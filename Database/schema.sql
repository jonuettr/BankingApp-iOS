-- ============================================================
-- BankingApp
-- Database Schema
-- ============================================================

-- ============================================================
-- CUSTOMER
-- ============================================================

CREATE DATABASE IF NOT EXISTS banking_app
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE banking_app;
    
CREATE TABLE CUSTOMER (

    -- Identificador único del cliente.
    id_customer INT PRIMARY KEY,

    -- Datos personales básicos.
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,

    -- No permitimos dos clientes con
    -- el mismo correo electrónico.
    email VARCHAR(255) NOT NULL UNIQUE,

    -- Permite desactivar un cliente
    -- sin eliminar físicamente su información.
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- ACCOUNT
-- ============================================================

CREATE TABLE ACCOUNT (

    id_account INT PRIMARY KEY,

    -- Cliente propietario de la cuenta.
    id_customer INT NOT NULL,

    -- checking = cuenta corriente/digital
    -- savings  = cuenta de ahorro
    account_type VARCHAR(20) NOT NULL,

    account_name VARCHAR(100) NOT NULL,

    -- Solo almacenaremos los últimos cuatro
    -- dígitos que mostramos en la aplicación.
    last_four_digits CHAR(4) NOT NULL,

    -- Para dinero evitamos FLOAT/DOUBLE.
    balance DECIMAL(12, 2) NOT NULL DEFAULT 0.00,

    currency CHAR(3) NOT NULL DEFAULT 'MXN',

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,


    -- Relación:
    --
    -- CUSTOMER 1 ───── N ACCOUNT
    CONSTRAINT fk_account_customer
        FOREIGN KEY (id_customer)
        REFERENCES CUSTOMER(id_customer),


    -- Solo permitimos los tipos utilizados
    -- actualmente por BankingApp.
    CONSTRAINT chk_account_type
        CHECK (
            account_type IN (
                'checking',
                'savings'
            )
        ),


    -- Una cuenta bancaria no puede tener
    -- saldo negativo en este proyecto.
    CONSTRAINT chk_account_balance
        CHECK (
            balance >= 0
        )
);


-- ============================================================
-- CREDIT_CARD
-- ============================================================

CREATE TABLE CREDIT_CARD (

    id_credit_card INT PRIMARY KEY,

    id_customer INT NOT NULL,

    card_name VARCHAR(100) NOT NULL,

    last_four_digits CHAR(4) NOT NULL,

    credit_limit DECIMAL(12, 2) NOT NULL,

    current_balance DECIMAL(12, 2) NOT NULL DEFAULT 0.00,

    minimum_payment DECIMAL(12, 2) NOT NULL DEFAULT 0.00,

    payment_to_avoid_interest DECIMAL(12, 2) NOT NULL DEFAULT 0.00,

    statement_day INT NOT NULL,

    payment_due_day INT NOT NULL,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,


    CONSTRAINT fk_credit_card_customer
        FOREIGN KEY (id_customer)
        REFERENCES CUSTOMER(id_customer),


    CONSTRAINT chk_credit_limit
        CHECK (
            credit_limit > 0
        ),


    CONSTRAINT chk_credit_balance
        CHECK (
            current_balance >= 0
        ),


    -- Los días deben representar
    -- un día válido posible del mes.
    CONSTRAINT chk_statement_day
        CHECK (
            statement_day BETWEEN 1 AND 31
        ),


    CONSTRAINT chk_payment_due_day
        CHECK (
            payment_due_day BETWEEN 1 AND 31
        )
);

-- ============================================================
-- BANK_TRANSACTION
-- ============================================================

CREATE TABLE BANK_TRANSACTION (

    id_transaction INT AUTO_INCREMENT PRIMARY KEY,

    -- Uno de estos dos campos tendrá valor
    -- y el otro deberá ser NULL.
    id_account INT NULL,
    id_credit_card INT NULL,

    description VARCHAR(255) NOT NULL,

    amount DECIMAL(12, 2) NOT NULL,

    transaction_type VARCHAR(30) NOT NULL,

    category VARCHAR(30) NOT NULL,

    transaction_status VARCHAR(20) NOT NULL,

    transaction_date TIMESTAMP NOT NULL,

    merchant VARCHAR(150) NULL,

    reference VARCHAR(100) NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,


    -- ========================================================
    -- Foreign Keys
    -- ========================================================

    CONSTRAINT fk_transaction_account
        FOREIGN KEY (id_account)
        REFERENCES ACCOUNT(id_account),


    CONSTRAINT fk_transaction_credit_card
        FOREIGN KEY (id_credit_card)
        REFERENCES CREDIT_CARD(id_credit_card),


    -- ========================================================
    -- Product validation
    -- ========================================================

    CONSTRAINT chk_transaction_product
        CHECK (

            (
                id_account IS NOT NULL
                AND
                id_credit_card IS NULL
            )

            OR

            (
                id_account IS NULL
                AND
                id_credit_card IS NOT NULL
            )
        ),

    CONSTRAINT chk_transaction_amount
        CHECK (
            amount > 0
        ),

    CONSTRAINT chk_transaction_type
        CHECK (
            transaction_type IN (
                'purchase',
                'deposit',
                'transferOut',
                'transferIn',
                'directDebit',
                'creditCardPayment'
            )
        ),

    CONSTRAINT chk_transaction_category
        CHECK (
            category IN (
                'income',
                'food',
                'transportation',
                'entertainment',
                'shopping',
                'services',
                'health',
                'transfers',
                'financial',
                'other'
            )
        ),

    CONSTRAINT chk_transaction_status
        CHECK (
            transaction_status IN (
                'pending',
                'completed',
                'declined'
            )
        )
);

-- ============================================================
-- BENEFICIARY
-- ============================================================

CREATE TABLE BENEFICIARY (

    id_beneficiary INT PRIMARY KEY,

    -- Cliente propietario de la agenda
    -- de beneficiarios.
    id_owner_customer INT NOT NULL,

    beneficiary_name VARCHAR(150) NOT NULL,

    bank_name VARCHAR(150) NOT NULL,

    -- En México una CLABE contiene 18 dígitos.
    --
    -- Usamos CHAR y no un tipo numérico porque
    -- no realizaremos operaciones matemáticas
    -- con este valor.
    clabe CHAR(18) NOT NULL,

    id_destination_customer INT NULL,
    id_destination_account INT NULL,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,


    -- Cliente que registró al beneficiario.
    CONSTRAINT fk_beneficiary_owner
        FOREIGN KEY (id_owner_customer)
        REFERENCES CUSTOMER(id_customer),


    -- Cliente destino, cuando sea interno.
    CONSTRAINT fk_beneficiary_destination_customer
        FOREIGN KEY (id_destination_customer)
        REFERENCES CUSTOMER(id_customer),


    -- Cuenta destino, cuando sea interna.
    CONSTRAINT fk_beneficiary_destination_account
        FOREIGN KEY (id_destination_account)
        REFERENCES ACCOUNT(id_account),


    -- Una misma CLABE no puede aparecer dos veces
    -- en la agenda del mismo cliente.
    CONSTRAINT uq_beneficiary_owner_clabe
        UNIQUE (
            id_owner_customer,
            clabe
        ),

    CONSTRAINT chk_beneficiary_internal_destination
        CHECK (

            (
                id_destination_customer IS NULL
                AND
                id_destination_account IS NULL
            )

            OR

            (
                id_destination_customer IS NOT NULL
                AND
                id_destination_account IS NOT NULL
            )
        )
);

-- ============================================================
-- DEVICE
-- ============================================================

CREATE TABLE DEVICE (

    id_device INT PRIMARY KEY,

    id_customer INT NOT NULL,

    device_name VARCHAR(150) NOT NULL,

    device_type VARCHAR(20) NOT NULL,

    device_identifier VARCHAR(255) NOT NULL UNIQUE,

    is_trusted BOOLEAN NOT NULL DEFAULT FALSE,

    registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    last_access_at TIMESTAMP NULL,


    CONSTRAINT fk_device_customer
        FOREIGN KEY (id_customer)
        REFERENCES CUSTOMER(id_customer),


    CONSTRAINT chk_device_type
        CHECK (
            device_type IN (
                'iPhone',
                'iPad'
            )
        )
);
-- ============================================================
-- TRANSFER
-- ============================================================

CREATE TABLE TRANSFER (

    id_transfer INT AUTO_INCREMENT PRIMARY KEY,

    -- Cuenta desde la que sale el dinero.
    id_source_account INT NOT NULL,

    -- Beneficiario seleccionado por el cliente.
    id_beneficiary INT NOT NULL,

    -- Monto de la transferencia.
    amount DECIMAL(12, 2) NOT NULL,

    concept VARCHAR(255) NOT NULL,

    -- Referencia visible de la operación.
    reference VARCHAR(100) NULL,

    transfer_status VARCHAR(20) NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Mientras la transferencia no termine,
    -- este valor puede permanecer NULL.
    completed_at TIMESTAMP NULL,


    -- ========================================================
    -- Foreign Keys
    -- ========================================================

    CONSTRAINT fk_transfer_source_account
        FOREIGN KEY (id_source_account)
        REFERENCES ACCOUNT(id_account),


    CONSTRAINT fk_transfer_beneficiary
        FOREIGN KEY (id_beneficiary)
        REFERENCES BENEFICIARY(id_beneficiary),


    -- ========================================================
    -- Validations
    -- ========================================================

    CONSTRAINT chk_transfer_amount
        CHECK (
            amount > 0
        ),

    CONSTRAINT chk_transfer_status
        CHECK (
            transfer_status IN (
                'created',
                'processing',
                'completed',
                'declined'
            )
        ),

    CONSTRAINT chk_transfer_dates
        CHECK (
            completed_at IS NULL
            OR
            completed_at >= created_at
        )
);
-- ============================================================
-- RISK_EVALUATION
-- ============================================================

CREATE TABLE RISK_EVALUATION (

    id_risk_evaluation INT AUTO_INCREMENT PRIMARY KEY,

    -- Transferencia evaluada.
    id_transfer INT NOT NULL,

    -- Puntaje producido por el motor
    -- de reglas.
    risk_score INT NOT NULL,

    risk_level VARCHAR(20) NOT NULL,

    -- Indica si necesitamos una
    -- verificación adicional.
    requires_verification BOOLEAN NOT NULL DEFAULT FALSE,

    evaluated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,


    CONSTRAINT fk_risk_transfer
        FOREIGN KEY (id_transfer)
        REFERENCES TRANSFER(id_transfer),


    -- Nuestro score nunca puede
    -- ser negativo.
    CONSTRAINT chk_risk_score
        CHECK (
            risk_score >= 0
        ),

    CONSTRAINT chk_risk_level
        CHECK (
            risk_level IN (
                'low',
                'medium',
                'high'
            )
        )
);

-- ============================================================
-- RISK_REASON
-- ============================================================
--
-- Una evaluación de riesgo puede tener varias razones.
-- Por ejemplo:
--   - Monto mayor a $20,000
--   - Dispositivo no confiable
--   - Beneficiario nuevo
-- ============================================================

CREATE TABLE RISK_REASON (

    id_risk_reason INT AUTO_INCREMENT PRIMARY KEY,

    -- Evaluación a la que pertenece esta razón.
    id_risk_evaluation INT NOT NULL,

    -- Descripción de la regla que incrementó
    -- el nivel de riesgo.
    reason VARCHAR(255) NOT NULL,

    CONSTRAINT fk_risk_reason_evaluation
        FOREIGN KEY (id_risk_evaluation)
        REFERENCES RISK_EVALUATION(id_risk_evaluation)
);
-- =========================================================
-- AUTH_CREDENTIAL
-- =========================================================
-- Almacena las credenciales utilizadas para autenticación.
--
-- IMPORTANTE:
-- Nunca almacenamos la contraseña original.
-- password_hash contendrá únicamente el hash generado
-- mediante BCrypt.
--
-- La relación con CUSTOMER es 1:1.
-- =========================================================

CREATE TABLE AUTH_CREDENTIAL (

    id_credential INT AUTO_INCREMENT PRIMARY KEY,

    id_customer INT NOT NULL,

    password_hash VARCHAR(255) NOT NULL,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP NOT NULL
        DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_auth_customer
        UNIQUE (id_customer),

    CONSTRAINT fk_auth_customer
        FOREIGN KEY (id_customer)
        REFERENCES CUSTOMER(id_customer)
);
