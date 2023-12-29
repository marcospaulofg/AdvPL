//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
#Define PAD_JUSTIFY 3 //Opção disponível somente a partir da versão 1.6.2 da TOTVS Printer

/*/{Protheus.doc} XRELAT02
Relatório Frete Mundial por Nota com FWMSPrinter (linhas zebradas)
@author Marcos Gonçalves
@since 06/10/2023
@version 1.2
@type function
/*/
 
User Function XRELAT02()
    Local aArea  := FWGetArea()
    Local aPergs   := {}
    Local cCombo    := {"Alexandre de Goes", "Estrela de Davi", "LCP", "Vilmar Transporte"}
    Local cCombo2    := {"Antiga", "Nova"}
    Private lJob := IsBlind()
     
    //Se for execução automática, não mostra pergunta, executa direto
    If lJob
        Processa({|| fMontaRel()}, "Processando...")
         
    //Senão, se a pergunta for confirmada, executa o relatório
    Else
        //Adicionando os parametros do ParamBox
        AAdd(aPergs, {1, "Filial", Space(TamSX3("C5_FILIAL")[1]) ,,,,, 100, .T.})   // MV_PAR01
        AAdd(aPergs, {2, "Transportadora", cCombo[1], cCombo, 100,"", .T.})         // MV_PAR02
        AAdd(aPergs, {1, "Romaneio", Space(TamSX3("GW1_NRROM")[1]) ,,,,, 100, .T.}) // MV_PAR03
        AAdd(aPergs, {2, "Cotação", cCombo2[2], cCombo2, 100,"", .T.})              // MV_PAR04

        //Se a pergunta for confirma, cria as definicoes do relatorio
        If ParamBox(aPergs, "Informe os parâmetros", , , , , , , , , .T., .T.)
            //MV_PAR05 := Val(cValToChar(MV_PAR05))
            Processa({|| fMontaRel()}, "Processando...")
        EndIf
    EndIf
     
    FWRestArea(aArea)
Return
 
/*---------------------------------------------------------------------*
 | Func:  fMontaRel                                                    |
 | Desc:  Função que monta o relatório                                 |
 *---------------------------------------------------------------------*/
 
