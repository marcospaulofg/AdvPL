#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} XVALCUS
Valida��o de custo m�dio na rotina de movimenta��es internas
@author  Marcos Gon�alves
@since   08/11/2023
@version 1.2
/*/
//-------------------------------------------------------------------

User Function XVALCUS()

	Local bRet := .T.

	If FunName() == "MATA241"	
		If M->D3_XCUSUND > 1.5*(POSICIONE("SB2",1,xFilial("SB2")+GDFieldGet("D3_COD",n)+GDFieldGet("D3_LOCAL",n),"B2_CM1"))
			bRet := FWAlertYesNo("Custo da mercadoria acima de 150% da m�dia! Custo atual � de R$" + ALLTRIM(TRANSFORM(POSICIONE("SB2",1,xFilial("SB2")+GDFieldGet("D3_COD",n)+GDFieldGet("D3_LOCAL",n),"B2_CM1"),"@E 999,999,999.9999")) + ". Deseja continuar?", "Custo m�dio")
		ElseIf M->D3_XCUSUND < 0.5*(POSICIONE("SB2",1,xFilial("SB2")+GDFieldGet("D3_COD",n)+GDFieldGet("D3_LOCAL",n),"B2_CM1"))
			bRet := FWAlertYesNo("Custo da mercadoria abaixo de 50% da m�dia! Custo atual � de R$" + ALLTRIM(TRANSFORM(POSICIONE("SB2",1,xFilial("SB2")+GDFieldGet("D3_COD",n)+GDFieldGet("D3_LOCAL",n),"B2_CM1"),"@E 999,999,999.9999")) + ". Deseja continuar?", "Custo m�dio")
		EndIf
	EndIf
Return (bRet)
