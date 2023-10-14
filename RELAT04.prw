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
Relatório de recibo em FWMSPrinter
@author Marcos Gonçalves
@since 09/10/2023
@version 1.3
@type function
@see https://tdn.totvs.com/display/public/PROT/FWMsPrinter
/*/
 
User Function XRELAT04()
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
    Local cArquivo      := "RECIBO_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".pdf"
    Local cTexto        := ""
    Local cTexto2       := ""
    Local cTexto3       := ""
    Local cCab          := ""
    Local dDataAtual    := dDataBase
    Local cQryRel       := ""
    Local cFil          := MV_PAR01
    Local cDoc          := MV_PAR02
    Local cForn         := MV_PAR03
    Local cLoja         := MV_PAR04
    Local cParc         := MV_PAR05
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



    //Montando consulta de dados
    cQryRel := "SELECT " + CRLF
    cQryRel += "E2_NUM, E2_NOMFOR, E2_VALOR, E2_SALDO, E2_HIST, E2_VENCTO, A2_CGC " + CRLF
    cQryRel += " " + CRLF
    cQryRel += "FROM " + CRLF
    cQryRel += ""+RetSQLName("SE2")+" " + CRLF
    cQryRel += "LEFT JOIN "+RetSQLName("SA2")+" ON (E2_FORNECE = A2_COD) " + CRLF
    cQryRel += " " + CRLF
    cQryRel += "WHERE " + CRLF
    cQryRel += "E2_NUM = '"+cDoc+"' " + CRLF
    cQryRel += "AND E2_FORNECE = '"+cForn+"' " + CRLF
    cQryRel += "AND E2_LOJA = '"+cLoja+"' " + CRLF
    cQryRel += "AND E2_FILIAL = '"+cFil+"' " + CRLF
    cQryRel += "AND E2_PARCELA = '"+cParc+"' " + CRLF
    cQryRel += "AND SE2010.D_E_L_E_T_ = ' ' AND SA2010.D_E_L_E_T_ = ' ' " + CRLF
    

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
        oPrintPvt:Box(15,15,390,565)
        oPrintPvt:Box(15,15,100,565)

    Else
        FWAlertError("Não foram encontrados dados com os filtros informados", "Falha")
    Endif

    //Cria o cabeçalho
    cCab += "RECIBO Nº " + cValToChar(Year(QRY_REL->E2_VENCTO)) + cValToChar(Month(QRY_REL->E2_VENCTO)) + cValToChar(Day(QRY_REL->E2_VENCTO)) + Alltrim(QRY_REL->E2_NUM)

    //Cria o texto1
    cTexto += "Eu, " + Alltrim(QRY_REL->E2_NOMFOR) + ", inscrito no CPF/CNPJ sob número " + IIF(LEN(Alltrim(QRY_REL->A2_CGC))==11, ALLTRIM(TRANSFORM(QRY_REL->A2_CGC,"@R 999.999.999-99")), ALLTRIM(TRANSFORM(QRY_REL->A2_CGC,"@R 99.999.999/9999-99"))) + ", confirmo que recebi da NIPO BRASILEIRA FRUTAS E LEGUMES LTDA a importância de R$ " + Alltrim(Transform(QRY_REL->E2_VALOR - QRY_REL->E2_SALDO,"@E 999,999,999.99")) + " (" + Alltrim(Lower(Extenso(QRY_REL->E2_VALOR - QRY_REL->E2_SALDO,.F.,1,,"1",.T.,.F.))) + ') referente a "' + Lower(Alltrim(QRY_REL->E2_HIST)) + '".'

    //Cria o texto2
    cTexto2 += "Rio de Janeiro, " + cValToChar(Day(dDataAtual)) + " de " + MesExtenso(dDataAtual) + " de " + cValToChar(Year(dDataAtual))

    //Cria o texto3
    cTexto3 += "Ass.: _____________________________________"
        
    //Imprimindo o logo
    cLogoRel := "\logos\logomatriz.bmp"
    nLinAtu := 30
    oPrintPvt:SayBitmap(nLinAtu, nColIni, cLogoRel, 185, 050) 

    //Agora iremos imprimir o texto com alinhamento justificado
    nLinAtu := 40
    oPrintPvt:SayAlign(nLinAtu, nColIni, cCab,                  oFontDetN,   (nColFin - nColIni - 030),    300, , PAD_RIGHT,  )
    nLinAtu := 130
    oPrintPvt:SayAlign(nLinAtu, nColIni, cTexto,                oFontDet,   (nColFin - nColIni - 030),    300, , PAD_JUSTIFY,  )
    nLinAtu += 120
    oPrintPvt:SayAlign(nLinAtu, nColIni, cTexto2,               oFontDet,   (nColFin - nColIni - 030),    300, , PAD_RIGHT,  )
    nLinAtu += 80
    oPrintPvt:SayAlign(nLinAtu, nColIni, cTexto3,               oFontDet,   (nColFin - nColIni - 030),    300, , PAD_CENTER,  )
    
    QRY_REL->(DbCloseArea())

    //Encerrando a impressão e exibindo o pdf
    oPrintPvt:EndPage()
    oPrintPvt:Preview()
     
Return
