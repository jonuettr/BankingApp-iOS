package com.jonuettr.banking_api.dto;

import java.util.List;


// Resultado interno producido por el motor de riesgo.
//
// Usamos un "record" porque este objeto solamente
// transporta información y no necesita modificarla
// después de ser creado.
public record RiskAssessment(
        int score,
        String level,
        boolean requiresVerification,
        List<String> reasons
) {
}
