Param(
    [Parameter(Mandatory,ValueFromPipeline)][string]$GHToken
)

#Requires -Version 5.1
Set-StrictMode -Version 'latest'
$ErrorActionPreference = 'stop'
[bool]$found = $false

Start-Transcript -Path "$env:TEMP\lolDrivers_Results.txt" -IncludeInvocationHeader -Force

Function New-GitHubGist() {
    [cmdletbinding(SupportsShouldProcess,DefaultParameterSetName = "Content")]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "What is the name for your gist?",ValueFromPipelineByPropertyName)][ValidateNotNullorEmpty()][string]$Name,
        [Parameter(ParameterSetName="path",Mandatory,ValueFromPipelineByPropertyName)][ValidateNotNullorEmpty()][Alias("pspath")][string]$Path,
        [Parameter(ParameterSetName="Content",Mandatory)][ValidateNotNullorEmpty()][string[]]$Content,
        [Alias("token")][ValidateNotNullorEmpty()][string]$UserToken = $GHToken,
        [string]$Description,
        [switch]$Private,
        [switch]$Passthru
    )

    Begin {
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
        #create the header
        $head = @{
            Authorization = 'Bearer ' + $UserToken
        }
        #define API uri
        $base = "https://api.github.com"

    } #begin

    Process {
        #display PSBoundparameters formatted nicely for Verbose output  
        [string]$pb = ($PSBoundParameters | Format-Table -AutoSize | Out-String).TrimEnd()
        Write-Verbose "[PROCESS] PSBoundparameters: `n$($pb.split("`n").Foreach({"$("`t"*2)$_"}) | Out-String) `n" 

        #json section names must be lowercase
        #format content as a string
        
        switch ($pscmdlet.ParameterSetName) {
        "path" {
            $gistContent = Get-Content -Path $Path | Out-String
        }
        "content" {
            $gistContent = $Content | Out-String
        }
        } #close Switch

        $data = @{
            files = @{$Name = @{content = $gistContent}}
            description = $Description
            public = (-Not ($Private -as [boolean]))
        } | Convertto-Json

        Write-Verbose ($data| out-string)
        Write-Verbose "[PROCESS] Posting to $base/gists"
        
        If ($pscmdlet.ShouldProcess("$name [$description]")) {
            
            #parameters to splat to Invoke-Restmethod
            $invokeParams = @{
                Method = 'Post'
                Uri = "$base/gists" 
                Headers = $head 
                Body = $data 
                ContentType = 'application/json'
            }

            $r = Invoke-Restmethod @invokeParams

        if ($Passthru) {
            Write-Verbose "[PROCESS] Writing a result to the pipeline"
            $r | Select @{Name="Url";Expression = {$_.html_url}},
            Description,Public,
            @{Name = "Created";Expression = {$_.created_at -as [datetime]}}
        } 
        } #should process

    } #process

    End {
        Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
    } #end

} #end function

$DirPathDrivers = @(
    'C:\WINDOWS\inf'
    'C:\WINDOWS\System32\drivers'
    'C:\WINDOWS\System32\DriverStore\FileRepository'
)


if ( !(Test-Path -Path 'Variable:lolDriversJson' -PathType Leaf) ) {
    [datetime]::Now.ToString('o') | Write-Host -ForegroundColor Cyan
    'downloading lolJdriver JSON' | Write-Host -ForegroundColor Cyan
    $lolDriversJson = Invoke-RestMethod -Method Get -Uri 'https://www.loldrivers.io/api/drivers.json'
}

$execTimeStart = [datetime]::Now

[datetime]::Now.ToString('o') | Write-Host -ForegroundColor Cyan
'building hashtable of driver files and their hashes' | Write-Host -ForegroundColor Cyan
$htDriverHashPath = [hashtable]::new([System.StringComparer]::OrdinalIgnoreCase)

foreach ( $dirverDir in $DirPathDrivers ) {
    foreach ( $driverFile in (Get-ChildItem -File -LiteralPath $dirverDir) ) {
        foreach ( $hashType in ('SHA256', 'SHA1', 'MD5') ) {
            foreach ( $driverFileHash in ($driverFile | Get-FileHash -Algorithm $hashType) ) {
                if ( !$htDriverHashPath.ContainsKey($driverFileHash.Hash) ) {
                    $htDriverHashPath.Add(
                        $driverFileHash.Hash, @{
                            'HashType' = $hashType
                            'path'     = $driverFileHash.Path
                        }
                    )
                }
            }
        }
    }
}


[datetime]::Now.ToString('o') | Write-Host -ForegroundColor Cyan
'looking for lolDriver hash matches' | Write-Host -ForegroundColor Cyan
$htSearchResults = [hashtable]::new([System.StringComparer]::OrdinalIgnoreCase)

foreach ( $lolDriver in $lolDriversJson ) {
    foreach ( $KnownVulnerableSample in $lolDriver.KnownVulnerableSamples ) {

        if ( ($KnownVulnerableSample | Get-Member).Name.Contains('SHA256') ) {
            $propNameHashType = 'SHA256'
        } elseif (($KnownVulnerableSample | Get-Member).Name.Contains('SHA1')) {
            $propNameHashType = 'SHA1'
        } elseif ( ($KnownVulnerableSample | Get-Member).Name.Contains('MD5') ) {
            $propNameHashType = 'MD5'
        } else {            
            Write-Error -Message ("fix me" + [System.Environment]::NewLine + $KnownVulnerableSample | Out-String)
        }

        if ( $htDriverHashPath.ContainsKey($KnownVulnerableSample.$propNameHashType) ) {
            if (!$htSearchResults.ContainsKey($KnownVulnerableSample.$propNameHashType)) {
                $htSearchResults.Add(
                    $KnownVulnerableSample.$propNameHashType, @{
                        'driverPath' = $htDriverHashPath.($KnownVulnerableSample.$propNameHashType)
                        'lolDriver'  = $lolDriver
                    }
                )
            }
        }
    }
}

Write-Host
Write-Host

'time (seconds) to run, excluding download of lolDriver JSON' | Write-Host
(New-TimeSpan -Start $execTimeStart -End ([datetime]::Now)).TotalSeconds | Write-Host

Write-Host
Write-Host

[datetime]::Now.ToString('o') | Write-Host -ForegroundColor Cyan
if ( $htSearchResults.Count -eq 0 ) {
    'no lolDrivers found' | Write-Host -ForegroundColor Green
} else {
    'lolDrivers found!' | Write-Host -ForegroundColor Red
    $found = $true
    $htSearchResults | ConvertTo-Json | Write-Host
}

Stop-Transcript
if ($found) { New-GitHubGist -Name $env:COMPUTERNAME -Path "$env:TEMP\lolDrivers_Results.txt" -Private -UserToken $GHToken }
Remove-Item "$env:TEMP\lolDrivers_Results.txt"