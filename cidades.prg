/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.00
 * Identificacao: Manuten‡Æo de Cidades
 * Prefixo......: LtAdm
 * Programa.....: Cidades.prg
 * Autor........: Andre Lucas Souza
 * Data.........: 23 de Setembro de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConCidades(lAbrir,lIncluir)
   local getlist := {},oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados
   local nCursor := setcursor(),cCor := setcolor(),nLin1 := 02,nCol1 := 10
    local nLin2 := 30,nCol2 := 81,cQuery,oQuery
    local cPesquisar
    
   private nRecno
   
    Msg(.t.)
    Msg("Aguarde: pesquisando cidades")
    if !ExecuteSql("SELECT codcid FROM administrativo.cidades LIMIT 1",@oQuery,{"Falha: pesquisr"},"sqlerro")
        Msg(.f.)
        RestWindow(cTela)
        return
    endif
    Msg(.f.)
    if oQuery:lastrec() = 0
        Mens({"Tabela vazia"})
        return
    endif
    if !lAbrir
        setcursor(SC_NONE)
    endif
    Window(nLin1,nCol1,nLin2,nCol2,"> Consulta de Cidades <")
    setcolor(Cor(11))
    @ nLin1+1,nCol1+1 say "Cidade: "
    cPesquisar := space(40)
    setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
    @ nLin1+1,nCol1+09 get cPesquisar picture "@k!"
    @ nLin1+2,nCol1+1 say replicate(chr(196),70)
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
    cQuery := "SELECT codcid,nomcid,estcid,codibge FROM administrativo.cidades"
    if !empty(cPesquisar)
        cQuery += " WHERE NomCid LIKE '"+rtrim(cPesquisar)+"%'"
    endif
    cQuery += " ORDER BY nomcid"
    Msg(.t.)
    Msg("Aguarde: pesquisando as informa?„es")
    if !ExecuteSql(cQuery,@oQuery,{"Falha: pesquisr"},"sqlerro")
        oQuery:Close()
        Msg(.f.)
        RestWindow(cTela)
        return
    endif
    if oQuery:lastrec() = 0
        if !empty(cPesquisar)
            Msg(.f.)
            Mens({"Cidade nÆo cadastrada"})
            RestWindow(cTela)
            return
        endif
    endif
    Msg(.f.)
    if lAbrir
        Rodape("Esc-Encerrar")
    else
        Rodape("Esc-Encerra | ENTER-Transfere")
    endif
    setcolor(cor(5))
    oBrow := TBrowseDB(nLin1+3,nCol1+1,nLin2-1,nCol2-1)
    oBrow:headSep := SEPH
    oBrow:colSep  := SEPV
    oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)
    oCurRow := oQuery:GetRow( 1 )
    oBrow:SkipBlock := {| n | oCurRow := SkipperQuery( @n, oQuery ), n }
    oBrow:GoBottomBlock := {|| oCurRow := oQuery:GetRow( oQuery:LastRec() ), 1 }
    oBrow:GoTopBlock := {|| oCurRow := oQuery:GetRow( 1 ), 1 }
    oBrow:addcolumn(tbcolumnnew("Codigo",{|| transform(oQuery:FieldGet('codCid'),"9999")}))
    oBrow:addcolumn(tbcolumnnew("Cidade",{|| oQuery:FieldGet('nomCid')}))
    oBrow:addcolumn(tbcolumnnew("Estado",{|| oQuery:FieldGet('EstCid')}))
    oBrow:addcolumn(tbcolumnnew("IBGE",{|| oQuery:FieldGet('CodIbge')}))
    do while (! lFim)
        ForceStable(oBrow)
        if ( obrow:hittop .or. obrow:hitbottom )
            tone(1200,1)
        endif
        aRect := { oBrow:rowPos,1,oBrow:rowPos,4}
        oBrow:colorRect(aRect,{2,2})
        cTecla := chr((nTecla := inkey(0)))
        if !OnKey( nTecla,oBrow)
        endif
        if nTecla == K_ENTER
            if !lAbrir
                cDados := str(oQuery:FieldGet('codcid'))
                keyboard (cDados)+chr(K_ENTER)
                lFim := .t.
            endif
        elseif nTecla == K_F7 .and. lIncluir .and. !lAbrir
            IncCidades(.f.)
            oBrow:refreshall()
        elseif nTecla == K_ESC
            lFim := .t.
        endif
        oBrow:refreshcurrent()
    enddo
    if !lAbrir
        setcursor(nCursor)
        setcolor(cCor)
    else
        oQuery:Close()
    endif
    RestWindow( cTela )
return
// ****************************************************************************
procedure IncCidades(lAbrir)
	local getlist := {},cTela := SaveWindow()
    local cQuery,oQuery
	private cCodCid,cNomCid,cEstCid,cCodIBGE

    AtivaF4()
    TelaCidade(1)
    do while .t.
        cNomCid  := space(40)
        cEstCid  := space(02)
        cCodIBGE := space(07)
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        // ***********************************************************************
        oQuery  := oServer:Query("SELECT Last_value FROM administrativo.cidades_codcid_seq")
        nCodCid := oQuery:fieldget('last_value')
        @ 10,26 say cCodCid picture "9999"
		if !GetCidades()
			exit
		endif
      	if !Confirm("Confirma a Inclusao")
         	loop
      	endif
      	GravarCidades(.t.)
      	Grava_Log(cDiretorio,"Cidades|Incluir|Codigo "+cCodCid,Cidades->(recno()))
      	if !lAbrir
         	exit
      	endif
   	enddo
   	if lAbrir
      	DesativaF4()
      	FechaDados()
   	endif
   	RestWindow(cTela)
