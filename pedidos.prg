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

procedure ConPedidos(lAbrir)
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
    select Pedidos
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
    oBrow:addcolumn(tbcolumnnew("Proposta"     ,{|| Pedidos->NumPed }))
    oBrow:addcolumn(tbcolumnnew("Data"         ,{|| Pedidos->Data }))
    oBrow:addcolumn(tbcolumnnew("Cliente"         ,{|| ;
   		Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli),Pedidos->CodCli+'-'+Clientes->ApeCli)}))
    oBrow:addcolumn(tbcolumnnew("Total"        ,{|| transform(Pedidos->Total,"@e 999,999.99")}))
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
               cDados := Pedidos->NumPed
               keyboard (cDados)+chr(K_ENTER)
               lFim := .t.
            endif
         elseif nTecla == K_F3
            VerItemPed(Pedidos->NumPed)
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
procedure IncPedidos
   local getlist := {},cTela := SaveWindow(),cTela2
   local lLimpa := .t.,nDebitos,nI
   local nIdCliente,oQCliente
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
	private cCodPla,cCodPla2,nEntrada2,nTotal2,dData,nSubTotal
   private cNumPed,lIncluirPedido,cCodVen,cCodProd2,lAbandonar
   private nModoPedido := 1
   private cTpV  // Tipo de venda 0-Avista  1-Aprazo

   /*
	if !AbrirArquivos()
		return
	endif
   if Pedidos->(dbsetorder(6),dbseek(.f.))
      Mens({"Venda n£mero "+Pedidos->NumPed+" de "+dtoc(Pedidos->data)+" nÆo finalizado","Favor Excluir"})
      FechaDados()
      return
   endif
   */
   DesativaF9()
   AtivaF4()
   TelPedido(1)
	do while .t.
		if lLimpa
			cNumPed    := space(09)
			nIdCliente   := 0
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
         cTpV := space(01)
         lAbandonar := .f.
         lLimpa := .f.
      endif
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      /*
      if (Sequencia->NumPed+1) > 999999999
         Mens({"Limite de Proposta Esgotado"})
         exit
      endif
      //cNumPed := strzero(Sequencia->NumPed+1,09)
      //@ 04,12 say cNumPed picture "@k 999999999"
      */
      @ 04,31 get dData   picture "@k"  valid NoEmpty(dData)
      @ 05,12 get nIdCliente picture "@k 99999";
      			when Rodape("Esc-Encerra | F4-Clientes");
      			valid iif(lastkey() == K_UP,.t.,vCliente(@nIdCliente,@oQCliente))
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
      @ 05,75 get cTpV picture "@k!";
                valid MenuArray(@cTpV,{{"0","Avista "},{"1","A prazo"}},row(),col(),row(),col()+1)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      endif
      GetItemsPedidos()
      if lAbandonar
         Msg(.t.)
         Msg("Aguarde: Cancelando proposta")
         if Pedidos->(dbsetorder(1),dbseek(cNumPed))
            do while Pedidos->(!Trava_Reg()) 
            enddo
            ItemPed->(dbsetorder(1),dbseek(cNumPed))
            do while Itemped->NumPed == cNumPed .and. Itemped->(!eof())
               do while Itemped->(!Trava_Reg())
               enddo
               AtualizaSaldoFisico(Itemped->Codpro,.t.,Itemped->Qtdpro)
               Itemped->(dbdelete())
               Itemped->(dbcommit())
               Itemped->(dbunlock())
               Itemped->(dbskip())
            enddo
            Pedidos->(dbdelete())
            Pedidos->(dbcommit())
            Pedidos->(dbunlock())
         endif
         Msg(.f.)
         loop
      endif
      nTotal    := Soma_Vetor(aTotPro)
      nSubTotal := Soma_Vetor(aSubTotal)
      GetPedido()
      if Pedidos->(dbsetorder(1),dbseek(cNumPed))
         do while Pedidos->(!Trava_Reg())
         enddo
         Pedidos->ValDesc     := Soma_Vetor(aValDescTotal) // ** Valor total do desconto
         //Pedidos->PerDesc     := nPerDesc
         Pedidos->SubTotal    := nSubTotal
         Pedidos->Total       := nTotal
         Pedidos->Entrada     := nEntrada
         Pedidos->CodPla      := cCodPla
         Pedidos->Obs  := cObs
         Pedidos->TipoCobra := cTipoCobra
         Pedidos->CP_Ven := Vendedor->CP_Ven
         Pedidos->CV_Ven := Vendedor->CV_Ven
         Pedidos->FatCom := Plano->FatCom
         Pedidos->Finalizado := .t.
         Pedidos->Tpv := val(cTpv)
         Pedidos->(dbcommit())
         Pedidos->(dbunlock())
      endif
      @ 04,12 say cNumPed picture "@k 999999999"
		Grava_Log(cDiretorio,"Proposta|Incluir|Pedido "+cNumPed,Pedidos->(recno()))
		GeraDupl(cNumPed,cCodCli,cCodVen,cTipoCobra,dData,nTotal,nEntrada)
		lLimpa := .t.
      if Aviso_1( 27,,32,,"Atencao!","Imprimir proposta ?",{ [  ^Sim  ], [  ^Nao  ] }, 1, .t. ) = 1
         iPedCompra(cNumPed)
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
procedure AltPedidos
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
   private cTpV  // Tipo de venda 0-Avista  1-Aprazo
   
	if !AbrirArquivos()
		return
	endif
   DesativaF9()
   AtivaF4()
   TelPedido(2)
   do while .t.
      lIncluirPedido := .f.
      lAbandorar := .f.
      cNumPed := space(09)  // Local
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 04,12 get cNumPed picture "@k 999999999";
      			valid Busca(Zera(@cNumPed),"Pedidos",1,,,,{"Numero Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      dData   := Pedidos->Data
      cCodCli := Pedidos->CodCli
      cCodVen := Pedidos->CodVen
        Vendedor->(dbsetorder(1),dbseek(cCodVen))
        @ 29,67 say Pedidos->SubTotal picture "@e 999,999.99"
        @ 30,67 say Pedidos->ValDesc picture "@e 999,999.99"
        @ 31,67 say Pedidos->Total picture "@e 999,999.99"
                      
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
        nValDesc   := Pedidos->ValDesc
        nSubTotal  := Pedidos->SubTotal
        nTotal     := Pedidos->Total
        nEntrada   := Pedidos->Entrada
        cCodPla    := Pedidos->CodPla
        cObs       := Pedidos->Obs
        cTipoCobra := Pedidos->TipoCobra
        // ** Controle
        nEntrada2  := Pedidos->Entrada
        cCodPla2   := Pedidos->CodPla
        nTotal2    := Pedidos->Total
        cTpV       := Pedidos->Tpv
      
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
      	ItemPed->(dbsetorder(1),dbseek(cNumPed))
      	do while ItemPed->NumPed == cNumPed .and. ItemPed->(!eof())
         	Produtos->(dbsetorder(1),dbseek(alltrim(ItemPed->CodPro)))
         	aadd(aCodItem, ItemPed->CodItem)
            aadd(aCodPro,ItemPed->CodPro)
         	aadd(aDesPro,left(Produtos->FanPro,30))
         	aadd(aEmbPro,Produtos->EmbPro)
         	aadd(aQteEmb,Produtos->QteEmb)
         	aadd(aPcoVen, ItemPed->PcoVen) // ** pre‡o de venda
         	aadd(aDscPro, ItemPed->DscPro) // ** % de desconto
         	aadd(aQtdPro, ItemPed->QtdPro)
         	aadd(aPcoLiq, ItemPed->PcoLiq)
         	aadd(aTotPro, ItemPed->PcoLiq*Itemped->QtdPro)
            aadd(aValDesc,ItemPed->ValDesc)
            aadd(aSubTotal,ItemPed->PcoVen*ItemPed->QtdPro)
            aadd(aValDescTotal,ItemPed->ValDesc*ItemPed->QtdPro) // ** Valor do desconto total
            aadd(aPcoCus,ItemPed->Custo) // pre‡o de custo
         	ItemPed->(dbskip())
      	enddo
      	nSubTotal := Soma_Vetor(aSubTotal)
      	nTotal    := Soma_Vetor(aTotPro)
        nValDesc  := Soma_Vetor(aValDescTotal) // valor do desconto total dos itens
        @ 29,67 say nSubTotal picture "@e 999,999.99"
        @ 30,67 say nValDesc picture "@e 999,999.99"
        @ 31,67 say nTotal picture "@e 999,999.99"
        if nTotal == Pedidos->Total
            // ** Variaveis das datas de vencimento e valores das duplicatas
            aVencmto := {}
            aParcela := {}
            // ** Pega as Duplicatas
            if DupRec->(dbsetorder(2),dbseek(cNumPed))
                if Plano->(dbsetorder(1),dbseek(Pedidos->CodPla),Plano->PerEnt == "S")
                    nEntrada := DupRec->ValDup
                    DupRec->(dbskip())
                endif
                do while left(DupRec->NumDup,9) == cNumPed .and. DupRec->(!eof())
                    aadd(aVencmto,DupRec->DtaVen)
                    aadd(aParcela,DupRec->ValDup)
                    DupRec->(dbskip())
                enddo
            endif
        endif
        cTela2 := SaveWindow()
        GetItemsPedidos()
      	nSubTotal := Soma_Vetor(aSubTotal)
      	nTotal    := Soma_Vetor(aTotPro)
        nValDesc  := Soma_Vetor(aValDescTotal) // valor do desconto total dos itens
		GetPedido()
      	nTotal := nTotal - nEntrada
      	@ 31,67 say nTotal picture "@e 999,999.99"
        // ** Retira as Duplicatas e os Cheques Ja Cadastrados
        if DupRec->(dbsetorder(1),dbgotop(),dbseek(Pedidos->CodCli+Pedidos->NumPed))
            do while DupRec->CodCli == Pedidos->CodCli .and. left(DupRec->NumDup,9) == cNumPed .and. DupRec->(!eof())
                // ** Retira as Duplicatas
                do while !DupRec->(Trava_Reg())
                enddo
                DupRec->(dbdelete())
                DupRec->(dbcommit())
                DupRec->(dbunlock())
                DupRec->(dbskip())
            enddo
        endif
        // ** Retira as Duplicatas Ja Baixadas
        if BxaDupRe->(dbsetorder(1),dbgotop(),dbseek(Pedidos->CodCli+Pedidos->NumPed))
            do while BxaDupRe->CodCli == Pedidos->CodCli .and. left(BxaDupRe->NumDup,9) == cNumPed .and. BxaDupRe->(!eof())
                do while !BxaDupRe->(Trava_Reg())
                enddo
                BxaDupRe->(dbdelete())
                BxaDupRe->(dbcommit())
                BxaDupRe->(dbunlock())
                BxaDupRe->(dbskip())
            enddo
        endif
        do while !Pedidos->(Trava_Reg())
        enddo
        Pedidos->NumPed    := cNumPed
        Pedidos->CodCli    := cCodCli
        Pedidos->Data      := dData
        Pedidos->CodVen    := cCodVen
        Pedidos->ValDesc   := nValDesc
        Pedidos->SubTotal  := nSubTotal
        Pedidos->Total     := nTotal
        Pedidos->Entrada   := nEntrada
        Pedidos->CodPla    := cCodPla
        Pedidos->Obs       := cObs
        Pedidos->TipoCobra := cTipoCobra
        Pedidos->(dbcommit())
        Pedidos->(dbunlock())
        Grava_Log(cDiretorio,"Proposta|Alterar|Pedido "+cNumPed,Pedidos->(recno()))
        GeraDupl(cNumPed,cCodCli,cCodVen,cTipoCobra,dData,nTotal,nEntrada)
        lLimpa := .t.
        if Aviso_1( 27,,32,,"Atencao!","Imprimir proposta ?",{ [  ^Sim  ], [  ^Nao  ] }, 1, .t. ) = 1
            iPedCompra(cNumPed)
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
procedure ExcPedidos
   local getlist := {},cTela := SaveWindow(),cTela2
   local cNumPed
   
	if !AbrirArquivos()
		return
	endif
    DesativaF9()
    AtivaF4()
    Window(12,00,19,76," Excluir Pedidos ")
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
      			valid Busca(Zera(@cNumPed),"Pedidos",1,,,,{"Venda nÆo cadastrada"},.f.,.f.,.f.)
      	setcursor(SC_NORMAL)
      	read
      	setcursor(SC_NONE)
      	if lastkey() == K_ESC
        	exit
      	endif
      	Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
      	@ 15,10 say Pedidos->Data
      	@ 16,10 say Pedidos->CodCli+"-"+Clientes->NomCli
      	@ 17,10 say Pedidos->Total picture "@e 999,999,999.99"
      	if !Confirm("Confirma a Exclusao",2)
        	loop
      	endif
      	Msg(.t.)
      	Msg("Aguarde: Excluindo o pedido")
      	// ** Retira as Duplicatas e os Cheques Ja Cadastrados
		if DupRec->(dbsetorder(1),dbgotop(),dbseek(Pedidos->CodCli+Pedidos->NumPed))
        	do while DupRec->CodCli == Pedidos->CodCli .and. left(DupRec->NumDup,9) == cNumPed .and. DupRec->(!eof())
            	// ** Retira os Cheques
            	if Cheques->(dbsetorder(1),dbseek(DupRec->CodBco+DupRec->NumAge+DupRec->NumCon+DupRec->NumChq))
               		do while Cheques->(!Trava_Reg())
               		enddo
               		Cheques->(dbdelete())
               		Cheques->(dbunlock())
            	endif
            	// ** Retira as Duplicatas
            	do while DupRec->(!Trava_Reg())
            	enddo
            	DupRec->(dbdelete())
            	DupRec->(dbcommit())
            	DupRec->(dbunlock())
            	DupRec->(dbskip())
         	enddo
      	endif
      	// ** Retira as Duplicatas Ja Baixadas
      	if BxaDupRe->(dbsetorder(1),dbgotop(),dbseek(Pedidos->CodCli+Pedidos->NumPed))
        	do while BxaDupRe->CodCli == Pedidos->CodCli .and. left(BxaDupRe->NumDup,9) == cNumPed .and. BxaDupRe->(!eof())
            	do while BxaDupRe->(!Trava_Reg())
            	enddo
            	BxaDupRe->(dbdelete())
            	BxaDupRe->(dbcommit())
            	BxaDupRe->(dbunlock())
            	BxaDupRe->(dbskip())
         	enddo
      	endif
      	if MovCaixa->(dbsetorder(1),dbseek(Pedidos->LanCxa))
         	if Caixa->(dbsetorder(1),dbseek(MovCaixa->CodCaixa))
            	// ** Trava o registro do caixa e atualiza o saldo
            	do while Caixa->(!Trava_Reg())
            	enddo
            	Caixa->SldCaixa -= MovCaixa->Valor
            	Caixa->(dbcommit())
            	Caixa->(dbunlock())
         	endif
         	do while MovCaixa->(!Trava_Reg())
         	enddo
         	MovCaixa->(dbdelete())
         	MovCaixa->(dbcommit())
         	MovCaixa->(dbunlock())
         	Grava_Log(cDiretorio,"Exclusao do Lanc.Aut. no Caixa do Pedido "+cNumPed,MovCaixa->(recno()))
      	endif
        Msg(.f.)
      	do while !Pedidos->(Trava_Reg())
      	enddo
        Msg(.t.)
        Msg("Aguarde: Excluindo os Itens")
        if ItemPed->(dbsetorder(1),dbseek(cNumPed))
            do while ItemPed->NumPed == cNumPed .and. ItemPed->(!eof())
                do while !ItemPed->(Trava_Reg())
                enddo
                AtualizaSaldoFisico(Itemped->CodPro,.t.,Itemped->Qtdpro)
                Itemped->(dbdelete())
                Itemped->(dbcommit())
                Itemped->(dbunlock())
                Itemped->(dbskip())
            enddo
         endif
        Pedidos->(dbdelete())
      	Pedidos->(dbcommit())
      	Pedidos->(dbunlock())
      	Grava_Log(cDiretorio,"Proposta|Excluir|Pedido "+cNumPed,Pedidos->(recno()))
      	Msg(.f.)
   	enddo
   	DesativaF4()
   	if PwNivel == "0"
		AtivaF9()
	endif
	FechaDados()
	RestWindow(cTela)
return
// ****************************************************************************
procedure ConfLancPe // Configura o Lancamento no Caixa
   local getlist := {},cTela := SaveWindow()

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenCaixa()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenHistCxa()
        FechaDados()
        Msg(.f.)
        return
   endif
   Msg(.f.)
   restore from (Arq_Sen)+"p" additive
   AtivaF4()
   Window(09,14,14,64,"> Conf. Lanc. no Caixa <")
   setcolor(Cor(11))
   //           67890123456789012345678901234567890123456789012345678
   //               2         3         4         5         6         7
   @ 11,16 say "    Caixa:"
   @ 12,16 say "Historico:"
   do while .t.
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,27 get cPCodCxa picture "@k 99" when Rodape("Esc-Encerra | F4-Caixas");
            valid Busca(Zera(@cPCodCxa),"Caixa",1,11,31,"Caixa->NomCaixa",{"Caixa Nao Cadastrado"},.f.,.f.,.f.)
      @ 12,27 get cPCodHis picture "@k 999" when Rodape("Esc-Encerra | F4-Historicos") valid Busca(Zera(@cPCodHis),"Historico",1,12,31,"Historico->NomHist",{"Historic Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      if !Confirm("Confirma as Informacoes")
         loop
      endif
      save to (Arq_Sen)+"p" all like cPCod*
      exit
   enddo
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
return
// ****************************************************************************
procedure ImpPedidos
   local getlist := {},cTela := SaveWindow(),cTela2
   local cNumPed
   
	if !AbrirArquivos()
		return
	endif
   AtivaF4()
   Window(12,00,19,60," Imprimir Proposta ")
   setcolor(Cor(11))
	@ 14,01 say " Numero:"
	@ 15,01 say "   Data:"
	@ 16,01 say "Cliente:"
	@ 17,01 say "  Valor:"
   do while .t.
      cNumPed := space(09)  // Local
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 14,10 get cNumPed picture "@k 999999999";
      		when Rodape("Esc-Encerra | F4-Proposta");
      		valid Busca(Zera(@cNumPed),"Pedidos",1,,,,{"Numero Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
      @ 15,10 say Pedidos->Data
      @ 16,10 say Pedidos->CodCli+"-"+Clientes->ApeCli
      @ 17,10 say Pedidos->Total picture "@e 999,999,999.99"
      if !Confirm("Confirma as Informacoes")
         loop
      endif
      iPedCompra(cNumPed)
   enddo
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
return
// ****************************************************************************
procedure ImpCupomNaoFiscal
   local getlist := {},cTela := SaveWindow(),cTela2
   local cNumPed
   
	if !AbrirArquivos()
		return
	endif
   AtivaF4()
   Window(12,00,19,60," Imprimir Cupom nao fiscal ")
   setcolor(Cor(11))
	@ 14,01 say " Pedido:"
	@ 15,01 say "   Data:"
	@ 16,01 say "Cliente:"
	@ 17,01 say "  Valor:"
   while .t.
      cNumPed := space(09)  // Local
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 14,10 get cNumPed picture "@k 999999999";
      		when Rodape("Esc-Encerra | F4-Proposta");
      		valid Busca(Zera(@cNumPed),"Pedidos",1,,,,{"Numero Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
      @ 15,10 say Pedidos->Data
      @ 16,10 say Pedidos->CodCli+"-"+Clientes->ApeCli
      @ 17,10 say Pedidos->Total picture "@e 999,999,999.99"
      if !Confirm("Confirma as Informacoes")
         loop
      endif
      iCupomNaoFiscal(cNumPed)
      //iCupomNaoFiscal(cNumPed)
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
return
// ****************************************************************************
procedure VerPedido()
   local cTela := SaveWindow()

   TelPedido(7)
   @ 04,12 say Pedidos->NumPed
   MosPedidos(Pedidos->NumPed)
   Rodape(space(20)+"Pressione Qualquer Tecla para Continuar")
   Inkey(0)
   RestWindow(cTela)
return
// ****************************************************************************
procedure MosPedidos(cNumPed)
   local nLinha,aLixo := {"Dinheiro        ","Duplicata       ","Cheque          ","Nota Promissoria","Nota de Debito  "}

   Vendedor->(dbsetorder(1),dbseek(Pedidos->CodVen))
   Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
   Cidades->(dbsetorder(1),dbseek(Clientes->CodCid))
   Plano->(dbsetorder(1),dbseek(Pedidos->CodPla))

   @ 04,31 say Pedidos->Data picture "@k"
   @ 04,55 say Pedidos->CodVen picture "@k 99"
   @ 04,58 say Vendedor->Nome
   @ 05,12 say Pedidos->CodCli picture "@k 99999"
   @ 05,18 say Clientes->NomCli
   @ 06,12 say Clientes->EndCli
   @ 07,12 say left(Clientes->BaiCli,20)
   @ 07,44 say left(Cidades->NomCid,20)
   @ 07,75 say Cidades->EstCid
   ItemPed->(dbsetorder(1),dbseek(cNumPed))
   nLinha := 11
   scroll(11,03,17,08,0)
   scroll(11,10,17,44,0)
   scroll(11,46,17,52,0)
   scroll(11,54,17,63,0)
   scroll(11,65,17,78,0)
   do while ItemPed->NumPed == cNumPed .and. ItemPed->(!eof())
      Produtos->(dbsetorder(1),dbseek(ItemPed->CodPro))
      @ nLinha,03 say ItemPed->CodPro
      @ nLinha,10 say left(Produtos->DesPro,20)+" -> "+Produtos->EmbPro+" x "+str(Produtos->QteEmb,3)
      @ nLinha,46 say ItemPed->QtdPro picture "@e 999,999"
      @ nLinha,54 say ItemPed->PcoVen picture "@e 99,999.999"
      @ nLinha,65 say ItemPed->PcoVen*ItemPed->QtdPro picture "@e 99,999,999.99"
      ItemPed->(dbskip())
      nLinha += 1
      if nLinha >= 18
         exit
      endif 
   enddo 
   @ 19,02 say [Desconto($):]
   @ 19,15 say space(10)
   @ 19,15 say Pedidos->ValDesc picture [@e 99,999.99]
   @ 20,67 say space(10)
   @ 20,67 say Pedidos->ValDesc picture "@e 999,999.99"
   if Pedidos->PerDesc > 0
      @ 19,02 say [Desconto(%):]
      @ 19,15 say space(10)
      @ 19,15 say Pedidos->PerDesc picture [99.99]
      @ 20,67 say space(10)
      @ 20,67 say Pedidos->SubTotal*(Pedidos->PerDesc/100) picture "@e 999,999.99"
   endif 
   @ 19,67 say Pedidos->SubTotal picture "@e 999,999.99"
   @ 21,67 say Pedidos->Total    picture "@e 999,999.99"
   @ 20,15 say Pedidos->CodPla   picture "@k 99"
   @ 20,18 say Plano->DesPla
   @ 19,41 say Pedidos->Entrada picture "@ke 999,999.99"
   @ 21,15 say Pedidos->TipoCobra
   @ 21,17 say aLixo[val(Pedidos->TipoCobra)]
   @ 22,15 say Pedidos->Obs picture "@k!"
return
// ****************************************************************************
procedure TelPedido( nModo )
   local cTitulo, aTitulos := {"InclusÆo","Altera‡Æo","ExclusÆo","Impressao","Fechamento","Abertura","VisualizaÎ’o"},nI

	Window(02,00,33,100,"> "+aTitulos[nModo]+" de Proposta <")
	setcolor(Cor(11))
	//           234567890123456789012345678901234567890123456789012345678901234567890123456789
	//                   1         2         3         4         5         6         7
	@ 04,02 say "  Numero:              Data:               Vendedor:"
	@ 05,02 say " Cliente:                                                 Tipo de Venda:" 
	@ 06,02 say "Endereco:"
	@ 07,02 say "  Bairro:                         Cidade:                            UF:"
   @ 08,01 say replicate(chr(196),99)
   @ 08,01 say " Itens da Proposta " color Cor(26)
// @ 07,01 say "         1         2         3         4         5         6         7         8         9         0         1"
//   @ 08,01 say "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
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
   @ 10,001 say replicate(chr(196),129)
   
   @ 10,018 say chr(194)
   @ 10,059 say chr(194)
   @ 10,064 say chr(194)
   @ 10,069 say chr(194)
   @ 10,081 say chr(194)
   @ 10,088 say chr(194)
   @ 10,100 say chr(194)
   @ 10,112 say chr(194)
   for nI := 11 to 27
		@ nI,018 say chr(179)
		@ nI,059 say chr(179)
		@ nI,064 say chr(179)
		@ nI,069 say chr(179)
		@ nI,081 say chr(179)
		@ nI,088 say chr(179)
		@ nI,100 say chr(179)
		@ nI,112 say chr(179)
	next
    */
   @ 28,01 say replicate(chr(196),99)
   @ 29,02 Say "Desconto($):                  Entrada:                Sub-Total:"
   @ 30,02 Say "      Plano:                                           Desconto:"
   @ 31,02 say " Tipo Pagto:                                              Total:"
   @ 32,02 Say "        OBS:"
return
// ****************************************************************************
static function vCliente(nIdCliente,oQCliente)
   local cNomCli := space(40),lAtraso := .f.,lRetorno,nDebitos := 0
   local cQuery,oQuery,oQCidades

   if !SqlBusca("id = "+NumberToSql(nIdCliente),"idcidade,endcli,baicli,nomcli,blocli",@oQCliente,;
      "administrativo.clientes",,,,{"Cliente nÆo cadastrado"},.f.)
      return(.f.)
   endif

   cQuery := "SELECT codcid,nomcid,estcid FROM administrativo.cidades WHERE codcid = "+;
      NumberToSql(oQCliente:Fieldget('idcidade'))

   if !ExecuteSql(cQuery,@oQCidades,{"Consulta de Cidades "},"sqlerro")
      oQCidades:close()
      return
   endif
   @ 06,12 say oQCliente:Fieldget('EndCli')
   @ 07,12 say left(oQCliente:Fieldget('BaiCli'),20)
   @ 07,44 say left(oQCidades:Fieldget('NomCid'),20)
   @ 07,75 say oQCidades:Fieldget('EstCid')
   if oQCliente:Fieldget('BloCli') == "S"
      Mens({"Cliente Bloqueado","Favor Verificar"})
      return(.f.)
   endif 

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
static function vPlano(cCodPla) // Plano de pagamento
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
static function BuscarValor(nPosicao)

    // se o tipo da venda for avista pega o preco avista
    if cTpV = '0'
        if empty(Produtos->PcoVen)
            Mens({"Pre‡o de venda nÆo definido"})
            return(.f.)
        else
            aPcoVen[nPosicao] := Produtos->PcoVen
        endif
    // se nÆo pega a prazo
    else
        if empty(Produtos->PcoPrz)
            Mens({"Pre‡o a prazo nÆo definido"})
            return(.f.)
        else
            aPcoVen[nPosicao] := Produtos->PcoPrz
        endif
   endif
return(.t.)
// ****************************************************************************
function vPedido(Pos_H,Pos_V,Ln,Cl,Tecla) // Gets dos Itens do Pedido
   Local GetList := {},cCampo,cCor := setcolor(),cCodigo,cLixo,nPreco

	If Tecla = K_ENTER
		// ** Codigo do Produto
		if Pos_H == 1
			cCodigo := aCodItem[Pos_V]
			@ ln,cl get cCodigo picture "@k";
         			when Rodape("Esc-Encerra | F4-Produtos");
         			valid BuscarCodigo(@cCodigo) .and. vCodigo(cCodigo,pos_v)  .and. BuscarValor(Pos_V) .and. vSemSaldo(@cCodigo) 
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
            aPcoCus[Pos_V] := Produtos->PcoCus
            if C_VAltPco = "S"
               keyboard replicate(chr(K_RIGHT),2)+chr(K_ENTER)
            else
               keyboard replicate(chr(K_RIGHT),3)+chr(K_ENTER)
            endif
            return(2)
         else
            lIncluir := .f.
         endif
      // Pre‡o unit rio
      elseif Pos_H = 3 .and. C_VAltPco = "S"
         nPreco := aPcoVen[Pos_V]
         @ Ln,Cl get nPreco picture "@e 99,999.999";
                  valid NoEmpty(nPreco)
         setcursor(SC_NORMAL)
         read
         setcursor(SC_NONE)
         if !(lastkey() == K_ESC)
            aPcoVen[Pos_V] := nPreco
            keyboard chr(K_RIGHT)+chr(K_ENTER)
            return(2)
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
         				valid NoEmpty(cCampo) .and. vSaldo(cCampo,Pos_V)
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
                        Sequencia->NumPed += 1
                        cNumPed := strzero(Sequencia->NumPed,09)
                        Sequencia->(dbunlock())
                        @ 04,12 say cNumPed picture "@k 999999999"
                        
                        do while Pedidos->(!Adiciona())
                        enddo
                        Pedidos->NumPed := cNumPed
                        Pedidos->CodCli := cCodCli
                        Pedidos->Data := dData
                        Pedidos->CodVen := cCodVen
                        Pedidos->(dbcommit())
                        Pedidos->(dbunlock())
                        lIncluirPedido := .f.
                    endif
                    if !(aCodItem[pos_v] == cCodProd2)
                        if !empty(cCodProd2)
                            if ItemPed->(dbsetorder(2),dbseek(cNumPed+cCodProd2))
                                // se for os dois estoque 
                                if nTipoEstoque = 0
                                    // se o pedido da baixa no estoque
                                    if Sequencia->PedidoBe
                                        // Acrescenta o saldo ao estoque
                                        AtualizaSaldoFisico(cCodProd2,.t.,ItemPed->QtdPro)
                                    endif
                                // se for nÆo fiscal
                                elseif nTipoEstoque = 1
                                    AtualizaSaldoFisico(cCodProd2,.t.,ItemPed->QtdPro)
                                endif
                                do while ItemPed->(!Trava_Reg())
                                enddo
                                Itemped->(dbdelete())
                                ItemPed->(dbcommit())
                            endif
                        endif
                    endif
                    if ItemPed->(dbsetorder(2),dbseek(cNumPed+aCodPro[Pos_v]))
                        if nTipoEstoque = 0 
                            // se o pedido da baixa no estoque
                            if Sequencia->PedidoBe
                                // Acrescenta o saldo ao estoque
                                AtualizaSaldoFisico(aCodPro[Pos_V],.t.,Itemped->QtdPro)
                            endif
                        elseif nTipoEstoque = 1
                            AtualizaSaldoFisico(aCodPro[Pos_V],.t.,Itemped->QtdPro)
                        endif
                        do while ItemPed->(!Trava_Reg())
                        enddo
                        Itemped->(dbdelete())
                        ItemPed->(dbcommit())
                    endif
                    do while !ItemPed->(Adiciona())
                    enddo
                    ItemPed->NumPed  := cNumPed
                    ItemPed->CodItem := aCodItem[pos_v]
                    ItemPed->CodPro  := aCodPro[pos_v]
                    ItemPed->QtdPro  := aQtdPro[pos_v]
                    ItemPed->PcoVen  := aPcoVen[pos_v]
                    ItemPed->DscPro  := aDscPro[pos_v]
                    ItemPed->PcoLiq  := aPcoLiq[pos_v]
                    ItemPed->DtaSai  := dData
                    ItemPed->ValDesc := aValDesc[pos_v]
                    ItemPed->Custo := aPcoCus[Pos_V]
                    ItemPed->(dbcommit())
                    ItemPed->(dbunlock())
                    // Retira o saldo do estoque
                    AtualizaSaldoFisico(aCodPro[pos_v],.f.,aQtdPro[pos_v])
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
    // Excluir produto
   elseif Tecla == K_F6
        if Aviso_1( 27,,32,,"Atencao!","Confirma a exclus’o do produto ?",{ [  ^Sim  ], [  ^Nao  ] }, 2, .t. ) = 1
            if ItemPed->(dbsetorder(1),dbseek(cNumPed+aCodPro[pos_v]))
                do while Itemped->(!Trava_Reg())
                enddo
                if nTipoEstoque = 0 
                    // se o pedido da baixa no estoque
                    if Sequencia->PedidoBe
                        // Acrescenta o saldo ao estoque
                        AtualizaSaldoFisico(aCodPro[Pos_V],.t.,Itemped->QtdPro)
                    endif
                elseif nTipoEstoque = 1
                    AtualizaSaldoFisico(aCodPro[Pos_V],.t.,Itemped->QtdPro)
                endif
                Itemped->(dbdelete())
                Itemped->(dbcommit())
                Itemped->(dbunlock())
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
            Mens({"Essa opl‡ao nÆo ‚ permitida na altera‡Æo"})
        endif
   EndIf
	if lastkey() == K_ESC .and. !lIncluir
        if len(aCodItem) = 1
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
static function V_Par( Inclui )
   Local Laco, aCampo := {}, aTitulo := {}, aMascara := {},N_Par := Len( aVencmto )
   local GetList := {},Parcial,cTela,Tel_Ant,MDesPla := Space( 30 ), Area_Ant := Select()
   local nI
   private lCodBco := .f.

   aadd(aCampo,"aVencmto")
   aadd(aCampo,"aParcela")
   aadd(aTitulo,"Vencmto.")
   aadd(aTitulo,"Parcela")
   aadd(aMascara,"")
   aadd(aMascara,"@E 999,999.99")
   cTela := SaveWindow()
   If Plano->TipOpe == "1"  // Se For Avista
      MNumPar := Plano->NumPar
      If Empty( aVencmto ) .or. !(cCodPla == cCodPla2)
         aVencmto := {}
         aParcela := {}
         if !(Plano->PrzPri == 0)
            aadd(aVencmto,dData+Plano->PrzPri)
         else
            aadd( aVencmto, dData )
         endif
         aadd( aParcela, nTotal )
      endif
   Else
      MNumPar := Plano->NumPar
      Parcial := nTotal
      If Plano->FatAtu == 0
         Parcial = round( nTotal / Plano->NumPar, 2)
      Else
         Parcial := ( Parcial * Plano->FatAtu )
      EndIf
      If Empty( aVencmto ) .or. !(nEntrada == nEntrada2) .or. !(cCodPla == cCodPla2) .or. !(nTotal2 == nTotal)
         MEntDif = 0
         If nEntrada > 0
            If Parcial > nEntrada
               MEntDif := ( Parcial - nEntrada )
               MEntDif := round( MEntDif / If( Plano->PerEnt = [S], MNumPar - 1, MNumPar ),2)
               Parcial := ( Parcial + MEntDif )
            ElseIf Parcial < nEntrada
               MEntDif := ( nEntrada - Parcial )
               MEntDif := ( MEntDif / If( Plano->PerEnt = [S], MNumPar - 1, MNumPar ) )
               Parcial := ( Parcial - MEntDif )
            EndIf
         EndIf
         aVencmto := {}
         aParcela := {}
         For Laco := 1 to If( Plano->PerEnt = [S], MNumPar - 1, MNumPar )
            if Laco == 1 .and. !(Plano->PrzPri == 0)
               aadd(aVencmto,dData+(Laco*Plano->PrzPri))
            else
               aadd(aVencmto,dData+(Laco*Plano->PraPar))
            endif
            aadd(aParcela, Parcial )
         Next
         if Plano->PerEnt == "S"
            if !(Soma_Vetor(aParcela) == (nTotal-nEntrada))
               aParcela[1] := aParcela[1] - (Soma_Vetor(aParcela)-(nTotal-nEntrada))
            endif
         else
            if !(Soma_Vetor(aParcela) == nTotal)
               aParcela[1] := aParcela[1] - (Soma_Vetor(aParcela)-nTotal)
            endif
         endif
      endif
   endif
   Window(05,20,18,59,"> Dados da Duplicata(s) <")
   Rodape("Esc-Encerra | F2-Confirma | F8-Abandona")
   Edita_Vet(06,21,17,58,aCampo,aTitulo,aMascara,[SV_Par])
   RestWindow(cTela)
   cCodPla2  := cCodPla
   nEntrada2 := nEntrada
   nTotal2   := nTotal
   If LastKey() == K_ESC
      Return( .t. )
   elseif lastkey() == K_F8
      return(.f.)
   EndIf
Return( .t. )
// ****************************************************************************
function SV_Par(Pos_H,Pos_V,Ln,Cl,Tecla)  // Gets das Duplicatas
   Local MCampo, GetList := {},lNoGet := .f.

   If Tecla == K_ENTER
      If Pos_H = 1 .and. lNoGet
         MCampo = aVencmto[Pos_V]
         @ Ln, Cl Get MCampo Valid !Empty( MCampo )
         setcursor(SC_NORMAL)
         read
         setcursor(SC_NONE)
         if !(lastkey() == K_ESC)
            aVencmto[Pos_V] = MCampo
            KeyBoard Chr( 04 ) + Chr( 13 )
            Return( 3 )
         EndIf
      ElseIf Pos_H = 2 .and. lNoGet
         MCampo = aParcela[Pos_V]
         @ Ln, Cl Get MCampo Pict [@R 999,999,999.99] Valid !Empty( MCampo )
         setcursor(SC_NORMAL)
         read
         setcursor(SC_NONE)
         if !(lastkey() == K_ESC)
            aParcela[Pos_V] := MCampo
            If Pos_V < Len( aParcela )
               KeyBoard Chr( 19 ) + Chr( 24 ) + Chr( 13 )
            endif
            return( 3 )
         endif
      endif
      Return( 2 )
   ElseIf Tecla = K_F2 .or. Tecla == K_F8
      Return( 0 )
   elseif Tecla == K_F11
      Calc()
   EndIf
   Return( 1 )
// ******************************************************************************
procedure iPedCompra(cNumPed)  // Impressao do Pedido de Compra
   local cTela := SaveWindow(),nVideo,lCabec := .t.,nSeq := 1
   local cTexto,nTotal := 0,nSubTotal := 0,nDesc := 0,nVia := 1,nX
   local cImpressoraPadrao,nTipoImp
   local aTipoCo := {"Dinheiro","Duplicata","Cheque","Nota Promissoria","Nota de Debito"}
   private nPagina := 1

   //nTipoImp := Aviso_1(09,,14,,[AtenÎ"o!],[              Tipo de Impressao?           ],{ [  ^Proposta  ], [  ^Cupom Nao Fiscal ] }, 1, .t. )
   nTipoImp := val(Sequencia->ModImpProp)
   if nTipoImp == 1
		If Ver_Imp2(@nVideo)
			if nVideo == 1
				cImpressoraPadrao := ImpressoraPadrao()
				ImprimePedido(cNumPed,cImpressoraPadrao)
				RestWindow(cTela)
				return
            else
                Mens({"Op‡Æo nÆo dispon¡vel"})
                return
			endif
         begin sequence
            Msg(.t.)
            Msg("Aguarde : Imprimindo Proposta")
            //set printer to c:\tmp\pedidos.prn
            Set Device to Print
            for nX := 1 to nVia
               Pedidos->(dbsetorder(1),dbseek(cNumPed))
               ItemPed->(dbsetorder(1),dbseek(cNumPed))
               Plano->(dbsetorder(1),dbseek(Pedidos->CodPla))
               while ItemPed->NumPed == cNumPed .and. ItemPed->(!eof())
                  if lCabec
                     Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
                     Cidades->(dbsetorder(1),dbseek(Clientes->CodCid))
                     Vendedor->(dbsetorder(1),dbseek(Pedidos->CodVen))
                     @ prow()+1,000  say rtrim(cEmpFantasia)
                     @ prow()+1,000  say rtrim(cEmpEndereco)+" "+rtrim(clMunLoj)+"/"+clEstLoj+" Fone: "+transform(clTelLoj,"@!r (999) X999-9999")
                     @ prow()+1,000  say "Usuario: "+PwRegt+"-"+PwNome
                     @ prow()  ,099  say "**** PROPOSTA ****"
                     @ prow()+1,000  say TracoEsquerdo("[ Emissao: "+dtoc(date())+" Hora: "+time()+" Pagina: "+strzero(nPagina,4)+" ]",136,"-")
                     @ prow()+1,000  say TracoCentro("[ Dados do Solicitante ]",136,"-")
                     @ prow()+1,000  say " Cliente: "+Pedidos->CodCli+"-"+Clientes->NomCli
                     @ prow()  ,109  say "No.: "+Pedidos->NumPed
                     
						if Clientes->Entrega == "S"
							@ prow()+1,000 say "Endereco: "+Clientes->EndCli+" Numero: "+Clientes->NUMCLI
							@ prow()  ,109 say "Data: "+dtoc(Pedidos->Data)
							@ prow()+1,000 say "  Compl.: "+Clientes->Compl+" Ponto Ref.: "+Clientes->PReferenci
							@ prow()+1,000 say "  Bairro: "+Clientes->BaiCli+"  Cep: "+Clientes->CepCli
							@ prow()+1,000 say "  Cidade: "+Cidades->NomCid+"/"+Cidades->EstCid+"  Telefone: "+;
   								transform(Clientes->TelCli1,"@kr (999)9999-9999")+"/"+;
   								transform(Clientes->TelCli2,"@kr (999)9999-9999")+"  Celular: "+left(Clientes->CelCli,12)
   						else
   							Cidades->(dbsetorder(1),dbseek(Clientes->CODCIDENTR))
							@ prow()+1,000 say "Endereco: "+Clientes->ENDERENTRE+" Numero: "+Clientes->NUMERENTRE
							@ prow()  ,109 say "Data: "+dtoc(Pedidos->Data)
							@ prow()+1,000 say "  Compl.: "+Clientes->COMPLENTRE+" Ponto Ref.: "+Clientes->REFERENTRE
							@ prow()+1,000 say "  Bairro: "+Clientes->BAIRRENTRE+"  Cep: "+Clientes->CEPENTRE
							@ prow()+1,000 say "  Cidade: "+Cidades->NomCid+"/"+Cidades->EstCid+"  Telefone: "+;
   							transform(Clientes->FONE1ENTRE,"@kr (999)9999-9999")+"/"+;
   							transform(Clientes->FONE2ENTRE,"@kr (999)9999-9999")+"  Celular: "+left(Clientes->CELULAENTR,12)
   						endif
                     	@ prow()+1,000  say "CNPJ/CPF: "+iif(Clientes->TipCli == "F",transform(Clientes->CpfCli,"@r 999.999.999-99"),transform(Clientes->CgcCli,"@r 99.999.999/9999-99"))
                     	@ prow()  ,030  say "Insc.Estadual/RG: "+iif(Clientes->TipCli == "J",Clientes->IEsCli,Clientes->RgCli)+space(15)+"Vendedor: "+Clientes->CodVen+"-"+Vendedor->Nome
                     	@ prow()+1,000  say "Observacao: "+Clientes->Obs
                     	@ prow()+1,000  say TracoCentro("[ Informacoes do(s) Iten(s) ]",136,"-")
                     	//                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                     	//                           1         2         3         4         5         6         7         8         9         0         1         2         3
                     	@ prow()+1,00 say "                                                                                                    Preco             Preco       Valor"
						@ prow()+1,00 say "Seq. Codigo       -Descricao do Produto- ---------------------------- Emb  x Qtd.- Quantidade-   Unitario-%Desc.-   Liquido--     Total"
   						//                 999  1234567890123 12345678901234567890123456789012345678901234567890 1234 x  123 999.999.999 999,999.999 999.99 999,999.99  999,999.99
                     //                                                                                                                      Valor Total a Pagar:    999,999.99
                     lCabec := .f.
                   end
                   Produtos->(dbsetorder(1),dbseek(ItemPed->CodPro))
         			if len(alltrim(ItemPed->CodItem)) <= 6
         				Produtos->(dbsetorder(1),dbseek(alltrim(ItemPed->CodItem)))
         			else
         				Produtos->(dbsetorder(5),dbseek(ItemPed->CodItem))
         			endif
         			@ prow()+1,000 say strzero(nSeq,3)
         			@ prow()  ,005 say ItemPed->CodItem
         			@ prow()  ,019 say Produtos->FanPro
         			@ prow()  ,070 say Produtos->EmbPro
         			@ prow()  ,075 say "x"
         			@ prow()  ,078 say str(Produtos->QteEmb,3)
         			@ prow()  ,082 say ItemPed->QtdPro picture "@e 999,999.999"
         			@ prow()  ,094 say ItemPed->PcoVen picture "@e 999,999.999"
         			@ prow()  ,106 say ItemPed->DscPro picture "@ 999.99"
         			@ prow()  ,113 say ItemPed->PcoLiq picture "@e 999,999.999"
         			@ prow()  ,125 say ItemPed->PcoLiq*ItemPed->QtdPro picture "@e 999,999.99"
                   nSeq  += 1
                   ItemPed->(dbskip())
                   if prow() > 55
                      //nPagina++
                      eject
                      //lCabec := .t.
                   endif
               end
               if prow()+5 > 30
                  eject
               end
               @ prow()+1,125 say "----------"
               @ prow()+1,000 say "Observacao: "+Pedidos->Obs
               @ prow()  ,111 say "Sub-Total:"
               @ prow()  ,125 say Pedidos->SubTotal picture "@e 999,999.99"
               @ prow()+1,100 say "Desconto Promocional:"
               if Pedidos->ValDesc > 0
                  nDesc := Pedidos->ValDesc
               end
               if Pedidos->PerDesc > 0
                  nDesc := Pedidos->SubTotal*(Pedidos->PerDesc/100)
               end
               @ prow()  ,125 say nDesc picture "@e 999,999.99"
               @ prow()+1,000 say "Condicoes de Pagamento: "+rtrim(Plano->DesPla)+" ,conforme a Baixo:"
               @ prow()  ,101 say "Valor Total a Pagar:"
               @ prow()  ,125 say Pedidos->SubTotal-nDesc picture "@e 999,999.99"
               //nLinhas := iif(prow() < 17,17-prow(),1)
               @ prow()+1,000 say TracoCentro("[ Dados da(s) Duplicata(s) ]",136,"-")
               //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
               //                           1         2         3         4         5         6         7         8         9         0         1         2         3
               @ prow()+1,00 say "Duplicata ----- Vencimento --- Valor(R$) ----- Duplicata ----- Vencimento --- Valor(R$) ----- Duplicata ------ Vencimento --- Valor(R$)"
               //                 1234567890123   99/99/9999    999,999.99       1234567890123   99/99/9999    999,999.99       1234567890123    99/99/9999    999,999.99
               DupRec->(dbsetorder(1),dbseek(Pedidos->CodCli+cNumPed))
               do while DupRec->CodCli == Pedidos->CodCli .and. left(DupRec->NumDup,9) == cNumPed .and. DupRec->(!eof())
                  @ prow()+1,00 say DupRec->NumDup
                  @ prow()  ,16 say DupRec->DtaVen
                  @ prow()  ,30 say DupRec->ValDup picture "@e 999,999.99"
                  DupRec->(dbskip())
                  if !(DupRec->CodCli == Pedidos->CodCli .and. left(DupRec->NumDup,9) == cNumPed)
                     exit
                  endif
                  if DupRec->(!eof())
                     @ prow(),47 say DupRec->NumDup
                     @ prow(),63 say DupRec->DtaVen
                     @ prow(),77 say DupRec->ValDup picture "@e 999,999.99"
                  endif
                  DupRec->(dbskip())
                  if !(DupRec->CodCli == Pedidos->CodCli .and. left(DupRec->NumDup,9) == cNumPed)
                     exit
                  endif
                  if DupRec->(!eof())
                     @ prow(),094 say DupRec->NumDup
                     @ prow(),111 say DupRec->DtaVen
                     @ prow(),125 say DupRec->ValDup picture "@e 999,999.99"
                  endif
                  DupRec->(dbskip())
                  if prow() > 30
                     eject
                  endif
               enddo
               @ prow()+2,00 say rtrim(clMunLoj)+" ("+clEstLoj+"), "+DatPort(Pedidos->Data,0)
               @ prow()  ,80 say "______________________________________"
               @ prow()+1,80 say "                 Cliente"
               @ prow(),pcol() say T_ICPP10
               eject
               @ prow(),pcol() say chr(27)+chr(67)+chr(66)
               lCabec := .t.
            next
            set device to screen
            set printer to
            Msg(.f.)
            Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,maxrow()-1,133,200)
         end sequence
      end
    elseif nTipoImp == 2
         nCopias := NumeroDeCopias(19,10)
         ICupomNaoFiscal(cNumPed,nCopias)
         RestWindow(cTela)
         return
    elseif nTipoImp = 3
        iPedCompraGrafico(cNumPed)
        RestWindow(cTela)
        return
    endif
    RestWindow(cTela)
return
// ******************************************************************************
static function vCodigo(cCodProd,pos_v)  // Verifica se o item ja foi cadastrado

   if !(ascan(aCodItem,cCodProd) == 0) .and. !(aCodItem[pos_v] == cCodProd)
      Mens({"Produto j  incluido"})
      return(.f.)
   endif
return(.t.)
// *****************************************************************************
// Gera as Duplicatas
// *****************************************************************************
procedure GeraDupl(cNumPed,cCodCli,cCodVen,cTipoCobra,dData,nTotal,nEntrada)
   local cNumDup

   // ** Gera as Duplicatas
   If Plano->TipOpe == "1" // se for Avista
      cNumDup := cNumPed+"-01/01 "

      while !DupRec->(Adiciona())
      end
      DupRec->CodCli    := cCodCli
      DupRec->NumDup    := cNumDup
      DupRec->CodVen    := cCodVen
      DupRec->TipoCobra := cTipoCobra
      DupRec->DtaEmi    := dData
      DupRec->DtaVen    := dData
      DupRec->ValDup    := nTotal
      DupRec->Comven    := 1
      DupRec->DtaPag    := dData
      DupRec->ValPag    := nTotal
      DupRec->Pedido    := "S"
      DupRec->CodUsu    := PwRegt
      DupRec->(dbcommit())
      DupRec->(dbunlock())

      // ** LanÎa a Baixa da duplicata
      while !BxaDupRe->(Adiciona())
      end
      BxaDupRe->CodCli    := cCodCli
      BxaDupRe->NumDup    := cNumDup
      BxaDupRe->DtaEmi    := dData
      BxaDupRe->TipoCobra := "1"
      BxaDupRe->ValPag    := aParcela[1]
      BxaDupRe->DtaPag    := dData
      BxaDupRe->DtaVen    := aVencmto[1]
      BxaDupRe->(dbcommit())
      BxaDupRe->(dbunlock())
      Grava_Log(cDiretorio,"Baixa Dupl.Receber |Cliente "+cCodCli+" Duplicata "+cNumDup,BxaDupRe->(recno()))
        if Sequencia->ImpRecibo == "S"
            iRecibo(cCodCli,cNumDup)
        endif
	Else // se for A prazo
		Msg(.t.)
		Msg("Aguarde: Gerando duplicatas")
		If Plano->PerEnt = [S] // se tiver entrada
         do while DupRec->(!Adiciona())
         enddo
         DupRec->CodCli    := cCodCli
         DupRec->NumDup    := cNumPed+"-01/"+strzero(Plano->NumPar,2)
         DupRec->CodVen    := cCodVen
         if cTipoCobra == "3"
            DupRec->CodBco := aCodBco[1]
            DupRec->NumAge := aNumAge[1]
            DupRec->NumCon := aNumCon[1]
            DupRec->NumChq := aNumChq[1]
            DupRec->NomCon := aNomCon[1]
         endif
         DupRec->TipoCobra := cTipoCobra
         DupRec->DtaEmi    := dData
         DupRec->DtaVen    := dData
         DupRec->ValDup    := nEntrada
         DupRec->DtaPag    := dData
         DupRec->ValPag    := nEntrada
         DupRec->Pedido    := "S"
         DupRec->CodUsu    := PwRegt
         DupRec->(dbcommit())
         DupRec->(dbunlock())
      Endif
      For Laco := 1 to if( Plano->PerEnt == "S",Plano->NumPar-1,Plano->NumPar)
         do while DupRec->(!Adiciona())
         enddo
         DupRec->CodCli    := cCodCli
         DupRec->NumDup    := cNumPed+"-"+strzero(if(Plano->PerEnt == "S",Laco+1,Laco),2)+"/"+strzero(Plano->NumPar,2)
         DupRec->CodVen    := cCodVen
         DupRec->TipoCobra := cTipoCobra
         DupRec->DtaEmi    := dData
         DupRec->DtaVen    := aVencmto[Laco]
         DupRec->ValDup    := aParcela[Laco]
         DupRec->Pedido    := "S"
         DupRec->CodUsu    := PwRegt
         DupRec->(dbcommit())
         DupRec->(dbunlock())
      next
      Msg(.f.)
   Endif
return
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
static function vSaldo(nQtd,Pos_V)
   local cCampo,nSaldo := 0

   if !(Produtos->CtrlEs == "S")
      return(.t.)
   endif
   nSaldo := Produtos->QteAc02
   if !lIncluir
      nSaldo += aQtdPro[Pos_V]
   end
   if nQtd > nSaldo
      Mens({"Saldo Insuficiente"})
      return(.f.)
   end
return(.t.)
// *****************************************************************************
procedure VerItemPed(cNumPed)
   Local cCor := setcolor(),cTela := SaveWindow()
   local aCampo  := {},aTitulo := {},aMascara := {}
   private aVetor1 := {},aVetor2 := {},aVetor3 := {},aVetor4 := {},aVetor5 := {}
   private aVetor6 := {}

   ItemPed->(dbsetorder(1),dbseek(cNumPed))
   while ItemPed->NumPed == cNumPed .and. ItemPed->(!eof())
      Produtos->(dbsetorder(1),dbseek(ItemPed->CodPro))
      aadd(aVetor1,ItemPed->CodItem)
      aadd(aVetor2,left(Produtos->FanPro,40))
      aadd(aVetor3,Produtos->EmbPro+" x "+str(Produtos->QteEmb,3))
      aadd(aVetor4,ItemPed->QtdPro)
      aadd(aVetor5,ItemPed->PcoLiq)  // ** Pre‡o l¡quido
      aadd(aVetor6,ItemPed->QtdPro*ItemPed->PcoLiq)
      ItemPed->(dbskip())
   end
   aTitulo  := {" Codigo" ,"Descricao","Qtde."        ,"Pco. Venda"   ,"Total"}
   aCampo   := {"aVetor1","aVetor2"   ,"aVetor4"      ,"aVetor5"      ,"aVetor6"}
   aMascara := {"@!"     ,"@!"        ,"@e 99,999.999","@e 99,999.999","@e 9,999,999.99"}
   cTela := SaveWindow()
   Rodape("Esc-Encerra")
   Window(10,00,23,100,"> Itens da Proposta nr.: "+cNumPed+" <")
   Edita_Vet(11,01,22,099,aCampo,aTitulo,aMascara, [XAPAGARU],,,5)
   RestWindow(cTela)
   setcolor(cCor)
   Return
// *****************************************************************************
procedure ImprimePedido(cNumPed,cImpressoraPadrao)
   local cTela := SaveWindow(),aPrn,lCabec := .t.
   local nX,nSeq := 1,nDesc := 0,nQualidade
	private oPrinter,cFont,nPagina := 1

	if !IniciaImpressora(cImpressoraPadrao)
      return
   endif   
   nCopia := 0
   while .t.
      Pedidos->(dbsetorder(1),dbseek(cNumPed))
      ItemPed->(dbsetorder(1),dbseek(cNumPed))
      Plano->(dbsetorder(1),dbseek(Pedidos->CodPla))
        do while ItemPed->NumPed == cNumPed .and. ItemPed->(!eof())
            if lCabec
                Cabecalho()
                lCabec := .f.
            endif
            Produtos->(dbsetorder(1),dbseek(alltrim(ItemPed->CodPro)))
            ImpLinha(oPrinter:prow()+1,000,strzero(nSeq,3))
            ImpLinha(oPrinter:prow()  ,005,ItemPed->CodItem)
            ImpLinha(oPrinter:prow()  ,019,Produtos->FanPro)
            ImpLinha(oPrinter:prow()  ,070,Produtos->EmbPro)
            ImpLinha(oPrinter:prow()  ,075,"x")
            ImpLinha(oPrinter:prow()  ,078,str(Produtos->QteEmb,3))
            ImpLinha(oPrinter:prow()  ,082,transform(ItemPed->QtdPro,"@e 999,999.999"))
            ImpLinha(oPrinter:prow()  ,094,transform(ItemPed->PcoVen,"@e 999,999.999"))
            ImpLinha(oPrinter:prow()  ,106,transform(ItemPed->DscPro,"@ 999.99"))
            ImpLinha(oPrinter:prow()  ,113,transform(ItemPed->PcoLiq,"@e 999,999.999"))
            ImpLinha(oPrinter:prow()  ,125,transform(ItemPed->PcoLiq*ItemPed->QtdPro,"@e 999,999.99"))
            nSeq  += 1
            ItemPed->(dbskip())
            if oPrinter:prow() > 66
                oPrinter:NewPage()
                nPagina++
                lCabec := .t.
            endif
        enddo
        ImpLinha(oPrinter:prow()+1,125,"----------")
        ImpLinha(oPrinter:prow()+1,000,"Observacao: "+Pedidos->Obs)
        ImpLinha(oPrinter:prow()  ,111,"Sub-Total:")
        ImpLinha(oPrinter:prow()  ,125,transform(Pedidos->SubTotal,"@e 999,999.99"))
        ImpLinha(oPrinter:prow()+1,100,"Desconto Promocional:")
        if Pedidos->ValDesc > 0
            nDesc := Pedidos->ValDesc
        endif
        if Pedidos->PerDesc > 0
            nDesc := Pedidos->SubTotal*(Pedidos->PerDesc/100)
        endif
        ImpLinha(oPrinter:prow()  ,125,transform(nDesc,"@e 999,999.99"))
        ImpLinha(oPrinter:prow()+1,000,"Condicoes de Pagamento: "+rtrim(Plano->DesPla)+" ,conforme a Baixo:")
        ImpLinha(oPrinter:prow()  ,101,"Valor Total a Pagar:")
        ImpLinha(oPrinter:prow()  ,125,transform(Pedidos->SubTotal-nDesc,"@e 999,999.99"))
        ImpLinha(oPrinter:prow()+1,000,TracoCentro("[ Dados da(s) Duplicata(s) ]",136,"-"))
      //                             01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
      //                                       1         2         3         4         5         6         7         8         9         0         1         2         3
      ImpLinha(oPrinter:prow()+1,00,"Duplicata ----- Vencimento --- Valor(R$) ----- Duplicata ----- Vencimento --- Valor(R$) ----- Duplicata ------ Vencimento --- Valor(R$)")
      //                             1234567890123   99/99/9999    999,999.99       1234567890123   99/99/9999    999,999.99       1234567890123    99/99/9999    999,999.99
      DupRec->(dbsetorder(1),dbseek(Pedidos->CodCli+cNumPed))
      while DupRec->CodCli == Pedidos->CodCli .and. left(DupRec->NumDup,9) == cNumPed .and. DupRec->(!eof())
         ImpLinha(oPrinter:prow()+1,00,DupRec->NumDup)
         ImpLinha(oPrinter:prow()  ,16,dtoc(DupRec->DtaVen))
         ImpLinha(oPrinter:prow()  ,30,transform(DupRec->ValDup,"@e 999,999.99"))
         DupRec->(dbskip())
         if !(DupRec->CodCli == Pedidos->CodCli .and. left(DupRec->NumDup,9) == cNumPed)
            exit
         endif
         if DupRec->(!eof())
            ImpLinha(oPrinter:prow(),47,DupRec->NumDup)
            ImpLinha(oPrinter:prow(),63,dtoc(DupRec->DtaVen))
            ImpLinha(oPrinter:prow(),77,transform(DupRec->ValDup,"@e 999,999.99"))
         endif
         DupRec->(dbskip())
         if !(DupRec->CodCli == Pedidos->CodCli .and. left(DupRec->NumDup,9) == cNumPed)
            exit
         endif
         if DupRec->(!eof())
            ImpLinha(oPrinter:prow(),094,DupRec->NumDup)
            ImpLinha(oPrinter:prow(),111,dtoc(DupRec->DtaVen))
            ImpLinha(oPrinter:prow(),125,transform(DupRec->ValDup,"@e 999,999.99"))
         endif
         DupRec->(dbskip())
         if oPrinter:prow() > 66
            oPrinter:NewPage()
         endif
      enddo
      Cidades->(dbsetorder(1),dbseek(cEmpCodcid))
      ImpLinha(oPrinter:prow()+2,00,rtrim(Cidades->NomCid)+" ("+Cidades->EstCid+"), "+DatPort(Pedidos->Data,0))
      ImpLinha(oPrinter:prow()  ,80,"--------------------------------------")
      ImpLinha(oPrinter:prow()+1,80,"                 Cliente")
      ImpLinha(oPrinter:prow()+4,00,"")
      nCopia += 1
      lCabec := .t.
      if nSeq > 12
         oPrinter:NewPage()
      endif
      nSeq := 1
      if nCopia == 2
         exit
      endif
      // *ImpLinha(oPrinter:prow()+7,00,"")  // ** 13/20/2015
   enddo
   oPrinter:enddoc()
   oPrinter:Destroy()
   RestWindow(cTela)
return
// *****************************************************************************
procedure Cabecalho

   //Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
   //Cidades->(dbsetorder(1),dbseek(Clientes->CodCid))
   //Vendedor->(dbsetorder(1),dbseek(Pedidos->CodVen))
   Cidades->(dbsetorder(1),dbseek(cEmpCodcid))
   
   oPrinter:SetFont(cFont,,11)
   ImpNegrito(oPrinter:prow()+1,00,rtrim(cEmpFantasia))
   // ** define como 17 cpp a impress’o
   oPrinter:SetFont(cFont,,18)
   ImpLinha(oPrinter:prow()+1,00,rtrim(cEmpEndereco)+" "+rtrim(Cidades->NomCid)+"/"+cEmpEstCid+" Fone: "+transform(cEmpTelefone1,"@!r (999) X999-9999"))
   ImpLinha(oPrinter:prow()+1,00,"Usuario: "+PwRegt+"-"+PwNome)
   oPrinter:SetFont(cFont,,11)
   ImpNegrito(oPrinter:prow(),60,"**** PROPOSTA ****")
   oPrinter:SetFont(cFont,,18)
   
   Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
   Cidades->(dbsetorder(1),dbseek(Clientes->CodCid))
   Vendedor->(dbsetorder(1),dbseek(Pedidos->CodVen))
   ImpLinha(oPrinter:prow()+1,000,TracoEsquerdo("[ Emissao: "+dtoc(date())+" Hora: "+time()+" Pagina: "+strzero(nPagina,4)+" ]",136,"-"))
   ImpLinha(oPrinter:prow()+1,000,TracoCentro("[ Dados do Solicitante ]",136,"-"))
   ImpLinha(oPrinter:prow()+1,000," Cliente: "+Pedidos->CodCli+"-"+Clientes->NomCli)
   ImpNegrito(oPrinter:prow(),109,"No.: "+Pedidos->NumPed)
	if Clientes->Entrega == "S"
		ImpLinha(oPrinter:prow()+1,000,"Endereco: "+Clientes->EndCli+" Numero: "+Clientes->NUMCLI)
		ImpNegrito(oPrinter:prow(),109,"Data: "+dtoc(Pedidos->Data))
		ImpLinha(oPrinter:prow()+1,000,"  Compl.: "+Clientes->Compl+" Ponto Ref.: "+Clientes->PReferenci)
		ImpLinha(oPrinter:prow()+1,000,"  Bairro: "+Clientes->BaiCli+"  Cep: "+Clientes->CepCli)
		ImpLinha(oPrinter:prow()+1,000,"  Cidade: "+Cidades->NomCid+"/"+Cidades->EstCid+"  Telefone: "+;
   				transform(Clientes->TelCli1,"@kr (999)9999-9999")+"/"+;
   				transform(Clientes->TelCli2,"@kr (999)9999-9999")+"  Celular: "+left(Clientes->CelCli,12))
   	else
   		Cidades->(dbsetorder(1),dbseek(Clientes->CODCIDENTR))
		ImpLinha(oPrinter:prow()+1,000,"Endereco: "+Clientes->ENDERENTRE+" Numero: "+Clientes->NUMERENTRE)
		ImpNegrito(oPrinter:prow(),109,"Data: "+dtoc(Pedidos->Data))
		ImpLinha(oPrinter:prow()+1,000,"  Compl.: "+Clientes->COMPLENTRE+" Ponto Ref.: "+Clientes->REFERENTRE)
		ImpLinha(oPrinter:prow()+1,000,"  Bairro: "+Clientes->BAIRRENTRE+"  Cep: "+Clientes->CEPENTRE)
		ImpLinha(oPrinter:prow()+1,000,"  Cidade: "+Cidades->NomCid+"/"+Cidades->EstCid+"  Telefone: "+;
   				transform(Clientes->FONE1ENTRE,"@kr (999)9999-9999")+"/"+;
   				transform(Clientes->FONE2ENTRE,"@kr (999)9999-9999")+"  Celular: "+left(Clientes->CELULAENTR,12))
   	endif
   ImpLinha(oPrinter:prow()+1,000,"CNPJ/CPF: "+iif(Clientes->TipCli == "F",transform(Clientes->CpfCli,"@r 999.999.999-99"),transform(Clientes->CgcCli,"@r 99.999.999/9999-99")))
   ImpLinha(oPrinter:prow()  ,030,"Insc.Estadual/RG: "+iif(Clientes->TipCli == "J",Clientes->IEsCli,Clientes->RgCli)+space(15)+"Vendedor: "+Clientes->CodVen+"-"+Vendedor->Nome)
   ImpLinha(oPrinter:prow()+1,000,"Observacao: "+Clientes->Obs)
   ImpLinha(oPrinter:prow()+1,000,TracoCentro("[ Informacoes do(s) Iten(s) ]",136,"-"))
   //                             01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
   //                                       1         2         3         4         5         6         7         8         9         0         1         2         3
   ImpLinha(oPrinter:prow()+1,00,"                                                                                                    Preco             Preco       Valor")
   ImpLinha(oPrinter:prow()+1,00,"Seq. Codigo       -Descricao do Produto- ---------------------------- Emb  x Qtd.- Quantidade-   Unitario-%Desc.-   Liquido--     Total")
   //                             999  1234567890123 12345678901234567890123456789012345678901234567890 1234 x  123 999.999.999 999,999.999 999.99 999,999.99  999,999.99
   //                                                                                                                                              ----------
   //                                                                                                                                Sub-Total:    999.999.99
   //                                                                                                                     Desconto Promocional:    999,999.99
   //                                                                                                                      Valor Total a Pagar:    999,999.99
return
// *****************************************************************************   
// Imprime o pedido como cupom nÆo fiscal
procedure ICupomNaoFiscal(cNumPed,nCopias)
   local nContador,nDesc,nI,lTempo

   lTempo := nCopias > 1

   for nI := 1 to nCopias
      nContador := 1
      nDesc := 0
      Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
      Vendedor->(dbsetorder(1),dbseek(Pedidos->CodVen))
      Plano->(dbsetorder(1),dbseek(Pedidos->CodPla))
      Cidades->(dbsetorder(1),dbseek(cEmpCodcid))
    
      cComando := ""
      cComando += 'ESCPOS.ativar' + CRLF
      cComando += 'ESCPOS.imprimirlinha("</zera>")' + CRLF
      cComando += 'ESCPOS.imprimirlinha("</ce><e>'+left(rtrim(cEmpFantasia),38)+'</e>")'+CRLF
      cComando += 'ESCPOS.imprimirlinha("</ae><c>'+rtrim(cEmpEndereco)+","+cEmpNumero+rtrim(cEmpBairro)+" "+rtrim(Cidades->NomCid)+"-"+;
                    Cidades->EstCid+'</c>")'+CRLF
      cComando += 'ESCPOS.imprimirlinha("<c>'+"Fone: "+transform(cEmpTelefone1,"@r (999)99999-9999")+' '+;
            transform(cEmpTelefone2,"@r (999)99999-9999")+'</c>")'+CRLF
      cComando += 'ESCPOS.imprimirlinha("</linha_simples>")'+CRLF            
      cComando += 'ESCPOS.imprimirlinha('+PADC("CUPOM NAO FISCAL", 48 )+')'+CRLF
      cComando += 'ESCPOS.imprimirlinha('+"Proposta No: "+cNumPed+" "+dtoc(Pedidos->Data)+" "+time()+')'+CRLF
      cComando += 'ESCPOS.imprimirlinha('+"    Cliente: "+Pedidos->CodCli+" "+left(Clientes->NomCli,30)+')'+CRLF
      cComando += 'ESCPOS.imprimirlinha('+"   Vendedor: "+Pedidos->CodVen+" "+Vendedor->Nome+')'+CRLF
      cComando += 'ESCPOS.imprimirlinha("</linha_simples>")'+CRLF
      cComando += 'ESCPOS.imprimirlinha("'+'#|COD|DESC|QTD|UN|VL UN R$|(VLTR R$)*|VL ITEM R$"'+')'+CRLF
      cComando += 'ESCPOS.imprimirlinha("</linha_simples>")'+CRLF    
      ItemPed->(dbsetorder(1),dbgotop(),dbseek(cNumPed))
      do while ItemPed->NumPed == cNumPed .and. ItemPed->(!eof())
         Produtos->(dbsetorder(1),dbseek(ItemPed->CodPro))
         cComando += 'ESCPOS.imprimirlinha('+'"<c>'+strzero(nContador,3,0)+;
                    space(02)+ItemPed->CodItem+;
                    space(02)+left(Produtos->FanPro,30)+'</c>")'+CRLF
         cComando += 'ESCPOS.imprimirlinha('+'"<c>'+;
                    transform(ItemPed->QtdPro,"@e 99,999.999")+;
                    space(02)+Produtos->EmbPro+;
                    space(02)+'X'+;
                    space(02)+transform(ItemPed->PcoVen,"@e 99,999.999")+;
                    space(02)+transform(ItemPed->DscPro,"@e 99.99")+"%"+;
                    space(02)+transform(ItemPed->PcoLiq,"@e 99,999.999")+;
                    space(02)+transform(ItemPed->PcoLiq*ItemPed->QtdPro,"@e 999,999.99")+;
                    '</c>")'+CRLF
         ItemPed->(dbskip())
         if ItemPed->(eof())
            exit
         endif
         nContador += 1
      enddo
      cComando += 'ESCPOS.imprimirlinha("</linha_simples>")'+CRLF
      cTexto   := 'Itens: '+strzero(nContador,3,0)+space(15)+'Sub-Total:'+transform(Pedidos->SubTotal,"@e 999,999.99")
      cComando += 'ESCPOS.imprimirlinha("'+cTexto+'")'+CRLF
      if Pedidos->ValDesc > 0
         nDesc := Pedidos->ValDesc
      endif
      if Pedidos->PerDesc > 0
         nDesc := Pedidos->SubTotal*(Pedidos->PerDesc/100)
      endif
      cComando += 'ESCPOS.imprimirlinha("'+space(24)+" Desconto: "+transform(nDesc,"@e 999,999.99")+'")'+CRLF
      cComando += 'ESCPOS.imprimirlinha("<n>'+space(24)+"    Total: "+transform(Pedidos->SubTotal-nDesc,"@e 999,999.99")+'</n>")'+CRLF
      cComando += 'ESCPOS.imprimirlinha("</linha_simples>")'+CRLF
      // ** Forma de pagamento
      cComando += 'ESCPOS.imprimirlinha("'+"Pagamento: "+Plano->DesPla+'")'+CRLF
      if Plano->TipOpe = "2" 
         cComando += 'ESCPOS.imprimirlinha("'+"Duplicata       Vencimento      Valor"+'")'+CRLF
         DupRec->(dbsetorder(1),dbseek(Pedidos->CodCli+cNumPed))
         do while DupRec->CodCli == Pedidos->CodCli .and. left(DupRec->NumDup,9) == cNumPed .and. DupRec->(!eof())
            cValor := transform(DupRec->ValDup,"@e 999,999.99")
            cComando += 'ESCPOS.imprimirlinha("'+Duprec->Numdup+dtoc(Duprec->DtaVen)+' '+cValor+'")'+CRLF
            Duprec->(dbskip())
         enddo
      endif
      if !empty(Pedidos->Obs)
         cComando += 'ESCPOS.imprimirlinha("</linha_simples>")'+CRLF
         cComando += 'ESCPOS.imprimirlinha("'+Pedidos->Obs+'")'+CRLF
      endif
      // ***********************************************************    
      if !empty(Sequencia->MCupom1) .or. !empty(Sequencia->MCupom2) .or. !empty(Sequencia->MCupom3)
         cComando += 'ESCPOS.imprimirlinha("</linha_simples>")'+CRLF
         if !empty(Sequencia->MCupom1)
            cComando += 'ESCPOS.imprimirlinha("</ce> '+rtrim(Sequencia->MCupom1)+'")'+CRLF
         endif
         if !empty(Sequencia->MCupom2)
            cComando += 'ESCPOS.imprimirlinha("</ce> '+rtrim(Sequencia->MCupom2)+'")'+CRLF
         endif
         if !empty(Sequencia->MCupom3)
            cComando += 'ESCPOS.imprimirlinha("</ce> '+rtrim(Sequencia->MCupom3)+'")'+CRLF
         endif
      endif
      cComando += 'ESCPOS.imprimirlinha("</pular_linhas>")'+CRLF
      cComando += 'ESCPOS.imprimirlinha("</corte_total>")'+CRLF
      cComando += 'ESCPOS.desativar'+CRLF
      Memowrit(rtrim(Sequencia->dirnfe)+"\escpos.txt",cComando)
      MemoWrit(rtrim(Sequencia->dirnfe)+"\entnfe.txt",cComando)
      if lTempo
         inkey(1)
      endif
   next
return
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
        return(.f.)
	endif
	if !OpenCidades()
		FechaDados()
		Msg(.f.)
        return(.f.)
	endif
	if !OpenPedidos()
		FechaDados()
		Msg(.f.)
        return(.f.)
	endif
	if !OpenItemPed()
		FechaDados()
		Msg(.f.)
        return(.f.)
	endif
	if !OpenPlano()
		FechaDados()
		Msg(.f.)
        return(.f.)
	endif
	if !OpenDupRec()
		FechaDados()
		Msg(.f.)
        return(.f.)
	endif
	if !OpenVendedor()
		FechaDados()
		Msg(.f.)
        return(.f.)
	endif
	if !OpenBanco()
		FechaDados()
		Msg(.f.)
        return(.f.)
	endif
	if !OpenCheques()
		FechaDados()
		Msg(.f.)
        return(.f.)
	endif
	if !OpenBxaDupRe()
		FechaDados()
		Msg(.f.)
        return(.f.)
	endif
	if !OpenCaixa()
		FechaDados()
		Msg(.f.)
        return(.f.)
	endif
	if !OpenMovCxa()
		FechaDados()
		Msg(.f.)
        return(.f.)
	endif
	if !OpenNatureza()
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
// *****************************************************************************   
static procedure GetPedido

    do while .t.
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))        
        @ 30,15 get cCodPla    picture "@k 99";
			when Rodape("Esc-Encerra | F4-Planos de Pagamento");
			valid vPlano(@cCodPla)
        @ 29,41 get nEntrada   picture "@ke 999,999.99";
			when Plano->PerEnt == "S" valid iif(lastkey() == K_UP,.t.,nEntrada > 0 .and. nEntrada < nTotal)
        @ 31,15 get cTipoCobra picture "@k 9";
			when Rodape("Esc-Encerra") valid iif(lastkey() == K_UP,.t.,vTipoCobra(cTipoCobra) .and. v_par())
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
static procedure GetItemsPedidos
   
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
        Edita_Vet(09,01,27,99,aCampo,aTitulo,aMascara,"vPedido",,,,2)
        if lastkey() == K_F8
            if Aviso_1( 09,,14,,[Atencao!],"Confirma o cancelamento da proposta ?",{ [  ^Sim  ], [  ^Nao  ] }, 2, .t. ) = 1
                lAbandonar := .t.
                exit
            endif
	   elseif lastkey() == K_F2
	      // Verifica se o cliente controle o limite
	      if Clientes->Limite > 0
	         nDebitos := VerDebitos(cCodCli)
	         if (nDebitos+Soma_Vetor(aTotPro)) > Clientes->Limite
	            If Aviso_1(17,, 22,, [AtenÎ"o!], [O cliente estÿ sem limite de cr'dito, continuar?], { [  ^Sim  ], [  ^N"o  ] }, 2, .t. ) = 1
	               exit
	            else
	               loop
	            Endif
	         endif
	      endif
	      if !Confirm("Confirma os Itens da Proposta")
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
    
procedure iPedCompraGrafico(cNumero)  // Impressao do Pedido de Compra
   local cTela := SaveWindow(),nVideo,lCabec := .t.,nSeq := 1
   local cTexto,nTotal := 0,nSubTotal := 0,nDesc := 0,nVia := 1,nX
   local aTipoCo := {"Dinheiro","Duplicata","Cheque","Nota Promissoria","Nota de Debito"}
   private nPagina := 1

   cTexto := "Solicitamos a essa firma fornecer-nos, nas condicoes aqui especificadas, o(s) material(is) acima discriminado(s)"
    //If Aviso_1(09,,14,,[Aten‡„o!],[Imprimir Proposta ?],{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
        // se o modelo de impressÆo da proposta for tipo cupom nÆo fiscal
        if Sequencia->ModPropost = "2"
            ICupomNaoFiscal(cNumero)
            return
        endif
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
            ItemPed->(dbsetorder(1),dbseek(cNumero))
            nSeq := 1
            Msg(.t.)
            Msg("Aguarde: Processando as informa‡äes")
            do while ItemPed->NumPed == cNumero .and. ItemPed->(!eof())
                Produtos->(dbsetorder(1),dbseek(ItemPed->CodPro))
                Temp23->(dbappend())
                Temp23->ordem := strzero(nSeq,3)
                Temp23->codpro := ItemPed->CodPro
                Temp23->descricao := Produtos->FanPro
                Temp23->unidade := Produtos->EmbPro
                Temp23->quantidade := ItemPed->QtdPro 
                Temp23->valor := ItemPed->PcoLiq 
                Temp23->total := (ItemPed->PcoLiq*ItemPed->Qtdpro)
                ItemPed->(dbskip())
            enddo
            nCampo := 1
            DupRec->(dbsetorder(1),dbseek(Pedidos->CodCli+cNumero))
            do while DupRec->CodCli == Pedidos->CodCli .and. left(DupRec->NumDup,9) == cNumero .and. DupRec->(!eof())
                if nCampo = 1
                    Temp24->(dbappend())
                    Temp24->Numdup1 := DupRec->NumDup
                    Temp24->DtaVen1 := DupRec->DtaVen
                    Temp24->ValDup1 := DupRec->ValDup
                elseif nCampo = 2
                    Temp24->Numdup2 := DupRec->NumDup
                    Temp24->DtaVen2 := DupRec->DtaVen
                    Temp24->ValDup2 := DupRec->ValDup
                endif
                DupRec->(dbskip())
                nCampo += 1
                if nCampo > 2                           
                    nCampo := 1
                endif
            enddo
            Msg(.f.)
            select Clientes
            set relation to codcid into cidades
            Clientes->(dbgotop())
            Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
            Plano->(dbsetorder(1),dbseek(Pedidos->CodPla))
            oFrPrn := frReportManager():new()
            oFrPrn:LoadLangRes('english.xml')                     //arquivo de idioma
            oFrprn:SetWorkArea("Pedidos",select("pedidos"))
            oFrprn:SetWorkArea("Clientes",select("Clientes"))
            oFrprn:SetWorkArea("Temp23",select("Temp23"))
            oFrprn:SetWorkArea("Temp24",select("Temp24"))
            
            
            oFrPrn:SetWorkArea("CIDADES", Select("CIDADES"))
            oFrPrn:SetResyncPair('Clientes', 'Cidades')  // Ativa o set relation no FastReport

            
            oFrprn:LoadFromFile('proposta.fr3')
            oFrPrn:AddVariable("variaveis","empresa","'"+cEmpFantasia+"'")
            oFrPrn:AddVariable("Pedido","numero","'"+cNumero+"'")
            oFrPrn:AddVariable("Pedido","plano","'"+Plano->DesPla+"'") 
            
            oFrPrn:AddVariable("Clientes","cnpjcpf","'"+iif(Clientes->TipCli == "F",transform(Clientes->CpfCli,"@r 999.999.999-99"),transform(Clientes->CgcCli,"@r 99.999.999/9999-99"))+"'")
            oFrPrn:AddVariable("Clientes","ierg","'"+iif(Clientes->TipCli == "J",Clientes->IEsCli,Clientes->RgCli)+"'")
            
            //oFrPrn:SetMasterDetail('Temp21','ItemEntr',{|| Temp21->Entrega}) // Filtra Itens da Venda
            oFrPrn:PrepareReport()
            
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
   //endif
   RestWindow(cTela)
   return
    
    
	
// ** Fim do Arquivo.
