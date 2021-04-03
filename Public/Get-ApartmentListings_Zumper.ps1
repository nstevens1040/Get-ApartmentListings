Add-Type -Path ..\lib\Execute.HttpRequest.dll
$reg= [regex]::new(" window.__PRELOADED_STATE__ = (\{.*\})")
$uri = "https://www.zumper.com/apartments-for-rent/chicago-il/1-beds/under-2300?bathrooms=1&polygons=}jg~FzqpuO__@ePy{A}i@ebBia@u{CePwkA?u{BhCw{@?cr@zKqXpG_OnT{nA|gAceC~cCynAtcA{~@re@ie@ha@cR?w[{KiU{KckF?|^??vXkE`]qHlTeRhCgxA?vKre@`b@vXbR`]vKvXvKnr@?|sHpHflA?tcAdBha@?nyCxKvX|NnTfxBse@t[a]lx@wXv[iC`r@?tk@hCduAdPjUiCdRqGbuB?dRiC|d[?jUia@rHwaBrX_dCrHwX?euCa_@guCy[or@sXwv@eRgn@jE{i@lEoTdB_]?a]sHen@yKse@eBa]kEwX_OwX?wXsHmTyKeP_O{KjErG&listing-amenities=2,14,7,16&box=-87.96615600585938,41.748518877483804,-87.40036010742188,42.08420992526112&images"
$r = [Execute.HttpRequest]::Send($uri)
$json = $reg.Match($r.ResponseText).Groups[1].Value | ConvertFrom-Json
$results = @()
$JSON.currentSearch.listables.listables.ForEach({ $results += $_ })
$total = $JSON.currentSearch.listables.matching
$per_page = $JSON.currentSearch.firstPageCount
$no_pages = [Math]::Ceiling(($total / $per_page))
while($JSON.currentSearch.hasMoreListables)
{
    for($i = 2; $i -lt $no_pages; $i++){
        $uri = "https://www.zumper.com/apartments-for-rent/chicago-il/1-beds/under-2300?bathrooms=1&polygons=}jg~FzqpuO__@ePy{A}i@ebBia@u{CePwkA?u{BhCw{@?cr@zKqXpG_OnT{nA|gAceC~cCynAtcA{~@re@ie@ha@cR?w[{KiU{KckF?|^??vXkE``]qHlTeRhCgxA?vKre@``b@vXbR``]vKvXvKnr@?|sHpHflA?tcAdBha@?nyCxKvX|NnTfxBse@t[a]lx@wXv[iC``r@?tk@hCduAdPjUiCdRqGbuB?dRiC|d[?jUia@rHwaBrX_dCrHwX?euCa_@guCy[or@sXwv@eRgn@jE{i@lEoTdB_]?a]sHen@yKse@eBa]kEwX_OwX?wXsHmTyKeP_O{KjErG&listing-amenities=2,14,7,16&box=-87.96615600585938,41.748518877483804,-87.40036010742188,42.08420992526112&images=&page=$($i)"
        $r = [Execute.HttpRequest]::Send($uri)
        $json = $reg.Match($r.ResponseText).Groups[1].Value | ConvertFrom-Json
        $JSON.currentSearch.listables.listables.ForEach({ $results += $_ })
    }
}
$results[0]
