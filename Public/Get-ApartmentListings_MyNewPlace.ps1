Add-Type -Path ..\lib\Execute.HttpRequest.dll
Add-Type -TypeDefinition @"
using System;
using System.Collections.Generic;
namespace MyNewPlace
{
    public class Listing
    {
        public string Address
        {
            get;
            set;
        }
        public string PhoneNumber
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
        public Int32 Beds_High
        {
            get;
            set;
        }
        public Int32 Beds_Low
        {
            get;
            set;
        }
        public Double Baths_High
        {
            get;
            set;
        }
        public Double Baths_Low
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
        public string Title
        {
            get;
            set;
        }
    }
    public class Collection
    {
        public static List<Listing> CreateList()
        {
            List<Listing> collection = new List<Listing>();
            return collection;
        }
    }
}
"@
$uri = "https://www.mynewplace.com/apartments-for-rent/60660/beds:1/baths:1/"
$r = [Execute.HttpRequest]::Send($uri)
$listings = $r.HtmlDocument.getElementById("listings").children
$collection = [MyNewPlace.Collection]::CreateList()
foreach($listing in $listings)
{
    $item = [MyNewPlace.Listing]::new()
    $price = "$($listing.getElementsByTagName("p")[0].innerText.Split("`n")[0] -replace "\`$",'' -replace ",",'')"
    $baths = [regex]::new("<i>(.*)</i>").Match("$($listing.getElementsByTagName("p")|% outerHtml)").Groups[1].value.split('>')[-1]
    $beds = [regex]::new("<i>(.*)</i>").Match("$($listing.getElementsByTagName("p")|% outerHtml)").Groups[1].value.split('<')[0]
    if($price.Split(' ').Count -gt 1 -and $price.Trim().ToLower() -ne 'please call')
    {
        $item.Price_Low = [System.Convert]::ToInt32([regex]::New("^(\d*)").Match($price).Groups[1].Value)
        $item.Price_High = [System.Convert]::ToInt32([regex]::New("\s*(\d*)").Match($price).Groups[1].Value)
    } else {
        if($price.Trim().ToLower() -ne 'please call')
        {
            $item.Price_Low =  [System.Convert]::ToInt32($price)
            $item.Price_High = [System.Convert]::ToInt32($price)
        }
    }
    if($baths.Split(' ').Count -gt 1)
    {
        $item.Baths_Low = [System.Convert]::ToInt32([regex]::New("^(\d*)").Match($Baths).Groups[1].Value)
        $item.Baths_High = [System.Convert]::ToInt32([regex]::New("\s*(\d*)").Match($baths).Groups[1].Value)
    } else {
        $item.Baths_Low =  [System.Convert]::ToInt32($baths)
        $item.Baths_High = [System.Convert]::ToInt32($Baths)
    }
    if($beds.Split(' ').Count -gt 1)
    {
        $item.Beds_Low = [System.Convert]::ToInt32([regex]::New("^(\d*)").Match($Beds).Groups[1].Value)
        $item.Beds_High = [System.Convert]::ToInt32([regex]::New("\s*(\d*)").Match($Beds).Groups[1].Value)
    } else {
        $item.Beds_Low =  [System.Convert]::ToInt32($Beds)
        $item.Beds_High = [System.Convert]::ToInt32($Beds)
    }
    $item.Title = $listing.getElementsByTagName("h2")|% innerText
    $item.Address = $listing.innerText.split("`n")[-1].split('(')[0]
    $item.ImageUri = $listing.getElementsByTagName("img")[0].GetAttribute("data-src")
    $item.Latitude = [System.Convert]::ToDouble($listing.getAttribute("data-lat"))
    $item.Link = "$($listing.href -replace "^about:","https://mynewplace.com")"
    $item.Longitude = [System.Convert]::ToDouble($listing.getAttribute("data-lng"))
    $item.PhoneNumber = $listing.getElementsByTagName("b")|% innerText
    $collection.Add($item)
}
$collection[0]

<#
$address = $listing.getElementsByTagName("h2")|% innerText
$phoneNumber = $listing.getElementsByTagName("b")|% innerTExt
$price = [System.Convert]::ToInt32("$($listing.getElementsByTagName("p")[0].innerText.Split("`n")[0] -replace "\`$",'' -replace ",",'')")
$beds = [System.Convert]::ToInt32([regex]::new("<i>(.*)</i>").Match(($listing.getElementsByTagName("p")|% outerHtml)).Groups[1].value.split('<')[0])
$baths = [System.Convert]::ToInt32([regex]::new("<i>(.*)</i>").Match(($listing.getElementsByTagName("p")|% outerHtml)).Groups[1].value.split('>')[-1])
$link = "$($listing.href -replace "^about:","https://mynewplace.com")"
$image = $listing.getElementsByTagName("img") |% src
$lat = [System.Convert]::ToDouble($listing.getAttribute("data-lat"))
$lng = [System.Convert]::ToDouble($listing.getAttribute("data-lng"))
#>

