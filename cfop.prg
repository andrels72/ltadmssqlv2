#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConCFOP(lAbrir)
	local getlist := {},oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados
	local nCursor := setcursor(),cCor := setcolor()
	local nLin1 := 02,nCol1 := 01,nLin2 := 30,nCol2 := 95
	local cQuery,oQuery
	local cPesquisar
	private nRecno
 
	cQuery := "SELECT cfop FROM administrativo.cfop LIMIT 1 "
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
   Window(nLin1,nCol1,nLin2,nCol2,"> Tabela de CFOP <")
   setcolor(Cor(11))
	@ nLin1+1,nCol1+1 say "Descri‡Æo: "
	cPesquisar := space(70)
	setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
	@ nLin1+1,nCol1+12 get cPesquisar picture "@k!"
	@ nLin1+2,nCol1+1 say replicate(chr(196),93)
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
	cQuery := "SELECT cfop,descricao FROM administrativo.cfop "
	if !empty(cPesquisar)
		cQuery += " WHERE descricao LIKE '"+rtrim(cPesquisar)+"%'"
	endif
	cQuery += " ORDER BY cfop"
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
	oBrow:addcolumn(TBColumnNew("C¢digo" ,{|| oQuery:FieldGet('cfop') }))	
	oBrow:addcolumn(TBColumnNew("Descri‡Æo" ,{|| oQuery:FieldGet('descricao')}))
	setcolor(Cor(26))
	do WHILE (! lFim)
		ForceStable(oBrow)
		if ( obrow:hittop .or. obrow:hitbottom )
			tone(1200,1)
		endif
		aRect := { oBrow:rowPos,1,oBrow:rowPos,2}
		oBrow:colorRect(aRect,{2,2})
		cTecla := chr((nTecla := inkey(0)))
		if !OnKey( nTecla,oBrow)
		endif
		if nTecla == K_ENTER
			if !lAbrir
				cDados := oQuery:FieldGet('cfop')
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
procedure IncCfop
	local getlist := {},cTela := SaveWindow()
	local lLimpa := .t.
	private nCfop,cDescricao,cQuery,oQuery
	
	AtivaF4()
	TelCfop(1)
	do while .t.
		if lLimpa
			nCfop := 0
			cDescricao := space(80)
			lLimpa := .f.
		endif
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 08,12 get nCfop picture "@k 9999";
					when Rodape("Esc-Encerra | F4-CFOP");
					valid SqlBusca("cfop = "+NumberToSql(nCfop),"descricao",@oQuery,;
					"administrativo.cfop",,,,{"CFOP j  cadastrado"},.t.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		@ 09,12 get cDescricao picture "@k"
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			loop
		endif
		if !Confirm("Confirma a Inclusao")
			loop
		endif
        Msg(.t.)
        Msg("Aguarde: Gravando as informa‡äes")
		oServer:StartTransaction() // Inicia a transa‡Æo
		GravarCfop(.t.)
        if !ExecuteSql(cQuery,@oQuery,{"Falha: Incluir"},"sqlerro")
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        if !Grava_LogSql("Cadastros|Fiscal|CFOP|Incluir|CFOP: "+Str(nCfop))
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        oServer:Commit()
        oQuery:Close()
		Msg(.f.)
		lLimpa := .t.
	enddo
	DesativaF4()
	RestWindow(cTela)
return
// ********************************************************************************************************		
procedure AltCfop
	local getlist := {},cTela := SaveWindow()
	private nCfop,cDescricao,cQuery,oQuery
	
	AtivaF4()
	TelCfop(2)
	do while .t.
		nCfop := 0
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 08,12 get nCfop picture "@k 9999";
					when Rodape("Esc-Encerra | F4-CFOP");
					valid SqlBusca("cfop = "+NumberToSql(nCfop),"descricao",@oQuery,;
					"administrativo.cfop",,,,{"CFOP nÆo cadastrado"},.f.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		cDescricao := oQuery:fieldget('Descricao')
		@ 09,12 get cDescricao picture "@k";
				when Rodape("Esc-Encerra")
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			loop
		endif
		if !Confirm("Confirma a Alteracao")
			loop
		endif
        Msg(.t.)
        Msg("Aguarde: Gravando as informa‡äes")
		oServer:StartTransaction() // Inicia a transa‡Æo
		GravarCfop(.f.)
        if !ExecuteSql(cQuery,@oQuery,{"Falha: Incluir"},"sqlerro")
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        if !Grava_LogSql("Cadastros|Fiscal|CFOP|Alterar|CFOP: "+Str(nCfop))
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        oServer:Commit()
        oQuery:Close()
		Msg(.f.)
		Mens({"Altera‡Æo realizada com sucesso"})
	enddo
	DesativaF4()
	RestWindow(cTela)
return
// ********************************************************************************************************		
procedure ExcCfop
	local getlist := {},cTela := SaveWindow()
	local nCfop,cQuery,oQuery
	
	AtivaF4()
	TelCfop(3)
	do while .t.
		nCfop := 0
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 08,12 get nCfop picture "@k 9999";
					when Rodape("Esc-Encerra | F4-CFOP");
					valid SqlBusca("cfop = "+NumberToSql(nCfop),"descricao",@oQuery,;
					"administrativo.cfop",,,,{"CFOP nÆo cadastrado"},.f.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		@ 09,12 say oQuery:fieldget('Descricao')
		if !Confirm("Confirma a Exclusao")
			loop
		endif
		cQuery := "DELETE FROM administrativo.cfop WHERE cfop = "+NumberToSql(nCfop)
        Msg(.t.)
        Msg("Aguarde: Excuindo as informa‡äes")
		oServer:StartTransaction() // Inicia a transa‡Æo
		GravarCfop(.f.)
        if !ExecuteSql(cQuery,@oQuery,{"Falha: Incluir"},"sqlerro")
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        if !Grava_LogSql("Cadastros|Fiscal|CFOP|Excluir|CFOP: "+Str(nCfop))
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        oServer:Commit()
        oQuery:Close()
		Msg(.f.)
		Mens({"ExclusÆo realizada com sucesso"})
	enddo
	DesativaF4()
	RestWindow(cTela)
return
// ********************************************************************************************************		
static procedure TelCfop(nModo)
	local aTitulo := {"Incluir","Alterar","Excluir"}
	
	
	Window(06,00,11,95,"> "+aTitulo[nModo]+" CFOP <")
	setcolor(Cor(11))
	@ 08,01 say "     CFOP:"
	@ 09,01 say "Descricao:"
return
// ********************************************************************************************************	
static procedure GravarCfop(lIncluir)

	if lIncluir
		cQuery := "INSERT INTO administrativo.cfop (cfop,descricao) "
		cQuery += "VALUES ("+NumberToSql(nCfop)+","+StringToSql(cDescricao)+")"
	else
		cQuery := "UPDATE administrativo.cfop SET descricao = "+StringToSql(cDescricao)+" WHERE cfop ="+NumberToSql(nCfop)
	endif
return
	
	
// ** Fim do arquivo.
