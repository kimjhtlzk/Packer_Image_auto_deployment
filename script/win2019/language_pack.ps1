# Download Language pack -- taking a long time
Write-Host "Download Language pack -- taking a long time"
curl.exe -o "c:\language_pack_ko-kr.cab" "https://technms.com2us.com/download/files/language_pack/2019_language_pack_ko-kr.cab"

# install Language pack
Write-Host "install Language pack"
lpksetup.exe /i ko-KR /r /s /p "c:\language_pack_ko-kr.cab"
