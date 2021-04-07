@{
RootModule = 'Get-AparmentListings.psm1'
ModuleVersion = '1.0.0'
GUID = '{be79d8b5-593c-4411-b0df-d091dcb954d4}'
Author = 'nstevens1040'
Copyright = '(c) 2021 nstevens1040. All rights reserved.'
Description = 'Aggregates search results from apartmentfinder.com, apartmentsearch.com, forrent.com, hotpads.com, mynewplace.com, padmapper.com, rentcafe.com, trulia.com, walkscore.com, zillow.com, and zumper.com (& technically also domu.com, but that is only for Chicago)'
PowerShellVersion = '5.1'
# DotNetFrameworkVersion = ''
CLRVersion = '4.0'
RequiredAssemblies = @(".\lib\Execute.HttpRequest.dll",".\lib\Newtonsoft.Json.dll")
# Script files (.ps1) that are run in the caller's environment prior to importing this module.
ScriptsToProcess = @(
    ".\Public\Get-ApartmentListings_ApartmentFinder.ps1",
    ".\Public\Get-ApartmentListings_ApartmentSearch.ps1",
    ".\Public\Get-ApartmentListings_ForRent.ps1",
    ".\Public\Get-ApartmentListings_Hotpads.ps1",
    ".\Public\Get-ApartmentListings_MyNewPlace.ps1",
    ".\Public\Get-ApartmentListings_PadMapper.ps1",
    ".\Public\Get-ApartmentListings_RentCafe.ps1",
    ".\Public\Get-ApartmentListings_Trulia.ps1",
    ".\Public\Get-ApartmentListings_WalkScore.ps1",
    ".\Public\Get-ApartmentListings_Zillow.ps1",
    ".\Public\Get-ApartmentListings_Zumper.ps1"
)
# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()
# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = 'Get-ApartmentListings.Format.ps1xml'
FunctionsToExport = 'Get-ApartmentListings'
CmdletsToExport = 'Get-ApartmentListings'
FileList = @(
    ".\LICENSE",
    ".\README.md",
    ".\en-US\about_Find-Apartment.help.txt",
    ".\lib\Execute.HttpRequest.dll",
    ".\lib\Execute.HttpRequest.pdb",
    ".\Public\Get-ApartmentListings_ApartmentFinder.ps1",
    ".\Public\Get-ApartmentListings_ApartmentSearch.ps1",
    ".\Public\Get-ApartmentListings_ForRent.ps1",
    ".\Public\Get-ApartmentListings_Hotpads.ps1",
    ".\Public\Get-ApartmentListings_MyNewPlace.ps1",
    ".\Public\Get-ApartmentListings_PadMapper.ps1",
    ".\Public\Get-ApartmentListings_RentCafe.ps1",
    ".\Public\Get-ApartmentListings_Trulia.ps1",
    ".\Public\Get-ApartmentListings_WalkScore.ps1",
    ".\Public\Get-ApartmentListings_Zillow.ps1",
    ".\Public\Get-ApartmentListings_Zumper.ps1"   
)
PrivateData = @{
    PSData = @{
        Tags = @(
            "search",
            "apartments",
            "apartment",
            "listings",
            "rental",
            "apartmentfinder",
            "apartmentsearch",
            "forrent",
            "hotpads",
            "mynewplace",
            "padmapper",
            "rentcafe",
            "trulia",
            "walkscore",
            "zillow",
            "zumper"
        )
        LicenseUri = 'https://raw.githubusercontent.com/nstevens1040/Get-ApartmentListings/main/LICENSE'
        ProjectUri = 'https://github.com/nstevens1040/Get-ApartmentListings'
    }

}
# HelpInfo URI of this module
# HelpInfoURI = ''
# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''
}
