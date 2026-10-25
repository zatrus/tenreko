package com.example.app.greeting;

import com.example.app.common.DomainException;

class BlankNameException extends DomainException {

  private static final long serialVersionUID = 1L;

  BlankNameException() {
    super("name must not be blank");
  }
}
