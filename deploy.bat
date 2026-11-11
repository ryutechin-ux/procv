@echo off
echo ========================================================
echo Deploying ProCV to Firebase Hosting (cvbuilder-ea3ab)...
echo ========================================================
call npx firebase-tools deploy --only hosting
echo.
echo Your public link: https://cvbuilder-ea3ab.web.app
pause

