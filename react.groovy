pipeline {
    agent { label 'windows-agent' }

    tools {
        nodejs 'NodeJS_24.4.1'  // השם כפי שהגדרת ב-Jenkins
    }

    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/your-username/your-react-repo.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                bat 'npm install'
            }
        }

        stage('Build') {
            steps {
                bat 'npm run build'
            }
        }

        stage('Deploy') {
            steps {
                // מעתיק את תיקיית build לנתיב IIS
                bat 'xcopy /E /Y /I build\\* C:\\inetpub\\wwwroot\\MyReactSite\\'
            }
        }
    }
}
