/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 3.00
 * Identificacao: Relat¢rio de Tabela de Pre‡o
 * Prefixo......: LTADM
 * Programa.....: Relprod1.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 15 de Julho de 2004
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure RelProd1
   local getlist := {},cTela := SaveWindow()
   private cSaldo,cCodFor,cCodGru,nPct,cPreco,dData

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenCidades()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenFornecedor()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenProdutos()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenGrupos()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenSubGrupo()
      FechaDados()
      Msg(.f.)
      return
   endif
   Msg(.f.)
   DesativaF9()
   AtivaF4()
   Window(6,10,16,68)
   setcolor(Cor(11))
   //           234567890123456789012345678901234567890
   //                   2         3
   @ 08,12 say "  Produtos sem saldo:"
   @ 09,12 say "          Fornecedor:"
   @ 10,12 say "               Grupo:"
   @ 11,12 say "          Percentual:"
   @ 12,12 say "       Preco N/C/S/V:"
   @ 13,12 say " Produtos com Precos"
   @ 14,12 say "Alterados apartir de:"
   while .t.
      cSaldo  := "N"
      cCodFor := space(04)
      cCodGru := space(03)
      nPct    := 1
      cPreco  := "V"
      dData   := ctod(space(08))
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 08,34 get cSaldo  picture "@k!" when Rodape("Esc-Encerra")
      @ 09,34 get cCodFor picture "@k 9999" when Rodape("Esc-Encerra | F4-Fornecedores") valid iif(empty(cCodFor),.t.,Busca(Zera(@cCodFor),"Fornece",1,09,39,"'-'+left(Fornecedor->RazFor,27)",{"Fornecedor Nao Cadastrado"},.f.,.f.,.f.))
      @ 10,34 get cCodGru picture "@k 999" when Rodape("Esc-Encerra | F4-Grupos") valid iif(empty(cCodGru),.t.,Busca(Zera(@cCodGru),"Grupos",1,10,37,"'-'+Grupos->NomGru",{"Grupo Nao Cadastrado"},.f.,.f.,.f.))
      @ 11,34 get nPct    picture "@k 99.99%" when Rodape("Esc-Encerra") valid iif(lastkey() == K_UP,.t.,nPct > 0)
      @ 12,34 get cPreco  picture "@k!" valid cPreco $ "N/C/S/V"
      @ 14,34 get dData   picture "@k"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
      Imprima()
      exit
   end
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   end
   FechaDados()
   RestWindow(cTela)
   return
// *****************************************************************************
static procedure Imprima
   local cTela := SaveWindow(),lCabec := .t.,nVideo
   local lEstCid,nCont := 0,lSaldo,lFornec,lGrupo,lImpGru := .t.,cLixo
   local cCampo,cEstoque,nCalc
   private nPagina := 1,cEst
   nTecla := 0

   if Ver_Imp(@nVideo)
      T_IPorta := "USB"
      if cSaldo == "N"
         if !lGeral
            lSaldo := "!(Produtos->QteAc01 == 0)"
         else
            lSaldo := "!(Produtos->Qteac02 == 0)"
         end
      else
         lSaldo := ".t."
      end
      lFornec := iif(empty(cCodFor),".t.","Produtos->CodFor == cCodFor")
      lGrupo  := iif(empty(cCodGru),".t.","Produtos->CodGru == cCodGru")
      lData   := iif(empty(dData),".t.","Produtos->DtaAlt >= dData")

      set exclusive on
      use dados\tmp01 alias tmp01 new
      zap
      index on ordem+CodGru+ordef+despro to dados\tmp01
      tmp01->(dbclosearea())
      set exclusive off
      use dados\tmp01 alias tmp01 new
      set index to dados\tmp01
      Produtos->(dbsetorder(1),dbgotop())
      while Produtos->(!eof())
         if &lSaldo. .and. &lFornec. .and. &lGrupo. .and. &lData.
            Grupos->(dbsetorder(1),dbseek(Produtos->CodGru))
            tmp01->(dbappend())
            tmp01->CodPro := Produtos->CodPro
            tmp01->DesPro := Produtos->DesPro
            tmp01->CodGru := Produtos->CodGru
            tmp01->Ordem  := Grupos->NomGru
            tmp01->OrdeF  := "A"+space(29)
         end
         Produtos->(dbskip())
      end
      begin sequence
         Set Device to Print
         tmp01->(dbgotop())
         while tmp01->(!eof())
            if lCabec
               cabec(140,cEmpFantasia,"Tabela de Preco - "+iif(!lGeral,"0","1"))
               if !(left(T_IPorta,3) == "USB")
                  @ prow(),pcol() say T_ICONDI
               end
               @ prow()+1,00 say replicate("=",136)
               //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
               //                           1         2         3         4         5         6         7         8         9         0         1         2         3
               @ prow()+1,00 say "Codigo Descricao                                          Referencia      Und. x Qtde. Fornecedor             Estoque         Preco"
               //                   1234 12345678901234567890123456789012345678901234567890 123456789012345 123  x 123   12345678901234567890 9,999,999 99,999,999.99
               @ prow()+1,00 say replicate("=",136)
               lCabec := .f.
            end
            if lImpGru
               @ prow()+1,001 say "<< "+Tmp01->CodGru+"-"+tmp01->Ordem+" >>"
               lImpGru := .f.
               cLixo := tmp01->Ordem
               @ prow()+1,00 say ""
            end
            Produtos->(dbsetorder(1),dbseek(tmp01->CodPro))
            Fornecedor->(dbsetorder(1),dbseek(Produtos->CodFor))
            if cPreco == "N"
               cCampo := "Produtos->PcoNot"
            elseif cPreco == "C"
               cCampo := "Produtos->PcoCal"
            elseif cPreco == "S"
               cCampo := "Produtos->PcoSug"
            elseif cPreco == "V"
               cCampo := "Produtos->PcoVen"
            end
            cEstoque := iif(!lGeral,"Produtos->QteAc01","Produtos->QteAc02")
            nCalc := &cCampo.
            nCalc := nCalc * nPct
            @ prow()+1,000 say tmp01->CodPro
            @ prow()  ,007 say tmp01->DesPro
            @ prow()  ,058 say Produtos->RefPro
            @ prow()  ,074 say Produtos->EmbPro
            @ prow()  ,079 say "x"
            @ prow()  ,081 say Produtos->QteEmb picture "999"
            @ prow()  ,087 say left(Fornecedor->RazFor,20)
            @ prow()  ,108 say &cEstoque. picture "@e 9,999,999"
            @ prow()  ,118 say nCalc      picture "@e 99,999,999.99"
            tmp01->(dbskip())
            if prow() > 90
               nPagina++
               lCabec := .t.
               if !(left(T_IPorta,3) == "USB")
                  @ prow()+1,00 say T_ICONDF
                  eject
               else
                  @ prow()+1,00 say ""
                  setprc(00,00)
                  eject
               end
            end
            if !(tmp01->Ordem == cLixo)
               lImpGru := .t.
               @ prow()+1,00 say ""
            end
         end
      end sequence
      FimPrinter(136)
      if !(left(T_IPorta,3) == "USB")
         @ prow()+1,00 say T_ICONDF
         eject
      else
         @ prow()+1,00 say ""
         setprc(00,00)
      end
      set printer to
      set device to screen
      if nVideo == 1
         Fim_Imp(140)
      elseif nVideo == 2
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,30,100,150)
      end
   end
   RestWindow(cTela)
   return

//** Fim do Arquivo.
