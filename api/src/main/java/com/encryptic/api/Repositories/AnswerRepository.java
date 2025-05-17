package com.encryptic.api.Repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.encryptic.api.Models.Answers;

public interface AnswerRepository extends JpaRepository<Answers, Long> {
    List<Answers> findByQuestion_Id(Long questionId);
}
