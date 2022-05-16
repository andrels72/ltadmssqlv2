/*************************************************************************
 * Sistema......: Controle de Ceramica
 * Versao.......: 2.00
 * Identificacao: Manutencao de Fornecedores
 * Prefixo......: LtSCC
 * Programa.....: Fornece.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 18 de Agosto de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConProdFor(lAbrir)
   local oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados
   local nCursor := setcursor(),cCor := setcolor(),cCodFor := space(04)
   private nRecno
   	
	if !AbrirArquivos()
		return
	endif
	AtivaF4()
	Window(02,00,maxrow()-1,100,"> Consulta de Produtos do fornecedor <")
	setcolor(Cor(11))
	//           1234567890123 
	@ 04,01 say "Fornecedor:"
	@ 05,01 say replicate(chr(196),99)
	setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
	@ 04,13 get cCodFor picture "@k 9999";
			when Rodape("Esc-Emcerra | F4-Fornecedores | Deixe em branco para todos");
			valid iif(empty(cCodFor),.t.,Busca(Zera(@cCodFor),"Fornecedor",1,row(),col(),"'-'+left(Fornecedor->RazFor,50)",{"Fornecedor Nao Cadastrado"},.f.,.f.,.f.))
	setcursor(SC_NORMAL)
	read
	setcursor(SC_NONE)
	if lastkey() == K_ESC
		setcursor(nCursor)
		setcolor(cCor)
		DesativaF4()
		FechaDados()
		RestWindow(cTela)
		return
	endif
	dbselectarea("ProdutoFornecedor")
	if !empty(cCodFor)
		ProdutoFornecedor->(dbsetorder(2),dbgotop())
		ProdutoFornecedor->(ordscope(0,cCodFor))
		ProdutoFornecedor->(ordscope(1,cCodFor))
		ProdutoFornecedor->(dbgotop())
	else
		ProdutoFornecedor->(dbsetorder(1),dbgotop())
	endif
	Rodape("Esc-Encerrar")
	setcolor(cor(5))
	oBrow := tbrowsedb(06,01,maxrow()-2,99)
   oBrow:headSep   := SEPH
   oBrow:colSep    := SEPV
   oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)
    //oBrow:addcolumn(tbcolumnnew("Fornecedor",;
   	//        {|| Fornecedor->(dbsetorder(1),dbseek(ProdutoFornecedor->CodFor),ProdutoFornecedor->CodFor+"-"+;
   	//	   left(Fornecedor->RazFor,30))}))
   oBrow:addcolumn(tbcolumnnew("Prod. Fornecedor",{|| ProdutoFornecedor->ProdFor }))
   oBrow:addcolumn(tbcolumnnew("Produto",;
   	{|| Produtos->(dbsetorder(1),dbseek(ProdutoFornecedor->CodPro),ProdutoFornecedor->CodPro+"-"+left(Produtos->DesPro,70))}))
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
         	nTecla := INKEY(0)
      	endif
      	if !TBMoveCursor(nTecla,oBrow)
         	if nTecla == K_ESC   // ESC pressionado - Encerra a Consulta
            	lFim := .T.
         	endif
		endif
	enddo
	if !lAbrir
		setcursor(nCursor)
		setcolor(cCor)
	else
		FechaDados()
	endif
   	DesativaF4()
   	RestWindow( cTela )
	return

procedure IncProdFor
	local getlist := {},cTela := SaveWindow()
	local cCodFor,cProdFor,cCodPro,lLimpa := .t.
	
	if !AbrirArquivos()
		return
	endif	
	AtivaF4()
	TelProdFor(1)
	do while .t.
		if lLimpa
			cCodFor  := space(04)
			cProdFor := space(15)
			cCodPro  := space(06)
			lLimpa := .f.
		endif
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 10,31 get cCodFor picture "@k 9999";
				when Rodape("Esc-Encerra | F4-Fornecedores");
				valid Busca(Zera(@cCodFor),"Fornecedor",1,row(),col(),"'-'+Fornecedor->FanFor",{"Fornecedor Nao Cadastrado"},.f.,.f.,.f.)
		@ 11,31 get cProdFor picture "@k";
				when Rodape("Esc-Encerra");
				valid NoEmpty(cProdFor)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		if ProdutoFornecedor->(dbsetorder(1),dbseek(cCodFor+cProdFor))
			Mens({"Produto do Fornecedor ja cadastrado"})
			loop
		endif
		@ 12,31 get cCodPro picture "@k 999999";
				when Rodape("Esc-Encerra | F4-Produtos");
				valid Busca(Zera(@cCodPro),"Produtos",1,row(),col(),"'-'+Produtos->FanPro",{"Fornecedor Nao Cadastrado"},.f.,.f.,.f.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			loop
		endif
		if !Confirm("Confirma a Inclusao")
			loop
		endif
		do while ProdutoFornecedor->(!Adiciona())
		enddo
		ProdutoFornecedor->CodFor := cCodFor
		ProdutoFornecedor->ProdFor := cProdFor
		ProdutoFornecedor->CodPro  := cCodPro
		ProdutoFornecedor->(dbcommit())
		ProdutoFornecedor->(dbunlock())
		lLimpa := .t.
	enddo
	DesativaF4()
	FechaDados()
	RestWindow(cTela)
	return
	
procedure AltProdFor
	local getlist := {},cTela := SaveWindow()
	local cCodFor,cProdFor,cCodPro
	
	if !AbrirArquivos()
		return
	endif	
	AtivaF4()
	TelProdFor(2)
	do while .t.
		cCodFor  := space(04)
		cProdFor := space(15)
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 10,31 get cCodFor picture "@k 9999";
				when Rodape("Esc-Encerra | F4-Fornecedores");
				valid Busca(Zera(@cCodFor),"Fornecedor",1,row(),col(),"'-'+left(Fornecedor->RazFor,40)",{"Fornecedor Nao Cadastrado"},.f.,.f.,.f.)
		@ 11,31 get cProdFor picture "@k";
				when Rodape("Esc-Encerra | Deixe em branco para todos os produtos");
				valid PegarProdutos(cCodFor,@cProdFor)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		if !ProdutoFornecedor->(dbsetorder(1),dbseek(cCodFor+cProdFor))
			Mens({"Produto do Fornecedor Nao cadastrado"})
			loop
		endif
		cCodPro := ProdutoFornecedor->CodPro
		@ 12,31 get cCodPro picture "@k 999999";
				when Rodape("Esc-Encerra | F4-Produtos");
				valid Busca(Zera(@cCodPro),"Produtos",1,row(),col(),"'-'+Produtos->FanPro",{"Fornecedor Nao Cadastrado"},.f.,.f.,.f.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			loop
		endif
		if !Confirm("Confirma a Alteracao")
			loop
		endif
		do while ProdutoFornecedor->(!Trava_Reg())
		enddo
		ProdutoFornecedor->CodPro  := cCodPro
		ProdutoFornecedor->(dbcommit())
		ProdutoFornecedor->(dbunlock())
	enddo
	FechaDados()
	RestWindow(cTela)
	return

procedure ExcProdFor
	local getlist := {},cTela := SaveWindow()
	local cCodFor,cProdFor,cCodPro

	if !AbrirArquivos()
		return
	endif
	AtivaF4()
	TelProdFor(3)
	do while .t.
		cCodFor  := space(04)
		cProdFor := space(15)
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 10,31 get cCodFor picture "@k 9999";
				when Rodape("Esc-Encerra | F4-Fornecedores");
				valid Busca(Zera(@cCodFor),"Fornecedor",1,row(),col(),"'-'+left(Fornecedor->RazFor,40)",{"Fornecedor Nao Cadastrado"},.f.,.f.,.f.)
		@ 11,31 get cProdFor picture "@k";
				when Rodape("Esc-Encerra");
				valid PegarProdutos(cCodFor,@cProdFor)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		if !ProdutoFornecedor->(dbsetorder(1),dbseek(cCodFor+cProdFor))
			Mens({"Produto do Fornecedor Nao cadastrado"})
			loop
		endif
		@ 12,31 say ProdutoFornecedor->CodPro
		if !Confirm("Confirma a Exclusao",2)
			loop
		endif
		do while ProdutoFornecedor->(!Trava_Reg())
		enddo
		ProdutoFornecedor->(dbdelete())
		ProdutoFornecedor->(dbcommit())
		ProdutoFornecedor->(dbunlock())
	enddo
	DesativaF4()
	FechaDados()
	RestWindow(cTela)
	return

static procedure TelProdFor(nModo)
	local aTitulos := {"InclusÆo","Altera‡Æo","ExclusÆo"}

	Window(08,00,14,81,"> "+aTitulos[nModo]+" de Prod. Fornecedor <")
	setcolor(Cor(11))
	//           1234567890123456789012345678901
	//                    1         2
	@ 10,01 say "                  Fornecedor:"
	@ 11,01 say "C¢digo produto no fornecedor:"
	@ 12,01 say "   C¢digo produto no sistema:"
	return

static function AbrirArquivos
	
   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenFornecedor()
      FechaDados()
      Msg(.f.)
      return(.f.)
   endif
   if !OpenProdutos()
      FechaDados()
      Msg(.f.)
      return(.f.)
   endif
   if !OpenProdutoFornecedor()
      FechaDados()
      Msg(.f.)
      return(.f.)
   endif
   Msg(.f.)
   return(.t.)
   
static function PegarProdutos(cCodFor,cProdFor)
	local cTela,aTitulo := {},aCampo := {},aMascara := {},cCor := setcolor()
	local nLin1 := 15  ,nCol1 := 00,nLin2 := maxrow()-1,nCol2 := 90
	private aProdFor := {},aCodPro := {},aDesPro := {},nPos

	if !empty(cProdFor)
		return(.t.)
	endif
	if !ProdutoFornecedor->(dbsetorder(2),dbseek(cCodFor))
		return(.f.)
	endif
	Produtos->(dbsetorder(1))
	do while ProdutoFornecedor->CodFor == cCodFor .and. ProdutoFornecedor->(!eof())
		Produtos->(dbseek(ProdutoFornecedor->CodPro))
		aadd(aProdFor,ProdutoFornecedor->ProdFor)
		aadd(aCodPro,ProdutoFornecedor->CodPro)
		aadd(aDesPro,Produtos->FanPro)
		ProdutoFornecedor->(dbskip())
	enddo
	cTela := SaveWindow()
	aCampo   := {"aProdFor","aCodPro","aDesPro"}
	aTitulo  := {"Prod.Fornecedor","Cod.Produto","Descricao"}
	aMascara := {"@!","@!","@!"}
	Window(nLin1,nCol1,nLin2,nCol2," Produtos do Fornecedor ")
	Edita_Vet(nLin1+1,nCol1+1,nLin2-1,nCol2-1,aCampo,aTitulo,aMascara, [XAPAGARU],,,4)
	RestWindow(cTela)
	setcolor(cCor)
	if nPos == 0
		return(.f.)
	endif
	cProdFor := aProdFor[nPos]
	return(.t.)
	
// ** Fim do arquivo.
	
