#  "cookie"="__cfduid=de9f7ce785f455cfa35cc989958ab85441617296870; currentCountry=usa; .AspNetCore.Antiforgery.Z-QtVDMCKbE=CfDJ8Cz7UMMoLdtLlEcngGOp0HcMFo2o0On4f5Kc6-Y6lOZdsmJoA2jI3_rZGmDAUNoU5Ly1NFXAje2tFXEIAEbuNCAoOXWqv1IIHQZ7zuy_UxI_0n7RBGvooMeZvKfxrwiLQ5lLXVMA4QJSrYmcBq45Xco; _gcl_au=1.1.1474236522.1617296877; _ga=GA1.2.437213789.1617296877; yTrackUser=BOLHZRT0VSFKTWZ1GIQ7DP7296877205; yTrackVisit=0TGEISMWWFHPN25IH68SGY7296877234; MarketTrends_RentRanges=graph; _yTrackUser=MTExNjQ5ODY3MSM0OTY2NTgyMzU%253d-gYMwGJ1piIo%253d; _fbp=fb.1.1617296879502.390651108; _hjTLDTest=1; _hjid=bcf85fce-2eee-4403-860a-69cc66cf4e40; _omappvp=XusqqxGQU1ZZKrBMIV7rZiYMOCrRxadqS2FlINUYoiBvg8yCXiiEqrza8OGgxo85DhyG4PxrOtLIOPOIBsSax9QoPHUni0oh; _bs=b8e21a65-efe1-df4e-a65b-c1ce28658a1a; _yTrackVisit=MTk5NjY0MzQ5OCM5MjExNzQ1MDA%253d-nsURuNON3Ss%253d; ILSSaveSearchNotification=false; Bedrooms=undefined; _gat=1; _gat_ILSonlyTracker=1; trackThisPage=1617405606913"

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
    "referer"="https://www.rentcafe.com/apartments-for-rent/us/il/chicago/?AmenitiesIds=c1&AmenitiesIds=c2&AmenitiesIds=c10&geopicker_type=polygontool&geopicker_output=-87.59923790571307%2C41.86591689090929%2C-87.65416954633807%2C42.04055965320957%2C-87.74755333540057%2C42.03953974166476%2C-87.74343346235369%2C41.86182595305973&viewport=-88.27077721235369%2C41.529179879191524%2C-87.12270592329119%2C42.12250696248575&zoom=10&Beds=OneTwo&Bathrooms=OneTwo"
    "accept-encoding"="gzip, deflate"
    "accept-language"="en-US,en;q=0.9"
}
$ContentType = "application/x-www-form-urlencoded"
$Body = "Location=Chicago%2C+IL&LocationGeoId=&PreviousLocation=Chicago%2C+IL&PropertyType=Any&PriceMin=&PriceMax=&Beds=OneTwo&Bathrooms=OneTwo&BuildingName=&CompanyName=&PetPolicy=None&PriceCategory=Default&AmenitiesIds=c1&AmenitiesIds=c2&AmenitiesIds=c10&CurrentPage=1&CountryCode=us&SeoUrl=us%2Fil%2Fchicago%2F&PreviousSeoUrl=us%2Fil%2Fchicago%2F&CustomSeoUrl=&CustomRentalsPage=None&OrderBy=Default&zoom=10&viewport=-88.27077721235369%2C41.529179879191524%2C-87.12270592329119%2C42.12250696248575&geopicker_output=-87.59786461469744%2C41.86489418098591%2C-87.65554283735369%2C42.05483669595058%2C-87.74480675336932%2C42.05585636193774%2C-87.74480675336932%2C41.86080317769923&geopicker_type=polygontool&__RequestVerificationToken=CfDJ8Cz7UMMoLdtLlEcngGOp0HdSqRqDtpRgE1ljhpbc3nMYBDVHfz-uK_SXJPvduOLQGjRObpLRpg4udOIN19zTxH1hBdNNXPT0hbD-naYkc20RmJeaC8atrucyV7XS1Syg2qMHyoMsT0Pki-DVLhzhml8&X-Requested-With=XMLHttpRequest"
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
$Uri = "https://www.rentcafe.com/Search/GetPagedResults/apartments-for-rent/us/il/chicago/"
$Headers = [ordered]@{
    "method"="POST"
    "authority"="www.rentcafe.com"
    "scheme"="https"
    "path"="/Search/GetPagedResults/apartments-for-rent/us/il/chicago/"
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
    "referer"="https://www.rentcafe.com/apartments-for-rent/us/il/chicago/?AmenitiesIds=c1&AmenitiesIds=c2&AmenitiesIds=c10&geopicker_type=polygontool&geopicker_output=-87.59786461469744%2C41.86489418098591%2C-87.65554283735369%2C42.05483669595058%2C-87.74480675336932%2C42.05585636193774%2C-87.74480675336932%2C41.86080317769923&viewport=-88.27077721235369%2C41.529179879191524%2C-87.12270592329119%2C42.12250696248575&zoom=10&Beds=OneTwo&Bathrooms=OneTwo"
    "accept-encoding"="gzip, deflate"
    "accept-language"="en-US,en;q=0.9"
}
for($i = 2; $i -lt $no_pages; $i++){
    $Body = "Beds=OneTwo&Bathrooms=OneTwo&zoom=10&viewport=-88.27077721235369%2C41.529179879191524%2C-87.12270592329119%2C42.12250696248575&geopicker_output=-87.59786461469744%2C41.86489418098591%2C-87.65554283735369%2C42.05483669595058%2C-87.74480675336932%2C42.05585636193774%2C-87.74480675336932%2C41.86080317769923&geopicker_type=polygontool&AmenitiesIds=c1&AmenitiesIds=c2&AmenitiesIds=c10&page=$($i)&__RequestVerificationToken=CfDJ8Cz7UMMoLdtLlEcngGOp0HdSqRqDtpRgE1ljhpbc3nMYBDVHfz-uK_SXJPvduOLQGjRObpLRpg4udOIN19zTxH1hBdNNXPT0hbD-naYkc20RmJeaC8atrucyV7XS1Syg2qMHyoMsT0Pki-DVLhzhml8&CurrentPage=$($i - 1)&SeoUrl=us%2Fil%2Fchicago%2F&CustomRentalsPage=None"
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
$results[0]
