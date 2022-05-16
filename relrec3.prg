/*************************************************************************
 * Sistema......: Administrativo
 * Identificacao: Relatorio de Extrato do Cliente
 * Prefixo......: LtAdm
 * Programa.....: RelRec3.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 07 de Janeiro de 2004
 * Copyright (C): LT - LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"
#include "setcurs.ch"

procedure RelRec3
   local getlist := {},cTela := SaveWindow()
   private cCodCli,dDataI,dDataF

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenClientes()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenCidades()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenDupRec()
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
   Window(09,08,15,70,"> Extrato do Cliente <")
   setcolor(Cor(11))
   //           012345678901234567890
   //                     2
   @ 11,10 say "     Cliente:"
   @ 12,10 say "Data Inicial:"
   @ 13,10 say "  Data Final:"
   while .t.
      cCodCli := space(04)
      dDataI  := date()
      dDataF  := date()
      cQual   := space(01)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,24 get cCodCli picture "@k 9999";
      			when Rodape("Esc-Encerra | F4-Clientes");
      			valid Busca(Zera(@cCodCli),"Clientes",1,row(),col(),"'-'+Clientes->ApeCli",{"Cliente Nao Cadastrado"},.f.,.f.,.f.)
      @ 12,24 get dDataI  picture "@k" when Rodape("Esc-Encerra")
      @ 13,24 get dDataF  picture "@k" valid dDataF >= dDataI
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      if !Confirm("Confirma as Informacoes")
         loop
      endif
      Imprima()
      exit
   enddo
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// *****************************************************************************
static procedure Imprima
   local nVideo,nTecla
	private lCabec := .t.,nTotal := 0,nQtd := 0,cLixo
	private nTotPag := 0,nTotApg := 0,aVetor1 := {},nPagina := 1

   set softseek on
   DupRec->(dbsetorder(6),dbseek(cCodCli+dtos(dDataI)))
   if !(DupRec->CodCli == cCodCli) .or. DupRec->DtaVen > dDataF
      set softseek off
      Mens({"Nao Existe Nada a Receber"})
      return
   end
   set softseek off
   if Ver_Imp2(@nVideo,2)
		if nVideo == 1
			cImpressoraPadrao := ImpressoraPadrao()
			ImprimaUSB(cImpressoraPadrao)
			return
		endif
      begin sequence
         set device to printer
         while DupRec->(!eof())
            if DupRec->CodCli == cCodCli .and. (DupRec->DtaVen >= dDataI .and. DupRec->DtaVen <= dDataF) .or. (DupRec->DtaPag >= dDataI .and. DupRec->DtaPag <= dDataF)
               if lCabec
                  cabec(80,cEmpFantasia,{"Extrato do Cliente","No Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
                  @ prow()+1,00 say replicate("=",80)
                  @ prow()+1,00 say "Cliente: "+Clientes->CodCli+"-"+Clientes->ApeCli
                  @ prow()+1,00 say replicate("=",80)
                  //                 012345678901234567890123456789012345678901234567890123456789012345678901234567890
                  //                           1         2         3         4         5         6         7         8
                  @ prow()+1,00 say "Documento         Emissao     Vencimento         Valor        Pago         Valor"
                  //                 1234567890123456  99/99/9999  99/99/9999  9,999,999.99  99/99/9999  9,999,999.99
                  //                                        Total Pago: 99,999,999.99  Total a Pagar: 99,999,999.99
                  @ prow()+1,00 say replicate("=",80)
                  lCabec := .f.
               end
               @ prow()+1,00 say DupRec->NumDup
               @ prow()  ,18 say DupRec->DtaEmi
               @ prow()  ,30 say DupRec->DtaVen
               @ prow()  ,42 say DupRec->ValDup picture "@e 9,999,999.99"
               @ prow()  ,55 say DupRec->DtaPag
               @ prow()  ,68 say DupRec->ValPag picture "@e 9,999,999.99"

               if !empty(DupRec->DtaPag)
                  nTotPag += DupRec->ValPag
               else
                  nTotApg += DupRec->ValDup
               end
               nQtd   += 1
               if ascan(aVetor1,subst(DupRec->NumDup,1,6)) == 0
                  aadd(aVetor1,subst(DupRec->NumDup,1,6))
               end
            end
            DupRec->(dbskip())
            if prow() > 50
               lCabec := .t.
               nPagina += 1
               if !(left(T_IPorta,3) == "USB")
                  eject
               else
                  setprc(00,00)
                  eject
               endif
            endif
         end
         @ prow()+1,00 say replicate("=",80)
         @ prow()+1,00 say "Listados : "+transform(nQtd,"@e 999,999")
         @ prow()  ,26 say "Total Pago:"
         @ prow()  ,38 say nTotPag picture "@e 99,999,999.99"
         @ prow()  ,53 say "Total a Pagar:"
         @ prow()  ,68 say nTotApg picture "@e 99,999,999.99"
         if !(left(T_IPorta,3) == "USB")
            @ prow(),pcol() say t_icpp10
         end
      end sequence
      FimPrinter(80)
      eject
      set printer to
      set device to screen
        Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,33,100,120)
   end
   return
// *********************************************************************************************************
static procedure ImprimaUSB(cImpressoraPadrao)
   private oPrinter,cPrinter,cFont


   if !IniciaImpressora(cImpressoraPadrao)
      return
   endif
	Msg(.t.)
	Msg("Aguarde: Imprimindo Relatorio")
	do while DupRec->(!eof())
		if DupRec->CodCli == cCodCli .and. (DupRec->DtaVen >= dDataI .and. DupRec->DtaVen <= dDataF) .or. (DupRec->DtaPag >= dDataI .and. DupRec->DtaPag <= dDataF)
			if lCabec
				oPrinter:setfont(cFont,,11)
				cabecUSB(80,cEmpFantasia,{"Extrato do Cliente","No Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
				ImpLinha(oPrinter:prow()+1,00,replicate("=",80))
				ImpLinha(oPrinter:prow()+1,00,"Cliente: "+Clientes->CodCli+"-"+Clientes->ApeCli)
				ImpLinha(oPrinter:prow()+1,00,replicate("=",80))
				//                             012345678901234567890123456789012345678901234567890123456789012345678901234567890
				//                                       1         2         3         4         5         6         7         8
				ImpLinha(oPrinter:prow()+1,00,"Documento         Emissao     Vencimento         Valor        Pago         Valor")
				//                             1234567890123456  99/99/9999  99/99/9999  9,999,999.99  99/99/9999  9,999,999.99
				//                                                                 Total Pago: 99,999,999.99  Total a Pagar: 99,999,999.99
				ImpLinha(oPrinter:prow()+1,00,replicate("=",80))
				lCabec := .f.
			endif
			ImpLinha(oPrinter:prow()+1,00,DupRec->NumDup)
			ImpLinha(oPrinter:prow()  ,18,dtoc(DupRec->DtaEmi))
			ImpLinha(oPrinter:prow()  ,30,dtoc(DupRec->DtaVen))
			ImpLinha(oPrinter:prow()  ,42,transform(DupRec->ValDup,"@e 9,999,999.99"))
			ImpLinha(oPrinter:prow()  ,56,dtoc(DupRec->DtaPag))
			ImpLinha(oPrinter:prow()  ,68,transform(DupRec->ValPag,"@e 9,999,999.99"))
			if !empty(DupRec->DtaPag)
				nTotPag += DupRec->ValPag
			else
				nTotApg += DupRec->ValDup
			endif
			nQtd   += 1
			if ascan(aVetor1,subst(DupRec->NumDup,1,6)) == 0
				aadd(aVetor1,subst(DupRec->NumDup,1,6))
			endif
		endif
		DupRec->(dbskip())
		if oPrinter:prow() > 63
			lCabec := .t.
			nPagina += 1
			oPrinter:newpage()
		endif
	enddo
	ImpLinha(oPrinter:prow()+1,00,replicate("=",80))
	ImpLinha(oPrinter:prow()+1,00,"Listados : "+transform(nQtd,"@e 999,999"))
	ImpLinha(oPrinter:prow()  ,26,"Total Pago:")
	ImpLinha(oPrinter:prow()  ,38,transform(nTotPag,"@e 99,999,999.99"))
	ImpLinha(oPrinter:prow()  ,53,"Total a Pagar:")
	ImpLinha(oPrinter:prow()  ,67,transform(nTotApg,"@e 99,999,999.99"))
	oPrinter:enddoc()
	oPrinter:Destroy()
	Msg(.f.)
	return

//** Fim do Arquivo
