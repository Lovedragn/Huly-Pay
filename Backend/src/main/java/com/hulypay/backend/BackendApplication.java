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
     * Ensures existing PostgreSQL tables in Supabase match the normalized unencrypted schema.
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

                        // 2. Ensure currencies lookup table exists
                        executeSql.accept("""
                            CREATE TABLE IF NOT EXISTS currencies (
                                code CHAR(3) PRIMARY KEY,
                                symbol VARCHAR(5) NOT NULL
                            )
                        """);

                        // 3. Ensure transaction_status lookup table exists
                        executeSql.accept("""
                            DO $$
                            BEGIN
                                IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'transaction_statuses')
                                   AND NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'transaction_status') THEN
                                    ALTER TABLE transaction_statuses RENAME TO transaction_status;
                                END IF;
                            END $$;
                        """);
                        executeSql.accept("""
                            CREATE TABLE IF NOT EXISTS transaction_status (
                                code SMALLINT PRIMARY KEY,
                                name VARCHAR(30) NOT NULL UNIQUE
                            )
                        """);

                        // 4. Ensure payment_methods lookup table exists
                        executeSql.accept("""
                            CREATE TABLE IF NOT EXISTS payment_methods (
                                method VARCHAR(100) NOT NULL,
                                provider VARCHAR(100) NOT NULL,
                                PRIMARY KEY (method, provider)
                            )
                        """);

                        // 5. Ensure merchants table exists and has uuid default
                        executeSql.accept("""
                            CREATE TABLE IF NOT EXISTS merchants (
                                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                name VARCHAR(255) NOT NULL UNIQUE,
                                created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
                            )
                        """);
                        executeSql.accept("ALTER TABLE merchants ALTER COLUMN id SET DEFAULT gen_random_uuid()");
                        executeSql.accept("ALTER TABLE merchants ALTER COLUMN created_at SET DEFAULT NOW()");

                        // 6. Align categories table to clean (name VARCHAR(100) PRIMARY KEY)
                        executeSql.accept("""
                            DO $$
                            BEGIN
                                IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'categories' AND column_name = 'id') THEN
                                    CREATE TABLE IF NOT EXISTS categories_clean (
                                        name VARCHAR(100) PRIMARY KEY
                                    );
                                    INSERT INTO categories_clean (name)
                                    SELECT DISTINCT TRIM(name)
                                    FROM categories
                                    WHERE name IS NOT NULL AND TRIM(name) <> ''
                                    ON CONFLICT (name) DO NOTHING;
                                    
                                    DROP TABLE categories CASCADE;
                                    ALTER TABLE categories_clean RENAME TO categories;
                                ELSIF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'categories') THEN
                                    CREATE TABLE categories (
                                        name VARCHAR(100) PRIMARY KEY
                                    );
                                END IF;
                            END $$;
                        """);

                        // 7. Align transactions table columns
                        executeSql.accept("ALTER TABLE transactions ADD COLUMN IF NOT EXISTS currency_code CHAR(3) DEFAULT 'INR'");
                        executeSql.accept("ALTER TABLE transactions ADD COLUMN IF NOT EXISTS status_code SMALLINT DEFAULT 1");
                        executeSql.accept("ALTER TABLE transactions ADD COLUMN IF NOT EXISTS category_name VARCHAR(100)");
                        executeSql.accept("ALTER TABLE transactions ADD COLUMN IF NOT EXISTS merchant_id UUID");

                        executeSql.accept("UPDATE transactions SET currency_code = 'INR' WHERE currency_code IS NULL");
                        executeSql.accept("UPDATE transactions SET status_code = 1 WHERE status_code IS NULL");

                        // Populate category_name from legacy category column if present
                        executeSql.accept("""
                            DO $$
                            BEGIN
                                IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'transactions' AND column_name = 'category') THEN
                                    UPDATE transactions SET category_name = TRIM(category) WHERE category_name IS NULL AND category IS NOT NULL;
                                END IF;
                            END $$;
                        """);

                        // Deduplicate and populate merchants from legacy merchant_name
                        executeSql.accept("""
                            DO $$
                            BEGIN
                                IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'transactions' AND column_name = 'merchant_name') THEN
                                    INSERT INTO merchants (id, name)
                                    SELECT gen_random_uuid(), TRIM(merchant_name)
                                    FROM transactions
                                    WHERE merchant_name IS NOT NULL AND TRIM(merchant_name) <> ''
                                    ON CONFLICT (name) DO NOTHING;

                                    UPDATE transactions t
                                    SET merchant_id = m.id
                                    FROM merchants m
                                    WHERE TRIM(t.merchant_name) = m.name AND t.merchant_id IS NULL;
                                END IF;
                            END $$;
                        """);

                        executeSql.accept("ALTER TABLE transactions ALTER COLUMN description TYPE TEXT");
                        executeSql.accept("ALTER TABLE transactions ALTER COLUMN upi_transaction_id TYPE TEXT");
                        executeSql.accept("ALTER TABLE transactions ALTER COLUMN transaction_reference TYPE TEXT");
                        executeSql.accept("ALTER TABLE transactions ALTER COLUMN upi_id TYPE TEXT");

                        // 8. Align users table columns to unencrypted plaintext
                        executeSql.accept("ALTER TABLE users ALTER COLUMN email DROP NOT NULL");
                        executeSql.accept("ALTER TABLE users ALTER COLUMN full_name TYPE TEXT");
                        executeSql.accept("ALTER TABLE users ALTER COLUMN first_name TYPE TEXT");
                        executeSql.accept("ALTER TABLE users ALTER COLUMN last_name TYPE TEXT");
                        executeSql.accept("ALTER TABLE users ALTER COLUMN phone_number TYPE TEXT");
                        executeSql.accept("ALTER TABLE users ALTER COLUMN avatar_url TYPE TEXT");
                        executeSql.accept("ALTER TABLE users ALTER COLUMN auth_provider TYPE TEXT");
                        executeSql.accept("ALTER TABLE users ALTER COLUMN provider_subject TYPE TEXT");

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
