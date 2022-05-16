/*************************************************************************
 * Sistema......: Administrativo
 * Identificacao: Relatorios de Historicos Padr’o
 * Prefixo......: LtfCaixa
 * Programa.....: REL1_2.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 03 DE JAMEIRO DE 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"

procedure RelCxa2()
   local cTela := SaveWindow(),nVideo,lCabec := .t.,nQtd := 0
    local cImpressoraPadrao
   private nPagina := 1

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenHistCxa()
        FechaDados()
        Msg(.f.)
        return
    endif
   Msg(.f.)
   Historico->(dbsetorder(2),dbgotop())
   If Aviso_1(09,,14,,[Aten‡Æo!],[Imprimir relat½rio de Historicos Padrao ?],{ [  ^Sim  ], [  ^NÆo  ] }, 1, .t. ) = 1
      If Ver_Imp2(@nVideo,2)
        if nVideo == 1
            cImpressoraPadrao := ImpressoraPadrao()
            ImprimaUSB(cImpressoraPadrao)
            FechaDados()
            RestWindow(cTela)
            return
        endif
         begin sequence
         Set Device to Print
         while Historico->(!eof())
            if lCabec
               cabec(80,cEmpFantasia,"Relatorio dos Historicos Padrao")
               @ prow()+1,00 say replicate("=", 80 )
               //                 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
               //                           1         2         3         4         5         6         7         8         9         0         1
               @ prow()+1,00 say "Codigo  Historico                       Tipo"
               //                    123  123456789012345678901234567890
               @ prow()+1,00 say replicate("=",80)
               lCabec := .f.
            end
            @ prow()+1,03 say Historico->CodHist
            @ prow()  ,08 say Historico->NomHist
            @ prow()  ,40 say Historico->TipHist
            nQtd += 1
            Historico->(dbskip())
            if prow() > 55
               nPagina++
               lCabec := .t.
               eject
            endif
         end
         end sequence
         FimPrinter(80)
         @ prow()+1,00 say "Listados : "+transform(nQtd,"@e 999,999")
         @ prow()+1,00 say ""
        eject
         set printer to
         set device to screen
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,33,100,140)
      endif
   endif
   FechaDados()
   RestWindow(cTela)
   return



static procedure ImprimaUSB(cImpressoraPadrao)
    local nVideo,lCabec := .t.,nQtd := 0
    private oPrinter,cPrinter,cFont
    
    if !IniciaImpressora(cImpressoraPadrao)
        return
    endif
    do while Historico->(!eof())
        if lCabec
            oPrinter:SetFont(cFont,,11)
            CabecUSB(80,cEmpFantasia,"Relatorio dos Historicos Padrao")
            ImpLinha(oPrinter:prow()+1,00,replicate("=", 80 ))
            //                 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
            //                           1         2         3         4         5         6         7         8         9         0         1
            ImpLinha(oPrinter:prow()+1,00,"Codigo  Historico                       Tipo")
            //                    123  123456789012345678901234567890
            ImpLinha(oPrinter:prow()+1,00,replicate("=",80))
            lCabec := .f.
        endif
        ImpLinha(oPrinter:prow()+1,03,Historico->CodHist)
        ImpLinha(oPrinter:prow()  ,08,Historico->NomHist)
        ImpLinha(oPrinter:prow()  ,40,Historico->TipHist)
        nQtd += 1
        Historico->(dbskip())
        if oPrinter:prow() > 55
            nPagina++
            lCabec := .t.
            oPrinter:NewPage()
        endif
    enddo
    ImpLinha(oPrinter:prow()+1,00,replicate("=",80))
    ImpLinha(oPrinter:prow()+1,00,"Listados : "+transform(nQtd,"@e 999,999"))
	oPrinter:enddoc()
	oPrinter:Destroy()
    return


//** Fim do Arquivo.
