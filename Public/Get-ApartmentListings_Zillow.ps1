
$uri = "https://www.zillow.com/search/GetSearchPageState.htm?searchQueryState=%7B%22pagination%22%3A%7B%7D%2C%22usersSearchTerm%22%3A%2260660%22%2C%22mapBounds%22%3A%7B%22west%22%3A-87.96038056835937%2C%22east%22%3A-87.42067719921874%2C%22south%22%3A41.79910845381241%2C%22north%22%3A42.09908397007359%7D%2C%22mapZoom%22%3A11%2C%22isMapVisible%22%3Atrue%2C%22filterState%22%3A%7B%22beds%22%3A%7B%22min%22%3A1%7D%2C%22baths%22%3A%7B%22min%22%3A1%7D%2C%22isPreMarketForeclosure%22%3A%7B%22value%22%3Afalse%7D%2C%22isForSaleForeclosure%22%3A%7B%22value%22%3Afalse%7D%2C%22onlyRentalInUnitLaundry%22%3A%7B%22value%22%3Atrue%7D%2C%22hasAirConditioning%22%3A%7B%22value%22%3Atrue%7D%2C%22isAllHomes%22%3A%7B%22value%22%3Atrue%7D%2C%22isAuction%22%3A%7B%22value%22%3Afalse%7D%2C%22isNewConstruction%22%3A%7B%22value%22%3Afalse%7D%2C%22isForRent%22%3A%7B%22value%22%3Atrue%7D%2C%22isLotLand%22%3A%7B%22value%22%3Afalse%7D%2C%22isManufactured%22%3A%7B%22value%22%3Afalse%7D%2C%22isForSaleByOwner%22%3A%7B%22value%22%3Afalse%7D%2C%22isComingSoon%22%3A%7B%22value%22%3Afalse%7D%2C%22onlyRentalParkingAvailable%22%3A%7B%22value%22%3Atrue%7D%2C%22isPreMarketPreForeclosure%22%3A%7B%22value%22%3Afalse%7D%2C%22isForSaleByAgent%22%3A%7B%22value%22%3Afalse%7D%7D%2C%22isListVisible%22%3Atrue%7D&wants={%22cat1%22:[%22mapResults%22]}&requestId=2"
$Headers = [ordered]@{
    "method"="GET"
    "authority"="www.zillow.com"
    "scheme"="https"
    "path"="/search/GetSearchPageState.htm?searchQueryState=%7B%22pagination%22%3A%7B%7D%2C%22usersSearchTerm%22%3A%2260660%22%2C%22mapBounds%22%3A%7B%22west%22%3A-87.96038056835937%2C%22east%22%3A-87.42067719921874%2C%22south%22%3A41.79910845381241%2C%22north%22%3A42.09908397007359%7D%2C%22mapZoom%22%3A11%2C%22isMapVisible%22%3Atrue%2C%22filterState%22%3A%7B%22beds%22%3A%7B%22min%22%3A1%7D%2C%22baths%22%3A%7B%22min%22%3A1%7D%2C%22isPreMarketForeclosure%22%3A%7B%22value%22%3Afalse%7D%2C%22isForSaleForeclosure%22%3A%7B%22value%22%3Afalse%7D%2C%22onlyRentalInUnitLaundry%22%3A%7B%22value%22%3Atrue%7D%2C%22hasAirConditioning%22%3A%7B%22value%22%3Atrue%7D%2C%22isAllHomes%22%3A%7B%22value%22%3Atrue%7D%2C%22isAuction%22%3A%7B%22value%22%3Afalse%7D%2C%22isNewConstruction%22%3A%7B%22value%22%3Afalse%7D%2C%22isForRent%22%3A%7B%22value%22%3Atrue%7D%2C%22isLotLand%22%3A%7B%22value%22%3Afalse%7D%2C%22isManufactured%22%3A%7B%22value%22%3Afalse%7D%2C%22isForSaleByOwner%22%3A%7B%22value%22%3Afalse%7D%2C%22isComingSoon%22%3A%7B%22value%22%3Afalse%7D%2C%22onlyRentalParkingAvailable%22%3A%7B%22value%22%3Atrue%7D%2C%22isPreMarketPreForeclosure%22%3A%7B%22value%22%3Afalse%7D%2C%22isForSaleByAgent%22%3A%7B%22value%22%3Afalse%7D%7D%2C%22isListVisible%22%3Atrue%7D&wants={%22cat1%22:[%22mapResults%22]}&requestId=2"
    "pragma"="no-cache"
    "cache-control"="no-cache"
    "sec-ch-ua"="`"Google Chrome`";v=`"89`", `"Chromium`";v=`"89`", `";Not A Brand`";v=`"99`""
    "dnt"="1"
    "sec-ch-ua-mobile"="?0"
    "user-agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36"
    "accept"="*/*"
    "sec-fetch-site"="same-origin"
    "sec-fetch-mode"="cors"
    "sec-fetch-dest"="empty"
    "referer"="https://www.zillow.com/homes/for_rent/1-_beds/1.0-_baths/?searchQueryState=%7B%22pagination%22%3A%7B%7D%2C%22usersSearchTerm%22%3A%2260660%22%2C%22mapBounds%22%3A%7B%22west%22%3A-87.82545472607421%2C%22east%22%3A-87.5556030415039%2C%22south%22%3A41.87423465813818%2C%22north%22%3A42.024222440957125%7D%2C%22mapZoom%22%3A12%2C%22isMapVisible%22%3Atrue%2C%22filterState%22%3A%7B%22beds%22%3A%7B%22min%22%3A1%7D%2C%22baths%22%3A%7B%22min%22%3A1%7D%2C%22pmf%22%3A%7B%22value%22%3Afalse%7D%2C%22fore%22%3A%7B%22value%22%3Afalse%7D%2C%22lau%22%3A%7B%22value%22%3Atrue%7D%2C%22ac%22%3A%7B%22value%22%3Atrue%7D%2C%22ah%22%3A%7B%22value%22%3Atrue%7D%2C%22auc%22%3A%7B%22value%22%3Afalse%7D%2C%22nc%22%3A%7B%22value%22%3Afalse%7D%2C%22fr%22%3A%7B%22value%22%3Atrue%7D%2C%22land%22%3A%7B%22value%22%3Afalse%7D%2C%22manu%22%3A%7B%22value%22%3Afalse%7D%2C%22fsbo%22%3A%7B%22value%22%3Afalse%7D%2C%22cmsn%22%3A%7B%22value%22%3Afalse%7D%2C%22parka%22%3A%7B%22value%22%3Atrue%7D%2C%22pf%22%3A%7B%22value%22%3Afalse%7D%2C%22fsba%22%3A%7B%22value%22%3Afalse%7D%7D%2C%22isListVisible%22%3Atrue%7D"
    "accept-encoding"="gzip, deflate"
    "accept-language"="en-US,en;q=0.9"
}
$r = [execute.httprequest]::Send(
    $uri,
    [System.Net.Http.HttpMethod]::Get,
    $headers
)
$results = $r.responseText | Convertfrom-Json
