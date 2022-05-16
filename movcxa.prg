/*************************************************************************
 * Sistema......: Controle Administrativo
 * Identificacao: Manutencao de Movimento de Caixa
 * Prefixo......: Ltadm
 * Programa.....: MOVCAIXA.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 28 DE DEZEMBRO DE 2002
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConMovCxa(lAbrir)
   local oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados,cTela2
   local nCursor := setcursor(),cCor := setcolor(),nCodCaixa
   local oQuery,cQuery,dDataI,dDataF,nCodHisto,nLin1,nCol1,nLin2,nCol2,oQCaixa
   local oQSaldo,nSaldoAnterior := 0,nSaldo := 0
   

    setcursor(SC_NONE)
   if lAbrir
      AtivaF4()
   endif
   Window(02,00,30,100,"> Consulta do Movimento de Caixa <")
   setcolor(Cor(11))
   //           1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
   //                    1         2         3         4         5         6         7         8         9         0
   @ 03,01 say "  Caixa:                             Historico:"                         
   @ 04,01 say "Per≠odo:            a             Saldo anterior:                            Saldo : " 
   @ 05,01 say replicate(chr(196),99)
   nIdCaixa := 0
   dDataI := date()
   dDataF := ctod(space(08))
   nIdHistorico := 0
   setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
    @ 03,10 get nIdCaixa picture "@k 99";
            when Rodape("Esc-Encerra | F4-Caixas");
            valid iif(empty(nIdCaixa),.t.,SqlBusca("id = "+NumberToSql(nIdCaixa),;
                "descricao,saldo",@oQCaixa,"financeiro.caixa",row(),col()+1,;
                {"descricao",18},{"Caixa n∆o cadastrado"},.f.))
                
    @ 03,49 get nIdHistorico picture "@k 999";
            when Rodape("Esc-Encerra | F4-Historicos");
            valid iif(empty(nIdHistorico),.t.,SqlBusca("id = "+NumberToSql(nIdHistorico),;
                "descricao",@oQuery,"financeiro.historicocaixa",row(),col()+1,;
                {"descricao",18},{"Historico n∆o cadastrado"},.f.))
                
    @ 04,10 get dDataI picture "@k" when Rodape("Esc-Encerra | informe o per≠odo")
    @ 04,23 get dDataF picture "@k"
            //valid vDataF(dDataI,@dDataF)
            
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
    if lAbrir
        DesativaF4()
    endif
    
    // Calcula o saldo anterior se o caixa for informado
    // retornando a ultima data do saldo e o valor do saldo
    if !empty(nCodCaixa)
        cQuery := "SELECT" 
        cQuery += " max(movimento.data) AS data,"
        cQuery += " sum("
        cQuery += "(case when Movimento.tipo = '1' then 1"
        cQuery += "      when movimento.tipo = '2' then -1 end) * movimento.valor ) as Saldo " 
        cQuery += "FROM financeiro.movcaixa Movimento " 
        cQuery += "WHERE  Movimento.idcaixa = "+NumberToSql(nIdCaixa)
        cQuery += " AND movimento.data < "+DateToSql(dDataI)
        Msg(.t.)
        Msg("Aguarde: calculando saldo ")
        if !ExecuteSql(cQuery,@oQuery,{"Falha na consulta do movimento do caixa"},"sqlerro")
            oQuery:close()
            Msg(.f.)
            RestWindow(cTela)
            return
        endif
        Msg(.f.)
        nSaldoAnterior := oQuery:fieldget('Saldo')
        dDataSaldoAnterior := oQuery:fieldget('data')
        nSaldo := 0.00 // SaldoAtualCaixa(nCodCaixa,dDataF)
    else
        dDataSaldoAnterior := ctod(space(08))
    endif
    // Calcula o saldo quando o historico for informado e o caixa nío 
    if empty(nIdCaixa) .and. !empty(nIdHistorico)
        cQuery := "SELECT "  
        cQuery += "SUM("
        cQuery += "(CASE WHEN Movimento.tipo = '1' then 1"
        cQuery += "      WHEN movimento.tipo = '2' then -1 end) * movimento.valor ) as Saldo "
        cQuery += "FROM financeiro.movcaixa Movimento " 
        cQuery += "WHERE movimento.data >= "+DateToSql(dDataI)
        cQuery += " AND movimento.data <= "+DateToSql(dDataF)
        cQuery += " AND movimento.idhistorico = "+NumberToSql(nIdHistorico)
        Msg(.t.)
        Msg("Aguarde: calculando saldo ")
        if !ExecuteSql(cQuery,@oQSaldo,{"Falha na consulta do movimento do caixa"},"sqlerro")
            oQuery:close()
            Msg(.f.)
            RestWindow(cTela)
            return
        endif
        nSaldo := oQSaldo:fieldget('saldo')
        Msg(.f.)
    endif
    
    cQuery := "SELECT" 
    cQuery += " movcaixa.id,"
    cQuery += " movcaixa.data,"
    cQuery += " movcaixa.idcaixa,"
    cQuery += " movcaixa.idhistorico,"
    cQuery += " histcaixa.nomhist,"
    cQuery += " movcaixa.complemento1,"
    cQuery += " movcaixa.complemento2,"
    cQuery += " movcaixa.fechado,"
    cQuery += " movcaixa.valor,"
    cQuery += " movcaixa.idpagto,"
    cQuery += " movcaixa.tipo,"
    cQuery += " formapagtocaixa.descricao,"
    cQuery += " caixa.descricao AS des_caixa,"
    cQuery += " movcaixa.banco,"
    cQuery += "histbanco.id,"
    cQuery += "FROM " 
    cQuery += "  financeiro.movcaixa movcaixa "
    cQuery += "INNER JOIN financeiro.historicocaixa ON movcaixa.idhistorico = historicocaixa.id "
    cQuery += "INNER JOIN financeiro.formapagtocaixa ON movcaixa.idpagto = formapagtocaixa.id "
    cQuery += "INNER JOIN financeiro.caixa ON (movcaixa.idcaixa = caixa.id) "
    
    if !empty(nIdCaixa) .and. empty(dDataI) .and. empty(nIdHistorico)
        cQuery += "WHERE "
        cQuery += " movcaixa.idcaixa = "+NumberToSql(nIdCaixa)+" "
        
    elseif !empty(nIdCaixa) .and. !empty(dDataI) .and. empty(nIdHistorico)
        cQuery += " WHERE "
        cQuery += "  movcaixa.idcaixa = "+NumberToSql(nIdCaixa)
        cQuery += " AND movcaixa.data >= "+DateToSql(dDataI)
        cQuery += " AND movcaixa.data <= "+DateToSql(dDataF)
        
    elseif !empty(nIdCaixa) .and. !empty(dDataI) .and. !empty(nIdHistorico)        
        cQuery += "WHERE "
        cQuery += " movcaixa.idcaixa = "+NumberToSql(nIdCaixa)
        cQuery += " AND movcaixa.data >= "+DateToSql(dDataI)
        cQuery += " AND movcaixa.data <= "+DateToSql(dDataF)
        cQuery += " AND movcaixa.idhistorico = "+NumberToSql(nIdHistorico)+" "
        
    elseif !empty(nIdCaixa) .and. empty(dDataI) .and. !empty(nIdHistorico)
        cQuery += "WHERE movcaixa.idcaixa = "+NumberToSql(nIdCaixa)+" "
        
    
    elseif empty(nIdCaixa) .and. !empty(dDataI) .and. empty(nIdHistorico)
        cQuery += "WHERE movcaixa.data >= "+DateToSql(dDataI)
        cQuery += " AND movcaixa.data <= "+DateToSql(dDataF)
    
    elseif empty(nIdCaixa) .and. !empty(dDataI) .and. !empty(nIdHistorico)
        cQuery += "WHERE movcaixa.data >= "+DateToSql(dDataI)
        cQuery += " AND movcaixa.data <= "+DateToSql(dDataF)
        cQuery += " AND movcaixa.idhistorico = "+NumberToSql(nIdHistorico)+" "
        
    elseif empty(nIdCaixa) .and. empty(dDataI) .and. !empty(nIdHistorico)        
        cQuery += "WHERE movcaixa.idhistorico = "+NumberToSql(nIdHistorico)+" "
    endif
    cQuery += " ORDER BY movcaixa.id,movcaixa.data"
    
    Msg(.t.)
    Msg("Aguarde: Pesquisando as informa?Ñes")
    if !ExecuteSql(cQuery,@oQuery,{"Falha na consulta do movimento do caixa"},"sqlerro")
        oQuery:close()
        Msg(.f.)
        RestWindow(cTela)
        return
    endif
    Msg(.f.)
    if oQuery:Lastrec() = 0
        Mens({"Nío existe informa?ío"})
        RestWindow(cTela)
        return
    endif
    if empty(nCodCaixa) .and. empty(dDataI) .and. empty(dDataF) .and. empty(nCodHisto)
        oQuery:Goto(oQuery:lastrec())
    endif        
   
    // apresenta os saldos
    @ 04,51 say dDataSaldoAnterior
    @ 04,62 say nSaldoAnterior picture "@e 999,999,999.99"
    @ 04,86 say nSaldo picture "@e 999,999,999.99"   
    
   if lAbrir
      Rodape("Esc-Encerrar")
   else
      Rodape("Esc-Encerra | ENTER-Transfere")
   end
   setcolor(cor(5))
   nLin1 := 05
   nCol1 := 00
   nLin2 := 30
   nCol2 := 100
   oBrow := TBrowseDB(nLin1+1,nCol1+1,nLin2-5,nCol2-1)
   oBrow:headSep := SEPH
   oBrow:footSep := SEPB
   oBrow:colSep  := SEPV
   
    oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)
    oCurRow := oQuery:GetRow( 1 )
    oBrow:SkipBlock := {| n | oCurRow := SkipperQuery( @n, oQuery ), n }
    oBrow:GoBottomBlock := {|| oCurRow := oQuery:GetRow( oQuery:LastRec() ), 1 }
    oBrow:GoTopBlock := {|| oCurRow := oQuery:GetRow( 1 ), 1 }
   
   oBrow:addcolumn(TBColumnNew(" " ,{|| iif(oQuery:fieldget("Fechado") = "S","*"," ")  }))
   
   oColuna := tbcolumnnew("Lancamento",{|| transform(oQuery:fieldget('id'),"@e 999,999,999")})
   oColuna:colorblock := {|| iif(oQuery:fieldget('Tipo') == "2",{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   // *-------------------------------------------------------------------------
   oColuna := tbcolumnnew("Data",{|| oQuery:fieldget('Data') })
   oColuna:colorblock := {|| iif(oQuery:fieldget('Tipo') == "2",{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   
   // *-------------------------------------------------------------------------
   oColuna := tbcolumnnew("Caixa",{|| str(oQuery:fieldget('codcaixa'),02)})
   oColuna:colorblock := {|| iif(oQuery:fieldget('Tipo') == "2",{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   // *-------------------------------------------------------------------------
    oColuna := tbcolumnnew("Historico",{|| str(oQuery:fieldget('CodHisto'),03)+"-"+oQuery:fieldget('historico')})
   oColuna:colorblock := {|| iif(oQuery:fieldget('Tipo') == "2",{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   // *-------------------------------------------------------------------------
   oColuna := tbcolumnnew("Valor",{|| transform(oQuery:fieldget('Valor'),"@ke 99,999,999.99")})
   oColuna:colorblock := {|| iif(oQuery:fieldget('Tipo') == "2",{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   
   oColuna := tbcolumnnew("Tipo",{|| iif(oQuery:fieldget('tipo') = '1','C','D')})
   oColuna:colorblock := {|| iif(oQuery:fieldget('Tipo') == "2",{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   
   
    @ nLin2-4,nCol1+1 say " Complemento:" color Cor(11)
    @ nLin2-2,nCol1+1 say "Forma pagto.:                                    " color Cor(11)
   setcolor(Cor(26))
   scroll(nLin2-1,nCol1+1,nLin2-1,nCol2-1,0)
   /*
   if PwNivel == "0" .and. !empty(nCodCaixa)
      @ 04,49 say oQCaixa:fieldget('saldo') picture "@e 999,999,999.99"
   endif
   */
   Centro(nLin2-1,nCol1+1,nCol2-1,"F2-Visualizar ")
    do while (! lFim)
        do while ( ! oBrow:stabilize() )
            nTecla := INKEY()
            if ( nTecla != 0 )
                exit
            endif
        enddo
        @ nLin2-4,15 say oQuery:fieldget('Complemento1') color Cor(11)
        @ nLin2-3,15 say oQuery:fieldget('Complemento2') color Cor(11)
        @ nLin2-2,15 say str(oQuery:fieldget('CodPagto'),02)+"-"+oQuery:fieldget('descricao') color Cor(11)
        //@ nLin2-2,57 say oQuery:fieldget('Tipo')+"-"+iif(oQuery:fieldget('tipo') = "1","Credito","Debito ") color Cor(11)
        aRect := { oBrow:rowPos,1,oBrow:rowPos,7}
        oBrow:colorRect(aRect,{2,2})
        if ( oBrow:stable )
            if ( oBrow:hitTop .OR. oBrow:hitBottom )
                tone(1200,1)
            endif
            nTecla := inkey(0)
        endif
        if !TBMoveCursor(nTecla,oBrow)
            if nTecla == K_ESC
                lFim := .t.
            elseif nTecla == K_ENTER
                if !lAbrir
                    cDados := alltrim(str(oQuery:fieldget('id')))
                    keyboard (cDados)+chr(K_ENTER)
                    lFim := .t.
                endif
            elseif nTecla == K_F2
                VerMovCxa(oQuery)
            endif
      endif
      oBrow:refreshcurrent()
   enddo
   if !lAbrir
      setcursor(nCursor)
      setcolor(cCor)
   endif
   RestWindow( cTela )
   return
