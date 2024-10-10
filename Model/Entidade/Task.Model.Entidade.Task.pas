unit Task.Model.Entidade.Task;

interface

uses Task.Model.Entidade;

type
  [Tabela('TASK')]
  TEntidadeTask = class(TEntidade)
  private
    FCodigo: Integer;
    FUsuario: Integer;
    FTitulo: string;
    FDescricao: string;
  public
    [Campo('CODIGO_TASK'), Pk, AutoInc('GEN_TASK')]
    property Codigo: Integer read FCodigo write FCodigo;

    [Campo('USUARIO_TASK'), User]
    property Usuario: Integer read FUsuario write FUsuario;

    [Campo('TITULO_TASK')]
    property Titulo: string read FTitulo write FTitulo;

    [Campo('DESCRICAO_TASK')]
    property Descricao: string read FDescricao write FDescricao;
  end;

implementation

end.
