package com.satya.assignment.auth;

import com.satya.assignment.security.JwtService;
import com.satya.assignment.user.AppUser;
import com.satya.assignment.user.AppUserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AuthService {

    @Autowired
    private JwtService jwtService;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private AppUserRepository appUserRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    public AuthResponse authenticate(AuthRequest authRequest) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(authRequest.getUsername(), authRequest.getPassword()));
        if (authentication.isAuthenticated()) {
            AppUser user = appUserRepository.findByUsername(authRequest.getUsername())
                    .orElseThrow(() -> new UsernameNotFoundException("invalid user request !"));
            return new AuthResponse(jwtService.generateToken(authRequest.getUsername(), user.getRole()));
        } else {
            throw new UsernameNotFoundException("invalid user request !");
        }
    }

    public AuthResponse register(RegisterRequest registerRequest) {
        // Validate passwords match
        if (!registerRequest.getPassword().equals(registerRequest.getConfirmPassword())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Passwords do not match");
        }

        // Validate username length
        if (registerRequest.getUsername() == null || registerRequest.getUsername().trim().length() < 3) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Username must be at least 3 characters");
        }

        // Validate password length
        if (registerRequest.getPassword() == null || registerRequest.getPassword().length() < 4) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Password must be at least 4 characters");
        }

        // Check if username already exists
        if (appUserRepository.findByUsername(registerRequest.getUsername()).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Username already exists");
        }

        // Create new user
        AppUser newUser = new AppUser(
                registerRequest.getUsername(),
                passwordEncoder.encode(registerRequest.getPassword()),
                "USER"
        );
        appUserRepository.save(newUser);

        // Auto-login after registration
        return new AuthResponse(jwtService.generateToken(registerRequest.getUsername(), "USER"));
    }

    public java.util.Map<String, Object> getCurrentUserData(String username) {
        AppUser user = appUserRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        java.util.Map<String, Object> response = new java.util.HashMap<>();
        response.put("username", user.getUsername());
        response.put("role", user.getRole());
        response.put("studentId", user.getStudentId());
        return response;
    }
}

