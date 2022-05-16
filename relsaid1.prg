/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 3.00
 * Identificacao: Relat¢rio de Romaneio
 * Prefixo......: LTADM
 * Programa.....: RelSaid1.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 14 de Julho de 2004
 * Copyright (C): LT - LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure RelSaid1
   local getlist := {},cTela := SaveWindow()
   local aTitulo := {},aCampo := {},aMascara := {}
   private aCodPed := {},aNomCli  := {}

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenProdutos()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenClientes()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenPedidos()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenItemPed()
      FechaDados()
      Msg(.f.)
      return
   endif
   Msg(.f.)
   Window(07,04,22,71)
   setcolor(Cor(11))
   @ 20,05 to 20,70
   while .t.
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      aCodPed := {}
      aNomCli := {}
      aadd(aCodPed,space(06))
      aadd(aNomCli,space(50))
      aTitulo  := {"Numero" ,"Descricao"}
      aCampo   := {"aCodPed","aNomCli"}
      aMascara := {"@!"     ,"@!"}
      setcolor(Cor(26))
      Centro(20,01,78," F2-Confirma | F6-Exclui | F8-Abandona ")
      Rodape("Esc-Encerra")
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      keyboard chr(K_ENTER)
      while .t.
         Edita_Vet(08,05,19,70,aCampo,aTitulo,aMascara,"TbRelSaid1")
         if lastkey() == K_F8
            exit
         elseif lastkey() == K_F2
            if !Confirm("Confirma os Itens do Romaneio")
               loop
            end
            exit
         end
      end
      if lastkey() == K_F8
         exit
      end
      Imprima()
      exit
   end
   FechaDados()
   RestWindow(cTela)
   return
