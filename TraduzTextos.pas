unit TraduzTextos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListBox,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts, FMX.Edit,
  FMX.ExtCtrls, System.JSON,
  Math, REST.Types, REST.Client, Data.Bind.Components, Data.Bind.ObjectScope,
  FMX.DialogService, FMX.Media, System.IOUtils, FMX.Ani, FMX.Effects,
  FMX.Filter.Effects, Creditos, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  System.Threading, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef,
  FireDAC.FMXUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Xml.XMLIntf, Xml.XMLDoc, System.NetEncoding;

type
  TFormPrincipal = class(TForm)
    ScaledLayout1: TScaledLayout;
    FlowLayout1: TFlowLayout;
    LayoutTitulo: TLayout;
    RectangleTitulo: TRectangle;
    lbTitulo: TLabel;
    RESTTranslate: TRESTClient;
    RESTRequestTranslate: TRESTRequest;
    RESTResponseTranslate: TRESTResponse;
    RESTGetLanguages: TRESTClient;
    RESTRequestGetLanguages: TRESTRequest;
    RESTResponseLanguage: TRESTResponse;
    RESTGetLanguageScope: TRESTClient;
    RESTRequestLanguageScope: TRESTRequest;
    RESTResponseLanguaScope: TRESTResponse;
    RESTDetectLanguage: TRESTClient;
    RESTRequestDetectLanguage: TRESTRequest;
    RESTResponseDetectLanguage: TRESTResponse;
    Loading: TAniIndicator;
    LayoutLanguages: TLayout;
    Label1: TLabel;
    CBoxLanguages: TComboBox;
    LayoutDestino: TLayout;
    lbMetas: TLabel;
    CBoxTo: TComboBox;
    LayoutIdMoodle: TLayout;
    Label4: TLabel;
    LayoutBotoes: TLayout;
    RectangleBtGrafico: TRectangle;
    buttonGrafico: TSpeedButton;
    LayoutOrigem: TLayout;
    Panel1: TPanel;
    Label2: TLabel;
    Panel2: TPanel;
    MemoSource: TMemo;
    LayoutTranslate: TLayout;
    Panel3: TPanel;
    Label3: TLabel;
    Panel4: TPanel;
    MemoTranslated: TMemo;
    EditIdMoodle: TEdit;
    lbTranslateSuported: TLabel;
    lbLanguageDetected: TLabel;
    FDConnectionMySql: TFDConnection;
    FDQuery: TFDQuery;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    procedure FormShow(Sender: TObject);
    procedure SetHeadersToRestRequest(RestRequest: TRESTRequest);
    procedure PopulateComboBoxFromJSON(CBox: TComboBox; JSONText: string);
    procedure CBoxLanguagesChange(Sender: TObject);
    procedure SortComboBoxItems(CBox: TComboBox);
    procedure SetDefaultComboBoxValue(CBox: TComboBox; DefaultKey: string);
    procedure CBoxToChange(Sender: TObject);
    procedure ShowAniIndicator;
    procedure HideAniIndicator;
    procedure lbTituloClick(Sender: TObject);
    procedure buttonGraficoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ExtractResourceToFile(const ResName, OutputFileName: string);
    procedure DetectLanguage(texto:String);

  private
    { Private declarations }
    Param01, Param02, Param03, Param04: TRESTRequestParameter;
    ParamName01, ParamName02, ParamName03, ParamName04: string;
  public
    { Public declarations }
  end;

var
  FormPrincipal: TFormPrincipal;
  CONTENT_TYPE_HEADER :String;
  CONTENT_TYPE_VALUE :String;
  SUBSCRIPTION_KEY_HEADER :String;
  SUBSCRIPTION_KEY_VALUE :String;
  SUBSCRIPTION_REGION_HEADER :String;
  SUBSCRIPTION_REGION_VALUE :String;
  controle :Integer;

implementation

{$R *.fmx}

procedure TFormPrincipal.SetHeadersToRestRequest(RestRequest: TRESTRequest);
var
  Header: TRESTRequestParameter;
