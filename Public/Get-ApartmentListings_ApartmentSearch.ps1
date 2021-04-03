Add-Type -Path ..\lib\Execute.HttpRequest.dll
$Uri = "https://www.apartmentsearch.com/PropertySearch/GetSearchResults"
$Method = "POST"
$Headers = [ordered]@{
    "Pragma"="no-cache"
    "Cache-Control"="no-cache"
    "sec-ch-ua"="`"Google Chrome`";v=`"89`", `"Chromium`";v=`"89`", `";Not A Brand`";v=`"99`""
    "Accept"="application/json, text/javascript, */*; q=0.01"
    "DNT"="1"
    "X-Requested-With"="XMLHttpRequest"
    "sec-ch-ua-mobile"="?0"
    "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36"
    "Origin"="https://www.apartmentsearch.com"
    "Sec-Fetch-Site"="same-origin"
    "Sec-Fetch-Mode"="cors"
    "Sec-Fetch-Dest"="empty"
    "Referer"="https://www.apartmentsearch.com/apartments"
    "Accept-Encoding"="gzip, deflate"
    "Accept-Language"="en-US,en;q=0.9"
}
$ContentType = "application/json"
$Body = "{`"customerID`":`"`",`"query`":`"60660`",`"latne`":42.12487359261793,`"lngne`":-87.48175262501464,`"latsw`":41.85537900738207,`"lngsw`":-87.84433737498536,`"minBeds`":`"1`",`"maxBeds`":null,`"baths`":1,`"minRent`":null,`"maxRent`":null,`"shortTerm`":false,`"military`":false,`"student`":false,`"pageID`":1,`"pageSize`":10,`"furnitureInterest`":null,`"dogsOK`":false,`"catsOK`":false,`"amenities`":[`"71CFFCF2-16E8-4030-B7CA-F77AD17D94B6`",`"DAC77221-E345-4D41-B5F6-63BF627730F8`",`"CA5AE8ED-18DF-4E4C-9AF5-BE1A210F24BB`",`"2D7A19FB-383D-4078-B134-354B010A48F0`",`"F810557D-375B-4036-8796-39BDE0AB56CE`",`"78766DDF-8884-467F-92AF-25D15D6D86D8`",`"33ABF023-9193-49C0-A10A-8274762AF9D8`",`"F07A413D-DD6D-4879-A17E-C2A29DC8A08F`",`"97DFA871-0454-42E5-9A85-8F99F3CD5571`"],`"sort`":null}"

$r = [Execute.HttpRequest]::Send(
    $Uri,
    [System.Net.http.HttpMethod]::Post,
    $Headers,
    $null,
    $ContentType,
    $Body
)
