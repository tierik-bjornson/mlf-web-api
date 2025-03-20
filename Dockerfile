# Sử dụng hình ảnh Maven chính thức để xây dựng ứng dụng
FROM maven:3.8.5-openjdk-17 AS build

# Đặt thư mục làm việc trong container
WORKDIR /app

# Sao chép file pom.xml và các file nguồn vào container
COPY pom.xml .
COPY src ./src

# Biên dịch và đóng gói ứng dụng
RUN mvn clean package -DskipTests

# Sử dụng hình ảnh OpenJDK nhẹ để chạy ứng dụng
FROM openjdk:17-jdk-slim

# Đặt thư mục làm việc trong container
WORKDIR /app

# Sao chép file JAR từ giai đoạn build
COPY --from=build /app/target/mlf-web-api.jar .

# Mở cổng mà ứng dụng sẽ chạy
EXPOSE 8080

# Lệnh để chạy ứng dụng
CMD ["java", "-jar", "mlf-web-api.jar"]
