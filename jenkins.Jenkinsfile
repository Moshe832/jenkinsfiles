
pipeline {
    options { timestamps() }
    agent any
    stages {
        stage('Get_Dumps') {
            steps {
                powershell '''

                               \$dumps=get-process  WmiPrvSE |select-object -ExpandProperty ID

                                             foreach (\$dump in \$dumps)
                                                {

                                    c:\\Dump\\Procdump\\procdump.exe  -ma $dump E:\\test\\PROCESSNAME.PID.YYMMDD
                                                }

                                             exit 0
                                             '''
            }
        }
    }
}
