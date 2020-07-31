Function DownloadFile($Uri, $OutFile)
{
	$path = Join-Path -Path $pwd -ChildPath $Outfile
	$wc = New-Object System.Net.WebClient
	$wc.DownloadFile($Uri, $path)
}

Function UpdateNodeJS
{
	$binUrl = "https://nodejs.org/dist/latest/win-x64/node.exe"
	$shaUrl = "https://nodejs.org/dist/latest/SHASUMS256.txt"

	DownloadFile -Uri $shaUrl -Outfile "signatures.txt"

	if (Test-Path -Path "signatures.txt")
	{
		$sig = Get-Content "signatures.txt"| Where-Object { $_.Contains("win-x64/node.exe") }
		$sig = $sig.Substring(0, 64)

		DownloadFile -Uri $binUrl -Outfile "node.exe"
		if (Test-Path -Path "node.exe")
		{
			$shasum = (Get-FileHash -Path "node.exe" -Algorithm SHA256).Hash
			if ($sig -eq $shasum)
			{
				Unblock-File -Path "node.exe"
				$dest = (Get-Command -Name node).Path
				Copy-Item -Path "node.exe" -Destination $dest -Force
			}
			else
			{
				Write-Output "assinatura inválida"
			}
		}
		else
		{
			Write-Output "não consegui descarregar 'node.exe'"
		}
	}
	else
	{
		Write-Output "não consegui descarregar 'shasums256.txt'"
	}
}

$location = $pwd.Path
$tempDir = Join-Path -Path $env:temp -ChildPath ([System.Guid]::NewGuid())
New-Item -ItemType Directory -Path $tempDir | Out-Null
Set-Location $tempDir

try {
	UpdateNodeJS
}
finally {
	Remove-Item $tempdir\*.* -Force
	Set-Location $location
	Remove-Item $tempDir
}

