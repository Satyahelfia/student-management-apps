package com.satya.assignment.security;

import com.satya.assignment.model.AppUser;
import com.satya.assignment.repository.AppUserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    @Autowired
    private AppUserRepository appUserRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Optional<AppUser> appUser = appUserRepository.findByUsername(username);
        return appUser.map(user -> User.withUsername(user.getUsername())
                .password(user.getPassword())
                .roles(user.getRole())
                .build())
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));
    }
}
