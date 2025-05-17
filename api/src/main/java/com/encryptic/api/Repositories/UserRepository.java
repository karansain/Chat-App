package com.encryptic.api.Repositories;

// package com.api.encryptic.Repositories;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.encryptic.api.Models.User;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    // Method to find a user by email
    Optional<User> findByEmail(String email);

    // Method to find a user by username
    Optional<User> findByUsername(String username);

    Optional<User> findById(Long userId);

    Optional<User> findUserByPrivateKey(String privateKey);

    Optional<User> findUserByRawPrivateKey(String decodedKey);

}

