function Get-ApartmentListings_CheckCommutingAddress
{
    [cmdletbinding()]
    Param(
        [string]$Address
    )
    $uri = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?key=$($env:GooglePlaces_API_Key)&inputtype=textquery&input=$($Address)&fields=business_status,formatted_address,geometry,icon,name,photos,place_id,plus_code,types"
    $r = [Execute.HttpRequest]::Send($uri)
    $geoCoding = $r.ResponseText | ConvertFrom-Json
    if($geoCoding.status -eq 'OK')
    {
        return "$($geoCoding.candidates[0].formatted_address)"
    } else {
        return $false
    }
}