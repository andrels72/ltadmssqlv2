/*************************************************************************
 *       Sistema: Controle Administrativo
 *        Versao: 2.00
 * Identificacao: Modulo Principal
 *       Prefixo: LtAdm
 *      Programa: LtAdm.PRG
 *         Autor: Andre Lucas Souza
 *          Data: 18 de Agosto de 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "dbinfo.ch"

function Principal(cComando)
    local lFaz, cCor := setcolor(),cUsuario
    local aConfCor   := {},aConfig    := {},aSenhas1  := {},aSenhas     := {}
    local aUtilit    := {},aCupom     := {},aRelat    := {}
    local cVersao    := "8.0"

    public aMenu := {}, aPrompt := {}, NIVEL := "02",lAutorizado
    public cDiretorio := "dados\",C_VFIXIMP := "N",C_VTESTIM,aDbfIdx := {}

    // Variaveis utilizadas pelo Plano de Senhas
    public PWnivel, PWregt, PWnome,cCodUser
    public anLin := { 06,12 },aString := {"Joya","Moto"},cCorBanner := Cor(1)
    public aNumIdx := {}
   
    public lGeral   := .f.      // .f. estoque fiscal .t. estoque fisico
   
	// ** variaveis dos dados da empresa - emitente   
    private cEmpRazao
    private cEmpFantasia
	private cEmpEndereco
	private cEmpnumero
	private cEmpComplend  // ** complemento de enderezo
	private cEmpBairro
	private cEmpCodcid
	private cEmpEstCid
	private cEmpCep
	private cEmpTelefone1
	private cEmpTelefone2
	private cEmpEmail
	private cEmpCnpj
	private cEmpIe
	private cEmpIm  // ** Inscriz'o municipal
	private cEmpCnae
	private cEmpCrt // ** c©digo de regime tributario
    
    public p_nNormalMaxrow := 35, p_nNormalMaxcol := 101
   

    request Hb_noMouse  // ** Desativa o Mouse

    Config()
    if cComando == "/LICENCA"
        GravaCFG()
    endif
    if !file("licenca.cfg")
        Mens({"Esta Faltando o Arquivo de Licenca de Uso","Favor entra em contato com o Programador","Para a Liberacao do Uso do Sistema"})
        quit
    else
        restore from licenca.cfg additive
        if !( GeraCod(clNOME) == clCODIGO)
            Mens({"Violacao na Licenca de Uso do Sistema","Favor Entra em Contato Com o Programador para a Licenca do Sistema"})
            setmode(25,80)
            quit
        endif
    endif
    Arq_Sen := if(empty(netname()),[Ervidor],right(alltrim(netname()),7))
   ArqTerm := if(empty(netname()),[Ervidor],right(alltrim(netname()),7))+".cf"
   Arq_Cfg := "config.cfg"
   if cComando == "/AUTORIZA"
      IniAuto()
   endif
   ConfiguraAmbiente()
   if !CheckAuto()
      Mens({"Computador Nao Autorizado"})
      set cursor on
      quit
   endif
   if !LerDadosEmpresa(.t.)
      return
   endif
   
   **
   CLEAR
   *-> Variavel de fundo da tela
   FUNDO := 1
   cor("TITULO")
   /*
   @ 00,00 clear to 00,maxcol()
   cor("FUNDO DA TELA")
   @ 02,00 clear to maxrow(),maxcol()
   cor("MENU")
   scroll(01,00,01,maxcol()+1,0)
   scroll(maxrow(),00,maxrow(),maxcol(),0)
   */
   @ 00,00 clear to 00,p_nNormalMaxcol
   cor("FUNDO DA TELA")
   @ 02,00 clear to p_nNormalMaxrow,p_nNormalMaxcol
   cor("MENU")
   scroll(01,00,01,p_nNormalMaxcol+1,0)
   scroll(p_nNormalMaxrow,00,p_nNormalMaxrow,p_nNormalMaxcol,0)
    if !file("pword01.dbf") .or. !file("pword02.dbf") .or. !file("pword03.dbf")
         Mens({"Falta Completar Instalacao","Favor Comunicar ao Programador"})
         setcolor(cCor)
         clear
         quit
   endif
   aInfofile := directory("ltpdv.exe")
   Abertura("Modulo PDV "+cVersao,"2016",dtoc(aInfoFile[1,3])+'-'+aInfoFile[1,4],rtrim(cEmpFantasia))
   if ( ! PwOpen() )
      close all
      cls
      quit
   end
   if (! PwCheck())
      Mens({"Acesso Nao Autorizado!"})
      setcolor(cCor)
      set cursor on
      cls
      close all
      quit
   endif
   CriarDbf()
   PwRegt      := PwUsers->Registro
   PwNivel     := PwUsers->Nivel
   PwNome      := PwUsers->Nome
   set key K_F11 to Calc()
   set key K_F12 to Calen()
   set exclusive off
   Conf_Cfg("AJUDA",.t.)
   
    aadd(aCupom,{" &1-Vendas                  ",{|| Vendas() }})
    aadd(aCupom,{" &2-Excluir venda           ",{|| ExcluirVenda()}})
    aadd(aCupom,{" &3-Consultar               ",{|| ConNFce(.t.)}})
    aadd(aCupom,{" &4-Cancelar NFC-e          ",{|| Nada()}})
    aadd(aCupom,{" &5-Consultar NFC-e na SEFAZ",{|| ConNFCeSEFAZ()}})
    aadd(aCupom,{" &6-Transmitir              ",{|| TransNFCe()}})
    aadd(aCupom,{" &7-Imprimir NFC-e          ",{|| ImpNFCe()}})
    aadd(aCupom,{" &8-Status servi‡os         ",{|| StatusServicoNFCe()}})
    aadd(aCupom,{" &9-Resolu‡Æo da tela       ",{|| teste()}})
    //aadd(aCupom,{" &0-Teste2",{|| teste2()}})
    
    
    aMenu := {}
    aadd(aMenu,{" &NFC-e ",aCupom})
    setcursor(0)
    do while .t.
        lSAIDA := .F.
        lPAD   := .F.
        Menu(aMenu,"LtPDV v"+cVersao,rtrim(cEmpFantasia),"| Usuario: "+left(PwNome,10))
        if !lSAIDA
            if Aviso_1(10,,15,,"Atencao!","Confirma o Abandono do Sistema?",{ " ^Sim ", " ^Nao " }, 1, .t. ) == 1
                exit
            endif
        endif
   enddo
   set color to
   set cursor on
   cls
   return nil
   
#pragma BEGINDUMP

#include "hbapi.h"

HB_FUNC( WVW_SIZE_READY )
{
   BOOL bIsReady;
   static BOOL s_bIsReady = FALSE;
   bIsReady = s_bIsReady;
   if (ISLOG(1))
   {
      s_bIsReady = hb_parl(1);
   }
   hb_retl(bIsReady);
}
#pragma ENDDUMP
   

//** Fim do Arquivo.
