CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Users
CREATE TABLE public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE,
    full_name TEXT,
    first_name TEXT,
    last_name TEXT,
    phone_number TEXT,
    avatar_url TEXT,
    auth_provider VARCHAR(50) DEFAULT 'email',
    provider_subject TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Merchants
CREATE TABLE public.merchants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Categories
CREATE TABLE public.categories (
    name VARCHAR(100) PRIMARY KEY
);

-- 4. Currencies
CREATE TABLE public.currencies (
    code VARCHAR(3) PRIMARY KEY,
    symbol VARCHAR(10) NOT NULL UNIQUE,
    CONSTRAINT currencies_code_check
        CHECK (code IN ('INR', 'USD')),
    CONSTRAINT currencies_symbol_check
        CHECK (symbol IN ('₹', '$'))
);

-- 5. Transaction Statuses
CREATE TABLE public.transaction_status (
    name VARCHAR(30) PRIMARY KEY
);

-- 6. Payment Methods
CREATE TABLE public.payment_methods (
    name VARCHAR(100) PRIMARY KEY
);

-- 7. Transactions
CREATE TABLE public.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    currency VARCHAR(10) NOT NULL DEFAULT '₹',
    merchant_name VARCHAR(255),
    category VARCHAR(100) NOT NULL DEFAULT 'Others',
    description TEXT,
    provider VARCHAR(100),
    status VARCHAR(30) NOT NULL DEFAULT 'CONFIRMED',
    upi_transaction_id TEXT,
    transaction_reference TEXT,
    upi_id TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    location_accuracy_meters DOUBLE PRECISION,
    transaction_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_transactions_user
        FOREIGN KEY (user_id)
        REFERENCES public.users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_transactions_merchant
        FOREIGN KEY (merchant_name)
        REFERENCES public.merchants(name)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT fk_transactions_category
        FOREIGN KEY (category)
        REFERENCES public.categories(name)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_transactions_currency
        FOREIGN KEY (currency)
        REFERENCES public.currencies(symbol)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_transactions_status
        FOREIGN KEY (status)
        REFERENCES public.transaction_status(name)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_transactions_provider
        FOREIGN KEY (provider)
        REFERENCES public.payment_methods(name)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT transactions_amount_check
        CHECK (amount >= 0),

    CONSTRAINT transactions_latitude_check
        CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),

    CONSTRAINT transactions_longitude_check
        CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180),

    CONSTRAINT transactions_accuracy_check
        CHECK (
            location_accuracy_meters IS NULL
            OR location_accuracy_meters >= 0
        )
);