@echo off
E:\Software\flutter\bin\flutter.bat test "N:\Works\Projects\GoMeetFlutter\test\features\auth\google_sign_in_web_service_test.dart" --reporter expanded > "N:\Works\Projects\GoMeetFlutter\gomeet\auth_test_output.txt" 2>&1
echo EXIT_CODE=%ERRORLEVEL% >> "N:\Works\Projects\GoMeetFlutter\gomeet\auth_test_output.txt"
