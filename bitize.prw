#include 'totvs.ch'

/*/{Protheus.doc} bitize
classe de integra��o Bitize x Protheus
@type class
@version 1.0  
@author Carlos Tirabassi Jr
@since 27/01/2021
/*/
class bitize

	data lVerb		  as Logical
	data cHost      as String // Host da API. Ex: https://app.bitize.com.br/
	data cConsumer  as String // Usu�rio
	data cSecret    as String // Senha
	data cAToken	  as String // Token
	data cRToken	  as String // Refresh Token
	data dDtAToken	as Date
	data cHrAToken	as String
	data dDtRToken	as Date
	data cHrRToken 	as String
	data lRet       as Logical
	data cRet       as String
	data oRet       as Object
	data cErro      as String
	data aHeaders   as Array
	data oRest      as Object

	method new() CONSTRUCTOR
	method consoleLog(cMsg,lErro)
	method refresh()
	method post(cPath,oJson,cParams,aHeader)
	method get(cPath,cParams,aHeader)
	method put(oJson,cPath,cParams,aHeader)
	method delete(cPath,cParams,aHeader)
	method getResponse()
	method getError()

endClass

/*/{Protheus.doc} bitize::new
Inst�ncia a classe
@type method
@version 1.0 
@author Carlos Tirabassi
@since 03/02/2021
@return object, Objeto
/*/
method new() class bitize

	::cHost     := superGetMV('BT_HOST'   ,.f.,'http://localhost:3333')
	::oRest			:= FWRest():New(::cHost)
	::cConsumer := superGetMV('BT_USER'   ,.f.,'268f364d-0eff-4cb5-a9cd-0ebc3dca0c27')
	::cSecret   := superGetMV('BT_PSW'    ,.f.,'17a44e1add0941066c5!@e1asdf35223@%#$9ab3cd193f41d71@!@@f')
	::cAToken   := superGetMV('BT_TOKEN'  ,.f.,'')
	::cRToken   := superGetMV('BT_RTOKEN' ,.f.,'')
	::lVerb		  := superGetMV('BT_VERBO'  ,.f.,.T.)
	::dDtAToken	:= superGetMV('BT_DTATOK' ,.f.,ctod('  /  /    '))
	::cHrAToken	:= superGetMV('BT_HRATOK' ,.f.,'')
	::dDtRToken	:= superGetMV('BT_DTRTOK' ,.f.,ctod('  /  /    '))
	::cHrRToken := superGetMV('BT_HRRTOK' ,.f.,'')
	::lRet      := .t.
	::cRet      := ''
	::oRet      := nil
	::cErro     := ''
	::aHeaders	:= {"Content-Type: application/json"}

	if !(::refresh())
		::cRToken:= ''
		::refresh(.t.) //Tenta renovar o Token novamente
	endif

	::consoleLog('Classe instanciada com ' + if (::lRet,'sucesso!','com erros: ' + ::cErro))

return Self

/*/{Protheus.doc} bitize::consoleLog
Rotina de gera��o de logs
@type method
@version 1.0 
@author Carlos Tirabassi
@since 03/02/2021
@param cMsg, character, Mensagem
@param lErro, logical, Indica se � um erro
/*/
method consoleLog(cMsg,lErro) class bitize
	local cLog:= ''

	default cMsg := ''
	default lErro:= .f.

	if ::lVerb .or. lErro
		cLog:= '[' + dtoc(date()) + ']'
		cLog+= '[' + time() + ']'
		cLog+= '[' + ProcName(1) + ']'
		cLog+= '[' + cValToChar(ProcLine(1)) + ']'
		cLog+= '['+allTrim(cMsg)+']'

		if lErro
			::cErro:= cLog
			::lRet := .f.
		endif

		if ::lVerb .or. lErro
			conout(cLog)
		endif

	endif
return

