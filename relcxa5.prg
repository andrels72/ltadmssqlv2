/*************************************************************************
 * Sistema......: Fluxo de Caixa
 * Versao.......: 2.00
 * Identificacao: Relatorio Livro Caixa
 * Prefixo......: LtfCaixa
 * Programa.....: REL1_5.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 17 DE JAMEIRO DE 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"
#include "setcurs.ch"

procedure RelCxa5()
   local getlist := {},cTela := SaveWindow()
   local dDataI := date(),dDataF := date(),cCodCaixa,cCodHist,nSldAnter
   local cSaldo,cDiaMes,nNrLinhas := 55

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
   Window(07,12,16,66,"> Movimento do Caixa <")
   setcolor(Cor(11))
   //           45678901234567890123456789012345678901234567890123456789012345678
   //                 2         3         4         5         6         7
   @ 09,14 say "   Data Inicial:"
   @ 10,14 say "     Data Final:"
   @ 11,14 say "          Caixa:"
   @ 12,14 say "Saldo Detalhado:"
   @ 13,14 say "  Diario/Mensal:"
   @ 14,14 say " Saldo Anterior:"
   while .t.
      cCodCaixa := space(02)
      cSaldo    := space(01)
      cDiaMes   := space(01)
      cSldAnter := space(01)
      scroll(09,31,14,59,0)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 09,31 get dDataI    picture "@k"    when Rodape("Esc-Encerra") valid NoEmpty(dDataI)
      @ 10,31 get dDataF    picture "@k"    valid dDataF >= dDataI
      @ 11,31 get cCodCaixa picture "@k 99" when Rodape("Esc-Encerra | F4-Caixas") valid iif(lastkey() == K_UP,.t.,Busca(Zera(@cCodCaixa),"Caixa",1,11,34,"Caixa->NomCaixa",{"Caixa Nao Cadastrado"},.f.,.t.,.f.))
      @ 12,31 get cSaldo    picture "@k!"   when Rodape("Esc-Encerra") valid MenuArray(@cSaldo,{{"S","Sim"},{"N","Nao"}},12,31,12,31)
      @ 13,31 get cDiaMes   picture "@k!"   valid MenuArray(@cDiaMes,{{"D","Diario"},{"M","Mensal"}},13,31,13,31)
      @ 14,31 get cSldAnter picture "@k!"   valid MenuArray(@cSldAnter,{{"S","Sim"},{"N","Nao"}},14,31,14,31)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
      if cDiaMes == "M"
         Rel1_5_1(cCodCaixa,dDataI,dDataF,cSaldo,nNrLinhas)
      else
         Rel1_5_2(cCodCaixa,dDataI,dDataF,cSaldo,nNrLinhas,cSldAnter)
      end
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
//****************************************************************************
procedure Rel1_5_1(cCodCaixa,dDataI,dDataF,cSaldo,nNrLinhas) // Mensal
   local cTela := SaveWindow(),nTecla := 0,nVideo,lCabec := .t.,nRecno,dData
   local cHistorico,lSaldoAnter := .f.,nSaldo := 0.00,nI,nLinha,nSaldoAnter
   local lSaldoTransf := .f.,lData := .t.,lTem := .f.,nTotCred,nTotDebi
   local aCodPagto := {},aVlPagtoE := {},aVlPagtoS := {},lZeros := .t.
   private nPagina := 1

   Msg( .t. )
   Msg( "Aguarde : Estou selecionando as informacoes" )
   if cSaldo == "S"
      FormaPag->(dbgotop())
      while FormaPag->(!eof())
         aadd(aCodPagto,FormaPag->CodPagto)
         aadd(aVlPagtoE,0)
         aadd(aVlPagtoS,0)
         FormaPag->(dbskip())
      end
   end
   set softseek on
   MovCaixa->(dbsetorder(3),dbseek(cCodCaixa+dtos(dDataI)))
   if MovCaixa->(eof()) .or. MovCaixa->Data > dDataF
      Msg(.f.)
      Mens({"Nao Existe Movimento"})
      set softseek off
      return
   end
   Msg(.f.)
   set softseek off
   nTotCred    := 0
   nTotDebi    := 0
   nRecno      := 0
   nSaldoAnter := 0
   //** Verifica
   Msg(.t.)
   Msg("Aguarde: Verificando o Saldo Anterior")
   MovCaixa->(dbsetorder(2),dbgotop())
   while MovCaixa->(!eof())
      if MovCaixa->CodCaixa == cCodCaixa
         if nRecno == 0
            nRecno := MovCaixa->(recno())
         end
         if MovCaixa->Data < dDataI
            if MovCaixa->Tipo == "1"
               nSaldoAnter += MovCaixa->Valor
            elseif MovCaixa->Tipo == "2"
               nSaldoAnter -= MovCaixa->Valor
            end
            dData := MovCaixa->Data
            lSaldoAnter := .t.
         else
            exit
         end
      end
      MovCaixa->(dbskip())
   end
   Msg(.f.)
   MovCaixa->(dbgoto(nRecno))
   nSaldo := nSaldoAnter
   If Aviso_1(09,,14,,[Aten‡„o!],[Imprimir Movimento do Caixa ?],{"  ^Sim  ","  ^N„o  "},1,.t.) == 1
      If Ver_Imp(@nVideo)
         T_IPorta := "USB"
         begin sequence
         Set Device to Print
         while MovCaixa->(!eof())
            if MovCaixa->CodCaixa == cCodCaixa .and. MovCaixa->Data >= dDataI .and. MovCaixa->Data <= dDataF
               if lCabec
                  cabec(140,cEmpFantasia,{"MOVIMENTO DO CAIXA (MENSAL)",;
                     "Caixa.: "+cCodCaixa+"-"+Caixa->NomCaixa,;
                     "Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)},.f.)
                     if !(left(T_IPorta,3) == "USB")
                        @ prow(),pcol() say T_ICondI
                     end
                     @ prow()+1,00 say "+"+replicate("=",135)+"+"
                     //                 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
                     //                           1         2         3         4         5         6         7         8         9         0         1         2         3
                     @ prow()+1,00 SAY "| Data          Historico                                                                                      Entradas         Saidas |"
                     //                   99/99/9999    123 - 12345678901234567890123456789012345678901234567890                                     999,999.99     999,999.99
                     //                                               Saldo Anterior ==> 9,999,999.99
                     //                                        Total de Entradas (+) ==> 9,999,999.99
                     //                                          Total de Saidas (-) ==> 9,999,999.99
                     //                                     Saldo para Transferencia ==> 9,999,999.99
                     @ prow()+1,00   say "+"+replicate("=",135)+"+"
                  lCabec := .f.
               end
               lTem := .t.
               if MovCaixa->Tipo == "1"
                  nSaldo += MovCaixa->Valor
               else
                  nSaldo -= MovCaixa->Valor
               end
               Historico->(dbsetorder(1),dbseek(MovCaixa->CodHisto))
               if lData
                  @ prow()+1,00 say "|"
                  @ prow()  ,02 say MovCaixa->Data
                  lData := .f.
                  dData := MovCaixa->Data
                  cTexto := rtrim(Historico->NomHist)+" "+rtrim(MovCaixa->Complemen1)+" "+rtrim(MovCaixa->Complemen2)
                  nLinha := mlcount(cTexto,78)
                  lLinha := .f.
                  for nI := 1 to nLinha
                     if nI == 1
                        @ prow()  ,016 say memoline(cTexto,78,nI)
                        if nLinha > 1
                           @ prow(),136 say "|"
                        end
                     else
                        @ prow()+1,000 say "|"
                        @ prow()  ,016 say memoline(cTexto,78,nI)
                     end
                  next
               else
                  cTexto := rtrim(Historico->NomHist)+" "+rtrim(MovCaixa->Complemen1)+" "+rtrim(MovCaixa->Complemen2)
                  nLinha := mlcount(cTexto,78)
                  for nI := 1 to nLinha
                     if nI == 1
                        @ prow()+1,00 say "|"
                        @ prow()  ,016 say memoline(cTexto,78,nI)
                        if nLinha > 1
                           @ prow(),136 say "|"
                        end
                     else
                        @ prow()+1,000 say "|"
                        @ prow()  ,016 say memoline(cTexto,78,nI)
                     end
                  next
               end
               if MovCaixa->Tipo == "1"
                  nTotCred += MovCaixa->Valor
               else
                  nTotDebi -= MovCaixa->Valor
               end
               if MovCaixa->Tipo == "1"
                  @ prow(),109 say MovCaixa->Valor picture "@e 999,999.99"
               elseif MovCaixa->Tipo == "2"
                  @ prow(),124 say MovCaixa->Valor picture "@e 999,999.99"
               end
               if cSaldo == "S"
                  nPosicao := ascan(aCodPagto,MovCaixa->CodPagto)
                  if MovCaixa->Tipo == "1"
                     aVlPagtoE[nPosicao] += MovCaixa->Valor
                  else
                     aVlPagtoS[nPosicao] -= MovCaixa->Valor
                  end
               end
               @ prow(),136 say "|"
            end
            MovCaixa->( dbskip() )
            if !( MovCaixa->Data == dData )
               if lTem
                  lDATA := .t.
               end
            end
            if MovCaixa->(eof())
               if prow() < 36
                  for nI := 1 to 36
                     @ prow()+1,000 say "|"
                     @ prow()  ,136 say "|"
                  next
               end
               Rodape1_5(nVideo,nSaldoAnter,nTotCred,nTotDebi,nSaldo,cSaldo,aCodPagto,aVlPagtoE,aVlPagtoS)
               if !(left(T_IPorta,3) == "USB")
                  eject
               end
               exit
            end
            if prow() > (nNrLinhas-(12+Len(aCodPagto))) //55
               nPagina++
               Rodape1_5(nVideo,nSaldoAnter,nTotCred,nTotDebi,nSaldo,cSaldo,aCodPagto,aVlPagtoE,aVlPagtoS)
               lSaldoTrans := .t.
               if !(left(T_IPorta,3) == "USB")
                  eject
               end
               lSaldoAnter := .t.
               nSaldoAnter := nSaldo
               lData := .t.
               lCabec := .t.
            end
         end
         end sequence
         if !(left(T_IPorta,3) == "USB")
            @ prow(),pcol() say T_ICondF
            eject
         end
         set printer to
         set device to screen
         if nVideo == 1
            Fim_Imp(140)
         elseif nVideo == 2
            Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,200)
         end
      end
   end
   RestWindow(cTela)
   return
//****************************************************************************
procedure Rel1_5_2(cCodCaixa,dDataI,dDataF,cSaldo,nNrLinhas,cSldAnter) // Diario
   local cTela := SaveWindow(),nTecla := 0,nVideo,lCabec := .t.,nRecno,dData
   local cHistorico,lSaldoAnter := .f.,nSaldo := 0.00,nI,nLinha,nSaldoAnter
   local lSaldoTransf := .f.,lData := .t.,lTem := .f.,nTotCred,nTotDebi
   local aCodPagto := {},aVlPagtoE := {},aVlPagtoS := {},lZeros := .t.
   private nPagina := 1

   Msg( .t. )
   Msg( "Aguarde : Estou selecionando as informacoes" )
   if cSaldo == "S"
      FormaPag->(dbgotop())
      while FormaPag->(!eof())
         aadd(aCodPagto,FormaPag->CodPagto)
         aadd(aVlPagtoE,0)
         aadd(aVlPagtoS,0)
         FormaPag->(dbskip())
      end
   end
   set softseek on
   Msg(.f.)
   MovCaixa->(dbsetorder(3),dbseek(cCodCaixa+dtos(dDataI)))
   if MovCaixa->(eof()) .or. MovCaixa->Data > dDataF
      Mens({"Nao Existe Movimento"})
      set softseek off
      return
   end
   set softseek off
   nTotCred    := 0
   nTotDebi    := 0
   nRecno      := 0
   nSaldoAnter := 0
   //** Verifica o Saldo Anterior
   Msg(.t.)
   Msg("Aguarde: Verificando o Saldo Anterior")
   MovCaixa->(dbsetorder(2),dbgotop())
   while MovCaixa->(!eof())
      if MovCaixa->CodCaixa == cCodCaixa
         if nRecno == 0
            nRecno := MovCaixa->(recno())
         end
         if MovCaixa->Data < dDataI
            if MovCaixa->Tipo == "1"
               nSaldoAnter += MovCaixa->Valor
            elseif MovCaixa->Tipo == "2"
               nSaldoAnter -= MovCaixa->Valor
            end
            dData       := MovCaixa->Data
            lSaldoAnter := .t.
         else
            exit
         end
      end
      MovCaixa->(dbskip())
   end
   Msg(.f.)
   MovCaixa->(dbgoto(nRecno))
   nSaldo := iif(cSldAnter == "S",nSaldoAnter,0)
   If Aviso_1(09,,14,,[Aten‡„o!],[Imprimir Movimento do Caixa Diario ?],{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
      If Ver_Imp(@nVideo)
         begin sequence
            Msg(.t.)
            if nVideo == 1
               Msg("Aguarde: Imprimindo")
            else
               Msg("Aguarde: Gerando o Relatorio")
            end
            set margin to 5
            Set Device to Print
            while MovCaixa->(!eof())
               if MovCaixa->CodCaixa == cCodCaixa .and. MovCaixa->Data >= dDataI .and. MovCaixa->Data <= dDataF
                  if lCabec
                     cabec(70,cEmpFantasia,{"MOVIMENTO DO CAIXA (DIARIO)",;
                        T_ICPP17+"Caixa....: "+cCodCaixa+"-"+Caixa->NomCaixa+T_ICPP10,;
                        T_ICPP17+"Periodo..: "+dtoc(dDataI)+" a "+dtoc(dDataF)+T_ICPP10,;
                        T_ICPP17+"Data.....: "+dtoc(MovCaixa->Data)+T_ICPP10},.f.)
                        if !(left(T_IPorta,3) == "USB")
                           @ prow(),pcol() say T_ICPP17
                        end
                        @ prow()+1,00 say "+"+replicate("-",134)+"+"
                        //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
                        //                           1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
                        @ prow()+1,00 SAY "| Lancamento    Historico                                                                                      Entradas         Saidas |"
                        //                       123456    123456789012345678901234567890 12345678901234567890123456789012345678901234567890            999,999.99     999,999.99
                        //                                               Saldo Anterior ==> 9,999,999.99
                        //                                        Total de Entradas (+) ==> 9,999,999.99
                        //                                          Total de Saidas (-) ==> 9,999,999.99
                        //                                     Saldo para Transferencia ==> 9,999,999.99
                        @ prow()+1,00   say "+"+replicate("=",134)+"+"
                     lCabec := .f.
                  end
                  lTem := .t.
                  if MovCaixa->Tipo == "1"
                     nSaldo += MovCaixa->Valor
                  else
                     nSaldo -= MovCaixa->Valor
                  end
                  Historico->(dbsetorder(1),dbseek(MovCaixa->CodHisto))
                  if lData
                     lData := .f.
                     dData := MovCaixa->Data
                  end
                  cTexto := rtrim(Historico->NomHist)+" "+rtrim(MovCaixa->Complemen1)+" "+rtrim(MovCaixa->Complemen2)
                  nLinha := mlcount(cTexto,78)
                  lLinha := .f.
                  @ prow()+1,00 say "|"
                  @ prow()  ,06 say MovCaixa->Lancamento
                  for nI := 1 to nLinha
                     if nI == 1
                        @ prow()  ,016 say memoline(cTexto,78,nI)
                        if nLinha > 1
                           @ prow(),135 say "|"
                        end
                     else
                        @ prow()+1,000 say "|"
                        @ prow()  ,016 say memoline(cTexto,78,nI)
                     end
                  next
                  if MovCaixa->Tipo == "1"
                     nTotCred += MovCaixa->Valor
                  else
                     nTotDebi -= MovCaixa->Valor
                  end
                  if MovCaixa->Tipo == "1"
                     @ prow(),109 say MovCaixa->Valor picture "@e 999,999.99"
                  elseif MovCaixa->Tipo == "2"
                     @ prow(),124 say MovCaixa->Valor picture "@e 999,999.99"
                  end
                  if cSaldo == "S"
                     nPosicao := ascan(aCodPagto,MovCaixa->CodPagto)
                     if MovCaixa->Tipo == "1"
                        aVlPagtoE[nPosicao] += MovCaixa->Valor
                     else
                        aVlPagtoS[nPosicao] -= MovCaixa->Valor
                     end
                  end
                  @ prow(),135 say "|"
                  @ prow(),138 say prow()  //*** Para Teste
               end
               MovCaixa->( dbskip() )
               if MovCaixa->(eof())
                  if lTem
                     if prow() < 36
                        for nI := prow() to 36
                           @ prow()+1,000 say "|"
                           @ prow()  ,135 say "|"
                           //@ prow(),138 say prow()  //*** Para Teste
                        next
                     end
                     Rodape1_5(nVideo,nSaldoAnter,nTotCred,nTotDebi,nSaldo,cSaldo,aCodPagto,aVlPagtoE,aVlPagtoS)
                     break
                     exit
                  end
               end
               if !( MovCaixa->Data == dData )
                  if lTem
                     lDATA := .t.
                     if prow() < 36
                        for nI := prow() to 36
                           @ prow()+1,000 say "|"
                           @ prow()  ,135 say "|"
//                           @ prow(),138 say prow()  //*** Para Teste
                        next
                     end
                     Rodape1_5(nVideo,nSaldoAnter,nTotCred,nTotDebi,nSaldo,cSaldo,aCodPagto,aVlPagtoE,aVlPagtoS)
                     lCabec := .t.
                     nTotCred := 0
                     nTotDebi := 0
                     nSaldoAnter := nSaldo
                     @ prow(),pcol() say T_ICPP10
                     nPagina++
                     eject
                     lTem := .f.
                  end
               end
               if prow() > (nNrLinhas-(12+Len(aCodPagto))) //55
                  nPagina++
                  Rodape1_5(nVideo,nSaldoAnter,nTotCred,nTotDebi,nSaldo,cSaldo,aCodPagto,aVlPagtoE,aVlPagtoS)
                  lSaldoTrans := .t.
                  eject
                  lSaldoAnter := .t.
                  nSaldoAnter := nSaldo
                  lData := .t.
                  lCabec := .t.
               end
            end
         end sequence
         @ prow(),pcol() say &cpi10.
         eject
         set printer to
         set device to screen
         set margin to
         Msg(.f.)
         if nVideo == 1
            Fim_Imp()
         elseif nVideo == 2
            Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,200)
         end
      end
   end
   RestWindow(cTela)
   return
//****************************************************************************
static procedure Rodape1_5(nVideo,nSaldoAnter,nTotCred,nTotDebi,nSaldo,cSaldo,aCodPagto,aVlPagtoE,aVlPagtoS)
   local nTot1 := 0,nTot2 := 0

   if cSaldo == "S"
      ApagarZeros(aCodPagto,aVlPagtoE,aVlPagtoS)
   end
   @ prow()+1,000 say "+"+replicate("=",135)+"+"
   @ prow()+1,000 say "|"
   @ prow()  ,030 say "Saldo Anterior ==>"
   @ prow()  ,049 say nSaldoAnter picture "@e 9,999,999.99"
   @ prow()  ,135 say "|"
   @ prow()+1,000 say "|"
   @ prow()  ,023 say "Total de Entradas (+) ==>"
   @ prow()  ,049 say nTotCred picture "@e 9,999,999.99"
   @ prow()  ,135 say "|"
   @ prow()+1,000 say "|"
   @ prow()  ,025 say "Total de Saidas (-) ==>"
   @ prow()  ,049 say nTotDebi*-1 picture "@e 9,999,999.99"
   @ prow()  ,135 say "|"
   @ prow()+1,000 say "|"
   @ prow()  ,020 say "Saldo para Transferencia ==>"
   @ prow()  ,049 say nSaldo picture "@e 9,999,999.99"
   @ prow()  ,135 say "|"

   if cSaldo == "S"
      @ prow()+1,00 say "+"+replicate("=",135)+"+"
      //                  234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
      //                         1         2         3         4         5         6         7         8         9         0         1         2         3
      @ prow()+1,000 say "|"
      @ prow()  ,002 say "Detalhes do Saldo                       Entradas        Saidas"
      //                  12-123456789012345678901234567890   9,999,999.99  9,999,999.99
      //                  Total ===========================>
      @ prow()  ,135 say "|"
      for nI := 1 to len(aCodPagto)
         FormaPag->(dbsetorder(1),dbseek(aCodPagto[nI]))
         @ prow()+1,000 say "|"
         @ prow()  ,002 say aCodPagto[nI]
         @ prow()  ,005 say FormaPag->NomPagto
         @ prow()  ,038 say aVlPagtoE[nI] picture "@e 9,999,999.99"
         @ prow()  ,052 say aVlPagtoS[nI]*-1 picture "@e 9,999,999.99"
         @ prow()  ,135 say "|"
         nTot1 += aVlPagtoE[nI]
         nTot2 += (aVlPagtoS[nI]*-1)
      next
      @ prow()+1,000 say "|"
      @ prow()  ,002 say "Total ===========================>"
      @ prow()  ,038 say nTot1 picture "@e 9,999,999.99"
      @ prow()  ,052 say nTot2 picture "@e 9,999,999.99"
      @ prow()  ,135 say "|"
      afill(aVlPagtoE,0)
      afill(aVlPagtoS,0)
   end
   @ prow()+1,00 say "+"+replicate("=",135)+"+"
   @ prow()+1,30 say "______________________________      ______________________________"
   @ prow()+1,30 say "            Caixa                                Visto            "
   return
//****************************************************************************
static procedure ApagarZeros(aCodPagto,aVlPagtoE,aVlPagtoS)
   local nI,nCont := 0,nVezes
   nVezes := len(aCodPagto)

   for nI := 1 to nVezes
      if empty(aVlPagtoE[ni]) .and. empty(aVlPagtoS[nI])
         adel(aCodPagto,nI)
         adel(aVlPagtoE,nI)
         adel(aVlPagtoS,nI)
         nCont += 1
      end
   next
   if !(nCont == 0)
      asize(aCodPagto,(nVezes-nCont))
      asize(aVlPagtoE,(nVezes-nCont))
      asize(aVlPagtoS,(nVezes-nCont))
   end
   return

//** Fim do Arquivo.
