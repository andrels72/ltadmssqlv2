/*************************************************************************
 * Sistema......: Fluxo de Caixa
 * Identificacao: Relatorios de Formas de Pagamento
 * Prefixo......: LtFCaixa
 * Programa.....: REL1_3.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 06 DE JAMEIRO DE 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"

procedure RelCxa3()
   local cTela := SaveWindow(),nVideo,lCabec := .t.,nQtd := 1
   private nPagina := 1

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenFPagCxa()
        FechaDados()
        Msg(.f.)
        return
    endif
   Msg(.f.)
   FormaPag->(dbsetorder(1),dbgotop())
   If Aviso_1(09,,14,,[Aten‡„o!],[Imprimir Relat¢rio de Formas de Pagamento ?],{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
      If Ver_Imp(@nVideo)
         T_IPorta := "USB"
         begin sequence
            Set Device to Print
            while FormaPag->(!eof())
               if lCabec
                  cabec(80,cEmpFantasia,"Relatorio das Formas de Pagamento")
                  @ prow()+1,00 say replicate("=", 80 )
                  //                 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
                  //                           1         2         3         4         5         6         7         8         9         0         1
                  @ prow()+1,00 SAY [Codigo    Forma de Pagamento]
                  //                     12
                  @ prow()+1,00 say replicate("=",80)
                  lCabec := .f.
               end
               @ prow()+1,04 say FormaPag->CodPagto
               @ prow()  ,10 say FormaPag->NomPagto
               nQtd += 1
               FormaPag->(dbskip())
               if prow() > 55
                  nPagina++
                  lCabec := .t.
                  if !(left(T_IPorta,3) == "USB")
                     eject
                  else
                     @ prow()+1,00 say ""
                     setprc(00,00)
                     eject
                  end
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

