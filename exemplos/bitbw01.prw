#include 'protheus.ch'
#include 'fwmbrowse.ch'
#Include 'fwmvcdef.ch'

/*/{Protheus.doc} bitbw01
Monitor de Integra��o
@type function
@version 1.0  
@author Carlos Tirabassi
@since 05/02/2021
/*/									                         
User Function bitbw01()
	Local aArea   := GetArea()

	Private oBrowse
	Private aRotina:= MenuDef()

	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("ZB0")

	//Setando a descri��o da rotina
	oBrowse:SetDescription('Monitor de Integra��os ZB0')

  //Legendas
	oBrowse:AddLegend( "ZB0->ZB0_STATUS == '1'"	, "GREEN" , "Registro Processado")
	oBrowse:AddLegend( "ZB0->ZB0_STATUS == '2'"	, "RED"   , "Erro no Processamento")

	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)
Return Nil


Static Function MenuDef()
	Local aRotina := {}

	//Adicionando op��es
	ADD OPTION aRotina TITLE "Visualizar" 	    ACTION "VIEWDEF.bitbw01"   OPERATION 2 ACCESS 0	
  ADD OPTION aRotina TITLE 'Legenda'     		  ACTION 'u_LBRWZB0'        OPERATION 6 ACCESS 0 //OPERATION X

Return aRotina


Static Function ModelDef()
	Local oStZB0 := FWFormStruct(1, "ZB0")

	Private oModel

	oModel := MPFormModel():New("bitbw01M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)
	oModel:AddFields("FORMZB0",/*cOwner*/,oStZB0)
	oModel:SetPrimaryKey({'ZB0_FILIAL','ZB0_ID'})
	oModel:SetDescription("Monitor de Integra��o")
	oModel:GetModel("FORMZB0"):SetDescription("Monitor de Integra��o")
Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel('bitbw01')
	Local oStZB0 := FWFormStruct(2, "ZB0")  

	//Criando oView como nulo
	Private oView := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Atribuindo formul�rios para interface
	oView:AddField("VIEW_ZB0", oStZB0, "FORMZB0")

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	//Colocando t�tulo do formul�rio
	oView:EnableTitleView('VIEW_ZB0', 'Monitor de Integra��o ' ) 

	//For�a o fechamento da janela na confirma��o
	oView:SetCloseOnOk({||.T.})

	//O formul�rio da interface ser� colocado dentro do container
	oView:SetOwnerView("VIEW_ZB0","TELA")
Return oView

User Function LBRWZB0()
	Local aLegenda := {}

	//Monta as cores
	AADD(aLegenda,{"BR_VERDE",   "Registro Processado"  })
	AADD(aLegenda,{"BR_VERMELHO","Erro de Processamento"})

	BrwLegenda("Monitor de Integra��o", "Status", aLegenda)
Return
