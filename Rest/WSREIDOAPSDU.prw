#Include "TOTVS.ch"    
#include "Topconn.ch"  
#include "RESTFUL.CH"

//+------------------------------------------------------------------------------------------------------------------+
//| Programa | MT4REIDOAPSDU10ALT | Autor | Marcos Gonçalves | Data | 10.11.2023 | 
//+------------------------------------------------------------------------------------------------------------------+
//| Descr. | Exemplo de API REST Consulta de Fornecedor | 
//| | PARA CONEXÃO COM O APP POR API PARA SER SUBMETIDO A LIBERAÇÃO | 
//+------------------------------------------------------------------------------------------------------------------+
//| Uso | Canal Youtube | 
//+------------------------------------------------------------------------------------------------------------------+

WSRESTFUL WebSrv03 DESCRIPTION "Teste de API REST Protheus" FORMAT APPLICATION_JSON
WSDATA cpfCnpjForn	       AS CHARACTER  OPTIONAL
WSDATA codigoLojaForn       AS CHARACTER  OPTIONAL
WSDATA nomeForn		       AS CHARACTER  OPTIONAL

WSMETHOD GET ConsultaFornecedor;
	DESCRIPTION "API utilizada para efetuar a consulta de Fornecedores";
	WSSYNTAX "/consultar/fornecedores/?{cpfCnpjForn}&{codigoLojaForn}&{nomeForn}";
	PATH "/consultar/fornecedores/";
	TTALK "ConsultaFornecedor";
	PRODUCES APPLICATION_JSON

END WSRESTFUL


WSMETHOD GET ConsultaFornecedor HEADERPARAM cpfCnpjForn, codigoLojaForn, nomeForn  WSSERVICE WebSrv03


Local oResponse		:=	Nil
Local aResponse		:=	{}
Local oForn
Local lRet			:=	.T.
Local cCnpj         := ""
Local cCodFor       := ""
Local cNomFor       := ""
Local cQuery        := ""
Local cAliasSA2     


if ( ValType( self:cpfCnpjForn  ) == "C" .and. !Empty( self:cpfCnpjForn  ) )
   cCnpj := self:cpfCnpjForn
   cCnpj := StrTran(cCnpj,".","")
   cCnpj := StrTran(cCnpj,"/","")
   cCnpj := StrTran(cCnpj,"-","")
ENDIF

if ( ValType( self:codigoLojaForn  ) == "C" .and. !Empty( self:codigoLojaForn  ) )
   cCodFor := self:codigoLojaForn
ENDIF

if ( ValType( self:nomeForn  ) == "C" .and. !Empty( self:nomeForn  ) )
   cNomFor := self:nomeForn
ENDIF


cQuery := "SELECT * "
cQuery += "	FROM " + RetSqlName("SA2") + " SA2 " + Chr(10) + Chr (13) 
cQuery += "WHERE SA2.D_E_L_E_T_='' "+ Chr(10) + Chr(13)
cQuery += "AND A2_FILIAL ='"+XFILIAL("SA2")+"' "+ Chr(10) + Chr(13)
if !empty(cCnpj)
cQuery += "AND A2_CGC = '"+cCnpj+"' "+ Chr(10) + Chr(13)
endif
if !empty(cNomFor)
   cQuery += "AND A2_NOME LIKE'%"+cNomFor+"%' "+ Chr(10) + Chr(13)
endif
if !empty(cCodFor)
cQuery += "AND A2_COD + A2_LOJA ='"+cCodFor+"' "+ Chr(10) + Chr(13)
endif

cQuery += "ORDER BY A2_NOME "

conout("testapi: "+ cQuery)


While .T.
    cAliasSA2 := GetNextAlias()
    If !TCCanOpen(cAliasSA2) .And. Select(cAliasSA2) == 0
        Exit
    EndIf
EndDo

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSA2,.F.,.T.) 
DbSelectArea(cAliasSA2)
(cAliasSA2)->(DbGoTop())

IF (cAliasSA2)->(EOF())
   (cAliasSA2)->(DbcloseArea())
   oResponse := JsonObject():New()
   oResponse["consultarResultado"]	:= {}
   self:SetResponse( oResponse:ToJson() )
   FreeObj( oResponse )
   oResponse := Nil
   Return( lRet )
ELSE
   While !(cAliasSA2)->(EOF())
                    
        oForn  := nil
        oForn  := JsonObject():New()
        oForn["codigoLojaForn"]          := (cAliasSA2)->A2_COD + (cAliasSA2)->A2_LOJA
        oForn["cpfCnpjForn"]             := (cAliasSA2)->A2_CGC
        oForn["nomeForn"]                := ALLTRIM((cAliasSA2)->A2_NOME)
        oForn["nomeFantasia"]            := ALLTRIM((cAliasSA2)->A2_NREDUZ)
        oForn["endereco"]                := ALLTRIM((cAliasSA2)->A2_END)
        oForn["cep"]                     := (cAliasSA2)->A2_CEP
        oForn["bairro"]                  := alltrim((cAliasSA2)->A2_BAIRRO)
        oForn["estado"]                  := (cAliasSA2)->A2_EST
       
        aadd(aResponse,oForn)
        
        (cAliasSA2)->(dbskip())
    Enddo 
    (cAliasSA2)->(DbcloseArea())
     
    oResponse := JsonObject():New()
    oResponse["consultarResultado"]	:= aResponse
    self:SetResponse( EncodeUTF8(oResponse:ToJson()) )
ENDIF

FreeObj( oResponse )
oResponse := Nil

Return( lRet )
