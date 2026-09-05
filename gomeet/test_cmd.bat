@echo off
echo Hello from batch > "N:\Works\Projects\GoMeetFlutter\gomeet\cmd_test_result.txt" 2>&1
echo Exit: %ERRORLEVEL% >> "N:\Works\Projects\GoMeetFlutter\gomeet\cmd_test_result.txt"
dir "E:\" >> "N:\Works\Projects\GoMeetFlutter\gomeet\cmd_test_result.txt" 2>&1
