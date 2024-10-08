; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Zoa"
#define MyAppVersion "0.1.7"
#define MyAppPublisher "My Company, Inc."
#define MyAppURL "https://www.example.com/"
#define MyAppExeName "Zoa.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{4EB6E376-ADC1-4000-A2AE-C0F399B70AEA}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
PrivilegesRequired=lowest
OutputBaseFilename=mysetup
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "C:\dev\zoa\build\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\gtk-4-1.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\gio-2.0-0.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\glib-2.0-0.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\cairo-2.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\gobject-2.0-0.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\plplot.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\plplotfortran.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\gdk_pixbuf-2.0-0.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\zlib1.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\pixman-1-0.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\intl.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\gmodule-2.0-0.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\fontconfig-1.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\freetype-6.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\libpng16.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\pcre2-8.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\pango-1.0-0.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\pangocairo-1.0-0.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\harfbuzz.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\fribidi-0.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\cairo-gobject-2.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\epoxy-0.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\graphene-1.0-0.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\pangowin32-1.0-0.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\qsastime.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\ffi-8.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\tiff.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\jpeg62.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\cairo-script-interpreter-2.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\iconv.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\libexpat.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\gtk-build\gtk\x64\release\bin\pangoft2-1.0-0.dll"; DestDir: "{app}"; Flags: ignoreversion
;Source: "C:\gtk-build/gtk/x64/release/lib/plplot5.15.0/drivers/cairo.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\program files (x86)\intel\oneapi\compiler\latest\bin\LIBIFCOREMD.DLL"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\program files (x86)\intel\oneapi\compiler\latest\bin\LIBMMD.DLL"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\program files (x86)\intel\oneapi\compiler\latest\bin\SVML_DISPMD.DLL"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\program files (x86)\intel\oneapi\compiler\latest\bin\1033\ifcore_msg.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\program files (x86)\intel\oneapi\compiler\latest\bin\1033\irc_msg.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\program files (x86)\intel\oneapi\compiler\latest\bin\1033\libmUI.DLL"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\program files (x86)\intel\oneapi\compiler\latest\bin\LIBMMDD.DLL"; DestDir: "{app}"; Flags: ignoreversion

Source: "C:\dev\zoa\Library\*"; DestDir: "{userappdata}\Zoa"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
Source: "C:\dev\zoa\help\html\*.*"; DestDir: "{userappdata}\Zoa\help\html"; Flags: ignoreversion recursesubdirs createallsubdirs


[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

