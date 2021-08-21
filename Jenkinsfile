pipeline {
    agent any
	
	  tools
    {
       maven "Maven.3.6.3"
    }
 stages {
      stage('checkout') {
           steps {
             
                git branch: 'master', url: 'https://github.com/Mounika113/jenkins.git'
             
          }
        }
	 stage('Execute Maven') {
           steps {
             
                sh 'mvn package'             
          }
        }
        

  stage('Docker Build and Tag') {
           steps {
                
                sh 'docker build -t samplewebapp:latest .' 
                sh 'docker tag samplewebapp sairagamounika/jenkins:latest'
                //sh 'docker tag samplewebapp nikhilnidhi/samplewebapp:$BUILD_NUMBER'
               
          }
        }
     
  		
	stage('Run Docker')	 {
	
			steps {	
			
			sh "docker run --name javaapp -d -p 8080:8080 sairagamounika/jenkins"
			sh 'sleep 10'
			
			}
	}
	
	stage('Test')	 {
	
			steps {	
			sh 'curl localhost:8080/health'
			sh 'sleep 20'
			
			}
	}
	
	stage('Publish image to Docker Hub') {
          
            steps {
        withCredentials([string credentialsId: 'DOCKER_USER', variable: 'DOCKER_USER'), string credentialsId: 'PASSWD', variable: 'DOCKER_PASSWORD') ]) {
          sh  'docker login -u $DOCKER_USER -p $DOCKER_PASSWORD'
          sh  'docker push sairagamounika/jenkins:latest'
		  #docker push user-id/repo-name in docker-hub
		  #make sure there's a repo in your dockerhub account and use those creds above
        }
                  
          }
        }
	
	stage('Delete Infra')	 {
	
			steps {	
			
			sh 'docker stop javaapp'
			sh 'docker rm javaapp'
			
			}
		}
	
	}
}
