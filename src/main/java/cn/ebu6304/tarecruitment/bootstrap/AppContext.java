package cn.ebu6304.tarecruitment.bootstrap;

import cn.ebu6304.tarecruitment.ai.AiProviderFactory;
import cn.ebu6304.tarecruitment.model.AttachmentRecord;
import cn.ebu6304.tarecruitment.model.ApplicationRecord;
import cn.ebu6304.tarecruitment.model.JobPosting;
import cn.ebu6304.tarecruitment.model.UserProfile;
import cn.ebu6304.tarecruitment.repository.AttachmentRepository;
import cn.ebu6304.tarecruitment.repository.ApplicationRepository;
import cn.ebu6304.tarecruitment.repository.JobRepository;
import cn.ebu6304.tarecruitment.repository.UserRepository;
import cn.ebu6304.tarecruitment.service.AiService;
import cn.ebu6304.tarecruitment.service.AttachmentService;
import cn.ebu6304.tarecruitment.service.ApplicationService;
import cn.ebu6304.tarecruitment.service.JobService;
import cn.ebu6304.tarecruitment.service.WorkloadService;
import cn.ebu6304.tarecruitment.storage.JsonlFileStore;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.nio.file.Path;

public class AppContext {
    private static final AppContext INSTANCE = new AppContext();

    private final ObjectMapper objectMapper;
    private final JobRepository jobRepository;
    private final ApplicationRepository applicationRepository;
    private final JobService jobService;
    private final ApplicationService applicationService;
    private final WorkloadService workloadService;
    private final AiService aiService;
    private final UserRepository userRepository;
    private final AttachmentRepository attachmentRepository;
    private final AttachmentService attachmentService;

    private AppContext() {
        this.objectMapper = new ObjectMapper();

        String dataDir = System.getProperty("ta.data.dir", "data");
        Path base = Path.of(dataDir);

        JsonlFileStore<JobPosting> jobStore = new JsonlFileStore<>(base.resolve("jobs.jsonl"), JobPosting.class, objectMapper);
        JsonlFileStore<ApplicationRecord> applicationStore = new JsonlFileStore<>(base.resolve("applications.jsonl"), ApplicationRecord.class, objectMapper);
        JsonlFileStore<UserProfile> userStore = new JsonlFileStore<>(base.resolve("users.jsonl"), UserProfile.class, objectMapper);
        JsonlFileStore<AttachmentRecord> attachmentStore = new JsonlFileStore<>(base.resolve("attachments.jsonl"), AttachmentRecord.class, objectMapper);

        this.jobRepository = new JobRepository(jobStore);
        this.applicationRepository = new ApplicationRepository(applicationStore);
        this.userRepository = new UserRepository(userStore);
        this.attachmentRepository = new AttachmentRepository(attachmentStore);
        this.attachmentService = new AttachmentService(attachmentRepository, base.resolve("uploads"));

        this.jobService = new JobService(jobRepository);
        this.applicationService = new ApplicationService(applicationRepository, jobRepository);
        this.workloadService = new WorkloadService(applicationRepository);
        this.aiService = new AiService(
                jobRepository,
                userRepository,
                applicationRepository,
                attachmentService,
                AiProviderFactory.fromRuntimeConfig(objectMapper)
        );
    }

    public static AppContext getInstance() {
        return INSTANCE;
    }

    public ObjectMapper objectMapper() {
        return objectMapper;
    }

    public JobService jobService() {
        return jobService;
    }

    public ApplicationService applicationService() {
        return applicationService;
    }

    public WorkloadService workloadService() {
        return workloadService;
    }

    public AiService aiService() {
        return aiService;
    }

    public UserRepository userRepository() {
        return userRepository;
    }

    public AttachmentService attachmentService() {
        return attachmentService;
    }
}
