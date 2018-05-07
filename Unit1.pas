unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, IPPeerClient,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  REST.Client, Data.Bind.Components, Data.Bind.ObjectScope, FMX.StdCtrls,
  FMX.Objects, FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.Controls.Presentation,
  REST.Types,System.JSON, System.UIConsts;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Memo1: TMemo;
    Edit4: TEdit;
    Image1: TImage;
    Button1: TButton;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    IdHTTP1: TIdHTTP;
    procedure Button1Click(Sender: TObject);
    procedure RESTRequest1AfterExecute(Sender: TCustomRESTRequest);
  private
    { private �錾 }
  public
    { public �錾 }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
begin
  RESTRequest1.ResetToDefaults;
  RESTClient1.ResetToDefaults;
  RESTResponse1.ResetToDefaults;

  RESTClient1.BaseURL := 'https://www.googleapis.com/';
  RESTRequest1.Resource := 'books/v1/volumes?q=isbn:{ISBN}';
  RESTRequest1.Params.AddItem('ISBN', Edit1.Text, TRESTRequestParameterKind.pkURLSEGMENT);
  RESTRequest1.Execute;
end;

procedure TForm1.RESTRequest1AfterExecute(Sender: TCustomRESTRequest);
var
  BookInfo : TJSONValue;
  BookItems : TJSONArray;
  Authors : TJSONArray;
  ThumbnailURL : string;
  ItemCount : integer;
  i : Integer;
  ImageStream : TMemoryStream;
begin
  BookInfo := RESTResponse1.JSONValue;

  // ���ڂ��N���A
  Edit2.Text := '';
  Edit3.Text := '';
  Memo1.Text := '';
  Edit4.Text := '';
  Image1.Bitmap.Clear(claWhite);

  // �A�C�e�����擾
  ItemCount := BookInfo.GetValue<Integer>('totalItems');

  if ItemCount > 0 then
  begin
    // ���ʂ��p�[�X����B
    BookItems := BookInfo.GetValue<TJSONArray>('items');
    with BookItems.Items[0] do
    begin
      // �薼
      Edit2.Text := GetValue<String>('volumeInfo.title');

      // ����
      Edit3.Text := GetValue<String>('volumeInfo.subtitle');

      // ����
      Authors := GetValue<TJSONArray>('volumeInfo.authors');
      for I := 0 to Authors.Count - 1 do
      begin
        Memo1.Lines.Add(Authors.Items[i].GetValue<String>());
      end;

      // �o�œ�
      Edit4.Text := GetValue<String>('volumeInfo.publishedDate');

      // ���e�̃T���l�C��
      ThumbnailURL := GetValue<String>('volumeInfo.imageLinks.thumbnail');
      ImageStream := TMemoryStream.Create;
      IdHTTP1.Get(ThumbnailURL, ImageStream);
      Image1.Bitmap.LoadFromStream(ImageStream);
    end;
  end;
end;

end.
