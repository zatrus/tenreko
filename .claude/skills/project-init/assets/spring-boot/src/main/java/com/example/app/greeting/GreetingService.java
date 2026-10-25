package com.example.app.greeting;

import org.springframework.stereotype.Service;

@Service
class GreetingService {

  private final GreetingProperties properties;

  GreetingService(GreetingProperties properties) {
    this.properties = properties;
  }

  Greeting greet(String name) {
    String trimmed = name.strip();
    if (trimmed.isEmpty()) {
      throw new BlankNameException();
    }
    return new Greeting(properties.template().formatted(trimmed));
  }
}
