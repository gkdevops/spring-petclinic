FROM eclipse-temurin:17.0.13_11-jre-alpine

LABEL application-name="PetClinic"
LABEL dev-team="dev-team@gmail.com"

WORKDIR /opt

COPY target/*.jar petclinic.jar

ENTRYPOINT ["java", "jar", "petclinic.jar"]
