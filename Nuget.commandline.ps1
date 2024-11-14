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

# Download and place nuget.exe into Windows file system
Invoke-WebRequest https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile C:\DevOps\Nuget.commandline\nuget.exe -proxy $zscalerproxy
