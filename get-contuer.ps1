
$limit = (Get-Date).AddMinutes(1)

while ((Get-Date) -le $limit) {
    Get-Counter |out-file c:\temp\Counter.csv -force
    Start-Sleep -Seconds 10

}

Get-Counter | Get-Member
Get-Counter -ListSet *

Get-Counter -listset * | sort-object countersetname | Format-Table countersetname

Get-Counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 2 -MaxSamples 10

(Get-Counter -listset memory).paths