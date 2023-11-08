#Include "TOTVS.ch"    
#include "Topconn.ch"  
#include "RESTFUL.CH"

WSRESTFUL WebSrv01 DESCRIPTION "Exemplo 01 de Web Service REST ADVPL"

   WSDATA cMensagem AS STRING

   WSMETHOD GET DESCRIPTION "Get da classe WebSrv01"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cMensagem WSSERVICE WebSrv01

Local cRetorno := ""

::SetContentType("application/json")

DbSelectArea("SA1")
SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
SA1->(DbGoTop())

If Len(::cMensagem) > 20
   cRetorno := '{' + CRLF
   cRetorno += EncodeUTF8('  "Retorno":"Mensagem: ' + ::cMensagem + SA1->SA1_COD + ' Recebida com sucesso!"') + CRLF
   cRetorno += '}'
   ::SetResponse(cRetorno)
   ::SetStatus(200)
Else
   cRetorno := '{' + CRLF
   cRetorno += EncodeUTF8('  "Retorno":"Falha, mensagem enviada é insuficiente."') + CRLF
   cRetorno += '}'
   ::SetResponse(cRetorno)
   ::SetStatus(400)
EndIf

SA1->(DbCloseArea())

Return .T.
