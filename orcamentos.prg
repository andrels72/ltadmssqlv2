/*************************************************************************
         Sistema: Administrativo
          Vers’o: 3.00
   IdentificaÎ’o: Manutencao de Pedidos
         Prefixo: LtAdm
        Programa: Pedidos.PRG
           Autor: Andre Lucas Souza
            Data: 31 de Agosto de 2003
   Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

#define CRLF chr(K_ENTER)+chr(K_CTRL_ENTER)

procedure ConOrcamentos(lAbrir)
    local oBrow,nTecla,lFim := .F.,cTela := savewindow(),cDados
    local nCursor := setcursor(),cCor := setcolor()
    local nLinha1,nColuna1,nLinha2,nColuna2

	if lAbrir
		if !AbrirArquivos()
			return
		endif
	else
		setcursor(SC_NONE)
	endif
    select Orcamentos
    set order to 1
    dbgobottom()
    Rodape(iif(lAbrir,"Esc-Encerra","Esc-Encerra | ENTER-Transfere"))
    nLinha1  := 02
    nColuna1 := 00
    nLinha2  := 33  // 23
    nColuna2 := 86
    setcolor(cor(5))
    Window(nLinha1,nColuna1,nLinha2,nColuna2,"> Consulta de Proposta <")
    oBrow := TBrowseDB(nLinha1+1,nColuna1+1,nLinha2-2,nColuna2-1)
    oBrow:headSep := SEPH
    oBrow:footSep := SEPB
    oBrow:colSep  := SEPV
    oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)   
    oBrow:addcolumn(tbcolumnnew("Proposta"     ,{|| Orcamentos->Id }))
    oBrow:addcolumn(tbcolumnnew("Data"         ,{|| Orcamentos->Data }))
    oBrow:addcolumn(tbcolumnnew("Cliente"         ,{|| ;
   		Clientes->(dbsetorder(1),dbseek(Orcamentos->CodCli),Orcamentos->CodCli+'-'+Clientes->ApeCli)}))
    oBrow:addcolumn(tbcolumnnew("Total"        ,{|| transform(Orcamentos->Total,"@e 999,999.99")}))
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
      if ( oBrow:stable )
         if ( oBrow:hitTop .OR. oBrow:hitBottom )
            tone(1200,1)
         endif
        aRect := { oBrow:rowPos,1,oBrow:rowPos,4}
        oBrow:colorRect(aRect,{2,2})               
         
         nTecla := INKEY(0)
      endif
      if !TBMoveCursor(nTecla,oBrow)
         if nTecla == K_ESC
            lFim := .t.
         elseif nTecla == K_ENTER
            if !lAbrir
               cDados := Orcamentos->Id
               keyboard (cDados)+chr(K_ENTER)
               lFim := .t.
            endif
         elseif nTecla == K_F3
            VerItemOrcamentos(Orcamentos->Id)
         endif
      endif
      oBrow:refreshcurrent()
   enddo
   if !lAbrir
      setcursor(nCursor)
      setcolor(cCor)
   else
      FechaDados()
   endif
   RestWindow( cTela )
   RETURN
// ****************************************************************************
procedure IncOrcamentos
   local getlist := {},cTela := SaveWindow(),cTela2
   local lLimpa := .t.,nDebitos,nI
	// ** Itens do Pedido
	private aCodItem  := {} // ** Codigo do item ou cod. de barras
    private aCodPro   := {} 
	private aDesPro  := {}
	private aQtdPro  := {}
	private aPcoVen  := {}
	private aEmbPro  := {}
	private aQteEmb  := {}
	private aDscPro  := {}  // ** Desconto do produto
	private aPcoLiq  := {}  // ** Valor Liquido de venda
    private aValDesc := {}  // ** Valor do Desconto por Item
    private aSubTotal := {}
    private aValDescTotal := {} // ** Valor do desconto total
    private aPcoCus := {} // pre‡o de custo
    
    
	private aTitulo := array(7),aCampo := array(7),aMascara := array(7)
	private aTotPro  := {}
	private aVencmto := {}
	private aParcela := {}
	private lIncluir := .f.,nPerDesc,nValDesc,nTotal,nEntrada,cTipoCobra
	private cCodCli,cCodPla,cCodPla2,nEntrada2,nTotal2,dData,nSubTotal
    private cNumPed,lIncluirPedido,cCodVen,cCodProd2,lAbandonar
    private nModoPedido := 1

	if !AbrirArquivos()
		return
	endif
    DesativaF9()
    AtivaF4()
    TelOrcamentos(1)
	do while .t.
		if lLimpa
			cNumPed    := space(09)
			cCodCli    := space(04)  // Local
			dData      := date()     // Local
			nTotal     := 0          // Private
			cCodVen    := space(02)  // Local
			cCodPla    := space(02)  // Local
			nValDesc   := 0          // Private
			nPerDesc   := 0          // Private
			lIncluir   := .t.        // Private
			nTotal     := 0          // Private
			nEntrada   := 0          // Private
			nSubTotal  := 0
			cObs       := space(50)  // Local
			cTipoCobra := space(01)
			// ** Variaveis dos Itens do Pedido
			aCodItem  := {} // ** codigo do item do produto
            aCodPro  := {}
			aDesPro  := {} // ** Descricao do produto
			aEmbPro  := {} // ** Embalagem do produto
			aQteEmb  := {} // ** Unidade na embalage,
			aPcoVen  := {} // ** Preco de venda bruto
			aDscPro  := {} // ** Percentual de desconto por item
			aPcoLiq  := {} // ** Preco liquido com desconto
			aQtdPro  := {} // ** Quantidade			
			aTotPro  := {}
            aValDesc := {} // ** Valor do desconto por item
            aSubTotal := {} // ** Sub-Total do item
            aValDescTotal := {} // ** Valor do desconto total
            aPcoCus := {} // pre‡o de custo
            
			aadd(aCodItem,space(14))
            aadd(aCodPro,space(06))
			aadd(aDesPro,space(30))
			aadd(aEmbPro,space(04))
			aadd(aQteEmb,0)
			aadd(aPcoVen,0)
			aadd(aDscPro,0)
			aadd(aPcoLiq,0)
			aadd(aQtdPro,0)
			aadd(aTotPro,0)
            aadd(aValDesc,0) // ** Valor do desconto por item
            aadd(aSubTotal,0)  // ** Sub-Total do item
            aadd(aValDescTotal,0) // ** Valor do desconto total
            aadd(aPcoCus,0) // pre‡o de custo
        	 // ** Variaveis das datas de vencimento e valores das duplicatas
         	aVencmto := {}
         	aParcela := {}
            lIncluirPedido := .t.
            cCodProd2 := space(14)
            lAbandonar := .f.
         	lLimpa := .f.
      	endif
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        if (Sequencia->IdOrca+1) > 999999999
            Mens({"Limite de Proposta Esgotado"})
            exit
        endif
        //cNumPed := strzero(Sequencia->NumPed+1,09)
        @ 04,12 say cNumPed picture "@k 999999999"
        @ 04,31 get dData   picture "@k"  valid NoEmpty(dData)
        @ 05,12 get cCodCli picture "@k 99999";
      			when Rodape("Esc-Encerra | F4-Clientes");
      			valid iif(lastkey() == K_UP,.t.,vCliente(@cCodCli))
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        cCodVen := Clientes->CodVen
        Vendedor->(dbsetorder(1),dbseek(cCodVen))
        @ 04,58 say Vendedor->Nome
        @ 04,55 get cCodVen picture "@k 99" when Rodape("Esc-Encerra | F4-Vendedores") valid Busca(Zera(@cCodVen),"Vendedor",1,04,57,"'-'+Vendedor->Nome",{"Vendedor N’o Cadastrado"},.f.,.f.,.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            loop
        endif
        GetItemsOrcamentos()
        if lAbandonar
            Msg(.t.)
            Msg("Aguarde: Cancelando proposta")
            if Orcamentos->(dbsetorder(1),dbseek(cNumPed))
                do while Orcamentos->(!Trava_Reg()) 
                enddo
                ItemOrcamentos->(dbsetorder(1),dbseek(cNumPed))
                do while ItemOrcamentos->id == cNumPed .and. ItemOrcamentos->(!eof())
                    do while ItemOrcamentos->(!Trava_Reg())
                    enddo
                    ItemOrcamentos->(dbdelete())
                    ItemOrcamentos->(dbcommit())
                    ItemOrcamentos->(dbunlock())
                    ItemOrcamentos->(dbskip())
                enddo
                Orcamentos->(dbdelete())
                Orcamentos->(dbcommit())
                Orcamentos->(dbunlock())
            endif
            Msg(.f.)
            loop
        endif
        nTotal    := Soma_Vetor(aTotPro)
        nSubTotal := Soma_Vetor(aSubTotal)
        GetOrcamentos()
        if Orcamentos->(dbsetorder(1),dbseek(cNumPed))
            do while Orcamentos->(!Trava_Reg())
            enddo
            Orcamentos->ValDesc     := Soma_Vetor(aValDescTotal) // ** Valor total do desconto
            //Orcamentos->PerDesc     := nPerDesc
            Orcamentos->SubTotal    := nSubTotal
            Orcamentos->Total       := nTotal
            Orcamentos->Entrada     := nEntrada
            Orcamentos->CodPla      := cCodPla
            Orcamentos->Obs  := cObs
            Orcamentos->TipoCobra := cTipoCobra
            Orcamentos->CP_Ven := Vendedor->CP_Ven
            Orcamentos->CV_Ven := Vendedor->CV_Ven
            Orcamentos->FatCom := Plano->FatCom
            Orcamentos->Finalizado := .t.
            Orcamentos->(dbcommit())
            Orcamentos->(dbunlock())
        endif
        @ 04,12 say cNumPed picture "@k 999999999"
		Grava_Log(cDiretorio,"Proposta|Incluir|Pedido "+cNumPed,Orcamentos->(recno()))
		lLimpa := .t.
        if Aviso_1( 27,,32,,"Atencao!","Imprimir Or‡amento ?",{ [  ^Sim  ], [  ^Nao  ] }, 1, .t. ) = 1
            IOrcamentos(cNumPed)
        endif
   enddo
    DesativaF4()
    if PwNivel == "0"
        AtivaF9()
    endif
    FechaDados()
    RestWindow(cTela)
    return
// ****************************************************************************
procedure AltOrcamentos
   local getlist := {},cTela := SaveWindow(),cTela2
   local lLimpa := .t.,nDebitos
   
	// ** Dados do itens do pedido   
   	private aCodItem  := {}
    private aCodPro  := {}
	private aDesPro  := {}
	private aQtdPro  := {}
	private aPcoVen  := {}
	private aEmbPro  := {}
	private aQteEmb  := {}
	private aDscPro  := {}  // ** Desconto do produto
	private aPcoLiq  := {}  // ** Valor Liquido de venda
	private aTotPro  := {}
    private aValDesc := {}  // ** Valor do Desconto por Item
    private aSubTotal := {}
    private aValDescTotal := {} // ** Valor do desconto total
    private aPcoCus := {} // pre‡o de custo
    
	// ** Cabe‡alho do pedido
	private aTitulo := array(7),aCampo := array(7),aMascara := array(7)	
    // ** Dados da duplicatas 
    private aVencmto := {},aParcela := {}
    private lIncluir := .f.,nPerDesc,nValDesc,nTotal,nEntrada,cTipoCobra
    private cLanCxa,cCodCli,cCodPla,cCodPla2,nEntrada2,nTotal2,dData,nSubTotal
    private cNumPed,lIncluirPedido,cCodVen,cCodProd2,lAbandonar
    private nModoPedido := 2   
   
	if !AbrirArquivos()
		return
	endif
   DesativaF9()
   AtivaF4()
   TelOrcamentos(2)
    while .t.
        lIncluirPedido := .f.
        lAbandorar := .f.
    
      cNumPed := space(09)  // Local
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 04,12 get cNumPed picture "@k 999999999";
      			valid Busca(Zera(@cNumPed),"Orcamentos",1,,,,{"Numero Nao Cadastrado"},.f.,.f.,.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        dData   := Orcamentos->Data
        cCodCli := Orcamentos->CodCli
        cCodVen := Orcamentos->CodVen
        Vendedor->(dbsetorder(1),dbseek(cCodVen))
        @ 29,67 say Orcamentos->SubTotal picture "@e 999,999.99"
        @ 30,67 say Orcamentos->ValDesc picture "@e 999,999.99"
        @ 31,67 say Orcamentos->Total picture "@e 999,999.99"
                      
        @ 04,31 get dData   picture "@k"  valid NoEmpty(dData)
        @ 05,12 get cCodCli picture "@k 99999" when Rodape("Esc-Encerra | F4-Clientes") valid iif(lastkey() == K_UP,.t.,vCliente(@cCodCli))
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        @ 04,55 say cCodVen picture "@k 99"
        @ 04,58 say Vendedor->Nome
        @ 04,55 get cCodVen picture "@k 99" when Rodape("Esc-Encerra | F4-Vendedores") valid Busca(Zera(@cCodVen),"Vendedor",1,04,57,"'-'+Vendedor->Nome",{"Vendedor N’o Cadastrado"},.f.,.f.,.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            loop
        endif
        nValDesc   := Orcamentos->ValDesc
        nSubTotal  := Orcamentos->SubTotal
        nTotal     := Orcamentos->Total
        nEntrada   := Orcamentos->Entrada
        cCodPla    := Orcamentos->CodPla
        cObs       := Orcamentos->Obs
        cTipoCobra := Orcamentos->TipoCobra
        // ** Controle
        nEntrada2  := Orcamentos->Entrada
        cCodPla2   := Orcamentos->CodPla
        nTotal2    := Orcamentos->Total
      
		aCodItem  := {}
        aCodPro  := {}
		aDesPro  := {}
		aEmbPro  := {}
		aQteEmb  := {}
		aPcoVen  := {}		
		aQtdPro  := {}
		aDscPro  := {}  // ** Desconto do produto
		aPcoLiq  := {}  // ** Valor Liquido de venda
		aTotPro  := {}
        aValDesc := {}  // ** Valor do Desconto por Item
        aSubTotal := {}
        aPcoCus := {} // pre‡o de custo
        
      	// ** Pega os Items do Pedido
      	ItemOrcamentos->(dbsetorder(1),dbseek(cNumPed))
      	do while ItemOrcamentos->Id == cNumPed .and. ItemOrcamentos->(!eof())
         	Produtos->(dbsetorder(1),dbseek(alltrim(ItemOrcamentos->CodPro)))
         	aadd(aCodItem, ItemOrcamentos->CodItem)
            aadd(aCodPro,ItemOrcamentos->CodPro)
         	aadd(aDesPro,left(Produtos->FanPro,30))
         	aadd(aEmbPro,Produtos->EmbPro)
         	aadd(aQteEmb,Produtos->QteEmb)
         	aadd(aPcoVen, ItemOrcamentos->PcoVen) // ** pre‡o de venda
         	aadd(aDscPro, ItemOrcamentos->DscPro) // ** % de desconto
         	aadd(aQtdPro, ItemOrcamentos->QtdPro)
         	aadd(aPcoLiq, ItemOrcamentos->PcoLiq)
         	aadd(aTotPro, ItemOrcamentos->PcoLiq*ItemOrcamentos->QtdPro)
            aadd(aValDesc,ItemOrcamentos->ValDesc)
            aadd(aSubTotal,ItemOrcamentos->PcoVen*ItemOrcamentos->QtdPro)
            aadd(aValDescTotal,ItemOrcamentos->ValDesc*ItemOrcamentos->QtdPro) // ** Valor do desconto total
            aadd(aPcoCus,ItemOrcamentos->Custo) // pre‡o de custo
         	ItemOrcamentos->(dbskip())
      	enddo
      	nSubTotal := Soma_Vetor(aSubTotal)
      	nTotal    := Soma_Vetor(aTotPro)
        nValDesc  := Soma_Vetor(aValDescTotal) // valor do desconto total dos itens
        @ 29,67 say nSubTotal picture "@e 999,999.99"
        @ 30,67 say nValDesc picture "@e 999,999.99"
        @ 31,67 say nTotal picture "@e 999,999.99"
        
        cTela2 := SaveWindow()
        GetItemsOrcamentos()
      	nSubTotal := Soma_Vetor(aSubTotal)
      	nTotal    := Soma_Vetor(aTotPro)
        nValDesc  := Soma_Vetor(aValDescTotal) // valor do desconto total dos itens
		GetOrcamentos()
      	nTotal := nTotal - nEntrada
      	@ 31,67 say nTotal picture "@e 999,999.99"
        do while !Orcamentos->(Trava_Reg())
        enddo
        Orcamentos->Id   := cNumPed
        Orcamentos->CodCli    := cCodCli
        Orcamentos->Data      := dData
        Orcamentos->CodVen    := cCodVen
        Orcamentos->ValDesc   := nValDesc
        Orcamentos->SubTotal  := nSubTotal
        Orcamentos->Total     := nTotal
        Orcamentos->Entrada   := nEntrada
        Orcamentos->CodPla    := cCodPla
        Orcamentos->Obs       := cObs
        Orcamentos->TipoCobra := cTipoCobra
        Orcamentos->(dbcommit())
        Orcamentos->(dbunlock())
        Grava_Log(cDiretorio,"Orcamentos|Alterar|Orcamento "+cNumPed,Orcamentos->(recno()))
        lLimpa := .t.
        IOrcamentos(cNumPed)
    enddo
    DesativaF4()
    
    if PwNivel == "0"
        AtivaF9()
    endif
    
    FechaDados()
    RestWindow(cTela)
    return
// ****************************************************************************
procedure ExcOrcamentos
   local getlist := {},cTela := SaveWindow(),cTela2
   local cNumPed
   
	if !AbrirArquivos()
		return
	endif
    DesativaF9()
    AtivaF4()
    Window(12,00,19,76," Excluir Or‡amentos ")
	setcolor(Cor(11))
	// **        123456789012345
	@ 14,01 say " Numero:"
	@ 15,01 say "   Data:"
	@ 16,01 say "Cliente:"
	@ 17,01 say "  Valor:"
	do while .t.
      	cNumPed := space(09)
      	setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      	@ 14,10 get cNumPed picture "@k 999999999";
      			when Rodape("Esc-Encerra");
      			valid Busca(Zera(@cNumPed),"Orcamentos",1,,,,{"Numero Ja Cadastrado"},.f.,.f.,.f.)
      	setcursor(SC_NORMAL)
      	read
      	setcursor(SC_NONE)
      	if lastkey() == K_ESC
        	exit
      	endif
      	Clientes->(dbsetorder(1),dbseek(Orcamentos->CodCli))
      	@ 15,10 say Orcamentos->Data
      	@ 16,10 say Orcamentos->CodCli+"-"+Clientes->NomCli
      	@ 17,10 say Orcamentos->Total picture "@e 999,999,999.99"
      	if !Confirm("Confirma a Exclusao",2)
        	loop
      	endif
      	Msg(.t.)
      	Msg("Aguarde: Excluindo o or‡amento")
      	do while !Orcamentos->(Trava_Reg())
      	enddo
        Msg(.t.)
        Msg("Aguarde: Excluindo os Itens")
        if ItemOrcamentos->(dbsetorder(1),dbseek(cNumPed))
            do while ItemOrcamentos->Id == cNumPed .and. ItemOrcamentos->(!eof())
                do while !ItemOrcamentos->(Trava_Reg())
                enddo
                ItemOrcamentos->(dbdelete())
                ItemOrcamentos->(dbcommit())
                ItemOrcamentos->(dbunlock())
                ItemOrcamentos->(dbskip())
            enddo
         endif
        Orcamentos->(dbdelete())
      	Orcamentos->(dbcommit())
      	Orcamentos->(dbunlock())
      	Grava_Log(cDiretorio,"Orcamentos|Excluir|Orcamentoo "+cNumPed,Orcamentos->(recno()))
      	Msg(.f.)
   	enddo
   	DesativaF4()
   	if PwNivel == "0"
		AtivaF9()
	end
	FechaDados()
	RestWindow(cTela)
	return
// ****************************************************************************
procedure ImpOrcamentos
   local getlist := {},cTela := SaveWindow(),cTela2
   local cNumPed
   
	if !AbrirArquivos()
		return
	endif
   AtivaF4()
   Window(12,00,19,60," Imprimir Or‡amentos ")
   setcolor(Cor(11))
	@ 14,01 say " Numero:"
	@ 15,01 say "   Data:"
	@ 16,01 say "Cliente:"
	@ 17,01 say "  Valor:"
   do while .t.
      cNumPed := space(09)  // Local
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 14,10 get cNumPed picture "@k 999999999";
      		when Rodape("Esc-Encerra | F4-Orcamentos");
      		valid Busca(Zera(@cNumPed),"Orcamentos",1,,,,{"Numero Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      Clientes->(dbsetorder(1),dbseek(Orcamentos->CodCli))
      @ 15,10 say Orcamentos->Data
      @ 16,10 say Orcamentos->CodCli+"-"+Clientes->ApeCli
      @ 17,10 say Orcamentos->Total picture "@e 999,999,999.99"
      if !Confirm("Confirma as Informacoes")
         loop
      endif
      IOrcamentos(cNumPed)
   enddo
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
procedure VerOrcamentos
   local cTela := SaveWindow()

   TelPedido(7)
   @ 04,12 say Orcamentos->NumPed
   MosPedidos(Orcamentos->NumPed)
   Rodape(space(20)+"Pressione Qualquer Tecla para Continuar")
   Inkey(0)
   RestWindow(cTela)
   return
// ****************************************************************************
procedure MosOrcamentos(cNumPed)
   local nLinha,aLixo := {"Dinheiro        ","Duplicata       ","Cheque          ","Nota Promissoria","Nota de Debito  "}

   Vendedor->(dbsetorder(1),dbseek(Orcamentos->CodVen))
   Clientes->(dbsetorder(1),dbseek(Orcamentos->CodCli))
   Cidades->(dbsetorder(1),dbseek(Clientes->CodCid))
   Plano->(dbsetorder(1),dbseek(Orcamentos->CodPla))

   @ 04,31 say Orcamentos->Data picture "@k"
   @ 04,55 say Orcamentos->CodVen picture "@k 99"
   @ 04,58 say Vendedor->Nome
   @ 05,12 say Orcamentos->CodCli picture "@k 99999"
   @ 05,18 say Clientes->NomCli
   @ 06,12 say Clientes->EndCli
   @ 07,12 say left(Clientes->BaiCli,20)
   @ 07,44 say left(Cidades->NomCid,20)
   @ 07,75 say Cidades->EstCid
   ItemOrcamentos->(dbsetorder(1),dbseek(cNumPed))
   nLinha := 11
   scroll(11,03,17,08,0)
   scroll(11,10,17,44,0)
   scroll(11,46,17,52,0)
   scroll(11,54,17,63,0)
   scroll(11,65,17,78,0)
   while ItemOrcamentos->NumPed == cNumPed .and. ItemOrcamentos->(!eof())
      Produtos->(dbsetorder(1),dbseek(ItemOrcamentos->CodPro))
      @ nLinha,03 say ItemOrcamentos->CodPro
      @ nLinha,10 say left(Produtos->DesPro,20)+" -> "+Produtos->EmbPro+" x "+str(Produtos->QteEmb,3)
      @ nLinha,46 say ItemOrcamentos->QtdPro picture "@e 999,999"
      @ nLinha,54 say ItemOrcamentos->PcoVen picture "@e 99,999.999"
      @ nLinha,65 say ItemOrcamentos->PcoVen*ItemOrcamentos->QtdPro picture "@e 99,999,999.99"
      ItemOrcamentos->(dbskip())
      nLinha += 1
      if nLinha >= 18
         exit
      end
   end
   @ 19,02 say [Desconto($):]
   @ 19,15 say space(10)
   @ 19,15 say Orcamentos->ValDesc picture [@e 99,999.99]
   @ 20,67 say space(10)
   @ 20,67 say Orcamentos->ValDesc picture "@e 999,999.99"
   if Orcamentos->PerDesc > 0
      @ 19,02 say [Desconto(%):]
      @ 19,15 say space(10)
      @ 19,15 say Orcamentos->PerDesc picture [99.99]
      @ 20,67 say space(10)
      @ 20,67 say Orcamentos->SubTotal*(Orcamentos->PerDesc/100) picture "@e 999,999.99"
   end
   @ 19,67 say Orcamentos->SubTotal picture "@e 999,999.99"
   @ 21,67 say Orcamentos->Total    picture "@e 999,999.99"
   @ 20,15 say Orcamentos->CodPla   picture "@k 99"
   @ 20,18 say Plano->DesPla
   @ 19,41 say Orcamentos->Entrada picture "@ke 999,999.99"
   @ 21,15 say Orcamentos->TipoCobra
   @ 21,17 say aLixo[val(Orcamentos->TipoCobra)]
   @ 22,15 say Orcamentos->Obs picture "@k!"
   return
// ****************************************************************************
procedure TelOrcamentos( nModo )
   local cTitulo, aTitulos := {"InclusÆo","Altera‡Æo","ExclusÆo","Impressao","Fechamento","Abertura","VisualizaÎ’o"},nI

	Window(02,00,33,100,"> "+aTitulos[nModo]+" de Orcamentos <")
	setcolor(Cor(11))
	//           234567890123456789012345678901234567890123456789012345678901234567890123456789
	//                   1         2         3         4         5         6         7
	@ 04,02 say "  Numero:              Data:               Vendedor:"
	@ 05,02 say " Cliente:"
	@ 06,02 say "Endereco:"
	@ 07,02 say "  Bairro:                         Cidade:                            UF:"
   @ 08,01 say replicate(chr(196),99)
   @ 08,01 say " Itens do Orcamentos " color Cor(26)
// @ 07,01 say "         1         2         3         4         5         6         7         8         9         0         1"
//   @ 08,01 say "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
//                       1          2         3         4         5         6         7
   @ 28,01 say replicate(chr(196),99)
   @ 29,02 Say "Desconto($):                  Entrada:                Sub-Total:"
   @ 30,02 Say "      Plano:                                           Desconto:"
   @ 31,02 say " Tipo Pagto:                                              Total:"
   @ 32,02 Say "        OBS:"
   return
// ****************************************************************************
static function vCliente(cCodCli)
   local cNomCli := space(40),lAtraso := .f.,lRetorno,nDebitos := 0

   if !Busca(Zera(@cCodCli),"Clientes",1,row(),col(),"'-'+Clientes->ApeCli",{"Cliente Nao Cadastrado"},.f.,.f.,.f.)
      return(.f.)
   endif

   Cidades->(dbsetorder(1),dbseek(Clientes->CodCid))
   @ 06,12 say Clientes->EndCli
   @ 07,12 say left(Clientes->BaiCli,20)
   @ 07,44 say left(Cidades->NomCid,20)
   @ 07,75 say Cidades->EstCid
   if Clientes->BloCli == "S"
      Mens({"Cliente Bloqueado","Favor Verificar"})
      return(.f.)
   end
   // ** Verifica se o clientes esta em atraso
   if DupRec->(dbsetorder(1),dbseek(cCodCli))
      do while DupRec->CodCli == cCodCli .and. DupRec->(!eof())
         if empty(DupRec->DtaPag) .and. DupRec->DtaVen <= date()
            lAtraso := .t.
            exit
         endif
         DupRec->(dbskip())
      enddo
      if lAtraso
         If Aviso_1(17,, 22,, [AtenÎ"o!], [O cliente estÿ em atrazo, continuar?], { [  ^Sim  ], [  ^N"o  ] }, 2, .t. ) = 1
            Return( .t. )
         Else
            Return( .f. )
         Endif
      endif
   endif
   if Clientes->Limite > 0
      nDebitos := VerDebitos(cCodCli)
      if nDebitos > Clientes->Limite
         If Aviso_1(17,, 22,, [AtenÎ"o!], [O cliente estÿ sem limite de cr'dito, continuar?], { [  ^Sim  ], [  ^N"o  ] }, 2, .t. ) = 1
            Return( .t. )
         Else
            Return( .f. )
         endif
      endif
   endif
   return(.t.)
// ****************************************************************************
static function W_Dsc( Opcao )

   @ 29,02 say space(25)
   If Opcao = 1
      @ 29,02 Say [Desconto($):]
      @ 29,15 Say nValDesc picture [@e 99,999.99]
   ElseIf Opcao = 2
      @ 29,02 Say [Desconto(%):]
      @ 29,15 Say nPerDesc picture [99.99]
   EndIf
   Return( .t. )
// ****************************************************************************
static Function vPlano(cCodPla) // Plano de pagamento
   local cDesPla := space(30)

   if Busca(Zera(@cCodPla),"Plano",1,row(),col()+1,"Plano->DesPla",{"Plano de Pagamento Nao Cadastrado"},.f.,.f.,.f.)
      If Plano->PerEnt = [S]
         If Plano->FatAtu = 0
            if empty(nEntrada)
               nEntrada := round( nTotal / Plano->NumPar,2)
            endif
         Else
            nEntrada := ( nTotal * Plano->FatAtu )
         EndIf
      Else
         nEntrada := 0
      EndIf
      Return( .t. )
   EndIf
   Return( .f. )
// ****************************************************************************
static procedure MostraSubTotal
    @ 29,67 say Soma_Vetor(aSubTotal) picture "@e 999,999.99"
    @ 30,67 say Soma_Vetor(aValDescTotal) picture "@e 999,999.99"
    @ 31,67 say Soma_Vetor(aTotPro) picture "@e 999,999.99"
    return 
// ****************************************************************************
function vOrcamentos(Pos_H,Pos_V,Ln,Cl,Tecla) // Gets dos Itens do Pedido
   Local GetList := {},cCampo,cCor := setcolor(),cCodigo,cLixo

	If Tecla = K_ENTER
		// ** Codigo do Produto
		if Pos_H == 1
			cCodigo := aCodItem[Pos_V]
			@ ln,cl get cCodigo picture "@k";
         			when Rodape("Esc-Encerra | F4-Produtos");
         			valid BuscarCodigo(@cCodigo) .and. vCodigo(cCodigo,pos_v) 
         	setcursor(SC_NORMAL)
         	read
         	setcursor(SC_NONE)
         	if !(lastkey() == K_ESC)
                cCodProd2 := aCodPro[pos_v]
            	aCodItem[pos_v] := cCodigo
                aCodPro[Pos_V] := Produtos->CodPro
            	aDesPro[pos_v] := left(Produtos->FanPro,30)
            	aEmbPro[Pos_V] := Produtos->EmbPro
            	aQteEmb[Pos_V] := Produtos->QteEmb
            	aPcoVen[pos_v] := Produtos->PcoVen
                aPcoCus[Pos_V] := Produtos->PcoCus
            	keyboard replicate(chr(K_RIGHT),3)+chr(K_ENTER)
            	return(2)
            else
                lIncluir := .f.
         	endif
        // ** Desconto
		elseif Pos_H == 4
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
                    aValDesc[Pos_V] := round(aPcoVen[Pos_V]*(aDscPro[Pos_V] /100),2) 
            	else
            		aPcoLiq[Pos_V] := aPcoVen[Pos_V]
            	endif
            	keyboard chr(K_RIGHT)+chr(K_ENTER)
            	return(2)
            endif
		// ** Quantidade
		elseif Pos_H == 5
			cCampo := aQtdPro[pos_v]
         	@ ln,Cl get cCampo picture "@k 99,999.999";
         				when Rodape("Esc-Encerra");
         				valid NoEmpty(cCampo) 
         	setcursor(SC_NORMAL)
         	read
         	setcursor(SC_NONE)
        	if !(lastkey() == K_ESC)
				aQtdPro[Pos_V] := cCampo
                aSubTotal[Pos_V] := aPcoVen[Pos_V]*aQtdPro[Pos_V]
            	aTotPro[Pos_V] := aQtdPro[Pos_V]*aPcoLiq[Pos_V]
                aValDescTotal[Pos_V] := (aValDesc[Pos_v]*aQtdPro[Pos_V])
                MostraSubTotal()
                if !empty(aCodItem[pos_v]) .and. !empty(aQtdPro[pos_v])
                    if lIncluirPedido
                        do while Sequencia->(!Trava_Reg())
                        enddo 
                        Sequencia->IdOrca += 1
                        cNumPed := strzero(Sequencia->IdOrca,09)
                        Sequencia->(dbunlock())
                        @ 04,12 say cNumPed picture "@k 999999999"
                        
                        do while Orcamentos->(!Adiciona())
                        enddo
                        Orcamentos->id:= cNumPed
                        Orcamentos->CodCli := cCodCli
                        Orcamentos->Data := dData
                        Orcamentos->CodVen := cCodVen
                        Orcamentos->(dbcommit())
                        Orcamentos->(dbunlock())
                        lIncluirPedido := .f.
                    endif
                    if !(aCodItem[pos_v] == cCodProd2)
                        if !empty(cCodProd2)
                            if ItemOrcamentos->(dbsetorder(2),dbseek(cNumPed+cCodProd2))
                                do while ItemOrcamentos->(!Trava_Reg())
                                enddo
                                ItemOrcamentos->(dbdelete())
                                ItemOrcamentos->(dbcommit())
                            endif
                        endif
                    endif
                    if ItemOrcamentos->(dbsetorder(2),dbseek(cNumPed+aCodPro[Pos_v]))
                        do while ItemOrcamentos->(!Trava_Reg())
                        enddo
                        ItemOrcamentos->(dbdelete())
                        ItemOrcamentos->(dbcommit())
                    endif
                    do while !ItemOrcamentos->(Adiciona())
                    enddo
                    ItemOrcamentos->id  := cNumPed
                    ItemOrcamentos->CodItem := aCodItem[pos_v]
                    ItemOrcamentos->CodPro  := aCodPro[pos_v]
                    ItemOrcamentos->QtdPro  := aQtdPro[pos_v]
                    ItemOrcamentos->PcoVen  := aPcoVen[pos_v]
                    ItemOrcamentos->DscPro  := aDscPro[pos_v]
                    ItemOrcamentos->PcoLiq  := aPcoLiq[pos_v]
                    ItemOrcamentos->DtaSai  := dData
                    ItemOrcamentos->ValDesc := aValDesc[pos_v]
                    ItemOrcamentos->Custo := aPcoCus[Pos_V]
                    ItemOrcamentos->(dbcommit())
                    ItemOrcamentos->(dbunlock())
               	    if Pos_v >= len(aCodItem)
                        aadd(aCodItem,space(14))
                        aadd(aCodPro,space(06))
                        aadd(aDesPro,space(30))
                        aadd(aEmbPro,space(04))
                        aadd(aQteEmb,0)
                        aadd(aPcoVen,0)
                        aadd(aDscPro,0)
                        aadd(aPcoLiq,0)
                        aadd(aQtdPro,0.00)
                        aadd(aTotPro,0)
                        aadd(aValDesc,0) // ** Valor do desconto por item
                        aadd(aSubTotal,0)  // ** Sub-Total do item
                        aadd(aValDescTotal,0) // ** Valor do desconto total
                        aadd(aPcoCus,0) // pre‡o de custo
                        keyboard chr(K_DOWN)+replicate(chr(K_LEFT),Pos_H-1)+chr(K_ENTER)
                        return(3)
                    else
                        keyboard chr(K_DOWN)+replicate(chr(K_LEFT),Pos_H-1)+chr(K_ENTER)
                        return(3)
                    endif
                endif
            endif
         endif
	elseif Tecla == K_F4
        if !(pos_v = len(aCodItem))
            Mens({"Posicione no œltimo produto para incluir um novo"})
            return(2)
        endif
        if Aviso_1( 27,,32,,"Atencao!","Incluir outro produto ?",{ [  ^Sim  ], [  ^Nao  ] }, 2, .t. ) = 1
            if !empty(aCodItem[pos_v])
                aadd(aCodItem,space(14))
                aadd(aCodPro,space(06))
                aadd(aDesPro,space(30))
                aadd(aEmbPro,space(04))
                aadd(aQteEmb,0)
                aadd(aPcoVen,0)
                aadd(aDscPro,0)
                aadd(aPcoLiq,0)
                aadd(aQtdPro,0.00)
                aadd(aTotPro,0)
                aadd(aValDesc,0) // ** Valor do desconto por item
                aadd(aSubTotal,0)  // ** Sub-Total do item
                aadd(aValDescTotal,0) // ** Valor do desconto total
                aadd(aPcoCus,0) // pre‡o de custo
                keyboard chr(K_DOWN)+replicate(chr(K_LEFT),Pos_H-1)+chr(K_ENTER)
                return( 3 )
            endif
        endif
   elseif Tecla == K_F6
        if Aviso_1( 27,,32,,"Atencao!","Confirma a exclus’o do produto ?",{ [  ^Sim  ], [  ^Nao  ] }, 2, .t. ) = 1
            if ItemOrcamentos->(dbsetorder(1),dbseek(cNumPed+aCodPro[pos_v]))
                do while ItemOrcamentos->(!Trava_Reg())
                enddo
                ItemOrcamentos->(dbdelete())
                ItemOrcamentos->(dbcommit())
                ItemOrcamentos->(dbunlock())
            endif
            if len(aCodItem) == 1
                aCodItem[Pos_V] := space(14)
                aCodPro[Pos_V] := space(06)
                aDesPro[Pos_V] := space(30)
                aEmbPro[Pos_V] := space(04)
                aQteEmb[Pos_V] := 0
                aPcoVen[Pos_V] := 0
                aDscPro[Pos_V] := 0
                aPcoLiq[Pos_V] := 0
                aQtdPro[Pos_V] := 0.00
                aTotPro[Pos_V] := 0
                aValDesc[Pos_V] := 0 // ** Valor do desconto por item
                aSubTotal[Pos_V] := 0  // ** Sub-Total do item
                aValDescTotal[Pos_V] := 0 // ** Valor do desconto total
                aPcoCus[Pos_V] := 0 // pre‡o de custo
                MostraSubTotal()
         	    return(3)
            endif
            adel(aCodItem,Pos_V)
            adel(aCodPro,Pos_V)
            adel(aDesPro,Pos_V)
            adel(aEmbPro,Pos_V)
            adel(aQteEmb,Pos_V)
            adel(aPcoVen,Pos_V)
            adel(aDscPro,Pos_V)
            adel(aPcoLiq,Pos_V)
            adel(aQtdPro,Pos_V)
            adel(aTotPro,Pos_V)
            adel(aValDesc,Pos_V) // ** Valor do desconto por item
            adel(aSubTotal,Pos_V)  // ** Sub-Total do item
            adel(aValDescTotal,Pos_V) // ** Valor do desconto total)
            adel(aPcoCus,Pos_V) // pre‡o de custo
            nItens := len(aCodItem)-1
            asize(aCodItem,nItens)
            asize(aCodPro,nItens)
            asize(aDesPro,nItens)
            asize(aEmbPro,nItens)
            asize(aQteEmb,nItens)
            asize(aPcoVen,nItens)
            asize(aDscPro,nItens)
            asize(aPcoLiq,nItens)
            asize(aQtdPro,nItens)
            asize(aTotPro,nItens)
            asize(aValDesc,nItens) // ** Valor do desconto por item
            asize(aSubTotal,nItens)  // ** Sub-Total do item
            asize(aValDescTotal,nItens) // ** Valor do desconto total
            asize(aPcoCus,nItens) // pre‡o de custo
            @ 29,67 say Soma_Vetor(aTotPro) picture "@e 999,999.99"
        return(3)
    endif
   elseif Tecla == K_F2
      return(0)
   elseif Tecla == K_F11
      Calc()
    elseif Tecla == K_F8
        if nModoPedido = 1
            return(0)
        else
            Mens({"Essa opÎ’o n’o ' permitida na alteraÎ’o"})
        endif
   EndIf
	if lastkey() == K_ESC .and. !lIncluir
        if len(aCodItem) = 1
            if empty(aCodPro[Pos_V])
                aCodItem[Pos_V] := space(14)
                aCodPro[Pos_V] := space(06)
                aDesPro[Pos_V] := space(30)
                aEmbPro[Pos_V] := space(04)
                aQteEmb[Pos_V] := 0
                aPcoVen[Pos_V] := 0
                aDscPro[Pos_V] := 0
                aPcoLiq[Pos_V] := 0
                aQtdPro[Pos_V] := 0.00
                aTotPro[Pos_V] := 0
                aValDesc[Pos_V] := 0 // ** Valor do desconto por item
                aSubTotal[Pos_V] := 0  // ** Sub-Total do item
                aValDescTotal[Pos_V] := 0 // ** Valor do desconto total
                aPcoCus[Pos_V] := 0 // preco de custo
                MostraSubTotal()
                lIncluir := .t.
                return(3)
            endif
        else
            if empty(aCodItem[pos_v])
			     adel(aCodItem,Pos_V)
                adel(aCodPro,Pos_V)
                adel(aDesPro,Pos_V)
                adel(aEmbPro,Pos_V)
                adel(aQteEmb,Pos_V)
                adel(aPcoVen,Pos_V)
                adel(aDscPro,Pos_V) // ** Percentual de desconto por item
                adel(aPcoLiq,Pos_V)
                adel(aQtdPro,Pos_V)
                adel(aTotPro,Pos_V)
                adel(aValDesc,Pos_V) // ** Valor do desconto por item
                adel(aSubTotal,Pos_V)  // ** Sub-Total do item
                adel(aValDescTotal,Pos_V) // ** Valor do desconto total
                adel(aPcoCus,Pos_V) // preco de custo
                nItens := len(aCodItem)-1
                asize(aCodItem,nItens)
                asize(aCodPro,nItens)
                asize(aDesPro,nItens)
                asize(aEmbPro,nItens)
                asize(aQteEmb,nItens)
                asize(aPcoVen,nItens)
                asize(aDscPro,nItens)
                asize(aPcoLiq,nItens)
                asize(aQtdPro,nItens)
                asize(aTotPro,nItens)
                asize(aValDesc,nItens) // ** Valor do desconto por item
                asize(aSubTotal,nItens)  // ** Sub-Total do item
                asize(aValDescTotal,nItens) // ** Valor do desconto total
                asize(aPcoCus,nItens) // pre‡o de custo
                lIncluir := .t.
                return(3)
            endif
        endif
	endif
   Return( 1 )
// ****************************************************************************
static function vCodigo(cCodProd,pos_v)  // Verifica se o item ja foi cadastrado

   if !(ascan(aCodItem,cCodProd) == 0) .and. !(aCodItem[pos_v] == cCodProd)
      Mens({"Produto jÿ incluido"})
      return(.f.)
   endif
   return(.t.)
// *****************************************************************************
static function vTipoCobra

   if Plano->TipOpe == "1" // Se for Avista
      MenuArray(@cTipoCobra,{;
      {"1","Dinheiro         "},;
      {"3","Cheque           "},;
      {"4","Cartao de credito"}},row()-5,col(),row(),col()+1)
   else
      MenuArray(@cTipoCobra,{;
      {"1","Dinheiro         "},;
      {"2","Duplicata        "},;
      {"3","Cheque           "},;
      {"4","Nota Promissoria "},;
      {"5","Nota de Debito   "},;
      {"6","Cartao de credito"}},row()-5,col(),row(),col()+1)
   endif
   return(.t.)
// *****************************************************************************
procedure VerItemOrcamentos(cNumPed)
   Local cCor := setcolor(),cTela := SaveWindow()
   local aCampo  := {},aTitulo := {},aMascara := {}
   private aVetor1 := {},aVetor2 := {},aVetor3 := {},aVetor4 := {},aVetor5 := {}
   private aVetor6 := {}

   ItemOrcamentos->(dbsetorder(1),dbseek(cNumPed))
   while ItemOrcamentos->Id == cNumPed .and. ItemOrcamentos->(!eof())
      Produtos->(dbsetorder(1),dbseek(ItemOrcamentos->CodPro))
      aadd(aVetor1,ItemOrcamentos->CodItem)
      aadd(aVetor2,left(Produtos->FanPro,40))
      aadd(aVetor3,Produtos->EmbPro+" x "+str(Produtos->QteEmb,3))
      aadd(aVetor4,ItemOrcamentos->QtdPro)
      aadd(aVetor5,ItemOrcamentos->PcoLiq)  // ** Pre‡o l¡quido
      aadd(aVetor6,ItemOrcamentos->QtdPro*ItemOrcamentos->PcoLiq)
      ItemOrcamentos->(dbskip())
   end
   aTitulo  := {" Codigo" ,"Descricao","Qtde."        ,"Pco. Venda"   ,"Total"}
   aCampo   := {"aVetor1","aVetor2"   ,"aVetor4"      ,"aVetor5"      ,"aVetor6"}
   aMascara := {"@!"     ,"@!"        ,"@e 99,999.999","@e 99,999.999","@e 9,999,999.99"}
   cTela := SaveWindow()
   Rodape("Esc-Encerra")
   Window(10,00,23,100,"> Itens do Or‡amento nr.: "+cNumPed+" <")
   Edita_Vet(11,01,22,099,aCampo,aTitulo,aMascara, [XAPAGARU],,,5)
   RestWindow(cTela)
   setcolor(cCor)
   Return
// *****************************************************************************
static function AbrirArquivos

    Msg(.t.)
    Msg("Aguarde : Abrindo os Arquivos")
	if !OpenProdutos()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
	if !OpenClientes()
		FechaDados()
		Msg(.f.)
	endif
	if !OpenCidades()
		FechaDados()
		Msg(.f.)
	endif
	if !OpenOrcamentos()
		FechaDados()
		Msg(.f.)
	endif
	if !OpenItemOrcamentos()
		FechaDados()
		Msg(.f.)
	endif
	if !OpenPlano()
		FechaDados()
		Msg(.f.)
	endif
	if !OpenDupRec()
		FechaDados()
		Msg(.f.)
	endif
	if !OpenVendedor()
		FechaDados()
		Msg(.f.)
	endif
	if !OpenBanco()
		FechaDados()
		Msg(.f.)
	endif
	if !OpenCheques()
		FechaDados()
		Msg(.f.)
	endif
	if !OpenBxaDupRe()
		FechaDados()
		Msg(.f.)
	endif
	if !OpenCaixa()
		FechaDados()
		Msg(.f.)
	endif
	if !OpenMovCxa()
		FechaDados()
		Msg(.f.)
	endif
	if !OpenNatureza()
		FechaDados()
		Msg(.f.)
	endif
	if !OpenSequencia()
		FechaDados()
		Msg(.f.)
	endif
   Msg(.f.)
   return(.t.)
// *****************************************************************************   
static procedure GetOrcamentos

    do while .t.
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))        
        @ 30,15 get cCodPla    picture "@k 99";
			when Rodape("Esc-Encerra | F4-Planos de Pagamento");
			valid vPlano(@cCodPla)
        @ 29,41 get nEntrada   picture "@ke 999,999.99";
			when Plano->PerEnt == "S" valid iif(lastkey() == K_UP,.t.,nEntrada > 0 .and. nEntrada < nTotal)
        @ 31,15 get cTipoCobra picture "@k 9";
			when Rodape("Esc-Encerra") valid iif(lastkey() == K_UP,.t.,vTipoCobra(cTipoCobra))
        @ 32,15 get cObs       picture "@k!"
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        nTotal := nTotal - nEntrada
        @ 31,67 say nTotal     picture "@e 999,999.99"
        if !Confirm("Confirma os dados")
            loop
        endif
        exit
    enddo
    return
// *****************************************************************************	
static procedure GetItemsOrcamentos
   
	aTitulo[1]  := "Codigo" 
	aTitulo[2]  := "Descricao"
	aTitulo[3]  := "Pco.Unit"
	aTitulo[4]  := "%Desc."
	aTitulo[5]  := "Qtde."
	aTitulo[6]  := "Pco. Liq."
	aTitulo[7]  := "Total"
	
	// ***************************************************************************************************
	aCampo[1]   := "aCodItem"
	aCampo[2]   := "aDesPro"
	aCampo[3]   := "aPcoVen"
	aCampo[4]   := "aDscPro"  // ** Desconto do produto
	aCampo[5]   := "aQtdPro"
	aCampo[6]   := "aPcoLiq"
	aCampo[7]   := "aTotPro"
	// ***************************************************************************************************
	aMascara[1] := "@!"
	aMascara[2] := "@!"
	aMascara[3] := "@e 99,999.999"   // ** Valor Unitario
	aMascara[4] := "@k 999.99"       // ** Desconto
	aMascara[5] := "@k 99,999.999" // ** Quantidade
	aMascara[6] := "@e 99,999.999"   // ** Valor Liquido
	aMascara[7] := "@e 999,999.99" // ** Valor total
    
	cTela2 := SaveWindow(18,01,18,99)
    if nModoPedido = 1
        @ 28,01 say " F2-Confirma | F4-Inclui | F6-Exclui | F8-Abandona " color Cor(26)
    else
        @ 28,01 say " F2-Confirma | F4-Inclui | F6-Exclui " color Cor(26)
    endif
	Rodape("Esc-Encerra")
	setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
	// **keyboard chr(K_ENTER)
    do while .t.
        Edita_Vet(09,01,27,99,aCampo,aTitulo,aMascara,"vOrcamentos",,,,2)
        if lastkey() == K_F8
            if Aviso_1( 09,,14,,[Atencao!],"Confirma o cancelamento do or‡amento ?",{ [  ^Sim  ], [  ^Nao  ] }, 2, .t. ) = 1
                lAbandonar := .t.
                exit
            endif
	   elseif lastkey() == K_F2
	      if !Confirm("Confirma os Itens do or‡amento")
	         loop
	      endif
	      exit
	   endif
	enddo
    return
    
static function vSemSaldo(cCod)

    if Produtos->CtrLes == "S"
        if Produtos->QteAc02 == 0
            Mens({"Produto sem saldo"})
            cCod := space(14)
            return(.f.)
        endif
    endif
    return(.t.)
    
procedure iOrcamentos(cNumero)  // Impressao do Pedido de Compra
   local cTela := SaveWindow(),nVideo,lCabec := .t.,nSeq := 1
   local cTexto,nTotal := 0,nSubTotal := 0,nDesc := 0,nVia := 1,nX
   local aTipoCo := {"Dinheiro","Duplicata","Cheque","Nota Promissoria","Nota de Debito"}
   private nPagina := 1

   cTexto := "Solicitamos a essa firma fornecer-nos, nas condicoes aqui especificadas, o(s) material(is) acima discriminado(s)"
   If Aviso_1(09,,14,,[Aten‡„o!],[Imprimir Or‡amento ?],{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
      If Ver_Imp2(@nVideo)
            if nVideo == 1
                cImpressoraPadrao := ImpressoraPadrao()
            endif
            if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"23",.t.,.t.,"Temp23")
                Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
                return
            endif
            zap
            Temp23->(dbclosearea())
            // ** Abre o arquivo em modo exclusivo
            if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"23",.t.,.t.,"Temp23")
                Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
                return
            endif
            if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"24",.t.,.t.,"Temp24")
                Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
                return
            endif
            zap
            Temp24->(dbclosearea())
            // ** Abre o arquivo em modo exclusivo
            if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"24",.t.,.t.,"Temp24")
                Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
                return
            endif
            ItemOrcamentos->(dbsetorder(1),dbseek(cNumero))
            nSeq := 1
            Msg(.t.)
            Msg("Aguarde: Processando as informa‡äes")
            do while ItemOrcamentos->Id == cNumero .and. ItemOrcamentos->(!eof())
                Produtos->(dbsetorder(1),dbseek(ItemOrcamentos->CodPro))
                Temp23->(dbappend())
                Temp23->ordem := strzero(nSeq,3)
                Temp23->codpro := ItemOrcamentos->CodPro
                Temp23->descricao := Produtos->FanPro
                Temp23->unidade := Produtos->EmbPro
                Temp23->quantidade := ItemOrcamentos->QtdPro 
                Temp23->valor := ItemOrcamentos->PcoLiq 
                Temp23->total := (ItemOrcamentos->PcoLiq*ItemOrcamentos->Qtdpro)
                ItemOrcamentos->(dbskip())
            enddo
            Msg(.f.)
            select Clientes
            set relation to codcid into cidades
            Clientes->(dbgotop())
            Clientes->(dbsetorder(1),dbseek(Orcamentos->CodCli))
            Plano->(dbsetorder(1),dbseek(Orcamentos->CodPla))
            oFrPrn := frReportManager():new()
            oFrPrn:LoadLangRes('english.xml')                     //arquivo de idioma
            oFrprn:SetWorkArea("Clientes",select("Clientes"))
            oFrprn:SetWorkArea("Orcamentos",select("Orcamentos"))
            oFrprn:SetWorkArea("Temp23",select("Temp23"))
            oFrprn:SetWorkArea("Temp24",select("Temp24"))
            
            oFrPrn:SetWorkArea("CIDADES", Select("CIDADES"))
            oFrPrn:SetResyncPair('Clientes', 'Cidades')  // Ativa o set relation no FastReport

            
            oFrprn:LoadFromFile('orcamento.fr3')
            oFrPrn:AddVariable("variaveis","empresa","'"+cEmpFantasia+"'")
            oFrPrn:AddVariable("Pedido","numero","'"+cNumero+"'")
            oFrPrn:AddVariable("Pedido","plano","'"+Plano->DesPla+"'") 
            
            oFrPrn:AddVariable("Clientes","cnpjcpf","'"+iif(Clientes->TipCli == "F",transform(Clientes->CpfCli,"@r 999.999.999-99"),transform(Clientes->CgcCli,"@r 99.999.999/9999-99"))+"'")
            oFrPrn:AddVariable("Clientes","ierg","'"+iif(Clientes->TipCli == "J",Clientes->IEsCli,Clientes->RgCli)+"'")
            oFrPrn:SetMasterDetail('Temp21','ItemEntr',{|| Temp21->Entrega}) // Filtra Itens da Venda
            Msg(.t.)
            Msg("Aguarde: Gerando o relatorio")
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
            Temp23->(dbclosearea())
            Temp24->(dbclosearea())
            Clientes->(DbClearRelation())
        endif
   endif
   RestWindow(cTela)
   return
    
    
	
// ** Fim do Arquivo.
