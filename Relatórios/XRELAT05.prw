//Bibliotecas
#Include "TopConn.ch"
#Include "Protheus.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
 
//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
#Define PAD_JUSTIFY 3 //Opção disponível somente a partir da versão 1.6.2 da TOTVS Printer
 
/*/{Protheus.doc} RelatRecibo
Relatório de recibo de transferência bancária em FWMSPrinter
@author Marcos Gonçalves
@since 10/10/2023
@version 1.0
@type function
@see https://tdn.totvs.com/display/public/PROT/FWMsPrinter
/*/
 
User Function XRELAT05()
    Local aArea    := FWGetArea()
    Local aPergs   := {}
    //Adicionando os parametros do ParamBox
    AAdd(aPergs, {1, "Filial", Space(TamSX3("E2_FILIAL")[1]) ,,,,, 60, .T.})   // MV_PAR01
    AAdd(aPergs, {1, "Nº do documento", Space(TamSX3("E2_NUM")[1]) ,,,,, 60, .T.})   // MV_PAR02
    AAdd(aPergs, {1, "Fornecedor", Space(TamSX3("E2_FORNECE")[1]) ,"@!","ExistCpo('SA2', MV_PAR03)","SA2",, 60, .T.})   // MV_PAR03
    AAdd(aPergs, {1, "Loja", Space(TamSX3("E2_LOJA")[1]) ,,"ExistCpo('SA2', MV_PAR03 + MV_PAR04)","SA2",, 60, .T.})   // MV_PAR04
    AAdd(aPergs, {1, "Parcela", Space(TamSX3("E2_PARCELA")[1]) ,,,,, 60, .F.})    // MV_PAR05

    //Se a pergunta for confirma, cria as definicoes do relatorio
    If ParamBox(aPergs, "Informe os parâmetros", , , , , , , , , .T., .T.)
        Processa({|| fMontaRel()}, "Processando...")
    EndIf

    FWRestArea(aArea)
Return

Static Function fMontaRel()
    Local cArquivo      := "RECIBOTF_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".pdf"
    Local cTexto        := ""
    Local cTexto2       := ""
    Local cTexto3       := ""
    Local cTextoa       := ""
    Local cTextob       := ""
    Local cTextoc       := ""
    Local cTipCon       := ""
    Local cCab          := ""
