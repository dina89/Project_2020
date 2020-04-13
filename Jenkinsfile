node("linux") {
environment{
    credentialsId = "Github-Dina89"
    registry = "dstefansky/phonebook-app_phonebook-app"
    registryCredential = "dockerhub-dstefansky"
}
def DockerImage = "phonebook-app:v1.0"
def customImage = null
stage('Git') { // Get code from GitLab repository
    git branch: 'mysqlapp',
      url: 'https://github.com/dina89/Project_2020.git'
}

stage("build docker") {
    sh 'docker build "whale-app" -t dstefansky/whale-app:latest'
    //dir("phonebook-app"){
        //sh 'sudo /usr/local/bin/docker-compose up -d'
    //}
}
stage("verify dockers") {// Run the built image
    sh 'sudo docker run -d -p 5000:5000 whale-app'
    sleep 30 // seconds
    sh 'curl localhost:5000'
}
stage('Push to Docker Hub') { 
    withDockerRegistry(credentialsId: 'dockerhub-dstefansky') {
        // sh "docker tag phonebook-app_phonebook-app dstefansky/phonebook-app:latest"
        // sh "docker tag phonebook-app_phonebook-mysql dstefansky/phonebook-mysql:latest"
        // sh "docker push dstefansky/phonebook-app:latest"
        // sh "docker push dstefansky/phonebook-mysql:latest"
        sh "docker push dstefansky/whale-app:latest"
    }
  }
stage('Clean up'){
     sh 'docker rm --force dstefansky/whale-app:latest'
//   dir("phonebook-app"){
//     sh 'sudo /usr/local/bin/docker-compose down --rmi all'
//   }
 }
stage("deploy webapp") {
    sh "aws eks --region us-east-1 update-kubeconfig --name opsSchool-eks-dina"
    sh "kubectl apply -f deploy/loadbalancerservice.yml"
    // sh "kubectl apply -f deploy/phonebookapp-deployment.yml"
    // sh "kubectl apply -f deploy/phonebookmysql-deployment.yml"
    sh "kubectl apply -f deploy/loadbalancerservice.yml"
    sh "kubectl apply -f deploy/webapp-deployment.yml"
}
}
