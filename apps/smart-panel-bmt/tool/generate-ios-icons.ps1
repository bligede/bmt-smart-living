$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$source = [Drawing.Image]::FromFile((Join-Path $root 'assets/brand/bmt-m-only.png'))
function Save-BrandImage([string]$target, [int]$size) {
    $bitmap = [Drawing.Bitmap]::new($size, $size, [Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $graphics = [Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.Clear([Drawing.Color]::White)
        $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $width = $size * 0.72
        $height = $width * $source.Height / $source.Width
        $graphics.DrawImage($source, [single](($size-$width)/2), [single](($size-$height)/2), [single]$width, [single]$height)
        $bitmap.Save($target, [Drawing.Imaging.ImageFormat]::Png)
    } finally { $graphics.Dispose(); $bitmap.Dispose() }
}
try {
    $icons = Join-Path $root 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    $manifest = Get-Content -LiteralPath (Join-Path $icons 'Contents.json') -Raw | ConvertFrom-Json
    foreach ($item in $manifest.images) {
        $size = [int]([double]($item.size -split 'x')[0] * [double]($item.scale -replace 'x',''))
        Save-BrandImage (Join-Path $icons $item.filename) $size
    }
    $launch = Join-Path $root 'ios/Runner/Assets.xcassets/LaunchImage.imageset'
    Save-BrandImage (Join-Path $launch 'LaunchImage.png') 200
    Save-BrandImage (Join-Path $launch 'LaunchImage@2x.png') 400
    Save-BrandImage (Join-Path $launch 'LaunchImage@3x.png') 600
} finally { $source.Dispose() }
Write-Output 'Generated opaque iOS icons from the approved BMT mark.'
