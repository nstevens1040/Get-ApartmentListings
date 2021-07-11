function Get-ApartmentListings_PadMapper
{
    [cmdletbinding()]
    Param(
        [string]$City,
        [string]$State_Code
    )
    $reg = [regex]::new("window.__PRELOADED_STATE__ = (\{.+\})")
    . .\Public\Get-ApartmentListings_GeoCode.ps1
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
    $all_results = [Search.ListingCollection]::new()
    $c = 0
    $all = $json.listables.Count
    foreach($item in $json.listables)
    {
        remove-variable p,j,listing -ea 0
        $p = ([System.Net.WebClient]::New()).DownloadString("https://padmapper.com" + $item.url)
        $j = $reg.Match($p).Groups[1].Value | ConvertFrom-Json
        $listing = [Search.Results]::new()
        if($j.entity.agents.Count -gt 0)
        {
            $listing.EmailAddress = $j.entity.agents[0].email
        }
        $listing.Address = $item.address + ", " + $item.city + ", " + $item.state + " " + $item.zipcode
        $listing.Baths_max = $item.max_bathrooms
        $listing.Baths_min = $item.min_bathrooms
        $listing.Beds_max = $item.max_bedrooms
        $listing.Beds_min = $item.min_bedrooms
        $listing.Latitude = $item.lat
        $listing.ImageUri = "https://img.zumpercdn.com/" + $item.image_ids[0] + "/1280x960"
        $listing.Link = "https://padmapper.com" + $item.url
        $listing.Longitude = $item.lng
        $listing.Name = $item.agent_name
        $listing.OriginPlatform = "padmapper.com"
        if(!$item.phone)
        {
            if($j.entity.agents.Count -gt 0)
            {
                $listing.PhoneNumber = $j.entity.agents[0].phone
            }
        } else {
            $listing.PhoneNumber = $item.phone
        }
        $listing.Price_High = $item.max_price
        $listing.Price_Low = $item.min_price
        $listing.PropertyManager = $item.brokerage_name
        $all_results.resultList.Add($listing)
        $c++
        Write-Progress -PercentComplete ($c/$all*100) -Status "$([math]::Round(($c/$all*100),2))%" -Activity "PadMapper :: $($c) of $($all) listings added"
    }
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
            $all = $json.listables.Count
            $c = 0
            foreach($item in $json.listables)
            {
                $p = [System.Net.WebClient]::New().DownloadString("https://padmapper.com" + $item.url)
                $j = $reg.Match($p).Groups[1].Value | ConvertFrom-Json
                $listing = [Search.Results]::new()
                if($j.entity.agents.Count -gt 0)
                {
                    $listing.EmailAddress = $j.entity.agents[0].email
                }
                $listing.Address = $item.address + ", " + $item.city + ", " + $item.state + " " + $item.zipcode
                $listing.Baths_max = $item.max_bathrooms
                $listing.Baths_min = $item.min_bathrooms
                $listing.Beds_max = $item.max_bedrooms
                $listing.Beds_min = $item.min_bedrooms
                $listing.Latitude = $item.lat
                $listing.ImageUri = "https://img.zumpercdn.com/" + $item.image_ids[0] + "/1280x960"
                $listing.Link = "https://padmapper.com" + $item.url
                $listing.Longitude = $item.lng
                $listing.Name = $item.agent_name
                $listing.OriginPlatform = "padmapper.com"
                if(!$item.phone)
                {
                    if($j.entity.agents.Count -gt 0)
                    {
                        $listing.PhoneNumber = $j.entity.agents[0].phone
                    }
                } else {
                    $listing.PhoneNumber = $item.phone
                }
                $listing.Price_High = $item.max_price
                $listing.Price_Low = $item.min_price
                $listing.PropertyManager = $item.brokerage_name
                $all_results.resultList.Add($listing)
                $c++
                write-progress -percentComplete ($c/$all*100) -Status "$([Math]::Round(($c/$all*100),2))%" -Activity "page $($i) :: $($c) of $($all)"
            }
        }
    }
    return $all_results.resultList
}
