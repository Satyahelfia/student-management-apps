package com.satya.assignment.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import com.satya.assignment.entity.AppUser;
import com.satya.assignment.entity.Project;
import com.satya.assignment.entity.Student;
import com.satya.assignment.entity.Project;
import com.satya.assignment.repository.AppUserRepository;
import com.satya.assignment.repository.ProjectRepository;
import com.satya.assignment.repository.StudentRepository;
import com.satya.assignment.repository.ProjectRepository;
import com.satya.assignment.service.StudentService;

import java.time.LocalDateTime;
import java.util.List;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private AppUserRepository appUserRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private ProjectRepository projectRepository;

    @Autowired
    private StudentService studentService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private ProjectRepository projectRepository;

    @Override
    public void run(String... args) throws Exception {
        // 1. Create Admin if not exists
        if (appUserRepository.findByUsername("admin").isEmpty()) {
            AppUser admin = new AppUser("admin", passwordEncoder.encode("admin"), "ADMIN");
            appUserRepository.save(admin);
            System.out.println("Admin user created automatically.");
        }

        // 2. Create 3 Lecturers if not exists
        String[] lecturers = { "lecturer1", "lecturer2", "lecturer3" };
        for (String lect : lecturers) {
            if (appUserRepository.findByUsername(lect).isEmpty()) {
                AppUser lecturerUser = new AppUser(lect, passwordEncoder.encode(lect), "LECTURER");
                appUserRepository.save(lecturerUser);
                System.out.println("Lecturer user created: " + lect);
            }
        }

        // 3. Seed Students & link accounts
        String[] students = { "student1", "student2", "student3", "student4", "student5", "student6", "student7" };
        String[] studentRealNames = {
                "Satya Helfi",
                "Agustianto Robin",
                "Shera Wijaya",
                "Budi Santoso",
                "Dewi Lestari",
                "Eko Prasetyo",
                "Fitri Handayani"
        };
        double[] studentAverages = { 9.0, 7.8, 8.8, 8.2, 7.5, 6.9, 8.5 };

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
                System.out.println(
                        "Student user account created: " + stdUsername + " linked to Student ID: " + profile.getId());
            } else if (appUser.getStudentId() == null) {
                appUser.setStudentId(profile.getId());
                appUserRepository.save(appUser);
                System.out.println(
                        "Updated student user account " + stdUsername + " with Student ID: " + profile.getId());
            }
        }
        // 4. Seed Projects
        String[] projects = {
                "Meeting Room Revamp",
                "Inventory Management System",
                "Smart Attendance App",
                "Internal HR Dashboard",
                "Warehouse Monitoring",
                "Sales Analytics Platform",
                "Booking Integration Service"
        };

        for (String projectName : projects) {

            boolean exists = projectRepository.findAll().stream()
                    .anyMatch(p -> p.getName().equalsIgnoreCase(projectName));

            if (!exists) {

                Project project = new Project();
                project.setName(projectName);

                projectRepository.save(project);

                System.out.println("Project created: " + projectName);
            }
        }

        // 4. Seed Projects if not exists
        String[] projectNames = {
            "E-Commerce Mobile Application",
            "IoT Smart Agriculture Dashboard",
            "Machine Learning Recommendation Engine"
        };

        for (String projName : projectNames) {
            Project proj = projectRepository.findAll().stream()
                    .filter(p -> p.getName().equalsIgnoreCase(projName))
                    .findFirst()
                    .orElse(null);
            
            if (proj == null) {
                proj = new Project();
                proj.setName(projName);
                projectRepository.save(proj);
                System.out.println("Project created: " + projName);
            }
        }

        // 5. Auto-assign at least one Project to Students to avoid empty Assignment views
        List<Student> allStudents = studentRepository.findAll();
        List<Project> allProjects = projectRepository.findAll();

        if (!allStudents.isEmpty() && !allProjects.isEmpty()) {
            for (int i = 0; i < allStudents.size(); i++) {
                Student s = allStudents.get(i);
                // If student has no projects yet, auto-assign one
                if (s.getProjects().isEmpty()) {
                    // Distribute projects using modulo
                    Project p = allProjects.get(i % allProjects.size());
                    LocalDateTime now = LocalDateTime.now();
                    studentService.addProjectToStudent(s.getId(), p.getId(), now, now.plusMonths(3));
                    System.out.println("Auto-assigned project '" + p.getName() + "' to student '" + s.getName() + "'");
                }
            }
        }
    }
}
