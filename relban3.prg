/*************************************************************************
 * Sistema......: Administrativo
 * Identificacao: Relatorios dos Movimentos bancarios
 * Prefixo......: LTam
 * Programa.....: RelBan3.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 21 de Outubro de 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure RelBan3
   local getlist := {},cTela := SaveWindow()
   local nVideo,lCabec := .t.,oQuery
   private lTem := .f.
   private nPagina := 1,lUSB
   private dDataI,dDataF,cCodBco,cNumAge,nCodHis,cNumConm,nSaldoAnterior,cCD
   private oQBanco,oQHistBanco,dSaldoAnterior,cSaldoAnterior
   
   
   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenMovBan()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenBanco()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenHistBan()
        FechaDados()
        Msg(.f.)
        return
    endif
   Msg(.f.)
   AtivaF4()
   Window(07,07,18,73,"> Movimento Bancario <")
   setcolor(Cor(11))
   //           9012345678901234567890123456789012345678901234567890123456789012345678
   //            1         2         3         4         5         6         7
   @ 09,09 say "         Banco:"
   @ 10,09 say "    Nõ Ag^ncia:"
   @ 11,09 say "   Nõ da Conta:"
   @ 12,09 say "     Historico:"
   @ 13,09 say "    Cred./Deb.:"
   @ 14,09 say "Saldo Anterior:"
   @ 15,09 say "  Data Inicial:"
   @ 16,09 say "    Data Final:"
   while .t.
      cCodBco := Space(03)
      cNumAge := Space(04)
      cNumCon := Space(15)
      cCodHis := Space(03)
      dDataI  := date()
      dDataF  := date()
      cCd := space(01)
      nSaldoAnterior := 0
      cSaldoAnterior := "S"
      dSaldoAnterior := ctod(space(08))
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 09,25 get cCodBco picture "@k 999";
                when Rodape("Esc-Encerra | F4-Bancos");
                valid Busca(Zera(@cCodBco),"Banco",1,09,27,"Banco->NomBco",{"Banco Nao Cadastrado"},.f.,.f.,.f.)                
                
      @ 10,25 get cNumAge picture "@k";
                when Rodape("Esc-Encerra") valid V_Zera(@cNumAge)
                
      @ 11,25 get cNumCon picture "@k";
            valid iif(lastkey() == K_UP,.t.,Busca(cCodBco+cNumAge+cNumCon,"Banco",1,,,,{"Banco/Agencia/Conta Nao Cadastrado"},.f.,.f.,.f.))
                            
      @ 12,25 get nCodHis picture "@k 999";
            when Rodape("Esc-Encerra | F4-Historico Bancario");
            valid iif(!empty(cCodHis),iif(lastkey() == K_UP,.t.,Busca(Zera(@cCodHis),"HistBan",1,12,27,"HistBan->DesHis",{"Historico Nao Cadastrado"},.f.,.f.,.f.)),.t.)
                 
        @ 13,25 get cCD picture "@k!";
                valid cCD $ "CD "
        @ 14,25 get cSaldoAnterior picture "@k!";
                valid cSaldoAnterior $ "SN"
        @ 15,25 get dDataI  picture "@k" when Rodape("Esc-Encerra") valid iif(lastkey() == K_UP,.t.,NoEmpty(dDataI))
        @ 16,25 get dDataF  picture "@k" valid dDataF >= dDataI
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      if !Confirm("Confirma as Informacoes")
         loop
      endif
        if !Processar()
            loop
        endif
        Imprima()
    enddo
    FechaDados()
    DesativaF4()
    RestWindow(cTela)
return


static function Processar()
    local nSaldo := 0,cQuery,oQuery

    MovBan->(dbsetorder(2),dbseek(cCodBco+cNumAge+cNumCon))
    if !(MovBan->CodBco == cCodBco) .or. !(MovBan->NumAge == cNumAge) .or. !(MovBan->NumCon == cNumCon)
        Mens({"Nao Existe Movimento"})
        set softseek off
        return(.f.)
    endif
    set softseek off

    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"34",.t.,.t.,"Temp34")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return(.f.)
	endif
	zap
	Temp34->(dbclosearea())
    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"34",.t.,.t.,"Temp34")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return(.f.)
	endif
    Msg(.t.)
    Msg("Aguarde: Processando as informaÎ„es")
    //nRecno := MovBan->(recno())
    nRecno := MovBan->(recno())
    do while (MovBan->CodBco+MovBan->NumAge+MovBan->NumCon == cCodBco+cNumAge+cNumCon) .and. MovBan->(!eof())
        HistBan->(dbsetorder(1),dbseek(MovBan->CodHis))
        if MovBan->DtaBal < dDataI
            if cSaldoAnterior = "S"
                if HistBan->TipHis == "D"
                    nSaldoAnterior -= MovBan->VlrMov
                    dSaldoAnterior := MovBan->DtaBal
                else
                    nSaldoAnterior += MovBan->VlrMov
                    dSaldoAnterior := MovBan->DtaBal
                endif
            endif
        else
            exit
        endif
        MovBan->(dbskip())
    enddo
    if cSaldoAnterior = "N"
        nSaldoAnterior := 0
        dSaldoAnterior := ctod(space(08))
    endif
    nSaldo := nSaldoAnterior
    do while (MovBan->DtaBal >= dDataI .and. MovBan->DtaBal <= dDataF) .and. MovBan->(!eof())
        HistBan->(dbsetorder(1),dbseek(MovBan->CodHis))
        Temp34->(dbappend())
        Temp34->numdoc    := MovBan->NumDoc
        Temp34->balancete := MovBan->DtaBal
        Temp34->data      := MovBan->DtaMov
        Temp34->historico := MovBan->CodHis+" "+rtrim(HistBan->DesHis)+" "+MovBan->Compl
        Temp34->valor     := MovBan->VlrMov 
        Temp34->tipo := HistBan->TipHis
        if Histban->TipHis == "D"
            nSAldo -= MovBan->VlrMov
        else
            nSaldo += MovBan->VlrMov
        endif
        Temp34->Saldo := nSaldo
        MovBan->(dbskip())
    enddo
    Temp34->(dbclosearea())
    Msg(.f.)
    return(.t.)
    
static procedure Imprima
    local nVideo

    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"34",.t.,.t.,"Temp34")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return
	endif
    If Aviso_1(09,,14,,[AtenÎ"o!],[Imprimir Relat½rio ?],{ [  ^Sim  ], [  ^N"o  ] }, 1, .t. ) = 1
        If Ver_Imp2(@nVideo)
            if nVideo == 1
                cImpressoraPadrao := ImpressoraPadrao()
            endif
            Banco->(dbsetorder(1),cCodBco+cNumAge+cNumCon)
            oFrPrn := frReportManager():new()
            oFrPrn:LoadLangRes( 'brazil.xml')                     //arquivo de idioma
            oFrPrn:SetWorkArea("Temp34",select("Temp34"))
            oFrprn:LoadFromFile('bancos_movimento.fr3')
            oFrPrn:AddVariable("variaveis","empresa","'"+cEmpRazao+"'")
            oFrPrn:AddVariable("variaveis","datainicial","'"+dtoc(dDatai)+"'")
            oFrPrn:AddVariable("variaveis","datafinal","'"+dtoc(dDataf)+"'")
            
            oFrPrn:AddVariable("variaveis","Banco","'"+cCodBco+" - "+Banco->NomBco+"'")
            oFrPrn:AddVariable("variaveis","Agencia","'"+cNumAge+" - "+Banco->NomAge+"'")
            oFrPrn:AddVariable("variaveis","Conta","'"+cNumCon+" - "+Banco->NomCon+"'")
            oFrPrn:AddVariable("variaveis","saldo","'"+transform(nSaldoAnterior,"@e 999,999,999.99")+"'")
            oFrPrn:AddVariable("variaveis","datasaldoanyerio","'"+dtoc(dSaldoAnterior)+"'")
            oFrPrn:PrepareReport()
            //oFrPrn:DesignReport()                                 // aqui para "desenhar" o relat¢rio
            oFrPrn:PreviewOptions:SetAllowEdit( .F. )
            if nVideo == 2
                oFrPrn:ShowReport()
            else
                // se a impress’o for na impressora padr’o
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
    Temp34->(dbclosearea())
    return


//** Fim do Arquivo.
