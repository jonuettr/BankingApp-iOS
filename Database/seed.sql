-- ============================================================
-- BANKINGAPP - SEED DATA
-- ============================================================
-- Datos ficticios utilizados para desarrollo y pruebas.
-- ============================================================

USE banking_app;


-- ============================================================
-- CUSTOMERS
-- ============================================================

INSERT INTO CUSTOMER (
    id_customer,
    first_name,
    last_name,
    email
)
VALUES
    (
        1,
        'Alex',
        'Rivera',
        'alex.rivera@bankingapp.test'
    ),
    (
        2,
        'Sofía',
        'Martínez',
        'sofia.martinez@bankingapp.test'
    ),
    (
        3,
        'Diego',
        'Hernández',
        'diego.hernandez@bankingapp.test'
    );


-- ============================================================
-- ACCOUNTS
-- ============================================================

INSERT INTO ACCOUNT (
    id_account,
    id_customer,
    account_type,
    account_name,
    last_four_digits,
    balance,
    currency
)
VALUES
    (
        101,
        1,
        'checking',
        'Cuenta Digital',
        '4821',
        48720.35,
        'MXN'
    ),
    (
        102,
        1,
        'savings',
        'Ahorro',
        '7314',
        92500.00,
        'MXN'
    ),
    (
        201,
        2,
        'checking',
        'Cuenta Digital',
        '1647',
        28850.90,
        'MXN'
    ),
    (
        301,
        3,
        'checking',
        'Cuenta Digital',
        '9052',
        63125.40,
        'MXN'
    ),
    (
        302,
        3,
        'savings',
        'Ahorro',
        '3378',
        150000.00,
        'MXN'
    );


-- ============================================================
-- CREDIT CARDS
-- ============================================================

INSERT INTO CREDIT_CARD (
    id_credit_card,
    id_customer,
    card_name,
    last_four_digits,
    credit_limit,
    current_balance,
    minimum_payment,
    payment_to_avoid_interest,
    statement_day,
    payment_due_day
)
VALUES
    (
        501,
        1,
        'Platinum',
        '5832',
        60000.00,
        13840.20,
        850.00,
        13840.20,
        15,
        5
    ),
    (
        502,
        2,
        'Gold',
        '2196',
        45000.00,
        7215.75,
        520.00,
        7215.75,
        20,
        10
    ),
    (
        503,
        3,
        'Platinum',
        '7741',
        100000.00,
        21480.50,
        1250.00,
        21480.50,
        12,
        2
    );
    
-- ============================================================
-- BENEFICIARIES
-- ============================================================

INSERT INTO BENEFICIARY (
    id_beneficiary,
    id_owner_customer,
    beneficiary_name,
    bank_name,
    clabe,
    id_destination_customer,
    id_destination_account
)
VALUES
    (
        701,
        1,
        'Sofía Martínez',
        'BankingApp',
        '012345678901234567',
        2,
        201
    ),
    (
        702,
        1,
        'Diego Hernández',
        'BankingApp',
        '012345678901234568',
        3,
        301
    );


-- ============================================================
-- DEVICES
-- ============================================================

INSERT INTO DEVICE (
    id_device,
    id_customer,
    device_name,
    device_type,
    device_identifier,
    is_trusted,
    registered_at,
    last_access_at
)
VALUES
    (
        801,
        1,
        'iPhone principal',
        'iPhone',
        'DEVICE-ALEX-001',
        TRUE,
        '2026-08-15 10:00:00',
        '2026-09-28 12:00:00'
    ),
    (
        802,
        1,
        'iPad nuevo',
        'iPad',
        'DEVICE-ALEX-002',
        FALSE,
        '2026-09-27 18:30:00',
        '2026-09-27 18:30:00'
    );
    
-- ============================================================
-- BANK TRANSACTIONS
-- ============================================================

