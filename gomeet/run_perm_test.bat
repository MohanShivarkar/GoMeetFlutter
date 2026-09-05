@echo off
cd /d N:\Works\Projects\GoMeetFlutter
E:\Software\flutter\bin\flutter.bat test test/platform/permission_service_web_test.dart --reporter expanded > "N:\Works\Projects\GoMeetFlutter\gomeet\perm_test_result.txt" 2>&1
echo EXIT_CODE=%ERRORLEVEL% >> "N:\Works\Projects\GoMeetFlutter\gomeet\perm_test_result.txt"
