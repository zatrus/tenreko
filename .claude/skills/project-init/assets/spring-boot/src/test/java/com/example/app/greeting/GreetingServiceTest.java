package com.example.app.greeting;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

class GreetingServiceTest {

  private final GreetingService service = new GreetingService(new GreetingProperties("Hello, %s!"));

  @Test
  void greetsByTrimmedName() {
    Greeting result = service.greet("  Ada ");

    assertThat(result.message()).isEqualTo("Hello, Ada!");
  }

  @ParameterizedTest
  @ValueSource(strings = {"", "   "})
  void rejectsBlankName(String blank) {
    assertThatThrownBy(() -> service.greet(blank)).isInstanceOf(BlankNameException.class);
  }
}
