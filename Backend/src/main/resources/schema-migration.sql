-- ==============================================================================
-- HulyPay Supabase / PostgreSQL Database Schema
-- Normalized + Query-Friendly + Encryption-Ready
-- ==============================================================================


-- ==============================================================================
-- 1. USERS
-- ==============================================================================

CREATE TABLE IF NOT EXISTS users (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    email             VARCHAR(255) UNIQUE NOT NULL,

    full_name         TEXT,
    first_name        TEXT,
    last_name         TEXT,
    phone_number      TEXT,
    avatar_url        TEXT,

    auth_provider     VARCHAR(30) DEFAULT 'email',
    provider_subject  TEXT,

    active            BOOLEAN NOT NULL DEFAULT TRUE,

    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ==============================================================================
-- 2. CURRENCIES
-- ==============================================================================

CREATE TABLE IF NOT EXISTS currencies (
    code      CHAR(3) PRIMARY KEY,
    symbol    VARCHAR(5) NOT NULL
);


-- ==============================================================================
-- 3. CATEGORIES
-- ==============================================================================

CREATE TABLE IF NOT EXISTS categories (
    name VARCHAR(100) PRIMARY KEY
);


-- ==============================================================================
-- 4. PAYMENT METHODS
-- ==============================================================================

CREATE TABLE IF NOT EXISTS payment_methods (
    method    VARCHAR(30) NOT NULL,
    provider  VARCHAR(50) NOT NULL,

    PRIMARY KEY (method, provider)
);


-- ==============================================================================
-- 5. TRANSACTION STATUS ENUM
-- ==============================================================================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_type
        WHERE typname = 'transaction_status'
    ) THEN
        CREATE TYPE transaction_status AS ENUM (
            'SUCCESS',
            'PENDING',
            'CANCELLED',
            'TIMEOUT'
        );
    END IF;
END $$;


-- ==============================================================================
-- 6. MERCHANTS
-- ==============================================================================

CREATE TABLE IF NOT EXISTS merchants (
    id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name  VARCHAR(255) NOT NULL UNIQUE
);


-- ==============================================================================
-- 7. TRANSACTIONS
-- ==============================================================================

