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

	u_bitLog('Inicio')

	u_bitLog('Cadastro de Usuarios')
	jobUsers()

	u_bitLog('Cadastro de Perfis de Aprovacao')
	jobPerf()

	u_bitLog('Cadastro de Aprovadores')
	jobAprov()

	u_bitLog('Fim')

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
		u_bitLog('Erro ao carregar a classe de comunicacao com o Bitize')
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

	oBitize:cleanUp()
	freeObj(oBitize)

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
		u_bitLog('Erro ao carregar a classe de comunicacao com o Bitize')
		return
	endif

	DHL->(dbSetOrder(1))
	while DHL->(!eof())

		if DHL->DHL_XBTSIT <> '2'
			u_bitC002()
		endif

		DHL->(dbSkip())
	enddo

	DHL->(dbCloseArea())

	oBitize:cleanUp()
	freeObj(oBitize)

return

/*/{Protheus.doc} jobAprov
JCadastro de Aprovadores
@type function
@version 1.0 
@author Carlos Tirabassi
@since 20/02/2021
/*/
static function jobAprov()
	private oBitize:= bitize():new()

	if !oBitize:lRet
		u_bitLog('Erro ao carregar a classe de comunicacao com o Bitize')
		return
	endif

	SAK->(dbSetOrder(1))
	while SAK->(!eof())

		if SAK->AK_XBTSIT <> '2'
			u_bitC003()
		endif

		SAK->(dbSkip())
	enddo

	SAK->(dbCloseArea())

	oBitize:cleanUp()
	freeObj(oBitize)

return
