/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 3.00
 * Identificacao: Manutencao de Grupos de Produtos
 * Prefixo......: LTADM
 * Programa.....: Grupos.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 05 de Mar‡o de 2004
 * Copyright (C): LT - LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConGrupo(lAbrir,lAtivo)
	local acampo   := {"id","descricao"}
	local atitulo  := { "C¢digo","Descricao"}
	local amascara := { "999","@"}
	local nCursor := setcursor(),cCor := setcolor(),cQuery
	private oQuery
 
	cQuery := "SELECT id,descricao FROM administrativo.grupos ORDER BY descricao "
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
	ViewTableSql(oQuery,02,38,33,79,"> Grupo de produtos <",2,iif(!lAbrir,"id",NIL),aCampo,aTitulo,aMascara)
	setcursor(nCursor)
	setcolor(cCor)
return


// ****************************************************************************
procedure IncGrupo
   local getlist := {},cTela := SaveWindow()
   local nId,cDescricao,cQuery,oQuery
   
	if PwNivel == "0"
		DesativaF9()
	endif
	AtivaF4()
	TelGrupo(1)
	while .t.
      nId := 0
      cDescricao := space(30)
      cQuery := "SELECT Last_value FROM administrativo.grupos_id_seq;"
      if !ExecuteSql(cQuery,@oQuery,{"Falha: "},"sqlerro")
         oQuery:Close()
         exit
      endif
      nId := strzero(oQuery:fieldget('last_value'),3)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,30 say nId picture "@k 999" 
      @ 12,30 get cDescricao picture "@k";
            when Rodape("Esc-Encerra")
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
      if !Confirm("Confirma a Inclusao")
         loop
      endif
      cQuery := "INSERT INTO administrativo.grupos (descricao) "
      cQuery += "VALUES ("+StringToSql(cDescricao)+")"
      Msg(.t.)
      Msg("Aguarde: Gravando as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Falha: gravar"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      if !Grava_LogSql("Cadastros|Produtos|Grupos|Incluir|Codigo "+nId)
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      oServer:Commit()
      oQuery:Close()
      Msg(.f.)
   enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   end
   RestWindow(cTela)
return
// *****************************************************************************
procedure AltGrupo
   local getlist := {},cTela := SaveWindow()
   local nId,cDescricao,cQuery,oQuery

   if PwNivel == "0"
      DesativaF9()
   endif
   AtivaF4()
   TelGrupo(2)
   while .t.
      nId := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,30 get nId picture "@k 999";
      			when Rodape("Esc-Encerra | F4-Grupos");
               valid SqlBusca("id = "+NumberToSql(nId),"descricao",@oQuery,;
               "administrativo.grupos",,,,{"Grupo nÆo cadastrado"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      cDescricao := oQuery:fieldget('descricao')
      @ 12,30 get cDescricao picture "@k";
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
      cQuery := "UPDATE administrativo.grupos SET descricao = "+StringToSql(cDescricao)
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
      /*
      if !Grava_LogSql("Cadastros|Caixa|Alterar|Codigo "+str(nCodCaixa),2112)
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      */
      oServer:Commit()
      oQuery:Close()
      MSg(.f.)
   enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   end
   RestWindow(cTela)
return
// *****************************************************************************
procedure ExcGrupo
   local getlist := {},cTela := SaveWindow()
   local nId,cQuery,oQuery

   if PwNivel == "0"
      DesativaF9()
   end
   AtivaF4()
   TelGrupo(3)
   do while .t.
      nId := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,30 get nId picture "@k 999";
               when Rodape("Esc-Encerra | F4-Grupos");
               valid SqlBusca("id = "+NumberToSql(nId),"descricao",@oQuery,;
               "administrativo.grupos",,,,{"Grupo nÆo cadastrado"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      @ 12,30 say oQuery:FieldGet('descricao')
      if !Confirm("Confirma a Exclusao",2)
         loop
      end
      cQuery := "DELETE FROM administrativo.grupos WHERE id = "+NumberToSql(nId)
      Msg(.t.)
      Msg("Aguarde: excluindo informa?’o")
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
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   end
   RestWindow(cTela)
return
// *****************************************************************************
procedure TelGrupo(nModo)
   local aTitulos := {"InclusÆo","Altera‡Æo","ExclusÆo"}

   Window(09,17,14,61,"> "+aTitulos[nModo]+" de Grupos <")
   setcolor(Cor(11))
   @ 11,19 say "   Codigo:"
   @ 12,19 say "Descricao:"
return

//** Fim do Arquivo.
