@echo off
setlocal enabledelayedexpansion

set "inputFile=MCL.csv"
set "inputFile2=BarcodeToSKU.csv"
set "outputFile=output.txt"

:LooptoHere

set /p barcode="Enter Barcode: "

REM Initialize flag to check if barcode is found in both files
set "foundInBarcodeToSKU=0"
set "foundInMCL=0"

REM Search for SKU based on entered barcode in BarcodeToSKU.csv
for /f "tokens=1,* delims=," %%a in (%inputFile2%) do (
    if "%%a" equ "%barcode%" (
        set sku=%%b
        set foundInBarcodeToSKU=1
        goto FoundSKU
    )
)

REM If barcode not found in BarcodeToSKU.csv, inform the user and restart the loop
if !foundInBarcodeToSKU! equ 0 (
    echo Barcode not found in the BarcodeToSKU.csv file. Please contact Roshan Varughese on workplace with the barcode.
    pause
    goto LooptoHere
)

:FoundSKU
REM Trim SKU to only first two sections (Product ID/Color)
for /f "tokens=1-2 delims=/" %%a in ("!sku!") do (
    set "trimmedSKU=%%a/%%b"
)

REM Search for details based on trimmed SKU in MCL.csv
for /f "tokens=1-4 delims=," %%a in (%inputFile%) do (
    if "%%a" equ "%trimmedSKU%" (
        set name=%%b
        set color=%%c
        set now=%%d
        set foundInMCL=1
    )
)

REM If barcode not found in MCL.csv, inform the user and restart the loop
if !foundInMCL! equ 0 (
    echo Barcode details not found in the MCL.csv file. Not a Clearance Product.
    pause
    goto LooptoHere
)

REM Create output.txt file with details
(
    echo ^^XA~TA000~JSN~^^LT0^^MNW^^MTT^^PON^^PMN^^LH0,0^^JMA^^PR2,2~SD15^^JUS^^LRN^^CI0^^XZ>> %outputFile%
    echo ^^XA^^MMT^^LL0160^^PW320^^LS0>> %outputFile%
    echo ^^FT89,38^^A0N,30,27^^FH\^^FDClearance^^FS>> %outputFile%
    echo ^^FT35,145^^A0N,38,38^^FH\^^FDNow^^FS>> %outputFile%

    echo ^^FT27,65^^A0N,23,24^^FH\^^FD-/-/--^^FS>> %outputFile%

    echo ^^FT27,83^^A0N,17,16^^FH\^^>> %outputFile%
    echo FD!name!>> %outputFile%
    echo ^^FS>> %outputFile%

    echo ^^FT186,64^^A0N,17,16^^FH\^^>> %outputFile%
    echo FD!sku!>> %outputFile%
    echo ^^FS>> %outputFile%

    echo ^^FT27,100^^A0N,17,16^^FH\^^>> %outputFile%
    echo FD!color!>> %outputFile%
    echo ^^FS>> %outputFile%

    echo ^^FT133,145^^A0N,38,38^^FH\^^>> %outputFile%
    echo FD!now!>> %outputFile%
    echo ^^FS>> %outputFile%

    echo ^^PQ1,0,1,Y^^XZ>> %outputFile%
)

REM Copy and clean up
copy output.txt \\127.0.0.1\Zebra
pause
del output.txt
goto LooptoHere