Static Function fMontaRel()
    Local cCaminho    := ""
    Local cArquivo    := ""
    Local lNegrito    := .T.
    Local lSublinhado := .T.
    Local lItalico    := .T.
    Local nRegAtu     := 0
    Local nRegTot     := 0
    Local cQryRel     := ""
    Local cFil        := MV_PAR01
    Local cTransp     := SUBSTR(Upper(MV_PAR02),1,TamSX3("A4_NREDUZ")[1])
    Local cRoman      := MV_PAR03
    Local cCot        := MV_PAR04
    Local nTotal      := 0
    //Linhas e colunas
    Private nLinAtu   := 000
    Private nTamLin   := 010
    Private nLinFin   := 820
    Private nColIni   := 010
    Private nColFin   := 550
    Private nColMeio  := (nColFin-nColIni)/2
    Private nEspLin   := 015
    //Colunas dos campos
    Private nColCli := nColIni
    Private nColEmi := nColIni + 080
    Private nColDoc := nColIni + 080 + 080
    Private nColFre := nColFin - 080
    //Variáveis auxiliares
    Private dDataGer  := Date()
    Private cHoraGer  := Time()
    Private nPagAtu   := 1
    //Cores usadas
    Private nCorFraca := RGB(198, 239, 206)
    Private nCorForte := RGB(003, 101, 002)
    Private nCorCinza := RGB(150, 150, 150)
    Private nCorVerme := RGB(255, 000, 000)
    Private oBrush    := TBrush():New(, nCorFraca)
    //Objetos de impressão e fonte
    Private oPrintPvt
    Private cNomeFont  := "Arial"
    Private oFontCabN  := TFont():New(cNomeFont, /*uPar2*/, -15, /*uPar4*/,   lNegrito, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, ! lSublinhado, ! lItalico)
    Private oFontDet   := TFont():New(cNomeFont, /*uPar2*/, -11, /*uPar4*/, ! lNegrito, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, ! lSublinhado, ! lItalico)
    Private oFontDetN  := TFont():New(cNomeFont, /*uPar2*/, -13, /*uPar4*/,   lNegrito, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, ! lSublinhado, ! lItalico)
    Private oFontDetI  := TFont():New(cNomeFont, /*uPar2*/, -11, /*uPar4*/, ! lNegrito, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, ! lSublinhado,   lItalico)
    Private oFontMin   := TFont():New(cNomeFont, /*uPar2*/, -09, /*uPar4*/, ! lNegrito, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, ! lSublinhado, ! lItalico)
    Private oFontRod   := TFont():New(cNomeFont, /*uPar2*/, -08, /*uPar4*/, ! lNegrito, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, ! lSublinhado, ! lItalico)
     
    //Montando consulta de dados
    cQryRel := "SELECT " + CRLF
    cQryRel += "CLIENTE, " + CRLF
    cQryRel += "EMISSAO, " + CRLF
    cQryRel += "DOCUMENTO, " + CRLF
    cQryRel += "SUM(FRETE*QUANTIDADE) AS FRETETOTAL " + CRLF
    cQryRel += "FROM " + CRLF
    cQryRel += "(SELECT " + CRLF
    cQryRel += "F2_DOC AS DOCUMENTO, " + CRLF
    cQryRel += "F2_EMISSAO AS EMISSAO, " + CRLF
    cQryRel += "A1_NREDUZ AS CLIENTE, " + CRLF
    cQryRel += "D2_QUANT AS QUANTIDADE, " + CRLF
    cQryRel += "CASE WHEN B1_DESC IN ( " + CRLF
    cQryRel += "    'ABOBORA BATA / CX 15KG        ', " + CRLF
    cQryRel += "    'ABOBRINHA ITALIANA / CX 15KG  ', " + CRLF
    cQryRel += "    'AIPIM PARAFINADO / 20KG       ', " + CRLF
    cQryRel += "    'BATATA BAROA / CX 10KG        ', " + CRLF
    cQryRel += "    'BATATA DOCE / CX 20KG         ', " + CRLF
    cQryRel += "    'BERINJELA / CX 10KG           ', " + CRLF
    cQryRel += "    'BETERRABA / CX 20KG           ', " + CRLF
    cQryRel += "    'CENOURA / CX 20KG             ', " + CRLF
    cQryRel += "    'CHUCHU / CX 20KG              ', " + CRLF
    cQryRel += "    'GENGIBRE / CX 10KG            ', " + CRLF
    cQryRel += "    'INHAME / CX 20KG              ', " + CRLF
    cQryRel += "    'JILO / CX 15KG                ', " + CRLF
    cQryRel += "    'PEPINO / CX 20KG              ', " + CRLF
    cQryRel += "    'PIMENTAO VERDE / CX 10KG      ', " + CRLF
    cQryRel += "    'TOMATE / CX 20KG              ', " + CRLF
    cQryRel += "    'TOMATE ITALIANO / CX 20KG     ', " + CRLF
    cQryRel += "    'VAGEM MACARRAO / CX 13KG      ', " + CRLF
    cQryRel += "    'VAGEM MANTEIGA / CX 13KG      ') THEN "+IIF(cCot=="Antiga", '3.75', '3.94')+" " + CRLF
    cQryRel += "WHEN B1_DESC IN ( " + CRLF
    cQryRel += "    'MORANGO / BD                  ') THEN "+IIF(cCot=="Antiga", '0.345', '0.355')+" " + CRLF
    cQryRel += "WHEN B1_DESC IN ( " + CRLF
    cQryRel += "    'ABOBRINHA EMBALADA / BD       ', " + CRLF
    cQryRel += "    'BATATA BAROA EMBALADA / BD    ', " + CRLF
    cQryRel += "    'BATATA DOCE EMBALADA / BD     ', " + CRLF
    cQryRel += "    'BATATA YAKON / BD             ', " + CRLF
    cQryRel += "    'BERINJELA EMBALADA / BD       ', " + CRLF
    cQryRel += "    'BETERRABA EMBALADA / BD       ', " + CRLF
    cQryRel += "    'CENOURA EMBALADO / BD         ', " + CRLF
    cQryRel += "    'CHUCHU EMBALADO / BD          ', " + CRLF
    cQryRel += "    'ERVILHA EMBALADA / BD         ', " + CRLF
    cQryRel += "    'GENGIBRE EMBALADO / BD        ', " + CRLF
    cQryRel += "    'INHAME EMBALADO / BD          ', " + CRLF
    cQryRel += "    'JILO EMBALADO / BD            ', " + CRLF
    cQryRel += "    'MAXIXE EMBALADO / BD          ', " + CRLF
    cQryRel += "    'NABO EMBALADO / BD            ', " + CRLF
    cQryRel += "    'PEPINO COMUM EMBALADO / BD    ', " + CRLF
    cQryRel += "    'PEPINO JAPONES EMBALADO / BD  ', " + CRLF
    cQryRel += "    'PIMENTA CAMBUCI / BD          ', " + CRLF
    cQryRel += "    'PIMENTA DE CHEIRO / BD        ', " + CRLF
    cQryRel += "    'PIMENTA DEDO DE MOCA / BD     ', " + CRLF
    cQryRel += "    'PIMENTA MALAGUETA / BD        ', " + CRLF
    cQryRel += "    'PIMENTAO AMARELO EMBALADO / BD', " + CRLF
    cQryRel += "    'PIMENTAO VERDE EMBALADO / BD  ', " + CRLF
    cQryRel += "    'PIMENTAO VERMELHO EMBALADO/ BD', " + CRLF
    cQryRel += "    'TOMATE EMBALADO / BD          ', " + CRLF
    cQryRel += "    'TOMATE ITALIANO EMBALADO / BD ', " + CRLF
    cQryRel += "    'TOMATE RED GRAPE / BD         ', " + CRLF
    cQryRel += "    'VAGEM FRANCESA - BDJ 200GR    ', " + CRLF
    cQryRel += "    'VAGEM FRANCESA EMBALADA  / BD ', " + CRLF
    cQryRel += "    'VAGEM MACARRAO EMBALADA / BD  ', " + CRLF
    cQryRel += "    'VAGEM MANTEIGA EMBALADA / BD  ') THEN "+IIF(cCot=="Antiga", '0.3', '0.37')+" " + CRLF
    cQryRel += "WHEN B1_DESC IN ( " + CRLF
    cQryRel += "    'ABACAXI / CX 10UN             ') THEN "+IIF(cCot=="Antiga", '6', '6.3')+" " + CRLF
    cQryRel += "WHEN B1_DESC IN ( " + CRLF
    cQryRel += "    'MANGA PALMER - CXT 6KG        ', " + CRLF
    cQryRel += "    'MANGA TOMMY - CXT 6KG         ') THEN "+IIF(cCot=="Antiga", '2.55', '2.69')+" " + CRLF
    cQryRel += "WHEN B1_DESC IN ( " + CRLF
    cQryRel += "    'PIMENTAO AMARELO / CX 5KG     ', " + CRLF
    cQryRel += "    'PIMENTAO VERDE / CX 5KG       ', " + CRLF
    cQryRel += "    'PIMENTAO VERMELHO / CX 5KG    ') THEN "+IIF(cCot=="Antiga", '1.87', '1.97')+" " + CRLF
    cQryRel += "WHEN B1_DESC IN ( " + CRLF
    cQryRel += "    'QUIABO EMBALADO / KG          ') THEN "+IIF(cCot=="Antiga", '0.6', '0.74')+" " + CRLF
    cQryRel += "WHEN B1_DESC IN ( " + CRLF
    cQryRel += "    'BANANA TERRA / CX 15KG        ') THEN "+IIF(cCot=="Antiga", '3.4', '3.57')+" " + CRLF
    cQryRel += "WHEN B1_DESC IN (    " + CRLF
    cQryRel += "    'MELAO AMARELO / CX 13KG       ') THEN "+IIF(cCot=="Antiga", '3.45', '3.62')+" " + CRLF
    cQryRel += "WHEN B1_DESC IN (    " + CRLF
    cQryRel += "    'PESSEGO NACIONAL / CX 06KG    ') THEN "+IIF(cCot=="Antiga", '2.69', '2.55')+" " + CRLF
    cQryRel += "ELSE 0 END AS FRETE " + CRLF
    cQryRel += " " + CRLF
    cQryRel += "FROM " + CRLF
    cQryRel += ""+RetSQLName("SF2")+" SF2 " + CRLF
    cQryRel += "LEFT JOIN "+RetSQLName("SD2")+" SD2 ON (SF2.F2_DOC = SD2.D2_DOC) " + CRLF
    cQryRel += "LEFT JOIN "+RetSQLName("SA1")+" SA1 ON (SF2.F2_CLIENTE = SA1.A1_COD AND SF2.F2_LOJA = SA1.A1_LOJA) " + CRLF
    cQryRel += "LEFT JOIN "+RetSQLName("SB1")+" SB1 ON (SD2.D2_COD = SB1.B1_COD) " + CRLF
    cQryRel += "LEFT JOIN "+RetSQLName("SA4")+" SA4 ON (SF2.F2_TRANSP = SA4.A4_COD) " + CRLF
    cQryRel += "LEFT JOIN "+RetSQLName("GW1")+" GW1 ON (SF2.F2_DOC = GW1.GW1_NRDC) " + CRLF
    cQryRel += " " + CRLF
    cQryRel += "WHERE " + CRLF
    cQryRel += "SF2.D_E_L_E_T_ = ' ' AND SD2.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' AND SA4.D_E_L_E_T_ = ' ' AND GW1.D_E_L_E_T_ = ' ' " + CRLF
    cQryRel += "AND F2_CLIENTE = 'MUND' " + CRLF
    cQryRel += "AND D2_TES IN (501, 508, 509) " + CRLF
    cQryRel += "AND F2_FILIAL = '"+cFil+"' " + CRLF
    cQryRel += "AND GW1_NRROM = '"+cRoman+"' " + CRLF
    cQryRel += "AND A4_NREDUZ = '"+cTransp+"' ) AS TB " + CRLF
    cQryRel += " " + CRLF
    cQryRel += "GROUP BY " + CRLF
    cQryRel += "CLIENTE, EMISSAO, DOCUMENTO " + CRLF

    //Executando consulta e setando o total da regua
    PlsQuery(cQryRel, "QRY_REL")
    DbSelectArea("QRY_REL")
    Count To nRegTot
    ProcRegua(nRegTot)
    QRY_REL->(DbGoTop())

    //Somente se tiver dados
    If ! QRY_REL->(EoF())
        //Se for via JOB, muda as parametrizações
        If lJob
            //Define o caminho dentro da protheus data e o nome do arquivo
            cCaminho := "\x_relatorios\"
            cArquivo := "XRELAT02_job_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-') + ".pdf"
            
            //Se não existir a pasta na Protheus Data, cria ela
            If ! ExistDir(cCaminho)
                MakeDir(cCaminho)
            EndIf
            
            //Cria o objeto FWMSPrinter
            oPrintPvt := FWMSPrinter():New(;
                cArquivo,; // cFilePrinter
                IMP_PDF,;  // nDevice
                .F.,;      // lAdjustToLegacy
                '',;       // cPathInServer
                .T.,;      // lDisabeSetup
                .F.,;      // lTReport
                ,;         // oPrintSetup
                ,;         // cPrinter
                .T.,;      // lServer
                .T.,;      // lParam10
                ,;         // lRaw
                .F.;       // lViewPDF
            )
            oPrintPvt:cPathPDF := cCaminho
            
        Else
            //Definindo o diretório como a temporária do S.O. e o nome do arquivo com a data e hora (sem dois pontos)
            cCaminho  := GetTempPath()
            cArquivo  := "FRETE_MUNDIAL_" +LEFT(DToS(Date()),4)+"-"+SUBSTR(DToS(Date()),5,2) +"-"+RIGHT(DToS(Date()),2) +"_" + StrTran(Time(),":","")
            //Criando o objeto do FMSPrinter
            oPrintPvt := FWMSPrinter():New(;
                cArquivo,; // cFilePrinter
                IMP_PDF,;  // nDevice
                .F.,;      // lAdjustToLegacy
                "",;       // cPathInServer
                .T.,;      // lDisabeSetup
                ,;         // lTReport
                ,;         // oPrintSetup
                "",;       // cPrinter
                ,;         // lServer
                ,;         // lParam10
                ,;         // lRaw
                .T.;       // lViewPDF
            )
            oPrintPvt:cPathPDF := cCaminho
        EndIf
        
        //Setando os atributos necessários do relatório
        oPrintPvt:SetResolution(72)
        oPrintPvt:SetPortrait()
        oPrintPvt:SetPaperSize(DMPAPER_A4)
        oPrintPvt:SetMargin(60, 60, 60, 60)

        //Imprime o primeiro cabeçalho
        fImpCab()

        //Percorre os registros da tabela
        While ! QRY_REL->(EoF())
            //Incrementa a régua
            nRegAtu++
            IncProc("Imprimindo registro " + cValToChar(nRegAtu) + " de " + cValToChar(nRegTot) + " [" + cValToChar(Round(100*nRegAtu/nRegTot,2)) + "%]...")
            
            //Verifica a quebra de página
            fQuebra()

            //Se for par, irá pintar o fundo da linha
            If nRegAtu % 2 == 0
                oPrintPvt:FillRect({nLinAtu - 2, nColIni+1, nLinAtu + nEspLin - 3, nColFin - 1}, oBrush)
            EndIf

            //Soma tudo
            nTotal += QRY_REL->FRETETOTAL

            //Aciona a impressão dos dados
            oPrintPvt:SayAlign(nLinAtu, nColCli, Alltrim(QRY_REL->CLIENTE),          oFontDet,  080,    10, , PAD_LEFT,   )
            oPrintPvt:SayAlign(nLinAtu, nColEmi, DTOC(SToD(QRY_REL->EMISSAO)),    oFontDet,  080,    10, , PAD_LEFT,   )
            oPrintPvt:SayAlign(nLinAtu, nColDoc, Alltrim(QRY_REL->DOCUMENTO),        oFontDet,  080,    10, , PAD_LEFT,   )
            oPrintPvt:SayAlign(nLinAtu, nColFre, "R$ "+ALLTRIM(TRANSFORM(QRY_REL->FRETETOTAL,"@E 999,999,999.99")),oFontDet,  080,    10, , PAD_RIGHT,   )
            nLinAtu += nEspLin

            //Faz uma linha de separação
            oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin, nCorCinza)

            QRY_REL->(DbSkip())
        EndDo
        //Imprime a soma
        oPrintPvt:SayAlign(nLinAtu, nColFre, "R$ "+ALLTRIM(TRANSFORM(nTotal,"@E 999,999,999.99"))  ,oFontDetN,  080,    10, nCorForte, PAD_RIGHT,   )
        oPrintPvt:SayAlign(nLinAtu, nColDoc + 200, "Frete total:"  ,oFontDetN,  060,    10, nCorForte, PAD_LEFT,   )

        //Imprime a soma com 5%
        oPrintPvt:SayAlign(nLinAtu+nEspLin, nColFre, "R$ "+ALLTRIM(TRANSFORM(nTotal/0.95,"@E 999,999,999.99"))  ,oFontDetN,  080,    10, nCorVerme, PAD_RIGHT,   )
        oPrintPvt:SayAlign(nLinAtu+nEspLin, nColDoc + 200, "Frete total com 5%:"  ,oFontDetN,  100,    10, nCorVerme, PAD_LEFT,   )

        //Verifica a quebra de página
        fQuebra()

        //Encerra a última página
        fImpRod()
        
        //Se for via job, imprime o arquivo para gerar corretamente o pdf
        If lJob
            oPrintPvt:Print()

        //Se for via manual, mostra o relatório
        Else
            oPrintPvt:Preview()
        EndIf
    Else
        If ! lJob
            FWAlertError("Não foram encontrados dados com os filtros informados", "Falha")
        EndIf
    EndIf
    QRY_REL->(DbCloseArea())
