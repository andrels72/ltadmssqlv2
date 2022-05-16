/*************************************************************************
 * Sistema......: Administrativo
 * Identificacao: Relatorio de Pedidos por Periodo e Plano de Pagto
 * Prefixo......: LtAdm
 * Programa.....: RelPed5.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 10 de Janeiro de 2004
 * Copyright (C): LT - LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"
#include "setcurs.ch"

procedure RelPed4
   local getlist := {},cTela := SaveWindow()
   local dDataI,dDataF,cCodPla

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
    if !OpenPLano()
        FechaDados()
        Msg(.f.)
        return
   endif
   Msg(.f.)
   AtivaF4()
   Window(08,14,14,64)
   setcolor(Cor(11))
   //           6789012345678901234567890123456789012345678901234567890123456789012345678
   //               2         3         4         5         6         7
   @ 10,16 say "       Plano:"
   @ 11,16 say "Data Inicial:"
   @ 12,16 say "  Data Final:"
   while .t.
      cCodPla := space(02)
      dDataI  := ctod(space(08))
      dDataF  := ctod(space(08))
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,30 get cCodPla picture "@k 99" when Rodape("Esc-Encerra | F4-Plano de Pagamento") valid iif(lastkey() == K_UP,.t.,Busca(Zera(@cCodPla),"Plano",1,10,32,"'-'+Plano->DesPla",{"Plano Nao Cadastrado"},.f.,.f.,.f.))
      @ 11,30 get dDataI picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDataI)
      @ 12,30 get dDataF picture "@k" valid dDataF >= dDataI
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
      Imprima(dDataI,dDataF,cCodPla)
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// *****************************************************************************
static procedure Imprima(dDataI,dDataF,cCodPla)
   local nVideo,lCabec := .t.,nTotal := 0,nQtd := 0,nTecla := 0
   private nPagina := 1

   set softseek on
   Pedidos->(dbsetorder(2),dbseek(dDataI))
   if Pedidos->Data > dDataF
      set softseek off
      Mens({"Nao Existe Pedidos Nesse Periodo"})
      return
   end
   set softseek off
   if Ver_Imp(@nVideo)
      
         Msg(.t.)
         if nVideo == 1
            Msg("Aguarde: Imprimindo (Esc-Cancela)")
         elseif nVideo == 2
            Msg("Aguarde: Gerando o Relatorio (Esc-Cancela)")
         elseif nVideo == 3
         	Msg(.f.)
         	cImpressoraPadrao := ImpressoraPadrao()
         	ImprimaUSB(dDataI,dDataF,cCodPla,cImpressoraPadrao)
         	return
         endif
       begin sequence
         set device to printer
         while Pedidos->(!eof())
            if Pedidos->Data >= dDataI .and. Pedidos->Data <= dDataF .and. Pedidos->CodPla == cCodPla
               if lCabec
                  cabec(80,cEmpFantasia,{"Relatorio de Propostas (Por Periodo e Plano de Pagto.)","        Periodo: "+dtoc(dDataI)+" a "+dtoc(dDataF),"Plano de Pagto.: "+cCodPla+"-"+Plano->DesPla},.f.)
                  @ prow()+1,00 say replicate("=", 80 )
                  //                 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
                  //                           1         2         3         4         5         6         7         8         9         0         1
                  @ prow()+1,00 SAY "Numero  Data        Cliente                                        Valor"
                  //                 123456  99/99/9999  1234 1234567890123456789012345678901234567890  999,999.99
                  //                                                                          Total : 9,999,999.99
                  @ prow()+1,00 say replicate("=",80)
                  lCabec := .f.
               end
               Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
               @ prow()+1,00 say Pedidos->NumPed
               @ prow()  ,08 say Pedidos->Data
               @ prow()  ,20 say Pedidos->CodCli
               @ prow()  ,25 say Clientes->NomCli
               @ prow()  ,67 say Pedidos->Total picture "@e 999,999.99"
               nTotal += Pedidos->Total
               nQtd += 1
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
         if nTotal > 0
            @ prow()+1,00 say replicate("-",80)
            @ prow()+1,00 say "Propostas Listadas : "+transform(nQtd,"@e 999,999")
            @ prow()  ,57 say "Total : "+transform(nTotal,"@e 9,999,999.99")
         end
      end sequence
      if nTotal > 0
         if nTecla == K_ESC
            FimPrinter(80,"Impressao Cancelada")
         else
            FimPrinter(80)
         end
      end
      if !(left(T_IPorta,3) == "USB")
         eject
      else
         @ prow()+1,00 say ""
         setprc(00,00)
      end
      set printer to
      set device to screen
      Msg(.f.)
      if nVideo == 1
         Fim_Imp(80)
      elseif nVideo == 2
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,140)
      end
   end
   return

static procedure ImprimaUSB(dDataI,dDataF,cCodPla,cImpressoraPadrao)
   local nVideo,lCabec := .t.,nTotal := 0,nQtd := 0,nTecla := 0
   	private oPrinter,cPrinter,cFont,nPagina := 1

	if !IniciaImpressora(cImpressoraPadrao,.t.)
		return
	endif

         while Pedidos->(!eof())
            if Pedidos->Data >= dDataI .and. Pedidos->Data <= dDataF .and. Pedidos->CodPla == cCodPla
               if lCabec
               		oPrinter:setfont(cFont,,11)
                  	CabecUSB(80,cEmpFantasia,{"Relatorio de Propostas (Por Periodo e Plano de Pagto.)","        Periodo: "+dtoc(dDataI)+" a "+dtoc(dDataF),"Plano de Pagto.: "+cCodPla+"-"+Plano->DesPla},.f.)
                  	ImpLinha(oPrinter:prow()+1,00,replicate("=", 80 ))
                  	//                 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
                  	//                           1         2         3         4         5         6         7         8         9         0         1
                  	ImpLinha(oPrinter:prow()+1,00,"Numero  Data        Cliente                                        Valor")
                  	//                             123456  99/99/9999  1234 1234567890123456789012345678901234567890  999,999.99
                  //                                                                          Total : 9,999,999.99
                  ImpLinha(oPrinter:prow()+1,00,replicate("=",80))
                  lCabec := .f.
               endif
               Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
               ImpLinha(oPrinter:prow()+1,00,Pedidos->NumPed)
               ImpLinha(oPrinter:prow()  ,08,dtoc(Pedidos->Data))
               ImpLinha(oPrinter:prow()  ,20,Pedidos->CodCli)
               ImpLinha(oPrinter:prow()  ,25,Clientes->NomCli)
               ImpLinha(oPrinter:prow()  ,67,transform(Pedidos->Total,"@e 999,999.99"))
               nTotal += Pedidos->Total
               nQtd += 1
            endif
            Pedidos->(dbskip())
            if oPrinter:prow() > 65
               nPagina += 1
               lCabec := .t.
               oPrinter:NewPage()
            endif
         enddo
         if nTotal > 0
            ImpLinha(oPrinter:prow()+1,00,replicate("-",80))
            ImpLinha(oPrinter:prow()+1,00,"Propostas Listadas : "+transform(nQtd,"@e 999,999"))
            ImpLinha(oPrinter:prow()  ,57,"Total : "+transform(nTotal,"@e 9,999,999.99"))
         endif
         oPrinter:EndDoc()
         oPrinter:Destroy()
         return
   
//** Fim do Arquivo.
