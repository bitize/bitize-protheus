#include 'totvs.ch'

/*/{Protheus.doc} bitC004
Cadastro de Comprador no Bitize, SY1 deve estar posicionada
@type function
@version 1.0 
@author Carlos Tirabassi
@since 06/02/2021
@param lJob, logical, Indica se está rodando via Job
@param cIdUsr,character, ID do Usuário
@param lDelete, logical, Indica se está deletando o registro
@return logical, Retorna true se o processo ocorreu com sucesso
/*/
user function bitC004(lJob,cIdUsr,lDelete)
	local lRet       := .f.
	local oComprador := JsonObject():new()
	local cId        := allTrim(SY1->Y1_XBTID)

	default lJob      := .f.
	default lDelete		:= .f.
	default cIdUsr    := ''

	if type('cLog') == 'U'
		cLog:= ''
	endif

	if type('oBitize') == 'U'
		oBitize  := bitize():new()
	endif

	oComprador['user_id']    := cIdUsr
	oComprador['external_id']:= allTrim(SY1->Y1_COD)
	oComprador['order']      := if(SY1->Y1_PEDIDO == '1',.t.,.f.)

	if !lDelete
		if empty(cId) //Cadastrar
			lRet:= oBitize:post('buyers',oComprador)

			if lRet
				cId := oBitize:getResponse()['id']

				if !empty(cId)
					recLock('SY1',.f.)
					SY1->Y1_XBTID:= cId
					SY1->(msUnlock())
				endif
			else
				cLog:= oBitize:getError()
			endif
		else //Atualizar
			lRet:= oBitize:put('buyers/' + cId,oComprador)
			if !lRet
				cLog:= oBitize:getError()
			endif
		endif
	else
		lRet:= oBitize:delete('buyers/' + cId)
		if !lRet
			cLog:= oBitize:getError()
		endif
	endif

	if !lRet .and. !lJob
		alert('Erro na integração: ' + cLog)
	endif

return lRet
