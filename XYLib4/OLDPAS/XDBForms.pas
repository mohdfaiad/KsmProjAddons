{*******************************************************}
{                                                       }
{            X-library v.03.75                          }
{                                                       }
{   15.04.98                   				}
{                                                       }
{   TXPageControl - PageControl for XForms              }
{   TXDBPageControl - PageControl for XDBForms          }
{                                                       }
{   Last corrections 14.11.98                           }
{                                                       }
{*******************************************************}
{$I XLib.inc }
Unit XDBForms;

Interface

Uses Classes, Controls, Forms, Messages, DB, XForms, Nav, ExtCtrls,
     ComCtrls, SrcIndex, LnkMisc, EtvContr;

Const fcDBDefaultClass = 'dbDefault';

type

{ TLinkIndexCombo }

  TLinkIndexCombo = class(TSrcLinkCombo{TDBIndexCombo})
  private
    FMaster: TComponent;
    FChecked: Boolean;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
  protected
    function GetParentComponent: TComponent; override;
    function HasParent: Boolean; override;
    procedure SetParentComponent(AParent: TComponent); override;
    procedure ReadState(Reader: TReader); override;
    procedure Change; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Master: TComponent read FMaster write FMaster stored False;
  published
    property OnDropDown;
  end;
{ TLinkIndexCombo }

{ TLinkNavigator }

  TLinkNavigator = class(TExtDBNavigator)
  private
    FMaster: TComponent;
  protected
    function GetParentComponent: TComponent; override;
    function HasParent: Boolean; override;
    procedure SetParentComponent(AParent: TComponent); override;
    procedure ReadState(Reader: TReader); override;
  public
    destructor Destroy; override;
    property Master: TComponent read FMaster write FMaster stored False;
  end;
{ TLinkNavigator }

{ TLinkPanel }

  TLinkPanel = class(TPanel)
  private
    FSlotSize: Integer;
    FComboActive: Boolean;
    FIndexCombo: {TDB}TSrcLinkCombo;
    FNavigatorActive: Boolean;
    FNavigator: TExtDBNavigator;
    FMaster: TComponent;
    procedure ChangeSize;
    procedure SetSlotSize(Value: Integer);
    procedure SetComboActive(Value: Boolean);
    procedure SetNavigatorActive(Value: Boolean);
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  protected
    function GetParentComponent: TComponent; override;
    function HasParent: Boolean; override;
    procedure SetParentComponent(AParent: TComponent); override;
    procedure ReadState(Reader: TReader); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Master: TComponent read FMaster write FMaster stored False;
    property IndexCombo: {TDB}TSrcLinkCombo read FIndexCombo;
    property Navigator: TExtDBNavigator read FNavigator;
  published
    property Height default 24;
    property SlotSize: Integer read FSlotSize write SetSlotSize default 2;
    property ComboActive: Boolean read FComboActive write SetComboActive;
    property NavigatorActive: Boolean read FNavigatorActive write SetNavigatorActive;
  end;
{ TLinkPanel }

{ TXPageControl }

  TXPageControl = class(TEtvPageControl)
  private
    FActiveControl: TWinControl;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
  protected
    procedure ShowControl(AControl: TControl); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    procedure SendToPage(Value: Longint);
    function CanChange: Boolean; override;
    procedure Change; override;
    property ActiveControl: TWinControl read FActiveControl write FActiveControl;
  end;
{ TXPageControl }

{ TXDBPageControl }

  TXDBPageControl = class(TXPageControl)
  private
    FPanelActive: Boolean;
    FPanel: TLinkPanel;
    procedure SetPanelActive(Value: Boolean);
    function GetPanelHeight: Integer;
  protected
    procedure Change; override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure SetChildOrder(Child: TComponent; Order: Integer); override;
  public
    procedure ChangeLink(aLink: TAggregateLink; aDataLink: TDataLink);
    property Panel: TLinkPanel read FPanel;
  published
    property PanelActive: Boolean read FPanelActive write SetPanelActive default False;
  end;

{ TXDBForm }

  TXDBForm = class(TXForm)
  private
    FXPageControl: TXDBPageControl;
  protected
    procedure InsideFormLinkSetName(Component: TComponent; var Name: string);override;
    procedure Deactivate; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    function DefaultXControl: TWinControl; override;
    Procedure SummExecute;
    Property XPageControl: TXDBPageControl read FXPageControl write FXPageControl;
  end;

