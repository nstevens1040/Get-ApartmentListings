Function Get-ApartmentListings_Hotpads
{
    [cmdletbinding()]
    Param(
        [string]$State_Code,
        [string]$City
    )
    if(!("Execute.HttpRequest" -as [type])){
        Add-Type -Path ..\lib\Execute.HttpRequest.dll
    }
    . "C:\.TEMP\BIN\Get-ApartmentListings\Public\Get-ApartmentListings_GeoCode.ps1"
    $geo = Get-ApartmentListings_GeoCode -City $City -State_Code $State_Code
    $Uri = "https://hotpads.com/node/hotpads-api/api/v2/listing/byCoordsV2?amenities=cooling%2Cdishwasher%2Cheating%2Cparking&areas=310398133&bathrooms=0%2C0.5%2C1%2C1.5%2C2%2C2.5%2C3%2C3.5%2C4%2C4.5%2C5%2C5.5%2C6%2C6.5%2C7%2C7.5%2C8plus&bedrooms=0%2C1%2C2%2C3%2C4%2C5%2C6%2C7%2C8plus&channels=&components=basic%2Cuseritem%2Cquality%2Cmodel%2Cphotos&hideUnknownAvailabilityDate=false&includeVaguePricing=false&incomeRestricted=false&keywords=&laundry=inUnit&limit=40&listingTypes=corporate%2Crental%2Croom%2Csublet&lowPrice=0&maxLat=$($geo.North)&maxLon=$($geo.East)&militaryHousing=false&minLat=$($geo.South)&minLon=$($geo.West)&minPhotos=1&minSqft=0&offset=0&orderBy=lowPrice&pets=&propertyTypes=condo%2Cdivided%2Cgarden%2Chouse%2Cland%2Clarge%2Cmedium%2Ctownhouse&seniorHousing=false&studentHousing=false&visible=favorite%2Cinquiry%2Cnew%2Cnote%2Cnotified%2Cviewed&commuteTime=&commuteMode=&commuteLats=&commuteLons="
    $Headers =  [ordered]@{
        "Pragma"="no-cache"
        "Cache-Control"="no-cache"
        "sec-ch-ua"="`"Google Chrome`";v=`"89`", `"Chromium`";v=`"89`", `";Not A Brand`";v=`"99`""
        "X-Build-Id"="5971"
        "X-Original-Uri"="/$($City.ToLower())-$($State_Code.ToLower())/apartments-for-rent"
        "sec-ch-ua-mobile"="?0"
        "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36"
        "X-Server-Rendered"="false"
        "Accept"="application/json,text/html"
        "x-original-request-id"="2775256162964003074"
        "ZG-Via-Server"="hotpads-web"
        "DNT"="1"
        "Sec-Fetch-Site"="same-origin"
        "Sec-Fetch-Mode"="cors"
        "Sec-Fetch-Dest"="empty"
        "Referer"="https://hotpads.com/$($City.ToLower())-$($State_Code.ToLower())/apartments-for-rent?amenities=cooling-dishwasher-heating-parking&includeVaguePricing=false&incomeRestricted=false&laundry=inUnit&militaryHousing=false&orderBy=lowPrice&photos=1&seniorHousing=false&studentHousing=false"
        "Accept-Encoding"="gzip, deflate"
        "Accept-Language"="en-US,en;q=0.9"
    }
    $ContentType  = "application/json"
    $r = [execute.httprequest]::Send(
        $uri,
        [System.Net.Http.httpMethod]::Get,
        $Headers,
        $null,
        $ContentType
    )
    $results = @()
    $json.data.buildings.ForEach({$results += $_.listings})
    return $results
}
