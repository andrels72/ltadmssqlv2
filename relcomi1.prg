/*************************************************************************
 *       Sistema: Controle Administrativo
 *        Versao: 2.00
 * Identificacao: Relat¢rio de ComissÆo de Vendedores
 *       Prefixo: LtAdm
 *      Programa: RelComi1.PRG
 *         Autor: Andre Lucas Souza
 *          Data: 18 de Agosto de 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure RelComi1
   local getlist := {},cTela := SaveWindow()
   private cCodVen,dDataI,dDataF,cResumo

   T_IPorta := "USB"
   Msg(.t.)
   Msg("Aguarde: Abrindo o(s) Arquivo(s)")
    if !OpenVendedor()
      Msg(.f.)
      FechaDados()
      return
   end
    if !OpenPedidos()
        Msg(.f.)
        FechaDados()
        return
    endif
    if !OpenItemPed()
      FechaDados()
      Msg(.f.)
      return
    endif
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
    if !OpenPlano()
      FechaDados()
      Msg(.f.)
      return
   endif
   Msg(.f.)
   if PwNivel == "0"
      DesativaF9()
   end
   AtivaF4()
   Window(08,19,15,59)
   setcolor(Cor(11))
   @ 10,21 say "    Vendedor:"
   @ 11,21 say "Data Inicial:"
   @ 12,21 say "  Data Final:"
   @ 13,21 say "      Resumo:"
   while .t.
      cCodVen := space(02)
      dDataI  := date()
      dDataF  := date()
      cResumo := "S"
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,35 get cCodVen picture "@k 99" when Rodape("Esc-Encerra | F4-Vendedores") valid Busca(Zera(@cCodVen),"Vendedor",1,10,37,"'-'+Vendedor->Nome",{"Vendedor Nao Cadastrado"},.f.,.f.,.f.)
      @ 11,35 get dDataI  picture "@k" when Rodape("Esc-Encerra") valid iif(lastkey() == K_UP,.t.,NoEmpty(dDataI))
      @ 12,35 get dDataF  picture "@k" valid iif(lastkey() == K_UP,.t.,dDataF >= dDataI)
      @ 13,35 get cResumo picture "@k!" valid MenuArray(@cResumo,{{"S","Sim"},{"N","Nao"}},12,35)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informa‡äes")
         loop
      end
      Imprima()
   end
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   end
   FechaDados()
   RestWindow(cTela)
   return
//****************************************************************************
static procedure Imprima
   local nVideo,nTecla := 0,lCabec := .t.,dData,lData := .t.,nPctComi := 0
   local nValComi := 0,nTotPed := 0,nTotCom := 0
   private nPagina := 1

   if Ver_Imp(@nVideo)
      T_IPorta := "USB"
      begin sequence
         Msg(.t.)
         if nVideo == 2
            Msg("Aguarde: Gerando o Relatorio (Esc-Cancela)")
         else
            Msg("Aguarde: Imprimindo (Esc-Cancela)")
         end
         set device to printer
         set softseek on
         Pedidos->(dbsetorder(2),dbseek(dtos(dDataI)))
         set softseek off
         while Pedidos->(!eof())
            if Pedidos->CodVen == cCodVen .and. Pedidos->Data >= dDataI .and. Pedidos->Data <= dDataF
               if lCabec
                  cabec(140,cEmpFantasia,{"Relatorio de Comissao","No Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF),"Vendedor: "+cCodVen+"-"+Vendedor->Nome})
//                  @ prow(),pcol() say T_ICONDI
//                  @ prow()+1,00 say T_ICONDI+replicate("=",136)
                  @ prow()+1,00 say replicate("=",136)
                  //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                  //                           1         2         3         4         5         6         7         8         9         0         1         2         3
                  @ prow()+1,00 say "Pedido Cliente                                       Data       Plano                                     Valor   Comissao  Vl. Comissao"
                  //                 123456 1234-1234567890123456879012345678901234568790 99/99/9999 12-123456789012345678901234567890 999,999,999.99    99.99%    999,999.99
                  if cResumo == "N"
                     @ prow()+1,00 say "       Produto                                                    Embalagem    Qtde.   Pco. Venda          Total"
                     //                        123456-12345678901234567890123456789012345678901234567890  123 x 123  999,999   99,999.999   9,999,999.99
                  end
                  //Total:  9,999,999,999.99            9,999,999.99
                  @ prow()+1,00 say replicate("=",136)
                  lCabec := .f.
               end
               Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
               Plano->(dbsetorder(1),dbseek(Pedidos->CodPla))
               @ prow()+1,000 say Pedidos->NumPed
               @ prow()  ,007 say Pedidos->CodCli+"-"+Clientes->NomCli
               @ prow()  ,053 say Pedidos->Data
               @ prow()  ,064 say Pedidos->CodPla+"-"+Plano->DesPla
               @ prow()  ,098 say Pedidos->Total picture "@e 999,999,999.99"
               if Plano->TipOpe == "1"
                  nPctComi := Percent(Pedidos->FatCom,Pedidos->CV_Ven,4)
                  @ prow(),116 say nPctComi picture "99.99%"
               else
                  nPctComi := Percent(Pedidos->FatCom,Pedidos->CP_Ven,4)
                  @ prow(),116 say nPctComi picture "99.99%"
               end
               nValComi := Percent(nPctComi,Pedidos->Total,4)
               @ prow(),126 say nValComi picture "@e 999,999.99"
               if cResumo == "N"
                  ItemPed->(dbsetorder(1),dbseek(Pedidos->NumPed))
                  while ItemPed->NumPed == Pedidos->NumPed .and. ItemPed->(!eof())
                     Produtos->(dbsetorder(1),dbseek(ItemPed->CodPro))
                     @ prow()+1,007 say ItemPed->CodPro
                     @ prow()  ,013 say "-"+Produtos->DesPro
                     @ prow()  ,066 say Produtos->EmbPro+" x "+str(Produtos->QteEmb,3)
                     @ prow()  ,077 say ItemPed->QtdPro picture "@e 999,999"
                     @ prow()  ,087 say ItemPed->PcoVen picture "@e 99,999.999"
                     @ prow()  ,100 say ItemPed->QtdPro*ItemPed->PcoVen picture "@e 9,999,999.99"
                     ItemPed->(dbskip())
                     if prow() > 55
                        if !(left(T_IPorta,3) == "USB")
                           eject
                        else
                           @ prow()+1,00 say ""
                           setprc(00,00)
                           eject
                        end
                     end
                  end
                  @ prow()+1,00 say ""
               end
               nTotPed += Pedidos->Total
               nTotCom += nValComi
            end
            Pedidos->(dbskip())
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
            if prow() > 50
               lCabec  := .t.
               nPagina += 1
               if !(left(T_IPorta,3) == "USB")
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
         @ prow()+1,000 say replicate("-",136)
         @ prow()+1,088 say "Total:"
         @ prow()  ,096 say nTotPed picture "@e 9,999,999,999.99"
         @ prow()  ,124 say nTotCom picture "@e 9,999,999.99"
         FimPrinter(136)
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
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,180)
      end
   end
   return

//** Fim do Arquivo.
