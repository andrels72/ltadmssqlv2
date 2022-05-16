/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 
 * Identificacao: Manutencao de NCM
 * Prefixo......: LtadmS
 * Programa.....: NCM.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 28 de Março de 2016
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConNCM(lAbrir)
	local getlist := {},oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados
	local nCursor := setcursor(),cCor := setcolor(),cQuery,oQuery
	local nLin1 := 02,nCol1 := 01,nLin2 := 30,nCol2 := 98
	local cPesquisar
 
	cQuery := "SELECT ncm FROM administrativo.ncm LIMIT 1 "
	if !ExecuteSql(cQuery,@oQuery,{"Falha: Acessar"},"sqlerro")
		oQuery:Close()
		return
	endif
	if oQuery:lastrec() = 0
		Mens({"Tabela vazia"})
		return
	endif
   if !lAbrir
	  setcursor(SC_NONE)
   endif
   Window(nLin1,nCol1,nLin2,nCol2,"> Tabela de NCM <")
   setcolor(Cor(11))
	@ nLin1+1,nCol1+1 say "Descri‡Æo: "
	cPesquisar := space(60)
	setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
	@ nLin1+1,nCol1+12 get cPesquisar picture "@k!"
	@ nLin1+2,nCol1+1 say replicate(chr(196),96)
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
	cQuery := "SELECT ncm,descricao,unidade FROM administrativo.ncm "
	if !empty(cPesquisar)
		cQuery += " WHERE descricao LIKE '"+rtrim(cPesquisar)+"%'"
	endif
	cQuery += " ORDER BY descricao"
	if !ExecuteSql(cQuery,@oQuery,{"Falha: Acessar (Historico bancario)"},"sqlerro")
		oQuery:Close()
		return
	endif
   if lAbrir
	  Rodape("Esc-Encerrar")
   else
	  Rodape("Esc-Encerra | ENTER-Transfere")
   endif
   n_Itens := lastrec()
   Pos := 1
   setcolor(cor(5))
   oBrow := TBrowseDB(nLin1+3,nCol1+1,nLin2-1,nCol2-1)
   oBrow:headSep := chr(194)+chr(196)
   oBrow:colSep  := chr(179)              
   oBrow:footSep := chr(193)+chr(196)
	oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)
	oCurRow := oQuery:GetRow( 1 )
	oBrow:SkipBlock := {| n | oCurRow := SkipperQuery( @n, oQuery ), n }
	oBrow:GoBottomBlock := {|| oCurRow := oQuery:GetRow( oQuery:LastRec() ), 1 }
	oBrow:GoTopBlock := {|| oCurRow := oQuery:GetRow( 1 ), 1 }
   
   oBrow:addcolumn(TBColumnNew("NCM" ,{|| oQuery:FieldGet('ncm') }))
   oBrow:addcolumn(TBColumnNew("Descri‡Æo" ,{|| LEFT(oQuery:FieldGet('descricao'),70)}))
   oBrow:addcolumn(TBColumnNew("Unidade" ,{|| oQuery:FieldGet('unidade')}))
   setcolor(Cor(26))
   WHILE (! lFim)
		ForceStable(oBrow)
		if ( obrow:hittop .or. obrow:hitbottom )
			tone(1200,1)
		endif
		aRect := { oBrow:rowPos,1,oBrow:rowPos,3}
		oBrow:colorRect(aRect,{2,2})
		cTecla := chr((nTecla := inkey(0)))
		if !OnKey( nTecla,oBrow)
		endif
		if nTecla == K_ENTER
			if !lAbrir
				cDados := oQuery:FieldGet('ncm')
				keyboard (cDados)+chr(K_ENTER)
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
	endif
   RestWindow( cTela )
