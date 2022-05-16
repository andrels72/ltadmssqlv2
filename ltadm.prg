/*************************************************************************
         Sistema: Controle Administrativo
          Vers'o: 2.00
   Identifica×'o: Modulo Principal
         Prefixo: LtAdm
        Programa: LtAdm.PRG
           Autor: Andre Lucas Souza
            Data: 18 de Agosto de 2003
   Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "winuser.ch"
#include "cxwin.ch"
//#include "icbrasil.ch"

#define CRLF chr(K_ENTER)+chr(K_CTRL_ENTER)

function main(cComando)
	local lFaz, cCor := setcolor(),cUsuario,nTecla
	local aInfofile
	local aConfCor   := {},aConfig    := {},aSenhas1  := {},aSenhas     := {}
	local aUtilit    := {},aBancos    := {},aCidades   := {},aClientes  := {}
	local aCadastro  := {},aRelat     := {},aProdutos  := {},aFornece   := {}
	local aRelCli    := {},aPlanos    := {},aVendedor  := {},aTranspo   := {}
	local aDuplRec   := {},aBancos1   := {},aHistBan   := {},aMovBan    := {}
	local aCaixa     := {},aDuplicata := {},aCaixa1    := {},aHistCxa   := {}
	local aFPagtoCxa := {},aMovCxa    := {},aRelCxa    := {},aRelBan    := {}
	local aDuplPag   := {},aDuplPagF  := {},aDuplPagV  := {},aImpresso  := {}
	local aRelFor    := {},aEstados   := {},aCheques   := {},aRelCheq   := {}
	local aRelDup    := {},aRelDupRec := {},aRelFat    := {},aRelDupPag := {}
	local aGrupos    := {},aNatureza  := {},aSitTrib   := {},aFinance   := {}
	local aRelFinan  := {},aEntrada   := {},aCompra    := {},aSaida     := {}
	local aOrcame    := {},aReajI     := {},aReajP     := {},aLocImp    := {}
	local aSubGrupo  := {},aPedido    := {},aMapaFis   := {},aInventar  := {}
    local aRelEntra  := {},aRelProd   := {},aRelSaida  := {},aRelPed    := {}
    local aCheque    := {},aNegociado := {},aNegociar  := {},aNotaAvu   := {}
    local aOrcamen   := {},aMuniIbge  := {},aNotaNFE   := {},aCCE       := {}
    local aUnidMed   := {},aFiscal    := {},aClientes2 := {},aGrupoCli  := {}
	local aNCM       := {},aCFOP      := {},aNfeVenda := {},aFabricante := {}
	local aBaixaDuplNormal := {},aBaixaDuplGeral := {},aSuporte := {},aNfeEntrada := {}
    local aImportaXml := {},aNfeDev := {},aOrcamentos := {},aMov := {},aMovFinanceiro := {}
    local aMovVendas := {},aMovNotas := {},aNFe := {},aEstoque := {}
	
    // vetores do menu
	private aProdFor := {},aProdutos2 := {},aTransfProd := {},cVersao := "8.0"
    
    public s_nNormalMaxrow := 34,s_nNormalMaxcol := 135
    
   
	public _aObjetos      := {}
	public aMenu := {}, aPrompt := {}, NIVEL := "02",cDiretorio := "dados\",aNumIdx[100]
    public nTipoEstoque  // 1-Com Nota e Sem Nota,2-Sem Nota
   // ** Vetores do Menu
	private aCredCartao := {}
	private  aNFCE      := {}  // ** Menu da NFCe
	
   // Variaveis de Configura×'o de lan×amentos no caixa
   private cCCodCxa := space(02),cCCodHis := space(03)
   private cPCodCxa := space(02),cPCodHis := space(03)
   private cRCodCxa := space(02),cRCodHis := space(03)
   // Conf. do lan×amento no caixa do contas a pagar
   private cACodCxa := space(02),cACodHis := space(03)

   // Variaveis utilizadas pelo Plano de Senhas
   public PWnivel, PWregt, PWnome,cCodUser,lGeral := .f.
   public anLin := {},aString := {},cCorBanner := Cor(1)

   // Variaveis para a Funcao de Valor por Extenso
   public C_VMoedaIS := [Real                ]
   public C_VMoedaIP := [Reais               ]
   public C_VMoedaFS := [Centavo             ]
   public C_VMoedaFP := [Centavos            ]

	// ** variaveis dos dados da empresa - emitente   
	private cEmpRazao
    private cEmpFantasia
	private cEmpEndereco
	private cEmpnumero
	private cEmpComplend  // ** complemento de endereÎo
	private cEmpBairro
	private cEmpCodcid
    private cEmpCidade
	private cEmpEstCid
	private cEmpCep
	private cEmpTelefone1
	private cEmpTelefone2
	private cEmpEmail
	private cEmpCnpj
	private cEmpIe
	private cEmpIm  // ** InscriÎ’o municipal
	private cEmpCnae
	private cEmpCrt // ** c½digo de regime tributario

   public oServer,lBancoConectado := .f.,lAutorizado := .t.
   public cHost,cDataBase,cUser,cPass,nPort

   


   // variaveis de retorno da NFE

   request Hb_noMouse  // Desativa o Mouse
   REQUEST DBFNTX
	REQUEST DBFCDX
	REQUEST DBFFPT
	RDDSETDEFAULT("DBFCDX")

   Config()
   Arq_Sen := if(empty(netname()),[Ervidor],right(alltrim(netname()),7))
   ArqTerm := if(empty(netname()),[Ervidor],right(alltrim(netname()),7))+".cf"
   Arq_Cfg := "config.cfg"

   Config()
   if cComando == "/AUTORIZA"
      IniAuto()
   end
   ConfiguraAmbiente()
   if !CheckAuto()
      Mens({"Computador Nao Autorizado"})
      setcursor(1)
      lAutorizado := .f.
      quit
   end
   CLEAR
   *-> Variavel de fundo da tela
   FUNDO := 1
   cor("TITULO")
   @ 00,00 clear to 00,wvw_maxmaxcol()
   cor("FUNDO DA TELA")
   @ 02,00 clear to wvw_maxmaxrow(),wvw_maxmaxcol()
   cor("MENU")
   scroll(01,00,01,wvw_maxmaxcol(),0)
   scroll(wvw_maxmaxrow(),00,wvw_maxmaxrow(),wvw_maxmaxcol(),0)

   if cComando = "/BANCO"
      if !ConfiBanco()
          lAutorizado := .f.
          close all
        setcursor(1)
          set color to
          cls
          quit
      endif
  endif
   if !ConectarAoBancoDeDados()
      close all
      setcursor(1)
      set color to
      cls
      quit
   endif
   
   if !LerDadosEmpresa()
      setcolor(cCor)
      cls
      setcursor(1)
      oServer:Close() // fecha o banco de dados
      quit
   endif

   aInfofile := directory("ltadm.exe")
   Abertura("Sistema Administrativo - Versao "+cVersao,"2016",dtoc(aInfoFile[1,3])+'-'+aInfoFile[1,4],rtrim(cEmpFantasia))

  if cComando == "/ROTINAS"
      if !InstSenha()
          close all
        setcursor(1)
          set color to
          cls
          quit
      endif
  endif
  if cComando == "/EXECUTAVEL"
      if !AtualizarExecutavel()
          oServer:Close()
          quit
      endif
  endif
  if (! PwCheck())
      Mens({"Acesso Nao Autorizado!"})
      setcolor(cCor)
      cls
      setcursor(1)
      oServer:Close()  // fecha o banco de dados
      quit
  endif
  Msg(.t.)
  Msg("Aguarde: Carregando o sistema")
  if !IsDirectory("dados")
      DirMake("dados")
  endif
   if !file(Arq_Sen+"c.mem")
      save to (Arq_Sen)+"c" all like cCCod*
   endif
   if !file(Arq_Sen+"p.mem")
      save to (Arq_Sen)+"p" all like cPCod*
   endif
   // ** Arquivo de Configura×'o de lan×amento autom˜tico no caixa de duplicatas
   // ** a receber
   if !file(Arq_Sen+"r.mem")
      save to (Arq_Sen)+"r" all like cRCod*
   endif
   // ** Arquivo de configura×'o de lan×amento autom˜tico no caixa do contas a pagar
   if !file(Arq_Sen+"a.mem")
      save to (Arq_Sen)+"a" all like cACod*
   endif
    if !IsDirectory("importxml")
        DirMake("importxml")
    endif
   CriarTemp()
   TmpDbfs()
   set key K_F11 to Calc()
   set key K_F12 to Calen()
   if PWnivel == "0"
      AtivaF9()
   endif
   set exclusive off
   Conf_Cfg("AJUDA",.t.)
   // ** Impressoras
   aadd(aImpresso,{" &1-Incluir   ",{|| IncImpress()},iif(!PwCheck("3000341"),999,NIL)})
   aadd(aImpresso,{" &2-Alterar   ",{|| AltImpress()},iif(!PwCheck("3000342"),999,NIL)})
   aadd(aImpresso,{" &3-Consultar ",{|| ConImpress()},iif(!PwCheck("3000343"),999,NIL)})
   aadd(aImpresso,{" &4-Testar    ",{|| ""}          ,iif(!PwCheck("3000344"),999,NIL)})

   // ** Local de Impressao
   aadd(aLocImp,{" &1-Incluir   ",{|| IncLocImp() },iif(!PwCheck("300041"),999,NIL)})
   aadd(aLocImp,{" &2-Alterar   ",{|| AltLocImp() },iif(!PwCheck("300042"),999,NIL)})
   aadd(aLocImp,{" &3-Excluir   ",{|| ExcLocImp() },iif(!PwCheck("300043"),999,NIL)})
   aadd(aLocImp,{" &4-ConSultar ",{|| ConLocImp() },iif(!PwCheck("300044"),999,NIL)})
   aadd(aLocImp,{" &5-Carregar  ",{|| CarLocImp() },iif(!PwCheck("300045"),999,NIL)})

   aadd(aConfig,{" &1-Dados da Empresa     ",{||Empresa()}    ,iif(!PwCheck("300031"),999,NIL)})
   aadd(aConfig,{" &2-Impressoras         >",aImpresso,iif(!PwCheck("300034"),999,NIL)})
   aadd(aConfig,{" &3-Local de Impressao  >",aLocImp  ,iif(!PwCheck("30004") ,999,NIL)})
   aadd(aConfig,{" &4-Parametros           ",{|| ManParamet()},iif(!PwCheck("30007") ,999,NIL)})
   aadd(aConfig,{" &5-Parametros da NF-e   ",{|| ParametroNFE()}})
   aadd(aConfig,{" &6-Parametros da NFC-e  ",{|| ParametroNFCe()}})
   aadd(aConfig,{" &7-Parametros do ACBR   ",{|| ParametroAcbr()}})
   aadd(aConfig,{" &8-Salva Configura‡Æo   ",{|| SaveConfig() }})
   //aadd(aConfig,{" &-Teste",{|| InfoCertificado()}})
   //aadd(aConfig,{" &-Teste",{|| testar_1()}})

   aadd(aSenhas1,{" &1-Incluir   ",&("{||PwCadUs()}")})
   aadd(aSenhas1,{" &2-Alterar   ",&("{||PwAltUs()}")})
   aadd(aSenhas1,{" &3-Excluir   ",&("{||PwExcUs()}")})
   aadd(aSenhas1,{" &4-Consulta  ",&("{||PwConUs()}")})
   aadd(aSenhas1,{" &5-Liberar   ",&("{||PwLibUs()}")})

    aadd(aSenhas,{" &1-Manutencao de Usuarios "+">",aSenhas1})
    aadd(aSenhas,{" &2-Manutencao dos Acessos ",{||PwManAce()}})
    aadd(aSenhas,{" &3-Alteracao da Senha     ",{||PwChange()}})

    aadd(aUtilit,{" &1-Plano de Senhas       >",aSenhas,iif(!PwCheck("31000"),999,NIL)})
    aadd(aUtilit,{" &2-Copia de seguranca     ",{|| nada()}})
    aadd(aUtilit,{" &3-Configura‡äes         >", aConfig,iif(!PwCheck("30003"),999,NIL)})
    aadd(aUtilit,{" &4-Exportar arquivo xml   ",{|| ExportaXml()}})
    aadd(aUtilit,{" &5-Resolucao da tela      ",{|| Teste()}})
    aadd(aUtilit,{" &6-Sobre                  ",{|| TelaAbout()}})

   // ** Clientes
   aadd(aClientes2,{" &1-Incluir   ",{||IncCliente()}   ,iif(!PwCheck("11101"),999,NIL)})
   aadd(aClientes2,{" &2-Alterar   ",{||AltCliente()}   ,iif(!PwCheck("11102"),999,NIL)})
   aadd(aClientes2,{" &3-Excluir   ",{||ExcCliente()}   ,iif(!PwCheck("11103"),999,NIL)})
   aadd(aClientes2,{" &4-Consultar ",{||ConCliente(.t.)},iif(!PwCheck("11104"),999,NIL)})
   
    // ** Grupo de clientes
   aadd(aGrupoCli,{" &1-Incluir   ",{|| IncGrupoCliente()},iif(!PwCheck("11201"),999,NIL)})
   aadd(aGrupoCli,{" &2-Alterar   ",{|| AltGrupoCliente()},iif(!PwCheck("11202"),999,NIL)})
   aadd(aGrupoCli,{" &3-Excluir   ",{|| ExcGrupoCliente()},iif(!PwCheck("11203"),999,NIL)})
   aadd(aGrupoCli,{" &4-Consultar ",{|| ConGrupoCliente(.t.)},iif(!PwCheck("11204"),999,NIL)})

   aadd(aClientes,{" &1-Clientes >",aClientes2,iif(!PwCheck("11100"),999,NIL)})
   aadd(aClientes,{" &2-Grupos   >",aGrupoCli ,iif(!PwCheck("11200"),999,NIL)})
//****************************
   // ** Fornecedores
   aadd(aFornece,{" &1-Incluir   ",{|| IncFornecedor()}   ,iif(!PwCheck("12001"),999,NIL)})
   aadd(aFornece,{" &2-Alterar   ",{|| AltFornecedor()}   ,iif(!PwCheck("12002"),999,NIL)})
   aadd(aFornece,{" &3-Excluir   ",{|| ExcFornecedor()}   ,iif(!PwCheck("12003"),999,NIL)})
   aadd(aFornece,{" &4-Consultar ",{|| ConFornecedor(.t.)},iif(!PwCheck("12004"),999,NIL)})

   // Cadastros/Produtos/Grupos de Produtos
   aadd(aGrupos,{" &1-Incluir   ",{|| IncGrupo()}       ,iif(!PwCheck("13201"),999,NIL)})
   aadd(aGrupos,{" &2-Alterar   ",{|| AltGrupo()}       ,iif(!PwCheck("13202"),999,NIL)})
   aadd(aGrupos,{" &3-Excluir   ",{|| ExcGrupo()}       ,iif(!PwCheck("13203"),999,NIL)})
   aadd(aGrupos,{" &4-Consultar ",{|| ConGrupo(.t.,.f.)},iif(!PwCheck("13204"),999,NIL)})

   // Cadastros/Produtos/Sub-Grupos
   aadd(aSubGrupo,{" &1-Incluir   ",&("{|| IncSubGrupo()}")   ,iif(!PwCheck("13301"),999,NIL)})
   aadd(aSubGrupo,{" &2-Alterar   ",&("{|| AltSubGrupo()}")   ,iif(!PwCheck("13302"),999,NIL)})
   aadd(aSubGrupo,{" &3-Excluir   ",&("{|| ExcSubGrupo()}")   ,iif(!PwCheck("13303"),999,NIL)})
   aadd(aSubGrupo,{" &4-Consultar ",&("{|| ConSubGrupo(.t.)}"),iif(!PwCheck("13304"),999,NIL)})
   
    MenuProdutos()
    
    // Cadastros/Produtos/fabricantes
    aadd(aFabricante,{" &1-Incluir   ",{|| IncFabricante()}       ,iif(!PwCheck("13401"),999,NIL)})
    aadd(aFabricante,{" &2-Alterar   ",{|| AltFabricante()}       ,iif(!PwCheck("13402"),999,NIL)})
    aadd(aFabricante,{" &3-Excluir   ",{|| ExcFabricante()}       ,iif(!PwCheck("13403"),999,NIL)})
    aadd(aFabricante,{" &4-Consultar ",{|| ConFabricante(.t.,.f.)},iif(!PwCheck("13404"),999,NIL)})
    
    // Cadastros/Produtos/Unidade de medida
    aadd(aUnidMed,{" &1-Incluir   ",{|| IncUnidMed()},iif(!PwCheck("13501"),999,NIL)})
    aadd(aUnidMed,{" &2-Alterar   ",{|| AltUnidMed()},iif(!PwCheck("13502"),999,NIL)})
    aadd(aUnidMed,{" &3-Excluir   ",{|| ExcUnidMed()},iif(!PwCheck("13503"),999,NIL)})
    aadd(aUnidMed,{" &4-Consultar ",{|| ConUnidMed(.t.)},iif(!PwCheck("13504"),999,NIL)})

    MenuProdutoFornecedor()
    
    // Cadastros/Produtos/Importar XML
    aadd(aImportaXml,{" &1-Importar XML          ",{|| ImportarXml()}        ,iif(!PwCheck("13701"),999,NIL)})
    aadd(aImportaXml,{" &2-Atualizar dados       ",{|| AtualizarProdutoXml()},iif(!PwCheck("13702"),999,NIL)})
    aadd(aImportaXml,{" &3-Excluir XML importado ",{|| ExcluirXml()}         ,iif(!PwCheck("13703"),999,NIL)})
    aadd(aImportaXml,{" &4-Consultar XML         ",{|| ConXml()}             ,iif(!PwCheck("13704"),999,NIL)})

    
    // Cadastros/Produtos/Produtos
    aadd(aProdutos,{" &1-Produtos               >",aProdutos2 ,iif(!PwCheck("13100"),999,NIL)})
    aadd(aProdutos,{" &2-Grupos                 >",aGrupos    ,iif(!PwCheck("13200"),999,NIL)})
    aadd(aProdutos,{" &3-Sub-Grupo              >",aSubGrupo  ,iif(!PwCheck("13300"),999,NIL)})
    aadd(aProdutos,{" &4-Fabricantes            >",aFabricante,iif(!PwCheck("13400"),999,NIL)})
    aadd(aProdutos,{" &5-Unidade de Medida      >",aUnidMed   ,iif(!PwCheck("13500"),999,NIL)})
    aadd(aProdutos,{" &6-Produtos do Fornecedor >",aProdFor   ,iif(!PwCheck("13600"),999,NIL)})
    aadd(aProdutos,{" &7-Importar XML           >",aImportaXml,iif(!PwCheck("13700"),999,NIL)})
   
   // Cadastros/Financeiro/Duplicatas/A receber/Baixa individual
   aadd(aBaixaDuplNormal,{" &1-Baixar          ",{|| BxaDupRec()},iif(!PwCheck("1410171"),999,NIL)})
   aadd(aBaixaDuplNormal,{" &2-Cancelar baixar ",{|| CbxDupRec()},iif(!PwCheck("1410172"),999,NIL)})
   
   // Cadastros/Financeiro/Duplicatas/A receber/Baixa Selecionadada
   aadd(aBaixaDuplGeral,{" &1-Baixar          ",{|| IncBaixaGeral()}   ,iif(!PwCheck("1410181"),999,NIL)})
   aadd(aBaixaDuplGeral,{" &2-Imprimir recibo ",{|| ImpBaixaGeral()}   ,iif(!PwCheck("1410182"),999,NIL)})
   aadd(aBaixaDuplGeral,{" &3-Consultar       ",{|| ConBaixaGeral(.t.)},iif(!PwCheck("1410183"),999,NIL)})
   aadd(aBaixaDuplGeral,{" &4-Cancelar baixa  ",{|| CanBaixaGeral()}   ,iif(!PwCheck("1410184"),999,NIL)})
	
   // ** Duplicatas a Receber
   	aadd(aDuplRec,{" &1-Incluir              ",{|| IncDupRec()}    ,iif(!PwCheck("141011"),999,NIL)})
   	aadd(aDuplRec,{" &2-Alterar              ",{|| AltDupRec()}    ,iif(!PwCheck("141012"),999,NIL)})
   	aadd(aDuplRec,{" &3-Excluir              ",{|| ExcDupRec()}    ,iif(!PwCheck("141013"),999,NIL)})
   	aadd(aDuplRec,{" &4-Consultar            ",{|| ConDupRec(.t.)} ,iif(!PwCheck("141014"),999,NIL)})
   	aadd(aDuplRec,{" &5-imprimir recibo      ",{|| ImpRecibo()}    ,iif(!PwCheck("141015"),999,NIL)})
    aadd(aDuplRec,{" &6-Imprimir Carne       ",{|| ImprimirCarne()},iif(!PwCheck("141016"),999,NIL)})
   	aadd(aDuplRec,{" &7-Baixa individual    >",aBaixaDuplNormal    ,iif(!PwCheck("141017"),999,NIL)})
   	aadd(aDuplRec,{" &8-Baixa selecionada   >",aBaixaDuplGeral     ,iif(!PwCheck("141018"),999,NIL)})
   	aadd(aDuplRec,{" &9-Conf. Lanc. no Caixa ",{|| ConfLancRx()}   ,iif(!PwCheck("141019"),999,NIL)})
   	

   // Cadastros/Financeiro/Duplicatas/A Pagar
   aadd(aDuplPag,{" &1-Incluir              ",{|| IncDupPag() },iif(!PwCheck("141021"),999,NIL)})
   aadd(aDuplPag,{" &2-Alterar              ",{|| AltDupPag() },iif(!PwCheck("141022"),999,NIL)})
   aadd(aDuplPag,{" &3-Excluir              ",{|| ExcDupPag() },iif(!PwCheck("141023"),999,NIL)})
   aadd(aDuplPag,{" &4-Consultar            ",{|| ConDupPag() },iif(!PwCheck("141024"),999,NIL)})
   aadd(aDuplPag,{" &5-Baixa                ",{|| BxaDupPag() },iif(!PwCheck("141025"),999,NIL)})
   aadd(aDuplPag,{" &6-Cancela a Baixa      ",{|| CbxDupPag() },iif(!PwCheck("141026"),999,NIL)})
   aadd(aDuplPag,{" &7-Conf. Lanc. no Caixa ",{|| ConfLancAx()},iif(!PwCheck("141027"),999,NIL)})
   aadd(aDuplPag,{" &8-Importar do XML      ",{|| Nada()}      ,iif(!PwCheck("141028"),999,NIL)})

   // ** Duplicatas
   aadd(aDuplicata,{" &1-A Receber "+">",aDuplRec,iif(!PwCheck("14101"),999,NIL)})
   aadd(aDuplicata,{" &2-A Pagar   "+">",aDuplPag,iif(!PwCheck("14102"),999,NIL)})


   // ** Caixa
   aadd(aCaixa1,{" &1-Incluir   ",{|| IncCaixa()}})
   aadd(aCaixa1,{" &2-Alterar   ",{|| AltCaixa()}})
   aadd(aCaixa1,{" &3-Excluir   ",{|| ExcCaixa()}})
   aadd(aCaixa1,{" &4-Consultar ",{|| ConCaixa()}})

   // ** Historico de Lancamentos do Caixa
   aadd(aHistCxa,{" &1-Incluir   ",{|| IncHistCxa()}})
   aadd(aHistCxa,{" &2-Alterar   ",{|| AltHistCxa()}})
   aadd(aHistCxa,{" &3-Excluir   ",{|| ExcHistCxa()}})
   aadd(aHistCxa,{" &4-Consultar ",{|| ConHistCxa(.t.)}})

   // ** Formas de Pagamento dos Lancamentos dos Caixa
   aadd(aFPagtoCxa,{" &1-Incluir   ",{|| IncFPagCxa()}})
   aadd(aFPagtoCxa,{" &2-Alterar   ",{|| AltFPagCxa()}})
   aadd(aFPagtoCxa,{" &3-Excluir   ",{|| ExcFPagCxa()}})
   aadd(aFPagtoCxa,{" &4-Consultar ",{|| ConFPagCxa()}})


   // ** Op×"es do Caixa
   aadd(aCaixa,{" &1-Caixas              "+">",aCaixa1   })
   aadd(aCaixa,{" &2-Historico Padrao    "+">",aHistCxa  })
   aadd(aCaixa,{" &3-Formas de Pagamento "+">",aFPagtoCxa})


   // ** Bancos
   aadd(aBancos1,{" &1-Incluir   ",{|| IncBancos(.t.)}})
   aadd(aBancos1,{" &2-Alterar   ",{|| AltBancos()}})
   aadd(aBancos1,{" &3-Excluir   ",{|| ExcBancos()}})
   aadd(aBancos1,{" &4-Consultar ",{|| ConBancos(.t.)}})

   // ** Hist«ricos do Movimento de Banco
   aadd(aHistBan,{" &1-Incluir   ",{|| IncHistBan()}})
   aadd(aHistBan,{" &2-Alterar   ",{|| AltHistBan()}})
   aadd(aHistBan,{" &3-Excluir   ",{|| ExcHistBan()}})
   aadd(aHistBan,{" &4-Consultar ",{|| ConHistBan(.t.)}})

   // ** Movimento de Bancos
   aadd(aMovBan,{" &1-Incluir   ",{|| IncMovBan()}   })
   aadd(aMovBan,{" &2-Alterar   ",{|| AltMovBan()}   })
   aadd(aMovBan,{" &3-Excluir   ",{|| ExcMovBan()}   })
   aadd(aMovBan,{" &4-Consultar ",{|| ConMovBan(.t.)}})

   // ** Op×"es de Bancos
   aadd(aBancos,{" &1-Bancos             >",aBancos1})
   aadd(aBancos,{" &2-Historico Bancario >",aHistBan})
   aadd(aBancos,{" &3-Movimento          >",aMovBan })
   aadd(aBancos,{" &4-Recalcular Saldo   ",{|| CalcBan() }})

   // ** Cadastos/Vendedores
   aadd(aVendedor,{" &1-Incluir   ",{|| IncVendedor()},iif(!PwCheck("19101"),999,NIL)})
   aadd(aVendedor,{" &2-Alterar   ",{|| AltVendedor()},iif(!PwCheck("19102"),999,NIL)})
   aadd(aVendedor,{" &3-Excluir   ",{|| ExcVendedor()},iif(!PwCheck("19103"),999,NIL)})
   aadd(aVendedor,{" &4-Consultar ",{|| ConVendedor(.t.)},iif(!PwCheck("19104"),999,NIL)})

   // ** Cidades
   aadd(aCidades,{" &1-Incluir   ",{||IncCidades(.t.)}    })
   aadd(aCidades,{" &2-Alterar   ",{||AltCidades()}       })
   aadd(aCidades,{" &3-Excluir   ",{||ExcCidades()}       })
   aadd(aCidades,{" &4-Consultar ",{||ConCidades(.t.,.f.)}})

   // ** Estados
   aadd(aEstados,{" &1-Incluir   ",{|| IncEstados()}})
   aadd(aEstados,{" &2-Alterar   ",{|| AltEstados()}})
   aadd(aEstados,{" &3-Excluir   ",{|| ExcEstados()}})
   aadd(aEstados,{" &4-Consultar ",{|| ConEstados()}})

   // ** Plano de Pagamentos
   aadd(aPlanos,{" &1-Incluir ",{|| IncPlano()}  })
   aadd(aPlanos,{" &2-Alterar ",{|| AltPlano()}  })
   aadd(aPlanos,{" &3-Excluir ",{|| ExcPlano()}  })
   aadd(aPlanos,{" &4-Consultar ",{|| ConPlano(.t.)}})

   // ** Cheques
   aadd(aCheques,{" &1-Incluir         ",{|| IncCheques()}   })
   aadd(aCheques,{" &2-Alterar         ",{|| AltCheques()}   })
   aadd(aCheques,{" &3-Excluir         ",{|| ExcCheques()}   })
   aadd(aCheques,{" &4-Consultar       ",{|| ConCheques(.t.)}})
   aadd(aCheques,{" &5-Baixa           ",{|| BxaCheques()}   })
   aadd(aCheques,{" &6-Cancela Baixa   ",{|| CxaCheques()}   })
   aadd(aCheques,{" &7-ImPrimir Recibo ",{|| ImpRChq()}      })

   // ** Negociador de Cheques
   aadd(aNegociado,{" &1-Incluir   ",&("{|| IncNegociad() }")})
   aadd(aNegociado,{" &2-Alterar   ",&("{|| AltNegociad() }")})
   aadd(aNegociado,{" &3-Excluir   ",&("{|| ExcNegociad() }")})
   aadd(aNegociado,{" &4-Consultar ",&("{|| ConNegociad() }")})

   // ** Negociar Cheques
   aadd(aNegociar,{" &1-Incluir   ",{|| IncNegoci() }})
   aadd(aNegociar,{" &2-Alterar   ",{|| AltNegoci() }})
   aadd(aNegociar,{" &3-Excluir   ",{|| ExcNegoci() }})
   aadd(aNegociar,{" &4-Consultar ",{|| ConNegoci(.t.) }})
   aadd(aNegociar,{" &5-Imprimir  ",{|| ImpNegoci() }})

   aadd(aCheque,{" &1-Cheques    >",aCheques})
   aadd(aCheque,{" &2-Negociador >",aNegociado})
   aadd(aCheque,{" &3-Negociar   >",aNegociar})

   // ** Transportadora
   aadd(aTranspo,{" &1-Incluir   ",{|| IncTranspo(.t.)}})
   aadd(aTranspo,{" &2-Alterar   ",{|| AltTranspo()}})
   aadd(aTranspo,{" &3-Excluir   ",{|| ExcTranspo()}})
   aadd(aTranspo,{" &4-Consultar ",{|| ConTranspo()}})

   // ** Natureza Fiscal
   aadd(aNatureza,{" &1-Incluir   ",{|| IncNatureza() }})
   aadd(aNatureza,{" &2-Alterar   ",{|| AltNatureza() }})
   aadd(aNatureza,{" &3-Excluir   ",{|| ExcNatureza() }})
   aadd(aNatureza,{" &4-Consultar ",{|| ConNatureza(.t.) }})

   // ** Situa×'o Tribut˜ria
   aadd(aSitTrib,{" &1-Incluir   ",{|| IncSitTrib() }})
   aadd(aSitTrib,{" &2-Alterar   ",{|| AltSitTrib() }})
   aadd(aSitTrib,{" &3-Excluir   ",{|| ExcSitTrib() }})
   aadd(aSitTrib,{" &4-Consultar ",{|| ConSitTrib(.t.) }})
   
   
   // ** Financeiro
	aadd(aFinance,{" &1-Caixa                   >",aCaixa    ,iif(!PwCheck("17000"),999,NIL)})
	aadd(aFinance,{" &2-Bancos                  >",aBancos   ,iif(!PwCheck("18000"),999,NIL)})
	aadd(aFinance,{" &3-Cheques                 >",iif(PwNivel == "0",aCheque,aCheques)})
	aadd(aFinance,{" &4-Planos de PagamenTo     >",aPlanos})
	aadd(aFinance,{" &5-Credenciadora de Cartao >",aCredCartao})   	

   // ** Entrada
   aadd(aEntrada,{" &1-Incluir    ",{|| IncCompra()},iif(!PwCheck("15101"),999,NIL)})
   aadd(aEntrada,{" &2-Alterar    ",{|| AltCompra()},iif(!PwCheck("15102"),999,NIL)})
   aadd(aEntrada,{" &3-Excluir    ",{|| ExcCompra()},iif(!PwCheck("15103"),999,NIL)})
   aadd(aEntrada,{" &4-Consultar  ",{|| ConCompra(.t.)},iif(!PwCheck("15104"),999,NIL)})

	aadd(aCCe,{" &1-Incluir   ",{|| IncluirCartaCorrecao() }})
	aadd(aCCe,{" &2-Imprimir  ",{|| ImprimirCartaDeCorrecao() }})
	aadd(aCCe,{" &4-Consultar ",{|| nada() }})
   


   // Cadastros/Propostas
   aadd(aPedido,{" &1-Incluir   ",{|| IncPedidos()}   ,iif(!PwCheck("16101"),999,NIL)})
   aadd(aPedido,{" &2-Alterar   ",{|| AltPedidos()}   ,iif(!PwCheck("16102"),999,NIL)})
   aadd(aPedido,{" &3-Excluir   ",{|| ExcPedidos()}   ,iif(!PwCheck("16103"),999,NIL)})
   aadd(aPedido,{" &4-Consultar ",{|| ConPedidos(.t.)},iif(!PwCheck("16104"),999,NIL)})
   aadd(aPedido,{" &5-ImPrimir  ",{|| ImpPedidos()}   ,iif(!PwCheck("16105"),999,NIL)})
   
   //aadd(aPedido,{" Imp. cupom nao &fiscal ",{|| ImpCupomNaoFiscal()}})
   aadd(aOrcamentos,{" &1-Incluir   ",{|| IncOrcamentos()}   ,iif(!PwCheck("16101"),999,NIL)})
   aadd(aOrcamentos,{" &2-Alterar   ",{|| AltOrcamentos()}   ,iif(!PwCheck("16102"),999,NIL)})
   aadd(aOrcamentos,{" &3-Excluir   ",{|| ExcOrcamentos()}   ,iif(!PwCheck("16103"),999,NIL)})
   aadd(aOrcamentos,{" &4-Consultar ",{|| ConOrcamentos(.t.)},iif(!PwCheck("16104"),999,NIL)})
   aadd(aOrcamentos,{" &5-ImPrimir  ",{|| ImpOrcamentos()}   ,iif(!PwCheck("16105"),999,NIL)})
   

   // ** Nota Fiscal Avulsa
   aadd(aNotaAvu,{" &Incluir   ",&("{|| IncNotaSAV() }")})
   aadd(aNotaAvu,{" &Alterar   ",&("{|| AltNotaSAV() }")})
   aadd(aNotaAvu,{" &Excluir   ",&("{|| ExcNotaSAV() }")})
   aadd(aNotaAvu,{" Con&Sultar ",&("{|| ConNotaSaV(.t.)}")})

	aadd(aNFCe,{" &1-Incluir                  ",{|| IncNFCe()}})
    aadd(aNFCe,{" &2-Alterar                  ",{|| AltNFCe()}})
	aadd(aNFCe,{" &3-Excluir (Lan‡amento)     ",{|| ExcNFce()}})
	aadd(aNFCe,{" &4-Consultar                ",{|| ConNFCe(.t.)}})
	aadd(aNFCe,{" &5-Cancelar  NFC-e          ",{|| CanNFCe()}})
	aadd(aNFCe,{" &6-Consultar NFC-e na SEFAZ ",{|| ConNFCeSEFAZ()}})
    aadd(aNFCe,{" &7-Enviar NFC-e por e-mail  ",{|| EmailNFCe()}})
	aadd(aNFCe,{" &8-Transmitir               ",{|| TranNFCe()}})
	aadd(aNFCe,{" &9-Imprimir DANFE           ",{|| ImpNFCe() }})
	aadd(aNFCe,{" &A-Status Servi‡o           ",{|| StatusServicoNFCe()}})
    
   // ** Saida - Nota Fiscal Eletr"nica
	aadd(aNotaNFE,{" &1-Incluir                   ",{|| IncNotaNFE() }})
    aadd(aNotaNFE,{" &2-Alterar                   ",{|| Nada()}})
    aadd(aNotaNFE,{" &3-Excluir                   ",{|| Nada()}})
    aadd(aNotaNFE,{" &4-Consultar                 ",{|| ConNotaNFE(.t.) }})    
	aadd(aNotaNFE,{" &5-Transmitir                ",{|| TransNFE() }})
	aadd(aNotaNFE,{" &6-Cancelar                  ",{|| CancelaNFE() }})
	aadd(aNotaNFE,{" &7-ImPrimir DANFE            ",{|| ImprimiDANFE() }})
	aadd(aNotaNFE,{" &8-Consultar na SEFAZ        ",{|| ConsultarNFeSEFAZ() }})
	aadd(aNotaNFE,{" &9-Enviar NFe por email      ",{|| EnviarEmailNFE() }})
	aadd(aNotaNFE,{" &0-Inutilizar NFE            ",{|| NFeInutiliza()}})
	aadd(aNotaNFE,{" &A-Consultar NFE inutilizada ", {|| NFeInutilizadaConsulta() }})
	aadd(aNotaNFe,{" &B-Carta de Correcao         >",aCCE})

    // Nota fiscal de devolu‡Æo    
    aadd(aNfeDev,{" &1-Incluir                 ",{|| IncNfeDev()}})
    aadd(aNfeDev,{" &2-Alterar                 ",{|| AltNfeDev()}})
    aadd(aNfeDev,{" &3-Excluir (lan‡amento)    ",{|| ExcNfeDev()}})
    aadd(aNfeDev,{" &4-Consultar               ",{|| ConNfeDev(.t.,.f.) }})
    aadd(aNfeDev,{" &5-Cancelar NF-e           ",{|| CanNfeDev() }})
	aadd(aNfeDev,{" &6-Consultar NF-e na SEFAZ ",{|| SefazDev() }})
    aadd(aNfeDev,{" &7-Enviar NF-e por email   ",{|| nada() }})
	aadd(aNfeDev,{" &8-Transmitir              ",{|| TraNfeDev() }})
    aadd(aNfeDev,{" &9-Imprimir DANFE          ",{|| ImpNfeDev() }})
    aadd(aNfeDev,{" &0-Status do servi‡o       ",{|| StatusServicoNFe()}})
    
    // Nota Fiscal de entrada
    aadd(aNfeEntrada,{" &1-Incluir                 ",{|| IncNfeEntrada()}})
    aadd(aNfeEntrada,{" &2-Alterar                 ",{|| Nada()}})
    aadd(aNfeEntrada,{" &3-Excluir (lan?amento)    ",{|| Nada()}})
    aadd(aNfeEntrada,{" &4-Consultar               ",{|| ConNfeEntrada(.t.,.f.)}})
    aadd(aNfeEntrada,{" &5-Cancelar NF-e           ",{|| CancNfeEntrada()}})
    aadd(aNfeEntrada,{" &6-Consultar Nf-e na SEFAZ ",{||ConNfeEntradaSefaz()}})
    aadd(aNfeEntrada,{" &7-Enviar NF-e por email   ",{|| nada() }})
	aadd(aNfeEntrada,{" &8-Transmitir              ",{|| TransNfeEntrada() }})
    aadd(aNfeEntrada,{" &9-Imprimir DANFE          ",{|| ImpNfeEntrada() }})
    aadd(aNfeEntrada,{" &0-Status do servi?o       ",{|| StatusServicoNFe()}})
        

	
    aadd(aNFe,{" &1-Sa¡da     >",aNotaNfe})
    aadd(aNFe,{" &2-Devolu‡Æo >",aNfeDev}) 
    aadd(aNfe,{" &3-Entrada   >",aNfeEntrada})  

	aadd(aNCM,{" &1-Incluir   ",{|| IncNCM()}})
	aadd(aNCM,{" &2-Alterar   ",{|| AltNCM()}})
	aadd(aNCM,{" &3-Excluir   ",{|| ExcNCM()}})
	aadd(aNCM,{" &4-Consultar ",{|| ConNCM(.t.)}})

	aadd(aCFOP,{" &1-Incluir   ",{|| IncCfop()}})
	aadd(aCFOP,{" &2-Alterar   ",{|| AltCfop()}})
	aadd(aCFOP,{" &3-Excluir   ",{|| ExcCfop()}})
	aadd(aCFOP,{" &4-Consultar ",{|| ConCfop(.t.)}})
	
	aadd(aFiscal,{" &1-Natureza Fiscal     >",aNatureza})
	aadd(aFiscal,{" &2-Situacao Tributaria >",aSitTrib })
	aadd(aFiscal,{" &3-Tabela de NCM       >",aNCM})
	aadd(aFiscal,{" &4-CFOP                >",aCFOP})
	
	MenuCredenciadoraDeCartao()

    aadd(aMovVendas,{" &1-Propostas  >",aPedido})
    aadd(aMovVendas,{" &2-Or‡amentos >",aOrcamentos})

    // ** Movimento do Lan×amento do Caixa
    aadd(aMovCxa,{" &1-Incluir          ",{|| IncMovCxa()}})
    aadd(aMovCxa,{" &2-Alterar          ",{|| AltMovCxa()}})
    aadd(aMovCxa,{" &3-Excluir          ",{|| ExcMovCxa()}})
    aadd(aMovCxa,{" &4-Consultar        ",{|| ConMovCxa(.t.)}})
    aadd(aMovCxa,{" &5-Recalcula Saldos ",{|| CalcSaldo()}})
    aadd(aMovCxa,{" &6-Fechar Movimento ",{|| FecharMov()}})
    aadd(aMovCxa,{" &7-Abrir Movimento  ",{|| AbrirMov()}})

    aadd(aMovFinanceiro,{" &1-Movimento do caixa   >",aMovCxa})
    aadd(aMovFinanceiro,{" &2-Duplicatas a receber >",aDuplRec})
    aadd(aMovFinanceiro,{" &3-Duplicatas a pagar   >",aDuplPag})
    aadd(aMovFinanceiro,{" &4-Movimento banc rio   >",aDuplPag})


    aadd(aMovNotas,{" &1-NF-e   >",aNFe})
    aadd(aMovNotas,{" &4-NFC-e  >",aNFCE})

    aadd(aEstoque,{" &1-Entrada  >",aEntrada})

    aadd(aMov,{" &1-Vendas       >",aMovVendas})
    aadd(aMov,{" &2-Financeiro   >",aMovFinanceiro})
    aadd(aMov,{" &3-Estoque      >",aEstoque})
    aadd(aMov,{" &4-Notas Ficais >",aMovNotas})

   // ** Opcoes do Cadastro
	aadd(aCadastro,{" &1-Clientes         >",aClientes ,iif(!PwCheck("11000"),999,NIL)})
	aadd(aCadastro,{" &2-Fornecedores     >",aFornece  ,iif(!PwCheck("12000"),999,NIL)})
	aadd(aCadastro,{" &3-Produtos         >",aProdutos ,iif(!PwCheck("13000"),999,NIL)})
	aadd(aCadastro,{" &4-Financeiro       >",aFinance  ,iif(!PwCheck("14000"),999,NIL)})
	aadd(aCadastro,{" &5-Vendedores       >",aVendedor ,iif(!PwCheck("19000"),999,NIL)})
	aadd(aCadastro,{" &6-Cidades          >",aCidades  ,iif(!PwCheck("1A000"),999,NIL)})
	aadd(aCadastro,{" &7-Estados          >",aEstados  ,iif(!PwCheck("1B000"),999,NIL)})
	aadd(aCadastro,{" &8-Transportadoras  >",aTranspo  ,iif(!PwCheck("1E000"),999,NIL)})
    if nTipoEstoque = 0    	
	    aadd(aCadastro,{" &9-Fiscal           >",aFiscal})
    endif

   // ** Relat«rios de Clientes
   aadd(aRelCli,{" &1-Cadastro     ",{|| RelCli1() }})
   aadd(aRelCli,{" &2-Telefones    ",{|| RelCli2() }})
   aadd(aRelCli,{" &3-Por cidade   ",{|| RelCli3() }})
   aadd(aRelCli,{" &4-Por vendedor ",{|| RelCli4() }})
   aadd(aRelCli,{" &5-Ranking      ",{|| RelCli5() }})

   // ** Relat«rio de Fornecedores
   aadd(aRelFor,{" &1-Cadastro  ",{|| RelFor1()} })
   aadd(aRelFor,{" &2-Telefones ",{|| RelFor2()} })

   // ** Relatorio de Caixa
   aadd(aRelCxa,{" &1-Relatorio dos caixa               ",{|| RelCxa1()}})
   aadd(aRelCxa,{" &2-Relatorio dos historico padrao    ",{|| RelCxa2()}})
   aadd(aRelCxa,{" &3-Formas de pagamento               ",{|| RelCxa3()}})
   aadd(aRelCxa,{" &4-Conferencia do movimento do caixa ",{|| RelCxa4()}})
   aadd(aRelCxa,{" &5-Resumo do movimento do caixa      ",{|| RelCxa7()}})

   // ** Relat«rios de Bancos
   aadd(aRelBan,{" &1-Bancos             ",{|| RelBan1()}})
   aadd(aRelBan,{" &2-Historico bancario ",{|| RelBan2()}})
   aadd(aRelBan,{" &3-Movimento          ",{|| RelBan3()}})

   // ** Relat«rios de Duplicatas A Receber
   aadd(aRelDupRec,{" &1-No periodo por cliente ",{|| RelRec1()},iif(!PwCheck("25111"),999,NIL)})
   aadd(aRelDupRec,{" &2-No periodo por dia     ",{|| RelRec2()},iif(!PwCheck("25112"),999,NIL)})
   aadd(aRelDupRec,{" &3-Extrato do cliente     ",{|| RelRec3()},iif(!PwCheck("25113"),999,NIL)})

   // ** Relat«rio de Duplicatas a Pagar
   aadd(aRelDupPag,{" &1-No Periodo por fornecedor ",{|| RelPag1()},iif(!PwCheck("25121"),999,NIL)})
   aadd(aRelDupPag,{" &2-No Periodo por dia        ",{|| RelPag2()},iif(!PwCheck("25122"),999,NIL)})
   aadd(aRelDupPag,{" &3-Extrato do fornecedor     ",{|| RelPag3()},iif(!PwCheck("25123"),999,NIL)})

   aadd(aRelDup,{" &1-A receber "+">",aRelDupRec,iif(!PwCheck("25110"),999,NIL)})
   aadd(aRelDup,{" &2-A pagar   "+">",aRelDupPag,iif(!PwCheck("25120"),999,NIL)})

   aadd(aRelCheq,{" &1-Extrato     ",{|| RelCheq1() }})
   aadd(aRelCheq,{" &2-Por periodo ",{|| RelCheq2() }})
   aadd(aRelCheq,{" &3-Digitados   ",{|| RelCheq3() }})
   aadd(aRelCheq,{" &4-Negociados  ",{|| RelCheq4() }})

   aadd(aRelFinan,{" &1-Duplicatas                >",aRelDup,iif(!PwCheck("25100"),999,NIL)})
   aadd(aRelFinan,{" &2-Caixa                     >",aRelCxa,iif(!PwCheck("25200"),999,NIL)})
   aadd(aRelFinan,{" &3-Bancos                    >",aRelBan,iif(!PwCheck("25300"),999,NIL)})
   aadd(aRelFinan,{" &4-Cheques                   >",aRelCheq,iif(!PwCheck("25400"),999,NIL)})
   aadd(aRelFinan,{" &5-Comissao de Vendedores     ",{|| RelComi1()},iif(!PwCheck("25500"),999,NIL)})
   aadd(aRelFinan,{" &6-Lucro presumido de vendas  ",{|| RelLucroVenda()},iif(!PwCheck("25500"),999,NIL)}) 

   // ** Entradas
   aadd(aRelEntra,{" &1-Por per¡odo                     ",{|| RelComp1() }})
   aadd(aRelEntra,{" &2-Produtos por per­odo (resumido) ",{|| RelComp2() }})
   aadd(aRelEntra,{" &3-Completo                        ",{|| RelComp3() }})

   // ** Relat«rios de Produtos
   	aadd(aRelProd,{" &1-Tabela de Preco            ",{|| RelProd1()},iif(!PwCheck("24100"),999,NIL)})
   	aadd(aRelProd,{" &2-Estoque Inicial            ",{|| Nada()}    ,iif(!PwCheck("24200"),999,NIL)})      
   	aadd(aRelProd,{" &3-Conferenca do Estoque      ",{|| RelProd2()},iif(!PwCheck("24300"),999,NIL)})
   	aadd(aRelProd,{" &4-Ficha do Produto           ",{|| RelProd3()},iif(!PwCheck("24400"),999,NIL)})
   	aadd(aRelProd,{" &5-Curva ABC                  ",{|| RelProd4()},iif(!PwCheck("24500"),999,NIL)})
   	aadd(aRelProd,{" &6-Inventario                 ",{|| RelProd5()},iif(!PwCheck("24600"),999,NIL)})
   	aadd(aRelProd,{" &7-Entrada/Saida              ",{|| RelProd6()},iif(!PwCheck("24700"),999,NIL)})
   	aadd(aRelProd,{" &8-Saldos( Estoque )          ",{|| RelProd7()},iif(!PwCheck("24800"),999,NIL)})
	aadd(aRelProd,{" &9-Produtos (Custo/Venda)     ",{|| Relprod8()},iif(!PwCheck("24900"),999,NIL)})
    aadd(aRelProd,{" &0-Produtos sem NCM           ",{|| RelProdSemNCM()},iif(!PwCheck("24A00"),999,NIL)})
    aadd(aRelProd,{" &A-Produtos NCM/CEST/CFOP/CST ",{|| RelProdA()},iif(!PwCheck("24B00"),999,NIL)})
    aadd(aRelProd,{" &B-Rela‡Æo de produtos        ",{|| RelProdB()},iif(!PwCheck("24B00"),999,NIL)})
    

   // ** Relatorios de Pedidos
   aadd(aRelPed,{" &1-Por per¡odo         ",{|| RelPed1()}})
   aadd(aRelPed,{" &2-Por cliente         ",{|| RelPed2()}})
   aadd(aRelPed,{" &3-Por vendedor        ",{|| RelPed3()}})
   aadd(aRelPed,{" &4-Por plano de pagto. ",{|| RelPed4()}})

    // ** Relat«rio de Saida
    aadd(aRelSaida,{" &1-Romaneio          ",{|| RelSaid1() }})
    aadd(aRelSaida,{" &2-Proposta          >",aRelPed})
    aadd(aRelSaida,{" &3-Notas por per¡odo ",{|| RelSaida3()}})
    aadd(aRelSaida,{" &4-Por produtos      ",{|| RelSaida4()}})
    

   aadd(aRelat,{" &1-Clientes             "+">",aRelCli,iif(!PwCheck("21000"),999,NIL)})
   aadd(aRelat,{" &2-Fornecedores         "+">",aRelFor,iif(!PwCheck("22000"),999,NIL)})
   aadd(aRelat,{" &3-Grupos               ",{|| RelGrupo()},iif(!PwCheck("23000"),999,NIL)})
   aadd(aRelat,{" &4-Produtos             "+">",aRelProd,iif(!PwCheck("24000"),999,NIL)})
   aadd(aRelat,{" &5-FinAnceiro           "+">",aRelFinan,iif(!PwCheck("25000"),999,NIL)})
   aadd(aRelat,{" &6-Entrada              "+">",aRelEntra,iif(!PwCheck("26000"),999,NIL)})
   aadd(aRelat,{" &7-Saida                "+">",aRelSaida,iif(!PwCheck("27000"),999,NIL)})
   aadd(aRelat,{" &8-Cidades              ",{|| RelCida()},iif(!PwCheck("28000"),999,NIL)})
   aadd(aRelat,{" &9-Natureza Fiscal      ",{|| RelNatur() }})
   aadd(aRelat,{" &0-Atividade do Usuario ",{|| RelAtiv()}})

   aMenu := {}
   aadd(aMenu,{" &Movimenta‡äes ",aMov})
   aadd(aMenu,{" &Cadastros     ",aCadastro,iif(!PwCheck("10000"),999,NIL)})
   aadd(aMenu,{" &Relat¢rios    ",aRelat   ,iif(!PwCheck("20000"),999,NIL)})   
   aadd(aMenu,{" &Utilit rios   ",aUtilit  ,iif(!PwCheck("30000"),999,NIL)})
   setcursor(0)
   Msg(.f.)
    do while .t.
        lSAIDA := .F.
        lPAD   := .F.
        Menu(aMenu,"LtAdmS v"+cVersao,rtrim(cEmpFantasia),"| Usuario: "+left(rtrim(PwNome),10)+" IP: "+cHost)
        IF !lSAIDA
            if Alerta("Confirma Sa¡da do Sistema",MB_YESNO,MB_ICONQUESTION) == IDYES
                exit
            endif
        endif
    enddo 
    setcursor(1)
    set color to
    cls
return nil
// ********************************************************************************************************   
static procedure MenuCredenciadoraDeCartao

   aadd(aCredCartao,{" &1-Incluir   ",{|| IncCredCartao()}})
   aadd(aCredCartao,{" &2-Alterar   ",{|| AltCredCartao()}})
   aadd(aCredCartao,{" &3-Excluir   ",{|| ExcCredCartao()}})
   aadd(aCredCartao,{" &4-ConSultar ",{|| ConCredCartao(.t.)}})
return
// ********************************************************************************************************   
static procedure MenuProdutoFornecedor
    aadd(aProdFor,{" &1-Incluir   ",{|| IncProdFor()}})
    aadd(aProdFor,{" &2-Alterar   ",{|| AltProdFor()}})
    aadd(aProdFor,{" &3-Excluir   ",{|| ExcProdFor()}})
    aadd(aProdFor,{" &4-Consultar ",{|| ConProdFor(.t.)}})
return
// ********************************************************************************************************
static procedure MenuProdutos

    aadd(aTransfProd,{" &1-Incluir   ",{|| IncTransfProd()}})
    aadd(aTransfProd,{" &2-Excluir   ",{|| ExcTransfProd()}})
    aadd(aTransfProd,{" &3-Consultar ",{|| ConTransfProd(.t.)}})
	// ** Produtos
	aadd(aProdutos2,{" &1-Incluir                ",{|| IncProduto()}   ,iif(!PwCheck("13101"),999,NIL)})
	aadd(aProdutos2,{" &2-Alterar                ",{|| AltProduto()}   ,iif(!PwCheck("13102"),999,NIL)})
	aadd(aProdutos2,{" &3-Excluir                ",{|| ExcProduto()}   ,iif(!PwCheck("13103"),999,NIL)})
	aadd(aProdutos2,{" &4-Consulta Geral         ",{|| ConProduto(.t.)},iif(!PwCheck("13104"),999,NIL)})
	aadd(aProdutos2,{" &5-Consulta com saldo     ",{|| ConProdutoSaldo(.t.)},iif(!PwCheck("13105"),999,NIL)})
   	aadd(aProdutos2,{" &6-Estoque inicial        ",{|| LancEstoqInicial ()},iif(!PwCheck("13106"),999,NIL)})
	aadd(aProdutos2,{" &7-Reorganizar Saldos     ",{|| ReorgSaldo()},iif(!PwCheck("13107"),999,NIL)})
    aadd(aProdutos2,{" &8-Alterar NCM            ",{|| AlterarNCM()},iif(!PwCheck("13108"),999,NIL)})
    aadd(aProdutos2,{" &9-Alterar pre‡os         ",{|| AlterarPreco()},iif(!PwCheck("13109"),999,NIL)})
    aadd(aProdutos2,{" &0-Imprimir etiquetas     ",{|| ImprimirEtiquetas()},iif(!PwCheck("13110"),999,NIL)})
    aadd(aProdutos2,{" &A-Transferir quantidade >",aTransfProd})
return       	
// ********************************************************************************************************
exit procedure FecharBanco

    if lAutorizado
        oServer:Close()
    endif
return
    

// ** Fim do Arquivo.
