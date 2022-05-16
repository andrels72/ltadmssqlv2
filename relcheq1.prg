/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.00
 * Identificacao: Relatorios do Extro de Cheques
 * Prefixo......: LtAdm
 * Programa.....: RelCheq.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 17 de Novembro de 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"
#include "setcurs.ch"

procedure RelCheq1
   local getlist := {},cTela := SaveWindow()
   local cCodCli,dDataI := date(),dDataF := date(),nOrdem

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenCheques()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenClientes()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenBanco()
        FechaDados()
        Msg(.f.)
        return
    endif
   Msg(.f.)
   AtivaF4()
   Window(08,13,15,65,chr(16)+" Extrato de Cheques "+chr(17))
   setcolor(Cor(11))
   //           456789012345678901234567890123456789012345678901234567890123456789012345678
   //                 1         2         3         4         5         6         7
   @ 10,15 say "     Cliente:"
   @ 11,15 say "Data Inicial:"
   @ 12,15 say "  Data Final:"
   @ 13,15 say "    Situacao:"
   while .t.
      cCodCli := space(04)
      cSitChq := space(01)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,29 get cCodCli picture "@k 9999" when Rodape("Esc-Encerra | F4-Clientes") valid Busca(Zera(@cCodCli),"Clientes",1,10,33,"'-'+left(Clientes->NomCli,30)",{"Cliente Nao Cadastrado"},.f.,.f.,.f.)
      @ 11,29 get dDataI picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDataI)
      @ 12,29 get dDataF picture "@k" valid dDataF >= dDataI
      @ 13,29 get cSitChq picture "@k!" valid MenuArray(@cSitChq,{{"1","A Compensar"},{"2","Compensado "},{"3","Devolvido  "},{"4","Todos      "}},13,29,13,31)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
      if cSitChq == "1"
         Cheques->(dbsetorder(3),dbgotop())
      elseif cSitChq == "2"
         Cheques->(dbsetorder(4),dbgotop())
      elseif cSitChq == "3"
         Cheques->(dbsetorder(5),dbgotop())
      end
      if cSitChq == "1" .or. cSitChq == "2" .or. cSitChq == "3"
         Imprima(cCodCli,dDataI,dDataF,cSitChq)
      elseif cSitChq == "4"
         Imprima2(cCodCli,dDataI,dDataF)
      end
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
//****************************************************************************
static procedure Imprima(cCodCli,dDataI,dDataF,cSitChq)
   local cTela := SaveWindow(),nVideo,lCabec := .t.,nTotal := 0,nTotChq := 0
   local aTitulos := {"Relacao de Cheques (A Compensar)",;
                      "Relacao de Cheques (Compensado)",;
                      "Relacao de Cheques (Devolvido)"},lRetorno := .t.
   local aTexto := {"Compensar ","Compensado","Devolvido "}
   private nPagina := 1,dData1,dData2,cSitChq2

   dData1   := dDataI
   dData2   := dDataF
   cSitChq2 := cSitChq
   Msg( .t. )
   Msg( "Aguarde : Estou selecionando as informacoes" )
   set softseek on
   Cheques->(dbseek(cCodCli+dtos(dDataI)))
   if cSitChq == "1"
      if !(Cheques->CodCli == cCodCli) .or. Cheques->DtaVen > dDataF
         lRetorno := .f.
      end
      lCondicao := "Cheques->DtaVen >= dData1 .and. Cheques->DtaVen <= dData2 .and. empty(Cheques->DtaPag) .and. Cheques->SitChq == cSitChq2 "
   elseif cSitChq == "2"
      if !(Cheques->CodCli == cCodCli) .or. Cheques->DtaPag > dDataF
         lRetorno := .f.
      end
      lCondicao := "Cheques->DtaPag >= dData1 .and. Cheques->DtaPag <= dData2 .and. !empty(Cheques->DtaPag)"
   elseif cSitChq == "3"
      if !(Cheques->CodCli == cCodCli) .or. Cheques->DtaDev > dDataF
         lRetorno := .f.
      end
      lCondicao := "Cheques->DtaDev >= dData1 .and. Cheques->DtaDev <= dData2 .and. !empty(Cheques->DtaDev)"
   end
   if !lRetorno
      Msg(.f.)
      Mens({"Nao Existe Cheques"})
      set softseek off
      return
   end
   set softseek off
   Msg(.f.)
   If Ver_Imp(@nVideo)
      T_IPorta := "USB"
      begin sequence
      Set Device to Print
      while Cheques->CodCli == cCodCli .and. Cheques->(!eof())
         if &lCondicao.
            if lCabec
               cabec(140,cEmpFantasia,{aTitulos[val(cSitChq)],"Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
               @ prow()+1,00 say replicate("=",135)
               @ prow()+1,00 say cCodCli+"-"+Clientes->NomCli
               @ prow()+1,00 say replicate("-",135)
                  //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                  //                           1         2         3         4         5         6         7         8         9         0         1         2         3
               if cSitChq == "3"
                  @ prow()+1,00 SAY "Bco Agencia    Conta           Cheque     Correntista               Vencimento      Valor Pagamento    Vl. Pago Situacao    Devolvido"
                  //                 123 1234567890 123456789012345 1234567890 1234567890123456789012345 99/99/9999 999,999.99 99/99/9999 999,999.99 1234567890 99/99/9999
               else
                  //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                  //                           1         2         3         4         5         6         7         8         9         0         1         2         3
                  @ prow()+1,00 SAY "Bco  Agencia     Conta            Cheque      Correntista                     Vencimento       Valor  Pagamento        Valor"
                  //                 123  1234567890  123456789012345  1234567890  123456789012345678901234567890  99/99/9999  999,999.99  99/99/9999  999,999.99
               end
               @ prow()+1,00 say replicate("=",135)
               lCabec := .f.
            end
            Banco->(dbsetorder(1),dbseek(Cheques->CodBco+Cheques->NumAge+Cheques->NumCon))
            if cSitChq == "3"
               @ prow()+1,000 say Cheques->CodBco
               @ prow()  ,004 say Cheques->NumAge
               @ prow()  ,015 say Cheques->NumCon
               @ prow()  ,031 say Cheques->NumChq
               @ prow()  ,042 say left(Banco->NomCon,25)
               @ prow()  ,068 say Cheques->DtaVen
               @ prow()  ,079 say Cheques->ValChq picture "@e 999,999.99"
               @ prow()  ,090 say Cheques->DtaPag
               @ prow()  ,101 say Cheques->ValPag picture "@e 999,999.99"
               @ prow()  ,112 say aTexto[val(Cheques->SitChq)]
               @ prow()  ,123 say Cheques->DtaDev
            else
               @ prow()+1,000 say Cheques->CodBco
               @ prow()  ,005 say Cheques->NumAge
               @ prow()  ,017 say Cheques->NumCon
               @ prow()  ,034 say Cheques->NumChq
               @ prow()  ,046 say Banco->NomCon
               @ prow()  ,078 say Cheques->DtaVen
               @ prow()  ,090 say Cheques->ValChq picture "@e 999,999.99"
               @ prow()  ,102 say Cheques->DtaPag
               @ prow()  ,114 say Cheques->ValPag picture "@e 999,999.99"
            end
            if Cheques->SitChq $ "1#3"
               nTotal += Cheques->ValChq
            elseif Cheques->SitChq == "2"
               nTotal += Cheques->ValPag
            end
            nTotChq += 1
         end
         Cheques->( dbskip() )
         if prow() > 55
            if !(left(T_IPorta,3) == "USB")
               @ prow(),pcol() say &cpi18.
               eject
            else
               setprc(00,00)
            end
            nPagina += 1
            lCabec := .t.
         end
      end
      end sequence
      if nTotal > 0
         @ prow()+1,00 say replicate("-",135)
         @ prow()+1,00 say "Total dos Cheques : "+transform(nTotal,"@e 999,999,999.99")
         @ prow()+1,00 say " Cheques Listados : "+transform(nTotChq,"99999999999999")
      end
      FimPrinter(135)
      if !(left(T_IPorta,3) == "USB")
         eject
      else
         @ prow()+1,00 say ""
         setprc(00,00)
      end
      set printer to
      set device to screen
      if nVideo == 1
         Fim_Imp(140)
      elseif nVideo == 2
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,200)
      end
   end
   RestWindow(cTela)
   return
//****************************************************************************
static procedure Imprima2(cCodCli,dDataI,dDataF)
   local cTela   := SaveWindow(),nVideo,lCabec := .t.,nTotal := 0,nTotChq := 0
   local nTotal1 := 0,nTotal2 := 0,nTotal3 := 0,nQtd1 := 0,nQtd2 := 0,nQtd3 := 0
   local nQtd := 0,aTexto := {"Compensar ","Compensado","Devolvido ",,"Negociado"}
   local nQtd5 := 0,nTotal5 := 0
   private nPagina := 1,dData1,dData2

   dData1 := dDataI
   dData2 := dDataF
   Msg( .t. )
   Msg( "Aguarde : Estou selecionando as informacoes" )
   set softseek on
   Cheques->(dbsetorder(3),dbgotop(),dbseek(cCodCli+dtos(dDataI)))
   if !(Cheques->CodCli == cCodCli) .or. Cheques->DtaVen > dDataF
      Msg(.f.)
      Mens({"Nao Existe Cheques"})
      set softseek off
      return
   end
   set softseek off
   Msg(.f.)
   If Ver_Imp(@nVideo)
      T_IPorta := "USB"
      begin sequence
         Set Device to Print
         while Cheques->CodCli == cCodCli .and. Cheques->(!eof())
            if lCabec
               cabec(140,cEmpFantasia,{"Extrato do Cliente - Relacao de Cheques ( Todos )","Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
               @ prow()+1,00 say replicate("=",135)
               @ prow()+1,00 say "Cliente : "+cCodCli+"-"+Clientes->NomCli
               @ prow()+1,00 say replicate("-",135)
               //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
               //                           1         2         3         4         5         6         7         8         9         0         1         2         3
               @ prow()+1,00 SAY "Bco Agencia    Conta           Cheque     Correntista               Vencimento      Valor Pagamento    Vl. Pago Situacao    Devolvido"
               //                 123 1234567890 123456789012345 1234567890 1234567890123456789012345 99/99/9999 999,999.99 99/99/9999 999,999.99 1234567890 99/99/9999
               @ prow()+1,00 say replicate("=",135)
               lCabec := .f.
            end
            Banco->(dbsetorder(1),dbseek(Cheques->CodBco+Cheques->NumAge+Cheques->NumCon))
            @ prow()+1,000 say Cheques->CodBco
            @ prow()  ,004 say Cheques->NumAge
            @ prow()  ,015 say Cheques->NumCon
            @ prow()  ,031 say Cheques->NumChq
            @ prow()  ,042 say left(Banco->NomCon,25)
            @ prow()  ,068 say Cheques->DtaVen
            @ prow()  ,079 say Cheques->ValChq picture "@e 999,999.99"
            @ prow()  ,090 say Cheques->DtaPag
            @ prow()  ,101 say Cheques->ValPag picture "@e 999,999.99"
            @ prow()  ,112 say aTexto[val(Cheques->SitChq)]
            @ prow()  ,123 say Cheques->DtaDev
            if Cheques->SitChq == "1"
               nTotal1 += Cheques->ValChq
               nQtd1 += 1
            elseif Cheques->SitChq == "2"
               nTotal2 += Cheques->ValPag
               nQtd2 += 1
            elseif Cheques->SitChq == "3"
               nTotal3 += Cheques->ValChq
               nQtd3 += 1
            elseif Cheques->SitChq == "5"
               nTotal5 += Cheques->ValChq
               nQtd5   += 1
            end
            nQtd += 1
            Cheques->( dbskip() )
            if prow() > 47
               nPagina += 1
               lCabec := .t.
               if !(left(T_IPorta,3) == "USB")
                  @ prow(),pcol() say &cpi18.
                  eject
               else
                  setprc(00,00)
               end
            end
         end
         if (nTotal1+nTotal2+nTotal3+nTotal5) > 0
            @ prow()+1,00 say replicate("-",136)
            @ prow()+1,00 say " Cheques Listados : "+transform(nQtd,"@e 9,999")
            @ prow()+1,00 say "==> Total de Cheques (A Compensar) : "+transform(nQtd1,"@e 9,999")+" ==> Valor Total : "+transform(nTotal1,"@e 999,999,999.99")
            @ prow()+1,00 say "==> Total de Cheques (Compensado)  : "+transform(nQtd2,"@e 9,999")+" ==> Valor Total : "+transform(nTotal2,"@e 999,999,999.99")
            @ prow()+1,00 say "==> Total de Cheques (Devolvido)   : "+transform(nQtd3,"@e 9,999")+" ==> Valor Total : "+transform(nTotal3,"@e 999,999,999.99")
            @ prow()+1,00 say "==> Total de Cheques (Negociado)   : "+transform(nQtd5,"@e 9,999")+" ==> Valor Total : "+transform(nTotal5,"@e 999,999,999.99")
         end
      end sequence
      FimPrinter(135)
      if !(left(T_IPorta,3) == "USB")
         eject
      else
         @ prow()+1,00 say ""
         setprc(00,00)
      end
      set printer to
      set device to screen
      if nVideo == 1
         Fim_Imp(140)
      elseif nVideo == 2
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,200)
      end
   end
   RestWindow(cTela)
   return

//** Fim do Arquivo.
