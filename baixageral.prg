/*************************************************************************
         Sistema: Controle Administrativo
          VersÆo: 2.00
   Identifica‡Æo: Modulo Principal
         Prefixo: LtAdm
        Programa: LtAdm.PRG
           Autor: Andre Lucas Souza
            Data: 18 de Agosto de 2003
   Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConBaixaGeral(lAbrir)
   local oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados,cTela2
   local nCursor := setcursor(),cCor := setcolor()
   private nRecno

	if lAbrir
		if !AbrirArquivos()
			FechaDados()
			return
		endif
   else
      setcursor(SC_NONE)
   endif
   
   select BaixaGeral
   set order to 1
   goto top
   Rodape(iif(lAbrir,"Esc-Encerra","Esc-Encerra | ENTER-Transfere"))
   nLinha1  := 02
   nColuna1 := 00
   nLinha2  := maxrow()-1  // 23
   nColuna2 := maxcol()
   setcolor(cor(5))
   Window(nLinha1,nColuna1,nLinha2,nColuna2,"> Consulta de Baixa Geral <")
   oBrow := TBrowseDB(nLinha1+1,nColuna1+1,nLinha2-3,nColuna2-1)
   oBrow:headSep := SEPH
   oBrow:footSep := SEPB
   oBrow:colSep  := SEPV
   oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)   
   oBrow:addcolumn(tbcolumnnew("Codigo",{|| BaixaGeral->Codigo }))
   oBrow:addcolumn(tbcolumnnew("Data de;Pagamento" ,{|| BaixaGeral->Dta_Baixa }))
	oBrow:addcolumn(tbcolumnnew("Cliente",{|| Clientes->(dbsetorder(1),;
		dbseek(BaixaGeral->CodCli),Clientes->CodCli+"-"+Clientes->ApeCli)}))
	oBrow:addcolumn(tbcolumnnew("Valor;Selecionado",{|| transform(BaixaGeral->Vlr_Dupl,"@e 9,999,999.99")}))
	oBrow:addcolumn(tbcolumnnew("Valor dos;Juros",{|| transform(BaixaGeral->Juros,"@e 9,999,999.99")}))	
	oBrow:addcolumn(tbcolumnnew("Valor do;Desconto",{|| transform(BaixaGeral->Desconto,"@e 9,999,999.99")}))
	oBrow:addcolumn(tbcolumnnew("Valor Pago",{|| transform(BaixaGeral->Vlr_pago,"@e 9,999,999.99")}))	

	/*	   
   aTab := TabHNew(nLinha2-2,nColuna1+1,nColuna2-1,setcolor(cor(28)),1)
   TabHDisplay(aTab)
   */
   
   setcolor(Cor(26))
   scroll(nLinha2-1,nColuna1+1,nLinha2-1,nColuna2-1,0)
   Centro(nLinha2-1,nColuna1+1,nColuna2-1,"F2-Visualizar Duplicatas")
   do while (! lFim)
      do while ( ! oBrow:stabilize() )
         nTecla := INKEY()
         if ( nTecla != 0 )
            exit
         endif
      enddo
      aRect := {oBrow:rowpos,1,oBrow:rowPos,7}
      oBrow:colorRect(aRect,{2,2})
      if ( oBrow:stable )
         if ( oBrow:hitTop .OR. oBrow:hitBottom )
            tone(1200,1)
         endif
         nTecla := INKEY(0)
      endif
      if !TBMoveCursor(nTecla,oBrow)
         if nTecla == K_ESC
            lFim := .t.
         elseif nTecla == K_ENTER
            if !lAbrir
               cDados := BaixaGeral->Codigo
               keyboard (cDados)+chr(K_ENTER)
               lFim := .t.
            endif
         elseif nTecla == K_F2
         	VerDuplBaixada(BaixaGeral->Codigo)
         endif
      endif
      /*
      if nTecla == K_RIGHT
         tabHupdate(aTab,obrow:colpos,obrow:colcount,.t.)
      elseif nTecla == K_LEFT
         tabHupdate(aTab,obrow:colpos,obrow:colcount,.t.)
      endif
      */
      oBrow:refreshCurrent()
   enddo
   if !lAbrir
      setcursor(nCursor)
      setcolor(cCor)
   else
      FechaDados()
   end
   RestWindow( cTela )
   RETURN
