pipeline {
    agent any

    environment {
        CLONE_DIR = "${WORKSPACE}/cloned_files"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Somaya-Ayman/tttest.git'
                script {
                    // Remove the directory if it exists
                    if (fileExists(CLONE_DIR)) {
                        echo "Directory exists. Cleaning up."
                        sh "rm -rf '${CLONE_DIR}'"
                    }
                    
                    // Create the directory
                    sh "mkdir -p '${CLONE_DIR}'"
                    
                    // Clone the repository into the created directory
                    sh "git clone https://github.com/Somaya-Ayman/tttest.git '${CLONE_DIR}'"
                }
            }
        }
        
        stage('Access and Modify Running Docker Container') {
            steps {
                script {
                    // Define remote host and container name
                    def remoteHost = 'somaya@102.37.146.184' // Replace with your remote server's user and IP
                    def containerName = 'user1container'
                    
                    // Ensure the SSH key has the correct permissions
                    sh "chmod 600 ~/host_key.pem"

                    // Step 1: Check if the named container is running
                    def containerId = sh(script: "ssh -i ~/host_key.pem ${remoteHost} 'docker ps -qf \"name=${containerName}\"'", returnStdout: true).trim()

                    if (containerId) {
                        echo "Container is running with ID: ${containerId}"

                        // Path inside the container where NGINX serves files
                        def nginxPath = "/usr/share/nginx/html"

                        // Step 2: Remove current files inside NGINX's HTML directory
                        sh "ssh -i ~/host_key.pem ${remoteHost} 'docker exec ${containerId} sh -c \"rm -rf ${nginxPath}/*\"'"

                        // Step 3: Copy new files from the cloned directory to the container
                        sh "scp -i ~/host_key.pem -r ${CLONE_DIR}/. ${remoteHost}:${nginxPath}"

                        // Step 4: Verify the new files are in place
                        sh "ssh -i ~/host_key.pem ${remoteHost} 'docker exec ${containerId} sh -c \"ls -al ${nginxPath}\"'"
                    } else {
                        error "No container found with the name '${containerName}'"
                    }
                }
            }
        }
    }
}
