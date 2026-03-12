package cn.ebu6304.tarecruitment;

import cn.ebu6304.tarecruitment.service.ApplicationService;
import cn.ebu6304.tarecruitment.storage.TextFileRepository;

public class Main {
    public static void main(String[] args) {
        ApplicationService service = new ApplicationService(new TextFileRepository("data/applications.txt"));
        System.out.println("TA Recruitment System started.");
        System.out.println("Current application count: " + service.countApplications());
    }
}
