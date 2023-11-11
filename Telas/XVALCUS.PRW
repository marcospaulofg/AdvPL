#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} XVALCUS
Validação de custo médio na rotina de movimentações internas
@author  Marcos Gonçalves
@since   08/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------

User Function XVALCUS()

	Local bRet := .T.

	If FunName() == "MATA241"	
		If M->D3_XCUSUND > 1.5*(POSICIONE("SB2",1,xFilial("SB2")+GDFieldGet("D3_COD",n)+GDFieldGet("D3_LOCAL",n),"B2_CM1"))
			bRet := FWAlertYesNo("Custo da mercadoria acima de 150% da média! Deseja continuar?", "Custo médio")
		ElseIf M->D3_XCUSUND < 0.5*(POSICIONE("SB2",1,xFilial("SB2")+GDFieldGet("D3_COD",n)+GDFieldGet("D3_LOCAL",n),"B2_CM1"))
			bRet := FWAlertYesNo("Custo da mercadoria abaixo de 50% da média! Deseja continuar?", "Custo médio")
		EndIf
	EndIf
Return (bRet)