//****************************************************************************
static procedure Imprima
   local cTela := SaveWindow(),nVideo,lCabec := .t.,nQtd := 0
   local aChave := {},aVetPro := {},aVetPed := {},nPosi := 0,aVetQtd := {}
   local cCodPed,lCodPed := .t.,nTotPed := 0
   private nPagina := 1

   If Aviso_1(09,,14,,[Aten‡„o!],[Imprimir Romaneio ?],{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
      If Ver_Imp(@nVideo)
         T_IPorta := "USB"
         begin sequence
         for nI := 1 to len(aCodPed)
            if Pedidos->(dbsetorder(1),dbseek(aCodPed[nI]))
               nTotPed += Pedidos->Total
            end
            if ItemPed->(dbsetorder(1),dbseek(aCodPed[nI]))
               while ItemPed->NumPed == aCodPed[nI] .and. ItemPed->(!eof())
                  nPosi := ascan(aChave,aCodPed[nI]+ItemPed->CodPro)
                  if nPosi == 0
                     aadd(aChave,aCodPed[nI]+ItemPed->CodPro)
                     aadd(aVetPed,aCodped[nI])
                     aadd(aVetPro,ItemPed->CodPro)
                     aadd(aVetQtd,ItemPed->QtdPro)
                  else
                     aVetQtd[nPosi] += ItemPed->QtdPro
                  end
                  ItemPed->(dbskip())
               end
            end
         next
         Set Device to Print
         @ prow(),00 say chr(27)+chr(67)+chr(33)
         for nI := 1 to len(aChave)
            if lCodPed
               cCodPed := aVetPed[nI]
               lCodPed := .f.
            end
            if !(aVetPed[nI] == cCodPed)
               nPagina++
               eject
               lCabec := .t.
               lCodPed := .t.
            end
            if lCabec
               cabec(96,cEmpFantasia,"Romaneio de Saida")
               if !(left(T_IPorta,3) == "USB")
                  @ prow(),pcol() say T_ICPP12
               end
               @ prow()+1,00 say replicate("=",96)
               //                 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
               //                           1         2         3         4         5         6         7         8         9
               @ prow()+1,00 SAY "Numero       Codigo  Descricao                                                           Qtde."
               //                 123456  1234-123456  12345678901234567890123456789012345678901234567890  123 x 123  99,999,999
               @ prow()+1,00 say replicate("=",96)
               lCabec := .f.
            end
            Pedidos->(dbsetorder(1),dbseek(aVetPed[nI]))
            Produtos->(dbsetorder(1),dbseek(aVetPro[nI]))
            @ prow()+1,00 say aVetPed[nI]
            @ prow()  ,08 say Pedidos->CodCLi
            @ prow()  ,13 say aVetPro[nI]
            @ prow()  ,21 say Produtos->DesPro
            @ prow()  ,73 say Produtos->EmbPro
            @ prow()  ,77 say "x"
            @ prow()  ,79 say Produtos->QteEmb picture "999"
            @ prow()  ,84 say aVetQtd[nI] picture "@e 99,999,999"
            if prow() > 30
               nPagina++
               if !(left(T_IPorta,3) == "USB")
                  eject
               else
                  setprc(00,00)
               end
               lCabec := .t.
            end
         next
         end sequence
         @ prow()+1,00 say replicate("-",96)
         @ prow()+1,00 say "Valor Total: "+transform(nTotPed,"@e 999,999,999.99")
         if !(left(T_IPorta,3) == "USB")
            @ prow(),pcol() say T_ICPP10
            eject
         else
         @ prow()+1,00 say ""
            setprc(00,00)
         end
         @ prow(),pcol() say chr(27)+chr(67)+chr(66)
         set printer to
         set device to screen
         if nVideo == 1
            Fim_Imp(96)
         elseif nVideo == 2
            Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,140)
         end
      end
   end
   FechaDados()
   RestWindow(cTela)
   return
//****************************************************************************
Function TbRelSaid1(Pos_H,Pos_V,Ln,Cl,Tecla) // Gets dos Itens do Pedido
   Local GetList := {},cCampo,cCor := setcolor(),cCodigo,cLixo

   If Tecla = K_ENTER
      //** Codigo do Produto
      if Pos_H == 1
         cCampo := aCodPed[Pos_V]
         @ ln,cl get cCampo picture "@k 999999" valid vPedido(@cCampo) .and. vCodigo(cCampo,Pos_V,aCodPed)
         setcursor(SC_NORMAL)
         read
         setcursor(SC_NONE)
         if !(lastkey() == K_ESC)
            aCodPed[Pos_V] := cCampo
            aNomCli[Pos_V] := Clientes->NomCli+space(10)
            if Pos_v >= len(aCodPed)
               nItens := len(aCodPed)+1
               asize(aCodPed,nItens)
               asize(aNomCli,nItens)
               ains(aCodPed,Pos_V+1)
               ains(aNomCli,Pos_V+1)
               aCodPed[Pos_V+1] := space(06)
               aNomCli[Pos_V+1] := space(50)
               keyboard chr(K_DOWN)+replicate(chr(K_LEFT),Pos_H-1)+chr(K_ENTER)
               return(3)
            end
         end
      end
      return(2)
   elseif Tecla == K_F6
      if !Confirm("Confirma a Exclusao do Item")
         return(0)
      end
      if len(aCodPed) == 1
         aCodPed[Pos_V] := space(06)
         aNomCli[Pos_V] := space(50)
         return(3)
      end
      adel(aCodPed,Pos_V)
      adel(aNomCli,Pos_V)
      nItens := len(aCodPed)-1
      asize(aCodPed,nItens)
      asize(aNomCli,nItens)
      return(3)
   elseif Tecla == K_F2
      return(0)
   elseif Tecla == K_F8
      return(0)
   end
   Return( 1 )
//****************************************************************************
static function vPedido(cCampo)

   if !Busca(Zera(@cCampo),"Pedidos",1,,,,{"Numero Nao Cadastrado"},.f.,.f.,.f.)
      return(.f.)
   end
   if !Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
      Mens({"Cliente Nao Cadastrado"})
      return(.f.)
   end
   return(.t.)
//****************************************************************************
static function vCodigo(cCodProd,pos_v,aVet)  // Verifica se o item ja foi cadastrado

   if !(ascan(aVet,cCodProd) == 0) .and. !(aVet[Pos_V] == cCodProd)
      Mens({"Item Ja Cadastrado"})
      return(.f.)
   end
   return(.t.)
