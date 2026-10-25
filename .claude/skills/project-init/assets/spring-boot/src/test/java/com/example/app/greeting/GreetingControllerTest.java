package com.example.app.greeting;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.BDDMockito.given;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.assertj.MockMvcTester;

@WebMvcTest(GreetingController.class)
class GreetingControllerTest {

  @Autowired private MockMvcTester mvc;

  @MockitoBean private GreetingService service;

  @Test
  void returnsGreetingAsJson() {
    given(service.greet("Ada")).willReturn(new Greeting("Hello, Ada!"));

    assertThat(mvc.get().uri("/api/v1/greetings").param("name", "Ada"))
        .hasStatusOk()
        .bodyJson()
        .extractingPath("$.message")
        .isEqualTo("Hello, Ada!");
  }

  @Test
  void mapsDomainErrorToProblemDetail() {
    given(service.greet(" ")).willThrow(new BlankNameException());

    assertThat(mvc.get().uri("/api/v1/greetings").param("name", " "))
        .hasStatus(HttpStatus.UNPROCESSABLE_CONTENT)
        .hasContentTypeCompatibleWith(MediaType.APPLICATION_PROBLEM_JSON)
        .bodyJson()
        .extractingPath("$.detail")
        .isEqualTo("name must not be blank");
  }

  @Test
  void rejectsMissingNameParameter() {
    assertThat(mvc.get().uri("/api/v1/greetings")).hasStatus(HttpStatus.BAD_REQUEST);
  }
}
