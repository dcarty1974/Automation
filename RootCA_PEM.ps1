$type = [System.Security.Cryptography.X509Certificates.X509ContentType]::Cert

New-Item -Path "C:\DevOps\Certificates\DERS" -ItemType Directory
New-Item -Path "C:\DevOps\Certificates\PEMS" -ItemType Directory

get-childitem -path cert:\LocalMachine\Root | ForEach-Object {
$hash = $_.GetCertHashString()
[System.IO.File]::WriteAllBytes("C:\DevOps\Certificates\DERS\"+"$hash.der", $_.export($type) )
openssl.exe x509 -in "C:\DevOps\Certificates\DERS\$hash.der" -inform DER -out "C:\DevOps\Certificates\PEMS\$hash.pem" -outform PEM
Get-Content "C:\DevOps\Certificates\PEMS\$hash.pem" >> C:\DevOps\Certificates\RootCAs.pem
}

Remove-Item -Path "C:\DevOps\Certificates\DERS" -Recurse
Remove-Item -Path "C:\DevOps\Certificates\PEMS" -Recurse