CREATE TABLE IF NOT EXISTS transactions (
    id                         UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id                    UUID NOT NULL,

    -- Queryable / analytics fields
    amount                     NUMERIC(12,2) NOT NULL,

    currency_code              CHAR(3) NOT NULL DEFAULT 'INR',

    merchant_id                UUID,

    category_name              VARCHAR(100),

    payment_method             VARCHAR(30),
    provider                   VARCHAR(50),

    status                     transaction_status NOT NULL DEFAULT 'SUCCESS',

    -- Sensitive fields
    description                TEXT,

    upi_transaction_id         TEXT,
    transaction_reference      TEXT,
    upi_id                     TEXT,

    latitude                   DOUBLE PRECISION,
    longitude                  DOUBLE PRECISION,
    location_accuracy_meters   DOUBLE PRECISION,

    -- Dates / timestamps
    transaction_time           TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_at                 TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                 TIMESTAMPTZ NOT NULL DEFAULT NOW(),


    -- ==========================================================================
    -- FOREIGN KEYS
    -- ==========================================================================

    CONSTRAINT fk_transactions_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_transactions_currency
        FOREIGN KEY (currency_code)
        REFERENCES currencies(code),

    CONSTRAINT fk_transactions_merchant
        FOREIGN KEY (merchant_id)
        REFERENCES merchants(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_transactions_category
        FOREIGN KEY (category_name)
        REFERENCES categories(name)
        ON DELETE SET NULL,

    CONSTRAINT fk_transactions_payment_method
        FOREIGN KEY (payment_method, provider)
        REFERENCES payment_methods(method, provider)
        ON DELETE SET NULL
);


-- ==============================================================================
-- 8. SEED LOOKUP VALUES
-- ==============================================================================


-- ------------------------------------------------------------------------------
-- CURRENCIES
-- ------------------------------------------------------------------------------

INSERT INTO currencies (code, symbol)
VALUES
    ('INR', '₹'),
    ('USD', '$'),
    ('EUR', '€'),
    ('GBP', '£')
ON CONFLICT (code) DO NOTHING;


-- ------------------------------------------------------------------------------
-- CATEGORIES
-- ------------------------------------------------------------------------------

INSERT INTO categories (name)
VALUES
    ('Food & Dining'),
    ('Groceries'),
    ('Shopping'),
    ('Bills & Utilities'),
    ('Entertainment'),
    ('Travel & Transport'),
    ('Health & Medical'),
    ('Education'),
    ('Investments'),
    ('Personal Care'),
    ('Others')
ON CONFLICT (name) DO NOTHING;


-- ------------------------------------------------------------------------------
-- PAYMENT METHODS
-- ------------------------------------------------------------------------------

INSERT INTO payment_methods (method, provider)
VALUES

    -- UPI
    ('UPI', 'GOOGLE_PAY'),
    ('UPI', 'PHONEPE'),
    ('UPI', 'BHIM'),
    ('UPI', 'AMAZON_PAY'),
    ('UPI', 'WHATSAPP_PAY'),
    ('UPI', 'PAYTM'),
    ('UPI', 'UPI'),

    -- Cards
    ('DEBIT_CARD', 'BANK'),
    ('CREDIT_CARD', 'BANK'),

    -- Banking
    ('NET_BANKING', 'BANK'),

    -- Manual cash
    ('CASH', 'MANUAL'),

    -- Other
    ('OTHER', 'OTHER')

ON CONFLICT (method, provider) DO NOTHING;


-- ==============================================================================
-- 9. MIGRATION OF EXISTING DATA
-- ==============================================================================

DO $$
BEGIN

    -- ==========================================================================
    -- Check transactions table
    -- ==========================================================================

    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'transactions'
    ) THEN


        -- ======================================================================
        -- Add normalized columns if they don't exist
        -- ======================================================================

        IF NOT EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = 'transactions'
            AND column_name = 'currency_code'
        ) THEN

            ALTER TABLE transactions
            ADD COLUMN currency_code CHAR(3) DEFAULT 'INR';

        END IF;


        IF NOT EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = 'transactions'
            AND column_name = 'merchant_id'
        ) THEN

            ALTER TABLE transactions
            ADD COLUMN merchant_id UUID;

        END IF;


        IF NOT EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = 'transactions'
            AND column_name = 'category_name'
        ) THEN

            ALTER TABLE transactions
            ADD COLUMN category_name VARCHAR(100);

        END IF;


        -- ======================================================================
        -- Migrate merchants
        -- ======================================================================

        IF EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = 'transactions'
            AND column_name = 'merchant_name'
        ) THEN

            INSERT INTO merchants (name)

            SELECT DISTINCT TRIM(merchant_name)

            FROM transactions

            WHERE merchant_name IS NOT NULL
              AND TRIM(merchant_name) <> ''

            ON CONFLICT (name) DO NOTHING;


            UPDATE transactions t

            SET merchant_id = m.id

            FROM merchants m

            WHERE TRIM(t.merchant_name) = m.name
              AND t.merchant_id IS NULL;

        END IF;


        -- ======================================================================
        -- Migrate categories
        -- ======================================================================

        IF EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = 'transactions'
            AND column_name = 'category'
        ) THEN

            INSERT INTO categories (name)

            SELECT DISTINCT TRIM(category)

            FROM transactions

            WHERE category IS NOT NULL
              AND TRIM(category) <> ''

            ON CONFLICT (name) DO NOTHING;


            UPDATE transactions

            SET category_name = TRIM(category)

            WHERE category_name IS NULL
              AND category IS NOT NULL;

        END IF;


        -- ======================================================================
        -- Migrate currencies
        -- ======================================================================

        IF EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = 'transactions'
            AND column_name = 'currency'
        ) THEN

            UPDATE transactions

            SET currency_code = UPPER(TRIM(currency))

            WHERE currency IS NOT NULL
              AND TRIM(currency) <> ''
              AND UPPER(TRIM(currency)) IN (
                  SELECT code FROM currencies
              );

        END IF;


        -- ======================================================================
        -- Migrate payment methods
        -- ======================================================================

        IF EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = 'transactions'
            AND column_name = 'payment_method'
        )
        AND EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = 'transactions'
            AND column_name = 'provider'
        ) THEN

            INSERT INTO payment_methods (method, provider)

            SELECT DISTINCT
                TRIM(payment_method),
                TRIM(provider)

            FROM transactions

            WHERE payment_method IS NOT NULL
              AND provider IS NOT NULL
              AND TRIM(payment_method) <> ''
              AND TRIM(provider) <> ''

            ON CONFLICT (method, provider) DO NOTHING;

        END IF;


        -- ======================================================================
        -- Add foreign keys if they don't exist
        -- ======================================================================

        IF NOT EXISTS (
            SELECT 1
            FROM information_schema.table_constraints
            WHERE constraint_name = 'fk_transactions_user'
        ) THEN

            ALTER TABLE transactions
            ADD CONSTRAINT fk_transactions_user
            FOREIGN KEY (user_id)
            REFERENCES users(id)
            ON DELETE CASCADE;

        END IF;


        IF NOT EXISTS (
            SELECT 1
            FROM information_schema.table_constraints
            WHERE constraint_name = 'fk_transactions_currency'
        ) THEN

            ALTER TABLE transactions
            ADD CONSTRAINT fk_transactions_currency
            FOREIGN KEY (currency_code)
            REFERENCES currencies(code);

        END IF;


        IF NOT EXISTS (
            SELECT 1
            FROM information_schema.table_constraints
            WHERE constraint_name = 'fk_transactions_merchant'
        ) THEN

            ALTER TABLE transactions
            ADD CONSTRAINT fk_transactions_merchant
            FOREIGN KEY (merchant_id)
            REFERENCES merchants(id)
            ON DELETE SET NULL;

        END IF;


        IF NOT EXISTS (
            SELECT 1
            FROM information_schema.table_constraints
            WHERE constraint_name = 'fk_transactions_category'
        ) THEN

            ALTER TABLE transactions
            ADD CONSTRAINT fk_transactions_category
            FOREIGN KEY (category_name)
            REFERENCES categories(name)
            ON DELETE SET NULL;

        END IF;


        IF NOT EXISTS (
            SELECT 1
            FROM information_schema.table_constraints
            WHERE constraint_name = 'fk_transactions_payment_method'
        ) THEN

            ALTER TABLE transactions
            ADD CONSTRAINT fk_transactions_payment_method
            FOREIGN KEY (payment_method, provider)
            REFERENCES payment_methods(method, provider)
            ON DELETE SET NULL;

        END IF;

    END IF;

