package cn.ebu6304.tarecruitment.model;

public record UserProfile(
        String userId,
        String displayName,
        String role,
        String skills,
        String updatedAt
) {
}
