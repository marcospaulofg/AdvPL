#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} XVALCTOT
Validação de custo total na rotina de movimentações internas
@author  Marcos Gonçalves
@since   27/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------

User Function XVALCTOT()

	Local bRet := .T.

	If FunName() == "MATA241"	
		If (M->D3_CUSTO1 <> GDFieldGet("D3_XCUSUND",n)*GDFieldGet("D3_QUANT",n))
			bRet := FWAlertYesNo("Custo total não confere com quantidade x custo unitário. Deseja continuar?", "Custo total")
		EndIf
	EndIf
Return (bRet)
