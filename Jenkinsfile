pipeline {
    agent any

    environment {
        // Tests boot the full Spring context (@SpringBootTest), so they need a DB.
        // Inside the 'devops' Docker network, the MySQL container is reachable by name.
        SPRING_DATASOURCE_URL = 'jdbc:mysql://mysql-studentdb:3306/studentdb?createDatabaseIfNotExist=true'
        SPRING_DATASOURCE_USERNAME = 'root'
        SPRING_DATASOURCE_PASSWORD = ''
    }

    stages {
        stage('Checkout') {
            steps {
                // SCM checkout is automatic for a "Pipeline from SCM" job; this is just a marker.
                echo "Building ${env.JOB_NAME} #${env.BUILD_NUMBER}"
            }
        }

        stage('Build') {
            steps {
                sh 'chmod +x mvnw'
                sh './mvnw -B clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                sh './mvnw -B test'
            }
            post {
                always {
                    junit testResults: 'target/surefire-reports/*.xml', allowEmptyResults: true
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    sh '''./mvnw -B sonar:sonar \
                        -Dsonar.host.url=http://sonarqube:9000 \
                        -Dsonar.projectKey=student-management \
                        -Dsonar.token=$SONAR_TOKEN'''
                }
            }
        }
    }

    post {
        success { echo 'Pipeline succeeded ✅' }
        failure { echo 'Pipeline failed ❌' }
    }
}
