/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 3.00
 * Identificacao: Manutencao de Notas Fiscais - Saida
 * Prefixo......: LTADM
 * Programa.....: CAIXA.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 28 DE DEZEMBRO DE 2002
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "Fileio.ch"
#define CRLF chr(K_ENTER)+chr(K_CTRL_ENTER)


procedure ConNFce(lAbrir)
    local oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados,cTela2
    local nCursor := setcursor(),cCor := setcolor(),lSaiMenu := .f.
    local nLinha1,nColuna1,nLinha2,nColuna2

	if lAbrir
		if !AbrirArquivos()
			return
		endif
	else
		setcursor(SC_NONE)
	endif
   select NFCe
   set order to 1
   dbgobottom()
   Rodape(iif(lAbrir,"Esc-Encerra","Esc-Encerra | ENTER-Transfere"))
   nLinha1  := 02
   nColuna1 := 00
   nLinha2  := maxrow()-1  // 23
   nColuna2 := 100
   setcolor(cor(5))
   Window(nLinha1,nColuna1,nLinha2,nColuna2,"> Consulta de NFC-e <")
   oBrow := TBrowseDB(nLinha1+1,nColuna1+1,nLinha2-7,nColuna2-1)
   oBrow:headSep := SEPH
   oBrow:footSep := SEPB
   oBrow:colSep  := SEPV
    oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)
    oCol := tbcolumnnew("Nr. Controle",{|| NFce->NumCon})
    oCol:colorblock := {|| iif( nfce->Autorizado,{1,2},{3,2})}   
	oBrow:addcolumn(oCol)
    
	oCol := tbcolumnnew("Nr. NFC-e",{|| NFce->NumNot})
    oCol:colorblock := {|| iif( nfce->Autorizado,{1,2},{3,2})}
    oBrow:addcolumn(oCol)
    
	oCol := tbcolumnnew("Cliente",;
		{|| NFce->CodCli+"-"+Clientes->(dbsetorder(1),dbseek(NFCe->CodCli),Clientes->ApeCli)})
    oCol:colorblock := {|| iif( nfce->Autorizado,{1,2},{3,2})}
    oBrow:addcolumn(oCol)        
        
        
	oCol := tbcolumnnew("Emissao",{|| NFce->DtaEmi})
    oCol:colorblock := {|| iif( nfce->Autorizado,{1,2},{3,2})}
    oBrow:addcolumn(oCol)
    
	oCol := tbcolumnnew("Valor",{|| transform(NFce->TotNot,"@e 999,999.99")})
    oCol:colorblock := {|| iif( nfce->Autorizado,{1,2},{3,2})}
    oBrow:addcolumn(oCol)
    
   setcolor(Cor(26))
   scroll(nLinha2-1,nColuna1+1,nLinha2-1,nColuna2-1,0)
   Centro(nLinha2-1,nColuna1+1,nColuna2-1,"F3-Visualizar Itens")
    do while (! lFim)
        do while ( ! oBrow:stabilize() )
            nTecla := INKEY()
            if ( nTecla != 0 )
                exit
            endif
        enddo
        @ nLinha2-6,01 say " Situacao: "+nfce->CStat Color Cor(11)
        @ nLinha2-5,01 say "   Motivo: "+nfce->XMotivo color Cor(11)
        
        if empty(nfce->chnfce)
            @ nLinha2-4,01 say "    Chave: "+space(50) color Cor(11)
        else
            @ nLinha2-4,01 say "    Chave: "+transform(nfce->chnfce,"9999.9999.9999.9999.9999.9999.9999.9999.9999.9999") color Cor(11)
        endif
        @ nLinha2-3,01 say "Protocolo: "+nfce->NProt color Cor(11)
        @ nLinha2-2,01 say "Data/Hora: "+nfce->DhRecBto color Cor(11)
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
               cDados := Nfce->NumCon
               keyboard (cDados)+chr(K_ENTER)
               lFim := .t.
            endif
         elseif nTecla == K_F3
            VerItemNfce(Nfce->NumCon)
         endif
      endif
   enddo
   if !lAbrir
      setcursor(nCursor)
      setcolor(cCor)
   else
      FechaDados()
   endif
   RestWindow( cTela )
   RETURN


procedure IncNFCe
    local getlist := {},cTela := SaveWindow()
    local llimpa := .t.
    local cNumPed
    
    // ** declara Variaveis de retorno do acbr    
    private cNRec    // número do recibo
    private cCStat
    private cXMotivo // 
    private cChNfe  // chave da acesso
    private cDhRec  // data e hora do recebimento
    private cNProt  // número do protocolo
    // **********************************************    
	private cCodCli,dDtaEmi
	Private cNumCon, cNumNot, cEstCli,cCodNat
	private nTotPro, nBasNor, nBasSub, nICMNor, nICMSub, MTotNo
	private MOutDsp, MIPINot, MAliICM, MPesBru
	private MCodPla, nDscNot
	private MBruPro	
	
   	private aAliSai    := {}
   	private aCST       := {}
   	private aBaseIcms  := {}
   	private aValorICMS := {}
   	private aIPI       := {}
   	private lEntrada := .f.,cFormaPag
	private cComando 
	
	private aCodItem  := {}
	private aDesPro   := {}
	private aQtdPro   := {}
	private aPcoVen   := {}
	private aEmbPro   := {}
	private aQteEmb   := {}
	private aDscPro   := {}  // ** Desconto do produto
	private aPcoLiq   := {}  // ** Valor Liquido de venda
	private aTotPro   := {}
	private aDesconto := {}
    private aCodPro   := {} // código do produto
	private aTitulo   := array(9),aCampo := array(9),aMascara := array(9)
	
	private aCodPagto := {} // ** Codigo de Pagamento
	private aDesPagto := {} // ** Descricao do Pagamento
	private aVlrPagto := {} // ** Valor do Pagamento
	private aCodiCredCartao := {} // ** Codigo da Credenciadora do Cartao de Credido/Debito
	private aBandeiraCartao := {} // ** Bandeira da operadora de cartão de crédito e/ou débito
	private aAutorizaCartao := {} // ** Número de autorização da operação cartão de crédito e/ou débito
    private cRetorno

	if !AbrirArquivos()
		return
	endif
	TelaNFCe(1)
    AtivaF4()
    setkey( K_F10, { |pcProg,pnLine,pcVar| IncCpfCliente( pcProg, pnLine, pcVar ) } )
    do while .t.
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        if lLimpa
            cNumCon := Space( 10 ) // ** número de controle
            cCodNat := space(03) // ** Natureza da Operação
            cNumNot := Space( 06 ) // ** Numero da nota
            cCodCli := space(04)
            dDtaEmi := date()
            
            nDscNot := 0
            MBruPro := 0
            
            MIPINot  := 0
            
            aCodItem  := {} // ** codigo do item do produto
            aDesPro   := {} // ** Descricao do produto
            aEmbPro   := {} // ** Embalagem do produto
            aQteEmb   := {} // ** Unidade na embalage,
            aPcoVen   := {} // ** Preco de venda bruto
            aDscPro   := {} // ** Percentual de desconto
            aPcoLiq   := {} // ** Preco liquido com desconto
            aQtdPro   := {} // ** Quantidade
            aTotPro   := {} // ** Valor total dos produtos
            aDesconto := {}
            aCodPro   := {} // ** Código do produto
            // ** Para calculo dos impostos
            aAliSai    := {}
            aCST       := {}
            aDesconto  := {}
            aBaseIcms  := {}
            aValorICMS := {}
            aIPI       := {}
            cNumPed    := space(09) // ** Numero do pedido
            cFormaPag  := space(02) // ** Forma de Pagamento
        endif
        cNRec     := "" // número do recibo
        cCStat    := ""
        cXMotivo  := "" // 
        cChNfe    := "" // chave da acesso
        cDhRec    := "" // data e hora do recebimento
        cNProt    := "" // número do protocolo
        
        nTotPro = 0
        nBasNor = 0
        nBasSub = 0
        nICMSub = 0
        nICMNor = 0
        MAliICM = 0
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        if (Sequencia->LancNFCE+1) > 9999999999
            Mens({"Limite de Lancamento Esgotado"})
            exit
        endif
        cNumCon := strzero(Sequencia->LancNFCE+1,10)
        cNumNot := strzero(Sequencia->NumNFCE+1,9,0)
        @ 03,11 say cNumCon
        @ 03,47 get cNumPed picture "@k 999999999";
      		when Rodape("Esc-Encerra | F4-Propostas");
      		valid iif(empty(cNumPed),.t.,Busca(Zera(@cNumPed),"Pedidos",1,,,,{"Numero Nao Cadastrado"},.f.,.f.,.f.))
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        // ** Se for infomado o numero da proposta
		if !empty(cNumPed)
			if !ImportaProposta(cNumPed)
				loop
			endif
			cCodCli := Pedidos->CodCli
            MostrarSubTotal()
		else
			if lLimpa
         		aadd(aCodItem,space(13))
				aadd(aDesPro,space(40))
				aadd(aEmbPro,space(04))
				aadd(aQteEmb,0)
				aadd(aPcoVen,0)
				aadd(aDscPro,0)
				aadd(aPcoLiq,0)
				aadd(aQtdPro,0)
				aadd(aTotPro,0)
				aadd(aDesconto,0)
                aadd(aCodPro,space(06)) // código do produto
            	// ** Parte para calcular os impostos
            	aadd(aAliSai,0)
				aadd(aCst,space(03))
            	aadd(aBaseIcms,0)
            	aadd(aValorICMS,0)
            	aadd(aIPI,0)
            endif
        endif
        // **************************
        @ 03,64 say cNumNot
        @ 04,11 get cCodCli picture "@k 9999" when Rodape("Esc-Encerra | F4-Clientes") valid vCliente(@cCodCli)
        @ 05,11 get cCodNat picture "@k 999";
      			when Rodape("Esc-Encerra | F4-Natureza da Operacao");
      			valid Busca(Zera(@cCodNat),"Natureza",1,row(),col(),"'-'+Natureza->Cfop+'-'+Natureza->Descricao",;
      				{"Natureza da Operacao Nao cadastrada"},.f.,.f.,.f.)
        @ 06,11 get dDtaEmi picture "@k";
				when Rodape("Esc-Encerra")
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
		GetItemsPedidos()  // ** Gets dos itens do pedido
		if lastkey() == K_F8
			loop
		endif
        
        Recebimento(.t.)
        
		nTotPro        := Soma_Veto2(aTotPro)
      	MBruPro        := Soma_Veto2(aTotPro)
      	nTotalDesconto := Soma_Veto2(aDesconto)
        
      	If !Empty( nDscNot )
        	nTotPro = MBruPro  // ** - nDscNot
      	EndIf
        
        MTotNot := nTotPro - nTotalDesconto + nICMSub + MIPINot
        MQtdVol :=  0 // ** Soma_Vetor( VQtdPro )
        MPerDsc := 0
        If !Empty( nDscNot )
            MPerDsc = nDscNot / MBruPro * 100
        EndIf
        
        // ** Regras para a calculo do Imposto *********************************************************
		nBaseICMS  := 0
		nValorICMS := 0
		nIPINot    := 0
		for nI := 1 to len(aCodItem)
			// ** Tributada sem permissao de Crédito
			if aCst[nI] == "102"
				aAliSai[nI]    := 0
				aBaseIcms[nI]  := 0
				aValorICMS[nI] := 0
			// ** Isenção do ICMS para faixa da receita bruta
			elseif aCst[nI] == "103"
				aAliSai[nI]    := 0
				aBaseICMS[nI]  := 0
				aValorICMS[nI] := 0
			// ** Imune
			elseif aCst[nI] == "300"
				aAliSai[nI]    := 0
				aBaseICMS[nI]  := 0
				aValorICMS[nI] := 0
			 // ** Não tributada
			elseif aCst[nI] == "400"
				aAliSai[nI]    := 0
				aBaseICMS[nI]  := 0
				aValorICMS[nI] := 0
			elseif aCst[nI] == "500"
				aAliSai[nI]    := 0
				aBaseICMS[nI]  := 0
				aValorICMS[nI] := 0
			elseif aCst[nI] == "900" // ** Outros
				if aAliSai[nI] == 0
					aBaseICMS[nI] := 0
					aValorICMS[nI] := 0
				endif
            else
                nBaseICMS  += aBaseICMS[nI]
                nValorICMS += aValorICMS[nI]
			endif
      	next
        // *********************************************************************
        // ** Gravação da NFCe
        
		do while !Sequencia->(Trava_Reg())
      	enddo
      	Sequencia->LancNFCE := val(cNumCon)
      	Sequencia->(dbunlock())
      	cNumCon := strzero(Sequencia->LancNFCE,10)
        
      	@ 03,11 say cNumCon
