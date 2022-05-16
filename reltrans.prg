/*************************************************************************
 * Sistema......: Administrativo
 * Identificacao: Relatorios de Transportadoa
 * Prefixo......: LtfCaixa
 * Programa.....: REL1_1.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 20 de Novembro de 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"

procedure RelTransp()
   local cTela := SaveWindow(),nVideo,lCabec := .t.,nQtd := 0
   private nPagina := 1

   T_IPorta := "USB"
   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if Abre_Dados(cDiretorio,"Transpo",1,2,"Transpo",1,.f.) # 0
      FechaDados()
      Msg(.f.)
      return
   end
   Msg(.f.)
   Transpo->(dbsetorder(1),dbgotop())
   If Aviso_1(09,,14,,[Aten‡„o!],[Imprimir Relat¢rio de Transportadora ?],{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
      If Ver_Imp(@nVideo)
         begin sequence
         if nVideo == 1
            set printer to lpt1
         end
         Set Device to Print
         while Transpo->(!eof())
            if lCabec
               cabec(80,cEmpFantasia,"Relatorio de Transportadora")
               @ prow()+1,00 say replicate("=", 80 )
               //                 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
               //                           1         2         3         4         5         6         7         8         9         0         1
               @ prow()+1,00 SAY "  Placa   Motorista                        Veiculo"
               //                 AAA-999   123456789012345678901234567890   123456789012345678901234567890
               @ prow()+1,00 say replicate("=",80)
               lCabec := .f.
            end
            @ prow()+1,00 say Transpo->Placa
            @ prow()  ,10 say Transpo->Motorista
            @ prow()  ,43 say Transpo->Veiculo
            nQtd += 1
            Transpo->(dbskip())
            if prow() > 55
               nPagina++
               eject
               lCabec := .t.
            end
         end
         FimPrinter(80)
         @ prow()+1,00 say "Listados : "+transform(nQtd,"@e 999,999")
         end sequence
         eject
         set printer to
         set device to screen
         if nVideo == 2
            Ve_Txt("",Arq_Sen+".prn",02,00,23,79,140)
         end
      end
   end
   FechaDados()
   RestWindow(cTela)
   return

//** Fim do Arquivo.
