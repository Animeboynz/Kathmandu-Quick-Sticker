@echo off
setlocal enabledelayedexpansion

set "inputFile=MCL.csv"
set "inputFile2=BarcodeToSKU.csv"
set "outputFile=output.txt"

:LooptoHere

set /p barcode="Enter Barcode: "

REM Search for SKU based on entered barcode
for /f "tokens=1,* delims=," %%a in (%inputFile2%) do (
    if "%%a" equ "%barcode%" (
        set sku=%%b
        goto FoundSKU
    )
)
echo Barcode not found in the CSV file.
pause
goto LooptoHere

:FoundSKU
REM Trim SKU to only first two sections (Product ID/Color)
for /f "tokens=1-2 delims=/" %%a in ("!sku!") do (
    set "trimmedSKU=%%a/%%b"
)

for /f "tokens=1-4 delims=," %%a in (%inputFile%) do (
    if "%%a" equ "%trimmedSKU%" (
        set name=%%b
        set color=%%c
        set now=%%d
    )
)

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

copy output.txt \\127.0.0.1\Zebra
pause
del output.txt
goto LooptoHere
