package com.encryptic.api.Repositories;

import java.util.List;


import org.springframework.data.jpa.repository.JpaRepository;

import com.encryptic.api.Models.Questions;

public interface QuestionRepository extends JpaRepository<Questions, Long> {
    List<Questions> findByClub_Id(Long clubId);
    List<Questions> findByContentContainingIgnoreCase(String keyword);
}
