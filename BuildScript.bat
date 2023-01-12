::@echo off
cd /d "%~dp0"

git clean -fdxq && git reset --hard

