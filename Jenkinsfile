pipeline {
    agent any
   
    environment {
        AWS_REGION = 'ap-south-1'
        ECR_REPO = '745392035468.dkr.ecr.ap-south-1.amazonaws.com/awskeksdemo'
        DOCKER_IMAGE_NAME = 'awseksdemo'
        KUBECONFIG = "/var/lib/jenkins/.kube/config" //locate in jenkins EC2 serevr
    }
   
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image
                    docker.build("$DOCKER_IMAGE_NAME:${env.GIT_COMMIT}")
                }
            }
        }
       
        stage('Tag Docker Image') {
            steps {
                script {
                    // Tag Docker image using Docker command directly
                    sh "docker tag $DOCKER_IMAGE_NAME:${env.GIT_COMMIT} $ECR_REPO:${env.GIT_COMMIT}"
                }
            }
        }


        stage('Push to ECR') {
            steps {
                script {
                    // Authenticate Docker client to ECR using AWS CLI
                    withCredentials([aws(credentialsId: 'AWS-Credentials', region: AWS_REGION)]) {
                        sh "aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO"
                    }
                   
                    // Push Docker image to ECR
                    sh "docker push $ECR_REPO:${env.GIT_COMMIT}"
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    // Set KUBECONFIG environment variable
                    withEnv(["KUBECONFIG=${KUBECONFIG}"]) {
                        // Get the latest image tag from the GIT_COMMIT environment variable
                        def imageTag = env.GIT_COMMIT
                        
                        // Replace the placeholder ${IMAGE_TAG} in deployment.yaml with the actual image tag
                        sh "sed -i 's|\${IMAGE_TAG}|${imageTag}|' deployment.yaml"
                        
                        // Apply deployment.yaml to the EKS cluster
                        sh "kubectl apply -f deployment.yaml"
                        sh "kubectl apply -f service.yaml"
                    }
                }
            }
        }
    }
}