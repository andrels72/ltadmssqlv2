/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 3.00
 * Identificacao: Manutencao de Caixas
 * Prefixo......: LTADM
 * Programa.....: CAIXA.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 28 DE DEZEMBRO DE 2002
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"       // Inclusao do Arquivo Header Padrao
#include "inkey.ch"   // Header para manipulacao de Teclas
#include "setcurs.ch"
#include "Fileio.ch"

procedure EmiteCupom
   local getlist := {},cTela := SaveWindow()
   local cNumPed := space(06)

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !(Abre_Dados(cDiretorio,"Produtos",1,aNumIdx[06],"Produtos",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return(.f.)
   end
   if !(Abre_Dados(cDiretorio,"Clientes",1,aNumIdx[05],"Clientes",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return(.f.)
   end
   if !(Abre_Dados(cDiretorio,"Pedidos" ,1,aNumIdx[25],"Pedidos" ,1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return(.f.)
   end
   if !(Abre_Dados(cDiretorio,"ItemPed" ,1,aNumIdx[26],"ItemPed" ,1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return(.f.)
   end
   if !(Abre_Dados(cDiretorio,"Cidades" ,1,aNumIdx[04],"Cidades" ,1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return(.f.)
   end
   if !(Abre_Dados(cDiretorio,"Tributa",1,2,"Tributa",0,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   Msg(.f.)
   Window(07,16,13,63," EmissÆo de cupom fiscal ")
   setcolor(Cor(11))
   //           901234567890123456789
   //            2         3
   @ 09,18 say " Pedido:"
   @ 10,18 say "Cliente:"
   @ 11,18 say "  Valor:"
   while .t.
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 09,27 get cNumPed picture "@k 999999" when Rodape("Esc-Encerra | F4-Pedidos") valid Busca(Zera(@cNumPed),"Pedidos",1,,,,{"Pedido nÆo cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if Pedidos->ImpCupom
         Mens({"Cupom Ja Emitido"})
         loop
      end
      Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
      Cidades->(dbsetorder(1),dbseek(Clientes->CodCid))
      if !(Cidades->EstCid == "SE")
         Mens({"Cliente fora do estado"})
         loop
      end
      @ 10,27 say Pedidos->CodCli+"-"+left(Clientes->NomCli,30)
      @ 11,27 say Pedidos->Total picture "@e 999,999.99"
      if !Confirm("Confirma as infoma‡äes")
         loop
      end
      nTotal := Pedidos->Total
      nQual := Aviso_1( 14,, 19,, [Aten‡„o!], [    Emitir Cupom Fiscal  ?    ], { [ ^Sim ], [ ^Nao ] }, 1, .t. )
      if nQual == -27
         loop
      end
      if nQual == 2
         loop
      end
      aCodPro := {}
      aQtdPro := {}
      aPcoPro := {}
      aTotIte := {}
      aDesPro := {}
      aCodTri := {}
      aTotIte := {}
      aCplPro := {}
      aUndPro := {}
      nTotal  := 0.00
      nValor  := 0.00
      ItemPed->(dbsetorder(1),dbseek(cNumPed))
      while ItemPed->NumPed == cNumPed .and. ItemPed->(!eof())
         Produtos->(dbsetorder(1),dbseek(ItemPed->CodPro))
         if !(Produtos->QteAc01 == 0)
            if ItemPed->QtdPro > Produtos->QteAc01
               nQtd := Produtos->QteAc01
            else
               nQtd := ItemPed->QtdPro
            end
            Tributa->(dbsetorder(1),dbseek(Produtos->CodTrib))
            cDesPro := Produtos->DesPro // subst(Produtos->DesPro,1,24)
            cCompl  := subst(Produtos->DesPro,23,17)
            if empty(cCompl)
               cCompl := "..."
            end
            nVlUnit := round2(Produtos->PcoCal,2)
            nValor  := round2(nVlUnit*nQtd,2)
            nTotal  += nValor
            aadd(aCodPro,ItemPed->CodPro)
            aadd(aQtdPro,nQtd)
            aadd(aPcoPro,round2(Produtos->PcoCal,2))
            aadd(aDesPro,cDesPro)
            aadd(aTotIte,nValor)
            aadd(aCplPro,cCompl)
            aadd(aCodtri,Tributa->TipTrib)
            aadd(aUndPro,Produtos->EmbPro)
         end
         ItemPed->(dbskip())
      end
      Acbr_AbreCupom()
      for nI := 1 to len(aCodPro)
         Acbr_VendeItem(aCodPro[nI],aDesPro[nI],aCodTri[nI],aQtdPro[nI],aPcoPro[nI],0,aUndPro[nI])
      next
      Acbr_SubTotalizaCupom()
      Acbr_EfetuaPagamento(nTotal,"01")
      Acbr_FechaCupom("Volte Sempre")
      nQual := Aviso_1( 14,, 19,, [Aten‡„o!], [  Cupom fiscal correto  ?    ], { [ ^Sim ], [ ^Nao ] }, 1, .t. )
      if nQual == 2
         Acbr_CancelaCupom()
      elseif nQual == 1
         while !Pedidos->(Trava_Reg())
         end
         Pedidos->ImpCupom := .t.
         Pedidos->(dbunlock())
         Msg(.t.)
         Msg("Aguarde: Confirmando o Cupom")
         for nI := 1 to len(aCodPro)
            if ItemPed->(dbsetorder(2),dbseek(cNumPed+aCodPro[nI]))
               while !ItemPed->(Trava_Reg())
               end
               ItemPed->CalPro := aQtdPro[nI]
               ItemPed->(dbunlock())
            end
            if Produtos->(dbsetorder(1),dbseek(aCodPro[nI]))
               while !Produtos->(Trava_Reg())
               end
               Produtos->QteAc01 -= aQtdPro[nI]
               Produtos->(dbunlock())
            end
         next
         Msg(.f.)
      end
   end
   FechaDados()
   RestWindow(cTela)
   return


//** Fim do arquivo.
