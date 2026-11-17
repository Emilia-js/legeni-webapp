pipeline {
    agent any
    parameters {
        string(name: 'DOCKERHUB_ID', defaultValue: 'ottou', description: 'Ton Docker Hub ID')
        booleanParam(name: 'PUSH', defaultValue: true, description: "Pousser l'image")
    }
    environment {
        IMAGE          = "${params.DOCKERHUB_ID}/legeni-webapp"
        VERSION        = "1.0.${env.BUILD_NUMBER}"
        TEST_CONTAINER = "webapp-ci-${env.BUILD_NUMBER}"
        CI_NETWORK     = "ci-net-${env.BUILD_NUMBER}"
    }
    stages {
        stage('Build image') {
            steps { sh 'docker build -t $IMAGE:$VERSION -t $IMAGE:latest .' }
        }
        stage("Test d'acceptance") {
            steps {
                sh '''
                    docker network create $CI_NETWORK
                    docker run -d --name $TEST_CONTAINER --network $CI_NETWORK -e APP_VERSION=$VERSION $IMAGE:$VERSION
                    docker run --rm --network $CI_NETWORK curlimages/curl:8.11.1 -sf --retry 10 --retry-connrefused http://$TEST_CONTAINER:5000/health
                    docker run --rm --network $CI_NETWORK curlimages/curl:8.11.1 -sf http://$TEST_CONTAINER:5000/ | grep -q "Version $VERSION"
                '''
            }
        }
        stage('Push Docker Hub') {
            when { expression { params.PUSH } }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DH_USER', passwordVariable: 'DH_TOKEN')]) {
                    sh '''
                        echo "$DH_TOKEN" | docker login -u "$DH_USER" --password-stdin
                        docker push $IMAGE:$VERSION
                        docker push $IMAGE:latest
                    '''
                }
            }
        }
    }
    post {
        always { sh 'docker rm -f $TEST_CONTAINER || true; docker network rm $CI_NETWORK || true' }
    }
}
