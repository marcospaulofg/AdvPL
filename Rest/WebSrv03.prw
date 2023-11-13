#Include "TOTVS.ch"
#include "Topconn.ch"  
#include "RESTFUL.ch"

/*
{Protheus.doc} WebSrv03
Exemplo de API REST para extrair dados das tabelas
@author  Marcos Gonçalves
@since   07/11/2023
@version 1.0
@url     http://nipobrasileira132750.protheus.cloudtotvs.com.br:2306/rest/WebSrv03
*/

WSRESTFUL WebSrv03 DESCRIPTION "Exemplo de API REST para extrair dados das tabelas" FORMAT APPLICATION_JSON

    WSMETHOD GET;
    DESCRIPTION "Get das tabela SB1";
    PRODUCES APPLICATION_JSON

END WSRESTFUL

// Método GET

WSMETHOD GET WSSERVICE WebSrv03

Local oJson    := JsonObject():New()
Local oJsonAux  := JsonObject():New()

DbSelectArea("SB1")
SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
SB1->(DbGoTop())

oJson['SB1'] := {}

While SB1->(!Eof())
    oJsonAux := JsonObject():New()

    oJsonAux['Filial']       := Alltrim(SB1->B1_FILIAL)
    oJsonAux['Codigo']       := Alltrim(SB1->B1_COD)
    oJsonAux['Descricao']    := Alltrim(SB1->B1_DESC)
    oJsonAux['Unidade']      := Alltrim(SB1->B1_UM)
    oJsonAux['Armazem Pad.'] := Alltrim(SB1->B1_LOCPAD)
    oJsonAux['Seg.Un.Medi.'] := Alltrim(SB1->B1_SEGUM)
    oJsonAux['Fator Conv.']  := Alltrim(SB1->B1_CONV)
    oJsonAux['Tipo de Conv'] := Alltrim(SB1->B1_TIPCONV)
    oJsonAux['Peso Liquido'] := Alltrim(SB1->B1_PESO)
    oJsonAux['Peso Bruto']   := Alltrim(SB1->B1_PESBRU)

    Aadd(oJson['SB1'],oJsonAux)

    FreeObj(oJsonAux)

    SB1->(DbSkip())
EndDo
SB1->(DbCLoseArea())

Self:SetResponse(EncodeUTF8(oJson:toJson()))

Return
