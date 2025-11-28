FROM maven:3.6.3-openjdk-11 AS builder

WORKDIR /app

COPY users-api/pom.xml .
RUN mvn dependency:go-offline

COPY users-api/src ./src
RUN mvn package -DskipTests

FROM eclipse-temurin:11-jre-alpine

WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080

CMD ["java", "-jar", "app.jar"]