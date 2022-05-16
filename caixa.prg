/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 3.00
 * Identificacao: Manutencao de Caixas
 * Prefixo......: LTADM
 * Programa.....: CAIXA.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 28 DE DEZEMBRO DE 2002
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConCaixa(lAbrir)
    local cTela := SaveWindow()
    
    View_Caixa(.f.)
    RestWindow(cTela)
return
// ****************************************************************************
procedure IncCaixa
    local getlist := {},cTela := SaveWindow()
    local nCodCaixa,cNomCaixa,nSldCaixa
    local cQuery,oQuery

    AtivaF4()
    TelCaixa(1)
    do while .t.
        nCodCaixa := 0
        cNomCaixa := space(30)
        nSldCaixa := 0.00
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        oQuery := oServer:Query("SELECT Last_value FROM financeiro.caixa_id_seq")
        nCodCaixa := oQuery:fieldget('last_value')
        @ 10,34 say nCodCaixa
        @ 11,34 get cNomCaixa picture "@k!" when Rodape("Esc-Encerra")
        @ 12,34 get nSldCaixa picture "@ke 999,999,999.99"
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        if !Confirm("Confirma a Inclusao")
            loop
        endif
        cQuery := "INSERT INTO financeiro.caixa (descricao,saldo ) "
      	CqUERY += " values ("+StringToSql(cNomCaixa)+","+NumberToSql(nSldCaixa,15,2)+")"
        Msg(.t.)
        Msg("Aguarde: Gravando as informa‡äes")
        oServer:StartTransaction()
        if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        if !Grava_LogSql("Cadastros|Financeiro|Caixa|Caixa|Incluir|Codigo: "+str(nCodCaixa))
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop
         endif
        oServer:Commit()
        oQuery:Close()
        Msg(.f.)
    enddo
    DesativaF4()
    RestWindow(cTela)
return
// ****************************************************************************
procedure AltCaixa
   local getlist := {},cTela := SaveWindow()
   local nCodCaixa,cNomCaixa,nSldCaixa
   local cQuery,oQuery,oTabela

   AtivaF4()
   TelCaixa(2)
   while .t.
      nCodCaixa := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,34 get nCodCaixa picture "@k 99";
            when Rodape("Esc-Encerra | F4-Caixas");
            valid SqlBusca("id = "+NumberToSql(nCodCaixa),"descricao,saldo",@oQuery,;
                "financeiro.caixa",,,,{"Caixa nÆo cadastrado"},.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        cNomCaixa := oQuery:fieldget("descricao")
        nSldCaixa := oQuery:fieldget("saldo")
        @ 11,34 get cNomCaixa picture "@k!";
                when Rodape("Esc-Encerra")
        @ 12,34 get nSldCaixa picture "@ke 999,999,999.99";
                when empty(nSldCaixa)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            loop
        endif       
        if !Confirm("Confirma a Alteracao")
            loop
        endif
        cQuery := "UPDATE financeiro.caixa "
		cQuery += "SET "
        cQuery += "descricao = "+StringToSql(cNomCaixa)+","
        cQuery += "saldo = "+NumberToSql(nSldCaixa,15,2)
        cQuery += " WHERE id = "+NumberToSql(nCodCaixa)
        Msg(.t.)
        Msg("Aguarde: Gravando as informa‡äes")
        oServer:StartTransaction()
        if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar "},"sqlerro")
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        if !Grava_LogSql("Cadastros|Financeiro|Caixa|Caixa|Alterar|Codigo: "+str(nCodCaixa))
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
// ****************************************************************************
procedure ExcCaixa
   local getlist := {},cTela := SaveWindow()
   local nCodCaixa,oQuery,cQuery,oTabela

   AtivaF4()
   TelCaixa(3)
   while .t.
      nCodCaixa := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,34 get nCodCaixa picture "@k 99";
            when Rodape("Esc-Encerra | F4-Caixas");
            valid SqlBusca("id = "+NumberToSql(nCodCaixa),"descricao,saldo",;
                @oQuery,"financeiro.caixa",,,,{"Caixa nÆo cadastrado"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
        oTabela := oQuery:getrow()
        @ 11,34 say oTabela:fieldget("descricao")
        @ 12,34 say oTabela:fieldget("saldo") picture "@ke 999,999,999.99"
        // pesquisa movimento do caixa
        /*
        if !SqlBusca("codcaixa = "+NumberToSql(nCodCaixa),;
                "CodCaixa",@oQuery,"financeiro.movcaixa",,,,;
                {"Existe movimento com esse caixa","ExclusÆo nÆo permitida"},.t.,1,"Aguarde: pesquisando movimento do caixa")
            loop
        endif
        */
        if !Confirm("Confirma a Exclusao",2)
            loop
        endif
        oServer:StartTransaction()
      	cQuery := "DELETE FROM financeiro.caixa WHERE id = "+NumberToSql(nCodCaixa)
        Msg(.t.)
        Msg("Aguarde: excluindo informa‡Æo")
        if !ExecuteSql(cQuery,@oQuery,{"Falha: excluir"},"sqlerro")
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        if !Grava_LogSql("Cadastros|Financeiro|Caixa|Caixa|Excluir|Codigo: "+str(nCodCaixa))
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop
         endif
        oServer:Commit()
        oQuery:Close()
    enddo
    DesativaF4()
    RestWindow(cTela)
return
// ****************************************************************************
procedure TelCaixa( nModo )
   local cTitulo, aTitulos := { "InclusÆo" , "Altera‡Æo" , "ExclusÆo" }

   Window(08,17,14,69,"> "+aTitulos[nModo]+" de Caixas <")
   setcolor(Cor(11))
   //           901234567890123456789
   //            2         3
   @ 10,19 say "       C¢digo:"
   @ 11,19 say "    Descri‡Æo:"
   @ 12,19 say "        Saldo:"
return
   
// fim do arquivo.