/*/{Protheus.doc} bitize::refresh
Faz o gerenciamento do token, fazendo o refresh caso necess�rio
@type method
@version 1.0 
@author Carlos Tirabassi
@since 03/02/2021
@param lForca, logical, Caso seja true for�a a renova��o do token
@return logical, Retorna true se integra��o ocorreu com sucesso 
/*/
method refresh(lForca) class bitize
	local oEnv	:= nil
	local nPos  := 0

	default lForca:= .f.

	if retDif(date(),time(),::dDtAToken,::cHrAToken) >= 0 .or. empty(::cAToken) .or. lForca
		if retDif(date(),time(),::dDtRToken,::cHrRToken) < 0 .and. !empty(::cRToken) .and. !lForca
			::cAToken:= ''
			if ::get('auth','refresh_token=' + ::cRToken,,.f.)
				::cAToken	:= ::oRet['access_token']
				::cRToken	:= ::oRet['refresh_token']
				::dDtAToken	:= stod(strTran(subStr(::oRet['expiration_access_token'],1,10),'-'))
				::cHrAToken	:= subStr(::oRet['expiration_access_token'],11,8)
				::dDtRToken	:= stod(strTran(subStr(::oRet['expiration_refresh_token'],1,10),'-'))
				::cHrRToken := subStr(::oRet['expiration_refresh_token'],11,8)

				PutMV('BT_ATOKEN',::cAToken)
				PutMV('BT_RTOKEN',::cRToken)
				PutMV('BT_DTATOK',::dDtAToken)
				PutMV('BT_HRATOK',::cHrAToken)
				PutMV('BT_DTRTOK',::dDtRToken)
				PutMV('BT_HRRTOK',::cHrRToken)

				::lRet:= .t.
				::speak('Token atualizado com sucesso!')
			else
				::speak('Erro ao tentar renovar o token usando o refresh token: ' + ::cErro,.t.)
			endif
		else

			oEnv:= JsonObject():new()
			oEnv['consumer_key']:= ::cConsumer
			oEnv['secret_key']	:= ::cSecret

			::cAToken:= ''

			if ::post('/auth',oEnv,,,.f.)

				::cAToken		:= ::oRet['access_token']
				::cRToken		:= ::oRet['refresh_token']
				::dDtAToken	:= stod(strTran(subStr(::oRet['expiration_access_token'],1,10),'-'))
				::cHrAToken	:= subStr(::oRet['expiration_access_token'],12,8)
				::dDtRToken	:= stod(strTran(subStr(::oRet['expiration_refresh_token'],1,10),'-'))
				::cHrRToken := subStr(::oRet['expiration_refresh_token'],12,8)

				PutMV('BT_ATOKEN',::cAToken)
				PutMV('BT_RTOKEN',::cRToken)
				PutMV('BT_DTATOK',::dDtAToken)
				PutMV('BT_HRATOK',::cHrAToken)
				PutMV('BT_DTRTOK',::dDtRToken)
				PutMV('BT_HRRTOK',::cHrRToken)

				::lRet:= .t.
				::consoleLog('Token atualizado com sucesso!')

			else
				::consoleLog('Erro ao tentar renovar o token: ' + ::cErro,.t.)
			endif
		endif
	endif

	if ::lRet
		nPos:= aScan(::aHeaders,{|x| 'Authorization' $ x})
		if nPos > 0
			::aHeaders[nPos]:= 'Authorization: Bearer ' + ::cAToken
		else
			aAdd(::aHeaders,'Authorization: Bearer ' + ::cAToken)
		endif
	endif

return ::lRet

