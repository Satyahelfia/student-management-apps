package com.satya.assignment.student;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StudentRepository extends JpaRepository<Student, Integer>{

    @Query("SELECT DISTINCT s FROM Student s LEFT JOIN FETCH s.projects")
    List<Student> findAllWithProjects();

    @Query("SELECT s FROM Student s LEFT JOIN FETCH s.projects WHERE s.id = :id")
    Optional<Student> findByIdWithProjects(@Param("id") int id);
}

