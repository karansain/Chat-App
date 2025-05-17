package com.encryptic.api.Repositories;

import com.encryptic.api.Models.Club;

import org.springframework.data.jpa.repository.JpaRepository;

public interface ClubRepository extends JpaRepository<Club, Long> {
    // Custom queries if needed

}
