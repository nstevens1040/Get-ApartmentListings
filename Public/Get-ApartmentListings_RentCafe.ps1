function Get-ApartmentListings_RentCafe
{
    [cmdletbinding()]
    Param(
        [string]$City,
        [string]$State_Code
    )
    . "C:\.TEMP\BIN\Get-ApartmentListings\Public\Get-ApartmentListings_GeoCode.ps1"
    $geo = Get-ApartmentListings_GeoCode -City $City -State_Code $State_Code
    $Uri = "https://www.rentcafe.com/Search/GetSearchResults"
    $Headers = [ordered]@{
        "method"="POST"
        "authority"="www.rentcafe.com"
        "scheme"="https"
        "path"="/Search/GetSearchResults"
        "pragma"="no-cache"
        "cache-control"="no-cache"
        "sec-ch-ua"="`"Google Chrome`";v=`"89`", `"Chromium`";v=`"89`", `";Not A Brand`";v=`"99`""
        "accept"="*/*"
        "dnt"="1"
        "x-requested-with"="XMLHttpRequest"
        "sec-ch-ua-mobile"="?0"
        "user-agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36"
        "origin"="https://www.rentcafe.com"
        "sec-fetch-site"="same-origin"
        "sec-fetch-mode"="cors"
        "sec-fetch-dest"="empty"
        "referer"="https://www.rentcafe.com/apartments-for-rent/us/$($State_Code.ToLower())/$($City.ToLower())/?AmenitiesIds=c1&AmenitiesIds=c2&AmenitiesIds=c10&geopicker_type=polygontool&geopicker_output=$($geo.East)%2C$($geo.South)%2C$($geo.East)-%2C$($geo.North)%2C$($geo.West)-%2C$($geo.North)%2C$($geo.West)-%2C$($geo.South)&viewport=$($geo.West + 0.5)%2C$($geo.North + 0.5)%2C$($geo.East - 0.5)%2C$($geo.South - 0.5)&zoom=10&Beds=OneTwo&Bathrooms=OneTwo"
        "accept-encoding"="gzip, deflate"
        "accept-language"="en-US,en;q=0.9"
    }
    $ContentType = "application/x-www-form-urlencoded"
    $Body = "Location=$($City)%2C+$($State_Code)&LocationGeoId=&PreviousLocation=&PropertyType=Any&PriceMin=&PriceMax=&Beds=OneTwo&Bathrooms=OneTwo&BuildingName=&CompanyName=&PetPolicy=None&PriceCategory=Default&AmenitiesIds=c1&AmenitiesIds=c2&AmenitiesIds=c10&CurrentPage=1&CountryCode=us&SeoUrl=&PreviousSeoUrl=&CustomSeoUrl=&CustomRentalsPage=None&OrderBy=Default&zoom=10&viewport=$($geo.West + 0.5)%2C$($geo.North + 0.5)%2C$($geo.East - 0.5)%2C$($geo.South - 0.5)&geopicker_output=$($geo.East)%2C$($geo.South)%2C$($geo.East)-%2C$($geo.North)%2C$($geo.West)-%2C$($geo.North)%2C$($geo.West)-%2C$($geo.South)&geopicker_type=polygontool&__RequestVerificationToken=CfDJ8Cz7UMMoLdtLlEcngGOp0HdSqRqDtpRgE1ljhpbc3nMYBDVHfz-uK_SXJPvduOLQGjRObpLRpg4udOIN19zTxH1hBdNNXPT0hbD-naYkc20RmJeaC8atrucyV7XS1Syg2qMHyoMsT0Pki-DVLhzhml8&X-Requested-With=XMLHttpRequest"
    $r = [execute.HttpRequest]::send(
        $Uri,
        [System.Net.Http.HttpMethod]::Post,
        $Headers,
        $null,
        $ContentType,
        $body
    )
    $json = $r.ResponseText | convertFrom-Json
    $results_per_page = $JSON.result.Rentals[0].Rentals.Count
    $total_results = $JSON.result.NoOfResults
    $no_pages = $total_results / $results_per_page
    $results = @()
    $JSON.result.Rentals[0].Rentals.forEach({ $results += $_ })
    $Uri = "https://www.rentcafe.com/Search/GetPagedResults/apartments-for-rent/us/$($State_Code.ToLower())/$($City.ToLower())/"
    $Headers = [ordered]@{
        "method"="POST"
        "authority"="www.rentcafe.com"
        "scheme"="https"
        "path"="/Search/GetPagedResults/apartments-for-rent/us/$($State_Code.ToLower())/$($City.ToLower())/"
        "pragma"="no-cache"
        "cache-control"="no-cache"
        "sec-ch-ua"="`"Google Chrome`";v=`"89`", `"Chromium`";v=`"89`", `";Not A Brand`";v=`"99`""
        "accept"="*/*"
        "dnt"="1"
        "x-requested-with"="XMLHttpRequest"
        "sec-ch-ua-mobile"="?0"
        "user-agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36"
        "origin"="https://www.rentcafe.com"
        "sec-fetch-site"="same-origin"
        "sec-fetch-mode"="cors"
        "sec-fetch-dest"="empty"
        "referer"="https://www.rentcafe.com/apartments-for-rent/us/$($State_Code.ToLower())/$($City.ToLower())/?AmenitiesIds=c1&AmenitiesIds=c2&AmenitiesIds=c10&geopicker_type=polygontool&geopicker_output=$($geo.East)%2C$($geo.South)%2C$($geo.East)-%2C$($geo.North)%2C$($geo.West)-%2C$($geo.North)%2C$($geo.West)-%2C$($geo.South)&viewport=$($geo.West + 0.5)%2C$($geo.North + 0.5)%2C$($geo.East - 0.5)%2C$($geo.South - 0.5)&zoom=10&Beds=OneTwo&Bathrooms=OneTwo"
        "accept-encoding"="gzip, deflate"
        "accept-language"="en-US,en;q=0.9"
    }
    if($no_pages -gt 1){
        for($i = 2; $i -lt $no_pages; $i++){
            $Body = "Beds=OneTwo&Bathrooms=OneTwo&zoom=10&viewport=$($geo.West + 0.5)%2C$($geo.North + 0.5)%2C$($geo.East - 0.5)%2C$($geo.South - 0.5)&geopicker_output=$($geo.East)%2C$($geo.South)%2C$($geo.East)-%2C$($geo.North)%2C$($geo.West)-%2C$($geo.North)%2C$($geo.West)-%2C$($geo.South)&geopicker_type=polygontool&AmenitiesIds=c1&AmenitiesIds=c2&AmenitiesIds=c10&page=$($i)&__RequestVerificationToken=CfDJ8Cz7UMMoLdtLlEcngGOp0HdSqRqDtpRgE1ljhpbc3nMYBDVHfz-uK_SXJPvduOLQGjRObpLRpg4udOIN19zTxH1hBdNNXPT0hbD-naYkc20RmJeaC8atrucyV7XS1Syg2qMHyoMsT0Pki-DVLhzhml8&CurrentPage=$($i - 1)&SeoUrl=&CustomRentalsPage=None"
            $r = [execute.HttpRequest]::send(
                $Uri,
                [System.Net.Http.HttpMethod]::Post,
                $Headers,
                $null,
                $ContentType,
                $body
            )
            $json = $r.ResponseText | convertFrom-Json
            $JSON.result.Rentals[0].Rentals.forEach({ $results += $_ })
        }
    }
    return $results
}