//      	@ 03,64 say cNumNot
      	
		GravarNFCe(.t.)		// ** Grava o Cabecalho da Nota
		GravarItensNFCe(.t.)   // ** Grava os Itens da NFCe
		GravarFormaPagto(.t.)	// ** Grava o detalhamento da forma de pagamento
         
		If Aviso_1( 17,, 22,, [Aten‡„o!], [Transmitir NFC-e ?], { [  ^Sim  ], [  ^NÆo  ] }, 1, .t. ) = 1
			if Sequencia->TestarInte == "S"
				lInternet := Testa_Internet()
         		if !lInternet
            		loop
         		endif
         	endif
            
            // Travou arquivo de sequencia da nota
            do while Sequencia->(!Trava_Reg())
            enddo
            cNumNot := Sequencia->NumNFCE + 1
            
            // trava o registro da nota fiscal
            do while nfce->(!Trava_Reg())
            enddo
            nfce->NumNot := strzero(cNumNot,9)
            nfce->Serie  := Sequencia->SerieNfce
            
         	// ** Monta a nota fiscal de comsunidor eletronica
         	MontarNFCe()
         	// ** verifica o status de conexão com a secretária da fazenda
            if !Status_NFeNFCe(Sequencia->dirNFe) 
                nfce->NumNot := space(09)
                nfce->Serie  := space(03)
                nfce->(dbcommit())
                nfce->(dbunlock())
                Sequencia->(dbunlock())
				loop
			endif
            // Cria o arquivo xml
            if !Criar_NFeNFCe(rtrim(Sequencia->dirNFe),@cChNfe,cComando)
                nfce->NumNot := space(09)
                nfce->Serie  := space(03)
                nfce->(dbcommit())
                nfce->(dbunlock())
                Sequencia->(dbunlock())
				loop
			endif
            // grava a chave da nota gerada
            nfce->Chnfce := cChNfe
            
            if !Assinar_NFeNFCe(rtrim(Sequencia->DirEnvResp),rtrim(Sequencia->dirNFe),cChNfe)            
                nfce->NumNot := space(09)
                nfce->Serie  := space(03)
                nfce->(dbcommit())
                nfce->(dbunlock())
                Sequencia->(dbunlock())
				loop
			endif
            // faz a valida‡Æo da nota
            if !Validar_NFeNFCe(rtrim(Sequencia->DirEnvResp),rtrim(Sequencia->dirNFe),cChNfe)
                nfce->NumNot := space(09)
                nfce->Serie  := space(03)
                nfce->(dbcommit())
                nfce->(dbunlock())
                Sequencia->(dbunlock())
				loop
			endif
            // transmite a nota
            if !Transmitir_NFeNFCe(rtrim(Sequencia->DirEnvResp),rtrim(Sequencia->dirNFe),cChNfe)
                nfce->NumNot := space(09)
                nfce->Serie  := space(03)
                nfce->Cstat   := cCStat
                nfce->Xmotivo := cXMotivo
                nfce->(dbcommit())
                nfce->(dbunlock())
                Sequencia->(dbunlock())
				loop
			endif
            cCStat    := RetornoSEFAZ("CStat",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
            cXMotivo  := RetornoSEFAZ("XMotivo",rtrim(Sequencia->dirNFe)+"\sainfe.txt") 
            cNProt    := RetornoSEFAZ("NProt",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
            cDhRecbto := RetornoSEFAZ("DhRecbto",rtrim(Sequencia->dirNFe)+"\sainfe.txt")

            // atualiza os dados da nota            
			nfce->Autorizado := iif(cCStat == "100",.t.,.f.)
            nfce->CStat      := cCStat
            nfce->XMotivo    := cXMotivo
			nfce->ChNFCe     := cChNFe
			nfce->DhRecbto   := cDhRecbto
			nfce->NProt      := cNProt
			nfce->(dbcommit())
			nfce->(dbunlock())
            // Atualiza a sequencia da nota fiscal
            Sequencia->NumNfce := cNumNot
            Sequencia->(dbunlock()) // destrava o registro de sequencia
            if Aviso_1( 17,, 22,, [Aten‡„o!],"Imprimir NFC-e ?", { [  ^Sim  ], [  ^NÆo  ] }, 1, .t. ) == 1
                Imprimir_NFeNFCe(rtrim(Sequencia->dirNFe),cChNfe)
            endif
		endif
    enddo
    setkey(K_F10,NIL)
    DesativaF4()
    if PwNivel == "0"
        AtivaF9()
    endif
    FechaDados()
    RestWindow(cTela)
    return
// **********************************************************************************************************
procedure AltNFCe
    local getlist := {},cTela := SaveWindow()
    local llimpa := .t.
    local cNumPed
    
	private cCodCli,dDtaEmi
	Private cNumCon, cNumNot, cEstCli,cCodNat
	private nTotPro, nBasNor, nBasSub, nICMNor, nICMSub, MTotNo
	private MOutDsp, MIPINot, MAliICM, MPesBru
	private MCodPla, nDscNot
	private MBruPro	
	
   	private aAliSai    := {}
   	private aCST       := {}
   	private aBaseIcms  := {}
   	private aValorICMS := {}
   	private aIPI       := {}
   	private lEntrada := .f.,cFormaPag
	private cComando 
	
	private aCodItem  := {}
	private aDesPro   := {}
	private aQtdPro   := {}
	private aPcoVen   := {}
	private aEmbPro   := {}
	private aQteEmb   := {}
	private aDscPro   := {}  // ** Desconto do produto
	private aPcoLiq   := {}  // ** Valor Liquido de venda
	private aTotPro   := {}
	private aDesconto := {}
    private aCodPro   := {} // ** código do produto
	private aTitulo   := array(9),aCampo := array(9),aMascara := array(9)
	
	private aCodPagto := {} // ** Codigo de Pagamento
	private aDesPagto := {} // ** Descricao do Pagamento
	private aVlrPagto := {} // ** Valor do Pagamento
	private aCodiCredCartao := {} // ** Codigo da Credenciadora do Cartao de Credido/Debito
	private aBandeiraCartao := {} // ** Bandeira da operadora de cartão de crédito e/ou débito
	private aAutorizaCartao := {} // ** Número de autorização da operação cartão de crédito e/ou débito
    private cRetorno

	if !AbrirArquivos()
		return
	endif
	TelaNFCe(2)
    AtivaF4()
    setkey( K_F10, { |pcProg,pnLine,pcVar| IncCpfCliente( pcProg, pnLine, pcVar ) } )
    do while .t.
        cNumCon := space(10)
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 03,11 get cNumCon picture "@k 9999999999";
                when Rodape("Esc-Encerra | F4-NFC-e");
                valid Busca(Zera(@cNumCon),"nfce",1,,,,{"Nao cadastrado"},.f.,.f.,.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        if nfce->autorizado
            Mens({"NFC-e ja autorizada"})
            loop
        endif
        if nfce->Cancelada
            Mens({"NFC-e ja cancelada"})
            loop
        endif
        cCodCli := nfce->CodCli
        cCodNat := nfce->CodNat
        dDtaEmi := nfce->DtaEmi
        
        
        // ** carrega os itens da nfce
        aCodItem  := {}
        aDesPro   := {}
        aQtdPro   := {}
        aPcoVen   := {}
        aEmbPro   := {}
        aQteEmb   := {}
        aDscPro   := {}  // ** Desconto do produto
        aPcoLiq   := {}  // ** Valor Liquido de venda
        aTotPro   := {}
        aDesconto := {}
        aCodPro   := {}  // ** Código do produto
        
        aAliSai    := {}
        aCST       := {}
        aBaseIcms  := {}
        aValorICMS := {}
        aIPI       := {}
        nfceitem->(dbsetorder(1),dbseek(cNumCon))
        do while nfceitem->NumCon == cNumCon .and. nfceitem->(!eof())
            Produtos->(dbsetorder(1),dbseek(nfceitem->codpro))
            aadd(aCodItem,nfceitem->coditem)
            aadd(aDesPro,Produtos->FanPro)
            aadd(aEmbPro,Produtos->EmbPro)
            aadd(aQteEmb,Produtos->QteEmb)
            aadd(aPcoVen,nfceitem->PcoVen)
            aadd(aDscPro,nfceitem->DscPro) // ** desconto (%)
			aadd(aQtdPro,nfceitem->QtdPro) 
            aadd(aPcoLiq,nfceitem->PcoLiq)// ** preço líquido
            aadd( aTotPro,nfceitem->TotPro)
            aadd( aDesconto,nfceitem->desconto)
            aadd(aCodPro,nfceitem->CodPro) // ** Código do produto
            
            aadd(aAliSai,nfceitem->AliSai) 
            aadd(aCst,nfceitem->CstSimples) 
            aadd(aBaseICms,nfceitem->baseicms) 
            aadd(avaloricms,nfceitem->valoricms)
            aadd( aIpi     ,nfceitem->ipi)
            nfceitem->(dbskip())
        enddo
        
        // ** carrega o detalhamento da forma de pagamento
        aCodPagto := {}
        aVlrPagto := {}
        aCodiCredCartao := {}
        aBandeiraCartao := {}
        aAutorizaCartao := {}
        DetPagtonfce->(dbsetorder(1),dbseek(cNumCon))
        FormaPagtoNFCE->(dbsetorder(1))
        do while DetPagtoNfce->NumCon == cNumCon .and. DetPagtoNfce->(!eof())
            FormaPagtoNFCE->(dbseek(DetPagtoNfce->CodPagto))
			aadd(aCodPagto,DetPagtoNfce->CodPagto)
            aadd(aDesPagto,FormaPagtoNFCE->DesPagto)
			aadd(aVlrPagto,DetPagtoNfce->VlrPagto)
			aadd(aCodiCredCartao,DetPagtoNfce->codiCred)
			aadd(aBandeiraCartao,DetPagtoNfce->Bandeira) // ** Bandeira da operadora de cartão de crédito e/ou débito
			aadd(aAutorizaCartao,DetPagtoNfce->Autoriza) // ** Número de autorização da operação cartão de crédito e/ou débito
			DetPagtoNfce->(dbskip())
        enddo
        // *************************************************
        @ 03,64 say nfce->NumNot
        @ 04,11 get cCodCli picture "@k 9999" when Rodape("Esc-Encerra | F4-Clientes") valid vCliente(@cCodCli)
        @ 05,11 get cCodNat picture "@k 999";
      			when Rodape("Esc-Encerra | F4-Natureza da Operacao");
      			valid Busca(Zera(@cCodNat),"Natureza",1,row(),col(),"'-'+Natureza->Cfop+'-'+Natureza->Descricao",;
      				{"Natureza da Operacao Nao cadastrada"},.f.,.f.,.f.)
        @ 06,11 get dDtaEmi picture "@k";
				when Rodape("Esc-Encerra")
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        MostrarSubTotal()
		GetItemsPedidos()  // ** Gets dos itens do pedido
		if lastkey() == K_F8
			loop
		endif
        
        Recebimento(.f.)
        
		nTotPro        := Soma_Veto2(aTotPro)
      	MBruPro        := Soma_Veto2(aTotPro)
      	nTotalDesconto := Soma_Veto2(aDesconto)
        
      	If !Empty( nDscNot )
        	nTotPro = MBruPro  // ** - nDscNot
      	EndIf
        
        MTotNot := nTotPro - nTotalDesconto
        MQtdVol :=  0 // ** Soma_Vetor( VQtdPro )
        MPerDsc := 0
        If !Empty( nDscNot )
            MPerDsc = nDscNot / MBruPro * 100
        EndIf
        
        // ** Regras para a calculo do Imposto *********************************************************
		nBaseICMS  := 0
		nValorICMS := 0
		nIPINot    := 0
		for nI := 1 to len(aCodItem)
			// ** Tributada sem permissao de Crédito
			if aCst[nI] == "102"
				aAliSai[nI]    := 0
				aBaseIcms[nI]  := 0
				aValorICMS[nI] := 0
			// ** Isenção do ICMS para faixa da receita bruta
			elseif aCst[nI] == "103"
				aAliSai[nI]    := 0
				aBaseICMS[nI]  := 0
				aValorICMS[nI] := 0
			// ** Imune
			elseif aCst[nI] == "300"
				aAliSai[nI]    := 0
				aBaseICMS[nI]  := 0
				aValorICMS[nI] := 0
			 // ** Não tributada
			elseif aCst[nI] == "400"
				aAliSai[nI]    := 0
				aBaseICMS[nI]  := 0
				aValorICMS[nI] := 0
			elseif aCst[nI] == "500"
				aAliSai[nI]    := 0
				aBaseICMS[nI]  := 0
				aValorICMS[nI] := 0
			elseif aCst[nI] == "900" // ** Outros
				if aAliSai[nI] == 0
					aBaseICMS[nI] := 0
					aValorICMS[nI] := 0
				endif
            else
                nBaseICMS  += aBaseICMS[nI]
                nValorICMS += aValorICMS[nI]
			endif
      	next
        // *********************************************************************
        // ** Gravação da NFCe
        
		GravarNFCe(.f.)		// ** Grava o Cabecalho da Nota
        
		GravarItensNFCe(.f.)   // ** Grava os Itens da NFCe
		GravarFormaPagto(.f.)	// ** Grava o detalhamento da forma de pagamento
         
    enddo
    setkey(K_F10,NIL)
    DesativaF4()
    if PwNivel == "0"
        AtivaF9()
    endif
    FechaDados()
    RestWindow(cTela)
    return
    
procedure ExcNFCe // ** ExclusÆo do Lan‡amento
	local getlist := {}, cTela := SaveWindow()
	local cNumCon
    
	if !AbrirArquivos()
		FechaDados()
		return
	endif

	AtivaF4()
	Window(08,09,15,70,"> Exclui (Lan‡amento) NFC-e <")
   setcolor(Cor(11))
   @ 10,11 say "N§ Controle:"
   @ 11,11 say "    Cliente:"
   @ 12,11 say "       Data:"
   @ 13,11 say "      Valor:"
    do while .t.
        cNumCon := Space( 10 )
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 10,24 get cNumCon picture "@k 9999999999";
                when Rodape("Esc-Encerra | F4-NFC-e");
                valid Busca(Zera(@cNumCon),"nfce",1,,,,{"Controle Nao Cadastrado"},.f.,.f.,.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        Clientes->(dbsetorder(1),dbseek(nfce->CodCli))
        @ 11,24 say nfce->CodCli+"-"+Clientes->ApeCli
        @ 12,24 say nfce->DtaEmi
        @ 13,24 say nfce->TotNot picture "@e 999,999.99"
        if nfce->Autorizado
            Mens({"Nota fiscal ja transmitida"})
            loop
        endif
        if nfce->Cancelada
            Mens({"Nota cancelada"})
            loop
        endif
        if !Confirm("Confirma as informa‡äes")
            loop
        endif
        Msg(.t.)
        Msg("Aguarde: Excluindo Lan‡amento")
        do while NFce->(!Trava_Reg())
        enddo
        if NfceItem->(dbsetorder(1),dbseek(cNumCon))
            do while NfceItem->NumCon == cNumCon .and. NfceItem->(!eof())
                do while NfceItem->(!Trava_Reg())
                enddo
                Produtos->(dbsetorder(1),dbseek(NfceItem->CodPro))
                do while Produtos->(!Trava_Reg())
                enddo
                Produtos->QteAC01 += NfceItem->QtdPro
                Produtos->(dbcommit())
                Produtos->(dbunlock())
                
                NfceItem->(dbdelete())
                NfceItem->(dbcommit())
                NfceItem->(dbunlock())
                NfceItem->(dbskip())
            enddo
        endif
        Nfce->(dbdelete())
        Nfce->(dbcommit())
        Nfce->(dbunlock())
        Msg(.f.)
   enddo
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
    
// **********************************************************************************************************

// ** Transmite a NFC-e
// **********************************************************************************************************
procedure TranNFCe // ** Faz transmissão
	local getlist := {}, cTela := SaveWindow()
	local cNumCon
    local cCodNumerico // C¢digo num‚rico da nfce
    
    // ** declara Variaveis de retorno do acbr    
    private cNRec    // número do recibo
    private cCStat
    private cXMotivo // 
    private cChNfe  // chave da acesso
    private cDhRec  // data e hora do recebimento
    private cNProt  // número do protocolo

	private cComando
	
	if !AbrirArquivos()
		FechaDados()
		return
	endif

	AtivaF4()
	Window(08,09,15,70,"> Transmitir NFCe <")
   setcolor(Cor(11))
   @ 10,11 say "N§ Controle:"
   @ 11,11 say " N§ da nota:"
   @ 12,11 say "    Cliente:"
   @ 13,11 say "       Data:"
   @ 14,11 say "      Valor:"
    do while .t.
        cNumCon := Space( 10 )
        cNRec    := "" // número do recibo
        cCStat   := ""
        cXMotivo := "" // 
        cChNfe   := "" // chave da acesso
        cDhRec   := "" // data e hora do recebimento
        cNProt   := "" // número do protocolo
        
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 10,24 get cNumCon picture "@k 9999999999";
                when Rodape("Esc-Encerra | F4-NFC-e");
                valid Busca(Zera(@cNumCon),"nfce",1,,,,{"Controle Nao Cadastrado"},.f.,.f.,.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        Clientes->(dbsetorder(1),dbseek(nfce->CodCli))
        @ 12,24 say nfce->CodCli+"-"+Clientes->ApeCli
        @ 13,24 say nfce->DtaEmi
        @ 14,24 say nfce->TotNot picture "@e 999,999.99"
        if nfce->Autorizado
            Mens({"Nota fiscal ja transmitida"})
            loop
        endif
        if nfce->Cancelada
            Mens({"Nota cancelada"})
            loop
        endif
        if !(nfce->DtaEmi == date()) 
            if Aviso_1( 17,, 22,, [Aten‡„o!],"Data de emissÆo diferente da data atual, atualiza data?", { [  ^Sim  ], [  ^NÆo  ] }, 1, .t. ) == 1
                do while nfce->(!Trava_Reg())
                enddo
                nfce->DtaEmi := date()
                nfce->(dbcommit())
                nfce->(dbunlock())
                Msg(.t.)
                Msg("Aguarde: Atualizando a data de emissÆo")
                nfceitem->(dbsetorder(1),dbseek(cNumCon))
                do while nfceitem->NumCon == cNumCon .and. nfceitem->(!eof())
                    do while nfceitem->(!Trava_Reg())
                    enddo
                    nfceitem->DtaMov := date()
                    nfceitem->(dbcommit())
                    nfceitem->(dbunlock())
                    nfceitem->(dbskip())
                enddo
                nfceitem->(dbgotop())
                Msg(.f.)
            else
                loop
            endif
        endif
        if !Confirm("Confirma as informa‡äes")
            loop
        endif
		if Sequencia->TestarInte == "S"
			lInternet := Testa_Internet()
         	if !lInternet
            	loop
         	endif
		endif
            
            // Travou arquivo de sequencia da nota
            do while Sequencia->(!Trava_Reg())
            enddo
            cNumNot := Sequencia->NumNFCE + 1
            
            @ 11,24 say cNumNot
            
            // trava o registro da nota fiscal
            do while nfce->(!Trava_Reg())
            enddo
            nfce->NumNot := strzero(cNumNot,9)
            nfce->Serie  := Sequencia->SerieNfce
            
         	// ** Monta a nota fiscal de comsunidor eletronica
         	MontarNFCe()
            
         	// ** verifica o status de conexão com a secretária da fazenda
            if !Status_NFeNFCe(Sequencia->dirNFe) 
                nfce->NumNot := space(09)
                nfce->Serie  := space(03)
                nfce->(dbcommit())
                nfce->(dbunlock())
                Sequencia->(dbunlock())
				loop
			endif
            // Cria o arquivo xml
            if !Criar_NFeNFCe(rtrim(Sequencia->dirNFe),@cChNfe,cComando)
                nfce->NumNot := space(09)
                nfce->Serie  := space(03)
                nfce->(dbcommit())
                nfce->(dbunlock())
                Sequencia->(dbunlock())
				loop
			endif
            // grava a chave da nota gerada
            nfce->Chnfce := cChNfe
            
            if !Assinar_NFeNFCe(rtrim(Sequencia->DirEnvResp),rtrim(Sequencia->dirNFe),cChNfe)            
                nfce->NumNot := space(09)
                nfce->Serie  := space(03)
                nfce->(dbcommit())
                nfce->(dbunlock())
                Sequencia->(dbunlock())
				loop
			endif
            
            // faz a valida‡Æo da nota
            if !Validar_NFeNFCe(rtrim(Sequencia->DirEnvResp),rtrim(Sequencia->dirNFe),cChNfe)            
                nfce->NumNot := space(09)
                nfce->Serie  := space(03)
                nfce->(dbcommit())
                nfce->(dbunlock())
                Sequencia->(dbunlock())
				loop
			endif
            
            if !Transmitir_NFeNFCe(rtrim(Sequencia->DirEnvResp),rtrim(Sequencia->dirNFe),cChNfe)
                nfce->NumNot := space(09)
                nfce->Serie  := space(03)
                nfce->Cstat   := cCStat
                nfce->Xmotivo := cXMotivo
                nfce->(dbcommit())
                nfce->(dbunlock())
                Sequencia->(dbunlock())
				loop
			endif
            cCStat    := RetornoSEFAZ("CStat",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
            cXMotivo  := RetornoSEFAZ("XMotivo",rtrim(Sequencia->dirNFe)+"\sainfe.txt") 
            cNProt    := RetornoSEFAZ("NProt",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
            cDhRecbto := RetornoSEFAZ("DhRecbto",rtrim(Sequencia->dirNFe)+"\sainfe.txt")

            // atualiza os dados da nota            
			nfce->Autorizado := iif(cCStat == "100",.t.,.f.)
            nfce->CStat      := cCStat
            nfce->XMotivo    := cXMotivo
			nfce->ChNFCe     := cChNFe
			nfce->DhRecbto   := cDhRecbto
			nfce->NProt      := cNProt
			nfce->(dbcommit())
			nfce->(dbunlock())
            // Atualiza a sequencia da nota fiscal
            Sequencia->NumNfce := cNumNot
            Sequencia->(dbunlock()) // destrava o registro de sequencia
            if Aviso_1( 17,, 22,, [Aten‡„o!],"Imprimir NFC-e ?", { [  ^Sim  ], [  ^NÆo  ] }, 1, .t. ) == 1
                Imprimir_NFeNFCe(rtrim(Sequencia->dirNFe),cChNfe)        
            endif
    enddo
    DesativaF4()
    if PwNivel == "0"
        AtivaF9()
    endif
    FechaDados()
    RestWindow(cTela)
return
// **********************************************************************************************************
// ** Consulta a NFC-e na SEFAZ
// **********************************************************************************************************
procedure ConNFCeSEFAZ
	local getlist := {},cTela := SaveWindow()
	local cNrNota,cStatus
	
	
	if !AbrirArquivos()
		return
	endif
	AtivaF4()
	Window(08,09,20,70,"> Consultar NFC-e na Sefaz <")
	setcolor(Cor(11))
	@ 10,11 say "Nr. da Nota:"
	@ 11,11 say "    Cliente:"
	@ 12,11 say "       Data:"
	@ 13,11 say "      Valor:"
	@ 14,10 say replicate(chr(196),60)
	@ 15,11 say "     Status:"
	@ 16,11 say "     Motivo:"
	@ 17,11 say "  Protocolo:"
	@ 18,11 say "  Data/Hora:"
	do while .t.
		cNrNota  := Space( 9)
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 10,24 get cNrNota picture "@k 999999999" when Rodape("ESC-Encerrar") valid Busca(Zera(@cNrNota),"nfce",3,,,,{"Nota Fiscal nao Cadastrada"},.f.,.f.,.f.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		Clientes->(dbsetorder(1),dbseek(nfce->CodCli))
		@ 11,24 say nfce->CodCli+"-"+Clientes->ApeCli
		@ 12,24 say nfce->DtaEmi
		@ 13,24 say nfce->TotNot picture "@e 999,999.99"
		if !Confirm("Confirma as Informacoes")
			loop
		endif
		if Sequencia->TestarInte == "S"
			lInternet := Testa_Internet()
         	if !lInternet
            	loop
         	endif
		endif
        // ** verifica o status de conexão com a secretária da fazenda
        if !Status_NFeNFCe(Sequencia->dirNFe)
			loop
		endif
        if !Consultar_NFeNFCe(Sequencia->DirNFe,nfce->ChNFCe)
            loop
        endif
        cCStat    := RetornoSEFAZ("CStat",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
		cNProt    := RetornoSEFAZ("NProt",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
		cDhRecbto := RetornoSEFAZ("DhRecbto",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
		cXMotivo  := RetornoSEFAZ("XMotivo",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
		@ 15,24 say cCStat
		@ 16,24 say cXMotivo
		@ 17,24 say cNProt
		@ 18,24 say cDhRecbto
        
		do while !nfce->(Trava_Reg())
		enddo
        if cCStat == "100"
            nfce->Autorizado  := .t.
        endif
        if cCStat == "101"
            nfce->Cancelada := .t.
        endif
		nfce->NProt       := cNProt
        nfce->DhRecbto    := cDhRecbto
		nfce->CStat       := cCStat
        nfce->xmotivo     := cXMotivo
		nfce->(dbunlock())
	enddo
	DesativaF4()
	if PwNivel == "0"
		AtivaF9()
	endif
	FechaDados()
	RestWindow(cTela)
	return
// **********************************************************************************************************
procedure CanNFCe // ** Cancelar NFC-e
   local getlist := {},cTela := SaveWindow()
   local cNrNota,cObsCan1,cObsCan2,cObsCan3,lLimpa := .t.
   private cCStat,cXMotivo,cNProt,cDhRecbto
   
   
	if !AbrirArquivos()
		return
	endif
   AtivaF4()
   Window(08,00,20,92,"> Cancela NFC-e <")
   setcolor(Cor(11))
   //           2345678901234567890
   @ 10,02 say "N§ Nota:"
   @ 11,02 say "Cliente:"
   @ 12,02 say "Emissao:"
   @ 13,02 say "  Sa¡da:"
   @ 14,02 say "  Valor:"
   @ 15,01 say replicate(chr(196),90)
   @ 16,02 say "Motivo :"
	do while .t.
		if lLimpa
			cNrNota := Space(09)
      		cObsCan1 := space(80)
      		cObsCan2 := space(80)
      		cObsCan3 := space(80)
      		lLimpa := .f.
      	endif
      	setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      	@ 10,11 get cNrNota picture "@k 999999999";
                when Rodape("Esc-Encerra | F4-Notas ");
                valid Busca(Zera(@cNrNota),"nfce",3,,,,{"Nota Nao Cadastrada"},.f.,.f.,.f.)
      	setcursor(SC_NORMAL)
      	read
      	setcursor(SC_NONE)
      	if lastkey() == K_ESC
         	exit
      	endif
      	Clientes->(dbsetorder(1),dbseek(nfce->CodCli))
      	nfceitem->(dbsetorder(1),dbseek(nfce->numnot))
      	@ 11,11 say nfce->CodCli+"-"+Clientes->NomCli
      	@ 12,11 say nfce->DtaEmi
      	@ 13,11 say nfce->DtaSai
      	@ 14,11 say nfce->TotNot picture "@e 999,999.99"
      	if !nfce->autorizado
         	Mens({"Nota fiscal nÆo autorizada"})
         	loop
      	endif
      	if nfce->Cancelada
         	Mens({"Nota Ja Cancelada"})
         	loop
      	endif
		@ 16,11 get cObsCan1 picture "@k" when Rodape("Esc-Encerra")
		@ 17,11 get cObsCan2 picture "@k"
		@ 18,11 get cObsCan3 picture "@k"
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			loop
		endif
		if empty(cObsCan1+cObsCan2+cObsCan3)
			Mens({"Obrigatorio o preenchimento do Motivo do Cancelamento"})
			loop
		endif
		if len(rtrim(cObsCan1)+rtrim(cObsCan2)+rtrim(cObsCan3)) < 15
			Mens({"Caracter m¡nimo ‚ 15"})
			loop
		endif
		if !Confirm("Confirma o Cancelamento",2)
			loop
		endif
		if Sequencia->TestarInte == "S"
			lInternet := Testa_Internet()
			if !lInternet
				loop
			endif
		endif
        if !Status_NFeNFCe(Sequencia->dirNFe)
			loop
		endif
		cTexto := ""
		if !empty(cObsCan1)
			cTexto += cObsCan1 + iif(!empty(cObsCan2),";","")
		endif
		if !empty(cObsCan2)
			cTexto += cObsCan2 + iif(!empty(cObsCan3),";","")
		endif
		if !empty(cObsCan3)
			cTexto += rtrim(cObsCan3)
		endif
		Msg(.t.)
		Msg("Aguarde: Cancelando NFC-e")
        AcbrNFE_CancelarNFe(rtrim(Sequencia->DirNFe),nfce->ChNfce,rtrim(cTexto),cEmpCnpj)
        cRetorno := Mon_Ret(rtrim(Sequencia->dirNFe),"sainfe.txt",Sequencia->Tempo)
		if !Men_Ok(cRetorno)
			Msg(.f.)
			LerErro(rtrim(Sequencia->DirNFe),"sainfe.txt")
			loop
		endif
		Msg(.f.)
		cCStat    := MEN_RET("CStat",cRetorno)
		cXMotivo  := MEN_RET( "XMotivo",cRetorno)
		cNProt    := MEN_RET( "NProt",cRetorno)
		cDhRecbto := MEN_RET("DhRecbto",cRetorno)
		if !(cCStat == "135")
			MostrarErro(cCStat,cXMotivo)
			loop
		endif
		if empty(cNProt)
			Mens({"Problema com Protocolo de Cancelamento","Favor repetir o cancelamento"})
			loop
		endif
		do while !nfce->(Trava_Reg())
		enddo
      	nfce->Cancelada   := .t.
      	nfce->NProtca    := cNProt     // ** n£mero do protocolo de cancelando
      	nfce->DhRecbtoca := cDhRecbto  // ** Data e hora do cancelamento
      	nfce->CStatca    := cCStat     // ** c¢digo de retorno da operacao
      	nfce->XMotivoca  := cXMotivo   // ** Mensagem do retorno da opera‡Æo
      	nfce->(dbunlock())
      	nfceitem->(dbsetorder(1),dbseek(cNrNota))
		do while nfceitem->NumCon == cNrNota .and. nfceitem->(!eof())
			do while !nfceitem->(Trava_Reg())
			enddo
         	nfceitem->Cancelada := .t.
			if Produtos->(dbsetorder(1),dbseek(nfceitem->CodPro))
				if Produtos->CtrlEs == "S"
					do while !Produtos->(Trava_Reg())
                  	enddo
                    // Atualiza estoque fiscal
                  	Produtos->QteAc01 += nfeitem->QtdPro
                    // Atualiza estoque fisico
                    Produtos->QteAc02 += NfeItem->QtdPro
                  	Produtos->(dbunlock())
               	endif
            endif
         	nfceitem->(dbunlock())
         	nfceitem->(dbskip())
      	enddo
      	Mens({"Nota fiscal cancelada"})
      	lLimpa := .t.
	enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   endif
   FechaDados()
   RestWindow(cTela)
   return
   
procedure EmailNFCe // ** Envia email
    local getlist := {},cTela := SaveWindow()
    local cNrNFce,cEmail,cAssunto,cRetorno
    
    if !AbrirArquivos()
        return
    endif
    
	AtivaF4()
	Window(08,09,18,70," Enviar NFe por email ")
	setcolor(Cor(11))
	@ 10,11 say "Nr.   NFC-e:"
	@ 11,11 say "    Cliente:"
	@ 12,11 say "       Data:"
	@ 13,11 say "      Valor:"
	@ 14,10 say replicate(chr(196),60)
	@ 15,11 say "      Email:"
	@ 16,11 say "    Assunto:"
    do while .t.
        cNrNFce := space(09)
        cEmail  := space(60)
        cAssunto := space(60)
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 10,24 get cNrNFce picture "@k 999999999";
            when Rodape("ESC-Encerra");
            valid Busca(Zera(@cNrNFce),"nfce",3,,,,{"NFC-e nao cadastrada"},.f.,.f.,.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        if !nfce->Autorizado
            Mens({"NFC-e nao autorizada"})
            loop
        endif
        Clientes->(dbsetorder(1),dbseek(nfce->CodCli))
        cEmail := Clientes->EmaCli+space(20)
        @ 11,24 say nfce->CodCli+"-"+Clientes->ApeCli
        @ 12,24 say nfce->DtaEmi  // ** data da emissão
        @ 13,24 say nfce->TotNot picture "@ke 999,999.99"
        @ 15,24 get cEmail picture "@KS45"
        @ 16,24 get cAssunto picture "@KS45"
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            loop
        endif
        if !Confirm("Confirma as informacoes")
            loop
        endif
        if Sequencia->TestarInte == "S"
            if !Testa_Internet()
            	loop
         	endif
        endif
		Msg(.t.)
		Msg("Aguarde: Enviando Email")
        AcbrNFe_EnviarEmail(rtrim(Sequencia->DirNFE),cEmail,nfce->ChNFce,1,cAssunto)        
        cRetorno := Mon_Ret(rtrim(Sequencia->dirNFe),"sainfe.txt",Sequencia->Tempo)
		Msg(.f.)        
		if !Men_Ok(cRetorno)
			Mens({"Email nao enviado, favor verificar"})
			loop
		else
			Mens({"Email enviando com sucesso"})
		endif
    enddo
    FechaDados()
    RestWindow(cTela)
    return
// **********************************************************************************************************
procedure ImpNFCe // ** Imprime o DANFE
	local getlist := {}, cTela := SaveWindow()
	local cNumCon,cArquivoXML
	
	if !AbrirArquivos()
		FechaDados()
		return
	endif

	AtivaF4()
	Window(08,09,15,70,"> Imprimir DANFE NFCe <")
   setcolor(Cor(11))
   @ 10,11 say "N§ Controle:"
   @ 11,11 say "    Cliente:"
   @ 12,11 say "       Data:"
   @ 13,11 say "      Valor:"
   while .t.
        cNumCon := Space( 10 )
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 10,24 get cNumCon picture "@k 9999999999";
                valid Busca(Zera(@cNumCon),"nfce",1,,,,{"Controle Nao Cadastrado"},.f.,.f.,.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        if !nfce->Autorizado
         Mens({"Nota fiscal nao transmitida"})
         loop
      endif
        Clientes->(dbsetorder(1),dbseek(nfce->CodCli))
        @ 11,24 say nfce->CodCli+"-"+Clientes->ApeCli
        @ 12,24 say nfce->DtaSai
        @ 13,24 say nfce->TotNot picture "@e 999,999.99"
        if !nfce->Autorizado
            Mens({"Nota fiscal nao transmitida"})
            loop
        endif
		if !Confirm("Confirma os Dados")
			loop
		endif
        Imprimir_NFeNFCe(rtrim(Sequencia->dirNFe),nfce->chnfce)
   enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   endif
   FechaDados()
   RestWindow(cTela)
   return
// **********************************************************************************************************   
static function vCliente(cCodCli)

   if !Busca(Zera(@cCodCli),"Clientes",1,row(),col(),"'-'+left(Clientes->ApeCli,30)",{"Cliente Nao Cadastrado"},.f.,.f.,.f.)
      return(.f.)
   endif
	cCodNat := Clientes->CodNat   
	// ** Se o cliente for Venda ao Consumidor não faz a validação do restante dos dados
	if cCodCli == "9999"
		return(.t.)
	endif
   if empty(Clientes->NumCli)
      Mens({"Erro no cadastro do cliente","N£mero do endere‡o esta vazio"})
      return(.f.)
   endif
   Cidades->(dbsetorder(1),dbseek(Clientes->CodCid))
   cEstCli := Cidades->EstCid
   
   if empty(Clientes->CodNat)
      Mens({"Natureza Fiscal do Cliente NÆo Cadastrada","Favor Verificar"})
      return(.f.)
   endif
   if !Natureza->(dbsetorder(1),dbseek(Clientes->CodNat))
      Mens({"Natureza Fiscal Nao Cadastrada"})
      return(.f.)
   endif
   return(.t.)
// **********************************************************************************************************   
/*
	Mostra os totais
*/
static procedure MostrarSubTotal
	

	@ 30,85 say Soma_Veto2(aTotPro)   picture "@e 99,999,999.99"   // ** Mostra Sub total
	@ 31,85 say Soma_Veto2(aDesconto) picture "@e 99,999,999.99"  // ** Mostra o valor total do desconto
	@ 32,84 say Soma_Veto2(aTotPro)-Soma_Veto2(aDesconto) picture "@e 999,999,999.99"  // ** Valor total
	return
// **********************************************************************************************************	
static procedure AdicionarItemNFCe(nPosicao)
	local N_Itens := Len( aCodItem ) + 1
	
	asize(aCodItem  ,n_Itens)
	asize(aDesPro   ,n_Itens)
	asize(aEmbPro   ,n_Itens)
	asize(aQteEmb   ,n_Itens)
	asize(aPcoVen   ,n_Itens)
	asize(aDscPro   ,n_Itens)
	asize(aPcoLiq   ,n_Itens)
	asize(aQtdPro   ,n_Itens)
	asize(aTotPro   ,n_Itens)
	asize(aDesconto ,n_Itens)  // ** Desconto em Valor
    asize(aCodPro   ,n_Itens)  // ** Código do produto
	asize(aCST      ,N_Itens)
	asize(aBaseICMS ,N_Itens)
	asize(aAliSai   ,N_Itens )
	asize(aValorICMS,N_Itens)
	asize(aIPI      ,N_Itens)

	ains(aCodItem  ,nPosicao+1)
	ains(aDesPro   ,nPosicao+1)
	ains(aEmbPro   ,nPosicao+1)
	ains(aQteEmb   ,nPosicao+1)
	ains(aPcoVen   ,nPosicao+1)
	ains(aDscPro   ,nPosicao+1)
	ains(aPcoLiq   ,nPosicao+1)                  	
	ains(aQtdPro   ,nPosicao+1)
	ains(aTotPro   ,nPosicao+1)
	ains(aDesconto ,nPosicao+1)
    ains(aCodPro   ,nPosicao+1) // ** Código do produto
	ains(aAliSai   ,nPosicao+1)
	ains(aCST      ,nPosicao+1)
	ains(aBaseICMS ,nPosicao+1)
	ains(aValorICMS,nPosicao+1)
	ains(aIPI      ,nPosicao+1)

	aCodItem[nPosicao+1] := space(13)
	aDesPro[nPosicao+1] := space(40)
	aEmbPro[nPosicao+1] := space(04)
	aQteEmb[nPosicao+1] := 0
	aPcoVen[nPosicao+1] := 0
	aDscPro[nPosicao+1] := 0
	aPcoLiq[nPosicao+1] := 0
	aQtdPro[nPosicao+1] := 0.00
	aTotPro[nPosicao+1] := 0
	aDesconto[nPosicao+1] := 0
    aCodPro[nPosicao+1]   := space(06) // ** Código do produto

	aCST[nPosicao+1] := space(03)
	aAliSai[nPosicao+1]    := 0	
	aBaseIcms[nPosicao+1]  := 0
	aValorICMS[nPosicao+1] := 0
	aIPI[nPosicao+1]       := 0
	return
// **********************************************************************************************************
function nfceitem( Pos_H, Pos_V, Ln, Cl, nTecla )
   Local Laco, Verif := .f.

   If nTecla == K_ENTER
      // ** Codigo do Produto
        If Pos_H = 1
            cCampo := aCodItem[Pos_V]
            @ Ln,Cl get cCampo picture "@k";
         		when Rodape("Esc-Encerra | F4-Produtos");
         		valid ValidProduto(@cCampo)
            setcursor(SC_NORMAL)
            read
            setcursor(SC_NONE)
            if !(lastkey() == K_ESC)
                Rodape("Esc-Encerra")
                aCodItem[Pos_V] := cCampo
                aDesPro[pos_v] := Produtos->FanPro
                aEmbPro[Pos_V] := Produtos->EmbPro
                aQteEmb[Pos_V] := Produtos->QteEmb
                aPcoVen[pos_v] := Produtos->PcoCal
                aCodPro[Pos_V] := Produtos->CodPro
                aCST[Pos_V]    := Produtos->Cst
                if Natureza->Local == "F"
				    aAliSai[Pos_V] := Produtos->AliFor
			    elseif Natureza->Local == "D" 
				    aAliSai[Pos_V] := Produtos->AliDtr
			    endif
                if C_VAltPco == "N"
                    keyboard replicate(chr(K_RIGHT),5)+chr(K_ENTER)
                else
                    keyboard replicate(chr(K_RIGHT),4)+chr(K_ENTER)
                endif
                Return(2)
            EndIf
        // ** Preco de venda            
        elseif Pos_H == 5
            // *8 se permitir a altera‡Æo de pre‡o na venda
            if C_VAltPco == "S"
                cCampo := aPcoVen[Pos_V]
                @ Ln,Cl get cCampo picture "@e 999,999.999"
                setcursor(SC_NORMAL)              
                read
                setcursor(SC_NONE)
                if !(lastkey() == K_ESC)
                    aPcoVen[Pos_V] := cCampo
                    keyboard chr(K_RIGHT)+chr(K_ENTER)
                    return(2)
                endif
            endif
            
        // ** Desconto
		elseif Pos_H == 6
			cCampo := aDscPro[pos_v]
         	@ ln,Cl get cCampo picture "@e 999.99";
         				when Rodape("Esc-Encerra")
         	setcursor(SC_NORMAL)
         	read
         	setcursor(SC_NONE)
         	if !(lastkey() == K_ESC)
            	aDscPro[Pos_V] := cCampo
            	if aDscPro[Pos_V] > 0
            		aPcoLiq[Pos_V] := round(aPcoVen[Pos_V]-(round(aPcoVen[Pos_V]*(aDscPro[Pos_V] /100),2)),2)
            	else
            		aPcoLiq[Pos_V] := aPcoVen[Pos_V]
            	endif
            	keyboard chr(K_RIGHT)+chr(K_ENTER)
            	return(2)
            endif
            
		elseif Pos_H == 7
			cCampo := aQtdPro[pos_v]
         	@ ln,Cl get cCampo picture "@e 999,999.999";
         				when Rodape("Esc-Encerra");
         				valid NoEmpty(cCampo) .and. vSaldo(cCampo,aCodItem[Pos_V])
         	setcursor(SC_NORMAL)
         	read
         	setcursor(SC_NONE)
        	if !(lastkey() == K_ESC)
				aQtdPro[Pos_V]   := cCampo
            	aTotPro[Pos_V]   := aQtdPro[Pos_V]*aPcoVen[Pos_V]   //aPcoLiq[Pos_V]
            	aDesconto[Pos_V] := (aPcoVen[Pos_V]*aQtdPro[Pos_V])-(aPcoLiq[Pos_V]*aQtdPro[Pos_V])
            	aBaseICMS[Pos_V] := aTotPro[Pos_V]
            	MostrarSubTotal() // ** Apresenta os totais
               	if Pos_v >= len(aCodItem)
                    // ** Cria mais itens 
               		AdicionarItemNFCe(Pos_V)
                  	keyboard chr(K_DOWN)+replicate(chr(K_LEFT),Pos_H-1)+chr(K_ENTER)
                  	return(3)
               	endif
            else
               	keyboard chr(K_RIGHT)+chr(K_ENTER)
            endif
         	Return( 2 )
		EndIf
   elseif nTecla = K_F2
      N_Itens := Len(aCodItem)
      Brancos := 0
      For Laco = 1 to Len(aCodItem)
          If !Empty(aCodItem[Laco]) .and. (Empty(aQtdPro[Laco]) .or. Empty(aPcoLiq[Laco]))
             Aviso_1( 10,, 15,, [Aten‡„o!], [N„o s„o permitidos quantidades ou pre‡os zerados.], { [  ^Ok!  ] }, 1, .t., .t. )
             Return( 1 )
          ElseIf Empty( aCodItem[Laco] )
             ++Brancos
          EndIf
      Next
      If Brancos = N_Itens
         Aviso_1( 10,, 15,, [Aten‡„o!], [N„o ‚ permitido gravar nota sem ¡tens.], { [  ^Ok!  ] }, 1, .t., .t. )
         Return( 1 )
      EndIf
      Return( 0 )
	ElseIf nTecla == K_F4
		// ** Adiciona linha no tbrowser
		AdicionarItemNFCe(Pos_V)
		keyboard Chr( 24 ) + Chr( 13 )
		Return( 3 )
   elseif nTecla == K_F2
      return(0)
   elseif nTecla == K_F8
      return(0)
	ElseIf nTecla == K_F6
		If Len( aCodItem ) > 1
			if !Confirm("Confirma a Exclusao do Item")
            	return(0)
         	endif
			adel(aCodItem  ,Pos_V)
			adel(aDesPro   ,Pos_V)
			adel(aEmbPro   ,Pos_V)
			adel(aQteEmb   ,Pos_V)
			adel(aPcoVen   ,Pos_V)
			adel(aDscPro   ,Pos_V)
			adel(aPcoLiq   ,Pos_V)
			adel(aQtdPro   ,Pos_V)
			adel(aTotPro   ,Pos_V)
			adel(aDesconto ,Pos_V) // ** Desconto em Valor
            adel(aCodPro   ,Pos_V) // ** Código do produto
			adel(aCST      ,Pos_V)
			adel(aBaseICMS ,Pos_V)
			adel(aAliSai   ,Pos_V )
			adel(aValorICMS,Pos_V)
			adel(aIPI      ,Pos_V)
         	nItens := Len(aCodItem) - 1
			asize(aCodItem,nItens)
			asize(aDesPro,nItens)
			asize(aEmbPro,nItens)
			asize(aQteEmb,nItens)
			asize(aPcoVen,nItens)
			asize(aDscPro,nItens)
			asize(aPcoLiq,nItens)
			asize(aQtdPro,nItens)
			asize(aTotPro,nItens)
			asize(aDesconto,nItens)  // ** Desconto em Valor
            asize(aCodPro,nItens) // ** Código do produto
            
			asize(aCST      ,nItens)
			asize(aBaseICMS ,nItens)
			asize(aAliSai   ,nItens )
			asize(aValorICMS,nItens)
			asize(aIPI      ,nItens)
         	return( 3 )
      	EndIf
   EndIf
   Return( 1 )
// **********************************************************************************************************
static function vSaldo(nQtd,cCampo)

    if !ValidProduto(cCampo)
        return(.f.)
    endif
	if Produtos->CtrlEs == "S"
		if nQtd > Produtos->QteAc01
			Mens({"Este produto Nao tem saldo suficiente"})
         	return(.f.)
      	endif
   endif
   return(.t.)
// **********************************************************************************************************
static function vCodigo(cCodProd,pos_v)  // Verifica se o item ja foi cadastrado

   if !(ascan(aCodPro,cCodProd) == 0) .and. !(aCodPro[pos_v] == cCodProd)
      Mens({"Item Ja Cadastrado"})
      return(.f.)
   end
   return(.t.)
// **********************************************************************************************************
static function Soma_Veto2( Vetor )
   local Laco, Retorno := 0, Tam_Vetor := LEN( Vetor )

   for Laco := 1 TO Tam_Vetor
      Retorno += round(Vetor[Laco],2)
   next
   return( Retorno )
// **********************************************************************************************************
static procedure VerItemNot(cNumCon)
   Local cCor := setcolor(),cTela := SaveWindow()
   local aCampo  := {},aTitulo := {},aMascara := {}
   private aVetor1 := {},aVetor2 := {},aVetor3 := {},aVetor4 := {},aVetor5 := {}
   private aVetor6 := {}

   nfceitem->(dbsetorder(1),dbseek(cNumCon))
   while nfceitem->NumCon == cNumCon .and. nfceitem->(!eof())
      Produtos->(dbsetorder(1),dbseek(nfceitem->CodPro))
      aadd(aVetor1,nfceitem->CodPro)
      aadd(aVetor2,left(Produtos->DesPro,23)+"-> "+str(Produtos->QteEmb,3)+" x "+Produtos->EmbPro)
      aadd(aVetor3,nfceitem->QtdPro)
      aadd(aVetor4,nfceitem->PcoPro)
      aadd(aVetor5,nfceitem->QtdPro*nfceitem->PcoPro)
      nfceitem->(dbskip())
   end
   aCampo   := { "aVetor1" ,"aVetor2"   ,"aVetor3"   ,"aVetor4"     ,"aVetor5"}
   aTitulo  := { "C¢digo"  ,"Descri‡„o ","Qtde."     ,"P‡o. Venda"  ,"Total" }
   aMascara := {"@k 999999","@!S40"     ,"@E 999,999","@E 99,999.99","@E 9,999,999.99"}
   cTela := SaveWindow()
   Rodape("Esc-Encerra")
   Window(10,00,23,79,chr(16)+" Itens da Nota "+chr(17))
   Edita_Vet(11,01,22,78,aCampo,aTitulo,aMascara, [XAPAGARU],,.t.)
   RestWindow(cTela)
   setcolor(cCor)
   Return
// **********************************************************************************************************
static function ImportaProposta(cNumPed)
   local nItens := 0,nQtd := 0

	ItemPed->(dbsetorder(1),dbseek(cNumPed))
	do while ItemPed->NumPed == cNumPed .and. ItemPed->(!eof())
		Produtos->(dbsetorder(1),dbseek(ItemPed->CodPro))
      
		aadd(aCodItem,ItemPed->CodItem)
		aadd(aDesPro ,left(Produtos->FanPro,40))
		aadd(aEmbPro ,Produtos->EmbPro)
		aadd(aQteEmb ,Produtos->QteEmb)
		aadd(aPcoVen ,ItemPed->PcoVen)
		aadd(aDscPro ,ItemPed->DscPro)
		aadd(aPcoLiq ,ItemPed->PcoLiq)
		aadd(aQtdPro ,ItemPed->QtdPro)
		aadd(aTotPro ,ItemPed->PcoVen*ItemPed->QtdPro)
        aadd(aDesconto,(ItemPed->PcoVen*ItemPed->QtdPro)-(ItemPed->PcoLiq*ItemPed->QtdPro))
        
		//aadd(aDesconto,0)
		// ** Parte para calcular os impostos
		aadd(aAliSai,0)
		aadd(aCst,space(03))
		aadd(aBaseIcms,0)
		aadd(aValorICMS,0)
		aadd(aIPI,0)
        // ** se controlar estoque
        if Produtos->CtrlEs == "S"
            if !(Produtos->QteAc01 == 0)
                if ItemPed->QtdPro > Produtos->QteAc01
				    nQtd := Produtos->QteAc01
                else
				    nQtd := ItemPed->QtdPro
                endif
            endif
        endif
        nItens += 1
		ItemPed->(dbskip())
	enddo
    MostrarSubTotal()
   if nItens == 0
      Mens({"Nao Existe Saldo Disponivel para o Pedido"})
      return(.f.)
   end
   return(.t.)
// **********************************************************************************************************   
static function AbrirArquivos
   
   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenCidades()
      FechaDados()
      Msg(.f.)
      return(.f.)
   endif
   if !OpenGrupos()
      FechaDados()
      Msg(.f.)
      return(.f.)
   endif
   if !OPenClientes()
      FechaDados()
      Msg(.f.)
      return(.f.)
   endif
   if !OpenVendedor()
      FechaDados()
      Msg(.f.)
      return(.f.)
   endif
   if !OpenProdutos()
      FechaDados()
      Msg(.f.)
      return(.f.)
   endif
   if !OpenSubGrupo()
      FechaDados()
      Msg(.f.)
      return(.f.)
   endif
   if !OpenNFCe()
      FechaDados()
      Msg(.f.)
      return(.f.)
   endif
   if !OpenNFCeItem()
      FechaDados()
      Msg(.f.)
      return(.f.)
   endif
   if !OpenNatureza()
      FechaDados()
      Msg(.f.)
      return(.f.)
   endif
   if !OpenSitTrib()
      FechaDados()
      Msg(.f.)
      return(.f.)
   endif
   if !OpenSequencia()
      FechaDados()
      Msg(.f.)
      return(.f.)
   endif
	if !OpenDupRec()
		FechaDados()
		Msg(.f.)
		return(.f.)
    endif
	if !(Abre_Dados(cDiretorio,"ibptax"+cEmpEstCid,1,1,"ibpt",1,.f.) == 0)
		FechaDados()
		Msg(.f.)
		return(.f.)
    endif
	if !(Abre_Dados(cDiretorio,"fpagtonfce",1,1,"FormaPagtoNFCE",1,.f.) == 0)
		FechaDados()
		Msg(.f.)
		return(.f.)
    endif
	if !(Abre_Dados(cDiretorio,"detpagtonfce",1,1,"DetPagtoNfce",1,.f.) == 0)
		FechaDados()
		Msg(.f.)
		return(.f.)
    endif
    if !OpenCredCartao()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
	if !OpenEmpresa()
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
   return(.t.)
// **********************************************************************************************************   
procedure TelaNFCe(nModo)
  local cTitulo, aTitulos := {"InclusÆo","Altera‡Æo","ExclusÆo","Impressao","Fechamento","Abertura","Visualiza‡Æo"},nI
     
   Window(02,00,33,100,"> "+aTitulos[nModo]+" de NFC-e <")
   setcolor(Cor(11))
   //           12345678901234567890123456789012345678901234567890123456789012345678901234567890
   //                    1         2         3         4         5         6         7         8
    @ 03,01 say "Controle:                           Proposta:           NFC-e:       /"
    @ 04,01 say " Cliente:"
    @ 05,01 say "   NatOp:"
    @ 06,01 say " Emissao:"
    @ 07,01 say replicate(chr(196),99)
   	@ 07,01 say " Produtos " color Cor(26)
   	@ 09,001 say replicate(chr(196),99)    
// 	@ 07,01 say "         1         2         3         4         5         6         7         8         9         0 "
//   @ 08,01 say "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                       1          2         3         4         5         6         7
/*
   	@ 09,005 say "Codigo"
   	@ 09,019 say "Descricao"
   	@ 09,060 say "Emb"
   	@ 09,065 say "Und."
   	@ 09,070 say "Pco.Unit"
   	@ 09,082 say "%Desc."
   	@ 09,089 say "Qtde."
   	@ 09,101 say "Pco.Liq."
   	@ 09,113 say "Total"
*/
    

	@ 29,01 say replicate(chr(196),99)
	@ 30,01 say "                                                                          Sub Total:"
	@ 31,01 say "                                                                           Desconto:"
	@ 32,01 say "                                                                              Total:"
// **********************************************************************************************************   
static procedure Recebimento(lModo)
	local cTela := SaveWindow(),GetList := {}
	local aCampo := {},aTitulo := {},aMascara := {}
	private aCodigoPagamento := {},aCredCartao := {}
	
	// ** Carrega as formas de pagamentos
	FormaPagtoNFCE->(dbgotop())
	do while FormaPagtoNFCE->(!eof())
		aadd(aCodigoPagamento,{FormaPagtoNFCE->CodPagto,FormaPagtoNFCE->DesPagto})
		FormaPagtoNFCE->(dbskip())
	enddo
	// ** Carrega as credenciadoras de cartão de crédito/débito
	CredCartao->(dbsetorder(3),dbgotop())
	do while CredCartao->(!eof())
		aadd(aCredCartao,{CredCartao->Codigo,CredCartao->Nome})
		CredCartao->(dbskip())
	enddo
	// **************************************************************
	// ****
    if lModo
	   aCodPagto       := {}  // ** Codigo de Pagamento
	   aDesPagto       := {}  // ** Descricao do Pagamento
	   aVlrPagto       := {}       // ** Valor do Pagamento
	   aCodiCredCartao := {} // ** Credenciadora do Cartao de Credido/Debito
	   aBandeiraCartao := {} // ** Bandeira da operadora de cartão de crédito e/ou débito
	   aAutorizaCartao := {} // ** Número de autorização da operação cartão de crédito e/ou débito
	
	   aadd(aCodPagto,space(02))
	   aadd(aDesPagto,space(20))
	   aadd(aVlrPagto,0.00)
	   aadd(aCodiCredCartao,space(02))	// ** Credenciadora do Cartao de Credido/Debito
	   aadd(aBandeiraCartao,space(02))	// ** Bandeira da operadora de cartão de crédito e/ou débito
	   aadd(aAutorizaCartao,space(20))	// ** Número de autorização da operação cartão de crédito e/ou débito
    endif
	
	aadd(aCampo,"aCodPagto")
	aadd(aCampo,"aDesPagto")
	aadd(aCampo,"aVlrPagto")
	aadd(aCampo,"aCodiCredCartao")
	aadd(aCampo,"aBandeiraCartao")
	aadd(aCampo,"aAutorizaCartao")
	
	aadd(aTitulo,"Codigo")
	aadd(aTitulo,"Descricao")
	aadd(aTitulo,"Valor")
	aadd(aTitulo,"Cred.")
	aadd(aTitulo,"Bandeira")
	aadd(aTitulo,"Autorizacao")
	
	aadd(aMascara,"@k 99")
	aadd(aMascara,"@!")
	aadd(aMascara,"@E 999,999.99")
	aadd(aMascara,"@e 99")
	aadd(aMascara,"@k 99")
	aadd(aMascara,"@!")
	Window(05,01,18,89,"> Forma de Pagamento < ")
	Rodape("Esc-Encerra | F2-Confirma | F6-Exclui | F8-Abandona")
	do while .t.
		Edita_Vet(06,02,17,88,aCampo,aTitulo,aMascara,[ItemPagto])
		if lastkey() == K_F8
			exit
		elseif lastkey() == K_F2
			if !Confirm("Confirma os Dados")
				loop
			endif
			exit
		endif
	enddo
	RestWindow(cTela)
	return
// **********************************************************************************************************
Function ItemPagto(Pos_H,Pos_V,Ln,Cl,Tecla)  
   Local MCampo, GetList := {},lNoGet := .f.

	If Tecla == K_ENTER
		If Pos_H = 1 
			MCampo := aCodPagto[Pos_V]
			// **@ Ln, Cl Get MCampo valid iif(empty(MCampo),MenuArray(@MCampo,aCredCartao),.t.) .and. Busca(@MCampo,"FormaPagtoNFCE",1,,,,{"Forma de pagamento nao cadastrada"},.f.,.f.,.f.)
			@ Ln, Cl Get MCampo valid iif(empty(MCampo),MenuArray(@MCampo,aCodigoPagamento),.t.) .and. Busca(@MCampo,"FormaPagtoNFCE",1,,,,{"Forma de pagamento nao cadastrada"},.f.,.f.,.f.)
			setcursor(SC_NORMAL)
			read
			setcursor(SC_NONE)
			if !(lastkey() == K_ESC)
				aCodPagto[Pos_V] := MCampo
				aDesPagto[Pos_V] := FormaPagtoNFCE->DesPagto
				keyboard replicate(chr(K_RIGHT),2)+chr(K_ENTER)
				Return( 3 )
			EndIf
		// ** Valor Pago
		elseif Pos_H == 3
			MCampo := aVlrPagto[Pos_V]
         	@ Ln, Cl Get MCampo Pict [@R 999,999.99] Valid NoEmpty( MCampo )  
         	setcursor(SC_NORMAL)
         	read
         	setcursor(SC_NONE)
         	if !(lastkey() == K_ESC)
         		aVlrPagto[Pos_V] := MCampo
         		if aCodPagto[Pos_V] $ "03|04"
         			keyboard chr(K_RIGHT)+chr(K_ENTER)
         		else
         			// ** Zera os dados de cartão, caso mude a forma de pagamento
         			aCodiCredCartao[Pos_V] := space(02)
         			aBandeiraCartao[Pos_V] := space(02)
         			aAutorizaCartao[Pos_V] := space(20)
         			AdicionaLinha(Pos_V) // ** Adiciona Linha na Tabela
         			keyboard chr(K_DOWN)+replicate(chr(K_LEFT),Pos_H-1)+chr(K_ENTER)
         		endif
         		return(3)
         	endif
         	
         // ** Código da Credenciadora do Cartao
         elseif Pos_H == 4 .and.  (aCodPagto[Pos_V] $ "03|04")
         	MCampo := aCodiCredCartao[Pos_V]
			@ Ln, Cl Get MCampo picture "@k 99" valid iif(empty(MCampo),MenuArray(@MCampo,aCredCartao),.t.) .and. Busca(Zera(@MCampo),"CredCartao",1,,,,{"Forma de Pagamento nao cadastrada"},.f.,.f.,.f.)
			setcursor(SC_NORMAL)
			read
			setcursor(SC_NONE)
			if !(lastkey() == K_ESC)
            	aCodiCredCartao[Pos_V] := MCampo
            	keyboard chr(K_RIGHT)+chr(K_ENTER)
            	return( 3 )
			endif
         	
         	
		// ** Bandeira do Cartão de Crédito/Débito
		ElseIf Pos_H == 5 .and.  (aCodPagto[Pos_V] $ "03|04")
         	MCampo := aBandeiraCartao[Pos_V]
         	@ Ln, Cl Get MCampo Pict "@k 99" Valid MenuArray(@MCampo,{{"01","Visa            "},{"02","MaterCard       "},{"03","American Express"},{"04","Sorocred        "},{"99","Outros          "}})
         	setcursor(SC_NORMAL)
         	read
         	setcursor(SC_NONE)
         	if !(lastkey() == K_ESC)
            	aBandeiraCartao[Pos_V] := MCampo
            	keyboard chr(K_RIGHT)+chr(K_ENTER)
            	return( 3 )
         	endif
         	
		//  ** Numero da autorização do cartão de crédito/débito
		elseif Pos_H == 6 .and.  (aCodPagto[Pos_V] $ "03|04")
         	MCampo := aAutorizaCartao[Pos_V]
         	@ Ln, Cl Get MCampo Pict "@k!" Valid NoEmpty( MCampo )  
         	setcursor(SC_NORMAL)
         	read
         	setcursor(SC_NONE)
         	if !(lastkey() == K_ESC)
            	aAutorizaCartao[Pos_V] := MCampo
         		AdicionaLinha(Pos_V) // ** Adiciona Linha na Tabela
         		keyboard chr(K_DOWN)+replicate(chr(K_LEFT),Pos_H-1)+chr(K_ENTER)
            	return( 3 )
         	endif
      	endif
      Return( 2 )
   ElseIf Tecla = K_F2
      Return( 0 )
	elseif Tecla == K_F8
		return(0)
   elseif Tecla == K_F11
      Calc()
   EndIf
   Return( 1 )
// **********************************************************************************************************		
static procedure AdicionaLinha(nPosicao)

	nItens := len(aCodPagto)+1
    asize(aCodPagto,nItens)
    asize(aDesPagto,nItens)
    asize(aVlrPagto,nItens)
    asize(aCodiCredCartao,nItens)
    asize(aBandeiraCartao,nItens)
    asize(aAutorizaCartao,nItens)
    
    ains(aCodPagto,nPosicao+1)
    ains(aDesPagto,nPosicao+1)
    ains(aVlrPagto,nPosicao+1)
    ains(aCodiCredCartao,nPosicao+1)
    ains(aBandeiraCartao,nPosicao+1)
    ains(aAutorizaCartao,nPosicao+1)
    
    aCodPagto[nPosicao+1] := space(02)
	aDesPagto[nPosicao+1] := space(20)
	aVlrPagto[nPosicao+1] := 0.00
	aCodiCredCartao[nPosicao+1] := space(14) // ** CNPJ da Credenciadora do Cartao de Credido/Debito
	aBandeiraCartao[nPosicao+1] := space(02) // ** Bandeira da operadora de cartão de crédito e/ou débito
	aAutorizaCartao[nPosicao+1]    := space(20) // ** Número de autorização da operação cartão de crédito e/ou débito
	return
// **********************************************************************************************************		
/*
	GravarFormaPgto
	Grava o detalhamento da forma de pagamento da NFCE
	
*/	
static procedure GravarFormaPagto(lModo)
	local nI
    
    if lModo // .t. inclui
        Msg(.t.)
        Msg("Aguarde: Gravando o pagamento")        
	    for nI := 1 to len(aCodPagto)
            if !empty(aCodPagto[nI])
                do while !DetPagtoNfce->(Adiciona())
                enddo
                DetPagtoNfce->Numcon := cNumCon
                DetPagtoNfce->CodPagto := aCodPagto[nI]
                DetPagtoNfce->VlrPagto := aVlrPagto[nI]
                DetPagtoNfce->codiCred := aCodiCredCartao[nI]
                DetPagtoNfce->Bandeira := aBandeiraCartao[nI] // ** Bandeira da operadora de cartão de crédito e/ou débito
                DetPagtoNfce->Autoriza := aAutorizaCartao[nI] // ** Número de autorização da operação cartão de crédito e/ou débito
                DetPagtoNfce->(dbcommit())
                DetPagtoNfce->(dbunlock())
            endif
        next
        Msg(.f.)
    else
        Msg(.t.)
        Msg("Aguarde: Excluindo Pagamento")
        DetPagtoNfce->(dbsetorder(1),dbseek(cNumCon))
        do while DetPagtoNfce->NumCon == cNumCon .and. DetPagtoNfce->(!eof())
            do while DetPagtoNfce->(!Trava_Reg()) 
            enddo
            DetPagtoNfce->(dbdelete())
            DetPagtoNfce->(dbcommit())
            DetPagtoNfce->(dbunlock())
            DetPagtoNfce->(dbskip())
        enddo
        Msg(.f.)
        GravarFormaPagto(.t.)
    endif
    return
// **********************************************************************************************************			
static procedure GravarItensNFCe(lModo) // Grava os itens da nfce
	local nI
	         
    if lModo // .t. incluir
        Msg(.t.)
        Msg("Aguarde: Gravando os Itens")
        For nI := 1 to len(aCodItem)
            if !empty(aCodItem[nI])
                do while !nfceitem->(Adiciona())
                enddo
                nfceitem->NumCon     := cNumCon
                nfceitem->CodCli     := cCodCli
                nfceitem->CodItem    := aCodItem[nI]
                nfceitem->codPro     := aCodPro[nI]
                nfceitem->QtdPro     := aQtdPro[nI]
                nfceitem->PcoVen     := aPcoVen[nI]
                nfceitem->DscPro     := aDscPro[nI] // ** desconto (%)
                nfceitem->PcoLiq     := aPcoLiq[nI] // ** preço líquido
                nfceitem->TotPro     := aTotPro[nI]
                //nfceitem->CodNat     := cCodNat
                nfceitem->AliSai     := aAliSai[nI]
                nfceitem->CodVen     := Clientes->CodVen
                nfceitem->DtaMov     := dDtaEmi
                nfceitem->CstSimples := aCst[nI]
                nfceitem->baseicms   := aBaseICms[nI]
                nfceitem->valoricms  := avaloricms[nI]
                nfceitem->ipi        := aipi[nI]
                nfceitem->desconto   := aDesconto[nI]
                nfceitem->(dbcommit())
                nfceitem->(dbunlock())
                
                Produtos->(dbsetorder(1),dbseek(aCodPro[nI]))
                do while !Produtos->(Trava_Reg())
                enddo
                if Produtos->CtrlEs == "S"
                    // Atualiza o estoque fiscal
                    Produtos->QteAC01 -= aQtdPro[nI]
                    if aQtdPro[nI] <= Produtos->QteAc02 
                        // Atualiza estoque fisico
                        Produtos->QteAc02 -= aQtdPro[nI]
                    endif
                endif
                Produtos->(dbcommit())
                Produtos->(dbunlock())
            endif
        Next
        Msg(.f.)
    else  // .f. alterrar
        Msg(.t.)
        Msg("Aguarde: Excluindo os itens")
        nfceitem->(dbsetorder(1),dbseek(cNumCon))
        do while nfceitem->NumCon == cNumCon .and. nfceitem->(!eof())
            do while nfceitem->(!Trava_Reg())
            enddo
            if Produtos->(dbsetorder(1),dbseek(nfceitem->CodPro))
                do while Produtos->(!Trava_Reg())
                enddo
                // ** se o produto controla o estoque
                if Produtos->CtrlEs == "S"
                    // ** atualiza o estoque fiscal
                    Produtos->QteAc01 += nfceitem->QtdPro
                    // Atualiza o estoque fisico
                    Produtos->QteAc02 += NfceItem->QtdPro
                endif
                Produtos->(dbcommit())
                Produtos->(dbunlock())
            endif
            nfceitem->(dbdelete())
            nfceitem->(dbunlock())
            nfceitem->(dbskip())
        enddo
        Msg(.f.)
        GravarItensNFCe(.t.)
    endif
    return
      
static procedure GravarNFce(lModo)

    if lModo  // .t. Incluir
	   do while !nfce->(Adiciona())
        enddo
	    nfce->NumCon  := cNumCon
        nfce->NumNot  := cNumNot
    else  //  .f. alterar
        do while nfce->(!Trava_Reg())
        enddo
    endif
	nfce->CodCli  := cCodCli
	nfce->CodVen  := Clientes->CodVen
	nfce->CodNat  := cCodNat
	nfce->DtaEmi  := dDtaEmi
	nfce->BasNor  := nBaseICMS
	nfce->ICMNor  := nValorICMS
	nfce->TotNot  := MTotNot
	nfce->TotPro  := nTotPro
	nfce->TipFre  := "9"       // ** Frete - 9 Sem frete
	nfce->DscNo1 := Soma_Veto2(aDesconto)        // **nDscNot
    nfce->Serie  := Sequencia->SerieNfce
    
	nfce->(dbcommit())
	nfce->(dbunlock())
	return
	
	
static procedure MontarNFCe(cCodNumerico)

	Natureza->(dbsetorder(1),dbseek(nfce->CodNat))
	
    // Identifica‡Æo
	cComando := ""
	cComando += "[infNFE]"                           +CRLF
	//cComando += "Versao=4.00"                        +CRLF
	cComando += "[Identificacao]"                    +CRLF
	cComando += 'NaturezaOperacao='+Natureza->Descricao +CRLF
	cComando += "Modelo=65"                          +CRLF
	cComando += "Serie="+Sequencia->SerieNfce+CRLF
	cComando += "nNF="+nfce->numnot+CRLF
    if !(cCodNumerico = NIL)
        cComando += "Codigo="+cCodNumerico+CRLF
    endif
	// ** Data Emissao
	cComando += "Emissao="+dtoc(nfce->DtaEmi)+" "+time()   + CRLF
	cComando += "indFinal="+Clientes->IndiFinal+CRLF
	cComando += "IndPres=1"+CRLF
	cComando += 'FormaPag=0'+CRLF // ** 0=Avista 1-Aprazo 2-Outros
	cComando += "tpAmb="+Sequencia->TipoAmbNfc+ CRLF // ** Identificação do Ambiente 1-Produçao 2-Homologação
	// ** Formato de impressão do danfe
	cComando += "tpImp=4"+CRLF
	
	// ** Dados do Emitente
	cComando += "[Emitente]"+CRLF
	cComando += 'CNPJ='        +Empresa->Cnpj+CRLF
	cComando += 'IE='          +Empresa->Ie  +CRLF
	cComando += 'Razao='       +Empresa->Razao +CRLF
    if !empty(Empresa->Fantasia)
        cComando += 'Fantasia='+Empresa->Fantasia+CRLF
    endif
	// **cComando += 'Fantasia='    +clNomLoj  +CRLF
	if !empty(Empresa->Telefone1)
		cComando += 'Fone='+Empresa->Telefone1+CRLF
	endif
	cComando += 'CEP='         +Empresa->Cep+CRLF
	cComando += 'Logradouro='  +Empresa->Endereco+CRLF
	cComando += 'Numero='      +Empresa->Numero+CRLF
	if !empty(Empresa->Complend)
		cComando += 'Complemento='+Empresa->Complend+CRLF
	endif
	cComando += 'Bairro='+Empresa->Bairro+CRLF
	Cidades->(dbsetorder(1),dbseek(Empresa->CodCid))
    
	cComando += 'CidadeCod='+Cidades->CodIbge +CRLF
	cComando += 'Cidade='+Cidades->NomCid+CRLF
	cComando += 'UF='+Cidades->EstCid+CRLF
	cComando += 'PaisCod=1058'+CRLF
	cComando += 'Pais=BRASIL'+CRLF
	cComando += 'Crt='+Empresa->Crt+CRLF
	
	
	// ** DESTINATµRIO
    if Clientes->TipCli == "F"
        if !(Clientes->CpfCli == "00000000000")
            cComando += '[Destinatario]'+CRLF
            cComando += 'CNPJCPF='+Clientes->CpfCli+CRLF
            cComando += 'xNome='+Clientes->NomCli+CRLF
            cComando += 'indIEDest='+Clientes->indIEDest+CRLF
        endif
        
    endif
	nBaseICMS  := 0
	nValorICMS := 0
	nValorDoTributos := 0.00
	nValorTotalDoTributos := 0.00

    // Produtos
	nfceitem->(dbsetorder(1),dbseek(nfce->NumCon))
	nContador := 1
	do while nfceitem->NumCon == nfce->NumCon .and. nfceitem->(!eof())
		Produtos->(dbsetorder(1),dbseek(nfceitem->CodPro))

		cQuantidade    := rtrim(alltrim(str(nfceitem->QtdPro,15,4)))
        
		//cValorUnitario := rtrim(alltrim(str(round(nfceitem->PcoLiq,2),12,2)))
        
		cValorTotal    := rtrim(alltrim(str(nfceitem->TotPro,12,2)))
		cValorDesconto := rtrim(alltrim(str(nfceitem->Desconto,15,2)))
        if nfceitem->desconto > 0
            cValorUnitario := rtrim(alltrim(str(round(nfceitem->PcoVen,2),12,2)))
        else
            cValorUnitario := rtrim(alltrim(str(round(nfceitem->PcoLiq,2),12,2)))
        endif
		
		// ** Calcula o valor total dos tributos
		/*
		if ibpt->(dbsetorder(1),dbseek(Produtos->CodNCM))
			nValorDoTributos := round(((nfeitem->TotPro * ibpt->aliqnac) / 100),2)
			nValorTotalDoTributos += nValorDoTributos
		endif
		*/
		Natureza->(dbsetorder(1),dbseek(Produtos->NatSaiDent))
		cComando += '[Produto'+strzero(nContador,3)+']'+CRLF
        if empty(Produtos->CodBar)
            cComando += 'cEAN=SEM GTIN'+CRLF
        else
            cComando += 'cEAN='+Produtos->Codbar+CRLF
        endif
		cComando += 'CFOP='+Natureza->Cfop+CRLF
		cComando += 'Codigo='       +nfceitem->CodPro        +CRLF
		cComando += 'NCM='+Produtos->CodNCM+CRLF

        // ** Se o ambiente for de homologacao        
        if Sequencia->TipoAmbNfc == "2"
            if nContador == 1
                cComando += 'Descricao='+'NOTA FISCAL EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL'+CRLF
            else
                cComando += 'Descricao='    +Produtos->DesPro        +CRLF
            endif
        else
            cComando += 'Descricao='    +Produtos->DesPro        +CRLF
        endif            
		cComando += 'Unidade='      +Produtos->EmbPro        +CRLF
		cComando += 'Quantidade='   +cQuantidade             +CRLF
		cComando += 'ValorUnitario='+cValorUnitario          +CRLF
		cComando += 'ValorTotal='   +cValorTotal             +CRLF
		cComando += 'vDesc='+cValorDesconto          +CRLF
		cComando += 'vTotTrib='+rtrim(alltrim(str(nValorDoTributos,12,2)))+CRLF
        
        if empty(Produtos->CodBar)
            cComando += 'cEANTrib=SEM GTIN'+CRLF
        else
            cComando += 'cEANTrib='+Produtos->CodBar+CRLF
        endif
        

		cBaseICMS  := rtrim(alltrim(str(nfceitem->baseicms,12,2)))
		cAliquota  := rtrim(alltrim(str(nfceitem->AliSai,5,2)))
      
		cValorICMS := rtrim(alltrim(str(nfceitem->ValorIcms,12,2)))

		nBaseICMS  += val(cBaseICMS)  //   nfeitem->baseicms
		nValorICMS += val(cValorICMS) //nfeitem->valoricms
		
		// **nTotalDesconto += nfeitem->Desconto

		cComando +='[ICMS'+strzero(nContador,3)+']'+CRLF
		cComando += 'CSOSN='+nfceitem->CstSimples+CRLF
		cComando +='ValorBase='+cBaseIcms+CRLF
		cComando +='Aliquota='+cAliquota+CRLF
		cComando +='Valor='+cValorICMS+CRLF
        
        if !empty(Produtos->Pis)
            cComando += '[PIS'+strzero(nContador,3)+']'+CRLF
            cComando += 'CST='+Produtos->Pis+CRLF
            cComando += 'ValorBase=0.00'+CRLF
            cComando += 'Aliquota=0.00'+CRLF
            cComando += 'Valor=0.00'+CRLF
        endif
        if !empty(Produtos->Cofins)
            cComando += '[COFINS'+strzero(nContador,3)+']'+CRLF
            cComando += 'CST='+Produtos->Pis+CRLF
            cComando += 'ValorBase=0.00'+CRLF
            cComando += 'Aliquota=0.00'+CRLF
            cComando += 'Valor=0.00'+CRLF
        endif
		nfceitem->(dbskip())
		nContador += 1
	enddo
	cBaseICMS  := rtrim(alltrim(str(nBaseICMS,12,2)))
	cValorICMS := rtrim(alltrim(str(nValorICMS,12,2)))

	cBasSub := rtrim(alltrim(str(nfce->BasSub,12,2)))
	cICMSub := rtrim(alltrim(str(nfce->ICMSub,12,2)))
	cTotPro := rtrim(alltrim(str(nfce->TotPro,12,2)))
	cTotNot := rtrim(alltrim(str(nfce->TotNot,12,2)))
	cTotalDesconto := rtrim(alltrim(str(nfce->dscno1,15,2)))

	cComando +='[Total]'+CRLF
	cComando += 'BaseICMS='             +cBaseICMS+CRLF
	cComando += 'ValorICMS='            +cValorICMS+CRLF
	cComando += 'ValorProduto='         +cTotPro+CRLF
	cComando += 'BaseICMSSubstituicao=' +cBasSub+CRLF
	cComando += 'ValorICMSSubstituicao='+cICMSub+CRLF
	cComando += 'ValorFrete=0.00'       +CRLF
	cComando += 'ValorSeguro=0.00'      +CRLF
	cComando += 'ValorDesconto='        +cTotalDesconto+CRLF
	cComando += 'ValorNota='            +cTotNot+CRLF
	
	// ** Detalhamento de Pagamento
	nContador := 1
	DetPagtoNfce->(dbsetorder(1),dbseek(nfce->NumCon))
	do while DetPagtoNfce->NumCon == nfce->NumCon .and. DetPagtoNfce->(!eof())
		cComando += "[Pag"+strzero(nContador,3)+"]"                         + CRLF
		cComando += "tPag="+DetPagtoNfce->CodPagto                          + CRLF
		cComando += "vPag="+rtrim(alltrim(str(DetPagtoNfce->VlrPagto,13,2)))+ CRLF
        // ** se for cartão de crédito/débito
        if DetPagtoNfce->CodPagto $ "03|04"
            CredCartao->(dbsetorder(1),dbseek(DetPagtoNfce->CodiCred))
            cComando += "[card]" + CRLF
            cComando += "CNPJ"+CredCartao->Cnpj+CRLF
            cComando += "tBand="+DetPagtoNfce->Bandeira+CRLF
            cComando += "cAut="+DetPagtoNfce->Autoriza+CRLF
        endif
		DetPagtoNfce->(dbskip())
	enddo
	
	// ** Dados do Transportador
	cComando += '[Transportador]'+CRLF
	cComando += 'FretePorConta=9' +CRLF
	
	cDadosAdicionais := ""
	if !empty(Sequencia->ObsNfce1)
		cDadosAdicionais += Sequencia->ObsNfce1
	endif
	if !empty(Sequencia->ObsNfce2)
        if !empty(Sequencia->ObsNfce1)
            cDadosAdicionais += ";"
        endif
      	cDadosAdicionais += Sequencia->ObsNfce2
   	endif
	if !empty(Sequencia->ObsNfce3)
        if !empty(Sequencia->ObsNfce2)
            cDadosAdicionais += ";"
        endif
      	cDadosAdicionais += Sequencia->ObsNfce3
	endif
	cComando +='[DadosAdicionais]'+CRLF
	cComando +='Complemento='+cDadosAdicionais+CRLF
	return
	

      
procedure MostrarErro(cCodigo,cMotivo)
	local cTela := SaveWindow()
	
	Window(09,00,14,79," Retorno ")
	setcolor(Cor(11))
	@ 11,01 say "Codigo: "+cCodigo
	@ 12,01 say "Motivo: "+cMotivo
	inkey(0)
	RestWindow(cTela)
	return

	
static procedure GetItemsPedidos
   
	aTitulo[1]  := "Codigo" 
	aTitulo[2]  := "Descricao"
	aTitulo[3]  := "Emb."
	aTitulo[4]  := "Und."
	aTitulo[5]  := "Pco.Unit"
	aTitulo[6]  := "%Desc."
	aTitulo[7]  := "Qtde."
	aTitulo[8]  := "Pco. Liq."
	aTitulo[9]  := "Total"
	
	// ***************************************************************************************************
	aCampo[1]   := "aCodItem"
	aCampo[2]   := "aDesPro"
	aCampo[3]   := "aEmbPro"
	aCampo[4]   := "aQteEmb"
	aCampo[5]   := "aPcoVen"
	aCampo[6]   := "aDscPro"  // ** Desconto do produto
	aCampo[7]   := "aQtdPro"
	aCampo[8]   := "aPcoLiq"
	aCampo[9]   := "aTotPro"
	// ***************************************************************************************************
	aMascara[1] := "@!"
	aMascara[2] := "@!"
	aMascara[3] := "@k" 
	aMascara[4] := "999"
	aMascara[5] := "@e 999,999.999"   // ** Valor Unitario
	aMascara[6] := "@k 999.99"       // ** Desconto
	aMascara[7] := "@ke 999,999.999" // ** Quantidade
	aMascara[8] := "@e 999,999.999"   // ** Valor Liquido
	aMascara[9] := "@e 9,999,999.99" // ** Valor total
	cTela2 := SaveWindow(18,01,18,129)
	@ 29,01 say " F2-Confirma | F4-Inclui | F6-Exclui | F8-Abandona " color Cor(26)
	Rodape("Esc-Encerra")
	setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
	// **keyboard chr(K_ENTER)
	do while .t.
		Edita_Vet(08,01,28,99,aCampo,aTitulo,aMascara,"nfceitem",,,,2)
		if lastkey() == K_F8
			exit
		elseif lastkey() == K_F2
			// Verifica se o cliente controle o limite
			if Clientes->Limite > 0
				nDebitos := VerDebitos(cCodCli)
				if (nDebitos+Soma_Vetor(aTotPro)) > Clientes->Limite
					if Aviso_1(17,, 22,, [Aten‡„o!], [O cliente est  sem limite de cr‚dito, continuar?], { [  ^Sim  ], [  ^N„o  ] }, 2, .t. ) = 1
						exit
					else
	               loop
	            Endif
	         endif
	      endif
	      if !Confirm("Confirma o(s) produto(s)")
	         loop
	      endif
	      exit
	   endif
	enddo
	return
//*********************************************************************************************    
static procedure IncCpfCliente(pcProg, pnLine, pcVar) 
    local cTela := SaveWindow()
    
    if !(pcVar = "CCODCLI")
        return
    endif
    Window(05,05,11,77)
    setcolor(Cor(11))
    @ 07,07 say "   CPF:"
    @ 08,07 say "  Nome:"
    @ 09,07 say "Cidade:"
    inkey(0)
    RestWindow(cTela)
    return


	
procedure VerItemNFce(cNumLanc)
   Local cCor := setcolor(),cTela := SaveWindow()
   local aCampo  := {},aTitulo := {},aMascara := {},nContador := 1
   private aVetor1 := {},aVetor2 := {},aVetor3 := {},aVetor4 := {},aVetor5 := {}
   private aVetor6 := {},aVetor7 := {},aVetor8 := {},aVetor9 := {},aVetor10 := {}

    if !NfceItem->(dbsetorder(1),dbseek(cNumLanc))
        Mens({"Problema nos iten(s) da NFC-e"})
        return
    endif
    do while NfceItem->NumCon == cNumLanc .and. NfceItem->(!eof())
        Produtos->(dbsetorder(1),dbseek(NfceItem->CodPro))
        aadd(aVetor1,nContador)
        aadd(aVetor2,NfceItem->CodItem)
        aadd(aVetor3,Produtos->FanPro)
        aadd(aVetor8,NfceItem->QtdPro)
        aadd(aVetor9,NfceItem->PcoLiq)   
        aadd(aVetor10,NfceItem->TotPro)
        
        NfceItem->(dbskip())
        nContador += 1
    enddo
    aadd(aTitulo,"Nr.Item")
    aadd(aTitulo," C¢digo")
    aadd(aTitulo,"Descri‡Æo")
    aadd(aTitulo,"Quantidade")
    aadd(aTitulo,"Pco.Liq")
    aadd(aTitulo,"Valor total")
    
    
    aadd(aCampo,"aVetor1")
    aadd(aCampo,"aVetor2")
    aadd(aCampo,"aVetor3")
    aadd(aCampo,"aVetor8")
    aadd(aCampo,"aVetor9")
    aadd(aCampo,"aVetor10")
    
    
    
    aadd(aMascara,"999")
    aadd(aMascara,"@!")
    aadd(aMascara,"@!")
    aadd(aMascara,"@e ")
    aadd(aMascara,"@e 999,999.999")
    aadd(aMascara,"@e 999,999.999")
    aadd(aMascara,"@e 9,999,999.99")
    
    cTela := SaveWindow()
    Rodape("Esc-Encerra")
    Window(10,00,23,115,"> Itens da NFC-e <")
    Edita_Vet(11,01,22,114,aCampo,aTitulo,aMascara, [XAPAGARU],,.t.,,2)
    RestWindow(cTela)
    setcolor(cCor)
    Return
	
procedure StatusServicoNFCe
	local lInternet,cRetorno,cCStat,cXMotivo

	Msg(.t.)
	Msg("Aguarde : Abrindo o Arquivo")
	if !OpenSequencia()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
	Msg(.f.)
	if Sequencia->TestarInte == "S"
		lInternet := Testa_Internet()
         if !lInternet
            FechaDados()
            return
         endif
	endif
    if !Status_NFeNFCe(Sequencia->DirNfe)
        FechaDados()
        return
    endif
    cCStat := RetornoSEFAZ("CStat",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
	cXMotivo := RetornoSEFAZ("XMotivo",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
	MostrarErro(cCStat,cXMotivo)	
	FechaDados()
	return
	
// ** Fim do Arquivo.
