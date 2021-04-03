Add-Type -Path ..\lib\Execute.HttpRequest.dll
$uri = "https://domu.com/find/map/markers?sw=41.85%2C-87.7&ne=42.02%2C-87.61&domu_bedrooms_min=1&domu_bedrooms_max=&domu_bathrooms_min=1&domu_bathrooms_max=&domu_rentalprice_min=&domu_rentalprice_max=&domu_parking%5B%5D=Yes&domu_airconditioning%5B%5D=1&domu_washerdrier%5B%5D=Washer%2FDryer%3A+In-Unit&sort=&page="
$Headers = [ordered]@{
    "method"="GET"
    "authority"="www.domu.com"
    "scheme"="https"
    "pragma"="no-cache"
    "cache-control"="no-cache"
    "sec-ch-ua"="`"Google Chrome`";v=`"89`", `"Chromium`";v=`"89`", `";Not A Brand`";v=`"99`""
    "accept"="application/json, text/javascript, */*; q=0.01"
    "dnt"="1"
    "x-requested-with"="XMLHttpRequest"
    "sec-ch-ua-mobile"="?0"
    "user-agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36"
    "sec-fetch-site"="same-origin"
    "sec-fetch-mode"="cors"
    "sec-fetch-dest"="empty"
    "referer"="https://www.domu.com/chicago/apartment-search2?zoom=11&center=41.92808%2C-87.663345&domu_keys=&domu_search=Chicago%2C+IL+60660%2C+USA&place_id=ChIJGc4nd5nRD4gR2pJwvTB7NDw&domu_bedrooms_min=1&domu_bedrooms_max=&domu_bathrooms_min=1&domu_bathrooms_max=&domu_rentalprice_min=&domu_rentalprice_max=&domu_parking=Yes&domu_airconditioning=1&domu_washerdrier=Washer%2FDryer%3A+In-Unit&sort=acttime"
    "accept-encoding"="gzip, deflate"
    "accept-language"="en-US,en;q=0.9"
}
$page = 0
$results = @();
while($j.listings -notmatch "pager-current last"){
    Write-Host "`rpage index $($page)" -NoNewline
    $r = [Execute.HttpRequest]::Send(
        "$($URI -replace "page=","page=$($page)")",
        [System.Net.Http.HttpMethod]::Get,
        $Headers
    )
    $page++
    $json = $r.ResponseText | ConvertFrom-Json
    $results += $json.listings
    $j = $json
    Remove-Variable json -ea 0
}
$body = $results | Out-String

$html = @"
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width;initial-scale=1"/>
<title>domu results</title>
</head>
<body>
$($body)
</body>
</html>
"@

$document = [mshtml.HTMLDocumentClass]::new()
$bytes = [System.Text.Encoding]::Unicode.GetBytes($html)
$document.write($bytes)
$listings = $document.body.getElementsByClassName("domu-search-listing")

$coordinates = $listings[0].getAttribute("data-position")
$price = $listings[0].getAttribute("data-price")
$title = $listings[0].getElementsByClassName("listing-title") |% innerText
$pic = $listings[0].getElementsByClassName("listing-image")[0].getAttribute("data-src")
$link = "$($listings[0].getElementsByClassName("listing-image")[0].href -replace "^about:","https://www.domu.com")"
