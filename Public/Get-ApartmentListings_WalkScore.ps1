Add-Type -TypeDefinition @"
using System;
using System.Collections.Generic;
namespace WalkScore
{
    public class Listing
    {
        public Double Latitude
        {
            get;
            set;
        }
        public Double Longitude
        {
            get;
            set;
        }
        public Int32 Beds_Low
        {
            get;
            set;
        }
        public Int32 Beds_High
        {
            get;
            set;
        }
        public Int32 Price_Low
        {
            get;
            set;
        }
        public Int32 Price_High
        {
            get;
            set;
        }
        public DateTime Datelisted
        {
            get;
            set;
        }
        public string Link
        {
            get;
            set;
        }
        public string ImageUri
        {
            get;
            set;
        }
        public string Address
        {
            get;
            set;
        }
        public string Beds
        {
            get;
            set;
        }
        public string Price
        {
            get;
            set;
        }
    }
    public class Custom
    {
        public static List<Listing> CreateList()
        {
            List<Listing> collection = new List<Listing>();
            return collection;
        }
    }
}
"@

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
    "Referer"="https://www.walkscore.com/apartments/search/IL/Chicago"
    "Accept-Encoding"="gzip, deflate"
    "Accept-Language"="en-US,en;q=0.9"
}
$ContentType = "application/x-www-form-urlencoded"
#$Body = "query=https%3A%2F%2Fwww.walkscore.com%2Fapartments%2Fsearch%2FChicago-IL%3Fzoom%3D12%26sort%3D14_low%26filters%3D7%253D0%253A100%25264_1%253D0%253A1000000%25264%253D0%253A2450%25263%253D1%253A2%252621_1%253D1%252621_4%253D1%252621_2%253D1%252611%253D1%25268%253D0%25269%253D0%2526hidden%253D0%252618%253D0%25260_S8%253D0%26hood%3Doff%26overlay%3Dwalkability%26nearby%3D%257B%257D%26hiddenids%3D%26lat%3D41.93747945201589%26lng%3D-87.71192249755859%26rentsale%3D2%26sw%3D41.860561020923235%252C-87.91928944091796%26ne%3D42.014305221688666%252C-87.50455555419921&max=9999&new_fps=true&full=true"
$Body = "query=https%3A%2F%2Fwww.walkscore.com%2Fapartments%2Fsearch%2FChicago-IL%3Fzoom%3D12%26sort%3D14_low%26filters%3D7%253D0%253A100%25264_1%253D0%253A1000000%25264%253D0%253A2450%25263%253D1%253A2%252621_1%253D1%252621_4%253D1%252621_2%253D1%252611%253D1%25268%253D0%25269%253D0%2526hidden%253D0%252618%253D0%25260_S8%253D0%26hood%3Doff%26overlay%3Dwalkability%26nearby%3D%257B%257D%26hiddenids%3D%26lat%3D41.93747945201589%26lng%3D-87.71192249755859%26rentsale%3D2%26sw%3D41.860561020923235%252C-87.91928944091796%26ne%3D42.014305221688666%252C-87.50455555419921&max=6000&new_fps=true&full=true"
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

<#
$lat = $listing[1]
$lng = $listing[2]
$bed_low = $listing[3][0]
$bed_high = $listing[3][-1]
$price_low = $listing[4][0]
$price_high = $listing[4][-1]
$date_listed = [datetime]::Parse("1970-01-01").addSeconds($listing[5]).ToLocalTIme()
$title = $listing[10]
$image = $listing[11]
$address = $listing[16]
$beds_string = $listing[22][0]
$price_from =  $listing[22][2]
#>
