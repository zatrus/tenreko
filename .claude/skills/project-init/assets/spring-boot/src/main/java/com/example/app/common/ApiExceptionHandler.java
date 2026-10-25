package com.example.app.common;

import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

/** Maps exceptions to RFC 9457 problem+json responses. Framework errors are handled by the base. */
@RestControllerAdvice
class ApiExceptionHandler extends ResponseEntityExceptionHandler {

  @ExceptionHandler(DomainException.class)
  ProblemDetail handleDomain(DomainException ex) {
    ProblemDetail problem =
        ProblemDetail.forStatusAndDetail(HttpStatus.UNPROCESSABLE_CONTENT, ex.getMessage());
    problem.setTitle("Business rule violated");
    return problem;
  }
}
