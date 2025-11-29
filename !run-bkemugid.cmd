
del x-bkemugid\Img\ANDOS.IMG
@if exist "x-bkemugid\Img\ANDOS.IMG" (
  echo.
  echo ####### FAILED to delete old disk image file #######
  exit /b
)

copy "x-bkemugid\Img\ANDOS_.IMG " "x-bkemugid\Img\ANDOS.IMG"
bkdecmd a x-bkemugid/Img/ANDOS.IMG SABOT1.BIN
bkdecmd a x-bkemugid/Img/ANDOS.IMG S1CORE.LZS

start x-bkemugid\BK_x64.exe /C BK-0011M_FDD
