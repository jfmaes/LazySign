
function Invoke-LazySign{

    <#
    .SYNOPSIS
        Easy script that Sign a Windows binary with a self-signed certificate
        Ported from https://github.com/jfmaes/LazySign by Jean Maes
	# Import
        ipmo .\Invoke-LazySign.ps1
        # Run
        Invoke-LazySign [-Password <certificate password>|-Guid] <search-term>
    .EXAMPLE
        # Sign binary with a crafted cert (exported without password)
        Invoke-LazySign -Target "target.exe" -Domain "microsoft.com"
        # Sign binary with a crafted cert (exported with password)
        Invoke-LazySign -Target "target.exe" -Domain "microsoft.com"-Password "Passw0rd!
    #>

    [CmdletBinding()]
    param
    (
	[Parameter(Mandatory=$False)]
	[string]$Password,
	[Parameter(Mandatory=$True)]
	[string]$Domain,
	[Parameter(Mandatory=$True)]
	[string]$Target
    )

    $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force -ErrorAction SilentlyContinue
    
    $StoreLocation = "Cert:\CurrentUser\My"

    $CertPath = $(Join-Path (Get-Location) "$Domain.pfx") 
 
    $Certificate = New-SelfSignedCertificate -CertStoreLocation $StoreLocation -DnsName $Domain -Type CodeSigning -ErrorAction SilentlyContinue
    
    if (-not (Test-Path $StoreLocation)){
        Write-Output "[-] Certificate Not Found in Store"
        return
    }    
    
    Export-PfxCertificate -FilePath $CertPath -Password $SecurePassword -Cert $Certificate -ErrorAction SilentlyContinue

    if (-not (Test-Path $CertPath)){
        Write-Output "[-] Certificate Creation Failed"
        return
    }

    Set-AuthenticodeSignature -Certificate $Certificate -Filepath $Target –TimestampServer “http://timestamp.comodoca.com/authenticode”

    Remove-Item $CertPath

}

$PSDefaultParameterValues.Remove("Invoke-LazySign:Password")
$PSDefaultParameterValues.Add("Invoke-LazySign:Password", "Passw0rd!")