INSERT INTO BANK_TRANSACTION (
    id_transaction,
    id_account,
    id_credit_card,
    description,
    amount,
    transaction_type,
    category,
    transaction_status,
    transaction_date,
    merchant,
    reference
)
VALUES

    -- Nómina recibida por Alex.
    (
        1001, 101, NULL,
        'Nómina',
        28500.00,
        'deposit',
        'income',
        'completed',
        '2026-09-25 08:30:00',
        NULL,
        'NOM-SEP-2026'
    ),

    -- Compra de supermercado.
    (
        1002, 101, NULL,
        'Supermercado',
        1248.60,
        'purchase',
        'food',
        'completed',
        '2026-09-26 18:15:00',
        'Mercado Central',
        NULL
    ),

    -- Pago domiciliado de internet.
    (
        1003, 101, NULL,
        'Servicio de internet',
        670.00,
        'directDebit',
        'services',
        'completed',
        '2026-09-26 07:00:00',
        'Internet Hogar',
        'SERV-0926'
    ),

    (
        1004, 101, NULL,
        'Restaurante',
        845.50,
        'purchase',
        'food',
        'completed',
        '2026-09-24 21:10:00',
        'Restaurante Central',
        NULL
    ),

    -- Salida de la cuenta corriente de Alex
    -- hacia su propia cuenta de ahorro.
    (
        1005, 101, NULL,
        'Transferencia a ahorro',
        5000.00,
        'transferOut',
        'transfers',
        'completed',
        '2026-09-23 10:45:00',
        NULL,
        'TRF-1005'
    ),

    -- Entrada correspondiente en la cuenta de ahorro.
    (
        1006, 102, NULL,
        'Transferencia recibida',
        5000.00,
        'transferIn',
        'transfers',
        'completed',
        '2026-09-23 10:45:00',
        NULL,
        'TRF-1005'
    ),

    -- A partir de aquí los movimientos pertenecen
    -- a la tarjeta 501, por eso id_account es NULL.

    (
        1007, NULL, 501,
        'Cafetería',
        185.00,
        'purchase',
        'food',
        'completed',
        '2026-09-27 09:20:00',
        'Café Central',
        NULL
    ),

    (
        1008, NULL, 501,
        'Streaming',
        299.00,
        'purchase',
        'entertainment',
        'completed',
        '2026-09-25 06:00:00',
        'Stream+',
        'SUB-0926'
    ),

    (
        1009, NULL, 501,
        'Gasolina',
        950.00,
        'purchase',
        'transportation',
        'completed',
        '2026-09-22 19:35:00',
        'Estación Central',
        NULL
    ),

    (
        1010, NULL, 501,
        'Compra en línea',
        2199.00,
        'purchase',
        'shopping',
        'pending',
        '2026-09-27 16:40:00',
        'Tienda Online',
        'WEB-1010'
    );
    
-- ============================================================
-- HISTORICAL TRANSACTIONS - ALEX RIVERA
-- ============================================================
-- 30 movimientos adicionales.
-- Sumados a los 10 movimientos iniciales,
-- Alex tendrá un historial de 40 transacciones.
-- ============================================================

INSERT INTO BANK_TRANSACTION (
    id_transaction,
    id_account,
    id_credit_card,
    description,
    amount,
    transaction_type,
    category,
    transaction_status,
    transaction_date,
    merchant,
    reference
)
VALUES

-- =========================
-- SEPTEMBER 2026
-- =========================

(1011, 101, NULL, 'Supermercado', 986.40,
 'purchase', 'food', 'completed',
 '2026-09-20 18:42:00', 'Supermercado del Valle', NULL),

(1012, NULL, 501, 'Restaurante', 620.00,
 'purchase', 'food', 'completed',
 '2026-09-18 20:35:00', 'Casa Norte', NULL),

(1013, 101, NULL, 'Telefonía móvil', 499.00,
 'directDebit', 'services', 'completed',
 '2026-09-16 07:15:00', 'Telefonía Móvil', 'TEL-SEP-2026'),

(1014, NULL, 501, 'Farmacia', 378.50,
 'purchase', 'health', 'completed',
 '2026-09-14 17:20:00', 'Farmacia Central', NULL),

(1015, 101, NULL, 'Transporte', 245.00,
 'purchase', 'transportation', 'completed',
 '2026-09-12 19:10:00', 'Movilidad Urbana', NULL),

