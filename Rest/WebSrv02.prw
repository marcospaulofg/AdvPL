#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "Topconn.ch"  
#include "RESTFUL.ch"

/*
{Protheus.doc} WebSrv02
Exemplo de API REST para extrair dados das tabelas
@author  Marcos Gonçalves
@since   07/11/2023
@version 1.0
*/

WSRESTFUL WebSrv02 DESCRIPTION "Exemplo de API REST para extrair dados das tabelas"

    WSMETHOD GET DESCRIPTION "Get da tabela SA1" WSSYNTAX "/"

END WSRESTFUL

// Método GET

WSMETHOD GET WSSERVICE WebSrv02

Local oJson := JsonObject():New()
Local oJsonAux := JsonObject():New()

DbSelectArea("SA1")
SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
SA1->(DbGoTop())

oJson['CLIENTES'] := {}

While SA1->(!Eof())
    oJsonAux := JsonObject():New()

    oJsonAux['CODIGO'] := SA1->SA1_COD
    oJsonAux['LOJA'] := SA1->SA1_LOJA
    oJsonAux['NOME'] := SA1->SA1_NOME

    Aadd(oJson['CLIENTES'],oJsonAux)

    FreeObj(oJsonAux)

    SA1->(DbSkip())
EndDo

Self:SetResponse(oJson)

Return
