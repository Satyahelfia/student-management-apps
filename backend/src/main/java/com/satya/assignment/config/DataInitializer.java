package com.satya.assignment.config;

import com.satya.assignment.user.AppUser;
import com.satya.assignment.user.AppUserRepository;
import com.satya.assignment.student.Student;
import com.satya.assignment.student.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private AppUserRepository appUserRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        // 1. Create Admin if not exists
        if (appUserRepository.findByUsername("admin").isEmpty()) {
            AppUser admin = new AppUser("admin", passwordEncoder.encode("admin"), "ADMIN");
            appUserRepository.save(admin);
            System.out.println("Admin user created automatically.");
        }

        // 2. Create 3 Lecturers if not exists
        String[] lecturers = {"lecturer1", "lecturer2", "lecturer3"};
        for (String lect : lecturers) {
            if (appUserRepository.findByUsername(lect).isEmpty()) {
                AppUser lecturerUser = new AppUser(lect, passwordEncoder.encode(lect), "LECTURER");
                appUserRepository.save(lecturerUser);
                System.out.println("Lecturer user created: " + lect);
            }
        }

        // 3. Seed Students & link accounts
        String[] students = {"student1", "student2", "student3", "student4", "student5", "student6", "student7"};
        String[] studentRealNames = {
            "Satya Helfi", 
            "Agustianto Robin", 
            "Shera Wijaya", 
            "Budi Santoso", 
            "Dewi Lestari", 
            "Eko Prasetyo", 
            "Fitri Handayani"
        };
        double[] studentAverages = {9.0, 7.8, 8.8, 8.2, 7.5, 6.9, 8.5};

        for (int i = 0; i < students.length; i++) {
            final String currentName = studentRealNames[i];
            
            // A. Manage Student profile
            Student profile = studentRepository.findAll().stream()
                    .filter(s -> s.getName().equalsIgnoreCase(currentName))
                    .findFirst()
                    .orElse(null);

            if (profile == null) {
                profile = new Student();
                profile.setName(currentName);
                profile.setAverage(studentAverages[i]);
                profile = studentRepository.save(profile);
                System.out.println("Student profile created: " + currentName + " (ID: " + profile.getId() + ")");
            }

            // B. Manage AppUser authentication account
            String stdUsername = students[i];
            AppUser appUser = appUserRepository.findByUsername(stdUsername).orElse(null);
            if (appUser == null) {
                appUser = new AppUser(stdUsername, passwordEncoder.encode(stdUsername), "STUDENT", profile.getId());
                appUserRepository.save(appUser);
                System.out.println("Student user account created: " + stdUsername + " linked to Student ID: " + profile.getId());
            } else if (appUser.getStudentId() == null) {
                appUser.setStudentId(profile.getId());
                appUserRepository.save(appUser);
                System.out.println("Updated student user account " + stdUsername + " with Student ID: " + profile.getId());
            }
        }
    }
}
