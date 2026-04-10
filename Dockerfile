FROM debian:bookworm AS builder

# Install Maven, git, and binutils for jlink
RUN apt-get update && \
    apt-get install -y \
        openjdk-17-jdk \
        maven \
        git \
        binutils && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone https://github.com/tabulapdf/tabula-java.git .

RUN mvn clean compile assembly:single
RUN cp target/*jar-with-dependencies.jar tabula.jar

COPY ./jlink.sh .
RUN ./jlink.sh tabula.jar


FROM gcr.io/distroless/java-base-debian12

COPY --from=builder /build/tabula.jar /opt/tabula/tabula.jar
COPY --from=builder /build/target/runtime /opt/java

ENTRYPOINT ["/opt/java/bin/java", "-jar", "/opt/tabula/tabula.jar"]
CMD ["--help"]
