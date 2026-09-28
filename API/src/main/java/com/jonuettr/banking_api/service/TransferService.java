package com.jonuettr.banking_api.service;

import com.jonuettr.banking_api.dto.TransferRequest;
import com.jonuettr.banking_api.dto.TransferResponse;
import com.jonuettr.banking_api.entity.Account;
import com.jonuettr.banking_api.entity.Beneficiary;
import com.jonuettr.banking_api.entity.BankTransaction;
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

    public TransferService(
        TransferRepository transferRepository,
        AccountService accountService,
        BeneficiaryService beneficiaryService,
        BankTransactionService bankTransactionService) {

    this.transferRepository = transferRepository;
    this.accountService = accountService;
    this.beneficiaryService = beneficiaryService;
    this.bankTransactionService = bankTransactionService;
     }

    @Transactional
    public TransferResponse createTransfer(TransferRequest request) {

        // -----------------------------------------------------
        // 1. BLOQUEAR CUENTA ORIGEN
        // -----------------------------------------------------

        Account sourceAccount = accountService
                .getAccountByIdForUpdate(request.getSourceAccountId())
                .orElseThrow(() ->
                        new InvalidTransferException(
                                "Source account does not exist"
                        )
                );


        // -----------------------------------------------------
        // 2. VALIDAR CUENTA ORIGEN
        // -----------------------------------------------------

        if (!Boolean.TRUE.equals(sourceAccount.getActive())) {
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

        Beneficiary beneficiary = beneficiaryService
                .getActiveBeneficiary(
                        request.getBeneficiaryId(),
                        sourceAccount.getCustomerId()
                )
                .orElseThrow(() ->
                        new InvalidTransferException(
                                "Beneficiary does not exist "
                                + "or does not belong to this customer"
                        )
                );


        if (!beneficiary.isInternal()) {
            throw new InvalidTransferException(
                    "External transfers are not supported yet"
            );
        }


        // -----------------------------------------------------
        // 5. EVITAR TRANSFERENCIA A LA MISMA CUENTA
        // -----------------------------------------------------

        if (sourceAccount.getId().equals(
                beneficiary.getDestinationAccountId())) {

            throw new InvalidTransferException(
                    "Source and destination accounts cannot be the same"
            );
        }


        // -----------------------------------------------------
        // 6. BLOQUEAR CUENTA DESTINO
        // -----------------------------------------------------

        Account destinationAccount = accountService
                .getAccountByIdForUpdate(
                        beneficiary.getDestinationAccountId()
                )
                .orElseThrow(() ->
                        new InvalidTransferException(
                                "Destination account does not exist"
                        )
                );


        if (!Boolean.TRUE.equals(destinationAccount.getActive())) {
            throw new InvalidTransferException(
                    "Destination account is not active"
            );
        }


        if (!destinationAccount.getCustomerId().equals(
                beneficiary.getDestinationCustomerId())) {

            throw new InvalidTransferException(
                    "Beneficiary destination data is inconsistent"
            );
        }


        // -----------------------------------------------------
        // 7. MODIFICAR SALDOS
        // -----------------------------------------------------

        sourceAccount.debit(request.getAmount());

        destinationAccount.credit(request.getAmount());


        // -----------------------------------------------------
        // 8. CREAR REGISTRO DE TRANSFERENCIA
        // -----------------------------------------------------

           LocalDateTime now = LocalDateTime.now();

       Transfer transfer = new Transfer(
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
                transferRepository.save(transfer);

// -----------------------------------------------------
// 9. CREAR MOVIMIENTO DE SALIDA
// -----------------------------------------------------

BankTransaction outgoingTransaction =
        new BankTransaction(
                sourceAccount.getId(),
                null,
                "Transferencia a " + beneficiary.getName(),
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
// 10. CREAR MOVIMIENTO DE ENTRADA
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
        // 11. CONSTRUIR RESPUESTA
        // -----------------------------------------------------

        return new TransferResponse(
                savedTransfer.getId(),
                savedTransfer.getSourceAccountId(),
                savedTransfer.getBeneficiaryId(),
                savedTransfer.getAmount(),
                savedTransfer.getConcept(),
                savedTransfer.getReference(),
                savedTransfer.getStatus(),
                savedTransfer.getCreatedAt()
        );
    }
}