// ****************************************************************************
procedure IncMovCxa
   local getlist := {},cTela := SaveWindow()
	local lLimpa := .t.
	private cLanc,dData,nIdCaixa,nIdHistorico,cCompl1,cCompl2,nValor,cTipo,nIdPagto,cQuery,oQuery
   
   AtivaF4()
   TelaMovCxa(1)
   do while .t.
		if lLimpa
			nIdCaixa := 0
			dData     := date()
			nIdHistorico := 0
			cCompl1   := space(50)
			cCompl2   := space(50)
			cLanc     := space(06)
			nValor    := 0.00
			nIdPagto := 0
			cTipo     := space(01)
			lLimpa := .f.
		endif
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      cQuery := "SELECT last_value FROM financeiro.movcaixa_id_seq "
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
         exit
      endif  
      nId := oQuery:fieldget('last_value')
      @ 08,22 say nId picture "999999"
		if !GetMovCxa()
			exit
		endif
      if !Confirm("Confirma a Inclusao")
         loop
      endif
      GravarMovCxa(.t.) // gera a Query para inclusao
      Msg(.t.)
      Msg("Aguarde: Gravando as informa?Ñes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      if !Grava_LogSql("Cadastros|Financeiro|Caixa|Movimento|incluir|Lancamento: "+str(nId))
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
       endif
      oServer:Commit()
      oQuery:Close()
      Msg(.f.)
      /*
		if cTipo == "1"
			Caixa->SldCaixa += nValor
		else
			Caixa->SldCaixa -= nValor
		endif
		Caixa->(dbunlock())
      */
		lLimpa := .t.
   enddo
   DesativaF4()
   RestWindow(cTela)
return
// ****************************************************************************
procedure AltMovCxa
   local getlist := {},cTela := SaveWindow()
   local lLimpa := .t.
   private nId,dData,nIdCaixa,nIdHistorico,cCompl1,cCompl2,nValor,cTipo,nIdPagto,cQuery,oQuery
   
   AtivaF4()
   TelaMovCxa(2)
   while .t.
		if lLimpa
         nId := 0
      	dData     := date()
      	nIdCaixa := 0
      	nIdHistorico := 0
      	cCompl1   := space(50)
      	cCompl2   := space(50)
      	nValor    := 0.00
      	nIdPagto := 0
      	cTipo     := space(01)
      	lLimpa := .f.
      endif
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 08,22 get nId picture "@k 999999";
                  when Rodape("Esc-Encerra | F4-Lanáamentos");
                  valid SqlBusca("id = "+NumberToSql(nId),"data,idcaixa,idhistorico,complemento1,complemento2,tipo,valor,"+;
                  "idpagto,Altera,fechado",@oQuery,"financeiro.movcaixa",,,,{"Lanáamento n∆o cadastrado"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif 
      if oQuery:fieldget('Fechado') == "S"
         Mens({"Este Lancamento Nao Pode Ser Alterado","Movimento Ja Fechado"})
         loop
      end
      if !oQuery:fieldget('Altera')
         Mens({"Este Lancamento Ç Autom†tico","Alteracao NAO permitida"})
         loop
      end
      dData     := oQuery:fieldget('Data')
      nIdCaixa := oQuery:fieldget('idcaixa')
      nIdHistorico := oQuery:fieldget('idhistorico')
      cCompl1   := oQuery:fieldget('Complemento1')
      cCompl2   := oQuery:fieldget('Complemento2')
      cTipo     := oQuery:fieldget('Tipo')
      nValor    := oQuery:fieldget('Valor')
      nIdPagto := oQuery:fieldget('IdPagto')
		if !GetMovCxa()
			loop
		endif
      if !Confirm("Confirma a Alteraá∆o")
         loop
      endif
      GravarMovCxa(.f.) // gera a Query para inclusao
      Msg(.t.)
      Msg("Aguarde: Gravando as informaá‰es")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      if !Grava_LogSql("Cadastros|Financeiro|Caixa|Movimento|Alterar|Lancamento: "+str(nId))
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      oServer:Commit()
      oQuery:Close()
      Msg(.f.)
      Mens({"Alteraá∆o realizada com sucesso"})

      /*
      if !(MovCaixa->CodCaixa == cCodCaixa)
         if Caixa->(dbsetorder(1),dbseek(MovCaixa->CodCaixa))
            do while !Caixa->(Trava_Reg())
            enddo
            if MovCaixa->Tipo == "1"
            	Caixa->SldCaixa -= MovCaixa->Valor
            else
            	Caixa->SldCaixa += nValor
            endif
         endif
         if Caixa->(dbsetorder(1),dbseek(cCodCaixa))
            do while !Caixa->(Trava_Reg())
            enddo
            if cTipo == "1"
            	Caixa->SldCaixa += nValor
            else
               Caixa->SldCaixa -= nValor
            endif
         endif
         Caixa->(dbcommit())
         Caixa->(dbunlock())
      else
         if Caixa->(Trava_Reg())
            if MovCaixa->Tipo == "1"
               Caixa->SldCaixa -= MovCaixa->Valor
            else
               Caixa->SldCaixa += nValor
            end
            if cTipo == "1"
               Caixa->SldCaixa += nValor
            else
               Caixa->SldCaixa -= nValor
            end
            Caixa->(dbunlock())
         end
      end
      */
      lLimpa := .t.
   enddo
   DesativaF4()
   RestWindow(cTela)
return
// ****************************************************************************
procedure ExcMovCxa
   local getlist := {},cTela := SaveWindow()
   local nId,cQuery
   private oQuery

   
   AtivaF4()
   TelaMovCxa(3)
   while .t.
      nId := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 08,22 get nId picture "@k 999999";
                  when Rodape("Esc-Encerra | F4-Lanáamentos")
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif 
      cQuery := " SELECT " 
      cQuery += "movcaixa.id, movcaixa.data,movcaixa.idcaixa,movcaixa.idhistorico,historicocaixa.descricao,"
      cQuery += "movcaixa.complemento1,movcaixa.complemento2,movcaixa.valor,movcaixa.idpagto,movcaixa.tipo,"
      cQuery += "formapagtocaixa.descricao,caixa.descricao AS des_caixa,movcaixa.altera "
      cQuery += "FROM financeiro.movcaixa movcaixa "
      cQuery += " INNER JOIN financeiro.historicocaixa ON movcaixa.idhistorico = historicocaixa.id " 
      cQuery += " INNER JOIN financeiro.formapagtocaixa ON movcaixa.idpagto = formapagtocaixa.id "
      cQuery += " INNER JOIN financeiro.caixa ON (movcaixa.idcaixa = caixa.id)"
      cQuery += " WHERE movcaixa.id = "+NumberToSql(nId)
      if !ExecuteSql(cQuery,@oQuery,{"Falha ao pesquisar lanáamento"},"sqlerro")
          oQuery:close()
          loop
      endif
      if oQuery:lastrec() = 0
          Mens({"Lanáaamento n∆o cadastrado"})
          loop
      endif
      if oQuery:fieldget('Fechado') == "S"
          Mens({"Este Lancamento Nao Pode Ser Excluido","Movimento Ja Fechado"})
          loop
      endif
      if !oQuery:fieldget('Altera')
         Mens({"Este Lancamento Ç Autom†tico","Exclusao NAO permitida"})
         loop
      end
      MostMovCxa()
      if !Confirm("Confirma a Exclus∆o",2)
         loop
      end
      while !Caixa->(Trava_Reg())
      end
      if MovCaixa->tipo == "1"
         Caixa->SldCaixa -= MovCaixa->Valor
      else
         Caixa->SldCaixa += MovCaixa->Valor
      end
      Caixa->(dbunlock())
      while !MovCaixa->(Trava_Reg())
      end
      MovCaixa->(dbdelete())
      MovCaixa->(dbcommit())
      MovCaixa->(dbunlock())
      Grava_Log(cDiretorio,"Movimento|Excluir|Lancamento "+cLanc,MovCaixa->(recno()))
      scroll(09,22,16,72,0)
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
// ****************************************************************************
static procedure VerMovCxa()
   local cTela := SaveWindow()

   TelaMovCxa(4)
   MostMovCxa()
   Rodape(space(20)+"Pressione Qualquer Tecla Para Continuar")
   inkey(0)
   RestWindow(cTela)
   return
// ****************************************************************************
static procedure MostMovCxa()
   @ 08,22 say oQuery:fieldget('id') picture "@e 999,999,999"
   @ 09,22 say oQuery:fieldget('Data')
   @ 10,22 say oQuery:fieldget('idcaixa')  picture "@k 99"
   @ 10,27 say oQuery:fieldget('des_caixa')
   @ 11,22 say oQuery:fieldget('idhistorico') picture "@k 999"
   @ 11,27 say oQuery:fieldget('descricao')
   @ 12,22 say oQuery:fieldget('Complemento1') picture "@k!"
   @ 13,22 say oQuery:fieldget('Complemento2') picture "@k!"
   @ 14,22 Say oQuery:fieldget('Valor')      picture "@ke 999,999,999.99"
   @ 15,22 say oQuery:fieldget('idpagto')   picture "@k 99"
   @ 15,27 say oQuery:fieldget('descricao')
   @ 16,22 say oQuery:fieldget('Tipo')       picture "@k!"
   @ 16,27 say iif(oQuery:fieldget('tipo') = "1","Credito","DÇbito ")
return

// ****************************************************************************
procedure FecharMov  // Fechamento do Movimento
   local getlist := {},cTela := SaveWindow()
   local dDataI := date(),dDataF := date()
   local cQuery,oQuery

   Window(06,06,11,40,chr(16)+" Fechar Movimento "+chr(17))
   setcolor(Cor(11))
   //           89012345678901234567890123456789012345678901234567890123456789012345678
   //             1         2         3         4         5         6         7
   @ 08,08 say "Data Inicial:"
   @ 09,08 say "  Data Final:"
   while .t.
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 08,22 get dDataI picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDataI)
      @ 09,22 get dDataF picture "@k" valid dDataF >= dDataI
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      cQuery := "SELECT data FROM financeiro.movcaixa WHERE data >= "+DateToSql(dDataI)+" AND data <= "+DateToSql(dDataF)
      Msg(.t.)
      Msg("Aguarde: Selecionando as informaá‰es")
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      Msg(.f.)
      if oQuery:lastrec() = 0
         Mens({"N∆o existe informaá∆o"})
         loop
      endif
      if !Confirm("Confirma as Informacoes")
         loop
      endif 
      // fecha o movimento
      cQuery := "UPDATE financeiro.movcaixa SET fechado = 'S' "
      cQuery += "WHERE data >= "+DateToSql(dDataI)+" AND data <= "+DateToSql(dDataF)
      Msg(.t.)
      Msg("Aguarde: Fechando o movimento")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      oServer:Commit()
      oQuery:Close()
      Msg(.f.)
      Mens({"Movimento Fechado"})
   end
   RestWindow(cTela)
return
// ****************************************************************************
procedure AbrirMov  // Abri o Movimento Fechado
   local getlist := {},cTela := SaveWindow()
   local dDataI := date(),dDataF := date()
   local cQuery,oQuery

   Window(06,06,11,40,chr(16)+" Abrir Movimento "+chr(17))
   setcolor(Cor(11))
   //           89012345678901234567890123456789012345678901234567890123456789012345678
   //             1         2         3         4         5         6         7
   @ 08,08 say "Data Inicial:"
   @ 09,08 say "  Data Final:"
   while .t.
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 08,22 get dDataI picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDataI)
      @ 09,22 get dDataF picture "@k" valid dDataF >= dDataI
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      cQuery := "SELECT data FROM financeiro.movcaixa "
      cQuery += "WHERE data >= "+DateToSql(dDataI)+" AND data <= "+DateToSql(dDataF)+" AND Fecha = 'S' "
      Msg(.t.)
      Msg("Aguarde: pesquisando as informaá‰es")
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      Msg(.f.)
      if oQuery:lastrec() = 0
         Mens({"N∆o existe informaá∆o"})
         loop
      endif
      if !Confirm("Confirma as Informacoes")
         loop
      endif 
      cQuery := "UPDATE financeiro.movcaixa SET fechado = 'N' "
      cQuery += "WHERE data >= "+DateToSql(dDataI)+" AND data <= "+DateToSql(dDataF)+" AND Fecha = 'S' "
      Msg(.t.)
      Msg("Aguarde: abrindo movimento")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      oServer:Commit()
      oQuery:Close()
      Msg(.f.)
      Mens({"Movimento Aberto"})
   enddo
   RestWindow(cTela)
return
// ****************************************************************************
procedure TelaMovCxa( nModo )
   local cTitulo, aTitulos := {"Inclus∆o","Alteraá∆o","Exclus∆o","Visualizacao" }

   Window(06,07,18,73,"> "+aTitulos[nModo]+" de Movimento de Caixa <")
   setcolor(Cor(11))
   //           9012345678901234567890123456789012345678901234567890123456789012345678
   //            1         2         3         4         5         6         7
   @ 08,09 say " Lanáamento:"
   @ 09,09 say "       Data:"
   @ 10,09 say "      Caixa:"
   @ 11,09 say "  Historico:"
   @ 12,09 say "Complemento:"
   @ 14,09 say "      Valor:"
   @ 15,09 say "Forma Pagto:"
   @ 16,09 say "       Tipo:"
return
// ****************************************************************************
procedure CalcSaldo  // Recalcula Saldos
   local getlist := {},cTela := SaveWindow()
   private cCodCaixa

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenCaixa()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenMovCxa()
        FechaDados()
        Msg(.f.)
        return
    endif
   Msg(.f.)
   AtivaF4()
   Window(09,18,13,63," Recalcula Saldos de Caixa ")
   setcolor(Cor(11))
   //           012345678
   @ 11,20 say "Caixa:"
   while .t.
      cCodCaixa := space(02)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,27 get cCodCaixa picture "@k 99" when Rodape("Esc-Encerra | F4-Caixas") valid iif(cCodCaixa == "99",.t.,Busca(Zera(@cCodCaixa),"Caixa",1,11,31,"Caixa->NomCaixa",{"Caixa Nao Cadastrado"},.f.,.t.,.f.))
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma")
         loop
      end
      lCondicao := iif(cCodCaixa == "99",".t.","MovCaixa->CodCaixa == cCodCaixa")
      if !Caixa->(Trava_Arq())
         Caixa->(dbunlock())
         loop
      end
      if !MovCaixa->(Trava_Arq())
         MovCaixa->(dbunlock())
         loop
      end
      Msg(.t.)
      Msg("Aguarde : Zerando Saldo do(s) Caixa(s)")
      Caixa->(dbgotop())
      while Caixa->(!eof())
         Caixa->SldCaixa := 0.00
         Caixa->(dbskip())
      end
      Msg(.f.)
      Msg(.t.)
      Msg("Aguarde : Recalculando Saldo")
      MovCaixa->(dbgotop())
      while MovCaixa->(!eof())
         if &lCondicao
            if Caixa->(dbsetorder(1),dbseek(MovCaixa->CodCaixa))
               if MovCaixa->tipo == "1"
                  Caixa->SldCaixa += MovCaixa->Valor
               else
                  Caixa->SldCaixa -= MovCaixa->Valor
               end
            end
         end
         MovCaixa->(dbskip())
      end
      Msg(.f.)
      Mens({"Saldo Ja Recalculado"})
   end
   DesativaF4()
   RestWindow(cTela)
return

   
static function GetMovCxa
   local oQuery
   
	@ 09,22 get dData picture "@k";
               when Rodape("Esc-Encerra") valid NoEmpty(dData)
	@ 10,22 get nIdCaixa picture "@k 99";
               when Rodape("Esc-Encerra | F4-Caixas");
               valid SqlBusca("id = "+NumberToSql(nIdCaixa),"descricao",@oQuery,;
               "financeiro.caixa",row(),col()+1,{"descricao",0},{"Caixa n∆o cadastrado"},.f.)
	@ 11,22 get nIdHistorico picture "@k 999";
               when Rodape("Esc-Encerra | F4-Historicos Padrao");
               valid SqlBusca("id = "+NumberToSql(nIdHistorico),"descricao",@oQuery,;
               "financeiro.historicocaixa",row(),col()+1,{"descricao",0},{"Hist¢rico n∆o cadastrado"},.f.)
	@ 12,22 get cCompl1   picture "@k!"    when Rodape("Esc-Encerra")
	@ 13,22 get cCompl2   picture "@k!"
	@ 14,22 get nValor    picture "@ke 999,999,999.99"
	@ 15,22 get nIdPagto picture "@k 99";
               when Rodape("Esc-Encerra | F4-Formas de Pagamento");
               valid SqlBusca("id = "+NumberToSql(nIdPagto),"descricao",@oQuery,;
               "financeiro.formapagtocaixa",row(),col()+1,{"descricao",0},{"Forma de pagamento n∆o cadastrada"},.f.)
	@ 16,22 get cTipo     picture "@k!"    when Rodape("Esc-Encerra") valid MenuArray(@cTipo,{{"1","Credito"},{"2","Debito "}},16,22,16,27)
	setcursor(SC_NORMAL)
	read
	setcursor(SC_NONE)
	if lastkey() == K_ESC
		return(.f.)
	endif
return(.t.)
	
static procedure GravarMovCxa(lIncluir)

	if lIncluir
      cQuery := "INSERT INTO financeiro.movcaixa (data,idcaixa,idhistorico,complemento1,complemento2,tipo,valor,idpagto,altera) "
      cQuery += "VALUES ("
      cQuery += DateToSql(dData)+","
      cQuery += NumberToSql(nIdCaixa)+","
      cQuery += NumberToSql(nIdHistorico)+","
      cQuery += StringToSql(cCompl1)+","
      cQuery += StringToSql(cCompl2)+","
      cQuery += StringToSql(cTipo)+","
      cQuery += NumberToSql(nValor,12,2)+","
      cQuery += NumberToSql(nIdPagto)+","
      cQuery += 'true'
      cQuery += ")"
	else
      cQuery := "UPDATE financeiro.movcaixa SET " 
      cQuery += "data = "+DateToSql(dData)+","
      cQuery += "idcaixa = "+NumberToSql(nIdCaixa)+","
      cQuery += "idhistorico = "+NumberToSql(nIdHistorico)+","
      cQuery += "complemento1 = "+StringToSql(cCompl1)+","
      cQuery += "complemento2 = "+StringToSql(cCompl2)+","
      cQuery += "tipo = "+StringToSql(cTipo)+","
      cQuery += "valor = "+NumberToSql(nValor,12,2)+","
      cQuery += "idpagto = "+NumberToSql(nIdPagto)
      cQuery += " WHERE id = "+NumberToSql(nId)
	endif
return


// ** Fim do Arquivo.
