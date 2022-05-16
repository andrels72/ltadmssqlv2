/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.2
 * Identificacao: Relatorios de Contas a Receber - Por Cliente
 * Prefixo......: LtAdm
 * Programa.....: RelRec1.prg
 * Autor........: Andre Lucas Souza
 * Data.........: 23 de Setembro de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure RelRec1
   local getlist := {},cTela := SaveWindow()
   local cTexto,cImpressoraPadrao
   private cCodCli,dDataI,dDataF,nQual,cTitRel,nVideo
   private n30dias,n60dias,nMais60dias

   nQual := Aviso_1( 14,, 19,, [Aten‡„o!], [    Listar quais duplicatas?    ], { [ ^Recebidas ], [ ^A receber ] }, 1, .t. )

   if nQual == -27
      FechaDados()
      return
   elseif nQual == 1
      cTexto  := "> A Receber no periodo por Cliente ( Recebidas ) <"
      cTitRel := "Relatorio de Duplicatas a Receber ( Recebidas )"
   elseif nQual == 2
      cTexto  := "> A Receber no periodo por Cliente ( A Receber ) <"
      cTitRel := "Relatorio de Duplicatas a Receber ( A Receber )"
   end
   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenClientes()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenNatureza()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenVendedor()
      FechaDados()
      Msg(.f.)
      return
   endif
   
   if !OpenCidades()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenDupRec()
      FechaDados()
      Msg(.f.)
      return
   end
   Msg(.f.)
   AtivaF4()
   Window(09,08,15,70,cTexto)
   setcolor(Cor(11))
   //           0123456789012345678901234567890
   //                     2
   @ 11,10 say "     Cliente:"
   @ 12,10 say "Data Inicial:"
   @ 13,10 say "  Data Final:"
   while .t.
      cCodCli := space(04)
      dDataI  := date()
      dDataF  := date()
      cQual   := space(01)
      n30dias := 0
      n60dias := 0
      nMais60dias := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,24 get cCodCli picture "@k 9999";
                when Rodape("Esc-Encerra | F4-Clientes | Deixe em Branco p/ Todos");
                valid iif(empty(cCodCli),.t.,Busca(Zera(@cCodCli),"Clientes",1,11,30,"left(Clientes->NomCli,30)",{"Cliente Nao Cadastrado"},.f.,.f.,.f.))
      @ 12,24 get dDataI  picture "@k" when Rodape("Esc-Encerra")
      @ 13,24 get dDataF  picture "@k" valid iif(lastkey() == K_UP,.t.,dDataF >= dDataI)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      if !Confirm("Confirma as Informacoes")
         loop
      endif
        if !Processa()
            loop
        endif
		Imprima()
		exit
	enddo
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
   
