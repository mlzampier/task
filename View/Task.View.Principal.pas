unit Task.View.Principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl, FMX.Layouts, FMX.ListBox, FMX.StdCtrls, FMX.Edit, FMX.Objects, FMX.Effects,
  FMX.Controls.Presentation,
  Task.Controller.Task, FMX.ScrollBox, FMX.Memo;

type
  TFPrincipal = class(TForm)
    TabControl: TTabControl;
    tiLogin: TTabItem;
    tiLista: TTabItem;
    tiEdit: TTabItem;
    RectBackground: TRectangle;
    lbDesenvolvedor: TLabel;
    RectQuadroBranco: TRectangle;
    SdwQuadroBranco: TShadowEffect;
    RecUsuario: TRectangle;
    ImgUsuario: TImage;
    edLogin_Usuario: TEdit;
    RectEdtSenha: TRectangle;
    edLogin_Senha: TEdit;
    ImgSenha: TImage;
    RecBtnEntrar: TRectangle;
    lbLogin: TLabel;
    cbLogin_LembrarSenha: TCheckBox;
    LayNomeAplicativo: TLayout;
    lbSoftwareTitulo: TLabel;
    lbSoftwareVersao: TLabel;
    lbLista: TListBox;
    laListaVazia: TLayout;
    ImgListaVazia: TImage;
    txListaVazia: TText;
    ToolBar2: TToolBar;
    btLogout: TSpeedButton;
    btLista_Novo: TSpeedButton;
    ToolBar1: TToolBar;
    btEdit_Voltar: TSpeedButton;
    Layout1: TLayout;
    Layout2: TLayout;
    tiConfig: TTabItem;
    ToolBar3: TToolBar;
    btConfig_Voltar: TSpeedButton;
    edNovoTitulo: TEdit;
    Layout3: TLayout;
    edConfigUrl: TEdit;
    ToolBar4: TToolBar;
    btConfig: TSpeedButton;
    Label1: TLabel;
    StyleBook1: TStyleBook;
    btEdit_Excluir: TSpeedButton;
    edNovoDetalhamento: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure btLogoutClick(Sender: TObject);
    procedure btLista_NovoClick(Sender: TObject);
    procedure btEdit_VoltarClick(Sender: TObject);
    procedure lbLoginClick(Sender: TObject);
    procedure btConfigClick(Sender: TObject);
    procedure lbListaItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
    procedure btEdit_ExcluirClick(Sender: TObject);
    procedure btConfig_VoltarClick(Sender: TObject);
  private
    { Private declarations }
    FTask: TControllerTask;
    procedure CarregarLista;
    procedure CarregarEdicao;
  public
    { Public declarations }
  end;

var
  FPrincipal: TFPrincipal;

implementation

{$R *.fmx}

uses Task.Define.Constantes.Client, Task.Define.Constantes, Task.Controller.Client, Task.Controller.Login, Task.Model.Entidade, Task.Model.Entidade.Task;

{ TForm1 }

procedure TFPrincipal.FormCreate(Sender: TObject);
begin
  Self.Caption := cSoftware_NomeComercial;
  Application.Title := cSoftware_NomeComercial;

  lbSoftwareTitulo.Text := cSoftware_NomeComercial;
  lbSoftwareVersao.Text := 'Versão ' + cSoftware_Versao;
  lbDesenvolvedor.Text := 'by ' + cDesenvolvedor_Nome;

  FTask := TControllerTask.Create;

  TabControl.TabPosition := TTabPosition.None;
  TabControl.ActiveTab := tiLogin;

  with TControllerClient.GetInstance do
  begin
    Load;
    edLogin_Usuario.Text := Secao.Usuario;
    edLogin_Senha.Text := Secao.Senha;
  end;
  cbLogin_LembrarSenha.IsChecked := edLogin_Senha.Text <> '';
end;

procedure TFPrincipal.CarregarLista;
var
  LEntidade: TEntidade;
  LLBItem: TListBoxItem;
  LbgfLastro: TListBoxGroupFooter;
