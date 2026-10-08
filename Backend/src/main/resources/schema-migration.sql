-- ==============================================================================
-- HulyPay Complete Supabase / PostgreSQL Schema Migration & Setup Script
-- Compatible with: Supabase SQL Editor, Spring Boot JPA, Next.js Web, & Flutter App
-- ==============================================================================

-- 0. Enable UUID & Crypto Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";


-- ==============================================================================
-- 1. USERS TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS users (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email             VARCHAR(255) UNIQUE,
    full_name         TEXT,
    first_name        TEXT,
    last_name         TEXT,
    phone_number      TEXT,
    avatar_url        TEXT,
    auth_provider     VARCHAR(50) DEFAULT 'email',
    provider_subject  TEXT,
    active            BOOLEAN NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ==============================================================================
-- 2. LOOKUP TABLES: CURRENCIES, CATEGORIES, TRANSACTION_STATUS, PAYMENT_METHODS
-- ==============================================================================

-- Currencies
CREATE TABLE IF NOT EXISTS currencies (
    code      CHAR(3) PRIMARY KEY,
    symbol    VARCHAR(5) NOT NULL
);

-- Categories
CREATE TABLE IF NOT EXISTS categories (
    name      VARCHAR(100) PRIMARY KEY
);

-- Transaction Status (Table for Spring Boot entity & lookup)
CREATE TABLE IF NOT EXISTS transaction_status (
    code      SMALLINT PRIMARY KEY,
    name      VARCHAR(30) NOT NULL UNIQUE
);

-- Payment Methods (Composite key: method, provider)
CREATE TABLE IF NOT EXISTS payment_methods (
    method    VARCHAR(100) NOT NULL,
    provider  VARCHAR(100) NOT NULL,
    PRIMARY KEY (method, provider)
);

-- Merchants
CREATE TABLE IF NOT EXISTS merchants (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(255) NOT NULL UNIQUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ==============================================================================
-- 3. TRANSACTIONS TABLE
-- ==============================================================================
CREATE TABLE IF NOT EXISTS transactions (
    id                         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                    UUID NOT NULL,

    -- Amount & Currency
    amount                     NUMERIC(12,2) NOT NULL,
    currency_code              CHAR(3) NOT NULL DEFAULT 'INR',
    currency                   VARCHAR(10) DEFAULT 'INR',

    -- Merchant & Category
    merchant_id                UUID,
    merchant_name              VARCHAR(255),
    category_name              VARCHAR(100) DEFAULT 'Others',
    category                   VARCHAR(100) DEFAULT 'Others',

    -- Payment Method & Provider
    payment_method             VARCHAR(100),
    provider                   VARCHAR(100),

    -- Status
    status_code                SMALLINT NOT NULL DEFAULT 1,
    status                     VARCHAR(50) DEFAULT 'SUCCESS',

    -- References & Details
    description                TEXT,
    upi_transaction_id         TEXT,
    transaction_reference      TEXT,
    upi_id                     TEXT,

    -- Location
    latitude                   DOUBLE PRECISION,
    longitude                  DOUBLE PRECISION,
    location_accuracy_meters   DOUBLE PRECISION,

    -- Timestamps
    transaction_time           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at                 TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                 TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT fk_transactions_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_transactions_currency
        FOREIGN KEY (currency_code) REFERENCES currencies(code) ON DELETE RESTRICT,
    CONSTRAINT fk_transactions_merchant
        FOREIGN KEY (merchant_id) REFERENCES merchants(id) ON DELETE SET NULL,
    CONSTRAINT fk_transactions_category
        FOREIGN KEY (category_name) REFERENCES categories(name) ON DELETE SET NULL,
    CONSTRAINT fk_transactions_status
        FOREIGN KEY (status_code) REFERENCES transaction_status(code) ON DELETE RESTRICT
);


-- ==============================================================================
-- 4. CLEAN UP LEGACY TABLES IF THEY EXIST
-- ==============================================================================
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS expenses CASCADE;


-- ==============================================================================
-- 5. SEED DEFAULT DATA
-- ==============================================================================

-- Seed Currencies (Only INR and USD)
INSERT INTO currencies (code, symbol)
VALUES
    ('INR', '₹'),
    ('USD', '$')
ON CONFLICT (code) DO NOTHING;

-- Seed Categories
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

-- Seed Transaction Status Codes
INSERT INTO transaction_status (code, name)
VALUES
    (1, 'SUCCESS'),
    (2, 'PENDING'),
    (3, 'CANCELLED'),

ON CONFLICT (code) DO NOTHING;

-- Seed Standard Payment Methods
INSERT INTO payment_methods (method, provider)
VALUES
    ('UPI', 'GOOGLE_PAY'),
    ('UPI', 'BHIM'),
    ('UPI', 'AMAZON_PAY'),
    ('UPI', 'WHATSAPP_PAY'),
    
    ('DEBIT_CARD', 'BANK'),
    ('CREDIT_CARD', 'BANK'),
    ('NET_BANKING', 'BANK'),

    ('CASH', 'MANUAL'),

    ('OTHER', 'OTHER')
ON CONFLICT (method, provider) DO NOTHING;


-- ==============================================================================
-- 6. AUTOMATIC SYNCHRONIZATION TRIGGER (BRIDGES MOBILE, WEB & BACKEND)
-- ==============================================================================
CREATE OR REPLACE FUNCTION sync_transaction_fields()
RETURNS TRIGGER AS $$
BEGIN
    -- 1. Merchant sync (find or auto-create merchant by name)
    IF NEW.merchant_name IS NOT NULL AND TRIM(NEW.merchant_name) <> '' THEN
        INSERT INTO merchants (id, name)
        VALUES (gen_random_uuid(), TRIM(NEW.merchant_name))
        ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name
        RETURNING id INTO NEW.merchant_id;
    ELSIF NEW.merchant_id IS NOT NULL AND (NEW.merchant_name IS NULL OR TRIM(NEW.merchant_name) = '') THEN
        SELECT name INTO NEW.merchant_name FROM merchants WHERE id = NEW.merchant_id;
    END IF;

    -- 2. Category sync
    IF NEW.category_name IS NOT NULL AND TRIM(NEW.category_name) <> '' THEN
        NEW.category = NEW.category_name;
    ELSIF NEW.category IS NOT NULL AND TRIM(NEW.category) <> '' THEN
        NEW.category_name = NEW.category;
    ELSE
        NEW.category_name = 'Others';
        NEW.category = 'Others';
    END IF;

    -- Ensure category exists in lookup
    IF NEW.category_name IS NOT NULL THEN
        INSERT INTO categories (name) VALUES (NEW.category_name) ON CONFLICT (name) DO NOTHING;
    END IF;

    -- 3. Currency sync
    IF NEW.currency_code IS NOT NULL AND TRIM(NEW.currency_code) <> '' THEN
        NEW.currency_code = UPPER(TRIM(NEW.currency_code));
        NEW.currency = NEW.currency_code;
    ELSIF NEW.currency IS NOT NULL AND TRIM(NEW.currency) <> '' THEN
        NEW.currency_code = UPPER(TRIM(NEW.currency));
        NEW.currency = NEW.currency_code;
    ELSE
        NEW.currency_code = 'INR';
        NEW.currency = 'INR';
    END IF;

    -- 4. Status sync
    IF NEW.status IS NOT NULL AND TRIM(NEW.status) <> '' THEN
        SELECT code INTO NEW.status_code FROM transaction_status WHERE UPPER(name) = UPPER(TRIM(NEW.status));
        IF NEW.status_code IS NULL THEN
            NEW.status_code = 1;
        END IF;
    ELSIF NEW.status_code IS NOT NULL THEN
        SELECT name INTO NEW.status FROM transaction_status WHERE code = NEW.status_code;
        IF NEW.status IS NULL THEN
            NEW.status = 'SUCCESS';
        END IF;
    ELSE
        NEW.status_code = 1;
        NEW.status = 'SUCCESS';
    END IF;

    -- 5. Payment method sync
    IF NEW.payment_method IS NOT NULL AND NEW.provider IS NOT NULL THEN
        INSERT INTO payment_methods (method, provider)
        VALUES (TRIM(NEW.payment_method), TRIM(NEW.provider))
        ON CONFLICT (method, provider) DO NOTHING;
    END IF;

    -- 6. Updated at timestamp
    NEW.updated_at = NOW();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sync_transaction_fields ON transactions;
CREATE TRIGGER trg_sync_transaction_fields
    BEFORE INSERT OR UPDATE ON transactions
    FOR EACH ROW
    EXECUTE FUNCTION sync_transaction_fields();


-- User updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_users_updated_at ON users;
CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


-- ==============================================================================
-- 7. SUPABASE AUTH USER AUTO-PROVISIONING TRIGGER
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, full_name, avatar_url, auth_provider)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', ''),
        NEW.raw_user_meta_data->>'avatar_url',
        COALESCE(NEW.raw_app_meta_data->>'provider', 'email')
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT OR UPDATE ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- ==============================================================================
-- 8. PERFORMANCE INDEXES
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_user_tx_time ON transactions(user_id, transaction_time DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_merchant_id ON transactions(merchant_id);
CREATE INDEX IF NOT EXISTS idx_transactions_category_name ON transactions(category_name);
CREATE INDEX IF NOT EXISTS idx_transactions_status_code ON transactions(status_code);
CREATE INDEX IF NOT EXISTS idx_transactions_upi_transaction_id ON transactions(upi_transaction_id);
CREATE INDEX IF NOT EXISTS idx_merchants_name ON merchants(name);

-- Prevent duplicate UPI transaction IDs per user
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_user_upi_transaction
ON transactions(user_id, upi_transaction_id)
WHERE upi_transaction_id IS NOT NULL;


-- ==============================================================================
-- 9. BACKWARD-COMPATIBLE VIEW
-- ==============================================================================
CREATE OR REPLACE VIEW transactions_view AS
SELECT
    t.id,
    t.user_id,
    t.amount,
    t.currency_code,
    t.currency,
    c.symbol AS currency_symbol,
    t.merchant_id,
    COALESCE(t.merchant_name, m.name) AS merchant_name,
    t.category_name,
    t.category,
    t.payment_method,
    t.provider,
    t.status_code,
    COALESCE(t.status, s.name, 'SUCCESS') AS status,
    t.description,
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
LEFT JOIN merchants m ON t.merchant_id = m.id
LEFT JOIN currencies c ON t.currency_code = c.code
LEFT JOIN transaction_status s ON t.status_code = s.code;


-- ==============================================================================
-- 10. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE merchants ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE currencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE transaction_status ENABLE ROW LEVEL SECURITY;

-- Transactions Policies
DROP POLICY IF EXISTS "transactions_select_policy" ON transactions;
CREATE POLICY "transactions_select_policy" ON transactions
    FOR SELECT TO authenticated
    USING (user_id = auth.uid());

DROP POLICY IF EXISTS "transactions_insert_policy" ON transactions;
CREATE POLICY "transactions_insert_policy" ON transactions
    FOR INSERT TO authenticated
    WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "transactions_update_policy" ON transactions;
CREATE POLICY "transactions_update_policy" ON transactions
    FOR UPDATE TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "transactions_delete_policy" ON transactions;
CREATE POLICY "transactions_delete_policy" ON transactions
    FOR DELETE TO authenticated
    USING (user_id = auth.uid());

-- Users Policies
DROP POLICY IF EXISTS "users_select_policy" ON users;
CREATE POLICY "users_select_policy" ON users
    FOR SELECT TO authenticated
    USING (id = auth.uid());

DROP POLICY IF EXISTS "users_update_policy" ON users;
CREATE POLICY "users_update_policy" ON users
    FOR UPDATE TO authenticated
    USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

-- Lookup Table Read Policies (Public / Authenticated)
DROP POLICY IF EXISTS "currencies_read_policy" ON currencies;
CREATE POLICY "currencies_read_policy" ON currencies FOR SELECT TO public USING (true);

DROP POLICY IF EXISTS "categories_read_policy" ON categories;
CREATE POLICY "categories_read_policy" ON categories FOR SELECT TO public USING (true);

DROP POLICY IF EXISTS "transaction_status_read_policy" ON transaction_status;
CREATE POLICY "transaction_status_read_policy" ON transaction_status FOR SELECT TO public USING (true);

DROP POLICY IF EXISTS "payment_methods_read_policy" ON payment_methods;
CREATE POLICY "payment_methods_read_policy" ON payment_methods FOR SELECT TO public USING (true);

DROP POLICY IF EXISTS "merchants_read_policy" ON merchants;
CREATE POLICY "merchants_read_policy" ON merchants FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "merchants_insert_policy" ON merchants;
CREATE POLICY "merchants_insert_policy" ON merchants FOR INSERT TO authenticated WITH CHECK (true);
