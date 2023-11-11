#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "Topconn.ch"  
#include "RESTFUL.ch"

WSRESTFUL PEDIDO_VENDA DESCRIPTION "Pedido de venda" FORMAT APPLICATION_JSON

    WSMETHOD GET V1 DESCRIPTION "Busca os dados de um pedido" PATH "/v1/{Filial}/{NumPed}" WSSYNTAX "/v1/{Filial}/{NumPed}" TTALK "V1"

END WSRESTFUL

// busca dados do pedido
WSMETHOD GET V1 WSSERVICE PEDIDO_VENDA
    
    Local lRet      := .T.
    Local oJsonRet  := JsonObject():New()

    DbSelectArea("SC5")
    SC5->(DbSetOrder(1))
    SC5->(DbGoTop())

    If SC5->(DbSeek("0102000006"))
        oJsonRet['code'] := 200
        oJsonRet['message'] := 'Pedido encontrado com sucesso!'

        lRet := .T.
        self:SetResponse(oJsonRet:toJson())
    Else
        lRet := .F.
        SetRestFault(1 ,;
                    "Pedido não encontrado.",;
                    .T.,;
                    400,;
                    "Informe uma filial e pedido existentes no Protheus.")
    EndIf    

RETURN lRet
