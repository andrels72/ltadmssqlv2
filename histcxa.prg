/*************************************************************************
 * Sistema......: Administrativo
 * Identificacao: Manutencao de Historicos Padrao
 * Prefixo......: Ltadm
 * Programa.....: HistCxa.prg
 * Autor........: Andre Lucas Souza
 * Data.........: 28 DE DEZEMBRO DE 2002
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "LUCAS.CH"       // Inclusao do Arquivo Header Padrao
#include "INKEY.CH"   // Header para manipulacao de Teclas
#include "setcurs.ch"

procedure ConHistCxa(lAbrir)
   local getlist := {},oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados
   local nCursor := setcursor(),cCor := setcolor(),nLin1 := 02,nCol1 := 10,nLin2 := 30,nCol2 := 70
   local cQuery,oQuery,cPesquisar

    if !ExecuteSql("SELECT id FROM financeiro.historicocaixa LIMIT 1",@oQuery,{"Falha: pesquisar historico"},"sqlerro")
        oQuery:Close()
        return
    endif
    if oQuery:lastrec() = 0
        Mens({"Tabela vazia"})
        return
    endif
   Window(nLin1,nCol1,nLin2,nCol2,"> Tabela de Historicos <")
   setcolor(Cor(11))
    @ nLin1+1,nCol1+1 say "Hist¢rico: "
    cPesquisar := space(30)
    setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
    @ nLin1+1,nCol1+12 get cPesquisar picture "@k!"
    @ nLin1+2,nCol1+1 say replicate(chr(196),59)
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
    cQuery := "SELECT id,descricao,tipo FROM financeiro.historicocaixa "
    // se tive pesquisa
    if !empty(cPesquisar)
        cQuery += " WHERE descricao LIKE '"+rtrim(cPesquisar)+"%'"
    endif
    cQuery += " ORDER BY descricao "
    Msg(.t.)
    Msg("Aguarde: pesquisando infoma‡äes")
    if !ExecuteSql(cQuery,@oQuery,{"Falha: pesquisar historico"},"sqlerro")
        oQuery:Close()
        Msg(.f.)
        RestWindow(cTela)
        return
    endif
    Msg(.f.)
    if oQuery:lastrec() = 0
        Mens({"Tabela de hist¢ico vazia"})
        oQuery:close()
        RestWindow(cTela)
        return
    endif
   if !lAbrir
      setcursor(SC_NONE)
   endif
   if lAbrir
      Rodape("Esc-Encerrar")
   else
      Rodape("Esc-Encerra | ENTER-Transfere")
   end
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
   oBrow:addcolumn(TBColumnNew("C¢digo" ,{|| str(oQuery:fieldget('id'),3) }))
   oBrow:addcolumn(TBColumnNew("Histrico" ,{|| oQuery:fieldget('descricao') }))
   oBrow:addcolumn(TBColumnNew("Tipo" ,{|| oQuery:fieldget('tipo') }))
   setcolor(Cor(26))
   do WHILE (! lFim)
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
                cDados := str(oQuery:fieldget('id'),3)
                keyboard (cDados)+chr(K_ENTER)
                lFim := .t.
            endif
        elseif nTecla == K_ESC
            lFim := .t.
        endif
        oBrow:refreshcurrent()
   end
   if !lAbrir
      setcursor(nCursor)
      setcolor(cCor)
   endif
   RestWindow( cTela )
RETURN
// ****************************************************************************
procedure IncHistCxa
	local getlist := {},cTela := SaveWindow()
	private nId,cDescricao,cTipo,cQuery,oQuery

   if PwNivel == "0"
      DesativaF9()
   endif
   AtivaF4()
   TelHistCxa(1)
   while .t.
      nId := 0
      cDescricao := space(30)
      cTipo := space(01)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      oQuery := oServer:Query("SELECT Last_value FROM financeiro.historicocaixa_id_seq;")
      nId := oQuery:fieldget('last_value')
      @ 11,31 say nId picture "999" 
      @ 12,31 get cDescricao picture "@k!";
                  when Rodape("Esc-Encerra")
      @ 13,31 get cTipo picture "@k!";
                  valid MenuArray(@cTipo,{{"R","Receita"},{"D","Despesa"}},13,31,13,31)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
		if !Confirm("Confirma a InclusÆo")
			loop
		endif
      Msg(.t.)
      Msg("Aguarde: Gravando as informa‡äes")
      oServer:StartTransaction()
      GravarHistCxa(.t.)
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      if !Grava_LogSql("Cadastros|Financeiro|Caixa|Historico padrao|Incluir "+str(nId))
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
   end
   RestWindow(cTela)
return
// ****************************************************************************
procedure AltHistCxa
   local getlist := {},cTela := SaveWindow()
	private nId,cDescricao,cTipo,cQuery,oQuery

   AtivaF4()
   TelHistCxa(2)
   do while .t.
      nId := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,31 get nId picture "@k 999";
               when Rodape("Esc-Encerra | F4-Historicos");
               valid SqlBusca("id = "+NumberToSql(nId),"descricao,tipo",@oQuery,;
               "financeiro.historicocaixa",,,,{"Hist¢rico nÆo cadastrado"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      cDescricao := oQuery:fieldget('descricao')
      cTipo := oQuery:fieldget('tipo')
      @ 12,31 get cDescricao picture "@k!";
                  when Rodape("Esc-Encerra")
      @ 13,31 get cTipo picture "@k!";
                  valid MenuArray(@cTipo,{{"R","Receita"},{"D","Despesa"}},13,31,13,31)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      end
      if !Confirm("Confirma a Altera‡Æo")
         loop
      endif
      Msg(.t.)
      Msg("Aguarde: Alterando as informa‡äes")
      oServer:StartTransaction()
      GravarHistCxa(.f.)
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      if !Grava_LogSql("Cadastros|Financeiro|Caixa|Historico padrao|Alterar|Codigo: "+str(nId))
         oQuery:Close()
         oServer:Rollback()
         Msg(.f.)
         loop
      endif
      oServer:Commit()
      Msg(.f.)
      Mens({"Altera‡Æo realizada com sucesso"})
//		Grava_Log(cDiretorio,"Historico|Alterar|Codigo "+cCodHist,Historico->(recno()))
	enddo
   DesativaF4()
   RestWindow(cTela)
return
// ****************************************************************************
procedure ExcHistCxa
   local getlist := {},cTela := SaveWindow()
   local nId,cQuery,oQuery

   AtivaF4()
   TelHistCxa(3)
   do while .t.
      nId := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,31 get nId picture "@k 999";
               when Rodape("Esc-Encerra | F4-Historicos");
               valid SqlBusca("id = "+NumberToSql(nId),"descricao,tipo",@oQuery,;
               "financeiro.historicocaixa",,,,{"Hist¢rico nÆo cadastrado"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      @ 12,31 say oQuery:fieldget('descricao')
      @ 13,31 say oQuery:fieldget('tipo')
      if !Confirm("Confirma a ExclusÆo",2)
         loop
      end
      cQuery := "DELETE FROM financeiro.historicocaixa WHERE id ="+NumberToSql(nId)
      Msg(.t.)
      Msg("Aguarde: Excluindo as informa‡äes")
      oServer:StartTransaction()
      GravarHistCxa(.f.)
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      if !Grava_LogSql("Cadastros|Financeiro|Caixa|Historico padrao|Excluir|Codigo: "+str(nId))
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
   RestWindow(cTela)
return
// ****************************************************************************
procedure TelHistCxa( nModo )
   local cTitulo, aTitulos := { "InclusÆo" , "Altera‡Æo" , "ExclusÆo" }

   Window(09,18,15,63,"> "+aTitulos[nModo]+" de Historico Padrao <")
   setcolor(Cor(11))
   //           901234567890123456789
   //            2         3
   @ 11,19 say "    C¢digo:"
   @ 12,19 say " Descricao:"
   @ 13,19 say "      Tipo:"
   return
   
static procedure GravarHistCxa(lIncluir)

	if lIncluir
      cQuery := "INSERT INTO financeiro.historicocaixa (descricao,tipo) "
      cQuery += "VALUES ("+StringToSql(cDescricao)+","+StringToSql(cTipo)+")"
	else
      cQuery := "UPDATE financeiro.historicocaixa "
      cQuery += "SET descricao ="+StringToSql(cDescricao)+", tipo = "+StringToSql(cTipo)+" WHERE id ="+NumberToSql(nId)
	endif
return



//** Fim do Arquivo
