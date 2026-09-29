package com.jonuettr.banking_api.service;

import com.jonuettr.banking_api.dto.RiskAssessment;
import com.jonuettr.banking_api.dto.TransferRequest;
import com.jonuettr.banking_api.dto.TransferResponse;
import com.jonuettr.banking_api.exception.ForbiddenTransferException;
import com.jonuettr.banking_api.entity.Account;
import com.jonuettr.banking_api.entity.BankTransaction;
import com.jonuettr.banking_api.entity.Beneficiary;
import com.jonuettr.banking_api.entity.Device;
import com.jonuettr.banking_api.entity.Transfer;

import com.jonuettr.banking_api.exception.InsufficientFundsException;
import com.jonuettr.banking_api.exception.InvalidTransferException;

import com.jonuettr.banking_api.repository.TransferRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;


@Service
public class TransferService {

    private final TransferRepository transferRepository;
    private final AccountService accountService;
    private final BeneficiaryService beneficiaryService;
    private final BankTransactionService bankTransactionService;

    // Nuevos servicios utilizados por el módulo de riesgo.
    private final DeviceService deviceService;
    private final RiskEngineService riskEngineService;
    private final RiskEvaluationService riskEvaluationService;


    public TransferService(
            TransferRepository transferRepository,
            AccountService accountService,
            BeneficiaryService beneficiaryService,
            BankTransactionService bankTransactionService,
            DeviceService deviceService,
            RiskEngineService riskEngineService,
            RiskEvaluationService riskEvaluationService) {

        this.transferRepository = transferRepository;
        this.accountService = accountService;
        this.beneficiaryService = beneficiaryService;
        this.bankTransactionService = bankTransactionService;
        this.deviceService = deviceService;
        this.riskEngineService = riskEngineService;
        this.riskEvaluationService = riskEvaluationService;
    }