begin


  // Adiciona o cabeçalho Content-Type
  Header := RestRequest.Params.ParameterByName(CONTENT_TYPE_HEADER);
  if Header = nil then
  begin
    Header := RestRequest.Params.AddItem;
    Header.Name := CONTENT_TYPE_HEADER;
    Header.Value := CONTENT_TYPE_VALUE;
    Header.Kind := pkURLSEGMENT;
  end;

  // Adiciona o cabeçalho Ocp-Apim-Subscription-Key
  Header := RestRequest.Params.ParameterByName(SUBSCRIPTION_KEY_HEADER);
  if Header = nil then
  begin
    Header := RestRequest.Params.AddItem;
    Header.Name := SUBSCRIPTION_KEY_HEADER;
    Header.Value := SUBSCRIPTION_KEY_VALUE;
    Header.Kind := pkHTTPHEADER;
  end;

  // Adiciona o cabeçalho Ocp-Apim-Subscription-Region
  Header := RestRequest.Params.ParameterByName(SUBSCRIPTION_REGION_HEADER);
  if Header = nil then
  begin
    Header := RestRequest.Params.AddItem;
    Header.Name := SUBSCRIPTION_REGION_HEADER;
    Header.Value := SUBSCRIPTION_REGION_VALUE;
    Header.Kind := pkHTTPHEADER;
  end;

end;

procedure TFormPrincipal.PopulateComboBoxFromJSON(CBox: TComboBox;
  JSONText: string);
var
  JSONObject, TranslationObject: TJSONObject;
  Pair: TJSONPair;
  LangObject: TJSONObject;
  LangName, LangKey: string;
begin
  JSONObject := TJSONObject.ParseJSONValue(JSONText) as TJSONObject;
  CBox.Items.Clear;

  try
    TranslationObject := JSONObject.GetValue<TJSONObject>('translation');
    if Assigned(TranslationObject) then
    begin
      for Pair in TranslationObject do
      begin
        LangKey := Pair.JsonString.Value;
        LangObject := Pair.JsonValue as TJSONObject;

        LangName := LangObject.GetValue<string>('name');

        CBox.Items.AddObject(LangName, TObject(Pointer(LangKey)));
      end;
    end;
  finally
    JSONObject.FreeInstance;
  end;
end;

procedure TFormPrincipal.SortComboBoxItems(CBox: TComboBox);
var
  SortedList: TStringList;
  i: Integer;
begin
  SortedList := TStringList.Create;
  try
    for i := 0 to CBox.Items.Count - 1 do
      SortedList.AddObject(CBox.Items[i], CBox.Items.Objects[i]);

    SortedList.Sort;

    CBox.Items.Clear;
    for i := 0 to SortedList.Count - 1 do
      CBox.Items.AddObject(SortedList[i], SortedList.Objects[i]);
  finally
    SortedList.Destroy;
  end;
end;

procedure TFormPrincipal.ShowAniIndicator;
begin
  Loading.Visible := True;
  Loading.Enabled := True;
end;

procedure TFormPrincipal.HideAniIndicator;
begin
  Loading.Enabled := False;
  Loading.Visible := False;
end;

procedure TFormPrincipal.lbTituloClick(Sender: TObject);
begin
  FormCreditos.Left := FormPrincipal.Left +
    (FormPrincipal.Width - FormCreditos.Width) div 2;
  FormCreditos.Top := FormPrincipal.Top +
    (FormPrincipal.Height - FormCreditos.Height) div 2;
  FormCreditos.Visible := True;
end;



procedure TFormPrincipal.DetectLanguage(texto:String);
var
  JsonRequest, JsonRequestTranslate: TJSONArray;
  JsonObject, JsonObjectTranslate: TJSONObject;
  JsonResponse, JsonResponseTranslate, TranslationsArray: TJSONArray;
  ResponseItem, ResponseItemTranslate, TranslationObj: TJSONObject;
  ResponseContent, ResponseContentTranslate, TranslatedText, TextoToTranslate: string;
