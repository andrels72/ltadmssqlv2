/*************************************************************************
 * Sistema......: Controle de Ceramica
 * Versao.......: 2.00
 * Identificacao: Relatorios de Fornecedores tipo Lista Telefonica
 * Prefixo......: LtSCC
 * Programa.....: RelFor2.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 17 de Novembro de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "inkey.ch"

procedure RelFor2()
   local cTela := SaveWindow(),lCabec := .t.,nVideo,cLetra,lLetra := .t.
   local nCont := 0
   private nPagina := 1

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenFornecedor()
        FechaDados()
        Msg(.f.)
        Return
   EndIf
   Msg(.f.)
   Fornece->(dbsetorder(2),dbgotop())
   If Aviso_1(09,,14,, [Aten‡„o!],[Imprimir Relat¢rio de Telefones de Fornecedores?],{ [  ^Sim  ], [  ^N„o  ]},1,.t.) == 1
      if Ver_Imp(@nVideo)
         T_IPorta := "USB"
         begin sequence
            Set Device to Print
            while Fornece->(!eof())
               if lCabec
                  cabec(80,cEmpFantasia,"Relacao de Telefones de Fornecedores")
                  //                 012345678901234567890123456789012345678901234567890123456789012345678901234567890
                  //                           1         2         3         4         5         6         7         8
                  @ prow()+1,00 say replicate("=",80)
                  @ prow()+1,00 say "Fornecedor                                         Telefone"
                  //                 1234567890123456789012345678901234567890           12345678901234567890
                  @ prow()+1,00 say replicate("=",80)
                  lCabec := .f.
                  lLetra := .t.
               end
               if lLetra
                  cLetra := upper(subst(Fornece->RazFor,1,1))
                  @ prow()+1,00 say "<<** "+cLetra+" **>>"
                  lLetra := .f.
               end
               @ prow()+1,00 say rtrim(Fornece->RazFor)+replicate(".",49-len(rtrim(Fornece->RazFor)))
               @ prow()  ,51 say Fornece->TelFor1 picture "@r (99)9999-9999"
               if !empty(Fornece->TelFor2)
                  @ prow()  ,65 say Fornece->TelFor2 picture "@r (99)9999-9999"
               end
               Fornece->(dbskip())
               nCont += 1
               if !( upper(subst(Fornece->RazFor,1,1)) == cLetra )
                  lLetra := .t.
                  @ prow()+1,00 say replicate("=",80)
               end
               if prow() > 55
                  nPagina++
                  lCabec := .t.
                  if Fornece->(!eof())
                     if !(left(T_IPorta,3) == "USB")
                        eject
                     else
                        setprc(00,00)
                     end
                  end
               end
            end
         end sequence
         FimPrinter(80)
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
            Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,132)
         end
      end
   end
   FechaDados()
   RestWindow(cTela)
   return

//** Fim do Arquivo.
