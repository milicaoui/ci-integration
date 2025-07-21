pipeline {
    agent any

    environment {
        CI_REPO = 'https://github.com/milicaoui/ci-integration.git'
        SPRING_REPO = 'https://github.com/milicaoui/springbootapp.git'
        TEST_REPO = 'https://github.com/milicaoui/pytestproject.git'
        ANALYTICS_REPO = 'git@bitbucket.org:upmonthteam/upmonth-analytics.git'
        ANALYTICS_VERSION = "666.0.0"  // or read dynamically from pom.xml if needed
        MYSQL_ROOT_PASSWORD = 'upmonth'  // Add any other env vars here if needed
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }



        stage('Clone Projects') {
            steps {
                script {
                    
                    echo "Cloning Upmonth analytics repo..."
                    dir('upmonth-analytics') {
                        git credentialsId: 'bitbucket-ssh-key-new', url: "${ANALYTICS_REPO}"
                    }

                    echo "Cloning CI Integration repo..."
                    sh "git clone $CI_REPO ci-integration"

                    echo "Cloning Spring Boot repo (PRIVATE)..."
                    dir('springbootapp') {
                        git credentialsId: 'fde95b67-c24d-4ad3-bd22-297701e72f6a', url: 'https://github.com/milicaoui/springbootapp.git'
                    }

                    echo "Cloning Pytest repo..."
                    sh "git clone $TEST_REPO pytestproject"
                }
            }
        }

        stage('Cleanup') {
            steps {
                dir('ci-integration') {
                    sh '''
                        echo "Cleaning up old docker containers and networks..."
                        docker compose down --remove-orphans || true
                        docker rm -f springbootapp || true
                        docker rm -f pytest-tests || true
                        docker rm -f testupmonthdb || true
                    '''
                }
            }
        }

        stage('Build Analytics Service') {
            steps {
                configFileProvider([configFile(fileId: 'upmonth-maven-settings', variable: 'MAVEN_SETTINGS')]) {
                    dir('upmonth-analytics') {
                        sh '''
                            source "$HOME/.sdkman/bin/sdkman-init.sh"
                            sdk use java 8.0.392-tem
                            echo "Using Java version:"
                            java -version

                            mvn clean package -s $MAVEN_SETTINGS -DskipTests
                        '''
                    }
                }
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
                        echo "UPM_ANALYTICS_VERSION=${ANALYTICS_VERSION}" > .env
                        docker compose build --no-cache
                        docker compose up --abort-on-container-exit --exit-code-from pytest-tests spring-app pytest-tests
                    '''
                }
            }
        }
    }

    post {
        always {
            dir('ci-integration') {
                sh '''
                    echo "Cleaning up docker containers after tests..."
                    docker compose down --remove-orphans || true
                    docker rm -f springbootapp || true
                    docker rm -f pytest-tests || true
                    docker rm -f testupmonthdb || true
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