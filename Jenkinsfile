pipeline {
    agent any

    environment {
        CLONE_DIR = "/home/somaya/cloned_files" // Adjust to a suitable path on the remote host
        HOST_KEY_PATH = "/var/lib/jenkins/host_key.pem" // Adjust this if necessary
        REMOTE_HOST = 'somaya@102.37.146.184' // Define remote host here
        REPO_URL = 'https://github.com/Somaya-Ayman/tttest.git' // Define repo URL here
    }

    stages {
        stage('Clone Repository on Remote Host') {
            steps {
                script {
                    // Ensure the SSH key has the correct permissions
                    sh "chmod 600 ${HOST_KEY_PATH}"

                    // Clone the repository on the remote host
                    sh "ssh -i ${HOST_KEY_PATH} ${REMOTE_HOST} 'mkdir -p ${CLONE_DIR} && git clone ${REPO_URL} ${CLONE_DIR}'"
                }
            }
        }
        
        stage('Access and Modify Running Docker Container') {
            steps {
                script {
                    // Define container name
                    def containerName = 'user1container'

                    // Step 1: Check if the named container is running
                    def containerId = sh(script: "ssh -i ${HOST_KEY_PATH} ${REMOTE_HOST} 'docker ps -qf \"name=${containerName}\"'", returnStdout: true).trim()

                    if (containerId) {
                        echo "Container is running with ID: ${containerId}"

                        // Path inside the container where NGINX serves files
                        def nginxPath = "/usr/share/nginx/html"
                        
                        // Step 2: Remove current files inside NGINX's HTML directory
                        sh "ssh -i ${HOST_KEY_PATH} ${REMOTE_HOST} 'docker exec ${containerId} sh -c \"rm -rf ${nginxPath}/*\"'"

                        // Step 3: Copy new files from the cloned directory to the container using docker cp
                        sh "ssh -i ${HOST_KEY_PATH} ${REMOTE_HOST} 'docker cp ${CLONE_DIR}/. ${containerId}:${nginxPath}'"

                        // Step 4: Verify the new files are in place
                        sh "ssh -i ${HOST_KEY_PATH} ${REMOTE_HOST} 'docker exec ${containerId} sh -c \"ls -al ${nginxPath}\"'"
                    } else {
                        error "No container found with the name '${containerName}'"
                    }
                }
            }
        }
    }
}
