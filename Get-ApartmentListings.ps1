
    [cmdletbinding()]
    Param(
        [string]$City,
        [string]$State_Code,
        [switch]$Keep_csv_file,
        [string]$Commute_To = $null
    )
    $start_dir = "$($PWD.Path)"
    cd "$([System.IO.FileInfo]::New($MyInvocation.MyCommand.Path).Directory.FullName)"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    function RelCom
    {
        param($ComObject)
        $ret=1
        while($ret -gt 0){
            try {
                $ret=[System.Runtime.Interopservices.Marshal]::ReleaseComObject($comobject)
            }
            catch [System.Management.Automation.MethodInvocationException]{
                break
            }
        }
    }
    Add-Type -Path .\lib\Execute.HttpRequest.dll
    $ReferencedAssemblies = @(
        "C:\Windows\Microsoft.Net\assembly\GAC_MSIL\System.Net.Http\v4.0_4.0.0.0__b03f5f7f11d50a3a\System.Net.Http.dll",
        "C:\Windows\Microsoft.Net\assembly\GAC_MSIL\Microsoft.CSharp\v4.0_4.0.0.0__b03f5f7f11d50a3a\Microsoft.CSharp.dll",
        "C:\Windows\assembly\GAC\Microsoft.mshtml\7.0.3300.0__b03f5f7f11d50a3a\Microsoft.mshtml.dll",
        "C:\Windows\Microsoft.Net\assembly\GAC_64\System.Data\v4.0_4.0.0.0__b77a5c561934e089\System.Data.dll",
        "C:\Windows\Microsoft.Net\assembly\GAC_MSIL\System.Xml\v4.0_4.0.0.0__b77a5c561934e089\System.Xml.dll",
        "C:\Windows\Microsoft.Net\assembly\GAC_64\System.Web\v4.0_4.0.0.0__b03f5f7f11d50a3a\System.Web.dll",
        "$($PWD.Path)\lib\System.ComponentModel.DataAnnotations.dll",
        "$($PWD.Path)\lib\System.Data.DataSetExtensions.dll",
        "$($PWD.Path)\lib\System.Data.SQLite.Linq.dll",
        "$($PWD.Path)\lib\System.Data.SQLite.dll",
        "$($PWD.Path)\lib\Newtonsoft.Json.dll",
        "$($PWD.Path)\lib\EntityFramework.SqlServer.dll",
        "$($PWD.Path)\lib\EntityFramework.dll",
        "$($PWD.Path)\lib\System.Data.SQLite.EF6.dll"
    )
    $ReferencedAssemblies.ForEach({ Add-Type -Path $_ })
    Add-Type -ReferencedAssemblies $ReferencedAssemblies -TypeDefinition "using System;`nusing System.Text.RegularExpressions;`nusing System.Net;`nusing System.Threading.Tasks;`nusing System.Collections;`nusing System.Collections.Generic;`nusing System.Linq;`nusing Search.Execute;`nusing System.Data;`nusing Newtonsoft.Json;`nusing System.Web;`nusing System.Data.SQLite;`n`nnamespace Search`n{`n    public class Candidate`n    {`n        public string place_id { get; set; }`n    }`n`n    public class Root`n    {`n        public List<Candidate> candidates { get; set; }`n        public string status { get; set; }`n    }`n    public class Distance`n    {`n        public string text { get; set; }`n        public int value { get; set; }`n    }`n    public class Duration`n    {`n        public string text { get; set; }`n        public int value { get; set; }`n    }`n    public class Element`n    {`n        public Distance distance { get; set; }`n        public Duration duration { get; set; }`n        public string status { get; set; }`n    }`n    public class Row`n    {`n        public List<Element> elements { get; set; }`n    }`n    public class GoogleDistance`n    {`n        public List<string> destination_addresses { get; set; }`n        public List<string> origin_addresses { get; set; }`n        public List<Row> rows { get; set; }`n        public string status { get; set; }`n    }`n    public class Results`n    {`n        public string Name`n        {`n            get;`n            set;`n        }`n        public string PropertyManager`n        {`n            get;`n            set;`n        }`n        public string EmailAddress`n        {`n            get;`n            set;`n        }`n        public string PhoneNumber`n        {`n            get;`n            set;`n        }`n        public string Address`n        {`n            get;`n            set;`n        }`n        public Int32 Price_Low`n        {`n            get;`n            set;`n        }`n        public Int32 Price_High`n        {`n            get;`n            set;`n        }`n        public Int32 Beds_min`n        {`n            get;`n            set;`n        }`n        public Int32 Beds_max`n        {`n            get;`n            set;`n        }`n        public Double Baths_min`n        {`n            get;`n            set;`n        }`n        public Double Baths_max`n        {`n            get;`n            set;`n        }`n        public Int32 ListingPrice`n        {`n            get;`n            set;`n        }`n        public Double Latitude`n        {`n            get;`n            set;`n        }`n        public Double Longitude`n        {`n            get;`n            set;`n        }`n        public string Link`n        {`n            get;`n            set;`n        }`n        public string ImageUri`n        {`n            get;`n            set;`n        }`n        public string OriginPlatform`n        {`n            get;`n            set;`n        }`n        public Double CommuteTime`n        {`n            get;`n            set;`n        }`n    }`n    public class ListingCollection`n    {`n        public List<Results> resultList = new List<Results>();`n    }`n    public class ProcessWalkScore`n    {`n        private static Regex phoneRegex = new Regex(@`"data-pretty_phone=`"`"(\+\d+)`");`n        private void GetResults(List<Results> collection, Results listing, string uri)`n        {`n            string place = new WebClient().DownloadString(uri);`n            listing.PhoneNumber = phoneRegex.Match(place).Groups[1].Value;`n            collection.Add(listing);`n        }`n        public async Task AddResult(List<Results> collection, Results listing, string uri)`n        {`n            await Task.Factory.StartNew(() =>`n            {`n                GetResults(collection, listing, uri);`n            }, TaskCreationOptions.None);`n        }`n    }`n    public class Convert`n    {`n        public static Double GetDistance(Results item, string to = null)`n        {`n            string from = item.Address;`n            string apiKey = Environment.GetEnvironmentVariable(`"GoogleDistance_API_Key`");`n            string uri = `"https://maps.googleapis.com/maps/api/distancematrix/json?origins=`" + from + `"&destinations=`" + to + `"&mode=driving&units=imperial&key=`" + apiKey;`n            string json = new WebClient().DownloadString(uri);`n            GoogleDistance r = JsonConvert.DeserializeObject<GoogleDistance>(json);`n            Int32 time = r.rows.FirstOrDefault().elements.FirstOrDefault().duration.value;`n            Double seconds = Double.Parse(time.ToString());`n            Double minutes = seconds / 60;`n            return Math.Round(minutes,2);`n        }`n        public static void dt(SQLiteCommand cmd, Results item, DataTable dt, string to = null)`n        {`n            string phone = String.Empty;`n            Double commuteTime = 0;`n            if(to == null)`n            {`n                try`n                {`n                    commuteTime = GetDistance(item);`n                }`n                catch`n                {}`n            }`n            else`n            {`n                try`n                {`n                    commuteTime = GetDistance(item, to);`n                }`n                catch`n                {}`n            }`n            RetObject req = Search.Execute.HttpRequest.Send(`n                @`"https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=`" + HttpUtility.UrlEncode(item.Address) + `"&inputtype=textquery&key=`" + System.Environment.GetEnvironmentVariable(`"GooglePlaces_API_Key`")`n            );`n            Root r = JsonConvert.DeserializeObject<Root>(req.ResponseText);`n            DataRow row = dt.NewRow();`n            if (!String.IsNullOrEmpty(item.PhoneNumber))`n            {`n                MatchCollection matches = new Regex(@`"\d+`").Matches(new Regex(@`"^[\+\s*]+1`").Replace(item.PhoneNumber, String.Empty));`n                List<Match> matchList = new List<Match>();`n                foreach (Match m in matches)`n                {`n                    matchList.Add(m);`n                }`n                phone = String.Join(String.Empty, String.Join(String.Empty, matchList.Select(i => i.Value).ToList()).ToCharArray().ToList().Skip(0).Take(10).Select(x => x));`n            }`n            if (!String.IsNullOrEmpty(phone))`n            {`n                row[`"Info`"] = `"<table>\n    <colgroup>\n        <col/>\n        <col/>\n    </colgroup>\n    <tbody>\n        <tr>\n            <td class=\`"left\`">Address</td>\n            <td class=\`"right\`"><a href=\`"https://www.google.com/maps/search/?api=1&query=Google&query_place_id=`" + r.candidates.FirstOrDefault().place_id + `"\`" target=\`"_blank\`">`" + item.Address + `"</a></td>\n        </tr>\n        <tr>\n            <td class=\`"left\`">Link</td>\n            <td class=\`"right\`"><a href=\`"`" + item.Link + `"\`" target=\`"_blank\`" title=\`"`" + item.Link + `"\`">`" + item.OriginPlatform + `"</a></td>\n        </tr>\n        <tr>\n            <td class=\`"left\`">Lowest rent</td>\n            <td class=\`"right\`">`" + (Char)36 + item.Price_Low + `"</td>\n        </tr>\n        <tr>\n            <td class=\`"left\`">Highest rent</td>\n            <td class=\`"right\`">`" + (Char)36 + item.Price_High + `"</td>\n        </tr>\n        <tr>\n            <td class=\`"left\`">Minimum bedrooms</td>\n            <td class=\`"right\`">`" + item.Beds_min + `"</td>\n        </tr>\n        <tr>\n            <td class=\`"left\`">Maximum bedrooms</td>\n            <td class=\`"right\`">`" + item.Beds_max + `"</td>\n        </tr>\n        <tr>\n            <td class=\`"left\`">Minimum bathrooms</td>\n            <td class=\`"right\`">`" + item.Baths_min + `"</td>\n        </tr>\n        <tr>\n            <td class=\`"left\`">Maximum bathrooms</td>\n            <td class=\`"right\`">`" + item.Baths_max + `"</td>\n        </tr>\n        <tr>\n            <td class=\`"left\`">Phone number</td>\n            <td class=\`"right\`"><a href=\`"tel://`" + phone + `"\`">`" + item.PhoneNumber + `"</a></td>\n        </tr>\n        <tr>\n            <td class=\`"left\`">Commute Time</td>\n            <td class=\`"right\`">`" + commuteTime + `" minutes</td>\n        </tr>\n    </tbody>\n</table>`";`n            }`n            else`n            {`n                row[`"Info`"] = `"<table>\n    <colgroup>\n        <col/>\n        <col/>\n    </colgroup>\n    <tbody>\n        <tr>\n            <td class=\`"left\`">Address</td>\n            <td class=\`"right\`"><a href=\`"https://www.google.com/maps/search/?api=1&query=Google&query_place_id=`" + r.candidates.FirstOrDefault().place_id + `"\`" target=\`"_blank\`">`" + item.Address + `"</a></td>\n        </tr>\n        <tr>\n            <td class=\`"left\`">Link</td>\n            <td class=\`"right\`"><a href=\`"`" + item.Link + `"\`" target=\`"_blank\`" title=\`"`" + item.Link + `"\`">`" + item.OriginPlatform + `"</a></td>\n        </tr>\n        <tr>\n            <td class=\`"left\`">Lowest rent</td>\n            <td class=\`"right\`">`" + (Char)36 + item.Price_Low + `"</td>\n        </tr>\n        <tr>\n            <td class=\`"left\`">Highest rent</td>\n            <td class=\`"right\`">`" + (Char)36 + item.Price_High + `"</td>\n        </tr>\n        <tr>\n            <td class=\`"left\`">Minimum bedrooms</td>\n            <td class=\`"right\`">`" + item.Beds_min + `"</td>\n        </tr>\n        <tr>\n            <td class=\`"left\`">Maximum bedrooms</td>\n            <td class=\`"right\`">`" + item.Beds_max + `"</td>\n        </tr>\n        <tr>\n            <td class=\`"left\`">Minimum bathrooms</td>\n            <td class=\`"right\`">`" + item.Baths_min + `"</td>\n        </tr>\n        <tr>\n            <td class=\`"left\`">Maximum bathrooms</td>\n            <td class=\`"right\`">`" + item.Baths_max + `"</td>\n        </tr>\n        <tr>\n            <td class=\`"left\`">Commute Time</td>\n            <td class=\`"right\`">`" + commuteTime + `" minutes</td>\n        </tr>\n        </tbody>\n</table>`";`n            }`n            row[`"Link`"] = `"<a href=\`"`" + item.Link + `"\`" target=\`"_blank\`" title=\`"`" + item.Link + `"\`"><img height=\`"200\`" width=auto src=\`"`" + item.ImageUri + `"\`"></a>`";`n            row[`"Map`"] = `"<a href=\`"https://www.google.com/maps/search/?api=1&query=Google&query_place_id=`" + r.candidates.FirstOrDefault().place_id + `"\`" target=\`"_blank\`" title=\`"https://www.google.com/maps/search/?api=1&query=Google&query_place_id=`" + r.candidates.FirstOrDefault().place_id + `"\`"><img height=\`"200\`" width=auto src=\`"https://maps.googleapis.com/maps/api/staticmap?center=`" + item.Latitude.ToString() + `",`" + item.Longitude.ToString() + `"&zoom=14&size=400x400&maptype=roadmap&markers=color:red%7Clabel:`" + Uri.EscapeDataString(item.Address) + `"%7C`" + item.Latitude.ToString() + `",`" + item.Longitude.ToString() + `"&key=AIzaSyCZpstuo1hvbPo6FKFTUr1r0dZbec8vW-g\`"></a>`";`n            row[`"Address`"] = `"<a href=\`"https://www.google.com/maps/search/?api=1&query=Google&query_place_id=`" + r.candidates.FirstOrDefault().place_id + `"\`" target=\`"_blank\`">`" + item.Address + `"</a>`";`n            row[`"Rental Rate From`"] = item.Price_Low;`n            row[`"Rental Rate Ceiling`"] = item.Price_High;`n            row[`"Minimum Bedrooms`"] = item.Beds_min;`n            row[`"Maximum Bedrooms`"] = item.Beds_max;`n            row[`"Minimum Bathrooms`"] = item.Baths_min;`n            row[`"Maximum Bathrooms`"] = item.Baths_max;`n            row[`"Platform of Origin`"] = `"<a href=\`"https://`" + item.OriginPlatform + `"\`" target=\`"_blank\`">`" + item.OriginPlatform + `"</a>`";`n            row[`"Commute Time`"] = commuteTime;`n            if (!String.IsNullOrEmpty(phone))`n            {`n                row[`"Phone Number Property Management`"] = `"<a href=\`"tel://`" + phone + `"\`">`" + item.PhoneNumber + `"</a>`";`n            }`n            row[`"Building Name`"] = `"<a href=\`"`" + item.Link + `"\`" target=\`"_blank\`">`" + item.Name + `"</a>`";`n            if (!String.IsNullOrEmpty(item.PropertyManager))`n            {`n                row[`"Property Management Company Name`"] = item.PropertyManager;`n            }`n            if (!String.IsNullOrEmpty(item.EmailAddress))`n            {`n                row[`"Email Address`"] = `"<a href=\`"mailto:`" + item.EmailAddress + `"\`">`" + item.EmailAddress + `"</a>`";`n            }`n            Insert_row_sql(cmd, row);`n            //dt.Rows.Add(row);`n        }`n        public static void Insert_row_sql(SQLiteCommand cmd, DataRow row)`n        {`n            string insert_command = `"INSERT INTO ApartmentListings (address, building_name, commute_time, email_address, info, link, map, maximum_bathrooms, maximum_bedrooms, minimum_bathrooms, minimum_bedrooms, phone_number_property_management, platform_of_origin, property_management_company_name, rental_rate_ceiling, rental_rate_from)`";`n            insert_command = insert_command + `"VALUES ('`" + row[`"Address`"] + `"', '`" + row[`"Building Name`"] + `"', '`" + row[`"Commute Time`"] + `"', '`" + row[`"Email Address`"] + `"', '`" + row[`"Info`"] + `"', '`" + row[`"Link`"] + `"', '`" + row[`"Map`"] + `"', '`" + row[`"Maximum Bathrooms`"] + `"', '`" + row[`"Maximum Bedrooms`"] + `"', '`" + row[`"Minimum Bathrooms`"] + `"', '`" + row[`"Minimum Bedrooms`"] + `"', '`" + row[`"Phone Number Property Management`"] + `"', '`" + row[`"Platform of Origin`"] + `"', '`" + row[`"Property Management Company Name`"] + `"', '`" + row[`"Rental Rate Ceiling`"] + `"', '`" + row[`"Rental Rate From`"] + `"');`";`n            cmd.CommandText = insert_command;`n            cmd.ExecuteNonQuery();`n        }`n        public static async Task ToDataTable(SQLiteCommand cmd, Results item, DataTable dataTable, string to = null)`n        {`n            await Task.Factory.StartNew(() =>`n            {`n                if(to == null)`n                {`n                    Search.Convert.dt(cmd,item, dataTable);`n                }`n                else`n                {`n                    Search.Convert.dt(cmd,item, dataTable,to);`n                }`n            }, TaskCreationOptions.None);`n        }`n    }`n}`nnamespace Search.Execute`n{`n    using System;`n    using System.Collections.Generic;`n    using System.Collections.Specialized;`n    using System.Linq;`n    using System.Text;`n    using System.Threading.Tasks;`n    using System.Net.Http;`n    using System.Net.Http.Headers;`n    using System.Net;`n    using System.Collections;`n    using System.Text.RegularExpressions;`n    using System.IO;`n    using System.IO.Compression;`n    using mshtml;`n    public class RetObject`n    {`n        public string ResponseText`n        {`n            get;`n            set;`n        }`n        public OrderedDictionary HttpResponseHeaders`n        {`n            get;`n            set;`n        }`n        public CookieCollection CookieCollection`n        {`n            get;`n            set;`n        }`n        public HTMLDocument HtmlDocument`n        {`n            get;`n            set;`n        }`n        public HttpResponseMessage HttpResponseMessage`n        {`n            get;`n            set;`n        }`n    }`n    public class HttpRequest`n    {`n        private static dynamic DOMParser(string responseText)`n        {`n            dynamic domobj = Activator.CreateInstance(Type.GetTypeFromCLSID(Guid.Parse(@`"{25336920-03F9-11cf-8FD0-00AA00686F13}`")));`n            List<string> memberNames = new List<string>();`n            for (int i = 0; i < memberNames.Count; i++)`n            {`n                memberNames.Add(domobj.GetType().GetMembers()[i].Name);`n            }`n            if (memberNames.Contains(`"IHTMLDocument2_write`"))`n            {`n                domobj.IHTMLDocument2_write(Encoding.Unicode.GetBytes(responseText));`n            }`n            else`n            {`n                domobj.write(Encoding.Unicode.GetBytes(responseText));`n            }`n            return domobj;`n        }`n        private static CookieCollection SetCookieParser(List<string> setCookie, CookieCollection cooks, CookieCollection initCookies)`n        {`n            List<Exception> ex = new List<Exception>();`n            List<Hashtable> rckevalues = new List<Hashtable>();`n            List<Hashtable> ckevalues = new List<Hashtable>();`n            List<Cookie> ckeList = new List<Cookie>();`n            if (initCookies != null)`n            {`n                for (int i = 0; i < initCookies.Count; i++)`n                {`n                    ckeList.Add(initCookies[i]);`n                    Hashtable h = new Hashtable();`n                    h.Add(initCookies[i].Name, initCookies[i].Value);`n                    ckevalues.Add(h);`n                }`n            }`n            try`n            {`n`n                List<string> rckes = new List<string>();`n                for (int i = 0; i < cooks.Count; i++)`n                {`n                    rckes.Add(cooks[i].Name);`n                }`n                foreach (string set in setCookie)`n                {`n                    Cookie cke = new Cookie();`n                    for (int i = 0; i < set.Split(';').ToList().Count; i++)`n                    {`n                        List<string> v = new List<string>();`n                        string item = set.Split(';').ToList()[i];`n                        for (int ii = 1; ii < item.Split('=').ToList().Count; ii++)`n                        {`n                            v.Add(item.Split('=')[ii]);`n                        }`n                        string va = String.Join('='.ToString(), v);`n                        string key = new Regex(@`"^(\s*)`").Replace(item.Split('=').ToList()[0], `"`");`n                        string value = new Regex(@`"^(\s*)`").Replace(va, `"`");`n                        if (i == 0)`n                        {`n                            cke.Name = key;`n                            cke.Value = value;`n                        }`n                        else`n                        {`n                            switch (key.ToLower())`n                            {`n                                case `"comment`":`n                                    cke.Comment = value;`n                                    break;`n                                case `"commenturi`":`n                                    cke.CommentUri = new Uri(value);`n                                    break;`n                                case `"httponly`":`n                                    cke.HttpOnly = bool.Parse(value);`n                                    break;`n                                case `"discard`":`n                                    cke.Discard = bool.Parse(value);`n                                    break;`n                                case `"domain`":`n                                    cke.Domain = value;`n                                    break;`n                                case `"expires`":`n                                    cke.Expires = DateTime.Parse(value);`n                                    break;`n                                case `"name`":`n                                    cke.Name = value;`n                                    break;`n                                case `"path`":`n                                    cke.Path = value;`n                                    break;`n                                case `"port`":`n                                    cke.Port = value;`n                                    break;`n                                case `"secure`":`n                                    cke.Secure = bool.Parse(value);`n                                    break;`n                                case `"value`":`n                                    cke.Value = value;`n                                    break;`n                                case `"version`":`n                                    cke.Version = int.Parse(value);`n                                    break;`n                            }`n                        }`n                        if (!rckes.Contains(cke.Name))`n                        {`n                            cooks.Add(cke);`n                        }`n                        else`n                        {`n                            CookieCollection tempRCkes = new CookieCollection();`n                            for (int ii = 0; ii < cooks.Count; ii++)`n                            {`n                                Cookie current = cooks[ii];`n                                if (!current.Name.Equals(cke.Name))`n                                {`n                                    tempRCkes.Add(current);`n                                }`n                            }`n                            tempRCkes.Add(cke);`n                            cooks = new CookieCollection();`n                            for (int ii = 0; ii < tempRCkes.Count; ii++)`n                            {`n                                cooks.Add(tempRCkes[ii]);`n                            }`n                            rckes = new List<string>();`n                            for (int ii = 0; ii < cooks.Count; ii++)`n                            {`n                                rckes.Add(cooks[ii].Name);`n                            }`n                        }`n                    }`n                }`n                if (cooks != null)`n                {`n                    for (int i = 0; i < cooks.Count; i++)`n                    {`n                        Hashtable h = new Hashtable();`n                        h.Add(cooks[i].Name, cooks[i].Value);`n                        rckevalues.Add(h);`n                    }`n                }`n                if (ckevalues != null)`n                {`n                    if (rckevalues != null)`n                    {`n                        List<string> rNames = new List<string>();`n                        List<string> rValue = new List<string>();`n                        for (int i = 0; i < rckevalues.Count; i++)`n                        {`n                            string rcken = rckevalues[i].Keys.ToString();`n                            string rckev = rckevalues[i].Values.ToString();`n                            rNames.Add(rcken);`n                            rValue.Add(rckev);`n                        }`n                        for (int i = 0; i < ckevalues.Count; i++)`n                        {`n                            string ckeName = ckevalues[i].Keys.ToString();`n                            string ckeValu = ckevalues[i].Values.ToString();`n                            if (!rValue.Contains(ckeValu))`n                            {`n                                if (!rNames.Contains(ckeName))`n                                {`n                                    cooks.Add(ckeList.Where(item => item.Name.Equals(ckeName)).FirstOrDefault());`n                                }`n                            }`n                            else`n                            {`n                                if (!rNames.Contains(ckeName))`n                                {`n                                    cooks.Add(ckeList.Where(item => item.Name.Equals(ckeName)).FirstOrDefault());`n                                }`n                            }`n                        }`n                    }`n                    else`n                    {`n                        ckeList.ForEach(i => cooks.Add(i));`n                    }`n                }`n            }`n            catch (Exception e)`n            {`n                ex.Add(e);`n            }`n            return cooks;`n        }`n        public static void CopyTo(Stream src, Stream dest)`n        {`n            byte[] bytes = new byte[4096];`n            int cnt;`n            while ((cnt = src.Read(bytes, 0, bytes.Length)) != 0)`n            {`n                dest.Write(bytes, 0, cnt);`n            }`n        }`n        public static string Unzip(byte[] bytes)`n        {`n            using (var msi = new MemoryStream(bytes))`n            using (var mso = new MemoryStream())`n            {`n                using (var gs = new GZipStream(msi, CompressionMode.Decompress))`n                {`n                    //gs.CopyTo(mso);`n                    CopyTo(gs, mso);`n                }`n                return Encoding.UTF8.GetString(mso.ToArray());`n            }`n        }`n        private static async Task<RetObject> SendHttp(string uri, HttpMethod method = null, OrderedDictionary headers = null, CookieCollection cookies = null, string contentType = null, string body = null, string filepath = null)`n        {`n            byte[] reStream;`n            RetObject retObj = new RetObject();`n            HttpResponseMessage res = new HttpResponseMessage();`n            OrderedDictionary httpResponseHeaders = new OrderedDictionary();`n            CookieCollection responseCookies;`n            CookieCollection rCookies = new CookieCollection();`n            List<string> setCookieValue = new List<string>();`n            CookieContainer coo = new CookieContainer();`n            dynamic dom = new object();`n            string htmlString = String.Empty;`n            if (method == null)`n            {`n                method = HttpMethod.Get;`n            }`n            HttpClientHandler handle = new HttpClientHandler()`n            {`n                AutomaticDecompression = (DecompressionMethods)1 & (DecompressionMethods)2,`n                UseProxy = false,`n                AllowAutoRedirect = true,`n                MaxAutomaticRedirections = 500`n            };`n            HttpClient client = new HttpClient(handle);`n            if (!client.DefaultRequestHeaders.Contains(`"User-Agent`"))`n            {`n                client.DefaultRequestHeaders.Add(`"User-Agent`", `"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36`");`n            }`n            if (client.DefaultRequestHeaders.Contains(`"Path`"))`n            {`n                client.DefaultRequestHeaders.Remove(`"Path`");`n            }`n            client.DefaultRequestHeaders.Add(`"Path`", (new Uri(uri).PathAndQuery));`n            List<string> headersToSkip = new List<string>();`n            headersToSkip.Add(`"Accept`");`n            headersToSkip.Add(`"pragma`");`n            headersToSkip.Add(`"Cache-Control`");`n            headersToSkip.Add(`"Date`");`n            headersToSkip.Add(`"Content-Length`");`n            headersToSkip.Add(`"Content-Type`");`n            headersToSkip.Add(`"Expires`");`n            headersToSkip.Add(`"Last-Modified`");`n            if (headers != null)`n            {`n                headersToSkip.ForEach((i) => {`n                    headers.Remove(i);`n                });`n                IEnumerator enume = headers.Keys.GetEnumerator();`n                while (enume.MoveNext())`n                {`n                    string key = enume.Current.ToString();`n                    string value = String.Join(`"\n`", headers[key]);`n                    if (client.DefaultRequestHeaders.Contains(key))`n                    {`n                        client.DefaultRequestHeaders.Remove(key);`n                    }`n                    try`n                    {`n                        client.DefaultRequestHeaders.Add(key, value);`n                    }`n                    catch`n                    {`n                        client.DefaultRequestHeaders.TryAddWithoutValidation(key, value);`n                    }`n                }`n            }`n            if (cookies != null)`n            {`n                IEnumerator cnume = cookies.GetEnumerator();`n                while (cnume.MoveNext())`n                {`n                    Cookie cook = (Cookie)cnume.Current;`n                    coo.Add(cook);`n                }`n                handle.CookieContainer = coo;`n            }`n            switch (method.ToString())`n            {`n                case `"DELETE`":`n                    res = await client.SendAsync((new HttpRequestMessage(method, uri)));`n                    if (res.Content.Headers.ContentEncoding.ToString().ToLower().Equals(`"gzip`"))`n                    {`n                        reStream = res.Content.ReadAsByteArrayAsync().Result;`n                        htmlString = Unzip(reStream);`n                    }`n                    else`n                    {`n                        htmlString = res.Content.ReadAsStringAsync().Result;`n                    }`n                    try`n                    {`n                        setCookieValue = res.Headers.GetValues(`"Set-Cookie`").ToList();`n                    }`n                    catch`n                    { }`n                    res.Headers.ToList().ForEach((i) =>`n                    {`n                        httpResponseHeaders.Add(i.Key, i.Value);`n                    });`n                    res.Content.Headers.ToList().ForEach((i) =>`n                    {`n                        httpResponseHeaders.Add(i.Key, i.Value);`n                    });`n                    responseCookies = handle.CookieContainer.GetCookies(new Uri(uri));`n                    rCookies = SetCookieParser(setCookieValue, responseCookies, cookies);`n                    if (!String.IsNullOrEmpty(htmlString))`n                    {`n                        dom = DOMParser(htmlString);`n                        retObj.HtmlDocument = dom;`n                    }`n                    retObj.HttpResponseHeaders = httpResponseHeaders;`n                    retObj.HttpResponseMessage = res;`n                    break;`n                case `"GET`":`n                    res = await client.SendAsync((new HttpRequestMessage(method, uri)));`n                    if (res.Content.Headers.ContentEncoding.ToString().ToLower().Equals(`"gzip`"))`n                    {`n                        reStream = res.Content.ReadAsByteArrayAsync().Result;`n                        htmlString = Unzip(reStream);`n                    }`n                    else`n                    {`n                        htmlString = res.Content.ReadAsStringAsync().Result;`n                    }`n                    try`n                    {`n                        setCookieValue = res.Headers.GetValues(`"Set-Cookie`").ToList();`n                    }`n                    catch`n                    { }`n                    res.Headers.ToList().ForEach((i) =>`n                    {`n                        httpResponseHeaders.Add(i.Key, i.Value);`n                    });`n                    res.Content.Headers.ToList().ForEach((i) =>`n                    {`n                        httpResponseHeaders.Add(i.Key, i.Value);`n                    });`n                    responseCookies = handle.CookieContainer.GetCookies(new Uri(uri));`n                    rCookies = SetCookieParser(setCookieValue, responseCookies, cookies);`n                    if (!String.IsNullOrEmpty(htmlString))`n                    {`n                        dom = DOMParser(htmlString);`n                        retObj.HtmlDocument = dom;`n                    }`n                    retObj.HttpResponseHeaders = httpResponseHeaders;`n                    retObj.HttpResponseMessage = res;`n                    break;`n                case `"HEAD`":`n                    res = await client.SendAsync((new HttpRequestMessage(method, uri)));`n                    try`n                    {`n                        setCookieValue = res.Headers.GetValues(`"Set-Cookie`").ToList();`n                    }`n                    catch`n                    { }`n                    res.Headers.ToList().ForEach((i) =>`n                    {`n                        httpResponseHeaders.Add(i.Key, i.Value);`n                    });`n                    res.Content.Headers.ToList().ForEach((i) =>`n                    {`n                        httpResponseHeaders.Add(i.Key, i.Value);`n                    });`n                    responseCookies = handle.CookieContainer.GetCookies(new Uri(uri));`n                    rCookies = SetCookieParser(setCookieValue, responseCookies, cookies);`n                    retObj.HttpResponseHeaders = httpResponseHeaders;`n                    retObj.HttpResponseMessage = res;`n                    break;`n                case `"OPTIONS`":`n                    res = await client.SendAsync((new HttpRequestMessage(method, uri)));`n                    if (res.Content.Headers.ContentEncoding.ToString().ToLower().Equals(`"gzip`"))`n                    {`n                        reStream = res.Content.ReadAsByteArrayAsync().Result;`n                        htmlString = Unzip(reStream);`n                    }`n                    else`n                    {`n                        htmlString = res.Content.ReadAsStringAsync().Result;`n                    }`n                    try`n                    {`n                        setCookieValue = res.Headers.GetValues(`"Set-Cookie`").ToList();`n                    }`n                    catch`n                    { }`n                    res.Headers.ToList().ForEach((i) =>`n                    {`n                        httpResponseHeaders.Add(i.Key, i.Value);`n                    });`n                    res.Content.Headers.ToList().ForEach((i) =>`n                    {`n                        httpResponseHeaders.Add(i.Key, i.Value);`n                    });`n                    responseCookies = handle.CookieContainer.GetCookies(new Uri(uri));`n                    rCookies = SetCookieParser(setCookieValue, responseCookies, cookies);`n                    if (!String.IsNullOrEmpty(htmlString))`n                    {`n                        dom = DOMParser(htmlString);`n                        retObj.HtmlDocument = dom;`n                    }`n                    retObj.HttpResponseHeaders = httpResponseHeaders;`n                    retObj.HttpResponseMessage = res;`n                    break;`n                case `"POST`":`n                    if (String.IsNullOrEmpty(contentType))`n                    {`n                        contentType = `"application/x-www-form-urlencoded`";`n                    }`n                    if (!String.IsNullOrEmpty(body))`n                    {`n                        switch (contentType)`n                        {`n                            case @`"application/x-www-form-urlencoded`":`n                                res = await client.SendAsync(`n                                    (new HttpRequestMessage(method, uri)`n                                    {`n                                        Content = (new StringContent(body, Encoding.UTF8, contentType))`n                                    })`n                                );`n                                break;`n                            case @`"multipart/form-data`":`n                                MultipartFormDataContent mpc = new MultipartFormDataContent(`"Boundary----`" + DateTime.Now.Ticks.ToString(`"x`"));`n                                if (!String.IsNullOrEmpty(filepath))`n                                {`n                                    if (File.Exists(filepath))`n                                    {`n                                        ByteArrayContent bac = new ByteArrayContent(File.ReadAllBytes(filepath));`n                                        bac.Headers.Add(`"Content-Type`", `"application/octet-stream`");`n                                        mpc.Add(bac, new FileInfo(filepath).Name);`n                                    }`n                                }`n                                if (!String.IsNullOrEmpty(body))`n                                {`n                                    StringContent sc = new StringContent(body, Encoding.UTF8, @`"application/x-www-form-urlencoded`");`n                                    mpc.Add(sc);`n                                }`n                                res = await client.SendAsync(`n                                    (new HttpRequestMessage(method, uri)`n                                    {`n                                        Content = mpc`n                                    })`n                                );`n                                break;`n                            default:`n                                res = await client.SendAsync(`n                                    (new HttpRequestMessage(method, uri)`n                                    {`n                                        Content = (new StringContent(body, Encoding.UTF8, contentType))`n                                    })`n                                );`n                                break;`n                        }`n                        if (res.Content.Headers.ContentEncoding.ToString().ToLower().Equals(`"gzip`"))`n                        {`n                            reStream = res.Content.ReadAsByteArrayAsync().Result;`n                            htmlString = Unzip(reStream);`n                        }`n                        else`n                        {`n                            htmlString = res.Content.ReadAsStringAsync().Result;`n                        }`n                        try`n                        {`n                            setCookieValue = res.Headers.GetValues(`"Set-Cookie`").ToList();`n                        }`n                        catch`n                        { }`n                        res.Headers.ToList().ForEach((i) =>`n                        {`n                            httpResponseHeaders.Add(i.Key, i.Value);`n                        });`n                        res.Content.Headers.ToList().ForEach((i) =>`n                        {`n                            httpResponseHeaders.Add(i.Key, i.Value);`n                        });`n                    }`n                    else`n                    {`n                        res = await client.SendAsync((new HttpRequestMessage(method, uri)));`n                        if (res.Content.Headers.ContentEncoding.ToString().ToLower().Equals(`"gzip`"))`n                        {`n                            reStream = res.Content.ReadAsByteArrayAsync().Result;`n                            htmlString = Unzip(reStream);`n                        }`n                        else`n                        {`n                            htmlString = res.Content.ReadAsStringAsync().Result;`n                        }`n                        try`n                        {`n                            setCookieValue = res.Headers.GetValues(`"Set-Cookie`").ToList();`n                        }`n                        catch`n                        { }`n                        res.Headers.ToList().ForEach((i) =>`n                        {`n                            httpResponseHeaders.Add(i.Key, i.Value);`n                        });`n                        res.Content.Headers.ToList().ForEach((i) =>`n                        {`n                            httpResponseHeaders.Add(i.Key, i.Value);`n                        });`n                    }`n                    responseCookies = handle.CookieContainer.GetCookies(new Uri(uri));`n                    rCookies = SetCookieParser(setCookieValue, responseCookies, cookies);`n                    if (!String.IsNullOrEmpty(htmlString))`n                    {`n                        dom = DOMParser(htmlString);`n                        retObj.HtmlDocument = dom;`n                    }`n                    retObj.HttpResponseHeaders = httpResponseHeaders;`n                    retObj.HttpResponseMessage = res;`n                    break;`n                case `"PUT`":`n                    if (String.IsNullOrEmpty(contentType))`n                    {`n                        contentType = `"application/x-www-form-urlencoded`";`n                    }`n                    if (!String.IsNullOrEmpty(body))`n                    {`n                        res = await client.SendAsync(`n                            (new HttpRequestMessage(method, uri)`n                            {`n                                Content = (new StringContent(body, Encoding.UTF8, contentType))`n                            })`n                        );`n                        if (res.Content.Headers.ContentEncoding.ToString().ToLower().Equals(`"gzip`"))`n                        {`n                            reStream = res.Content.ReadAsByteArrayAsync().Result;`n                            htmlString = Unzip(reStream);`n                        }`n                        else`n                        {`n                            htmlString = res.Content.ReadAsStringAsync().Result;`n                        }`n                        try`n                        {`n                            setCookieValue = res.Headers.GetValues(`"Set-Cookie`").ToList();`n                        }`n                        catch`n                        { }`n                        res.Headers.ToList().ForEach((i) =>`n                        {`n                            httpResponseHeaders.Add(i.Key, i.Value);`n                        });`n                        res.Content.Headers.ToList().ForEach((i) =>`n                        {`n                            httpResponseHeaders.Add(i.Key, i.Value);`n                        });`n                    }`n                    else`n                    {`n                        res = await client.SendAsync((new HttpRequestMessage(method, uri)));`n                        if (res.Content.Headers.ContentEncoding.ToString().ToLower().Equals(`"gzip`"))`n                        {`n                            reStream = res.Content.ReadAsByteArrayAsync().Result;`n                            htmlString = Unzip(reStream);`n                        }`n                        else`n                        {`n                            htmlString = res.Content.ReadAsStringAsync().Result;`n                        }`n                        try`n                        {`n                            setCookieValue = res.Headers.GetValues(`"Set-Cookie`").ToList();`n                        }`n                        catch`n                        { }`n                        res.Headers.ToList().ForEach((i) =>`n                        {`n                            httpResponseHeaders.Add(i.Key, i.Value);`n                        });`n                        res.Content.Headers.ToList().ForEach((i) =>`n                        {`n                            httpResponseHeaders.Add(i.Key, i.Value);`n                        });`n                    }`n                    responseCookies = handle.CookieContainer.GetCookies(new Uri(uri));`n                    rCookies = SetCookieParser(setCookieValue, responseCookies, cookies);`n                    if (!String.IsNullOrEmpty(htmlString))`n                    {`n                        dom = DOMParser(htmlString);`n                        retObj.HtmlDocument = dom;`n                    }`n                    retObj.HtmlDocument = dom;`n                    retObj.HttpResponseHeaders = httpResponseHeaders;`n                    retObj.HttpResponseMessage = res;`n                    break;`n                case `"TRACE`":`n                    res = await client.SendAsync((new HttpRequestMessage(method, uri)));`n                    if (res.Content.Headers.ContentEncoding.ToString().ToLower().Equals(`"gzip`"))`n                    {`n                        reStream = res.Content.ReadAsByteArrayAsync().Result;`n                        htmlString = Unzip(reStream);`n                    }`n                    else`n                    {`n                        htmlString = res.Content.ReadAsStringAsync().Result;`n                    }`n                    try`n                    {`n                        setCookieValue = res.Headers.GetValues(`"Set-Cookie`").ToList();`n                    }`n                    catch`n                    { }`n                    res.Headers.ToList().ForEach((i) =>`n                    {`n                        httpResponseHeaders.Add(i.Key, i.Value);`n                    });`n                    res.Content.Headers.ToList().ForEach((i) =>`n                    {`n                        httpResponseHeaders.Add(i.Key, i.Value);`n                    });`n                    responseCookies = handle.CookieContainer.GetCookies(new Uri(uri));`n                    rCookies = SetCookieParser(setCookieValue, responseCookies, cookies);`n                    if (!String.IsNullOrEmpty(htmlString))`n                    {`n                        dom = DOMParser(htmlString);`n                        retObj.HtmlDocument = dom;`n                    }`n                    retObj.HttpResponseHeaders = httpResponseHeaders;`n                    retObj.HttpResponseMessage = res;`n                    break;`n            }`n            if (!String.IsNullOrEmpty(htmlString))`n            {`n                retObj.ResponseText = htmlString;`n            }`n            retObj.CookieCollection = rCookies;`n            return retObj;`n        }`n        public static RetObject Send(string uri, HttpMethod method = null, OrderedDictionary headers = null, CookieCollection cookies = null, string contentType = null, string body = null, string filepath = null)`n        {`n            Task<RetObject> r = SendHttp(uri, method, headers, cookies, contentType, body, filepath);`n            return r.Result;`n        }`n    }`n}`n`n"
    . ".\Public\Get-ApartmentListings_CheckCommutingAddress.ps1"
    . ".\Public\Get-ApartmentListings_ForRent.ps1"
    . ".\Public\Get-ApartmentListings_MyNewPlace.ps1"
    . ".\Public\Get-ApartmentListings_PadMapper.ps1"
    . ".\Public\Get-ApartmentListings_RentCafe.ps1"
    . ".\Public\Get-ApartmentListings_WalkScore.ps1"
    . ".\Public\Get-ApartmentListings_Hotpads.ps1"
    . ".\Public\Get-ApartmentListings_ApartmentFinder.ps1"
    . ".\Public\Get-ApartmentListings_GeoCode.ps1"
    . ".\Public\Get-ApartmentListings_ApartmentSearch.ps1"
    . ".\Public\Get-ApartmentListings_Zumper.ps1"
    . ".\Public\Get-ApartmentListings_Trulia.ps1"
    . ".\Public\Get-ApartmentListings_Zillow.ps1"
    (0..3).ForEach({ Write-Host "`n" })
    write-host "GeoCode" -ForegroundColor Green -NoNewline
    $Geo = Get-ApartmentListings_GeoCode -State_Code $State_Code -City $City
    (0..(20 - "GeoCode".Length)).ForEach({ Write-Host " " -NoNewline })
    write-host "done" -ForegroundColor Yellow
    write-host "    $($geo.Latitude.ToString() + "," + $geo.Longitude.ToString())"
    Write-Host "Commute To" -ForegroundColor Green -NoNewline
    $commute_result = Get-ApartmentListings_CheckCommutingAddress -Address $Commute_To
    if($Commute_To)
    {
        (0..(20 - "Commute To".Length)).ForEach({ Write-Host " " -NoNewline })
        write-host "done" -ForegroundColor Yellow
        Write-Host "    $($commute_result)"
    } else {
        (0..(20 - "Commute To".Length)).ForEach({ Write-Host " " -NoNewline })
        write-host "failed" -ForegroundColor red
    }
    write-host "ForRent" -ForegroundColor Green -NoNewline
    $ForRent_results = Get-ApartmentListings_ForRent -State_Code $State_Code -City $City
    (0..(20 - "ForRent".Length)).ForEach({ Write-Host " " -NoNewline })
    write-host "done" -ForegroundColor Yellow
    write-host "    $($ForRent_results.Count) results"
    write-host "MyNewPlace" -ForegroundColor Green -NoNewline
    $MyNewPlace_results = Get-ApartmentListings_MyNewPlace -State_Code $State_Code -City $City
    (0..(20 - "MyNewPlace".Length)).ForEach({ Write-Host " " -NoNewline })
    write-host "done" -ForegroundColor Yellow
    write-host "    $($MyNewPlace_results.count) results"
    write-host "PadMapper" -ForegroundColor Green -NoNewline
    $PadMapper_results = Get-ApartmentListings_PadMapper -State_Code $State_Code -City $City
    (0..(20 - "PadMapper".Length)).ForEach({ Write-Host " " -NoNewline })
    write-host "done" -ForegroundColor Yellow
    write-host "    $($PadMapper_results.count) results"
    write-host "RentCafe" -ForegroundColor Green -NoNewline
    $RentCafe_results = Get-ApartmentListings_RentCafe -State_Code $State_Code -City $City
    (0..(20 - "RentCafe".Length)).ForEach({ Write-Host " " -NoNewline })
    write-host "done" -ForegroundColor Yellow
    write-host "    $($RentCafe_results.count) results"
    write-host "WalkScore" -ForegroundColor Green -NoNewline
    $WalkScore_results = Get-ApartmentListings_WalkScore -State_Code $State_Code -City $City
    (0..(20 - "WalkScore".Length)).ForEach({ Write-Host " " -NoNewline })
    write-host "done" -ForegroundColor Yellow
    write-host "    $($WalkScore_results.count) results"
    write-host "HotPads" -ForegroundColor Green -NoNewline
    $Hotpads_results = Get-ApartmentListings_Hotpads -State_Code $State_Code -City $City
    (0..(20 - "HotPads".Length)).ForEach({ Write-Host " " -NoNewline })
    write-host "done" -ForegroundColor Yellow
    write-host "    $($HotPads_results.count) results"
    write-host "ApartmentFinder" -ForegroundColor Green -NoNewline
    $ApartmentFinder_results = Get-ApartmentListings_ApartmentFinder -State_Code $State_Code -City $City
    (0..(20 - "ApartmentFinder".Length)).ForEach({ Write-Host " " -NoNewline })
    write-host "done" -ForegroundColor Yellow
    write-host "    $($ApartmentFinder_results.count) results"
    write-host "ApartmentSearch" -ForegroundColor Green -NoNewline
    $ApartmentSearch_results = Get-ApartmentListings_ApartmentSearch -State_Code $State_Code -City $City
    (0..(20 - "ApartmentSearch".Length)).ForEach({ Write-Host " " -NoNewline })
    write-host "done" -ForegroundColor Yellow
    write-host "    $($ApartmentSearch_results.count) results"
    write-host "Zumper" -ForegroundColor Green -NoNewline
    $Zumper_results = Get-ApartmentListings_Zumper -State_Code $State_Code -City $City
    (0..(20 - "Zumper".Length)).ForEach({ Write-Host " " -NoNewline })
    write-host "done" -ForegroundColor Yellow
    write-host "    $($Zumper_results.count) results"
    write-host "Trulia" -ForegroundColor Green -NoNewline
    $Trulia_results = Get-ApartmentListings_Trulia -State_Code $State_Code -City $City
    (0..(20 - "Trulia".Length)).ForEach({ Write-Host " " -NoNewline })
    write-host "done" -ForegroundColor Yellow
    write-host "    $($Trulia_results.count) results"
    write-host "Zillow" -ForegroundColor Green -NoNewline
    $Zillow_results = Get-ApartmentListings_Zillow -State_Code $State_Code -City $City
    (0..(20 - "Zillow".Length)).ForEach({ Write-Host " " -NoNewline })
    write-host "done" -ForegroundColor Yellow
    write-host "    $($Zillow_results.count) results"
    $all_results = [Search.ListingCollection]::new()
    foreach($item in $ForRent_results)
    {
        $listing = [Search.Results]::new()
        $listing.Address = $item.Address
        $listing.Baths_max = $item.Baths_high
        $listing.Baths_min = $item.Baths_low
        $listing.Beds_max = $item.Beds_high
        $listing.Beds_min = $item.Beds_low
        $listing.ImageUri = $item.ImageUri
        $listing.Latitude = $item.Latitude
        $listing.Link = $item.Link
        $listing.Longitude = $item.Longitude
        $listing.Name = $item.Name
        $listing.OriginPlatform = "forrent.com"
        $listing.PhoneNumber = $item.PhoneNumber
        $listing.Price_High = $item.Price_high
        $listing.Price_Low = $item.Price_low
        $all_results.resultList.Add($listing)
    }
    foreach($item in $MyNewPlace_results)
    {
        $listing = [Search.Results]::new()
        $listing.Address = $item.Address
        $listing.Baths_max = $item.Baths_High
        $listing.Baths_min = $item.baths_Low
        $listing.Beds_max = $item.Beds_High
        $listing.Beds_min = $item.Beds_Low
        $listing.ImageUri = $item.ImageUri
        $listing.Latitude = $item.Latitude
        $listing.Link = $item.Link
        $listing.Longitude = $item.Longitude
        $listing.Name = $item.Title
        $listing.OriginPlatform = "mynewplace.com"
        $listing.PhoneNumber = $item.PhoneNumber
        $listing.Price_High = $item.Price_High
        $listing.Price_Low = $item.Price_Low
        $all_results.resultList.Add($listing)
    }
    foreach($item in $PadMapper_results)
    {
        $all_results.resultList.Add($item)
    }
    foreach($item in $RentCafe_results)
    {
        $listing = [Search.Results]::new()
        $listing.Address = $item.AddressFormatted
        if([regex]::new("^([0-9\.]+)-([0-9\.]+)").Match($item.Baths).Success)
        {
            $listing.Baths_max  = [Convert]::ToDouble([regex]::new("^([0-9\.]+)-([0-9\.]+)").Match($item.Baths).Groups[2].Value)
            $listing.Baths_min  = [Convert]::ToDouble([regex]::new("^([0-9\.]+)-([0-9\.]+)").Match($item.Baths).Groups[1].Value)
        } else {
            $listing.Baths_max = [Convert]::ToDouble([regex]::new("^([0-9\.]+)").Match($item.Baths).Groups[1].Value)
            $listing.Baths_min  = [Convert]::ToDouble([regex]::new("^([0-9\.]+)").Match($item.Baths).Groups[1].Value)
        }
        if([regex]::new("^([0-9]+)-([0-9]+)").Match($item.Beds).Success)
        {
            $listing.Beds_max  = [Convert]::ToInt32([regex]::new("^([0-9]+)-([0-9]+)").Match($item.Beds).Groups[2].Value)
            $listing.Beds_min  = [Convert]::ToInt32([regex]::new("^([0-9]+)-([0-9]+)").Match($item.Beds).Groups[1].Value)
        } else {
            $listing.Beds_max = [Convert]::ToInt32([regex]::new("^([0-9]+)").Match($item.Beds).Groups[1].Value)
            $listing.Beds_min  = [Convert]::ToInt32([regex]::new("^([0-9]+)").Match($item.Beds).Groups[1].Value)
        }
        $listing.ImageUri = $item.ImageUrl
        $listing.Latitude = $item.Latitude
        $listing.Link = $item.DetailsUrl
        $listing.Longitude = $item.Longitude
        $listing.Name = $item.Name
        $listing.OriginPlatform = "rentcafe.com"
        $listing.PhoneNumber = $item.Phone
        if([regex]::new("\`$([0-9,]+)\s*-\s*\`$([0-9,]+)").Match($item.PriceValue).Success -and $item.PriceValue -notmatch 'Contact for Pricing')
        {
            $listing.Price_High = [Convert]::ToInt32([regex]::new(",").Replace([regex]::new("\`$([0-9,]+)\s*-\s*\`$([0-9,]+)").Match($item.PriceValue).Groups[2].Value,[string]::Empty))
            $listing.Price_Low  = [Convert]::ToInt32([regex]::new(",").Replace([regex]::new("\`$([0-9,]+)\s*-\s*\`$([0-9,]+)").Match($item.PriceValue).Groups[1].Value,[string]::Empty))
        } else {
            if($item.PriceValue -notmatch 'Contact for Pricing')
            {
                $listing.Price_High = [Convert]::ToInt32([regex]::new(",").Replace([regex]::new("\`$([0-9,]+)").Match($item.PriceValue).Groups[1].Value,[string]::Empty))
                $listing.Price_Low  = [Convert]::ToInt32([regex]::new(",").Replace([regex]::new("\`$([0-9,]+)").Match($item.PriceValue).Groups[1].Value,[string]::Empty))
            }
        }
        $listing.PropertyManager = $item.CompanyDisplayName
        $all_results.resultList.Add($listing)
    }
    foreach($item in $WalkScore_results)
    {
        $listing = [Search.Results]::new()
        $listing.Address = $item.Address
        $listing.Beds_max = $item.Beds_High
        $listing.Beds_min = $item.Beds_Low
        $listing.ImageUri = $item.ImageUri
        $listing.Latitude = $item.Latitude
        $listing.Link = $item.Link
        $listing.ListingPrice = $item.ListingPrice
        $listing.Longitude = $item.Longitude
        $listing.OriginPlatform = "WalkScore.com"
        $listing.Price_High = $item.Price_High
        $listing.Price_Low = $item.Price_Low
        $listing.PhoneNumber = $item.phoneNumber
        $all_results.resultList.Add($listing)
    }
    $class = "ContactPhone-listedby-phone-link"
    $c = 0
    $all = $Hotpads_results.count
    if($Hotpads_results)
    {
        foreach($item in $Hotpads_results)
        {
            $listing = [Search.Results]::new()
            $listing.Address = "$($item.address.street), $($item.address.city), $($item.address.state) $($item.address.zip)"
            $listing.Baths_max = [System.Convert]::ToDouble($item.modelSummary.maxBaths)
            $listing.Baths_min = [System.Convert]::ToDouble($item.modelSummary.minBaths)
            $listing.Beds_max = [System.Convert]::ToInt32($item.modelSummary.maxBeds)
            $listing.Beds_min = [System.Convert]::ToInt32($item.modelSummary.minBeds)
            $listing.ImageUri = $item.medPhotoUrl
            $coords = ([System.Net.WebClient]::New().DownloadString("https://maps.googleapis.com/maps/api/geocode/json?address=$([uri]::EscapeDataString("$($item.address.street), $($item.address.city), $($item.address.state) $($item.address.zip)"))&key=$($env:GoogleGeoCode_API_Key)") | ConvertFrom-Json).results[0].geometry.location
            $listing.Latitude = [System.Convert]::ToDouble($coords.lat)
            $listing.Longitude = [System.Convert]::ToDouble($coords.lng)
            $listing.Link = "https://hotpads.com" + $item.uriMalone
            $listing.Name = $item.name
            $listing.OriginPlatform = "hotpads.com"
            if(!$blocked)
            {
                $r = [Execute.HttpRequest]::Send($listing.Link)
            }
            if($r.HtmlDocument.title.Equals('Access to this page has been denied.') -or $blocked)
            {
                $blocked = $true
                if(!($ie))
                {
                    $ie = [System.Activator]::CreateInstance([type]::GetTypeFromCLSID([guid]::Parse("{0002DF01-0000-0000-C000-000000000046}")))
                    $ie.Visible = $true
                }
                while($ie.Busy){ sleep -m 100 }
                $ie.Navigate($listing.Link)
                while($ie.Busy){ sleep -m 100 }
                while($ie.Document.readyState -ne 'complete'){ sleep -m 100 }
                remove-variable phoneNumber -ea 0
                $html = $ie.Document.body.parentElement.outerHTML
                if(![string]::IsNullOrEmpty($html))
                {
                    $htmlfile = [System.Activator]::CreateInstance([type]::GetTypeFromCLSID([guid]::Parse("{25336920-03F9-11cf-8FD0-00AA00686F13}")))
                    $htmlfile.write([System.Text.Encoding]::Unicode.GetBytes($html))
                    $listing.PhoneNumber = $htmlfile.body.getElementsByClassName($class) |% innerText
                    RelCom $htmlfile
                    remove-variable htmlfile -ea 0
                }
            } else 
            {
                $listing.PhoneNumber = $r.HtmlDocument.body.getElementsByClassName($class) |% innerText
            }
            if($item.modelSummary.maxPrice -eq 0){
                $listing.Price_High = $item.modelSummary.minPrice
            } else {
                $listing.Price_High = $item.modelSummary.maxPrice
            }
            $listing.Price_Low = $item.modelSummary.minPrice
            $listing.PropertyManager = $item.companyName
            $all_results.resultList.Add($listing)
            $c++
            write-progress -PercentComplete ($c/$all*100) -Activity "$([math]::Round(($c/$all*100),2))%" -Status "$($c) of $($all) listings added"
        }
        if($ie)
        {
            $ie.Quit()
            relcom $ie
            if(Get-Process iexplore -ea 0){(Get-Process iexplore).kill() }
            Remove-Variable ie -ea 0
        }
    }
    foreach($item in $ApartmentFinder_results)
    {
        $listing = [Search.Results]::new()
        $listing.Address = $item.Address
        $listing.Beds_max = $item.Beds_High
        $listing.Beds_min = $item.Beds_Low
        $listing.ImageUri = $item.ImageUri
        $listing.Latitude = $item.Latitude
        $listing.Link = $item.Link
        $listing.Longitude = $item.Longitude
        $listing.Name = $item.Name
        $listing.OriginPlatform = "apartmentfinder.com"
        $listing.PhoneNumber = $item.PhoneNumber
        $listing.Price_High = [System.Convert]::ToInt32($item.Price_High.ToString())
        $listing.Price_Low = [System.Convert]::ToInt32($item.Price_Low.ToString())
        $all_results.resultList.Add($listing)
    }
    foreach($item in $ApartmentSearch_results)
    {
        $listing = [Search.Results]::new()
        $listing.Address = $item.Address1 + ' ' + $item.Address2 + ', ' + $item.City + ', ' + $item.State + ' ' + $item.ZipCode
        $listing.Baths_max = [System.Convert]::ToDouble($item.MaximumBathrooms)
        $listing.Baths_min = [System.Convert]::ToDouble($item.MinimumBathrooms)
        $listing.Beds_max = $item.MaximumBedrooms
        $listing.Beds_min = $item.MinimumBedrooms
        $listing.ImageUri  = $item.ThumbnailURL
        $listing.Latitude = [System.Convert]::ToDouble($item.Latitude)
        $listing.Link = "https://apartmentsearch.com" + $item.URL
        $listing.Longitude = [System.Convert]::ToDouble($item.Longitude)
        $listing.Name = $item.PropertyName 
        $listing.OriginPlatform = "apartmentsearch.com"
        $listing.PhoneNumber = $item.PropertyPhoneNumber 
        $listing.Price_High = $item.MaximumRent 
        $listing.Price_Low = $item.MinimumRent 
        $listing.PropertyManager = $item.ManagementCompany
        $all_results.resultList.Add($listing)
    }
    foreach($item in $Zumper_results)
    {
        $listing = [Search.Results]::new()
        $listing.Address = $item.address + ", " + $item.city + ", " + $item.state + ' ' + $item.zipcode
        $listing.Baths_max = [System.Convert]::ToDouble($item.max_bathrooms.ToString())
        $listing.Baths_min = [System.Convert]::ToDouble($item.min_bathrooms.ToString())
        $listing.Beds_max = [System.Convert]::ToInt32($item.max_bedrooms.ToString())
        $listing.Beds_min = [System.Convert]::ToInt32($item.min_bedrooms.ToString())
        $listing.ImageUri = "https://img.zumpercdn.com/" + $item.image_ids[0] + "/1280x960"
        $listing.Latitude = [System.Convert]::ToDouble($item.lat.ToString())
        $listing.Link = "https://zumper.com" + $item.url
        $listing.Longitude = [System.Convert]::ToDouble($item.lng.ToString())
        $listing.Name = $item.building_name
        $listing.OriginPlatform = "zumper.com"
        $listing.PhoneNumber = $item.phone
        $listing.Price_High = [System.Convert]::ToInt32($item.max_price.ToString())
        $listing.Price_Low = [System.Convert]::ToInt32($item.min_price.ToString())
        $listing.PropertyManager = $item.brokerage_name
        $all_results.resultList.Add($listing)
    }
    $all = $Trulia_results.Count
    $c = 0
    foreach($item in $Trulia_results)
    {
        $listing = [Search.Results]::New()
        $listing.Address = $item.location.fullLocation
        $listing.Baths_max = @([regex]::new("([0-9\.]+)").Matches($item.bathrooms.formattedValue))[-1].Value
        $listing.Baths_min = @([regex]::new("([0-9\.]+)").Matches($item.bathrooms.formattedValue))[0].value
        if($item.bedrooms.formattedValue.ToLower().Contains("studio"))
        {
            $listing.Beds_min = 0
            $listing.Beds_max = @([regex]::new("([0-9\.]+)").Matches($item.bedrooms.formattedValue))[0].Value
        } else {
            $listing.Beds_min = @([regex]::new("([0-9\.]+)").Matches($item.bathrooms.formattedValue))[0].Value
            $listing.Beds_max = @([regex]::new("([0-9\.]+)").Matches($item.bathrooms.formattedValue))[-1].Value
        }
        $r = [Execute.HttpRequest]::Send("https://www.trulia.com$($item.url)")
        if($r.HtmlDocument.Title.Equals('Access to this page has been denied.'))
        {
            $cors = [Execute.HttpRequest]::Send(
                "https://cors-anywhere.herokuapp.com/https://www.trulia.com$($item.url)",
                [System.Net.http.HttpMethod]::Get,
                ([ordered]@{"X-Requested-With"="XMLHttpRequest"})
            )
            if($cors.ResponseText -match 'This demo of CORS Anywhere should only be used for development purposes, see')
            {
                $qs = $cors.HtmlDocument.getElementsByTagName("input") | ? {$_.Type -eq 'hidden'} | select name,value | % {"$([uri]::EscapeDataString("$($_ |% Name)"))=$([uri]::EscapeDataString("$($_ |% Value)"))"}
                $Uri = "https://cors-anywhere.herokuapp.com/corsdemo?$($qs)"
                $Headers = [ordered]@{
                    "Pragma"="no-cache"
                    "Cache-Control"="no-cache"
                    "sec-ch-ua"="`"Google Chrome`";v=`"89`", `"Chromium`";v=`"89`", `";Not A Brand`";v=`"99`""
                    "sec-ch-ua-mobile"="?0"
                    "Upgrade-Insecure-Requests"="1"
                    "DNT"="1"
                    "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36"
                    "Accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
                    "Sec-Fetch-Site"="same-origin"
                    "Sec-Fetch-Mode"="navigate"
                    "Sec-Fetch-User"="?1"
                    "Sec-Fetch-Dest"="document"
                    "Referer"="https://cors-anywhere.herokuapp.com/corsdemo"
                    "Accept-Encoding"="gzip, deflate"
                    "Accept-Language"="en-US,en;q=0.9"
                }
                $r2 = [Execute.HttpRequest]::Send($uri,[System.Net.Http.HttpMethod]::Get,$Headers)
                $cors = [Execute.HttpRequest]::Send(
                    "https://cors-anywhere.herokuapp.com/https://www.trulia.com$($item.url)",
                    [System.Net.http.HttpMethod]::Get,
                    ([ordered]@{"X-Requested-With"="XMLHttpRequest"})
                )
                if($cors.HtmlDocument.Title.Equals('Access to this page has been denied.'))
                {
                    Write-Host "Trulia: " -ForegroundColor Yellow -NoNewline
                    Write-Host "$($cors.HtmlDocument.title)" -ForegroundColor Red
                } else {
                    $info = $cors.HtmlDocument.getElementById("__NEXT_DATA__") | % innerHTML | ConvertFrom-Json
                }
            } else {
                if($cors.HtmlDocument.Title.Equals('Access to this page has been denied.'))
                {
                    Write-Host "Trulia: " -ForegroundColor Yellow -NoNewline
                    Write-Host "$($cors.HtmlDocument.title)" -ForegroundColor Red
                } else {
                    $info = $cors.HtmlDocument.getElementById("__NEXT_DATA__") | % innerHTML | ConvertFrom-Json
                }
            }
        } else {
            $info = $r.HtmlDocument.getElementById("__NEXT_DATA__") | % innerHTML | ConvertFrom-Json
        }
        $listing.PhoneNumber = $info.props.homeDetails.description.contactPhoneNumber
        $listing.ImageUri = $info.props.homeDetails.media.metaTagHeroImages.url.desktop
        $listing.Latitude = [System.Convert]::ToDouble($item.location.coordinates.latitude)
        $listing.Link = "https://www.trulia.com$($item.url)"
        $listing.Longitude = [System.Convert]::ToDouble($item.location.coordinates.longitude)
        if(!$info.props.homeDetails.price.min)
        {
            $listing.Price_Low = [system.Convert]::ToInt32($info.props.homeDetails.price.price.ToString())
            $listing.Price_High= [system.Convert]::ToInt32($info.props.homeDetails.price.price.ToString())
        } else {
            $listing.Price_Low = [System.Convert]::ToInt32($info.props.homeDetails.price.min.ToString())
            $listing.Price_High = [System.Convert]::ToInt32($info.props.homeDetails.price.max.ToString())
        }
        $listing.Name =  $info.props.homeDetails.name
        $listing.OriginPlatform = "trulia.com"
        $all_results.resultList.Add($listing)
        $c++
        write-progress -PercentComplete ($c/$all*100) -Status "$([Math]::Round(($c/$all*100),2))%" -Activity "trulia.com :: $($c) of $($all) listings added"
    }
    $all = $Zillow_results.Count
    $c = 0
    foreach($item in $Zillow_results)
    {
        remove-variable r,j -ea 0
        $r = [Execute.HttpRequest]::Send("https://zillow.com$($item.detailUrl)")
        if($r.HtmlDocument.getElementById("__NEXT_DATA__"))
        {
            $j = $r.HtmlDocument.getElementById("__NEXT_DATA__") |% innerHTML | ConvertFrom-Json
        }
        $listing = [Search.Results]::New()
        $listing.Address = $item.Address
        $listing.Baths_min = @([regex]::new("([0-9\.]+)").Matches($j.props.initialData.building.adTargets.ba))[0].Value
        $listing.Baths_max =  @([regex]::new("([0-9\.]+)").Matches($j.props.initialData.building.adTargets.ba))[-1].Value
        $listing.Beds_min = @([regex]::new("\d").Matches($j.props.initialData.building.adTargets.bd))[0].Value
        $listing.Beds_max = @([regex]::new("\d").Matches($j.props.initialData.building.adTargets.bd))[-1].Value
        $listing.ImageUri = $item.imgSrc
        $listing.Latitude = [System.convert]::ToDouble($j.props.initialData.building.latitude)
        $listing.Link = "https://zillow.com$($item.detailUrl)"
        $listing.Longitude = [System.Convert]::ToDouble($j.props.initialData.building.longitude)
        $listing.Name = $j.props.initialData.building.buildingName
        $listing.OriginPlatform = "zillow.com"
        $listing.PhoneNumber = $j.props.initialData.building.buildingPhoneNumber
        $listing.Price_Low = [System.Convert]::ToInt32([regex]::new(",").Replace([regex]::new("([0-9,]+)").Match($item.price).Groups[1].Value,[string]::Empty))
        $listing.Price_High = [System.Convert]::ToInt32([regex]::new(",").Replace([regex]::new("([0-9,]+)").Match($item.price).Groups[1].Value,[string]::Empty))
        $listing.ListingPrice = [System.Convert]::ToInt32([regex]::new(",").Replace([regex]::new("([0-9,]+)").Match($item.price).Groups[1].Value,[string]::Empty))
        $all_results.resultList.Add($listing)
        $c++
        write-progress -PercentComplete ($c/$all*100) -Status "$([Math]::Round(($c/$all*100),2))%" -Activity "zillow.com :: $($c) of $($all) listings added"
    }
    $all_results.resultList | ConvertTo-Json | out-file "$($ENV:USERPROFILE)\Desktop\AllListings.json"
    $dt = [System.Data.DataTable]::new("Apartment Listings")
    $dt.Columns.Add([System.Data.DataColumn]::New("Info"))
    $dt.Columns.Add([System.Data.DataColumn]::new("Link"))
    $dt.Columns.Add([System.Data.DataColumn]::new("Map"))
    $dt.Columns.Add([System.Data.DataColumn]::new("Address"))
    $dt.Columns.Add([System.Data.DataColumn]::new("Rental Rate From",[int32]))
    $dt.Columns.Add([System.Data.DataColumn]::new("Rental Rate Ceiling",[Int32]))
    $dt.Columns.Add([System.Data.DataColumn]::new("Minimum Bedrooms",[int32]))
    $dt.Columns.Add([System.Data.DataColumn]::new("Maximum Bedrooms",[int32]))
    $dt.Columns.Add([System.Data.DataColumn]::new("Minimum Bathrooms",[double]))
    $dt.Columns.Add([System.Data.DataColumn]::new("Maximum Bathrooms",[double]))
    $dt.Columns.Add([System.Data.DataColumn]::new("Phone Number Property Management"))
    $dt.Columns.Add([System.Data.DataColumn]::new("Building Name"))
    $dt.Columns.Add([System.Data.DataColumn]::new("Property Management Company Name"))
    $dt.Columns.Add([System.Data.DataColumn]::new("Email Address"))
    $dt.Columns.Add([System.Data.DataColumn]::new("Platform of Origin"))
    $dt.Columns.Add([System.Data.DataColumn]::new("Commute Time",[double]))
    $c = 0;
    
    $all = $all_results.resultList.Count;
    $start = [datetime]::Now
    $tasks = @()
    $columns = $dt.Columns | select ColumnName,DataType
    $create_table = "CREATE TABLE ApartmentListings ("
    for($i = 0; $i -lt $Columns.Count; $i++)
    {
        $name = $Columns[$i].ColumnName.Replace(' ','_').ToLower()
        if($columns[$i].DataType.Name.split(' ')[0] -eq 'string')
        {
            $type = "TEXT(4000)"
        } else {
            $type = $columns[$i].DataType.Name.split(' ')[0]
        }
        if($i -eq ($Columns.Count - 1))
        {
            $create_table = $create_table + "`r`n    $($name) $($type)"
        } else
        {
            $create_table = $create_table + "`r`n    $($name) $($type),"
        }
    }
    $create_table = $create_table + "`r`n);"
    $con = [System.Data.SQLite.SQLiteConnection]@{
        ConnectionString = "Data Source=:memory:"
    }
    $con.Open()
    $cmd = [System.Data.SQLite.SQLiteCommand]::New($con);
    $cmd.CommandText = $create_table
    $cmd.ExecuteNonQuery()
    
    foreach($item in $all_results.resultList)
    {
        if($commute_result)
        {
            $tasks += [Search.Convert]::ToDataTable($cmd,$item,$dt,$commute_result)
        } else {
            $tasks += [Search.Convert]::ToDataTable($cmd,$item,$dt)
        }
        while($tasks.Where({!$_.IsCompleted}).Count -gt 3){}
        $no = [datetime]::Now
        $el = ($no - $start).TotalMilliseconds
        if($tasks.Where({$_.IsCompleted}).Count -eq 0)
        {
            $c = $tasks.Count
            $re = ($el*($all/$c)) - $el
            ($no.AddMilliseconds($re) - $no) | select Days,Hours,Minutes,Seconds,Milliseconds | % {
                $ts = "$($_ |% Days) days :: $($_ |% hours) hours :: $($_ |% Minutes) minutes :: $($_ |% Seconds) seconds ::$($_ | % milliseconds)ms"
            }
            Write-Progress -PercentComplete ($c/$all*100) -Status "$([math]::Round(($c/$all*100),2))% :: $($ts)" -Activity "all platforms :: $($c) of $($all) tasks started"
        } else {
            $c = $tasks.Where({$_.IsCompleted}).Count
            $re = ($el*($all/$c)) - $el
            ($no.AddMilliseconds($re) - $no) | select Days,Hours,Minutes,Seconds,Milliseconds | % {
                $ts = "$($_ |% Days) days :: $($_ |% hours) hours :: $($_ |% Minutes) minutes :: $($_ |% Seconds) seconds ::$($_ | % milliseconds)ms"
            }
            Write-Progress -PercentComplete ($c/$all*100) -Status "$([math]::Round(($c/$all*100),2))% :: $($ts)" -Activity "all platforms :: $($c) of $($all) tasks completed"
        }
    }
    while($tasks.Where({!$_.IsCompleted}).Count -gt 0)
    {
        $c = $tasks.Where({$_.IsCompleted}).Count
        $no = [datetime]::Now
        $el = ($no - $start).TotalMilliseconds
        $re = ($el*($all/$c)) - $el
        ($no.AddMilliseconds($re) - $no) | select Days,Hours,Minutes,Seconds,Milliseconds | % {
            $ts = "$($_ |% Days) days :: $($_ |% hours) hours :: $($_ |% Minutes) minutes :: $($_ |% Seconds) seconds ::$($_ | % milliseconds)ms"
        }
        Write-Progress -PercentComplete ($c/$all*100) -Status "$([math]::Round(($c/$all*100),2))% :: $($ts)" -Activity "all platforms :: $($c) of $($all) tasks completed"
    }
    $outfile = "$($ENV:USERPROFILE)\Desktop\AllListings.csv"
    $fileCount = 0
    while([io.file]::Exists($outfile))
    {
        $folder = [System.IO.FileInfo]::New("$($ENV:USERPROFILE)\Desktop\AllListings.csv").Directory.FullName
        $file = [System.IO.FileInfo]::New("$($ENV:USERPROFILE)\Desktop\AllListings.csv").Name
        $outfile = $folder + "\" + "$($filecount)_$($file)"
        $fileCount++
    }
    $cmd = [System.Data.SQLite.SQLiteCommand]::new($con)
    $cmd.CommandText = "SELECT * FROM ApartmentListings"
    $adapter = [System.Data.SQLite.SQLiteDataAdapter]::new($cmd)
    $dataset = [System.Data.DataSet]::new()
    $adapter.Fill($dataset)
    $dt = $dataset.Tables[0]
    $folder = [System.IO.FileInfo]::New($outfile).Directory.FullName
    $name = [System.IO.Path]::GetFileNameWithoutExtension($outfile)
    $htmlFile = $folder + "\" + "$($name).html"
    $dt | Export-Csv $outfile -NoTypeInformation
    excel2table $outfile $htmlFile
    cmd /c "`"C:\Program Files\Git\usr\bin\patch.exe`" $($htmlFile) Resources\patch.txt"
    if(!$Keep_csv_file)
    {
        Remove-Item $outfile -ea 0
    }
    start $htmlFile
    cd "$($start_dir)"
