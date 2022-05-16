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

procedure ConGrupoCliente(lAbrir,lAtivo)
	local acampo   := {"id","descricao"}
	local atitulo  := { "C¢digo","Descricao"}
	local amascara := { "999","@"}
	local nCursor := setcursor(),cCor := setcolor(),cQuery
	private oQuery
 
	cQuery := "SELECT id,descricao FROM administrativo.gruposclientes ORDER BY descricao "
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
	ViewTableSql(oQuery,02,35,30,79,"> Grupos de clientes <",2,iif(!lAbrir,"id",NIL),aCampo,aTitulo,aMascara)
	setcursor(nCursor)
	setcolor(cCor)
return


// ****************************************************************************
procedure IncGrupoCliente
   local getlist := {},cTela := SaveWindow()
   local nId,cNomGru,cQuery,oQuery
   
	if PwNivel == "0"
		DesativaF9()
	endif
	AtivaF4()
	TelGrupoCliente(1)
	while .t.
      cDescricao := space(30)
      oQuery := oServer:Query("SELECT Last_value FROM administrativo.gruposclientes_id_seq;")
      nId := oQuery:fieldget('last_value')
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,30 say nId picture "@k 999" 
      @ 12,30 get cDescricao picture "@k" when Rodape("Esc-Encerra")
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
      if !Confirm("Confirma a Inclusao")
         loop
      endif
      cQuery := "INSERT INTO administrativo.gruposclientes (descricao) "
      cQuery += "VALUES ("+StringToSql(cDescricao)+")"
      Msg(.t.)
      Msg("Aguarde: Gravando as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      if !Grava_LogSql("Cadastros|  Clientes | Grupos | Incluir | Codigo: "+str(nId))
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      oServer:Commit()
      oQuery:Close()
      Msg(.f.)
      Mens({"Grupo inclu¡do com sucesso"})
   enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   endif 
   RestWindow(cTela)
return
// *****************************************************************************
procedure AltGrupoCliente
   local getlist := {},cTela := SaveWindow()
   local nId,cDescricao,cQuery,oQuery

   if PwNivel == "0"
      DesativaF9()
   endif
   AtivaF4()
   TelGrupoCliente(2)
   while .t.
      nId := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,30 get nId picture "@k 999";
      			when Rodape("Esc-Encerra | F4-Grupos");
               valid SqlBusca("id = "+NumberToSql(nId),"descricao",@oQuery,;
               "administrativo.gruposclientes",,,,{"Grupo nÆo cadastrado"},.f.)
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
      cQuery := "UPDATE administrativo.gruposclientes SET descricao = "+StringToSql(cDescricao)
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
      if !Grava_LogSql("Cadastros|  Clientes | Grupos | Alterar | Codigo: "+str(nId))
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      oServer:Commit()
      oQuery:Close()
      MSg(.f.)
      Mens({"Grupo alterado com sucesso"})
   enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   end
   RestWindow(cTela)
return
// *****************************************************************************
procedure ExcGrupoCliente
   local getlist := {},cTela := SaveWindow()
   local nId,cQuery,oQuery

   if PwNivel == "0"
      DesativaF9()
   end
   AtivaF4()
   TelGrupoCliente(3)
   do while .t.
      nId := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,30 get nId picture "@k 999";
               when Rodape("Esc-Encerra | F4-Grupos");
               valid SqlBusca("id = "+NumberToSql(nId),"descricao",@oQuery,;
               "administrativo.gruposclientes",,,,{"Grupo nÆo cadastrado"},.f.)
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
      cQuery := "DELETE FROM administrativo.gruposclientes WHERE id = "+NumberToSql(nId)
      Msg(.t.)
      Msg("Aguarde: excluindo informa‡Æo")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Falha: excluir"},"sqlerro")
         oServer:Rollback()
         Msg(.f.)
         loop
      endif
      if !Grava_LogSql("Cadastros|  Clientes | Grupos | Excluir | Codigo: "+str(nId))
         oServer:Rollback()
         Msg(.f.)
         loop
      endif
      oServer:Commit()
      oQuery:Close()
      Msg(.f.)
      Mens({"Grupo excluido com sucesso"})
   enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   end
   RestWindow(cTela)
return
// *****************************************************************************
procedure TelGrupoCliente(nModo)
   local aTitulos := {"InclusÆo","Altera‡Æo","ExclusÆo"}

   Window(09,17,14,61,"> "+aTitulos[nModo]+" de Grupos <")
   setcolor(Cor(11))
   @ 11,19 say "   Codigo:"
   @ 12,19 say "Descricao:"
return

//** Fim do Arquivo.
