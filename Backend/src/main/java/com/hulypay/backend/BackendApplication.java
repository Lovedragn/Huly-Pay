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
                                ('SUCCESS'), ('PENDING'), ('FAILED'), ('CANCELLED'),
                                ('TIMEOUT'), ('CONFIRMED'), ('SUBMITTED'), ('INITIATED')
                            ON CONFLICT (name) DO NOTHING
                        """);

                        // 4. Ensure payment_methods lookup table exists
                        executeSql.accept("""
                            CREATE TABLE IF NOT EXISTS public.payment_methods (
                                method VARCHAR(100) NOT NULL,
                                provider VARCHAR(100) NOT NULL,
                                CONSTRAINT payment_methods_pkey PRIMARY KEY (method, provider)
                            )
                        """);
                        executeSql.accept("""
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
                            ON CONFLICT (method, provider) DO NOTHING
                        """);

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
                                ('Food & Dining'), ('Groceries'), ('Shopping'), ('Bills & Utilities'),
                                ('Entertainment'), ('Travel & Transport'), ('Health & Medical'),
                                ('Education'), ('Investments'), ('Personal Care'), ('Others')
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
                                CONSTRAINT transactions_pkey PRIMARY KEY (id)
                            )
                        """);

                        executeSql.accept("ALTER TABLE public.transactions ADD COLUMN IF NOT EXISTS currency VARCHAR(10) DEFAULT '₹'");
                        executeSql.accept("ALTER TABLE public.transactions ADD COLUMN IF NOT EXISTS merchant_name VARCHAR(255)");
                        executeSql.accept("ALTER TABLE public.transactions ADD COLUMN IF NOT EXISTS category VARCHAR(100) DEFAULT 'Others'");
                        executeSql.accept("ALTER TABLE public.transactions ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'SUCCESS'");

                        // Populate currency default
                        executeSql.accept("UPDATE public.transactions SET currency = '₹' WHERE currency IS NULL OR currency = 'INR'");
                        executeSql.accept("UPDATE public.transactions SET currency = '$' WHERE currency = 'USD'");
                        executeSql.accept("UPDATE public.transactions SET category = 'Others' WHERE category IS NULL");
                        executeSql.accept("UPDATE public.transactions SET status = 'SUCCESS' WHERE status IS NULL");

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
