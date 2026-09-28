package com.jonuettr.banking_api.dto;

import java.math.BigDecimal;
import java.util.Map;

public class FinancialAnalysisResponse {

    private final BigDecimal totalIncome;
    private final BigDecimal totalExpenses;
    private final BigDecimal netCashFlow;

    private final Map<String, BigDecimal> expensesByCategory;

    public FinancialAnalysisResponse(
            BigDecimal totalIncome,
            BigDecimal totalExpenses,
            BigDecimal netCashFlow,
            Map<String, BigDecimal> expensesByCategory) {

        this.totalIncome = totalIncome;
        this.totalExpenses = totalExpenses;
        this.netCashFlow = netCashFlow;
        this.expensesByCategory = expensesByCategory;
    }

    public BigDecimal getTotalIncome() {
        return totalIncome;
    }

    public BigDecimal getTotalExpenses() {
        return totalExpenses;
    }

    public BigDecimal getNetCashFlow() {
        return netCashFlow;
    }

    public Map<String, BigDecimal> getExpensesByCategory() {
        return expensesByCategory;
    }
}