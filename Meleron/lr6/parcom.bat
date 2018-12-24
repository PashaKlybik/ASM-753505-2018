@echo off
tasm\tasm %1.asm
if errorlevel 1 goto end
tasm\tlink /t %1
if errorlevel 1 goto end
del %1.obj
del %1.map
%1.com -d
:end