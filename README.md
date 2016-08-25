# WinPE_BuilderADK.bat
Batch for making custom WinPE images using ADK 10

Required: Windows Assesment and Deployment Kit

https://developer.microsoft.com/en-us/windows/hardware/windows-assessment-deployment-kit

- Create a working folder called "WinPE_Builder" and put "WinPE_BuilderADK.bat" inside of it.
- On first run the batch will create 4 new folders; WinPE_ADK10-DRIVERS, WinPE_ADK10-FILES, WinPE_ADK10-REG and WinPE_Temp.
- The "WinPE_ADK10-DRIVERS" folder should contain fully extracted drivers that will be injected into your image such as network and video drivers.
- The "WinPE_ADK10-FILES" folder should contain files to be copied to the X:\Windows\System32 directory of your WinPE image such as startnet.cmd, winpe.jpg, imagex.exe, other scripts...
- The "WinPE_ADK10-REG" folder should contain .reg files for customizing the PE environment such as command console settings.
- If you don't want to customize anything leave the above folders empty.
- The "WinPE_Temp" folder is what it sounds like, temp files are written here.

Once all of the files are in place, you can create a custom image by running Batch Mode then Make ISO or USB media. Batch Mode runs the other options in succession:
- Create Working Directory
- Mount image
- Add FILES to image
- Load REG hives
- Add DRIVERS
- Unmount image

You can run these options individually, but keep in mind that one is dependent on the other. The script tries to check for error states like "You can't mount an image until you've created a working directory" or "You can't add files until you've mounted the image". Comment if you come across a state I haven't accounted for. Only x64 images are supported in this script.
