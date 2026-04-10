package cn.ebu6304.tarecruitment.repository;

import cn.ebu6304.tarecruitment.model.UserProfile;
import cn.ebu6304.tarecruitment.storage.JsonlFileStore;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public class UserRepository {
    private final JsonlFileStore<UserProfile> fileStore;

    public UserRepository(JsonlFileStore<UserProfile> fileStore) {
        this.fileStore = fileStore;
    }

    public synchronized void upsert(UserProfile profile) {
        Map<String, UserProfile> allById = new HashMap<>();
        fileStore.forEach(item -> allById.put(item.userId(), item));
        allById.put(profile.userId(), profile);
        fileStore.replaceAll(new ArrayList<>(allById.values()));
    }

    public synchronized List<UserProfile> listAll() {
        List<UserProfile> result = new ArrayList<>();
        fileStore.forEach(result::add);
        return result;
    }

    public synchronized Optional<UserProfile> findById(String userId) {
        final UserProfile[] found = {null};
        fileStore.forEach(profile -> {
            if (found[0] == null && profile.userId().equals(userId)) {
                found[0] = profile;
            }
        });
        return Optional.ofNullable(found[0]);
    }

    public synchronized List<UserProfile> listByRole(String role) {
        List<UserProfile> result = new ArrayList<>();
        if (role == null || role.isBlank()) {
            return result;
        }
        String normalizedRole = role.trim().toUpperCase();
        fileStore.forEach(profile -> {
            if (profile.role() != null && profile.role().trim().toUpperCase().equals(normalizedRole)) {
                result.add(profile);
            }
        });
        return result;
    }
}
