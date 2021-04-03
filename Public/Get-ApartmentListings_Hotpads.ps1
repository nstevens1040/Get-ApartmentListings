Add-Type -Path ..\lib\Execute.HttpRequest.dll
$URI = "https://hotpads.com/node/hotpads-api/api/v2/listing/byCoordsV2?amenities=cooling%2Cdishwasher%2Cheating%2Cparking&areas=2067068844&bathrooms=0%2C0.5%2C1%2C1.5%2C2%2C2.5%2C3%2C3.5%2C4%2C4.5%2C5%2C5.5%2C6%2C6.5%2C7%2C7.5%2C8plus&bedrooms=0%2C1%2C2%2C3%2C4%2C5%2C6%2C7%2C8plus&channels=&components=basic%2Cuseritem%2Cquality%2Cmodel%2Cphotos&hideUnknownAvailabilityDate=false&includeVaguePricing=false&incomeRestricted=false&keywords=&laundry=inUnit&limit=0&listingTypes=corporate%2Crental%2Csublet&lowPrice=0&maxLat=41.9916938&maxLon=-87.4226662&militaryHousing=false&minLat=41.6753152&minLon=-88.0413338&minPhotos=1&minSqft=0&offset=0&orderBy=lowPrice&pets=&propertyTypes=condo%2Cdivided%2Cgarden%2Chouse%2Cland%2Clarge%2Cmedium%2Ctownhouse&seniorHousing=false&studentHousing=false&visible=favorite%2Cinquiry%2Cnew%2Cnote%2Cnotified%2Cviewed&commuteTime=&commuteMode=&commuteLats=&commuteLons="
$Headers = [ordered]@{
    "Pragma"="no-cache"
    "Cache-Control"="no-cache"
    "sec-ch-ua"="`"Google Chrome`";v=`"89`", `"Chromium`";v=`"89`", `";Not A Brand`";v=`"99`""
    "X-Build-Id"="5963"
    "X-Original-Uri"="/chicago-il/cheap-apartments-for-rent"
    "sec-ch-ua-mobile"="?0"
    "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36"
    "X-Server-Rendered"="false"
    "Accept"="application/json,text/html"
    "x-original-request-id"="2833717661468727855"
    "ZG-Via-Server"="hotpads-web"
    "DNT"="1"
    "Sec-Fetch-Site"="same-origin"
    "Sec-Fetch-Mode"="cors"
    "Sec-Fetch-Dest"="empty"
    #"Referer"="https://hotpads.com/chicago-il/cheap-apartments-for-rent?amenities=cooling-dishwasher-heating-parking&includeVaguePricing=false&incomeRestricted=false&lat=41.8337&laundry=inUnit&lon=-87.7320&militaryHousing=false&orderBy=lowPrice&photos=1&seniorHousing=false&studentHousing=false&z=11"
    "Accept-Encoding"="gzip, deflate"
    "Accept-Language"="en-US,en;q=0.9"
}
$ContentType = "application/json"
$r = [execute.httprequest]::Send(
    $uri,
    [system.Net.Http.HttpMethod]::Get,
    $headers,
    $null,
    $ContentType
)
$j = $r.ResponseText | ConvertFrom-Json

$URI = "https://hotpads.com/node/hotpads-api/api/v2/listing/byCoordsV2?amenities=cooling%2Cdishwasher%2Cheating%2Cparking&areas=2067068844&bathrooms=0%2C0.5%2C1%2C1.5%2C2%2C2.5%2C3%2C3.5%2C4%2C4.5%2C5%2C5.5%2C6%2C6.5%2C7%2C7.5%2C8plus&bedrooms=0%2C1%2C2%2C3%2C4%2C5%2C6%2C7%2C8plus&channels=&components=basic%2Cuseritem%2Cquality%2Cmodel%2Cphotos&hideUnknownAvailabilityDate=false&includeVaguePricing=false&incomeRestricted=false&keywords=&laundry=inUnit&limit=$($j.data.numListingsAvailable)&listingTypes=corporate%2Crental%2Csublet&lowPrice=0&maxLat=41.9916938&maxLon=-87.4226662&militaryHousing=false&minLat=41.6753152&minLon=-88.0413338&minPhotos=1&minSqft=0&offset=0&orderBy=lowPrice&pets=&propertyTypes=condo%2Cdivided%2Cgarden%2Chouse%2Cland%2Clarge%2Cmedium%2Ctownhouse&seniorHousing=false&studentHousing=false&visible=favorite%2Cinquiry%2Cnew%2Cnote%2Cnotified%2Cviewed&commuteTime=&commuteMode=&commuteLats=&commuteLons="
$Headers = [ordered]@{
    "Pragma"="no-cache"
    "Cache-Control"="no-cache"
    "sec-ch-ua"="`"Google Chrome`";v=`"89`", `"Chromium`";v=`"89`", `";Not A Brand`";v=`"99`""
    "X-Build-Id"="5963"
    "X-Original-Uri"="/chicago-il/cheap-apartments-for-rent"
    "sec-ch-ua-mobile"="?0"
    "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36"
    "X-Server-Rendered"="false"
    "Accept"="application/json,text/html"
    "x-original-request-id"="2833717661468727855"
    "ZG-Via-Server"="hotpads-web"
    "DNT"="1"
    "Sec-Fetch-Site"="same-origin"
    "Sec-Fetch-Mode"="cors"
    "Sec-Fetch-Dest"="empty"
    "Referer"="https://hotpads.com/chicago-il/cheap-apartments-for-rent?amenities=cooling-dishwasher-heating-parking&includeVaguePricing=false&incomeRestricted=false&lat=41.8337&laundry=inUnit&lon=-87.7320&militaryHousing=false&orderBy=lowPrice&photos=1&seniorHousing=false&studentHousing=false&z=11"
    "Accept-Encoding"="gzip, deflate"
    "Accept-Language"="en-US,en;q=0.9"
}
$ContentType = "application/json"
$r = [execute.httprequest]::Send(
    $uri,
    [system.Net.Http.HttpMethod]::Get,
    $headers,
    $null,
    $ContentType
)
$results = $r.ResponseText | ConvertFrom-Json
