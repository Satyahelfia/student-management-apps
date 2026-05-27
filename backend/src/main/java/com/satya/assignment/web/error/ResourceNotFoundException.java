package com.satya.assignment.web.error;

import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

public class ResourceNotFoundException extends ResponseStatusException {

    public ResourceNotFoundException(String resourceName, int id) {
        super(HttpStatus.NOT_FOUND, resourceName + " with id " + id + " is not Found !");
    }

    public ResourceNotFoundException(String message) {
        super(HttpStatus.NOT_FOUND, message);
    }
}
