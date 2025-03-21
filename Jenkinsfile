pipeline {
    agent {
        kubernetes {
            yaml """
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              - name: maven
                image: maven:3.8.6-eclipse-temurin-17
                command:
                - cat
                tty: true
              - name: docker
                image: docker:20.10.24
                command:
                - cat
                tty: true
                securityContext:
                  privileged: true
                volumeMounts:
                - name: docker-socket
                  mountPath: /var/run/docker.sock
              volumes:
              - name: docker-socket
                hostPath:
                  path: /var/run/docker.sock
            """
        }
    }

    environment {
        HARBOR_REGISTRY = "10.8.0.2:80"  // Dùng IP của máy host (hoặc đổi thành localhost nếu sửa docker-compose)
        HARBOR_PROJECT = "mlf-web"
        IMAGE_NAME = "mlf-api"
        IMAGE_TAG = "latest"
        JAR_FILE = "league-api-0.0.1-SNAPSHOT.jar"  // Đảm bảo đúng tên file JAR
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                container('maven') {
                    sh 'mvn clean package -DskipTests'
                    sh 'ls -l target/'  // Kiểm tra xem file JAR có tạo không
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                container('maven') {
                    sh 'mvn test'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                container('docker') {
                    sh """
                    docker build --build-arg JAR_FILE=$JAR_FILE -t $HARBOR_REGISTRY/$HARBOR_PROJECT/$IMAGE_NAME:$IMAGE_TAG .
                    """
                }
            }
        }

        stage('Push to Harbor') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: 'harbor-cre', usernameVariable: 'HARBOR_USER', passwordVariable: 'HARBOR_PASSWORD')]) {
                        sh """
                        echo "\$HARBOR_PASSWORD" | docker login $HARBOR_REGISTRY -u "\$HARBOR_USER" --password-stdin
                        docker push $HARBOR_REGISTRY/$HARBOR_PROJECT/$IMAGE_NAME:$IMAGE_TAG
                        docker logout $HARBOR_REGISTRY
                        """
                    }
                }
            }
        }
    }
}
