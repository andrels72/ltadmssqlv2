/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 3.00
 * Identificacao: Manutencao de credenciadora de cartão de credito/débito
 * Prefixo......: LTADM
 * Programa.....: credcartao
 * Autor........: Andre Lucas Souza
 * Data.........: 26 de fevereiro de 2015
 * Copyright (C): LT - LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConCredCartao(lAbrir,lIncluir)
	local getlist := {},oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados
	local nCursor := setcursor(),cCor := setcolor()
	local nLin1 := 02,nCol1 := 15,nLin2 := 30,nCol2 := 80
	local cQuery,oQuery
	local cPesquisar
	private nRecno
 
	cQuery := "SELECT id,cnpj,nome FROM administrativo.credcartao "
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
   Window(nLin1,nCol1,nLin2,nCol2,"> Tabela de Credenciado de cartao <")
   setcolor(Cor(11))
   if lAbrir
	  Rodape("Esc-Encerrar")
   else
	  Rodape("Esc-Encerra | ENTER-Transfere")
   endif
   n_Itens := lastrec()
   Pos := 1
   setcolor(cor(5))
   oBrow := TBrowseDB(nLin1+1,nCol1+1,nLin2-1,nCol2-1)
   oBrow:headSep := chr(194)+chr(196)
   oBrow:colSep  := chr(179)              
   oBrow:footSep := chr(193)+chr(196)
	oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)
	oCurRow := oQuery:GetRow( 1 )
	oBrow:SkipBlock := {| n | oCurRow := SkipperQuery( @n, oQuery ), n }
	oBrow:GoBottomBlock := {|| oCurRow := oQuery:GetRow( oQuery:LastRec() ), 1 }
	oBrow:GoTopBlock := {|| oCurRow := oQuery:GetRow( 1 ), 1 }
	oBrow:addcolumn(TBColumnNew("C¢digo" ,{|| str(oQuery:FieldGet('id'),2) }))	
	oBrow:addcolumn(TBColumnNew("Cnpj" ,{|| transform(oQuery:FieldGet('cnpj'),"@r 99.999.999/9999-99")}))
   oBrow:addcolumn(TBColumnNew("Nome" ,{|| oQuery:FieldGet('nome')}))	
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
				cDados := str(oQuery:FieldGet('id'))
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

