package cn.ebu6304.tarecruitment.common;

public class ApiException extends RuntimeException {
    private final int httpStatus;

    public ApiException(int httpStatus, String message) {
        super(message);
        this.httpStatus = httpStatus;
    }

    public int getHttpStatus() {
        return httpStatus;
    }
}
