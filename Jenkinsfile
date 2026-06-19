pipeline {
    agent any

    environment {
        // Tests boot the full Spring context (@SpringBootTest), so they need a DB.
        // Inside the 'devops' Docker network, the MySQL container is reachable by name.
        SPRING_DATASOURCE_URL = 'jdbc:mysql://mysql-studentdb:3306/studentdb?createDatabaseIfNotExist=true'
        SPRING_DATASOURCE_USERNAME = 'root'
        SPRING_DATASOURCE_PASSWORD = ''
        // Docker Hub image — format nomprenom_classe_nomProjet, under your Docker Hub user.
        IMAGE = 'mouhamedboukari/boukari_acc1_student-management'
    }

    stages {
        stage('Checkout') {
            steps {
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

        stage('Docker Build') {
            steps {
                sh 'docker build -t $IMAGE:$BUILD_NUMBER -t $IMAGE:latest .'
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub',
                                 usernameVariable: 'DOCKER_USER',
                                 passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $IMAGE:$BUILD_NUMBER
                        docker push $IMAGE:latest
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    docker rm -f student-app || true
                    docker run -d --name student-app --network devops -p 8089:8089 \
                        -e SPRING_DATASOURCE_URL="jdbc:mysql://mysql-studentdb:3306/studentdb?createDatabaseIfNotExist=true" \
                        $IMAGE:latest
                '''
            }
        }
    }

    post {
        success { echo 'Pipeline succeeded ✅' }
        failure { echo 'Pipeline failed ❌' }
    }
}
