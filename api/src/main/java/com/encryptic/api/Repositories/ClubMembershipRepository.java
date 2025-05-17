package com.encryptic.api.Repositories;

import com.encryptic.api.Models.ClubMembership;
import com.encryptic.api.Models.Club;
import com.encryptic.api.Models.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ClubMembershipRepository extends JpaRepository<ClubMembership, Long> {
    Optional<ClubMembership> findByUserAndClub(User user, Club club);
}
