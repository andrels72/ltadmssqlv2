/*************************************************************************
 * Sistema......: Administrativo
 * Identificacao: Relatorios de Natureza Fiscal
 * Prefixo......: Ltadm
 * Programa.....: RelNatur.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 10 de Mar‡o de 2004
 * Copyright (C): LT- LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"

procedure RelNatur()
   local cTela := SaveWindow(),nVideo,lCabec := .t.,nQtd := 0
   private nPagina := 1

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenNatureza()
      FechaDados()
      Msg(.f.)
      return
   endif
   Msg(.f.)
   Natureza->(dbsetorder(2),dbgotop())
   If Aviso_1(09,,14,,[Aten‡„o!],[Imprimir Relat¢rio de Natureza Fiscal ?],{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
      If Ver_Imp(@nVideo)
         T_IPorta := "USB"
         begin sequence
            Set Device to Print
            while Natureza->(!eof())
               if lCabec
                  cabec(80,cEmpFantasia,"Relatorio de Natureza Fiscal")
                  @ prow()+1,00 say replicate("=", 80 )
                  //                 012345678901234567890123456789012345678901234567890123456789012345678901234567890
                  //                           1         2         3         4         5         6         7         8
                  @ prow()+1,00 SAY "Cod. Descricao                        CFO  Tipo  Opera.  Aliq.  Local"
                  //                   12 123456789012345678901234567890  1234  ENT.  TRANS.  99.99  1234567890123456
                  @ prow()+1,00 say replicate("=",80)
                  lCabec := .f.
               end
               @ prow()+1,02 say Natureza->CodNat
               @ prow()  ,05 say Natureza->DesNat
               @ prow()  ,37 say Natureza->CFONat
               @ prow()  ,43 say iif(Natureza->TipNat == "E","ENT.","SAI.")
               if Natureza->OpeNat == "C"
                  @ prow(),49 say "COMPRA"
               elseif Natureza->OpeNat == "V"
                  @ prow(),49 say "VENDA"
               elseif Natureza->OpeNat == "T"
                  @ prow(),49 say "TRANS."
               elseif Natureza->OpeNat == "D"
                  @ prow(),49 say "DEVOL."
               elseif Natureza->OpeNat == "O"
                  @ prow(),49 say "OUTRAS"
               end
               @ prow(),57 say Natureza->AliNat picture "@r 99.99"
               @ prow(),64 say iif(Natureza->LocNat == "D","DENTRO DO ESTADO","FORA DO ESTADO")
               nQtd += 1
               Natureza->(dbskip())
               if prow() > 55
                  nPagina++
                  if !(left(T_IPorta,3) == "USB")
                     eject
                  else
                     setprc(00,00)
                  end
                  lCabec := .t.
               end
            end
            FimPrinter(80)
            @ prow()+1,00 say "Listados : "+transform(nQtd,"@e 999,999")
            @ prow()+1,00 say ""
         end sequence
         if !(left(T_IPorta,3) == "USB")
            eject
         else
            setprc(00,00)
         end
         set printer to
         set device to screen
         if nVideo == 1
            Fim_Imp(80)
         elseif nVideo == 2
            Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,140)
         end
      end
   end
   FechaDados()
   RestWindow(cTela)
   return

//** Fim do Arquivo.
