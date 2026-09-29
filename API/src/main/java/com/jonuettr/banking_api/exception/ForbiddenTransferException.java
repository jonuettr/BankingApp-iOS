package com.jonuettr.banking_api.exception;


// Indica que el usuario sí está autenticado,
// pero intenta utilizar un recurso bancario
// que pertenece a otro cliente.
public class ForbiddenTransferException
        extends RuntimeException {

    public ForbiddenTransferException(
            String message) {

        super(message);
    }
}
