<#
.DESCRIPTION
Converts a file to JpegXl

.EXAMPLE
$f = ConvertTo-JpegXl -Source "pic.jpeg" -LosslessJpeg; ConvertTo-PngFromJpegXl -Source $f
$f = ConvertTo-JpegXl -Source "pic.jpeg" -Effort 5 -Quality 75; ConvertTo-PngFromJpegXl -Source $f
#>
function global:ConvertTo-JpegXl {
    param (
        [Parameter()]
        [ValidateScript({ Test-Path $_ })]
        [System.IO.FileInfo]
        $Source,
        [Parameter()]
        [ValidateRange(0, 100)]
        [int]
        $Quality = 90,
        [Parameter()]
        [ValidateRange(1, 9)]
        [int]
        $Effort = 7,
        [Parameter()]
        [switch]
        $LosslessJpeg
    )
    Check-JpegXlCapabitlies

    # the input can be PNG, APNG, GIF, JPEG, PPM, PFM, or PGX
    $allowedExtentions = @("png", "apng", "gif", "jpg", "jpeg", "ppm", "pfm", "pgx")
    $ext = $Source.Extension.ToLower().Trim(".")
    if ($allowedExtentions -notcontains $ext) {
        Write-Error "File extension $($Source.Extension) not supported, only $($allowedExtentions -join ", ") are supported"
        return
    }

    if ($ext -eq "jpeg" -or $ext -eq "jpg") {
        if (-not $LosslessJpeg) {
            Write-Warning "Your input is a jpeg, consider -LosslessJpeg for less size and excatly equal quality"
        }
    }

    # Quality Recommended range: 68 .. 96. Allowed range: 0 .. 100.
    if ($Quality -lt 68 -or $Quality -gt 96) {
        Write-Warning "Recommended quality is be between 68 and 96"
    }

    $out = $Source.FullName + ".jxl"

    $cmd = "cjxl "
    if ($LosslessJpeg) {
        $cmd += " --lossless_jpeg=1 "
    }
    else {
        $cmd += " --lossless_jpeg=0 "
        $cmd += " -q $Quality "
    }
    $cmd += " -e $Effort "
    $cmd += "  ""$($Source.FullName)"" ""$($out)"""
    Write-Host $cmd

    $start = Get-Date
    Invoke-Expression $cmd
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to convert file to JpegXl"
        return
    }

    Write-Host "Duration:    $((Get-Date) - $start)"

    $sourceLength = [math]::Round($Source.Length / 1KB, 2)
    $afterLength = [math]::Round((Get-Item $out).Length / 1KB, 2)
    Write-Host "Size before: $($sourceLength ) KB"
    Write-Host "Size after:  $($afterLength) KB"
    $diff = $sourceLength - $afterLength
    Write-Host "Diff:        $([math]::Round(($diff/$sourceLength ) * 100, 2)) %"
    if ($diff -lt 0) {
        Write-Host "Warning:     File is bigger than before" -ForegroundColor Yellow
    }

    Get-ChildItem $out
}

<#
.DESCRIPTION
Converts a file from JpegXl to PNG

.EXAMPLE
$f = ConvertTo-JpegXl -Source "pic.jpeg" -LosslessJpeg; ConvertTo-PngFromJpegXl -Source $f
$f = ConvertTo-JpegXl -Source "pic.jpeg" -Effort 5 -Quality 75; ConvertTo-PngFromJpegXl -Source $f
#>
function global:ConvertTo-PngFromJpegXl {
    param (
        [Parameter()]
        [ValidateScript({ Test-Path $_ })]
        [System.IO.FileInfo]
        $Source
    )

    $out = $Source.FullName + ".png"

    $cmd = "djxl "
    $cmd += " ""$($Source.FullName)"" ""$($out)"""

    $start = Get-Date
    Invoke-Expression $cmd

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to convert file to JpegXl"
        return
    }

    Write-Host "Duration:    $((Get-Date) - $start)"
    Get-ChildItem $out
}

