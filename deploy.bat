@echo off
set REPO_NAME=Tahfidz-Core

echo [1/4] Membersihkan build lama...
call flutter clean

echo [2/4] Mengambil dependensi...
call flutter pub get

echo [3/4] Build Web secara Manual (Base-Href Terkunci)...
:: Kita build manual dulu untuk memastikan folder build/web benar
call flutter build web --base-href "/%REPO_NAME%/" --release

echo [4/4] Mengirim ke GitHub Pages via Peanut...
:: Peanut akan mengambil folder build/web yang sudah kita build di atas
call flutter pub global run peanut --directory=web

echo [FINISHING] Force push ke branch gh-pages...
call git push origin gh-pages --force

echo ====================================================
echo SELESAI! Silakan tunggu 1 menit lalu coba akses:
echo https://dasturnm.github.io/%REPO_NAME%/
echo ====================================================
pause