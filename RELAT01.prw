#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RELAT01
Exemplo 01 de relatório em TReport para Excel
@author  Marcos Gonçalves
@since   19/09/2023
@version 1.0
/*/
//-------------------------------------------------------------------
User Function XRELAT01()

    Local oReport	:= Nil
    Local aPergs    := {}
    Local aResps    := {}
    Local cCombo    := {"Alexandre de Goes", "Estrela de Davi", "LCP", "Vilmar Transporte"}

	AAdd(aPergs, {1, "Filial", Space(TamSX3("C5_FILIAL")[1]) ,,,,, 100, .T.})
//	AAdd(aPergs, {1, "Emissão de", SToD("") ,,,,, 100, .T.})
//	AAdd(aPergs, {1, "Emissão até", SToD("") ,,,,, 100, .T.})
	AAdd(aPergs, {2, "Transportadora", cCombo[1], cCombo, 100,"", .T.})
	AAdd(aPergs, {1, "Romaneio", Space(TamSX3("GW1_NRROM")[1]) ,,,,, 100, .T.})
    //AAdd(aPergs, {2, "Resultado", "1-Todos" ,{"1-Todos","2-Pedido de Venda","3-Nota Fiscal"},100,"",.F.})

    If ParamBox(aPergs, "Parâmetros do relatório", @aResps,,,,,,,, .T., .T.)
        oReport := ReportDef(aResps)
        oReport:PrintDialog()
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Define a estrutura do relatório
@author  Marcos Gonçalves
/*/
//-------------------------------------------------------------------
Static Function ReportDef(aResps)

Local oReport		:= Nil
Local oSection		:= Nil
Local oBreak		:= Nil
Local cAliasTop		:= ""
Local cNomArq		:= "FRETEMUNDIAL_" +LEFT(DToS(Date()),4)+"-"+SUBSTR(DToS(Date()),5,2) +"-"+RIGHT(DToS(Date()),2) +"_" + StrTran(Time(),":","")
Local cTitulo		:= "Frete Mundial"

If SUBSTR(Upper(aResps[2]),1,TamSX3("A4_NREDUZ")[1]) == "ALEXANDRE DE GO"
	cTitulo	:= "Frete Mundial - Alexandre de Goes"
elseif SUBSTR(Upper(aResps[2]),1,TamSX3("A4_NREDUZ")[1]) == "ESTRELA DE DAVI"
	cTitulo	:= "Frete Mundial - Estrela de Davi"
elseif SUBSTR(Upper(aResps[2]),1,TamSX3("A4_NREDUZ")[1]) == "LCP"
	cTitulo	:= "Frete Mundial - LCP"
elseif SUBSTR(Upper(aResps[2]),1,TamSX3("A4_NREDUZ")[1]) == "VILMAR TRANSPOR"
	cTitulo	:= "Frete Mundial - Vilmar Transporte"
else
	cTitulo	:= "Frete Mundial"
endif

oReport := TReport():New(cNomArq, cTitulo, "", {|oReport| ReportPrint(oReport, @cAliasTop, aResps)}, "Este programa tem como objetivo imprimir informações do relatório.")
//oReport:SetLandscape() //modo paisagem
oReport:SetPortrait() //modo retrato
oReport:cFontBody := "Calibri" 
oReport:nFontBody := 12
//oReport:oPage:SetPaperSize(9) //Folha A4

