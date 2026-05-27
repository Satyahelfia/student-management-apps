package com.satya.assignment.service;

import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.satya.assignment.entity.Project;
import com.satya.assignment.entity.Student;
import com.satya.assignment.repository.StudentRepository;

@Service
public class AssignmentService {

    @Autowired
    private StudentRepository studentRepository;

    public HashMap<String, List<String>> assignProjectToStudent() {
        HashMap<String, List<String>> assignList = new HashMap<>();
        List<Student> listStudent = studentRepository.findAllWithProjects();
        for (Student s : listStudent) {
            List<String> projectNames = s.getProjects().stream()
                    .map(Project::getName)
                    .collect(Collectors.toList());
            assignList.put(s.getName(), projectNames);
        }
        return assignList;
    }
}

