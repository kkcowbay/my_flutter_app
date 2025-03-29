@echo off
echo ✅ 備份 .git 資料夾...
xcopy .git .git_backup /E /H /C /I

echo 🧹 移除 Git 歷史中的大檔案...
REM 以下為範例清單，請依實際需求新增或修改
set FILES_TO_REMOVE="build/windows/x64/extracted/firebase_cpp_sdk_windows/libs/windows/VS2019/MT/x64/Debug/firebase_firestore.lib" ^
 "build/windows/x64/firebase_cpp_sdk_windows_12.0.0.zip" ^
 "build/windows/x64/extracted/firebase_cpp_sdk_windows/libs/windows/VS2019/MD/x64/Debug/firebase_firestore.lib" ^
 "windows/flutter/ephemeral/flutter_windows.dll.pdb" ^
 "build/windows/x64/runner/my_flutter_app.dir/Debug/my_flutter_app.ilk"

for %%F in (%FILES_TO_REMOVE%) do (
    echo ❌ Removing: %%F
    git filter-branch --force --index-filter "git rm --cached --ignore-unmatch %%F" --prune-empty --tag-name-filter cat -- --all
)

echo 🧼 清理 Git 垃圾...
git reflog expire --expire=now --all
git gc --prune=now --aggressive

echo 🚀 強制推送乾淨版本至 GitHub...
git push origin --force --all
git push origin --force --tags

echo ✅ 清理完成
pause