// *********************************************************************************************************
procedure IncBaixaGeral
	local getlist := {}, cTela := SaveWindow()
	local cCodigo,cCodCli,dPagto,nJuros,nDesconto,cObservacao,aValorDaDupl,aJuros,aDesconto,aVlrPago
	local nValorCalculado
	private nValorPago
	private aDuplSelecionada,aValorSelecionado
	
	if !AbrirArquivos()
		Return
	endif
	TelBaixaGeral(1)
	do while .t.
		cCodCli    := space(04)
		dPagto     := date()
		nJuros     := 0.00
		nDesconto  := 0.00
		nValorPago := 0.00
		cObservacao := space(80)
		aJuros            := {}
		aDesconto         := {}
		aDuplSelecionada  := {}
		aValorSelecionado := {}
		nCalculo := 0.00
		if (Sequencia->baixageral+1) > 9999999999999
			Mens({"Limite de Baixa esgotado"})
			loop
		endif
		cCodigo := strzero(Sequencia->baixageral+1,13)
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 04,21 say cCodigo
		@ 05,21 get cCodCli picture "@k 9999" when Rodape("ESC-Encerra") ;
				valid Busca(Zera(@cCodCli),"Clientes",1,row(),col()+1,"Clientes->NomCli",{"Cliente Nao Cadastro"},.f.,.f.,.f.) .and.;
					SelecionarDupl(cCodCli)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		if Soma_Vetor(aValorSelecionado) == 0.00
			Mens({"Selecione alguma duplicata"})
			loop
		endif
		@ 06,21 say Soma_Vetor(aValorSelecionado) picture "@e 999,999.99"
		@ 07,21 get dPagto picture "@k" when Rodape("ESC-Encerrra") valid NoEmpty(dPagto)
		@ 08,21 get nJuros picture "@ke 999,999.99"
		@ 09,21 get nDesconto picture "@ke 999,999.99" valid CalcularValorPago(nJuros,nDesconto)
		@ 10,21 get nValorPago picture "@ke 999,999.99"
		@ 11,21 get cObservacao picture "@kS67"
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			loop
		endif
		if !Confirm(HB_AnsiToOem("Confirma as informações"),2)
			loop
		endif
		for nI := 1 to len(aDuplSelecionada)
			aadd(aJuros,0.00)
			aadd(aDesconto,0.00)
		next
		// ** Calcula o desconto proporcional nas duplicatas selecionadas
		if !empty(nDesconto)
			for nI := 1 to len(aDuplSelecionada)
				if !empty(aDuplSelecionada[nI])
					aDesconto[nI] := (aValorSelecionado[nI]*nDesconto)/Soma_Vetor(aValorSelecionado)
				endif
			next
		endif
		// ** Calcula o juros proporcional nas duplicatas selecionadas
		if !empty(nJuros)
			for nI := 1 to len(aDuplSelecionada)
				if !empty(aDuplSelecionada[nI])
					aJuros[nI] := (aValorSelecionado[nI]*nJuros)/Soma_Vetor(aValorSelecionado)
				endif
			next
		endif
		// ***********************************************************************
		do while !Sequencia->(Trava_Reg())
		enddo
		Sequencia->baixageral += 1
		Sequencia->(dbunlock())
		cCodigo := strzero(Sequencia->baixageral+1,13)
		@ 04,21 say cCodigo
		do while !BaixaGeral->(Adiciona())
		enddo
		BaixaGeral->codigo    := cCodigo
		BaixaGeral->CodCli    := cCodCli
		BaixaGeral->dta_baixa := dPagto
		BaixaGeral->vlr_pago  := nValorPago
		BaixaGeral->vlr_dupl  := Soma_Vetor(aValorSelecionado)
		BaixaGeral->juros     := nJuros
		BaixaGeral->desconto  := nDesconto
		BaixaGeral->obs       := cObservacao
		BaixaGeral->(dbcommit())
		BaixaGeral->(dbunlock())
		// ** 
		for nI := 1 to len(aDuplSelecionada)
			if !empty(aDuplSelecionada[nI])
				DupRec->(dbsetorder(2),dbseek(aDuplSelecionada[nI]))
				do while !DupRec->(Trava_Reg())
				enddo
				nValorCalculado := (aValorSelecionado[nI] + aJuros[nI]) - aDesconto[nI]
				if  nValorCalculado <= nValorPago
					DupRec->ValPag := nValorCalculado
				else
					DupRec->ValPag := nValorPago
				endif
				DupRec->DtaPag := dPagto // ** data de pagamento
				DupRec->ValJur := aJuros[nI]
				DupRec->ValDes := aDesconto[nI]
				DupRec->ObsBai := cObservacao
				DupRec->Recibo := cCodigo
				DupRec->(dbcommit())
				DupRec->(dbunlock())
				if nValorPago < nValorCalculado
         			// **if Aviso_1(09,,14,,"Aten‡„o!","Valor Pago Menor. Gerar Triplicata ?",{ "  ^Sim  ","  ^N„o  "},1,.t.) == 1
            			dDtaEmi    := DupRec->DtaEmi
            			dDtaVen    := DupRec->DtaVen
            			nValDup    := (DupRec->ValDup+aJuros[nI])-aDesconto[nI]
            			cTipoCobra := DupRec->TipoCobra
            			if right(alltrim(aDuplSelecionada[nI]),1) $ "0123456789"
               				do while !DupRec->(Adiciona())
               				enddo
               				DupRec->CodCli    := cCodCli
               				DupRec->NumDup    := alltrim(aDuplSelecionada[nI])+"A"
               				DupRec->TipoCobra := cTipoCobra
               				DupRec->DtaEmi    := dDtaEmi
               				DupRec->DtaVen    := dDtaVen
               				DupRec->ValDup    := nValDup-nValorPago
               				DupRec->Pedido    := "S"
               				DupRec->Recibo    := cCodigo  // ** cCodigo -> numero da baixa
               				DupRec->(dbcommit())
               				DupRec->(dbunlock())
               				cTriPli := DupRec->NumDup
            			else
               				nI := 1
               				do while .t.
                  				if !DupRec->(dbsetorder(1),dbseek(cCodCli+left(alltrim(aDuplSelecionada[nI]),;
                  					len(alltrim(aDuplSelecionada[nI]))-1)+chr(asc(right(alltrim(aDuplSelecionada[nI]),1))+nI)))
                     				do while !DupRec->(Adiciona())
                     				enddo
                     				DupRec->CodCli    := cCodCli
                     				DupRec->NumDup    := left(alltrim(aDuplSelecionada[nI]),;
                     										len(alltrim(aDuplSelecionada[nI]))-1)+;
                     										chr(asc(right(alltrim(aDuplSelecionada[nI]),1))+nI)
                     				DupRec->TipoCobra := cTipoCobra
                     				DupRec->DtaEmi    := dDtaEmi
                     				DupRec->DtaVen    := dDtaVen
                     				DupRec->ValDup    := nValDup-nValorPago
                     				DupRec->Pedido    := "S"
                     				DupRec->Recibo    := cCodigo  // ** cCodigo -> numero da baixa
                     				DupRec->(dbcommit())
                     				DupRec->(dbunlock())
                     				cTriPli := DupRec->NumDup
                     				exit
                  				else
                     				nI += 1
                  				endif
               				enddo
            			endif
            			if DupRec->(dbsetorder(1),dbseek(cCodCli+aDuplSelecionada[nI]))
               				do while !DupRec->(Trava_Reg())
               				enddo
               				DupRec->TriPlicata := cTriPli
               				DupRec->(dbunlock())
            			endif
         			// **endif
      			endif
      			// ** Efetua a baixa da duplicata
            	do while !BxaDupRe->(Adiciona())
            	enddo
            	cLanCxa := space(06)
            	// ** Gera o Lancamento no Movimento do Caixa
            	/*
            	if !empty(aValPag[nI])
               		LancMovCxa(@cLanCxa,dDtaPag,cRCodCxa,cRCodHis,aNumChq[nI],aCodBco[nI],aNumAge[nI],aNumCon[nI],aValPag[nI],aTipoCo[nI])
            	endif
            	*/
            	BxaDupRe->CodCli    := cCodCli
            	BxaDupRe->NumDup    := aDuplSelecionada[nI]
            	BxaDupRe->TipoCobra := "1"
				if  nValorCalculado <= nValorPago
					BxaDupRe->ValPag := nValorCalculado
				else
					BxaDupRe->ValPag := nValorPago
				endif
            	BxaDupRe->DtaPag    := dPagto
            	BxaDupRe->LanCxa    := cLanCxa
            	BxaDupRe->recibo    := cCodigo // ** cCodigo -> Numero da baixa
            	BxaDupRe->(dbcommit())
            	BxaDupRe->(dbunlock())
            	Grava_Log(cDiretorio,"Dupl.Receber|Baixa|Cliente "+cCodCli+" Duplicata "+aDuplSelecionada[nI],BxaDupRe->(recno()))
            	nValorPago := (nValorPago - nValorCalculado)
      			if nValorPago = 0
      				exit
      			endif
			endif
		next
	enddo
	FechaDados()
	RestWindow(cTela)
	return
