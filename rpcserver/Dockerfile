## Stage 1: Build
FROM maven:3.9-eclipse-temurin-8 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn package -DskipTests -B

## Stage 2: Runtime
FROM eclipse-temurin:8-jre-jammy
WORKDIR /app

# Install Datadog Java agent
ADD https://dtdg.co/latest-java-tracer dd-java-agent.jar

COPY --from=build /app/target/rpcserver-0.0.1-SNAPSHOT.jar app.jar

ENTRYPOINT ["java", "-javaagent:/app/dd-java-agent.jar", "-jar", "/app/app.jar"]
