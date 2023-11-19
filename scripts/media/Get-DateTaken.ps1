<#
.SYNOPSIS
    Retrieves the date when a file was taken or created.

.DESCRIPTION
    The Get-DateTaken function uses the Windows Shell COM object to access file properties that aren't directly accessible through .NET's System.IO classes. It attempts to retrieve the "Date taken" property of the file. If this property is not available, it retrieves the "Date created" property instead. The retrieved date string is sanitized and parsed into a DateTime object.

.PARAMETER file
    The file for which the date taken or created is to be retrieved. This parameter is mandatory.

.OUTPUTS
    DateTime
    Returns the date when the file was taken or created.

.EXAMPLE
    PS C:\> Get-DateTaken -file $file
    This command retrieves the date when the file represented by the $file variable was taken or created.
#>
[OutputType([datetime])]
param (
    [Parameter(Mandatory = $true)]
    [System.IO.FileInfo]
    $file
)

# $DateFormat = 'dd.MM.yyyy HH:mm'
$DateTakenWinApi = 12
$DateCreatedWinApi = 4

if ($null -eq $Shell) {
    $Shell = New-Object -ComObject shell.application
}
 
$dir = $Shell.Namespace($_.DirectoryName)
$DateTakenString = $dir.GetDetailsOf($dir.ParseName($_.Name), $DateTakenWinApi)
if ($DateTakenString -eq '') {
    $DateTakenString = $dir.GetDetailsOf($dir.ParseName($_.Name), $DateCreatedWinApi)
}
# sanitze string
$DateTakenString = $DateTakenString -replace '[^0-9\.\:\ \/]', ''
# parse to DateTime
$DateTaken = Get-Date $DateTakenString # -Format $DateFormat
$DateTaken
