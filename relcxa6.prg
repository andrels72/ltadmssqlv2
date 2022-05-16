/*************************************************************************
 * Sistema......: Fluxo de Caixa
 * Versao.......: 2.00
 * Identificacao: Relatorios de Resumo do Movimento do Caixa por Historico
 * Prefixo......: LTCAIXA
 * Programa.....: RelCxa4.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 06 DE JAMEIRO DE 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"
#include "setcurs.ch"

procedure RelCxa6()
   local getlist := {},cTela := SaveWindow()
   local dDataI := date(),dDataF := date(),cCodCaixa,cCodHist,cTipHist,cDemHist
   local cSldAnter

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenCaixa()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenHistCxa()
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
   Window(09,07,17,60,chr(16)+" Demonstrativo das Despesas "+chr(17))
   setcolor(Cor(11))
   //           9012345678901234567890123456789012345678901234567890123456789012345678
   //            1         2         3         4         5         6         7
   @ 11,09 say " Data Inicial:"
   @ 12,09 say "   Data Final:"
   @ 13,09 say "        Caixa:"
   @ 14,09 say "      Despesa:"
   @ 15,09 say "Demonstrativo:"
   while .t.
      cCodCaixa := space(02)
      cTipHist  := space(01)
      cDemHist  := "N"
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      scroll(11,24,15,58,0)
      @ 11,24 get dDataI picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDataI)
      @ 12,24 get dDataF picture "@k" valid dDataF >= dDataI
      @ 13,24 get cCodCaixa picture "@k 99" when Rodape("Esc-Encerra | F4-Caixas") valid iif(lastkey() == K_UP,.t.,Busca(Zera(@cCodCaixa),"Caixa",1,13,28,"Caixa->NomCaixa",{"Caixa Nao Cadastrado"},.f.,.t.,.f.))
      @ 14,24 get cTipHist picture "@k!" when Rodape("Esc-Encerra") valid MenuArray(@cTipHist,{{"R","Receita"},{"D","Despesa"}},14,24,14,24)
      @ 15,24 get cDemHist picture "@k!" valid MenuArray(@cDemHist,{{"S","Sim"},{"N","Nao"}},15,24,15,24)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
      Imprima(cCodCaixa,dDataI,dDataF,cTipHist,cDemHist,cDemHist)
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
//****************************************************************************
static procedure Imprima(cCodCaixa,dDataI,dDataF,cTipHist,cDemHist)
   local cTela := SaveWindow(),nTecla := 0,nVideo,lCabec := .t.,nRecno,dData
   local aCodHist := {},aValor := {},nPos := 0,nTotal := 0
   private nPagina := 1

   Msg( .t. )
   Msg( "Aguarde : Estou selecionando as informacoes" )
   Historico->(dbsetorder(2),dbgotop())
   while Historico->(!eof())
      if Historico->TipHist == cTipHist .and. Historico->DemHist == cDemHist
         aadd(aCodHist,Historico->CodHist)
      end
      Historico->(dbskip())
   end
   asize(aValor,len(aCodHist))
   afill(aValor,0)
   MovCaixa->(dbsetorder(3),dbgotop())
   while MovCaixa->(!eof())
      if MovCaixa->Data >= dDataI .and. MovCaixa->Data <= dDataF .and. MovCaixa->CodCaixa == cCodCaixa
         if !MovCaixa->Banco
            nPos := ascan(aCodHist,MovCaixa->CodHisto)
            if !(nPos == 0)
               if MovCaixa->Tipo == "1"
                  aValor[nPos] += MovCaixa->Valor
               elseif MovCaixa->Tipo == "2"
                  aValor[nPos] -= MovCaixa->Valor
               end
            end
         end
      end
      MovCaixa->(dbskip())
   end
   Msg(.f.)
   if Soma_Vetor(aValor) == 0
      Mens({"Nao Existe Lancamento"})
      return
   end
   for nI := 1 to len(aValor)
      if aValor[nI] < 0
         aValor[nI] := aValor[nI]*-1
      end
   end
   nPos := 1
   If Aviso_1(09,,14,,[Aten‡„o!],[Imprimir Demonstrativo das Despesas ?],{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
      If Ver_Imp(@nVideo)
         T_IPorta := "USB"
         begin sequence
         Set Device to Print
         while .t.
            if lCabec
               cabec(iif(nVideo == 1,80,135),cEmpFantasia,{"DEMONSTRATIVO DAS DESPESAS",;
                     "Caixa..........: "+cCodCaixa+"-"+Caixa->NomCaixa,;
                     "Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF),;
                     "Demonstrativo..: "+iif(cDemHist == "S","Sim","Nao")},.f.)
               @ prow()+1,00 say replicate("=",80)
               //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
               //                           1         2         3         4         5         6         7         8         9         0         1         2         3
               @ prow()+1,00 SAY "Historico                                                        Valor"
               //                 123 - 12345678901234567890123456789012345678901234567890     999,999.99
               //                                                                     Total: 9,999,999.99
               @ prow()+1,00 say replicate("=",80)
               @ prow(),pcol() say t_cpp10
               lCabec := .f.
            end
            if !(aValor[nPos] == 0)
               Historico->(dbsetorder(1),dbseek(aCodHist[nPos]))
               @ prow()+1,00 say aCodHist[nPos]
               @ prow()  ,06 say Historico->NomHist
               @ prow()  ,61 say aValor[nPos] picture "@e 999,999.99"
               nTotal += aValor[nPos]
            end
            nPos += 1
            if prow() > 55
               nPagina++
               lCabec := .t.
               eject
            end
            if nPos > len(aCodHist)
               exit
            end
         end
         end sequence
         @ prow()+1,00 say replicate("-",80)
         @ prow()+1,52 say "Total: "+transform(nTotal,"@e 9,999,999.99")
         FimPrinter(80)
         eject
         Set Printer to
         set device to screen
         if nVideo == 1
            Fim_Imp()
         elseif nVideo == 2
            Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,200)
         end
      end
   end
   RestWindow(cTela)
   return

//** Fim do Arquivo.
