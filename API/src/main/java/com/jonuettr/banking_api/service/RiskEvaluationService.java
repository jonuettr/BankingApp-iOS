package com.jonuettr.banking_api.service;

import com.jonuettr.banking_api.dto.RiskAssessment;
import com.jonuettr.banking_api.entity.RiskEvaluation;
import com.jonuettr.banking_api.entity.RiskReason;
import com.jonuettr.banking_api.repository.RiskEvaluationRepository;
import com.jonuettr.banking_api.repository.RiskReasonRepository;

import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;


// Guarda en la base de datos el resultado producido
// previamente por RiskEngineService.
//
// RiskEngineService = calcula el riesgo.
// RiskEvaluationService = persiste el resultado.
//
// Mantener ambas responsabilidades separadas hace
// que la arquitectura sea más clara y fácil de probar.
@Service
public class RiskEvaluationService {

    private final RiskEvaluationRepository
            riskEvaluationRepository;

    private final RiskReasonRepository
            riskReasonRepository;


    public RiskEvaluationService(
            RiskEvaluationRepository riskEvaluationRepository,
            RiskReasonRepository riskReasonRepository) {

        this.riskEvaluationRepository =
                riskEvaluationRepository;

        this.riskReasonRepository =
                riskReasonRepository;
    }


    // Guarda una evaluación asociada a una transferencia.
    //
    // Primero guardamos RISK_EVALUATION porque necesitamos
    // su ID para relacionar posteriormente cada RISK_REASON.
    public RiskEvaluation saveEvaluation(
            Integer transferId,
            RiskAssessment assessment,
            LocalDateTime evaluatedAt) {

        RiskEvaluation evaluation =
                new RiskEvaluation(
                        transferId,
                        assessment.score(),
                        assessment.level(),
                        assessment.requiresVerification(),
                        evaluatedAt
                );


        // Después de save(), JPA nos devuelve la entidad
        // con id_risk_evaluation generado por MySQL.
        RiskEvaluation savedEvaluation =
                riskEvaluationRepository.save(evaluation);


        // Convertimos cada texto producido por el motor
        // en un registro de RISK_REASON.
        List<RiskReason> reasons =
                assessment.reasons()
                        .stream()
                        .map(reason ->
                                new RiskReason(
                                        savedEvaluation.getId(),
                                        reason
                                )
                        )
                        .toList();


        // Si el riesgo fue cero puede no existir ninguna razón.
        // Evitamos hacer una operación innecesaria.
        if (!reasons.isEmpty()) {

            riskReasonRepository.saveAll(reasons);
        }


        return savedEvaluation;
    }
}
