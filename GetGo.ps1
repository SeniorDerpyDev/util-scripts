$uri = 'https://golang.org/dl/'
$json = Invoke-RestMethod -Uri "${uri}?mode=json" -Method Get
$json = $json | Sort-Object -Property version -Descending
$x = $json[0].files | Where-Object { ($_.os -eq 'windows') -and ($_.arch -eq 'amd64') -and ($_.kind -eq 'archive') } 
$filename = $x.filename
$filepath = Join-Path $pwd $filename

Write-Output "Downloading $($json[0].version) ..."
$wc = New-Object System.Net.WebClient
$wc.DownloadFile("${uri}${filename}", $filepath)

$shasum = (Get-FileHash -Path $filepath -Algorithm SHA256).Hash
if ($x.sha256 -eq $shasum)
{
	Unblock-File -Path $filepath
}
else
{
	Write-Error "Invalid checksum!"
	Remove-Item $filepath
}