(1016, NULL, 501, 'Compra de ropa', 1350.00,
 'purchase', 'shopping', 'completed',
 '2026-09-09 16:30:00', 'Moda Urbana', NULL),

(1017, 101, NULL, 'Electricidad', 815.00,
 'directDebit', 'services', 'completed',
 '2026-09-07 08:00:00', 'Energía Hogar', 'ELEC-SEP-2026'),

(1018, 101, NULL, 'Supermercado', 1125.75,
 'purchase', 'food', 'completed',
 '2026-09-04 19:25:00', 'Mercado Central', NULL),

(1019, NULL, 501, 'Cine', 410.00,
 'purchase', 'entertainment', 'completed',
 '2026-09-02 21:05:00', 'Cinema Center', NULL),

-- =========================
-- AUGUST 2026
-- =========================

(1020, 101, NULL, 'Nómina', 28500.00,
 'deposit', 'income', 'completed',
 '2026-08-25 08:30:00', NULL, 'NOM-AGO-2026'),

(1021, 101, NULL, 'Supermercado', 1376.20,
 'purchase', 'food', 'completed',
 '2026-08-23 17:50:00', 'Supermercado del Valle', NULL),

(1022, NULL, 501, 'Restaurante', 930.00,
 'purchase', 'food', 'completed',
 '2026-08-21 21:15:00', 'Terraza Centro', NULL),

(1023, 101, NULL, 'Servicio de internet', 670.00,
 'directDebit', 'services', 'completed',
 '2026-08-20 07:00:00', 'Internet Hogar', 'SERV-0826'),

(1024, NULL, 501, 'Plataforma de música', 129.00,
 'purchase', 'entertainment', 'completed',
 '2026-08-18 06:10:00', 'Music+', 'MUSIC-0826'),

(1025, 101, NULL, 'Gasolina', 875.00,
 'purchase', 'transportation', 'completed',
 '2026-08-15 18:45:00', 'Estación Central', NULL),

(1026, NULL, 501, 'Compra en línea', 1689.00,
 'purchase', 'shopping', 'completed',
 '2026-08-12 13:25:00', 'Tienda Online', NULL),

(1027, 101, NULL, 'Restaurante', 540.50,
 'purchase', 'food', 'completed',
 '2026-08-09 15:40:00', 'Cocina Urbana', NULL),

(1028, NULL, 501, 'Farmacia', 284.90,
 'purchase', 'health', 'completed',
 '2026-08-06 19:30:00', 'Farmacia Central', NULL),

(1029, 101, NULL, 'Supermercado', 1040.35,
 'purchase', 'food', 'completed',
 '2026-08-03 18:20:00', 'Mercado Central', NULL),

-- =========================
-- JULY 2026
-- =========================

(1030, 101, NULL, 'Nómina', 28500.00,
 'deposit', 'income', 'completed',
 '2026-07-25 08:30:00', NULL, 'NOM-JUL-2026'),

(1031, 101, NULL, 'Supermercado', 1298.40,
 'purchase', 'food', 'completed',
 '2026-07-22 18:10:00', 'Supermercado del Valle', NULL),

(1032, NULL, 501, 'Restaurante', 755.00,
 'purchase', 'food', 'completed',
 '2026-07-19 20:50:00', 'Casa Norte', NULL),

(1033, 101, NULL, 'Servicio de internet', 670.00,
 'directDebit', 'services', 'completed',
 '2026-07-17 07:00:00', 'Internet Hogar', 'SERV-0726'),

(1034, NULL, 501, 'Streaming', 299.00,
 'purchase', 'entertainment', 'completed',
 '2026-07-15 06:00:00', 'Stream+', 'SUB-0726'),

(1035, 101, NULL, 'Gasolina', 920.00,
 'purchase', 'transportation', 'completed',
 '2026-07-12 17:35:00', 'Estación Central', NULL),

(1036, NULL, 501, 'Zapatos', 1849.00,
 'purchase', 'shopping', 'completed',
 '2026-07-09 16:20:00', 'Moda Urbana', NULL),