//VLR_PED	VLR_ABERTO	VLR_NF	QTDE_PV	QTDE_NF	VLR_DEVOL
oSection := TRSection():New(oReport, cTitulo, {"SF2", "SD2", "SA1", "SB1", "SA4", "GW1"})
//TRCell():New(oSection, "A1_COD" 		, "TRB"		, "Código"			, /*Picture*/		, /*Tamanho*/	, /*lPixel*/, /*{|| code-block de impressao }*/, alinhamento)
TRCell():New(oSection, "CLIENTE"        , cAliasTop	, "Cliente"			,					,20				,			, {|| (cAliasTop)->CLIENTE}		,"CENTER")
TRCell():New(oSection, "PRODUTO"        , cAliasTop	, "Produto"			,					,30				,			, {|| (cAliasTop)->PRODUTO}		,"LEFT")
TRCell():New(oSection, "UND"            , cAliasTop	, "Und"				,					,5 				,			, {|| (cAliasTop)->UND}			,"CENTER")
TRCell():New(oSection, "QUANTIDADE"     , cAliasTop	, "Quantidade"		,					,7 				,			, {|| (cAliasTop)->QUANTIDADE}	,"RIGHT")
TRCell():New(oSection, "FRETE"          , cAliasTop	, "Frete Und"		,"@E 999,999,999.99",12				,			, {|| (cAliasTop)->FRETE}		,"RIGHT")
TRCell():New(oSection, "FRETETOTAL"		, cAliasTop	, "Frete Total"		,"@E 999,999,999.99",12				,			, {|| (cAliasTop)->FRETETOTAL}	,"RIGHT")

oBreak := TRBreak():New(oSection,oSection:Cell("CLIENTE"),"Total por cliente",.F.)

//TRFunction():New( <oCell> , <cName> , <cFunction> , <oBreak> , <cTitle> , <cPicture> , <uFormula> , <lEndSection> , <lEndReport> , <lEndPage> , <oParent> , <bCondition> , <lDisable> , <bCanPrint> )
//cFunction = Função que será utilizada pelo totalizador. Exemplo: SUM, COUNT, MAX, MIN
TRFunction():New(oSection:Cell("QUANTIDADE"),,"SUM",oBreak,,"@E 9,999,999,999.99",,.T.,.F.)
TRFunction():New(oSection:Cell("FRETETOTAL"),,"SUM",oBreak,,"@E 9,999,999,999.99",,.T.,.F.)
/*TRFunction():New(oSection:Cell("VLR_NF")	,,"SUM",oBreak,,"@E 9,999,999,999.99",,.T.,.F.)
TRFunction():New(oSection:Cell("QTDE_PV")	,,"SUM",oBreak,,"@E 9,999,999,999.99",,.T.,.F.)
TRFunction():New(oSection:Cell("QTDE_NF")	,,"SUM",oBreak,,"@E 9,999,999,999.99",,.T.,.F.)
TRFunction():New(oSection:Cell("VLR_DEVOL")	,,"SUM",oBreak,,"@E 9,999,999,999.99",,.T.,.F.)
*/
Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Executa a query e imprime o relatório
@author Marcos Gonçalves
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport, cAliasTop, aResps)

	Local oSection	    := oReport:Section(1)
	Local cQuery        := ""
	Local cFil			:= aResps[1]
//	Local dEmisDe		:= aResps[2]
//	Local dEmisAte		:= aResps[3]
	Local cTransp		:= SUBSTR(Upper(aResps[2]),1,TamSX3("A4_NREDUZ")[1])
	Local cRoman		:= aResps[3]
//	Local cResult		:= aResps[6]

