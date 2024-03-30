pipeline {
    agent any
    stages {
        stage('Get_Dumps') {
            steps {
                   
                             
                              powershell  '''
                                    \$dumps=get-process  WmiPrvSE |select-object -ExpandProperty ID
                                            foreach (\$dump in \$dumps)
                                                {

                                           c:\\Dump\\Procdump\\procdump.exe  -ma $dump E:\\test\\explorer.PROCESSNAME.PID.YYMMDD.HHMMSS
                                                     }   

                                                     exit 0 '''  
                  }
        }
    }
}