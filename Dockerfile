FROM eclipse-temurin:17-jdk
ARG JAR_FILE=build/libs/jpashop-0.0.1-SNAPSHOT-plain.jar
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]