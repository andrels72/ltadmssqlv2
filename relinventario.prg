/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 3.00
 * Identificacao: Relat¢rio de Invent rio
 * Prefixo......: LTADM
 * Programa.....: Relprod5.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 20 de Dezembro de 2004
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure RelProd5
   local getlist := {},cTela := SaveWindow()
   private cSaldo,cCodFor,cCodGru,nPct,cPreco,dData,dDataI,dDataF
   
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
    if !OpenItemPed()
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
    if !OpenPdvNfce()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenNfce()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenNfceItem()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenPdvNfceItem()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenCidades()
        FechaDados()
        Msg(.f.)
        return
    endif
   if !(Abre_Dados(cDiretorio,"coriven",1,1,"CorIven",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end

   Msg(.f.)
   DesativaF9()
//   lGeral := .f.
   AtivaF4()
   Window(6,10,14,68)
   setcolor(Cor(11))
   //           234567890123456789012345678901234567890
   //                   2         3
   @ 08,12 say "  Produtos sem saldo:"
   @ 09,12 say "          Percentual:"
   @ 10,12 say "       Preco N/C/S/V:"
   @ 11,12 say "        Data Inicial:"
   @ 12,12 say "          Data Final:"
   while .t.
      cSaldo  := "N"
      cCodFor := space(04)
      cCodGru := space(03)
      nPct    := 1
      cPreco  := "N"
      dData   := ctod(space(08))
      dDataI  := date()
      dDataF  := date()
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 08,34 get cSaldo  picture "@k!" when Rodape("Esc-Encerra")
      @ 09,34 get nPct    picture "@k 99.99%" when Rodape("Esc-Encerra") valid iif(lastkey() == K_UP,.t.,nPct > 0)
      @ 10,34 get cPreco  picture "@k!" valid cPreco $ "N/C/S/V"
      @ 11,34 get dDataI  picture "@k"
      @ 12,34 get dDataF  picture "@k" valid dDataF >= dDataI
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
static procedure Processar

   
   
// *****************************************************************************
static procedure Imprima
   local cTela := SaveWindow(),lCabec := .t.,nVideo
   local lEstCid,nCont := 0,lFornec,lGrupo,lImpGru := .t.,cLixo
   local cCampo,cEstoque,nCalc,nSubTotal := 0,nTotal := 0,nLixo
   private nPagina := 2,cEst,lSaldo
   nTecla := 0

    
    if cSaldo == "N"
        // se o tipo do estoque for com/sem nota
        if nTipoEstoque = 0
            if !lGeral
                //lSaldo := ".t." //"Tmp05->QteAc01 > 0"
                lSaldo := "Tmp05->QteAc01 > 0"
            else
                lSaldo := "!(Tmp05->Qteac02 == 0)"
            endif
        // se o tipo do estoque for s¢ fisico
        elseif nTipoEstoque = 1
            lSaldo := "!(Tmp05->Qteac02 == 0)"
        endif
    else
        lSaldo := ".t."
    endif
    lFornec := iif(empty(cCodFor),".t.","Produtos->CodFor == cCodFor")
    lGrupo  := iif(empty(cCodGru),".t.","Produtos->CodGru == cCodGru")
    lData   := iif(empty(dData),".t.","Produtos->DtaAlt == dData")

    if !Use_dbf(cDiretorio,"tmp05",.t.,.t.,"Tmp05")
        Mens({"Arquivo para impressao indisponivel","Tente novamente"})
        Tmp05->(dbclosearea())
        return
    endif
    dbzap()
    index on despro to dados\tmp05
    index on codpro to dados\tmp052
    Tmp05->(dbclosearea())
    if !Use_dbf(cDiretorio,"tmp05",.t.,.t.,"Tmp05")
        Mens({"Arquivo para impressao indisponivel","Tente novamente"})
        Tmp05->(dbclosearea())
        return
    endif
    set index to dados\tmp05,dados\tmp052
    Produtos->(dbsetorder(1),dbgotop())
    Msg(.t.)
    Msg("Aguarde: Verificando as Informacoes")
    do while Produtos->(!eof())
        Tmp05->(dbappend())
        tmp05->CodPro := Produtos->CodPro
        tmp05->DesPro := Produtos->DesPro
        tmp05->embpro := Produtos->EmbPro
        tmp05->CodGru := Produtos->CodGru
        tmp05->OrdeF  := "A"+space(29)
        Produtos->(dbskip())
    enddo
    dbcommitall()
    Msg(.f.)
	GeraEntrada()
    GeraSaida()
    
    // se for os dois estoques
    if nTipoEstoque = 0
        if lGeral // se for sem nota
            Tmp05->(dbgotop())
            do while Tmp05->(!eof())
                if Tmp05->QteAC02 = 0
                    Tmp05->(dbdelete())
                endif
                Tmp05->(dbskip())
            enddo
            Tmp05->(dbgotop())
            if Tmp05->(eof())
                Mens({"NÆo existe informa‡äes"})
                Tmp05->(dbclosearea())
                return
            endif
        endif
    // se nÆo for, se for so o estoque fisico
    else
        Tmp05->(dbgotop())
        do while Tmp05->(!eof())
            if Tmp05->QteAC02 = 0
                Tmp05->(dbdelete())
            endif
            Tmp05->(dbskip())
        enddo
        Tmp05->(dbgotop())
        if Tmp05->(eof())
            Mens({"NÆo existe informa‡äes"})
            Tmp05->(dbclosearea())
            return
        endif
    endif
    dbcommitall()
//    Msg(.f.)
//	GeraEntrada()
//    GeraSaida()
    If Aviso_1(09,,14,,[Aten‡„o!],[Imprimir Relat¢rio ?],{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
        if Ver_Imp2(@nVideo)
            Cidades->(dbsetorder(1),dbseek(cEmpCodCid))
            Tmp05->(dbsetorder(1),dbgotop())
            if nVideo == 1
                cImpressoraPadrao := ImpressoraPadrao()
            endif
            oFrPrn := frReportManager():new()
            oFrPrn:LoadLangRes( 'brazil.xml')                     //arquivo de idioma
            oFrPrn:SetWorkArea("Tmp05",select("Tmp05"))
            // se for os dois estoques
            if nTipoEstoque = 0
                if !lGeral
                    oFrprn:LoadFromFile('inventario01.fr3')
                else
                    oFrprn:LoadFromFile('inventario02.fr3')
                endif
            // senÆo
            else
                oFrprn:LoadFromFile('inventario02.fr3')
            endif
            oFrPrn:AddVariable("variaveis","datainicial","'"+dtoc(dDatai)+"'")
            oFrPrn:AddVariable("variaveis","datafinal","'"+dtoc(dDataf)+"'")
            oFrPrn:AddVariable("variaveis","empresa","'"+cEmpRazao+"'")
            oFrPrn:AddVariable("variaveis","cidade","'"+rtrim(Cidades->NomCid)+"/"+cEmpEstCid+"'")
            oFrPrn:AddVariable("variaveis","cnpj","'"+transform(cEmpCnpj,"@r 99.999.999/9999-99")+"'")
            oFrPrn:AddVariable("variaveis","pagina","'"+strzero(nPagina,4)+"'")
            oFrPrn:AddVariable("variaveis","inscricao","'"+cEmpIe+"'")
            Msg(.t.)
            Msg("Aguarde: Gerando o relat¢rio")
            oFrPrn:PrepareReport()
            Msg(.f.)
            //oFrPrn:DesignReport()                                 // aqui para "desenhar" o relatório
            oFrPrn:PreviewOptions:SetAllowEdit( .F. )
            if nVideo == 2
                oFrPrn:ShowReport()
            else
                // se a impressÆo for na impressora padrÆo
                if !empty(cImpressoraPadrao)
                    oFrPrn:PrintOptions:SetShowDialog(.f.)
                else
                    oFrPrn:PrintOptions:SetShowDialog(.t.)
                endif
                oFrPrn:Print( .T. )
            endif
            oFrPrn:DestroyFR()
        endif
        Tmp05->(dbclosearea())
    endif
    return
// *****************************************************************************
static procedure GeraEntrada

	Msg(.t.)
	Msg("Aguarde: Verificando as Entradas")
	
	Compra->(dbgotop(),dbsetorder(3))
    // se for os dois estoques
    if nTipoEstoque = 0 
	   // ** se for sem nota
	   if lGeral
	   	   Compra->(dbsetfilter( { || DtaEnt <= dDataF .and. Compra->SN }))
	   else
		  Compra->(dbsetfilter( { || DtaEnt <= dDataF .and. !Compra->SN }))
	   endif
    // se nÆo se for o estoque fisico
    else
        Compra->(dbsetfilter( { || DtaEnt <= dDataF }))
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
                
            
            
                if Tmp05->(dbsetorder(2),dbseek(Cmp_Ite->CodPro))
				    // ** trava o registro
					do while !Tmp05->(Trava_Reg())
					enddo
                    // se for os dois estoque
                    if nTipoEstoque = 0
                        if lGeral // ** sem nota
						    Tmp05->QteAc02 += Cmp_Ite->Quantidade
					    else						      
                            Tmp05->QteAc01 += Cmp_Ite->Quantidade
                            tmp05->PcoNot01 += (cmp_ite->quantidade*cmp_ite->custo)
                            /*
						    if empty(Tmp05->Data01)
                                Tmp05->Data01   := Cmp_Ite->DtaEnt
							    Tmp05->PcoNot01 := Cmp_Ite->Custo
						    else
							    if Tmp05->Data01 < Cmp_Ite->DtaEnt
								    Tmp05->PcoNot01 := Cmp_Ite->Custo
                                endif
                            endif
                            */
                            
					    endif
                    // senÆo
                    else
                        Tmp05->QteAc02 += Cmp_Ite->Quantidade
                        if empty(Tmp05->Data01)
							 Tmp05->Data01   := Cmp_Ite->DtaEnt
							 Tmp05->PcoNot02 := Cmp_Ite->Custo
						  else
							 if Tmp05->Data02 < Cmp_Ite->DtaEnt
								Tmp05->PcoNot02 := Cmp_Ite->Custo
							endif
                        endif
                    endif
					Tmp05->(dbunlock())
				endif
				Cmp_Ite->(dbskip())
			enddo
		endif
		Compra->(dbskip())
	enddo
	Compra->(dbclearfilter())
    tmp05->(dbgotop())
    do while tmp05->(!eof())
    	do while !Tmp05->(Trava_Reg())
		enddo
        tmp05->pconot01 := tmp05->pconot01/tmp05->QteAc01
        tmp05->(dbunlock())
        tmp05->(dbskip())
    enddo
    
    Msg(.f.)
    return
// *****************************************************************************
static procedure GeraSaida

    // se for os dois estoques
    if nTipoEstoque = 0
        if !lGeral
            // ** Nota Fiscal Eletronica
            Msg(.t.)
            Msg("Aguarde: Processando NF-e")
            NFEVen->(dbgotop(),dbsetorder(2))
            Nfeven->(dbsetfilter( { || DtaEmi <= dDataF .and. !Nfeven->Cancelada }))
            Nfeven->(dbgotop())
            Nfeitem->(dbsetorder(1))
            do while Nfeven->(!eof())
                if Nfeitem->(dbseek(Nfeven->NumCon))
				    do while Nfeitem->Numcon == Nfeven->NumCon .and. Nfeitem->(!eof())
					   if tmp05->(dbsetorder(2),dbseek(Nfeitem->CodPro))
						  do while !Tmp05->(Trava_Reg())
						  enddo
						  tmp05->QteAc01 -= Nfeitem->QtdPro
						  //Tmp05->Saida   += nfeitem->QtdPro
						  tmp05->(dbunlock())
					   endif
					   Nfeitem->(dbskip())
				    enddo
                endif
                Nfeven->(dbskip())
            enddo
            Nfeven->(dbclearfilter())
            Msg(.f.)
        
            Msg(.t.)
            Msg("Aguarde: Processando NFC-e")
            PdvNfce->(dbsetorder(2),dbgotop())
            PdvNfce->(dbsetfilter( {|| Data <= dDataF .and. PdvNfce->Autorizado .and. !PdvNfce->Cancelada }))
            PdvNfce->(dbgotop())
            PdvNfceItem->(dbsetorder(1))
            Tmp05->(dbsetorder(2))
            do while PdvNfce->(!eof())
                if PdvNfceItem->(dbseek(PdvNfce->Lanc))
                    do while PdvNfceItem->Lanc == PdvNfce->Lanc .and. PdvNfceItem->(!eof())
                        if Tmp05->(dbseek(PdvNfceItem->CodPro))
                            do while !Tmp05->(Trava_Reg())
                            enddo
                            Tmp05->QteAc01 -= PdvNfceItem->QtdPro
                            Tmp05->(dbunlock())
                        endif
                        PdvNfceItem->(dbskip())
                    enddo
                endif
                PdvNfce->(dbskip())
            enddo
            PdvNfce->(dbclearfilter())
        
            // NFC-e
            Nfce->(dbsetorder(6),dbgotop())
            Nfce->(dbsetfilter( {|| DtaEmi <= dDataF .and. Nfce->Autorizado .and. !Nfce->Cancelada }))
            Nfce->(dbgotop())
            NfceItem->(dbsetorder(1))
            do while Nfce->(!eof())
                if NfceItem->(dbseek(Nfce->NumCon))
                    do while NfceItem->NumCon == Nfce->NumCon .and. NfceItem->(!eof())
                        if Tmp05->(dbsetorder(2),dbseek(NfceItem->CodPro))
                            do while !Tmp05->(Trava_Reg())
                            enddo
                            Tmp05->QteAc01 -= NfceItem->QtdPro
                        endif
                        NfceItem->(dbskip())
                    enddo
                endif
                Nfce->(dbskip())
            enddo
            Nfce->(dbclearfilter())
            Msg(.f.)
		
            Msg(.t.)
            Msg("Aguarde: Processando Ajustes")
		  // ** Arquivo de ajuste do inventario
		  //CorIven->(dbgotop(),dbsetorder(1))
		  //CorIven->(dbsetfilter( { || Data <= dDataF  }))
		  CorIven->(dbgotop())
		  //CorIven->(dbsetorder(1))
            do while CorIven->(!eof())
                if tmp05->(dbsetorder(2),dbseek(strzero(CorIven->CodPro,6)))
				    do while !Tmp05->(Trava_Reg())
				    enddo
				    tmp05->QteAc01 -= CorIven->Quantidade
				    tmp05->(dbunlock())
                endif
                CorIven->(dbskip())
            enddo
            //CorIven->(dbclearfilter())
            Msg(.f.)
        else
            ItemPed->(dbsetorder(4),dbgotop())
            do while ItemPed->(!eof())
                if ItemPed->DtaSai >= dDataI .and. ItemPed->DtaSai <= dDataF
                    if Tmp05->(dbsetorder(2),dbseek(ItemPed->CodPro))
                        while !Tmp05->(Trava_Reg())
                        enddo
                        Tmp05->QteAc02 -= ItemPed->QtdPro
                        Tmp05->(dbunlock())
                    endif
                    ItemPed->(dbskip())
                endif
            enddo
        endif
        // se nÆo dois estoque e for se nÆo fiscal
    elseif nTipoEstoque = 1
        ItemPed->(dbsetorder(4),dbgotop())
        do while ItemPed->(!eof())
            if ItemPed->DtaSai >= dDataI .and. ItemPed->DtaSai <= dDataF
                if Tmp05->(dbsetorder(2),dbseek(ItemPed->CodPro))
                    do while !Tmp05->(Trava_Reg())
                    enddo
                    Tmp05->QteAc02 -= ItemPed->QtdPro
                    Tmp05->(dbunlock())
                endif
            endif
            ItemPed->(dbskip())
        enddo
    endif
    return

static procedure ImprimaUSB
   local lCabec := .t.,nPagina := 2,cPrinter,nTotal := 0.00
   private oPrinter,cFont

   if !IniciaImpressora()
      return
   endif
   oPrinter:LeftMargin := 15
   Cidades->(dbsetorder(1),dbseek(cEmpCodCid))
   tmp05->(dbsetorder(1),dbgotop())
   while tmp05->(!eof())
      if &lSaldo.
         if lCabec
            oPrinter:setfont(cFont,,11)
            ImpLinha(oPrinter:prow()+1,00,cEmpFantasia)
            ImpLinha(oPrinter:prow()+1,00,rtrim(Cidades->NomCid)+"/"+cEmpEstCid)
            ImpLinha(oPrinter:prow()+1,00,"     CNPJ: "+transform(cEmpCnpj,"@r 99.999.999/9999-99"))
            ImpLinha(oPrinter:prow()  ,80-13,"Pagina : "+strzero(nPagina,4))
            ImpLinha(oPrinter:prow()+1,00,"Inscricao: "+cEmpIe)

            ImpLinha(oPrinter:prow()+3,00,padc("REGISTRO DE INVENTARIO",80))
            ImpLinha(oPrinter:prow()+1,00,padc("ESTOQUE EXISTENTE EM "+dtoc(dDataF),80))

            oPrinter:setfont(cFont,,13)
            ImpLinha(oPrinter:prow()+1,00,replicate("=",96))
            //                             012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
            //                                       1         2         3         4         5         6         7         8         9         0         1         2         3         4
            ImpLinha(oPrinter:prow()+1,00,"Cod.   Descricao                                          Und     Quant   Unitario        Total")
            //                             123456 12345678901234567890123456789012345678901234567890 123 9,999,999 99,999.999 9,999,999.99
            //                                                                                           Total: 999,999,999.99
            ImpLinha(oPrinter:prow()+1,00,replicate("=",96))
            lCabec := .f.
         end
         Produtos->(dbsetorder(1),dbseek(tmp05->CodPro))
         cEstoque := iif(!lGeral,"Tmp05->QteAc01","Tmp05->QteAc02")
         nValor := 0
         if !lGeral
            nValor := Tmp05->PcoNot01
         else
            nValor := Produtos->PcoVen
         end
         nCalc := nValor
         nCalc := nCalc * nPct
         nLixo := &cEstoque.
         nSubTotal := 0
         nSubTotal := (nCalc * nLixo)
         nTotal    += nSubTotal
         ImpLinha(oPrinter:prow()+1,000,tmp05->CodPro)
         ImpLinha(oPrinter:prow()  ,007,tmp05->DesPro)
         ImpLinha(oPrinter:prow()  ,058,Produtos->EmbPro)
         ImpLinha(oPrinter:prow()  ,062,transform(&cEstoque.,"@e 9,999,999"))
         ImpLinha(oPrinter:prow()  ,072,transform(nCalc     ,"@e 99,999.999"))
         ImpLinha(oPrinter:prow()  ,083,transform(nSubTotal ,"@e 9,999,999.99"))
      endif
      tmp05->(dbskip())
      if oPrinter:prow() > 64
         oPrinter:newpage()
         nPagina++
         lCabec := .t.
      endif
   enddo
   ImpNegrito(oPrinter:prow()+1,074,"Total:")
   ImpNegrito(oPrinter:prow()  ,081,transform(nTotal,"@e 999,999,999.99"))
   oPrinter:enddoc()
   oPrinter:Destroy()
   return



// ** Fim do Arquivo.
