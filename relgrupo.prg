/*************************************************************************
 * Sistema......: Administrativo
 * Identificacao: Relatorios de Grupos
 * Prefixo......: Ltadm
 * Programa.....: RelGrupo.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 11 de Mar‡o de 2004
 * Copyright (C): LT- LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"

procedure RelGrupo()
   local cTela := SaveWindow(),nVideo,lCabec := .t.,nQtd := 0
   private nPagina := 1

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenGrupos()
        FechaDados()
        Msg(.f.)
        return
    endif
   Msg(.f.)
   Grupos->(dbsetorder(2),dbgotop())
   If Aviso_1(09,,14,,[Aten‡„o!],[Imprimir Relat¢rio de Grupos ?],{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
      If Ver_Imp(@nVideo)
         T_IPorta := "USB"
         begin sequence
            Set Device to Print
            while Grupos->(!eof())
               if lCabec
                  cabec(80,cEmpFantasia,"Relatorio de Grupos")
                  @ prow()+1,00 say replicate("=", 80 )
                  //                 012345678901234567890123456789012345678901234567890123456789012345678901234567890
                  //                           1         2         3         4         5         6         7         8
                  @ prow()+1,00 SAY "Cod.  Descricao"
                  //                  123  1234567890123456789012345678901234567890
                  @ prow()+1,00 say replicate("=",80)
                  lCabec := .f.
               end
               @ prow()+1,01 say Grupos->CodGru
               @ prow()  ,06 say Grupos->NomGru
               nQtd += 1
               Grupos->(dbskip())
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
