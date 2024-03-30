pipeline {
    agent any
    stages {
        stage('Get_Dumps') {
            steps {
                   
                             
                              bat  '''
                              c:\\Dump\\Procdump\\procdump.exe  -ma 10012 E:\\test\\explorer.PROCESSNAME.PID
                              echo %errorlevel%
                               EXIT /B %ERRORLEVEL%'''
                                
                               
            

                
                  }
        }
    }
}