Get-Content .\progid.txt | foreach { $p = "HKLM:\Software\Classes\" + $_; Remove-ItemProperty -path $p -name VSCode }
