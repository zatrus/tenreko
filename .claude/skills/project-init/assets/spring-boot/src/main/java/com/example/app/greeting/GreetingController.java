package com.example.app.greeting;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/greetings")
class GreetingController {

  private final GreetingService service;

  GreetingController(GreetingService service) {
    this.service = service;
  }

  @GetMapping
  Greeting greet(@RequestParam String name) {
    return service.greet(name);
  }
}
