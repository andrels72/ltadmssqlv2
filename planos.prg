/*************************************************************************
 * Sistema......: Ordem de Servico
 * Versao.......: 2.00
 * Identificacao: Manutencao de Planos de Pagamento
 * Prefixo......: LtServi
 * Programa.....: Planos.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 25 de Agosto de 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConPlano(lAbrir)
   local oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados
   local nCursor := setcursor(),cCor := setcolor(),nLin1 := 02,nCol1 := 02
    local nLin2 := 30,nCol2 := 95,cQuery,oQuery
   private nRecno

    setcursor(SC_NONE)
    cQuery := "SELECT IdPlano,DesPla,NumPar,PraPar,FatAtu,TipoPe,PerEnt "
    cQuery += "FROM financeiro.plano "
    cQuery += "ORDER BY despla"
    Msg(.t.)
    Msg("Aguarde: pesquisando as informa‡äes")
    if !ExecuteSql(cQuery,@oQuery,{"Falha: Acessar (planos)"},"planos")
        oQuery:Close()
        Msg(.f.)
        return
    endif
    Msg(.f.)
    if oQuery:lastrec() = 0
        Mens({"Tabela vazia"})
        return
    endif
    if lAbrir
        Rodape("Esc-Encerrar")
    else
        Rodape("Esc-Encerra | ENTER-Transfere")
    endif
    setcolor(cor(5))
    Window(nLin1,nCol1,nLin2,nCol2,"> Consulta de Planos de pagamento <")
    oBrow := TBrowseDB(nLin1+1,nCol1+1,nLin2-1,nCol2-1)
    oBrow:headSep := SEPH
    oBrow:colSep  := SEPV
    oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)    
    oCurRow := oQuery:GetRow( 1 )
    oBrow:SkipBlock := {| n | oCurRow := SkipperQuery( @n, oQuery ), n }
    oBrow:GoBottomBlock := {|| oCurRow := oQuery:GetRow( oQuery:LastRec() ), 1 }
    oBrow:GoTopBlock := {|| oCurRow := oQuery:GetRow( 1 ), 1 }
   oBrow:addcolumn(tbcolumnnew("Codigo",{|| strzero(oQuery:FieldGet('idplano'),2)}))
   oBrow:addcolumn(tbcolumnnew("Descri‡Æo",{|| oQuery:FieldGet('despla')}))
   oBrow:addcolumn(tbcolumnnew("Numero de;Parcelas",{|| str(oQuery:FieldGet('numpar'),02) }))
   oBrow:addcolumn(tbcolumnnew("Prazo entre;Parcelas",{|| str(oQuery:FieldGet('prapar'),02)  }))
   oBrow:addcolumn(tbcolumnnew("Fator;Atualizador",{|| oQuery:FieldGet('fatatu')}))
   oBrow:addcolumn(tbcolumnnew("Tipo de;Opera‡Æo",{|| oQuery:FieldGet('tipope')}))
   oBrow:addcolumn(tbcolumnnew("Permite ;Emtrada",{|| oQuery:FieldGet('perent')}))
   while (! lFim)
      ForceStable(oBrow)
      if ( obrow:hittop .or. obrow:hitbottom )
         tone(1200,1)
      endif
      cTecla := chr((nTecla := inkey(0)))
      if !OnKey( nTecla,oBrow)
      endif
      if nTecla == K_ENTER
         if !lAbrir
            cDados := str(oQuery:FieldGet('idplano'),02)
            keyboard (cDados)+chr(K_ENTER)
            lFim := .t.
         endif
      elseif nTecla == K_ESC
         lFim := .t.
      endif
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
procedure IncPlano
    local getlist := {},cTela := SaveWindow()
    
    local cQuery,oQuery
    private nCodPla,cDesPla,nNumPar,nTotPar,nPraPar,nFatAtu,cTipOpe,cPerEnt    

   AtivaF4()
   TelPlano(1)
   while .t.
      nCodPla := 0
      cDesPla := space(30)
      nNumPar := 0
      nTotPar := 0
      nPraPar := 0
      nFatAtu := 0
      cTipOpe := space(01)
      cPerEnt := space(01)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      scroll(10,32,11,62,0)
      @ 12,32 say space(02)
      scroll(13,32,15,62,0)
        oQuery  := oServer:Query("SELECT last_value FROM financeiro.plano_idplano_seq")
        nCodPla := strzero(oQuery:FieldGet("last_value"),02)
        @ 09,32 say nCodPLa picture "99"
        if !GetPlano()
            exit
        endif
        if !Confirm("Confirma a Inclusao")
            loop
        endif
        cQuery := "INSERT INTO financeiro.plano"
        cQuery += " (DesPla,NumPar,PraPar,FatAtu,TipOpe,PerEnt)"
        cQuery += " values ("
        cQuery += StringToSql(cDesPla)+","
        cQuery += NumberToSql(nNumPar,02,0)+","
        cQuery += NumberToSql(nPraPar,02,0)+","
        cQuery += NumberToSql(nFatAtu,11,4)+","
        cQuery += StringToSql(cTipOpe)+","
        cQuery += StringToSql(cPerEnt)
        cQuery += ")"
        Msg(.t.)
        Msg("Aguarde: Incluindo informa‡äes")
        oServer:StartTransaction()
        if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (Plano)"},"sqlerro")
            oQuery:close()
            oServer:Rollback()
            Msg(.f.)        
			loop        
		endif
        if !Grava_LogSql("Cadastrados|Financeiro|Planos de Pagamento|Incluir|Codigo "+nCodPla)
            oServer:Rollback()
            Msg(.f.)        
			loop        
		endif
        oServer:Commit()
        oQuery:Close()
        Msg(.f.)
    enddo
   RestWindow(cTela)
   return
// ****************************************************************************
procedure AltPlano
    local getlist := {},cTela := SaveWindow()
    local cQuery,oQuery
    private nCodPla,cDesPla,nNumPar,nTotPar,nPraPar,nFatAtu,cTipOpe,cPerEnt   

   AtivaF4()
   TelPlano(2)
   while .t.
      nCodPla := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      scroll(10,32,11,62,0)
      @ 12,32 say space(02)
      scroll(13,32,15,62,0)
        @ 09,32 get nCodPla picture "@k 99";
            when Rodape("Esc-Encerra | F4-Planos de Pagamento");
            valid SqlBusca("idplano = "+NumberToSql(nCodPla),;
                "DesPla,NumPar,PraPar,FatAtu,TipOpe,PerEnt",@oQuery,;
                "financeiro.plano",,,,{"Plano nÆo cadastrado"},.f.)            
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
        cDesPla := oQuery:FieldGet('DesPla')
        nNumPar := oQuery:FieldGet('NumPar')
        nPraPar := oQuery:FieldGet('PraPar')
        nFatAtu := oQuery:FieldGet('FatAtu')
        cTipOpe := oQuery:FieldGet('TipOpe')
        cPerEnt := oQuery:FieldGet('PerEnt')
        if !GetPlano()
            loop
        endif
        if !Confirm("Confirma a Alteracao")
            loop
        endif
        oQuery:Close()
        cQuery := "UPDATE financeiro.plano"
        cQuery += " set despla = "+StringToSql(cDesPla)+","
        cQuery += " numpar = "+NumberToSql(nNumpar,2,0)+","
        cQuery += " prapar = "+NumberToSql(nPrapar,2,0)+","
        cQuery += " fatatu = "+NumberToSql(nFatAtu,11,4)+","
        cQuery += " tipope = "+StringToSql(cTipOpe)+","
        cQuery += " perent = "+StringToSql(cPerEnt)
        cQuery += " where idplano = "+NumberToSql(nCodPla)
        Msg(.t.)
        Msg("Aguarde: Alterando informa‡äes")
        oServer:StartTransaction()
        if !ExecuteSql(cQuery,@oQuery,{"Erro: Altera (Plano)"},"sqlerro")
            oQuery:close()
            oServer:Rollback()
            Msg(.f.)        
			loop        
		endif
        if !Grava_LogSql("Cadastrados|Financeiro|Planos de Pagamento|Alterar|Codigo "+str(nCodPla))
            oServer:Rollback()
            Msg(.f.)        
			loop        
		endif
        oServer:Commit()
        oQuery:Close()
        Msg(.f.)
    enddo
    RestWindow(cTela)
    return
// ****************************************************************************
procedure ExcPlano
    local getlist := {},cTela := SaveWindow()
    local nCodPla,cQuery,oQuery

   AtivaF4()
   TelPlano(3)
   do while .t.
        nCodPla := 0
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        scroll(10,32,11,62,0)
        @ 12,32 say space(02)
        scroll(13,32,15,62,0)
        @ 09,32 get nCodPla picture "@k 99";
            when Rodape("Esc-Encerra | F4-Planos de Pagamento");
            valid SqlBusca("idplano = "+NumberToSql(nCodPla),;
                "DesPla,NumPar,PraPar,FatAtu,TipOpe,PerEnt",@oQuery,;
                "financeiro.plano",,,,{"Plano nÆo cadastrado"},.f.)            
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        @ 10,32 say oQuery:fieldget('DesPla')
        @ 11,32 say oQuery:fieldget('NumPar') picture "@k 99"
        @ 12,32 say oQuery:fieldget('PraPar') picture "@k 99"
        @ 13,32 say oQuery:fieldget('FatAtu') picture "999999.9999"
        @ 14,32 say oQuery:fieldget('TipOpe') picture "@k!"
        @ 15,32 say oQuery:fieldget('PerEnt') picture "@k!"
        // pesquisa os pedidos
        if !SqlBusca("idplano = "+NumberToSql(nCodPla),;
                "idplano",@oQuery,"financeiro.pedidos",,,,;
                {"Existe pedido(s) com esse plano","ExclusÆo nÆo permitida"},.t.,1,"Aguarde: pesquisando pedido(s)")
            loop
        endif
        if !Confirm("Confirma a Exclusao",2)
            loop
        endif
        cQuery := "DELETE FROM financeiro.plano "
        cQuery += " where idplano = "+NumberToSql(nCodPla)
        Msg(.t.)
        Msg("Aguarde: Excluindo o plano")
        oServer:StartTransaction()
        if !ExecuteSql(cQuery,@oQuery,{"Erro: Excluir (Plano)"},"sqlerro")
            oQuery:close()        
            oServer:Rollback()
            Msg(.f.)
			loop        
		endif
        if !Grava_LogSql("Cadastrados|Planos de Pagamento|Excluir|Codigo "+str(nCodPla))
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        oServer:Commit()
        oQuery:close()
        Msg(.f.)
   enddo
   RestWindow(cTela)
   return
// ****************************************************************************
procedure TelPlano( nModo )
   local cTitulo, aTitulos := { "InclusÆo" , "Altera‡Æo" , "ExclusÆo" }

   Window(07,08,17,63,"> "+aTitulos[nModo]+" de Planos de Pagamento <")
   setcolor(Cor(11))
   //           012345678901234567890123456789012345678901234567890123
   //           1         2         3         4         5         6
   @ 09,10 say "              C¢digo:"
   @ 10,10 say "           Descri‡„o:"
   @ 11,10 say "  N£mero de parcelas:"
   @ 12,10 say "Prazo entre parcelas:    dia(s)"
   @ 13,10 say "   Fator atualizador:"
   @ 14,10 say "    Tipo de opera‡„o:"
   @ 15,10 say "     Permite entrada:"
   return

static function GetPlano
   
    @ 10,32 get cDesPla picture "@k!" when Rodape("Esc-Encerra")
    @ 11,32 get nNumPar picture "@k 99" valid nNumPar > 0
    @ 12,32 get nPraPar picture "@k 99"
    @ 13,32 get nFatAtu picture "999999.9999"
    @ 14,32 get cTipOpe picture "@k!" valid MenuArray(@cTipOpe,{{"1","A Vista"},{"2","A Prazo"}},14,32,14,34)
    @ 15,32 get cPerEnt picture "@k!" when cTipOpe == "2" valid MenuArray(@cPerEnt,{{"S","Sim"},{"N","Nao"}},15,32,15,34)
    setcursor(SC_NORMAL)
    read
    setcursor(SC_NONE)
    if lastkey() == K_ESC
        return(.f.)
    endif
    return(.t.)
   
   

//** Fim do Arquivo.
