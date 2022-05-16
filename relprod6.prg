/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.0
 * Identificacao: Relat¢rio de Entradas - Produtos
 * Prefixo......: LtAdm
 * Programa.....: Bancos.prg
 * Autor........: Andre Lucas Souza
 * Data.........: 23 de Setembro de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure RelProd6
   local getlist := {},cTela := SaveWindow()
   local nVideo,cTitulo
   private cCodFor,dDataI,dDataF,nQual

   T_IPorta := "USB"
   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenProdutos()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenCompra()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenCmp_Ite()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenFornecedor()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenNfeVen()
		FechaDados()
		Msg(.f.)
		return
	endif
    if !OpenNfeItem()
		FechaDados()
		Msg(.f.)
		return
	endif
    if !OpenNFce()
		FechaDados()
		Msg(.f.)
		return
	endif
    if !OpenNFceItem()
		FechaDados()
		Msg(.f.)
		return
	endif  
    Msg(.f.)
   DesativaF9()
   AtivaF4()
   Window(09,08,15,70,cTitulo)
   setcolor(Cor(11))
   //           0123456789012345678901234567890
   //                     2
   @ 11,10 say "  Fornecedor:"
   @ 12,10 say "Data Inicial:"
   @ 13,10 say "  Data Final:"
   while .t.
      dDataI  := date()
      dDataF  := date()
      cCodFor := space(04)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,24 get cCodFor picture "@k 9999" when Rodape("Esc-Encerra | F4-Fornecedor") valid iif(empty(cCodFor),.t.,Busca(Zera(@cCodFor),"Fornece",1,11,29,"Fornece->RazFor",{"Fornecedor NÆo Cadastrado"},.f.,.f.,.f.))
      @ 12,24 get dDataI  picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDataI)
      @ 13,24 get dDataF  picture "@k" valid iif(lastkey() == K_UP,.t.,dDataF >= dDataI)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
      Gerar()
      Imprima1()
      exit
   end
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   endif
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
static procedure Imprima1
   local nVideo,nTecla := 0,lCabec := .t.,dData,lData := .t.,nTotal := 0
   local nQtd := 0
   private nPagina := 1

    if Ver_Imp2(@nVideo)
    
        if nVideo == 1
            Mens({"Opção não disponível"})
            return
        endif
         Msg(.t.)
        Msg("Aguarde: Gerando o Relatorio (Esc-Cancela)")
      begin sequence
         set device to printer
         Tmp02->(dbsetorder(2),dbgotop())
         while Tmp02->(!eof())
            if lCabec
               cabec(96,cEmpFantasia,{"Relatorio de Entrada/Saidas","No Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
               if !empty(cCodFor)
               	@ prow()+1,00 say "Fornecedor: "+cCodFor+"-"+Fornece->RazFor
               endif
               @ prow()+1,00 say replicate("=",96)
               //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
               //                           1         2         3         4         5         6         7         8         9         0         1         2         3
               @ prow()+1,00 say "Codigo   Descricao                                 Qtd. x Und.    Entrada      Saida  Diferenca"
               //                 123456   1234567890123456789012345678901234567890  123  x 123   9,999,999  9,999,999  9,999,999
               //                                                                                                                                Total: 999,999,999.999
               @ prow()+1,00 say replicate("=",96)
               lCabec := .f.
            end
            Produtos->(dbsetorder(1),dbseek(Tmp02->CodPro))
            @ prow()+1,000 say Tmp02->codpro
            @ prow()  ,009 say left(Produtos->DesPro,40)
            @ prow()  ,051 say Produtos->EmbPro
            @ prow()  ,056 say "x"
            @ prow()  ,058 say Produtos->QteEmb picture "999"
            @ prow()  ,064 say Tmp02->Entrada  picture "@e 9,999.999"
            @ prow()  ,075 say Tmp02->Saida    picture "@e 9,999.999"
            @ prow()  ,086 say Tmp02->Entrada-Tmp02->Saida    picture "@e 9,999.999"
            nQtd += 1
            Tmp02->(dbskip())
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
                  eject
            endif
         enddo
      end sequence
      if nTecla == K_ESC
         FimPrinter(96,"Impressao Cancelada")
      else
         FimPrinter(96)
         @ prow()+1,00 say "Listados : "+transform(nQtd,"@e 999,999")
         @ prow()+1,00 say ""
      endif
      eject
      set printer to
      set device to screen
      Msg(.f.)
        Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,maxrow()-1,maxcol(),100)
   endif
   return

static procedure Gerar

	set exclusive on
	use dados\tmp02 alias tmp02 new
	zap
	index on CodPro to dados\tmp02
	index on DesPro to dados\tmp022
	Tmp02->(dbclosearea())
	set exclusive off
	use dados\tmp02 alias Tmp02 new
	set index to dados\tmp02,dados\tmp022
	
	Msg(.t.)
	Msg("Aguarde: Processando as Entradas")
	Compra->(dbgotop(),dbsetorder(3))
	// ** se for sem nota
	if lGeral
		if empty(cCodFor)
			Compra->(dbsetfilter( { || DtaEnt >= dDataI .and. DtaEnt <= dDataF .and. Compra->SN }))
		else
			Compra->(dbsetfilter( { || CodFor = cCodFor .and. DtaEnt >= dDataI .and. DtaEnt <= dDataF .and. Compra->SN }))
		endif
	else
		if empty(cCodFor)
			Compra->(dbsetfilter( { || DtaEnt >= dDataI .and. DtaEnt <= dDataF .and. !Compra->SN }))
		else
			Compra->(dbsetfilter( { || CodFor = cCodFor .and. DtaEnt >= dDataI .and. DtaEnt <= dDataF .and. !Compra->SN }))
		endif
			
	endif
	Compra->(dbgotop())
	if Compra->(eof())
		Compra->(dbclearfilter())
		return
	endif
	Cmp_ite->(dbsetorder(1))
	do while Compra->(!eof())
		if Cmp_Ite->(dbseek(Compra->Chave))
			do while Cmp_ite->Chave == Compra->Chave .and. Cmp_Ite->(!eof())
				Produtos->(dbsetorder(1),dbseek(Cmp_Ite->CodPro))
				if !Tmp02->(dbsetorder(1),dbseek(Cmp_Ite->CodPro))
					do while !Tmp02->(Adiciona())
					enddo
					Tmp02->codpro := Cmp_Ite->Codpro
					Tmp02->desPro := Produtos->DesPro
					Tmp02->Entrada := Cmp_Ite->Quantidade
					Tmp02->(dbunlock())
				else
					do while !Tmp02->(Trava_Reg())
					enddo
					Tmp02->entrada += Cmp_Ite->Quantidade
					Tmp02->(dbunlock())
				endif
				Cmp_Ite->(dbskip())
			enddo
		endif
		Compra->(dbskip())
	enddo
	Compra->(dbclearfilter())
	Msg(.f.)
    
    ProcessarNfe()
    ProcessarNfce()
    return
   
   
static procedure ProcessarNfce()   

    Msg(.t.)
    Msg("Aguarde: Processando as Saidas : NFc-e")
    Produtos->(dbsetorder(1))
    Tmp02->(dbsetorder(1))    
    // Nfc-e
    set softseek on
    Nfce->(dbsetorder(6),dbseek(dtos(dDataI)))
    do while Nfce->DtaEmi >= dDataI .and. Nfce->DtaEmi <= dDataF .and. Nfce->(!eof())
        if !Nfce->Autorizado
            Nfce->(dbskip())
            loop 
        endif 
        if Nfce->Cancelada
            Nfce->(dbskip())
            loop
        endif
        if Nfceitem->(dbsetorder(1),dbseek(Nfce->NumCon))
            do while Nfceitem->NumCon == Nfce->NumCon .and. Nfceitem->(!eof())
                Produtos->(dbseek(Nfceitem->CodPro))
                if !Tmp02->(dbseek(Nfceitem->CodPro))
                    do while !Tmp02->(Adiciona())
                    enddo
				    Tmp02->codpro  := Nfceitem->Codpro
				    Tmp02->desPro  := Produtos->DesPro
				    Tmp02->Saida   := Nfceitem->QtdPro
				    Tmp02->(dbunlock())
			    else
				    do while !Tmp02->(Trava_Reg())
				    enddo
				    Tmp02->saida += Nfceitem->Qtdpro
				    Tmp02->(dbunlock())
                endif
                Nfceitem->(dbskip())
            enddo
        endif
        Nfce->(dbskip())
    enddo
    set softseek off    
	Msg(.f.)
	return
    
static procedure processarNfe
   Msg(.t.)
   Msg("Aguarde: Processando as Saidas : NF-e")
	NFEVen->(dbgotop(),dbsetorder(2))
	Nfeven->(dbsetfilter( { || DtaEmi >= dDataI .and. DtaEmi <= dDataF .and. !(CanNot == "S") }))
	Nfeven->(dbgotop())
	if Nfeven->(eof())
		Nfeven->(dbclearfilter())
		return
	endif
	Nfeitem->(dbsetorder(1))
	do while Nfeven->(!eof())
		if Nfeitem->(dbseek(Nfeven->NumCon))
			do while Nfeitem->Numcon == Nfeven->NumCon .and. Nfeitem->(!eof())
				Produtos->(dbsetorder(1),dbseek(Nfeitem->CodPro))
				if !Tmp02->(dbsetorder(1),dbseek(Nfeitem->CodPro))
					do while !Tmp02->(Adiciona())
					enddo
					Tmp02->codpro  := Nfeitem->Codpro
					Tmp02->desPro  := Produtos->DesPro
					Tmp02->Saida   := Nfeitem->QtdPro
					Tmp02->(dbunlock())
				else
					do while !Tmp02->(Trava_Reg())
					enddo
					Tmp02->saida += Nfeitem->Qtdpro
					Tmp02->(dbunlock())
				endif
				Nfeitem->(dbskip())
			enddo
		endif
		Nfeven->(dbskip())
	enddo
	Nfeven->(dbclearfilter())
    Msg(.f.)
    
    
//** Fim do arquivo.