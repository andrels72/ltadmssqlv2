/*************************************************************************
 * Sistema......: Controle para Ceramica
 * Versao.......: 2.00
 * Identificacao: Manutencao de Vendedores
 * Prefixo......: LtSCC
 * Programa.....: Vendedor.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 18 de Agosto de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConVendedor(lAbrir)
	local acampo   := {"id","nome"}
	local atitulo  := { "Codigo","Nome"}
	local amascara := { "99","@"}
	local nCursor := setcursor(),cCor := setcolor(),cQuery
	private oQuery
 
	cQuery := "SELECT id,nome FROM administrativo.vendedores ORDER BY nome "
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
	ViewTableSql(oQuery,02,38,33,79,"> Vendedores <",2,iif(!lAbrir,"id",NIL),aCampo,aTitulo,aMascara)
	setcursor(nCursor)
	setcolor(cCor)
return


// *****************************************************************************
procedure IncVendedor
   local getlist := {},cTela := SaveWindow()
	private nId,cNome,nCV_Ven,nCP_Ven,cQuery,oQuery

   DesativaF9()
   AtivaF4()
   TelVendedor(1)
   while .t.
      cNome   := space(20)
      nCV_Ven := 0
      nCP_Ven := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      oQuery := oServer:Query("SELECT Last_value FROM administrativo.vendedores_id_seq;")
      nId := oQuery:fieldget('last_value')
      @ 10,37 say nId picture "99" 
		if !GetVendedor()
         exit
		endif
      if !Confirm("Confirma a InclusÆo")
         loop
      endif
      Msg(.t.)
      Msg("Aguarde: Gravando as informa‡äes")
      oServer:StartTransaction()
      GravarVendedor(.t.)
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      if !Grava_LogSql("Cadastros|Vendedores|Incluir|Codigo: "+str(nId))
         oQuery:Close()
         oServer:Rollback()
         Msg(.f.)
         loop
      endif
      oServer:Commit()
      Msg(.f.)
   enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   endif
   RestWindow(cTela)
return
// *****************************************************************************
procedure AltVendedor
   local getlist := {},cTela := SaveWindow()
	private nId,cNome,nCp_Ven,nCv_Ven,cQuery,oQuery

   DesativaF9()
   AtivaF4()
   TelVendedor(2)
   while .t.
      nId := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,37 get nId picture "@k 99";
               when Rodape("Esc-Encerra | F4-Vendedores");
               valid SqlBusca("id = "+NumberToSql(nId),"nome,cp_ven,cv_ven",@oQuery,;
               "administrativo.vendedores",,,,{"Vendedor nÆo cadastrado"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      cNome   := oQuery:fieldget('Nome')
      nCp_Ven := oQuery:fieldget('Cp_Ven')
      nCv_Ven := oQuery:fieldget('Cv_Ven')
		if !GetVendedor()
			loop
		endif
		if !Confirm("Confirma a Altera‡Æo")
         loop
      endif
      Msg(.t.)
      Msg("Aguarde: Gravando as informa‡äes")
      oServer:StartTransaction()
      GravarVendedor(.f.)
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      if !Grava_LogSql("Cadastros|Vendedores|Alterar|Codigo: "+str(nId))
         oQuery:Close()
         oServer:Rollback()
         Msg(.f.)
         loop
      endif
      oServer:Commit()
      Msg(.f.)
      Mens({"Altera‡Æo realizada com sucesso"})
	enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   end
   RestWindow(cTela)
return
// *****************************************************************************
procedure ExcVendedor
   local getlist := {},cTela := SaveWindow()
   local nId,cQuery,oQuery

   DesativaF9()
   AtivaF4()
   TelVendedor(3)
   do while .t.
      nId := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,37 get nId picture "@k 99";
               when Rodape("Esc-Encerra | F4-Vendedores");
               valid SqlBusca("id = "+NumberToSql(nId),"nome,cp_ven,cv_ven",@oQuery,;
               "administrativo.vendedores",,,,{"Vendedor nÆo cadastrado"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      @ 11,37 say oQuery:fieldget('Nome')
      @ 12,37 say oQuery:fieldget('Cv_Ven') picture "@e 99.99"
      @ 13,37 say oQuery:fieldget('Cp_Ven') picture "@e 99.99"
      if !Confirm("Confirma a ExclusÆo",2)
         loop
      end
      cQuery :=  "DELETE FROM administrativo.vendedores WHERE id ="+NumberToSql(nId)
      Msg(.t.)
      Msg("Aguarde: Excluindo as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      if !Grava_LogSql("Cadastros|Vendedores|Excluir|Codigo: "+str(nId))
         oQuery:Close()
         oServer:Rollback()
         Msg(.f.)
         loop
      endif
      oServer:Commit()
      Msg(.f.)
      Mens({"ExclusÆo realizada com sucesso"})
   enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   end
   RestWindow(cTela)
return
   
static function GetVendedor
	local getlist := {}

	@ 11,37 get cNome picture "@k!" when Rodape("Esc-Encerra") valid NoEmpty(cNome)
	@ 12,37 get nCV_Ven picture "@k 99.99"
	@ 13,37 get nCP_Ven picture "@k 99.99"
	setcursor(SC_NORMAL)
	read
	setcursor(SC_NONE)
	if lastkey() == K_ESC
		return(.f.)
	endif
	return(.t.)
	
static procedure GravarVendedor(lIncluir)

	if lIncluir
      cQuery := "INSERT INTO administrativo.vendedores (nome,cv_ven,cp_ven) "
      cQuery += "VALUES ("+StringToSql(cNome)+","+NumberToSql(nCP_Ven,5,2)+","+NumberToSql(nCP_Ven,5,2)+")"
   else
      cQuery := "UPDATE administrativo.vendedores SET nome ="+StringToSql(cNome)+", cv_ven ="+NumberToSql(nCV_Ven,5,2)+","
      cQuery += " cp_ven = "+NumberToSql(nCP_Ven,2)+" WHERE id ="+NumberToSql(nId)
	endif
return

// *****************************************************************************
procedure TelVendedor( nModo )
   local cTitulo, aTitulos := { "InclusÆo" , "Altera‡Æo" , "ExclusÆo" }

   Window(08,21,15,58,"> "+aTitulos[nModo]+" de Vendedores <")
   setcolor(Cor(11))
   //           345678901234567890
   //                  3         4
   @ 10,23 say "      C¢digo:"
   @ 11,23 say "        Nome:"
   @ 12,23 say "Com. a Vista:      %"
   @ 13,23 say "Com. a Prazo:      %"
return

// ** Fim do Arquivo.
