#include 'totvs.ch'

user function bitUsua(lJob,lDelete)
	local lRet     := .f.
	local oUsuario := JsonObject():new()
	local cPsw     := superGetMV('BT_DEFPSW',.f.,'')
	local oBitize  := bitize():new()
	local aPerfil  := {}
	local cLog     := ''
	local cId      := ''

	default lJob      := .f.
	default lDelete		:= .f.

	oUsuario['external_id']      := allTrim(ZB1->ZB1_CODUSR)
	oUsuario['first_name']       := allTrim(ZB1->ZB1_NOME)
	oUsuario['last_name']        := allTrim(ZB1->ZB1_SOBREN)
	oUsuario['email']            := allTrim(ZB1->ZB1_EMAIL)
	oUsuario['active']           := if(ZB1_ATIVO=='1',.t.,.f.)
	oUsuario['country_area_code']:= allTrim(ZB1->ZB1_DDI)
	oUsuario['phone']            := allTrim(ZB1->ZB1_PHONE)
	oUsuario['extension']        := allTrim(ZB1->ZB1_RAMAL)

	if ZB1->ZB1_ADM
		aAdd(aPerfil,'ADMIN')
	endif
	if ZB1->ZB1_REG
		aAdd(aPerfil,'REGISTER')
	endif
	if ZB1->ZB1_SELLER
		aAdd(aPerfil,'SELLER')
	endif
	if ZB1->ZB1_REQ
		aAdd(aPerfil,'REQUESTER')
	endif

	oUsuario['roles']:= aPerfil

	if empty(ZB1->ZB1_ID)
		oUsuario['password']:= allTrim(cPsw)
	else
		cId:= allTRim(ZB1->ZB1_ID)
	endif

	if !lDelete
		if empty(cId) //Cadastrar
			lRet:= oBitize:post('users',oUsuario)

			if lRet
				cId := oBitize:getResponse()['id']

				if !empty(cId)
					recLock('ZB1',.f.)
					ZB1->ZB1_SIT:= '2'
					ZB1->ZB1_ID := cId
					ZB1->ZB1_LOG:= ''
					ZB1->(msUnlock())
				endif
			else
				cLog:= oBitize:getError()
			endif

		else //Atualizar
			if !empty(cId)
				lRet:= oBitize:put('users/' + cId,oUsuario)

				if lRet
					cId := oBitize:getResponse()['id']
					if !empty(cId)
						recLock('ZB1',.f.)
						ZB1->ZB1_SIT:= '2'
						ZB1->ZB1_ID := cId
						ZB1->ZB1_LOG:= ''
						ZB1->(msUnlock())
					endif
				else
					cLog:= oBitize:getError()
				endif
			else
				lRet:= .f.
				cLog:= u_bitLog('ID do usuario nao informado')
			endif
		endif
	else //Excluir
		if !empty(cId)
			lRet:= oBitize:delete('users/' + cId)
			if !lRet
				cLog:= oBitize:getError()
			else
				recLock('ZB1',.f.)
				ZB1->ZB1_SIT:= '4' //Deletado
				ZB1->(msUnlock())
			endif
		else
			lRet:= .f.
			cLog:= u_bitLog('ID do usuario nao informado')
		endif
	endif

	if !lRet .and. !lJob
		alert('Erro na integração: ' + cLog)
	endif

	if !empty(cLog)
		recLock('ZB1',.f.)
		ZB1->ZB1_LOG:= cLog
		ZB1->ZB1_SIT:= '4'
		ZB1->(msUnlock())
	endif

return lRet
