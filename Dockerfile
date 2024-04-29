FROM openjdk:21
EXPOSE 8080
COPY target/springboot-project-latest-1.0-SNAPSHOT.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
