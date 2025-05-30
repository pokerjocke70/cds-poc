FROM bellsoft/liberica-openjre-alpine:21.0.7-cds AS builder
WORKDIR /builder
# This points to the built jar file in the target folder
# Adjust this to 'build/libs/*.jar' if you're using Gradle
ARG JAR_FILE=target/*.jar
# Copy the jar file to the working directory and rename it to application.jar
COPY ${JAR_FILE} application.jar
# Extract the jar file using an efficient layout
RUN java -Djarmode=tools -jar application.jar extract --layers --destination extracted

# This is the runtime container
FROM bellsoft/liberica-openjre-alpine:21.0.7-cds
WORKDIR /application

EXPOSE 9090

# Copy the extracted jar contents from the builder container into the working directory in the runtime container
# Every copy step creates a new docker layer
# This allows docker to only pull the changes it really needs
COPY --from=builder /builder/extracted/dependencies/ ./
COPY --from=builder /builder/extracted/spring-boot-loader/ ./
COPY --from=builder /builder/extracted/snapshot-dependencies/ ./
COPY --from=builder /builder/extracted/application/ ./

# Do a practice run and dump the classes to application.jsa
RUN java -Dspring.context.exit=onRefresh -XX:ArchiveClassesAtExit=application.jsa -jar application.jar

# Remove unneeded stuff
RUN rm /usr/lib/jvm/jre/bin/jrunscript \
    && rm /usr/lib/jvm/jre/bin/rmiregistry \
    && rm /usr/lib/jvm/jre/bin/keytool \
    && rm /usr/lib/jvm/jre/bin/jwebserver

# Start the application jar - this is not the uber jar used by the builder
# This jar only contains application code and references to the extracted jar files
# This layout is efficient to start up and CDS/AOT cache friendly
ENTRYPOINT ["java", "-XX:SharedArchiveFile=application.jsa", "-Djava.security.egd=file:/dev/urandom", "-XX:+TieredCompilation", "-XX:TieredStopAtLevel=1", "-Dspring.aot.enabled=true", "-jar",  "application.jar"]
