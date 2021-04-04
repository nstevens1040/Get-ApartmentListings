Function Get-ApartmentListings_ApartmentSearch
{
    [cmdletbinding()]
    Param(
        [string]$City,
        [string]$State_Code
    )
    if(!("Execute.HttpRequest" -as [type]))
    {
        Add-Type -Path ..\lib\Execute.HttpRequest.dll
    }
    $geo = Get-ApartmentListings_GeoCode -City $City -State_Code $State_Code
    $Uri = "https://www.apartmentsearch.com/PropertySearch/GetSearchResults"
    $Headers = [ordered]@{
        "Pragma"="no-cache"
        "Cache-Control"="no-cache"
        "sec-ch-ua"="`"Google Chrome`";v=`"89`", `"Chromium`";v=`"89`", `";Not A Brand`";v=`"99`""
        "Accept"="application/json, text/javascript, */*; q=0.01"
        "DNT"="1"
        "X-Requested-With"="XMLHttpRequest"
        "sec-ch-ua-mobile"="?0"
        "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36"
        "Origin"="https://www.apartmentsearch.com"
        "Sec-Fetch-Site"="same-origin"
        "Sec-Fetch-Mode"="cors"
        "Sec-Fetch-Dest"="empty"
        "Referer"="https://www.apartmentsearch.com/apartments"
        "Accept-Encoding"="gzip, deflate"
        "Accept-Language"="en-US,en;q=0.9"
    }
    $ContentType = "application/json"
    $Body = "{`"customerID`":`"`",`"latne`":$($geo.North),`"lngne`":$($geo.East),`"latsw`":$($geo.South),`"lngsw`":$($geo.West),`"minBeds`":null,`"maxBeds`":null,`"minRent`":null,`"maxRent`":null,`"shortTerm`":false,`"military`":false,`"student`":false,`"pageID`":1,`"pageSize`":10,`"furnitureInterest`":false,`"dogsOK`":false,`"catsOK`":false,`"amenities`":[],`"sort`":null}"
    $r = [Execute.HttpRequest]::Send(
        $Uri,
        [System.Net.http.HttpMethod]::Post,
        $Headers,
        $null,
        $ContentType,
        $Body
    )
    return $r.ResponseText | ConvertFrom-Json
}


