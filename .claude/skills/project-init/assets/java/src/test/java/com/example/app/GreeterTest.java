package com.example.app;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

class GreeterTest {

  private final Greeter greeter = new Greeter();

  @Test
  void greetsByName() {
    String result = greeter.greet("Ada");

    assertThat(result).isEqualTo("Hello, Ada!");
  }

  @ParameterizedTest
  @ValueSource(strings = {"", "   ", "\t"})
  void rejectsBlankName(String blank) {
    assertThatThrownBy(() -> greeter.greet(blank))
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessageContaining("blank");
  }
}
