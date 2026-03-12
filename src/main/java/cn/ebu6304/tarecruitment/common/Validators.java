package cn.ebu6304.tarecruitment.common;

public final class Validators {
    private Validators() {
    }

    public static String requireNonBlank(String value, String fieldName) {
        if (value == null || value.isBlank()) {
            throw new ValidationException(fieldName + " must not be blank");
        }
        return value.trim();
    }

    public static int requirePositive(int value, String fieldName) {
        if (value <= 0) {
            throw new ValidationException(fieldName + " must be > 0");
        }
        return value;
    }

    public static int normalizePage(int value) {
        return value < 1 ? 1 : value;
    }

    public static int normalizeSize(int value) {
        if (value < 1) {
            return 10;
        }
        return Math.min(value, 100);
    }
}
