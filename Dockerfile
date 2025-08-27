FROM openjdk:17-jdk-slim
WORKDIR /opt/barq
COPY current ./barq-lite.jar
CMD ["sh", "-c", "java -jar barq-lite.jar >> /var/log/barq/barq.log 2>&1"]
