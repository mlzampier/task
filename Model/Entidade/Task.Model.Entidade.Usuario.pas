unit Task.Model.Entidade.Usuario;

interface

uses Task.Model.Entidade;

type
  [Tabela('USUARIO')]
  TEntidadeUsuario = class(TEntidade)
  private
    FCodigo: Variant;
    FDescricao: string;
    FSenha: string;
  public
    [Campo('CODIGO_USU'), Pk, AutoInc('GEN_USUARIO')]
    property Codigo: Variant read FCodigo write FCodigo;

    [Campo('DESCRICAO_USU')]
    property Descricao: string read FDescricao write FDescricao;

    [Campo('SENHA_USU')]
    property Senha: string read FSenha write FSenha;
  end;

implementation

end.
