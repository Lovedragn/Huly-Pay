package com.hulypay.backend.common;

import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {

    @GetMapping("/")
    public Map<String, Object> root() {
        return Map.of(
                "service", "Huly.Pay Backend API",
                "status", "UP",
                "swaggerUi", "/swagger-ui/index.html",
                "health", "/api/health",
                "databaseHealth", "/api/health/database"
        );
    }

    @GetMapping("/api/health")
    public HealthResponse health() {
        return new HealthResponse(
                "UP",
                "Huly.Pay backend is running"
        );
    }

    public record HealthResponse(
            String status,
            String message
    ) {
    }
}