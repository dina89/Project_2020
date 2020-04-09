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
    dir("phonebook-app"){
        //sh 'docker build -f Dockerfile-app -t phonebook-app_phonebook-app:latest .'
        //sh 'docker build -f Dockerfile-mysql -t phonebook-app_phonebook-mysql:latest .'
        sh 'sudo /usr/local/bin/docker-compose up -d'
    }
}
stage("verify dockers") {
    //sh 'docker run --name phonebook-mysql -d phonebook-app_phonebook-mysql'
    //sh 'docker run --name phonebook-app -d -p 8181:8181 phonebook-app_phonebook-app'
    sh 'curl localhost:8181'
}
stage('Push to Docker Hub') { // Run the built image
    withDockerRegistry(credentialsId: 'dockerhub-dstefansky') {
        sh "docker push dstefansky/phonebook-app_phonebook-app"
        sh "docker push dstefansky/phonebook-app_phonebook-mysql"
    }
  }
// stage('Clean up'){
//         sh 'docker rm --force dstefansky/phonebook-app'
  //  sh 'docker rm --force dstefansky/phonebook-mysql'
// }
stage("deploy webapp") {
    sh "aws eks --region us-east-1 update-kubeconfig --name opsSchool-eks-dina"
    sh "kubectl apply -f deploy/loadbalancerservice.yml"
    sh "kubectl apply -f deploy/phonebookapp-deployment.yml"
    sh "kubectl apply -f deploy/phonebookmysql-deployment.yml"
}
}
