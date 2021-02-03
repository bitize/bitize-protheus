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


## 💻 Integração Protheus x Bitize

Esse projeto tem como objetivo integrar uma base do Totvs Microsiga Protheus padrão com a Plataforma de Gestão de Compras 

### Classe de Integração
  O objetivo é centralizar a comunicação com a API do Bitize e possui as seguintes funcionalidades:

- [x] Gerenciamento do Token
- [x] Método POST
- [x] Método GET
- [x] Método PUT
- [x] Método DELETE
- [x] Método GetResponse
- [x] Método GetError

```clipper
function Teste()
local oBitize:= bitize():new() //Instância a classe
local lRet   := .t.
local oJson  := JsonObject():new()

lRet:= oBitize:post()

//Faz um GET em https://api.bitize.com.br/consumer-products
lRet:= oBitize.get('consumer-products')

if lRet
   conout('Sucesso!')
endif

return
```

### Exemplos
- [ ] Cadastro de Usuários
- [ ] Cadastro de Compradores
- [ ] Cadastro de Centros de Custos
- [ ] Cadastro de Grupos de Produtos
- [ ] Cadastro de Produtos
- [ ] Cadastro de Fornecedores


## 📝 Licença

Este projeto esta sobe a licença MIT.

Feito com ❤️ por Carlos Tirabassi 👋🏽 [Entre em contato!](https://www.linkedin.com/in/carlostirabassi/)
