# Sử dụng Maven để build
FROM maven:3.8.5-openjdk-17 AS build

# Đặt thư mục làm việc trong container
WORKDIR /app

# Sao chép file pom.xml và các file nguồn vào container
COPY pom.xml .
COPY src ./src

# Biên dịch và đóng gói ứng dụng
RUN mvn clean package -DskipTests

# Kiểm tra file JAR được tạo ra
RUN ls -l target/

# Sử dụng OpenJDK nhẹ để chạy ứng dụng
FROM openjdk:17-jdk-slim

# Đặt thư mục làm việc
WORKDIR /app

# Thêm ARG để đặt tên file JAR động
ARG JAR_FILE=league-api-0.0.1-SNAPSHOT.jar

# Sao chép file JAR từ giai đoạn build
COPY --from=build /app/target/${JAR_FILE} app.jar

# Mở cổng ứng dụng
EXPOSE 8080

# Chạy ứng dụng
CMD ["java", "-jar", "app.jar"]
