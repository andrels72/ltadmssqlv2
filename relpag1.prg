/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.2
 * Identificacao: Relatorios de Contas a Pagar
 * Prefixo......: LtAdm
 * Programa.....: RelPag1.prg
 * Autor........: Andre Lucas Souza
 * Data.........: 16 de Fevereiro de 2004
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure RelPag1
   local getlist := {},cTela := SaveWindow()
   local cTexto
   private cCodFor,dDataI,dDataF,nQual,cTitRel

   nQual := Aviso_1(14,,19,,"Aten‡„o!","    Listar quais duplicatas?    ",{" ^Pagas "," ^A Pagar "},1,.t.)

   if nQual == -27
      FechaDados()
      return
   elseif nQual == 1
      cTexto  := "> A Pagar no periodo por Fornecedor ( Pagas ) <"
      cTitRel := "Relatorio de Duplicatas a Pagar ( Pagas )"
   elseif nQual == 2
      cTexto  := "> A Pagar no periodo por Fornecedor ( A Pagar ) <"
      cTitRel := "Relatorio de Duplicatas a Pagar ( A Pagar )"
   end
   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenFornecedor()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenCidades()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenDupPag()
      FechaDados()
      Msg(.f.)
      return
   endif
   Msg(.f.)
   AtivaF4()
   Window(08,10,14,72,cTexto)
   setcolor(Cor(11))
   //           0123456789012345678901234567890
   //                     2
   @ 10,12 say "  Fornecedor:"
   @ 11,12 say "Data Inicial:"
   @ 12,12 say "  Data Final:"
   while .t.
      cCodFor := space(04)
      dDataI  := date()
      dDataF  := date()
      cQual   := space(01)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,26 get cCodFor picture "@k 9999";
                when Rodape("Esc-Encerra | F4-Fornecedores | Deixe em Branco p/ Todos");
                valid iif(empty(cCodFor),.t.,Busca(Zera(@cCodFor),"Fornecedor",1,10,31,"left(Fornecedor->RazFor,40)",{"Fornecedore Nao Cadastrado"},.f.,.f.,.f.))
      @ 11,26 get dDataI  picture "@k" when Rodape("Esc-Encerra")
      @ 12,26 get dDataF  picture "@k" valid iif(lastkey() == K_UP,.t.,dDataF >= dDataI)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
        if !Processa()
            loop
        endif
      Imprima()
      exit
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
   
   
static function Processa
   private lCondicao

   set softseek on
   if !empty(cCodFor)
      if nQual == 1
         DupPag->(dbsetorder(5),dbseek(cCodFor+dtos(dDataI)))
         if !(DupPag->CodFor == cCodFor) .or. DupPag->DtaPag > dDataF
            set softseek off
            Mens({"Nao Existe Nada Pago"})
            return(.f.)
         end
         lCondicao := "DupPag->CodFor == cCodFor .and. DupPag->DtaPag >= dDataI .and. DupPag->DtaPag <= dDataF"
      elseif nQual == 2
         DupPag->(dbsetorder(6),dbseek(cCodFor+dtos(dDataI)))
         if !(DupPag->CodFor == cCodFor) .or. DupPag->DtaVen > dDataF
            set softseek off
            Mens({"Nao Existe Nada a Pagar"})
            return(.f.)
         endif
         lCondicao := "DupPag->CodFor == cCodFor .and. DupPag->DtaVen >= dDataI .and. DupPag->DtaVen <= dDataF .and. empty(DupPag->DtaPag)"
      end
   else
      if nQual == 1
         DupPag->(dbsetorder(5),dbseek("    "+dtos(dDataI)))
         if DupPag->DtaPag > dDataF
            set softseek off
            Mens({"Nao Existe Nada Pago"})
            return(.f.)
         endif
         lCondicao := "DupPag->DtaPag >= dDataI .and. DupPag->DtaPag <= dDataF"
      elseif nQual == 2
         DupPag->(dbsetorder(6),dbseek("    "+dtos(dDataI)))
         if DupPag->DtaVen > dDataF
            set softseek off
            Mens({"Nao Existe Nada a Pagar"})
            return(.f.)
         endif
         lCondicao := "DupPag->DtaVen >= dDataI .and. DupPag->DtaVen <= dDataF .and. empty(DupPag->DtaPag)"
      endif
   endif
   set softseek off
    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"26",.t.,.t.,"Temp26")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return(.f.)
	endif
	zap
	Temp26->(dbclosearea())
	// ** Abre o arquivo em modo exclusivo
	if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"26",.t.,.t.,"Temp26")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return(.f.)
	endif
    do while DupPag->(!eof())
        if &lCondicao.
            Fornecedor->(dbsetorder(1),dbseek(DupPag->CodFor))
            Temp26->(dbappend())
            Temp26->codfor := DupPag->CodFor
            Temp26->Razfor := left(Fornecedor->RazFor,35)
            Temp26->NumDup := DupPag->NumDup
            // ** duplicatas pagas
            if nQual == 1
                Temp26->Data1 := DupPag->DtaVen
                Temp26->data2 := DupPag->DtaPag
                Temp26->valor := DupPag->ValPag 
            // duplicatas a pagar
            elseif nQual == 2
                Temp26->data1 := DupPag->DtaEmi
                Temp26->data2 := DupPag->DtaVen
                Temp26->Valor := DupPag->ValDup
                Temp26->data3 := date() 
            endif
        endif
        DupPag->(dbskip())
    enddo
    Temp26->(dbclosearea())
    return(.t.)
    
static procedure Imprima
    local nVideo


    If Aviso_1(09,,14,,[Aten‡„o!],"Imprimir Relatorio ?",{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
        if Ver_Imp2(@nVideo)
            // ** Abre o arquivo em modo exclusivo
            if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"26",.t.,.t.,"Temp26")
                Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
                return
            endif
            if nVideo == 1
                cImpressoraPadrao := ImpressoraPadrao()
            endif
            oFrPrn := frReportManager():new()
            oFrPrn:LoadLangRes( 'brazil.xml')                     //arquivo de idioma
            oFrPrn:SetWorkArea("Temp26",select("temp26"))
            if nQual = 1
                oFrprn:LoadFromFile('duplicata_apagar11.fr3')
            else
                oFrprn:LoadFromFile('duplicata_apagar12.fr3')
            endif
            oFrPrn:AddVariable("variaveis","datainicial","'"+dtoc(dDatai)+"'")
            oFrPrn:AddVariable("variaveis","datafinal","'"+dtoc(dDataf)+"'")
            oFrPrn:AddVariable("variaveis","empresa","'"+cEmpRazao+"'")
            oFrPrn:AddVariable("variaveis","fornecedor","'"+cCodFor+"-"+Fornecedor->RazFor+"'")
            Msg(.t.)
            Msg("Aguarde: Gerando o relat¢rio")
            oFrPrn:PrepareReport()
            Msg(.f.)
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
    Temp26->(dbclosearea())
    return


//** Fim do Arquivo.
