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

procedure ConFabricante(lAbrir,lIncluir)
   local acampo   := {"id","nome"}
	local atitulo  := { "C¢digo","Nome"}
	local amascara := { "999","@"}
	local nCursor := setcursor(),cCor := setcolor(),cQuery
	private oQuery
 
	cQuery := "SELECT id,nome FROM administrativo.fabricantes ORDER BY nome "
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
	ViewTableSql(oQuery,02,38,33,79,"> Fabricantes <",2,iif(!lAbrir,"id",NIL),aCampo,aTitulo,aMascara)
	setcursor(nCursor)
	setcolor(cCor)
return


// ****************************************************************************
procedure IncFabricante
   local getlist := {},cTela := SaveWindow()
   local nId,cNome,cQuery,oQuery
   
	if PwNivel == "0"
		DesativaF9()
	endif
	AtivaF4()
	TelFabricante(1)
	while .t.
      cNome := space(30)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      oQuery := oServer:Query("SELECT Last_value FROM administrativo.fabricantes_id_seq;")
      nId := oQuery:fieldget('last_value')
      @ 11,30 say nId picture "@k 999" 
      @ 12,30 get cNome picture "@k" when Rodape("Esc-Encerra")
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
      if !Confirm("Confirma a Inclusao")
         loop
      endif
      cQuery := "INSERT INTO administrativo.fabricantes (nome) VALUES ("+StringToSql(cNome)+")"
      Msg(.t.)
      Msg("Aguarde: Gravando as informa?„es")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      oServer:Commit()
      Msg(.f.)
   endd
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   end
   RestWindow(cTela)
return
// *****************************************************************************
procedure AltFabricante
   local getlist := {},cTela := SaveWindow()
   local nId,cNome,cQuery,oQuery

   if PwNivel == "0"
      DesativaF9()
   endif
   AtivaF4()
   TelFabricante(2)
   while .t.
      nId := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,30 get nId picture "@k 999";
      			when Rodape("Esc-Encerra | F4-Fabricantes");
               valid SqlBusca("id = "+NumberToSql(nId),"nome",@oQuery,;
               "administrativo.fabricantes",,,,{"Fabricante nÆo cadastrado"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      cNome := oQuery:fieldget('Nome')
      @ 12,30 get cNome picture "@k" when Rodape("Esc-Encerra")
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      endif
      if !Confirm("Confirma a Alteracao")
         loop
      endif
      cQuery := "UPDATE administrativo.fabricantes SET nome ="+StringToSql(cNome)+" WHERE id ="+NumberToSql(nId)
      Msg(.t.)
      Msg("Aguarde: Gravando as informa?„es")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar "},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      oServer:Commit()
      oQuery:Close()
      MSg(.f.)
   endd
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   endif
   RestWindow(cTela)
return
// *****************************************************************************
procedure ExcFabricante
   local getlist := {},cTela := SaveWindow()
   local nId,cQuery,oQuery

   if PwNivel == "0"
      DesativaF9()
   end
   AtivaF4()
   TelFabricante(3)
   do while .t.
      nId := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,30 get nId picture "@k 999";
                when Rodape("Esc-Encerra | F4-Fabricantes");
                valid SqlBusca("id = "+NumberToSql(nId),"nome",@oQuery,;
                "administrativo.fabricantes",,,,{"Fabricante nÆo cadastrado"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      @ 12,30 say oQuery:fieldget('Nome') picture "@k!"
      if !Confirm("Confirma a Exclusao",2)
         loop
      end
      cQuery := "DELETE FROM administrativo.fabricantes WHERE id ="+NumberToSql(nId)
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
procedure TelFabricante(nModo)
   local aTitulos := {"InclusÆo","Altera‡Æo","ExclusÆo"}

   Window(09,19,14,61,"> "+aTitulos[nModo]+" de Fabricantes <")
   setcolor(Cor(11))
   @ 11,20 say "  Codigo:"
   @ 12,20 say "    Nome:"
return

//** Fim do Arquivo.
