#include 'totvs.ch'

user function bitjob(aEmp,lJob)
	local cChave:= 'BITJOB'

	default aEmp:= {'99','01'}
	default lJob:= !(select('SX6') > 0)

	if lJob
		RpcSetType(3)
		if !RpcSetEnv(aEmp[1],aEmp[2],,,,,{'ZB0','ZB1','DHL'})
			u_bitLog("Nao foi possivel abrir as tabelas da Empresa "+aEmp[1]+"/"+aEmp[2])
			Return
		endif

		// Altera a Observação e usuário no Monitor do DbAcess
		#IFDEF TOP
			TCInternal( 8 , "Auto" )
			TCInternal( 1 , procName() )
		#ENDIF

		// Altera a observação no Monitor
		PtInternal(1,procName())
	endif

	if !u_lockRot(cChave)
		return
	endif

	//Usuários
	jobUsers()

	//Perfis de Aprovação
	jobPerf()

	u_bitLog('rodou')

	unLockByName(cChave)

	if lJob
		rpcClearEnv()
	endif

return

/*/{Protheus.doc} jobUsers
Cadastro de Usuários
@type function
@version 1.0 
@author Carlos Tirabassi
@since 06/02/2021
/*/
static function jobUsers()
	private oBitize:= bitize():new()

	if !oBitize:lRet
		u_bitLog('Erro ao carregar a classe do Bitize')
		return
	endif

	ZB1->(dbSetOrder(1))
	while ZB1->(!eof())

		if ZB1->ZB1_SIT <> '2'
			u_bitC001()
		endif

		ZB1->(dbSkip())
	enddo

	ZB1->(dbCloseArea())

return

/*/{Protheus.doc} jobPerf
Cadastro de Perfil de Aprovação
@type function
@version 1.0 
@author Carlos Tirabassi
@since 14/02/2021
/*/
static function jobPerf()
	private oBitize:= bitize():new()

	if !oBitize:lRet
		u_bitLog('Erro ao carregar a classe do Bitize')
		return
	endif

	DHL->(dbSetOrder(1))
	while DHL->(!eof())

		if DHL->DHL_XBTSIT <> '2'
			u_bitC002()
		endif

		DHL->(dbSkip())
	enddo
return