Implementation

Uses Windows, Dialogs, XTFC, XDBTFC, EtvBor, XMisc, LnkSet;

var XNotifyEvent: TXNotifyEvent;

{ TLinkIndexCombo }

Procedure TLinkIndexCombo.Change;
begin
  inherited;
  if FChecked then begin
    FChecked:= False;
    if (not DroppedDown or IsKeyReturn) and Assigned(CurrentXControl) then
      CurrentXControl.SetFocus;
  end;
end;

Procedure TLinkIndexCombo.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  if FChecked then begin
    FChecked:= False;
    if (not DroppedDown) and Assigned(CurrentXControl) then CurrentXControl.SetFocus;
  end;
end;

Procedure TLinkIndexCombo.CNCommand(var Message: TWMCommand);
begin
  inherited;
  case Message.NotifyCode of
{   CBN_CloseUp:}
    CBN_SELENDOK: FChecked:= True;
    CBN_SELENDCANCEL: if Assigned(CurrentXControl) then CurrentXControl.SetFocus;
  end;
end;

Constructor TLinkIndexCombo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FChecked:= False;
  Align:=alLeft;
end;

Destructor TLinkIndexCombo.Destroy;
begin
  if Assigned(FMaster) then begin
    TLinkPanel(FMaster).FIndexCombo:=Nil;
    TLinkPanel(FMaster).FComboActive:=False;
  end;
  Inherited Destroy;
end;

Function TLinkIndexCombo.HasParent: Boolean;
begin
  HasParent := True;
end;

Function TLinkIndexCombo.GetParentComponent: TComponent;
begin
  Result := Master;
end;

Procedure TLinkIndexCombo.SetParentComponent(AParent: TComponent);
begin
  if not (csLoading in ComponentState) then Master := AParent;
end;

Procedure TLinkIndexCombo.ReadState(Reader: TReader);
begin
  Inherited ReadState(Reader);
  if Reader.Parent is TLinkPanel then begin
    Master := Reader.Parent;
    TLinkPanel(Reader.Parent).FIndexCombo:=Self;
  end;
end;

{ TLinkNavigator }

Destructor TLinkNavigator.Destroy;
begin
  if Assigned(FMaster) then begin
    TLinkPanel(FMaster).FNavigator:=Nil;
    TLinkPanel(FMaster).FNavigatorActive:=False;
  end;
  Inherited Destroy;
end;

Function TLinkNavigator.HasParent: Boolean;
begin
  HasParent := True;
end;

Function TLinkNavigator.GetParentComponent: TComponent;
begin
  Result := Master;
end;

Procedure TLinkNavigator.SetParentComponent(AParent: TComponent);
begin
  if not (csLoading in ComponentState) then Master := AParent;
end;

Procedure TLinkNavigator.ReadState(Reader: TReader);
begin
  Inherited ReadState(Reader);
  if Reader.Parent is TLinkPanel then begin
    Master := Reader.Parent;
    TLinkPanel(Reader.Parent).FNavigator:=Self;
  end;
end;

{ TLinkPanel }

Constructor TLinkPanel.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  Height:=24;
  FSlotSize:=2;
{ ComboActive:=True;}
{ NavigatorActive:=True;}
end;

Destructor TLinkPanel.Destroy;
begin
  if Assigned(FMaster) then begin
    TXDBPageControl(FMaster).FPanel:=Nil;
    TXDBPageControl(FMaster).FPanelActive:=False;
  end;
  Inherited Destroy;
end;

Procedure TLinkPanel.ChangeSize;
begin
  if ComboActive and NavigatorActive then begin
    if FNavigator.Left< FIndexCombo.Left+FIndexCombo.Width+FSlotSize then
      FIndexCombo.Width:=FNavigator.Left-FIndexCombo.Left-FSlotSize
    else if FIndexCombo.Left+FIndexCombo.Width+FSlotSize<FNavigator.Left then
      FIndexCombo.Width:=FNavigator.Left-FIndexCombo.Left-FSlotSize;
  end;
end;

