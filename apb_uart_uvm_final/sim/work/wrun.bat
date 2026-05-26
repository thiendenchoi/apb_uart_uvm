@echo off
setlocal EnableExtensions DisableDelayedExpansion

rem =========================================================
rem   QUESTASIM UNIFIED RUNNER - APB-UART DTI DESIGN
rem =========================================================

set "QUESTA_HOME=C:\questasim64_2021.1"
set "PATH=%QUESTA_HOME%\win64;%PATH%"
set "SCRIPT_DIR=%~dp0"

set "TOP_TB=apb_uart_test_top"
set "UVM_TEST=apb_uart_test_write_parity_even"

set "ARG1=%~1"

if /I "%ARG1%"=="clean" goto :CLEAN
if /I "%ARG1%"=="wave"  goto :VIEW_WAVE
if /I "%ARG1%"=="cov"   goto :VIEW_COV
if /I "%ARG1%"=="merge" goto :MERGE
if not "%ARG1%"=="" set "UVM_TEST=%ARG1%"

pushd "%SCRIPT_DIR%" >nul
if not exist "log" mkdir "log" >nul 2>&1
set "TMP_DIR=%SCRIPT_DIR%._wrun_tmp"
if not exist "%TMP_DIR%" mkdir "%TMP_DIR%" >nul 2>&1

set "FL_COM=%TMP_DIR%\filelist_com.f"
set "FL_RTL=%TMP_DIR%\filelist_rtl.f"
set "FL_TB=%TMP_DIR%\filelist_tb.f"
call :WRITE_FILELISTS

rem =========================================================
rem   1. BIÊN DỊCH (COMPILE)
rem =========================================================
if exist work (
    echo [INFO] Refreshing work library...
)
vlib work
vmap work work

echo [INFO] Compiling RTL Core (DTI Modules)...
vlog -64 -sv +acc=all +cover=bcefs -f "%FL_COM%" -f "%FL_RTL%" -l log\compile_rtl.log
if errorlevel 1 goto :FAIL

echo [INFO] Compiling Testbench, VIPs and SVA...
vlog -64 -sv +acc=all -f "%FL_COM%" -f "%FL_TB%" -l log\compile_tb.log
if errorlevel 1 goto :FAIL

rem =========================================================
rem   2. MÔ PHỎNG (SIMULATE)
rem =========================================================
echo [INFO] Running UVM Test: %UVM_TEST%

vsim -c -64 -wlf vsim.wlf ^
    -solvefaildebug -assertdebug -sva ^
    -coverage ^
    -voptargs="+acc" ^
    +UVM_VERBOSITY=UVM_MEDIUM ^
    +UVM_TESTNAME=%UVM_TEST% ^
    -l log\vsim.log ^
    work.%TOP_TB% ^
    -do "coverage save -onexit -assert -code bcefs -directive -cvg work/coverage_%UVM_TEST%.ucdb; log -r /*; run -all; quit"

if errorlevel 1 goto :FAIL

echo [SUCCESS] Simulation Finished.
echo           Lenh xem song: wrun.bat wave
echo           Lenh xem coverage: wrun.bat cov
goto :DONE

rem =========================================================
rem   CÁC NHÁNH LỆNH PHỤ
rem =========================================================

:VIEW_WAVE
echo [INFO] Opening Waveform...
if exist vsim.wlf (
    vsim -view vsim.wlf -do "add wave -r /%TOP_TB%/*; wave zoom full"
) else (
    echo [ERROR] vsim.wlf not found.
)
goto :DONE

:MERGE
echo [INFO] Merging all coverage files inside 'work' directory...
if not exist "work" (
    echo [ERROR] Thu muc 'work' khong ton tai.
    goto :DONE
)

pushd work
dir /b coverage_*.ucdb > ucdb_list.f

for /f %%i in ("ucdb_list.f") do set size=%%~zi
if %size% equ 0 (
    echo [ERROR] Khong tim thay file coverage_*.ucdb nao trong work/.
    del ucdb_list.f
    popd
    goto :DONE
)

echo [INFO] Merging files using -inputs flag...
vcover merge -out ../merged.ucdb -inputs ucdb_list.f
del ucdb_list.f
popd

if exist merged.ucdb (
    echo [SUCCESS] Da tao file merged.ucdb thanh cong tai thu muc sim.
)
goto :DONE

:VIEW_COV
echo [INFO] Opening Coverage Report...
if exist "merged.ucdb" (
    echo [INFO] Opening MERGED database...
    vsim -viewcov merged.ucdb
) else if exist "coverage_%UVM_TEST%.ucdb" (
    echo [INFO] Opening individual test database: coverage_%UVM_TEST%.ucdb
    vsim -viewcov coverage_%UVM_TEST%.ucdb
) else (
    echo [ERROR] No coverage file found. Run 'wrun.bat merge' first.
)
goto :DONE

:CLEAN
pushd "%SCRIPT_DIR%" >nul
if exist work vdel -lib work -all >nul 2>&1
if exist "log" rmdir /s /q "log" >nul 2>&1
if exist "._wrun_tmp" rmdir /s /q "._wrun_tmp"
del /q vsim.wlf *.ucdb >nul 2>&1
echo [INFO] Cleaned.
goto :DONE

:FAIL
echo [ERROR] Task failed. Check logs in .\log\
popd >nul
pause
exit /b 1

:WRITE_FILELISTS

> "%FL_COM%" (
    echo +libext+.v
    echo +libext+.vh
    echo +libext+.sv
    echo +libext+.svh
)

> "%FL_RTL%" (
    echo +incdir+../../hdl
    echo -y ../../hdl
    echo ../../hdl/uart.svp
)

> "%FL_TB%" (
    echo +incdir+../inc
    echo +incdir+../lib
    echo +incdir+../lib/apb_vip/inc
    echo +incdir+../lib/apb_vip/apb
    echo +incdir+../lib/apb_vip/cov
    echo +incdir+../lib/apb_vip/intf
    echo +incdir+../lib/uart_vip/inc
    echo +incdir+../lib/uart_vip/intf
    echo +incdir+../lib/uart_vip/src
    echo +incdir+../lib/uart_vip/uart_tx
    echo +incdir+../lib/uart_vip/uart_rx
    echo +incdir+../src/test_comp
    echo +incdir+../src/uvm_comp
    echo +incdir+../sva
    echo +incdir+../src/uvm_seqs/apb_seq
    echo +incdir+../src/uvm_seqs/uart_seq
    echo +incdir+../../lib/register_block/sim/regassistant

    echo ../../lib/register_block/sim/regassistant/uart_regs_pkg.sv
    echo ../lib/apb_vip/inc/apb_pkg.svh
    echo ../lib/uart_vip/inc/uart_pkg.svh
    echo ../src/uvm_seqs/apb_seq/apb_seq_pkg.svh
    echo ../src/uvm_seqs/uart_seq/uart_seq_pkg.svh
    echo ../src/test_comp/apb_uart_test_top.sv
)
exit /b 0

:DONE
popd >nul
exit /b 0