Return

/*---------------------------------------------------------------------*
 | Func:  fImpCab                                                      |
 | Desc:  Função que imprime o cabeçalho                               |
 *---------------------------------------------------------------------*/

Static Function fImpCab()
    nLinAtu   := 40

    //Inicializa a página
    oPrintPvt:StartPage()

    //Somente se for na primeira página
    If nPagAtu == 1
        //Impressão do box e das linhas
        nFimQuadr := nLinAtu + ((nEspLin*6) + 5)
        oPrintPvt:Box(nLinAtu, nColIni, nFimQuadr, nColFin)
        oPrintPvt:FillRect({nLinAtu + 1, nColIni+1, nLinAtu + nEspLin - 1, nColFin - 1}, oBrush)
        oPrintPvt:Line(nLinAtu + nEspLin,           nColIni,       nLinAtu + nEspLin,           nColFin,                ) //Linha separando o título dos dados
        oPrintPvt:Line(nLinAtu + nEspLin,           nColIni + 195, nFimQuadr,                   nColIni + 195,          ) //Coluna entre Logo e Textos
        oPrintPvt:Line(nLinAtu + nEspLin,           nColFin - 085, nFimQuadr,                   nColFin - 085,          ) //Coluna entre Textos e QRCode
        oPrintPvt:Line(nLinAtu + (nEspLin * 2) + 2, nColIni + 200, nLinAtu + (nEspLin * 2) + 2, nColIni + 360, nCorFraca) //Linha abaixo do texto principal

        //Impressão do quadro de dados

        If SUBSTR(Upper(MV_PAR02),1,TamSX3("A4_NREDUZ")[1]) == "ALEXANDRE DE GO"
            oPrintPvt:SayAlign(nLinAtu, nColIni + 005 , "Frete Mundial - Alexandre de Goes",                            oFontDetN,  200,    015, nCorForte, PAD_CENTER,  )
        Elseif SUBSTR(Upper(MV_PAR02),1,TamSX3("A4_NREDUZ")[1]) == "ESTRELA DE DAVI"
            oPrintPvt:SayAlign(nLinAtu, nColIni + 005 , "Frete Mundial - Estrela de Davi",                            oFontDetN,  200,    015, nCorForte, PAD_CENTER,  )
        Elseif SUBSTR(Upper(MV_PAR02),1,TamSX3("A4_NREDUZ")[1]) == "LCP"
            oPrintPvt:SayAlign(nLinAtu, nColIni + 005 , "Frete Mundial - LCP",                            oFontDetN,  200,    015, nCorForte, PAD_CENTER,  )
        Elseif SUBSTR(Upper(MV_PAR02),1,TamSX3("A4_NREDUZ")[1]) == "VILMAR TRANSPOR"
            oPrintPvt:SayAlign(nLinAtu, nColIni + 005 , "Frete Mundial - Vilmar Transporte",                            oFontDetN,  200,    015, nCorForte, PAD_CENTER,  )
        Else
            oPrintPvt:SayAlign(nLinAtu, nColIni + 005 , "Dados:",                            oFontDetN,  200,    015, nCorForte, PAD_LEFT,  )
        Endif
        nLinAtu += nEspLin

        //Imprimindo o logo
        If xFilial("SF2") == "0102"
            cLogoRel := "\logos\logocd.bmp"
            oPrintPvt:SayBitmap(nLinAtu + 5, nColIni + 5, cLogoRel, 185, 070) // 100 é a metade de 200, - 35 que é a metade da largura, dá 065
        Else
            cLogoRel := "\logos\logomatriz.bmp"
            oPrintPvt:SayBitmap(nLinAtu + 15, nColIni + 5, cLogoRel, 185, 050) // 100 é a metade de 200, - 35 que é a metade da largura, dá 065
        Endif

        //Imprimindo o QRCode
        cUrlSite := "https://linktr.ee/nipobrasileiraoficial/"
        oPrintPvt:QRCode(nLinAtu + 70, nColFin - 73, cUrlSite, 65)

        //Impressão de informações internas
        oPrintPvt:SayAlign(nLinAtu, nColIni + 200, "Nipo Brasileira Frutas e Legumes LTDA",            oFontCabN,  300,    015, nCorForte, PAD_LEFT,  )
        nLinAtu += nEspLin + 5

        oPrintPvt:SayAlign(nLinAtu, nColIni + 200, "Site:",                             oFontDetN,  200,    015, , PAD_LEFT,  )
        oPrintPvt:SayAlign(nLinAtu, nColIni + 270, "https://www.nipobra.com.br/",  oFontDet,   200,    015, , PAD_LEFT,  )
        nLinAtu += nEspLin

        oPrintPvt:SayAlign(nLinAtu, nColIni + 200, "e-mail:",                           oFontDetN,  200,    015, , PAD_LEFT,  )
        oPrintPvt:SayAlign(nLinAtu, nColIni + 270, "cd@nipobra.com.br",  oFontDet,   200,    015, , PAD_LEFT,  )
        nLinAtu += nEspLin

        oPrintPvt:SayAlign(nLinAtu, nColIni + 200, "WhatsApp:",                         oFontDetN,  200,    015, , PAD_LEFT,  )
        oPrintPvt:SayAlign(nLinAtu, nColIni + 270, "(21) 97046-2203",                  oFontDet,   200,    015, , PAD_LEFT,  )
        nLinAtu += nEspLin

        oPrintPvt:SayAlign(nLinAtu, nColIni + 200, "Instagram:",                         oFontDetN,  200,    015, , PAD_LEFT,  )
        oPrintPvt:SayAlign(nLinAtu, nColIni + 270, "@nipobrasileiraoficial",   oFontDetI,  200,    015, , PAD_LEFT,  )
        nLinAtu += nEspLin

        //Imprime textos laterais com o método Say
        cTextoAux := FunName()+" (Relatório de Frete)     "+cUserName
        oPrintPvt:Say(040,     nColIni - 15, "Esq.: " + cTextoAux, oFontMin, , nCorForte, 90)
        oPrintPvt:Say(nLinFin, nColFin + 15, "Dir.: " + cTextoAux, oFontMin, , nCorForte, 270)
    EndIf
    
    nLinAtu += 010
    oPrintPvt:SayAlign(nLinAtu+05, nColCli, "Cliente",       oFontMin,  080,    10, nCorCinza, PAD_LEFT,   )
    oPrintPvt:SayAlign(nLinAtu+05, nColEmi, "Emissão",       oFontMin,  080,    10, nCorCinza, PAD_LEFT,   )
    oPrintPvt:SayAlign(nLinAtu+05, nColDoc, "Documento",     oFontMin,  080,    10, nCorCinza, PAD_LEFT,   )
    oPrintPvt:SayAlign(nLinAtu+05, nColFre, "Frete total",   oFontMin,  080,    10, nCorCinza, PAD_RIGHT,   )
    
    //Linha Separatória
    nLinAtu += 020
    oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, )
    nLinAtu += 005
