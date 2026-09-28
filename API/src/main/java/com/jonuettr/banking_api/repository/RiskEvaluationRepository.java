package com.jonuettr.banking_api.repository;

import com.jonuettr.banking_api.entity.RiskEvaluation;

import org.springframework.data.jpa.repository.JpaRepository;


// Repository para guardar y consultar
// evaluaciones de riesgo.
public interface RiskEvaluationRepository
        extends JpaRepository<RiskEvaluation, Integer> {
}