begin
  JsonRequest := TJSONArray.Create;
  try
    TextoToTranslate := texto;
    JsonObject := TJSONObject.Create;
    JsonObject.AddPair('Text', TextoToTranslate);
    JsonRequest.AddElement(JsonObject);

    RESTRequestDetectLanguage.AddBody(JsonRequest.ToJSON, TRESTContentType.ctAPPLICATION_JSON);


TTask.Run(
  procedure
  begin
    try
      RESTRequestDetectLanguage.Execute;

      TThread.Synchronize(nil,
        procedure
        begin
          ResponseContent := RESTRequestDetectLanguage.Response.Content;
          JsonResponse := TJSONObject.ParseJSONValue(ResponseContent) as TJSONArray;

          try
            if Assigned(JsonResponse) and (JsonResponse.Count > 0) then
            begin
              ResponseItem := JsonResponse.Items[0] as TJSONObject;
              if Assigned(ResponseItem) then
              begin
                lbLanguageDetected.Text := ResponseItem.GetValue<string>('language') + '  score=' + ResponseItem.GetValue<string>('score');
                lbLanguageDetected.TextSettings.FontColor := TAlphaColors.Teal;

                if ResponseItem.GetValue<Boolean>('isTranslationSupported') then
                begin
                  lbTranslateSuported.Text := 'isTranslationSupported';
                  lbTranslateSuported.TextSettings.FontColor := TAlphaColors.Teal;

                  JsonRequestTranslate := TJSONArray.Create;
                  try
                    JsonObjectTranslate := TJSONObject.Create;
                    JsonObjectTranslate.AddPair('Text', TextoToTranslate);
                    JsonRequestTranslate.AddElement(JsonObjectTranslate);


                    RESTRequestTranslate.Resource := '?api-version=3.0&to=' + string(Pointer(CBoxTo.Items.Objects[CBoxTo.ItemIndex]));

                    RESTRequestTranslate.AddBody(JsonRequestTranslate.ToJSON, TRESTContentType.ctAPPLICATION_JSON);

                    RESTRequestTranslate.Execute;

                    ResponseContentTranslate := RESTRequestTranslate.Response.Content;
                    ShowMessage(ResponseContentTranslate);
                    JsonResponseTranslate := TJSONObject.ParseJSONValue(ResponseContentTranslate) as TJSONArray;

                    if Assigned(JsonResponseTranslate) and (JsonResponseTranslate.Count > 0) then
                    begin
                      ResponseItemTranslate := JsonResponseTranslate.Items[0] as TJSONObject;
                      if Assigned(ResponseItemTranslate) then
                      begin
                        TranslationsArray := ResponseItemTranslate.GetValue<TJSONArray>('translations');
                        if Assigned(TranslationsArray) and (TranslationsArray.Count > 0) then
                        begin
                          TranslationObj := TranslationsArray.Items[0] as TJSONObject;
                          if Assigned(TranslationObj) then
                          begin
                            TranslatedText := TranslationObj.GetValue<string>('text');
                            MemoTranslated.Text := TranslatedText;
                          end;
                        end;
                      end;
                    end;
                  finally
                    JsonResponseTranslate.Free;
                  end;
                end
                else
                begin
                  lbTranslateSuported.Text := 'Translation NOT Supported';
                  lbTranslateSuported.TextSettings.FontColor := TAlphaColors.Red;
                end;
              end;
            end;
          finally
            if Assigned(JsonResponse) then
              JsonResponse.Free;
          end;
        end);
    except
      on E: Exception do
      begin
        TThread.Synchronize(nil,
          procedure
          begin
            ShowMessage('Erro durante a execução da requisição: ' + E.Message);
          end);
      end;
    end;
  end);




  finally
    JsonRequest.Free;
  end;
end;


procedure TFormPrincipal.buttonGraficoClick(Sender: TObject);
var
  IdMoodle: Integer;
  InputValue: string;
