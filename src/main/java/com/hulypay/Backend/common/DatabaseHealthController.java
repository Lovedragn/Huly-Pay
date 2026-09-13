package com.hulypay.backend.common;

import javax.sql.DataSource;
import java.sql.Connection;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DatabaseHealthController {

    private final DataSource dataSource;

    public DatabaseHealthController(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @GetMapping("/api/health/database")
    public DatabaseHealthResponse databaseHealth() {

        try (Connection connection = dataSource.getConnection()) {

            boolean valid = connection.isValid(2);

            return new DatabaseHealthResponse(
                    valid ? "UP" : "DOWN",
                    connection.getMetaData().getDatabaseProductName()
            );

        } catch (Exception exception) {

            return new DatabaseHealthResponse(
                    "DOWN",
                    exception.getMessage()
            );
        }
    }

    public record DatabaseHealthResponse(
            String status,
            String database
    ) {
    }
}