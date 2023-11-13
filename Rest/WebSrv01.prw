#Include "TOTVS.ch"
#include "Topconn.ch"  
#include "RESTFUL.ch"

/*
{Protheus.doc} WebSrv01
Exemplo de API REST para extrair dados das tabelas
@author  Marcos Gonçalves
@since   07/11/2023
@version 1.0
@url     http://nipobrasileira132750.protheus.cloudtotvs.com.br:2306/rest/WEBSRV01
*/

WSRESTFUL WebSrv01 DESCRIPTION "Exemplo de API REST para extrair dados das tabelas" FORMAT APPLICATION_JSON

    WSMETHOD GET;
    DESCRIPTION "Get das tabela SA1";
    PRODUCES APPLICATION_JSON

END WSRESTFUL

// Método GET

WSMETHOD GET WSSERVICE WebSrv01

Local oJson    := JsonObject():New()
Local oJsonAux  := JsonObject():New()

DbSelectArea("SA1")
SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
SA1->(DbGoTop())

oJson['SA1'] := {}

While SA1->(!Eof())
    oJsonAux := JsonObject():New()

    oJsonAux['Filial']      := Alltrim(SA1->A1_FILIAL)
    oJsonAux['Codigo']      := Alltrim(SA1->A1_COD)
    oJsonAux['Loja']        := Alltrim(SA1->A1_LOJA)
    oJsonAux['Nome']        := Alltrim(SA1->A1_NOME)
    oJsonAux['CNPJ/CPF']    := Alltrim(SA1->A1_CGC)
    oJsonAux['Ins. Estad.'] := Alltrim(SA1->A1_INSCR)
    oJsonAux['Cond. Pagto'] := Alltrim(SA1->A1_COND)

    Aadd(oJson['SA1'],oJsonAux)

    FreeObj(oJsonAux)

    SA1->(DbSkip())
EndDo
SA1->(DbCLoseArea())

Self:SetResponse(EncodeUTF8(oJson:toJson()))

Return