END $$;


-- ==============================================================================
-- 10. REMOVE OLD TABLES
-- ==============================================================================

DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS expenses CASCADE;


-- ==============================================================================
-- 11. BACKWARD-COMPATIBLE VIEW
-- ==============================================================================

CREATE OR REPLACE VIEW transactions_view AS

SELECT

    t.id,

    t.user_id,

    t.amount,

    t.currency_code AS currency,

    t.currency_code,

    c.symbol AS currency_symbol,

    t.merchant_id,

    m.name AS merchant_name,

    t.category_name AS category,

    t.category_name,

    t.description,

    t.payment_method,

    t.provider,

    t.status,

    t.upi_transaction_id,

    t.transaction_reference,

    t.upi_id,

    t.latitude,

    t.longitude,

    t.location_accuracy_meters,

    t.transaction_time,

    t.created_at,

    t.updated_at

FROM transactions t

LEFT JOIN merchants m
    ON t.merchant_id = m.id

LEFT JOIN currencies c
    ON t.currency_code = c.code;


-- ==============================================================================
-- 12. PERFORMANCE INDEXES
-- ==============================================================================

CREATE INDEX IF NOT EXISTS idx_transactions_user_id
ON transactions(user_id);


CREATE INDEX IF NOT EXISTS idx_transactions_user_tx_time
ON transactions(user_id, transaction_time DESC);