Procedure TLinkPanel.WMSize(var Message: TWMSize);
begin
  Inherited;
  ChangeSize;
end;

Procedure TLinkPanel.SetSlotSize(Value: Integer);
begin
  if (FSlotSize<>Value)and(Value>=2) then begin
    FSlotSize:=Value;
    ChangeSize;
  end;
end;

Function TLinkPanel.HasParent: Boolean;
begin
  HasParent := True;
end;

Function TLinkPanel.GetParentComponent: TComponent;
begin
  Result := Master;
end;

Procedure TLinkPanel.SetParentComponent(AParent: TComponent);
begin
  if not (csLoading in ComponentState) then Master := AParent{ as TXDBPageControl};
end;

Procedure TLinkPanel.ReadState(Reader: TReader);
begin
  Inherited ReadState(Reader);
  if Reader.Parent is TXDBPageControl then begin
    Master := Reader.Parent;
    TXDBPageControl(Reader.Parent).FPanel:=Self;
  end;
end;

Procedure TLinkPanel.SetComboActive(Value: Boolean);
begin
  if FComboActive<>Value then begin
    if not (csLoading in ComponentState) then
    if Value then begin
      FIndexCombo:= TLinkIndexCombo.Create(Owner{Self});
      FIndexCombo.Align:= alLeft;
      FIndexCombo.Name:=Name+'IndexCombo';
      InsertControl(FIndexCombo);
    end else begin
      RemoveControl(FIndexCombo);
      FIndexCombo.Free;
      FIndexCombo:=nil;
    end;
    FComboActive:=Value;
  end;
end;

Procedure TLinkPanel.SetNavigatorActive(Value: Boolean);
begin
  if FNavigatorActive<>Value then begin
    if not (csLoading in ComponentState) then
    if Value then begin
      FNavigator:= TLinkNavigator.Create(Owner{Self});
      FNavigator.Align:= alRight;
      FNavigator.Name:=Name+'Navigator';
      FNavigator.DataSource:=nil;
      InsertControl(FNavigator);
    end else begin
      RemoveControl(FNavigator);
      FNavigator.Free;
      FNavigator:=nil;
    end;
    FNavigatorActive:=Value;
  end;
end;

{ TXPageControl }

Procedure TXPageControl.CMDialogKey(var Message: TCMDialogKey);
begin
  if (Message.CharCode = VK_TAB) and (GetKeyState(VK_CONTROL) < 0) then begin
{    SelectNextPage(GetKeyState(VK_SHIFT) >= 0);
    Message.Result := 1;}
  end else Inherited;
end;

Procedure TXPageControl.SendToPage(Value: Longint);

  Procedure Send(W: TWinControl);
  var i: Integer;
  begin
    for i:=0 to W.ControlCount-1 do
      if W.Controls[i] is TWinControl then begin
        Send(TWinControl(W.Controls[i]));
        SendMessage(TWinControl(W.Controls[i]).Handle,wm_ChangePageSource, Value, 0);
      end;
  end;

begin
  Send(ActivePage);
end;

Function TXPageControl.CanChange: Boolean;
begin
  Result:=Inherited CanChange;
  if Result and Assigned(ActivePage) then SendToPage(0);
end;

Procedure TXPageControl.Change;
begin
  Inherited Change;
  ActiveControl:=GetParentForm(Self).ActiveControl;
  CurrentXControl:=ActiveControl;
  if Assigned(ActivePage) then SendToPage(1);
end;

Procedure TXPageControl.ShowControl(AControl: TControl);
begin
  if (ActivePage<>AControl) and (AControl is TTabSheet) and (ActivePage<>nil) and
  (TTabSheet(AControl).PageControl=Self) then begin
    CanChange;
    inherited;
    Change;
  end else Inherited;
end;

Procedure TXPageControl.Notification(AComponent: TComponent; Operation: TOperation);
var AWin: TWinControl;
    i,j:integer;
    Priz: Boolean;
    ANotifyEvent: TXNotifyEvent;
