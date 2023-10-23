//Bibliotecas
#Include "Totvs.ch"

/*/{Protheus.doc} User Function XRELAT07
Relatório de extrato bancário com histórico financeiro
@author Marcos Gonçalves
@since 14/10/2023
@version 1.0
@type function
/*/

User Function XRELAT07()
	Local aArea   	:= FWGetArea()
	Local aPergs  	:= {}

	//Adicionando os parametros do ParamBox
    AAdd(aPergs, {1, "Filial"		, Space(TamSX3("E5_FILIAL")[1])	,,,,, 38, .T.}) //MV_PAR01
	AAdd(aPergs, {1, "Emissão de"	, SToD("")						,,,,, 50, .T.}) //MV_PAR02
	AAdd(aPergs, {1, "Emissão até"	, SToD("") 						,,,,, 50, .T.}) //MV_PAR03
    AAdd(aPergs, {1, "Banco"        , Space(TamSX3("E5_BANCO")[1])  ,"@!","ExistCpo('SA6',MV_PAR04)","SA6",, 50, .T.})   // MV_PAR04
    AAdd(aPergs, {1, "Agencia"      , Space(TamSX3("E5_AGENCIA")[1]),"@!","ExistCpo('SA6',MV_PAR04 + MV_PAR05)","SA6",, 50, .T.})   // MV_PAR05
    AAdd(aPergs, {1, "Conta"        , Space(TamSX3("E5_CONTA")[1])  ,"@!","ExistCpo('SA6',MV_PAR04 + MV_PAR05 + MV_PAR06)","SA6",, 50, .T.})   // MV_PAR06
    
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
	Local oFWMsExcelXlsx
	Local oExcel
	Local cQuery     := ""
	Local cArquivo   := GetTempPath() + "MOVBANC" + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".xlsx"
	Local cWorkSheet := "Extrato"
	Local cTitulo    := "Movimentação bancária"
	Local nAtual 	 := 0
	Local nTotal 	 := 0
	Local cFil		 := MV_PAR01
	Local dEmisDe	 := DToS(MV_PAR02)
	Local dEmisAte	 := DToS(MV_PAR03)
    Local cBanco     := MV_PAR04
    Local cAgencia   := MV_PAR05
    Local cConta     := MV_PAR06
    Local nSalIni    := 0
	Local nSalFin    := 0
	Local nSomaEnt	 := 0
	Local nSomaSai	 := 0    

    //Montando consulta de dados
    cQuery += "SELECT " + CRLF
    cQuery += "E5_FILIAL, " + CRLF
    cQuery += "E5_DATA, " + CRLF
    cQuery += "E5_PREFIXO, " + CRLF
    cQuery += "E5_NUMERO, " + CRLF
    cQuery += "E5_BENEF, " + CRLF
    cQuery += "CASE WHEN E5_RECPAG = 'P' THEN E2_HIST " + CRLF
    cQuery += "ELSE E1_HIST END HISTORICO, " + CRLF
    cQuery += "E5_HISTOR, " + CRLF
    cQuery += "B1_DESC, " + CRLF
    cQuery += "CASE WHEN E5_RECPAG = 'R' THEN E5_VALOR " + CRLF
    cQuery += "ELSE 0 END ENTRADA, " + CRLF
    cQuery += "CASE WHEN E5_RECPAG = 'P' THEN E5_VALOR " + CRLF
    cQuery += "ELSE 0 END SAIDA, " + CRLF
    cQuery += "E8_SALATUA " + CRLF
    cQuery += " " + CRLF
    cQuery += "FROM " + CRLF
    cQuery += ""+RetSQLName("SE5010")+" " + CRLF
    cQuery += "LEFT JOIN "+RetSQLName("SE1010")+" ON (E5_FILIAL = E1_FILIAL AND E5_PREFIXO = E1_PREFIXO AND E5_NUMERO = E1_NUM AND E5_PARCELA = E1_PARCELA AND E5_TIPO = E1_TIPO AND E5_CLIFOR = E1_CLIENTE AND SE1010.D_E_L_E_T_ = ' ') " + CRLF
    cQuery += "LEFT JOIN "+RetSQLName("SE2010")+" ON (E5_FILIAL = E2_FILIAL AND E5_PREFIXO = E2_PREFIXO AND E5_NUMERO = E2_NUM AND E5_PARCELA = E2_PARCELA AND E5_TIPO = E2_TIPO AND E5_CLIFOR = E2_FORNECE AND SE2010.D_E_L_E_T_ = ' ') " + CRLF
    cQuery += "LEFT JOIN "+RetSQLName("SD1010")+" ON (E5_FILIAL = D1_FILIAL AND E5_PREFIXO = D1_SERIE AND E5_NUMERO = D1_DOC AND D1_ITEM = '0001' AND SD1010.D_E_L_E_T_ = ' ') " + CRLF
    cQuery += "LEFT JOIN "+RetSQLName("SD2010")+" ON (E5_FILIAL = D2_FILIAL AND E5_PREFIXO = D2_SERIE AND E5_NUMERO = D2_DOC AND D2_ITEM = '01' AND SD2010.D_E_L_E_T_ = ' ') " + CRLF
    cQuery += "LEFT JOIN "+RetSQLName("SB1010")+" ON ((D1_COD = B1_COD OR D2_COD = B1_COD) AND SB1010.D_E_L_E_T_ = ' ') " + CRLF
    cQuery += "LEFT JOIN "+RetSQLName("SE8010")+" ON (E5_FILIAL = E8_FILIAL AND E5_BANCO = E8_BANCO AND E5_AGENCIA = E8_AGENCIA AND E5_CONTA = E8_CONTA AND E5_DATA = E8_DTSALAT AND SE8010.D_E_L_E_T_ = ' ') " + CRLF
    cQuery += " " + CRLF
    cQuery += "WHERE " + CRLF
    cQuery += "E5_FILIAL = '"+cFil+"' " + CRLF
    cQuery += "AND E5_DATA BETWEEN '"+dEmisDe+"' AND '"+dEmisAte+"' " + CRLF
    cQuery += "AND E5_BANCO = '"+cBanco+"' " + CRLF
    cQuery += "AND E5_AGENCIA = '"+cAgencia+"' " + CRLF
    cQuery += "AND E5_CONTA = '"+cConta+"' " + CRLF
    cQuery += "AND SE5010.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += " " + CRLF
    cQuery += "ORDER BY " + CRLF
    cQuery += "E5_DATA " + CRLF
	
	//Executando consulta e setando o total da regua
	PlsQuery(cQuery, "QRY_DAD")
	DbSelectArea("QRY_DAD")
	
	//Cria a planilha do excel
	oFWMsExcelXlsx := FWMsExcelXlsx():New()
	
	//Criando a aba da planilha
	oFWMsExcelXlsx:AddworkSheet(cWorkSheet)
	
	//Criando a Tabela e as colunas
	oFWMsExcelXlsx:AddTable(cWorkSheet , cTitulo, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Data"		            , 1, 1, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Prefixo"	                , 1, 1, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Documento"		        , 1, 1, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Cliente / Fornecedor"	, 1, 1, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Histórico"		        , 1, 1, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Entrada"			        , 3, 3, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Saída"	                , 3, 3, .F.)
	oFWMsExcelXlsx:AddColumn(cWorkSheet, cTitulo, "Saldo atual"		        , 3, 3, .F.)
	
	//Calculando saldo inicial
	nSalFin := QRY_DAD->E8_SALATUA
	While QRY_DAD->E8_SALATUA == nSalFin
		nSomaEnt += QRY_DAD->ENTRADA
		nSomaSai += QRY_DAD->SAIDA
		QRY_DAD->(DbSkip())
    EndDo
	QRY_DAD->(DbGoTop())
	nSalIni := QRY_DAD->E8_SALATUA + nSomaSai - nSomaEnt

	//Definindo o tamanho da regua
	Count To nTotal
	ProcRegua(nTotal)
	QRY_DAD->(DbGoTop())

	//Percorrendo os dados da query
	While !(QRY_DAD->(EoF()))
		
		//Incrementando a regua
		nAtual++
		IncProc("Imprimindo registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + " [" + cValToChar(Round(100*nAtual/nTotal,2)) + "%]...")
		
		//Calculando o saldo final
		If nAtual == 1
			nSalFin := nSalIni - QRY_DAD->SAIDA + QRY_DAD->ENTRADA
		Else
			nSalFin := nSalFin - QRY_DAD->SAIDA + QRY_DAD->ENTRADA
		EndIf

		//Adicionando uma nova linha
		oFWMsExcelXlsx:AddRow(cWorkSheet, cTitulo, {;
			QRY_DAD->E5_DATA,;
			QRY_DAD->E5_PREFIXO,;
			QRY_DAD->E5_NUMERO,;
			QRY_DAD->E5_BENEF,;
			IIF(QRY_DAD->E5_PREFIXO == Space(3),QRY_DAD->E5_HISTOR,IIF(QRY_DAD->HISTORICO == Space(40), QRY_DAD->B1_DESC, QRY_DAD->HISTORICO)),;
			QRY_DAD->ENTRADA,;
            QRY_DAD->SAIDA,;			
			nSalFin;
		})

		QRY_DAD->(DbSkip())
	EndDo

	//Calculando total de entradas e saídas
	QRY_DAD->(DbGoTop())

	nSomaEnt := 0
	nSomaSai := 0

	While !(QRY_DAD->(EoF()))
		nSomaEnt += QRY_DAD->ENTRADA
		nSomaSai += QRY_DAD->SAIDA
		QRY_DAD->(DbSkip())
	EndDo

	QRY_DAD->(DbCloseArea())
	
	//Criando linha em branco
	oFWMsExcelXlsx:AddRow(cWorkSheet, cTitulo, {})

	//Criando linha de saldo inicial, total de entradas, total de saídas e saldo final
	oFWMsExcelXlsx:SetBold(.T.)
	oFWMsExcelXlsx:AddRow(cWorkSheet, cTitulo, {,,,,,,;
		"Saldo inicial",;
		nSalIni;
	})

	oFWMsExcelXlsx:AddRow(cWorkSheet, cTitulo, {,,,,,,;
		"Entradas totais",;
		nSomaEnt;
	})

	oFWMsExcelXlsx:AddRow(cWorkSheet, cTitulo, {,,,,,,;
		"Saídas totais",;
		nSomaSai;
	})	

	oFWMsExcelXlsx:AddRow(cWorkSheet, cTitulo, {,,,,,,;
		"Saldo final",;
		nSalFin;
	})

	//Ativando o arquivo e gerando o xml
	oFWMsExcelXlsx:Activate()
	oFWMsExcelXlsx:GetXMLFile(cArquivo)
	
	//Abrindo o excel e abrindo o arquivo xml
	oExcel := MsExcel():New()
	oExcel:WorkBooks:Open(cArquivo)
	oExcel:SetVisible(.T.)
	oExcel:Destroy()
	
Return