CREATE INDEX IF NOT EXISTS idx_transactions_merchant_id
ON transactions(merchant_id);


CREATE INDEX IF NOT EXISTS idx_transactions_category_name
ON transactions(category_name);


CREATE INDEX IF NOT EXISTS idx_transactions_status
ON transactions(status);


CREATE INDEX IF NOT EXISTS idx_transactions_upi_transaction_id
ON transactions(upi_transaction_id);


CREATE INDEX IF NOT EXISTS idx_merchants_name
ON merchants(name);


-- ==============================================================================
-- 13. DUPLICATE UPI TRANSACTION PROTECTION
-- ==============================================================================

CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_user_upi_transaction
ON transactions(user_id, upi_transaction_id)
WHERE upi_transaction_id IS NOT NULL;


-- ==============================================================================
-- 14. ROW LEVEL SECURITY
-- ==============================================================================

ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE merchants ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE currencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_methods ENABLE ROW LEVEL SECURITY;


-- ==============================================================================
-- TRANSACTION POLICIES
-- ==============================================================================

DROP POLICY IF EXISTS "transactions_select_policy"
ON transactions;

CREATE POLICY "transactions_select_policy"

ON transactions

FOR SELECT

TO authenticated

USING (
    user_id = auth.uid()
);


DROP POLICY IF EXISTS "transactions_insert_policy"
ON transactions;

CREATE POLICY "transactions_insert_policy"

ON transactions

FOR INSERT

TO authenticated

WITH CHECK (
    user_id = auth.uid()
);


DROP POLICY IF EXISTS "transactions_update_policy"
ON transactions;

CREATE POLICY "transactions_update_policy"

ON transactions

FOR UPDATE

TO authenticated

USING (
    user_id = auth.uid()
)

WITH CHECK (
    user_id = auth.uid()
);


DROP POLICY IF EXISTS "transactions_delete_policy"
ON transactions;

CREATE POLICY "transactions_delete_policy"

ON transactions

FOR DELETE

TO authenticated

USING (
    user_id = auth.uid()
);


-- ==============================================================================
-- USERS POLICIES
-- ==============================================================================

DROP POLICY IF EXISTS "users_select_policy"
ON users;

CREATE POLICY "users_select_policy"

ON users

FOR SELECT

TO authenticated

USING (
    id = auth.uid()
);


DROP POLICY IF EXISTS "users_update_policy"
ON users;

CREATE POLICY "users_update_policy"

ON users

FOR UPDATE

TO authenticated

USING (
    id = auth.uid()
)

WITH CHECK (
    id = auth.uid()
);


-- ==============================================================================
-- LOOKUP TABLE POLICIES
-- ==============================================================================

DROP POLICY IF EXISTS "currencies_read_policy"
ON currencies;

CREATE POLICY "currencies_read_policy"

ON currencies

FOR SELECT

TO public

USING (true);


DROP POLICY IF EXISTS "categories_read_policy"
ON categories;

CREATE POLICY "categories_read_policy"

ON categories

FOR SELECT

TO public

USING (true);


DROP POLICY IF EXISTS "payment_methods_read_policy"
ON payment_methods;

CREATE POLICY "payment_methods_read_policy"

ON payment_methods

FOR SELECT

TO public

USING (true);


-- ==============================================================================
-- MERCHANT POLICIES
-- ==============================================================================

DROP POLICY IF EXISTS "merchants_read_policy"
ON merchants;

CREATE POLICY "merchants_read_policy"

ON merchants

FOR SELECT

TO authenticated

USING (true);


DROP POLICY IF EXISTS "merchants_insert_policy"
ON merchants;

CREATE POLICY "merchants_insert_policy"

ON merchants

FOR INSERT

TO authenticated

WITH CHECK (true);