begin
  if AComponent is TXNotifyEvent then begin
    ANotifyEvent:= TXNotifyEvent(AComponent);
    case TXNotifyEvent(AComponent).SpellEvent of
      xeGetFirstXControl:
        if Operation=opInsert then begin
          if Assigned(ActivePage) then begin
            AWin:=nil;
            with ActivePage do
              for i:=0 to ControlCount-1 do
                if Controls[i] is TWinControl then begin
                  ANotifyEvent.GoSpell(Controls[i], xeGetFirstXControl, Operation);
                  if ANotifyEvent.SpellEvent = xeNone then begin
                    AWin:=TWinControl(ANotifyEvent.SpellChild);
                    if Assigned(AWin) and AWin.TabStop then Break;
                  end;
                end;
            if Assigned(AWin) then TXNotifyEvent(AComponent).SpellChild:=AWin
            else TXNotifyEvent(AComponent).SpellChild:=nil;
          end else TXNotifyEvent(AComponent).SpellChild:=nil;
          TXNotifyEvent(AComponent).SpellEvent:=xeNone;
        end else begin
          if Assigned(ActivePage) then begin
            AWin:=nil;
            Priz:=False;
            with ActivePage do begin
              for i:=0 to ControlCount-1 do
                if Controls[i] is TWinControl then begin
                  ANotifyEvent.GoSpell(Controls[i], xeGetFirstXControl, Operation);
                  if ANotifyEvent.SpellEvent = xeEnd then Exit;
                  if ANotifyEvent.SpellEvent = xeNone then begin
                    Priz:=True;
                    Break;
                  end;
                end;
              if Priz then begin
                for j:=i+1 to ControlCount-1 do
                  if Controls[j] is TXPageControl then begin
                    TXNotifyEvent(AComponent).SpellChild:=Controls[j];
                    TXNotifyEvent(AComponent).SpellEvent:=xeEnd;
                    FActiveControl:=TWinControl(Controls[i]);
                    Exit;
                  end;
                for j:=0 to i-1 do
                  if Controls[j] is TXPageControl then begin
                    TXNotifyEvent(AComponent).SpellChild:=Controls[j];
                    TXNotifyEvent(AComponent).SpellEvent:=xeEnd;
                    FActiveControl:=TWinControl(Controls[i]);
                    Exit;
                  end;
{                      TXNotifyEvent(AComponent).SpellChild:=Nil;}
                TXNotifyEvent(AComponent).SpellEvent:=xeNone;
              end;
            end;
          end else TXNotifyEvent(AComponent).SpellChild:=nil;
        end;
    end;
  end else Inherited;
end;

{ TXDBPageControl }

Procedure TXDBPageControl.SetPanelActive(Value: Boolean);
begin
  if FPanelActive<>Value then begin
    if not (csLoading in ComponentState) then
    if Value then begin
      FPanel:= TLinkPanel.Create(Owner);
      FPanel.Align:= alTop;
      FPanel.Name:=Name+'Panel';
      FPanel.Caption:='';
      FPanel.Height:=24;
      TLinkPanel(FPanel).NavigatorActive:=True;
      TLinkPanel(FPanel).ComboActive:=True;
      InsertControl(FPanel);
    end else begin
      RemoveControl(FPanel);
      FPanel.Free;
      FPanel:=nil;
    end;
    FPanelActive:=Value;
  end;
end;

Function TXDBPageControl.GetPanelHeight: Integer;
begin
  if Assigned(FPanel) then Result:=FPanel.Height else Result:=0;
end;

Procedure TXDBPageControl.Change;
var Act: TWinControl;
begin
  Inherited Change;
  Act:=GetParentForm(Self).ActiveControl;
  if Assigned(FPanel) and (Act=TLinkPanel(FPanel).FIndexCombo) then begin
    SelectNext(TLinkPanel(FPanel).FIndexCombo,False,True);
  end;
end;

Procedure TXDBPageControl.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
  inherited GetChildren(Proc, Root);
  if FPanelActive and Assigned(FPanel) then Proc(FPanel);
end;

Procedure TXDBPageControl.SetChildOrder(Child: TComponent; Order: Integer);
begin
  if Child is TTabSheet then Inherited SetChildOrder(Child, Order);
end;

