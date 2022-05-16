/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.00
 * Identificacao: Manuten‡Æo de Situa‡Æo Tribut ria
 * Prefixo......: LtAdm
 * Programa.....: SitTrib.prg
 * Autor........: Andre Lucas Souza
 * Data.........: 24 de Novembro de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConSitTrib(lAbrir)
	local acampo   := {"id","descricao"}
	local atitulo  := { "C¢digo","Descricao"}
	local amascara := { "999","@"}
	local nCursor := setcursor(),cCor := setcolor(),cQuery
	private oQuery
 
	cQuery := "SELECT id,descricao FROM administrativo.sittrib ORDER BY id "
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
	ViewTableSql(oQuery,02,05,33,79,"> Situa‡Æo tribut ria <",2,iif(!lAbrir,"id",NIL),aCampo,aTitulo,aMascara)
	setcursor(nCursor)
	setcolor(cCor)
return

// ****************************************************************************
procedure IncSitTrib
   local gelist := {},cTela := SaveWindow()
   local nId,cDescricao,cQuery,oQuery

   AtivaF4()
   TelSitTrib(1)
   do while .t.
      nId := 0
      cDescricao := space(60)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,20 get nId picture "@k 999";
               when Rodape("Esc-Encerra | F4-Situacao Tributaria");
               valid SqlBusca("id = "+NumberToSql(nId),"descricao",@oQuery,;
               "administrativo.sittrib",,,,{"Situa‡Æo tribut ria j  cadastrada"},.t.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      @ 12,20 get cDescricao picture "@k";
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
      cQuery := "INSERT INTO administrativo.sittrib (id,descricao) "
      cQuery += "VALUES ("+NumberToSql(nId)+","+StringToSql(cDescricao)+")"
      Msg(.t.)
      Msg("Aguarde: Gravando as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar "},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      if !Grava_LogSql("Cadastros|Fiscal|Situacao tributaria|incluir|Codigo : "+str(nId,3))
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
   end
   RestWindow(cTela)
return
// ****************************************************************************
procedure AltSitTrib
   local gelist := {},cTela := SaveWindow()
   local nId,cDescricao,cQuery,oQuery

   DesativaF9()
   AtivaF4()
   TelSitTrib(2)
   while .t.
      nId := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,20 get nId  picture "@k 999";
               when Rodape("Esc-Encerra | F4-Situacao Tributaria");
               valid SqlBusca("id = "+NumberToSql(nId),"descricao",@oQuery,;
               "administrativo.sittrib",,,,{"Situa‡Æo tribut ria nÆo cadastrada"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      cDescricao := oQuery:FieldGet('descricao')
      @ 12,20 get cDescricao picture "@k";
                  when Rodape("Esc-Encerra")
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      end
      if !Confirm("Confirma a Alteracao")
         loop
      end
      cQuery := "UPDATE administrativo.sittrib SET descricao = "+StringToSql(cDescricao)+ "WHERE id = "+NumberToSql(nId)
      Msg(.t.)
      Msg("Aguarde: Alterando as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar "},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      if !Grava_LogSql("Cadastros|Fiscal|Situacao tributaria|Alterar|Codigo : "+cCodFis)
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
   end
   RestWindow(cTela)
return
// ****************************************************************************
procedure ExcSitTrib
   local gelist := {},cTela := SaveWindow()
   local cCodFis,cQuery,oQuery

   DesativaF9()
   AtivaF4()
   TelSitTrib(3)
   while .t.
      cCodFis := space(03)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,20 get cCodFis picture "@k 999";
               when Rodape("Esc-Encerra | F4-Situacao Tributaria");
               valid SqlBusca("codfis = "+StringToSql(cCodFis),"descricao",@oQuery,;
                  "administrativo.sittrib",,,,{"Situa‡Æo tribut ria nÆo cadastrada"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      @ 12,20 say oQuery:FieldGet('descricao')
      if !Confirm("Confirma a Exclusao",2)
         loop
      endif
      cQuery := "DELETE FROM administrativo.sittrib WHERE codfis = "+StringToSql(cCodFis)
      Msg(.t.)
      Msg("Aguarde: Excluindo as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar "},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      if !Grava_LogSql("Cadastros|Fiscal|Situacao tributaria|Excluir|Codigo : "+cCodFis)
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
   endif
   RestWindow(cTela)
return
// ****************************************************************************
procedure TelSitTrib( nModo)
   local aTitulos := {"Inclusao","Alteracao","Exclusao"}

   Window(09,07,14,81,"> " + aTitulos[ nModo ] + " de Situacao Tributaria <")
   setcolor(Cor(11))
   //           8901234567890123456789012345678901234567890123456789012345678
   //             2         3         4         5         6         7
   @ 11,09 say "   C¢digo:"
   @ 12,09 say "Descricao:"
   return

//** Fim do Arquivo.
