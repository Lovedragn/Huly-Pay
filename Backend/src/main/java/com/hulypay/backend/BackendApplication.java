package com.hulypay.backend;

import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.Statement;
import java.util.TimeZone;

@Slf4j
@SpringBootApplication
public class BackendApplication {

    static {
        TimeZone.setDefault(TimeZone.getTimeZone("UTC"));
        loadDotEnv();
    }

    @PostConstruct
    public void init() {
        TimeZone.setDefault(TimeZone.getTimeZone("UTC"));
    }

    /**
     * Executes schema alignment BEFORE Hibernate EntityManagerFactory initializes.
     * Ensures existing PostgreSQL tables in Supabase match the schema in schema-migration.sql.
     */
    @Bean
    public static BeanPostProcessor dataSourceMigrationPostProcessor() {
        return new BeanPostProcessor() {
            @Override
            public Object postProcessAfterInitialization(Object bean, String beanName) {
                if (bean instanceof DataSource dataSource) {
                    try (Connection conn = dataSource.getConnection();
                         Statement stmt = conn.createStatement()) {

                        // Helper runner for individual idempotent SQL statements
                        java.util.function.Consumer<String> executeSql = sql -> {
                            try {
                                stmt.execute(sql);
                            } catch (Exception e) {
                                log.debug("Notice during schema migration step [{}]: {}", sql, e.getMessage());
                            }
                        };

                        executeSql.accept("CREATE EXTENSION IF NOT EXISTS \"pgcrypto\"");

                        // 1. Clean up legacy unused tables
                        executeSql.accept("DROP TABLE IF EXISTS payments CASCADE");
                        executeSql.accept("DROP TABLE IF EXISTS expenses CASCADE");

                        // 2. Ensure currencies lookup table exists with INR and USD
                        executeSql.accept("""
                            CREATE TABLE IF NOT EXISTS public.currencies (
                                code VARCHAR(3) NOT NULL,
                                symbol VARCHAR(10) NOT NULL UNIQUE,
                                CONSTRAINT currencies_pkey PRIMARY KEY (code)
                            )
                        """);
                        executeSql.accept("""
                            INSERT INTO public.currencies (code, symbol)
                            VALUES ('INR', '₹'), ('USD', '$')
                            ON CONFLICT (code) DO NOTHING
                        """);

                        // 3. Ensure transaction_status lookup table exists (primary key name)
                        executeSql.accept("""
                            CREATE TABLE IF NOT EXISTS public.transaction_status (
                                name VARCHAR(30) NOT NULL,
                                CONSTRAINT transaction_status_pkey PRIMARY KEY (name)
                            )
                        """);
                        executeSql.accept("""
                            INSERT INTO public.transaction_status (name)
                            VALUES
                                ('CONFIRMED'), ('PENDING')
                            ON CONFLICT (name) DO NOTHING
                        """);

                        // 4. Ensure payment_methods lookup table exists (providers)
                        executeSql.accept("""
                            CREATE TABLE IF NOT EXISTS public.payment_methods (
                                name VARCHAR(100) NOT NULL,
                                CONSTRAINT payment_methods_pkey PRIMARY KEY (name)
                            )
                        """);
                        executeSql.accept("""
                            INSERT INTO public.payment_methods (name)
                            VALUES
                                ('GOOGLE_PAY'),
                                ('BHIM'),
                                ('AMAZON_PAY'),
                                ('PHONEPE'),
                                ('PAYTM'),
                                ('WHATSAPP_PAY'),
                                ('UPI'),
                                ('CASH'),
                                ('NET_BANKING')
                            ON CONFLICT (name) DO NOTHING
                        """);
                        executeSql.accept("UPDATE public.transactions SET provider = 'GOOGLE_PAY' WHERE provider ILIKE 'gpay'");
                        executeSql.accept("DELETE FROM public.payment_methods WHERE name ILIKE 'gpay'");

                        // 5. Ensure merchants table exists
                        executeSql.accept("""
                            CREATE TABLE IF NOT EXISTS public.merchants (
                                id UUID NOT NULL DEFAULT gen_random_uuid(),
                                name VARCHAR(255) NOT NULL UNIQUE,
                                created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                                CONSTRAINT merchants_pkey PRIMARY KEY (id)
                            )
                        """);
                        executeSql.accept("ALTER TABLE public.merchants ALTER COLUMN id SET DEFAULT gen_random_uuid()");
                        executeSql.accept("ALTER TABLE public.merchants ALTER COLUMN created_at SET DEFAULT NOW()");

                        // 6. Ensure categories table exists
                        executeSql.accept("""
                            CREATE TABLE IF NOT EXISTS public.categories (
                                name VARCHAR(100) NOT NULL,
                                CONSTRAINT categories_pkey PRIMARY KEY (name)
                            )
                        """);
                        executeSql.accept("""
                            INSERT INTO public.categories (name)
                            VALUES
                                ('Food & Dining'), ('Shopping'), ('Bills & Utilities'),
                                ('Travel & Transport'), ('Health & Medical'), ('Investments'),
                                ('Unwanted Expenses'), ('Others')
                            ON CONFLICT (name) DO NOTHING
                        """);

                        // 7. Ensure transactions table columns and constraints match schema
                        executeSql.accept("""
                            CREATE TABLE IF NOT EXISTS public.transactions (
                                id UUID NOT NULL DEFAULT gen_random_uuid(),
                                user_id UUID NOT NULL,
                                amount NUMERIC(12,2) NOT NULL,
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
                                CONSTRAINT transactions_pkey PRIMARY KEY (id)
                            )
                        """);

                        executeSql.accept("ALTER TABLE public.transactions ADD COLUMN IF NOT EXISTS currency VARCHAR(10) DEFAULT '₹'");
                        executeSql.accept("ALTER TABLE public.transactions ADD COLUMN IF NOT EXISTS merchant_name VARCHAR(255)");
                        executeSql.accept("ALTER TABLE public.transactions ADD COLUMN IF NOT EXISTS category VARCHAR(100) DEFAULT 'Others'");
                        executeSql.accept("ALTER TABLE public.transactions ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'CONFIRMED'");

                        // Populate currency default
                        executeSql.accept("UPDATE public.transactions SET currency = '₹' WHERE currency IS NULL OR currency = 'INR'");
                        executeSql.accept("UPDATE public.transactions SET currency = '$' WHERE currency = 'USD'");
                        // Normalize transactions.status to only CONFIRMED and PENDING
                        executeSql.accept("UPDATE public.transactions SET status = 'CONFIRMED' WHERE status IS NULL OR status = 'SUCCESS' OR status = 'COMPLETED' OR status = 'SETTLED'");
                        executeSql.accept("UPDATE public.transactions SET status = 'PENDING' WHERE status = 'INITIATED' OR status = 'SUBMITTED' OR status = 'TIMEOUT'");
                        executeSql.accept("UPDATE public.transactions SET status = 'CONFIRMED' WHERE status NOT IN ('CONFIRMED', 'PENDING')");

                        // Ensure transaction_status contains only CONFIRMED and PENDING
                        executeSql.accept("INSERT INTO public.transaction_status (name) VALUES ('CONFIRMED'), ('PENDING') ON CONFLICT (name) DO NOTHING");
                        executeSql.accept("DELETE FROM public.transaction_status WHERE name NOT IN ('CONFIRMED', 'PENDING')");

                        // Ensure fk_transactions_status exists linking transactions.status -> transaction_status.name
                        executeSql.accept("""
                            DO $$
                            BEGIN
                                IF NOT EXISTS (
                                    SELECT 1 FROM information_schema.table_constraints
                                    WHERE constraint_name = 'fk_transactions_status' AND table_name = 'transactions'
                                ) THEN
                                    ALTER TABLE public.transactions
                                    ADD CONSTRAINT fk_transactions_status
                                    FOREIGN KEY (status)
                                    REFERENCES public.transaction_status(name)
                                    ON DELETE RESTRICT
                                    ON UPDATE CASCADE;
                                END IF;

                                IF NOT EXISTS (
                                    SELECT 1 FROM information_schema.table_constraints
                                    WHERE constraint_name = 'fk_transactions_provider' AND table_name = 'transactions'
                                ) THEN
                                    ALTER TABLE public.transactions
                                    DROP CONSTRAINT IF EXISTS fk_transactions_payment_method;

                                    ALTER TABLE public.transactions
                                    ADD CONSTRAINT fk_transactions_provider
                                    FOREIGN KEY (provider)
                                    REFERENCES public.payment_methods(name)
                                    ON DELETE RESTRICT
                                    ON UPDATE CASCADE;
                                END IF;

                                -- Safely migrate any remaining payment_method values into provider, then drop column
                                IF EXISTS (
                                    SELECT 1 FROM information_schema.columns
                                    WHERE table_schema = 'public' AND table_name = 'transactions' AND column_name = 'payment_method'
                                ) THEN
                                    UPDATE public.transactions
                                    SET provider = payment_method
                                    WHERE (provider IS NULL OR provider = '') AND payment_method IS NOT NULL AND payment_method <> '';

                                    DROP INDEX IF EXISTS public.idx_transactions_payment_method_provider;

                                    ALTER TABLE public.transactions
                                    DROP COLUMN payment_method;
                                END IF;

                                CREATE INDEX IF NOT EXISTS idx_transactions_provider
                                ON public.transactions(provider);
                            END $$;
                        """);

                        // Populate merchants from transactions.merchant_name
                        executeSql.accept("""
                            INSERT INTO public.merchants (id, name)
                            SELECT gen_random_uuid(), TRIM(merchant_name)
                            FROM public.transactions
                            WHERE merchant_name IS NOT NULL AND TRIM(merchant_name) <> ''
                            ON CONFLICT (name) DO NOTHING
                        """);

                        // Ensure users table matches
                        executeSql.accept("ALTER TABLE public.users ALTER COLUMN email DROP NOT NULL");
                        executeSql.accept("ALTER TABLE public.users ALTER COLUMN full_name TYPE TEXT");
                        executeSql.accept("ALTER TABLE public.users ALTER COLUMN first_name TYPE TEXT");
                        executeSql.accept("ALTER TABLE public.users ALTER COLUMN last_name TYPE TEXT");
                        executeSql.accept("ALTER TABLE public.users ALTER COLUMN phone_number TYPE TEXT");
                        executeSql.accept("ALTER TABLE public.users ALTER COLUMN avatar_url TYPE TEXT");
                        executeSql.accept("ALTER TABLE public.users ALTER COLUMN auth_provider TYPE VARCHAR(50)");
                        executeSql.accept("ALTER TABLE public.users ALTER COLUMN provider_subject TYPE TEXT");

                        log.info("Pre-Hibernate database schema alignment executed successfully");
                    } catch (Exception e) {
                        log.warn("Database migration warning: {}", e.getMessage());
                    }
                }
                return bean;
            }
        };
    }

    public static void main(String[] args) {
        TimeZone.setDefault(TimeZone.getTimeZone("UTC"));
        loadDotEnv();
        SpringApplication.run(BackendApplication.class, args);
    }

    private static void loadDotEnv() {
        try {
            java.nio.file.Path envPath = java.nio.file.Paths.get(".env");
            if (!java.nio.file.Files.exists(envPath)) {
                envPath = java.nio.file.Paths.get("../.env");
            }
            if (java.nio.file.Files.exists(envPath)) {
                for (String line : java.nio.file.Files.readAllLines(envPath)) {
                    line = line.trim();
                    if (!line.isEmpty() && !line.startsWith("#") && line.contains("=")) {
                        String[] parts = line.split("=", 2);
                        String key = parts[0].trim();
                        String value = parts[1].trim();
                        if (System.getProperty(key) == null && System.getenv(key) == null) {
                            System.setProperty(key, value);
                        }
                    }
                }
            }
        } catch (Exception ignored) {
        }
    }
}
