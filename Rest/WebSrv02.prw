#Include "TOTVS.ch"
#include "Topconn.ch"  
#include "RESTFUL.ch"

/*
{Protheus.doc} WebSrv02
Exemplo de API REST para extrair dados das tabelas
@author  Marcos Gonçalves
@since   07/11/2023
@version 1.0
@url     http://nipobrasileira132750.protheus.cloudtotvs.com.br:2306/rest/WEBSRV02
*/

WSRESTFUL WebSrv02 DESCRIPTION "Exemplo de API REST para extrair dados das tabelas" FORMAT APPLICATION_JSON

    WSMETHOD GET;
    DESCRIPTION "Get das tabela SA2";
    PRODUCES APPLICATION_JSON

END WSRESTFUL

// Método GET

WSMETHOD GET WSSERVICE WebSrv02

Local oJson    := JsonObject():New()
Local oJsonAux  := JsonObject():New()

DbSelectArea("SA2")
SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
SA2->(DbGoTop())

oJson['SA2'] := {}

While SA2->(!Eof())
    oJsonAux := JsonObject():New()

    oJsonAux['Filial']      := Alltrim(SA2->A2_FILIAL)
    oJsonAux['Codigo']      := Alltrim(SA2->A2_COD)
    oJsonAux['Loja']        := Alltrim(SA2->A2_LOJA)
    oJsonAux['Nome']        := Alltrim(SA2->A2_NOME)
    oJsonAux['CNPJ/CPF']    := Alltrim(SA2->A2_CGC)
    oJsonAux['Ins. Estad.'] := Alltrim(SA2->A2_INSCR)
    oJsonAux['Cond. Pagto'] := Alltrim(SA2->A2_COND)

    Aadd(oJson['SA2'],oJsonAux)

    FreeObj(oJsonAux)

    SA2->(DbSkip())
EndDo
SA2->(DbCLoseArea())

Self:SetResponse(EncodeUTF8(oJson:toJson()))

Return
