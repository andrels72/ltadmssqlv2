/*************************************************************************
 * Sistema......: Administrativo
 * Identificacao: Relatorio de Pedidos de por Periodo por Cliente
 * Prefixo......: LtAdm
 * Programa.....: RelPed1.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 22 de Novembro de 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"
#include "setcurs.ch"

procedure RelPed2
   local getlist := {},cTela := SaveWindow()
   local cCodCli,dDataI,dDataF,cResumi

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
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
    if !OpenVendedor()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenPlano()
        FechaDados()
        Msg(.f.)
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
   Msg(.f.)
   AtivaF4()
   Window(09,03,16,66)
   setcolor(Cor(11))
   //           56789012345678901234567890123456789012345678901234567890123456789012345678
   //                1         2         3         4         5         6         7
   @ 11,05 say "     Cliente:"
   @ 12,05 say "Data Inicial:"
   @ 13,05 say "  Data Final:"
   @ 14,05 say "    Resumido:"
   while .t.
      cCodCli := space(04)
      dDataI  := ctod(space(08))
      dDataF  := ctod(space(08))
      cResumi := "S"
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,19 get cCodCli picture "@k 9999";
        when Rodape("Esc-Encerra | F4-Clientes");
        valid iif(empty(cCodCli),.t.,Busca(Zera(@cCodCli),"Clientes",1,11,25,"left(Clientes->NomCli,40)",{"Cliente Nao Cadastrado"},.f.,.f.,.f.))
      @ 12,19 get dDataI picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDataI)
      @ 13,19 get dDataF picture "@k" valid dDataF >= dDataI
      @ 14,19 get cResumi picture "@k!";
                when !empty(cCodCli);
                valid MenuArray(@cResumi,{{"S","Sim"},{"N","Nao"}},14,19)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
        if empty(cCodCli)
            Imprima3(dDataI,dDataF)
        else
            if cResumi == "S"
                Imprima(cCodCli,dDataI,dDataF)
            else
                Imprima2(cCodCli,dDataI,dDataF)
            endif
        endif
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// *****************************************************************************
static procedure Imprima(cCodCli,dDataI,dDataF)
   local nVideo,lCabec := .t.,nTotal1 := 0,nTotal2 := 0,nTotal3 := 0,nTotal4 := 0
   local aTipoCobra := {"Dinheiro","Duplicata","Cheque ","Nota Promissoria","Nota de Debito "}
   private nPagina := 1

   if !Pedidos->(dbsetorder(3),dbseek(cCodCli))
      Mens({"Nao existe Proposta(s) desse cliente"})
      return
   end
   Pedidos->(dbsetorder(2),dbgotop())
   if Ver_Imp2(@nVideo)
         Msg(.t.)
         if nVideo == 1
         	Msg(.f.)
         	cImpressoraPadrao := ImpressoraPadrao()
         	ImprimaUSB(cCodCli,dDataI,dDataF,cImpressoraPadrao)
         	return
         elseif nVideo == 2
            Msg("Aguarde: Gerando o Relatorio (Esc-Cancela)")
         endif
      begin sequence
         set device to printer
         while Pedidos->(!eof())
            if Pedidos->CodCli == cCodCli .and. Pedidos->Data >= dDataI .and. Pedidos->Data <= dDataF
               if lCabec
                  cabec(140,cEmpFantasia,{"Relatorio de Proposta do Cliente - Resumido","Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
                  @ prow()+1,00 say replicate("=",136)
                  @ prow()+1,00 say "Cliente : "+cCodCli+"-"+Clientes->NomCli
                  @ prow()+1,00 say replicate("=",136)
                  //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                  //                           1         2         3         4         5         6         7         8         9         0         1         2         3
                    @ prow()+1,00 SAY "Numero    Data       Vendedor           Plano               Tipo Pagto.         Sub-Total      Entrada Desc.(%)   Desc.(R$)        Total"
                    //                 123456789 99/99/9999 12 123456789012345 12 123456789012345  1 123456789012345  999,999.99   999,999.99   999.99  999,999.99   999,999.99
                  //                                                                                   Total : 9,999,999.99 9,999,999.99         9,999,999.99 9,999,999.99
                  @ prow()+1,00 say replicate("=",136)
                  lCabec := .f.
               end
               Vendedor->(dbsetorder(1),dbseek(Pedidos->CodVen))
               Plano->(dbsetorder(1),dbseek(Pedidos->CodPla))
               @ prow()+1,000 say Pedidos->NumPed
               @ prow()  ,010 say Pedidos->Data
               @ prow()  ,021 say Pedidos->CodVen+"-"+left(Vendedor->Nome,15)
               @ prow()  ,040 say Pedidos->CodPla+"-"+left(Plano->DesPla,15)
               @ prow()  ,060 say Pedidos->TipoCobra+"-"+aTipoCobra[val(Pedidos->TipoCobra)]
               @ prow()  ,079 say Pedidos->SubTotal picture "@e 999,999.99"
               @ prow()  ,092 say Pedidos->Entrada  picture "@e 999,999.99"
               @ prow()  ,105 say Pedidos->PerDesc  picture "@e 999.99"
               @ prow()  ,113 say Pedidos->ValDesc  picture "@e 999,999.99"
               @ prow()  ,126 say Pedidos->Total    picture "@e 999,999.99"
               nTotal1 += Pedidos->SubTotal
               nTotal2 += Pedidos->Entrada
               nTotal3 += Pedidos->ValDesc
               nTotal4 += Pedidos->Total
            end
            Pedidos->(dbskip())
            if prow() > 55
               nPagina += 1
               lCabec := .t.
               if !(left(T_IPorta,3) == "USB")
                  eject
               else
                  setprc(00,00)
               end
            end
         end
      end sequence
      @ prow()+1,000 say replicate("-",136)
      @ prow()+1,066 say "Total : "
      @ prow()  ,077 say nTotal1 picture "@e 9,999,999.99"
      @ prow()  ,090 say nTotal2 picture "@e 9,999,999.99"
      @ prow()  ,111 say nTotal3 picture "@e 9,999,999.99"
      @ prow()  ,124 say nTotal4 picture "@e 9,999,999.99"
      FimPrinter(136)
      @ prow()+1,00 say ""
        setprc(00,00)
      set printer to
      set device to screen
      Msg(.f.)
      Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,30,100,180)
   end
   return

static procedure Imprima2(cCodCli,dDataI,dDataF)
   local nVideo,lCabec := .t.,nTotal1 := 0,nTotal2 := 0,nTotal3 := 0,nTotal4 := 0
   local aTipoCobra := {"Dinheiro","Duplicata","Cheque ","Nota Promissoria","Nota de Debito "}
   private nPagina := 1

   if !Pedidos->(dbsetorder(3),dbseek(cCodCli))
      Mens({"Nao existe Proposta(s) desse cliente"})
      return
   end
   Pedidos->(dbsetorder(2),dbgotop())
   if Ver_Imp2(@nVideo)

         Msg(.t.)
         if nVideo == 1
            Msg(.f.)
			cImpressoraPadrao := ImpressoraPadrao()
			Imprima2USB(cCodCli,dDataI,dDataF,cImpressoraPadrao)
			return
         elseif nVideo == 2
            Msg("Aguarde: Gerando o Relatorio (Esc-Cancela)")
         endif
      begin sequence         
         set device to printer
         while Pedidos->(!eof())
            if Pedidos->CodCli == cCodCli .and. Pedidos->Data >= dDataI .and. Pedidos->Data <= dDataF
               if lCabec
                  cabec(140,cEmpFantasia,{"Relatorio de Proposta do Cliente - Nao Resumido","Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
                  @ prow()+1,00 say replicate("=",136)
                  @ prow()+1,00 say "Cliente : "+cCodCli+"-"+Clientes->NomCli
                  @ prow()+1,00 say replicate("=",136)
                  //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                  //                           1         2         3         4         5         6         7         8         9         0         1         2         3
                  @ prow()+1,00 SAY "Numero    Data       Vendedor           Plano               Tipo Pagto.         Sub-Total      Entrada Desc.(%)   Desc.(R$)        Total"
                  //                 123456789 99/99/9999 12 123456789012345 12 123456789012345  1 123456789012345  999,999.99   999,999.99   999.99  999,999.99   999,999.99
                  //
                  //                                                                                       Total : 9,999,999.99 9,999,999.99         9,999,999.99 9,999,999.99
                  //                    123456 12345678901234567890123456789012345678901234567890  1234 999,999 x 99,999.999 = 9,999,999.99
                  @ prow()+1,00 say replicate("=",136)
                  lCabec := .f.
               end
               Vendedor->(dbsetorder(1),dbseek(Pedidos->CodVen))
               Plano->(dbsetorder(1),dbseek(Pedidos->CodPla))
               @ prow()+1,000 say Pedidos->NumPed
               @ prow()  ,010 say Pedidos->Data
               @ prow()  ,021 say Pedidos->CodVen+"-"+left(Vendedor->Nome,15)
               @ prow()  ,040 say Pedidos->CodPla+"-"+left(Plano->DesPla,15)
               @ prow()  ,060 say Pedidos->TipoCobra+"-"+aTipoCobra[val(Pedidos->TipoCobra)]
               @ prow()  ,079 say Pedidos->SubTotal picture "@e 999,999.99"
               @ prow()  ,092 say Pedidos->Entrada  picture "@e 999,999.99"
               @ prow()  ,105 say Pedidos->PerDesc  picture "@e 999.99"
               @ prow()  ,113 say Pedidos->ValDesc  picture "@e 999,999.99"
               @ prow()  ,126 say Pedidos->Total    picture "@e 999,999.99"
               if ItemPed->(dbsetorder(1),dbseek(Pedidos->NumPed))
                  @ prow()+1,00 say ""
                  while ItemPed->NumPed == Pedidos->NumPed .and. ItemPed->(!eof())
                     Produtos->(dbsetorder(1),dbseek(ItemPed->CodPro))
                     @ prow()+1,03 say ItemPed->Codpro
                     @ prow()  ,10 say Produtos->FanPro
                     @ prow()  ,62 say Produtos->embPro
                     @ prow()  ,67 say ItemPed->QtdPro picture "@e 999,999"
                     @ prow()  ,75 say "X"
                     @ prow()  ,77 say ItemPed->PcoVen picture "@e 99,999.999"
                     @ prow()  ,88 say "="
                     @ prow()  ,90 say ItemPed->PcoVen * ItemPed->QtdPro picture "@e 9,999,999.99"
                     ItemPed->(dbskip())
                     if prow() > 90
                           eject
                     end
                  end
                  @ prow()+1,00 say ""
               end
               nTotal1 += Pedidos->SubTotal
               nTotal2 += Pedidos->Entrada
               nTotal3 += Pedidos->ValDesc
               nTotal4 += Pedidos->Total
            end
            Pedidos->(dbskip())
            if prow() > 55
               nPagina += 1
               lCabec := .t.
                eject
            end
         end
      end sequence
      @ prow()+1,000 say replicate("-",136)
      @ prow()+1,066 say "Total : "
      @ prow()  ,077 say nTotal1 picture "@e 9,999,999.99"
      @ prow()  ,090 say nTotal2 picture "@e 9,999,999.99"
      @ prow()  ,111 say nTotal3 picture "@e 9,999,999.99"
      @ prow()  ,124 say nTotal4 picture "@e 9,999,999.99"
      FimPrinter(136)
         eject
      set printer to
      set device to screen
      Msg(.f.)
      Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,30,100,180)
   end
   return
// **********************************************************************************************************
static procedure ImprimaUSB(cCodCli,dDataI,dDataF,cImpressoraPadrao)
   local lCabec := .t.,nTotal1 := 0,nTotal2 := 0,nTotal3 := 0,nTotal4 := 0
   local aTipoCobra := {"Dinheiro","Duplicata","Cheque ","Nota Promissoria","Nota de Debito "}
   private oPrinter,cPrinter,cFont,nPagina := 1

	if !IniciaImpressora(cImpressoraPadrao,.t.)
		return
	endif

         do while Pedidos->(!eof())
            if Pedidos->CodCli == cCodCli .and. Pedidos->Data >= dDataI .and. Pedidos->Data <= dDataF
               	if lCabec
               		oPrinter:setfont(cFont,,11)
               		oPrinter:setFont(cFont,,18)
                  	CabecUSB(140,cEmpFantasia,{"Relatorio de Proposta do Cliente - Resumido","Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
                  	ImpLinha(oPrinter:prow()+1,00,replicate("=",136))
                  	ImpLinha(oPrinter:prow()+1,00,"Cliente : "+cCodCli+"-"+Clientes->NomCli)
                  	ImpLinha(oPrinter:prow()+1,00,replicate("=",136))
                  	//                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                  	//                           1         2         3         4         5         6         7         8         9         0         1         2         3
                  	ImpLinha(oPrinter:prow()+1,00,"Numero Data       Vendedor           Plano               Tipo Pagto.         Sub-Total      Entrada Desc.(%)   Desc.(R$)        Total")
                  	//                 123456 99/99/9999 12 123456789012345 12 123456789012345  1 123456789012345  999,999.99   999,999.99   999.99  999,999.99   999,999.99
                  	//                                                                                   Total : 9,999,999.99 9,999,999.99         9,999,999.99 9,999,999.99
                  	ImpLinha(oPrinter:prow()+1,00,replicate("=",136))
                  	lCabec := .f.
               	endif
               	Vendedor->(dbsetorder(1),dbseek(Pedidos->CodVen))
               	Plano->(dbsetorder(1),dbseek(Pedidos->CodPla))
               	ImpLinha(oPrinter:prow()+1,000,Pedidos->NumPed)
               	ImpLinha(oPrinter:prow()  ,007,dtoc(Pedidos->Data))
               	ImpLinha(oPrinter:prow()  ,018,Pedidos->CodVen)
               	ImpLinha(oPrinter:prow()  ,021,left(Vendedor->Nome,15))
               	ImpLinha(oPrinter:prow()  ,037,Pedidos->CodPla)
               	ImpLinha(oPrinter:prow()  ,040,left(Plano->DesPla,15))
               	ImpLinha(oPrinter:prow()  ,057,Pedidos->TipoCobra)
               	ImpLinha(oPrinter:prow()  ,059,aTipoCobra[val(Pedidos->TipoCobra)])
               	ImpLinha(oPrinter:prow()  ,076,transform(Pedidos->SubTotal,"@e 999,999.99"))
               	ImpLinha(oPrinter:prow()  ,089,transform(Pedidos->Entrada,"@e 999,999.99"))
               	ImpLinha(oPrinter:prow()  ,102,transform(Pedidos->PerDesc,"@e 999.99"))
               	ImpLinha(oPrinter:prow()  ,110,transform(Pedidos->ValDesc,"@e 999,999.99"))
               	ImpLinha(oPrinter:prow()  ,123,transform(Pedidos->Total,"@e 999,999.99"))
               	nTotal1 += Pedidos->SubTotal
               	nTotal2 += Pedidos->Entrada
               	nTotal3 += Pedidos->ValDesc
               	nTotal4 += Pedidos->Total
            endif
            Pedidos->(dbskip())
            if oPrinter:prow() > 65
               nPagina += 1
               lCabec  := .t.
               oPrinter:NewPage()
            endif
        enddo
    	ImpLinha(oPrinter:prow()+1,000,replicate("-",136))
    	ImpLinha(oPrinter:prow()+1,066,"Total : ")
      	ImpLinha(oPrinter:prow()  ,074,transform(nTotal1,"@e 9,999,999.99"))
      	ImpLinha(oPrinter:prow()  ,087,transform(nTotal2,"@e 9,999,999.99"))
      	ImpLinha(oPrinter:prow()  ,108,transform(nTotal3,"@e 9,999,999.99"))
      	ImpLinha(oPrinter:prow()  ,121,transform(nTotal4,"@e 9,999,999.99"))
      	oPrinter:EndDoc()
      	oPrinter:Destroy()
   return
   
static procedure Imprima2USB(cCodCli,dDataI,dDataF,cImpressoraPadrao)
   local lCabec := .t.,nTotal1 := 0,nTotal2 := 0,nTotal3 := 0,nTotal4 := 0
   local aTipoCobra := {"Dinheiro","Duplicata","Cheque ","Nota Promissoria","Nota de Debito "}
   private oPrinter,cPrinter,cFont,nPagina := 1

	if !IniciaImpressora(cImpressoraPadrao,.t.)
		return
	endif

         while Pedidos->(!eof())
            if Pedidos->CodCli == cCodCli .and. Pedidos->Data >= dDataI .and. Pedidos->Data <= dDataF
               if lCabec
               		oPrinter:setfont(cFont,,11)
               		oPrinter:setFont(cFont,,18)
                  	CabecUSB(140,cEmpFantasia,{"Relatorio de Proposta do Cliente - Nao Resumido","Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
                  	ImpLinha(oPrinter:prow()+1,00,replicate("=",136))
                  	ImpLinha(oPrinter:prow()+1,00,"Cliente : "+cCodCli+"-"+Clientes->NomCli)
                  	ImpLinha(oPrinter:prow()+1,00,replicate("=",136))
                  	//                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                  	//                           1         2         3         4         5         6         7         8         9         0         1         2         3
                    ImpLinha(oPrinter:prow()+1,00,"Numero    Data       Vendedor           Plano               Tipo Pagto.         Sub-Total      Entrada Desc.(%)   Desc.(R$)        Total")
                  	//                             123456 99/99/9999 12 123456789012345 12 123456789012345  1 123456789012345  999,999.99   999,999.99   999.99  999,999.99   999,999.99
                  	//
                  	//                                                                                       Total : 9,999,999.99 9,999,999.99         9,999,999.99 9,999,999.99
                  	//                        123456 12345678901234567890123456789012345678901234567890  999,999  99,999.999  9,999,999.99
                  	ImpLinha(oPrinter:prow()+1,00,replicate("=",136))
                  	lCabec := .f.
               endif
               Vendedor->(dbsetorder(1),dbseek(Pedidos->CodVen))
               Plano->(dbsetorder(1),dbseek(Pedidos->CodPla))
               ImpLinha(oPrinter:prow()+1,000,Pedidos->NumPed)
               ImpLinha(oPrinter:prow()  ,010,dtoc(Pedidos->Data))
               ImpLinha(oPrinter:prow()  ,021,Pedidos->CodVen+"-"+left(Vendedor->Nome,15))
               ImpLinha(oPrinter:prow()  ,040,Pedidos->CodPla+"-"+left(Plano->DesPla,15))
               ImpLinha(oPrinter:prow()  ,060,Pedidos->TipoCobra+"-"+aTipoCobra[val(Pedidos->TipoCobra)])
               ImpLinha(oPrinter:prow()  ,079,transform(Pedidos->SubTotal,"@e 999,999.99"))
               ImpLinha(oPrinter:prow()  ,092,transform(Pedidos->Entrada,"@e 999,999.99"))
               ImpLinha(oPrinter:prow()  ,105,transform(Pedidos->PerDesc,"@e 999.99"))
               ImpLinha(oPrinter:prow()  ,113,transform(Pedidos->ValDesc,"@e 999,999.99"))
               ImpLinha(oPrinter:prow()  ,126,transform(Pedidos->Total,"@e 999,999.99"))
               if ItemPed->(dbsetorder(1),dbseek(Pedidos->NumPed))
                  ImpLinha(oPrinter:prow()+1,00,"")
                    do while ItemPed->NumPed == Pedidos->NumPed .and. ItemPed->(!eof())
                        Produtos->(dbsetorder(1),dbseek(ItemPed->CodPro))
                        ImpLinha(oPrinter:prow()+1,03,ItemPed->Codpro)
                        ImpLinha(oPrinter:prow()  ,10,Produtos->FanPro)
                        ImpLinha(oPrinter:prow()  ,62,Produtos->embPro)
                        ImpLinha(oPrinter:prow()  ,67,transform(ItemPed->QtdPro,"@e 999,999"))
                        ImpLinha(oPrinter:prow()  ,75,"X")
                        ImpLinha(oPrinter:prow()  ,77,transform(ItemPed->PcoVen,"@e 99,999.999"))
                        ImpLinha(oPrinter:prow()  ,88,"=")
                        ImpLinha(oPrinter:prow()  ,90,transform(ItemPed->PcoVen * ItemPed->QtdPro,"@e 9,999,999.99"))
                        ItemPed->(dbskip())
                        if oPrinter:prow() > 90
                     	  oPrinter:NewPage()
                        endif
                    enddo
                    ImpLinha(oPrinter:prow()+1,00,"")
                endif
               nTotal1 += Pedidos->SubTotal
               nTotal2 += Pedidos->Entrada
               nTotal3 += Pedidos->ValDesc
               nTotal4 += Pedidos->Total
            endif
            Pedidos->(dbskip())
            if oPrinter:prow() > 55
               nPagina += 1
               lCabec := .t.
               oPrinter:NewPage()
            endif
         enddo
 	ImpLinha(oPrinter:prow()+1,000,replicate("-",136))
 	ImpLinha(oPrinter:prow()+1,066,"Total : ")
 	ImpLinha(oPrinter:prow()  ,077,transform(nTotal1,"@e 9,999,999.99"))
 	ImpLinha(oPrinter:prow()  ,090,transform(nTotal2,"@e 9,999,999.99"))
 	ImpLinha(oPrinter:prow()  ,111,transform(nTotal3,"@e 9,999,999.99"))
 	ImpLinha(oPrinter:prow()  ,124,transform(nTotal4,"@e 9,999,999.99"))
 	oPrinter:EndDoc()
 	oPrinter:Destroy()
 	return


static procedure Imprima3(dDataI,dDataF)
   local nVideo,lCabec := .t.,nTotal1 := 0,nTotal2 := 0,nTotal3 := 0,nTotal4 := 0
   local aTipoCobra := {"Dinheiro","Duplicata","Cheque ","Nota Promissoria","Nota de Debito "}
    local lCliente := .t.,cCodCli,aVetor1 := {},aVetor2 := {}
   private nPagina := 1

   set softseek on
   Pedidos->(dbsetorder(2),dbseek(dDataI))
   if Pedidos->Data > dDataF
      set softseek off
      Mens({"Nao Existe Proposta(s) Nesse Periodo"})
      return
   end
   set softseek off
   if Ver_Imp2(@nVideo)

         Msg(.t.)
         if nVideo == 1
            Msg(.f.)
			cImpressoraPadrao := ImpressoraPadrao()
			Imprima3USB(dDataI,dDataF,cImpressoraPadrao)
			return
         elseif nVideo == 2
            Msg("Aguarde: Gerando o Relatorio (Esc-Cancela)")
         endif
      begin sequence         
         set device to printer
         while Pedidos->(!eof())
            if Pedidos->Data >= dDataI .and. Pedidos->Data <= dDataF
               if lCabec
                  cabec(140,cEmpFantasia,{"Relatorio de Proposta Nao Resumido","Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
                  @ prow()+1,00 say replicate("=",136)
                  //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                  //                           1         2         3         4         5         6         7         8         9         0         1         2         3
                  @ prow()+1,00 SAY "Numero    Data       Vendedor           Plano               Tipo Pagto.         Sub-Total      Entrada Desc.(%)   Desc.(R$)        Total"
                  //                 123456789 99/99/9999 12 123456789012345 12 123456789012345  1 123456789012345  999,999.99   999,999.99   999.99  999,999.99   999,999.99
                  //
                  //                                                                                       Total : 9,999,999.99 9,999,999.99         9,999,999.99 9,999,999.99
                  //                    123456 12345678901234567890123456789012345678901234567890  1234 999,999 x 99,999.999 = 9,999,999.99
                  @ prow()+1,00 say replicate("=",136)
                  lCabec := .f.
               end
                nPosicao := ascan(aVetor1,Pedidos->CodPLa)
                if nPosicao = 0
                    aadd(aVetor1,Pedidos->CodPla)
                    aadd(aVetor2,Pedidos->Total)
                else
                    aVetor2[nPosicao] += Pedidos->Total
                endif
                Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
                @ prow()+1,00 say "Cliente: "+Clientes->CodCli+"-"+Clientes->NomCli
               Vendedor->(dbsetorder(1),dbseek(Pedidos->CodVen))
               Plano->(dbsetorder(1),dbseek(Pedidos->CodPla))
               @ prow()+1,000 say Pedidos->NumPed
               @ prow()  ,010 say Pedidos->Data
               @ prow()  ,021 say Pedidos->CodVen+"-"+left(Vendedor->Nome,15)
               @ prow()  ,040 say Pedidos->CodPla+"-"+left(Plano->DesPla,15)
               @ prow()  ,060 say Pedidos->TipoCobra+"-"+aTipoCobra[val(Pedidos->TipoCobra)]
               @ prow()  ,079 say Pedidos->SubTotal picture "@e 999,999.99"
               @ prow()  ,092 say Pedidos->Entrada  picture "@e 999,999.99"
               @ prow()  ,105 say Pedidos->PerDesc  picture "@e 999.99"
               @ prow()  ,113 say Pedidos->ValDesc  picture "@e 999,999.99"
               @ prow()  ,126 say Pedidos->Total    picture "@e 999,999.99"
               if ItemPed->(dbsetorder(1),dbseek(Pedidos->NumPed))
                  @ prow()+1,00 say ""
                  while ItemPed->NumPed == Pedidos->NumPed .and. ItemPed->(!eof())
                     Produtos->(dbsetorder(1),dbseek(ItemPed->CodPro))
                     @ prow()+1,03 say ItemPed->Codpro
                     @ prow()  ,10 say Produtos->FanPro
                     @ prow()  ,62 say Produtos->embPro
                     @ prow()  ,67 say ItemPed->QtdPro picture "@e 999,999"
                     @ prow()  ,75 say "X"
                     @ prow()  ,77 say ItemPed->PcoVen picture "@e 99,999.999"
                     @ prow()  ,88 say "="
                     @ prow()  ,90 say ItemPed->PcoVen * ItemPed->QtdPro picture "@e 9,999,999.99"
                     ItemPed->(dbskip())
                     if prow() > 90
                           eject
                     end
                  end
                  @ prow()+1,00 say replicate("-",136) 
               end
               nTotal1 += Pedidos->SubTotal
               nTotal2 += Pedidos->Entrada
               nTotal3 += Pedidos->ValDesc
               nTotal4 += Pedidos->Total
            end
            Pedidos->(dbskip())
            if prow() > 55
               nPagina += 1
               lCabec := .t.
                eject
            end
         end
      end sequence
      @ prow()+1,000 say replicate("-",136)
      @ prow()+1,066 say "Total : "
      @ prow()  ,077 say nTotal1 picture "@e 9,999,999.99"
      @ prow()  ,090 say nTotal2 picture "@e 9,999,999.99"
      @ prow()  ,111 say nTotal3 picture "@e 9,999,999.99"
      @ prow()  ,124 say nTotal4 picture "@e 9,999,999.99"
      @ prow()+1,000 say replicate("-",136)
        for nI := 1 to len(aVetor1)
            Plano->(dbsetorder(1),dbseek(aVetor1[nI]))
            @ prow()+1,00 say aVetor1[nI]+"-"+PLano->DesPla+" - "+transform(aVetor2[nI],"@e 9,999,999.99")
        next
            
      
      FimPrinter(136)
         eject
      set printer to
      set device to screen
      Msg(.f.)
      Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,30,100,180)
   end
   return


static procedure Imprima3USB(dDataI,dDataF,cImpressoraPadrao)
   local lCabec := .t.,nTotal1 := 0,nTotal2 := 0,nTotal3 := 0,nTotal4 := 0
   local aTipoCobra := {"Dinheiro","Duplicata","Cheque ","Nota Promissoria","Nota de Debito "}
   local aVetor1 := {},aVetor2 := {}
   private oPrinter,cPrinter,cFont,nPagina := 1

	if !IniciaImpressora(cImpressoraPadrao,.t.)
		return
	endif

         while Pedidos->(!eof())
            if Pedidos->Data >= dDataI .and. Pedidos->Data <= dDataF
               if lCabec
               		oPrinter:setfont(cFont,,11)
               		oPrinter:setFont(cFont,,18)
                  	CabecUSB(140,cEmpFantasia,{"Relatorio de Proposta Nao Resumido","Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
                  	ImpLinha(oPrinter:prow()+1,00,replicate("=",136))
                  	//                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                  	//                           1         2         3         4         5         6         7         8         9         0         1         2         3
                    ImpLinha(oPrinter:prow()+1,00,"Numero    Data       Vendedor           Plano               Tipo Pagto.         Sub-Total      Entrada Desc.(%)   Desc.(R$)        Total")
                  	//                             123456 99/99/9999 12 123456789012345 12 123456789012345  1 123456789012345  999,999.99   999,999.99   999.99  999,999.99   999,999.99
                  	//
                  	//                                                                                       Total : 9,999,999.99 9,999,999.99         9,999,999.99 9,999,999.99
                  	//                        123456 12345678901234567890123456789012345678901234567890  999,999  99,999.999  9,999,999.99
                  	ImpLinha(oPrinter:prow()+1,00,replicate("=",136))
                  	lCabec := .f.
               endif
                nPosicao := ascan(aVetor1,Pedidos->CodPLa)
                if nPosicao = 0
                    aadd(aVetor1,Pedidos->CodPla)
                    aadd(aVetor2,Pedidos->Total)
                else
                    aVetor2[nPosicao] += Pedidos->Total
                endif
               
                Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
                ImpLinha(oPrinter:prow()+1,00,"Cliente: "+Clientes->CodCli+"-"+Clientes->NomCli)
               
               Vendedor->(dbsetorder(1),dbseek(Pedidos->CodVen))
               Plano->(dbsetorder(1),dbseek(Pedidos->CodPla))
               ImpLinha(oPrinter:prow()+1,000,Pedidos->NumPed)
               ImpLinha(oPrinter:prow()  ,010,dtoc(Pedidos->Data))
               ImpLinha(oPrinter:prow()  ,021,Pedidos->CodVen+"-"+left(Vendedor->Nome,15))
               ImpLinha(oPrinter:prow()  ,040,Pedidos->CodPla+"-"+left(Plano->DesPla,15))
               ImpLinha(oPrinter:prow()  ,060,Pedidos->TipoCobra+"-"+aTipoCobra[val(Pedidos->TipoCobra)])
               ImpLinha(oPrinter:prow()  ,079,transform(Pedidos->SubTotal,"@e 999,999.99"))
               ImpLinha(oPrinter:prow()  ,092,transform(Pedidos->Entrada,"@e 999,999.99"))
               ImpLinha(oPrinter:prow()  ,105,transform(Pedidos->PerDesc,"@e 999.99"))
               ImpLinha(oPrinter:prow()  ,113,transform(Pedidos->ValDesc,"@e 999,999.99"))
               ImpLinha(oPrinter:prow()  ,126,transform(Pedidos->Total,"@e 999,999.99"))
               if ItemPed->(dbsetorder(1),dbseek(Pedidos->NumPed))
                  ImpLinha(oPrinter:prow()+1,00,"")
                    do while ItemPed->NumPed == Pedidos->NumPed .and. ItemPed->(!eof())
                        Produtos->(dbsetorder(1),dbseek(ItemPed->CodPro))
                        ImpLinha(oPrinter:prow()+1,03,ItemPed->Codpro)
                        ImpLinha(oPrinter:prow()  ,10,Produtos->FanPro)
                        ImpLinha(oPrinter:prow()  ,62,Produtos->embPro)
                        ImpLinha(oPrinter:prow()  ,67,transform(ItemPed->QtdPro,"@e 999,999"))
                        ImpLinha(oPrinter:prow()  ,75,"X")
                        ImpLinha(oPrinter:prow()  ,77,transform(ItemPed->PcoVen,"@e 99,999.999"))
                        ImpLinha(oPrinter:prow()  ,88,"=")
                        ImpLinha(oPrinter:prow()  ,90,transform(ItemPed->PcoVen * ItemPed->QtdPro,"@e 9,999,999.99"))
                        ItemPed->(dbskip())
                        if oPrinter:prow() > 90
                     	  oPrinter:NewPage()
                        endif
                    enddo
                    ImpLinha(oPrinter:prow()+1,00,"-")
                endif
               nTotal1 += Pedidos->SubTotal
               nTotal2 += Pedidos->Entrada
               nTotal3 += Pedidos->ValDesc
               nTotal4 += Pedidos->Total
            endif
            Pedidos->(dbskip())
            if oPrinter:prow() > 55
               nPagina += 1
               lCabec := .t.
               oPrinter:NewPage()
            endif
         enddo
 	  ImpLinha(oPrinter:prow()+1,000,replicate("-",136))
 	  ImpLinha(oPrinter:prow()+1,066,"Total : ")
 	  ImpLinha(oPrinter:prow()  ,077,transform(nTotal1,"@e 9,999,999.99"))
 	  ImpLinha(oPrinter:prow()  ,090,transform(nTotal2,"@e 9,999,999.99"))
 	  ImpLinha(oPrinter:prow()  ,111,transform(nTotal3,"@e 9,999,999.99"))
 	  ImpLinha(oPrinter:prow()  ,124,transform(nTotal4,"@e 9,999,999.99"))
 	  ImpLinha(oPrinter:prow()+1,000,replicate("-",136))    
        for nI := 1 to len(aVetor1)
            Plano->(dbsetorder(1),dbseek(aVetor1[nI]))
            ImpLinha(oPrinter:prow()+1,00,aVetor1[nI]+"-"+PLano->DesPla+" - "+transform(aVetor2[nI],"@e 9,999,999.99"))
        next
    
    
    
 	oPrinter:EndDoc()
 	oPrinter:Destroy()
 	return

//** Fim do Arquivo.
