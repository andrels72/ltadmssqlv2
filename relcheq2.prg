/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.00
 * Identificacao: Relatorios de Cheques no Periodo
 * Prefixo......: LtAdm
 * Programa.....: RelCheq.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 17 de Novembro de 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"
#include "setcurs.ch"

procedure RelCheq2
   local getlist := {},cTela := SaveWindow()
   local cTitulo
   private nQual,aCodBco := {},aNumAge := {},aNumCon := {},cNomCon,cCodCli
   private dDataI := date(),dDataF := date()

   nQual := Aviso_1(14,,19,,"Aten‡„o!","                        Listar quais Cheques?                        ",{" ^A Compensar "," ^Compensado "," ^Devolvido "," ^Todos  " }, 1, .t. )
   if nQual == -27
      return
   elseif nQual == 1
      cTitulo := "(A Compensar)"
   elseif nQual == 2
      cTitulo := "(Compensado)"
   elseif nQual == 3
      cTitulo := "(Devolvido)"
   elseif nQual == 4
      cTitulo := "(Todos)"
   end
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
   Window(08,11,15,68,chr(16)+" Cheques "+cTitulo+" "+chr(17))
   setcolor(Cor(11))
   //           345678901234567890123456789012345678901234567890123456789012345678
   //                  2         3         4         5         6         7
   @ 10,13 say " Correntista:"
   @ 11,13 say "     Cliente:"
   @ 12,13 say "Data Inicial:"
   @ 13,13 say "  Data Final:"
   while .t.
      aCodBco := {}
      aNumAge := {}
      aNumCon := {}
      cNomCon := space(30)
      cCodCli := space(04)
      cSitChq := space(01)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,27 get cNomCon picture "@k!" when nQual == 4 valid iif(!empty(cNomCon),Teste(),.t.)
      @ 11,27 get cCodCli picture "@k!" when iif(nQual == 4,Rodape("Esc-Encerra | F4-Clientes"),.f.) valid vCliente()
      @ 12,27 get dDataI  picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDataI)
      @ 13,27 get dDataF  picture "@k" valid dDataF >= dDataI
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
      if nQual == 1
         Cheques->(dbsetorder(6),dbgotop())
      elseif nQual == 2
         Cheques->(dbsetorder(7),dbgotop())
      elseif nQual == 3
         Cheques->(dbsetorder(8),dbgotop())
      end
      if nQual == 1 .or. nQual == 2 .or. nQual == 3
         Imprima(cCodCli,dDataI,dDataF)
      else
         Imprima2(cCodCli,dDataI,dDataF)
      end
      exit
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
//****************************************************************************
static procedure Imprima(cCodCli,dDataI,dDataF)
   local cTela := SaveWindow(),nVideo,lCabec := .t.,nTotal := 0,nTotChq := 0,nTecla := 0
   local aTitulos := {"Relacao de Cheques (A Compensar)",;
                      "Relacao de Cheques (Compensado)",;
                      "Relacao de Cheques (Devolvido)"},lRetorno := .t.
   local aTexto := {"Compensar ","Compensado","Devolvido "}
   private nPagina := 1,dData1,dData2,cSitChq2

   dData1   := dDataI
   dData2   := dDataF
   cSitChq2 := alltrim(str(nQual))
   Msg( .t. )
   Msg( "Aguarde : Estou selecionando as informacoes" )
   set softseek on
   Cheques->(dbseek(dtos(dDataI)))
   if nQual == 1  // A Compensar
      if Cheques->DtaVen > dDataF
         lRetorno := .f.
      end
      lCondicao := "Cheques->DtaVen >= dData1 .and. Cheques->DtaVen <= dData2 .and. Cheques->SitChq == cSitChq2 .and. empty(Cheques->DtaPag) "
   elseif nQual == 2 // Compensado
      if Cheques->DtaPag > dDataF
         lRetorno := .f.
      end
      lCondicao := "Cheques->DtaPag >= dData1 .and. Cheques->DtaPag <= dData2 .and. Cheques->SitChq == cSitChq2 .and. !empty(Cheques->DtaPag)"
   elseif nQual == 3 // Devolvido
      if Cheques->DtaDev > dDataF
         lRetorno := .f.
      end
      lCondicao := "Cheques->DtaDev >= dData1 .and. Cheques->DtaDev <= dData2 .and. Cheques->SitChq == cSitChq2 .and. !empty(Cheques->DtaDev)"
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
         Msg(.t.)
         if nVideo == 1
            Msg("Aguarde: Imprimindo (Esc-Cancela)")
         else
            Msg("Aguarde: Gerando o Relatorio (Esc-Cancela)")
         end
         Set Device to Print
         while Cheques->(!eof())
            if &lCondicao.
               if lCabec
                  cabec(140,cEmpFantasia,{aTitulos[nQual],"Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
                  @ prow()+1,00 say replicate("=",135)
                  if !(left(T_IPorta,3) == "USB")
                     @ prow(),pcol() say &cpi18.+&cpi15.
                  end
                  if nQual == 3
                     //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                     //                           1         2         3         4         5         6         7         8         9         0         1         2         3
                     @ prow()+1,00 SAY "Lanc   Bco Age. Conta           Cheque     Correntista               Vencimento      Valor Pagamento    Vl. Pago Situacao    Devolvido"
                     //                 123456 123 1234 123456789012345 1234567890 1234567890123456789012345 99/99/9999 999,999.99 99/99/9999 999,999.99 1234567890 99/99/9999
                  else
                     //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                     //                           1         2         3         4         5         6         7         8         9         0         1         2         3
                     @ prow()+1,00 SAY "Lanc    Bco  Age.  Conta            Cheque      Correntista                     Vencimento       Valor  Pagamento        Valor"
                     //                 123456  123  1234  123456789012345  1234567890  123456789012345678901234567890  99/99/9999  999,999.99  99/99/9999  999,999.99
                  end
                  @ prow()+1,00 say replicate("=",135)
                  lCabec := .f.
               end
               Banco->(dbsetorder(1),dbseek(Cheques->CodBco+Cheques->NumAge+Cheques->NumCon))
               if nQual == 3
                  @ prow()+1,000 say Cheques->LanChe
                  @ prow()  ,007 say Cheques->CodBco
                  @ prow()  ,011 say Cheques->NumAge
                  @ prow()  ,016 say Cheques->NumCon
                  @ prow()  ,032 say Cheques->NumChq
                  @ prow()  ,043 say left(Banco->NomCon,25)
                  @ prow()  ,069 say Cheques->DtaVen
                  @ prow()  ,080 say Cheques->ValChq picture "@e 999,999.99"
                  @ prow()  ,091 say Cheques->DtaPag
                  @ prow()  ,102 say Cheques->ValPag picture "@e 999,999.99"
                  @ prow()  ,113 say aTexto[val(Cheques->SitChq)]
                  @ prow()  ,124 say Cheques->DtaDev
               else
                  @ prow()+1,000 say Cheques->LanChe
                  @ prow()  ,008 say Cheques->CodBco
                  @ prow()  ,013 say Cheques->NumAge
                  @ prow()  ,019 say Cheques->NumCon
                  @ prow()  ,036 say Cheques->NumChq
                  @ prow()  ,048 say Banco->NomCon
                  @ prow()  ,080 say Cheques->DtaVen
                  @ prow()  ,092 say Cheques->ValChq picture "@e 999,999.99"
                  @ prow()  ,104 say Cheques->DtaPag
                  @ prow()  ,116 say Cheques->ValPag picture "@e 999,999.99"
               end
               if Cheques->SitChq $ "1#3"
                  nTotal += Cheques->ValChq
               elseif Cheques->SitChq == "2"
                  nTotal += Cheques->ValPag
               end
               nTotChq += 1
            end
            Cheques->( dbskip() )
            nTecla := inkey()
            if nTecla == K_ESC
               set device to screen
               keyboard " "
               If Aviso_1( 16,, 21,, [Aten‡„o!], [Deseja abortar a impress„o?], { [  ^Sim  ], [  ^N„o  ] }, 2, .t., .t. ) = 1
                  set device to print
                  nTecla := K_ESC
                  break
               else
                  nTecla := 0
                  Set Device to Print
               end
            end
            if prow() > 55
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
         if nTotal > 0
            @ prow()+1,00 say replicate("-",136)
            @ prow()+1,00 say "Total dos Cheques : "+transform(nTotal,"@e 999,999,999.99")
            @ prow()+1,00 say " Cheques Listados : "+transform(nTotChq,"9999")
         end
      end sequence
      if nTecla == K_ESC
         FimPrinter(135,"Impressao Cancelada")
      else
         FimPrinter(135)
      end
      if !(left(T_IPorta,3) == "USB")
         @ prow(),pcol() say &cpi18.
         eject
      else
         @ prow()+1,00 say ""
         setprc(00,00)
      end
      set printer to
      set device to screen
      Msg(.f.)
      if nVideo == 1
         Fim_Imp(140)
      elseif nVideo == 2
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,150)
      end
   end
   RestWindow(cTela)
   return
//****************************************************************************
static procedure Imprima2
   local cTela := SaveWindow(),nVideo,lCabec := .t.,nTotal1 := 0,nTotal2 := 0,nTotal3 := 0
   local nQtd1 := 0,nQtd2 := 0,nQtd3 := 0,nQtd := 0,aTexto := {"Compensar ","Compensado","Devolvido ",,"Negociados"}
   local nQtd5 := 0,nTotal5 := 0
   local nTecla := 0,lLixo1
   private nPagina := 1

   Cheques->(dbsetorder(6),dbgotop())
   If Ver_Imp(@nVideo)
      lLixo1 := iif(empty(cCodCli),".t.","Cheques->CodCli == cCodCli")
      if !(len(aCodBco) == 0)
         lLixo21 := "!(ascan(aCodBco,Cheques->CodBco) == 0)"
         lLixo22 := "!(ascan(aNumAge,Cheques->NumAge) == 0)"
         lLixo23 := "!(ascan(aNumCon,Cheques->NumCon) == 0)"
      else
         lLixo21 := ".t."
         lLixo22 := ".t."
         lLixo23 := ".t."
      end
      begin sequence
         Msg(.t.)
         if nVideo == 1
            Msg("Aguarde: Imprimindo (Esc-Cancela)")
         else
            Msg("Aguarde: Gerando o Relatorio (Esc-Cancela)")
         end
         Set Device to Print
         while Cheques->(!eof())
            if Cheques->DtaVen >= dDataI .and. Cheques->DtaVen <= dDataF .and. iif(nQual == 4,.t.,!(Cheques->SitChq == "5")) .and. &lLixo1. .and. &lLixo21. .and. &lLixo22. .and. &lLixo23.
               if lCabec
                  cabec(140,cEmpFantasia,{"Relacao de Cheques ( Todos )","Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
                  @ prow()+1,00 say replicate("=",135)
                  if !(left(T_IPorta,3) == "USB")
                     @ prow(),pcol() say &cpi10.+&cpi18.+&cpi15.
                  end
                  //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                  //                           1         2         3         4         5         6         7         8         9         0         1         2         3
                  @ prow()+1,00 SAY "Lanc.  Bco Age. Conta           Cheque     Correntista               Vencimento      Valor Pagamento    Vl. Pago Situacao    Devolvido"
                  //                 123456 123 1234 123456789012345 1234567890 1234567890123456789012345 99/99/9999 999,999.99 99/99/9999 999,999.99 1234567890 99/99/9999
                  @ prow()+1,00 say replicate("=",135)
                  lCabec := .f.
               end
               Banco->(dbsetorder(1),dbseek(Cheques->CodBco+Cheques->NumAge+Cheques->NumCon))
               @ prow()+1,000 say Cheques->LanChe
               @ prow()  ,007 say Cheques->CodBco
               @ prow()  ,011 say Cheques->NumAge
               @ prow()  ,016 say Cheques->NumCon
               @ prow()  ,032 say Cheques->NumChq
               @ prow()  ,043 say left(Banco->NomCon,25)
               @ prow()  ,069 say Cheques->DtaVen
               @ prow()  ,080 say Cheques->ValChq picture "@e 999,999.99"
               @ prow()  ,091 say Cheques->DtaPag
               @ prow()  ,102 say Cheques->ValPag picture "@e 999,999.99"
               @ prow()  ,113 say aTexto[val(Cheques->SitChq)]
               @ prow()  ,124 say Cheques->DtaDev
               if Cheques->SitChq == "1"
                  nTotal1 += Cheques->ValChq
                  nQtd1   += 1
               elseif Cheques->SitChq == "2"
                  nTotal2 += Cheques->ValPag
                  nQtd2   += 1
               elseif Cheques->SitChq == "3"
                  nTotal3 += Cheques->ValChq
                  nQtd3   += 1
               elseif Cheques->SitChq == "5"
                  nTotal5 += Cheques->ValChq
                  nQtd5   += 1
               end
               nQtd += 1
            end
            Cheques->( dbskip() )
            nTecla := inkey()
            if nTecla == K_ESC
               set device to screen
               keyboard " "
               If Aviso_1( 16,, 21,, [Aten‡„o!], [Deseja abortar a impress„o?], { [  ^Sim  ], [  ^N„o  ] }, 2, .t., .t. ) = 1
                  set device to print
                  nTecla := K_ESC
                  break
               else
                  nTecla := 0
                  Set Device to Print
               end
            end
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
      if !(left(T_IPorta,3) == "USB")
         @ prow(),pcol() say &cpi18.
      end
      if nTecla == K_ESC
         FimPrinter(135,"Impressao Cancelada")
      else
         FimPrinter(135)
      end
      if !(left(T_IPorta,3) == "USB")
         eject
      else
         @ prow()+1,00 say ""
         setprc(00,00)
      end
      set printer to
      set device to screen
      Msg(.f.)
      if nVideo == 1
         Fim_Imp(140)
      elseif nVideo == 2
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,200)
      end
   end
   RestWindow(cTela)
   return

static function Teste
   local nI

   Msg(.t.)
   Msg("Aguarde: Verificando Correntista")
   Banco->(dbsetorder(1),dbgotop())
   while Banco->(!eof())
      if rtrim(cNomCon) $ Banco->NomCon
         aadd(aCodBco,Banco->CodBco)
         aadd(aNumAge,Banco->NumAge)
         aadd(aNumCon,Banco->NumCon)
      end
      Banco->(dbskip())
   end
   Msg(.f.)
   if len(aCodBco) == 0
      Mens({"NÆo correntista com esse nome"})
      return(.f.)
   end
   return(.t.)

static function vCliente

   if empty(cCodCli)
      @ 11,31 say space(36)
      return(.t.)
   end
   if !Busca(Zera(@cCodCli),"Clientes",1,11,31,"'-'+left(Clientes->NomCli,35)",{"Cliente NÆo Cadastrado"},.f.,.f.,.f.)
      return(.f.)
   end
   return(.t.)





//** Fim do Arquivo.
