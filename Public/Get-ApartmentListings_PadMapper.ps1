Add-Type -Path ..\lib\Execute.HttpRequest.dll
$Uri =  "https://www.padmapper.com/api/t/1/pages/listables"
$Headers = [ordered]@{
    "Pragma"="no-cache"
    "Cache-Control"="no-cache"
    "sec-ch-ua"="`"Google Chrome`";v=`"89`", `"Chromium`";v=`"89`", `";Not A Brand`";v=`"99`""
    "DNT"="1"
    "X-CSRFToken"="xQ8nF6ZdBQnIF9m2QXE7vNLo0A52DcO6P4W0Vpe43hqHADwEPGNEemMIQxv0CKyxwRlKaApAAxWDoDlA"
    "X-Zumper-XZ-Token"="6edwx4vgh9.e0hubf4vq"
    "sec-ch-ua-mobile"="?0"
    "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36"
    "Accept"="*/*"
    "Origin"="https://www.padmapper.com"
    "Sec-Fetch-Site"="same-origin"
    "Sec-Fetch-Mode"="cors"
    "Sec-Fetch-Dest"="empty"
    "Referer"="https://www.padmapper.com/apartments/chicago-il/1-beds/under-1500?bathrooms=1&box=-87.9016172,41.871007,-87.5706568,42.0553219"
    "Accept-Encoding"="gzip, deflate"
    "Accept-Language"="en-US,en;q=0.9"
}
$ContentType = "application/json"
$Body = "{`"bedrooms`":[1],`"external`":true,`"longTerm`":false,`"maxLat`":42.05532,`"maxLng`":-87.57065,`"maxPrice`":1500,`"minBathrooms`":1,`"minLat`":41.871,`"minLng`":-87.90161,`"minPrice`":0,`"shortTerm`":false,`"transits`":{},`"matching`":true,`"limit`":100,`"offset`":0}"
$r = [Execute.HttpRequest]::Send(
    $uri,
    [System.Net.Http.HttpMethod]::Post,
    $Headers,
    $null,
    $ContentType,
    $body
)
$json = $r.ResponseText | ConvertFrom-Json
$results = @()
$json.listables.ForEach({ $results += $_ })
$iters = [Math]::Floor(($json.matching / 100))

for($i = 1; $i -lt $iters; $i++){
    $body = "{`"bedrooms`":[1],`"external`":true,`"longTerm`":false,`"maxLat`":42.05532,`"maxLng`":-87.57065,`"maxPrice`":1500,`"minBathrooms`":1,`"minLat`":41.871,`"minLng`":-87.90161,`"minPrice`":0,`"shortTerm`":false,`"transits`":{},`"matching`":true,`"limit`":100,`"offset`":$($i*100)}"
    $r = [Execute.HttpRequest]::Send(
        $uri,
        [System.Net.Http.HttpMethod]::Post,
        $Headers,
        $null,
        $ContentType,
        $body
    )
    $json = $r.ResponseText | ConvertFrom-Json
    $json.listables.ForEach({ $results += $_ })
    write-progress -percentComplete ($i/$iters*100) -Status "$([Math]::Round(($i/$iters*100),2))%" -Activity "page $($i) of $($iters - 1)"
}
$results[0]
