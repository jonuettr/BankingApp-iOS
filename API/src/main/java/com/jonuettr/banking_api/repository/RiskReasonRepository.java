package com.jonuettr.banking_api.repository;

import com.jonuettr.banking_api.entity.RiskReason;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;


// Repository para los motivos individuales
// de una evaluación de riesgo.
public interface RiskReasonRepository
        extends JpaRepository<RiskReason, Integer> {

    // Obtiene todos los motivos asociados
    // a una evaluación determinada.
    List<RiskReason> findByRiskEvaluationId(
            Integer riskEvaluationId
    );
}
