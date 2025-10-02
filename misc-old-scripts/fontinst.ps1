Expand-Archive -Path "C:\temp\Font_-_INSTALL_FIRST-20200821T012716Z-001.zip" -DestinationPath "c:\temp" -Force
robocopy "C:\Temp\Font - INSTALL FIRST." "C:\Windows\Fonts\" NunitoSans-Black.ttf NunitoSans-BlackItalic.ttf NunitoSans-Bold.ttf NunitoSans-BoldItalic.ttf NunitoSans-ExtraBold.ttf NunitoSans-ExtraBoldItalic.ttf NunitoSans-ExtraLight.ttf NunitoSans-ExtraLightItalic.ttf NunitoSans-Italic.ttf NunitoSans-Light.ttf NunitoSans-LightItalic.ttf NunitoSans-Regular.ttf NunitoSans-SemiBold.ttf NunitoSans-SemiBoldItalic.ttf "trajan pro.ttf"
cd C:\Temp
reg import MBSFonts.reg
reg import MBSMailSettings.reg