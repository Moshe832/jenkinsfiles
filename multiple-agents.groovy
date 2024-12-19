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
                    python3 -V
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
    agent none
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
        }
    }
}
