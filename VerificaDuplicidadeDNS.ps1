$outFilePath = "C:\Temp\dns.txt";
$outFilePathRev = "C:\Temp\dnsReverso.txt";

function VerificaEntradasDuplicadasNoDNS($zonename, $dchostname){
    $nenhumaIrregularidade = $true;
    try{ Remove-Item -Path $outFilePath -Force; New-Item -Path $outFilePath -ItemType File; clear;}catch{}
    Write-Host "Baixando dados do servidor DNS..."
    Start-Sleep -Seconds 3;
    Get-DnsServerResourceRecord -ZoneName $zonename -ComputerName $dchostname | Where-Object {$_.RecordType -eq "A"} | Format-Table
    $dnsData = Get-DnsServerResourceRecord -ZoneName $zonename -ComputerName $dchostname | Where-Object {$_.RecordType -eq "A"}
    Write-Host "----------------------------------------------------------------------------------------------------------------------------------------"
    Write-Host ""
    Write-Host ""
    Start-Sleep -Seconds 3;
    Foreach($dnsItem in $dnsData){
        if(($dnsItem.HostName[0] -match "E") -or (($dnsItem.HostName[0] -match "N") -and -Not($dnsItem.HostName[1] -match "o") -and -Not($dnsItem.HostName[1] -match "P")) -or ($dnsItem.HostName[0] -match "T")){
            $tempHST = $dnsItem.HostName;
            $tempIP = $dnsItem.RecordData.IPv4Address.IPAddressToString;
            Write-Host "Analisando "$dnsItem.HostName;
            Foreach($dnsItem in $dnsData){
                if(($dnsItem.RecordData.IPv4Address.IPAddressToString -eq $tempIP) -and ($dnsItem.HostName -ne $tempHST)){
                    $nenhumaIrregularidade = $false;
                    $newHST = $dnsItem.HostName;
                    $newIP = $dnsItem.RecordData.IPv4Address.IPAddressToString;
                    Add-Content $outFilePath "Encontrado irregularidade para $tempHST";
                    $tableObj = @();
                    $tableObj += [PSCustomObject]@{
                        Hostname = $tempHST
                        IP = $tempIP
                    }
                    $tableObj += [PSCustomObject]@{
                        Hostname = $newHST
                        IP = $newIP
                    }
                    Add-Content $outFilePath "Duplicação: ";
                    Add-Content $outFilePath "Hostname: $tempHST IP: $tempIP";
                    Add-Content $outFilePath "Hostname: $newHST IP: $newIP";
                    Add-Content $outFilePath "";
                    Write-Host "Encontrado irregularidade para "$tempHST;
                    Write-Host "Duplicação: ";
                    $tableObj | FT -auto
                }
            }
        }
    }
    Write-Host "Análise finalizada com sucesso!"
    if($nenhumaIrregularidade -eq $true){
        Write-Host "Análise finalizada com sucesso!"
    }
}

function VerificaEntradasDuplicadasNoDNSReverso($zonename, $dchostname){
    try{ Remove-Item -Path $outFilePath -Force; New-Item -Path $outFilePath -ItemType File; clear;}catch{}
    Write-Host "Baixando dados do servidor DNS..."
    Start-Sleep -Seconds 3;
    Get-DnsServerResourceRecord -ZoneName $zonename -ComputerName $dchostname | Where-Object {$_.Type -eq "12"} | Format-Table
    $reverseDNSData = Get-DnsServerResourceRecord -ZoneName $zonename -ComputerName $dchostname | Where-Object {$_.Type -eq "12"}
    Write-Host "----------------------------------------------------------------------------------------------------------------------------------------"
    Write-Host ""
    Write-Host ""
    Start-Sleep -Seconds 3;
    Foreach($reverseDNSItem in $reverseDNSData){     
        $tempHST = $reverseDNSItem.HostName;
        $tempIP = $reverseDNSItem.RecordData.PtrDomainName;
        Write-Host "Analisando "$reverseDNSItem.HostName;
        Foreach($reverseDNSItem in $reverseDNSData){
            if(($dnsItem.HostName -eq $tempHST) -and ($reverseDNSItem.RecordData.PtrDomainName -ne $tempIP)){
                $newHST = $reverseDNSItem.HostName;
                $newIP = $reverseDNSItem.RecordData.PtrDomainName;
                Add-Content $outFilePathRev "Encontrado irregularidade para $tempHST";
                Add-Content $outFilePathRev "Duplicação: ";
                Add-Content $outFilePathRev "IP: $tempHST Hostname: $tempIP";
                Add-Content $outFilePathRev "IP: $newHST Hostname: $newIP";
                Add-Content $outFilePathRev "";
                Write-Host "Encontrado irregularidade para "$tempHST;
                Write-Host "Duplicação: ";
                Write-Host "IP: "$tempHST "Hostname: "$tempIP;
                Write-Host "IP: "$reverseDNSItem.HostName "Hostname: "$reverseDNSItem.RecordData.PtrDomainName;
                Write-Host "";
            }
        }     
    }
}

VerificaEntradasDuplicadasNoDNS('cenibra.com.br','CNBBODC01')