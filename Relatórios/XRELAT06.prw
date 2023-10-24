//Bibliotecas
#Include "Totvs.ch"

/*/{Protheus.doc} User Function XRELAT06
Faturamento por produto em Excel
@author Marcos Gonçalves
@since 14/10/2023
@version 1.0
@type function
/*/

User Function XRELAT06()
	Local aArea   	:= FWGetArea()
	Local aPergs  	:= {}

	//Adicionando os parametros do ParamBox
    AAdd(aPergs, {1, "Filial"		, Space(TamSX3("C5_FILIAL")[1])	,,,,, 38, .T.}) //MV_PAR01
	AAdd(aPergs, {1, "Emissão de"	, SToD("")						,,,,, 50, .T.}) //MV_PAR02
	AAdd(aPergs, {1, "Emissão até"	, SToD("") 						,,,,, 50, .T.}) //MV_PAR03
    
	//Se a pergunta for confirma, cria as definições do relatório
    If ParamBox(aPergs, "Informe os parâmetros", , , , , , , , , .T., .T.)
		Processa({|| fGeraExcel()})
	EndIf
	
	FWRestArea(aArea)
Return

/*/{Protheus.doc} fGeraExcel
Criacao do arquivo Excel na funcao XRELAT06
/*/

Static Function fGeraExcel()
	Local cQuery  := ""
	Local oFWMsExcelXlsx
	Local oExcel
	Local cArquivo    := GetTempPath() + "FATURAMENTO" + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".xlsx"
	Local cWorkSheet := "Produtos"
	Local cTitulo    := "Lista de Produtos"
	Local nAtual := 0
	Local nTotal := 0
	Local cFil		:= MV_PAR01
	Local dEmisDe	:= DToS(MV_PAR02)
	Local dEmisAte	:= DToS(MV_PAR03)
	
	//Montando consulta de dados
	cQuery += "SELECT " + CRLF
	cQuery += "D2_ITEM, " + CRLF
	cQuery += "D2_EMISSAO, " + CRLF
	cQuery += "D2_DOC, " + CRLF
	//cQuery += "A1_NREDUZ, " + CRLF
	cQuery += "D2_CLIENTE, " + CRLF
	cQuery += "D2_LOJA, " + CRLF
	cQuery += "D2_COD, " + CRLF
	cQuery += "B1_DESC, " + CRLF
	cQuery += "D2_UM, " + CRLF
	cQuery += "D2_SEGUM, " + CRLF
	cQuery += "D2_QUANT, " + CRLF
	cQuery += "D2_PRCVEN, " + CRLF
	cQuery += "D2_TOTAL, " + CRLF
	cQuery += "D2_PESO, " + CRLF
	cQuery += "D2_CUSTO1 " + CRLF
	cQuery += " " + CRLF
	cQuery += "FROM " + CRLF
	cQuery += ""+RetSQLName("SD2010")+" " + CRLF
	cQuery += "LEFT JOIN "+RetSQLName("SB1010")+" ON (D2_COD = B1_COD) " + CRLF
	//cQuery += "LEFT JOIN "+RetSQLName("SA1010")+" ON (D2_CLIENTE = A1_COD AND D2_LOJA = A1_LOJA) " + CRLF
	cQuery += " " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "D2_EMISSAO BETWEEN '"+dEmisDe+"' AND '"+dEmisAte+"' " + CRLF
	cQuery += "AND D2_FILIAL = '"+cFil+"' " + CRLF
	cQuery += "AND SD2010.D_E_L_E_T_ = ' ' AND SB1010.D_E_L_E_T_ = ' ' " + CRLF
	//cQuery += "AND SA1010.D_E_L_E_T_ = ' ' " + CRLF
	
	//Executando consulta e setando o total da regua
	PlsQuery(cQuery, "QRY_DAD")
	DbSelectArea("QRY_DAD")
	
	//Cria a planilha do excel
	oFWMsExcelXlsx := FWMsExcelXlsx():New()
	
	//Criando a aba da planilha
	oFWMsExcelXlsx:AddworkSheet(cWorkSheet)
	
	//Criando a Tabela e as colunas
	oFWMsExcelXlsx:AddTable(cWorkSheet, cTitulo, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Item"		, 1, 1, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Código"		, 1, 1, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Und"			, 1, 1, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Seg. Und"	, 1, 1, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Quantidade"	, 3, 2, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Vlr und"		, 3, 3, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Vlr total"	, 3, 3, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Peso total"	, 3, 2, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "CLiente"		, 1, 1, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Loja"		, 1, 1, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Emissão"		, 1, 4, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Documento"	, 1, 1, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Custo total"	, 3, 3, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Produto"		, 1, 1, .F.)
	
	//Definindo o tamanho da regua
	Count To nTotal
	ProcRegua(nTotal)
	QRY_DAD->(DbGoTop())
	
	//Percorrendo os dados da query
	While !(QRY_DAD->(EoF()))
		
		//Incrementando a regua
		nAtual++
		IncProc("Imprimindo registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + " [" + cValToChar(Round(100*nAtual/nTotal,2)) + "%]...")
		
		//Adicionando uma nova linha
		oFWMsExcelXlsx:AddRow(cWorkSheet, cTitulo, {;
			QRY_DAD->D2_ITEM,;
			QRY_DAD->D2_COD,;
			QRY_DAD->D2_UM,;
			QRY_DAD->D2_SEGUM,;
			QRY_DAD->D2_QUANT,;
			QRY_DAD->D2_PRCVEN,;
			QRY_DAD->D2_TOTAL,;
			QRY_DAD->D2_PESO*QRY_DAD->D2_QUANT,;
			QRY_DAD->D2_CLIENTE,;
			QRY_DAD->D2_LOJA,;
			QRY_DAD->D2_EMISSAO,;
			QRY_DAD->D2_DOC,;
			QRY_DAD->D2_CUSTO1,;
			QRY_DAD->B1_DESC;
		})
		
		QRY_DAD->(DbSkip())
	EndDo
	QRY_DAD->(DbCloseArea())
	
	//Ativando o arquivo e gerando o xml
	oFWMsExcelXlsx:Activate()
	oFWMsExcelXlsx:GetXMLFile(cArquivo)
	
	//Abrindo o excel e abrindo o arquivo xml
	oExcel := MsExcel():New()
	oExcel:WorkBooks:Open(cArquivo)
	oExcel:SetVisible(.T.)
	oExcel:Destroy()
	
Return
