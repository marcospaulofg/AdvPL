#Include "TOTVS.ch"
#include "Topconn.ch"  
#include "RESTFUL.ch"

/*
{Protheus.doc} WebSrv05
Exemplo de API REST para extrair dados das tabelas
@author  Marcos Gonçalves
@since   07/11/2023
@version 1.0
@url     http://nipobrasileira132750.protheus.cloudtotvs.com.br:2306/rest/WebSrv05
*/

WSRESTFUL WebSrv05 DESCRIPTION "Exemplo de API REST para extrair dados das tabelas" FORMAT APPLICATION_JSON

    WSMETHOD GET;
    DESCRIPTION "Get das tabela SD2";
    PRODUCES APPLICATION_JSON

END WSRESTFUL

// Método GET

WSMETHOD GET WSSERVICE WebSrv05

Local oJson    := JsonObject():New()
Local oJsonAux  := JsonObject():New()

DbSelectArea("SD2")
SD2->(DbSetOrder(1)) //D2_FILIAL+D2_COD
SD2->(DbGoTop())

oJson['SD2'] := {}

While SD2->(!Eof())
    oJsonAux := JsonObject():New()
    
    oJsonAux['Filial']       := AllTrim(SD2->D2_FILIAL)
    oJsonAux['Item']         := AllTrim(SD2->D2_ITEM)
    oJsonAux['Produto']      := AllTrim(SD2->D2_COD)
    oJsonAux['Segunda UM']   := AllTrim(SD2->D2_SEGUM)
    oJsonAux['Unidade']      := AllTrim(SD2->D2_UM)
    oJsonAux['Quantidade']   := SD2->D2_QUANT
    oJsonAux['Vlr.Unitario'] := SD2->D2_PRCVEN
    oJsonAux['Vlr.Total']    := SD2->D2_TOTAL
    oJsonAux['Tipo Saida']   := AllTrim(SD2->D2_TES)
    oJsonAux['Desc.Item']    := SD2->D2_DESC
    oJsonAux['Peso total']   := SD2->D2_PESO
    oJsonAux['C Contabil']   := AllTrim(SD2->D2_CONTA)
    oJsonAux['No do Pedido'] := AllTrim(SD2->D2_PEDIDO)
    oJsonAux['Item do Ped.'] := AllTrim(SD2->D2_ITEMPV)
    oJsonAux['Cliente']      := AllTrim(SD2->D2_CLIENTE)
    oJsonAux['Loja']         := AllTrim(SD2->D2_LOJA)
    oJsonAux['Armazem']      := AllTrim(SD2->D2_LOCAL)
    oJsonAux['Num. Docto.']  := AllTrim(SD2->D2_DOC)
    oJsonAux['Serie']        := AllTrim(SD2->D2_SERIE)
    oJsonAux['Custo']        := SD2->D2_CUSTO1
    oJsonAux['Qtde 2a UM']   := SD2->D2_QTSEGUM

    Aadd(oJson['SD2'],oJsonAux)

    FreeObj(oJsonAux)

    SD2->(DbSkip())
EndDo
SD2->(DbCLoseArea())

Self:SetResponse(EncodeUTF8(oJson:toJson()))

Return
