/*************************************************************************
 * Sistema......: Controle de Ceramica
 * Versao.......: 2.00
 * Identificacao: Relatorios de Clientes tipo Lista Telefonica
 * Prefixo......: LtSCC
 * Programa.....: Rel1_2.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 21 de Agosto de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "inkey.ch"

procedure RelCli2()
   local cTela := SaveWindow(),lCabec := .t.,nVideo,cLetra,lLetra := .t.
   local nCont := 0,nTecla := 0,lTem := .f.
   private nPagina := 1

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   If !OpenClientes()
      FechaDados()
      Msg(.f.)
      Return
   EndIf
   Msg(.f.)
   Clientes->(dbsetorder(2),dbgotop())
   If Aviso_1(09,,14,, [Aten‡„o!],[Imprimir Relat¢rio de Telefones de Clientes?],{ [  ^Sim  ], [  ^N„o  ]},1,.t.) == 1
      if Ver_Imp(@nVideo)
         T_IPorta := "USB"
         begin sequence
            Msg(.t.)
            if nVideo == 1
               Msg("Aguarde: Imprimindo (Esc-Cancela)")
            else
               Msg("Aguarde: Gerando o Relatorio (Esc-Cancela)")
            end
            Set Device to Print
            while Clientes->(!eof())
               if lCabec
                  cabec(80,cEmpFantasia,"Relacao de Telefones de Clientes")
                  //                 012345678901234567890123456789012345678901234567890123456789012345678901234567890
                  //                           1         2         3         4         5         6         7         8
                  @ prow()+1,00 say replicate("=",80)
                  @ prow()+1,00 say "Cliente                                            Telefone"
                  //                 1234567890123456789012345678901234567890           12345678901234567890
                  @ prow()+1,00 say replicate("=",80)
                  lCabec := .f.
                  lLetra := .t.
               end
               if lLetra
                  cLetra := upper(subst(Clientes->NomCli,1,1))
                  @ prow()+1,00 say "<<** "+cLetra+" **>>"
                  lLetra := .f.
               end
               @ prow()+1,00 say rtrim(Clientes->NomCli)+replicate(".",49-len(rtrim(Clientes->NomCli)))
               @ prow()  ,51 say Clientes->TelCli1 picture "@r (999)9999-9999"
               if !empty(Clientes->TelCli2)
                  @ prow()  ,65 say Clientes->TelCli2 picture "@r (999)9999-9999"
               end
               if !lTem
                  lTem := .t.
               end
               Clientes->(dbskip())
               nCont += 1
               if !( upper(subst(Clientes->NomCli,1,1)) == cLetra )
                  lLetra := .t.
                  @ prow()+1,00 say replicate("=",80)
               end
               if prow() > 55
                  nPagina++
                  lCabec := .t.
                  if Clientes->(!eof())
                     if !(left(T_IPorta,3) == "USB")
                        eject
                     else
                        @ prow()+1,00 say ""
                        setprc(00,00)
                        eject
                     end
                  end
               end
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
            end
         end sequence
         if lTem .and. nTecla == K_ESC
            FimPrinter(80,"Impressao Cancelada")
         elseif lTem .and. !(nTecla == K_ESC)
            FimPrinter(80)
         end
         if !(left(T_IPorta,3) == "USB")
            eject
         else
            setprc(00,00)
         end
         set printer to
         set device to screen
         Msg(.f.)
         if nVideo == 1
            Fim_Imp(80)
         elseif nVideo == 2
            Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,132)
         end
      end
   end
   FechaDados()
   RestWindow(cTela)
   return

//** Fim do Arquivo.
