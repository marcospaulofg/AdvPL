#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} XVALDES
Validação das transformações usando a rotina de desmotagem
@author  Marcos Gonçalves
@since   11/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------

User Function XVALDES()

	Local bRet := .T.
	
	If FunName() == "MATA242"
		If GDFieldGet("D3_QTSEGUM",n) <> NQTDORIGSE
			bRet := FWAlertYesNo("Quantidades para conversão diferentes! Deseja continuar?", "Analise a transformação")
		EndIf
	EndIf
Return (bRet)
