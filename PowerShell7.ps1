# Set up the proxy server information for Zscaler.
$zscalerproxy = "http://gateway.zscloud.net:80"

# Configure the system-wide proxy settings to use the specified proxy.
# This ensures all web requests go through the Zscaler proxy, which uses default network credentials.
[System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy($zscalerproxy, $true)
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials

# Bypass the proxy server for local addresses.
[System.Net.WebRequest]::DefaultWebProxy.BypassProxyOnLocal = $true

# Define the security protocols to be used for secure connections.
# Enable support for SSL3, TLS (versions 1.0, 1.1, 1.2, and 1.3).
[Net.ServicePointManager]::SecurityProtocol = `
    [Net.SecurityProtocolType]::Ssl3 `
    -bor [Net.SecurityProtocolType]::Tls `
    -bor [Net.SecurityProtocolType]::Tls11 `
    -bor [Net.SecurityProtocolType]::Tls12 `
    -bor [Net.SecurityProtocolType]::Tls13

# Define a custom certificate policy class to trust all SSL certificates.
# This can be useful if working in a development environment with self-signed certificates.
Add-Type -TypeDefinition @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true; // Trust all certificates
    }
}
"@

# Apply the TrustAllCertsPolicy to bypass SSL certificate validation.
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# Define the GitHub API URL for PowerShell releases
$apiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases"

# Get the latest release tag name from the API
$latestVersion = (Invoke-RestMethod -Uri $apiUrl)[0].tag_name

# Remove the leading "v" from the version (e.g., v7.4.6 becomes 7.4.6)
$cleanVersion = $latestVersion.TrimStart("v")

# Set the download base URL
$baseUrl = "https://github.com/PowerShell/PowerShell/releases/download/$latestVersion/"

# Define the architectures to download
$architectures = @("x64", "x86")

# Loop over the architectures and download each version
foreach ($arch in $architectures) {
    # Construct the download URL for each architecture
    $downloadUrl = "$baseUrl/PowerShell-$cleanVersion-win-$arch.msi"

    # Specify the full path for the downloaded file
    $outputPath = "$outputDir\PowerShell-$cleanVersion-win-$arch.msi"

    # Download the installer
    Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath -proxy $zscalerproxy

    # Output the download URL and saved file location
    Write-Output "Download URL for ${arch}: $downloadUrl"
    Write-Output "File downloaded to: $outputPath"

    # Install the MSI package silently (without restarting, with progress bar)
    Write-Output "Installing PowerShell $cleanVersion for $arch..."
    $installProcess = Start-Process "msiexec.exe" -ArgumentList "/i $outputPath /norestart /qb!" -NoNewWindow -Wait -PassThru

    # Check if installation was successful
    if ($installProcess.ExitCode -eq 0) {
        Write-Output "Installation of PowerShell $cleanVersion for $arch completed successfully."
    } else {
        Write-Output "Installation of PowerShell $cleanVersion for $arch failed with Exit Code: $($installProcess.ExitCode)"
    }

    # Optionally remove the installer after installation
    Remove-Item -Path $outputPath -Force

}

# Set the output directory to C:\Temp
Write-Output "Cleaning up C:\Temp..."
Remove-Item -Path 'C:\Temp\*' -Force -Recurse
