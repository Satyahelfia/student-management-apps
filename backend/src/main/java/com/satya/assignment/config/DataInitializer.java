package com.satya.assignment.config;

import com.satya.assignment.model.AppUser;
import com.satya.assignment.repository.AppUserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private AppUserRepository appUserRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        if (appUserRepository.findByUsername("admin").isEmpty()) {
            AppUser admin = new AppUser("admin", passwordEncoder.encode("admin"), "ADMIN");
            appUserRepository.save(admin);
            System.out.println("Admin user created automatically.");
        }
    }
}
