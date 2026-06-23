SET CWD=%~dp0
SET INVALID=0
if not %CWD:~1,1%==: (
SET CWD=%CWD:*\home\=%
SET INVALID=1
)
if %INVALID%==1 (
SET CWD=%CWD:*\=%
)
if %INVALID%==1 (
cd /d Z:\%CWD%
)

call "C:\Anaconda3\Scripts\activate.bat"
conda env list | findstr /R /C:"^crowdwalk " >nul || conda create -n crowdwalk -y
call "C:\Anaconda3\Scripts\activate.bat" crowdwalk
jupyter notebook --ip=127.0.0.1 --port=3000 --notebook-dir=.
