# Get-ApartmentListings  
Aggregates search results from:
  - apartmentfinder.com
  - apartmentsearch.com
  - forrent.com
  - hotpads.com
  - mynewplace.com
  - padmapper.com
  - rentcafe.com
  - trulia.com
  - walkscore.com
  - zillow.com
  - and zumper.com  
  
This script uses **[excel2table](https://github.com/pyexcel/excel2table)** to create the final table of results.  

# Usage  
This script will only work using **Windows PowerShell** and will not work with PowerShell Core.  
I've tested and confirmed that the script runs without error using **Windows PowerShell 5.1.14393.4467**.  
  
**Fair warning:** the script **may take over one hour** to complete, depending on the city you're conducting your search in (Chicago, IL took 1 hour, 42 minutes, & 52 seconds and produced 7094 results). The purpose of this script is not to *quickly* gather apartment listing results, but to gather apartment listings and their granular details. That being said, the script will use 4 threads only because **my** CPU has four cores. Additionally, my machine has 12GB RAM so it's hard to say how well it will perform with any amount of RAM less than 12GB as I have seen the script's memory usage jump over 2GB in some cases.  
  
Before you begin, you will need these environment variables set up:
   - **[Google Places](https://developers.google.com/places/web-service/get-api-key)** - GooglePlaces_API_Key
   - **[Google Distance](https://developers.google.com/maps/documentation/distance-matrix/get-api-key)** - GoogleDistance_API_Key
   - **[Google GeoCode](https://developers.google.com/maps/documentation/geocoding/get-api-key)** - GoogleGeoCode_API_Key
  
1. Launch Windows PowerShell  
2. Clone this repo and change directory to the repo's root folder.  
```ps1
git clone https://github.com/nstevens1040/Get-ApartmentListings.git
cd .\Get-ApartmentListings\
```  
3. Run the script (example below).  
```ps1
. .\Get-ApartmentListings.ps1 -City Chicago -State_Code IL -Keep_csv_file -Commute_To '1060 W Addison St, Chicago, IL 60613'
```  

I'll write more about the parameters if necessary, but for now I'll rely on the idea that they are, more or less, self explanatory.  
   - **City** - The city you're conducting your search in.
   - **State_Code** - The state where you're conducting your search formatted as a two-character state code (ex. Illinois is IL, California is CA, New York is NY, etc.)
   - **Keep_csv_file** - The database that is generated from the results gets converted to a datatable and exported as a CSV file so that it can be used as input for **excel2table.exe** to create a nice HTML table. This switch tells the script **not** to delete the CSV file, because otherwise it will.
   - **Commute_To** - Optional parameter to include a **string address** to where you expect to be commuting regularly so that a **commute time** column will be included in the results as a sortable member.  

4. View your results. The final table of results will be an HTML file located at ```%USERPROFILE%\Desktop\AllListings.html``` or ```C:\Users\%USERNAME%\Desktop\AllListings.html```. The filename may vary if you've run the script more than once without deleting the results from the last time you ran the script.  
  
