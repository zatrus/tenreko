package com.example.app.common;

/**
 * Base class for expected business-rule violations. Mapped to HTTP 422 by {@link
 * ApiExceptionHandler}.
 */
public abstract class DomainException extends RuntimeException {

  private static final long serialVersionUID = 1L;

  protected DomainException(String message) {
    super(message);
  }
}
