@echo off
ECHO ==========================
ECHO Creating cert ...
set /p Company="Please provide the company name you want to sign as: "
ECHO ===========================
.\makecert.exe -len 2048  "%Company%.cer" -n "CN=%Company%"  -r -sv "%Company%.pvk"
ECHO ==========================
ECHO Creating pfx from cert ...
ECHO ===========================
.\pvk2pfx.exe -pvk "%Company%.pvk" -spc "%Company%.cer" -pfx "%Company%.pfx"
ECHO ==========================
ECHO Signing time....
ECHO ===========================
set /p BinToSign="Please provide the path to the binary to sign: "
.\signtool.exe sign /fd sha256 /f ".\%Company%.pfx" /t http://timestamp.comodoca.com/authenticode %BinToSign%
ECHO ==========================
ECHO Cleaning up...
ECHO ===========================
del "%Company%.pvk"
del "%Company%.cer"
del "%Company%.pfx"
PAUSE
