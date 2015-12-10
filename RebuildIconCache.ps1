#--------------------------------------------------------------------------------- 
#The sample scripts are not supported under any Microsoft standard support 
#program or service. The sample scripts are provided AS IS without warranty  
#of any kind. Microsoft further disclaims all implied warranties including,  
#without limitation, any implied warranties of merchantability or of fitness for 
#a particular purpose. The entire risk arising out of the use or performance of  
#the sample scripts and documentation remains with you. In no event shall 
#Microsoft, its authors, or anyone else involved in the creation, production, or 
#delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, 
#loss of business information, or other pecuniary loss) arising out of the use 
#of or inability to use the sample scripts or documentation, even if Microsoft 
#has been advised of the possibility of such damages 
#--------------------------------------------------------------------------------- 

#requires -version 2.0

<#
 	.SYNOPSIS
        This script can be used to refresh the Windows explorer.
    .DESCRIPTION
        This script can be used to refresh the Windows explorer.        
    .EXAMPLE
        C:\PS> C:\Script\RebuildIconCache\RebuildIconCache.ps1

		Successfully refreshed icon cache.
#>
Function RefreshExplorer
{
    $ProcessName = "explorer"

    Get-Process -Name $ProcessName -ErrorAction SilentlyContinue -ErrorVariable IsExistProcessError | Out-Null

    #Check if the process is running
    If($IsExistProcessError.Exception -eq $null)
    {
        Try
        {
            Write-Verbose "Stopping ProcessName: $ProcessName"
            Stop-Process -Name $ProcessName -ErrorAction Stop

            Try
            {
                #Check if file exists
                If(Test-Path -Path "$env:LOCALAPPDATA\IconCache.db")
                {
                    Remove-Item -Path "$env:LOCALAPPDATA\IconCache.db" -Force
                }
                #Restart process
                Start-Process $ProcessName

                Invoke-Expression -Command "ie4uinit.exe -cleariconcache"
                Write-Host "Successfully refreshed icon cache."
            }
            Catch
            {
                Write-Warning "Failed to refreshed icon cache."
            }
        }
        Catch
        {
            $ErrorMsg = $_.Exception.Message
            Write-Warning $ErrorMsg
        }
    }
}

RefreshExplorer -ProcessName "explorer"