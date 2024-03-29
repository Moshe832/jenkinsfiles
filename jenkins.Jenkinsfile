pipeline {
    agent any
    stages {
        stage(' 1') {
            steps {
                echo 'Hello world!!'
                powershell '''$dumps=get-process - WmiPrvSE |select-object -ExpandProperty ID 
                 get-process WmiPrvSE |select-object -ExpandProperty ID 
                        #get-process |get-member
                           foreach ($dump in $dumps)
                            {
                             C:\Dump\Procdump\procdump64.exe  -ma  $dump c:\temp\dump.PID 
                            }'''
            

                
            }
        }
    }
}