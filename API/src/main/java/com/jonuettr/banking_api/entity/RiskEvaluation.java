package com.jonuettr.banking_api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;


// Representa el resultado de evaluar el riesgo
// de una transferencia.
//
// Ejemplo:
//
// Transferencia: $25,000
// Puntuación:    30
// Nivel:         medium
// Verificación:  no
@Entity
@Table(name = "RISK_EVALUATION")
public class RiskEvaluation {

    // MySQL genera este ID automáticamente
    // mediante AUTO_INCREMENT.
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_risk_evaluation")
    private Integer id;


    // Transferencia que fue evaluada.
    @Column(name = "id_transfer", nullable = false)
    private Integer transferId;


    // Puntuación total obtenida al aplicar
    // nuestras diferentes reglas de riesgo.
    //
    // Ejemplo:
    // monto alto        +30
    // dispositivo nuevo +25
    // ---------------------
    // total              55
    @Column(name = "risk_score", nullable = false)
    private Integer score;


    // Clasificación obtenida a partir del score:
    //
    // low
    // medium
    // high
    @Column(name = "risk_level", nullable = false)
    private String level;


    // true  = necesitamos una verificación adicional.
    // false = la operación puede continuar normalmente.
    @Column(name = "requires_verification", nullable = false)
    private Boolean requiresVerification;


    // Momento en que realizamos la evaluación.
    @Column(name = "evaluated_at", nullable = false)
    private LocalDateTime evaluatedAt;


    // Constructor vacío requerido por JPA.
    public RiskEvaluation() {
    }


    // Constructor que utilizaremos desde nuestro
    // motor de riesgo para crear una evaluación nueva.
    //
    // No recibimos id porque MySQL lo genera.
    public RiskEvaluation(
            Integer transferId,
            Integer score,
            String level,
            Boolean requiresVerification,
            LocalDateTime evaluatedAt) {

        this.transferId = transferId;
        this.score = score;
        this.level = level;
        this.requiresVerification = requiresVerification;
        this.evaluatedAt = evaluatedAt;
    }


    public Integer getId() {
        return id;
    }

    public Integer getTransferId() {
        return transferId;
    }

    public Integer getScore() {
        return score;
    }

    public String getLevel() {
        return level;
    }

    public Boolean getRequiresVerification() {
        return requiresVerification;
    }

    public LocalDateTime getEvaluatedAt() {
        return evaluatedAt;
    }
}
