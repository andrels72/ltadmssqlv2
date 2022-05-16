/*************************************************************************
 * Sistema......: Administrativo
 * Identificacao: Relatorios do Modulo de Bancos
 * Prefixo......: LtfCaixa
 * Programa.....: RelBan.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 21 de Outubro de 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"

procedure RelBan1()
   local cTela := SaveWindow(),nVideo,lCabec := .t.,nQtd := 0,nTecla := 0
   private nPagina := 1

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenBanco()
      FechaDados()
      Msg(.f.)
      return
   end
   Msg(.f.)
   Banco->(dbsetorder(1),dbgotop())
   If Aviso_1(09,,14,,[Aten‡„o!],[Imprimir Relat¢rio de Bancos ?],{"  ^Sim  ","  ^N„o  "},1,.t.) == 1
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
            while Banco->(!eof())
               if lCabec
                  cabec(140,cEmpFantasia,"Relatorio de Bancos")
                  if !(left(T_IPorta,3) == "USB")
                     @ prow(),pcol() say T_ICONDI
                  end
                  @ prow()+1,00 say replicate("=",136)
                  //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                  //                           1         2         3         4         5         6         7         8         9         0         1         2         3
                  @ prow()+1,00 say "Bco Agencia    Conta           Nome do Banco                   Nome da Agencia       Praca                Correntista"
                  //                 123 1234567890 123456789012345 123456789012345678901234567890  12345678901234567890  12345678901234567890 123456789012345678901234567890
                  @ prow()+1,00 say replicate("=",136)
                  lCabec := .f.
               end
               @ prow()+1,000 say Banco->CodBco
               @ prow()  ,004 say Banco->NumAge
               @ prow()  ,015 say Banco->NumCon
               @ prow()  ,031 say Banco->NomBco
               @ prow()  ,063 say Banco->NomAge
               @ prow()  ,085 say Banco->PraBco
               @ prow()  ,106 say Banco->NomCon
               nQtd += 1
               Banco->(dbskip())
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
                  nPagina++
                  lCabec := .t.
                  if !(left(T_IPorta,3) == "USB")
                     @ prow(),pcol() say T_ICONDF
                     eject
                  else
                     setprc(00,00)
                  end
               end
            end
         end sequence
         if nTecla == K_ESC
            FimPrinter(136,"Impressao Cancelada")
         else
            FimPrinter(136)
            @ prow()+1,00 say "Listados : "+transform(nQtd,"@e 999,999")
         end
         if !(left(T_IPorta,3) == "USB")
            @ prow(),pcol() say T_ICONDF
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
            Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,140)
         end
      end
   end
   FechaDados()
   RestWindow(cTela)
   return

//** Fim do Arquivo.
