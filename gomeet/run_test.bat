@echo off
cd /d N:\Works\Projects\GoMeetFlutter
E:\Software\flutter\bin\flutter.bat test test/platform/notification_service_web_test.dart --reporter expanded > "N:\Works\Projects\GoMeetFlutter\gomeet\test_output.txt" 2>&1
echo EXIT_CODE=%ERRORLEVEL% >> "N:\Works\Projects\GoMeetFlutter\gomeet\test_output.txt"
