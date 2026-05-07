package com.satya.assignment.student;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface StudentProjectRepository extends JpaRepository<StudentProject, Integer> {
    List<StudentProject> findByStudentId(int studentId);
    Optional<StudentProject> findByStudentIdAndProjectId(int studentId, int projectId);
    void deleteByStudentIdAndProjectId(int studentId, int projectId);
}
