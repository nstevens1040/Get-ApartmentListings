Function Get-ApartmentListings_GeoCode
{
    [cmdletbinding()]
    Param(
        [String]$City,
        [string]$State_Code
    )
    Add-Type -TypeDefinition "using System;`nnamespace Geo`n{`n   public class Code`n   {`n        public string FormattedAddress`n        {`n            get;`n            set;`n        }`n        public Double Latitude`n        {`n            get;`n            set;`n        }`n        public Double Longitude`n        {`n            get;`n            set;`n        }`n        public Double North`n        {`n            get;`n            set;`n        }`n         public Double East`n         {`n            get;`n            set;`n        }`n        public Double South`n        {`n            get;`n            set;`n        }`n        public Double West`n        {`n            get;`n            set;`n        }`n        public string NorthEast`n        {`n            get;`n            set;`n        }`n        public string SouthWest`n        {`n            get;`n            set;`n        }`n        public string Name`n        {`n            get;`n            set;`n        }`n        public string PlaceId`n        {`n            get;`n            set;`n        }`n   }`n}"
    $geo = [Geo.Code]::new()
    if('GooglePlaces_API_Key' -notin @(gci env:\ |% Name))
    {
        write-host "Could not find environment variable " -ForegroundColor Red -NoNewline
        write-host 'GooglePlaces_API_Key' -ForegroundColor White
        write-host "If you need to get a Google Places API key, then start here " -ForegroundColor Red -NoNewline
        write-host "https://developers.google.com/maps/documentation/places/web-service/get-api-key" -ForegroundColor White
    } else {
        $uri = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?key=$($env:GooglePlaces_API_Key)&inputtype=textquery&input=$([uri]::EscapeDataString("$($city), $($state)"))&fields=business_status,formatted_address,geometry,icon,name,photos,place_id,plus_code,types"
        $r = [Execute.HttpRequest]::Send($uri)
        $geoCoding = $r.ResponseText | ConvertFrom-Json
        $geo.FormattedAddress = $geoCoding.candidates[0].formatted_address
        $geo.Latitude = [System.Convert]::ToDouble($geoCoding.candidates[0].geometry.location.lat)
        $geo.Longitude = [System.Convert]::ToDouble($geoCoding.candidates[0].geometry.location.lng)
        $geo.Name = $geoCoding.candidates[0].name
        $geo.North = [System.Convert]::ToDouble($geoCoding.candidates[0].geometry.viewport.northeast.lat)
        $geo.East = [System.Convert]::ToDouble($geoCoding.candidates[0].geometry.viewport.northeast.lng)
        $geo.South = [System.Convert]::ToDouble($geoCoding.candidates[0].geometry.viewport.southwest.lat)
        $geo.West = [System.Convert]::ToDouble($geoCoding.candidates[0].geometry.viewport.southwest.lng)
        $geo.NorthEast = "$($geoCoding.candidates[0].geometry.viewport.northeast.lat),$($geoCoding.candidates[0].geometry.viewport.northeast.lng)"
        $geo.PlaceId = $geoCoding.candidates[0].place_id
        $geo.SouthWest = "$($geoCoding.candidates[0].geometry.viewport.southwest.lat),$($geoCoding.candidates[0].geometry.viewport.southwest.lng)"
    }
    return $geo
}