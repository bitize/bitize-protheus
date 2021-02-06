#include 'protheus.ch'
#include 'fwmbrowse.ch'
#Include 'fwmvcdef.ch'

/*/{Protheus.doc} bitbw02
Cadastro de Usuários
@type function
@version 1.0  
@author Carlos Tirabassi
@since 05/02/2021
/*/									                         
User Function bitbw02()
	Local aArea   := GetArea()

	Private oBrowse
	Private aRotina:= MenuDef()

	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("ZB1")

	//Setando a descrição da rotina
	oBrowse:SetDescription('Monitor de Integraçãos ZB1')

	//Legendas
	oBrowse:AddLegend( "ZB1->ZB1_SIT == '1'", "BLUE"	, "Aguardando Cadastro")
	oBrowse:AddLegend( "ZB1->ZB1_SIT == '2'", "GREEN" , "Cadastrado")
	oBrowse:AddLegend( "ZB1->ZB1_SIT == '3'", "YELLOW", "Aguardando Atualização")

	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)
Return Nil


Static Function MenuDef()
	Local aRotina := {}

	//Adicionando opções
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.bitbw02' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.bitbw02' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.bitbw02' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.bitbw02' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRotina TITLE 'Enviar'     ACTION 'u_procZB1'       OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Legenda'    ACTION 'u_LBRWZB1'       OPERATION 6 ACCESS 0 //OPERATION X

Return aRotina


Static Function ModelDef()
	Local oStZB1 := FWFormStruct(1, "ZB1")

	Private oModel

	oModel := MPFormModel():New("bitbw02M",/*bPre*/,  { |oMdl| COMPPOS( oMdl )},/*bCommit*/,/*bCancel*/)
	oModel:AddFields("FORMZB1",/*cOwner*/,oStZB1)
	oModel:SetPrimaryKey({'ZB1_FILIAL','ZB1_CODUSR'})
	oModel:SetDescription("Cadastro de Usuários")
	oModel:GetModel("FORMZB1"):SetDescription("Cadastro de Usuários")
Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel('bitbw02')
	Local oStZB1 := FWFormStruct(2, "ZB1")

	//Criando oView como nulo
	Private oView := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Atribuindo formulários para interface
	oView:AddField("VIEW_ZB1", oStZB1, "FORMZB1")

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	//Colocando título do formulário
	oView:EnableTitleView('VIEW_ZB1', 'Cadastro de Usuários ' )

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZB1","TELA")
Return oView

User Function LBRWZB1()
	Local aLegenda := {}

	//Monta as cores
	AADD(aLegenda,{"BR_VERDE",   "Registro Processado"  })
	AADD(aLegenda,{"BR_AZUL",    "Aguardando Processamento"})
	AADD(aLegenda,{"BR_AMARELO", "Aguardando Atualização"})

	BrwLegenda("Cadastro de Usuários", "Status", aLegenda)
Return

static function COMPPOS( oModel )
	local nOp        := oModel:GetOperation()
	local lRet       := .t.
	local aCampos    := {'ZB1_ADM','ZB1_REQ','ZB1_REG','ZB1_SELLER'}
	local nX         := 1

	if nOp == MODEL_OPERATION_INSERT .or. nOp == MODEL_OPERATION_UPDATE

		lRet:= .f.

		for nX:=1 to len(aCampos)
			lRet:= oModel:GetValue( 'FORMZB1', aCampos[nX] )

			if lRet
				EXIT
			endif
		next

		if !lRet
			Help( ,, 'HELP',, 'O usuário precisa ter pelo meno um perfil de acesso!', 1, 0)
			Help(,,"Help",,'O usuário precisa ter pelo meno um perfil de acesso!',1,0,,,,,,{"Selecione pelo menos um perfil de acesso"})
		else
			If nOp == MODEL_OPERATION_UPDATE
				lRet:= oModel:SetValue('FORMZB1', 'ZB1_SIT','3'  )
			EndIf
		endif
	endif

Return lRet

user function procZB1()
	msgRun('Integrando...','Integração Bitize',{||u_bitUsua()})
return
