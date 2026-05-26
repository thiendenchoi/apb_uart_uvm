@echo off
setlocal enabledelayedexpansion

set "LOG=regression.log"
set "SIM_LOG=sim.log"

echo [START] %date% %time% > %LOG%
echo --------------------------------------- >> %LOG%

call wrun.bat apb_uart_test_base
if !errorlevel! neq 0 (
    powershell -Command "Write-Host '[FAIL] Compile Error' -ForegroundColor Red"
    echo [FAIL] Compile Error >> %LOG%
    exit /b 1
)

set TESTS=apb_uart_test_read_2_stop_bit ^
apb_uart_test_read_6_bit ^
apb_uart_test_read_no_parity ^
apb_uart_test_read_parity_even ^
apb_uart_test_read_parity_odd ^
apb_uart_test_simple ^
apb_uart_test_write_2_stop_bit ^
apb_uart_test_write_6_bit ^
apb_uart_test_write_no_parity ^
apb_uart_test_write_parity_even ^
apb_uart_test_write_parity_odd ^
apb_uart_test_write_pstrb_0 ^
apb_uart_test_write_read_reg ^
apb_uart_test_write_reg_error ^
apb_uart_test_write_check_tx_done 

for %%T in (%TESTS%) do (
    echo Running %%T...
    call wrun.bat %%T > %SIM_LOG% 2>&1
    
    set STATUS=PASS
    
    set "SIM_RESULT=Unknown"
    for /f "tokens=*" %%a in ('findstr /C:"# Errors:" %SIM_LOG%') do set "SIM_RESULT=%%a"
    
    set "UVM_W=UVM_WARNING : 0"
    set "UVM_E=UVM_ERROR   : 0"
    for /f "tokens=*" %%a in ('findstr /C:"UVM_WARNING :" %SIM_LOG%') do set "UVM_W=%%a"
    for /f "tokens=*" %%a in ('findstr /C:"UVM_ERROR :" %SIM_LOG%') do set "UVM_E=%%a"

    findstr /R /C:"UVM_WARNING : *[1-9]" /C:"UVM_ERROR : *[1-9]" /C:"UVM_FATAL : *[1-9]" /C:"Errors: *[1-9]" /C:"Assertion failure" %SIM_LOG% > nul
    if !errorlevel! equ 0 (
        set STATUS=FAIL
    )

    if "!STATUS!"=="PASS" (
        powershell -Command "Write-Host '[PASS] %%T' -ForegroundColor Green"
        echo [PASS] %%T >> %LOG%
    ) else (
        powershell -Command "Write-Host '[FAIL] %%T' -ForegroundColor Red"
        powershell -Command "Write-Host '      !SIM_RESULT!' -ForegroundColor Yellow"
        powershell -Command "Write-Host '      !UVM_E!' -ForegroundColor Yellow"
        
        echo [FAIL] %%T >> %LOG%
        echo      --- Chi tiet cac dong loi --- >> %LOG%
        findstr /C:"UVM_ERROR" /C:"UVM_WARNING" /C:"UVM_FATAL" /C:"Assertion" /C:"Errors:" %SIM_LOG% >> %LOG%
    )
    
    echo      !SIM_RESULT! >> %LOG%
    echo      !UVM_W! >> %LOG%
    echo      !UVM_E! >> %LOG%
    echo --------------------------------------- >> %LOG%
)

echo.
powershell -Command "Write-Host '=== KET QUA TONG HOP (REGRESSION SUMMARY) ===' -ForegroundColor Cyan"
type %LOG%
pause