# ---------- Stage 1: build the Spring Boot jar ----------
FROM eclipse-temurin:17-jdk AS build
WORKDIR /build

COPY gradlew ./
COPY gradle ./gradle
COPY build.gradle settings.gradle ./
COPY src ./src

RUN chmod +x gradlew && ./gradlew bootJar --no-daemon

# ---------- Stage 2: minimal runtime ----------
FROM eclipse-temurin:17-jre-jammy AS runtime
WORKDIR /app

RUN groupadd --system spring \
    && useradd --system --gid spring --home-dir /app spring

COPY --from=build --chown=spring:spring /build/build/libs/*.jar app.jar

USER spring:spring
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
