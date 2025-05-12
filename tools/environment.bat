@echo off

set DIR=%~dp0.
set BASE_PATH=%DIR%\git\mingw64\bin;%DIR%\python;%DIR%\python\Scripts
set PATH=%BASE_PATH%;%PATH%
set VENV_PATH=%~dp0.\..\code\venv

:: Force typical Windows appdata variables if not defined.
:: important to avoid errors with  winreg.QueryValueEx(key, shell_folder_name)
:: Redirection des dossiers vers G: pour éviter le manque d'espace sur C:
set APPDATA=G:\AppData\Roaming
set LOCALAPPDATA=G:\AppData\Local
set PROGRAMDATA=G:\ProgramData

:: Configuration des chemins Hugging Face pour stocker les modèles sur le lecteur G:
set HF_HOME=G:\HuggingFace
set TRANSFORMERS_CACHE=G:\HuggingFace\transformers-cache
set HF_DATASETS_CACHE=G:\HuggingFace\datasets-cache
set HF_MODULES_CACHE=G:\HuggingFace\modules-cache

:: Configuration du cache spécifique à hy3dgen
set HY3DGEN_MODELS=G:\HuggingFace\hy3dgen-cache

:: Création des répertoires s'ils n'existent pas
if not exist "G:\AppData\Roaming" mkdir "G:\AppData\Roaming"
if not exist "G:\AppData\Local" mkdir "G:\AppData\Local"
if not exist "G:\ProgramData" mkdir "G:\ProgramData"
if not exist "G:\HuggingFace" mkdir "G:\HuggingFace"
if not exist "G:\HuggingFace\transformers-cache" mkdir "G:\HuggingFace\transformers-cache"
if not exist "G:\HuggingFace\datasets-cache" mkdir "G:\HuggingFace\datasets-cache"
if not exist "G:\HuggingFace\modules-cache" mkdir "G:\HuggingFace\modules-cache"
if not exist "G:\HuggingFace\hy3dgen-cache" mkdir "G:\HuggingFace\hy3dgen-cache"

rem Check critical DLLs
if not exist "%DIR%\python\vcruntime140.dll" (
    echo Error: Missing vcruntime140.dll
    exit /b 1
)
if not exist "%DIR%\python\vcruntime140_1.dll" (
    echo Error: Missing vcruntime140_1.dll
    exit /b 1
)
if not exist "%DIR%\python\_ctypes.pyd" (
    echo Error: Missing _ctypes.pyd
    exit /b 1
)
if not exist "%DIR%\python\libffi-8.dll" (
    echo Error: Missing libffi-8.dll
    exit /b 1
)
if not exist "%DIR%\python\libcrypto-3.dll" (
    echo Error: Missing libcrypto-3.dll
    exit /b 1
)
if not exist "%DIR%\python\libssl-3.dll" (
    echo Error: Missing libssl-3.dll
    exit /b 1
)
if not exist "%DIR%\python\_ssl.pyd" (
    echo Error: Missing _ssl.pyd
    exit /b 1
)


:: Prevent Python from using user site packages (APPDATA)
set PYTHONNOUSERSITE=1

rem Clear any existing Python/Conda related env vars
set CONDA_PREFIX=
set CONDA_PYTHON_EXE=
set CONDA_DEFAULT_ENV=
set CONDA_SHLVL=
set CONDAPATH=
set PYTHONPATH=
set PYTHONHOME=

:: First set basic environment variables
set PIP_INSTALLER_LOCATION=%DIR%\python\get-pip.py
set PIP_DISABLE_PIP_VERSION_CHECK=1
::so that pip never tries to read from system config that triggers the registry call:
set PIP_CONFIG_FILE=NUL


:: Install virtualenv package if missing:
python -m pip show virtualenv >nul 2>&1
if errorlevel 1 (
    echo Installing virtualenv...
    python -m pip install virtualenv
)


:: create venv if it doesn't exist
if not exist "%VENV_PATH%\Scripts\activate.bat" (
    :: Verify python is available before trying to create venv
    python --version >nul 2>&1
    if errorlevel 1 (
        echo Python not found in PATH. Please check your installation.
        exit /b 1
    )
    echo Creating virtual environment...
	echo python -m virtualenv "%VENV_PATH%"
    python -m virtualenv "%VENV_PATH%"
    if errorlevel 1 (
        echo Failed to create virtual environment.
        exit /b 1
    )
)


:: In environment.bat after venv creation:
:: Always ensure our pip.ini is in place
copy /Y "%DIR%\python\pip.ini" "%VENV_PATH%\pip.ini"
if errorlevel 1 (
    echo Failed to copy pip.ini
    exit /b 1
)

:: activate venv
call "%VENV_PATH%\Scripts\activate.bat"
if errorlevel 1 (
    echo Failed to activate virtual environment
    exit /b 1
)

:: you can set your custom path to python here. Notice, python must be 3.11
:: Don't forget quotation marks ""
:: For example   set PYTHON="C:\Program Files\Python311\python.exe"
set PYTHON="%VENV_PATH%\Scripts\python.exe"

:: If PYTHON is not set, use the activated venv python
if not defined PYTHON (
	set PYTHON=python
)