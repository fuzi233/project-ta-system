package cn.ebu6304.tarecruitment.repository;

import cn.ebu6304.tarecruitment.model.UserProfile;
import cn.ebu6304.tarecruitment.storage.JsonlFileStore;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
}
