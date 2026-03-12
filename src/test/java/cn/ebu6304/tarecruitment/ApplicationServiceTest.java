package cn.ebu6304.tarecruitment;

import cn.ebu6304.tarecruitment.service.ApplicationService;
import cn.ebu6304.tarecruitment.storage.TextFileRepository;
import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertEquals;

class ApplicationServiceTest {

    @Test
    void submitApplicationShouldIncreaseCount() throws Exception {
        Path tmp = Files.createTempFile("applications", ".txt");
        ApplicationService service = new ApplicationService(new TextFileRepository(tmp.toString()));

        service.submitApplication("ta001", "job101");

        assertEquals(1, service.countApplications());
    }
}