begin
  ShowAniIndicator;
  InputValue := EditIdMoodle.Text;
  if TryStrToInt(InputValue, IdMoodle) then
  begin
 	  try
        FDConnectionMySql.Connected := True;
        try
          FDQuery.SQL.Text := 'SELECT * from mdl_question where id=' + EditIdMoodle.Text + ';';
          FDQuery.Open;

          MemoSource.Text := FDQuery.FieldByName('questiontext').AsString;
          DetectLanguage(MemoSource.Text);

        except
          on E: Exception do
            ShowMessage('Error connecting to MySQL: ' + E.Message);

        end;
      finally
        FDConnectionMySql.Connected := False;
      end;
    HideAniIndicator;


  end
  else
  begin
    ShowMessage('Erro: O valor digitado não é um número inteiro válido.');
  end;
end;

procedure TFormPrincipal.CBoxLanguagesChange(Sender: TObject);
var
  SelectedKey: string;
  JsonBody: TJSONObject;
  TranslationObj: TJSONObject;
  LanguageObj: TJSONObject;
begin
  if controle = 1 then
  begin
    SelectedKey := string(Pointer(CBoxLanguages.Items.Objects[CBoxLanguages.ItemIndex]));
    controle := controle +1;
    try
      JsonBody := TJSONObject.Create;
      TranslationObj := TJSONObject.Create;
      LanguageObj := TJSONObject.Create;
      LanguageObj.AddPair('name', CBoxLanguages.Text);
      TranslationObj.AddPair(SelectedKey, LanguageObj);
      JsonBody.AddPair('translation', TranslationObj);
      RESTRequestLanguageScope.ClearBody;
      RESTRequestLanguageScope.AddBody(JsonBody.ToJSON, TRESTContentType.ctAPPLICATION_JSON);

        try
          RESTRequestLanguageScope.Execute;
          PopulateComboBoxFromJSON(CBoxTo, RESTRequestLanguageScope.Response.Content);

        finally
          //SortComboBoxItems(CBoxTo);
          SetDefaultComboBoxValue(CBoxTo, 'pt');
          controle := 0;
        end
        {
        except
          on E: Exception do
            ShowMessage('Error: ' + E.Message);

        end;         }

              // CBoxLanguagesChange( CboxTo);

    finally

      JsonBody.FreeInstance;
      TranslationObj.FreeInstance;
      LanguageObj.FreeInstance;
    end
  end
end;

procedure TFormPrincipal.SetDefaultComboBoxValue(CBox: TComboBox;
DefaultKey: string);
var
  i: Integer;
begin
  for i := 0 to CBox.Items.Count - 1 do
  begin
    if string(Pointer(CBox.Items.Objects[i])) = DefaultKey then
    begin
      CBox.ItemIndex := i;
      CBoxLanguagesChange(CBox);
      Break;
    end;
  end;
end;

procedure TFormPrincipal.CBoxToChange(Sender: TObject);
begin
  HideAniIndicator;
end;

procedure TFormPrincipal.ExtractResourceToFile(const ResName, OutputFileName: string);
var
  ResourceStream: TResourceStream;
  FileStream: TFileStream;
begin
  ResourceStream := TResourceStream.Create(HInstance, ResName, RT_RCDATA);
  try
    FileStream := TFileStream.Create(OutputFileName, fmCreate);
    try
      FileStream.CopyFrom(ResourceStream, ResourceStream.Size);
    finally
      FileStream.Free;
    end;
  finally
    ResourceStream.Free;
  end;
end;

procedure TFormPrincipal.FormCreate(Sender: TObject);
var
  Host, Username, Password, DatabaseName, FilePath: string;
  Port: Integer;
  XMLDocument: IXMLDocument;
  Node: IXMLNode;
