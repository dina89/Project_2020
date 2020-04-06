node("linux") {
environment{
    credentialsId = "Github-Dina89"
    registry = "dstefansky/whale-app"
    registryCredential = "dockerhub-dstefansky"
}
def DockerImage = "whale-app:v1.0"
 def customImage = null
stage('Git') { // Get code from GitLab repository
    git branch: 'mysqlapp',
      url: 'https://github.com/dina89/Project_2020.git'
}

stage("build docker") {
    sh 'ls'
    dir(phonebook-app) {
        sh 'ls'
        sh 'sudo /usr/local/bin/docker-compose up -d'
    }
}
stage("verify dockers") {
sh "docker images"
}
stage('Push to Docker Hub') { // Run the built image
    withDockerRegistry(credentialsId: 'dockerhub-dstefansky') {
        sh "docker push dstefansky/phonebook-app:latest"
        sh "docker push dstefansky/phonebook-mysql:latest"
    }
  }
stage("deploy webapp") {
    sh "aws eks --region us-east-1 update-kubeconfig --name opsSchool-eks-dina"
    sh "kubectl apply -f deploy/loadbalancerservice.yml"
    sh "kubectl apply -f deploy/phonebookapp-deployment.yml"
    sh "kubectl apply -f deploy/phonebookmysql-deployment.yml"
}
}
