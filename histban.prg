/*************************************************************************
 * Sistema......:
 * Identificacao: Manutencao de Historicos Bancario
 * Prefixo......:
 * Programa.....: HistCxa.prg
 * Autor........: Andre Lucas Souza
 * Data.........: 21 de Outubro de 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConHistBan(lAbrir)
   local getlist := {},oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados
   local nCursor := setcursor(),cCor := setcolor()
   local nLin1 := 02,nCol1 := 35,nLin2 := 30,nCol2 := 79
   local cQuery,oQuery
   local cPesquisar
   private nRecno

   cQuery := "SELECT id FROM financeiro.historicobanco LIMIT 1 "
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
  Window(nLin1,nCol1,nLin2,nCol2,"> Tabela de Hist¢rico Banc rio <")
  setcolor(Cor(11))
   @ nLin1+1,nCol1+1 say "Descri‡Æo: "
   cPesquisar := space(30)
   setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
   @ nLin1+1,nCol1+12 get cPesquisar picture "@k!"
   @ nLin1+2,nCol1+1 say replicate(chr(196),43)
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
   cQuery := "SELECT id,descricao,tipo FROM financeiro.historicobanco "
   if !empty(cPesquisar)
       cQuery += " WHERE descricao LIKE '"+rtrim(cPesquisar)+"%'"
   endif
   cQuery += " ORDER BY descricao"
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
  
  oBrow:addcolumn(TBColumnNew("C¢digo" ,{|| str(oQuery:FieldGet('id'),03) }))
  oBrow:addcolumn(TBColumnNew("Descri‡Æo" ,{|| oQuery:FieldGet('descricao')}))
  oBrow:addcolumn(TBColumnNew("Tipo" ,{|| oQuery:FieldGet('descricao')}))
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
               cDados := str(oQuery:FieldGet('id'),3)
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
procedure IncHistBan
   local getlist := {},cTela := SaveWindow()
   local nId,cDescricao,cTipo,cQuery,oQuery

   AtivaF4()
   TelHistBan(1)
   do while .t.
      nId := 0
      cDescricao := space(20)
      cTipo := space(01)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      oQuery := oServer:Query("SELECT Last_value FROM financeiro.historicobanco_id_seq;")
      nId := oQuery:fieldget('last_value')
      @ 10,35 say nId picture "999" 
      @ 11,35 get cDescricao picture "@k!";
            when Rodape("Esc-Encerra")
      @ 12,35 get cTipo picture "@k!";
            valid MenuArray(@cTipo,{{"C","Credito"},{"D","Debito "}},12,35,12,35)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      if !Confirm("Confirma a InclusÆo")
         loop
      endif
      cQuery := "INSERT INTO financeiro.historicobanco (descricao,tipo) "
      cQuery += "VALUES ("+StringToSql(cDescricao)+","+StringToSql(cTipo)+")"
      Msg(.t.)
      Msg("Aguarde: Gravando as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      oServer:Commit()
      Msg(.f.)
   enddo 
   DesativaF4()
   RestWindow(cTela)
return
// ****************************************************************************
procedure AltHistBan
   local getlist := {},cTela := SaveWindow()
   local nId,cDescricao,cTipo,cQuery,oQuery

   AtivaF4()
   TelHistBan(2)
   do while .t.
      nId := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,35 get nId picture "@k 999";
               when Rodape("Esc-Encerra | F4-Historicos Bancario");
               valid SqlBusca("id = "+NumberToSql(nId),"descricao,tipo",@oQuery,;
               "financeiro.historicobanco",,,,{"Hist¢rico nÆo cadastrado"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      cDescricao := oQuery:fieldget('descricao')
      cTipo := oQuery:fieldget('tipo')
      @ 11,35 get cDescricao picture "@k!";
                  when Rodape("Esc-Encerra")
      @ 12,35 get cTipo picture "@k!";
                  valid MenuArray(@cTipo,{{"C","Credito"},{"D","Debito "}},12,35,12,35)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma a Altera‡Æo")
         loop
      end
      cQuery := "UPDATE financeiro.historicobanco "
      cQuery += "SET descricao ="+StringToSql(cDescricao)+", tipo = "+StringToSql(cTipo)
      cQuery += " WHERE id = "+NumberToSql(nId)
      Msg(.t.)
      Msg("Aguarde: Aterando as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      oServer:Commit()
      Msg(.f.)
      Mens({"Altera‡Æo efetuada com sucesso"})
   enddo
   DesativaF4()
   RestWindow(cTela)
return
// ****************************************************************************
procedure ExcHistBan
   local getlist := {},cTela := SaveWindow()
   local nId,cQuery,oQuery

   AtivaF4()
   TelHistBan(3)
   do while .t.
      nId := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,35 get nId picture "@k 999";
            when Rodape("Esc-Encerra | F4-Historicos Bancario");
            valid SqlBusca("id = "+NumberToSql(nId),"descricao,tipo",@oQuery,;
            "financeiro.historicobanco",,,,{"Hist¢rico nÆo cadastrado"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      @ 11,35 say oQuery:fieldget('descricao') 
      @ 12,35 say oQuery:fieldget('tipo')
      if !Confirm("Confirma a ExclusÆo",2)
         loop
      endif
      cQuery := "DELETE FROM financeiro.historicobanco WHERE id = "+NumberToSql(nId)
      Msg(.t.)
      Msg("Aguarde: Excluindo as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      oServer:Commit()
      Msg(.f.)
      Mens({"Exclus]ao efetuada com sucesso"})
   enddo
   DesativaF4()
   RestWindow(cTela)
return
// ****************************************************************************
procedure TelHistBan( nModo )
   local cTitulo, aTitulos := { "InclusÆo" , "Altera‡Æo" , "ExclusÆo" }

   Window(08,21,14,56,"> "+aTitulos[nModo]+" de Hist. Bancario <")
   setcolor(Cor(11))
   //           45678901234567890
   //                 1         2
   @ 10,24 say "   C¢digo:"
   @ 11,24 say "Descricao:"
   @ 12,24 say "     Tipo:"
return

// ** Fim do Arquivo
