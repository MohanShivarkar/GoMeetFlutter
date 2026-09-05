@echo off
cd /d N:\Works\Projects\GoMeetFlutter
E:\Software\flutter\bin\flutter.bat test test/firebase_options_web_test.dart --reporter expanded > "N:\Works\Projects\GoMeetFlutter\gomeet\firebase_test_output.txt" 2>&1
echo EXIT_CODE=%ERRORLEVEL% >> "N:\Works\Projects\GoMeetFlutter\gomeet\firebase_test_output.txt"
