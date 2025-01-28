# Build stage
FROM maven:3.8.4-openjdk-17-slim AS build
WORKDIR /app
COPY pom.xml . 
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage
FROM openjdk:17-jdk-slim AS runtime
WORKDIR /app

# Copy the JMX Exporter JAR and configuration file into the container
COPY ./jmx_prometheus_javaagent-1.1.0.jar /app/jmx_prometheus_javaagent-1.1.0.jar
COPY ./jmx_exporter.yml /app/jmx_exporter.yml

COPY --from=build /app/target/*.jar /app/spring-petclinic.jar

EXPOSE 8080
EXPOSE 1234 

# Update the JMX exporter port in ENTRYPOINT
ENTRYPOINT ["java", "-javaagent:/app/jmx_prometheus_javaagent-1.1.0.jar=1234:/app/jmx_exporter.yml", "-jar", "/app/spring-petclinic.jar"]

