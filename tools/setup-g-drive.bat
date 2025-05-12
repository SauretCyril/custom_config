@echo off
echo ===========================================================================
echo Configuration initiale des chemins sur le lecteur G:
echo ===========================================================================

:: Modifier environment.bat pour utiliser le lecteur G:
echo Modification du fichier environment.bat...

:: Ajouter les variables d'environnement pour Hugging Face
findstr /c:":: Configuration des chemins Hugging Face" g:\v12_hunyuan2-stableprojectorz\tools\environment.bat > nul
if %errorlevel% neq 0 (
    echo Ajout des configurations HuggingFace au fichier environment.bat...
    
    :: Créer un fichier temporaire
    (
        for /f "tokens=*" %%a in (g:\v12_hunyuan2-stableprojectorz\tools\environment.bat) do (
            echo %%a
            echo %%a | findstr /c:":: Redirection des dossiers vers G:" > nul
            if not errorlevel 1 (
                echo(
                echo :: Configuration des chemins Hugging Face pour stocker les modèles sur le lecteur G:
                echo set HF_HOME=G:\HuggingFace
                echo set TRANSFORMERS_CACHE=G:\HuggingFace\transformers-cache
                echo set HF_DATASETS_CACHE=G:\HuggingFace\datasets-cache
                echo set HF_MODULES_CACHE=G:\HuggingFace\modules-cache
                echo(
                echo :: Configuration du cache spécifique à hy3dgen
                echo set HY3DGEN_MODELS=G:\HuggingFace\hy3dgen-cache
                echo(
            )
        )
    ) > environment.bat.new
    
    move /Y environment.bat.new g:\v12_hunyuan2-stableprojectorz\tools\environment.bat > nul
    echo Configuration de environment.bat terminée.
) else (
    echo La configuration HuggingFace existe déjà dans environment.bat.
)

:: Création des répertoires nécessaires
echo Création des répertoires sur le lecteur G:...
if not exist "G:\AppData\Roaming" mkdir "G:\AppData\Roaming"
if not exist "G:\AppData\Local" mkdir "G:\AppData\Local"
if not exist "G:\ProgramData" mkdir "G:\ProgramData"
if not exist "G:\HuggingFace" mkdir "G:\HuggingFace"
if not exist "G:\HuggingFace\transformers-cache" mkdir "G:\HuggingFace\transformers-cache"
if not exist "G:\HuggingFace\datasets-cache" mkdir "G:\HuggingFace\datasets-cache"
if not exist "G:\HuggingFace\modules-cache" mkdir "G:\HuggingFace\modules-cache"
if not exist "G:\HuggingFace\hy3dgen-cache" mkdir "G:\HuggingFace\hy3dgen-cache"

:: Déplacement des modèles existants si nécessaire
echo Vérification des modèles existants à déplacer...
set "HF_SOURCE=%USERPROFILE%\.cache\huggingface"
if exist "%HF_SOURCE%" (
    echo Déplacement des modèles Hugging Face du lecteur C: vers le lecteur G:...
    robocopy "%HF_SOURCE%" "G:\HuggingFace" /E /MOVE /R:1 /W:1 /NFL /NDL /NJH /NJS
)

if exist "%USERPROFILE%\.cache\hy3dgen" (
    echo Déplacement du cache spécifique hy3dgen...
    robocopy "%USERPROFILE%\.cache\hy3dgen" "G:\HuggingFace\hy3dgen-cache" /E /MOVE /R:1 /W:1 /NFL /NDL /NJH /NJS
)

echo ===========================================================================
echo Configuration terminée !
echo ===========================================================================
echo.
echo Les modèles et fichiers seront désormais stockés sur le lecteur G:.
echo Cette configuration sera préservée même après une mise à jour.
echo.
pause
