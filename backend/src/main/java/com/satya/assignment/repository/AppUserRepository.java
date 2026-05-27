package com.satya.assignment.repository;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

import com.satya.assignment.entity.AppUser;

public interface AppUserRepository extends JpaRepository<AppUser, Long> {
    Optional<AppUser> findByUsername(String username);
}
