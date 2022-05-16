/*************************************************************************
 * Sistema......: Fluxo de Caixa
 * Versao.......: 2.00
 * Identificacao: Relatorios do Movimento do Caixa - Conferˆncia
 * Prefixo......: LTCAIXA
 * Programa.....: REL1_4.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 06 DE JAMEIRO DE 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"
#include "setcurs.ch"

procedure RelCxa4()
   local getlist := {},cTela := SaveWindow()
   local dDataI := date(),dDataF := date(),cCodCaixa,cCodHist,cCodPagto
   local cSldAnter,nSaldoFim
   private nVideo,cConsolida,nSaldoAnterior,dDataAnterior

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   
   if !OpenCaixa()
      FechaDados()
      Msg(.f.)
      return
   endif
   
   if !OpenHistBan()
      FechaDados()
      Msg(.f.)
      return
   endif 
   if !OpenHistCxa()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenFPagCxa()
      FechaDados()
      Msg(.f.)
      return
   endif

    if !OpenMovCxa()   
      FechaDados()
      Msg(.f.)
      return
   endif
   Msg(.f.)
   AtivaF4()
   Window(07,13,17,66,"> Conferencia do Movimento do Caixa <")
   setcolor(Cor(11))
   //           5678901234567890123456789012345678901234567890123456789012345678
   //                2         3         4         5         6         7
   @ 09,15 say "  Data Inicial:"
   @ 10,15 say "    Data Final:"
   @ 11,15 say "         Caixa:"
   @ 12,15 say "     Historico:"
   @ 13,15 say "   Forma Pagto:"
   @ 14,15 say "Saldo Anterior:"
   @ 15,15 say "   Saldo Final:"
   while .t.
      cCodCaixa := space(02)
      cCodHist  := space(03)
      cCodPagto := space(02)
      cSldAnter := space(01)
      cConsolida := "N"
      nSaldoFim := 0
      nSaldoAnterior := 0.00
      dDataAnterior := ctod(space(08))
      scroll(09,31,15,59,0)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 09,31 get dDataI    picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDataI)
      @ 10,31 get dDataF    picture "@k" valid dDataF >= dDataI
      @ 11,31 get cCodCaixa picture "@k 99" when Rodape("Esc-Encerra | F4-Caixas") valid iif(lastkey() == K_UP,.t.,Busca(Zera(@cCodCaixa),"Caixa",1,11,35,"Caixa->NomCaixa",{"Caixa Nao Cadastrado"},.f.,.t.,.f.))
      @ 12,31 get cCodHist  picture "@k 999" when Rodape("Esc-Encerra | F4-Historicos | Em branco p/ todos") valid iif(lastkey() == K_UP,.t.,iif(!empty(cCodHist),Busca(Zera(@cCodHist),"Historico",1,12,35,"Historico->NomHist",{"Historico Nao Cadastrado"},.f.,.t.,.f.),.t.))
      @ 13,31 get cCodPagto picture "@k 99" when Rodape("Esc-Encerra | F4-Formas de Pagto. | Em branco p/ todos") valid iif(lastkey() == K_UP,.t.,iif(!empty(cCodPagto),Busca(Zera(@cCodPagto),"FormaPag",1,13,35,"FormaPag->NomPagto",{"Forma de Pagamento Nao Cadastrado"},.f.,.t.,.f.),.t.))
      @ 14,31 get cSldAnter picture "@k!" when Rodape("Esc-Encerra") valid MenuArray(@cSldAnter,{{"S","Sim"},{"N","Nao"}},14,31,14,31)
      @ 15,31 get nSaldoFim picture "@ke 9,999,999.99"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
        if !Processar(cCodCaixa,cCodHist,cCodPagto,dDataI,dDataF,cSldAnter,nSaldoFim)
            loop
        endif
        Imprima(cCodCaixa,cCodHist,cCodPagto,dDataI,dDataF,cSldAnter,nSaldoFim)
   enddo
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return

static function Processar(cCodCaixa,cCodHist,cCodPagto,dDataI,dDataF,cSldAnter,nSaldoFim)
   local cTela := SaveWindow(),nTecla := 0,lCabec := .t.,nRecno,dData
   local lCodHist,cHistorico,lSaldoAnter := .f.,nSALDO := 0.00,nI,nLinha
   local lSaldoTransf := .f.,lData := .t.,lTem := .f.,nTotCred,nTotDebi
   local nQuantos := 0,lCodPagto,nTotCred1,nTotDebi2
   private nPagina := 1,cCodHist2 := cCodHist,cCodPagto2 := cCodPagto

   Msg( .t. )
   Msg( "Aguarde : Estou selecionando as informacoes" )
   set softseek on
   MovCaixa->(dbsetorder(3),dbseek(cCodCaixa+dtos(dDataI)))
   if MovCaixa->(eof()) .or. MovCaixa->Data > dDataF
      Msg(.f.)
      Mens({"Nao Existe Movimento"})
      set softseek off
      return(.f.)
   end
   Msg(.f.)
   set softseek off
   lHist     := iif(empty(cCodHist),".t.","MovCaixa->CodHisto == cCodHist2 .and. !MovCaixa->Banco")
   lCodPagto := iif(empty(cCodPagto),".t.","MovCaixa->CodPagto == cCodPagto2")
   nTotCred  := 0
   nTotCred1 := 0
   nTotDebi  := 0
   nTotDebi1 := 0
   nQuantos  := 0
   nRecno    := 0
    nRecno := MovCaixa->(recno())
    if cSldAnter == "S"
		Msg(.t.)
   		Msg("Aguarde: Verificando o Saldo Anterior")
		if cConsolida == "N"
   			// ** Verifica
			MovCaixa->(dbsetorder(2),dbgotop())
			do while MovCaixa->(!eof())
				if &lHist. .and. &lCodPagto. .and. MovCaixa->CodCaixa == cCodCaixa
					if nRecno == 0
						nRecno := MovCaixa->(recno())
					endif
					if MovCaixa->Data < dDataI
						if MovCaixa->Tipo == "1"
							nSaldo += MovCaixa->Valor
                            nSaldoAnterior += MovCaixa->Valor
						elseif MovCaixa->Tipo == "2"
							nSaldo -= MovCaixa->Valor
                            nSaldoAnterior -= MovCaixa->Valor
						endif
						dData := MovCaixa->Data
                        dDataAnterior := MovCaixa->Data
						lSaldoAnter := .t.
					else
						exit
					endif
				endif
				MovCaixa->(dbskip())
			enddo
		else
			// ** Verifica
			ConsolidaCaixa->(dbsetorder(1),dbseek(cCodCaixa))
			do while ConsolidaCaixa->CodCaixa == cCodCaixa .and. ConsolidaCaixa->(!eof())
				if ConsolidaCaixa->Data < dDataI
					nSaldo += ConsolidaCaixa->Saldo
					dData       := ConsolidaCaixa->Data
					lSaldoAnter := .t.
				endif
				ConsolidaCaixa->(dbskip())
			enddo
		endif
		Msg(.f.)
	endif
    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"31",.t.,.t.,"Temp31")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return(.f.)
	endif
	zap
	Temp31->(dbclosearea())
    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"31",.t.,.t.,"Temp31")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return(.f.)
	endif
    lSaldoAnter := iif(cSldAnter == "S",lSaldoAnter,.f.)
    nSaldo      := iif(cSldAnter == "S",nSaldo,0)
    MovCaixa->(dbgoto(nRecno))
    do while MovCaixa->(!eof())
        if &lHist. .and. &lCodPagto. .and. MovCaixa->CodCaixa == cCodCaixa .and. MovCaixa->Data >= dDataI .and. MovCaixa->Data <= dDataF
            lTem := .t.
            if lSaldoAnter
                lSaldoAnter := .f.
            endif
            if lSaldoTransf
                lSaldoTransf := .f.
            endif
            if MovCaixa->Tipo == "1"
                nSaldo += MovCaixa->Valor
            else
                nSaldo -= MovCaixa->Valor
            end
            Temp31->(dbappend())
            Temp31->Data := MovCaixa->Data
            Temp31->Lancamento := MovCaixa->Lancamento
            if empty(cCodHist)
                if !MovCaixa->Banco
                    Historico->(dbsetorder(1),dbseek(MovCaixa->CodHisto))
                else
                    HistBan->(dbsetorder(1),dbseek(MovCaixa->CodHisto))
                endif
            endif
            if !MovCaixa->Banco
                cTexto := Historico->CodHist+"-"+rtrim(Historico->NomHist)+" "+rtrim(MovCaixa->Complemen1)+" "+rtrim(MovCaixa->Complemen2)
            else
                cTexto := HistBan->CodHis+"-"+rtrim(HistBan->DesHis)+" "+rtrim(MovCaixa->Complemen1)+" "+rtrim(MovCaixa->Complemen2)
            endif
            nLinha := mlcount(cTexto,90)
            lLinha := .f.
            for nI := 1 to nLinha
                if nI == 1
                    Temp31->Historico := memoline(cTexto,90,nI)
                else
                    Temp31->(dbappend())
                    Temp31->Data := MovCaixa->Data
                    Temp31->Historico := memoline(cTexto,90,nI)
                endif
            next
            if MovCaixa->Tipo == "1"
                Temp31->Entrada := MovCaixa->Valor 
            elseif MovCaixa->Tipo == "2"
                Temp31->Saida := MovCaixa->Valor 
            endif
            Temp31->Saldo := nSALDO 
        endif
        MovCaixa->( dbskip() )
        if !( MovCaixa->Data == dData )
            lDATA := .t.
        endif
    enddo
    Temp31->(dbclosearea())
    RestWindow(cTela)
    return(.t.)
    
static procedure Imprima(cCodCaixa,cCodHist,cCodPagto,dDataI,dDataF,cSldAnter,nSaldoFim)
    local nVideo

    If Aviso_1(09,,14,,[Aten‡„o!],"Imprimir Relatorio ?",{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
        if Ver_Imp2(@nVideo)
            // ** Abre o arquivo em modo exclusivo
            if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"31",.t.,.t.,"Temp31")
                Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
                return
            endif
            if nVideo == 1
                cImpressoraPadrao := ImpressoraPadrao()
            endif
            oFrPrn := frReportManager():new()
            oFrPrn:LoadLangRes( 'brazil.xml')                     //arquivo de idioma
            oFrPrn:SetWorkArea("Temp31",select("Temp31"))
            oFrprn:LoadFromFile('caixa_conferencia.fr3')
            oFrPrn:AddVariable("variaveis","datainicial","'"+dtoc(dDatai)+"'")
            oFrPrn:AddVariable("variaveis","datafinal","'"+dtoc(dDataf)+"'")
            oFrPrn:AddVariable("variaveis","empresa","'"+cEmpRazao+"'")
            oFrPrn:AddVariable("variaveis","caixa","'"+cCodCaixa+"-"+Caixa->NomCaixa+"'")
            oFrPrn:AddVariable("variaveis","historico","'"+iif(empty(cCodHist),"Todos",cCodHist+"-"+Historico->NomHist)+"'")
            oFrPrn:AddVariable("variaveis","pagto","'"+iif(empty(cCodPagto),"Todas",cCodPagto+"-"+FormaPag->NomPagto)+"'") 
            oFrPrn:AddVariable("variaveis","saldoanterior","'"+transform(nSaldoAnterior,"@e 999,999,999.99")+"'")
            oFrPrn:AddVariable("variaveis","datadosaldo","'"+dtoc(dDataAnterior)+"'")           
            oFrPrn:PrepareReport()
            //oFrPrn:DesignReport()                                 // aqui para "desenhar" o relatório
            oFrPrn:PreviewOptions:SetAllowEdit( .F. )
            if nVideo == 2
                oFrPrn:ShowReport()
            else
                // se a impressÆo for na impressora padrÆo
                if !empty(cImpressoraPadrao)
                    oFrPrn:PrintOptions:SetShowDialog(.f.)
                else
                    oFrPrn:PrintOptions:SetShowDialog(.t.)
                endif
                oFrPrn:Print( .T. )
            endif
            oFrPrn:DestroyFR()
        endif
    endif
    Temp31->(dbclosearea())
    return
    
// ****************************************************************************


//** Fim do Arquivo.
