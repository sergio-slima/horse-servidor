program ServerHorse;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse, Horse.Compression, Horse.Jhonson, Horse.BasicAuthentication, Horse.Commons, System.JSON, System.SysUtils;

var
  Users: TJSONArray;

begin
  THorse.Use(Compression());
  THorse.Use(Jhonson());

  THorse.Use(HorseBasicAuthentication(
    function(const AUsername, APassword: string): Boolean
    begin
      Result:= AUsername.Equals('user') and APassword.Equals('123');
    end));

  Users:= TJSONArray.Create;

  THorse.Get('ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: Tproc)
    var
      LPong: TJSONArray;
    begin
      LPong:= TJSONArray.Create;
      for var i := 0 to 1000 do
        LPong.Add(TJSONObject.Create(TJSONPair.Create('ping', 'pong')));
      Res.Send(LPong);
    end);

  THorse.Get('/users',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send<TJSONAncestor>(Users.Clone);
    end);

  THorse.Post('/users',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      User: TJSONObject;
    begin
      User:= Req.Body<TJSONObject>.Clone as TJSONObject;
      Users.AddElement(User);
      Res.Send<TJSONAncestor>(User.Clone).Status(THTTPStatus.Created);
    end);

  THorse.Delete('/users/:id',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      id: Integer;
    begin
      Id:= Req.Params.Items['id'].ToInteger;
      Users.Remove(Pred(Id)).Free;
      Res.Send<TJSONAncestor>(Users.Clone).Status(THTTPStatus.NoContent);
    end);

  THorse.Listen(9000);
end.
