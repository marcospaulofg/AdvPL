#Include "TOTVS.ch"
#include "Topconn.ch"  
#include "RESTFUL.ch"

/*
{Protheus.doc} WebSrv04
Exemplo de API REST para extrair dados das tabelas
@author  Marcos Gonçalves
@since   07/11/2023
@version 1.0
@url     http://nipobrasileira132750.protheus.cloudtotvs.com.br:2306/rest/WebSrv04
*/

WSRESTFUL WebSrv04 DESCRIPTION "Exemplo de API REST para extrair dados das tabelas" FORMAT APPLICATION_JSON

    WSMETHOD GET;
    DESCRIPTION "Get das tabela SF2";
    PRODUCES APPLICATION_JSON

END WSRESTFUL

// Método GET

WSMETHOD GET WSSERVICE WebSrv04

Local oJson    := JsonObject():New()
Local oJsonAux  := JsonObject():New()

DbSelectArea("SF2")
SF2->(DbSetOrder(1)) //F2_FILIAL+F2_COD
SF2->(DbGoTop())

oJson['SF2'] := {}

While SF2->(!Eof())
    oJsonAux := JsonObject():New()

    oJsonAux['Filial']       := AllTrim(SF2->F2_FILIAL)
    oJsonAux['Numero']       := AllTrim(SF2->F2_DOC)
    oJsonAux['Serie Docto.'] := AllTrim(SF2->F2_SERIE)
    oJsonAux['Cliente']      := AllTrim(SF2->F2_CLIENTE)
    oJsonAux['Loja']         := AllTrim(SF2->F2_LOJA)
    oJsonAux['Cond. Pagto']  := AllTrim(SF2->F2_COND)
    oJsonAux['DT Emissao']   := SF2->F2_EMISSAO
    oJsonAux['Vlr.Bruto']    := SF2->F2_VALBRUT
    oJsonAux['Peso Liquido'] := SF2->F2_PLIQUI
    oJsonAux['Peso Bruto']   := SF2->F2_PBRUTO
    oJsonAux['Transp.']      := AllTrim(SF2->F2_TRANSP)

    Aadd(oJson['SF2'],oJsonAux)

    FreeObj(oJsonAux)

    SF2->(DbSkip())
EndDo
SF2->(DbCLoseArea())

Self:SetResponse(EncodeUTF8(oJson:toJson()))

Return