Return

/*---------------------------------------------------------------------*
 | Func:  fImpRod                                                      |
 | Desc:  Função que imprime o rodapé                                  |
 *---------------------------------------------------------------------*/

Static Function fImpRod()
    Local nLinRod:= nLinFin + 10
    Local cTexto := ''

    //Linha Separatória
    oPrintPvt:Line(nLinRod,   nColIni, nLinRod,   nColFin, nCorFraca)
    nLinRod += 5
    
    //Dados da Esquerda
    cTexto := dToC(dDataGer)+"     "+cHoraGer
    oPrintPvt:SayAlign(nLinRod, nColIni, cTexto, oFontRod, 400, 10, nCorForte, PAD_LEFT, )
    
    //Direita
    cTexto := "Página "+cValToChar(nPagAtu)
    oPrintPvt:SayAlign(nLinRod, nColFin-40, cTexto, oFontRod, 040, 10, nCorForte, PAD_RIGHT, )
    
    //Finalizando a página e somando mais um
    oPrintPvt:EndPage()
    nPagAtu++
Return

/*---------------------------------------------------------------------*
 | Func:  fQuebra                                                      |
 | Desc:  Função que faz a lógica da quebra de página                  |
 *---------------------------------------------------------------------*/

Static Function fQuebra()
    //Se atingiu o limite, quebra de página
    If nLinAtu >= nLinFin-5
        fImpRod()
        fImpCab()
    EndIf
Return