static function Processa
    local nDias
    private lCondicao

   set softseek on
    // se foi informado o codigo do cliente
	if !empty(cCodCli)
        // se a op‡Æo for recebidas
		if nQual == 1
			DupRec->(dbsetorder(5),dbseek(cCodCli+dtos(dDataI)))
			if !(DupRec->CodCli == cCodCli) .or. DupRec->DtaPag > dDataF
				set softseek off
				Mens({"Nao Existe Nada Recebido"})
				return(.f.)
			endif
			lCondicao := "DupRec->CodCli == cCodCli .and. DupRec->DtaPag >= dDataI .and. DupRec->DtaPag <= dDataF"
        // se a op‡Æo for a receber
		elseif nQual == 2
            DupRec->(dbsetorder(6),dbseek(cCodCli+dtos(dDataI)))
            if !(DupRec->CodCli == cCodCli) .or. DupRec->DtaVen > dDataF
                set softseek off
                Mens({"Nao Existe Nada a Receber"})
                return(.f.)
            endif
            lCondicao := "DupRec->CodCli == cCodCli .and. DupRec->DtaVen >= dDataI .and. DupRec->DtaVen <= dDataF .and. empty(DupRec->DtaPag)"
            cTitRel   := "Relatorio de Duplicatas a Receber ( A Receber )"
      end
   else
      if nQual == 1
         DupRec->(dbsetorder(5),dbseek("    "+dtos(dDataI)))
         if DupRec->DtaPag > dDataF
            set softseek off
            Mens({"Nao Existe Nada Recebido"})
            return(.f.)
         endif
         lCondicao := "DupRec->DtaPag >= dDataI .and. DupRec->DtaPag <= dDataF"
      elseif nQual == 2
         DupRec->(dbsetorder(6),dbseek("    "+dtos(dDataI)))
         if DupRec->DtaVen > dDataF
            set softseek off
            Mens({"Nao Existe Nada a Receber"})
            return(.f.)
         endif
         lCondicao := "DupRec->DtaVen >= dDataI .and. DupRec->DtaVen <= dDataF .and. empty(DupRec->DtaPag)"
      endif
   endif
   set softseek off
    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"27",.t.,.t.,"Temp27")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return(.f.)
	endif
	zap
	Temp27->(dbclosearea())
    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"27",.t.,.t.,"Temp27")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return(.f.)
	endif
    Msg(.t.)
    Msg("Aguarde: Processando as informa‡äes")
    do while DupRec->(!eof())
        if &lCondicao.
            Clientes->(dbsetorder(1),dbseek(DupRec->CodCli))
            Temp27->(dbappend())
            Temp27->CodCli := DupRec->CodCli
            Temp27->NomCli := Clientes->NomCli
            Temp27->NumDup := DupRec->NumDup
            // ** Recebidas
            if nQual == 1
               Temp27->Data1 := DupRec->DtaVen
               Temp27->Data2 := DupRec->DtaPag
               Temp27->Valor := DupRec->ValPag 
            // a Receber
            elseif nQual == 2
               Temp27->Data1 := DupRec->DtaEmi
               Temp27->Data2 := DupRec->DtaVen
               Temp27->Valor := DupRec->ValDup 
               Temp27->data3 := date()
               if DupRec->DtaVen < Date()
                    nDias := date() - Duprec->DtaVen
                    if nDias >= 1 .and. nDias <= 30
                        n30dias += DupRec->ValDup
                    elseif nDias > 30 .and. nDias <= 60
                        n60Dias += DupRec->ValDup
                    elseif nDias > 60
                        nMais60Dias += DupRec->ValDup
                    endif
                endif
            endif
        endif
        DupRec->(dbskip())
    enddo
    Msg(.f.)
    if Temp27->(lastrec()) == 0
        Mens({"NÆo existe duplicata a receber nesse per¡odo"})
        Temp27->(dbclosearea())
        return(.f.)
    endif
    Temp27->(dbclosearea())
    return(.t.)
    
static procedure Imprima
    local nVideo

    If Aviso_1(09,,14,,[Aten‡„o!],"Imprimir Relatorio ?",{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
        if Ver_Imp2(@nVideo)
            // ** Abre o arquivo em modo exclusivo
            if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"27",.t.,.t.,"Temp27")
                Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
                return
            endif
            if nVideo == 1
                cImpressoraPadrao := ImpressoraPadrao()
            endif
            oFrPrn := frReportManager():new()
            oFrPrn:LoadLangRes( 'brazil.xml')                     //arquivo de idioma
            oFrPrn:SetWorkArea("Temp27",select("temp27"))
            if nQual = 1
                oFrprn:LoadFromFile('duplicata_receber11.fr3')
            else
                oFrprn:LoadFromFile('duplicata_receber12.fr3')
            endif
            oFrPrn:AddVariable("variaveis","datainicial","'"+dtoc(dDatai)+"'")
            oFrPrn:AddVariable("variaveis","datafinal","'"+dtoc(dDataf)+"'")
            oFrPrn:AddVariable("variaveis","empresa","'"+cEmpRazao+"'")
            oFrPrn:AddVariable("calculo","n30dias","'"+transform(n30dias,"@e 9,999,999.99")+"'")
            oFrPrn:AddVariable("calculo","n60dias","'"+transform(n60dias,"@e 9,999,999.99")+"'")
            oFrPrn:AddVariable("calculo","nMais60dias","'"+transform(nMais60dias,"@e 9,999,999.99")+"'")
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
    Temp27->(dbclosearea())
    return

// ** Fim do Arquivo.
