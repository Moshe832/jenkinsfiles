def agents  = ['linux', 'Remote Machine']

def generateStage(nodeLabel) {
    return {
        stage("Runs on ${nodeLabel}") {
            node(nodeLabel) {
                script {
                    echo "Running on ${nodeLabel}"
                    echo '************************'
                    echo '*****BUILDING JOBS******'
                    echo '************************'
                    echo 'Very Good'
                    sh 'python3 -V'
                //sh 'python build.py'
                //sh 'cd ion-js && npm run prepublishOnly'
                }
            }
        }
    }
}
def parallelStagesMap = agents.collectEntries {
    ["${it}" : generateStage(it)]
}
pipeline {
    agent any
    options {
        timestamps()
        timeout(time: 20, unit: 'SECONDS')
    }

    stages {
        stage('non-parallel stage') {
            steps {
                echo 'This stage will be executed first.'
            }
        }
        stage('parallel stage') {
            steps {
                script {
                    parallel parallelStagesMap
                }
            }

            post {
                always {
                    sh 'echo "This will always run"'
                }
                success {
                    sh 'echo "This will run only if successful"'
                }
                failure {
                    sh 'echo "This will run only if failed"'
                }
                unstable {
                    sh 'echo "This will run only if the run was marked as unstable"'
                }
                changed {
                    sh 'echo "This will run only if the state of the Pipeline has changed"'
                    sh 'echo "For example, the Pipeline was previously failing but is now successful"'
                    sh 'echo "... or the other way around :)"'
                }
            }
        }
    }
}