//    Local dDataAtual    := dDataBase
    Local cQryRel       := ""
    Local cFil          := MV_PAR01
    Local cDoc          := MV_PAR02
    Local cForn         := MV_PAR03
    Local cLoja         := MV_PAR04
    Local cParc         := MV_PAR05
    Local nFunrural     := 0
    Local nRegAtu       := 0
    Local nRegTot       := 0    
    //Linhas e colunas
    Private nLinAtu     := 0
    Private nLinFin     := 800
    Private nColIni     := 030
    Private nColFin     := 580
    Private nEspCol     := (nColFin-(nColIni+150))/13
    Private nColMeio    := (nColFin-nColIni)/2
    //Objetos de impressão e fonte
    Private oPrintPvt
    Private cNomeFont   := "Arial"
    Private oFontDet    := TFont():New(cNomeFont, 9, -14, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontDetN   := TFont():New(cNomeFont, 9, -27, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontDet12  := TFont():New(cNomeFont, 9, -12, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontDetS   := TFont():New(cNomeFont, 9, -12, .T., .F., 5, .T., 5, .F., .T.)


    //Montando consulta de dados
    cQryRel += "SELECT " + CRLF
    cQryRel += "E2_NUM, E2_FORNECE, E2_NOMFOR, E2_VALOR, E2_SALDO, E2_HIST, E2_VENCTO, " + CRLF
    cQryRel += "E2_FORBCO, E2_FORAGE, E2_FAGEDV, E2_FORCTA, E2_FCTADV, " + CRLF
    cQryRel += "A2_CGC, A2_XTIPCON, " + CRLF
    cQryRel += "D1_COD, D1_VALINS, D1_VLSENAR, D1_VALFUN, " + CRLF
    cQryRel += "B1_DESC, " + CRLF
    cQryRel += "F1_DOC, F1_SERIE, F1_DTDIGIT, F1_VALBRUT " + CRLF
    cQryRel += " " + CRLF
    cQryRel += "FROM " + CRLF
    cQryRel += ""+RetSQLName("SE2")+" " + CRLF
    cQryRel += "LEFT JOIN "+RetSQLName("SA2")+" ON (E2_FORNECE = A2_COD) " + CRLF
    cQryRel += "LEFT JOIN "+RetSQLName("SD1")+" ON (E2_NUM = D1_DOC AND E2_FORNECE = D1_FORNECE AND E2_LOJA = D1_LOJA) " + CRLF
    cQryRel += "LEFT JOIN "+RetSQLName("SB1")+" ON (D1_COD = B1_COD) " + CRLF
    cQryRel += "LEFT JOIN "+RetSQLName("SF1")+" ON (E2_NUM = F1_DOC AND E2_FORNECE = F1_FORNECE AND E2_LOJA = F1_LOJA) " + CRLF
    cQryRel += " " + CRLF
    cQryRel += "WHERE " + CRLF
    cQryRel += "E2_NUM = '"+cDoc+"' " + CRLF
    cQryRel += "AND E2_FORNECE = '"+cForn+"' " + CRLF
    cQryRel += "AND E2_LOJA = '"+cLoja+"' " + CRLF
    cQryRel += "AND E2_FILIAL = '"+cFil+"' " + CRLF
    cQryRel += "AND E2_PARCELA = '"+cParc+"' " + CRLF
    cQryRel += "AND SE2010.D_E_L_E_T_ = ' ' AND SA2010.D_E_L_E_T_ = ' ' AND SD1010.D_E_L_E_T_ = ' ' AND SB1010.D_E_L_E_T_ = ' ' AND SF1010.D_E_L_E_T_ = ' ' " + CRLF
    

    //Executando consulta e setando o total da regua
    PlsQuery(cQryRel, "QRY_REL")
    DbSelectArea("QRY_REL")
    Count To nRegTot
    ProcRegua(nRegTot)
    QRY_REL->(DbGoTop())

    //Somente se tiver dados
    If ! QRY_REL->(EoF())
    
        //Criando o objeto de impressao
        oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., ,   .T., ,    @oPrintPvt, ,   ,    , ,.T.)
        oPrintPvt:cPathPDF := GetTempPath()
        oPrintPvt:SetResolution(72)
        oPrintPvt:SetPortrait()
        oPrintPvt:SetPaperSize(DMPAPER_A4)
        oPrintPvt:SetMargin(0, 0, 0, 0)
        oPrintPvt:StartPage()
        //oPrintPvt:Box(15,15,390,565)
        oPrintPvt:Box(140,15,225,565)
        oPrintPvt:Line(340, 15, 340, 565,)
        
    Else
        FWAlertError("Não foram encontrados dados com os filtros informados", "Falha")
    Endif

    //Cria o cabeçalho
    cCab += "Recibo Nº " + cValToChar(Year(QRY_REL->E2_VENCTO)) + cValToChar(Month(QRY_REL->E2_VENCTO)) + cValToChar(Day(QRY_REL->E2_VENCTO)) + Alltrim(QRY_REL->E2_NUM) + "        Ordem de Pagto.: " + cValToChar(Year(QRY_REL->E2_VENCTO)) + cValToChar(Month(QRY_REL->E2_VENCTO)) + cValToChar(Day(QRY_REL->E2_VENCTO)) + Alltrim(QRY_REL->E2_NUM) + "      Data de Pagto.: " + DtoC(QRY_REL->E2_VENCTO)

    //Cria o texto1
    cTexto += "Eu, " + Alltrim(QRY_REL->E2_NOMFOR) + ", inscrito no CPF/CNPJ sob número " + IIF(LEN(Alltrim(QRY_REL->A2_CGC))==11, ALLTRIM(TRANSFORM(QRY_REL->A2_CGC,"@R 999.999.999-99")), ALLTRIM(TRANSFORM(QRY_REL->A2_CGC,"@R 99.999.999/9999-99"))) + ", confirmo que recebi da NIPO BRASILEIRA FRUTAS E LEGUMES LTDA a importância de R$ " + Alltrim(Transform(QRY_REL->E2_VALOR - QRY_REL->E2_SALDO,"@E 999,999,999.99")) + " (" + Alltrim(Lower(Extenso(QRY_REL->E2_VALOR - QRY_REL->E2_SALDO,.F.,1,,"1",.T.,.F.))) + ") referente a NF " + Alltrim(QRY_REL->E2_NUM) + " via transferência bancária."

    //Cria o textoa
    cTextoa += "Total da NF: R$ " + Alltrim(Transform(QRY_REL->F1_VALBRUT,"@E 999,999,999.99")) + "        Desconto comercial: R$ " + Alltrim(Transform(QRY_REL->F1_VALBRUT - QRY_REL->E2_VALOR,"@E 999,999,999.99")) + "        Total pago: R$ " + Alltrim(Transform(QRY_REL->E2_VALOR - QRY_REL->E2_SALDO,"@E 999,999,999.99"))

    //Cria o texto2
    //cTexto2 += "Rio de Janeiro, " + cValToChar(Day(dDataAtual)) + " de " + MesExtenso(dDataAtual) + " de " + cValToChar(Year(dDataAtual))
    cTexto2 += "Nº do cheque: " + CRLF
    cTexto2 += " " + CRLF
    cTexto2 += "______/______/____________"

    //Cria o texto3
    cTexto3 += "Ass.: _____________________________________"

    //Cria o textob
    cTextob += "Recibo Nº " + cValToChar(Year(QRY_REL->E2_VENCTO)) + cValToChar(Month(QRY_REL->E2_VENCTO)) + cValToChar(Day(QRY_REL->E2_VENCTO)) + Alltrim(QRY_REL->E2_NUM) + "        Ordem de Pagto.: " + cValToChar(Year(QRY_REL->E2_VENCTO)) + cValToChar(Month(QRY_REL->E2_VENCTO)) + cValToChar(Day(QRY_REL->E2_VENCTO)) + Alltrim(QRY_REL->E2_NUM) + "      Data de Pagto.: " + DtoC(QRY_REL->E2_VENCTO) + CRLF
    cTextob += QRY_REL->E2_FORNECE + "      " + QRY_REL->E2_NOMFOR + CRLF
    cTextob += "Banco: " + QRY_REL->E2_FORBCO + "     Agencia: " + Alltrim(QRY_REL->E2_FORAGE)  + "-" + QRY_REL->E2_FAGEDV + "       Conta: " + Alltrim(QRY_REL->E2_FORCTA) + "-" + QRY_REL->E2_FCTADV + CRLF

    //Imprimindo o logo
    cLogoRel := "\logos\logomatriz.bmp"
    nLinAtu := 30
    oPrintPvt:SayBitmap(nLinAtu, nColIni, cLogoRel, 185, 050) 

    //Agora iremos imprimir o texto com alinhamento justificado
    nLinAtu := 100
    oPrintPvt:SayAlign(nLinAtu, nColIni, cCab, oFontDet,   (nColFin - nColIni - 030),    300, , PAD_CENTER,  )
    nLinAtu := 150
    oPrintPvt:SayAlign(nLinAtu, nColIni, cTexto, oFontDet,   (nColFin - nColIni - 030),    300, , PAD_JUSTIFY,  )
    nLinAtu := 270
    oPrintPvt:SayAlign(nLinAtu, nColIni, cTexto2, oFontDet,   (nColFin - nColIni - 030),    300, , PAD_LEFT,  )
    nLinAtu := 300
    oPrintPvt:SayAlign(nLinAtu, nColIni, cTexto3, oFontDet,   (nColFin - nColIni - 030),    300, , PAD_RIGHT,  )
    nLinAtu := 230
    oPrintPvt:SayAlign(nLinAtu, nColIni, cTextoa, oFontDet,   (nColFin - nColIni - 030),    300, , PAD_CENTER,  )
    nLinAtu := 360
    oPrintPvt:SayAlign(nLinAtu, nColIni, cTextob, oFontDet12,   (nColFin - nColIni - 030),    300, , PAD_LEFT,  )

    //Imprime o cabeçalho da query
    nLinAtu := 408
    oPrintPvt:SayAlign(nLinAtu, nColIni, "Entrada", oFontDetS,   (nColFin - nColIni - 030),    300, , PAD_LEFT,  )
    oPrintPvt:SayAlign(nLinAtu, nColIni+100, "Data", oFontDetS,   (nColFin - nColIni - 030),    300, , PAD_LEFT,  )
    oPrintPvt:SayAlign(nLinAtu, nColIni+200, "Produto", oFontDetS,   (nColFin - nColIni - 030),    300, , PAD_LEFT,  )
    oPrintPvt:SayAlign(nLinAtu, nColIni, "Valor", oFontDetS,   (nColFin - nColIni - 030),    300, , PAD_RIGHT,  )
    nLinAtu := 420
    
    //Grava valores em variáveis para serem usados após terminar os registros da query
    cTipCon  += QRY_REL->A2_XTIPCON

    //Imprime a primeira linha da query sem o nome do produto
    oPrintPvt:SayAlign(nLinAtu, nColIni, QRY_REL->F1_SERIE + " " + QRY_REL->F1_DOC, oFontDet12,   (nColFin - nColIni - 030),    300, , PAD_LEFT,  )
    oPrintPvt:SayAlign(nLinAtu, nColIni+100, DtoC(QRY_REL->F1_DTDIGIT), oFontDet12,   (nColFin - nColIni - 030),    300, , PAD_LEFT,  )
    oPrintPvt:SayAlign(nLinAtu, nColIni, "R$ " + Alltrim(Transform(QRY_REL->F1_VALBRUT,"@E 999,999,999.99")), oFontDet12,   (nColFin - nColIni - 030),    300, , PAD_RIGHT,  )
        
    //Percorre os registros da tabela para imprimir o nome do produto no final do relatório
    While ! QRY_REL->(EoF())

        //Incrementa a régua
        nRegAtu++
        IncProc("Imprimindo registro " + cValToChar(nRegAtu) + " de " + cValToChar(nRegTot) + " [" + cValToChar(Round(100*nRegAtu/nRegTot,2)) + "%]...")

        //Aciona a impressão dos dados
        oPrintPvt:SayAlign(nLinAtu, nColIni+200, QRY_REL->B1_DESC, oFontDet12,   (nColFin - nColIni - 030),    300, , PAD_LEFT,  )
        nLinAtu += 12
        
        //Soma o valor do Funrural em uma variável
        nFunrural += QRY_REL->D1_VALINS + D1_VLSENAR + D1_VALFUN
    QRY_REL->(DbSkip())
    EndDo

    //Imprime valor do funrural no final do relatório, se existir funrural
    If cTipCon == 'P'
        cTextoc += "Funrural: R$ " + Alltrim(Transform(nFunrural,"@E 999,999,999.99"))
        oPrintPvt:SayAlign(nLinAtu, nColIni, cTextoc, oFontDet12,   (nColFin - nColIni - 030),    300, , PAD_LEFT,  )
    ENdif

    QRY_REL->(DbCloseArea())

    //Encerrando a impressão e exibindo o pdf
    oPrintPvt:EndPage()
    oPrintPvt:Preview()
     
Return
