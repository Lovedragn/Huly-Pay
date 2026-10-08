-- HulyPay database schema

CREATE EXTENSION IF NOT EXISTS "pgcrypto";


-- Users

CREATE TABLE IF NOT EXISTS public.users (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
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
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT users_pkey PRIMARY KEY (id)
);


-- Merchants

CREATE TABLE IF NOT EXISTS public.merchants (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT merchants_pkey PRIMARY KEY (id)
);


-- Categories

CREATE TABLE IF NOT EXISTS public.categories (
    name VARCHAR(100) NOT NULL,
    CONSTRAINT categories_pkey PRIMARY KEY (name)
);


-- Currencies: only INR and USD

CREATE TABLE IF NOT EXISTS public.currencies (
    code VARCHAR(3) NOT NULL,
    symbol VARCHAR(10) NOT NULL UNIQUE,
    CONSTRAINT currencies_pkey PRIMARY KEY (code),
    CONSTRAINT currencies_code_check CHECK (code IN ('INR', 'USD')),
    CONSTRAINT currencies_symbol_check CHECK (symbol IN ('₹', '$'))
);


-- Transaction statuses

CREATE TABLE IF NOT EXISTS public.transaction_status (
    name VARCHAR(30) NOT NULL,
    CONSTRAINT transaction_status_pkey PRIMARY KEY (name)
);


-- Payment methods

CREATE TABLE IF NOT EXISTS public.payment_methods (
    method VARCHAR(100) NOT NULL,
    provider VARCHAR(100) NOT NULL,
    CONSTRAINT payment_methods_pkey PRIMARY KEY (method, provider)
);


-- Transactions

CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT '₹',
    merchant_name VARCHAR(255),
    category VARCHAR(100) NOT NULL DEFAULT 'Others',
    description TEXT,
    payment_method VARCHAR(100),
    provider VARCHAR(100),
    status VARCHAR(30) NOT NULL DEFAULT 'SUCCESS',
    upi_transaction_id TEXT,
    transaction_reference TEXT,
    upi_id TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    location_accuracy_meters DOUBLE PRECISION,
    transaction_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT transactions_pkey PRIMARY KEY (id),

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

    CONSTRAINT fk_transactions_payment_method
        FOREIGN KEY (payment_method, provider)
        REFERENCES public.payment_methods(method, provider)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT transactions_amount_check
        CHECK (amount >= 0),

    CONSTRAINT transactions_currency_check
        CHECK (currency IN ('₹', '$')),

    CONSTRAINT transactions_latitude_check
        CHECK (
            latitude IS NULL
            OR latitude BETWEEN -90 AND 90
        ),

    CONSTRAINT transactions_longitude_check
        CHECK (
            longitude IS NULL
            OR longitude BETWEEN -180 AND 180
        ),

    CONSTRAINT transactions_accuracy_check
        CHECK (
            location_accuracy_meters IS NULL
            OR location_accuracy_meters >= 0
        )
);


-- Supported currencies

INSERT INTO public.currencies (code, symbol)
VALUES
    ('INR', '₹'),
    ('USD', '$')
ON CONFLICT (code) DO NOTHING;


-- Categories

INSERT INTO public.categories (name)
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


-- Transaction statuses

INSERT INTO public.transaction_status (name)
VALUES
    ('SUCCESS'),
    ('PENDING'),
    ('FAILED'),
    ('CANCELLED'),
    ('TIMEOUT'),
    ('CONFIRMED'),
    ('SUBMITTED'),
    ('INITIATED')
ON CONFLICT (name) DO NOTHING;


-- Payment methods

INSERT INTO public.payment_methods (method, provider)
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


-- Indexes

CREATE INDEX IF NOT EXISTS idx_users_email
ON public.users(email);

CREATE INDEX IF NOT EXISTS idx_transactions_user_id
ON public.transactions(user_id);

CREATE INDEX IF NOT EXISTS idx_transactions_user_tx_time
ON public.transactions(user_id, transaction_time DESC);

CREATE INDEX IF NOT EXISTS idx_transactions_merchant_name
ON public.transactions(merchant_name);

CREATE INDEX IF NOT EXISTS idx_transactions_category
ON public.transactions(category);

CREATE INDEX IF NOT EXISTS idx_transactions_currency
ON public.transactions(currency);

CREATE INDEX IF NOT EXISTS idx_transactions_status
ON public.transactions(status);

CREATE INDEX IF NOT EXISTS idx_transactions_payment_method_provider
ON public.transactions(payment_method, provider);

CREATE INDEX IF NOT EXISTS idx_transactions_upi_transaction_id
ON public.transactions(upi_transaction_id);

CREATE INDEX IF NOT EXISTS idx_transactions_transaction_time
ON public.transactions(transaction_time);

CREATE INDEX IF NOT EXISTS idx_merchants_name
ON public.merchants(name);


-- Prevent duplicate UPI transactions per user

CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_user_upi_transaction
ON public.transactions(user_id, upi_transaction_id)
WHERE upi_transaction_id IS NOT NULL;


-- Updated-at function

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


-- Users updated-at trigger

CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();


-- Transactions updated-at trigger

CREATE TRIGGER trg_transactions_updated_at
BEFORE UPDATE ON public.transactions
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();


-- Supabase auth user provisioning

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.users (
        id,
        email,
        full_name,
        avatar_url,
        auth_provider
    )
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(
            NEW.raw_user_meta_data->>'full_name',
            NEW.raw_user_meta_data->>'name',
            ''
        ),
        NEW.raw_user_meta_data->>'avatar_url',
        COALESCE(
            NEW.raw_app_meta_data->>'provider',
            'email'
        )
    )
    ON CONFLICT (id)
    DO UPDATE SET
        email = EXCLUDED.email,
        updated_at = NOW();

    RETURN NEW;
END;
$$;


-- Supabase auth trigger

CREATE TRIGGER on_auth_user_created
AFTER INSERT OR UPDATE ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();


-- Enable RLS

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.merchants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.currencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaction_status ENABLE ROW LEVEL SECURITY;


-- Transaction RLS

CREATE POLICY "transactions_select_policy"
ON public.transactions
FOR SELECT
TO authenticated
USING (user_id = auth.uid());


CREATE POLICY "transactions_insert_policy"
ON public.transactions
FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());


CREATE POLICY "transactions_update_policy"
ON public.transactions
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());


CREATE POLICY "transactions_delete_policy"
ON public.transactions
FOR DELETE
TO authenticated
USING (user_id = auth.uid());


-- User RLS

CREATE POLICY "users_select_policy"
ON public.users
FOR SELECT
TO authenticated
USING (id = auth.uid());


CREATE POLICY "users_update_policy"
ON public.users
FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());


-- Currency read policy

CREATE POLICY "currencies_read_policy"
ON public.currencies
FOR SELECT
TO public
USING (true);


-- Category read policy

CREATE POLICY "categories_read_policy"
ON public.categories
FOR SELECT
TO public
USING (true);


-- Status read policy

CREATE POLICY "transaction_status_read_policy"
ON public.transaction_status
FOR SELECT
TO public
USING (true);


-- Payment method read policy

CREATE POLICY "payment_methods_read_policy"
ON public.payment_methods
FOR SELECT
TO public
USING (true);


-- Merchant read policy

CREATE POLICY "merchants_read_policy"
ON public.merchants
FOR SELECT
TO authenticated
USING (true);


-- Merchant insert policy

CREATE POLICY "merchants_insert_policy"
ON public.merchants
FOR INSERT
TO authenticated
WITH CHECK (true);