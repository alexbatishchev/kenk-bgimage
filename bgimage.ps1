# v1.02
# 2023-12-31 added auto-applying, text position fixed, file now saved to user's temp folder

Function Set-WallPaper {
<#

    .SYNOPSIS
    Applies a specified wallpaper to the current user's desktop
	via https://www.joseespitia.com/2017/09/15/set-wallpaper-powershell-function/
    
    .PARAMETER Image
    Provide the exact path to the image
 
    .PARAMETER Style
    Provide wallpaper style (Example: Fill, Fit, Stretch, Tile, Center, or Span)
  
    .EXAMPLE
    Set-WallPaper -Image "C:\Wallpaper\Default.jpg"
    Set-WallPaper -Image "C:\Wallpaper\Background.jpg" -Style Fit
  
#>
 
param (
    [parameter(Mandatory=$True)]
    # Provide path to image
    [string]$Image,
    # Provide wallpaper style that you would like applied
    [parameter(Mandatory=$False)]
    [ValidateSet('Fill', 'Fit', 'Stretch', 'Tile', 'Center', 'Span')]
    [string]$Style
)
 
$WallpaperStyle = Switch ($Style) {
  
    "Fill" {"10"}
    "Fit" {"6"}
    "Stretch" {"2"}
    "Tile" {"0"}
    "Center" {"0"}
    "Span" {"22"}
  
}
 
If($Style -eq "Tile") {
 
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 1 -Force
 
}
Else {
 
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 0 -Force
 
}
 
Add-Type -TypeDefinition @" 
using System; 
using System.Runtime.InteropServices;
  
public class Params
{ 
    [DllImport("User32.dll",CharSet=CharSet.Unicode)] 
    public static extern int SystemParametersInfo (Int32 uAction, 
                                                   Int32 uParam, 
                                                   String lpvParam, 
                                                   Int32 fuWinIni);
}
"@ 
  
    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendChangeEvent = 0x02
  
    $fWinIni = $UpdateIniFile -bor $SendChangeEvent
  
    $ret = [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
}


######
Add-Type -AssemblyName System.Drawing
$sText = $env:computername
$filename = $env:TEMP + "\$sText.bmp"


$bmp = new-object System.Drawing.Bitmap 500,500
$font = new-object System.Drawing.Font Consolas,24 
$iMinBG = 10
$iMaxBG = 100

$iBR = Get-Random -Minimum $iMinBG -Maximum $iMaxBG
$iBG = Get-Random -Minimum $iMinBG -Maximum $iMaxBG
$iBB = $iMaxBG*2 - $iBR - $iBG
$brushBG = New-Object Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, $iBR, $iBG,$iBB))

$iMinFG = 120
$iMaxFG = 240
$iFR = Get-Random -Minimum $iMinFG -Maximum $iMaxFG
$iFG = Get-Random -Minimum $iMinFG -Maximum $iMaxFG
$iFB = $iMaxFG*2 - $iFR - $iFG
if ($iFB -ge 255) {$iFB = 255}
$brushFg = New-Object Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, $iFR, $iFG, $iFB))

$graphics = [System.Drawing.Graphics]::FromImage($bmp) 
$graphics.FillRectangle($brushBg,0,0,$bmp.Width,$bmp.Height) 
$graphics.RotateTransform(-45)
$graphics.DrawString($sText,$font,$brushFg,-200,330) 

$bmp.Save($filename) 
write-host "saved image to [$filename]"
$bRet = Set-WallPaper -Image $filename -Style Tile
$graphics.Dispose() 