Procedure TXDBPageControl.ChangeLink(aLink: TAggregateLink; aDataLink: TDataLink);
begin
  Panel.Navigator.DataSource:= aDataLink.DataSource;
  aLink.FillIndexListCurrent;
  Panel.IndexCombo.SrcLinkItem:=nil;
  Panel.IndexCombo.SrcLinks:=aLink.CurrentIFNLink;
  Panel.IndexCombo.SrcLinkItem:=aLink.IFNItem;
end;

{ TXDBForm }

Procedure TXDBForm.Deactivate;
begin
  if Assigned(FormControl) then TFormControl(FormControl).ReturnFormShow;
  Inherited Deactivate;
end;

Procedure TXDBForm.InsideFormLinkSetName(Component: TComponent; var Name: string);
begin
  inherited;
  if Name='PageControl1' then XPageControl:=TXDBPageControl(Component);
end;

Function TXDBForm.DefaultXControl: TWinControl;
begin
  if Assigned(XPageControl) then begin
    XNotifyEvent.GoSpell(XPageControl, xeGetFirstXControl, opInsert);
    if XNotifyEvent.SpellEvent = xeNone then Result:=TWinControl(XNotifyEvent.SpellChild)
    else Result:=nil;
  end else Result:=nil;
end;

Procedure TXDBForm.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if AComponent is TXNotifyEvent then
    case TXNotifyEvent(AComponent).SpellEvent of
      xeChangeParams: if Assigned(FormControl) and (FormControl is TDBFormControl) and
                      (TXNotifyEvent(AComponent).SpellChild is TDataSource) then begin
                         if TDBFormControl(FormControl).CurrentSource<>
                           TDataSource(TXNotifyEvent(AComponent).SpellChild) then begin
                           TDBFormControl(FormControl).CurrentSource:=
                             TDataSource(TXNotifyEvent(AComponent).SpellChild);
                           if CurrentXControl<>ActiveControl then
                             CurrentXControl:=ActiveControl;
                         end else TDBFormControl(FormControl).CheckActiveControl(TDataSource(TXNotifyEvent(AComponent).SpellChild));
                         TXNotifyEvent(AComponent).SpellEvent:=xeNone;
                      end;
    end
  else Inherited;
end;

Procedure TXDBForm.KeyDown(var Key: Word; Shift: TShiftState);
var Win1: TWinControl;
begin
  if (Key=vk_Escape) and (ssShift in Shift) then begin
    if (FormControl is TDBFormControl)and
    (TDBFormControl(FormControl).CurrentSource is TLinkSource) then
      TLinkSource(TDBFormControl(FormControl).CurrentSource).Dataset.Cancel;
  end else
    if (Key=192) and (ssCtrl in Shift) then begin
      if Assigned(XPageControl) and Assigned(ActiveControl) then begin
        XNotifyEvent.GoSpellChild(XPageControl, xeGetFirstXControl, ActiveControl, opRemove);
        if XNotifyEvent.SpellEvent=xeNone then begin
          XNotifyEvent.SpellEvent:=xeEnd;
          XNotifyEvent.SpellChild:=XPageControl;
        end;
        if XNotifyEvent.SpellEvent=xeEnd then begin
          if TXPageControl(XNotifyEvent.SpellChild).ActiveControl<>nil then
            Win1:=TXPageControl(XNotifyEvent.SpellChild).ActiveControl
          else begin
            XNotifyEvent.GoSpell(TComponent(XNotifyEvent.SpellChild), xeGetFirstXControl, opInsert);
            if XNotifyEvent.SpellEvent = xeNone then
              Win1:=TWinControl(XNotifyEvent.SpellChild)
            else Win1:=nil;
          end;
          if Assigned(Win1) then Win1.SetFocus;
        end;
      end;
      Key:=0;
    end;
  Inherited
end;

Procedure TXDBForm.SummExecute;
begin
  if (FormControl is TDBFormControl) and
  (TDBFormControl(FormControl).CurrentSource is TLinkSource) then
    TLinkSource(TDBFormControl(FormControl).CurrentSource).SummExecute;
end;

Initialization
  RegisterClasses([TLinkIndexCombo, TLinkNavigator, TLinkPanel]);
  RegisterClasses([TXDBForm]);
  XNotifyEvent:=TXNotifyEvent.Create(nil);

Finalization
  XNotifyEvent.Free;
  XNotifyEvent:=nil;
end.
