#ifndef MyAppName
#define MyAppName "Focus Application"
#endif

#ifndef MyAppVersion
#define MyAppVersion "1.0.0"
#endif

#ifndef MyAppPublisher
#define MyAppPublisher "Focus Application Team"
#endif

#ifndef MyAppExeName
#define MyAppExeName "flutter_application_1.exe"
#endif

[Setup]
AppId={{A33B9B5D-4C84-48A9-9A77-39A12A6C1B69}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={localappdata}\Programs\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=..\build\installer
OutputBaseFilename=FocusApplicationSetup-{#MyAppVersion}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
UninstallDisplayIcon={app}\{#MyAppExeName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "vc_redist.x64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "..\startingPrograms.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\currentSessionBlocked.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\permanentBlockedLog.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\programsLog1.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\programsLog2.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\BadProgramNoise.wav"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\*"; DestDir: "{app}\project_files"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "build\*,.git\*,.dart_tool\*,.idea\*,.vscode\*"

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "Installing Visual C++ Runtime..."; Flags: waituntilterminated
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; WorkingDir: "{app}"; Flags: nowait postinstall skipifsilent