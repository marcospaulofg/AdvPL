//Bibliotecas
#Include "Protheus.ch"
#Include "TBIConn.ch" 
#Include "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
 
/*/{Protheus.doc} zGerDanfe
Fun��o que gera a danfe e o xml de uma nota em uma pasta passada por par�metro
@author Atilio
@since 10/02/2019
@version 1.0
@param cNota, characters, Nota que ser� buscada
@param cSerie, characters, S�rie da Nota
@param cPasta, characters, Pasta que ter� o XML e o PDF salvos
@type function
@example u_zGerDanfe("000123ABC", "1", "C:\TOTVS\NF")
@obs Para o correto funcionamento dessa rotina, � necess�rio:
    1. Ter baixado e compilado o rdmake danfeii.prw
    2. Ter baixado e compilado o zSpedXML.prw - https://terminaldeinformacao.com/2017/12/05/funcao-retorna-xml-de-uma-nota-em-advpl/
/*/
User Function zGerDanfe(cNota, cSerie, cPasta)
    Local aArea     := GetArea()
    Local cIdent    := ""
    Local cArquivo  := ""
    Local oDanfe    := Nil
    Local lEnd      := .F.
    Local nTamNota  := TamSX3('F2_DOC')[1]
    Local nTamSerie := TamSX3('F2_SERIE')[1]
	Local dDataDe   := sToD("20190101")
    Local dDataAt   := Date()
    Private PixelX
    Private PixelY
    Private nConsNeg
    Private nConsTex
    Private oRetNF
    Private nColAux
    Private oFontDet27  := TFont():New("Arial", 9, -27, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontDet99  := TFont():New("Andale Mono", 9, -120, .T., .F., 5, .T., 5, .T., .F.)   
    Default cNota   := ""
    Default cSerie  := ""
    Default cPasta  := GetTempPath()
     
    //Se existir nota
    If ! Empty(cNota)
        //Pega o IDENT da empresa
        cIdent := RetIdEnti()
         
        //Se o �ltimo caracter da pasta n�o for barra, ser� barra para integridade
        If SubStr(cPasta, Len(cPasta), 1) != "\"
            cPasta += "\"
        EndIf
         
        //Gera o XML da Nota
        cArquivo := cNota + "_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-")
        u_zSpedXML(cNota, cSerie, cPasta + cArquivo  + ".xml", .F.)
         
        //Define as perguntas da DANFE
        Pergunte("NFSIGW",.F.)
        MV_PAR01 := PadR(cNota,  nTamNota)     //Nota Inicial
        MV_PAR02 := PadR(cNota,  nTamNota)     //Nota Final
        MV_PAR03 := PadR(cSerie, nTamSerie)    //S�rie da Nota
        MV_PAR04 := 2                          //NF de Saida
        MV_PAR05 := 1                          //Frente e Verso = Sim
        MV_PAR06 := 2                          //DANFE simplificado = Nao
		MV_PAR07 := dDataDe                    //Data De
        MV_PAR08 := dDataAt                    //Data At�
         
        //Cria a Danfe
        oDanfe := FWMSPrinter():New(cArquivo, IMP_PDF, .F., , .T.)
         
        //Propriedades da DANFE
        oDanfe:SetResolution(78)
        oDanfe:SetPortrait()
        oDanfe:SetPaperSize(DMPAPER_A4)
        oDanfe:SetMargin(60, 60, 60, 60)
         
        //For�a a impress�o em PDF
        oDanfe:nDevice  := 6
        oDanfe:cPathPDF := cPasta                
        oDanfe:lServer  := .F.
        oDanfe:lViewPDF := .F.

        //Vari�veis obrigat�rias da DANFE (pode colocar outras abaixo)
        PixelX    := oDanfe:nLogPixelX()
        PixelY    := oDanfe:nLogPixelY()
        nConsNeg  := 0.4
        nConsTex  := 0.5
        oRetNF    := Nil
        nColAux   := 0
         
        //Chamando a impress�o da danfe no RDMAKE - StaticCall era no modo antigo
        //RptStatus({|lEnd| StaticCall(DANFEII, DanfeProc, @oDanfe, @lEnd, cIdent, , , .F.)}, "Imprimindo Danfe...")
		RptStatus({|lEnd| U_DANFEProc(@oDanfe, @lEnd, cIdent, , , .F.)}, "Imprimindo Danfe...")
        oDanfe:Box(048, 385, 068, 570, "-5")       
        oDanfe:SayAlign(043, 389, "NF CANCELADA", oFontDet27, 200, 100, CLR_HRED, 0, 1)
        oDanfe:Say(800, 60, "NF CANCELADA", oFontDet99, , RGB(255, 119, 119), 315)
        
        oDanfe:Print()
    EndIf
     
    RestArea(aArea)
Return
