@echo off
E:\Software\flutter\bin\flutter.bat test "N:\Works\Projects\GoMeetFlutter\test\main_firebase_init_test.dart" --reporter expanded > "N:\Works\Projects\GoMeetFlutter\gomeet\main_init_test_output.txt" 2>&1
echo EXIT_CODE=%ERRORLEVEL% >> "N:\Works\Projects\GoMeetFlutter\gomeet\main_init_test_output.txt"