RETURN
// ********************************************************************************************************		
procedure IncNCM
	local getlist := {},cTela := SaveWindow()
	local lLimpa := .t.
	private cCodNCM,cDescricao,cUnidade,cQuery,oQuery
	
	AtivaF4()
	TelNCM(1)
	do while .t.
		if lLimpa
			cCodNCM    := space(08)
			cDescricao := space(100)
			cUnidade   := space(04)
			lLimpa     := .f.
		endif
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 08,12 get cCodNCM picture "@k";
					when Rodape("Esc-Encerra | F4-NCM");
					valid SqlBusca("ncm = "+StringToSql(cCodNCM),"descricao",@oQuery,;
					"administrativo.ncm",,,,{"NCM j  cadastrado"},.t.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		@ 09,12 get cDescricao picture "@kS72";
				when Rodape("Esc-Encerra")
		@ 10,12 get cUnidade picture "@k!"
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			loop
		endif
		if !Confirm("Confirma a InclusÆo")
			loop
		endif
		cQuery := "INSERT INTO administrativo.ncm (ncm,descricao,unidade) "
		cQuery += "VALUES ("+StringToSql(cCodNCM)+","+StringToSql(cDescricao)+","+StringToSql(cUnidade)+")"
		Msg(.t.)
		Msg("Aguarde: Incluindo as informa‡äes")
		oServer:StartTransaction()
		if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar "},"sqlerro")
			oQuery:Close()
			oServer:Rollback()
			Msg(.f.)
			loop
		endif
		if !Grava_LogSql("Cadastros | Fiscal | Tabela de NCM | Incluir | NCM: "+cCodNCM)
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
	RestWindow(cTela)
return
// ********************************************************************************************************		
procedure AltNCM
	local getlist := {},cTela := SaveWindow()
	private cCodNCM,cDescricao,cUnidade,cQuery,oQuery
	
	AtivaF4()
	TelNCM(2)
	do while .t.
		cCodNCM    := space(08)
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 08,12 get cCodNCM picture "@k!";
					when Rodape("Esc-Encerra | F4-NCM");
					valid SqlBusca("ncm = "+StringToSql(cCodNCM),"descricao,unidade",@oQuery,;
					"administrativo.ncm",,,,{"NCM nÆo cadastrado"},.f.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		cDescricao := oQuery:fieldget('Descricao')
		cUnidade   := oQuery:fieldget('Unidade')
		@ 09,12 get cDescricao picture "@kS72";
				when Rodape("Esc-Encerra")
		@ 10,12 get cUnidade picture "@k!"
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			loop
		endif
		if !Confirm("Confirma a Altera‡Æo")
			loop
		endif
		cQuery := "UPDATE administrativo.ncm SET descricao = "+StringToSql(cDescricao)+", unidade = "+StringToSql(cUnidade)
		cQuery += " WHERE ncm = "+StringToSql(cCodNCM)
		Msg(.t.)
		Msg("Aguarde: Alterando as informa‡äes")
		oServer:StartTransaction()
		if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar "},"sqlerro")
			oQuery:Close()
			oServer:Rollback()
			Msg(.f.)
			loop
		endif
		if !Grava_LogSql("Cadastros | Fiscal | Tabela de NCM | Alterar | NCM: "+cCodNCM)
			oQuery:Close()
			oServer:Rollback()
			Msg(.f.)
			loop
		 endif
		oServer:Commit()
		oQuery:Close()
		MSg(.f.)
		Mens({"Altera‡Æo realizada com sucesso"})
	enddo
	DesativaF4()
	RestWindow(cTela)
return
// ********************************************************************************************************		
procedure ExcNCM
	local getlist := {},cTela := SaveWindow()
	local cCodNCM,cQuery,oQuery,oQProdutos
	
	AtivaF4()
	TelNCM(3)
	do while .t.
		cCodNCM    := space(08)
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 08,12 get cCodNCM picture "@k!";
					when Rodape("Esc-Encerra | F4-NCM");
					valid SqlBusca("ncm = "+StringToSql(cCodNCM),"descricao,unidade",@oQuery,;
					"administrativo.ncm",,,,{"NCM nÆo cadastrado"},.f.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		if SqlBusca("codncm = "+StringToSql(cNCMAtual),"fanpro",@oQProdutos,;
			"administrativo.produtos",,,,{"Existe produto(s) com esse NCM"},.f.)
			loop
		endif
		@ 09,12 say left(oQuery:FieldGet('Descricao'),72)
		@ 10,12 say oQuery:FieldGet('Unidade')
		if !Confirm("Confirma a ExclusÆo",2)
			loop
		endif
		cQuery := "DELETE FROM administrativo.ncm WHERE ncm = "+StringToSql(cCodNCM)
		Msg(.t.)
		Msg("Aguarde: Excluindo as informa‡äes")
		oServer:StartTransaction()
		if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar "},"sqlerro")
			oQuery:Close()
			oServer:Rollback()
			Msg(.f.)
			loop
		endif
		if !Grava_LogSql("Cadastros |Fiscal | Tabela de NCM | Excluir | NCM: "+cCodNCM)
			oQuery:Close()
			oServer:Rollback()
			Msg(.f.)
			loop
		 endif
		oServer:Commit()
		oQuery:Close()
		MSg(.f.)
		Mens({"ExclusÆo realizada com sucesso"})
	enddo
	DesativaF4()
	RestWindow(cTela)
return
// ********************************************************************************************************		
static procedure TelNCM(nModo)
	local aTitulo := {"Incluir","Alterar","Excluir"}
	
	Window(06,00,12,85,"> "+aTitulo[nModo]+" NCM <")
	setcolor(Cor(11))
	@ 08,01 say "      NCM:"
	@ 09,01 say "Descricao:"
	@ 10,01 say "  Unidade:"
return
	
// ** Fim do arquivo.
