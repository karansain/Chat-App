package com.encryptic.api.Repositories;

import com.encryptic.api.Models.ClubMessage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ClubMessageRepository extends JpaRepository<ClubMessage, Long> {
    List<ClubMessage> findByClubIdOrderByTimestampAsc(Long clubId);
}