function Check-JpegXlCapabitlies {
    $cmd = "cjxl"
    if ($null -eq (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Error "Command $cmd not found, please install it first and set it to path or alias. E.g. with 'workplace-sync -host ws.hdev.io -name jxl'"
        return $false
    }

    $cmd = "djxl"
    if ($null -eq (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Error "Command $cmd not found, please install it first and set it to path or alias. E.g. with 'workplace-sync -host ws.hdev.io -name jxl'"
        return $false
    }
}

<#
JPEG XL encoder v0.8.2 954b460 [AVX2,SSE4,SSSE3,Unknown]
Usage: C:\ws\cjxl.exe INPUT OUTPUT [OPTIONS...]
 INPUT
    the input can be PNG, APNG, GIF, JPEG, PPM, PFM, or PGX
 OUTPUT
    the compressed JXL output file
 -d maxError, --distance=maxError
    Max. butteraugli distance, lower = higher quality.
    0.0 = mathematically lossless. Default for already-lossy input (JPEG/GIF).
    1.0 = visually lossless. Default for other input.
    Recommended range: 0.5 .. 3.0. Allowed range: 0.0 ... 25.0.
    Mutually exclusive with --quality.
 -q QUALITY, --quality=QUALITY
    Quality setting (is remapped to --distance).    100 = mathematically lossless. Default for already-lossy input (JPEG/GIF).
    Other input gets encoded as per --distance default,
    which corresponds to quality 90.
    Quality values roughly match libjpeg quality.
    Recommended range: 68 .. 96. Allowed range: 0 .. 100.
    Mutually exclusive with --distance.
 -e EFFORT, --effort=EFFORT
    Encoder effort setting. Range: 1 .. 9.
     Default: 7. Higher number is more effort (slower).
 --brotli_effort=B_EFFORT
    Brotli effort setting. Range: 0 .. 11.
    Default: 9. Higher number is more effort (slower).
 -p, --progressive
    Enable progressive/responsive decoding.
 --resampling=-1|1|2|4|8
    Resampling for extra channels. Default of -1 applies resampling only for low quality. Value 1 does no downsampling (1x1), 2 does 2x2 downsampling, 4 is for 4x4 downsampling, and 8 for 8x8 downsampling.
 -v, --verbose
    Verbose output; can be repeated, also applies to help (!).
 -h, --help
    Prints this help message (use -v to see more options).

JPEG XL decoder v0.8.2 954b460 [AVX2,SSE4,SSSE3,Unknown]
Usage: C:\ws\djxl.exe INPUT OUTPUT [OPTIONS...]
 INPUT
    The compressed input file.
 OUTPUT
    The output can be (A)PNG with ICC, JPG, or PPM/PFM.
 -V, --version
    Print version number and exit.
 --num_reps=N
    Sets the number of times to decompress the image. Used for benchmarking, the default is 1.
 --num_threads=N
    Sets the number of threads to use. The default 0 value means the machine default.
 --bits_per_sample=N
    Sets the output bit depth. The 0 value (default for PNM output) means the original (input) bit depth. The -1 value (default for other codecs) means the full bit depth of the output pixel format.
 --display_nits=N
    If set to a non-zero value, tone maps the image the given peak display luminance.
 --color_space=COLORSPACE_DESC
    Sets the output color space of the image. This flag has no effect if the image is not XYB encoded.
 -s N, --downsampling=N
    If set and the input JXL stream is progressive and contains hints for target downsampling ratios, the decoder will skip any progressive passes that are not needed to produce a partially decoded image intended for this downsampling ratio.
 --allow_partial_files
    Allow decoding of truncated files.
 -j, --pixels_to_jpeg
    By default, if the input JPEG XL contains a recompressed JPEG file, djxl reconstructs the exact original JPEG file. This flag causes the decoder to instead decode the image to pixels and encode a new (lossy) JPEG. The output file if provided must be a .jpg or .jpeg file.
 -q N, --jpeg_quality=N
    Sets the JPEG output quality, default is 95. Setting an output quality implies --pixels_to_jpeg.
 --norender_spotcolors
    Disables rendering spot colors.
 --preview_out=FILENAME
    If specified, writes the preview image to this file.
 --icc_out=FILENAME
    If specified, writes the ICC profile of the decoded image to this file.
 --orig_icc_out=FILENAME
    If specified, writes the ICC profile of the original image to this file. This can be different from the ICC profile of the decoded image if --color_space was specified, or if the image was XYB encoded and the color conversion to the original profile was not supported by the decoder.
 --metadata_out=FILENAME
    If specified, writes decoded metadata info to this file in JSON format. Used by the conformance test script
 --print_read_bytes
    Print total number of decoded bytes.
 --quiet
    Silence output (except for errors).
 -h, --help
    Prints this help message (use -v to see more options).    
#>