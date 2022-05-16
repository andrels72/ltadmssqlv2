/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.2
 * Identificacao: Manuten‡Æo de Bancos
 * Prefixo......: LtAdm
 * Programa.....: Bancos.prg
 * Autor........: Andre Lucas Souza
 * Data.........: 23 de Setembro de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConBancos(lAbrir,lDemonstrativo)
   local oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow()
   local cDados1,cDados2,cDados3,nOpcao
   local nCursor := setcursor(),cCor := setcolor()
   local cQuery,oQuery
   local nLin1 := 02 ,nCol1 := 00,nLin2 := 30,nCol2 := 100

    if !lAbrir
        setcursor(SC_NONE)
    endif
    cQuery := "SELECT CodBco,NumAge,NumCon,NomBco,NomAge,PraBco,NomCon,Saldo " 
    cQuery += "FROM financeiro.banco "
    cQuery += "ORDER BY CodBco,NumAge,NumCon"
    Msg(.t.)
    Msg("Aguarde: pesquisando informa‡äes")
    if !ExecuteSql(cQuery,@oQuery,{"Falha: Acessar (Bancos)"},"sqlerro")
        oQuery:Close()
        Msg(.f.)
        return        
    endif
    if oQuery:lastrec() = 0
        Msg(.f.)
        Mens({"Tabela vazia"})
        return
    endif
    Msg(.f.)
   Rodape(iif(lAbrir,"Esc-Encerrar","Esc-Encerra | ENTER-Transfere"))
   setcolor(cor(5))
   Window(nLin1,nCol1,nLin2,nCol2,"> Consulta de Bancos <")
   oBrow := TBrowseDB(nLin1+1,nCol1+1,nLin2-2,nCol2-1)
   oBrow:headSep   := SEPH
   oBrow:footSep   := SEPB
   oBrow:colSep    := SEPV
   oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)   
    oCurRow := oQuery:GetRow( 1 )
    oBrow:SkipBlock := {| n | oCurRow := SkipperQuery( @n, oQuery ), n }
    oBrow:GoBottomBlock := {|| oCurRow := oQuery:GetRow( oQuery:LastRec() ), 1 }
    oBrow:GoTopBlock := {|| oCurRow := oQuery:GetRow( 1 ), 1 }
   
    oBrow:addcolumn(tbcolumnnew("C¢digo"         ,{|| oQuery:FieldGet('CodBco') }))
    oBrow:addcolumn(tbcolumnnew("N§ Agˆncia"     ,{|| oQuery:FieldGet('NumAge') }))
    oBrow:addcolumn(tbcolumnnew("N§ Conta"       ,{|| oQuery:FieldGet('NumCon') }))
    oBrow:addcolumn(tbcolumnnew("Nome do Banco"  ,{|| oQuery:FieldGet('NomBco') }))
    oBrow:addcolumn(tbcolumnnew("Nome da Agˆncia",{|| oQuery:FieldGet('NomAge') }))
    oBrow:addcolumn(tbcolumnnew("Pra‡a"          ,{|| oQuery:FieldGet('PraBco') }))
    oBrow:addcolumn(tbcolumnnew("Correntista"    ,{|| oQuery:FieldGet('NomCon') }))
    oBrow:addcolumn(tbcolumnnew("Saldo"          ,{|| transform(oQuery:FieldGet('saldo'),"@e 999,999,999.99")}))
    aTab := TabHNew(nLin2-1,nCol1+1,nCol2-1,setcolor(cor(28)),1)
    TabHDisplay(aTab)
    do while (! lFim)
        do while ( ! oBrow:stabilize() )
            nTecla := INKEY()
            IF ( nTecla != 0 )
                EXIT
            ENDIF
        ENDdo
        IF ( oBrow:stable )
            IF ( oBrow:hitTop .OR. oBrow:hitBottom )
                TONE(1200,1)
            ENDIF
            nTecla := INKEY(0)
        ENDIF
        if !TBMoveCursor(nTecla,oBrow)
            if nTecla == K_ESC
                lFim := .t.
            elseif nTecla == K_ENTER .and. !lAbrir
                cDados1 := oQuery:fieldget('CodBco')
                cDados2 := oQuery:fieldget('NumAge')
                cDados3 := oQuery:fieldget('NumCon')
                keyboard (cDados1)+chr(K_ENTER)+(cDados2)+chr(K_ENTER)+(cDados3)+chr(K_ENTER)
                lFim := .t.
            endif 
        endif 
        if nTecla == K_RIGHT
            tabHupdate(aTab,obrow:colpos,obrow:colcount,.t.)
        elseif nTecla == K_LEFT
            tabHupdate(aTab,obrow:colpos,obrow:colcount,.t.)
        endif 
    enddo
    if !lAbrir
      setcursor(nCursor)
      setcolor(cCor)
    else
        oQuery:close()
    endif
    RestWindow( cTela )
