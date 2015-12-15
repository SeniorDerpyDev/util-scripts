$current = $pwd
Get-ChildItem -path $current -filter .git -recurse -force | %{ Set-Location $_.Parent.FullName; git pull }
Get-ChildItem -path $current -filter .hg -recurse -force | %{ Set-Location $_.Parent.FullName; hg pull -u }
Set-Location $current
