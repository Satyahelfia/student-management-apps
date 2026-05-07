package com.satya.assignment.auth;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/login")
    public AuthResponse authenticateAndGetToken(@RequestBody AuthRequest authRequest) {
        return authService.authenticate(authRequest);
    }

    @PostMapping("/register")
    public AuthResponse register(@RequestBody RegisterRequest registerRequest) {
        return authService.register(registerRequest);
    }

    @GetMapping("/me")
    public ResponseEntity<?> getMe() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated() || 
                authentication instanceof org.springframework.security.authentication.AnonymousAuthenticationToken) {
            return ResponseEntity.status(401).body("Not authenticated");
        }
        
        String username = authentication.getName();
        try {
            return ResponseEntity.ok(authService.getCurrentUserData(username));
        } catch (org.springframework.web.server.ResponseStatusException ex) {
            return ResponseEntity.status(ex.getStatusCode()).body(ex.getReason());
        }
    }
}

