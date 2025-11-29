
del x-bkbtl\ANDOS.IMG
@if exist "x-bkbtl\ANDOS.IMG" (
  echo.
  echo ####### FAILED to delete old disk image file #######
  exit /b
)

copy "x-bkemugid\Img\ANDOS_.IMG " "x-bkbtl\ANDOS.IMG"
bkdecmd a x-bkbtl/ANDOS.IMG SABOT1.BIN
bkdecmd a x-bkbtl/ANDOS.IMG S1CORE.LZS

cd x-bkbtl
start BKBTL.exe