package com.jonuettr.banking_api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;


// Representa una razón específica que contribuyó
// al riesgo de una transferencia.
//
// Una evaluación puede tener varias razones.
//
// Ejemplo:
//
// Evaluación 15
// ├── "Amount greater than $20,000"
// └── "Untrusted device"
@Entity
@Table(name = "RISK_REASON")
public class RiskReason {

    // ID generado automáticamente por MySQL.
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_risk_reason")
    private Integer id;


    // Evaluación de riesgo a la que pertenece
    // este motivo.
    @Column(name = "id_risk_evaluation", nullable = false)
    private Integer riskEvaluationId;


    // Descripción de la regla que aumentó
    // la puntuación de riesgo.
    @Column(name = "reason", nullable = false)
    private String reason;


    // Constructor vacío requerido por JPA.
    public RiskReason() {
    }


    // Constructor para crear un motivo nuevo.
    //
    // No recibimos id porque MySQL lo genera
    // automáticamente.
    public RiskReason(
            Integer riskEvaluationId,
            String reason) {

        this.riskEvaluationId = riskEvaluationId;
        this.reason = reason;
    }


    public Integer getId() {
        return id;
    }

    public Integer getRiskEvaluationId() {
        return riskEvaluationId;
    }

    public String getReason() {
        return reason;
    }
}