(1037, 101, NULL, 'Restaurante', 485.00,
 'purchase', 'food', 'completed',
 '2026-07-07 14:45:00', 'Cocina Urbana', NULL),

(1038, NULL, 501, 'Consulta médica', 850.00,
 'purchase', 'health', 'completed',
 '2026-07-05 11:30:00', 'Clínica Central', NULL),

(1039, 101, NULL, 'Supermercado', 1185.60,
 'purchase', 'food', 'completed',
 '2026-07-03 19:05:00', 'Mercado Central', NULL),

(1040, 101, NULL, 'Telefonía móvil', 499.00,
 'directDebit', 'services', 'completed',
 '2026-07-01 07:10:00', 'Telefonía Móvil', 'TEL-JUL-2026');
 
-- ============================================================
-- HISTORICAL TRANSACTIONS - SOFÍA MARTÍNEZ
-- ============================================================
-- Sofía tendrá 35 movimientos históricos distribuidos
-- entre su cuenta corriente y su tarjeta de crédito.
-- ============================================================

INSERT INTO BANK_TRANSACTION (
    id_transaction,
    id_account,
    id_credit_card,
    description,
    amount,
    transaction_type,
    category,
    transaction_status,
    transaction_date,
    merchant,
    reference
)
VALUES

-- =========================
-- SEPTEMBER 2026
-- =========================

(2001, 201, NULL, 'Nómina', 24500.00,
 'deposit', 'income', 'completed',
 '2026-09-25 08:15:00', NULL, 'NOM-SOF-SEP-2026'),

(2002, 201, NULL, 'Supermercado', 1150.80,
 'purchase', 'food', 'completed',
 '2026-09-24 18:20:00', 'Mercado Central', NULL),

(2003, NULL, 502, 'Restaurante', 685.00,
 'purchase', 'food', 'completed',
 '2026-09-22 20:40:00', 'Terraza Centro', NULL),

(2004, 201, NULL, 'Servicio de internet', 620.00,
 'directDebit', 'services', 'completed',
 '2026-09-20 07:00:00', 'Internet Hogar', 'SOF-INT-0926'),

(2005, NULL, 502, 'Compra en línea', 1499.00,
 'purchase', 'shopping', 'completed',
 '2026-09-18 15:30:00', 'Tienda Online', NULL),

(2006, 201, NULL, 'Transporte', 310.00,
 'purchase', 'transportation', 'completed',
 '2026-09-16 19:05:00', 'Movilidad Urbana', NULL),

(2007, NULL, 502, 'Cine', 360.00,
 'purchase', 'entertainment', 'completed',
 '2026-09-14 21:15:00', 'Cinema Center', NULL),

(2008, 201, NULL, 'Telefonía móvil', 449.00,
 'directDebit', 'services', 'completed',
 '2026-09-12 07:10:00', 'Telefonía Móvil', 'SOF-TEL-0926'),

(2009, NULL, 502, 'Farmacia', 425.70,
 'purchase', 'health', 'completed',
 '2026-09-10 17:50:00', 'Farmacia Central', NULL),

(2010, 201, NULL, 'Supermercado', 895.40,
 'purchase', 'food', 'completed',
 '2026-09-07 18:45:00', 'Supermercado del Valle', NULL),

(2011, NULL, 502, 'Streaming', 249.00,
 'purchase', 'entertainment', 'completed',
 '2026-09-05 06:00:00', 'Stream+', 'SOF-SUB-0926'),

(2012, 201, NULL, 'Electricidad', 740.00,
 'directDebit', 'services', 'completed',
 '2026-09-02 08:00:00', 'Energía Hogar', NULL),

-- =========================
-- AUGUST 2026
-- =========================

(2013, 201, NULL, 'Nómina', 24500.00,
 'deposit', 'income', 'completed',
 '2026-08-25 08:15:00', NULL, 'NOM-SOF-AGO-2026'),

(2014, 201, NULL, 'Supermercado', 1085.60,
 'purchase', 'food', 'completed',
 '2026-08-23 18:30:00', 'Mercado Central', NULL),

