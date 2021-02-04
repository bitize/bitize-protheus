<p align="center">
  <a href="https://www.bitize.com.br">
    <img src="https://www.bitize.com.br/img/bitize-logo-min.png" width="300" alt="Logo Bitize" />
  </a>
</p>

<p align="center">
<a href="https://github.com/bitize/bitize-protheus/commits/master">
    <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/bitize/bitize-protheus?color=blue">
  </a>

  <img alt="License" src="https://img.shields.io/badge/license-MIT-blue">
   <a href="https://github.com/bitize/bitize-protheus/stargazers">
    <img alt="Stargazers" src="https://img.shields.io/github/stars/bitize/bitize-protheus?style=social">
  </a>
</p>


## 🚧 Integração Protheus x Bitize 🚧  Em Construção

Esse projeto tem como objetivo integrar uma base do Totvs Microsiga Protheus padrão com a Plataforma de Gestão de Compras [BITIZE](https://www.bitize.com.br)

### Classe de Integração
Para poder utilizar a classe você precisa de uma chave de consumo da API e de uma chave secreta, você pode encontrar o passo a passo para obter essas informações [aqui](https://bitize.stoplight.io/docs/api/docs/autenticacao/Como-obter-o-token-de-acesso.md)

O objetivo da classe (bitize.prw) é centralizar a comunicação com a API do Bitize e possui as seguintes funcionalidades:

- [x] Gerenciamento do Token
- [x] Método POST
- [x] Método GET
- [x] Método PUT
- [x] Método DELETE
- [x] Método GetResponse
- [x] Método GetError

**Exemplo de utilização da classe:**

```clipper
function tstBtz()
local oBitize:= nil
local oJson  := nil
local lRet   := .t.

RpcSetType(3)
if !RpcSetEnv('99','01')
    return
endif

//Instancia a classe
oBitize:= bitize():new()

oJson:= JsonObject():new()
oJson['external_id']	:= '000001'
oJson['title']		:= 'Projeto Teste'
oJson['description']	:= 'Descrição do Projeto Teste'

//Faz o POST do cadastro do projeto
lRet:= oBitize:post('projects',oJson)

if lRet
    conout('cadastrou!')
    oRet:= oBitize:getResponse()

    //Faz o GET do cadastro do projeto
    lRet:= oBitize:get('projects/' + oRet['id'])

    if lRet
        conout('listou!')

	oJson:= JsonObject():new()
	oJson['title']		:= 'Projeto Teste 2'
	oJson['description']	:= 'Descrição do Projeto Teste 2'

	//Faz o PUT do cadastro do projeto
	lRet:= oBitize:put('projects/' + oRet['id'],oJson)
	if lRet
	    conout('atualizou')

	    //Faz o DELETE do cadastro do projeto
	    lRet:= oBitize:delete('projects/' + oRet['id'])

	    if lRet
		conout('deletou')
	    endif
	endif
    endif
endif

if !lRet
    conout(oBitize:getError())
endif

RPCClearEnv()
return

```


## 📝 Licença

Este projeto esta sobe a licença MIT.

Feito com ❤️ por Carlos Tirabassi 👋🏽 [Entre em contato!](https://www.linkedin.com/in/carlostirabassi/)
