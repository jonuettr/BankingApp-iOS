package com.jonuettr.banking_api.service;

import com.jonuettr.banking_api.entity.Account;
import com.jonuettr.banking_api.repository.AccountRepository;
import java.util.Optional;

import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AccountService {

    private final AccountRepository accountRepository;

    public AccountService(AccountRepository accountRepository) {
        this.accountRepository = accountRepository;
    }

    public List<Account> getAccountsByCustomerId(Integer customerId) {

        return accountRepository.findByCustomerId(customerId);
    }

    public Optional<Account> getAccountById(Integer accountId) {
        return accountRepository.findById(accountId);
    }

    public Optional<Account> getAccountByIdForUpdate(Integer accountId) {
        return accountRepository.findByIdForUpdate(accountId);
    }
}