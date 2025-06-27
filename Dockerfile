# Use OpenJDK 11 as base image (tabula-java requires Java 8+)
FROM openjdk:11-jdk-slim AS builder

# Install Maven and git
RUN apt-get update && \
    apt-get install -y maven git && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone the repository
RUN git clone https://github.com/tabulapdf/tabula-java.git .

# Build the application
RUN mvn clean compile assembly:single

RUN cp target/*jar-with-dependencies.jar /app/tabula.jar

COPY ./jlink.sh .
RUN ./jlink.sh tabula.jar


FROM debian:bookworm-slim
WORKDIR /app

# Create a non-root user
RUN useradd -m tabula && \
    chown -R tabula:tabula /app

COPY --from=builder /app/tabula.jar .
COPY --from=builder /app/target/runtime /java

USER tabula

# Set the entrypoint to run tabula-java CLI
ENTRYPOINT ["/java/bin/java", "-jar", "/app/tabula.jar"]

# # Default command shows help
CMD ["--help"]

