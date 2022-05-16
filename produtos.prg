/*************************************************************************
 * Sistema......: Administrativo
 * Identificacao: Manutencao de Produtos
 * Prefixo......: LtSCC
 * Programa.....: Produtos.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 20 de Agosto de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

// Consulta todos os produtos com ou sem saldo
// ordem: fanpro
procedure ConProduto(lAbrir,lRetorno) 
   local getlist := {},oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados1
   local cDados2,nCursor := setcursor(),cCor := setcolor(),lTop,cTela2,lSaiMenu
   local aItem[05],aCampo := {},aTitulo := {},aMascara := {},cQuery,oQuery,cTipo
	local nLinha1  := 02,nColuna1 := 00,nLinha2  := 33,nColuna2 := 100
   local cCampo
   private nRecno,cCodLoja

	if !lAbrir
		setcursor(SC_NONE)
	endif
   cQuery := "SELECT id,fanpro,embpro,qteemb,pcoven,qteac01,qteac02 "
   cQuery += "FROM administrativo.produtos ORDER BY fanpro LIMIT 1"

   Msg(.t.)
   Msg("Aguarde: pesquisando as informa‡äes")
   if !ExecuteSql(cQuery,@oQuery,{"Falha: pesquisar fornecedor"},"sqlerro")
       oQuery:close()
       Msg(.f.)
       RestWindow(cTela)
       return
   endif
   Msg(.f.)
   if oQuery:Lastrec() = 0
       Mens({"NÆo existe informa‡Æo pesquisada"})
       oQuery:close()
       RestWindow(cTela)
       return
   endif

   cTipo := space(01)
	
	Window(nLinha1,nColuna1,nLinha2,nColuna2,"> Consulta de Produtos Geral <")  // 23
   setcolor(Cor(11))
   //
   @ 03,01 say "Tipo:"
   @ 03,11 say "Pesquisar:"
   @ 04,01 say replicate(chr(196),99)
   setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
   @ 03,07 get cTipo picture "@k 9";
            when Rodape("Esc-Encerra");
            valid MenuArray(@cTipo,{{"1","Codigo"},{"2","Cod. barras"},{"3","Descricao"},{"4","Desc. reduzida"}})
   setcursor(SC_NORMAL)
   read
   setcursor(SC_NONE)
   if lastkey() == K_ESC    
       if !lAbrir
           setcursor(nCursor)
           setcolor(cCor)
       endif
       RestWindow( cTela )
       return
   endif
   if cTipo = '1'
      cPesquisa := space(06)
   elseif cTipo = '2'
      cPesquisa := space(14)
   else 
      cPesquisa := space(06)
   endif
   @ 03,22 get cPesquisa picture "@K"
   setcursor(SC_NORMAL)
   read
   setcursor(SC_NONE)
   if lastkey() == K_ESC    
       if !lAbrir
           setcursor(nCursor)
           setcolor(cCor)
       endif
       RestWindow( cTela )
       return
   endif
   cQuery := "SELECT id,fanpro,embpro,qteemb,pcoven,qteac01,qteac02 "
   cQuery += "FROM administrativo.produtos "
   // se o tipo de pesquisa for por descricao ou descricao reduzida
   if cTipo = '3' .or. cTipo = '4'
      if !empty(cPesquisa)
         cQuery += " WHERE fanpro LIKE '%"+rtrim(cPesquisa)+"%'"
      endif
   elseif cTipo = '1'
      if !empty(cPesquisa)
         cQuery += "WHERE id = "+NumberToSql(val(cPesquisa))
      endif
   elseif cTipo = '2'
      if !empty(cPesquisa)
         cQuery += "WHERE codbar = "+StringToSql(cPesquisa)
      endif
   endif
   cQuery += "ORDER BY fanpro"

   Msg(.t.)
   Msg("Aguarde: pesquisando as informa‡äes")
   if !ExecuteSql(cQuery,@oQuery,{"Falha: pesquisar fornecedor"},"sqlerro")
       oQuery:close()
       Msg(.f.)
       RestWindow(cTela)
       return
   endif
   Msg(.f.)
	Rodape(iif(lAbrir,"Esc-Encerra","Esc-Encerra | ENTER-Transfere"))
	lRetorno := iif(lRetorno == NIL,.f.,lRetorno)
	oBrow := TBrowseDB(nLinha1+3,nColuna1+1,nLinha2-2,nColuna2-1)
	oBrow:headSep := chr(194)+chr(196)
	oBrow:colSep  := chr(179)
	oBrow:footSep := chr(193)+chr(196)
	oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)
   oBrow:SkipBlock := {| n | oCurRow := SkipperQuery( @n, oQuery ), n }
   oBrow:GoBottomBlock := {|| oCurRow := oQuery:GetRow( oQuery:LastRec() ), 1 }
   oBrow:GoTopBlock := {|| oCurRow := oQuery:GetRow( 1 ), 1 }
	oColuna := tbcolumnnew("Codigo", {|| transform(oQuery:fieldget('id'),"999999")})
	oColuna:colorblock := {|| iif( oQuery:fieldget('QteAc02') == 0,{3,2},{1,2})}
	oBrow:addcolumn(oColuna)
	oColuna := tbcolumnnew("Descricao Reduzida" ,{|| oQuery:fieldget('FanPro')})
	oColuna:colorblock := {|| iif( oQuery:fieldget('QteAc02') == 0,{3,2},{1,2})}
	oBrow:addcolumn(oColuna)
   if !lGeral
      oColuna := tbcolumnnew("Emb. x Qtde.",{|| oQuery:fieldget('EmbPro') + " x "+str(oQuery:fieldget('QteEmb'),3)  })
      oColuna:colorblock := {|| iif( oQuery:fieldget('QteAc02') == 0,{3,2},{1,2})}
      oBrow:addcolumn(oColuna)
   endif
	oColuna := tbcolumnnew("Pco. Venda",{|| transform(oQuery:fieldget('PcoVen'),"@e 999,999.999")})
	oColuna:colorblock := {|| iif( oQuery:fieldget('QteAc02') == 0,{3,2},{1,2})}
	oBrow:addcolumn(oColuna)
	oColuna := tbcolumnnew("Estoque",{|| transform(oQuery:fieldget('QteAc02'),"@e 999,999.999")})
	oColuna:colorblock := {|| iif( oQuery:fieldget('QteAc02') == 0,{3,2},{1,2})}
	oBrow:addcolumn(oColuna)
	if lGeral // ** Fiscal - F9 ativado pra visualizar o estoque fiscal
		oColuna := tbcolumnnew("Fiscal",{|| transform(oQuery:fieldget('QteAc01'),"@e 999,999.999")})
		oColuna:colorblock := {|| iif( oQuery:fieldget('QteAc01') == 0,{3,2},{1,2})}
		oBrow:addcolumn(oColuna)
	endif
	setcolor(Cor(26))
	scroll(nLinha2-1,01,nLinha2-1,nColuna2-1,0)
	Centro(nLinha2-1,01,nColuna2-1,"F2-Pesquisar | F3-Visualizar")
   oBrow:Configure()
   do WHILE (! lFim)
      ForceStable(oBrow)
      if ( obrow:hittop .or. obrow:hitbottom )
         tone(1200,1)
      endif
      aRect := { oBrow:rowPos,1,oBrow:rowPos,5}
      oBrow:colorRect(aRect,{2,2})
	   cTecla := chr((nTecla := inkey(0)))
	   if !OnKey( nTecla,oBrow)
	   endif
	   if nTecla == K_ENTER
	      if !lAbrir
	         if !lRetorno
	            cDados := str(oQuery:fieldget('id'))
	            keyboard (cDados)+chr(K_ENTER)
	         else
	            cDados := str(oQuery:fieldget('id'))
	            keyboard (cDados)+chr(K_ENTER)
	         endif
	         lFim := .t.
	      endif
	   elseif nTecla == K_ESC
	      lFim := .t.
	   endif
        oBrow:refreshcurrent() 
	enddo
	if !lAbrir
	   setcursor(nCursor)
	   setcolor(cCor)
	else
	   if PwNivel == "0"
	      AtivaF9()
	      lGeral := .f.
	   endif
	endif
	RestWindow( cTela )
RETURN
// Consulta produtos com saldos f¡sico (pedidos)
// *********************************************************************************************************
procedure ConProdutoSaldo(lAbrir,lRetorno) 
   local getlist := {},oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados1
   local cDados2,nCursor := setcursor(),cCor := setcolor(),lTop,cTela2,lSaiMenu
   local oQuery,cQuery,cTipo := '3'
	local nLinha1  := 02,nColuna1 := 00,nLinha2  := 33,nColuna2 := 100

	if !lAbrir
		setcursor(SC_NONE)
	endif
   cQuery := "SELECT id,fanpro,embpro,qteemb,pcoven,qteac01,qteac02 "
   cQuery += "FROM administrativo.produtos ORDER BY fanpro LIMIT 1"
   Msg(.t.)
   Msg("Aguarde: pesquisando as informa‡äes")
   if !ExecuteSql(cQuery,@oQuery,{"Falha: pesquisar fornecedor"},"sqlerro")
       oQuery:close()
       Msg(.f.)
       RestWindow(cTela)
       return
   endif
   Msg(.f.)
   if oQuery:Lastrec() = 0
       Mens({"Tabela de produtos vazia"})
       oQuery:close()
       RestWindow(cTela)
       return
   endif
	Window(nLinha1,nColuna1,nLinha2,nColuna2,"> Consulta de produtos com saldo <")  // 23
   setcolor(Cor(11))
   //
   @ 03,01 say "Tipo:"
   @ 03,11 say "Pesquisar:"
   @ 04,01 say replicate(chr(196),99)
   setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
   @ 03,07 get cTipo picture "@k 9";
            when Rodape("Esc-Encerra");
            valid MenuArray(@cTipo,{{"1","Codigo"},{"2","Cod. barras"},{"3","Descricao"},{"4","Desc. reduzida"}})
   setcursor(SC_NORMAL)
   read
   setcursor(SC_NONE)
   if lastkey() == K_ESC    
       if !lAbrir
           setcursor(nCursor)
           setcolor(cCor)
       endif
       RestWindow( cTela )
       return
   endif
   if cTipo = '1'
      cPesquisa := space(06)
   elseif cTipo = '2'
      cPesquisa := space(14)
   else 
      cPesquisa := space(60)
   endif
   @ 03,22 get cPesquisa picture "@K"
   setcursor(SC_NORMAL)
   read
   setcursor(SC_NONE)
   if lastkey() == K_ESC    
       if !lAbrir
           setcursor(nCursor)
           setcolor(cCor)
       endif
       RestWindow( cTela )
       return
   endif
   cQuery := "SELECT id,fanpro,embpro,qteemb,pcoven,qteac01,qteac02 "
   cQuery += "FROM administrativo.produtos "
   cQuery += "where (qteac02 > 0 and ctrles = 'S') "
   // se o tipo de pesquisa for por descricao ou descricao reduzida
   if cTipo = '3' .or. cTipo = '4'
      if !empty(cPesquisa)
         cQuery += " WHERE fanpro LIKE '%"+rtrim(cPesquisa)+"%'"
      endif
   elseif cTipo = '1'
      if !empty(cPesquisa)
         cQuery += "WHERE id = "+NumberToSql(val(cPesquisa))
      endif
   elseif cTipo = '2'
      if !empty(cPesquisa)
         cQuery += "WHERE codbar = "+StringToSql(cPesquisa)
      endif
   endif
   cQuery += "ORDER BY fanpro"
   Msg(.t.)
   Msg("Aguarde: pesquisando as informa‡äes")
   if !ExecuteSql(cQuery,@oQuery,{"Falha: pesquisar fornecedor"},"sqlerro")
       oQuery:close()
       Msg(.f.)
       RestWindow(cTela)
       return
   endif
   Msg(.f.)
   Rodape(iif(lAbrir,"Esc-Encerra","Esc-Encerra | ENTER-Transfere"))
   lRetorno := iif(lRetorno == NIL,.f.,lRetorno)
	setcolor(cor(5))
	oBrow := TBrowseDB(nLinha1+3,nColuna1+1,nLinha2-2,nColuna2-1)
	oBrow:headSep := chr(194)+chr(196)
	oBrow:colSep  := chr(179)
	oBrow:footSep := chr(193)+chr(196)
	oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)
   oBrow:SkipBlock := {| n | oCurRow := SkipperQuery( @n, oQuery ), n }
   oBrow:GoBottomBlock := {|| oCurRow := oQuery:GetRow( oQuery:LastRec() ), 1 }
   oBrow:GoTopBlock := {|| oCurRow := oQuery:GetRow( 1 ), 1 }
	oColuna := tbcolumnnew("Codigo", {|| str(oQuery:fieldget('id'),6) })
	oColuna:colorblock := {|| iif( oQuery:fieldget('QteAc02') == 0,{3,2},{1,2})}
	oBrow:addcolumn(oColuna)
	oColuna := tbcolumnnew("Descricao Reduzida" ,{|| oQuery:fieldget('FanPro')})
   oColuna:colorblock := {|| iif( oQuery:fieldget('QteAc02') == 0,{3,2},{1,2})}
	oBrow:addcolumn(oColuna)
	oColuna := tbcolumnnew("Emb. x Qtde.",{|| oQuery:fieldget('EmbPro')+" x "+str(oQuery:fieldget('QteEmb'),3)  })
   oColuna:colorblock := {|| iif( oQuery:fieldget('QteAc02') == 0,{3,2},{1,2})}
	oBrow:addcolumn(oColuna)
	oColuna := tbcolumnnew("Pco. Venda",{|| transform(oQuery:fieldget('PcoVen'),"@e 999,999.999")})
   oColuna:colorblock := {|| iif( oQuery:fieldget('QteAc02') == 0,{3,2},{1,2})}
	oBrow:addcolumn(oColuna)
   oColuna := tbcolumnnew("Estoque",{|| transform(oQuery:fieldget('QteAc02'),"@e 999,999.999")})
   oColuna:colorblock := {|| iif( oQuery:fieldget('QteAc02') == 0,{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
	setcolor(Cor(26))
	scroll(nLinha2-1,01,nLinha2-1,nColuna2-1,0)
	Centro(nLinha2-1,01,nColuna2-1,"F3-Visualizar")
	xTecla := ""
	do WHILE (! lFim)
	   ForceStable(oBrow)
	   if ( obrow:hittop .or. obrow:hitbottom )
	      tone(1200,1)
	   endif
      aRect := { oBrow:rowPos,1,oBrow:rowPos,5}
      oBrow:colorRect(aRect,{2,2})
      cTecla := chr((nTecla := inkey(0)))
	   if !OnKey( nTecla,oBrow)
	   endif
	   if nTecla == K_ENTER
	      if !lAbrir
	         if !lRetorno
	            cDados := StrZero(oQuery:fieldget('id'),6)
	            keyboard (cDados)+chr(K_ENTER)
	         else
	            cDados := StrZero(oQuery:fieldget('id'),6)
	            keyboard (cDados)+chr(K_ENTER)
	         endif
	         lFim := .t.
	      endif
	   elseif nTecla == K_ESC
	      lFim := .t.
	   endif
      oBrow:refreshcurrent()       
	enddo
	if !lAbrir
	   setcursor(nCursor)
	   setcolor(cCor)
	else
	   if PwNivel == "0"
	      AtivaF9()
	      lGeral := .f.
	   endif
	endif
    //Produtos->(DbClearFilter())
	RestWindow( cTela )
RETURN
// *********************************************************************************************************
// ** Consulta produtos com saldos Fiscal
// *********************************************************************************************************
procedure ConProdutoSaldoF(lAbrir,lRetorno) 
   local getlist := {},oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados1
   local cDados2,nCursor := setcursor(),cCor := setcolor(),lTop,cTela2,lSaiMenu
   local aItem[05],aCampo := {},aTitulo := {},aMascara := {}
   local nLinha1 := 02,nColuna1 := 00,nLinha2 := maxrow()-1,nColuna2 := 100
   local cCampo,nI
   
   private nRecno,cCodLoja

	if lAbrir
		if !AbrirArquivos()
			return
		endif
   else
      setcursor(SC_NONE)
   endif
    select Produtos
    dbsetorder(8)
    goto top
    Rodape(iif(lAbrir,"Esc-Encerra","Esc-Encerra | ENTER-Transfere"))
    lRetorno := iif(lRetorno == NIL,.f.,lRetorno)
    n_Itens := lastrec()
    Pos := 1
	setcolor(cor(5))
	Window(nLinha1,nColuna1,nLinha2,nColuna2,"> Consulta de produtos com saldo <")  // 23
	oBrow := TBrowseDB(nLinha1+1,nColuna1+1,nLinha2-4,nColuna2-1)
	oBrow:headSep := chr(194)+chr(196)
	oBrow:colSep  := chr(179)
	oBrow:footSep := chr(193)+chr(196)
	oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)
	
	oColuna := tbcolumnnew("Codigo", {|| Produtos->CodPro })
	oColuna:colorblock := {|| iif( Produtos->QteAc01 == 0,{3,2},{1,2})}
	oBrow:addcolumn(oColuna)
	// *****************	
	oColuna := tbcolumnnew("Descricao Reduzida" ,{|| Produtos->FanPro})
	oColuna:colorblock := {|| iif( Produtos->QteAc01 == 0,{3,2},{1,2})}
	oBrow:addcolumn(oColuna)
	
	oColuna := tbcolumnnew("Emb. x Qtde.",{|| Produtos->EmbPro+" x "+str(Produtos->QteEmb,3)  })
	oColuna:colorblock := {|| iif( Produtos->QteAc01 == 0,{3,2},{1,2})}
	oBrow:addcolumn(oColuna)
	
	oColuna := tbcolumnnew("Pco. Venda",{|| transform(Produtos->PcoVen,"@e 999,999.999")})
	oColuna:colorblock := {|| iif( Produtos->QteAc01 == 0,{3,2},{1,2})}
	oBrow:addcolumn(oColuna)

		
	oColuna := tbcolumnnew("Estoque",{|| transform(Produtos->QteAc01,"@e 999,999.999")})
	oColuna:colorblock := {|| iif( Produtos->QteAc01 == 0,{3,2},{1,2})}
	oBrow:addcolumn(oColuna)
	
	setcolor(Cor(26))
	scroll(nLinha2-1,01,nLinha2-1,nColuna2-1,0)
	Centro(nLinha2-1,01,nColuna2-1,"F2-Pesquisar")
	AddKeyAction(K_ESC,    {|| lFim := .t.})
	AddKeyAction(K_ALT_X,  {|| xTecla := ""})
	AddKeyAction(K_CTRL_H, {|| if((nLen := len(xTecla)) > 0,((xTecla := substr(xTecla, 1, --nLen)), Produtos->(SeekIt(xTecla,.T.,oBrow))),NIL) })
	xTecla := ""
	WHILE (! lFim)
	   @ nLinha2-3,01 say padr(" Pesquisar: "+ xTecla,30) color Cor(11)
	   ForceStable(oBrow)
	   if ( obrow:hittop .or. obrow:hitbottom )
	      tone(1200,1)
	   endif
        aRect := { oBrow:rowPos,1,oBrow:rowPos,5}
        oBrow:colorRect(aRect,{2,2})  
             
        cTecla := chr((nTecla := inkey(0)))
	   if !OnKey( nTecla,oBrow)
	      if !(nTecla == K_ENTER)
	         if (nTecla >= 32 .and. nTecla <= 93) .or. (nTecla >= 96 .and. nTecla <= 125)
	            xTecla += cTecla
	            nRec := Produtos->(Recno())
	            if !Produtos->(SeekIt(xTecla,.T.,obrow))
	               Produtos->(dbgoto(nRec))
	            endif
	         endif
	      endif
	   endif
	   if nTecla == K_RIGHT
	      // **tabHupdate(aTab,obrow:colpos,obrow:colcount,.t.)
	   elseif nTecla == K_LEFT
	      // **tabHupdate(aTab,obrow:colpos,obrow:colcount,.t.)
	   elseif nTecla == K_F2
	   elseif nTecla == K_F3
	      // **VerProduto()
	   elseif nTecla == K_ENTER
	      if !lAbrir
	         if !lRetorno
	            cDados := Produtos->CodPro
	            keyboard (cDados)+chr(K_ENTER)
	         else
	            cDados := Produtos->CodPro
	            keyboard (cDados)+chr(K_ENTER)
	         endif
	         lFim := .t.
	      endif
	   elseif nTecla == K_ESC
	      lFim := .t.
	   endif
       oBrow:refreshcurrent()
       //oBrow:refreshall()
       
	enddo
	if !lAbrir
	   setcursor(nCursor)
	   setcolor(cCor)
	else
	   FechaDados()
	   if PwNivel == "0"
	      AtivaF9()
	      lGeral := .f.
	   endif
	endif
	RestWindow( cTela )
RETURN
// ************************************************************************************************
procedure IncProduto
	local getlist := {},cTela := SaveWindow()
	local lLimpa := .t.
	private oProdutos,nId,cQuery,oQuery,oQUnidade
	
	if PwNivel == "0"
		DesativaF9()
	endif
   AtivaF4()
   TelProduto(1)
	do while .t.
		if lLimpa 
			oProdutos := TProdutos():new()
			lLimpa := .f.
		endif
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		oQuery := oServer:Query("SELECT Last_value FROM administrativo.produtos_id_seq")
		nId := oQuery:fieldget('last_value')
		@ 03,17 say nId picture "999999"
		if !GetProdutos(.t.,.t.)
			exit
		endif
		if !Confirm("Confirma a InclusÆo")
         loop
		endif
      Msg(.t.)
      Msg("Aguarde: Gravando as informa‡äes")
      oServer:StartTransaction()
      if !GravarProdutos(.t.)
         oServer:Rollback()
         Msg(.f.)
         loop
      endif
      if !Grava_LogSql("Cadastros | Produtos | Produtos | incluir | Codigo : "+str(nId,3))
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
       endif
      oServer:Commit()
      oQuery:Close()
      MSg(.f.)
		lLimpa := .t.
   enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   endif
   RestWindow(cTela)
return
// ****************************************************************************
procedure AltProduto
	local getlist := {},cTela := SaveWindow()
	local lLimpa := .t.,cQuery,oQuery
	private oProdutos,oQUnidade,oQProdutos,cCodPro

	if PwNivel == "0"
		DesativaF9()
	endif
	AtivaF4()
	TelProduto(2)
	do while .t.
		if lLimpa
			oProdutos := TProdutos():new()
			lLimpa := .f.
		endif
		cCodPro := space(14)
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 03,17 get cCodPro picture "@k ";
					when Rodape("Esc-Encerra | F4-Produtos") ;
	  				valid BuscarCodigo(@cCodPro,,@oQProdutos) 
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
      oProdutos:RecuperarDados(oQProdutos)
      if !empty(oProdutos:dUltEnt)
         @ 14,76 say oProdutos:dUltEnt
         @ 15,76 say oProdutos:nUltQtd picture "@e 999,999.999" 
         Fornecedor->(dbsetorder(1),dbseek(oProdutos:cUltFor))
         @ 16,76 say oProdutos:cUltFor+"-"+left(Fornecedor->FanFor,18) 
      endif
		if !GetProdutos(.t.,.f.)
	  		loop
		endif
      if !Confirm("Confirma a Alteracao")
         loop
      endif
      Msg(.t.)
      Msg("Aguarde: Gravando as informa‡äes")
      oServer:StartTransaction()
      if !GravarProdutos(.f.)
         oServer:Rollback()
         Msg(.f.)
         loop
      endif
      if !Grava_LogSql("Cadastros | Produtos | Produtos | Alterar: "+cCodPro)
         oServer:Rollback()
         Msg(.f.)
         loop
      endif
      oServer:Commit()
      MSg(.f.)
	enddo
	DesativaF4()
	if PwNivel == "0"
		AtivaF9()
		lGeral := .f.
	endif
	RestWindow(cTela)
return
// ****************************************************************************
procedure ExcProduto
    local getlist := {},cTela := SaveWindow()
    local lCompra := .f.,lNfe := .f.,lNfce := .f.,lPdv := .f.,aTexto := {}
    private oProdutos
   
	if !AbrirArquivos()
		return
	endif
   if PwNivel == "0"
      DesativaF9()
   end
   AtivaF4()
   TelProduto(3)
	do while .t.
        lCompra := .f.
        lNfe := .f.
        lNfce := .f.
        lPdv := .f.
        aTexto := {}     
		oProdutos := TProdutos():new()
      	setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      	@ 03,17 get oProdutos:cCodPro picture "@k 999999";
      			when Rodape("Esc-Encerra | F4-Produtos");
      			valid Busca(Zera(@oProdutos:cCodPro),"Produtos",1,,,,{"Produto Nao Cadastrado"},.f.,.f.,.f.)
      	setcursor(SC_NORMAL)
      	read
      	setcursor(SC_NONE)
      	if lastkey() == K_ESC
         	exit
      	endif
		oProdutos:RecuperarDados()
		if !GetProdutos(.f.)
	  		loop
		endif
        if Cmp_Ite->(dbsetorder(3),dbseek(oProdutos:cCodPro))
            aadd(aTexto,"Existe nota de entrada para esse produto")
            lCompra := .t.
        endif
        if NfeItem->(dbsetorder(3),dbseek(oProdutos:cCodPro))
            aadd(aTexto,"Existe NF-e de saida para esse produto")
            lNfe := .t.
        endif
        if NfceItem->(dbsetorder(3),dbseek(oProdutos:cCodPro))
            aadd(aTexto,"Existe NFC-e para esse produto")
            lNfce := .t.
        endif
        if PdvNfceItem->(dbsetorder(3),dbseek(oProdutos:cCodPro))
            aadd(aTexto,"Existe NFC-e PDV para esse produto")
            lPdv := .t.
        endif
        aadd(aTexto,"ExclusÆo nÆo permitida")
        if lCompra .or. lNfe .or. lNfce
            Mens(aTexto)
            loop
        endif
      	if !Confirm("Confirma a Exclusao",2)
         	loop
	  	endif
      	do while !Produtos->(Trava_Reg())
      	enddo
		Produtos->(dbdelete())
		Produtos->(dbcommit())
		Produtos->(dbunlock())
		Grava_Log(cDiretorio,"Produtos|Excluir|Codigo "+oProdutos:cCodPro,Produtos->(recno()))
	enddo
   	DesativaF4()
	if PwNivel == "0"
		AtivaF9()
		lGeral := .f.
	endif
	FechaDados()
	RestWindow(cTela)
return
// ****************************************************************************
procedure VerProduto
   local cTela := SaveWindow()

   TelProduto(4)
   MosProduto()
   Rodape(space(20)+"Pressione Qualquer Tecla para Continuar")
   Inkey(0)
   RestWindow(cTela)
return
// ****************************************************************************   
procedure LancEstoqInicial // Altera a quantidade de produto na Loja 
   local getlist := {},cTela := SaveWindow(),lLimpa := .t.
   local cCodPro,nQtdEstI01,nQtdEstI02,nPcoCus,nPcoVen,nPcoCal,cLixo,cQuery,oQuery

   
   AtivaF4()
   Window(06,00,18,72,"> Lancar estoque Inicial <")
   setcolor(Cor(11))
   //           123456789012345678901234567890123456789012345678901234567890
   //                    1         2         3         4         5         6
   @ 09,01 say "        Codigo:"
   @ 10,01 say "     Descricao:"
   @ 11,01 say "     Embalagem:"
   @ 12,01 say "Estoque Fisico:"
   @ 13,01 say "Estoque Fiscal:"
   @ 14,01 say "Preco de Custo:"
   @ 15,01 say "Preco de Venda:"
   @ 16,01 say "  Preco Fiscal:"
	do while .t.
		if lLimpa 
			cCodPro    := space(14)
			nQtdEstI01 := 0
			nQtdEstI02 := 0
			nPcoCus    := 0
			nPcoVen    := 0
			nPcoCal    := 0
			lLimpa     := .f.
		endif
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 09,17 get cCodPro picture "@k";
					when Rodape("Esc-Encerra | F4-Produtos");
					valid NoEmpty(cCodPro) .and. BuscarCodigo(@cCodPro,,@oQuery)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
      nQtdEstI01 := oQuery:fieldget('QtdEstI01')
		nQtdEstI02 := oQuery:fieldget('QtdEstI02')
		nPcoCus    := oQuery:fieldget('PcoCus')
		nPcoVen    := oQuery:fieldget('PcoVen')
		nPcoCal    := oQuery:fieldget('PcoCal')
		@ 09,17 say cCodPro
		@ 10,17 say oQuery:fieldget('FanPro')
		@ 11,17 say oQuery:fieldget('EmbPro')+" X "+str(oQuery:fieldget('QteEmb'),3)
		@ 12,17 get nQtdEstI02 picture "@ke 999,999.999";
					when Rodape("Esc-Encerra")
		@ 13,17 get nQtdEstI01 picture "@ke 999,999.999"
		@ 14,17 get nPcoCus picture "@ke 999,999.999"
		@ 15,17 get nPcoVen picture "@ke 999,999.999"
		@ 16,17 get nPcoCal picture "@ke 999,999.999"
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			loop
		endif
		if !Confirm("Confirma as Informacoes")
         	loop
      	endif
      	do while Produtos->(!Trava_Reg())
      	enddo
        if Produtos->QteAc01 == 0
            Produtos->QteAc01 += nQtdEstI01
            Produtos->QtdEsti01 := nQtdEstI01
        else
            Produtos->QteAc01 -= Produtos->QtdEstI01
            Produtos->QtdEsti01 := nQtdEstI01
            Produtos->QteAc01 += nQtdEstI01
        endif
        if Produtos->QteAc02 == 0
            Produtos->QteAc02 += nQtdEstI02
            Produtos->QtdEsti02 := nQtdEstI02
        else
            Produtos->QteAc02 -= Produtos->QtdEstI02
            Produtos->QtdEsti02 := nQtdEstI02
            Produtos->QteAc02 += nQtdEstI02
        endif
      	Produtos->PcoCus := nPcoCus
      	Produtos->PcoVen := nPcoVen
      	Produtos->PcoCal := nPcoCal 
      	Produtos->(dbcommit())
      	Produtos->(dbunlock())
      	lLimpa := .t.
   	enddo
   	DesativaF4()
   	FechaDados()
   	RestWindow(cTela)
return
// ****************************************************************************
static procedure MosProduto

   Grupos->(dbsetorder(1),dbseek(Produtos->CodGru))
   SitTrib->(dbsetorder(1),dbseek(Produtos->CodFis))
   SubGrupo->(dbsetorder(1),dbseek(Produtos->SubGru))
   MapaFis->(dbsetorder(1),dbseek(Produtos->CodMap))

   @ 04,16 say left(Produtos->DesPro,50)
   @ 05,16 say Produtos->FanPro

   @ 06,16 say Produtos->EmbPro picture "@k!"
   @ 06,23 say Produtos->QteEmb picture "@k 999"
   @ 06,44 say Produtos->CodBar picture "@k!"

   @ 07,16 say Produtos->CodFor picture "@k 9999"
   vFornec(Produtos->CodFor,07,20)
   @ 07,44 say Produtos->CodGru picture "@k 999"
   vGrupo(Produtos->CodGru,07,47)

   @ 08,16 say Produtos->SubGru picture "@k 999"
   vSubGru(Produtos->SubGru,08,19)
   
	if clCrt == "1"
   		@ 08,44 say Produtos->CstSimples
   	elseif clCrt == "3"
   		@ 08,44 say Produtos->CstNormal
   	endif
   	
   
   
   // **@ 08,44 say Produtos->CodFis picture "@k 99"
   // **@ 08,46 say '-'+left(SitTrib->DesFis,12)
   // **@ 08,68 say Produtos->CSOSN

   @ 09,16 say Produtos->LocPro picture "@k!"
   @ 09,44 say Produtos->RefPro picture "@k!"
   @ 10,16 say Produtos->PerRed picture "99.99%"
   @ 10,44 say Produtos->ParMax picture "@k 99"
   @ 10,68 say Produtos->TabEsp picture "@k!"
   @ 11,16 say Produtos->ICMSub picture "99.99%"
   @ 11,44 say Produtos->PctFre picture "99.99%"
   @ 11,68 say Produtos->CtrlEs
   @ 12,16 say Produtos->AliDtr picture "99.99%"
   @ 12,44 say Produtos->AliFor picture "99.99%"
   @ 12,68 say Produtos->CreICM picture "99.99%"   // ** Cr‚dito de ICMS

   @ 13,16 say Produtos->IPIPro picture "99.99%"
   @ 13,44 say Produtos->LucPro picture "999.99%"
   @ 13,52 say Produtos->PerNot picture "999.99%"

   @ 14,16 say Produtos->PcoNot picture "@ke 999,999.999"
   @ 14,44 say Produtos->PcoCal picture "@ke 999,999.999"
   @ 14,68 say Produtos->PctPrz picture "999.99%"
   @ 15,16 say Produtos->PcoSug picture "@ke 999,999.999"
   @ 15,44 say Produtos->PcoVen picture "@ke 999,999.999"
   @ 15,68 say Produtos->CusMed01 picture "@ke 999,999.999"
   @ 16,16 say Produtos->PcoPrz picture "@ke 999,999.999"
   @ 16,44 say Produtos->PcoPro picture "@ke 999,999.999"

   @ 17,16 say Produtos->PesBru picture "@r 99,999.999"
   @ 17,44 say Produtos->PesLiq picture "@r 99,999.999"

   @ 18,16 say Produtos->PctDsc picture "99.99%"
   @ 18,44 say Produtos->PctCom picture "99.99%"

   @ 19,16 say Produtos->QtdMin picture "@e 999,999"
   @ 19,44 say Produtos->QtdMax picture "@e 999,999"

   //fico") valid iif(lastkey() == K_UP,.t.,Busca(cCodMap,"MapaFis",1,20,24,"'-'+left(MapaFis->DesMap,50)",{"Mapa Fisiografico Nao Cadastrado"},.f.,.f.,.f.))
//   @ 21,16 say Produtos->ObsPro picture "@k!" when Rodape("Esc-Encerra")
return
// ****************************************************************************
procedure TelProduto(nModo)
   local cTitulo, aTitulos := {"InclusÆo","Altera‡Æo","ExclusÆo","Visualizacao"}

   Window(02,00,33,100,"> "+aTitulos[nModo]+" de Produtos <")
   setcolor(Cor(11))
   //            1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
   //                     1         2         3         4         5         6         7         8         9         0
	@ 03,01 say "        Codigo:                  Ativo:"
	@ 04,01 say "     Descricao:"
	@ 05,01 say "Desc. Reduzida:"
	@ 06,01 say "     Embalagem:      x                 Similar:             C¢d. na balan‡a:"
	@ 07,01 say "    Fornecedor:                          Grupo:                     Cod.Fab:"
	@ 08,01 say " Cod. de Barra:                      Sub-Grupo:"
	@ 09,01 say "   Localizacao:                     Referencia:"
	@ 10,01 say "  Parc. Maxima:                  Tab. Especial:                Pct. Frete:"
	@ 11,01 say "  Ctrl.Estoque:                   Credito ICMS:                Pct. Lucro:        /       "
	@ 12,01 say "Preco de Custo:                   Preco  Calc.:                Pct. Prazo:"
	@ 13,01 say "Preco Sugerido:                    Preco Venda:               Preco Medio:"
	@ 14,01 say "Preco  a Prazo:                 Preco Promocao:                V lido at‚:"
	@ 15,01 say "    Peso Bruto:                   Peso L¡quido:               Ult. Compra:"
	@ 16,01 say "      Desconto:                       Comissao:                 Ult. Qtd.:"
	@ 17,01 say "Estoque Minimo:                 Estoque Maximo:                 Ult.Forn.:"
	@ 18,01 say "           NCM:                           CEST:                    Origem:"
	@ 19,01 say "    Observacao:"
	@ 20,01 say replicate(chr(196),99)
	@ 20,01 say " Tributacao " color Cor(26)
	@ 21,01 say "           Cst:"
	@ 22,01 say "   Aliq.Dentro:"
	@ 23,01 say "     Aliq.Fora:                        Cst Pis:      Aliq.%:"
	@ 24,01 say "       Reducao:                     Cst Cofins:      Aliq.%:"
	@ 25,01 say "  Substituicao:"
	@ 26,01 say "           IPI:"
	@ 27,01 say replicate(chr(196),99) 
	@ 27,01 say " Natureza da operacao (CFOP) " color cor(26)
	@ 28,01 say "       Saida no estado:"
	@ 29,01 say "  Saida fora do estado:"
	@ 30,01 say "     Entrada no estado:"
	@ 31,01 say "Entrada fora do estado:"
return
// ************************************************************************************************   
static function ValidarCodBarra(cCodBarra,lIncluir)
   local cQuery,oQuery

    if empty(cCodBarra)
        return(.t.)
    endif
    // ** se for a opção de inclusão do produto
   if lIncluir
        // ** verifica se o código de barras já foi cadastrado
      if !SqlBusca("codbar = "+StringToSql(cCodBarra),"descricao",@oQuery,"administrativo.produtos",,,,{"C¢digo de barras j  cadastrado"},.t.)
         return(.f.)
      endif
   else
      // ** se for a opção de alteração
      // ** se o código de barras digitado for diferente do cadastro do produto
      // ** verificar se o novo código já foi cadastrado. 
      if !(cCodBarra == oQProdutos:fieldget('CodBar'))
         if !SqlBusca("codbar = "+StringToSql(cCodBarra),"descricao",@oQuery,"administrativo.produtos",,,,{"C¢digo de barras j  cadastrado"},.t.)
            return(.f.)
         endif
      endif
   endif
return(.t.)
// ****************************************************************************   
static function GetProdutos(lGet,lIncluir)
   local oQuery

	@ 03,41 get oProdutos:cAtivo picture "@k!";
				when Rodape("Esc-Encerra |");
				valid MenuArray(@oProdutos:cAtivo,{{"S","Sim"},{"N","Nao"}})
                
	// ** Descricao do produtio
	@ 04,17 get oProdutos:cDesPro picture "@kS76";
				when Rodape("Esc-Encerra");
				valid NoEmpty(oProdutos:cDesPro)
				
	// ** Descrição reduzida do produto
	@ 05,17 get oProdutos:cFanPro picture "@k";
				when Rodape("Esc-Encerra | Descricao reduzida ou nome fantasia do produto");
				valid iif(empty(oProdutos:cFanPro),(oProdutos:cFanPro := substr(oProdutos:cDesPro,1,50),.t.),.t.)
				
	// ** Unidade de medida			
	@ 06,17 get oProdutos:cEmbPro picture "@k!";
				when Rodape("Esc-Encerra | F4-Unidades de Medidas");
				valid NoEmpty(oProdutos:cEmbPro) .and. SqlBusca("unidade = "+StringToSql(oProdutos:cEmbPro),"descricao",@oQUnidade,;
               "administrativo.unidmedida",,,,{"Unidade de medida nÆo cadastrada"},.f.)
	// ** Quantidade da embalagem				
	@ 06,24 get oProdutos:nQteEmb picture "@k 999";
				when Rodape("Esc-Encerra");
				valid NoEmpty(oProdutos:nQteEmb)
				
	// ** Código do produto similar
	@ 06,49 get oProdutos:nIdSimilar picture "@k 999999";
				when Rodape("Esc-Encerra | F4-Produtos")//;
				//valid iif(empty(oProdutos:nIdSimilar),.t.,Busca(Zera(@oProdutos:cCodSimilar),;
				//	"Produtos",1,row(),col(),"'-'+left(Produtos->FanPro,30)",{"Produto Nao cadastrado"},.f.,.f.,.f.))
                    
    // c¢digo do produto na balan‡a toledo
    @ 06,78 get oProdutos:nProdBalanca picture "@k 9999";
                when Rodape("Esc-Encerra | C¢digo do produto na balan‡a toledo");
                valid iif(empty(oProdutos:nProdBalanca),.t.,V_Zera(@oProdutos:nProdBalanca))
	
	// ** codigo doFornecedor
	@ 07,17 get oProdutos:nIdFornecedor picture "@k 9999";
      			when Rodape("Esc-Encerra | F4-Fornecedores");
	  			valid iif(lastkey() == K_UP,.t.,vFornec(@oProdutos:nIdFornecedor,row(),col()+1))
	  			
	// ** Codigo do grupo do produtos
	@ 07,49 get oProdutos:nIdGrupo picture "@k 999";
				when Rodape("Esc-Encerra | F4-Grupos") ;
	  			valid iif(lastkey() == K_UP,.t.,vGrupo(@oProdutos:nIdGrupo,row(),col()+1))
    
    // C¢digo do Fabricante
    @ 07,78 get oProdutos:nIdFabricante picture "@k 999";
                when Rodape("Esc-Encerra | F4-Fabricantes");
                valid iif(lastkey() == K_UP,.t.,vFabricantes(@oProdutos:nIdFabricante,row(),col()+1))
                
	// ** Codigo de barras			
	@ 08,17 get oProdutos:cCodBar picture "@k";
                when Rodape("Esc-Encerra");
                valid ValidarCodBarra(@oProdutos:cCodBar,lIncluir)
                
	// ** Codigo do sub-grupo de produtos					
	@ 08,49 get oProdutos:nIdSubGrupo picture "@k 999";
				when Rodape("Esc-Encerra | F4-Sub-Grupos") ;
	  			valid iif(lastkey() == K_UP,.t.,vSubGru(@oProdutos:nIdSubGrupo,row(),col()))
	  			
	@ 09,17 get oProdutos:cLocPro picture "@k!";
				when Rodape("Esc-Encerra") // ** Localiza‡Æo do produto
	@ 09,49 get oProdutos:cRefPro picture "@k!" valid vRefPro()
	
	@ 10,17 get oProdutos:nParMax picture "@k 99" 
	@ 10,49 get oProdutos:cTabEsp picture "@k!" // Tabela especial
	
	@ 10,76 get oProdutos:nPctFre picture "99.99%" // percentual de frete
	
    @ 11,17 get oProdutos:cCtrlEs picture "@k!";
    			valid MenuArray(@oProdutos:cCtrlEs,{{"S","Sim"},{"N","Nao"}})
	@ 11,49 get oProdutos:nCreICM picture "99.99%"   // ** Cr‚dito de ICMS
	@ 11,76 get oProdutos:nLucPro picture "999.99%"
	@ 11,84 get oProdutos:nPerNot picture "999.99%"
	
    // preco de custo
	@ 12,17 get oProdutos:nPcoCus picture "@ke 999,999.999";
				valid Calc_Prv(oProdutos:nPcoCus,oProdutos:nIPIPro,oProdutos:nPctFre,;
						oProdutos:nCreICM,oProdutos:nLucPro,oProdutos:nPerNot,0,;
						oProdutos:nAliDtr,@oProdutos:nPcoCal,@oProdutos:nPcoSug)
	// ** Preço Calculado - Preço na nota
	@ 12,49 get oProdutos:nPcoCal picture "@ke 999,999.999"
	@ 12,76 get oProdutos:nPctPrz picture "999.99%"
	
	@ 13,17 get oProdutos:nPcoSug picture "@ke 999,999.999" //valid Calc_Mrg(nPcoCus,nIPIPro,nPctFre,nAliFor,nPcoSug,0,nAliDtr,@nLucPro)
	@ 13,49 get oProdutos:nPcoVen picture "@ke 999,999.999" // pre‡o de venda
	@ 13,76 get oProdutos:nCusMed picture "@ke 999,999.999" // custo m‚dio
	
	@ 14,17 get oProdutos:nPcoPrz picture "@ke 999,999.999"  // pre‡o a prazo
	@ 14,49 get oProdutos:nPcoPro picture "@ke 999,999.999"  // pre‡o da promo‡Æo
   @ 14,76 get oProdutos:dDtaPro picture "@k"               // Data de validade da promo‡Æo
	@ 15,18 get oProdutos:nPesBru picture "@r 99,999.999" // Peso bruto
	@ 15,50 get oProdutos:nPesLiq picture "@r 99,999.999" // Peso liquido
	@ 16,17 get oProdutos:nPctDsc picture "99.99%" // ** Percentual de Desconto
	@ 16,49 get oProdutos:nPctCom picture "99.99%" // ** Percentual de Comissao do produto
	@ 17,17 get oProdutos:nQtdMin picture "@e 999,999" // ** Quantidade pro estoque minimo      
	@ 17,49 get oProdutos:nQtdMax picture "@e 999,999" when Rodape("Esc-Encerra") // ** Quantidade pro estoque maximo
    
      
	// ** NCM
	@ 18,17 get oProdutos:cCodNCM    picture "@k";
			when iif(nTipoEstoque = 0,Rodape("Esc-Encerra | F4-Tabela de NCM"),.f.);
			valid iif(lastkey() == K_UP,.t.,NoEmpty(oProdutos:cCodNCM) .and.;
            SqlBusca("ncm = "+StringToSql(oProdutos:cCodNCM),"descricao",@oQuery,;
            "administrativo.ncm",,,,{"NCM nÆo cadastrado"},.f.))
            
    // C¢digo CEST
    @ 18,49 get oProdutos:cCest picture "@k";
            when iif(nTipoEstoque = 0,Rodape("Esc-Encerra"),.f.)
			
    // Origem da mercadoria
	@ 18,76 get oProdutos:cOrigem picture "@k 9";
			when iif(nTipoEstoque = 0,Rodape("Esc-Encerra"),.f.);
			valid MenuArray(@oProdutos:cOrigem,{;
			{"0","Nacional, exceto as indicadas nos códigos 3, 4, 5 e 8"},;
			{"1","Estrangeira - Importação direta, exceto a indicada no código 6"},;
			{"2","Estrangeira - Adquirida no mercado interno, exceto a indicada no código 7"},;
			{"3","Nacional, mercadoria ou bem com Conteúdo de Importação superior a 40% e inferior ou igual a 70%"},;
			{"4","Nacional, cuja produção tenha sido feita em conformidade com os processos produtivos básicos de que tratam o Decreto-Lei nº 288/67, e as Leis nºs 8.248/91, 8.387/91, 10.176/01 e 11.484/07"},;
			{"5","Nacional, mercadoria ou bem com Conteúdo de Importação inferior ou igual a 40% (quarenta por cento)"},;
			{"6","Estrangeira - Importação direta, sem similar nacional, constante em lista de Resolução CAMEX"},;
			{"7","Estrangeira - Adquirida no mercado interno, sem similar nacional, constante em lista de Resolução CAMEX"}},row(),00)
			
	@ 19,17 get oProdutos:cObsPro picture "@k!" when Rodape("Esc-Encerra")
	
	// ** Situacao Tributária **************************************************************************
	@ 21,17 get oProdutos:nIdCst    picture "@k 999";
			when iif(nTipoEstoque = 0,Rodape("Es-Encerra | F4-Sit.Tributaria"),.f.);
			valid SqlBusca("id = "+NumberToSql(oProdutos:nIdCst),"descricao",@oQuery,;
         "administrativo.sittrib",row(),col()+1,{"descricao",0},{"Situa‡Æo tribut ria nÆo cadastrada"},.f.)
				
	@ 22,17 get oProdutos:nAliDtr picture "99.99%";
			when iif(nTipoEstoque = 0,Rodape("Esc-Encerra"),.f.)
	@ 23,17 get oProdutos:nAliFor picture "99.99%";
            when iif(nTipoEstoque = 0,Rodape("Esc-Encerra"),.f.)
    // PIS
    @ 23,49 get oProdutos:cPis picture "@k 99";
            when iif(nTipoEstoque = 0,Rodape("Esc-Encerra"),.f.);
            valid iif(empty(oProdutos:cPis),.t.,V_Zera(@oProdutos:cPis))
    @ 23,62 get oProdutos:nPisAliq picture "999.99%";
            when iif(nTipoEstoque = 0,Rodape("Esc-Encerra"),.f.)
     	
	@ 24,17 get oProdutos:nPerRed picture "99.99%";
            when iif(nTipoEstoque = 0,Rodape("Esc-Encerra"),.f.)
    // COFINS
    @ 24,49 get oProdutos:cCofins picture "@k 99";
            when iif(nTipoEstoque = 0,Rodape("Esc-Encerra"),.f.);
            valid iif(empty(oProdutos:cCofins),.t.,V_Zera(@oProdutos:cCofins))
            
    @ 24,62 get oProdutos:nCofinsAliq picture "999.99%";
            when iif(nTipoEstoque = 0,Rodape("Esc-Encerra"),.f.)
     	
	@ 25,17 get oProdutos:nICMSub picture "99.99%";
            when iif(nTipoEstoque = 0,Rodape("Esc-Encerra"),.f.)	

	@ 26,17 get oProdutos:nIPIPro picture "99.99%";
            when iif(nTipoEstoque = 0,Rodape("Esc-Encerra"),.f.)
	// ***************************************************************************************************
	
	// ** Natureza de operação saída dentro do estado
	@ 28,25 get oProdutos:nIdNatSaiDent picture "@k 999";
				when iif(nTipoEstoque = 0,Rodape("Esc-Encerra | F4-Natureza de Operacao"),.f.);
				valid iif(empty(oProdutos:nIdNatSaiDent),.t.,ValidarNatureza(oProdutos:nIdNatSaiDent,row(),col()+1))
					
	// ** Natureza de operação saída fora do estado
	@ 29,25 get oProdutos:nIdNatSaiFora picture "@k 999";
				when iif(nTipoEstoque = 0,Rodape("Esc-Encerra | F4-Natureza de Operacao"),.f.);
            valid iif(empty(oProdutos:nIdNatSaiFora),.t.,ValidarNatureza(oProdutos:nIdNatSaiFora,row(),col()+1))
					
	// ** Natureza de operacao entrada dentro do estado
	@ 30,25 get oProdutos:nIdNatEntDent picture "@k 999";
				when iif(nTipoEstoque = 0,Rodape("Esc-Encerra | F4-Natureza de Operacao"),.f.);
            valid iif(empty(oProdutos:nIdNatEntDent),.t.,ValidarNatureza(oProdutos:nIdNatEntDent,row(),col()+1))
					
	// ** Natureza operacao entrada fora do estado
	@ 31,25 get oProdutos:nIdNatEntFora picture "@k 999";
				when iif(nTipoEstoque = 0,Rodape("Esc-Encerra | F4-Natureza de Operacao"),.f.);
            valid iif(empty(oProdutos:nIdNatEntFora),.t.,ValidarNatureza(oProdutos:nIdNatEntFora,row(),col()+1))
	if lGet
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			return(.f.)
		endif
	else
		clear gets
	endif
	return(.t.)
// ****************************************************************************
static function ValidarNatureza(nId,nLinha,nColuna)
   local cQuery,oQuery

   cQuery := "SELECT r.cfop,f.descricao FROM administrativo.natureza r "
   cQuery += "INNER JOIN administrativo.cfop f ON (r.cfop = f.cfop) "
   cQuery += "WHERE id = "+NumberToSql(nId)
   if !ExecuteSql(cQuery,@oQuery,{"Falha: pesquisar fornecedor"},"sqlerro")
      oQuery:close()
      return(.f.)
   endif
   if oQuery:lastrec() = 0
      Mens({"Natureza nÆo cadastrada"})
      return(.f.)
   endif
   @ nLinha,nColuna say 'CFOP: '+str(oQuery:fieldget('cfop'),4)+' '+left(oQuery:fieldget('descricao'),50)
return(.t.)
// ****************************************************************************
static function vFornec(nId,nLinha,nColuna)
   local oQuery

   if empty(nId)
      @ nLinha,nColuna say space(14)
      return(.t.)
   endif
   if !SqlBusca("id = "+NumberToSql(nId),"razfor",@oQuery,"administrativo.fornecedores",nLinha,nColuna,;
      {"razfor",14},{"Fornecedor nÆo cadastrado"},.f.)
      return(.f.)
   endif
return(.t.)
// ****************************************************************************   
static function vFabricantes(nIdFabricante,nLinha,nColuna)
   local oQuery

   if empty(nIdFabricante)
      @ nLinha,nColuna say space(10)
      return(.t.)
   endif
   if !SqlBusca("id = "+NumberToSql(nId),"nome",@oQuery,;
      "administrativo.fabricantes",nLinha,nColuna,{"nome",14},{"Fabricante nÆo cadastrado"},.f.)
      return(.f.)
   endif
return(.t.)
// ****************************************************************************
static function vSimilar(nIdSimilar,nLinha,nColuna)
   local oQuery

   if empty(nIdSimilar)
      @ nLinha,nColuna say space(10)
      return(.t.)
   endif
   if !SqlBusca("id = "+NumberToSql(nId),"fanpro",@oQuery,;
      "administrativo.produtos",nLinha,nColuna,{"fanpro",14},{"Similar nÆo cadastrado"},.f.)
      return(.f.)
   endif
return(.t.)
// ****************************************************************************   
static function vGrupo(nIdGrupo,nLinha,nColuna)
   local oQuery

   if empty(nIdGrupo)
      @ nLinha,nColuna say space(10)
      return(.t.)
   endif
   if !SqlBusca("id = "+NumberToSql(nIdGrupo),"descricao",@oQuery,"administrativo.grupos",nLinha,nColuna,;
      {"descricao",14},{"Grupo nÆo cadastrado"},.f.)
      return(.f.)
   endif
return(.t.)
// ****************************************************************************
static function vSubGru(nIdSubGrupo,nLinha,nColuna)
   local oQuery

   if empty(nIdSubGrupo)
      @ nLinha,nColuna say space(11)
      return(.t.)
   end
   if !SqlBusca("id = "+NumberToSql(nIdSubGrupo),"descricao",@oQuery,"administrativo.subgrupos",nLinha,nColuna,;
      {"descricao",11},{"Sub-Grupo nÆo cadastrado"},.f.)
      return(.f.)
   endif
return(.t.)
// ************************************************************************************************
static function vSitTrib(cCst)

	if !Busca(@cCst,"SitTrib",1,row(),col()+1,"'-'+SitTrib->DesFis",;
			{"Situacao tributaria nao cadastrada"},.f.,.f.,.f.)
		return(.f.)
	endif
return(.t.)
// ****************************************************************************
static function vRefPro

   if empty(oProdutos:cRefPro)
      oProdutos:cRefPro := oProdutos:cCodPro+space(09)
   endif
return(.t.)
// ************************************************************************************************
static function AbrirArquivos
	Msg(.t.)
	Msg("Aguarde : Abrindo os Arquivos")
	if !OpenProdutos()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
	if !OpenGrupos()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
	if !OpenSubGrupo()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
	if !OPenFornecedor()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
	if !OpenSequencia()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
	if !OpenUnidadeDeMedida()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
	if !OpenSitTrib()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
	if !OpenTabNCM()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
	if !OpenMapaFis()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
	if !OpenNatureza()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
    if !OpenCmp_ite()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenNfeItem()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenNfceItem()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenPdvNfceItem()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenCidades()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenFabricantes()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
	Msg(.f.)
	return(.t.)
// ************************************************************************************************
static function GravarProdutos(lModo)
   local oQuery,cQuery

   if lModo
      cQuery := "INSERT INTO administrativo.produtos "
      cQuery += "("
      cQuery += "ativo,DesPro,"  
      cQuery += 'Fanpro,'
      cQuery += 'EmbPro,'
      cQuery += 'QteEmb,'
      cQuery += 'idsimilar,'
      cQuery += 'prodbalanc, idfornecedor, idgrupo, idfabricante, codbar, idsubgrupo, locpro,'
      cQuery += "refpro, parmax, tabesp , pctfre, ctrles, creicm,  lucpro,  pernot, pcocus,  pcocal, pctprz, pcosug,"
      cQuery += "pcoven, cusmed, pcoprz, pcopro, dtapro, pesbru, pesliq, pctdsc, pctcom, qtdmin, qtdmax, codncm,"
      cQuery += "cest, origem, obspro, idcst, alidtr, alifor, pis, pisaliq, perred, cofins, cofinsaliq, icmsub,"
      cQuery += "ipipro, natsaident, natsaifora, natentdent, natentfora"
      cQuery += ") "
      cQuery += "VALUES ("
      cQuery += StringToSql(oProdutos:cAtivo)+","
      cQuery += StringToSql(oProdutos:cDesPro)+","
      cQuery += StringToSql(oProdutos:cFanPro)+","
      cQuery += StringToSql(oProdutos:cEmbPro)+","
      cQuery += NumberToSql(oProdutos:nQteEmb,3)+","
      cQuery += NumberToSql(oProdutos:nIdSimilar)+","
      cQuery += StringToSql(oProdutos:cProdBalanca)+","
      cQuery += NumberToSql(oProdutos:nIdFornecedor)+","   // ** Fornecedor
      cQuery += NumberToSql(oProdutos:nIdGrupo)+","
      cQuery += NumberToSql(oProdutos:nIdFabricante)+","
      cQuery += StringToSql(oProdutos:cCodBar)+","   // ** Codigo de Barras
      cQuery += NumberToSql(oProdutos:nIdSubGrupo)+','   // ** Sub-Grupo de Produtos
      cQuery += StringToSql(oProdutos:cLocPro)+","
      cQuery += StringToSql(oProdutos:cRefPro)+','
      cQuery += NumberToSql(oProdutos:nParMax,2,0)+","   // ** Parcela M xima
      cQuery += StringToSql(oProdutos:cTabEsp)+","
      cQuery += NumberToSql(oProdutos:nPctFre,6,2)+","   // ** Percentual de Frete
      cQuery += StringToSql(oProdutos:cCtrlEs)+","   // ** Controla estoque
      cQuery += NumberToSql(oProdutos:nCreICM,6,2)+","   // ** Cr‚dito de ICM
      cQuery += NumberToSql(oProdutos:nLucPro,6,2)+","   // ** Margem de Lucro
      cQuery += NumberToSql(oProdutos:nPerNot,6,2)+","   // ** Percentual para o Preco de Nota
      cQuery += NumberToSql(oProdutos:nPcoCus,11,3)+","
      cQuery += NumberToSql(oProdutos:nPcoCal,15,3)+","   // ** Pre‡o Calculado
      cQuery += NumberToSql(oProdutos:nPctPrz,6,2)+","   // ** Percentual de Pre‡o a Prazo
      cQuery += NumberToSql( oProdutos:nPcoSug,15,3)+","
      cQuery += NumberToSql(oProdutos:nPcoVen,11,3)+","
      cQuery += NumberToSql(oProdutos:nCusMed,15,3)+","
      cQuery += NumberToSql(oProdutos:nPcoPrz,11,3)+","
      cQuery += NumberToSql(oProdutos:nPcoPro,11,2)+","
      cQuery += DateToSql(oProdutos:dDtapro)+","
      cQuery += NumberToSql(oProdutos:nPesBru,9,3)+","   // ** Peso Bruto
      cQuery += NumberToSql(oProdutos:nPesLiq,9,3)+","   // ** Peso l¡quido
      cQuery += NumberToSql(oProdutos:nPctDsc,5,2)+","
      cQuery += NumberToSql(oProdutos:nPctCom,5,2)+","
      cQuery += NumberToSql(oProdutos:nQtdMin,8,2)+","   // ** Estoque M¡nino
      cQuery += NumberToSql(oProdutos:nQtdMax,8,2)+","   // ** Estoque M ximo
      cQuery += StringToSql(oProdutos:cCodNCM)+","
      cQuery += StringToSql(oProdutos:cCest)+"," // ** c¢digo CEST
      cQuery += StringToSql(oProdutos:cOrigem)+","   // ** Origem da mercadoria      
      cQuery += StringToSql(oProdutos:cObsPro)+","   // ** Observa‡Æo
      cQuery += NumberToSql(oProdutos:nIdCst)+","      
      cQuery += NumberToSql(oProdutos:nAliDtr,5,2)+","
      cQuery += NumberToSql(oProdutos:nAliFor,5,2)+","      
      cQuery += StringToSql(oProdutos:cPis)+","      
      cQuery += NumberToSql(oProdutos:nPisAliq,5,2)+","      
      cQuery += NumberToSql(oProdutos:nPerRed,5,2)+","   // ** Redu‡Æo      
      cQuery += StringToSql(oProdutos:cCofins)+","      
      cQuery += NumberToSql(oProdutos:nCofinsAliq,6,2)+","      
      cQuery += NumberToSql(oProdutos:nICMSub,5,2)+","   // ** Substitui‡Æo      
      cQuery += NumberToSql(oProdutos:nIPIPro,6,2)+","   // ** % Ipi      
      cQuery += NumberToSql(oProdutos:nIdNatSaiDent)+","      
      cQuery += NumberToSql(oProdutos:nIdNatSaiFora)+","      
      cQuery += NumberToSql(oProdutos:nIdNatEntDent)+","      
      cQuery += NumberToSql(oProdutos:nIdNatEntFora)
      cQuery += ")"
   else
      cQuery := "UPDATE administrativo.produtos "
      cQuery += "SET "
      cQuery += "ativo = "+StringToSql(oProdutos:cAtivo)+","
      cQuery += "despro = "+StringToSql(oProdutos:cDesPro)+","
      cQuery += "fanpro = "+StringToSql(oProdutos:cFanPro)+","
      cQuery += "embpro = "+StringToSql(oProdutos:cEmbPro)+","
      cQuery += "qteemb = "+NumberToSql(oProdutos:nQteEmb,3)+","
      cQuery += "idsimilar = "+NumberToSql(oProdutos:nIdSimilar)+","
      cQuery += "prodbalanc = "+NumberToSql(oProdutos:nProdBalanca)+","
      cQuery += "idfornecedor = "+NumberToSql(oProdutos:nIdFornecedor)+","   // ** Fornecedor
      cQuery += "idgrupo = "+NumberToSql(oProdutos:nIdGrupo)+","
      cQuery += "idfabricante = "+NumberToSql(oProdutos:nIdFabricante)+","
      cQuery += "codbar = "+StringToSql(oProdutos:cCodBar)+","   // ** Codigo de Barras
      cQuery += "idsubgrupo = "+NumberToSql(oProdutos:nIdSubGrupo)+','   // ** Sub-Grupo de Produtos
      cQuery += "locpro = "+StringToSql(oProdutos:cLocPro)+","
      cQuery += "refpro = "+StringToSql(oProdutos:cRefPro)+','
      cQuery += "parmax = "+NumberToSql(oProdutos:nParMax,2,0)+","   // ** Parcela M xima
      cQuery += "tabesp = "+StringToSql(oProdutos:cTabEsp)+","
      cQuery += "pctfre = "+NumberToSql(oProdutos:nPctFre,6,2)+","   // ** Percentual de Frete
      cQuery += "ctrles = "+StringToSql(oProdutos:cCtrlEs)+","   // ** Controla estoque
      cQuery += "creicm = "+NumberToSql(oProdutos:nCreICM,6,2)+","   // ** Cr‚dito de ICM
      cQuery += "lucpro = "+NumberToSql(oProdutos:nLucPro,6,2)+","   // ** Margem de Lucro
      cQuery += "pernot = "+NumberToSql(oProdutos:nPerNot,6,2)+","   // ** Percentual para o Preco de Nota
      cQuery += "pcocus = "+NumberToSql(oProdutos:nPcoCus,11,3)+","
      cQuery += "pcocal = "+NumberToSql(oProdutos:nPcoCal,15,3)+","   // ** Pre‡o Calculado
      cQuery += "pctprz = "+NumberToSql(oProdutos:nPctPrz,6,2)+","   // ** Percentual de Pre‡o a Prazo
      cQuery += "pcosug = "+NumberToSql( oProdutos:nPcoSug,15,3)+","
      cQuery += "pcoven = "+NumberToSql(oProdutos:nPcoVen,11,3)+","
      cQuery += "cusmed02 = "+NumberToSql(oProdutos:nCusMed,15,3)+","
      cQuery += "pcoprz = "+NumberToSql(oProdutos:nPcoPrz,11,3)+","
      cQuery += "pcopro = "+NumberToSql(oProdutos:nPcoPro,11,2)+","
      cQuery += "dtapro = "+DateToSql(oProdutos:dDtapro)+","
      cQuery += "pesbru = "+NumberToSql(oProdutos:nPesBru,9,3)+","   // ** Peso Bruto
      cQuery += "pesliq = "+NumberToSql(oProdutos:nPesLiq,9,3)+","   // ** Peso l¡quido
      cQuery += "pctdsc = "+NumberToSql(oProdutos:nPctDsc,5,2)+","
      cQuery += "pctcom = "+NumberToSql(oProdutos:nPctCom,5,2)+","
      cQuery += "qtdmin = "+NumberToSql(oProdutos:nQtdMin,8,2)+","   // ** Estoque M¡nino
      cQuery += "qtdmax = "+NumberToSql(oProdutos:nQtdMax,8,2)+","   // ** Estoque M ximo
      cQuery += "codncm = "+StringToSql(oProdutos:cCodNCM)+","
      cQuery += "cest = "+StringToSql(oProdutos:cCest)+"," // ** c¢digo CEST
      cQuery += "origem = "+StringToSql(oProdutos:cOrigem)+","   // ** Origem da mercadoria      
      cQuery += "obspro = "+StringToSql(oProdutos:cObsPro)+","   // ** Observa‡Æo
      cQuery += "idcst = "+NumberToSql(oProdutos:nIdCst)+","      
      cQuery += "alidtr = "+NumberToSql(oProdutos:nAliDtr,5,2)+","
      cQuery += "alifor = "+NumberToSql(oProdutos:nAliFor,5,2)+","      
      cQuery += "pis = "+StringToSql(oProdutos:cPis)+","      
      cQuery += "pisaliq = "+NumberToSql(oProdutos:nPisAliq,5,2)+","      
      cQuery += "perred = "+NumberToSql(oProdutos:nPerRed,5,2)+","   // ** Redu‡Æo      
      cQuery += "cofins = "+StringToSql(oProdutos:cCofins)+","      
      cQuery += "cofinsaliq = "+NumberToSql(oProdutos:nCofinsAliq,6,2)+","      
      cQuery += "icmsub = "+NumberToSql(oProdutos:nICMSub,5,2)+","   // ** Substitui‡Æo      
      cQuery += "ipipro = "+NumberToSql(oProdutos:nIPIPro,6,2)+","   // ** % Ipi      
      cQuery += "natsaident = "+NumberToSql(oProdutos:nIdNatSaiDent)+","      
      cQuery += "natsaifora = "+NumberToSql(oProdutos:nIdNatSaiFora)+","      
      cQuery += "natentdent = "+NumberToSql(oProdutos:nIdNatEntDent)+","      
      cQuery += "natentfora = "+NumberToSql(oProdutos:nIdNatEntFora)+" "
      if len(alltrim(cCodPro)) <= 6
         cQuery += "WHERE id = "+NumberToSql(val(cCodPro))
      else
         cQuery += "WHERE codba = "+StringToSql(cCodPro)
      endif
   endif
   if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar "},"sqlerro")
      return(.f.)
  endif
return(.t.)
// ************************************************************************************************    
procedure AlterarNCM
   local getlist := {},cTela := SaveWindow(),cTela2 
   local cQuery,oQuery,cNCMAtual,cNCMNovo,nContador,aCodPro := {}
    
	Window(06,00,11,45,"> Alteracao NCM <")
	setcolor(Cor(11))
   //           12345678901234567890123456789
   //                    1         2
	@ 08,01 say "NCM Atual:"    
	@ 09,01 say " NCM Novo:"
   do while .t.
      cNCMAtual := space(08)
      cNCMNovo  := space(08)
      nContador := 0
      aCodPro   := {}
      @ 08,24 say space(10)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 08,12 get cNCMAtual picture "@k 99999999";
               when Rodape("Esc-Encerra");
               valid SqlBusca("ncm = "+StringToSql(cNCMAtual),"descricao",@oQuery,;
                  "administrativo.ncm",,,,{"NCM nÆo cadastrado"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      if !SqlBusca("codncm = "+StringToSql(cNCMAtual),"fanpro",@oQuery,;
         "administrativo.produtos",,,,{"NÆo existe produto(s) com esse NCM"},.f.)
         loop
      endif
      @ 08,24 say "produtos: "+str(oQuery:Lastrec())
      @ 09,12 get cNCMNovo  picture "@k 99999999"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      endif
      if !Confirm("Confirma a informa‡Æo")
         loop
      endif
      cQuery := "UPDATE administrativo.produtos "
      cQuery += "SET codncm = "+StringToSql(cNCMNovo)+" WHERE codncm = "+StringToSql(cNCMAtual)
      Msg(.t.)
      Msg("Aguarde: Alterando o NCM")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Falha:"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      oServer:Commit()
      oQuery:Close()
      MSg(.f.)
      Mens({"NCM alterado com sucesso"})
    enddo
    RestWindow(cTela)
return
// ************************************************************************************************    
procedure AlterarPreco 
   local getlist := {},cTela := SaveWindow(),lLimpa := .t.
   local cCodPro,nPreco,oQuery

   AtivaF4()
   Window(06,00,15,72,"> Altera‡Æo de pre‡os <")
   setcolor(Cor(11))
   //           123456789012345678901234567890123456789012345678901234567890
   //                    1         2         3         4         5         6
   @ 09,01 say "     Codigo:"
   @ 10,01 say "  Descricao:"
   @ 11,01 say "  Embalagem:"
   @ 12,01 say "Pre‡o atual:"
   @ 13,01 say " Pre‡o novo:"
	do while .t.
		cCodPro := space(14)
      nPreco  := 0.000
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 09,14 get cCodPro picture "@k";
					when Rodape("Esc-Encerra | F4-Produtos");
					valid NoEmpty(cCodPro) .and. BuscarCodigo(@cCodPro,,@oQuery)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
      nPreco := oQuery:fieldget('PcoCal')
		@ 09,14 say cCodPro
		@ 10,14 say oQuery:fieldget('FanPro')
		@ 11,14 say oQuery:fieldget('EmbPro')+" X "+str(oQuery:fieldget('QteEmb'),3)
		@ 12,14 say oQuery:fieldget('PcoCal') picture "@ke 999,999.999"
      @ 13,14 get nPreco picture "@ke 999,999.999"
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			loop
		endif
		if !Confirm("Confirma as Informa‡äes")
         loop
      endif
      cQuery := "UPDATE administrativo.produtos "
      cQuery += "SET pcoven = "+NumberToSql(nPreco,11,3)+", pcocal = "+NumberToSql(nPreco,11,3)+" "
      cQuery += "WHERE id = "+NumberToSql(oQuery:fieldget('id'))
      Msg(.t.)
      Msg("Aguarde: Gravando as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Falha: alteracao de precos "},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      oServer:Commit()
      oQuery:Close()
      MSg(.f.)
      Mens({"Pre‡o alterado com sucesso"})
      lLimpa := .t.
   enddo
   DesativaF4()
   RestWindow(cTela)
return
// ************************************************************************************************    
procedure ImprimirEtiquetas
    local cTela := SaveWindow(),nVideo
    local aTitulo := {},aCampo := {},aMascara := {}
    private oPrinter,cPrinter,cFont
    private aCodItem  := {} // ** Codigo do item ou cod. de barras
    private aCodPro   := {} 
	private aDesPro  := {}
    private aQuantidade := {}
    
    

    Msg(.t.)
    if !OpenProdutos()
        FechaDados()
        Msg(.f.)
        return
    endif
    Msg(.f.)
    if !Use_dbf(cDiretorio,"etiq",.t.,.t.,"Etiq")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return
	endif
	zap
	Etiq->(dbclosearea())
    if !Use_dbf(cDiretorio,"etiq",.t.,.t.,"Etiq")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return
	endif
    /*
    do while Etiquetas->(!eof())
        for nI := 1 to Etiquetas->Quantidade
            Produtos->(dbsetorder(1),dbseek(Etiquetas->Codigo))
            Etiq->(dbappend())
            Etiq->Codigo := Etiquetas->Codigo
            Etiq->Descricao := Produtos->FanPro
            Etiq->Preco1 := Produtos->pcoven
            Etiq->Preco2 := Produtos->PcoCal
        next
        Etiquetas->(dbskip())
    enddo
    Etiq->(dbgotop())
    */
    
             
    aadd(aCodItem,space(14))
    aadd(aCodPro,space(06))
    aadd(aDesPro,space(40)) 
    aadd(aQuantidade,0)
    
	aadd(aTitulo,"Codigo") 
	aadd(aTitulo,"Descricao")
    aadd(aTitulo,"Quantidade")
	
	// ***************************************************************************************************
	aadd(aCampo,"aCodItem")
	aadd(aCampo,"aDesPro")
    aadd(aCampo,"aQuantidade")
	// ***************************************************************************************************
	aadd(aMascara,"@!")
	aadd(aMascara,"@!")
    aadd(aMascara,"999")
    
	Window(07,00,21,99,"> EmissÆo de etiquetas <")
    @ 21,01 say " F2-Confirma | F4-Inclui | F6-Exclui | F8-Abandona " color Cor(26)
	Rodape("Esc-Encerra")
	setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
	// **keyboard chr(K_ENTER)
    lAbandonar := .f.
    do while .t.
        Edita_Vet(09,01,20,98,aCampo,aTitulo,aMascara,"vEtiquetas",,,,1)
        if lastkey() == K_F8
            if Aviso_1( 09,,14,,[Atencao!],"Confirma o cancelamento da proposta ?",{ [  ^Sim  ], [  ^Nao  ] }, 2, .t. ) = 1
                lAbandonar := .t.
                exit
            endif
	   elseif lastkey() == K_F2
	      if !Confirm("Confirma os produtos")
	         loop
	      endif
	      exit
	   endif
	enddo
    if lAbandonar
        FechaDados()
        RestWindow(cTela)
        return
    endif
    Msg(.t.)
    Msg("Aguarde: Gerando as etiquetas")
    for nI := 1 to len(aCodItem)
        if !empty(aCodItem[nI])
            Produtos->(dbsetorder(1),dbseek(aCodPro[nI]))
            for nX := 1 to aQuantidade[nI]
                Etiq->(dbappend())
                Etiq->Codigo := aCodPro[nI]
                Etiq->Descricao := aDespro[nI]
                Etiq->Preco1 := Produtos->pcoven
                //Etiq->Preco2 := Produtos->PcoCal
            next
        endif
    next
    Msg(.f.)
    If Aviso_1(09,,14,,[Aten‡„o!],[Imprimir Relat¢rio ?],{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
        if Ver_Imp2(@nVideo)
            if nVideo == 1
                cImpressoraPadrao := ImpressoraPadrao()
            endif
            oFrPrn := frReportManager():new()
            oFrPrn:LoadLangRes( 'brazil.xml')                     //arquivo de idioma
            oFrPrn:SetWorkArea("Etiq",select("Etiq"))
            oFrprn:LoadFromFile('etiq_a4635_254.fr3')
            oFrPrn:PrepareReport()
            oFrPrn:DesignReport()                                 // aqui para "desenhar" o relatório
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
    endif
    FechaDados()
    RestWindow(cTela)
return        
// ************************************************************************************************
Function vEtiquetas(Pos_H,Pos_V,Ln,Cl,Tecla) // Gets dos Itens do Pedido
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
            	aCodItem[pos_v] := cCodigo
                aCodPro[pos_v] := Produtos->CodPro
                aDesPro[pos_v] := Produtos->FanPro
            	keyboard replicate(chr(K_RIGHT),2)+chr(K_ENTER)
            	return(2)
            else
                lIncluir := .f.
         	endif
        // ** Quantidade
		elseif Pos_H == 3
			cCampo := aQuantidade[pos_v]
         	@ ln,Cl get cCampo picture "999";
         				when Rodape("Esc-Encerra")
         	setcursor(SC_NORMAL)
         	read
         	setcursor(SC_NONE)
         	if !(lastkey() == K_ESC)
            	aQuantidade[Pos_V] := cCampo
                if Pos_v >= len(aCodItem)
                    aadd(aCodItem,space(14))
                    aadd(aCodPro,space(06))
                    aadd(aDesPro,space(30))
                    aadd(aQuantidade,0)
                    keyboard chr(K_DOWN)+replicate(chr(K_LEFT),Pos_H-1)+chr(K_ENTER)
                    return(3)
                endif
            endif
        endif
	elseif Tecla == K_F4
        if !(pos_v = len(aCodItem))
            Mens({"Posicione no £ltimo produto para incluir um novo"})
            return(2)
        endif
        if Aviso_1( 27,,32,,"Atencao!","Incluir outro produto ?",{ [  ^Sim  ], [  ^Nao  ] }, 2, .t. ) = 1
            if !empty(aCodItem[pos_v])
                aadd(aCodItem,space(14))
                aadd(aCodPro,space(06))
                aadd(aDesPro,space(30))
                aadd(aQuantidade,0)
                keyboard chr(K_DOWN)+replicate(chr(K_LEFT),Pos_H-1)+chr(K_ENTER)
                return( 3 )
            endif
        endif
    elseif Tecla == K_F6
        if Aviso_1( 27,,32,,"Atencao!","Confirma a exclusÆo do produto ?",{ [  ^Sim  ], [  ^Nao  ] }, 2, .t. ) = 1
            if len(aCodItem) == 1
                aCodItem[Pos_V] := space(14)
                aCodPro[pos_v] := space(06)
                aDesPro[Pos_V] := space(30)
                aQuantidade[pos_v] := 0
         	    return(3)
            endif
            adel(aCodItem,Pos_V)
            adel(aCodPro,pos_v)
            adel(aDesPro,Pos_V)
            adel(aQuantidade,pos_V)
            nItens := len(aCodItem)-1
            asize(aCodItem,nItens)
            asize(aCodPro,nItens)
            asize(aDesPro,nItens)
            asize(aQuantidade,nItens)
        return(3)
    endif
   elseif Tecla == K_F2
      return(0)
    elseif Tecla == K_F8
   EndIf
	if lastkey() == K_ESC 
      if len(aCodItem) = 1
         aCodItem[Pos_V] := space(14)
         aCodPro[pos_v] := space(06)
         aDesPro[Pos_V] := space(30)
         aQuantidade[pos_v] := 0
         lIncluir := .t.
         return(3)
      else
         if empty(aCodItem[pos_v])
			   adel(aCodItem,Pos_V)
            adel(aCodPro,pos_v)
                adel(aDesPro,Pos_V)
                adel(aQuantidade,pos_v)
                nItens := len(aCodItem)-1
                asize(aCodItem,nItens)
                asize(aCodPro,nItens)
                asize(aDesPro,nItens)
                asize(aQuantidade,nItens)
                lIncluir := .t.
                return(3)
            endif
        endif
	endif
Return( 1 )
// ************************************************************************************************    
static function vCodigo(cCodProd,pos_v)  // Verifica se o item ja foi cadastrado

   if !(ascan(aCodItem,cCodProd) == 0) .and. !(aCodItem[pos_v] == cCodProd)
      Mens({"Produto j  inclu¡do"})
      return(.f.)
   endif
return(.t.)

//** Fim do Arquivo
