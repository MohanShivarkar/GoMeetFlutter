@echo off
echo Testing E: drive access > N:\Works\Projects\GoMeetFlutter\gomeet\flutter_path_test.txt
dir E:\Software\flutter\bin\flutter.bat >> N:\Works\Projects\GoMeetFlutter\gomeet\flutter_path_test.txt 2>&1
echo EXIT_CODE=%ERRORLEVEL% >> N:\Works\Projects\GoMeetFlutter\gomeet\flutter_path_test.txt
where flutter >> N:\Works\Projects\GoMeetFlutter\gomeet\flutter_path_test.txt 2>&1
echo WHERE_EXIT=%ERRORLEVEL% >> N:\Works\Projects\GoMeetFlutter\gomeet\flutter_path_test.txt
