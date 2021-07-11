function Get-ApartmentListings_ForRent
{
    [cmdletbinding()]
    Param(
        [string]$City,
        [string]$State_Code
    )
    $Uri = "https://www.forrent.com/bff/link/breadcrumb/search?url=%2Ffind%2F$($State_Code)%2Fmetro-$($City)%2F$($City)&locale=en"
    $Headers = [ordered]@{
        "method"="GET"
        "authority"="www.forrent.com"
        "scheme"="https"
        "path"="/bff/link/breadcrumb/search?url=%2Ffind%2F$($State_Code)%2Fmetro-$($City)%2F$($City)&locale=en"
        "pragma"="no-cache"
        "cache-control"="no-cache"
        "sec-ch-ua"="`"Google Chrome`";v=`"89`", `"Chromium`";v=`"89`", `";Not A Brand`";v=`"99`""
        "accept"="application/json, text/plain, */*"
        "dnt"="1"
        "sec-ch-ua-mobile"="?0"
        "user-agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36"
        "sec-fetch-site"="same-origin"
        "sec-fetch-mode"="cors"
        "sec-fetch-dest"="empty"
        "referer"="https://www.forrent.com/find/$($State_Code)/metro-$($City)/$($City)"
        "accept-encoding"="gzip, deflate"
        "accept-language"="en-US,en;q=0.9"
    }
    $ContentType = "application/json"
    $r = [Execute.httpRequest]::Send(
        $Uri,
        [system.net.Http.HttpMethod]::Get,
        $Headers,
        $null,
        $ContentType
    )
    $searchUri = "https://www.forrent.com" + ($r.ResponseText | convertFrom-Json).data.Where({$_.Type.ToString().ToLower().Equals("city")})[0].url
    $Uri = $searchUri + "/beds-1/baths-1/extras-Air+Conditioning-Dishwasher-Washer+Dryer+In+Unit"
    $Headers = [ordered]@{
        "method"="GET"
        "authority"="www.forrent.com"
        "scheme"="https"
        "pragma"="no-cache"
        "cache-control"="no-cache"
        "sec-ch-ua"="`"Google Chrome`";v=`"89`", `"Chromium`";v=`"89`", `";Not A Brand`";v=`"99`""
        "sec-ch-ua-mobile"="?0"
        "dnt"="1"
        "upgrade-insecure-requests"="1"
        "user-agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36"
        "accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
        "sec-fetch-site"="same-origin"
        "sec-fetch-mode"="navigate"
        "sec-fetch-user"="?1"
        "sec-fetch-dest"="document"
        "accept-encoding"="gzip, deflate"
        "accept-language"="en-US,en;q=0.9"
    }
    $r = [Execute.httpRequest]::Send(
        $Uri,
        [system.Net.http.HttpMethod]::Get,
        $Headers
    )
    $json = [regex]::new("<script type=`"application/ld\+json`">(\{.*\})</script>(\s*)</div>(\s*)</fr-schema-org>").Match([regex]::new("`n").Replace($r.ResponseText,[string]::Empty)).Groups[1].Value | ConvertFrom-Json 
    $next_page = @($r.HtmlDocument.getElementsByTagName("link")).Where({$_.GetAttribute("rel") -eq "next"})[0].href
    @(
        "$($PWD.Path)\lib\Newtonsoft.Json.dll",
        "C:\Windows\Microsoft.Net\assembly\GAC_MSIL\Microsoft.CSharp\v4.0_4.0.0.0__b03f5f7f11d50a3a\Microsoft.CSharp.dll"
     ).forEach({ Add-Type -Path $_ })
    Add-Type -ReferencedAssemblies @(
        "$($PWD.Path)\lib\Newtonsoft.Json.dll",
        "C:\Windows\Microsoft.Net\assembly\GAC_MSIL\Microsoft.CSharp\v4.0_4.0.0.0__b03f5f7f11d50a3a\Microsoft.CSharp.dll"
    ) -TypeDefinition "using System;`nusing System.Net;`nusing System.Threading.Tasks;`nusing System.Text.RegularExpressions;`nusing System.Collections.Generic;`nusing System.Linq;`nusing Newtonsoft.Json;`nnamespace Apartment`n{`n    public class Listing`n    {`n        public Double Latitude`n        {`n            get;`n            set;`n        }`n        public Double Longitude`n        {`n            get;`n            set;`n        }`n        public string Link`n        {`n            get;`n            set;`n        }`n        public string ImageUri`n        {`n            get;`n            set;`n        }`n        public string Address`n        {`n            get;`n            set;`n        }`n        public string Name`n        {`n            get;`n            set;`n        }`n        public string PhoneNumber`n        {`n            get;`n            set;`n        }`n        public Int32 Price_low`n        {`n            get;`n            set;`n        }`n        public Int32 Price_high`n        {`n            get;`n            set;`n        }`n        public Int32 Beds_low`n        {`n            get;`n            set;`n        }`n        public Int32 Beds_high`n        {`n            get;`n            set;`n        }`n        public Double Baths_low`n        {`n            get;`n            set;`n        }`n        public Double Baths_high`n        {`n            get;`n            set;`n        }`n        public string PriceRange`n        {`n            get;`n            set;`n        }`n    }`n    public class ListingsObject`n    {`n        public List<Listing> ListingCollection = new List<Listing>();`n    }`n    public class Results`n    {`n        public static dynamic ConvertFromJson(string jsonData)`n        {`n            return JsonConvert.DeserializeObject<object>(jsonData);`n        }`n        public static Regex JsonReg = new Regex(@`"<script type=`"`"application/ld\+json`"`">(\{.*\})</script></div></fr-schema-org>`");`n        public static Regex LFReg = new Regex(@`"\n`");`n        private static void GetResults(ListingsObject collection, Listing listing, string uri)`n        {`n            string p = new WebClient().DownloadString(uri);`n            string meta_lat = p.Split((Char)62).ToList().Where(i=>{ return (i.Contains(@`"place:location:latitude`")|i.Contains(@`"place:location:longitude`")); }).FirstOrDefault();`n            string meta_lng = p.Split((Char)62).ToList().Where(i=>{ return (i.Contains(@`"place:location:latitude`")|i.Contains(@`"place:location:longitude`")); }).ToList()[1];`n            Double latitude = Convert.ToDouble(new Regex(@`"([0-9\.]+)`").Match(meta_lat).Groups[1].Value);`n            Double longitude = Convert.ToDouble(new Regex(@`"(-[0-9\.]+)`").Match(meta_lng).Groups[1].Value);`n            listing.Latitude = latitude;`n            listing.Longitude = longitude;`n            string beds = p.Split((Char)60).Where(i=>{ return (i.Contains(@`"table-data hide-mobile border-left`") & i.Contains(@`"Beds`")); }).FirstOrDefault().Split((Char)62).Last();`n            string baths = p.Split((Char)60).Where(i=>{ return (i.Contains(@`"table-data hide-mobile border-left`") & i.Contains(@`"Baths`")); }).FirstOrDefault().Split((Char)62).Last();`n            Int32 beds_low = Convert.ToInt32(new Regex(@`"(\d+)\s*-\s*(\d+)`").Match(beds).Groups[1].Value);`n            Int32 beds_high = Convert.ToInt32(new Regex(@`"(\d+)\s*-\s*(\d+)`").Match(beds).Groups[2].Value);`n            Double baths_low = Convert.ToDouble(new Regex(@`"([0-9\.]+)\s*-\s*([0-9\.]+)`").Match(baths).Groups[1].Value);`n            Double baths_high = Convert.ToDouble(new Regex(@`"([0-9\.]+)\s*-\s*([0-9\.]+)`").Match(baths).Groups[2].Value);`n            listing.Beds_low = beds_low;`n            listing.Beds_high = beds_high;`n            listing.Baths_low = baths_low;`n            listing.Baths_high = baths_high;`n            string jsonString = Results.JsonReg.Match(Results.LFReg.Replace(p, String.Empty)).Groups[1].Value;`n            dynamic json = ConvertFromJson(jsonString);`n            string low = json[`"about`"][`"offers`"][`"lowPrice`"];`n            string high = json[`"about`"][`"offers`"][`"highPrice`"];`n            if(!String.IsNullOrEmpty(low))`n            {`n                listing.Price_low = Convert.ToInt32(low);`n            }`n            if(!String.IsNullOrEmpty(high))`n            {`n                listing.Price_high = Convert.ToInt32(high);`n            }`n            string[] uris = new string[collection.ListingCollection.Count];`n            for(Int32 i = 0; i < uris.Length; i++)`n            {`n                uris[i] = collection.ListingCollection[i].Link;`n            }`n            if (!uris.Contains(listing.Link))`n            {`n                collection.ListingCollection.Add(listing);`n            }`n        }`n        public static async Task AddResult(ListingsObject collection, Listing listing, string uri)`n        {`n            await Task.Factory.StartNew(() =>`n            {`n                GetResults(collection, listing, uri);`n            }, TaskCreationOptions.None);`n        }`n    }`n}`n"
    $results = [Apartment.ListingsObject]::New()
    $page = 1
    $tasks = @()
    for($i = 0; $i -lt $json.about.count; $i++){
        if($i -gt 0){
            write-progress -PercentComplete ($i/($json.about.Count - 1)*100) -Status "$([math]::Round(($i/($json.about.Count - 1)*100),2))%" -Activity "ForRent :: page $($page) :: $($i) of $($json.about.Count - 1)"
        }
        $item = $json.about[$i]
        $listing = [Apartment.Listing]::new()
        $listing.Link = $item.url
        $listing.ImageUri  = $item.image
        $item.address | select streetAddress,addressLocality,addressRegion,postalCode | % {
            $listing.Address = "$($_ | % streetAddress), $($_ |% addressLocality), $($_ |% addressRegion) $($_ |% postalCode)"
        }
        $listing.Name = $item.name
        $listing.PhoneNumber = $item.telephone
        $tasks += [Apartment.Results]::AddResult($results,$listing,$item.url)
    }
    $page = 2
    while(![string]::IsNullOrEmpty([regex]::new("<link rel=`"next`" href=`"(.*)`"><style ng-transition=`"frc`">").Match([regex]::new("`n").Replace($r.ResponseText,[string]::Empty)).Groups[1].Value))
    {
        $r = [execute.httprequest]::Send($next_page)
        $next_page = [regex]::new("<link rel=`"next`" href=`"(.*)`"><style ng-transition=`"frc`">").Match([regex]::new("`n").Replace($r.ResponseText,[string]::Empty)).Groups[1].Value
        $json = [regex]::new("<script type=`"application/ld\+json`">(\{.*\})</script>(\s*)</div>(\s*)</fr-schema-org>").Match([regex]::new("`n").Replace($r.ResponseText,[string]::Empty)).Groups[1].Value | ConvertFrom-Json 
        for($i = 0; $i -lt $json.about.count; $i++){
            if($i -gt 0){
                write-progress -PercentComplete ($i/($json.about.Count - 1)*100) -Status "$([math]::Round(($i/($json.about.Count - 1)*100),2))%" -Activity "ForRent :: page $($page) :: $($i) of $($json.about.Count - 1)"
            }
            $item = $json.about[$i]
            $listing = [Apartment.Listing]::new()
            $listing.ImageUri  = $item.image
            $listing.Link = $item.url
            $item.address | select streetAddress,addressLocality,addressRegion,postalCode | % {
                $listing.Address = "$($_ | % streetAddress), $($_ |% addressLocality), $($_ |% addressRegion) $($_ |% postalCode)"
            }
            $listing.Name = $item.name
            $listing.PhoneNumber = $item.telephone
            $tasks += [Apartment.Results]::AddResult($results,$listing,$item.url)
        }
        $page++
    }
    $completed = $tasks.Where({$_.IsCompleted}).Count
    $all = $tasks.count
    while($tasks.Where({!$_.IsCompleted}).Count -ne 0)
    {
        $completed = $tasks.Where({$_.IsCompleted}).Count
        Write-Progress -PercentComplete ($completed/$all*100) -Status "$([Math]::Round(($completed/$all*100),2))%" -Activity "$($completed) tasks completed of $($all)"
    }
    return $results.ListingCollection
}