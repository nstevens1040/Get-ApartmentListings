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

$uri = "https://www.forrent.com/find/IL/metro-Chicago/Chicago/beds-1/baths-1/extras-Air+Conditioning-Dishwasher-Washer+Dryer+In+Unit"
$r = [Execute.HttpRequest]::Send($uri)
$json = [regex]::new("<script type=`"application/ld\+json`">(\{.*\})</script>(\s*)</div>(\s*)</fr-schema-org>").Match([regex]::new("`n").Replace($r.ResponseText,[string]::Empty)).Groups[1].Value | ConvertFrom-Json 


$next_page = @($r.HtmlDocument.getElementsByTagName("link")).Where({$_.GetAttribute("rel") -eq "next"})[0].href
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
    $ej = [regex]::new("<script type=`"application/ld\+json`">(\{.*\})</script></div></fr-schema-org>").Match([regex]::new("`n").Replace($p,[string]::Empty)).groups[1].Value | ConvertFrom-Json
    if($ej.about.offers.lowPrice -eq $ej.about.offers.highPrice){
        $listing.PriceRange = "`$$($ej.about.offers.lowPrice)"
    } else {
        $listing.PriceRange = "`$$($ej.about.offers.lowPrice) - `$$($ej.about.offers.highPrice)"
    }
    $results.Add($listing)
}
$page = 2
while(![string]::IsNullOrEmpty([regex]::new("<link rel=`"next`" href=`"(.*)`"><style ng-transition=`"frc`">").Match([regex]::new("`n").Replace($r.ResponseText,[string]::Empty)).Groups[1].Value))
{
    $r = [execute.httprequest]::Send($next_page)
    $next_page = [regex]::new("<link rel=`"next`" href=`"(.*)`"><style ng-transition=`"frc`">").Match([regex]::new("`n").Replace($r.ResponseText,[string]::Empty)).Groups[1].Value
    $json = [regex]::new("<script type=`"application/ld\+json`">(\{.*\})</script>(\s*)</div>(\s*)</fr-schema-org>").Match([regex]::new("`n").Replace($r.ResponseText,[string]::Empty)).Groups[1].Value | ConvertFrom-Json 
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
        $ej = [regex]::new("<script type=`"application/ld\+json`">(\{.*\})</script></div></fr-schema-org>").Match([regex]::new("`n").Replace($p,[string]::Empty)).groups[1].Value | ConvertFrom-Json
        if($ej.about.offers.lowPrice -eq $ej.about.offers.highPrice){
            $listing.PriceRange = "`$$($ej.about.offers.lowPrice)"
        } else {
            $listing.PriceRange = "`$$($ej.about.offers.lowPrice) - `$$($ej.about.offers.highPrice)"
        }
        $results.Add($listing)
    }
    $page++
}
$results[0]