// **********************************************************************************************************		
procedure canBaixaGeral
	local getlist := {}, cTela := SaveWindow()
	local cCodigoDaBaixa
	
	if !AbrirArquivos()
		return
	endif
	AtivaF4()
	TelBaixaGeral(3)
	do while .t.
		cCodigoDaBaixa := space(13)
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 04,21 get cCodigoDaBaixa picture "@k 9999999999999" when Rodape("ESC-Encerrar  | F4-Baixas") valid Busca(Zera(@cCodigoDaBaixa),"BaixaGeral",1,,,,{"Recibo nao cadastrado"},.f.,.f.,.f.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		Clientes->(dbsetorder(1),dbseek(BaixaGeral->CodCli))
		@ 05,21 say Clientes->CodCli+"-"+Clientes->NomCli
		@ 06,21 say BaixaGeral->Vlr_Dupl picture "@e 999,999,999.99"
		@ 07,21 say BaixaGeral->Dta_Baixa
		@ 08,21 say BaixaGeral->Juros picture "@e 999,999,999.99"
		@ 09,21 say BaixaGeral->Desconto picture "@e 999,999,999.99"
		@ 10,21 say BaixaGeral->Vlr_Pago picture "@e 999,999,999.99"
		if !Confirm("Confirma os dados para cancelamento",2)
			loop
		endif
		Msg(.t.)
		Msg("Aguarde: Cancelando a Baixa Geral")
		BaixaGeral->(dbsetorder(1),dbseek(cCodigoDaBaixa))
		do while !BaixaGeral->(Trava_Reg())
		enddo
		BaixaGeral->(dbdelete())
		BaixaGeral->(dbcommit())
		BaixaGeral->(dbunlock())
		DupRec->(dbsetorder(9),dbgotop(),dbseek(cCodigoDaBaixa))
		do while DupRec->Recibo == cCodigoDaBaixa .and. DupRec->(!eof())
			do while !DupRec->(Trava_Reg())
			enddo
			if !empty(right(DupRec->NumDup,1))
				DupRec->(dbdelete())
			else
				DupRec->ValPag := 0.00
				DupRec->DtaPag := ctod(space(08))
				DupRec->ValJur := 0.00
				DupRec->ValDes := 0.00
				DupRec->ObsBai := space(80)
			endif
			DupRec->(dbcommit())
			DupRec->(dbunlock())
			DupRec->(dbskip())
		enddo
		BxaDupRe->(dbsetorder(7),dbgotop(),dbseek(cCodigoDaBaixa))
		do while BxaDupRe->Recibo == cCodigoDaBaixa .and. BxaDupRe->(!eof())
			do while !BxaDupRe->(Trava_Reg())
			enddo
			BxaDupRe->(dbdelete())
			BxaDupRe->(dbcommit())
			BxaDupRe->(dbunlock())
			BxaDupRe->(dbskip())
		enddo
		Msg(.f.)
	enddo
	DesativaF4()
	FechaDados()
	RestWindow(cTela)
	return
// **********************************************************************************************************	
procedure impBaixaGeral
	local getlist := {}, cTela := SaveWindow()
	local cCodigoDaBaixa
	
	if !AbrirArquivos()
		return
	endif
	AtivaF4()
	TelBaixaGeral(2)
	do while .t.
		cCodigoDaBaixa := space(13)
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 04,21 get cCodigoDaBaixa picture "@k 9999999999999" when Rodape("ESC-Encerrar | F4-Baixas") valid Busca(Zera(@cCodigoDaBaixa),"BaixaGeral",1,,,,{"Recibo nao cadastrado"},.f.,.f.,.f.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		Clientes->(dbsetorder(1),dbseek(BaixaGeral->CodCli))
		@ 05,21 say Clientes->CodCli+"-"+Clientes->NomCli
		@ 06,21 say BaixaGeral->Vlr_Dupl picture "@e 999,999,999.99"
		@ 07,21 say BaixaGeral->Dta_Baixa
		@ 08,21 say BaixaGeral->Juros picture "@e 999,999,999.99"
		@ 09,21 say BaixaGeral->Desconto picture "@e 999,999,999.99"
		@ 10,21 say BaixaGeral->Vlr_Pago picture "@e 999,999,999.99"
		if !Confirm("Confirma os dados")
			loop
		endif
		iReciboGeralUSB(cCodigoDaBaixa)
	enddo
	DesativaF4()
	FechaDados()
	RestWindow(cTela)
	return
// **********************************************************************************************************	
static procedure TelBaixaGeral(nModo)
	local aTitulos := {" Baixa duplicatas ","Imprimir Recibo"," Cancelar baixa "}
	
	Window(02,00,13,90,"> " + aTitulos[ nModo ]+" <")
	setcolor(Cor(11))
	//           23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//                   1         2         3         4         5         6         7
	@ 04,02 say "    Nro. da baixa:"
	@ 05,02 say "          Cliente:"
	@ 06,02 say "Valor selecionado:"
	@ 07,02 say "    Data de pagto:"
	@ 08,02 say "   Valor do juros:" 
	@ 09,02 say "Valor do Desconto:"
	@ 10,02 say "       Valor pago:"
	@ 11,02 say HB_AnsiToOem("       Observação:")
	return
// **********************************************************************************************************	
static function CalcularValorPago(nJuros,nDesconto)

	nValorPago := (Soma_Vetor(aValorSelecionado)-nDesconto)-nJuros
	return(.t.)	
// **********************************************************************************************************
static function SelecionarDupl(cCodCli) // Mostra as Duplicatas a Pagar
   Local cCor := setcolor(),aVetor1,aVetor2,cTela,nI
   local aCampo  := {},aTitulo := {},aMascara := {}
   private aDupl := {},aEmissao := {},aVenc := {},aValor := {},aSelecao := {}
   Private nPos

	DupRec->(dbseek(cCodCli))
	do while DupRec->CodCli == cCodCli .and. DupRec->(!eof())
		if empty(DupRec->DtaPag)
			aadd(aDupl   ,DupRec->NumDup)
			aadd(aEmissao,DupRec->DtaEmi)
			aadd(aVenc   ,DupRec->DtaVen)
			aadd(aValor  ,DupRec->ValDup)
			aadd(aSelecao,space(01))
			aadd(aDuplSelecionada,space(13))
			aadd(aValorSelecionado,0.00)
		Endif
		DupRec->(dbskip())
	Enddo
	if len(aDupl) == 0
		Mens({"Nao Existe Duplicatas a Receber"})
		return(.f.)
	endif
	aVetor1 := {}
	for nI := 1 to len(aDupl)
		aadd(aVetor1,{aDupl[nI],aEmissao[nI],aVenc[nI],aValor[nI]})
	next
	aVetor2   := asort(aVetor1,,,{|x,y| x[3] < y[3]})
	aDupl     := {}
	aEmissao  := {}
	aVenc     := {}
	aValor    := {}
	for nI := 1 to len(aVetor2)
		aadd(aDupl    ,aVetor2[nI][1])
		aadd(aEmissao ,aVetor2[nI][2])
		aadd(aVenc    ,aVetor2[nI][3])
		aadd(aValor   ,aVetor2[nI][4])
	next
	aCampo   := {"aSelecao","aDupl"    ,"aEmissao","aVenc"    ,"aValor"}
	aTitulo  := {" "        ,"Duplicata","Emissao","Vencimento","Valor"}
	aMascara := {"@!"       ,"@!"       ,"@!"     ,"@!"        ,"@e 999,999.99"}
	cTela := SaveWindow()
	Rodape("Esc-Encerra | ENTER-Seleciona")
	Window(06,19,maxrow()-1,79,"> Selecao de Duplicatas <")
	@ maxrow()-1,22 say space(30)
	@ maxrow()-1,22 say " Selecionado:"
	@ maxrow()-1,57 say space(20)
	@ maxrow()-1,57 say " Total: "+transform(Soma_Vetor(aValor),"@e 999,999.99")
	Edita_Vet(07,20,maxrow()-2,78,aCampo,aTitulo,aMascara,"Selecao",,,5)
	RestWindow(cTela)
	if nPos == 0
		setcolor(cCor)
		return(.f.)
	endif
	setcolor(cCor)
	Return .t.
// *********************************************************************************************************	
Function Selecao( Pos_H, Pos_V, Ln, Cl, Tecla )

   If Tecla = 13
      nPos := pos_v
      Return( 0 )
   ElseIf Tecla = 27
      nPos := 0
      Return( 0 )
	elseif Tecla == K_SPACE
		if empty(aDuplSelecionada[Pos_V])
			aSelecao[Pos_V]          := ">"
			aDuplSelecionada[Pos_V ] := aDupl[Pos_V]
			aValorSelecionado[Pos_V] := aValor[Pos_V]
		else
			aSelecao[Pos_V]          := space(01)
			aDuplSelecionada[Pos_V]  := space(13)
			aValorSelecionado[Pos_V] := 0.00
		endif
		@ maxrow()-1,36 say Soma_Vetor(aValorSelecionado) picture "@e 999,999.99"
		return(2)
   EndIf
   Return( 1 )
// *********************************************************************************************************	   
procedure iReciboGeralUSB(cCodigoDaBaixa)
   local cTela := SaveWindow(),lCabec := .t.,cImpressoraPadrao
   local cTexto,cExtenso
   private nPagina := 1
   private oPrinter,cPrinter,cFont
   
   
	cImpressoraPadrao := ImpressoraPadrao()
	
	if !IniciaImpressora(cImpressoraPadrao)
		return
	endif
	   
   	begin sequence
      Msg(.t.)
      Msg("Aguarde: Imprimindo Recibo")
      nDinheiro := 0
      nCheque   := 0
      nDeposito := 0
      BaixaGeral->(dbsetorder(1),dbseek(cCodigoDaBaixa))
      
      Clientes->(dbsetorder(1),dbseek(BaixaGeral->CodCli))
      cExtenso := Extenso2(BaixaGeral->Vlr_Pago,.t.,.t.)
      cTexto := "        Recebemos de "+rtrim(Clientes->NomCli)+" a importancia de R$ "+rtrim(transform(BaixaGeral->Vlr_Pago,"@e 999,999.99"))+" ( "+cExtenso+" ), referente ao pagamento, Conforme abaixo descrito:"

      oPrinter:SetFont(cFont,,11)
      ImpNegrito(oPrinter:prow()+1,00,rtrim(cEmpFantasia))

      oPrinter:SetFont(cFont,,18)
      ImpLinha(oPrinter:prow()+1,000,rtrim(clEndLoj)+" "+rtrim(clMunLoj)+"/"+clEstLoj+" Fone: "+rtrim(clTelLoj))
      ImpLinha(oPrinter:prow()+1,000,"C.G.C..: "+transform(clCGCLoj,"@R 99.999.999/9999-99")+" Insc.Estadual: "+clInsLoj)

      oPrinter:SetFont(cFont,,11)
      ImpNegrito(oPrinter:prow()+3,035,"RECIBO")
      ImpNegrito(oPrinter:prow()+2,059,"No.: "+cCodigoDaBaixa)


      oPrinter:SetFont(cFont,,13)
      ImpLinha(oPrinter:prow()+2,000,"")
      for nI := 1 to mlcount(cTexto,80)
         if nI == 1
            ImpLinha(oPrinter:prow()+1,00,memoline(cTexto,100,nI))
         else
            ImpLinha(oPrinter:prow()+1,00,memoline(cTexto,100,nI))
         endif
      next
      oPrinter:SetFont(cFont,,18)
      ImpLinha(oPrinter:prow()+2,000,TracoCentro("[ Dados da(s) Duplicata(s) ]",136,"-"))
      //                             01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
      //                                       1         2         3         4         5         6         7         8         9         0         1         2         3
      ImpLinha(oPrinter:prow()+1,00,"Duplicata     Data       Vencimento     Valor Duplicata     Data       Vencimento     Valor Duplicata     Data       Vencimento     Valor")
      //                             1234567890123 99/99/9999 99/99/9999 99,999.99 1234567890123 99/99/9999 99/99/9999 99,999.99 1234567890123 99/99/9999 99/99/9999 99,999.99
      BxaDupRe->(dbsetorder(7),dbgotop(),dbseek(cCodigoDaBaixa))
		do while BxaDupRe->Recibo == cCodigoDaBaixa .and. BxaDupRe->(!eof())
			DupRec->(dbsetorder(2),dbseek(BxaDupRe->NumDup))
			ImpLinha(oPrinter:prow()+1,00,BxaDupRe->NumDup)
			ImpLinha(oPrinter:prow()  ,14,dtoc(DupRec->DtaEmi))
         	ImpLinha(oPrinter:prow()  ,25,dtoc(BxaDupRe->DtaPag))
         	ImpLinha(oPrinter:prow()  ,36,transform(BxaDupRe->ValPag,"@e 99,999.99"))
         	BxaDupRe->(dbskip())
         	if !(BxaDupRe->Recibo == cCodigoDaBaixa)
            	exit
         	endif
         	if BxaDupRe->(!eof())
         		DupRec->(dbsetorder(2),dbseek(BxaDupRe->NumDup))
            	ImpLinha(oPrinter:prow(),46,BxaDupRe->NumDup)
            	ImpLinha(oPrinter:prow(),60,dtoc(DupRec->DtaEmi))
            	ImpLinha(oPrinter:prow(),71,dtoc(BxaDupRe->DtaPag))
            	ImpLinha(oPrinter:prow(),82,transform(BxaDupRe->ValPag,"@e 99,999.99"))
         	endif
         	BxaDupRe->(dbskip())
         	if !(BxaDupRe->Recibo == cCodigoDaBaixa)
            	exit
         	endif
         	if BxaDupRe->(!eof())
         		DupRec->(dbsetorder(2),dbseek(BxaDupRe->NumDup))
            	ImpLinha(oPrinter:prow(),092,BxaDupRe->NumDup)
            	ImpLinha(oPrinter:prow(),106,dtoc(DupRec->DtaEmi))
            	ImpLinha(oPrinter:prow(),117,dtoc(BxaDupRe->DtaPag))
            	ImpLinha(oPrinter:prow(),128,transform(BxaDupRe->ValPag,"@e 99,999.99"))
         	endif
         	BxaDupRe->(dbskip())
      enddo
      ImpLinha(oPrinter:prow()+2,00,replicate("-",136))
      ImpLinha(oPrinter:prow()+2,00,rtrim(clMunLoj)+"( "+clEstLoj+" ), "+DatPort(BaixaGeral->Dta_Baixa,0))
      ImpLinha(oPrinter:prow()+1,40,"-----------------------------")
      ImpLinha(oPrinter:prow()+1,40,PwNome)
      ImpLinha(oPrinter:prow()+2,00,"Obs.: "+BaixaGeral->obs)
      oPrinter:enddoc()
      oPrinter:Destroy()
   end sequence
   Msg(.f.)
// **********************************************************************************************************   
static procedure VerDuplBaixada(cCodigoDaBaixa)
   Local cCor := setcolor(),cTela := SaveWindow()
   local aCampo  := {},aTitulo := {},aMascara := {}
   private aVetor1 := {},aVetor2 := {},aVetor3 := {},aVetor4 := {},aVetor5 := {}
   private aVetor6 := {},aVetor7 := {}

   DupRec->(dbsetorder(9),dbgotop(),dbseek(cCodigoDaBaixa))
   while DupRec->Recibo == cCodigoDaBaixa .and. DupRec->(!eof())
      aadd(aVetor1,DupRec->NumDup)
      aadd(aVetor2,DupRec->DtaVen)
      aadd(aVetor3,DupRec->ValDup)
      aadd(aVetor4,DupRec->DtaPag)
      aadd(aVetor5,DupRec->ValJur)
      aadd(aVetor6,DupRec->ValDes)
      aadd(aVetor7,DupRec->ValPag)
      DupRec->(dbskip())
   end
   aTitulo  := {"Duplicata","Vencimento","Valor"          ,"Dt.Pago","Juros"          ,"Desconto","Pago"}
   aCampo   := {"aVetor1"  ,"aVetor2"   ,"aVetor3"        ,"aVetor4","aVetor5"        ,"aVetor6" ,"aVetor7"}
   aMascara := {"@!"       ,"@k"        ,"@e 9,999,999.99","@k"     ,"@e 9,999,999.99","@e 9,999,999.99","@e 9,999,999.99"}
   cTela := SaveWindow()
   Rodape("Esc-Encerra")
   Window(10,00,maxrow()-3,91,"> Duplicatas baixadas <")
   Edita_Vet(11,01,maxrow()-4,90,aCampo,aTitulo,aMascara, [XAPAGARU],,.f.,7,2)
   RestWindow(cTela)
   setcolor(cCor)
   Return      
// *********************************************************************************************************	
static function AbrirArquivos

	Msg(.t.)
	Msg("Aguarde: Abrindo os arquivos")
    if !OpenClientes()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
    if !OpenDupRec()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
    if !OpenBxaDupRe()
 		FechaDados()
 		Msg(.f.)
 		return(.f.)
 	endif
    if !OpenBaixaGeral()
 		FechaDados()
 		Msg(.f.)
 		return(.f.)
 	endif
    if !OpenSequencia()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
	Msg(.f.)
	return(.t.)
		
// ** Fim do arquivo.
