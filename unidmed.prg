/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 3.00
 * Identificacao: Manutencao de Caixas
 * Prefixo......: LTADM
 * Programa.....: CAIXA.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 28 DE DEZEMBRO DE 2002
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConUnidMed(lAbrir)
	local acampo   := {"unidade","descricao"}
	local atitulo  := { "Unidade","Descricao"}
	local amascara := { "@!","@!"}
	local nCursor := setcursor(),cCor := setcolor(),cQuery
	private oQuery
 
	cQuery := "SELECT unidade,descricao FROM administrativo.unidmedida ORDER BY descricao "
	Msg(.t.)
	Msg("Aguarde: pesquisando")
	if !ExecuteSql(cQuery,@oQuery,{"Falha: pesquisa "},"sqlerro")
	   Msg(.f.)
	   return
	endif
	Msg(.f.)
	if oQuery:lastrec() = 0
	   Mens({"Tabela vazia"})
	   return
	endif
	ViewTableSql(oQuery,02,38,33,79,"> Unidade de medida <",2,iif(!lAbrir,"unidade",NIL),aCampo,aTitulo,aMascara)
	setcursor(nCursor)
	setcolor(cCor)
return
 
	
procedure IncUnidMed
	local getlist := {}, cTela := SaveWindow()
	local cCodMed,cDesMed,cQuery,oQuery
	
	AtivaF4()
	TelUnidMed(1)
	do while .t.
		cCodMed := space(04)
		cDesMed := space(15)
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 11,14 get cCodMed picture "@k!";
				when Rodape("Esc-Encerra | F4-Unidades");
				valid SqlBusca("unidade = "+StringToSql(cCodMed),"descricao",@oQuery,;
				"administrativo.unidmedida",,,,{"Unidade de medida j  cadastrada"},.t.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		@ 12,14 get cDesMed picture "@k";
					when Rodape("Esc-Encerra")
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			loop
		endif
		if !Confirm("Confirma a inclusÆo")
			loop
		endif
		cQuery := "INSERT INTO administrativo.unidmedida (unidade,descricao) "
		cQuery += "VALUES ("+StringToSql(cCodMed)+","+StringToSql(cDesMed)+")"
		Msg(.t.)
		Msg("Aguarde: incluindo a informa‡Æo")
		oServer:StartTransaction()
		if !ExecuteSql(cQuery,@oQuery,{"Falha: excluir"},"sqlerro")
		   oServer:Rollback()
		   Msg(.f.)
		   loop
		endif
	   /*
	   if !Grava_LogSql("Cadastros|Caixa|Excluir|Codigo "+str(nCodCaixa))
		   oServer:Rollback()
		   Msg(.f.)
		   loop
	   endif
	   */
	   oServer:Commit()
	   oQuery:Close()
	   Msg(.f.)
	enddo
	DesativaF4()
	RestWindow(cTela)
return
	
procedure AltUnidMed
	local getlist := {}, cTela := SaveWindow()
	local cCodMed,cDesMed,cQuery,oQuery
	
	AtivaF4()
	TelUnidMed(2)
	do while .t.
		cCodMed := space(04)
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 11,14 get cCodMed picture "@k!";
				when Rodape("Esc-Encerra | F4-Unidades");
				valid SqlBusca("unidade = "+StringToSql(cCodMed),"descricao",@oQuery,;
				"administrativo.unidmedida",,,,{"Unidade de medida nÆo cadastrada"},.f.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		cDesMed := oQuery:fieldget('descricao')
		@ 12,14 get cDesMed picture "@k";
					when Rodape("Esc-Encerra")
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			loop
		endif
		if !Confirm("Confirma a altera‡Æo")
			loop
		endif
		cQuery := "UPDATE administrativo.unidmedida SET descricao = "+StringToSql(cDesMed)+" WHERE unidade = "+StringToSql(cCodMed)
		Msg(.t.)
		Msg("Aguarde: alterando a informa‡Æo")
		oServer:StartTransaction()
		if !ExecuteSql(cQuery,@oQuery,{"Falha: excluir"},"sqlerro")
			oServer:Rollback()
			Msg(.f.)
			loop
		endif
		oServer:Commit()
		oQuery:Close()
		Msg(.F.)
	enddo
	DesativaF4()
	Fechadados()
	RestWindow(cTela)
return
	
procedure ExcUnidMed
	local getlist := {}, cTela := SaveWindow()
	local cCodMed,cQuery,oQuery

	AtivaF4()
	TelUnidMed(3)
	do while .t.
		cCodMed := space(04)
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 11,14 get cCodMed picture "@k!";
				when Rodape("Esc-Encerra | F4-Unidades");
				valid SqlBusca("unidade = "+StringToSql(cCodMed),"descricao",@oQuery,;
				"administrativo.unidmedida",,,,{"Unidade de medida nÆo cadastrada"},.f.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		@ 12,14 say oQuery:fieldget('descricao') picture "@k"
		if !Confirm("Confirma a exclusÆo")
			loop
		endif
		cQuery := "DELETE FROM administrativo.unidmedida WHERE unidade = "+StringToSql(cCodMed)
		Msg(.t.)
		Msg("Aguarde: excluindo informa‡Æo")
		oServer:StartTransaction()
		if !ExecuteSql(cQuery,@oQuery,{"Falha: excluir"},"sqlerro")
			oServer:Rollback()
			Msg(.f.)
			loop
		endif
		oServer:Commit()
		oQuery:Close()
	enddo
	DesativaF4()
	RestWindow(cTela)
return
	
procedure TelUnidMed(nModo)
	local cTitulo, aTitulos := { "InclusÆo" , "Altera‡Æo" , "ExclusÆo" }

	Window(09,01,14,31,"> "+aTitulos[nModo]+" de Unid. Medida <")
	setcolor(Cor(11))
	//           3456789012345
	@ 11,03 say "  Unidade:"
	@ 12,03 say "Descricao:"
	return

static function AbrirArquivos
		
	Msg(.t.)
	Msg("Aguarde : Abrindo o Arquivo")
	if !OpenUnidadeDeMedida()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
	Msg(.f.)
	return(.t.)
	
	
// ** Fim do arquivo
	
   

