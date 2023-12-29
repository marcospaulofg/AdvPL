#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} XVALPEDCOM
Validação de pedido de compra do cliente preenchido no pedido de venda
@author  Marcos Gonçalves
@since   07/12/2023
@version 1.0
/*/
//-------------------------------------------------------------------

User Function XVALPEDCOM()

	Local bRet := .T.
	
	If (AllTrim(M->C5_CLIENTE) == "BOA PRACA" .OR. AllTrim(M->C5_CLIENTE) == "GPA") .AND. M->C5_XNPCOM == "          "
		bRet := FWAlertError("Preencha o campo de 'Ped Comp Cli'", "Pedido de compra do cliente")
	EndIf

Return (bRet)
