pipeline {
    agent any
    stages {
        stage('Get_Dumps') {
            steps {
                   
                             
                              bat  ''' echo C:\\Dump\\Procdump\\procdump.exe  -ma 4080
                              echo %errorlevel%
                               EXIT /B %ERRORLEVEL%'''
                                
                               
            

                
                  }
        }
    }
}