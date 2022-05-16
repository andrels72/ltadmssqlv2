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

procedure RelProdSemNCM
   local cTela := SaveWindow(),nVideo,lCabec := .t.,nQtd := 0
   private nPagina := 1

    Msg(.t.)
    if !OpenProdutos()
        Msg(.f.)
        FechaDados()
        return
    endif
    Msg(.f.)
    Produtos->(dbsetorder(2),dbgotop())
    If Aviso_1(09,,14,,[Aten‡„o!],[Imprimir Relat¢rio de Produtos sem NCM ?],{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
        If Ver_Imp2(@nVideo,2)
            if !(nVideo = 2)
                Mens({"Op‡Æo inv lida"})
                FechaDados()
                RestWindow(cTela)
                return
            endif
            Msg(.t.)
            Msg("Aguarde: Gerando o relat¢rio")
         begin sequence
            Set Device to Print
            do while Produtos->(!eof())
                if !(Produtos->Ativo = "S") .and. !empty(Produtos->CodNcm) 
                    Produtos->(dbskip())
                    loop
                endif
               if lCabec
                  cabec(80,cEmpFantasia,"Produtos sem NCM")
                  @ prow()+1,00 say replicate("=", 80 )
                  //                 012345678901234567890123456789012345678901234567890123456789012345678901234567890
                  //                           1         2         3         4         5         6         7         8
                  @ prow()+1,00 SAY "Codigo.  Cod.Barras      Descricao"
                  //                 123456   12345678901234  1234567890123456789012345678901234567890
                  @ prow()+1,00 say replicate("=",80)
                  lCabec := .f.
               end
               @ prow()+1,01 say Produtos->CodPro
               @ prow()  ,09 say Produtos->CodBar
               @ prow()  ,25 say Produtos->DesPro
               nQtd += 1
               Produtos->(dbskip())
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
         Msg(.f.)
         if nVideo == 1
            Fim_Imp(80)
         elseif nVideo == 2
            Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,maxrow()-1,maxcol()-1,200)
         end
      end
   end
   FechaDados()
   RestWindow(cTela)
   return

//** Fim do Arquivo.
