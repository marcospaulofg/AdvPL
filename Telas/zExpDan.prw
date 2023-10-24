//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} zExpDan
Função para gerar os pdf e os xml de um intervalo em uma pasta
@author Atilio
@since 23/06/2019
@version 1.0
@type function
/*/

User Function zExpDan()
	Local aArea   := GetArea()
	Local aPergs  := {}
	Local cDiret  := "C:\TOTVS\NF\" + Space(99)
	Local dDataDe := FirstDate(Date())
	Local dDataAt := Date()
	Local cCliDe  := Space(TamSX3('A1_COD')[1])
	Local cCliAt  := StrTran(cCliDe, ' ', 'Z')
	Local cDocDe  := Space(TamSX3('F2_DOC')[1])
	Local cDocAt  := StrTran(cDocDe, ' ', 'Z')
	
	//Adiciona os parâmetros
	aAdd(aPergs, {1, "Diretório",     cDiret,  "",   ".T.", "", ".T.", 80, .T.}) // MV_PAR01
	aAdd(aPergs, {1, "Data De",       dDataDe, "",   ".T.", "", ".T.", 80, .T.}) // MV_PAR02
	aAdd(aPergs, {1, "Data Até",      dDataAt, "",   ".T.", "", ".T.", 80, .T.}) // MV_PAR03
	aAdd(aPergs, {2, "Gera pdf",      1, {"1=Sim",  "2=Não"}, 040, ".T.", .F.}) // MV_PAR04
	aAdd(aPergs, {2, "Gera xml",      1, {"1=Sim",  "2=Não"}, 040, ".T.", .F.}) // MV_PAR05
	aAdd(aPergs, {2, "Tipo",          1, {"1=Normal (N)",  "2=Devolução (D)", "3=Fornecedor (B)"}, 060, ".T.", .F.}) // MV_PAR06
	aAdd(aPergs, {1, "Cliente De",    cCliDe,  "", ".T.", "SA1", ".T.", 60,  .F.}) // MV_PAR07
	aAdd(aPergs, {1, "Cliente Até",   cCliAt,  "", ".T.", "SA1", ".T.", 60,  .T.}) // MV_PAR08
	aAdd(aPergs, {1, "NF De",         cDocDe,  "", ".T.", "", ".T.", 90,  .F.}) // MV_PAR09
	aAdd(aPergs, {1, "NF Até",        cDocAt,  "", ".T.", "", ".T.", 90,  .T.}) // MV_PAR10
	
	//Mostra a tela para informas os parâmetros
	If ParamBox(aPergs, "Informe os parâmetros", , , , , , , , , .T., .T.)
		MV_PAR04 := cValToChar(MV_PAR04)
		MV_PAR05 := cValToChar(MV_PAR05)
		MV_PAR06 := cValToChar(MV_PAR06)
		
		//Se não existir o diretório,força a criação
		MV_PAR01 := Alltrim(MV_PAR01)
		If ! ExistDir(MV_PAR01)
			MakeDir(MV_PAR01)
		EndIf
		
		//Se a data até for maior que a data inicial
		If MV_PAR03 >= MV_PAR02
		
			//Se for para gerar o pdf ou o xml, chama a rotina de processamento
			If MV_PAR04 == "1" .Or. MV_PAR05 == "1"
				Processa({|| fProcessa() }, "Processando...")
			EndIf
			
		Else
			MsgStop("Data Até tem que ser maior que Data De", "Atenção")
		EndIf
	EndIf
	
	
	RestArea(aArea)
Return

Static Function fProcessa()
	Local aArea  := GetArea()
	Local cQuery := ""
	Local nAtual := 0
	Local nTotal := 0
	Local lXML   := MV_PAR05 == "1"
	Local lPDF   := MV_PAR04 == "1"
	Local cDir   := MV_PAR01
	
/*	//Exibo registros deletados
	Set Deleted Off

	//Abro a tabela SF2
	DbSelectArea('SF2')

	//Vou para o Recno 1
	SF2->(DbGoTop())

	//Verifico se está posicionado no registro que quer
	If(SF2->(dbSeek(xFilial("SF2")+MV_PAR09+"1  ")))

	    //Recupero o registro
	    RecLock('SF2', .F.)
	        SF2->(DbRecall())
	    SF2->(MsUnlock())

	Endif

	//Fecho a tabela
	SF2->(DbCloseArea())




	//Abro a tabela SD2
	DbSelectArea('SD2')

	//Vou para o Recno 1
	SD2->(DbGoTop())

	//Abro o índice 3
	SD2->(dbSetOrder(3))

	//Verifico se está posicionado no registro que quer
	If(SD2->(dbSeek(xFilial("SD2")+MV_PAR09+"1  ")))
		While D2_DOC == MV_PAR09
			//Recupero o registro
	    	RecLock('SD2', .F.)
	    	    SD2->(DbRecall())
	    	SD2->(MsUnlock())
			SD2->(dbSkip()) // pula pro próximo registro
		EndDo
	Endif

	//Fecho a tabela
	SD2->(DbCloseArea())

	//Exibo apenas registros válidos
	Set Deleted On

	//NAO ESQUECER DE DELETAR NOVAMENTE A NOTA
*/

	//Montando a query para geração das Notas Fiscais
	cQuery := " SELECT " + CRLF
	cQuery += "     F2_DOC, " + CRLF
	cQuery += "     F2_SERIE, " + CRLF
	cQuery += "     F2_EMISSAO " + CRLF
	cQuery += " FROM " + CRLF
	cQuery += "     " + RetSQLName('SF2') + " SF2 WITH (NOLOCK) " + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += "     F2_FILIAL = '" + FWxFilial('SF2') + "' " + CRLF
	cQuery += "     AND F2_EMISSAO >= '" + dToS(MV_PAR02) + "' " + CRLF
	cQuery += "     AND F2_EMISSAO <= '" + dToS(MV_PAR03) + "' " + CRLF
	If MV_PAR06 == "1"
		cQuery += "     AND F2_TIPO = 'N' " + CRLF
	ElseIf MV_PAR06 == "2"
		cQuery += "     AND F2_TIPO = 'D' " + CRLF
	ElseIf MV_PAR06 == "3"
		cQuery += "     AND F2_TIPO = 'B' " + CRLF
	EndIf
	cQuery += "     AND F2_CLIENTE >= '" + MV_PAR07 + "' " + CRLF
	cQuery += "     AND F2_CLIENTE <= '" + MV_PAR08 + "' " + CRLF
	cQuery += "     AND F2_DOC >= '" + MV_PAR09 + "' " + CRLF
	cQuery += "     AND F2_DOC <= '" + MV_PAR10 + "' " + CRLF
	cQuery += "     AND SF2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " ORDER BY " + CRLF
	cQuery += "     F2_EMISSAO, F2_DOC " + CRLF
	TCQuery cQuery New Alias "QRY_XML"
	TCSetField("QRY_XML", "F2_EMISSAO", "D")
	
	//Se tiver notas
	If ! QRY_XML->(EoF())
		
		//Pegando o total e definindo o tamanho da régua
		Count To nTotal
		ProcRegua(nTotal)
		QRY_XML->(DbGoTop())
		
		//Enquanto houver notas
		While ! QRY_XML->(EoF())
			
			//Incrementa a régua
			nAtual++
			IncProc("Gerando nota " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + " (dia " + dToC(QRY_XML->F2_EMISSAO) + ")...")
			
			//Chamando a função para gerar o xml e/ou o pdf
			u_zGerDanfe(QRY_XML->F2_DOC, QRY_XML->F2_SERIE, cDir, lXML, lPDF)
			
			QRY_XML->(DbSkip())
		EndDo
		
	Else
		MsgStop("Não existem notas no período informado!", "Atenção")
	EndIf
	QRY_XML->(DbCloseArea())
	
	RestArea(aArea)
Return
