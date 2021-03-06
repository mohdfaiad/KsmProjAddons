unit EtvLook;  (* Igo Val Lev *)

interface

{$I Etv.inc}

uses Windows,Messages,SysUtils,Classes,Graphics,
     Controls,StdCtrls,DB,DBCtrls,Mask,
     EtvDB;

type
  TEtvDataSourceLink = class(TDataSourceLink)
  protected
    function GetDBLookupControl:TDBLookupControl;
    property DBLookupControl:TDBLookupControl read GetDBLookupControl;
    procedure LayoutChanged; override;
    procedure UpdateData; override;
    procedure HideEtvEditors;
  end;

  TEtvListSourceLink = class(TListSourceLink)
  protected
    function GetDBLookupControl:TDBLookupControl;
    property DBLookupControl:TDBLookupControl read GetDBLookupControl;
    procedure ActiveChanged; override;
    procedure LayoutChanged; override;
    procedure ListLinkActiveChanged;
  end;

  TEtvLookupEdit = class(TMaskEdit)
  protected
    FLookup: TWinControl;  (* DBLookupControl / DBGrid *)
    fReturnData:boolean;
    fOldOnExit:TNotifyEvent;
  {protected}
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
    procedure KeyPress(var Key: Char); override;
    property Lookup: TWinControl read FLookup;
  public
    fExist:boolean;
    procedure DoExit; override;
    constructor Create(AOwner: TComponent); override;
    procedure UpdateShow;
  end;

  TEtvPopupDataList=class(TPopupDataList)
  protected
    FHeadLine:boolean;
    FHeadLineCount:smallint;
    procedure KeyPress(var Key: Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
    procedure ProcessSearchKey(Key: Char);

    function GetFKeyField:TField;
    property FKeyField:TField read GetFKeyField;
    function GetFListField:TField;
    property FListField:TField read GetFListField;
    {$IFNDEF Delphi4}
    procedure SelectKeyValue(const Value: Variant);
    function GetTextHeight: Integer;
    function GetSearchText: string;
    procedure SetSearchText(aSearchText:string);
    property SearchText: string read GetSearchText write SetSearchText;
    function GetListFields:TList;
    property ListFields: TList read GetListFields;
    function GetListLink:TListSourceLink;
    property ListLink: TListSourceLink read GetListLink;
    function GetHasFocus:boolean;
    property HasFocus:boolean read GetHasFocus;
    function GetListActive:boolean;
    property ListActive: Boolean read GetListActive;
    {$ENDIF}

  public
    constructor Create(AOwner: TComponent); override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
  end;

  TSetFontEvent = procedure (Sender: TObject; Field:TField;
    Font:TFont) of object;

  { TEtvCustomDBLookupCombo }
  TEtvCustomDBLookupCombo = class(TDBLookupComboBox)
  protected
    FDropDown,fIsSelectNow: Boolean;
    FOrigDataSource: TDataSource;
    FOnDropDown: TNotifyEvent;
    FOldFiltered,FOldUpFiltered:boolean;
    FOldFilter,FOldUpFilter:string;
    FFilterChanged,FFilterUpChanged:boolean;
    fReturnKey:word;
    fShift:TShiftState;
    FCurField:TEtvLookField;
    FOldValue:variant;
    FSubField:String;
    fSetFont:TSetFontEvent;
    FHeadLine:boolean;
    FHeadColor:TColor;
    FHeadLineStr:string;
    FHeadLineMultiStr:TStrings;
    FHeadLineCount:smallint;
    FFilterFieldName: String;
    FLevelUpName: String;
    FLevelDownName: String;
    FFilterKeyName: String;
    fLevel:integer;
    fOnFilter:TOnFieldFilterEvent;
    fLookupLevels:TEtvLookupLevelCol;
    fOldListField,
    fOldKeyField:string;
    fOldListSource:TDataSource;
    fOptions:TEtvLookFieldOptions;
    fEditData:TOnEditDataEvent;

    procedure ListMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    function LookupMode:boolean;

    function GetHeadline:boolean;
    function GetHeadColor:TColor;
    function GetLookupLevelUp:string;
    function GetLookupLevelDown:string;
    function GetLookupFilterField:string;
    function GetLookupFilterKey:string;
    function GetLookupLevels:TEtvLookupLevelCol;
    function GetListFieldIndex:Integer;
    function GetOptions:TEtvLookFieldOptions;
    function GetOnEditData:TOnEditDataEvent;
    function ExistOnFilter:boolean;

    procedure UpdateLevels(aFirst:boolean);
    procedure SetFilter(RezLevel:string);
    procedure SetFilterUp(RezLevel:string);
    procedure UnSetFilter;
    procedure UnSetFilterUp(FIsSelect:boolean);
    procedure EtvDropDown(Sender: TObject);
    procedure EtvCloseUp(FIsSelect:boolean);
    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CANCELMODE;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure Paint; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure SetHeadLineCount(Value:smallint);
    procedure SetListFieldIndex(Value: Integer);
    procedure DoEditData; dynamic;

    function GetFKeyField:TField;
    property FKeyField:TField read GetFKeyField;
    function GetLookupSource:TDataSource;
    property LookupSource:TDataSource read GetLookupSource;
    function GetDataList:TEtvPopupDataList;
    property FDataList:TEtvPopupDataList read GetDataList;
    {$IFNDEF Delphi4}
    procedure SelectKeyValue(const Value: Variant);
    function GetListFields:TList;
    property ListFields: TList read GetListFields;
    function GetListLink:TListSourceLink;
    property ListLink: TListSourceLink read GetListLink;
    function GetHasFocus:boolean;
    property HasFocus:boolean read GetHasFocus;
    function GetListActive:boolean;
    property ListActive: Boolean read GetListActive;
    {$ENDIF}

    procedure Notification(AComponent: TComponent;
                           Operation: TOperation); override;
    procedure ReadLookupLevelsData(Reader: TReader);
    procedure WriteLookupLevelsData(Writer: TWriter);
    procedure DefineProperties(Filer: TFiler); override;
    procedure Loaded; override;
    procedure CheckLookupLevels;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CloseUp(Accept: Boolean); {$IFDEF Delphi4} override; {$ENDIF}
    function CalcWidth:smallint;
    function FilterExist:boolean;
    property HeadLineStr:string read FHeadLineStr write FHeadLineStr;
  published
    property HeadLine:boolean read fHeadLine write fHeadLine default True;
    property HeadColor:TColor read fHeadColor write fHeadColor;
    property HeadLineCount:smallint read fHeadLineCount write SetHeadLineCount default 1;

    property LookupLevels:TEtvLookupLevelCol read fLookupLevels stored false;
    property LookupFilterField: String read fFilterFieldName write fFilterFieldName;
    property LookupLevelUp: String read fLevelUpName write fLevelUpName;
    property LookupLevelDown: String read fLevelDownName write fLevelDownName;
    property LookupFilterKey: String read fFilterKeyName write fFilterKeyName;

    property Options: TEtvLookFieldOptions read fOptions write fOptions
               default TEtvLookFieldOptionsDefault;

    property OnEditData:TOnEditDataEvent read fEditData Write fEditData;
    property OnDropDown: TNotifyEvent read FOnDropDown write FOnDropDown;
    property OnFilter:TOnFieldFilterEvent read fOnFilter write fOnFilter;
    property OnSetFont:TSetFontEvent read fSetFont Write fSetFont;
  end;

  { TEtvDBLookupCombo }
  TEtvDBLookupCombo = class(TEtvCustomDBLookupCombo)
   protected
    FEditCode:TEtvLookupEdit;
    fOnKeyDown:TKeyEvent;
    fEditFieldIndex:smallint;
    procedure Loaded; override;
    procedure KeyPress(var Key: Char); override;
    procedure UpdateEditCode(c:char);
    procedure KeyDown(var Key: Word; Shift: TShiftState);override;
    procedure EtvOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    function GetDataField: string;
    procedure SetDataField(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;

    function AutoWidth:smallint;
    {property EditCode: TEtvLookupEdit Read FEditCode;}
  published
    property DataField:string read GetDataField write SetDataField;
    property OnKeyDown:TKeyEvent read fOnKeyDown write fOnKeyDown;
  end;

IMPLEMENTATION

uses TypInfo,Forms,dbconsts,
     EtvBor,EtvConst,EtvForms,EtvPas,EtvDBFun,EtvPopup,EtvTemp;

Type TWinControlSelf = class(TWinControl)
     end;

{TEtvDataSourceLink}
function TEtvDataSourceLink.GetDBLookupControl:TDBLookupControl;
begin
  Result:=TDataSourceLinkBorland(Self).fDBLookupControl;
end;

procedure TEtvDataSourceLink.HideEtvEditors;
begin
  with TEtvDBLookupCombo(DBLookupControl) do
    if Assigned(FEditCode) and FEditCode.Focused then begin
      FEditCode.Visible:=False;
      SetFocus;
    end;
end;

procedure TEtvDataSourceLink.LayoutChanged;
begin
end;

procedure TEtvDataSourceLink.UpdateData;
begin
  with TEtvDBLookupCombo(DBLookupControl) do
    if Assigned(FEditCode) and FEditCode.fExist then HideEtvEditors;
  inherited;
end;

{ TEtvLookupEdit }
constructor TEtvLookupEdit.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  fReturnData:=true;
  fExist:=false;
  Visible:=False;
end;

procedure TEtvLookupEdit.CNKeyDown(var Message: TWMKeyDown);
begin
  if Message.CharCode=VK_TAB then begin
    fLookup.Setfocus;
    Message.CharCode:=0;
    PostMessage(fLookup.Handle,WM_KeyDown,VK_Tab,0);
  end;
  inherited;
end;

procedure TEtvLookupEdit.DoExit;
begin
  Inherited;
  if Assigned(fOldOnExit) then begin
    TWinControlSelf(fLookup).OnExit:=fOldOnExit;
    fOldOnExit:=nil;
  end;
  if fLookup is TEtvDBLookupCombo then begin
    fExist:=false;
    if (Not ReadOnly) and fReturnData then with TEtvDBLookupCombo(FLookup) do begin
      if (Field is TEtvLookField) and
         Assigned(TEtvLookField(Field).SetEditValue) then
        TEtvLookField(Field).SetEditValue(Field,Self.Text)
      else if (Self.Text<>'') then begin
        try
          if (foValueNotInLookup in GetOptions) and
             (LowerCase(TField(ListFields[fEditFieldIndex]).FieldName)=
              LowerCase(FKeyField.FieldName)) then begin
            if FKeyField is TDateField then
              SelectKeyValue(StrToDate_(Self.Text))
            else if FKeyField is TFloatField then
              SelectKeyValue(StrToFloat(Self.Text))
            else if FKeyField is TNumericField then
              SelectKeyValue(StrToInt(Self.Text))
            else SelectKeyValue(Self.Text);
          end else
            if ListLink.DataSet.Locate(
               TField(ListFields[fEditFieldIndex]).FieldName, Self.Text,
               [loCaseInsensitive,loPartialKey]) then
              SelectKeyValue(FKeyField.Value)
            else begin
              EtvApp.ShowMessage(SInvalidValue);
              fLookup.SetFocus;
            end;
        except
          SetFocus;
          EtvApp.ShowMessage(SInvalidInformation);
        end;
      end else SelectKeyValue(null);
    end;
    fReturnData:=true;
    Visible:=False;
  end;
end;

procedure TEtvLookupEdit.KeyPress(var Key: Char);
var WKey: Word;
begin
  WKey:=Integer(Key);
  Inherited;
  if WKey in [vk_Return, vk_Escape] then begin
    if WKey in [vk_Escape] then fReturnData:=false;
    Visible:=false;
    FLookup.SetFocus;
    if WKey=vk_Return then TWinControlSelf(FLookup).KeyDown(WKey,[]);
  end;
end;

procedure TEtvLookupEdit.UpdateShow;
begin
  if Assigned(TWinControlSelf(FLookup).OnExit) then begin
    fOldOnExit:=TWinControlSelf(FLookup).OnExit;
    TWinControlSelf(FLookup).OnExit:=nil;
  end;
  Visible:=True;
  SetFocus;
  fExist:=true;
end;

{TEtvPopupDataList}
constructor TEtvPopupDataList.Create(AOwner: TComponent);
begin
  inherited;
  Font.Assign(TDBLookupComboBox(AOwner).Font);
end;

procedure TEtvPopupDataList.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  if fHeadLine then begin
    AHeight:=AHeight+GetTextHeight*fHeadLineCount;
    if HandleAllocated and not IsIconic(Handle) then
      SetWindowPos(Handle, 0, ALeft, ATop, AWidth, AHeight,
        SWP_NOZORDER + SWP_NOACTIVATE)
    else TControlBorland(Self).fHeight := AHeight;
    RequestAlign;
  end;
end;

procedure TEtvPopupDataList.KeyPress(var Key: Char);
var s:string;
begin
  if Assigned(OnKeyPress) then OnKeyPress(Self, Key);
  ProcessSearchKey(Key);
  if Key=Char(VK_Back) then begin
    S:=SearchText;
    Delete(S,Length(S),1);
    SearchText:=S;
    if (S='') then KeyValue:=TDBLookupComboBox(Owner).KeyValue
    else if ListLink.DataSet.Locate(FListField.FieldName,
             S,[loCaseInsensitive, loPartialKey]) then
        KeyValue:=FKeyField.Value;
    TControl(Owner).Invalidate;
  end;
end;

procedure TEtvPopupDataList.KeyDown(var Key: Word; Shift: TShiftState);
var bm:TBookMark;
begin
  if (Key in [VK_UP, VK_LEFT, VK_DOWN, VK_RIGHT,
             VK_PRIOR, VK_NEXT, VK_HOME, VK_END]) and
     (SearchText<>'') then begin
    SearchText:='';
    BM:=ListLink.DataSet.GetBookMark;
    TEtvDBLookupCombo(Owner).Paint;
    ListLink.DataSet.GotoBookMark(BM);
    ListLink.DataSet.FreeBookMark(BM);
  end;
  inherited;
end;

procedure TEtvPopupDataList.MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
begin
  if fHeadLine then Y:=Y-GetTextHeight*FHeadLineCount;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TEtvPopupDataList.MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
begin
  if ssCtrl in Shift then begin
    TEtvCustomDBLookupCombo(Parent).FIsSelectNow:=true;
  end;
  if fHeadLine then Y:=Y-GetTextHeight*FHeadLineCount;
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TEtvPopupDataList.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if fHeadLine then Y:=Y-GetTextHeight*FHeadLineCount;
  inherited MouseMove(Shift, X, Y);
end;

function VarEquals(const V1, V2: Variant): Boolean;
begin
  Result := False;
  try
    Result := V1 = V2;
  except
  end;
end;

procedure TEtvPopupDataList.Paint;
var
  I, J, W, X, TextWidth, TextHeight, LastFieldIndex: Integer;
  S,S1: string;
  R: TRect;
  Selected: Boolean;
  Field: TField;
  FieldDown:TField;
  lAlignment:TALignment;
begin
  Canvas.Font:=Font;
  TextWidth := Canvas.TextWidth('0');
  TextHeight := Canvas.TextHeight('0');
  LastFieldIndex := ListFields.Count - 1;
  if ColorToRGB(Color) <> ColorToRGB(clBtnFace) then
    Canvas.Pen.Color := clBtnFace
  else Canvas.Pen.Color := clBtnShadow;

  with TEtvCustomDBLookupCombo(Owner) do
    FieldDown:=ListLink.DataSet.FindField(GetLookupLevelDown);
  (*  print of header *)
  if fHeadLine then begin
    if Enabled then
      Canvas.Font.Color := Font.Color
    else Canvas.Font.Color := clGrayText;
    Canvas.Brush.Color :=TEtvCustomDBLookupCombo(Owner).GetHeadColor;
    R.Top :=0;
    R.Bottom := R.Top + TextHeight*fHeadLineCount;
    R.Left:=0;
    R.Right:=ClientWidth;
    S:=TEtvCustomDBLookUpCombo(Parent).FHeadLineStr;
    if s<>'' then begin
      {$IFDEF ForLev}
      Canvas.Font.Color:=clRed;
      {$ENDIF}
      j:=1;
      for i:=0 to fHeadLineCount-1 do begin
        R.Bottom:=R.Top+TextHeight;
        if j<=Length(s) then begin
          s1:=copy(s,j,ClientWidth div TextWidth);
          Canvas.TextRect(R, (R.Right - Canvas.TextWidth(S1)) div 2, R.Top,s1);
          j:=j+ClientWidth div TextWidth;
        end else Canvas.TextRect(R,0,R.Top,'');
        R.Top:=R.Top+TextHeight;
      end;
      Canvas.MoveTo(0, R.Bottom-1);
      Canvas.LineTo(ClientWidth, R.Bottom-1);
    end else if TEtvCustomDBLookUpCombo(Parent).FHeadLineMultiStr.Count>0 then begin
      j:=TEtvCustomDBLookUpCombo(Parent).FHeadLineMultiStr.Count-fHeadLineCount;
      for i:=0 to fHeadLineCount-1 do begin
        R.Bottom:=R.Top+TextHeight;
        if j+i>=0 then begin
          s:=TEtvCustomDBLookUpCombo(Parent).FHeadLineMultiStr[j+i];
          Canvas.TextRect(R, (R.Right - Canvas.TextWidth(S)) div 2, R.Top,S);
          Canvas.MoveTo(0, R.Bottom-1);
          Canvas.LineTo(ClientWidth, R.Bottom-1);
        end else Canvas.TextRect(R, 0, R.Top,'');
        R.Top:=R.Top+TextHeight;
      end;
      if ColorToRGB(Color) <> ColorToRGB(clBtnFace) then
        Canvas.Pen.Color := clBtnFace
      else Canvas.Pen.Color := clBtnShadow;
    end else begin{ Print field labels }
      R.Right := 0;
      for J := 0 to LastFieldIndex do begin
        Field := ListFields[J];
        if J < LastFieldIndex then
          W := Field.DisplayWidth * TextWidth + 4 else
          W := ClientWidth - R.Right;
        S := Field.DisplayLabel;
        X := (W - Canvas.TextWidth(S)) div 2;
        R.Left := R.Right;
        R.Right := R.Right + W;
        if (j=0) and Assigned(FieldDown) then
          R.Right:=R.Right+Canvas.TextWidth('+')+1;
        Canvas.TextRect(R, R.Left + X, R.Top, S);
        if J < LastFieldIndex then begin
          Inc(R.Right);
          if R.Right >= ClientWidth then Break;
        end;
      end
    end;
    {Canvas.MoveTo(0, R.Bottom-1);
    Canvas.LineTo(ClientWidth, R.Bottom-1);}
  end;

  for I := 0 to TDBLookupListBoxBorland(Self).FRowCount - 1 do begin
    if Enabled then
      Canvas.Font.Color := Font.Color
    else Canvas.Font.Color := clGrayText;
    Canvas.Brush.Color := Color;
    Selected := not TDBLookupListBoxBorland(Self).FKeySelected and (I = 0);
    R.Top :=I * TextHeight;
    if fHeadLine then R.Top := R.Top + TextHeight*FHeadLineCount;
    R.Bottom := R.Top + TextHeight;
    if I < TDBLookupListBoxBorland(Self).FRecordCount then begin
      ListLink.ActiveRecord := I;
      if not VarIsNull(KeyValue) and
        VarEquals(FKeyField.Value,KeyValue) then
      begin
        Canvas.Font.Color := clHighlightText;
        Canvas.Brush.Color := clHighlight;
        Selected := True;
      end;

      R.Right := 0;
     {Etv Begin}
      (* [+] *)
      if Assigned(FieldDown) then begin
        R.Left:=0;
        R.Right:=Canvas.TextWidth('+')+1;
        if FieldDown.AsInteger>0 then Canvas.TextRect(R, R.Left+1, R.Top, '+')
        else Canvas.TextRect(R, R.Left, R.Top, '');
      end;

      if Assigned(TEtvCustomDBLookupCombo(Owner).fSetFont) then
        TEtvCustomDBLookupCombo(owner).
          fSetFont(Self,FKeyField,Canvas.Font);
      {Etv End}
      for J := 0 to LastFieldIndex do
      begin
        Field := ListFields[J];
        if J < LastFieldIndex then
          W := Field.DisplayWidth * TextWidth + 4 else
          W := ClientWidth - R.Right;
        S := Field.DisplayText;
        X := 2;

        lAlignment := Field.Alignment;
        {$IFDEF Delphi4}
        if UseRightToLeftAlignment then ChangeBiDiModeAlignment(lAlignment);
        {$ENDIF}
        case lAlignment of
          taRightJustify: X := W - Canvas.TextWidth(S) - 3;
          taCenter: X := (W - Canvas.TextWidth(S)) div 2;
        end;
        R.Left := R.Right;
        R.Right := R.Right + W;
        {$IFDEF Delphi4}
        if SysLocale.MiddleEast then TControlCanvas(Canvas).UpdateTextFlags;
        {$ENDIF}
        Canvas.TextRect(R, R.Left + X, R.Top, S);
        if J < LastFieldIndex then begin
          if (i=0) and (TEtvCustomDBLookUpCombo(Parent).FHeadLineStr='') and
             (TEtvCustomDBLookUpCombo(Parent).FHeadLineMultiStr.Count=0)then
            Canvas.MoveTo(R.Right, 0)
          else Canvas.MoveTo(R.Right, R.Top);
          Canvas.LineTo(R.Right, R.Bottom);
          Inc(R.Right);
          if R.Right >= ClientWidth then Break;
        end;
      end;
    end;
    R.Left := 0;
    R.Right := ClientWidth;
    if I >= TDBLookupListBoxBorland(Self).FRecordCount then Canvas.FillRect(R);
    if Selected and (HasFocus or
       TDBLookupListBoxBorland(Self).FPopup) then Canvas.DrawFocusRect(R);
  end;
  if TDBLookupListBoxBorland(Self).FRecordCount <> 0 then
    ListLink.ActiveRecord :=
      TDBLookupListBoxBorland(Self).FRecordIndex;
end;

function TEtvPopupDataList.GetFKeyField:TField;
begin
  Result:=TDBLookupControlBorland(Self).FKeyField;
end;

function TEtvPopupDataList.GetFListField:TField;
begin
  Result:=TDBLookupControlBorland(Self).FListField;
end;

{$IFNDEF Delphi4}
procedure TEtvPopupDataList.SelectKeyValue(const Value: Variant);
begin
  with Self,TDBLookupControlBorland(self) do begin
    if FMasterField <> nil then begin
      if FDataLink.Edit then
        FMasterField.Value := Value;
    end else
      KeyValue:=Value;
    Repaint;
    Click;
  end;
end;

function TEtvPopupDataList.GetTextHeight: Integer;
var
  DC: HDC;
  SaveFont: HFont;
  Metrics: TTextMetric;
begin
  DC := GetDC(0);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  Result := Metrics.tmHeight;
end;

function TEtvPopupDataList.GetSearchText: string;
begin
  Result:=TDBLookupControlBorland(self).FSearchText;
end;

procedure TEtvPopupDataList.SetSearchText(aSearchText:string);
begin
  TDBLookupControlBorland(self).FSearchText:=aSearchText;
end;

function TEtvPopupDataList.GetListFields:TList;
begin
  Result:=TDBLookupControlBorland(Self).FListFields;
end;

function TEtvPopupDataList.GetListLink:TListSourceLink;
begin
  Result:=TDBLookupControlBorland(Self).FListLink;
end;

function TEtvPopupDataList.GetHasFocus:Boolean;
begin
  Result:=TDBLookupControlBorland(Self).FFocused;
end;

function TEtvPopupDataList.GetListActive:boolean;
begin
  Result:=TDBLookupControlBorland(Self).FListActive;
end;
{$ENDIF}

procedure TEtvPopupDataList.ProcessSearchKey(Key: Char);
const SetIntType=[ftSmallint,ftInteger,ftWord,ftFloat,ftCurrency,ftAutoInc];
var S: string;
begin
{Etv begin}
{  if (FListField <> nil) and (FListField.FieldKind = fkData) and
    (FListField.DataType = ftString) then}
  if (FListField <> nil) and (FListField.FieldKind = fkData) and
    ((FListField.DataType=ftString) or
    ((FListField.DataType in SetIntType) and
      (Key in ['0'..'9']))) then {Lev 30/04/97}
{Etv end}
    case Key of
      {#8,} #27: SearchText := '';
      #32..#255: With TDBLookupControlBorland(self) do
        if ListActive and not ReadOnly and ((FDataLink.DataSource = nil) or
          (FMasterField <> nil) and FMasterField.CanModify) then begin
          if Length(SearchText) < 32 then begin
            S := SearchText + Key;
            try
              if ListLink.DataSet.Locate(FListField.FieldName, S,
                 [loCaseInsensitive, loPartialKey]) then begin
                SelectKeyValue(FKeyField.Value);
                SearchText := S;
              end else {Lev 30/04/97}
                if  FListField.DataType in SetIntType then if Length(SearchText)<8 then
                  SearchText := S;
            except
            end;
            TControl(Owner).Invalidate;
          end;
        end;
    end;
end;

{ TEtvCustomDBLookupCombo }
constructor TEtvCustomDBLookupCombo.Create(AOwner: TComponent);
var OldDataList:TPopupDataList;
begin
  inherited;
  fHeadLine:=true;
  fHeadColor:=DefaultHeadColor;
  fHeadLineCount:=1;
  fHeadLineMultiStr:=TStringList.Create;
  fLookupLevels:=TEtvLookupLevelCol.Create(TEtvLookupLevelItem);
  fLookupLevels.Owner:=Self;
  fOptions:=TEtvLookFieldOptionsDefault;

  TListSourceLinkBorland(ListLink).FDBLookupControl:=nil;
  ListLink.free;

  OldDataList:=TPopupDataList(FDataList);
  TDBLookupComboBoxBorland(Self).FDataList:=TEtvPopupDataList.Create(self);
  FDataList.Visible := False;
  FDataList.Parent := Self;
  OldDataList.free;

  TDBLookupControlBorland(Self).FListLink := TEtvListSourceLink.Create;
  TListSourceLinkBorland(ListLink).FDBLookupControl := Self;

  Inherited OnDropDown:=EtvDropDown;
  FDataList.OnMouseUp := ListMouseUp;
  fOrigDataSource:=nil;
  fLevel:=-1;
  FCurField:=nil;
  FFilterChanged:=false;
  FFilterUpChanged:=false;
  fIsSelectNow:=false;
  fOldValue:=null;
end;

destructor TEtvCustomDBLookupCombo.Destroy;
begin
  fHeadLineMultiStr.Free;
  fLookupLevels.Free;
  inherited;
end;

procedure TEtvCustomDBLookupCombo.Notification(AComponent: TComponent; Operation: TOperation);
var i:integer;
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
    for i:=0 to fLookupLevels.Count-1 do
      if fLookupLevels.DataSet[i]=AComponent then
        fLookupLevels.DataSet[i]:=nil;
end;

procedure TEtvCustomDBLookupCombo.ReadLookupLevelsData(Reader: TReader);
begin
  Reader.ReadValue;
  Reader.ReadCollection(LookupLevels);
end;

procedure TEtvCustomDBLookupCombo.WriteLookupLevelsData(Writer: TWriter);
begin
  Writer.WriteCollection(LookupLevels);
end;

procedure TEtvCustomDBLookupCombo.DefineProperties(Filer: TFiler);
  function WriteData: Boolean;
  begin
    Result:=FLookupLevels.Count>0;
  end;
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('LookupLevelsData',ReadLookupLevelsData,WriteLookupLevelsData,WriteData);
end;

procedure TEtvCustomDBLookupCombo.Loaded;
begin
  inherited;
  if ListLink.Active and Assigned(FKeyField) then CheckLookupLevels;
end;

procedure TEtvCustomDBLookupCombo.CheckLookupLevels;
var i:integer;
begin
  for i:=0 to LookupLevels.Count-1 do begin
    if (not Assigned(LookupLevels.DataSet[i])) or
       (LookupLevels.KeyField[i]='') or
       (LookupLevels.ResultFields[i]='') then
      DatabaseErrorFmt(SLookupInfoError, [Name]);
    if Not LookupLevels.DataSet[i].Active then LookupLevels.DataSet[i].Open;
    GetFieldProperty(LookupLevels.DataSet[i],Self,LookupLevels.KeyField[i]);
    try
      CheckFieldNames(LookupLevels.DataSet[i],LookupLevels.ResultFields[i]);
    except
      DatabaseErrorFmt(SFieldNotFound, [Name, LookupLevels.ResultFields[i]]);
    end;
  end;
end;

procedure TEtvCustomDBLookupCombo.CloseUp(Accept: Boolean);
begin
  if ListVisible then begin
    fDropDown:=false;
    EtvCloseUp(Accept);
    if not fDropDown then begin
      inherited CloseUp(Accept);
      fCurField:=nil;
      fHeadLineMultiStr.Clear;
      KeyReturn(Self,fReturnKey,fShift);
      fReturnKey:=0;
    end else begin
      inherited CloseUp(false);
      fReturnKey:=0;
      DropDown;
    end;
  end;
end;

procedure TEtvCustomDBLookupCombo.SetListFieldIndex(Value: Integer);
begin
  if Value<=ListFields.Count - 1 then
    ListFieldIndex:=Value else ListFieldIndex:=0;
  TEtvListSourceLink(ListLink).ActiveChanged;
  if (Field is TEtvLookField) then
    TEtvLookField(Field).ListFieldIndex:=ListFieldIndex;
end;

procedure TEtvCustomDBLookupCombo.DoEditData;
var PropInfo: PPropInfo;
    lOnEditData:TOnEditDataEvent;
    OldTag:TList;
    i:smallint;
    lField:TField;
    FieldReturn:TFieldReturn;
    lDataSet:TDataSet;
    lItemDataSet:TItemDataSet;
    DS:TDataSource;
begin
  lOnEditData:=GetOnEditData();
  if Assigned(lOnEditData) then begin
    lField:=Field;
    OldTag:=nil;
    if Assigned(lField) and (lField.DataSet.State in [dsInsert,dsEdit]) then begin
      OldTag:=TList.Create;
      {EtvApp.DisableRefreshForm;}
      lDataSet:=lField.DataSet;
      repeat
        lItemDataSet:=TItemDataSet.Create;
        lItemDataSet.DataSet:=lDataSet;
        lItemDataSet.tag:=lDataSet.Tag;
        OldTag.Add(lItemDataSet);
        lDataSet.Tag:=80;

        DS:=nil;
        PropInfo := GetPropInfo(lDataSet.ClassInfo, 'MasterSource');
        if PropInfo <> nil then
          DS:=TDataSource(GetOrdProp(lDataSet,PropInfo))
        else begin
          PropInfo := GetPropInfo(lDataSet.ClassInfo, 'DataSource');
          if PropInfo <> nil then
            DS:=TDataSource(GetOrdProp(lDataSet,PropInfo));
        end;
        if Assigned(DS) and Assigned(DS.DataSet) then
          lDataSet:=DS.DataSet
        else break;
      until false;
    end;

    FieldReturn:=TFieldReturn.Create(nil);
    if Assigned(lField) and (lField.FieldKind=fkLookup) then
      FieldReturn.Field:=lField.LookupKeyFields
    else FieldReturn.Field:=KeyField;
    FieldReturn.Value:=KeyValue;

    OkOnEditData:=false;
    try
      lOnEditData(Self,viShowModal,FieldReturn);
    except
    end;

    if Assigned(OldTag) then begin
      {EtvApp.EnableRefreshFormNow;}
      for i:=0 to OldTag.Count-1 do begin
        TItemDataSet(OldTag.Items[i]).DataSet.Tag:=
          TItemDataSet(OldTag.Items[i]).Tag;
        TItemDataSet(OldTag.Items[i]).Free;
      end;
      OldTag.free;
    end;

    if OkOnEditData and (not Self.ReadOnly) then begin
      if Assigned(lField) then begin
        if lField.FieldKind=fkLookup then
          lField:=lField.DataSet.fieldByName(lField.KeyFields);
        if lField.CanModify then begin
          if not (lField.Dataset.state in [dsInsert,dsEdit]) then
            lField.Dataset.Edit;
          lField.value:=FieldReturn.Value;
        end;
      end else KeyValue:=FieldReturn.Value;
    end;
    FieldReturn.free;
  end;
end;

function TEtvCustomDBLookupCombo.GetFKeyField:TField;
begin
  Result:=TDBLookupControlBorland(Self).FKeyField;
end;

function TEtvCustomDBLookupCombo.GetLookupSource:TDataSource;
begin
  Result:=TDBLookupControlBorland(Self).FLookupSource;
end;

function TEtvCustomDBLookupCombo.GetDataList:TEtvPopupDataList;
begin
  Result:=TEtvPopupDataList(TDBLookupComboBoxBorland(Self).FDataList);
end;

{$IFNDEF Delphi4}
procedure TEtvCustomDBLookupCombo.SelectKeyValue(const Value: Variant);
begin
  with Self,TDBLookupControlBorland(self) do begin
    if FMasterField <> nil then begin
      if FDataLink.Edit then
        FMasterField.Value := Value;
    end else
      KeyValue:=Value;
    Repaint;
    Click;
  end;
end;

function TEtvCustomDBLookupCombo.GetListFields:TList;
begin
  Result:=TDBLookupControlBorland(Self).FListFields;
end;

function TEtvCustomDBLookupCombo.GetListLink:TListSourceLink;
begin
  Result:=TDBLookupControlBorland(Self).FListLink;
end;

function TEtvCustomDBLookupCombo.GetHasFocus:Boolean;
begin
  Result:=TDBLookupControlBorland(Self).FFocused;
end;

function TEtvCustomDBLookupCombo.GetListActive:boolean;
begin
  Result:=TDBLookupControlBorland(Self).FListActive;
end;
{$ENDIF}

procedure TEtvCustomDBLookupCombo.SetFilter(RezLevel:string);
var lFilter:string;
begin
  lFilter:='';
  if RezLevel='' then RezLevel:='null';
  if (GetLookupFilterField<>'') then
    lFilter:=GetLookupFilterField+'='+RezLevel;
  if ExistOnFilter then
    if Assigned(fCurField)then
      lFilter:=AddFilterCondition(lFilter,fCurField.OnFilter(fCurField))
    else lFilter:=AddFilterCondition(lFilter,fOnFilter(Self));
  if lFilter<>'' then begin
    FFilterChanged:=True;
    FOldFiltered:=ListLink.DataSet.Filtered;
    FOldFilter:=ListLink.DataSet.Filter;
    ListLink.DataSet.Filter:=AddFilterCondition(ListLink.DataSet.Filter,lFilter);
    ListLink.DataSet.Filtered:=true;
  end;
end;

procedure TEtvCustomDBLookupCombo.SetFilterUp(RezLevel:string);
var lFilterUp:string;
begin
  lFilterUp:=GetLookupLevelUp;
  if (lFilterUp<>'') then begin
    if RezLevel='' then RezLevel:='null';
    if FFilterUpChanged then
      ListLink.DataSet.Filter:=AddFilterCondition(FOldUpFilter,
        '('+lFilterUp+'='+RezLevel+')'
        +' and ('+lFilterUp+'<>null)') (* with line for SAW *)
    else begin
      FOldUpFiltered:=ListLink.DataSet.Filtered;
      FOldUpFilter:=ListLink.DataSet.Filter;
      ListLink.DataSet.Filter:=AddFilterCondition(FOldUpFilter,
        '('+lFilterUp+'='+RezLevel+')');
      ListLink.DataSet.Filtered:=true;
      FFilterUpChanged:=True;
    end;
  end;
end;

procedure TEtvCustomDBLookupCombo.UnSetFilter;
begin
  if FFilterChanged then begin
    ListLink.DataSet.Filter:=FOldFilter;
    ListLink.DataSet.Filtered:=FOldFiltered;
    FFilterChanged:=false;
  end;
end;

procedure TEtvCustomDBLookupCombo.UnSetFilterUp(FIsSelect:boolean);
begin
  if FFilterUpChanged then begin
    ListLink.DataSet.Filter:=FOldUpFilter;
    ListLink.DataSet.Filtered:=FOldUpFiltered;
    FFilterUpChanged:=false;

    if (Not fIsSelect) and (fOldValue<>KeyValue) then
      KeyValue:=fOldValue;
  end;
end;

function TEtvCustomDBLookupCombo.LookupMode:boolean;
begin
  Result:=TDBLookupControlBorland(Self).fLookupMode;
end;

function TEtvCustomDBLookupCombo.GetHeadline:boolean;
begin
 if Assigned(Field) and (Field is TEtvLookField) then
   Result:=TEtvLookField(Field).Headline
 else Result:=fHeadline;
end;

function TEtvCustomDBLookupCombo.GetOnEditData:TOnEditDataEvent;
var PropInfo: PPropInfo;
begin
  Result:=nil;
  if Assigned(Field) and (Field is TEtvLookField) then
    Result:=TEtvLookField(Field).OnEditData;
  if not Assigned(Result) then Result:=OnEditData;
  if not Assigned(Result) then begin
    PropInfo := GetPropInfo(ListLink.DataSet.ClassInfo, 'OnEditData');
    if PropInfo <> nil then
      Result:=TOnEditDataEvent(GetMethodProp(ListLink.DataSet,PropInfo));
  end;
end;

function TEtvCustomDBLookupCombo.GetHeadColor:TColor;
begin
 if Assigned(Field) and (Field is TEtvLookField) then
   Result:=TEtvLookField(Field).HeadColor
 else Result:=fHeadColor;
end;

function TEtvCustomDBLookupCombo.GetLookupLevelUp:string;
begin
  Result:='';
  if (fLevel<0) or (fLevel>GetLookupLevels.Count-1) then
    if LookupMode and (Field is TEtvLookField) then
      Result:=TEtvLookField(Field).LookupLevelUp
    else  Result:=LookupLevelUp;
end;

function TEtvCustomDBLookupCombo.GetLookupLevelDown:string;
begin
  Result:='';
  if (fLevel<0) or (fLevel>GetLookupLevels.Count-1) then
    if LookupMode and (Field is TEtvLookField) then
      Result:=TEtvLookField(Field).LookupLevelDown
    else  Result:=LookupLevelDown;
end;

function TEtvCustomDBLookupCombo.GetLookupFilterField:string;
begin
  if (fLevel>=0) and (fLevel<=GetLookupLevels.Count-1) then
    Result:=GetLookupLevels.FilterField[fLevel]
  else if LookupMode and (Field is TEtvLookField) then
    Result:=TEtvLookField(Field).LookupFilterField
    else  Result:=LookupFilterField;
end;

function TEtvCustomDBLookupCombo.GetLookupFilterKey:string;
begin
  Result:='';
  if (fLevel<0) or (fLevel>GetLookupLevels.Count-1) then
    if Assigned(fCurField) then Result:=fCurField.LookupFilterKey
    else Result:=LookupFilterKey;
end;

function TEtvCustomDBLookupCombo.GetLookupLevels:TEtvLookupLevelCol;
begin
  if Assigned(fCurField) then
    Result:=fCurField.LookupLevels
  else Result:=LookupLevels;
end;

function TEtvCustomDBLookupCombo.GetListFieldIndex:Integer;
begin
  if Assigned(Field) and (Field is TEtvLookField) then
    Result:=TEtvLookField(Field).ListFieldIndex
  else Result:=ListFieldIndex;
end;

function TEtvCustomDBLookupCombo.GetOptions:TEtvLookFieldOptions;
begin
 if Assigned(Field) and (Field is TEtvLookField) then
   Result:=TEtvLookField(Field).Options
 else Result:=fOptions;
end;

function TEtvCustomDBLookupCombo.ExistOnFilter:boolean;
begin
  Result:=false;
  if (fLevel<0) or (fLevel>GetLookupLevels.Count-1) then
    if Assigned(fCurField) then Result:=Assigned(fCurField.OnFilter)
    else Result:=Assigned(fOnFilter);
end;

procedure TEtvCustomDBLookupCombo.UpdateLevels(aFirst:boolean);
var Item:TEtvLookupLevelItem;
    lValue:variant;
begin
  Item:=TEtvLookupLevelItem(GetLookupLevels.Items[fLevel]);
  if aFirst then begin
    fOldListField:=ListField;
    fOldKeyField:=KeyField;
    if fCurField=nil then fOldListSource:=ListSource;
  end;
  ListField:=Item.ResultFields;
  KeyField:=Item.KeyField;

  lValue:=Item.DataSet.FieldbyName(Item.KeyField).Value;
  LookupSource.DataSet:=Item.DataSet;
  ListLink.DataSource:=LookupSource;
  KeyValue:=lValue;
end;

procedure TEtvCustomDBLookupCombo.EtvDropDown(Sender: TObject);
var FilterField:TField;
    SFilter: String;
begin
  Application.ProcessMessages;
  if Assigned(FOnDropDown) then FOnDropDown(Sender);
  fDataList.FHeadLine:=GetHeadLine;
  fDataList.FHeadLineCount:=fHeadLineCount;
  if foAutoDropDownWidth in GetOptions then
    DropdownWidth:=(CalcWidth+3)*Canvas.TextWidth('0');

  if LookupMode and (Field is TEtvLookField) then begin
    fCurField:=TEtvLookField(Field);
    if ListFieldIndex<>fCurField.ListFieldIndex then
      SetListFieldIndex(fCurField.ListFieldIndex);
  end;
  if (fLevel<0) and (not fFilterUpChanged) then begin
    fOldValue:=KeyValue;

    if GetLookupLevels.Count>0 then begin
      fOrigDataSource:=DataSource;
      DataSource:=nil;
      Inc(fLevel);
      UpdateLevels(true);
    end else
      if ((GetLookupFilterKey<>'') or ExistOnFilter) then begin
        SFilter:=GetLookupFilterKey;
        if Assigned(Field) then begin
          FilterField:=Field.DataSet.FindField(SFilter);
          if Assigned(FilterField) then SFilter:=FilterField.AsString;
        end;
        SetFilter(SFilter);
      end;
  end;
  if not FFilterUpChanged then SetFilterUp('');
end;

procedure TEtvCustomDBLookupCombo.EtvCloseUp(FIsSelect:boolean);
var RezLevel:string;
    j:smallint;
    s:string;
  procedure SetOriginal;
  begin
    FDataList.ListSource:=nil;
    ListField:=fOldListField;
    KeyField:=fOldKeyField;
    if Assigned(ListSource) then ListSource:=nil;
    if fCurField=nil then
      ListLink.DataSource:=fOldListSource;
    if Assigned(fOrigDataSource) then begin
      DataSource:=fOrigDataSource;
      fOrigDataSource:=nil;
    end else KeyValue:=fOldValue;
  end;
begin
  FDataList.SearchText:='';
  RezLevel:=FKeyField.AsString;

  s:='';
  for J := 0 to ListFields.Count-1 do with TField(ListFields[J]) do begin
    if j>0 then s:=s+':';
    if length(DisplayText)>DisplayWidth then
      s:=s+sform(DisplayText,DisplayWidth,Alignment)
    else s:=s+DisplayText;
  end;
  FHeadLineMultiStr.Add(s);

     (* for CodeUp *)
  if fFilterUpChanged then begin
    if (not fIsSelectNow) and fIsSelect then begin
      SetFilterUp(RezLevel);
      if (ListLink.DataSet.BOF) and (ListLink.DataSet.EOF) then
        UnSetFilterUp(FIsSelect)
      else begin
        fReturnKey:=0;
        fDropDown:=true;
        Exit;
      end;
    end else UnSetFilterUp(FIsSelect);
  end;
  fIsSelectNow:=false;

  UnSetFilter; (* filter disconnect *)
  if (fLevel>=0) then
    if FIsSelect then begin
      if fLevel<=GetLookupLevels.Count-1 then begin(* it's not end *)
        (* Change level *)
        inc(fLevel);
        if fLevel>GetLookupLevels.Count-1 then (* Last level *)
          SetOriginal
        else UpdateLevels(false); (* No end level *)
        SetFilter(RezLevel); (* Set filter *)
        fDropDown:=true;
      end else fLevel:=-1;
    end else begin
      if fLevel<=GetLookupLevels.Count-1 then SetOriginal;
      fLevel:=-1;
    end;
end;

procedure TEtvCustomDBLookupCombo.Paint;
var
  J, W, X, TextWidth, Flags, LastFieldIndex: Integer;
  S: string;
  Selected: Boolean;
  R: TRect;
  lField: TField;
  Scheme:byte;
begin
  try
    if Not (Assigned(ListLink.DataSet) and
            ListLink.DataSet.Active) then begin
      Inherited;
      Exit;
    end
  except
    Inherited;
    Exit;
  end;

  Canvas.Font := Font;
  if Assigned(fSetFont) then
    FSetFont(Self,FKeyField,Canvas.Font);
  Canvas.Brush.Color := Color;
  if FDataList.SearchText<>'' then begin
    if ColorToRGB(Color) <> ColorToRGB(clBlue) then
      Canvas.Font.Color := clBlue
  end;

  Selected:=HasFocus and
    not Inherited ListVisible and  not (csPaintCopy in ControlState);
  TextWidth := Canvas.TextWidth('0');
  LastFieldIndex := ListFields.Count - 1;
  if ColorToRGB(Color) <> ColorToRGB(clBtnFace) then
    Canvas.Pen.Color := clBtnFace
  else Canvas.Pen.Color := clBtnShadow;
  if Selected then begin
    Canvas.Font.Color := clHighlightText;
    Canvas.Brush.Color := clHighlight;
  end;

  R.Top := 0;
  R.Bottom := ClientHeight;
  R.Right := 1;

  Scheme:=0;
  if FDataList.SearchText<>'' then
    Scheme:=1
  else if Assigned(Field) then
    if (Field is TEtvLookField) and
       Assigned(Field.DataSet) and
       (Field.DataSet.state<>dsSetKey) then Scheme:=2
    else begin
      if LastFieldIndex=0 then
        if (csPaintCopy in ControlState) and (Field.Lookup) then Scheme:=3
        else Scheme:=4
      else if ListLink.DataSet.Locate(TDBLookupControlBorland(Self).FKeyFieldName,
        KeyValue, []) then Scheme:=5;
    end
  else if ListLink.DataSet.Locate(TDBLookupControlBorland(Self).FKeyFieldName,
        KeyValue, []) then Scheme:=5;

  for J := 0 to LastFieldIndex do begin
    lField := ListFields[J];
    if J < LastFieldIndex then
      W := lField.DisplayWidth * TextWidth + 4
    else W := ClientWidth - R.Right-TDBLookupComboBoxBorland(Self).FButtonWidth;

    S:='';
    case Scheme of
      1: if J=GetListFieldIndex then
        S:= FDataList.SearchText;
      2: begin TEtvLookField(Field).VFieldIndex:=J;
        s:=Field.DisplayText;
      end;
      3: S := Field.DisplayText;
      4: s:=Text;
      5: S := lField.DisplayText;
      else
        if (KeyValue<>NULL)and
           (UpperCase(TDBLookupControlBorland(Self).FKeyFieldName)=
             UpperCase(lField.FieldName)) then begin
          S:=VarAsType(KeyValue,varString);
          if not (foValueNotInLookup in GetOptions) and
             (ColorToRGB(Color) <> ColorToRGB(clRed)) then
            Canvas.Font.Color := clRed
        end;
    end; (* of Case *)
    X := 2;
    case lField.Alignment of
      taRightJustify: X := W - Canvas.TextWidth(S) - 3;
      taCenter: X := (W - Canvas.TextWidth(S)) div 2;
    end;
    R.Left := R.Right;
    R.Right := R.Right + W;
    Canvas.TextRect(R, R.Left + X, 2, S);
    if J < LastFieldIndex then begin
      Canvas.MoveTo(R.Right, R.Top);
      Canvas.LineTo(R.Right, R.Bottom);
      Inc(R.Right);
      if R.Right >= ClientWidth then Break;
    end;
    if Focused and (j=GetListFieldIndex) then begin
      Canvas.MoveTo(R.Left+1, R.Bottom-3);
      Canvas.LineTo(R.Left+13, R.Bottom-3);
    end;
  end;
  if Scheme=2 then
    TEtvLookField(Field).VFieldIndex:=-1;

  {+++++++++++++++++++++++++++++++++++++++++++++++++++++}
  W := ClientWidth - TDBLookupComboBoxBorland(Self).FButtonWidth;
  SetRect(R, 1, 0, W, ClientHeight);
  if Selected then Canvas.DrawFocusRect(R);

  SetRect(R, W, 0, ClientWidth, ClientHeight);
  if not ListActive then
    Flags := DFCS_SCROLLCOMBOBOX or DFCS_INACTIVE
  else if TDBLookupComboBoxBorland(Self).FPressed then
    Flags := DFCS_SCROLLCOMBOBOX or DFCS_FLAT or DFCS_PUSHED
  else
    Flags :=DFCS_SCROLLCOMBOBOX;
  DrawFrameControl(Canvas.Handle, R, DFC_SCROLL, Flags);
end;

procedure TEtvCustomDBLookupCombo.ListMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
    CloseUp(PtInRect(FDataList.ClientRect, Point(X, Y)))
  end;
end;

procedure TEtvCustomDBLookupCombo.KeyDown(var Key: Word; Shift: TShiftState);
var c:char;
begin
  fReturnKey:=0;
  case Key of
    VK_UP,VK_DOWN: if ListVisible then begin
      if (ssAlt in Shift) then begin
        CloseUp(True);
        Key:=0;
      end
    end
    else if not (ssAlt in Shift) then
      if FilterExist or
         (not(foUpDownInClose in GetOptions)) then Key:=0;
    VK_RETURN: begin
      if ListVisible then begin
        if ssCtrl in Shift then begin
          FIsSelectNow:=true;
          c:=#13;
          KeyPress(c);
          Key:=0;
        end else begin
          fShift:=Shift;
          fReturnKey:=key;
        end;
      end else begin
        if ssCtrl in Shift then begin
          Key:=0;
          DropDown;
        end;
      end;
    end;
    VK_F1: if ssAlt in Shift then begin
      Key:=0;
      DoEditData;
    end;
    90: if (Shift=[ssCtrl]) then begin
      Key:=0;
      if ListVisible then begin
        CloseUp(false);
        SetListFieldIndex(GetListFieldIndex+1);
        DropDown;
      end else SetListFieldIndex(GetListFieldIndex+1);
    end;
  end;
  inherited;
end;

procedure TEtvCustomDBLookupCombo.KeyPress(var Key: Char);
begin
  case Key of
    #27: if ListVisible then begin
      CloseUp(false);
      Key:=#0;
    end;
    #13: begin
      if ListVisible then begin
        CloseUp(True);
        Key:=#0;
      end;
    end;
  end;
  inherited KeyPress(Key);
end;

procedure TEtvCustomDBLookupCombo.MouseDown(Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer);
var Exist:boolean;
begin
  fReturnKey:=0;
  if (Button = mbLeft) and (ssAlt in Shift) then begin
    DoEditData;
    Exit;
  end;
  Exist:=false;
  if Button = mbLeft then begin
    Exist:= not (Focused or
      PtInRect(Rect(ClientWidth-TDBLookupComboBoxBorland(Self).FButtonWidth,0,
        ClientWidth,ClientHeight), Point(X, Y)));
    SetFocus;
    if not Focused then Exit;
    if ListVisible then begin
      CloseUp(False);
      Exist:=true;
    end;
  end;
  if Exist then  begin
    if ListActive then
      TDBLookupControlBorland(Self).FListActive:=false
    else Exist:=false;
  end;
  inherited MouseDown(Button, Shift, X, Y);
  if Exist then
    TDBLookupControlBorland(Self).FListActive:=true;
end;

procedure TEtvCustomDBLookupCombo.SetHeadLineCount(Value:smallint);
begin
  if Value>=1 then fHeadLineCount:=Value;
end;

procedure TEtvCustomDBLookupCombo.CMCancelMode(var Message: TCMCancelMode);
begin
  if (Message.Sender <> Self) and
     (Message.Sender <> FDataList) then begin
    CloseUp(False);
  end;
end;

procedure TEtvCustomDBLookupCombo.WMKillFocus(var Message: TWMKillFocus);
begin
  CloseUp(false);
  inherited;
end;

function TEtvCustomDBLookupCombo.CalcWidth:smallint;
var lField:TField;
begin
  Result:=0;
  if (DataField<>'') and Assigned(DataSource) and Assigned(DataSource.DataSet) then begin
    lField:=DataSource.DataSet.FindField(DataField);
    if assigned(lField) and (lField.FieldKind=fkLookup) then begin
      if lField is TEtvLookField then
        Result:=TEtvLookField(lField).LengthResultFields
      else Result:=LengthResultFields(lField);
    end;
  end
  else if assigned(ListSource) then
    Result:=LengthFields(ListSource.DataSet,ListField);
end;

function TEtvCustomDBLookupCombo.FilterExist:boolean;
begin
  Result:=false;
  if Assigned(Field) and (Field is TEtvLookField) and
     ((TEtvLookField(Field).LookupFilterKey<>'') or
       Assigned(TEtvLookField(Field).OnFilter)) then Result:=true;
end;

{TEtvDBLookupCombo}
constructor TEtvDBLookupCombo.Create(AOwner: TComponent);
begin
  Inherited;
  FEditCode:=nil;
  TDBLookupControlBorland(Self).FDataLink.Free;
  TDBLookupControlBorland(Self).FDataLink:=TEtvDataSourceLink.Create;
  TDataSourceLinkBorland(TDBLookupControlBorland(Self).FDataLink).FDBLookupControl := Self;
  Inherited OnKeyDown:=EtvOnKeyDown;
end;

function TEtvDBLookupCombo.AutoWidth:smallint;
begin
  Result:=CalcWidth;
  if Result>0 then begin
    Width:=Canvas.TextWidth('0')*(Result+3)+
      TDBLookupComboBoxBorland(Self).FButtonWidth;
  end;
end;

procedure TEtvDBLookupCombo.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if ((Key=VK_F2) or (key=VK_Space)) and (Not ListVisible) and
    (foEditWindow in GetOptions) then begin
    UpdateEditCode(#0);
    Key:=0;
  end;
  Inherited;
end;

procedure TEtvDBLookupCombo.EtvOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyDown) then FOnKeyDown(Self,Key,Shift);
  if Not ListVisible then KeyReturn(Sender,Key,Shift);
end;

function TEtvDBLookupCombo.GetDataField: string;
begin
  Result:=inherited DataField;
end;

procedure TEtvDBLookupCombo.SetDataField(const Value: string);
begin
  if (Value<>DataField) and (Value<>'') and (DataField<>'') then
    inherited DataField:='';
  inherited DataField:=Value;
end;

procedure TEtvDBLookupCombo.UpdateEditCode(c:char);
var
  J, TextWidth: Integer;
  R: TRect;
  Exist:boolean;
begin

  if Not Assigned(FEditCode) then
    Try
      FEditCode:= TEtvLookupEdit.Create(self);
      try
        FEditCode.fLookup:=Self;
        FEditCode.Font.Assign(Font);
        Parent.InsertControl(FEditCode);
        TWinControlSelf(FEditCode).SetZOrder(True);
      except
        FEditCode.Free;
        FEditCode:=nil;
        Exit;
      end;
    Except
      EtvApp.ShowMessage('Error create EditKod!');
      Exit;
    end;

  if Assigned(Field) then
    if Field.FieldKind=fkLookup then
      FEditCode.ReadOnly:=
        not Field.DataSet.FieldByName(Field.KeyFields).CanModify
    else FEditCode.ReadOnly:=not Field.CanModify
  else FEditCode.ReadOnly:=false;
  if FEditCode.ReadOnly then c:=#0;
  FEditCode.Text:='';

  fEditFieldIndex:=-1;
  if Not (foKeyFieldEdit in GetOptions) then fEditFieldIndex:=GetListFieldIndex;
  if foAutoCodeName in GetOptions then
    if C in ['0'..'9'] then fEditFieldIndex:=0
    else if (C in Letters) and (ListFields.Count>=2) then fEditFieldIndex:=1;

  Exist:=false;
  for J := 0 to ListFields.Count - 1 do
    if (LowerCase(TField(ListFields[J]).FieldName)=LowerCase(FKeyField.FieldName)) then begin
      if fEditFieldIndex<0 then fEditFieldIndex:=j;
      if fEditFieldIndex=j then begin
        FEditCode.EditMask:=TField(ListFields[fEditFieldIndex]).EditMask;
        if (c=#0) and (KeyValue<>null) then FEditCode.Text:=KeyValue;
        Exist:=true;
      end;
      Break;
    end;
  if Not Exist then begin
    if fEditFieldIndex<0 then fEditFieldIndex:=GetListFieldIndex;
    FEditCode.EditMask:=TField(ListFields[fEditFieldIndex]).EditMask;
    if (C=#0) and ListLink.DataSet.Locate(FKeyField.FieldName,KeyValue,[]) then
      FEditCode.Text:=TField(ListFields[fEditFieldIndex]).Asstring;
  end;

  TextWidth := Canvas.TextWidth('0');
  R.Top := Top;
  R.Bottom := Top+Height-1;
  if Ctl3D then Inc(R.Bottom,1);

  if fEditFieldIndex=0 then R.Left:=Left
  else R.Left := Left+2;
  if Ctl3D then Inc(R.Left);

  for J := 0 to fEditFieldIndex-1 do
    Inc(R.Left,TField(ListFields[J]).DisplayWidth*TextWidth+5);

  R.Right:=R.Left+TField(ListFields[fEditFieldIndex]).DisplayWidth*TextWidth+5;
  if fEditFieldIndex=0 then Inc(R.Right,2);

  if R.Right>Left+ClientWidth+1-TDBLookupComboBoxBorland(self).FButtonWidth then begin
     (* don't place *)
    R.Left:=Left;
    if Ctl3D then Inc(R.Left);
    R.Right:=Left+ClientWidth+1-TDBLookupComboBoxBorland(self).FButtonWidth;
  end;

  if fEditFieldIndex=ListFields.count-1 then
    R.Right:=Left+ClientWidth+1-TDBLookupComboBoxBorland(self).FButtonWidth;

  with TDBLookupControlBorland(self).FDataLink do
    if Assigned(DataSet) and (not FEditCode.ReadOnly) and
       (DataSet.State in [dsInsert,dsBrowse]) then DataSet.Edit;

  SetWindowPos(FEditCode.Handle, HWND_TOP, R.Left, R.Top, R.Right-R.Left, R.Bottom-R.Top,0);
  FEditCode.UpdateShow;
end;

procedure TEtvDBLookupCombo.Loaded;
begin
  inherited;
  if (not(csDesigning in ComponentState)) and (PopupMenu=nil) then
    PopupMenu:=PopupMenuEtvDBFieldControls;
end;

procedure TEtvDBLookupCombo.KeyPress(var Key: Char);
  procedure lDropDown;
  begin
    if (foAutoCodeName in GetOptions) then
      if Key in ['0'..'9'] then SetListFieldIndex(0)
      else if (Key in Letters) then SetListFieldIndex(1);
    DropDown;
  end;
begin
  if (Key in [#33..#255]) and (not ListVisible) then begin
    if (foAutoDropDown in GetOptions) or
       (not (foEditWindow in GetOptions)) then lDropDown
    else begin
      UpdateEditCode(Key);
      if Assigned(FEditCode) and FEditCode.Visible then begin
        PostMessage(FEditCode.Handle, WM_CHAR, Word(Key), 0);
        Exit;
      end else lDropDown;
    end;
  end;
  inherited;
end;

{TListSourceLink}
function TEtvListSourceLink.GetDBLookupControl:TDBLookupControl;
begin
  Result:=TListSourceLinkBorland(self).FDBLookupControl;
end;

procedure TEtvListSourceLink.ActiveChanged;
var Va:Variant;
begin
  if DBLookupControl <> nil then begin
    ListLinkActiveChanged;
    with TEtvCustomDBLookupCombo(DBLookupControl) do
      if KeyValue<>null then begin (* replacement KeyValueChanged*)
        Va:=KeyValue;
        KeyValue:=Null;
        KeyValue:=Va;
      end else Invalidate;
  end;
end;

procedure TEtvListSourceLink.LayoutChanged;
begin
  ActiveChanged;
end;

type TDBLookupControlSelf=class(TDBLookupControl) end;

procedure TEtvListSourceLink.ListLinkActiveChanged;
var
  DataSet: TDataSet;
  ResultField: TField;
begin
  with TDBLookupControlBorland(DBLookupControl) do begin

    FListActive := False;
    FKeyField := nil;
    FListField := nil;
    FListFields.Clear;
    if FListLink.Active and (FKeyFieldName <> '') then begin
      {CheckNotCircular;}
      if FDataLink.Active and FDataLink.DataSet.
           IsLinkedTo(TDBLookupControlSelf(DBLookupControl).ListSource) then
        DatabaseError(SCircularDataLink);

      DataSet := FListLink.DataSet;

      {Etv begin}
      with  TEtvCustomDBLookupCombo(DBLookupControl) do
        if (fLevel<0) then begin
          if fLevelUpName<>'' then
            GetFieldProperty(DataSet,DBLookupControl, fLevelUpName);
          if fLevelDownName<>'' then
            GetFieldProperty(DataSet,DBLookupControl, fLevelDownName);
          if not (csLoading in ComponentState) then CheckLookupLevels;
        end;
      {Etv end}

      FKeyField := GetFieldProperty(DataSet,DBLookupControl, FKeyFieldName);
      try
        DataSet.GetFieldList(FListFields, FListFieldName);
      except
        DatabaseErrorFmt(SFieldNotFound, [DBLookupControl.Name, FListFieldName]);
      end;
      if FLookupMode then begin
      {Etv begin}
         {ResultField := GetFieldProperty(DataSet, Self, FDataField.LookupResultField);
          if FListFields.IndexOf(ResultField) < 0 then
            FListFields.Insert(0, ResultField);
          FListField := ResultField;}
        if FDataField is TEtvLookField then begin
          FListFields.Clear;
          DataSet.GetFieldList(FListFields,TEtvLookField(FDataField).LookupResultField);
          if (FListFieldIndex >= 0) and (FListFieldIndex < FListFields.Count) then
          FListField := FListFields[FListFieldIndex] else
          FListField := FListFields[0];
        end
        else begin
          ResultField := GetFieldProperty(DataSet, DBLookupControl, FDataField.LookupResultField);
          if FListFields.IndexOf(ResultField) < 0 then
            FListFields.Insert(0, ResultField);
          FListField := ResultField;
        end;
     {Etv End}
      end else
      begin
        if FListFields.Count = 0 then FListFields.Add(FKeyField);
        if (FListFieldIndex >= 0) and (FListFieldIndex < FListFields.Count) then
          FListField := FListFields[FListFieldIndex] else
          FListField := FListFields[0];
      end;
      FListActive := True;
    end;
  end;
end;

end.
