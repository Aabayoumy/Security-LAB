
cmd.exe /c sc config winrm start=auto
cmd.exe /c net start winrm

copy  unattend.xml "C:/Windows/Panther/unattend.xml"
C:/windows/system32/sysprep/sysprep.exe /generalize /oobe /unattend:C:/Windows/Panther/unattend.xml  /shutdown /mode:vm

