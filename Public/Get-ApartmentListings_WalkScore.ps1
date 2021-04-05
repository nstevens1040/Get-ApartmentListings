function Get-ApartmentListings_WalkScore
{
    [cmdletbinding()]
    Param(
        [string]$City,
        [string]$State_Code
    )
    Add-Type -TypeDefinition "`nusing System;`nusing System.Collections.Generic;`nnamespace WalkScore`n{`n    public class Listing`n    {`n        public Double Latitude`n        {`n            get;`n            set;`n        }`n        public Double Longitude`n        {`n            get;`n            set;`n        }`n        public Int32 Beds_Low`n        {`n            get;`n            set;`n        }`n        public Int32 Beds_High`n        {`n            get;`n            set;`n        }`n        public Int32 Price_Low`n        {`n            get;`n            set;`n        }`n        public Int32 Price_High`n        {`n            get;`n            set;`n        }`n        public DateTime Datelisted`n        {`n            get;`n            set;`n        }`n        public string Link`n        {`n            get;`n            set;`n        }`n        public string ImageUri`n        {`n            get;`n            set;`n        }`n        public string Address`n        {`n            get;`n            set;`n        }`n        public string Beds`n        {`n            get;`n            set;`n        }`n        public string Price`n        {`n            get;`n            set;`n        }`n    }`n    public class Custom`n    {`n        public static List<Listing> CreateList()`n        {`n            List<Listing> collection = new List<Listing>();`n            return collection;`n        }`n    }`n}"
    $geo = Get-ApartmentListings_GeoCode -City "$($City)" -State_Code "$($State_Code)"
    $q = [ordered]@{
        "zoom"="12"
        "sort"="14_low"
        "filters"="7=0:100&4_1=0:1000000&4=0:2450&3=1:2&21_1=1&21_4=1&21_2=1&11=1&8=0&9=0&hidden=0&18=0&0_S8=0"
        "hood"="off"
        "overlay"="walkability"
        "nearby"="{}"
        "hiddenids"=""
        "lat"="$($geo.Latitude)"
        "lng"="$($geo.Longitude)"
        "rentsale"="2"
        "sw"="$($geo.SouthWest)"
        "ne"="$($geo.NorthEast)"
    }
    $qString = @($q.Keys.ForEach({"$([Uri]::EscapeDataString("$($_)"))=$([Uri]::EscapeDataString("$($q[$_])"))"})) -join '&'
    $qUri = "https://www.walkscore.com/apartments/search/$($City)-$($state_Code)/?" + $qString
    $b = [ordered]@{
        "query"="$($qUri)"
        "max"="6000"
        "new_fps"="true"
        "full"="true"
    }
    $body = @($b.Keys.ForEach({"$([Uri]::EscapeDataString("$($_)"))=$([Uri]::EscapeDataString("$($b[$_])"))"})) -join '&'
    $Uri = "https://www.walkscore.com/rentals"
    $Headers = [ordered]@{
        "Pragma"="no-cache"
        "Cache-Control"="no-cache"
        "sec-ch-ua"="`"Google Chrome`";v=`"89`", `"Chromium`";v=`"89`", `";Not A Brand`";v=`"99`""
        "Accept"="application/json, text/javascript, */*; q=0.01"
        "DNT"="1"
        "X-Requested-With"="XMLHttpRequest"
        "sec-ch-ua-mobile"="?0"
        "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36"
        "Origin"="https://www.walkscore.com"
        "Sec-Fetch-Site"="same-origin"
        "Sec-Fetch-Mode"="cors"
        "Sec-Fetch-Dest"="empty"
        "Referer"="https://www.walkscore.com/apartments/search/$($state_Code)/$($city)"
        "Accept-Encoding"="gzip, deflate"
        "Accept-Language"="en-US,en;q=0.9"
    }
    $ContentType = "application/x-www-form-urlencoded"
    $r = [Execute.HttpRequest]::Send(
        $Uri,
        [System.Net.Http.HttpMethod]::Post,
        $Headers,
        $null,
        $ContentType,
        $Body
    )
    $json = $r.ResponseText | ConvertFrom-Json
    $collection = [WalkScore.Custom]::CreateList()
    $i = 0
    $all = $json.Results.Count - 1
    foreach($listing in $JSON.results)
    {
        $item = [WalkScore.Listing]::New()
        $item.Address = $listing[16]
        $item.Beds = $listing[22][0]
        $item.Beds_High = $listing[3][-1]
        $item.Beds_Low = $listing[3][0]
        $item.Datelisted = [datetime]::Parse("1970-01-01").addSeconds($listing[5]).ToLocalTIme()
        $item.ImageUri = $listing[11]
        $item.Latitude = $listing[1]
        $item.Longitude = $listing[2]
        $item.Price = $listing[22][2]
        $item.Price_High = $listing[4][-1]
        $item.Price_Low = $listing[4][0]
        $item.Link = "https://www.walkscore.com/score/" + $listing[10]
        $collection.Add($item)
        $i++
        write-progress -PercentComplete ($i/$all*100) -Status "$([Math]::Round(($i/$all*100),2))%" -Activity "$($i) of $($all) listings collected"
    }
    return $collection
}
