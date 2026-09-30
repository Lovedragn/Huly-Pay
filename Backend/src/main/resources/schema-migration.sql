-- ==============================================================================
-- HulyPay Database Schema Refactoring & Migration
-- Transition from: users, categories, expenses, payments
-- To: users, transactions (Single source of truth)
-- ==============================================================================

-- 1. Ensure `users` table matches the required schema
CREATE TABLE IF NOT EXISTS users (
    id                  UUID PRIMARY KEY,
    email               VARCHAR UNIQUE NOT NULL,
    full_name           TEXT,
    first_name          TEXT,
    last_name           TEXT,
    phone_number        TEXT,
    avatar_url          TEXT,
    auth_provider       TEXT,
    provider_subject    TEXT,
    active              BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ DEFAULT NOW(),
    updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create the unified `transactions` table
CREATE TABLE IF NOT EXISTS transactions (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                  UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount                   NUMERIC(12,2) NOT NULL,
    currency                 VARCHAR(3) NOT NULL DEFAULT 'INR',
    merchant_name            TEXT,
    category                 VARCHAR(100) NOT NULL DEFAULT 'Others',
    description              TEXT,
    payment_method           TEXT,
    provider                 TEXT,
    status                   VARCHAR(30) NOT NULL DEFAULT 'SUCCESS',
    upi_transaction_id       TEXT,
    transaction_reference    TEXT,
    upi_id                   TEXT,
    latitude                 DOUBLE PRECISION,
    longitude                DOUBLE PRECISION,
    location_accuracy_meters DOUBLE PRECISION,
    transaction_time         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Data Migration: Migrate existing payments and expenses safely into transactions
DO $$
BEGIN
    -- Check if payments table exists to migrate records
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'payments') THEN
        -- Check if expenses and categories exist to join richer metadata
        IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'expenses') THEN
            INSERT INTO transactions (
                id,
                user_id,
                amount,
                currency,
                merchant_name,
                category,
                description,
                payment_method,
                provider,
                status,
                upi_transaction_id,
                transaction_reference,
                upi_id,
                latitude,
                longitude,
                location_accuracy_meters,
                transaction_time,
                created_at,
                updated_at
            )
            SELECT
                p.id,
                p.user_id,
                p.amount,
                COALESCE(p.currency, 'INR'),
                COALESCE(p.merchant_name, e.merchant_name),
                COALESCE(
                    c.name,
                    CASE 
                        WHEN p.payment_method IS NOT NULL AND p.payment_method NOT IN ('UPI', 'CARD', 'NETBANKING', 'GPAY', 'PHONEPE', 'PAYTM') THEN p.payment_method
                        ELSE 'Others'
                    END
                ) AS category,
                COALESCE(e.description, 'Payment via ' || COALESCE(p.payment_method, 'UPI')),
                COALESCE(p.payment_method, e.payment_method, 'UPI'),
                p.provider,
                COALESCE(p.status, 'SUCCESS'),
                COALESCE(p.upi_transaction_id, e.upi_transaction_id),
                p.transaction_reference,
                p.upi_id,
                COALESCE(p.latitude, e.latitude),
                COALESCE(p.longitude, e.longitude),
                p.location_accuracy_meters,
                COALESCE(e.transaction_time, p.created_at, NOW()),
                COALESCE(p.created_at, NOW()),
                COALESCE(p.updated_at, NOW())
            FROM payments p
            LEFT JOIN expenses e ON p.expense_id = e.id
            LEFT JOIN categories c ON e.category_id = c.id
            ON CONFLICT (id) DO NOTHING;
        ELSE
            -- Payments exists but expenses doesn't
            INSERT INTO transactions (
                id,
                user_id,
                amount,
                currency,
                merchant_name,
                category,
                description,
                payment_method,
                provider,
                status,
                upi_transaction_id,
                transaction_reference,
                upi_id,
                latitude,
                longitude,
                location_accuracy_meters,
                transaction_time,
                created_at,
                updated_at
            )
            SELECT
                p.id,
                p.user_id,
                p.amount,
                COALESCE(p.currency, 'INR'),
                p.merchant_name,
                'Others',
                'Payment via ' || COALESCE(p.payment_method, 'UPI'),
                COALESCE(p.payment_method, 'UPI'),
                p.provider,
                COALESCE(p.status, 'SUCCESS'),
                p.upi_transaction_id,
                p.transaction_reference,
                p.upi_id,
                p.latitude,
                p.longitude,
                p.location_accuracy_meters,
                COALESCE(p.created_at, NOW()),
                COALESCE(p.created_at, NOW()),
                COALESCE(p.updated_at, NOW())
            FROM payments p
            ON CONFLICT (id) DO NOTHING;
        END IF;
    END IF;

    -- Migrate orphaned expenses (expenses not linked to any payment)
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'expenses') THEN
        INSERT INTO transactions (
            id,
            user_id,
            amount,
            currency,
            merchant_name,
            category,
            description,
            payment_method,
            provider,
            status,
            upi_transaction_id,
            transaction_reference,
            upi_id,
            latitude,
            longitude,
            location_accuracy_meters,
            transaction_time,
            created_at,
            updated_at
        )
        SELECT
            e.id,
            e.user_id,
            e.amount,
            COALESCE(e.currency, 'INR'),
            e.merchant_name,
            COALESCE(c.name, 'Others'),
            e.description,
            COALESCE(e.payment_method, 'UPI'),
            'UPI',
            COALESCE(e.status, 'SUCCESS'),
            e.upi_transaction_id,
            NULL,
            NULL,
            e.latitude,
            e.longitude,
            NULL,
            COALESCE(e.transaction_time, e.created_at, NOW()),
            COALESCE(e.created_at, NOW()),
            COALESCE(e.updated_at, NOW())
        FROM expenses e
        LEFT JOIN categories c ON e.category_id = c.id
        WHERE NOT EXISTS (
            SELECT 1 FROM transactions t WHERE t.id = e.id
        )
        ON CONFLICT (id) DO NOTHING;
    END IF;
END $$;

-- 4. Clean up redundant tables
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS expenses CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

-- 5. Create Performance and Constraint Indexes
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_user_tx_time ON transactions(user_id, transaction_time DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_upi_transaction_id ON transactions(upi_transaction_id);

-- Partial unique index to prevent duplicate UPI transactions for the same user
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_user_upi_transaction
ON transactions(user_id, upi_transaction_id)
WHERE upi_transaction_id IS NOT NULL;

-- 6. Configure Row Level Security (RLS)
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- Drop legacy or overly permissive policies if any exist
DROP POLICY IF EXISTS "Allow all for authenticated users" ON transactions;
DROP POLICY IF EXISTS "Public access" ON transactions;
DROP POLICY IF EXISTS "Enable all access" ON transactions;
DROP POLICY IF EXISTS "transactions_select_policy" ON transactions;
DROP POLICY IF EXISTS "transactions_insert_policy" ON transactions;
DROP POLICY IF EXISTS "transactions_update_policy" ON transactions;
DROP POLICY IF EXISTS "transactions_delete_policy" ON transactions;

-- Enforce strict per-user RLS policies for authenticated users
CREATE POLICY "transactions_select_policy"
    ON transactions
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "transactions_insert_policy"
    ON transactions
    FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "transactions_update_policy"
    ON transactions
    FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "transactions_delete_policy"
    ON transactions
    FOR DELETE
    TO authenticated
    USING (user_id = auth.uid());
