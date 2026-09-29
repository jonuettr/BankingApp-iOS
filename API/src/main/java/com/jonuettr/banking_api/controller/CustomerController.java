package com.jonuettr.banking_api.controller;

import com.jonuettr.banking_api.dto.FinancialAnalysisResponse;
import com.jonuettr.banking_api.entity.Account;
import com.jonuettr.banking_api.entity.BankTransaction;
import com.jonuettr.banking_api.entity.CreditCard;
import com.jonuettr.banking_api.entity.Customer;
import com.jonuettr.banking_api.service.AccountService;
import com.jonuettr.banking_api.service.BankTransactionService;
import com.jonuettr.banking_api.service.CreditCardService;
import com.jonuettr.banking_api.service.CustomerService;
import com.jonuettr.banking_api.service.FinancialAnalysisService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;


@RestController
@RequestMapping("/api/customers")
public class CustomerController {

    private final CustomerService customerService;
    private final AccountService accountService;
    private final CreditCardService creditCardService;
    private final BankTransactionService transactionService;
    private final FinancialAnalysisService financialAnalysisService;


    public CustomerController(
            CustomerService customerService,
            AccountService accountService,
            CreditCardService creditCardService,
            BankTransactionService transactionService,
            FinancialAnalysisService financialAnalysisService) {

        this.customerService =
                customerService;

        this.accountService =
                accountService;

        this.creditCardService =
                creditCardService;

        this.transactionService =
                transactionService;

        this.financialAnalysisService =
                financialAnalysisService;
    }


    // Comprueba que el cliente autenticado sea el mismo
    // cliente solicitado en la URL.
    //
    // JwtAuthenticationFilter guardó como principal
    // el customerId extraído del JWT.
    private boolean ownsResource(
            Integer requestedCustomerId,
            Authentication authentication) {

        Integer authenticatedCustomerId =
                (Integer) authentication.getPrincipal();

        return authenticatedCustomerId.equals(
                requestedCustomerId
        );
    }


    @GetMapping("/{id}")
    public ResponseEntity<Customer> getCustomerById(
            @PathVariable Integer id,
            Authentication authentication) {

        if (!ownsResource(id, authentication)) {

            return ResponseEntity
                    .status(HttpStatus.FORBIDDEN)
                    .build();
        }

        return customerService
                .getCustomerById(id)
                .map(ResponseEntity::ok)
                .orElseGet(
                        () ->
                            ResponseEntity
                                    .notFound()
                                    .build()
                );
    }


    @GetMapping("/{id}/accounts")
    public ResponseEntity<List<Account>> getCustomerAccounts(
            @PathVariable Integer id,
            Authentication authentication) {

        if (!ownsResource(id, authentication)) {

            return ResponseEntity
                    .status(HttpStatus.FORBIDDEN)
                    .build();
        }

        if (customerService
                .getCustomerById(id)
                .isEmpty()) {

            return ResponseEntity
                    .notFound()
                    .build();
        }

        return ResponseEntity.ok(
                accountService
                        .getAccountsByCustomerId(id)
        );
    }


    @GetMapping("/{id}/credit-cards")
    public ResponseEntity<List<CreditCard>>
    getCustomerCreditCards(
            @PathVariable Integer id,
            Authentication authentication) {

        if (!ownsResource(id, authentication)) {

            return ResponseEntity
                    .status(HttpStatus.FORBIDDEN)
                    .build();
        }

        if (customerService
                .getCustomerById(id)
                .isEmpty()) {

            return ResponseEntity
                    .notFound()
                    .build();
        }

        return ResponseEntity.ok(
                creditCardService
                        .getCreditCardsByCustomerId(id)
        );
    }


    @GetMapping("/{id}/transactions")
    public ResponseEntity<List<BankTransaction>>
    getCustomerTransactions(
            @PathVariable Integer id,
            Authentication authentication) {

        if (!ownsResource(id, authentication)) {

            return ResponseEntity
                    .status(HttpStatus.FORBIDDEN)
                    .build();
        }

        if (customerService
                .getCustomerById(id)
                .isEmpty()) {

            return ResponseEntity
                    .notFound()
                    .build();
        }

        return ResponseEntity.ok(
                transactionService
                        .getTransactionsByCustomerId(id)
        );
    }


    @GetMapping("/{id}/analysis")
    public ResponseEntity<FinancialAnalysisResponse>
    getCustomerAnalysis(
            @PathVariable Integer id,
            Authentication authentication) {

        if (!ownsResource(id, authentication)) {

            return ResponseEntity
                    .status(HttpStatus.FORBIDDEN)
                    .build();
        }

        if (customerService
                .getCustomerById(id)
                .isEmpty()) {

            return ResponseEntity
                    .notFound()
                    .build();
        }

        FinancialAnalysisResponse analysis =
                financialAnalysisService
                        .analyzeCustomer(id);

        return ResponseEntity.ok(analysis);
    }
}
