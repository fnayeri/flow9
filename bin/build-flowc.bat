:: Script for building Flowc compiler.
:: Make sure you have javac from JDK on your path!
@echo off



pushd .
pushd .

for /d %%i in ("%ProgramFiles%\Java\jdk1.8*") do (set Located=%%i)
rem check if JDK was located
if "%Located%"=="" goto else
rem if JDK located display message to user
rem update %JAVA_HOME%
set JAVA_HOME=%Located%
echo     JAVA_HOME has been set to:
echo         %JAVA_HOME%
goto endif

:else
rem if JDK was not located
rem if %JAVA_HOME% has been defined then use the existing value
if "%JAVA_HOME%"=="" goto NoExistingJavaHome
echo     Existing value of JAVA_HOME will be used:
echo         %JAVA_HOME%
goto endif

:NoExistingJavaHome
rem display message to the user that %JAVA_HOME% is not available
echo     No Existing value of JAVA_HOME is available.
echo     set JAVA_HOME=path to your jdk root
echo     and retry
goto endif

:endif

set JAVAC=%JAVA_HOME%\bin\javac
set JAR=%JAVA_HOME%\bin\jar


echo.
echo Compiling 'Flowc'
echo =================
echo.

set BASE_DIR=%~dp0..\

echo * Preparing version information
echo   -----------------------------
echo.

set VERFILE=%BASE_DIR%\tools\flowc\flowc_version.flow
set /p FLOWC_VERSION=<%BASE_DIR%\tools\flowc\flowc.version
for /f %%G in ('"git rev-parse --short HEAD"') do (

echo // This file is autogenerated.>  %VERFILE%
echo // Edit 'build-flowc' instead.>> %VERFILE%
echo export {>> %VERFILE%
echo 	flowc_version = "%FLOWC_VERSION%";>> %VERFILE%
echo 	flowc_git_revision = "%%G";>> %VERFILE%
echo }>> %VERFILE%

)

echo * Compiling runtime
echo   -----------------
echo.

pushd %BASE_DIR%\src\java
"%JAVAC%" -g com\area9innovation\flow\*.java -Xlint:deprecation
popd

echo.
echo * Generating the Java modules for flowc
echo   -------------------------------------
echo.
call flow --java javagen tools\flowc\flowc.flow

echo.
echo * Compiling the generated code
echo   ----------------------------
echo.

"%JAVAC%" -Xlint:unchecked -encoding UTF-8 -cp src\java javagen\*.java

echo.
echo * Building the 'flowc.jar'
echo   ------------------------
echo.

echo Main-Class: javagen.Main > Manifest.txt

"%JAR%" cfm tools\flowc\flowc.jar Manifest.txt javagen\*.class -C src\java com\area9innovation\flow

echo.
echo Done.
