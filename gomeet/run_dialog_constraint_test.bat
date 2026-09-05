@echo off
REM Run dialog constraint test — copies overlay files and runs flutter test
N:
cd N:\Works\Projects\GoMeetFlutter

REM Copy core/widgets helper (may not exist yet on first run — that's the RED state)
if not exist "lib\core\widgets" mkdir "lib\core\widgets"
if exist "gomeet\lib\core\widgets\dialog_helpers.dart" (
    copy /Y "gomeet\lib\core\widgets\dialog_helpers.dart" "lib\core\widgets\dialog_helpers.dart"
) else (
    echo [SKIP] dialog_helpers.dart not found in overlay - test will fail with import error
)

REM Copy test file
if not exist "test\widgets" mkdir "test\widgets"
copy /Y "gomeet\test\widgets\dialog_constraint_test.dart" "test\widgets\dialog_constraint_test.dart"

REM Run tests
E:\Software\flutter\bin\flutter.bat test test/widgets/dialog_constraint_test.dart --reporter expanded > "N:\Works\Projects\GoMeetFlutter\gomeet\dialog_constraint_test_output.txt" 2>&1
echo EXIT_CODE=%ERRORLEVEL% >> "N:\Works\Projects\GoMeetFlutter\gomeet\dialog_constraint_test_output.txt"
