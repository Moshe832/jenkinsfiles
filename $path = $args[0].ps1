$path = $args[0]

$path=$pwd

$folder = $Source | Split-Path -Leaf

$date = (Get-Date -Format "yyyy-MM-dd")

$Dest = 'C:\backup'

Add-Type -AssemblyName System.Windows.Forms

[System.Windows.Forms.MessageBox]::Show("The folder $Source will be copy to D:\backup ","Hi")

$Destination = "$Dest\$folder-$date"

Copy-Item -Path $Source  -Destination $Destination     -Recurse -force




if(Test-Path -Path $Destination)


{
    [System.Windows.Forms.MessageBox]::Show("Backup path $Destination " , 'Backup Done')

    #Invoke-Item -Path $Destination

}

#pause

