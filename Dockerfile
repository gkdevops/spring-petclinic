FROM eclipse-temurin:17.0.13_11-jre-alpine

LABEL application-name="PetClinic"
LABEL dev-team="dev-team@gmail.com"

EXPOSE 8080

WORKDIR /opt

COPY target/*.jar petclinic.jar

ENTRYPOINT ["java", "-jar", "-Dserver.port=8080", "petclinic.jar"]