return
// ****************************************************************************
procedure AltCidades
    local getlist := {},cTela := SaveWindow()
    local cQuery,oQuery
	private nId,cNomCid,cEstCid,cCodIbge
	
    AtivaF4()
    TelaCidade(2)
    do while .t.
        nId := 0
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 10,26 get nId picture "@k 9999";
            when Rodape("Esc-Encerra | F4-Cidades");
            valid SqlBusca("codcid = "+NumberToSql(nId),"nomcid,estcid,vlrfre,codibge",@oQuery,;
                "administrativo.cidades",,,,{"Cidade nÆo cadastrada"},.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
		cNomCid  := oQuery:Fieldget('NomCid')
		cEstCid  := oQuery:FieldGet('EstCid')
		cCOdIBGE := oQuery:FieldGet('CodIBGE')
		if !GetCidades()
			loop
		endif
		if !Confirm("Confirma a Alteracao")
			loop
		endif
        Msg(.t.)
        Msg("Aguarde: Gravando as informa‡äes")
        oServer:StartTransaction()
		if !GravarCidades(.f.)
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        if !Grava_LogSql("Cadastros |  Cidades | Alterar | Codigo: "+str(nId))
            oServer:Rollback()
            Msg(.f.)
            loop
         endif
         oServer:Commit()
         oQuery:Close()
         Msg(.f.)
         Mens({"Cidade alterada com sucesso"})
   enddo
   DesativaF4()
   RestWindow(cTela)
return
// ****************************************************************************
procedure ExcCidades
    local getlist := {},cTela := SaveWindow()
    local nId,cQuery,oQuery
   
    AtivaF4()
    TelaCidade(3)
    do while .t.
        nId := 0
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 10,25 get nId picture "@k 9999";
                when Rodape("Esc-Encerra | F4-Cidades");
                valid SqlBusca("codcid = "+NumberToSql(nId),"nomcid,estcid,vlrfre,codibge",@oQuery,;
                    "administrativo.cidades",,,,{"Cidade nÆo cadastrada"},.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif 
        @ 11,26 say oQuery:FieldGet('nomcid') 
        @ 12,26 say oQuery:FieldGet('estcid') 
        @ 13,26 say oQuery:FieldGet('CodIbge')
        if !Confirm("Confirma a Exclusao",2)
            loop
        endif 
   enddo
   DesativaF4()
   RestWindow(cTela)
return
// ****************************************************************************
procedure TelaCidade( nModo)
   local aTitulos := {"Inclusao","Alteracao","Exclusao"}

   Window(08,14,15,67,"> " + aTitulos[ nModo ] + " de Cidades <")
   setcolor(Cor(11))
   //           678901234567890123456789012345678901234567890123456789012345678
   //               2         3         4         5         6         7
   @ 10,16 say "  Codigo:"
   @ 11,16 say "    Nome:"
   @ 12,16 say "  Estado:"
   @ 13,16 say "Cod.IBGE:"
return
// ****************************************************************************

static function GetCidades
    local oQuery
	local lRetorno := .t.

	@ 11,26 get cNomCid picture "@k!" when Rodape("Esc-Encerra") valid NoEmpty(cNomCid)
	@ 12,26 get cEstCid picture "@k!";
			when Rodape("Esc-Encerra | F4-Estados");
            valid SqlBusca("codest = "+StringToSql(cEstCid),"nomest",@oQuery,;
            "administrativo.estados",,,,{"Estado nÆo cadastrado"},.f.)
	@ 13,26 get cCodIbge picture "@k 9999999";
				when Rodape("Esc-Encerra")
	setcursor(SC_NORMAL)
	read
	setcursor(SC_NONE)
	if lastkey() == K_ESC
		lRetorno := .f.
	endif
return(lRetorno)
	
static procedure GravarCidades(lIncluir)
    local cQuery,oQuery

	if lIncluir
        cQuery := "INSERT INTO administrativo.cidades (NomCid,EstCid,CodIbge) VALUES ("
        cQuery += StringToSql(cNomCid)+","+StringToSql(cEstCid)+","+StringToSql(cCodIBGE)+")"
	else
        cQuery := "UPDATE administrativo.cidades "
        cQuery += "SET NomCid = "+StringToSql(cNomCid)+", estcid = "+StringToSql(cEstCid)+", codibge = "+StringToSql(cCodIBGE)+" "
        cQuery += "WHERE codcid = "+NumberToSql(nId)
	endif
    if !ExecuteSql(cQuery,@oQuery,{"Erro: cidades"},"sqlerro")
        return(.f.)
    endif
return(.t.)
	
// ** Fim do Arquivo.
