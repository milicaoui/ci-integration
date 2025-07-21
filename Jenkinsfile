pipeline {
    agent any

    environment {
        CI_REPO = 'https://github.com/milicaoui/ci-integration.git'
        TEST_REPO = 'https://github.com/milicaoui/pytestproject.git'
        ANALYTICS_REPO = 'git@bitbucket.org:upmonthteam/upmonth-analytics.git'
        DSL_REPO = 'git@bitbucket.org:upmonthteam/upmonth-query-dsl.git'
        MYSQL_ROOT_PASSWORD = 'upmonth'
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

                    echo "Cloning Pytest repo..."
                    sh "git clone $TEST_REPO pytestproject"

                    echo "Cloning Upmonth dsl repo..."
                    dir('upmonth-query-dsl') {
                        git branch: 'main', credentialsId: 'bitbucket-ssh-key-new', url: "${DSL_REPO}"
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                dir('ci-integration') {
                    sh '''
                        echo "Cleaning up old docker containers and networks..."
                        docker compose down --remove-orphans || true
                        docker rm -f pytest-tests || true
                        docker rm -f testupmonthdb || true
                    '''
                }
            }
        }

        /*
        stage('Build Analytics Service') {
            environment {
                SDKMAN_DIR = "/var/jenkins_home/.sdkman"
                PATH = "${SDKMAN_DIR}/candidates/java/current/bin:${env.PATH}"
            }
            steps {
                configFileProvider([configFile(fileId: 'upmonth-maven-settings', variable: 'MAVEN_SETTINGS')]) {
                    dir('upmonth-analytics/upmonth-analytics') {
                        sh '''#!/bin/bash
                            echo "Building analytics service with Maven..."
                            source "$SDKMAN_DIR/bin/sdkman-init.sh" || { echo "❌ Failed to source SDKMAN"; exit 1; }
                            sdk use java 8.0.392-tem || { echo "❌ Failed to switch Java version"; exit 1; }
                            mvn clean package -s "$MAVEN_SETTINGS" -DskipTests

                            echo "Listing target directory after build:"
                            ls -la target || echo "target directory missing"
                        '''
                    }
                }
            }
        }

        stage('Verify Structure') {
            steps {
                script {
                    sh """
                        echo "--- CI Integration ---"
                        ls -la ci-integration/
                        [ -f "ci-integration/docker-compose.yml" ] || (echo "Missing docker-compose.yml" && exit 1)

                        echo "--- Pytest Project ---"
                        ls -la pytestproject/
                        [ -f "pytestproject/requirements.txt" ] || (echo "Missing requirements.txt" && exit 1)
                    """
                }
            }
        }
        */

        stage('Run Integration Tests') {
            steps {
                dir('ci-integration') {
                    sh '''
                        echo "Running integration tests with docker-compose..."
                        echo "UPM_ANALYTICS_VERSION=${UPM_ANALYTICS_VERSION}" > .env
                        docker compose build --no-cache
                        docker compose up --abort-on-container-exit --exit-code-from pytest-tests pytest-tests
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