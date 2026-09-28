package com.jonuettr.banking_api.service;

import com.jonuettr.banking_api.dto.RiskAssessment;
import com.jonuettr.banking_api.entity.Beneficiary;
import com.jonuettr.banking_api.entity.Device;
import com.jonuettr.banking_api.repository.TransferRepository;

import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;


// Motor central de evaluación de riesgo.
//
// IMPORTANTE:
// Este servicio NO mueve dinero.
// Solamente analiza una solicitud y devuelve:
//
// - puntuación
// - nivel
// - si requiere verificación
// - razones que incrementaron el riesgo
//
// Así mantenemos separada la lógica de riesgo
// de la lógica bancaria.
@Service
public class RiskEngineService {

    // ---------------------------------------------------------
    // CONSTANTES DE LAS REGLAS
    // ---------------------------------------------------------

    private static final BigDecimal HIGH_AMOUNT_THRESHOLD =
            new BigDecimal("20000.00");

    private static final int HIGH_AMOUNT_POINTS = 30;
    private static final int UNTRUSTED_DEVICE_POINTS = 25;
    private static final int NEW_BENEFICIARY_POINTS = 20;
    private static final int FREQUENT_TRANSFERS_POINTS = 20;
    private static final int UNUSUAL_TIME_POINTS = 10;

    // Un beneficiario se considera nuevo durante
    // sus primeras 24 horas.
    private static final int NEW_BENEFICIARY_HOURS = 24;

    // Ventana utilizada para detectar transferencias frecuentes.
    private static final int FREQUENCY_WINDOW_MINUTES = 10;

    // La operación actual será la tercera si ya existen
    // dos transferencias anteriores dentro de la ventana.
    private static final long PREVIOUS_TRANSFERS_THRESHOLD = 2;

    // Consideramos horario inusual desde las 00:00
    // hasta antes de las 06:00.
    private static final int UNUSUAL_TIME_END_HOUR = 6;


    private final TransferRepository transferRepository;


    public RiskEngineService(
            TransferRepository transferRepository) {

        this.transferRepository = transferRepository;
    }


    // ---------------------------------------------------------
    // EVALUACIÓN PRINCIPAL
    // ---------------------------------------------------------

    public RiskAssessment evaluate(
            BigDecimal amount,
            Device device,
            Beneficiary beneficiary,
            Integer sourceAccountId,
            LocalDateTime evaluationTime) {

        int score = 0;

        List<String> reasons = new ArrayList<>();


        // -----------------------------------------------------
        // REGLA 1: MONTO ALTO
        // -----------------------------------------------------

        if (amount.compareTo(HIGH_AMOUNT_THRESHOLD) > 0) {

            score += HIGH_AMOUNT_POINTS;

            reasons.add(
                    "Transfer amount exceeds 20000 MXN"
            );
        }


        // -----------------------------------------------------
        // REGLA 2: DISPOSITIVO NO CONFIABLE
        // -----------------------------------------------------

        if (!Boolean.TRUE.equals(device.getTrusted())) {

            score += UNTRUSTED_DEVICE_POINTS;

            reasons.add(
                    "Transfer requested from an untrusted device"
            );
        }


        // -----------------------------------------------------
        // REGLA 3: BENEFICIARIO NUEVO
        // -----------------------------------------------------

        LocalDateTime beneficiaryThreshold =
                evaluationTime.minusHours(
                        NEW_BENEFICIARY_HOURS
                );

        // Si createdAt es posterior al límite,
        // el beneficiario tiene menos de 24 horas.
        if (beneficiary.getCreatedAt()
                .isAfter(beneficiaryThreshold)) {

            score += NEW_BENEFICIARY_POINTS;

            reasons.add(
                    "Beneficiary was registered less than 24 hours ago"
            );
        }


        // -----------------------------------------------------
        // REGLA 4: TRANSFERENCIAS FRECUENTES
        // -----------------------------------------------------

        LocalDateTime frequencyThreshold =
                evaluationTime.minusMinutes(
                        FREQUENCY_WINDOW_MINUTES
                );

        long recentTransfers =
                transferRepository
                        .countBySourceAccountIdAndCreatedAtAfter(
                                sourceAccountId,
                                frequencyThreshold
                        );

        // Estamos evaluando la operación ANTES de guardarla.
        //
        // Si existen dos transferencias previas,
        // la solicitud actual se convertiría en la tercera
        // dentro de los últimos 10 minutos.
        if (recentTransfers >= PREVIOUS_TRANSFERS_THRESHOLD) {

            score += FREQUENT_TRANSFERS_POINTS;

            reasons.add(
                    "Three or more transfers within 10 minutes"
            );
        }


        // -----------------------------------------------------
        // REGLA 5: HORARIO INUSUAL
        // -----------------------------------------------------

        int hour = evaluationTime.getHour();

        if (hour < UNUSUAL_TIME_END_HOUR) {

            score += UNUSUAL_TIME_POINTS;

            reasons.add(
                    "Transfer requested during unusual hours"
            );
        }


        // -----------------------------------------------------
        // CLASIFICACIÓN FINAL
        // -----------------------------------------------------

        String level;

        if (score >= 60) {

            level = "high";

        } else if (score >= 30) {

            level = "medium";

        } else {

            level = "low";
        }


        // Únicamente las operaciones de riesgo alto
        // necesitan verificación adicional.
        boolean requiresVerification =
                score >= 60;


        return new RiskAssessment(
                score,
                level,
                requiresVerification,
                List.copyOf(reasons)
        );
    }
}
