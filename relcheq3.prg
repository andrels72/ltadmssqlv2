/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.00
 * Identificacao: Relatorios de Cheques Recebidos
 * Prefixo......: LtAdm
 * Programa.....: RelCheq3.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 08 de Agosto de 2004
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"
#include "setcurs.ch"

procedure RelCheq3
   local getlist := {},cTela := SaveWindow()
   local dDataI := date(),dDataF := date()

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
   Window(09,26,14,53)
   setcolor(Cor(11))
   //           456789012345678901234567890123456789012345678901234567890123456789012345678
   //                 1         2         3         4         5         6         7
   @ 11,28 say "Data Inicial:"
   @ 12,28 say "  Data Final:"
   while .t.
      cCodCli := space(04)
      cSitChq := space(01)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,42 get dDataI picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDataI)
      @ 12,42 get dDataF picture "@k" valid dDataF >= dDataI
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informa‡äes")
         loop
      end
      Imprima(dDataI,dDataF)
      exit
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
//****************************************************************************
static procedure Imprima(dDataI,dDataF)
   local cTela := SaveWindow(),nVideo,lCabec := .t.,nTotal := 0,nTotChq := 0,nTecla := 0
   local lTem := .f.
   private nPagina := 1

   Msg( .t. )
   Msg( "Aguarde : Estou selecionando as informacoes" )
   set softseek on
   Cheques->(dbsetorder(10),dbgotop(),dbseek(dtos(dDataI)))
   if Cheques->(eof()) .or. Cheques->DtaEmi > dDataF
      set softseek off
      Msg(.f.)
      Mens({"Nao Existe Cheques"})
   end
   Msg(.f.)
   set softseek off
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
            if Cheques->DtaEmi >= dDataI  .and. Cheques->DtaEmi <= dDataF
               if lCabec
                  cabec(96,cEmpFantasia,{"Relacao de Cheques Digitados","Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
                  @ prow()+1,00 say replicate("=",96)
                  //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                  //                           1         2         3         4         5         6         7         8         9         0         1         2         3
                  @ prow()+1,00 SAY "Lanc.   Bco Ag.  Conta           Cheque     Correntista               Vencimento      Valor"
                  //                 123456  123-1234-123456789012345-1234567890 1234567890123456789012345 99/99/9999 999,999.99
                  @ prow()+1,00 say replicate("=",96)
                  lCabec := .f.
               end
               Banco->(dbsetorder(1),dbseek(Cheques->CodBco+Cheques->NumAge+Cheques->NumCon))
               @ prow()+1,00 say Cheques->LanChe
               @ prow()  ,08 say Cheques->CodBco
               @ prow()  ,12 say Cheques->NumAge
               @ prow()  ,17 say Cheques->NumCon
               @ prow()  ,33 say Cheques->NumChq
               @ prow()  ,44 say left(Banco->NomCon,25)
               @ prow()  ,70 say Cheques->DtaVen
               @ prow()  ,81 say Cheques->ValChq picture "@e 999,999.99"
               nTotal  += Cheques->ValChq
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
                  eject
               else
                  setprc(00,00)
               end
            end
         end
         if nTotal > 0
            @ prow()+1,00 say replicate("-",96)
            @ prow()+1,00 say "Total dos Cheques : "+transform(nTotal,"@e 999,999,999.99")
            @ prow()+1,00 say " Cheques Listados : "+transform(nTotChq,"9999")
         end
      end sequence
      if nTecla == K_ESC
         FimPrinter(96,"Impressao Cancelada")
      else
         FimPrinter(96)
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
         Fim_Imp(96)
      elseif nVideo == 2
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,100)
      end
   end
   RestWindow(cTela)
   return

//** Fim do Arquivo.
