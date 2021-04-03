$cs = @"
using System;
using System.Collections.Generic;
namespace Apartment
{
    public class Listing
    {
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
        public string Name
        {
            get;
            set;
        }
        public string PhoneNumber
        {
            get;
            set;
        }
        public string PriceRange
        {
            get;
            set;
        }
    }
    public class ListingsObject
    {
        public static List<Listing> CreateListingArray()
        {
            List<Listing> listingCollection = new List<Listing>();
            return listingCollection;
        }
    }
}
"@
$json_id = "structuredSchemaBreadcrumb"
$price_class="price-range"
$uri = "https://www.apartmentfinder.com/Illinois/Chicago-Apartments/1-Bedroom/q/?bt=1&am=65558"
$r = [execute.httprequest]::Send(
    $uri,
    [System.Net.http.HttpMethod]::Get
)

$next_page = @($r.HtmlDocument.getElementsByTagName("link")).Where({$_.GetAttribute("rel") -eq "next"})[0].href
$json = $r.HtmlDocument.getElementById($json_id)|% innerHtml | convertfrom-Json
Add-Type -TypeDefinition $cs
$results = [Apartment.ListingsObject]::CreateListingArray()
$page = 1
for($i = 0; $i -lt $json.about.count; $i++){
    if($i -gt 0){
        write-progress -PercentComplete ($i/($json.about.Count - 1)*100) -Status "$([math]::Round(($i/($json.about.Count - 1)*100),2))%" -Activity "page $($page) :: $($i) of $($json.about.Count - 1)"
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
    $p = [System.Net.WebClient]::New().DownloadString($item.url)
    $low = [regex]::new("class=`"$($price_class)(.*)(\n)(.*)(\`$([0-9]|,)*)\s-\s(\`$([0-9]|,)*)(\s*)").Match($p).Groups[4].value
    $high = [regex]::new("class=`"$($price_class)(.*)(\n)(.*)(\`$([0-9]|,)*)\s-\s(\`$([0-9]|,)*)(\s*)").Match($p).Groups[6].value
    $listing.PriceRange = "$($low) - $($high)"
    $results.Add($listing)
}
$page = 2
while(![string]::IsNullOrEmpty(@($r.HtmlDocument.getElementsByTagName("link")).Where({$_.GetAttribute("rel") -eq "next"})[0].href))
{
    $r = [execute.httprequest]::Send(
        $next_page,
        [System.Net.http.HttpMethod]::Get
    )
    $next_page = @($r.HtmlDocument.getElementsByTagName("link")).Where({$_.GetAttribute("rel") -eq "next"})[0].href
    $json = $r.HtmlDocument.getElementById($json_id)|% innerHtml | convertfrom-Json
    for($i = 0; $i -lt $json.about.count; $i++){
        if($i -gt 0){
            write-progress -PercentComplete ($i/($json.about.Count - 1)*100) -Status "$([math]::Round(($i/($json.about.Count - 1)*100),2))%" -Activity "page $($page) :: $($i) of $($json.about.Count - 1)"
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
        $p = [System.Net.WebClient]::New().DownloadString($item.url)
        $low = [regex]::new("class=`"$($price_class)(.*)(\n)(.*)(\`$([0-9]|,)*)\s-\s(\`$([0-9]|,)*)(\s*)").Match($p).Groups[4].value
        $high = [regex]::new("class=`"$($price_class)(.*)(\n)(.*)(\`$([0-9]|,)*)\s-\s(\`$([0-9]|,)*)(\s*)").Match($p).Groups[6].value
        $listing.PriceRange = "$($low) - $($high)"
        $results.Add($listing)
    }
    $page++
}
$results