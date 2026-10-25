package com.example.app;

import java.util.Objects;

/** Example class showing the conventions. Delete it with its test once real code exists. */
public final class Greeter {

  /** Returns a greeting for {@code name}. */
  public String greet(String name) {
    Objects.requireNonNull(name, "name");
    String trimmed = name.strip();
    if (trimmed.isEmpty()) {
      throw new IllegalArgumentException("name must not be blank");
    }
    return "Hello, " + trimmed + "!";
  }
}
