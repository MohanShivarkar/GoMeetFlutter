@echo off
set OUTPUT=N:\Works\Projects\GoMeetFlutter\gomeet\dart_search_result.txt
echo ===SEARCH RESULTS=== > "%OUTPUT%" 2>&1
where flutter >> "%OUTPUT%" 2>&1
where dart >> "%OUTPUT%" 2>&1
echo --- PATH --- >> "%OUTPUT%" 2>&1
echo %PATH% >> "%OUTPUT%" 2>&1
echo --- ENV FLUTTER_ROOT --- >> "%OUTPUT%" 2>&1
echo %FLUTTER_ROOT% >> "%OUTPUT%" 2>&1
echo --- Checking common locations --- >> "%OUTPUT%" 2>&1
if exist "C:\src\flutter\bin\flutter.bat" echo FOUND C:\src\flutter >> "%OUTPUT%"
if exist "C:\flutter\bin\flutter.bat" echo FOUND C:\flutter >> "%OUTPUT%"
if exist "C:\tools\flutter\bin\flutter.bat" echo FOUND C:\tools\flutter >> "%OUTPUT%"
if exist "%LOCALAPPDATA%\flutter\bin\flutter.bat" echo FOUND LOCALAPPDATA\flutter >> "%OUTPUT%"
if exist "%USERPROFILE%\flutter\bin\flutter.bat" echo FOUND USERPROFILE\flutter >> "%OUTPUT%"
if exist "%USERPROFILE%\AppData\Local\flutter\bin\flutter.bat" echo FOUND AppData flutter >> "%OUTPUT%"
echo --- Checking Program Files --- >> "%OUTPUT%" 2>&1
dir "C:\Program Files\flutter\bin\flutter.bat" >> "%OUTPUT%" 2>&1
dir "%USERPROFILE%\fvm" >> "%OUTPUT%" 2>&1
echo DONE >> "%OUTPUT%"
