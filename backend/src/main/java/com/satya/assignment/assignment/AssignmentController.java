package com.satya.assignment.assignment;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;

@RestController
@RequestMapping("/students")
public class AssignmentController {

    @Autowired
    private AssignmentService assignmentService;

    @GetMapping("/assignment")
    public ResponseEntity<java.util.HashMap<String, java.util.List<String>>> assignProjectToStudent() {
        return ResponseEntity.ok(assignmentService.assignProjectToStudent());
    }

}
