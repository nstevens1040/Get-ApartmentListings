function Get-ApartmentListings_PadMapper
{
    [cmdletbinding()]
    Param(
        [string]$City,
        [string]$State_Code
    )
    . "C:\.TEMP\BIN\Get-ApartmentListings\Public\Get-ApartmentListings_GeoCode.ps1"
    $geo = Get-ApartmentListings_GeoCode -City $City -State_Code $State_Code
    $Uri = "https://www.padmapper.com/api/t/1/bundle"
    $Headers = [ordered]@{
        "Pragma"="no-cache"
        "Cache-Control"="no-cache"
        "sec-ch-ua"="`"Google Chrome`";v=`"89`", `"Chromium`";v=`"89`", `";Not A Brand`";v=`"99`""
        "DNT"="1"
        "X-CSRFToken"="5s5yahvCNY7MEoHLx2bWRbYMFFXwru4oVxnuStbuO0m6LNKyONpTPGCmybEys1WwcbZ6X7h606dBCfP8"
        "X-Zumper-XZ-Token"="6ee1klxjkr.oeb6mngq"
        "sec-ch-ua-mobile"="?0"
        "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36"
        "Accept"="*/*"
        "Sec-Fetch-Site"="same-origin"
        "Sec-Fetch-Mode"="cors"
        "Sec-Fetch-Dest"="empty"
        "Referer"="https://www.padmapper.com/"
        "Accept-Encoding"="gzip, deflate"
        "Accept-Language"="en-US,en;q=0.9"
    }
    $ContentType = "application/json"
    $r = [Execute.HttpRequest]::Send(
        $uri,
        [System.Net.Http.HttpMethod]::Get,
        $Headers,
        $null,
        $ContentType
    )
    $xz = $r.ResponseText | ConvertFrom-Json
    $Uri =  "https://www.padmapper.com/api/t/1/pages/listables"
    $Headers = [ordered]@{
        "Pragma"="no-cache"
        "Cache-Control"="no-cache"
        "sec-ch-ua"="`"Google Chrome`";v=`"89`", `"Chromium`";v=`"89`", `";Not A Brand`";v=`"99`""
        "DNT"="1"
        "X-CSRFToken"="$($xz.csrf)"
        "X-Zumper-XZ-Token"="$($xz.xz_token)"
        "sec-ch-ua-mobile"="?0"
        "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36"
        "Accept"="*/*"
        "Origin"="https://www.padmapper.com"
        "Sec-Fetch-Site"="same-origin"
        "Sec-Fetch-Mode"="cors"
        "Sec-Fetch-Dest"="empty"
        "Referer"="https://www.padmapper.com/apartments/$($City.ToLower())-$($State_Code.ToLower())/1-beds/under-2300?bathrooms=1&box=$($geo.West),$($geo.South),$($geo.East),$($geo.North)"
        "Accept-Encoding"="gzip, deflate"
        "Accept-Language"="en-US,en;q=0.9"
    }
    $ContentType = "application/json"
    $Body = "{`"bedrooms`":[1],`"external`":true,`"longTerm`":false,`"maxLat`":$($geo.North),`"maxLng`":$($geo.East),`"maxPrice`":2300,`"minBathrooms`":1,`"minLat`":$($geo.South),`"minLng`":$($geo.West),`"minPrice`":0,`"shortTerm`":false,`"transits`":{},`"matching`":true,`"limit`":100,`"offset`":0}"
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
    $iters = [Math]::Ceiling(($json.matching / 100))
    if($iters -gt 1){
        for($i = 1; $i -lt $iters; $i++){
            $body = "{`"bedrooms`":[1],`"external`":true,`"longTerm`":false,`"maxLat`":$($geo.North),`"maxLng`":$($geo.East),`"maxPrice`":2300,`"minBathrooms`":1,`"minLat`":$($geo.South),`"minLng`":$($geo.West),`"minPrice`":0,`"shortTerm`":false,`"transits`":{},`"matching`":true,`"limit`":100,`"offset`":$($i*100)}"
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
    }
    return $results
}


