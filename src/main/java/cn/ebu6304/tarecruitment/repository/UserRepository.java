package cn.ebu6304.tarecruitment.repository;

import cn.ebu6304.tarecruitment.model.UserProfile;
import cn.ebu6304.tarecruitment.storage.JsonlFileStore;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Locale;
import java.util.concurrent.ConcurrentHashMap;

public class UserRepository {
    private final JsonlFileStore<UserProfile> fileStore;
    private final Map<String, UserProfile> byUserId = new ConcurrentHashMap<>();
    private final Map<String, String> byEmail = new ConcurrentHashMap<>();
    private final Map<String, String> byRoleIdentifier = new ConcurrentHashMap<>();
    private final Map<String, String> byRoleLoginKey = new ConcurrentHashMap<>();

    public UserRepository(JsonlFileStore<UserProfile> fileStore) {
        this.fileStore = fileStore;
        rebuildIndexes();
    }

    public synchronized void upsert(UserProfile profile) {
        Map<String, UserProfile> allById = new ConcurrentHashMap<>(byUserId);
        allById.put(profile.userId(), profile);
        List<UserProfile> compacted = new ArrayList<>(allById.values());
        compacted.sort(Comparator.comparing(UserProfile::userId));
        fileStore.replaceAll(compacted);
        rebuildIndexesFrom(compacted);
    }

    public synchronized List<UserProfile> listAll() {
        List<UserProfile> result = new ArrayList<>(byUserId.values());
        result.sort(Comparator.comparing(UserProfile::userId));
        return result;
    }

    public synchronized Optional<UserProfile> findById(String userId) {
        if (userId == null || userId.isBlank()) {
            return Optional.empty();
        }
        return Optional.ofNullable(byUserId.get(userId.trim()));
    }

    public synchronized List<UserProfile> listByRole(String role) {
        List<UserProfile> result = new ArrayList<>();
        if (role == null || role.isBlank()) {
            return result;
        }
        String normalizedRole = role.trim().toUpperCase();
        byUserId.values().forEach(profile -> {
            if (profile.role() != null && profile.role().trim().toUpperCase().equals(normalizedRole)) {
                result.add(profile);
            }
        });
        result.sort(Comparator.comparing(UserProfile::userId));
        return result;
    }

    public synchronized Optional<UserProfile> findByRoleAndIdentifier(String role, String identifier) {
        if (role == null || role.isBlank() || identifier == null || identifier.isBlank()) {
            return Optional.empty();
        }
        String userId = byRoleIdentifier.get(key(role, identifier));
        return userId == null ? Optional.empty() : Optional.ofNullable(byUserId.get(userId));
    }

    public synchronized Optional<UserProfile> findByRoleAndLoginKey(String role, String loginKey) {
        if (role == null || role.isBlank() || loginKey == null || loginKey.isBlank()) {
            return Optional.empty();
        }
        String userId = byRoleLoginKey.get(key(role, loginKey));
        return userId == null ? Optional.empty() : Optional.ofNullable(byUserId.get(userId));
    }

    public synchronized boolean existsByRoleAndIdentifier(String role, String identifier) {
        return findByRoleAndIdentifier(role, identifier).isPresent();
    }

    public synchronized boolean existsByEmail(String email) {
        if (email == null || email.isBlank()) {
            return false;
        }
        return byEmail.containsKey(email.trim().toLowerCase(Locale.ROOT));
    }

    private void rebuildIndexes() {
        List<UserProfile> all = new ArrayList<>();
        fileStore.forEach(all::add);
        rebuildIndexesFrom(all);
    }

    private void rebuildIndexesFrom(List<UserProfile> profiles) {
        byUserId.clear();
        byEmail.clear();
        byRoleIdentifier.clear();
        byRoleLoginKey.clear();

        for (UserProfile profile : profiles) {
            if (profile == null || profile.userId() == null || profile.userId().isBlank()) {
                continue;
            }
            String userId = profile.userId().trim();
            byUserId.put(userId, profile);

            if (profile.email() != null && !profile.email().isBlank()) {
                byEmail.put(profile.email().trim().toLowerCase(Locale.ROOT), userId);
            }

            if (profile.role() != null && !profile.role().isBlank()) {
                if (profile.identifier() != null && !profile.identifier().isBlank()) {
                    byRoleIdentifier.put(key(profile.role(), profile.identifier()), userId);
                    byRoleLoginKey.put(key(profile.role(), profile.identifier()), userId);
                }
                if (profile.email() != null && !profile.email().isBlank()) {
                    byRoleLoginKey.put(key(profile.role(), profile.email()), userId);
                }
            }
        }
    }

    private String key(String role, String value) {
        return role.trim().toUpperCase(Locale.ROOT) + "|" + value.trim().toLowerCase(Locale.ROOT);
    }
}
