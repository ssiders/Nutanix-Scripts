
#==============NUTANIX=========================================
#WriteVMInfoToCSV.ps1 Script Written by Seth Siders seth.siders@nutanix.com 8/17/2017
#Customization of inputs required where noted below


add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
    ServicePoint srvPoint, X509Certificate certificate,
    WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

#========Set your Nutanix Prism user (REQUIRED)
$user = "admin"

#=======Set your Prism password (REQUIRED)
$pass = "Str0ngP@ssword!"


#=======By default the script will output the csv to the logged in user's desktop (OPTIONAL)
$path = $env:USERPROFILE
$path = $path + "\Desktop\"


$pair = "${user}:${pass}"
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"
$headers = @{ Authorization = $basicAuthValue }
$ts = (Get-Date -format yyyyMMdd_HHmmss)

#=======Customize the IP address for your Nutanix cluster VIP (REQUIRED)
$Uri = "https://10.4.44.27:9440/PrismGateway/services/rest/v2.0/vms/"


#=======Path and File name can optionally be overwritten here with desired path and file name e.g.: $PathAndFile = "c:\OutputDir\vminfo.csv"  (OPTIONAL)
$PathAndFile = $path + "VM List-" + $ts + ".csv"
$json = (Invoke-RestMethod -Uri $Uri -Headers $Headers).entities
$json | select @{N="Name";E={$_.name}},@{N="Description";E={$_.description}},@{N="Power State";E={$_.power_state}},@{N="RAM";E={$_.memory_mb}},@{N="VCPUS";E={$_.num_vcpus}},@{N="Cores";E={$_.num_cores_per_vcpu}} | Export-Csv -NoTypeInformation -Path $PathAndFile
write-host " "
write-host " "
write-host "    VM Info written to: " $PathAndFile
write-host " "
write-host " "
