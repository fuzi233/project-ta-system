package cn.ebu6304.tarecruitment.model;

public record UserProfile(
        String userId,
        String displayName,
        String role,
        String identifier,
        String email,
        String passwordHash,
        String skills,
        String resumeText,
        String updatedAt
) {
}
