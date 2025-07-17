pipeline {
    agent any

    environment {
        CI_REPO = 'https://github.com/milicaoui/ci-integration.git'
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
                // Clone ci-integration first to get docker-compose.yml
                sh '''
                    echo "Cloning CI Integration repo..."
                    git clone $CI_REPO ci-integration
                    echo "Cloning Spring Boot repo..."
                    git clone $SPRING_REPO springbootapp
                    echo "Cloning Pytest repo..."
                    git clone $TEST_REPO pytestproject
                '''
            }
        }

        stage('Verify Structure') {
            steps {
                sh '''
                    echo "--- CI Integration ---"
                    ls -la ci-integration/
                    [ -f "ci-integration/docker-compose.yml" ] || (echo "Missing docker-compose.yml" && exit 1)

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
                dir('ci-integration') {
                    sh '''
                        echo "Running integration tests with docker-compose..."
                        pwd
                        ls -la

                        docker compose down --remove-orphans || true
                        docker rm -f springbootapp || true
                        docker rm -f pytest-tests || true

                        docker compose build --no-cache
                        docker compose up --abort-on-container-exit --exit-code-from pytest-tests
                    '''
                }
            }
        }
    }

    post {
        always {
            dir('ci-integration') {
                sh '''
                    echo "Cleaning up docker containers..."
                    docker compose down --remove-orphans || true
                    docker rm -f springbootapp || true
                    docker rm -f pytest-tests || true
                '''
            }
        }
        success {
            echo "🎉 All tests passed successfully!"
        }
        failure {
            echo "❌ Tests failed. See logs above."
        }
    }
}
