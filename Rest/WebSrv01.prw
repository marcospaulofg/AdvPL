#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "Topconn.ch"  
#include "RESTFUL.ch"

/*
{Protheus.doc} WebSrv01
Exemplo de API REST para extrair dados das tabelas
@author  Marcos Gonçalves
@since   07/11/2023
@version 1.0
*/

WSRESTFUL WebSrv01 DESCRIPTION "Exemplo de API REST para extrair dados das tabelas" FORMAT APPLICATION_JSON

    WSMETHOD GET DESCRIPTION "Get da tabela SA1" PRODUCES APPLICATION_JSON

END WSRESTFUL

// Método GET

WSMETHOD GET WSSERVICE WebSrv01

Local oJson := JsonObject():New()
Local oJsonAux := JsonObject():New()

DbSelectArea("SA1")
SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
SA1->(DbGoTop())

oJson['SA1'] := {}

While SA1->(!Eof())
    oJsonAux := JsonObject():New()

    oJsonAux['A1_FILIAL'] := Alltrim(SA1->A1_FILIAL)
    oJsonAux['A1_COD'] := Alltrim(SA1->A1_COD)
    oJsonAux['A1_LOJA'] := Alltrim(SA1->A1_LOJA)
    oJsonAux['A1_NOME'] := Alltrim(SA1->A1_NOME)
    oJsonAux['A1_CGC'] := Alltrim(SA1->A1_CGC)
    oJsonAux['A1_INSCR'] := Alltrim(SA1->A1_INSCR)
    oJsonAux['A1_COND'] := Alltrim(SA1->A1_COND)

    Aadd(oJson['SA1'],oJsonAux)

    FreeObj(oJsonAux)

    SA1->(DbSkip())
EndDo
SA1->(DbCLoseArea())

DbSelectArea("SB1")
SA1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
SA1->(DbGoTop())

oJson['SB1'] := {}

While SB1->(!Eof())
    oJsonAux := JsonObject():New()

    oJsonAux['B1_FILIAL'] := Alltrim(SB1->B1_FILIAL)
    oJsonAux['B1_COD'] := Alltrim(SB1->B1_COD)
    oJsonAux['B1_DESC'] := Alltrim(SB1->B1_DESC)
    oJsonAux['B1_UM'] := Alltrim(SB1->B1_UM)
    oJsonAux['B1_LOCPAD'] := Alltrim(SB1->B1_LOCPAD)
    oJsonAux['B1_SEGUM'] := Alltrim(SB1->B1_SEGUM)
    oJsonAux['B1_CONV'] := Alltrim(SB1->B1_CONV)
    oJsonAux['B1_TIPCONV'] := Alltrim(SB1->B1_TIPCONV)
    oJsonAux['B1_PESO'] := Alltrim(SB1->B1_PESO)
    oJsonAux['B1_PESBRU'] := Alltrim(SB1->B1_PESBRU)

    Aadd(oJson['SB1'],oJsonAux)

    FreeObj(oJsonAux)

    SB1->(DbSkip())
EndDo
SB1->(DbCLoseArea())

Self:SetResponse(oJson)

Return
