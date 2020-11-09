  Add-Type -AssemblyName System.Drawing
  $sText = $env:computername

  $filename = [Environment]::GetFolderPath("Desktop") + "\$sText.bmp"

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
	$graphics.DrawString($sText,$font,$brushFg,-100,400) 

	$bmp.Save($filename) 
	$graphics.Dispose() 
	
  # задание обоев через реестр не работает без ребута или форсирования установок, так что этот код в продакшн не идёт
	#Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\" -Name "Wallpaper" -Value $filename -force
	#Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\" -Name "TileWallpaper" -Value "1" -force
	#Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\" -Name "WallpaperStyle " -Value "2" -force
# Окрыть картинку в дефолтном приложении на хосте (обычно это паинт и в нём можно сразу поставить фон плиткой)
	Invoke-Item $filename  