RETURN
// ****************************************************************************
procedure IncBancos(lAbrir)
   local getlist := {},cTela := SaveWindow()
   local cCodBco,cNumAge,cNumCon,cNomAge,cPraBco,cNomCon,cNomBco
   local nCursor := setcursor(),cDemons,cQuery,oQuery

   TelBancos(1)
   do while .t.
        cCodBco := space(03)
        cNumAge := space(04)
        cNumCon := space(15)
        cNomBco := space(30)
        cNomAge := space(20)
        cPraBco := space(20)
        cNomCon := space(30)
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 09,32 get cCodBco picture "@k 999";
            when Rodape("Esc-Encerra | F4-Bancos");
            valid NoEmpty(cCodBco) .and. V_Zera(@cCodBco) .and. v_Bco(@cCodBco)
            
        @ 10,32 get cNumAge picture "@k!";
            when Rodape("Esc-Encerra");
            valid NoEmpty(cNumAge) .and. V_Zera(@cNumAge)
                    
        @ 11,32 get cNumCon picture "@k!";
            valid NoEmpty(cNumCon) .and.;
                        SqlBusca("codbco = "+StringToSql(cCodBco)+;
                    " AND numage = "+StringToSql(cNumAge)+;
                    " AND numcon = "+StringToSql(cNumCon),"CodBco,Numage,NumCon",@oQuery,;
                    "financeiro.banco",,,,{"Banco/Agencia/Conta j  cadastrado"},.t.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
      @ 12,32 get cNomBco picture "@k!"
      @ 13,32 get cNomAge picture "@k!"
      @ 14,32 get cPraBco picture "@k!"
      @ 15,32 get cNomCon picture "@k!"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      end
      if !Confirm("Confirma a Inclusao")
         loop
      endif
        oQuery:Close()
        cQuery := "INSERT INTO financeiro.banco (codbco,numage,numcon,nombco,nomage,prabco,nomcon,demons) "
        cQuery += "VALUES ("
        cQuery += StringToSql(cCodBco)+","+StringToSql(cNumAge)+","+StringToSql(cNumCon)+","
        cQuery += StringToSql(cNomBco)+","+StringToSql(cNomAge)+","+StringToSql(cPraBco)+","
        cQuery += StringToSql(cNomCon)+")"
        // Inicia transacao
        oServer:StartTransaction()
        Msg(.t.)
        Msg("Aguarde: Gravando a InclusÆo")
        if !ExecuteSql(cQuery,@oQuery,{"Falha: incluir banco"},"sqlerro")
            oQuery:Close()
            oServer:Rollback()
            loop        
		endif
        if !Grava_LogSql("Cadastro|Financeiro|Bancos|Bancos|Incluir|Banco "+cCodBco+cNumAge+cNumCon)
            oServer:Rollback()
            loop        
		endif
        // Finaliza a transa‡Æo
        oServer:Commit()
        oQuery:Close()
        Msg(.f.)
    enddo
    if lAbrir
        DesativaF4()
   else
      setcursor(nCursor)
   endif
   RestWindow(cTela)
return
// ****************************************************************************
procedure AltBancos
   local getlist := {},cTela := SaveWindow()
   local cCodBco,cNumAge,cNumCon,cNomBco,cNomAge,cPraBco,cNomCon
   local cQuery,oQuery
   
   AtivaF4()
   TelBancos(2)
   while .t.
      cCodBco := space(03)
      cNumAge := space(04)
      cNumCon := space(15)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 09,32 get cCodBco picture "@k 999";
                when Rodape("Esc-Encerra | F4-Bancos");
                valid V_Zera(@cCodBco) .and. !(cCodBco == "000")
                
      @ 10,32 get cNumAge picture "@k";
                when Rodape("Esc-Encerra");
                valid NoEmpty(cNumAge) .and. V_Zera(@cNumAge)
                 
      @ 11,32 get cNumCon picture "@k";
            valid  SqlBusca("codbco = "+StringToSql(cCodBco)+;
                    " AND numage = "+StringToSql(cNumAge)+;
                    " AND numcon = "+StringToSql(cNumCon),"CodBco,NumAge,NumCon,"+;
                    "NomBco,NomAge,PraBco,NomCon,Demons",@oQuery,;
                    "financeiro.banco",,,,{"Banco/Agencia/Conta nÆo cadastrado"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
        cNomBco := oQuery:FieldGet('NomBco')
        cNomAge := oQuery:FieldGet('NomAge')
        cPraBco := oQuery:FieldGet('PraBco')
        cNomCon := oQuery:FieldGet('NomCon')
        @ 12,32 get cNomBco picture "@k!"
        @ 13,32 get cNomAge picture "@k!"
        @ 14,32 get cPraBco picture "@k!"
        @ 15,32 get cNomCon picture "@k!"
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            loop
        endif
        if !Confirm("Confirma a Altera‡Æo")
            loop
        endif
        cQuery := "UPDATE financeiro.banco"
        cQuery += " SET nombco = "+StringToSql(cNomBco)+","
        cQuery += " nomage = "+StringToSql(cNomAge)+","
        cQuery += " prabco = "+StringToSql(cPraBco)+","
        cQuery += " nomcon = "+StringToSql(cNomCon)
        cQuery += " WHERE codbco = "+StringToSql(cCodBco)+" AND numage = "+StringToSql(cNumAge)
        cQuery += " AND numcon = "+StringToSql(cNumCon)
        Msg(.t.)
        Msg("Aguarde: Gravando a Altera‡Æo")
        oServer:StartTransaction()
        if !ExecuteSql(cQuery,@oQuery,{"Falha: Alterar (Bancos)"},"sqlerro")
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop        
        endif
        if !Grava_LogSql("Cadastro|Financeiro|Bancos|Bancos|Alterar|Banco "+cCodBco+cNumAge+cNumCon)
            oServer:Rollback()
            Msg(.f.)
            loop        
        endif
        oQuery:Close()
        oServer:Commit()
        Msg(.f.)
    enddo
    DesativaF4()
    RestWindow(cTela)
return
// ****************************************************************************
procedure ExcBancos
   local getlist := {},cTela := SaveWindow()
   local cCodBco,cNumAge,cNumCon,cQuery,oQuery
   
   AtivaF4()
   TelBancos(3)
   while .t.
      cCodBco := space(03)
      cNumAge := space(04)
      cNumCon := space(15)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 09,32 get cCodBco picture "@k 999";
                when Rodape("Esc-Encerra | F4-Bancos");
                valid V_Zera(@cCodBco) .and. !(cCodBco == "000")
                
      @ 10,32 get cNumAge picture "@k";
                when Rodape("Esc-Encerra");
                valid NoEmpty(cNumAge) .and. V_Zera(@cNumAge)
                 
      @ 11,32 get cNumCon picture "@k";
            valid  SqlBusca("codbco = "+StringToSql(cCodBco)+;
                    " AND numage = "+StringToSql(cNumAge)+;
                    " AND numcon = "+StringToSql(cNumCon),"CodBco,NumAge,NumCon,"+;
                    "NomBco,NomAge,PraBco,NomCon,Demons",@oQuery,;
                    "financeiro.banco",,,,{"Banco/Agencia/Conta nÆo cadastrado"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
        @ 12,32 say oQuery:FieldGet('NomBco') picture "@k!"
        @ 13,32 say oQuery:FieldGet('NomAge') picture "@k!"
        @ 14,32 say oQuery:FieldGet('PraBco') picture "@k!"
        @ 15,32 say oQuery:fieldGet('NomCon') picture "@k!"
        // pesquisa se existe movimento de banco com esses dados
        /*
        if !SqlBusca(" codbco = "+StringToSql(cCodBco)+;
                " AND numage = "+StringToSql(cNumAge)+;
                " AND numcon = "+StringToSql(cNumCon),;
                "CodBco",@oQuery,"financeiro.movbanco",,,,;
                {"Existe movimento de banco com esse Banco/Agˆncia/Conta","ExclusÆo nÆo permitida"},.t.,,"Aguarde: pesquisando movimento")
            loop
        endif
        */
        // pesquisa se existe cheque        
        /*
        if !SqlBusca(" codbco = "+StringToSql(cCodBco)+;
                " AND numage = "+StringToSql(cNumAge)+;
                " AND numcon = "+StringToSql(cNumCon),;
                "CodBco",@oQuery,"financeiro.cheques",,,,;
                {"Existe cheque(s) com esse Banco/Agˆncia/Conta","ExclusÆo nÆo permitida"},.t.,,"Aguarde: pesquisando cheque(s)")
            loop
        endif
        */
        if !Confirm("Confirma a ExclusÆo",2)
            loop
        end
        cQuery := "DELETE FROM financeiro.banco"
        cQuery += " WHERE codbco = "+StringToSql(cCodBco)
        cQuery += " AND numage = "+StringToSql(cNumAge)
        cQuery += " AND numcon = "+StringToSql(cNumCon)
        Msg(.t.)
        Msg("Aguarde: Excluindo as informa‡äes ")
        oServer:StartTransaction()
        if !ExecuteSql(cQuery,@oQuery,{"Falha: Excluir (Bancos)"},"sqlerro")
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop        
        endif
        if !Grava_LogSql("Cadastro|Financeiro|Bancos|Bancos|Excluir|Banco "+cCodBco+cNumAge+cNumCon)
            oServer:Rollback()
            Msg(.f.)
            loop        
        endif
        oQuery:Close()
        oServer:Commit()
        Msg(.f.)
    enddo
   DesativaF4()
   RestWindow(cTela)
return
// ****************************************************************************
procedure TelBancos( nModo)
   local aTitulos := {"Inclusao","Alteracao","Exclusao"}

   Window(07,16,18,63,"> " + aTitulos[ nModo ] + " de Bancos <")
   setcolor(Cor(11))
   //           8901234567890123456789012345678901234567890123456789012345678
   //             2         3         4         5         6         7
   @ 09,18 say "      C¢digo:"
   @ 10,18 say "  N§ Agˆncia:"
   @ 11,18 say " N§ da Conta:            -"
   @ 12,18 say "  Nome Banco:"
   @ 13,18 say "Nome Agˆncia:"
   @ 14,18 say "       Pra‡a:"
   @ 15,18 say " Correntista:"
return

// ****************************************************************************
static function v_Bco(cCodBco)
    local oQuery

    if !SqlBusca("codbco = "+"'"+cCodBco+"'","NomBco",@oQuery,;
                "financeiro.banco",,,,{"Banco nÆo cadastrado"},.f.)
        return(.t.)
    endif
    cNomBco := oQuery:FieldGet('nombco')
    oQuery:Close()
return(.t.)
   
//** Fim do Arquivo.