begin
    controle := 0;
    FilePath := ExtractFilePath(ParamStr(0));
    ExtractResourceToFile('ConfigXml', FilePath + 'config.xml');
    ExtractResourceToFile('LibMysql', FilePath + 'LIBMYSQL.DLL');
    ExtractResourceToFile('LibMariaDb', FilePath + 'libmariadb.dll');

  XMLDocument := LoadXMLDocument('config.xml');
  Node := XMLDocument.DocumentElement.ChildNodes['AzureAI'];
  if Assigned(Node) then
  begin
    CONTENT_TYPE_HEADER :=Node.ChildValues['CONTENT_TYPE_HEADER'];
    CONTENT_TYPE_VALUE :=TNetEncoding.URL.Decode(Node.ChildValues['CONTENT_TYPE_VALUE']);
    SUBSCRIPTION_KEY_HEADER :=Node.ChildValues['SUBSCRIPTION_KEY_HEADER'];
    SUBSCRIPTION_KEY_VALUE :=Node.ChildValues['SUBSCRIPTION_KEY_VALUE'];
    SUBSCRIPTION_REGION_HEADER :=Node.ChildValues['SUBSCRIPTION_REGION_HEADER'];
    SUBSCRIPTION_REGION_VALUE :=Node.ChildValues['SUBSCRIPTION_REGION_VALUE'];

    RESTGetLanguages.BaseURL :=Node.ChildValues['BaseUrlLanguages'];
    RESTGetLanguageScope.BaseURL :=Node.ChildValues['BaseUrlLanguageScope'];
    RESTDetectLanguage.BaseURL :=Node.ChildValues['BaseUrlDetect'];
    RESTTranslate.BaseURL :=Node.ChildValues['BaseUrlTranslate'];

  end;
  Node := XMLDocument.DocumentElement.ChildNodes['Database'];
  if Assigned(Node) then
  begin
 	  try
      FDConnectionMySql.Params.Values['Server'] := Node.ChildValues['Host'];
      FDConnectionMySql.Params.Values['Database'] := Node.ChildValues['DatabaseName'];
      FDConnectionMySql.Params.Values['User_Name'] :=Node.ChildValues['Username'];
      FDConnectionMySql.Params.Values['Password'] := Node.ChildValues['Password'];
      FDConnectionMySql.Params.Values['Port'] := Node.ChildValues['Port'];
    except
      on E: Exception do
        ShowMessage('Error connecting to MySQL: ' + E.Message);
    end;

  end;




end;

procedure TFormPrincipal.FormShow(Sender: TObject);
var
  JSONObject, TranslationObject: TJSONObject;
  Pair: TJSONPair;
  LangObject: TJSONObject;
  LangName, LangKey: string;
begin
  ShowAniIndicator;

    try

    SetHeadersToRestRequest(RESTRequestLanguageScope);
    RESTRequestLanguageScope.Resource := '?api-version=3.0&scope=translation';
    RESTRequestLanguageScope.Method := rmGET;

    SetHeadersToRestRequest(RESTRequestDetectLanguage);
    RESTRequestDetectLanguage.Resource := '?api-version=3.0';
    RESTRequestDetectLanguage.Method := rmPOST;

    SetHeadersToRestRequest(RESTRequestTranslate);
    RESTRequestTranslate.Resource := '?api-version=3.0';
    RESTRequestTranslate.Method := rmPOST;


    SetHeadersToRestRequest(RESTRequestGetLanguages);
    RESTRequestGetLanguages.Resource := '?api-version=3.0';
    RESTRequestGetLanguages.Method := rmGET;

    try
      RESTRequestGetLanguages.Execute;
      controle := 1;
    except
      on E: Exception do
        ShowMessage('Error connecting to MySQL: ' + E.Message);
    end;
    finally
          PopulateComboBoxFromJSON(CBoxLanguages, RESTRequestGetLanguages.Response.Content);
          SortComboBoxItems(CBoxLanguages);
          SetDefaultComboBoxValue(CBoxLanguages, 'en');
          CBoxLanguagesChange(CBoxLanguages);
    end;





{$IFDEF ANDROID}
  FlowLayout1.Scale.X := 1;
  FlowLayout1.Scale.Y := 1;
{$ENDIF}
{$IFDEF MSWINDOWS}
  { FlowLayout1.Scale.X := 0.82;
    FlowLayout1.Scale.Y := 0.82; }
{$ENDIF}
end;

procedure ShowMessage(const TheMessage: string);
begin
  TDialogService.MessageDialog(TheMessage, TMsgDlgType.mtInformation,
    [TMsgDlgBtn.mbOk], TMsgDlgBtn.mbOk, 0, nil);
end;

end.
