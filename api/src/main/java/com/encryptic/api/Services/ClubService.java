package com.encryptic.api.Services;

import com.encryptic.api.DTOs.ClubDTO;
import com.encryptic.api.DTOs.ClubMembershipDTO;
import com.encryptic.api.Models.*;
import com.encryptic.api.Repositories.ClubRepository;
import com.encryptic.api.Repositories.UserRepository;
import com.encryptic.api.Repositories.ClubMembershipRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import jakarta.transaction.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class ClubService {

    @Autowired
    private ClubRepository clubRepository;

    @Autowired
    private ClubMembershipRepository membershipRepository;

    @Autowired
    private UserRepository userRepository;


    // Adding user to club (existing functionality)
    public void addUserToClub(User user, Club club, ClubRole role) {
        if (club.isFull()) {
            throw new IllegalStateException("Club is full");
        }

        ClubMembership membership = new ClubMembership();
        membership.setClub(club);
        membership.setUser(user);
        membership.setRole(role);
        club.getMembers().add(membership);

        membershipRepository.save(membership);
        clubRepository.save(club);
    }

    // Removing user from club (existing functionality)
    public void removeUserFromClub(User user, Club club) {
        Optional<ClubMembership> membershipOpt = membershipRepository.findByUserAndClub(user, club);
        if (membershipOpt.isPresent()) {
            ClubMembership membership = membershipOpt.get();
            membershipRepository.delete(membership);
            club.getMembers().remove(membership);
            clubRepository.save(club);
        } else {
            throw new IllegalStateException("User is not a member of this club.");
        }
    }

    // Checking if a user is an admin of a club (existing functionality)
    public boolean isUserAdmin(User user, Club club) {
        return club.isAdmin(user);
    }

    // Get all clubs (existing functionality)
    public List<ClubDTO> getAllClubs() {
        List<Club> clubs = clubRepository.findAll();
        return clubs.stream()
                .map(ClubDTO::new)  // Map each Club entity to a ClubDTO
                .collect(Collectors.toList());
    }

    // Find user by ID (existing functionality)
    public User findUserById(Long userId) {
        return userRepository.findById(userId).get();
    }

    // Find club by ID (existing functionality)
    @Transactional
    public Club findClubById(Long clubId) {
        return clubRepository.findById(clubId)
                .orElseThrow(() -> new IllegalArgumentException("Club not found with ID: " + clubId));
    }

    // Get all members of a club (existing functionality)
    public List<User> getMembersOfClub(Club club) {
        return club.getMembers().stream()
                .map(ClubMembership::getUser)
                .collect(Collectors.toList());
    }

    public List<ClubMembershipDTO> getMembersOfClubDTO(Club club) {
        return club.getMembers().stream()
                .map(member -> new ClubMembershipDTO(
                    member.getId(),
                    club.getId(),
                    club.getName(),
                    member.getUser().getId(),
                    member.getUser().getUsername(),
                    member.getUser().getPhotoUrl(),
                    member.getRole()
                ))
                .collect(Collectors.toList());
    }
    
}
