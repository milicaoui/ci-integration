pipeline {
    agent any

    environment {
        SPRING_REPO = 'https://github.com/milicaoui/springbootapp.git'
        TEST_REPO = 'https://github.com/milicaoui/pytestproject.git'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Clone Projects') {
            steps {
                sh '''
                    echo "Cloning Spring Boot repo..."
                    git clone $SPRING_REPO
                    echo "Cloning Pytest repo..."
                    git clone $TEST_REPO
                '''
            }
        }

        stage('Verify Structure') {
            steps {
                sh '''
                    echo "--- Spring Boot App ---"
                    ls -la springbootapp/
                    [ -f "springbootapp/pom.xml" ] || (echo "Missing pom.xml" && exit 1)

                    echo "--- Pytest Project ---"
                    ls -la pytestproject/
                    [ -f "pytestproject/requirements.txt" ] || (echo "Missing requirements.txt" && exit 1)
                '''
            }
        }

        stage('Build Spring Boot App') {
            steps {
                dir('springbootapp') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }

        stage('Run Integration Tests') {
            steps {
                sh '''
                    echo "Running integration tests with Docker Compose..."
                    pwd
                    ls -la
                    cat docker-compose.yml

                    docker compose down --remove-orphans || true
                    docker rm -f springbootapp || true
                    docker rm -f pytest-tests || true

                    docker compose build --no-cache
                    docker compose up --abort-on-container-exit --exit-code-from pytest-tests
                '''
            }
        }
    }

    post {
        always {
            sh '''
                echo "Cleaning up Docker containers..."
                docker compose down --remove-orphans || true
                docker rm -f springbootapp || true
                docker rm -f pytest-tests || true
            '''
        }
        success {
            echo "🎉 All tests passed successfully!"
        }
        failure {
            echo "❌ Tests failed. See logs above."
        }
    }
}
