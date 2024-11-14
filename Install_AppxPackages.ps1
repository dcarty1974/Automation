$storeapps = (Get-ChildItem -Path 'C:\Temp\*.*bundle').FullName

ForEach($storeapp in $storeapps){
 
Start-Process -Wait "C:\Windows\System32\Dism.exe"  -ArgumentList "/Online /add-ProvisionedAppxPackage /PackagePath:$storeapp /SkipLicense"

}
