package com.encryptic.api.Services;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.encryptic.api.DTOs.QuestionDTO;
import com.encryptic.api.Models.Club;
import com.encryptic.api.Models.Questions;
import com.encryptic.api.Models.User;
import com.encryptic.api.Repositories.QuestionRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class QuestionService {

    @Autowired
    private QuestionRepository questionRepository;

    public Questions createQuestion(Long clubId, String content, User author, Club club, List<String> tags) {
        Questions question = new Questions();
        question.setContent(content);
        question.setAuthor(author);
        question.setClub(club);
        question.setTags(tags);
        return questionRepository.save(question);
    }

    public List<Questions> getQuestionsByClub(Long clubId) {
        return questionRepository.findByClub_Id(clubId);
    }

    public List<QuestionDTO> getQuestionsByClubDTO(Long clubId) {
        // Fetching the list of Questions from the repository
        List<Questions> questions = questionRepository.findByClub_Id(clubId);

        // Convert each Question entity to a QuestionDTO
        return questions.stream()
            .map(question -> new QuestionDTO(
                question.getId(),
                question.getContent(),
                question.getCreatedAt(),
                question.getUpdatedAt(),
                question.getTags(),
                question.getClub() != null ? question.getClub().getId() : null, // Club ID
                question.getAuthor() != null ? question.getAuthor().getId() : null, // Author ID
                question.getAuthor() != null ? question.getAuthor().getUsername() : null, // Author Name
                question.getAuthor() != null ? question.getAuthor().getPhotoUrl() : null // Author Image URL
            ))
            .collect(Collectors.toList());
    }

    public Optional<Questions> updateQuestion(Long questionId, String content) {
        return questionRepository.findById(questionId).map(question -> {
            question.setContent(content);
            return questionRepository.save(question);
        });
    }

    public void deleteQuestion(Long questionId) {
        questionRepository.deleteById(questionId);
    }
}
