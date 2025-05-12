@echo off
setlocal enabledelayedexpansion

echo Déplacement des modèles Hugging Face de C: vers G:

:: Créer les répertoires de destination s'ils n'existent pas
if not exist "G:\HuggingFace" mkdir "G:\HuggingFace"
if not exist "G:\HuggingFace\transformers-cache" mkdir "G:\HuggingFace\transformers-cache"
if not exist "G:\HuggingFace\datasets-cache" mkdir "G:\HuggingFace\datasets-cache"
if not exist "G:\HuggingFace\modules-cache" mkdir "G:\HuggingFace\modules-cache"
if not exist "G:\HuggingFace\hy3dgen-cache" mkdir "G:\HuggingFace\hy3dgen-cache"

:: Chemins source par défaut
set "HF_SOURCE=%USERPROFILE%\.cache\huggingface"
set "TRANSFORMERS_SOURCE=%USERPROFILE%\.cache\huggingface\transformers"

:: Vérifier si les dossiers source existent
if exist "%HF_SOURCE%" (
    echo Déplacement du dossier principal HuggingFace...
    robocopy "%HF_SOURCE%" "G:\HuggingFace" /E /MOVE /R:1 /W:1
) else (
    echo Aucun dossier HuggingFace trouvé dans %HF_SOURCE%
)

:: Vérifier si d'autres dossiers de cache existent dans différents emplacements
if exist "C:\Users\%USERNAME%\.cache\huggingface" (
    echo Déplacement du cache HuggingFace alternatif...
    robocopy "C:\Users\%USERNAME%\.cache\huggingface" "G:\HuggingFace" /E /MOVE /R:1 /W:1
)

if exist "%APPDATA%\huggingface" (
    echo Déplacement du cache HuggingFace d'AppData...
    robocopy "%APPDATA%\huggingface" "G:\HuggingFace" /E /MOVE /R:1 /W:1
)

if exist "%LOCALAPPDATA%\huggingface" (
    echo Déplacement du cache HuggingFace de LocalAppData...
    robocopy "%LOCALAPPDATA%\huggingface" "G:\HuggingFace" /E /MOVE /R:1 /W:1
)

:: Déplacement du cache spécifique hy3dgen
if exist "%USERPROFILE%\.cache\hy3dgen" (
    echo Déplacement du cache spécifique hy3dgen...
    robocopy "%USERPROFILE%\.cache\hy3dgen" "G:\HuggingFace\hy3dgen-cache" /E /MOVE /R:1 /W:1
)

echo Terminé ! Les modèles ont été déplacés vers le lecteur G:
echo Les nouveaux téléchargements seront également stockés sur G:

pause
