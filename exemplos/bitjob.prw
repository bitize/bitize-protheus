#include 'totvs.ch'

user function bitjob(aEmp,lJob)
	local cChave:= 'BITJOB'

	default aEmp:= {'99','01'}
	default lJob:= !(select('SX6') > 0)

	if lJob
		RpcSetType(3)
		if !RpcSetEnv(aEmp[1],aEmp[2],,,,,{'ZB0','ZB1'})
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

	u_bitLog('rodou')

	unLockByName(cChave)

	if lJob
		rpcClearEnv()
	endif

return
