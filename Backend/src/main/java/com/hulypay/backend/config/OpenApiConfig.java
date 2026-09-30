package com.hulypay.backend.Config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

        @Value("${app.openapi.title:Huly.Pay API Documentation}")
        private String title;

        @Value("${app.openapi.version:latest}")
        private String version;

        @Value("${app.openapi.description:REST API endpoints for Huly.Pay backend services}")
        private String description;

        @Bean
        public OpenAPI customOpenAPI() {
                return new OpenAPI()
                                .info(new Info()
                                                .title(title)
                                                .version(version)
                                                .description(description))
                                .addSecurityItem(new SecurityRequirement().addList("BearerAuth"))
                                .components(new Components()
                                                .addSecuritySchemes("BearerAuth", new SecurityScheme()
                                                                .name("BearerAuth")
                                                                .type(SecurityScheme.Type.HTTP)
                                                                .scheme("bearer")
                                                                .bearerFormat("JWT")));
        }
}
