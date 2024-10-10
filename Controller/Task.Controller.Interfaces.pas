unit Task.Controller.Interfaces;

interface

uses Task.Model.Interfaces;

type
  iController = interface
    ['{D0D86AB1-CC8A-4AF8-B502-8D6DBD1EDD3F}']
    function Model: iModel;
    function &End: iController;
  end;

implementation

end.
