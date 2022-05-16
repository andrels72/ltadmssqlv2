/*************************************************************************
         Sistema: Administrativo
   Identifica‡Æo: Relat¢rio de Ranking do Produto
         Prefixo: LTADM
        Programa: RelProd4.PRG
           Autor: Andre Lucas Souza
            Data: 15 de Julho de 2004
   Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure RelProd7
   local getlist := {},cTela := SaveWindow()
   private cCodFor,cCodGru,dDataI,dDataF,nQtd

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenCidades()
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
    if !OpenItemPed()
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
    if !OpenNfce()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenNfceitem()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenNfeven()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenNfeItem()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenFornecedor()
        FechaDados()
        Msg(.f.)
        return
    endif
   Msg(.f.)
   AtivaF4()
   Window(07,13,13,65,"> Saldos (Estoque) <")
   setcolor(Cor(11))
   //           123456789012345678901234567890
   //                    3         4
   @ 09,15 say "  Fornecedor:"
   @ 10,15 say "       Grupo:"
   @ 11,15 say "   Saldo Ate:"
	while .t.
  
      cCodFor := space(04)
      cCodGru := space(03)
      dDataI  := date()
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 09,29 get cCodFor picture "@k 9999" when Rodape("Esc-Encerra | F4-Fornecedores") valid vFornece()
      @ 10,29 get cCodGru picture "@k 999" when Rodape("Esc-Encerra | F4-Grupos") valid vGrupo()
      @ 11,29 get dDataI  picture "@k"     when Rodape("Esc-Encerra")
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
      Processar()
      Imprimir()
      exit
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
   
// *****************************************************************************
static procedure Processar
   local cTela := SaveWindow()
   local lEstCid,nCont := 0,lImpGru := .t.,cLixo
   local cCampo,cEstoque,nCalc,nSubTotal := 0,nTotal := 0,nLixo
   private nPagina := 2,cEst,lSaldo,lFornece,lGrupo
   nTecla := 0


   lFornec := iif(empty(cCodFor),".t.","Produtos->CodFor == cCodFor")
   lGrupo  := iif(empty(cCodGru),".t.","Produtos->CodGru == cCodGru")
   
	if !Use_dbf(cDiretorio,"tmp05",.t.,.t.,"Tmp05")
		Mens({"Arquivo para impressao indisponivel","Tente novamente"})
		return
	endif
	zap
	index on despro to dados\tmp05
	index on codpro to dados\tmp052
	Tmp05->(dbclosearea())
	if !Use_dbf(cDiretorio,"tmp05",.t.,.t.,"Tmp05")
		Mens({"Arquivo para impressao indisponivel","Tente novamente"})
		return
	endif
	set index to dados\tmp05,dados\tmp052
   Produtos->(dbsetorder(1),dbgotop())
   Msg(.t.)
   Msg("Aguarde: Verificando as Informacoes")
	do while Produtos->(!eof())
		if &lFornec. .and. &lGrupo.
			Tmp05->(dbappend())
			tmp05->CodPro := Produtos->CodPro
			tmp05->DesPro := Produtos->DesPro
			tmp05->CodGru := Produtos->CodGru
			tmp05->OrdeF  := "A"+space(29)
		endif
		Produtos->(dbskip())
	enddo
   dbcommitall()
   Msg(.f.)
   GeraEntrada()
   GeraSaida()
   return
   
   
   
static procedure Imprimir   
	local cTela := SaveWindow(),nVideo,lCabec := .t.
   private nPagina := 2,cEst,lSaldo,lFornece,lGrupo

   
   lSaldo := "!(Tmp05->Qteac02 == 0)"
   nOnde := OndeImprimir()
   if nOnde == -27
      return
	elseif nOnde == 2
		ImprimaUSB()
		return
   endif
   if Ver_Imp(@nVideo)
   
      begin sequence
         Set Device to Print
         tmp05->(dbsetorder(1),dbgotop())
         while tmp05->(!eof()) 
            if lCabec
               cabec(80,cEmpFantasia,{"Relatorio de Saldo (Estoque) ate "+dtoc(dDataI),;
                     "Fornecedor: "+iif(!empty(cCodFor),cCodFor+"-"+left(Fornecedor->RazFor,20),"Todos")+" Grupo: "+iif(!empty(cCodGru),cCodGru+"-"+left(Grupos->NomGru,20),"Todos")})
               @ prow()+1,00 say replicate("=",80)
               //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
               //                           1         2         3         4         5         6         7         8         9         0         1         2         3
               @ prow()+1,00 say "Codigo Descricao                                           Embalagem      Saldo"
               //                 123456 12345678901234567890123456789012345678901234567890  1234 x 123 999,999.99"
               //                                                                                  Total:    99,999,999 999,999,999.99                 9,999.99
               @ prow()+1,00 say replicate("=",80)
               lCabec := .f.
            end
            Produtos->(dbsetorder(1),dbseek(Tmp05->CodPro))
            @ prow()+1,000 say Tmp05->CodPro
            @ prow()  ,007 say left(Produtos->DesPro,50)
            @ prow()  ,059 say Produtos->EmbPro+"x"+str(Produtos->QteEmb,3)
            if lGeral
                @ prow()  ,070 say Tmp05->QteAc02 picture "@e 999,999.99"
            else
                @ prow()  ,070 say Tmp05->QteAc01 picture "@e 999,999.999"
            endif
            Tmp05->(dbskip())
            
            if prow() > 54
               nPagina++
               lCabec := .t.
               eject
            endif
         enddo
      end sequence
      
      FimPrinter(136)
      eject
      set printer to
      set device to screen
      if nVideo == 1
         Fim_Imp(140)
      elseif nVideo == 2
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,maxrow()-1,maxcol(),150)
      end
   endif
   RestWindow(cTela)
   
static procedure ImprimaUSB

	local lCabec := .t.,nPagina := 2,cPrinter,nTotal := 0.00
	private oPrinter,cFont
	
	if !IniciaImpressora()
		return
	endif
	tmp05->(dbsetorder(1),dbgotop())
	while tmp05->(!eof()) 
		if lCabec
			oPrinter:setfont(cFont,,11)
			cabecUSb(80,cEmpFantasia,{"Relatorio de Saldo (Estoque) ate "+dtoc(dDataI),;
                     "Fornecedor: "+iif(!empty(cCodFor),cCodFor+"-"+left(Fornecedor->RazFor,20),"Todos")+" Grupo: "+iif(!empty(cCodGru),cCodGru+"-"+left(Grupos->NomGru,20),"Todos")})
            ImpLinha(oPrinter:prow()+1,00,replicate("=",80))
               //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
               //                           1         2         3         4         5         6         7         8         9         0         1         2         3
            ImpLinha(oPrinter:prow()+1,00,"Codigo Descricao                                           Embalagem      Saldo")
               //                 123456 12345678901234567890123456789012345678901234567890  123 x 123  999,999.99"
               //                                                                                  Total:    99,999,999 999,999,999.99                 9,999.99
            ImpLinha(oPrinter:prow()+1,00,replicate("=",80))
               lCabec := .f.
		endif
        Produtos->(dbsetorder(1),dbseek(Tmp05->CodPro))
        ImpLinha(oPrinter:prow()+1,000,Tmp05->CodPro)
        ImpLinha(oPrinter:prow()  ,007,Produtos->DesPro)
        ImpLinha(oPrinter:prow()  ,059,Produtos->EmbPro+" x "+str(Produtos->QteEmb,3))
        ImpLinha(oPrinter:prow()  ,070,transform(Tmp05->QteAc02,"@e 999,999.99"))
        tmp05->(dbskip())
		if oPrinter:prow() > 60
           nPagina++
           lCabec := .t.
           oPrinter:newpage()
        endif
	enddo
	oPrinter:enddoc()
	oPrinter:Destroy()
	return

// *****************************************************************************
static function vFornece

   if empty(cCodFor)
      @ 09,33 say space(31)
      return(.t.)
   end
   if !Busca(Zera(@cCodFor),"Fornece",1,09,33,"'-'+left(Fornecedor->RazFor,30)",{"Fornecedor Nao Cadastrado"},.f.,.f.,.f.)
      return(.f.)
   end
   return(.t.)
// *****************************************************************************
static function vGrupo

   if empty(cCodGru)
      @ 10,32 say space(21)
      return(.t.)
   end
   if !Busca(Zera(@cCodGru),"Grupos",1,10,32,"'-'+left(Grupos->NomGru,20)",{"Grupo Nao Cadastrado"},.f.,.f.,.f.)
      return(.f.)
   end
   return(.t.)
// *****************************************************************************
static procedure GeraEntrada

    Msg(.t.)
    Msg("Aguarde: Verificando as Entradas")
    Compra->(dbsetorder(6),dbgotop())
    Cmp_ite->(dbsetorder(1))
    do while Compra->DtaEnt <= dDataI .and. Compra->(!eof())
        if !lGeral
            if Compra->SN
                Compra->(dbskip())
                loop
            endif
        else
            if !Compra->SN
                Compra->(dbskip())
                loop
            endif
        endif
        if Cmp_ite->(dbseek(Compra->Chave))
            do while Cmp_ite->Chave == Compra->Chave .and. Cmp_Ite->(!eof())
                if Tmp05->(dbsetorder(2),dbseek(Cmp_Ite->CodPro))
				    do while !Tmp05->(Trava_Reg())
				    enddo
                    if lGeral
				        Tmp05->QteAc02 += Cmp_Ite->Quantidade
                    else
                        Tmp05->QteAc01 += Cmp_Ite->Quantidade
                    endif
                endif
                Tmp05->(dbunlock())
                Cmp_Ite->(dbskip())
            enddo
        endif
        Compra->(dbskip())
	enddo
	Msg(.f.)
	return
// *****************************************************************************
static procedure GeraSaida

    if lGeral
    else
        Msg(.t.)
        Msg("Aguarde: Processando Saidas : NF-e")
        nfeven->(dbsetorder(6),dbgotop())
        nfeitem->(dbsetorder(1))
        do while nfeven->DtaEmi <= dDataI .and. nfeven->(!eof())
            if !nfeven->Autorizado
                nfeven->(dbskip())
                loop
            endif
            if nfeven->Cancelada
                nfeven->(dbskip())
                loop
            endif
            if nfeitem->(dbseek(nfeven->NumCon))
                do while nfeitem->NumCon == nfeven->NumCon .and. nfeven->(!eof())
                    if tmp05->(dbsetorder(1),dbseek(nfeitem->CodPro))
                        do while !tmp05->(Trava_Reg())
                        enddo
                        tmp05->Qteac01 -= nfeitem->qtdpro
                        tmp05->(dbunlock())
                    endif
                    nfeitem->(dbskip())
                enddo
            endif
            nfeven->(dbskip())
        enddo
        Msg(.f.)
        
        Msg(.t.)
        Msg("Aguarde: Processando Saidas : NFc-e")
        Nfce->(dbsetorder(6),dbgotop())
        Nfceitem->(dbsetorder(1))
        do while Nfce->DtaEmi <= dDataI .and. Nfce->(!eof())
            if !Nfce->Autorizado
                Nfce->(dbskip())
                loop
            endif
            if Nfce->Cancelada
                Nfce->(dbskip())
                loop
            endif
            if Nfceitem->(dbseek(Nfce->NumCon))
                do while Nfceitem->NumCon == Nfce->NumCon .and. nfceitem->(!eof())
                    if tmp05->(dbsetorder(1),dbseek(nfceitem->CodPro))
                        do while !tmp05->(Trava_Reg())
                        enddo
                        tmp05->Qteac01 -= nfceitem->qtdpro
                        tmp05->(dbunlock())
                    endif
                    nfceitem->(dbskip())
                enddo
            endif
            nfce->(dbskip())
        enddo
        Msg(.f.)

        Mens({"Falta PdvNfce"}) 
        
        
        
        
    endif
    /*
	ItemPed->(dbsetorder(5),dbgotop())
	do while ItemPed->DtaSai <= dDataI .and. ItemPed->(!eof())
		if Tmp05->(dbsetorder(2),dbseek(ItemPed->CodPro))
			do while !Tmp05->(Trava_Reg())
			enddo
			Tmp05->QteAc02 -= ItemPed->QtdPro
			Tmp05->(dbunlock())
		endif
		ItemPed->(dbskip())
	enddo
    */
   return

   
   
      
// ** 