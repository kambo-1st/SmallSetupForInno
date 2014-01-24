// <copyright file="license.txt">
// Copyright (c) 2011 Bohuslav Šimek
//
// This source is subject to the Modified BSD License.
// Please see the License.txt file for more information.
// All other rights reserved.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
//
// </copyright>
// <author>Bohuslav Šimek</author>
// <date>2011-08-01</date>
// <summary>A simple Opera like setup script for Inno Setup Compiler</summary>


#define MyAppName "My Program"
#define Czech "cs"
#define English "en"
#define CreateDesktopIcon "true"
#define CreateStartMenuIcon "true"
#define CreateQuickLunchIcon "false"
#define Assets AddBackslash(SourcePath)+AddBackslash('assets')
#define ProjectPath GetFileVersion(AddBackslash(SourcePath))


[Setup]
AppName={#MyAppName}
AppVersion=1
DefaultDirName={pf}\{#MyAppName}
DisableStartupPrompt=Yes
DisableDirPage=Yes
DisableProgramGroupPage=Yes
DisableReadyPage=Yes
DisableFinishedPage=No
DisableWelcomePage=Yes
OutputDir=c:\temp

[Files]
Source: test.txt; DestDir: {code:getTargetDir};

Source: {#ProjectPath}licenses\license-{#Czech}.txt; Flags: dontcopy
Source: {#ProjectPath}licenses\license.txt; Flags: dontcopy
Source: {#Assets}main.bmp; Flags: dontcopy


[Languages]
Name: "{#English}"; MessagesFile: "compiler:Default.isl"
Name: "{#Czech}"; MessagesFile: "compiler:Languages\Czech.isl"

[Messages]
en.ButtonNext=&Accept and Install
cs.ButtonNext=&Pøijmout a nainstalovat 

[CustomMessages]
AppName={#MyAppName}
en.LicenceFileName=license.txt
cs.LicenceFileName=license-{#Czech}.txt
en.ButtonOptions=&Options
cs.ButtonOptions=&Nastavení
en.Terms=&license agreement.
cs.Terms=&Licenèní smlouvou.
en.Instructions = By clicking on "Accept and Install" you are agreeing to ours
cs.Instructions = Kliknutím na tlaèítko "Pøijmout a nainstalovat" nainstalujete program a vyslovíte souhlas s
en.DesktopShorcut = on desktop
cs.DesktopShorcut = na Ploše
en.StartMenuIcon = in Start menu
cs.StartMenuIcon = v nabídce Start
en.QuickLunchIcon = on Quick lunch bar
cs.QuickLunchIcon = v panelu snadného spouštìni
en.OptionsFormCaption = Options
cs.OptionsFormCaption = Nastavení
en.OptionsFormInstallPath = Install path
cs.OptionsFormInstallPath = Cesta
en.OptionsFormShortcuts = Shortcuts
cs.OptionsFormShortcuts = Zástupce
en.BrowserButton = Change
cs.BrowserButton = Zmìnit
en.EndButton = Finish
cs.EndButton = Dokonèit
en.InfoFinish = End
cs.InfoFinish = Konec
             
            


[Run]


[Icons]
Name: "{commondesktop}\test"; Filename: "{code:getTargetDir}\test.txt"; Check: CheckDesktopIcon
Name: "{group}\test"; Filename: "{app}\test"; Check: CheckStartMenuIcon

[Code]
var
  MainPage,FinishPage,InstallPage: TWizardPage;
  OptionsButton: TNewButton;
  targetDir: String;
  DesktopIcon,StartMenuIcon,QuickLunchIcon: boolean;
  BitmapFileName: String;
  InstructionsLabel:TNewStaticText;
  PathEdit : TEdit;
  FolderTreeView : TFolderTreeView;
  TargetDirEdit:TEdit;
  AppName : string;

procedure PlaceBitmapToPage(Page :TWizardPage;BitmapFileName : string);
var
  BitmapImage : TBitmapImage;
begin
  BitmapImage := TBitmapImage.Create(Page);
  with BitmapImage do
  begin
    AutoSize := true;
    Bitmap.LoadFromFile(BitmapFileName);
    Parent := Page.Surface;
  end;
end;


{***  Licence form ***}
procedure LicenseFormViewer();
var
  LicenseForm : TSetupForm;
  OKButton    : TNewButton;
  LicenseText : TRichEditViewer;
  LicenseFile : String;
begin
  LicenseForm := CreateCustomForm();
  try
    with LicenseForm do
    begin
      Left  := ScaleX(200);
      Top   := ScaleY(108);
      BorderIcons := [biSystemMenu];
      BorderStyle := bsDialog;
      Caption := SetupMessage(msgWizardLicense);
      ClientWidth  := ScaleX(450);
      ClientHeight := ScaleY(430);
      Font.Color   := clWindowText;
      Font.Height  := -11;
      Font.Name  := 'MS Sans Serif';
      Font.Style := [];
      CenterInsideControl(WizardForm, False);
    end;
  
    ExtractTemporaryFile(CustomMessage('LicenceFileName'));
    LoadStringFromFile(ExpandConstant('{tmp}')+'\'+CustomMessage('LicenceFileName'),LicenseFile);

    LicenseText := TRichEditViewer.Create(LicenseForm);
    with LicenseText do
    begin
      Left := ScaleX(16);
      Top  := ScaleY(16);
      Width   := ScaleX(418);
      Height  := ScaleY(370);
      Parent  := LicenseForm;
      RTFText := LicenseFile;
      UseRichEdit:= true;
      ScrollBars := ssVertical;
    end;

    OKButton := TNewButton.Create(LicenseForm);
    with OKButton do
    begin
      Left  := LicenseForm.ClientWidth - ScaleX(90);
      Top   := LicenseForm.ClientHeight - ScaleY(33);
      Width   := ScaleX(75);
      Height  := ScaleY(23);
      Caption := SetupMessage(msgButtonOK);
      Default := True;
      ModalResult := 1;
      TabOrder  := 3;
      Parent    := LicenseForm;
    end;

    LicenseForm.ShowModal(); 
   
  finally
    LicenseForm.Free();
  end;
end;

procedure TermsLabelOnClick(Sender: TObject);
begin
    LicenseFormViewer();
end;

procedure CreateTheWizardPages;
var
  TermsLabel,InfoFinishLabel,ClickFinishLabel:TNewStaticText;
  InfoFinish : string;
begin
{ *** Create MainPage setup page *** }  
  mainPage := CreateCustomPage(wpSelectTasks, '', '');
  mainPage.Surface.Notebook.SetBounds(0, 0, WizardForm.ClientWidth, ScaleY(260));
  mainPage.Surface.Notebook.Width := WizardForm.Width;
  mainPage.Surface.Notebook.Height := WizardForm.Width;

  BitmapFileName := ExpandConstant('{tmp}\main.bmp');
  ExtractTemporaryFile(ExtractFileName(BitmapFileName));
  PlaceBitmapToPage(mainPage, BitmapFileName);

  InstructionsLabel:=TNewStaticText.Create(mainPage);
  with InstructionsLabel do
  begin
     Caption := CustomMessage('Instructions');
     Left := ScaleX(20);
     Top  := ScaleY(250);
     Parent := mainPage.Surface;
  end;

  TermsLabel := TNewStaticText.Create(mainPage);
  with TermsLabel do
  begin
    Caption := CustomMessage('Terms');
    Left    := InstructionsLabel.Left + InstructionsLabel.Width + ScaleX(5);
    Top     := InstructionsLabel.Top;
    Cursor  := crHand;
    OnClick := @TermsLabelOnClick;
    Font.Style := Font.Style + [fsUnderline];
    Font.Color := clBlue;
    Parent := mainPage.Surface;
  end;

{ *** Create FinishPage setup page (add bitmap and place info label) *** }    
  FinishPage := CreateCustomPage(wpInstalling, '', '');
  PlaceBitmapToPage(FinishPage, BitmapFileName);
  

  InfoFinishLabel := TNewStaticText.Create(FinishPage);
  with InfoFinishLabel do
  begin
    Width   := ScaleX(100);
    Left := ScaleX(20);
    Top  := ScaleY(250);
    InfoFinish  := SetupMessage(msgFinishedLabelNoIcons);
    StringChangeEx(InfoFinish, '[name]', '{#MyAppName}', True);
    Caption  := InfoFinish;
    Parent   := FinishPage.Surface;
    WordWrap := True;
   
    Show;
  end;

  ClickFinishLabel := TNewStaticText.Create(FinishPage);
  with ClickFinishLabel do
  begin
    Width   := ScaleX(100);
    Left := ScaleX(20);
    Top  := ScaleY(270);
    Caption  := SetupMessage(msgClickFinish);
    Parent   := FinishPage.Surface;
    WordWrap := True;
   
    Show;
  end;

{ *** Modify wpInstalling setup page (add bitmap and rearrange components - Gauge etc.) *** }
  InstallPage := PageFromID(wpInstalling);
  PlaceBitmapToPage(InstallPage, BitmapFileName);
  with WizardForm do
  begin
    ProgressGauge.Left  := ScaleX(20);
    ProgressGauge.Top   := ScaleY(235);
    ProgressGauge.Width := ScaleX(540);
    FilenameLabel.Left  := ScaleX(20);
    FilenameLabel.Top   := ScaleY(265);
    StatusLabel.Left    := ScaleX(20);
    StatusLabel.Top     := ScaleY(285);
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if (CurPageID = finishPage.ID)  then
  begin 
    OptionsButton.visible := false;
    WizardForm.NextButton.Caption := CustomMessage('EndButton');
    WizardForm.NextButton.Left := ScaleX(370);
  end
  else if (CurPageID = wpInstalling)  then
  begin
    OptionsButton.visible := false;
  end;
end;
  

function CheckDesktopIcon(): Boolean;
begin
  Result := DesktopIcon;
end; 
  
function CheckStartMenuIcon(): Boolean;
begin
  Result := StartMenuIcon;
end;

function CheckQuickLunchIcon(): Boolean;
begin
  Result := QuickLunchIcon;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  if (PageID = mainPage.ID)  then
  begin
    Result := false;
  end
  else if (PageID = finishPage.ID)  then
  begin
    Result := false;
  end
  else if (PageID = wpInstalling)  then
  begin
    Result := false;
  end
  else 
  begin
    Result := true;
  end;     
end;

procedure SyncPathEdit(Sender: TObject);
begin
  PathEdit.text := FolderTreeView.Directory;
end;

procedure SyncEditPath(Sender: TObject);
begin
  FolderTreeView.Directory := PathEdit.text ; 
end;

procedure NewFolderButtonClick(Sender: TObject);
begin
  FolderTreeView.CreateNewDirectory(SetupMessage(msgNewFolderName));
end;

{***  Select folder ***}
function SelectFolder(SelectDir : string):string;
var
  SelectFolderForm : TSetupForm;
  OKButton, CancelButton, NewFolderButton : TNewButton;
  BrowseLabel : TNewStaticText;
begin
  SelectFolderForm := CreateCustomForm();
  try
    with SelectFolderForm do
    begin
      Left  := ScaleX(200);
      Top   := ScaleY(108);
      BorderIcons := [biSystemMenu];
      BorderStyle := bsDialog;
      Caption     := SetupMessage(msgBrowseDialogTitle);
      ClientWidth  := ScaleX(349);
      ClientHeight := ScaleY(337);
      Font.Color   := clWindowText;
      Font.Height  := -11;
      Font.Name    := 'MS Sans Serif';
      Font.Style   := [];
      CenterInsideControl(WizardForm, False);
    end;
    
    OKButton := TNewButton.Create(SelectFolderForm);
    with OKButton do
    begin
      Left  := SelectFolderForm.ClientWidth - ScaleX(75 + 6 + 75 + 10);
      Top   := SelectFolderForm.ClientHeight - ScaleY(33);
      Width := ScaleX(75);
      Height  := ScaleY(23);
      Caption := SetupMessage(msgButtonOK);
      Default := True;
      ModalResult := 1;
      TabOrder    := 3;
      Parent  := SelectFolderForm;
    end;

    CancelButton := TNewButton.Create(SelectFolderForm);
    with CancelButton do
    begin
      Width   := ScaleX(75);
      Height  := ScaleY(23);
      Left   := SelectFolderForm.ClientWidth - ScaleX(85);
      Top    := SelectFolderForm.ClientHeight - ScaleY(33);
      Caption := SetupMessage(msgButtonCancel);
      ModalResult := mrCancel;
      Cancel := True;
      Parent := SelectFolderForm; 
    end;
    
    BrowseLabel := TNewStaticText.Create(SelectFolderForm);
    with BrowseLabel do
    begin
      Left := ScaleX(12);
      Top := ScaleY(12);
      Width := ScaleX(325);
      Height := ScaleY(14);
      AutoSize := False;
      Caption :=  SetupMessage(msgBrowseDialogLabel);
      TabOrder := 0;
      WordWrap := True;
      Parent := SelectFolderForm;
    end;
    
    PathEdit := TEdit.Create(SelectFolderForm);
    with PathEdit do
    begin
      Left := 16;
      Top := 36;
      Width := 317;
      Height := 21;
      TabOrder := 1;
      Parent := SelectFolderForm;
      Text := SelectDir;
   //   OnChange  := @SyncPathEdit;
    end;

    NewFolderButton := TNewButton.Create(SelectFolderForm);
    with NewFolderButton do
    begin
      Width := ScaleX(100);
      Height := ScaleY(23);
      Left := 12;
      Top := 305;
      Caption := SetupMessage(msgButtonNewFolder);       
      TabOrder := 2;
      Parent := SelectFolderForm;
      OnClick := @NewFolderButtonClick;
    end;
 
    FolderTreeView := TFolderTreeView.Create(SelectFolderForm);
    with FolderTreeView do
    begin
      Left := 16;
      Top := 70;
      Width := 317;
      Height := 200;
      Parent := SelectFolderForm;
      Directory := SelectDir;
      OnChange  := @SyncPathEdit;
    end;

    if (SelectFolderForm.ShowModal() = mrOk) and not(SelectDir=FolderTreeView.Directory) then
    begin
      Result := FolderTreeView.Directory;
    end
    else Result := '0';

  finally
    SelectFolderForm.Free();
  end;
end;

procedure BrowserButtonOnClick(Sender: TObject);
var
DialogResult : string;
begin
  DialogResult :=  SelectFolder(TargetDirEdit.Text);
  if not(DialogResult='0') then TargetDirEdit.Text := AddBackslash(DialogResult)+AppName;
end;


procedure Options();
var
  OptionsForm: TSetupForm;
  OKButton, CancelButton, BrowserButton: TNewButton;
  CheckBoxDesktop,CheckBoxStartMenu, CheckBoxQuickLunch:TCheckBox;
  InstallPathLabel,ShortcutsLabel:TLabel;
  Bevel1:TBevel;

 
begin
  OptionsForm := CreateCustomForm();
  try
    with OptionsForm do
    begin
      ClientWidth  := ScaleX(465);
      ClientHeight := ScaleY(260);
      Caption :=  CustomMessage('OptionsFormCaption');
      CenterInsideControl(WizardForm, False);
    end;

    InstallPathLabel:=TLabel.Create(OptionsForm);
    with InstallPathLabel do
    begin
      Parent  := OptionsForm;
      Left    := 20;
      Top     := 32;
      Width   := 54;
      Height  := 13;
      Caption := CustomMessage('OptionsFormInstallPath');
      Show;
    end;

    Bevel1:=TBevel.Create(OptionsForm);
    with Bevel1 do
    begin
      Parent  := OptionsForm;
      Left    := 8;
      Top     := 29;
      Width   := 449;
      Height  := 50;
      Shape   := bsBottomLine;
      Show;
    end;
    
    ShortcutsLabel:=TLabel.Create(OptionsForm);
    with ShortcutsLabel do
    begin
      Parent    := OptionsForm;
      Left      := 20;
      Top       := 104;
      Width     := 47;
      Height    := 13;
      Caption   := CustomMessage('OptionsFormShortcuts');
      Show;
    end;

    TargetDirEdit:=TEdit.Create(OptionsForm);
    with TargetDirEdit do
    begin
      Parent   := OptionsForm;
      Left     := 104;
      Top      := 29;
      Width    := 225;
      Height   := 30;
      TabOrder := 0;
      Show;
    end;
    TargetDirEdit.Text := targetDir;
       
    BrowserButton := TNewButton.Create(OptionsForm);
    with BrowserButton do
    begin
      Parent:=OptionsForm;
      Left := 352;
      Top := 29;
      Width := 89;
      Height := 25;
      Caption := CustomMessage('BrowserButton');
      TabOrder := 1;
      OnClick := @BrowserButtonOnClick;
      Show;
    end;

    CheckBoxDesktop:=TCheckBox.Create(OptionsForm);
    with CheckBoxDesktop do
    begin
      Parent:=OptionsForm;
      Left := 104;
      Top := 103;
      Width := 150;
      Height := 17;
      Caption := CustomMessage('DesktopShorcut');
      TabOrder := 2;
      Show;
    end;
    CheckBoxDesktop.checked := DesktopIcon;

    CheckBoxStartMenu:=TCheckBox.Create(OptionsForm);
    with CheckBoxStartMenu do
    begin
      Parent:=OptionsForm;
      Left := 104;
      Top := CheckBoxDesktop.Top+CheckBoxDesktop.Height+10;
      Width := 150;
      Height := 17;
      Caption := CustomMessage('StartMenuIcon');
      TabOrder := 3;
      Show;
    end;
    CheckBoxStartMenu.checked := StartMenuIcon;
            
    CheckBoxQuickLunch:=TCheckBox.Create(OptionsForm);
    with CheckBoxQuickLunch do
    begin
      Parent:=OptionsForm;
      Left := 104;
      Top := CheckBoxStartMenu.Top+CheckBoxStartMenu.Height+10;
      Width := 200;
      Height := 17;
      Caption := CustomMessage('QuickLunchIcon');
      TabOrder := 4;
      Show;
    end;
    CheckBoxQuickLunch.checked := QuickLunchIcon;
    
    OKButton := TNewButton.Create(OptionsForm);
    with OKButton do
    begin
      Parent := OptionsForm;
      Width := ScaleX(75);
      Height := ScaleY(23);
      Left := OptionsForm.ClientWidth - ScaleX(75 + 6 + 75 + 10);
      Top := OptionsForm.ClientHeight - ScaleY(23 + 10);
      Caption := SetupMessage(msgButtonOK);
      ModalResult := mrOk;
    end;

    CancelButton := TNewButton.Create(OptionsForm);
    with CancelButton do
    begin
      Parent := OptionsForm;
      Width := ScaleX(75);
      Height := ScaleY(23);
      Left := OptionsForm.ClientWidth - ScaleX(75 + 10);
      Top := OptionsForm.ClientHeight - ScaleY(23 + 10);
      Caption := SetupMessage(msgButtonCancel);
      ModalResult := mrCancel;
      Cancel := True;
    end;

    OptionsForm.ActiveControl := OKButton;

    if OptionsForm.ShowModal() = mrOk then
    begin
      TargetDir      := TargetDirEdit.Text;
      DesktopIcon    := CheckBoxDesktop.checked;
      StartMenuIcon  := CheckBoxStartMenu.checked;
      QuickLunchIcon := CheckBoxQuickLunch.checked;
    end;
  finally
    OptionsForm.Free();
  end;
end;

procedure OptionsButtonOnClick(Sender: TObject);
begin
  Options();
end;

procedure CreateControlButtons(CancelButton,NextButton,BackButton: TNewButton);
begin

  OptionsButton := TNewButton.Create(WizardForm);
  with OptionsButton do
  begin
    Caption := CustomMessage('ButtonOptions');
    Left    := ScaleY(25);
    Top     := CancelButton.Top;
    Width   := ScaleX(150);
    Height  := CancelButton.Height;
    OnClick := @OptionsButtonOnClick;
    Parent  := WizardForm;
  end;


{ *** Modify default setup buttons (NextButton,CancelButton and  BackButton) *** }
  NextButton.Width := ScaleX(200);
  NextButton.Left  := OptionsButton.Left + OptionsButton.Width+ScaleY(85);

  CancelButton.Width :=  ScaleX(100);
  CancelButton.Left  :=  NextButton.Left + NextButton.Width+ScaleY(10);

  BackButton.visible := false;
end;

procedure InitializeWizard();
begin
  { Custom main Wizard form }
  with WizardForm do
  begin
    Width := ScaleX(600);
    MainPanel.visible    := false;
    OuterNotebook.Width  := WizardForm.Width;
    InnerNotebook.Height := ScaleY(300);
    Bevel.Width  :=  WizardForm.Width;
  end;
  { Custom custom wizard form pages }
  CreateTheWizardPages();

  { Custom controls }
  targetDir := ExpandConstant('{pf}\{#MyAppName}');
  AppName   := CustomMessage('AppName');

  { Default state of icons creations }
  DesktopIcon    := {#CreateDesktopIcon};
  StartMenuIcon  := {#CreateStartMenuIcon};
  QuickLunchIcon := {#CreateQuickLunchIcon};

  CreateControlButtons(WizardForm.CancelButton, WizardForm.NextButton, WizardForm.BackButton);
end;

procedure InitializeUninstallProgressForm();
begin
  { not implemeted yet }
end;

function getTargetDir(Param: String) : string;
begin
  Result := targetDir;
end;
