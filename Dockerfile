FROM eclipse-temurin:11-jre

WORKDIR /app

COPY target/spring-boot-full-stack-professional-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
