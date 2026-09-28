package com.jonuettr.banking_api.service;

import com.jonuettr.banking_api.entity.BankTransaction;
import com.jonuettr.banking_api.repository.BankTransactionRepository;

import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class BankTransactionService {

    private final BankTransactionRepository transactionRepository;

    public BankTransactionService(
            BankTransactionRepository transactionRepository) {

        this.transactionRepository = transactionRepository;
    }

    public List<BankTransaction> getTransactionsByAccountId(
            Integer accountId) {

        return transactionRepository
                .findByAccountIdOrderByDateDesc(accountId);
    }

    public List<BankTransaction> getTransactionsByCreditCardId(
            Integer creditCardId) {

        return transactionRepository
                .findByCreditCardIdOrderByDateDesc(creditCardId);
    }

    public List<BankTransaction> getTransactionsByCustomerId(
            Integer customerId) {

        return transactionRepository.findAllByCustomerId(customerId);
    }

    public BankTransaction createTransaction(
        BankTransaction transaction) {

        return transactionRepository.save(transaction);
    }
}