(2015, NULL, 502, 'Restaurante', 590.00,
 'purchase', 'food', 'completed',
 '2026-08-21 20:10:00', 'Cocina Urbana', NULL),

(2016, 201, NULL, 'Servicio de internet', 620.00,
 'directDebit', 'services', 'completed',
 '2026-08-19 07:00:00', 'Internet Hogar', 'SOF-INT-0826'),

(2017, NULL, 502, 'Ropa', 1275.00,
 'purchase', 'shopping', 'completed',
 '2026-08-17 16:25:00', 'Moda Urbana', NULL),

(2018, 201, NULL, 'Transporte', 280.00,
 'purchase', 'transportation', 'completed',
 '2026-08-14 18:40:00', 'Movilidad Urbana', NULL),

(2019, NULL, 502, 'Plataforma de música', 129.00,
 'purchase', 'entertainment', 'completed',
 '2026-08-12 06:05:00', 'Music+', 'SOF-MUSIC-0826'),

(2020, 201, NULL, 'Supermercado', 945.30,
 'purchase', 'food', 'completed',
 '2026-08-09 19:15:00', 'Supermercado del Valle', NULL),

(2021, NULL, 502, 'Farmacia', 315.50,
 'purchase', 'health', 'completed',
 '2026-08-07 17:35:00', 'Farmacia Central', NULL),

(2022, 201, NULL, 'Telefonía móvil', 449.00,
 'directDebit', 'services', 'completed',
 '2026-08-04 07:10:00', 'Telefonía Móvil', 'SOF-TEL-0826'),

(2023, NULL, 502, 'Restaurante', 720.00,
 'purchase', 'food', 'completed',
 '2026-08-02 20:30:00', 'Casa Norte', NULL),

-- =========================
-- JULY 2026
-- =========================

(2024, 201, NULL, 'Nómina', 24500.00,
 'deposit', 'income', 'completed',
 '2026-07-25 08:15:00', NULL, 'NOM-SOF-JUL-2026'),

(2025, 201, NULL, 'Supermercado', 1020.75,
 'purchase', 'food', 'completed',
 '2026-07-22 18:15:00', 'Mercado Central', NULL),

(2026, NULL, 502, 'Restaurante', 645.00,
 'purchase', 'food', 'completed',
 '2026-07-20 20:20:00', 'Terraza Centro', NULL),

(2027, 201, NULL, 'Servicio de internet', 620.00,
 'directDebit', 'services', 'completed',
 '2026-07-18 07:00:00', 'Internet Hogar', 'SOF-INT-0726'),

(2028, NULL, 502, 'Compra en línea', 985.00,
 'purchase', 'shopping', 'completed',
 '2026-07-16 14:45:00', 'Tienda Online', NULL),

(2029, 201, NULL, 'Transporte', 295.00,
 'purchase', 'transportation', 'completed',
 '2026-07-13 18:50:00', 'Movilidad Urbana', NULL),

(2030, NULL, 502, 'Cine', 390.00,
 'purchase', 'entertainment', 'completed',
 '2026-07-11 21:00:00', 'Cinema Center', NULL),

(2031, 201, NULL, 'Supermercado', 875.90,
 'purchase', 'food', 'completed',
 '2026-07-09 19:05:00', 'Supermercado del Valle', NULL),

(2032, NULL, 502, 'Consulta médica', 750.00,
 'purchase', 'health', 'completed',
 '2026-07-07 11:00:00', 'Clínica Central', NULL),

(2033, 201, NULL, 'Telefonía móvil', 449.00,
 'directDebit', 'services', 'completed',
 '2026-07-05 07:10:00', 'Telefonía Móvil', 'SOF-TEL-0726'),

(2034, NULL, 502, 'Cafetería', 165.00,
 'purchase', 'food', 'completed',
 '2026-07-03 09:20:00', 'Café Central', NULL),

(2035, 201, NULL, 'Electricidad', 695.00,
 'directDebit', 'services', 'completed',
 '2026-07-01 08:00:00', 'Energía Hogar', NULL);
 
-- ============================================================
-- HISTORICAL TRANSACTIONS - DIEGO HERNÁNDEZ
-- ============================================================
-- Diego tendrá 40 movimientos históricos.
-- ============================================================