/*/{Protheus.doc} bitize::post
M�todo HTTP Post
@type method
@version 1.0 
@author Carlos Tirabassi
@since 03/02/2021
@param cPath, character, Path
@param oJson, object, JSON a ser enviado
@param cParams, character, Query strings
@param aHeader, array, Headers
@param lRefresh, logical, Indica se deve verificar o token
@return logical, Retorna true se integra��o ocorreu com sucesso
/*/
method post(cPath,oJson,cParams,aHeader,lRefresh) class bitize
	local cLog := ''
	local cPost:= ''
	local aHd  := {}
	local nx   := 0

	default cParams	:= ''
	default cParams	:= ''
	default aHeader	:= {}
	default lRefresh:= .t.

	if lRefresh
		::refresh()
	endif

	::cRet := ''
	::oRet := nil
	::lRet := .t.
	::cErro:= ''

	cPath:= allTrim(cPath)

	if subStr(cPath,1,1) <> '/'
		cPath:= '/' + cPath
	endif

	::oRest:setPath(cPath)

	cPost:= encodeUTF8(strtran(FWJsonSerialize(oJson, .F., .F., .T.),'\'))
	if empty(cPost)
		cPost:= strtran(FWJsonSerialize(oJson, .F., .F., .T.),'\')
	endif

	aHd:= ::aHeaders
	for nX:=1 to len(aHeader)
		aAdd(aHd,aHeader[nX])
	next

	::oRest:SetPostParams(cPost)

	if ::oRest:Post(aHd)
		if !empty(::oRest:GetResult())
			::cRet:= FWNoAccent(DecodeUtf8(::oRest:GetResult()))

			if empty(::cRet)
				::cRet:= FWNoAccent(::oRest:GetResult())
			endif

			::oRet:= JsonObject():new()
			::oRet:fromJson(::cRet)

			::lRet := .t.
			::cErro:= ''
		else
			::oRet := nil
			::cErro:= ''
			::lRet := .t.
		endif
		::consoleLog('Sucesso! Operacao: POST ' + cPath)
	else
		::oRet := nil

		::cRet:= FWNoAccent(DecodeUtf8(::oRest:GetResult()))

		if empty(::cRet)
			::cRet:= FWNoAccent(::oRest:GetResult())
		endif

		cAux:= FWNoAccent(DecodeUtf8(::oRest:GetLastError()))

		if empty(cAux)
			cAux:= FWNoAccent(::oRest:GetLastError())
		endif

		cLog+= 'Host: ' + ::cHost + CRLF
		cLog+= 'Operacao: POST ' + cPath + CRLF
		cLog+= 'Erro: ' + cAux + CRLF
		cLog+= 'Resultado: ' + ::cRet + CRLF

		::consoleLog(cLog,.T.)
	endif

return ::lRet

/*/{Protheus.doc} bitize::get
M�todo HTTP GET
@type method
@version 1.0 
@author Carlos Tirabassi
@since 03/02/2021
@param cPath, character, Path
@param cParams, character, Query string
@param aHeader, array, Headers
@param lRefresh, logical, Indica se deve verificar o token
@return logical, Retorna true se integra��o ocorreu com sucesso
/*/
method get(cPath,cParams,aHeader,lRefresh) class bitize
	local cLog	:= ''
	local aHd  	:= {}
	local nx   	:= 0
	local cAux  := ''

	default cPath  := ''
	default cParams:= ''
	default aHeader:= {}
	default lRefresh:= .t.

	if lRefresh
		::refresh()
	endif

	::cRet := ''
	::oRet := nil
	::lRet := .t.
	::cErro:= ''

	if subStr(cPath,1,1) <> '/'
		cPath:= '/' + cPath
	endif

	::oRest:setPath(cPath + if(!empty(cParams),'?'+cParams,''))

	aHd:= ::aHeaders
	for nX:=1 to len(aHeader)
		aAdd(aHd,aHeader[nX])
	next

	if ::oRest:Get({aHd})
		if !empty(::oRest:GetResult())
			::cRet:= FWNoAccent(DecodeUtf8(::oRest:GetResult()))

			if empty(::cRet)
				::cRet:= FWNoAccent(::oRest:GetResult())
			endif

			::cRet:= strTran(::cRet,'\/','/')
			::cRet:= strtran(::cRet,":null",': " "')
			::cRet:= strtran(::cRet,'"self"','"_self"')

			::oRet:= JsonObject():new()
			::oRet:fromJson(::cRet)

			::lRet := .t.
			::cErro:= ''
		else
			::oRet := nil
			::cErro:= ''
			::lRet := .t.
		endif
	else
		::oRet := nil

		::cRet:= FWNoAccent(DecodeUtf8(::oRest:GetResult()))

		if empty(::cRet)
			::cRet:= FWNoAccent(::oRest:GetResult())
		endif

		cAux:= FWNoAccent(DecodeUtf8(::oRest:GetLastError()))

		if empty(cAux)
			cAux:= FWNoAccent(::oRest:GetLastError())
		endif

		cLog+= 'Host: ' + ::cHost + CRLF
		cLog+= 'Operacao: GET ' + cPath + CRLF
		cLog+= 'Erro: ' + cAux + CRLF
		cLog+= 'Resultado: ' + ::cRet + CRLF

		::consoleLog(cLog,.T.)
	endif

return ::lRet

/*/{Protheus.doc} bitize::put
M�todo HTTP PUT
@type method
@version 1.0 
@author Carlos Tirabassi
@since 03/02/2021
@param cPath, character, Path
@param oJson, object, JSON que ser� enviado
@param cParams, character, Query string
@param aHeader, array, Headers
@return logical, Retorna true se integra��o ocorreu com sucesso
/*/
method put(cPath,oJson,cParams,aHeader) class bitize
	local cLog := ''
	local cPut := ''
	local aHd  := {}
	local cAux := ''
	local nx   := 0

	default cParams := ''
	default aHeader	:= {}

	::refresh()

	::cRet := ''
	::oRet := nil
	::lRet := .t.
	::cErro:= ''

	cPath:= allTrim(cPath)

	if subStr(cPath,1,1) <> '/'
		cPath:= '/' + cPath
	endif

	::oRest:setPath(cPath + if(!empty(cParams),'?'+cParams,''))

	cPut:= encodeUTF8(strtran(FWJsonSerialize(oJson, .F., .F., .T.),'\'))
	if empty(cPut)
		cPut:= strtran(FWJsonSerialize(oJson, .F., .F., .T.),'\')
	endif

	aHd:= ::aHeaders
	for nX:=1 to len(aHeader)
		aAdd(aHd,aHeader[nX])
	next

	if ::oRest:Put(aHd,cPut)
		if !empty(::oRest:GetResult())
			::cRet:= ::oRest:GetResult()

			::oRet:= JsonObject():new()
			::oRet:fromJson(::cRet)

			::lRet := .t.
			::cErro:= ''
		else
			::oRet := nil
			::cErro:= ''
			::lRet := .t.
		endif
	else
		::oRet := nil

		::cRet:= FWNoAccent(DecodeUtf8(::oRest:GetResult()))

		if empty(::cRet)
			::cRet:= FWNoAccent(::oRest:GetResult())
		endif

		cAux:= FWNoAccent(DecodeUtf8(::oRest:GetLastError()))

		if empty(cAux)
			cAux:= FWNoAccent(::oRest:GetLastError())
		endif

		cLog+= 'Host: ' + ::cHost + CRLF
		cLog+= 'Operacao: GET ' + cPath + CRLF
		cLog+= 'Erro: ' + cAux + CRLF
		cLog+= 'Resultado: ' + ::cRet + CRLF

		::consoleLog(cLog,.T.)
	endif

return ::lRet

/*/{Protheus.doc} bitize::delete
M�todo DELETE
@type method
@version  1.0
@author Carlos Tirabassi
@since 03/02/2021
@param cPath, character, Path
@param cParams, character, Query string
@param aHeader, array, Headers
@return logical, Se a integra��o ocorrer com sucesso retorna true
/*/
method delete(cPath,cParams,aHeader) class bitize
	local cLog:= ''
	local aHd  := {}
	local cAux := ''
	local nx   := 0

	default cParams := ''
	default aHeader	:= {}

	::refresh()

	::cRet := ''
	::oRet := nil
	::lRet := .t.
	::cErro:= ''

	if subStr(cPath,1,1) <> '/'
		cPath:= '/' + cPath
	endif

	::oRest:setPath(cPath + if(!empty(cParams),'?'+cParams,''))

	aHd:= ::aHeaders
	for nX:=1 to len(aHeader)
		aAdd(aHd,aHeader[nX])
	next

	if ::oRest:Delete(aHd)
		if !empty(::oRest:GetResult())
			::cRet:= FWNoAccent(DecodeUtf8(::oRest:GetResult()))

			if empty(::cRet)
				::cRet:= FWNoAccent(::oRest:GetResult())
			endif

			::oRet:= JsonObject():new()
			::oRet:fromJson(::cRet)

			::lRet := .t.
			::cErro:= ''

		else
			::oRet := nil
			::cErro:= ''
			::lRet := .t.
		endif
	else
		::oRet := nil

		::cRet:= FWNoAccent(DecodeUtf8(::oRest:GetResult()))

		if empty(::cRet)
			::cRet:= FWNoAccent(::oRest:GetResult())
		endif

		cAux:= FWNoAccent(DecodeUtf8(::oRest:GetLastError()))

		if empty(cAux)
			cAux:= FWNoAccent(::oRest:GetLastError())
		endif

		cLog+= 'Host: ' + ::cHost + CRLF
		cLog+= 'Operacao: GET ' + cPath + CRLF
		cLog+= 'Erro: ' + cAux + CRLF
		cLog+= 'Resultado: ' + ::cRet + CRLF

		::consoleLog(cLog,.T.)
	endif

return ::lRet

/*/{Protheus.doc} bitize::getResponse
Retorna a resposta da requisi��o
@type method
@version  1.0
@author Carlos Tirabassi
@since 03/02/2021
@return object, Objeto JSON
/*/
method getResponse() class bitize
return ::oRet

/*/{Protheus.doc} bitize::getError
Retorna o erro gerado na requisi��o
@type method
@version 1.0
@author Carlos Tirabassi
@since 03/02/2021
@return character, Descri��o do erro
/*/
method getError() class bitize
return ::cErro

/*/{Protheus.doc} retDif
retorna diferen�a entre duas datas e horas
@type function
@version 1.0 
@author Carlos Tirabassi Jr
@since 27/01/2021
@param dDtIni, date, Data inicial
@param cHrIni, character, Hora Inicial
@param dDtFim, date, Data Final
@param cHrFim, character, Hora Final
@return numeric, Diferen�a em horas
/*/
static function retDif(dDtIni,cHrIni,dDtFim,cHrFim)
	local nHrIni:= 0
	local nHrFim:= 0
	local nHora	:= 0
	local nDias := 0

	default dDtIni:= date()
	default cHrIni:= '00:00:00'
	default dDtFim:= date()
	default cHrFim:= '00:00:00'

	nHrIni:= Hr2Val(cHrIni)
	nHrFim:= Hr2Val(cHrFim)

	nHora:= nHrIni - nHrFim

	if dDtIni >= dDtFim
		nDias:= DateDiffDay(dDtIni,dDtFim)
	else
		nDias:= DateDiffDay(dDtIni,dDtFim) * -1
	endif

return (nDias * 24) + nHora

/*/{Protheus.doc} Hr2Val
Retorna a hora me formato numerico
@type function
@version  1.0
@author Carlos Tirabassi Jr
@since 27/01/2021
@param cHora, character, Hora no formato HH:MM:SS
@param cSep, character, Separador
@return numeric, Hora decimal
/*/
static function Hr2Val(cHora, cSep)
	local nAux    := 0
	local cMin    := ""
	local nValor  := 0
	local nPosSep := 0

	default cHora := ""
	default cSep  := ':'

	//Se tiver a hora
	If !Empty(cHora)
		nPosSep := RAt(cSep, cHora)
		nAux    := Val(SubStr(cHora, nPosSep+1, 2))
		nAux    := Int(Round((nAux*100)/60, 0))
		cMin    := Iif(nAux > 10, cValToChar(nAux), "0"+cValToChar(nAux))
		nValor  := Val(SubStr(cHora, 1, nPosSep-1)+"."+cMin)
	EndIf

Return nValor


//fun��o para testes da classe
user function tstBtz()
	local oBitize:= nil
	local oJson  := nil
	local lRet   := .t.

	RpcSetType(3)
	if !RpcSetEnv('99','01')
		return
	endif

	//Instancia a classe
	oBitize:= bitize():new()

	SB1->(dbSetOrder(1))
	SB1->(dbGoTop())

	oJson:= JsonObject():new()
	oJson['external_id']	:= allTrim(SB1->(B1_FILIAL+B1_COD))
	oJson['title']				:= allTrim(SB1->B1_DESC)
	oJson['description']	:= allTrim(SB1->B1_DESC)

	lRet:= oBitize:post('consumer-products',oJson)

	RPCClearEnv()
return