    @Transactional
public TransferResponse createTransfer(
        TransferRequest request,
        Integer authenticatedCustomerId) {
        // Usaremos exactamente el mismo instante para
        // evaluar y registrar esta operación.
        LocalDateTime now = LocalDateTime.now();


        // -----------------------------------------------------
        // 1. OBTENER Y BLOQUEAR CUENTA ORIGEN
        // -----------------------------------------------------

        Account sourceAccount =
                accountService
                        .getAccountByIdForUpdate(
                                request.getSourceAccountId()
                        )
                        .orElseThrow(() ->
                                new InvalidTransferException(
                                        "Source account does not exist"
                                )
                        );
// -----------------------------------------------------
// AUTORIZACIÓN DEL PROPIETARIO
// -----------------------------------------------------

// sourceAccountId sí viene del cliente iOS,
// por lo que no podemos confiar en él para determinar
// quién tiene derecho a utilizar esa cuenta.
//
// authenticatedCustomerId, en cambio, proviene del JWT
// previamente verificado por el backend.
if (!sourceAccount
        .getCustomerId()
        .equals(authenticatedCustomerId)) {

    throw new ForbiddenTransferException(
            "Source account does not belong "
                    + "to authenticated customer"
    );
}

        // -----------------------------------------------------
        // 2. VALIDAR CUENTA ORIGEN
        // -----------------------------------------------------

        if (!Boolean.TRUE.equals(
                sourceAccount.getActive())) {

            throw new InvalidTransferException(
                    "Source account is not active"
            );
        }


        // -----------------------------------------------------
        // 3. VALIDAR SALDO
        // -----------------------------------------------------

        if (request.getAmount()
                .compareTo(sourceAccount.getBalance()) > 0) {

            throw new InsufficientFundsException(
                    "Insufficient funds"
            );
        }


        // -----------------------------------------------------
        // 4. OBTENER BENEFICIARIO
        // -----------------------------------------------------

        Beneficiary beneficiary =
                beneficiaryService
                        .getActiveBeneficiary(
                                request.getBeneficiaryId(),
                                sourceAccount.getCustomerId()
                        )
                        .orElseThrow(() ->
                                new InvalidTransferException(
                                        "Beneficiary does not exist "
                                                + "or does not belong "
                                                + "to this customer"
                                )
                        );


        if (!beneficiary.isInternal()) {

            throw new InvalidTransferException(
                    "External transfers are not supported yet"
            );
        }


        // -----------------------------------------------------
        // 5. EVITAR MISMA CUENTA
        // -----------------------------------------------------

        if (sourceAccount.getId().equals(
                beneficiary.getDestinationAccountId())) {

            throw new InvalidTransferException(
                    "Source and destination accounts "
                            + "cannot be the same"
            );
        }


        // -----------------------------------------------------
        // 6. OBTENER Y BLOQUEAR CUENTA DESTINO
        // -----------------------------------------------------

        Account destinationAccount =
                accountService
                        .getAccountByIdForUpdate(
                                beneficiary
                                        .getDestinationAccountId()
                        )
                        .orElseThrow(() ->
                                new InvalidTransferException(
                                        "Destination account "
                                                + "does not exist"
                                )
                        );


        if (!Boolean.TRUE.equals(
                destinationAccount.getActive())) {

            throw new InvalidTransferException(
                    "Destination account is not active"
            );
        }


        if (!destinationAccount
                .getCustomerId()
                .equals(
                        beneficiary
                                .getDestinationCustomerId()
                )) {

            throw new InvalidTransferException(
                    "Beneficiary destination data "
                            + "is inconsistent"
            );
        }


        // -----------------------------------------------------
        // 7. VALIDAR DISPOSITIVO
        // -----------------------------------------------------

        // No basta con recibir un deviceIdentifier.
        //
        // Comprobamos que ese dispositivo realmente
        // esté registrado para el propietario de
        // la cuenta origen.
        Device device =
                deviceService
                        .getDevice(
                                request.getDeviceIdentifier(),
                                sourceAccount.getCustomerId()
                        )
                        .orElseThrow(() ->
                                new InvalidTransferException(
                                        "Device is not registered "
                                                + "for this customer"
                                )
                        );


        // -----------------------------------------------------
        // 8. EVALUAR RIESGO
        // -----------------------------------------------------

        // Todavía NO hemos movido dinero.
        //
        // Primero decidimos si la transferencia
        // puede ejecutarse o necesita verificación.
        RiskAssessment assessment =
                riskEngineService.evaluate(
                        request.getAmount(),
                        device,
                        beneficiary,
                        sourceAccount.getId(),
                        now
                );


        // -----------------------------------------------------
        // 9. CASO HIGH: NO MOVER DINERO
        // -----------------------------------------------------

        if (assessment.requiresVerification()) {

            Transfer pendingTransfer =
                    new Transfer(
                            sourceAccount.getId(),
                            beneficiary.getId(),
                            request.getAmount(),
                            request.getConcept(),
                            request.getReference(),
                            "processing",
                            now,
                            null
                    );


            Transfer savedTransfer =
                    transferRepository.save(
                            pendingTransfer
                    );


            // Guardamos tanto el score como las razones.
            riskEvaluationService.saveEvaluation(
                    savedTransfer.getId(),
                    assessment,
                    now
            );


            // IMPORTANTE:
            // No debitamos.
            // No acreditamos.
            // No creamos BANK_TRANSACTION.
            //
            // La operación queda esperando
            // verificación adicional.
            return buildResponse(
                    savedTransfer,
                    assessment
            );
        }


        // -----------------------------------------------------
        // 10. CASO LOW/MEDIUM: MOVER DINERO
        // -----------------------------------------------------

        sourceAccount.debit(
                request.getAmount()
        );

        destinationAccount.credit(
                request.getAmount()
        );


        // -----------------------------------------------------
        // 11. GUARDAR TRANSFERENCIA COMPLETADA
        // -----------------------------------------------------

        Transfer completedTransfer =
                new Transfer(
                        sourceAccount.getId(),
                        beneficiary.getId(),
                        request.getAmount(),
                        request.getConcept(),
                        request.getReference(),
                        "completed",
                        now,
                        now
                );


        Transfer savedTransfer =
                transferRepository.save(
                        completedTransfer
                );


        // -----------------------------------------------------
        // 12. GUARDAR EVALUACIÓN DE RIESGO
        // -----------------------------------------------------

        riskEvaluationService.saveEvaluation(
                savedTransfer.getId(),
                assessment,
                now
        );


        // -----------------------------------------------------
        // 13. MOVIMIENTO DE SALIDA
        // -----------------------------------------------------

        BankTransaction outgoingTransaction =
                new BankTransaction(
                        sourceAccount.getId(),
                        null,
                        "Transferencia a "
                                + beneficiary.getName(),
                        request.getAmount(),
                        "transferOut",
                        "transfers",
                        "completed",
                        now,
                        null,
                        request.getReference()
                );


        bankTransactionService.createTransaction(
                outgoingTransaction
        );


        // -----------------------------------------------------
        // 14. MOVIMIENTO DE ENTRADA
        // -----------------------------------------------------

        BankTransaction incomingTransaction =
                new BankTransaction(
                        destinationAccount.getId(),
                        null,
                        "Transferencia recibida",
                        request.getAmount(),
                        "transferIn",
                        "transfers",
                        "completed",
                        now,
                        null,
                        request.getReference()
                );


        bankTransactionService.createTransaction(
                incomingTransaction
        );


        // -----------------------------------------------------
        // 15. RESPUESTA
        // -----------------------------------------------------

        return buildResponse(
                savedTransfer,
                assessment
        );
    }


    // ---------------------------------------------------------
    // CONSTRUCTOR DE RESPUESTA
    // ---------------------------------------------------------

    // Centralizamos aquí la conversión para no repetir
    // el mismo código en HIGH y LOW/MEDIUM.
    private TransferResponse buildResponse(
            Transfer transfer,
            RiskAssessment assessment) {

        return new TransferResponse(
                transfer.getId(),
                transfer.getSourceAccountId(),
                transfer.getBeneficiaryId(),
                transfer.getAmount(),
                transfer.getConcept(),
                transfer.getReference(),
                transfer.getStatus(),
                transfer.getCreatedAt(),
                assessment.score(),
                assessment.level(),
                assessment.requiresVerification(),
                assessment.reasons()
        );
    }
}