cQuery := "SELECT " + CRLF
cQuery += "CLIENTE, " + CRLF
cQuery += "PRODUTO, " + CRLF
cQuery += "UND, " + CRLF
cQuery += "SUM(QUANTIDADE) AS QUANTIDADE, " + CRLF
cQuery += "FRETE, " + CRLF
cQuery += "FRETE*SUM(QUANTIDADE) AS FRETETOTAL " + CRLF
cQuery += "FROM " + CRLF
cQuery += "(SELECT " + CRLF
cQuery += "F2_DOC AS DOCUMENTO, " + CRLF
cQuery += "A1_NREDUZ AS CLIENTE, " + CRLF
cQuery += "B1_DESC AS PRODUTO, " + CRLF
cQuery += "D2_UM AS UND, " + CRLF
cQuery += "D2_QUANT AS QUANTIDADE, " + CRLF
cQuery += "A4_NREDUZ AS TRANSPORTADORA, " + CRLF
cQuery += "D2_ITEM AS ORDEM, " + CRLF
cQuery += "GW1_NRROM AS ROMANEIO, " + CRLF
cQuery += "CASE WHEN B1_DESC IN ( " + CRLF
cQuery += "	'ABOBORA BATA / CX 15KG        ', " + CRLF
cQuery += "	'ABOBRINHA ITALIANA / CX 15KG  ', " + CRLF
cQuery += "	'AIPIM PARAFINADO / 20KG       ', " + CRLF
cQuery += "	'BATATA BAROA / CX 10KG        ', " + CRLF
cQuery += "	'BATATA DOCE / CX 20KG         ', " + CRLF
cQuery += "	'BERINJELA / CX 10KG           ', " + CRLF
cQuery += "	'BETERRABA / CX 20KG           ', " + CRLF
cQuery += "	'CENOURA / CX 20KG             ', " + CRLF
cQuery += "	'CHUCHU / CX 20KG              ', " + CRLF
cQuery += "	'GENGIBRE / CX 10KG            ', " + CRLF
cQuery += "	'INHAME / CX 20KG              ', " + CRLF
cQuery += "	'JILO / CX 15KG                ', " + CRLF
cQuery += "	'PEPINO / CX 20KG              ', " + CRLF
cQuery += "	'PIMENTAO VERDE / CX 10KG      ', " + CRLF
cQuery += "	'TOMATE / CX 20KG              ', " + CRLF
cQuery += "	'TOMATE ITALIANO / CX 20KG     ', " + CRLF
cQuery += "	'VAGEM MACARRAO / CX 13KG      ', " + CRLF
cQuery += "	'VAGEM MANTEIGA / CX 13KG      ') THEN 3.75 " + CRLF
cQuery += "WHEN B1_DESC IN ( " + CRLF
cQuery += "	'MORANGO / BD                  ') THEN 0.345 " + CRLF
cQuery += "WHEN B1_DESC IN ( " + CRLF
cQuery += "	'ABOBRINHA EMBALADA / BD       ', " + CRLF
cQuery += "	'BATATA BAROA EMBALADA / BD    ', " + CRLF
cQuery += "	'BATATA DOCE EMBALADA / BD     ', " + CRLF
cQuery += "	'BATATA YAKON / BD             ', " + CRLF
cQuery += "	'BERINJELA EMBALADA / BD       ', " + CRLF
cQuery += "	'BETERRABA EMBALADA / BD       ', " + CRLF
cQuery += "	'CENOURA EMBALADO / BD         ', " + CRLF
cQuery += "	'CHUCHU EMBALADO / BD          ', " + CRLF
cQuery += "	'ERVILHA EMBALADA / BD         ', " + CRLF
cQuery += "	'GENGIBRE EMBALADO / BD        ', " + CRLF
cQuery += "	'INHAME EMBALADO / BD          ', " + CRLF
cQuery += "	'JILO EMBALADO / BD            ', " + CRLF
cQuery += "	'MAXIXE EMBALADO / BD          ', " + CRLF
cQuery += "	'NABO EMBALADO / BD            ', " + CRLF
cQuery += "	'PEPINO COMUM EMBALADO / BD    ', " + CRLF
cQuery += "	'PEPINO JAPONES EMBALADO / BD  ', " + CRLF
cQuery += "	'PIMENTA CAMBUCI / BD          ', " + CRLF
cQuery += "	'PIMENTA DE CHEIRO / BD        ', " + CRLF
cQuery += "	'PIMENTA DEDO DE MOCA / BD     ', " + CRLF
cQuery += "	'PIMENTA MALAGUETA / BD        ', " + CRLF
cQuery += "	'PIMENTAO AMARELO EMBALADO / BD', " + CRLF
cQuery += "	'PIMENTAO VERDE EMBALADO / BD  ', " + CRLF
cQuery += "	'PIMENTAO VERMELHO EMBALADO/ BD', " + CRLF
cQuery += "	'TOMATE EMBALADO / BD          ', " + CRLF
cQuery += "	'TOMATE ITALIANO EMBALADO / BD ', " + CRLF
cQuery += "	'TOMATE RED GRAPE / BD         ', " + CRLF
cQuery += "	'VAGEM FRANCESA - BDJ 200GR    ', " + CRLF
cQuery += "	'VAGEM FRANCESA EMBALADA  / BD ', " + CRLF
cQuery += "	'VAGEM MACARRAO EMBALADA / BD  ', " + CRLF
cQuery += "	'VAGEM MANTEIGA EMBALADA / BD  ') THEN 0.3 " + CRLF
cQuery += "WHEN B1_DESC IN ( " + CRLF
cQuery += "	'ABACAXI / CX 10UN             ') THEN 6              " + CRLF
cQuery += "WHEN B1_DESC IN ( " + CRLF
cQuery += "	'MANGA PALMER - CXT 6KG        ', " + CRLF
cQuery += "	'MANGA TOMMY - CXT 6KG         ') THEN 2.55 " + CRLF
cQuery += "WHEN B1_DESC IN ( " + CRLF
cQuery += "	'PIMENTAO AMARELO / CX 5KG     ', " + CRLF
cQuery += "	'PIMENTAO VERDE / CX 5KG       ', " + CRLF
cQuery += "	'PIMENTAO VERMELHO / CX 5KG    ') THEN 1.87 " + CRLF
cQuery += "WHEN B1_DESC IN ( " + CRLF
cQuery += "	'QUIABO EMBALADO / KG          ') THEN 0.6 " + CRLF
cQuery += "WHEN B1_DESC IN ( " + CRLF
cQuery += "	'BANANA TERRA / CX 15KG        ') THEN 3.4 " + CRLF
cQuery += "WHEN B1_DESC IN (	 " + CRLF
cQuery += "	'MELAO AMARELO / CX 13KG       ') THEN 3.45 " + CRLF
cQuery += "ELSE 0 END AS FRETE " + CRLF
cQuery += " " + CRLF
cQuery += "FROM " + CRLF
cQuery += ""+RetSQLName("SF2")+" SF2 " + CRLF
cQuery += "LEFT JOIN "+RetSQLName("SD2")+" SD2 ON (SF2.F2_DOC = SD2.D2_DOC) " + CRLF
cQuery += "LEFT JOIN "+RetSQLName("SA1")+" SA1 ON (SF2.F2_CLIENTE = SA1.A1_COD AND SF2.F2_LOJA = SA1.A1_LOJA) " + CRLF
cQuery += "LEFT JOIN "+RetSQLName("SB1")+" SB1 ON (SD2.D2_COD = SB1.B1_COD) " + CRLF
cQuery += "LEFT JOIN "+RetSQLName("SA4")+" SA4 ON (SF2.F2_TRANSP = SA4.A4_COD) " + CRLF
cQuery += "LEFT JOIN "+RetSQLName("GW1")+" GW1 ON (SF2.F2_DOC = GW1.GW1_NRDC) " + CRLF
cQuery += " " + CRLF
cQuery += "WHERE " + CRLF
cQuery += "SF2.D_E_L_E_T_ = ' ' AND SD2.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' AND SA4.D_E_L_E_T_ = ' ' AND GW1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "AND F2_CLIENTE = 'MUND' " + CRLF
cQuery += "AND D2_TES IN (501, 508, 509) " + CRLF
cQuery += "AND F2_FILIAL = '"+cFil+"' " + CRLF
cQuery += "AND GW1_NRROM = '"+cRoman+"' " + CRLF
cQuery += "AND A4_NREDUZ = '"+cTransp+"' ) AS TB " + CRLF
cQuery += " " + CRLF
cQuery += "GROUP BY " + CRLF
cQuery += "CLIENTE, PRODUTO, UND, FRETE " + CRLF

	cAliasTop := MPSysOpenQuery(cQuery)

	If (cAliasTop)->(EOF())
		Alert("Nenhum dado com os parâmetros informados!")
	Else
		oSection:Init()
		While (cAliasTop)->(!EOF())
			oSection:PrintLine()
			(cAliasTop)->(DBSkip())
		EndDo

		(cAliasTop)->(dbCloseArea())
		oSection:Finish()
	EndIf
Return
