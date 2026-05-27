package com.satya.assignment.repository;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.satya.assignment.entity.Student;

@Repository
public interface StudentRepository extends JpaRepository<Student, Integer>{

    @Query("SELECT DISTINCT s FROM Student s LEFT JOIN FETCH s.projects")
    List<Student> findAllWithProjects();

    @Query("SELECT s FROM Student s LEFT JOIN FETCH s.projects WHERE s.id = :id")
    Optional<Student> findByIdWithProjects(@Param("id") int id);
}

