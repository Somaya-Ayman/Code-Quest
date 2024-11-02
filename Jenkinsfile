pipeline {
    agent any

    environment {
        CLONE_DIR = "${WORKSPACE}/cloned_files"
        REMOTE_USER = 'somaya' // Update with your remote server username
        REMOTE_HOST = '102.37.146.184' // Update with your remote server IP address
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
        
        stage('Access Remote Server and Modify Docker Container') {
            steps {
                script {
                    // Define commands to be executed on the remote server
                    def remoteCommands = """
                    #!/bin/bash
                    # Check if the named container is running
                    containerId=\$(docker ps -qf 'name=user1container')
                    if [ -z "\$containerId" ]; then
                        echo "No container found with the name 'user1container'"
                        exit 1
                    fi

                    echo "Container is running with ID: \$containerId"
                    
                    # Path inside the container where NGINX serves files
                    nginxPath="/usr/share/nginx/html"

                    # Step 1: Remove current files inside NGINX's HTML directory
                    docker exec \$containerId sh -c 'rm -rf \$nginxPath/*'

                    # Step 2: Copy new files from the cloned directory to the container
                    docker cp '${CLONE_DIR}/.' \$containerId:\$nginxPath

                    # Step 3: Verify the new files are in place
                    docker exec \$containerId sh -c 'ls -al \$nginxPath'
                    """

                    // SSH into the remote server and execute the commands
                    sh """
                    ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} 'bash -s' <<< "${remoteCommands}"
                    """
                }
            }
        }
    }
}
