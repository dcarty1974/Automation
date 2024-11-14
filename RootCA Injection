certutil.exe -generateSSTFromWU C:\DevOps\Certificates\RootCAs.sst
$sstFile = (Get-ChildItem -Path C:\DevOps\Certificates\RootCAs.sst)
$sstFile | Import-Certificate -CertStoreLocation Cert:\LocalMachine\Root
