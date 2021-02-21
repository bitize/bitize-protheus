#include 'totvs.ch'

/*/{Protheus.doc} bitC003
Cadastro de Aprovadores, a tabela SAK deve estar posicionada
@type function
@version 1.0 
@author Carlos Tirabassi
@since 20/02/2021
@param lDelete, logical, Indica se está deletando o registro
@param lJob, logical, Indica se está rodando via Job
@return logical, Retorna true se o processo ocorreu com sucesso
/*/
user function bitC003(lJob,lDelete)
	local aArea   := getArea()
	local lRet    := .f.
	local oAprova := JsonObject():new()
	local cId     := ''
	local nRecno  := SAK->(recno())

	default lDelete		:= .f.
	default lJob      := .f.

	//A classe pode ser instanciada no fonte que chama essa rotina
	if type('oBitize') == 'U'
		oBitize  := bitize():new()
	endif

	//A variavel cLog pode ser declarada no fonte que chama essa rotina
	if type('cLog') == 'U'
		cLog:= ''
	endif

	ZB1->(dbSetOrder(1))
	if ZB1->(dbSeek(xFilial('ZB1')+SAK->AK_USER)) .and. !empty(SAK->AK_USER)
		if !empty(ZB1->ZB1_ID)
			if empty(ZB1->ZB1_APROV)
				recLock('ZB1',.f.)
				ZB1->ZB1_APROV:= SAK->AK_COD
				ZB1->(msUnlock())
			endif

			oAprova['external_id']:= SAK->AK_COD
			oAprova['user_id']    := ZB1->ZB1_ID

			if SAK->AK_TIPO == 'D'
				oAprova['limit_type'] := 'DAILY'
			elseif SAK->AK_TIPO == 'S'
				oAprova['limit_type'] := 'WEEKLY'
			else
				oAprova['limit_type'] := 'MONTHLY'
			endif

			oAprova['limit_value']:= SAK->AK_LIMITE

			if !empty(SAK->AK_APROSUP)
				SAK->(dbSetOrder(1))
				if SAK->(dbSeek(xFilial('SAK')+SAK->AK_APROSUP))
					if ZB1->(dbSeek(xFilial('ZB1')+SAK->SAK_USER))
						oAprova['superior_approver_id']:= ZB1->ZB1_BTID
					endif
				else
					oAprova['superior_approver_id']:= ''
				endif

				SAK->(dbGoTo(nRecno))
			endif

			if !empty(SAK->AK_XBTID)
				cId:= SAK->AK_XBTID
			endif

			if !lDelete
				if empty(cId) //Cadastrar
					lRet:= oBitize:post('approvers',oAprova)

					if lRet
						cId := oBitize:getResponse()['id']

						if !empty(cId)
							recLock('SAK',.f.)
							SAK->AK_XBTID := cId
							SAK->AK_XBTSIT:= '2'
							SAK->(msUnlock())
						endif
					else
						cLog:= oBitize:getError()
						recLock('SAK',.f.)
						SAK->AK_XBTSIT:= '4'
						SAK->(msUnlock())
					endif
				else //Atualizar
					lRet:= oBitize:put('approvers/' + cId ,oAprova)
					if lRet
						recLock('SAK',.f.)
						SAK->AK_XBTSIT:= '2'
						SAK->(msUnlock())
					else
						cLog:= oBitize:getError()
						recLock('SAK',.f.)
						SAK->AK_XBTSIT:= '4'
						SAK->(msUnlock())
					endif
				endif
			else //Deletar
				lRet:= oBitize:delete('approvers/' + cId )
				if lRet
					recLock('SAK',.f.)
					SAK->AK_XBTSIT:= '2'
					SAK->(msUnlock())
				else
					cLog:= oBitize:getError()
					recLock('SAK',.f.)
					SAK->AK_XBTSIT:= '4'
					SAK->(msUnlock())
				endif
			endif
		endif
	endif

	restArea(aArea)

return lRet
