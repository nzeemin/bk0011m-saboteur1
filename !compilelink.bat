@echo off

rem Define ESCchar to use in ANSI escape sequences
rem https://stackoverflow.com/questions/2048509/how-to-echo-with-different-colors-in-the-windows-command-line
for /F "delims=#" %%E in ('"prompt #$E# & for %%E in (1) do rem"') do set "ESCchar=%%E"

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "DATESTAMP=%YYYY%-%MM%-%DD%"
for /f %%i in ('git rev-list HEAD --count') do (set REVISION=%%i)
echo V%REVISION% %DATESTAMP%

echo 	.ASCII /V%REVISION% %DATESTAMP%/ > VERSIO.MAC

@if exist _errors.txt del _errors.txt
@if exist S1CORE.out del S1CORE.out
@if exist S1CORE.LST del S1CORE.LST
@if exist S1CORE.MAC.raw del S1CORE.MAC.raw
@if exist S1CORE.raw del S1CORE.raw
@if exist S1CORE.LZS del S1CORE.LZS
@if exist S1TILE.MAC.raw del S1TILE.MAC.raw
@if exist S1TILE.raw del S1TILE.raw
@if exist S1TILE.LZS del S1TILE.LZS
@if exist S1SCRN.LZS del S1SCRN.LZS
@if exist S1BOOT.LST del S1BOOT.LST
@if exist S1BOOT.bin del S1BOOT.bin
@if exist SABOT1.BIN del SABOT1.BIN

tools\BKTurbo8.exe -ik --raw -s0100000 -lS1TILE.lst CO S1TILE.MAC >S1TILE.out
@if exist S1TILE.MAC.raw rename S1TILE.MAC.raw S1TILE.raw
@if exist _errors.txt (
  @echo %ESCchar%[91mFAILED S1TILE, see _errors.txt%ESCchar%[0m
  @exit /b
)
>nul findstr "—сылки на неопределЄнные метки!" S1TILE.out && (
  @echo %ESCchar%[91mUNDEFINED SYMBOLS, see S1TILE.out%ESCchar%[0m
  @exit /b
)
dir /-c S1TILE.raw|findstr /R /C:"S1TILE.raw"

tools\lzsa3.exe S1TILE.raw S1TILE.LZS
dir /-c S1TILE.LZS|findstr /R /C:"S1TILE.LZS"

tools\BKTurbo8.exe -ik --raw -s001400 -lS1CORE.lst CO S1CORE.MAC >S1CORE.out
@if exist S1CORE.MAC.raw rename S1CORE.MAC.raw S1CORE.raw
@if exist _errors.txt (
  @echo %ESCchar%[91mFAILED S1CORE, see _errors.txt%ESCchar%[0m
  @exit /b
)
>nul findstr "—сылки на неопределЄнные метки!" S1CORE.out && (
  @echo %ESCchar%[91mUNDEFINED SYMBOLS, see S1CORE.out%ESCchar%[0m
  @exit /b
)
dir /-c S1CORE.raw|findstr /R /C:"S1CORE.raw"

tools\lzsa3.exe S1CORE.raw S1CORE.LZS
dir /-c S1CORE.LZS|findstr /R /C:"S1CORE.LZS"
call :FileSize S1CORE.LZS
set "codelzsize=%fsize%"
rem Reuse VERSIO.MAC to pass parameters into S1BOOT.MAC
echo S1LZSZ = %codelzsize%. >> VERSIO.MAC

dir /-c S1SCRN.DAT|findstr /R /C:"S1SCRN.DAT"

tools\lzsa3.exe S1SCRN.DAT S1SCRN.LZS

dir /-c S1SCRN.LZS|findstr /R /C:"S1SCRN.LZS"

tools\BKTurbo8.exe -ik -s001000 -lS1BOOT.lst CO S1BOOT.MAC >S1BOOT.out
@if exist S1BOOT.bin rename S1BOOT.bin SABOT1.BIN
@if exist _errors.txt (
  @echo %ESCchar%[91mFAILED S1BOOT, see _errors.txt%ESCchar%[0m
  @exit /b
)
>nul findstr "—сылки на неопределЄнные метки!" S1BOOT.out && (
  @echo %ESCchar%[91mUNDEFINED SYMBOLS, see S1BOOT.out%ESCchar%[0m
  @exit /b
)
dir /-c SABOT1.BIN|findstr /R /C:"SABOT1.BIN"

findstr /R /C:"BOOTP1:" S1BOOT.lst
findstr /R /C:"START:" S1CORE.lst
findstr /R /C:"FREE0 =" S1CORE.lst
findstr /R /C:"FREE3 =" S1CORE.lst
findstr /R /C:"PROBLEM:" S1BOOT.out
findstr /R /C:"PROBLEM:" S1CORE.out

>nul findstr "PROBLEM:" S1BOOT.out && (
  @echo %ESCchar%[91mPROBLEMS in S1BOOT.out%ESCchar%[0m
  @exit /b
)
>nul findstr "PROBLEM:" S1CORE.out && (
  @echo %ESCchar%[91mPROBLEMS in S1CORE.out%ESCchar%[0m
  @exit /b
)

echo %ESCchar%[92mSUCCESS%ESCchar%[0m
exit

:Failed
@echo off
echo %ESCchar%[91mFAILED%ESCchar%[0m
exit /b

:FileSize
set fsize=%~z1
exit /b 0
