node("linux") {
environment{
    credentialsId = "Github-Dina89"
    registry = "dstefansky/whale-app"
    registryCredential = "dockerhub-dstefansky"
}
def DockerImage = "whale-app:v1.0"
 def customImage = null
stage('Git') { // Get code from GitLab repository
    git branch: 'master',
      url: 'https://github.com/dina89/Project_2020.git'
}

stage("build docker") {
customImage = docker.build "whale-app"
}
stage("verify dockers") {
sh "docker images"
}
stage('Push to Docker Hub') { // Run the built image
    withDockerRegistry(credentialsId: 'dockerhub-dstefansky') {
        customImage.push()
    }
  }
stage("deploy webapp") {
    sh "aws eks --region us-east-1 update-kubeconfig --name opsSchool-eks-dina"
    sh "kubectl apply -f k8s/service.yml"
    sh "kubectl apply -f k8s/webapp-deployment.yml"
}
}
