/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.0
 * Identificacao: Relat¢rio de Entradas - Notas
 * Prefixo......: LtAdm
 * Programa.....: Bancos.prg
 * Autor........: Andre Lucas Souza
 * Data.........: 23 de Setembro de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure RelComp1
   local getlist := {},cTela := SaveWindow()
   local nVideo,cTitulo
   private dDataI,dDataF,nQual

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenFornecedor()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenCompra()
        FechaDados()
        Msg(.f.)
        return
    endif
   // ** Natureza Fiscal
   if !OpenNatureza()
      FechaDados()
      Msg(.f.)
      return
   endif
   Msg(.f.)
   DesativaF9()
   DesativaF4()
   AtivaF4()
   Window(09,26,14,53,cTitulo)
   setcolor(Cor(11))
   //           0123456789012345678901234567890
   //                     2
   @ 11,28 say "Data Inicial:"
   @ 12,28 say "  Data Final:"
   while .t.
      dDataI  := date()
      dDataF  := date()
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,42 get dDataI  picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDataI)
      @ 12,42 get dDataF  picture "@k" valid iif(lastkey() == K_UP,.t.,dDataF >= dDataI)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
        if !Processar()
            loop
        endif
        Imprima()
      exit
   end
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   end
   FechaDados()
   RestWindow(cTela)
   return
   
static function Processar

    set softseek on
    Compra->(dbsetorder(8),dbseek(dDataI))
    if Compra->DtaEmi > dDataF .or. Compra->(eof())
        set softseek off
        Mens({"NÆo existe nota nesse per¡odo"})
        return(.f.)
    endif
    Msg(.t.)
    Msg("Aguarde: Gerando o Relatorio (Esc-Cancela)")
    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"07",.t.,.t.,"temp07")
	   Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
	   return(.f.)
	endif
    zap
    temp07->(dbclosearea())
    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"07",.t.,.t.,"temp07")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return(.f.)
	endif
    do while Compra->(!eof()) .and. Compra->DtaEmi >= dDataI .and. Compra->DtaEmi <= dDataF
        if !lGeral
            if Compra->SN
                Compra->(dbskip())
                loop
            endif
        else
            if !Compra->SN
                Compra->(dbskip())
                loop
            endif
        endif
        Fornecedor->(dbsetorder(1),dbseek(Compra->CodFor))
        temp07->(dbappend())
        temp07->lanc := Compra->Chave
        temp07->fornecedor := Compra->CodFor+" "+left(Fornecedor->FanFor,25)
        temp07->numnot := Compra->NumNot
        temp07->serie  := Compra->serie
        temp07->modelo := Compra->modelo
        //temp07->chave  := transform(Compra->chave,"9999.9999.9999.9999.9999.9999.9999.9999.9999.9999.9999")
        temp07->dtaemi := Compra->DtaEmi
        temp07->dtaent := Compra->DtaEnt
        temp07->codnat := Compra->CodNat
        temp07->totalnota := Compra->TotalNota
        Compra->(dbskip())
    enddo
    temp07->(dbclosearea())
    Msg(.f.)
    return(.t.)
// ****************************************************************************
static procedure Imprima
   local cTela := SaveWindow(),nVideo
   
   
    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"07",.t.,.t.,"Temp07")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return
	endif
    If Aviso_1(09,,14,,[Aten‡Æo!],[Imprimir Relat¢rio ?],{ [  ^Sim  ], [  ^NÆo ] }, 1, .t. ) = 1
        If Ver_Imp2(@nVideo)
            if nVideo == 1
                cImpressoraPadrao := ImpressoraPadrao()
            endif
            oFrPrn := frReportManager():new()
            oFrPrn:LoadLangRes( 'brazil.xml')                     //arquivo de idioma
            oFrPrn:SetWorkArea("Temp07",select("Temp07"))
            oFrprn:LoadFromFile('entrada_periodo.fr3')
            oFrPrn:AddVariable("variaveis","empresa","'"+cEmpFantasia+"'")
            oFrPrn:AddVariable("variaveis","datainicial","'"+dtoc(dDatai)+"'")
            oFrPrn:AddVariable("variaveis","datafinal","'"+dtoc(dDataf)+"'")
            Msg(.t.)
            Msg("Aguarde: gerando o relat¢rio")
            oFrPrn:PrepareReport()
            Msg(.f.)
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
    Temp07->(dbclosearea())
    RestWindow(cTela)
    return

// ****************************************************************************
   

//** Fim do Arquivo.
