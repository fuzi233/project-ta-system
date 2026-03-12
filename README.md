# TA Recruitment System (Java Prototype)

This branch contains the baseline implementation for the EBU6304 group project.

## Tech stack
- Java 17
- Maven
- JUnit 5
- Text file persistence (`data/applications.txt`)

## Run
```bash
mvn test
mvn exec:java -Dexec.mainClass="cn.ebu6304.tarecruitment.Main"
```

## Project structure
- `src/main/java`: application code
- `src/test/java`: unit tests
- `data/`: text-based persistence files
- `requirements.md`: initial requirements draft
