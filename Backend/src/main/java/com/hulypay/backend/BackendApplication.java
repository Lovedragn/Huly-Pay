package com.hulypay.backend;

import jakarta.annotation.PostConstruct;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.util.TimeZone;

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

    @org.springframework.context.annotation.Bean
    public org.springframework.boot.CommandLineRunner alignEncryptedColumns(javax.sql.DataSource dataSource) {
        return args -> {
            try (java.sql.Connection conn = dataSource.getConnection();
                 java.sql.Statement stmt = conn.createStatement()) {
                // Ensure all encrypted columns in transactions and users tables use TEXT type in PostgreSQL
                stmt.execute("""
                    DO $$
                    BEGIN
                        -- transactions table columns
                        IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'transactions') THEN
                            ALTER TABLE transactions ALTER COLUMN merchant_name TYPE TEXT;
                            ALTER TABLE transactions ALTER COLUMN description TYPE TEXT;
                            ALTER TABLE transactions ALTER COLUMN payment_method TYPE TEXT;
                            ALTER TABLE transactions ALTER COLUMN provider TYPE TEXT;
                            ALTER TABLE transactions ALTER COLUMN upi_transaction_id TYPE TEXT;
                            ALTER TABLE transactions ALTER COLUMN transaction_reference TYPE TEXT;
                            ALTER TABLE transactions ALTER COLUMN upi_id TYPE TEXT;
                        END IF;

                        -- users table columns
                        IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'users') THEN
                            ALTER TABLE users ALTER COLUMN full_name TYPE TEXT;
                            ALTER TABLE users ALTER COLUMN first_name TYPE TEXT;
                            ALTER TABLE users ALTER COLUMN last_name TYPE TEXT;
                            ALTER TABLE users ALTER COLUMN phone_number TYPE TEXT;
                            ALTER TABLE users ALTER COLUMN avatar_url TYPE TEXT;
                            ALTER TABLE users ALTER COLUMN auth_provider TYPE TEXT;
                            ALTER TABLE users ALTER COLUMN provider_subject TYPE TEXT;
                        END IF;
                    END $$;
                """);
            } catch (Exception e) {
                // Ignore if tables do not exist yet or on non-Postgres test instances
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


