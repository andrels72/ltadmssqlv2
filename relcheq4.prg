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

procedure RelCheq4
   local getlist := {},cTela := SaveWindow()
   private cCoNeg,dDataI := date(),dDataF := date()

   T_IPorta := "USB"
   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenCheques()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenNegociad()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenNegoci()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenItemNego()
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
   Window(08,13,14,65)
   setcolor(Cor(11))
   //           456789012345678901234567890123456789012345678901234567890123456789012345678
   //                 1         2         3         4         5         6         7
   @ 10,15 say "  Negociador:"
   @ 11,15 say "Data Inicial:"
   @ 12,15 say "  Data Final:"
   while .t.
      cCodNeg := space(03)
      cSitChq := space(01)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,29 get cCodNeg picture "@k 999" when Rodape("Esc-Encerra | F4-Negociadores") valid iif(empty(cCodNeg),.t.,Busca(Zera(@cCodNeg),"Negociador",1,10,32,"'-'+Negociador->Nome",{"Negociador Nao Cadastrado"},.f.,.f.,.f.))
      @ 11,29 get dDataI picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDataI)
      @ 12,29 get dDataF picture "@k" valid dDataF >= dDataI
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
      Imprima()
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
//****************************************************************************
static procedure Imprima
   local cTela := SaveWindow(),nVideo,lCabec := .t.,nTotal := 0,nTotChq := 0
   local nDias := 0,nJuros := 0
   private nPagina := 1

   Msg( .t. )
   Msg( "Aguarde : Estou selecionando as informacoes" )
   if empty(cCodNeg)
      set softseek on
      Cheques->(dbsetorder(11),dbseek(dtos(dDataI)))
      if Cheques->(eof()) .or. Cheques->DtaNeg > dDataF
         set softseek off
         Msg(.f.)
         Mens({"Nao Existe Cheques"})
         return
      end
      lCondicao := ".t."
   else
      set softseek on
      Cheques->(dbsetorder(12),dbgotop(),dbseek(cCodNeg+dtos(dDataI)))
      if Cheques->(eof()) .or. !(Cheques->CodNeg == cCodNeg) .or. Cheques->DtaNeg > dDataF
         set softseek off
         Msg(.f.)
         Mens({"Nao Existe Cheques"})
         return
      end
      lCondicao := "Cheques->CodNeg == cCodNeg .and. Cheques->DtaNeg >= dDataI .and. Cheques->DtaNeg <= dDataF"
   end
   set softseek off
   Msg(.f.)
   If Ver_Imp(@nVideo)
      T_IPorta := "USB"
      begin sequence
      Set Device to Print
      while Cheques->(!eof())
         if &lCondicao.
            if lCabec
               cabec(140,cEmpFantasia,{"Relacao de Cheques Negociados","Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
               @ prow()+1,00 say replicate("=",135)
               if !empty(cCodNeg)
                  @ prow()+1,00 say "Negociador: "+cCodNeg+"-"+Negociador->Nome
                  @ prow()+1,00 say replicate("-",135)
               end
               //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
               //                           1         2         3         4         5         6         7         8         9         0         1         2         3
               @ prow()+1,00 SAY "Lanc.  Bco Agen Conta           Cheque     Correntista               Vencimento      Valor  Negociado      Valor   Taxa"
               //                 123456 123 1234 123456789012345 1234567890 1234567890123456789012345 99/99/9999 999,999.99 99/99/9999 999,999.99  99.99
               @ prow()+1,00 say replicate("=",135)
               lCabec := .f.
            end
            Banco->(dbsetorder(1),dbseek(Cheques->CodBco+Cheques->NumAge+Cheques->NumCon))
            ItemNego->(dbsetorder(2),dbseek(Cheques->LanChe))
            Negocia->(dbsetorder(1),dbseek(ItemNego->LancNeg))
            nDias  := Cheques->DtaVen-Negocia->Data
            nJuros := (((Cheques->ValChq*(Negocia->Taxa/100))/30)*nDias)
            @ prow()+1,000 say Cheques->LanChe
            @ prow()  ,007 say Cheques->CodBco
            @ prow()  ,011 say Cheques->NumAge
            @ prow()  ,016 say Cheques->NumCon
            @ prow()  ,032 say Cheques->NumChq
            @ prow()  ,043 say left(Banco->NomCon,25)
            @ prow()  ,069 say Cheques->DtaVen
            @ prow()  ,080 say Cheques->ValChq picture "@e 999,999.99"
            @ prow()  ,091 say Cheques->DtaNeg
            @ prow()  ,102 say Cheques->ValChq-nJuros picture "@e 999,999.99"
            @ prow()  ,114 say Negocia->Taxa picture "99.99%"
            nTotChq += 1
            nTotal  += Cheques->ValChq
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
      if nTotChq > 0
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
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,150)
      end
   end
   RestWindow(cTela)
   return

//** Fim do Arquivo.