INSERT INTO BANK_TRANSACTION (
    id_transaction,
    id_account,
    id_credit_card,
    description,
    amount,
    transaction_type,
    category,
    transaction_status,
    transaction_date,
    merchant,
    reference
)
VALUES

-- =========================
-- SEPTEMBER 2026
-- =========================

(3001, 301, NULL, 'Nómina', 36000.00,
 'deposit', 'income', 'completed',
 '2026-09-25 08:10:00', NULL, 'NOM-DIE-SEP-2026'),

(3002, 301, NULL, 'Supermercado', 1540.80,
 'purchase', 'food', 'completed',
 '2026-09-24 18:35:00', 'Mercado Central', NULL),

(3003, NULL, 503, 'Restaurante', 1120.00,
 'purchase', 'food', 'completed',
 '2026-09-22 21:10:00', 'Terraza Centro', NULL),

(3004, 301, NULL, 'Servicio de internet', 720.00,
 'directDebit', 'services', 'completed',
 '2026-09-20 07:00:00', 'Internet Hogar', 'DIE-INT-0926'),

(3005, NULL, 503, 'Compra en línea', 2850.00,
 'purchase', 'shopping', 'completed',
 '2026-09-18 16:20:00', 'Tienda Online', NULL),

(3006, 301, NULL, 'Gasolina', 1100.00,
 'purchase', 'transportation', 'completed',
 '2026-09-16 19:30:00', 'Estación Central', NULL),

(3007, NULL, 503, 'Streaming', 299.00,
 'purchase', 'entertainment', 'completed',
 '2026-09-14 06:00:00', 'Stream+', 'DIE-SUB-0926'),

(3008, 301, NULL, 'Electricidad', 980.00,
 'directDebit', 'services', 'completed',
 '2026-09-12 08:00:00', 'Energía Hogar', NULL),

(3009, NULL, 503, 'Farmacia', 590.40,
 'purchase', 'health', 'completed',
 '2026-09-10 17:45:00', 'Farmacia Central', NULL),

(3010, 301, NULL, 'Supermercado', 1385.60,
 'purchase', 'food', 'completed',
 '2026-09-08 18:50:00', 'Supermercado del Valle', NULL),

(3011, 301, NULL, 'Transferencia a ahorro', 8000.00,
 'transferOut', 'transfers', 'completed',
 '2026-09-06 10:30:00', NULL, 'DIE-AHO-0926'),

(3012, 302, NULL, 'Transferencia recibida', 8000.00,
 'transferIn', 'transfers', 'completed',
 '2026-09-06 10:30:00', NULL, 'DIE-AHO-0926'),

(3013, NULL, 503, 'Restaurante', 875.00,
 'purchase', 'food', 'completed',
 '2026-09-03 20:15:00', 'Casa Norte', NULL),

(3014, 301, NULL, 'Telefonía móvil', 599.00,
 'directDebit', 'services', 'completed',
 '2026-09-01 07:10:00', 'Telefonía Móvil', 'DIE-TEL-0926'),

-- =========================
-- AUGUST 2026
-- =========================

(3015, 301, NULL, 'Nómina', 36000.00,
 'deposit', 'income', 'completed',
 '2026-08-25 08:10:00', NULL, 'NOM-DIE-AGO-2026'),

(3016, 301, NULL, 'Supermercado', 1475.30,
 'purchase', 'food', 'completed',
 '2026-08-23 18:25:00', 'Mercado Central', NULL),

(3017, NULL, 503, 'Restaurante', 980.00,
 'purchase', 'food', 'completed',
 '2026-08-21 20:50:00', 'Terraza Centro', NULL),

(3018, 301, NULL, 'Servicio de internet', 720.00,
 'directDebit', 'services', 'completed',
 '2026-08-19 07:00:00', 'Internet Hogar', 'DIE-INT-0826'),

(3019, NULL, 503, 'Electrónica', 3499.00,
 'purchase', 'shopping', 'completed',
 '2026-08-17 15:40:00', 'Tech Store', NULL),