// ****************************************************************************
procedure IncCredCartao
   local getlist := {},cTela := SaveWindow()
   local nId,cCnpj,cNome,cQuery,oQuery

   if PwNivel == "0"
      DesativaF9()
   endif
   AtivaF4()
   TelCredCartao(1)
	do while .t.
      nId := 0
		cCnpj := space(14)
		cNome := space(30)
      oQuery := oServer:Query("SELECT Last_value FROM administrativo.credcartao_id_seq")
      nId := oQuery:fieldget('last_value')
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,30 say nId picture "99"
      @ 12,30 get cCnpj picture "@r 99.999.999/9999-99";
                     when Rodape("Esc-Encerra | F4-Cred. Cartao");
                     valid SqlBusca("id = "+NumberToSql(nId),"nome",@oQuery,;
                     "administrativo.credcartao",,,,{"Credenciadora j  cadastrada"},.t.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      @ 13,30 get cNome picture "@k";
                        when Rodape("Esc-Encerra")
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      endif
      if !Confirm("Confirma a Inclusao")
         loop
      endif
      cQuery := "INSERT INTO administrativo.credcartao (cnpj,nome) VALUES ("+StringToSql(cCnpj)+","+StringToSql(cNome)+")"
      Msg(.t.)
      Msg("Aguarde: Gravando as informa?„es")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar "},"sqlerro")
         oQuery:Close()
         oServer:Rollback()
         Msg(.f.)
         loop
      endif
      if !Grava_LogSql("Cadastros|Financeiro|Credenciadora de cartao|Incluir|Codigo: "+str(nId))
         oQuery:Close()
         oServer:Rollback()
         Msg(.f.)
         loop
      endif
      oServer:Commit()
      oQuery:Close()
      MSg(.f.)
   enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   endif
   RestWindow(cTela)
return
// *****************************************************************************
procedure AltCredCartao
   local getlist := {},cTela := SaveWindow()
   local nId,cCnpj,cNome,cQuery,oQuery

   if PwNivel == "0"
      DesativaF9()
   endif
   AtivaF4()
   TelCredCartao(2)
	do while .t.
		nId := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,30 get nId picture "@k 99";
               when Rodape("Esc-Encerra | F4-Cred. Cartao");
               valid SqlBusca("id = "+NumberToSql(nId),"cnpj,nome",@oQuery,;
               "administrativo.credcartao",,,,{"Credenciadora nÆo cadastrada"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      cCnpj := oQuery:fieldget('cnpj')
      cNome := oQuery:fieldget('Nome')
      @ 12,30 get cCnpj picture "@r 99.999.999/9999-99";
                           when Rodape("Esc-Encerra | F4-Cred. Cartao");
      		               valid iif(cCnpj == oQuery:fieldget('Cnpj'),.t.,;
                                 SqlBusca("cnpj = "+StringToSql(cCnpj),"cnpj,nome",@oQuery,;
                                 "administrativo.credcartao",,,,{"Credenciadora j  cadastrada"},.t.))
      @ 13,30 get cNome picture "@k" when Rodape("Esc-Encerra")
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      endif
      if !Confirm("Confirma a Alteracao")
        	loop
      endif
      cQuery := "UPDATE administrativo.credcartao SET cnpj = "+StringToSql(cCnpj)+", nome = "+StringToSql(cNome)
      cQuery += " WHERE id = "+NumberToSql(nId)
      Msg(.t.)
      Msg("Aguarde: Gravando as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar "},"sqlerro")
         oQuery:Close()
         oServer:Rollback()
         Msg(.f.)
         loop
      endif
      if !Grava_LogSql("Cadastros|Financeiro|Credenciadora de cartao|Alterar|Codigo: "+str(nId))
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
   if PwNivel == "0"
    	AtivaF9()
      lGeral := .f.
   endif
   RestWindow(cTela)
return
// *****************************************************************************
procedure ExcCredCartao
   local getlist := {},cTela := SaveWindow()
   local nId,cQuery,oQuery

   if PwNivel == "0"
      DesativaF9()
   endif
   AtivaF4()
   TelCredCartao(3)
	do while .t.
      nId := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,30 get nId picture "@k 99";
               when Rodape("Esc-Encerra | F4-Cred. Cartao");
               valid SqlBusca("id = "+NumberToSql(nId),"cnpj,nome",@oQuery,;
               "administrativo.credcartao",,,,{"Credenciadora nÆo cadastrada"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      @ 12,30 say oQuery:FieldGet('cnpj') picture "@r 99.999.999/9999-99"
      @ 13,30 say oQuery:FieldGet('nome')
      if !Confirm("Confirma a Exclusao",2)
        	loop
      endif
      cQuery := "DELETE FROM administrativo.credcartao WHERE id = "+NumberToSql(nId)
      Msg(.t.)
      Msg("Aguarde: excluindo as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar "},"sqlerro")
         oQuery:Close()
         oServer:Rollback()
         Msg(.f.)
         loop
      endif
      if !Grava_LogSql("Cadastros|Financeiro|Credenciadora de cartao|Excluir|Codigo: "+str(nId))
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
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   endif
   RestWindow(cTela)
return
   
// *****************************************************************************
procedure TelCredCartao(nModo)
   local aTitulos := {"InclusÆo","Altera‡Æo","ExclusÆo"}

   Window(09,17,15,61,"> "+aTitulos[nModo]+" de Credenciadora de Cartao <")
   setcolor(Cor(11))
   @ 11,19 say "   Codigo:"
   @ 12,19 say "     CNPJ:"
   @ 13,19 say "     Nome:"
   return

//** Fim do Arquivo.
