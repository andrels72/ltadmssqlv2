/*************************************************************************
 * Sistema......: Controle de Ceramica
 * Versao.......: 2.00
 * Identificacao: Relatorios de Cidades
 * Prefixo......: LtSCC
 * Programa.....: RelCida.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 30 de Outubro de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "inkey.ch"
#include "setcurs.ch"

procedure RelCida()
   local getlist := {},cTela := SaveWindow()
   local cEstCid

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenCidades()
      FechaDados()
      Msg(.f.)
      Return
   EndIf
   if !OpenEstados()
      FechaDados()
      Msg(.f.)
      Return
   EndIf
   Msg(.f.)
   AtivaF4()
   Window(09,10,13,60)
   setcolor(Cor(11))
   //           2345678901234567890123456789
   //                   2         3
   @ 11,12 say "Estado:"
   while .t.
      cEstCid := space(02)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,20 get cEstCid picture "@k !!" when Rodape("Esc-Encerra | F4-Estados") valid Busca(cEstCid,"Estados",1,11,23,"Estados->NomEst",{"Estado Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Busca(cEstCid,"Cidades",3,,,,{"Nao Existe Cidades Cadastradas"},.f.,.t.,.f.)
         loop
      end
      if !Confirm("Confirma a Informacao")
         loop
      end
      Imprima(cEstCid)
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
//*****************************************************************************
static procedure Imprima(cEstCid)
   local cTela := SaveWindow(),lCabec := .t.,nVideo
   local lEstCid,nCont := 0
   private nPagina := 1,cEst

   cEst    := cEstCid
   lEstCid := iif(empty(cEstCid),".t.","Cidades->EstCid == cEst")

   nTecla := 0
   Cidades->(dbsetorder(3),dbgotop())
   if Ver_Imp(@nVideo)
      T_IPorta := "USB"
      begin sequence
      Set Device to Print
      while Cidades->(!eof())
         if &lEstCid.
            if lCabec
               cabec(80,cEmpFantasia,"Relacao de Cidades "+iif(empty(cEstCid),"(Todos os Estados)","do Estado de "+cEstCid))
               //                 012345678901234567890123456789012345678901234567890123456789012345678901234567890
               //                           1         2         3         4         5         6         7         8
               @ prow()+1,00 say replicate("=",80)
               @ prow()+1,00 say "Codigo   Cidade                                                            Estado"
               //                   1234   1234567890123456789012345678901234567890                              12
               @ prow()+1,00 say replicate("=",80)
               lCabec := .f.
            end
            @ prow()+1,00 say Cidades->CodCid
            @ prow()  ,09 say rtrim(Cidades->NomCid)+replicate(".",65-len(rtrim(Cidades->NomCid)))
            @ prow()  ,78 say Cidades->EstCid
            nCont += 1
         end
         Cidades->(dbskip())
         if prow() > 54
            nPagina++
            lCabec := .t.
            if Cidades->(!eof())
               if !(left(T_IPorta,3) == "USB")
                  eject
               else
                  setprc(00,00)
               end
            end
         end
         end sequence
         FimPrinter(80)
         @ prow()+1,00 say "Listados: "+transform(nCont,"@e 999,999")
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
            Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,132)
         end
      end
   end
   RestWindow(cTela)
   return

//** Fim do Arquivo.