(3020, 301, NULL, 'Gasolina', 1045.00,
 'purchase', 'transportation', 'completed',
 '2026-08-15 18:30:00', 'Estación Central', NULL),

(3021, NULL, 503, 'Cine', 480.00,
 'purchase', 'entertainment', 'completed',
 '2026-08-13 21:20:00', 'Cinema Center', NULL),

(3022, 301, NULL, 'Supermercado', 1290.75,
 'purchase', 'food', 'completed',
 '2026-08-10 19:00:00', 'Supermercado del Valle', NULL),

(3023, NULL, 503, 'Consulta médica', 950.00,
 'purchase', 'health', 'completed',
 '2026-08-08 11:15:00', 'Clínica Central', NULL),

(3024, 301, NULL, 'Transferencia a ahorro', 6000.00,
 'transferOut', 'transfers', 'completed',
 '2026-08-06 10:00:00', NULL, 'DIE-AHO-0826'),

(3025, 302, NULL, 'Transferencia recibida', 6000.00,
 'transferIn', 'transfers', 'completed',
 '2026-08-06 10:00:00', NULL, 'DIE-AHO-0826'),

(3026, 301, NULL, 'Telefonía móvil', 599.00,
 'directDebit', 'services', 'completed',
 '2026-08-03 07:10:00', 'Telefonía Móvil', 'DIE-TEL-0826'),

(3027, NULL, 503, 'Cafetería', 210.00,
 'purchase', 'food', 'completed',
 '2026-08-01 09:35:00', 'Café Central', NULL),

-- =========================
-- JULY 2026
-- =========================

(3028, 301, NULL, 'Nómina', 36000.00,
 'deposit', 'income', 'completed',
 '2026-07-25 08:10:00', NULL, 'NOM-DIE-JUL-2026'),

(3029, 301, NULL, 'Supermercado', 1435.20,
 'purchase', 'food', 'completed',
 '2026-07-22 18:40:00', 'Mercado Central', NULL),

(3030, NULL, 503, 'Restaurante', 1050.00,
 'purchase', 'food', 'completed',
 '2026-07-20 21:00:00', 'Casa Norte', NULL),

(3031, 301, NULL, 'Servicio de internet', 720.00,
 'directDebit', 'services', 'completed',
 '2026-07-18 07:00:00', 'Internet Hogar', 'DIE-INT-0726'),

(3032, NULL, 503, 'Ropa', 2290.00,
 'purchase', 'shopping', 'completed',
 '2026-07-16 16:10:00', 'Moda Urbana', NULL),

(3033, 301, NULL, 'Gasolina', 1080.00,
 'purchase', 'transportation', 'completed',
 '2026-07-14 18:35:00', 'Estación Central', NULL),

(3034, NULL, 503, 'Plataforma de música', 129.00,
 'purchase', 'entertainment', 'completed',
 '2026-07-12 06:05:00', 'Music+', 'DIE-MUSIC-0726'),

(3035, 301, NULL, 'Supermercado', 1325.90,
 'purchase', 'food', 'completed',
 '2026-07-10 19:15:00', 'Supermercado del Valle', NULL),

(3036, NULL, 503, 'Farmacia', 475.80,
 'purchase', 'health', 'completed',
 '2026-07-08 17:30:00', 'Farmacia Central', NULL),

(3037, 301, NULL, 'Transferencia a ahorro', 7000.00,
 'transferOut', 'transfers', 'completed',
 '2026-07-06 10:20:00', NULL, 'DIE-AHO-0726'),

(3038, 302, NULL, 'Transferencia recibida', 7000.00,
 'transferIn', 'transfers', 'completed',
 '2026-07-06 10:20:00', NULL, 'DIE-AHO-0726'),

(3039, 301, NULL, 'Telefonía móvil', 599.00,
 'directDebit', 'services', 'completed',
 '2026-07-03 07:10:00', 'Telefonía Móvil', 'DIE-TEL-0726'),

(3040, NULL, 503, 'Restaurante', 790.00,
 'purchase', 'food', 'completed',
 '2026-07-01 20:15:00', 'Cocina Urbana', NULL);