/*************************************************************************
 * Sistema......: Fluxo de Caixa
 * Identificacao: Relatorios de Caixas
 * Prefixo......: LtfCaixa
 * Programa.....: REL1_1.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 06 DE JAMEIRO DE 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"

procedure RelCxa1()
   local cTela := SaveWindow(),nVideo,lCabec := .t.,nQtd := 0
   private nPagina := 1

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenCaixa()
        FechaDados()
        Msg(.f.)
        return
    endif
   Msg(.f.)
   Caixa->(dbsetorder(1),dbgotop())
   If Aviso_1(09,,14,,[Aten‡„o!],[Imprimir Relat¢rio de Caixa ?],{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
      If Ver_Imp(@nVideo)
         T_IPorta := "USB"
         begin sequence
         Set Device to Print
         while Caixa->(!eof())
            if lCabec
               cabec(80,cEmpFantasia,"Relatorio dos Caixas")
               @ prow()+1,00 say replicate("=", 80 )
               //                 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
               //                           1         2         3         4         5         6         7         8         9         0         1
               @ prow()+1,00 SAY [Codigo    Caixa]
               //                     12
               @ prow()+1,00 say replicate("=",80)
               lCabec := .f.
            end
            @ prow()+1,04 say Caixa->CodCaixa
            @ prow()  ,10 say Caixa->NomCaixa
            nQtd += 1
            Caixa->(dbskip())
            if prow() > 55
               nPagina++
               if !(left(T_IPorta,3) == "USB")
                  eject
               else
                  @ prow()+1,00 say ""
                  setprc(00,00)
                  eject
               end
               lCabec := .t.
            end
         end
         end sequence
         FimPrinter(80)
         @ prow()+1,00 say "Listados : "+transform(nQtd,"@e 999,999")
         @ prow()+1,00 say ""
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
