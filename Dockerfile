# Multi-stage build for the student-management Spring Boot app.
# Stage 1 compiles the jar with Maven; stage 2 ships only a slim JRE + the jar,
# so the final image stays small and is fully self-contained (builds anywhere).

# ---- Build stage ----
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn -B clean package -DskipTests

# ---- Runtime stage ----
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8089
ENTRYPOINT ["java", "-jar", "app.jar"]
