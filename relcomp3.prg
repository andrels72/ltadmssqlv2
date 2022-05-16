/*************************************************************************
 *       Sistema: Administrativo
 *        VersÆo: 2.0
 * Identificacao: Relat¢rio de Entradas - Completo
 *       Prefixo: LtAdm
 *      Programa: RelComp3.prg
 *         Autor: Andre Lucas Souza
 *          Data: 25 de Julho de 2004
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure RelComp3
   local getlist := {},cTela := SaveWindow()
   private cCodFor,dDataI,dDataF,cNumNot

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
   //** Compras
    if !OpenCompra()
        FechaDados()
        Msg(.f.)
        return
    endif
   //** Iten da Compra
    if !OpenCmp_Ite()
        FechaDados()
        Msg(.f.)
        return
    endif
   //** Natureza Fiscal
   if !OpenNatureza()
      FechaDados()
      Msg(.f.)
      return
   endif
    if !OpenProdutos()
        FechaDados()
        Msg(.f.)
        return
    endif
   Msg(.f.)
   DesativaF9()
   DesativaF4()
   AtivaF4()
   Window(08,13,15,65)
   setcolor(Cor(11))
   //           0123456789012345678901234567890
   //                     2
   @ 10,15 say "  Fornecedor:"
   @ 11,15 say "Data Inicial:"
   @ 12,15 say "  Data Final:"
   @ 13,15 say "        Nota:"
   while .t.
      cCodFor := space(04)
      dDataI  := date()
      dDataF  := date()
      cNumNot := space(06)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,29 get cCodFor picture "@k 9999";
                when Rodape("Esc-Encerra | F4-Fornecedores");
                valid iif(empty(cCodFor),.t.,Busca(Zera(@cCodFor),"Fornecedor",1,10,33,"'-'+left(Fornecedor->RazFor,30)",{"Fornecedor Nao Cadastrado"},.f.,.f.,.f.))
      @ 11,29 get dDataI  picture "@k" when Rodape("Esc-Encerra") valid iif(lastkey() == K_UP,.t.,NoEmpty(dDataI))
      @ 12,29 get dDataF  picture "@k" valid iif(lastkey() == K_UP,.t.,dDataF >= dDataI)
      @ 13,29 get cNumNot picture "@k" valid iif(empty(cNumNot),.t.,V_Zera(@cNumNot))
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
//****************************************************************************
static procedure Imprima
   local nVideo,nTecla := 0,lCabec := .t.,dData,lData := .t.,nTotal := 0
   local nQtd := 0,lFornec,lNumNot,nTotICM := 0,nTotIPI := 0
   private nPagina := 1

   lFornec := iif(empty(cCodFor),".t.","Compra->CodFor == cCodFor")
   lNumNot := iif(empty(cNumNot),".t.","Compra->NumNot == cNumNot")

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
         Compra->(dbsetorder(6),dbseek(dtos(dDataI)))
         set softseek off
         while Compra->(!eof()) .and. Compra->DtaEnt <= dDataF
            if &lFornec. .and. &lNumNot.
               if !lGeral
                  if Compra->SN
                     Compra->(dbskip())
                     loop
                  end
               else
                  if !Compra->SN
                     Compra->(dbskip())
                     loop
                  end
               end
               if lCabec
                  cabec(140,cEmpFantasia,{"Relatorio de Compra (Notas)"+"-"+iif(!lGeral,"0","1"),"No Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
                  if !(left(T_IPorta,3) == "USB")
                     @ prow(),pcol() say T_ICONDI
                  end
                  @ prow()+1,00 say replicate("=",136)
                  //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                  //                           1         2         3         4         5         6         7         8         9         0         1         2         3
                  @ prow()+1,00 say "Codigo Descricao                                          Referencia      Tri. Qtde.     IPI    Aliq.  Desc.  Pco.Unitario         Total"
                  //                 123456 12345678901234567890123456789012345678901234567890 123456789012345  12  999999.99 99.99% 99.99% 99.99%   99,999.999 99,999,999.99
                  //                                                                                                                                       ICM: 99,999,999.99
                  //                                                                                                                                       IPI: 99,999,999.99
                  @ prow()+1,00 say replicate("=",136)
                  lCabec := .f.
               end
               Fornecedor->(dbsetorder(1),dbseek(Compra->CodFor))
               Natureza->(dbsetorder(1),dbseek(Compra->CodNat))
               @ prow()+1,00 say "        Chave: "+Compra->Chave+" Nota: "+Compra->NumNot+" Serie/Sub: "+Compra->Serie+"/"+Compra->SubSerie+"  Modelo: "+Compra->Modelo+" Emissao: "+dtoc(Compra->DtaEmi)+"   Entrada: "+dtoc(Compra->DtaEnt)
               @ prow()+1,00 say "   Fornecedor: "+Compra->CodFor+"-"+Fornecedor->RazFor+"     Natureza: "+Compra->CodNat+"-"+Natureza->Descricao
               //@ prow()+1,00 say "Total da Nota: "+transform(Compra->TotalNota,"@e 9,999,999,999.99")+space(08)+"  Frete($): "+transform(Compra->FreNo1,"@e 9,999,999.99")+"  Frete(%): "+transform(Compra->FreNo2,"99.99%")+"  Credito ICMS: "+transform(Compra->ICMCre,"99.99%")+" Valor ICMS: "+transform(Compra->ValICM,"@ 9,999,999.99")
               @ prow()+1,00 say ""
               Cmp_Ite->(dbsetorder(1),dbseek(Compra->Chave))
               while Cmp_Ite->Chave == Compra->Chave .and. Cmp_Ite->(!eof())
                  Produtos->(dbsetorder(1),dbseek(Cmp_Ite->CodPro))
                  @ prow()+1,000 say Cmp_Ite->CodPro
                  @ prow()  ,007 say left(Produtos->DesPro,50)
                  @ prow()  ,058 say Produtos->RefPro
                  @ prow()  ,075 say Produtos->CodFis
                  @ prow()  ,079 say Cmp_Ite->Quantidade picture "@e 999999.99"
                  //@ prow()  ,089 say Cmp_Ite->IPIPro picture "99.99%"
                  // prow()  ,096 say Cmp_Ite->AliEnt picture "99.99%"
                  //@ prow()  ,103 say Cmp_Ite->DSCPro picture "99.99%"
                  @ prow()  ,112 say Cmp_Ite->Custo picture "@ 99,999.999"
                  @ prow()  ,123 say Cmp_Ite->Quantidade*Cmp_Ite->Custo picture "@e 99,999,999.99"
                  //nTotICM += Percent(Cmp_Ite->AliEnt,(Cmp_Ite->Quantidade*Cmp_Ite->PCOBru),4)
                  //nTotIPI += Percent(Cmp_Ite->IPIPro,(Cmp_Ite->Quantidade*Cmp_Ite->PCOBru),4)
                  Cmp_Ite->(dbskip())
                  if prow() >= 50
                     eject
                  end
               end
               if (nTotICM+nTotIPI) > 0
                  //@ prow()+1,118 say "ICM: "+transform(nTotICM,"@e 99,999,999.99")
                  //@ prow()+1,118 say "IPI: "+transform(nTotIPI,"@e 99,999,999.99")
               end
               nTotICM := 0
               nTotIPI := 0
               @ prow()+1,00 say ""
               nQtd   += 1
            end
            Compra->(dbskip())
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
                  @ prow(),pcol() say T_ICONDF
                  eject
               else
                  @ prow()+1,00 say ""
                  setprc(00,00)
                  eject
               end
            end
         end
      end sequence
      if nTecla == K_ESC
         FimPrinter(136,"Impressao Cancelada")
      else
         FimPrinter(136)
         @ prow()+1,00 say "Listados : "+transform(nQtd,"@e 999,999")
         @ prow()+1,00 say ""
      end
      if !(left(T_IPorta,3) == "USB")
         @ prow(),pcol() say T_ICONDF
         eject
      else
         setprc(00,00)
      end
      set printer to
      set device to screen
      Msg(.f.)
      if nVideo == 1
         Fim_Imp(140)
      elseif nVideo == 2
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,30,95,200)
      end
   end
   return

//** Fim do Arquivo.
