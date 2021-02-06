#include 'totvs.ch'

//Esse possui funções genéricas 

/*/{Protheus.doc} bitNum
Obtém o próximo número disponível para o alias especificado no parâmetro
validando se o número realmente não está sendo utilizado
@type function
@version 1.0 
@author Carlos Tirabassi
@since 05/02/2021
@param cAlias, character, Alias
@param cCampo, character, Campo
@param nOrdem, numeric, Ordem do índice
@return character, Número
/*/
user function bitNum(cAlias,cCampo,nOrdem)
	local cNumero  	:= ''
	local lOk      	:= .F.
	local aArea		  := GetArea()

	default cAlias:= ''
	default cCampo:= ''
  default nOrdem:= 1

	//Verifica se os parametros foram informados
	if empty(cAlias) .Or. empty(cCampo) .Or. nOrdem == 0
		Return ''
	endIf

	DBSelectArea(cAlias)
	DBSetOrder(nOrdem)

	while !lOk

		cNumero:= GetSX8Num(cAlias,cCampo)

		//Verifica se a sequencia ja esta sendo usada
		if !((cAlias)->(DBSeek(xFilial(cAlias)+cNumero)))
			lOk:= .T.

			//Nao confirmamos o processo aqui para que seja possivel utilizar o rollback no fonte que chamar a rotina
			Exit
		endIf

		//Caso a sequencia já esteja sendo usada confirmamos a utilizacao e refazemos o processo
		ConfirmSX8()
	endDo

	restArea(aArea)

Return allTrim(cNumero)


/*/{Protheus.doc} bitLog
Padronizacao de mensagens de erros
@type function
@version 1.0 
@author Carlos Tirabassi
@since 05/02/2021
@param cErro, character, Mensagem de erro
@param lConout, logical, Indica se deve imprimir a mensagem no console
@return character, Mensagem padronizada de erro
/*/
User Function bitLog(cErro,lConout)
	Local cLog:= ''

	default cErro	:= ''
	default lConout	:= .t.

	cLog+= '[' + dtoc(date()) + ']'
	cLog+= '[' + time() + ']'
	cLog+= '[' + ProcName(1) + ']'
	cLog+= '[' + cValToChar(ProcLine(1)) + '] --> '
	cLog+= AllTrim(cErro)

	if lConout
		conout(cLog)
	endif

Return cLog

/*/{Protheus.doc} lockRot
Rotina para executar LockByName
@type function
@version 1.0  
@author Carlos Tirabassi
@since 21/01/2021
@param cChave, character, Utilizado como chave do LockByName
@param nVezes, numeric, Numero de tentativas que serão feitas
@return logical, retorna true caso obtenha sucesso 
/*/
user function lockRot(cChave,nVezes)
	local lRet:= .f.
	local nX  := 1

	default cRotina:= ''
	default nVezes := 3

	for nX:=1 to nVezes
		if LockByName(cChave)
			lRet:= .t.
			EXIT
		else
			sleep(randomize( 100,1000))
		endif
	next

	if lRet
		u_bitLog('Semaforo fechado com sucesso: ' + cChave)
	else
		u_bitLog('Semaforo já está fechado: ' + cChave)
	endif

return lRet
