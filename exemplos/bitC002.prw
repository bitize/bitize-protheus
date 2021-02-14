#include 'totvs.ch'

/*/{Protheus.doc} bitC002
Cadastro de perfil de aprovação, a tabela DHL deve estar procisionada
@type function
@version 1.0 
@author Carlos Tirabassi
@since 14/02/2021
@param lJob, logical, indica se a rotina está sendo executada via job
@param lDelete, logical, indica se é uma operação de exclusão
@return logical, Retorna true se o processo ocorreu com sucesso
/*/
user function bitC002(lJob,lDelete)
	local lRet    := .f.
	local oPerfil := JsonObject():new()
	local cLog    := ''
	local cId     := ''

	default lJob    := .f.
	default lDelete	:= .f.

	if type('oBitize') == 'U'
		oBitize  := bitize():new()
	endif

	oPerfil['external_id']:= allTrim(DHL->DHL_COD)
	oPerfil['title']      := allTrim(DHL->DHL_DESCRI)
	oPerfil['description']:= allTrim(DHL->DHL_DESCRI)
	oPerfil['minimum']    := DHL->DHL_LIMMIN
	oPerfil['maximum']    := DHL->DHL_LIMMAX
	oPerfil['active']     := .t.
	oPerfil['currency_id']:= 'BRL'

	if !empty(DHL->DHL_XBTID)
		cId:= allTRim(DHL->DHL_XBTID)
	endif

	if !lDelete
		if empty(cId) //Cadastrar
			lRet:= oBitize:post('approval-profiles',oPerfil)

			if lRet
				cId := oBitize:getResponse()['id']

				if !empty(cId)
					recLock('DHL',.f.)
					DHL->DHL_XBTID := cId
					DHL->DHL_XBTSIT:= '2'
					DHL->(msUnlock())
				endif
			else
				cLog:= oBitize:getError()
				recLock('DHL',.f.)
				DHL->DHL_XBTSIT:= '4'
				DHL->(msUnlock())
			endif
		else
			lRet:= oBitize:put('approval-profiles/' + cId ,oPerfil)
			if lRet
				recLock('DHL',.f.)
				DHL->DHL_XBTSIT:= '2'
				DHL->(msUnlock())
			else
				cLog:= oBitize:getError()
				recLock('DHL',.f.)
				DHL->DHL_XBTSIT:= '4'
				DHL->(msUnlock())
			endif
		endif
	else
		lRet:= oBitize:delete('approval-profiles/' + cId )
		if lRet
			recLock('DHL',.f.)
			DHL->DHL_XBTSIT:= '2'
			DHL->(msUnlock())
		else
			cLog:= oBitize:getError()
			recLock('DHL',.f.)
			DHL->DHL_XBTSIT:= '4'
			DHL->(msUnlock())
		endif
	endif

return lRet
