/*************************************************************************
         Sistema: Administrativo
          Vers’o: 3.00
   IdentificaÎ’o: Manutencao de Pedidos
         Prefixo: LtAdm
        Programa: Pedidos.PRG
           Autor: Andre Lucas Souza
            Data: 31 de Agosto de 2003
   Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConTransfProd(lAbrir)
    local oBrow,nTecla,lFim := .F.,cTela := savewindow(),cDados
    local nCursor := setcursor(),cCor := setcolor(),oQuery,cQuery
    local nLinha1  := 02,nColuna1 := 00,nLinha2 := 33,nColuna2 := 100

    if !ExecuteSql("SELECT id FROM administrativo.transfprod LIMIT 1",@oQuery,{"Falha: pesquisar historico"},"sqlerro")
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
    cQuery := "SELECT t.id ,t.data, t.codprod_sr, p.fanpro as prods, t.qtd_s, t.codprod_er ,p2.fanpro AS prode "
    cQuery += "FROM administrativo.transfprod t "
    cQuery += "INNER JOIN administrativo.produtos p ON (t.codprod_sr = p.id) "
    cQuery += "INNER JOIN administrativo.produtos p2 ON (t.codprod_er = p2.id) "
    cQuery += "ORDER BY t.data "
    Msg(.t.)
    Msg("Aguarde: Pesquisando as informa‡äes")
    if !ExecuteSql(cQuery,@oQuery,{"Falha: pesquisa"},"sqlerro")
        Msg(.f.)
        RestWindow(cTela)
        return
    endif
    msg(.f.)
    Rodape(iif(lAbrir,"Esc-Encerra","Esc-Encerra | ENTER-Transfere"))
    setcolor(cor(5))
    Window(nLinha1,nColuna1,nLinha2,nColuna2,"> Consulta de Transferˆncias <")
    oBrow := TBrowseDB(nLinha1+1,nColuna1+1,nLinha2-2,nColuna2-1)
    oBrow:headSep := SEPH
    oBrow:footSep := SEPB
    oBrow:colSep  := SEPV
    oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)   
    oBrow:SkipBlock := {| n | oCurRow := SkipperQuery( @n, oQuery ), n }
    oBrow:GoBottomBlock := {|| oCurRow := oQuery:GetRow( oQuery:LastRec() ), 1 }
    oBrow:GoTopBlock := {|| oCurRow := oQuery:GetRow( 1 ), 1 }
    oBrow:addcolumn(tbcolumnnew("Lanc.",{|| str(oQuery:fieldget('Id'),3) }))
    oBrow:addcolumn(tbcolumnnew("Data",{|| oQuery:fieldget('Data') }))
    oBrow:addcolumn(tbcolumnnew("De",{|| str(oQuery:fieldget('CodProd_Sr'),6)+"-"+oQuery:fieldget('prods')}))
    oBrow:addcolumn(tbcolumnnew("Quantidade",{|| transform(oQuery:fieldget('Qtd_s'),"99,999.999")}))
    oBrow:addcolumn(tbcolumnnew("Para",{|| str(oQuery:fieldget('CodProd_Er'),6)+"-"+oQuery:fieldget('prode')}))
    setcolor(Cor(26))
    scroll(nLinha2-1,nColuna1+1,nLinha2-1,nColuna2-1,0)
    do while (! lFim)
        do while ( ! oBrow:stabilize() )
            nTecla := INKEY()
            if ( nTecla != 0 )
                exit
            endif
        enddo
        if ( oBrow:stable )
            if ( oBrow:hitTop .OR. oBrow:hitBottom )
                tone(1200,1)
            endif
            nTecla := INKEY(0)
        endif
        if !TBMoveCursor(nTecla,oBrow)
            if nTecla == K_ESC
                lFim := .t.
            elseif nTecla == K_ENTER
                if !lAbrir
                    cDados := Pedidos->NumPed
                    keyboard (cDados)+chr(K_ENTER)
                    lFim := .t.
                endif
            elseif nTecla == K_F3
                VerItemPed(Pedidos->NumPed)
            endif
        endif   
    enddo
    if !lAbrir
        setcursor(nCursor)
        setcolor(cCor)
    else
        FechaDados()
    endif
    RestWindow( cTela )
RETURN
// ****************************************************************************
procedure IncTransfProd
    local getlist :={},cTela := SaveWindow()
    local nId,dData,cCodProdS,nQtdS,cCodProdE,lLimpa := .t.,nCodProdSr,nCodProdEr,oQuery,cQuery,oQProdutosS
    local oQProdutosE

    AtivaF4()
    TelTransfProd(1)
    do while .t.
        if lLimpa
            dData := date()
            cCodProdS := space(14)
            nQtdS := 0.000
            cCodProdE := space(14)
            lLimpa := .f.
        endif
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        oQuery := oServer:Query("SELECT Last_value FROM administrativo.transfprod_id_seq;")
        nId := oQuery:fieldget('last_value')
        @ 06,13 say nId picture "@e 999,999"

        @ 07,13 get dData picture "@k";
                when Rodape("Esc-Encerrar");
                valid NoEmpty(dData)
        @ 09,13 get cCodProdS picture "@k";
                when Rodape("Esc-Encerrar | F4-Produtos");
                valid BuscarCodigo(@cCodProdS,,@oQProdutosS)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        @ 10,13 say oQProdutosS:fieldget('fanpro')
        if oQProdutosS:fieldget('qteac02') = 0
            Mens({"Produto sem saldo para transferir"})
            loop
        endif
        nCodProdSr := oQProdutosS:fieldget('id')
        @ 11,13 get nQtdS picture "@k 99,999.999"
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            loop
        endif
        if nQtdS > oQProdutosS:fieldget('qteac02')
            Mens({"Saldo insuficiente para transferir"})
            loop
        endif
        // Produto de entrada
        @ 13,13 get cCodProdE picture "@k";
            when Rodape("Esc-Encerrar | F4-Produtos");
            valid BuscarCodigo(@cCodProdE,,@oQProdutosE)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        @ 14,13 say oQProdutosE:fieldget('fanpro')
        nCodProdEr := oQProdutosE:fieldget('id')
        if !Confirm("Confirma as informa‡äes")
            loop
        endif
        cQuery := "INSERT INTO administrativo.transfprod (data,codprod_s,codprod_sr,qtd_s,codprod_e,codprod_er )"
        cQuery += "VALUES ("
        cQuery += DateToSql(dData)+","
        cQuery += StringToSql(cCodProdS)+","
        cQuery += NumberToSql(nCodProdSr)+","
        cQuery += NumberToSql(nQtdS,11,3)+","
        cQuery += StringToSql(cCodProdE)+","
        cQuery += NumberToSql(nCodProdEr)+")"
        Msg(.t.)
        Msg("Aguarde: Gravando as informa‡äes")
        oServer:StartTransaction()
        if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        cQuery := "UPDATE administrativo.produtos "
        cQuery += "SET qteac02 = qteac02 - "+NumberToSql(nQtdS,11,3)+" "
        cQuery += "WHERE id = "+NumberToSql(nCodProdSr)
        if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        cQuery := "UPDATE administrativo.produtos "
        cQuery += "SET qteac02 = qteac02 + "+NumberToSql(nQtdS,11,3)+" "
        cQuery += "WHERE id = "+NumberToSql(nCodProdEr)
        if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
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
    RestWindow(cTela)
return
//*********************************************************************************************
procedure ExcTransfProd
    local getlist :={},cTela := SaveWindow()
    local nId,dData,cCodProdS,nQtdS,cCodProdE,lLimpa := .t.
    local cQuery,oQuery,oQuery2

    TelTransfProd(3)
    do while .t.
        nId := 0
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 06,13 get nId picture "@e 999,999";
                when Rodape("Esc-Encerra | F4-transferˆncias")
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        cQuery := "SELECT t.id ,t.data, t.codprod_s,t.codprod_sr, p.fanpro as prods, t.qtd_s, t.codprod_e, t.codprod_er ,p2.fanpro as prode "
        cQuery += "FROM administrativo.transfprod t "
        cQuery += "INNER JOIN administrativo.produtos p ON (t.codprod_sr = p.id) "
        cQuery += "INNER JOIN administrativo.produtos p2 ON (t.codprod_er = p2.id) "
        cQuery += "WHERE t.id = "+NumberToSql(nId)+" "
        cQuery += "ORDER BY t.data "
        Msg(.t.)
        Msg("Aguarde: Pesquisando ")
        if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
            oQuery:Close()
            Msg(.f.)
            loop
        endif
        Msg(.f.)
        if oQuery:lastrec() = 0
            Mens({"Transferˆncia nÆo cadastrada"})
            loop
        endif
        @ 07,13 say oQuery:fieldget('Data')
        @ 09,13 say oQuery:fieldget('CodProd_S')
        @ 10,13 say oQuery:fieldget('prods')
        @ 11,13 say oQuery:fieldget('Qtd_s') picture "@k 99,999.999"
        @ 13,13 say oQuery:fieldget('CodProd_E')
        @ 14,13 say oQuery:fieldget('prode') 
        if !Confirm("Confirma as informa‡äes")
            loop
        endif
        cQuery := "UPDATE administrativo.produtos "
        cQuery += "SET qteac02 = qteac02 + "+NumberToSql(oQuery:fieldget('qtd_s'),11,3)
        cQuery += "WHERE id = "+oQuery:fieldget('codprod_s')
        Msg(.t.)
        Msg("Aguarde: Gravando as informa‡äes")
        oServer:StartTransaction()
        if !ExecuteSql(cQuery,@oQuery2,{"Erro: Incluir (caixa)"},"sqlerro")
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        cQuery := "UPDATE administrativo.produtos "
        cQuery += "SET qteac02 = qteac02 - "+NumberToSql(oQuery:fieldget('qtd_s'),11,3)
        cQuery += "WHERE id = "+oQuery:fieldget('codprod_e')
        if !ExecuteSql(cQuery,@oQuery2,{"Erro: Incluir (caixa)"},"sqlerro")
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        oServer:Commit()
        oQuery:Close()
        MSg(.f.)
    enddo 
    FechaDados()
    RestWindow(cTela)
return
//*********************************************************************************************
procedure TelTransfProd(nModo)
    local cTitulo, aTitulos := {"InclusÆo","Altera‡Æo","ExclusÆo"}

	Window(04,00,16,80,"> "+aTitulos[nModo]+" de tranferˆncia de quantidade <")
	setcolor(Cor(11))    
    @ 06,01 say "Lan‡amento:"
    @ 07,01 say "      Data:"
    @ 08,01 say replicate(chr(196),79)
    @ 09,01 say "        De:"
    @ 10,01 say " Descricao:"
    @ 11,01 say "Quantidade:"
    @ 12,01 say replicate(chr(196),79)
    @ 13,01 say "      Para:"
    @ 14,01 say " Descricao:"
return

//** Fim do arquivo.