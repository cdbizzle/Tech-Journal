param($prefix, $server)

for ($i = 1; $i -le 255; $i++) {

    $ip = "$prefix.$i"
    $output = Resolve-DnsName -DnsOnly "$ip" -Server $server -ErrorAction Ignore
    
    if ($output) {
        $nameHost = $output.NameHost
        Write-Host "$ip - $nameHost"
    }
}