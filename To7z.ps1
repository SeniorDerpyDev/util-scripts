[CmdletBinding(SupportsShouldProcess=$True)]
param (
	[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
	[string] $Path,
	[Parameter(Mandatory=$false)]
	[int] $Level = 5,
	[switch] $DeleteSource
)
begin {
	$7za = Get-Command "7za"
	if ($7za -eq $null) { Exit }

	$originalSize = 0
	$newSize = 0
	$fileCount = 0

	function FormatSize($size) {
		switch($size) {
			{ $_ -gt 1tb }
				{ "{0:n2} TB" -f ($_ / 1tb); break }
			{ $_ -gt 1gb }
				{ "{0:n2} GB" -f ($_ / 1gb); break }
			{ $_ -gt 1mb }
				{ "{0:n2} MB " -f ($_ / 1mb); break }
			{ $_ -gt 1kb }
				{ "{0:n2} KB " -f ($_ / 1Kb); break }
			default
				{ "{0} B " -f $_ }
		}
	}
}
process {
	if ($PSCmdlet.ShouldProcess("$Path", "Convert archive to 7z")) {

		$tempDir = Join-Path -Path $env:temp -ChildPath ([System.Guid]::NewGuid())
		New-Item -ItemType Directory -Path $tempDir | Out-Null
		try {
			Write-Progress -Activity "$Path" -CurrentOperation "extracting"
			& $7za x "$Path" -o"$tempDir" | Out-Null
			if ($LastExitCode -eq 0) {
				$dest = [System.IO.Path]::ChangeExtension($Path, '7z')
				$files = $tempDir + "\*"

				Write-Progress -Activity "$Path" -CurrentOperation "compressing"
				& $7za a -t7z -mx"$Level" "$dest" "$files" | Out-Null
				if ($LastExitCode -eq 0) {
					Write-Progress -Activity "$Path" -CurrentOperation "testing"
					& $7za t "$dest" | Out-Null
					if ($LastExitCode -eq 0) {
						$originalSize += (Get-Item $Path).Length
						$newSize += (Get-Item $dest).Length
						$fileCount += 1
						if ($DeleteSource) {
							Remove-Item $Path
						}
					}
					else {
						Write-Error "Invalid 7z archive $dest"
						Remove-Item $dest
					}
				}
				else {
					Write-Error "Error creating archive $dest"
				}
			}
			else {
				Write-Error "Error decompressing $Path"
			}
		}
		finally {
			Remove-Item $tempDir -Recurse -Force
			Write-Progress -Activity "$Path" -Completed
		}
	}
}
end {
	Write-Host "$fileCount file(s) converted."
	Write-Host "Original size : $(FormatSize($originalSize))"
	Write-Host "New size  . . : $(FormatSize($newSize))"
}
