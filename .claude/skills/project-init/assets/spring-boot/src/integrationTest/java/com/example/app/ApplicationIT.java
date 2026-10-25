package com.example.app;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.assertj.MockMvcTester;

/** End-to-end smoke test: full context, real config, real HTTP layer (in-process). */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ApplicationIT {

  @Autowired private MockMvcTester mvc;

  @Test
  void healthIsUp() {
    assertThat(mvc.get().uri("/actuator/health"))
        .hasStatusOk()
        .bodyJson()
        .extractingPath("$.status")
        .isEqualTo("UP");
  }

  @Test
  void greetsThroughTheWholeStack() {
    assertThat(mvc.get().uri("/api/v1/greetings").param("name", "Ada"))
        .hasStatusOk()
        .bodyJson()
        .extractingPath("$.message")
        .isEqualTo("Hello, Ada!");
  }
}
