Function Get-ApartmentListings_Zumper
{
    [cmdletbinding()]
    Param(
        [string]$City,
        [string]$State_Code
    )
    $geo = Get-ApartmentListings_Geocode -City $City -State_Code $State_Code
    $reg= [regex]::new(" window.__PRELOADED_STATE__ = (\{.*\})")
    $uri = "https://www.zumper.com/apartments-for-rent/$($city.ToLower())-$($State_Code.ToLower())/1-beds?bathrooms=1&lease-term=short,long&listing-amenities=2,14,7&box=$($geo.West),$($geo.South),$($geo.East),$($geo.North)&images"
    $r = [Execute.HttpRequest]::Send($uri)
    $json = $reg.Match($r.ResponseText).Groups[1].Value | ConvertFrom-Json
    $results = @()
    $JSON.currentSearch.listables.listables.ForEach({ $results += $_ })
    $total = $JSON.currentSearch.listables.matching
    $per_page = $JSON.currentSearch.firstPageCount
    $no_pages = [Math]::Ceiling(($total / $per_page))
    $i = 2
    while($JSON.currentSearch.hasMoreListables)
    {
        $uri = "https://www.zumper.com/apartments-for-rent/$($city.ToLower())-$($State_Code.ToLower())/1-beds?bathrooms=1&lease-term=short,long&listing-amenities=2,14,7&box=$($geo.West),$($geo.South),$($geo.East),$($geo.North)&images=&page=$($i)"
        $r = [Execute.HttpRequest]::Send($uri)
        $json = $reg.Match($r.ResponseText).Groups[1].Value | ConvertFrom-Json
        $JSON.currentSearch.listables.listables.ForEach({ $results += $_ })
        $i++
    }
    return $results
}
