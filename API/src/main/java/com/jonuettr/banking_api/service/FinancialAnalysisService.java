package com.jonuettr.banking_api.service;

import com.jonuettr.banking_api.dto.FinancialAnalysisResponse;
import com.jonuettr.banking_api.entity.BankTransaction;

import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class FinancialAnalysisService {

    private final BankTransactionService transactionService;

    public FinancialAnalysisService(
            BankTransactionService transactionService) {

        this.transactionService = transactionService;
    }

    public FinancialAnalysisResponse analyzeCustomer(
            Integer customerId) {

        List<BankTransaction> transactions =
                transactionService.getTransactionsByCustomerId(customerId);

        BigDecimal totalIncome = BigDecimal.ZERO;
        BigDecimal totalExpenses = BigDecimal.ZERO;

        Map<String, BigDecimal> expensesByCategory =
                new LinkedHashMap<>();

        for (BankTransaction transaction : transactions) {

            if (!"completed".equals(transaction.getStatus())) {
                continue;
            }

            if ("deposit".equals(transaction.getType())) {

                totalIncome =
                        totalIncome.add(transaction.getAmount());
            }

            if ("purchase".equals(transaction.getType())
                    || "directDebit".equals(transaction.getType())) {

                totalExpenses =
                        totalExpenses.add(transaction.getAmount());

                expensesByCategory.merge(
                        transaction.getCategory(),
                        transaction.getAmount(),
                        BigDecimal::add
                );
            }
        }

        BigDecimal netCashFlow =
                totalIncome.subtract(totalExpenses);

        return new FinancialAnalysisResponse(
                totalIncome,
                totalExpenses,
                netCashFlow,
                expensesByCategory
        );
    }
}