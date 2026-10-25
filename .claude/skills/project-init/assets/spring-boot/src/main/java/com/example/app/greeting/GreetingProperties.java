package com.example.app.greeting;

import jakarta.validation.constraints.NotBlank;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

/**
 * Typed configuration under {@code app.greeting}. Example feature: delete when real code exists.
 */
@Validated
@ConfigurationProperties("app.greeting")
record GreetingProperties(@NotBlank String template) {}