begin
  laListaVazia.Visible := False;

  lbLista.BeginUpdate;
  try
    lbLista.Clear;
    for LEntidade in FTask.Model.Find do
    begin
      LLBItem := TListBoxItem.Create(lbLista);
      LLBItem.Parent := lbLista;
      LLBItem.StyleLookup := lbLista.DefaultItemStyles.ItemStyle;
      LLBItem.Data := LEntidade;
      LLBItem.Height := 112;
      with TEntidadeTask(LEntidade)  do
      begin
        LLBItem.StylesData['Titulo'] := Titulo;
        LLBItem.StylesData['Descricao'] := Descricao;
        LLBItem.Tag := Codigo;
      end;
    end;
  finally
    lbLista.EndUpdate;
  end;

  LbgfLastro := TListBoxGroupFooter.Create(lbLista);
  lbLista.AddObject(LbgfLastro);
  lbLista.ViewportPosition := TPointF.Zero;

  laListaVazia.Visible := lbLista.Count = 0;
end;

procedure TFPrincipal.CarregarEdicao;
begin
  edNovoTitulo.Text := FTask.Entidade.Titulo;
  edNovoDetalhamento.Text := FTask.Entidade.Descricao;
  btEdit_Excluir.Visible := FTask.Entidade.Codigo > 0;
end;

procedure TFPrincipal.lbListaItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  if Item.Tag <= 0 then
    Exit;
  FTask.Entidade := TEntidadeTask(Item.Data);
  CarregarEdicao;
  TabControl.ActiveTab := tiEdit;
end;

procedure TFPrincipal.lbLoginClick(Sender: TObject);
begin
  TControllerLogin.Logar(edLogin_Usuario.Text, edLogin_Senha.Text, cbLogin_LembrarSenha.IsChecked);
  CarregarLista;
  TabControl.ActiveTab := tiLista;
end;

procedure TFPrincipal.btConfigClick(Sender: TObject);
begin
  edConfigUrl.Text := TControllerClient.GetInstance.Configuracoes.Servidor_URL;
  TabControl.ActiveTab := tiConfig;
end;

procedure TFPrincipal.btConfig_VoltarClick(Sender: TObject);
begin
  TControllerClient.GetInstance.Save_Config(edConfigUrl.Text);
  TabControl.ActiveTab := tiLogin;
end;

procedure TFPrincipal.btLogoutClick(Sender: TObject);
begin
  TabControl.ActiveTab := tiLogin;
  lbLista.Clear;
end;

procedure TFPrincipal.btLista_NovoClick(Sender: TObject);
begin
  if not Assigned(FTask.Entidade) then
    FTask.Entidade := TEntidadeTask.Create;

  FTask.Entidade.Codigo := 0;
  FTask.Entidade.Titulo := '';
  FTask.Entidade.Descricao := '';

  CarregarEdicao;
  TabControl.ActiveTab := tiEdit;
end;

procedure TFPrincipal.btEdit_VoltarClick(Sender: TObject);
begin
  if FTask.Entidade.Codigo = 0  then
  begin
    if (edNovoTitulo.Text <> '') or (edNovoDetalhamento.Text <> '') then
    begin
      FTask.Entidade.Titulo := edNovoTitulo.Text;
      FTask.Entidade.Descricao := edNovoDetalhamento.Text;
      FTask.Model.Insert(FTask.Entidade);
    end;
  end
  else
  begin
    FTask.Entidade.Titulo := edNovoTitulo.Text;
    FTask.Entidade.Descricao := edNovoDetalhamento.Text;
    FTask.Model.Update(FTask.Entidade);
  end;
  CarregarLista;
  TabControl.ActiveTab := tiLista;
end;

procedure TFPrincipal.btEdit_ExcluirClick(Sender: TObject);
begin
  FTask.Model.Delete(FTask.Entidade.Codigo);
  CarregarLista;
  TabControl.ActiveTab := tiLista;
end;

end.
