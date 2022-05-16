/*************************************************************************
 * Sistema......: Administrativo
 * Identificacao: Relatorios dos Historicos Bancarios
 * Prefixo......: LtfCaixa
 * Programa.....: RelBan2.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 21 de Outubro de 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"

procedure RelBan2()
   local cTela := SaveWindow(),nVideo,lCabec := .t.,nQtd := 0
   private nPagina := 1


   T_IPorta := "USB"
   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenHistBan()
        FechaDados()
        Msg(.f.)
        return
    endif
   Msg(.f.)
   HistBan->(dbsetorder(2),dbgotop())
   If Aviso_1(09,,14,,[Aten‡„o!],[Imprimir relat¢rio de Historico Bancario ?],{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
      If Ver_Imp(@nVideo)
         T_IPorta := "USB"
         begin sequence
         Set Device to Print
         while HistBan->(!eof())
            if lCabec
               cabec(80,cEmpFantasia,"Relatorio de Historico Bancario")
               @ prow()+1,00 say replicate("=", 80 )
               //                 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
               //                           1         2         3         4         5         6         7         8         9         0         1
               @ prow()+1,00 SAY [Codigo    Historico               Tipo]
               //                    123    12345678901234567890       X
               @ prow()+1,00 say replicate("=",80)
               lCabec := .f.
            end
            @ prow()+1,03 say HistBan->CodHis
            @ prow()  ,10 say HistBan->DesHis
            @ prow()  ,37 say HistBan->TipHis
            nQtd += 1
            HistBan->(dbskip())
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
         end sequence
         FimPrinter(80)
         @ prow()+1,00 say "Listados : "+transform(nQtd,"@ee 999,999")
         if !(left(T_IPorta,3) == "USB")
            eject
         else
            @ prow()+1,00 say ""
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
