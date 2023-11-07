#Include "TOTVS.ch"    
#include "Topconn.ch"  
#include "RESTFUL.CH"

/*
{Protheus.doc} WebSrv01
Exemplo de classe usada no Web Services REST/Server
@author  Marcos Gonçalves
@since   07/11/2023
@version 1.0
*/

WSRESTFUL WebSrv01 DESCRIPTION "Exemplo 01 de Web Service REST ADVPL"

WSDATA cMensagem AS STRING

WSMETHOD GET DESCRIPTION "Get da classe WebSrv01"

END WSRESTFUL

/*
{Protheus.doc} GET
Método GET da classe
@author  Marcos Gonçalves
@since   07/11/2023
@version 1.0
*/

WSMETHOD GET WSRECEIVE cMensagem WSSERVICE WebSrv01

Local cRetorno := ""

// define o tipo de retorno do método
::SetContentType("application/json")
//::SetContentType("text/html")

If Len(::cMensagem) > 20
   cRetorno := '{' + CRLF
   cRetorno += '  "Retorno":"Mensagem: ' + ::Mensagem + ' Recebida com sucesso!"' + CRLF
   cRetorno += '}'
   ::SetResponse(cRetorno)
   ::SetResponse(200)
Else
   cRetorno := '{' + CRLF
   cRetorno += '  "Retorno":"Falha, mensagem enviada é insuficiente."' + CRLF
   cRetorno += '}'
   ::SetResponse(cRetorno)
   ::SetResponse(400)
EndIf

Return .T.
