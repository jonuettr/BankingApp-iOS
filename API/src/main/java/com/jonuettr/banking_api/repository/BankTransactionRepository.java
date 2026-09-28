package com.jonuettr.banking_api.repository;

import com.jonuettr.banking_api.entity.BankTransaction;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface BankTransactionRepository
        extends JpaRepository<BankTransaction, Integer> {

    List<BankTransaction>
    findByAccountIdOrderByDateDesc(Integer accountId);

    List<BankTransaction>
    findByCreditCardIdOrderByDateDesc(Integer creditCardId);


    // ---------------------------------------------------------
    // MOVIMIENTOS COMPLETOS DE UN CLIENTE
    // ---------------------------------------------------------

    @Query(value = """
            SELECT T.*
            FROM BANK_TRANSACTION T
            LEFT JOIN ACCOUNT A
                ON T.id_account = A.id_account
            LEFT JOIN CREDIT_CARD C
                ON T.id_credit_card = C.id_credit_card
            WHERE A.id_customer = :customerId
               OR C.id_customer = :customerId
            ORDER BY T.transaction_date DESC
            """,
            nativeQuery = true)
    List<BankTransaction> findAllByCustomerId(
            @Param("customerId") Integer customerId);
}