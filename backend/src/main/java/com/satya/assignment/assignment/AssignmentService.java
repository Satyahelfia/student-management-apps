package com.satya.assignment.assignment;

import com.satya.assignment.project.Project;
import com.satya.assignment.student.Student;
import com.satya.assignment.student.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;

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

