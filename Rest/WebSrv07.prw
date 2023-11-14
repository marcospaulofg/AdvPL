#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "Topconn.ch"  
#include "RESTFUL.ch"

/*
{Protheus.doc} WebSrv07
Exemplo de API REST para extrair dados das tabelas
@author  Marcos Gonçalves
@since   07/11/2023
@version 1.0
*/

WSRESTFUL WebSrv07 DESCRIPTION "WebService para consulta de clientes" FORMAT APPLICATION_JSON
    WSMETHOD GET V1;
    DESCRIPTION "Retorna infomaçoes do cliente.";
    PATH "/V1/{codigo}/{loja}";
    WSSYNTAX "/V1/{codigo}/{loja}"

END WSRESTFUL

// Método GET

WSMETHOD GET V1 WSSERVICE WebSrv07

    //variaveis
    Local cCodigo   := self:aURLParms[2]
    Local cLoja     := self:aURLParms[3]
    Local oCliente  := JsonObject():New()
    Local cResponse := ""

    //abre alias sa1
    DbSelectArea("SA1")
    SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
    SA1->(DbGoTop())

    //valida codigo e loja
    if Len(cCodigo) != 20 .OR. Len(cLoja) != 2
        SetRestFault(400, EncodeUTF8("Código ou loja inválido."))
        return .F.
    endif

    //posiciona no cliente
    if !SA1->(DbSeek(xFilial("SA1") + cCodigo + cLoja))
        SetRestFault(404, EncodeUTF8("Cliente não localizado."))
        return .F.
    endif

    //cria json
    oCliente['codigo']      := AllTrim(SA1->A1_COD)
    oCliente['loja']        := AllTrim(SA1->A1_LOJA)
    oCliente['uf']          := AllTrim(SA1->A1_EST)

    //json to sting
    cResponse := oCliente:toJson()

    //define o tipo de retorno
    self:SetContentType('application/json')

    //define resposta
    self:SetResponse(EncodeUTF8(cResponse))

Return .T.
