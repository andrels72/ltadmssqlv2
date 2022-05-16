/*
  Programa......:   PASSWORD.prg
  Localiza‡„o...:   QUALITY.lib
  Autor.........:   Evandro Siqueira
  Data..........:   09/06/94
  Objetivo......:   Rotinas do Plano de Senhas dos Sistemas QUALITY
*/
#include "lucas.CH"
#include "inkey.ch"
#include "setcurs.ch"

//static PWnivel
//static PWregt
//static PWnome

/*
  PwInstall(aProcs)
  Instala o Plano de Senhas

  Argumento:

  aProcs -----------> Vetor Bidimensional Contendo o Codigo e a Descricao das
                      Rotinas Componentes do Sistema.
*/
function PwInstall(aProcs)
   local nI,cQuery,oQuery

   Msg(.t.)
   Msg("Aguarde: Verificando rotinas de acessso")
    for nI := 1 TO LEN(aProcs)
        cQuery := "SELECT codigo,nome FROM administrativo.pwprocessos "
        cQuery += "WHERE codigo = "+StringToSql(aProcs[nI,1])
        if !ExecuteSql(cQuery,@oQuery,{"Falha"},"sqlerro")
            return(.f.)
        endif
        if oQuery:lastrec() = 0
            cQuery := "INSERT INTO administrativo.pwprocessos "
            cQuery += "("
            cQuery += "codigo,"
            cQuery += "nome "
            cQuery += ") "
            cQuery += "values "
            cQuery += "("
            cQuery += StringToSql(aProcs[nI,1])+","
            cQuery += StringToSql(aProcs[nI,2])
            cQuery += ")"
            if !ExecuteSql(cQuery,@oQuery,{"Falha"},"sqlerro")
                oQuery:close()
                return(.f.)
            endif
        endif
    NEXT
    Msg(.f.)
    return(.t.)
    
RETURN NIL


//****************************************************************************
/*
  PwCheck([cProc])

  Verifica o C¢digo de Acesso, a Senha do Usu rio, a Data de Validade da
  Senha e a Autoriza‡„o de Acesso as rotinas do sistema

  Parametros:

  cProc -------------> Nome da rotina a Verificar a autorizacao de Acesso.
                       Opcional. Se Nao for informada verifica o Registro e
                       senha de Acesso.
  Retorna .T. se for permitido o Acesso
*/
function PwCheck(cProc)
   local GetList := { }, cBusca, cSenha := space(10), nCont := 0, lReto := .T., nCad
   local nDias, cCodi := 0, sTela, cCursor,cQuery,oQuery,oRegistro 
   sTela := SaveWindow()

    if cProc = NIL 
        cQuery := "SELECT registro,nome,nivel,senha,entrada,saida,"
        cQuery += "bloqueio,log,abend FROM administrativo.pwusuarios "
        if !ExecuteSql(cQuery,@oQuery,{"Falha ao acessar tabela de suarios "},"sqlerro")
            oQuery:close()
            return(.f.)
        endif
        if oQuery:lastrec() == 0
            if Aviso_1(10,,15,,"Aten‡„o!","N„o h  Usu rios Cadastrados no Sistema, Cadastrar ?",{"  ^Sim  ","  ^N„o  "},2,.t.) == 1
                PwNivel := "0"
                PwCadUs() // cadastra o(s) usu rio(s)
                cQuery := "SELECT"
                cQuery += " registro,"
                cQuery += " nome,"
                cQuery += " nivel,"
                cQuery += " senha,"
                cQuery += " entrada,"
                cQuery += " saida,"
                cQuery += " bloqueio,"
                cQuery += " log,"
                cQuery += " abend "                
                cQuery += "FROM administrativo.pwusuarios"
                oQuery := oServer:Query(cQuery)
                if oQuery:NetErr()
                    oQuery:Destroy()
                    Mens({"Problema a acessar tabela de usuarios"})
                    quit
                endif
                if oQuery:lastrec() == 0
                    set color to w/n
                    cls
                    quit
                endif
            else
                close all
                set color to w/n
                cls
                quit
            endif
        endif
    endif
    // Parametro declarado, verifica o Nivel de Acesso
    if (cProc != NIL)
        // Verifica o Nivel de Acesso
        if (PWnivel = [1])
            // verificar se a rotina esta cadastrada
            cQuery := "SELECT codigo,nome FROM administrativo.pwprocessos "
            cQuery += "WHERE codigo = "+StringToSql(cProc)
            if !ExecuteSql(cQuery,@oQuery,{"Falha: pesquisar rotina"},"sqlerro")
                return(.f.)
            endif
            if oQuery:lastrec() = 0
                Mens({"Rotina "+cProc,"NÆo cadastrada","Contacte o desenvolvedor"})
                return(.f.)
            endif
             
            cQuery := "SELECT * FROM administrativo.pwacesso "
            cQuery += "WHERE registro = "+StringToSql(PwRegt)
            cQuery += " AND "
            cQuery += " rotina = "+StringToSql(cProc)
            oQuery := oServer:Query(cQuery)
            if oQuery:neterr()
                LogDeErro("pwacesso",oQuery:ErrorMsg())
                oQuery:close()
                Mens({"Falhar: Acessar PwAcesso"})
                quit
            endif
            if oQuery:lastrec() == 0
                oQuery:close()
                lReto := .f.
            endif
        endif
    else  // Parametro Nao declarado
        // Solicita Registro, permitindo ate 3 tentativas
        Window(09,23,14,56,"> Acesso ao Sistema <")
        setcolor(Cor(11))
        //           5678901234567890123
        //                3         4
        @ 11,25 say "C¢digo de Acesso:"
        @ 12,25 say " Senha de Acesso:"
        do while (nCont < 3)
            setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
            cCodi := 0
            cCursor := setcursor(IIF(READINSERT(),SC_INSERT,SC_NORMAL))
            @ 11,43 get cCodi picture [999] valid cCodi > 0
            read
            if lastkey() == K_ESC
                lReto := .f.
                exit
            endif
            cCodi := StrZero(cCodi,3,0)
            @ 11,43 say cCodi
            cQuery := "SELECT "
            cQuery += " registro,nivel,nome,log,saida,bloqueio,senha " 
            cQuery += "FROM administrativo.pwusuarios "
            cQuery += "WHERE registro = "+"'"+cCodi+"'"
            oQuery := oServer:Query(cQuery)
            if oQuery:Neterr()
                LogDeErro("pwusers",cQuery)
                oQuery:Destroy()
                quit
            endif
            if oQuery:lastrec() == 0
                Mens({"Codigo de Acesso Invalido."})
                lReto := .f.
                nCont++
            else
                lReto := .t.
                nCont := 3
                //PwRegt := cCodi
                oRegistro := oQuery:GetRow()
                PwRegt   := oRegistro:FieldGet("registro")
                PwNivel  := oRegistro:FieldGet("nivel")
                PwNome   := oRegistro:FieldGet("nome")
                if oRegistro:FieldGet('Log') == "S"
                    Mens({"O Usuario ja esta acessando o sistema","Em outra Maquiba ou Sessao."})
                    lReto := .F.
                endif
            endif
        enddo
        // Se o Registro Conferir, solicita a Senha de Acesso, permitindo
        // ate tres tentativas
        if (lReto)
            nCont := 0
            do while (nCont < 3)
                cSenha := space(10)
                do while (cSenha == space(10))
                    cSenha := GetSenha(12,43)
                enddo
                if cSenha == cripto(oRegistro:FieldGet('senha'),10,1)
                    lReto := .T.
                    nCont := 3
                    PWnivel := oRegistro:FieldGet('nivel') //PwUsers->Nivel
                else
                    Mens({"Senha Inv lida!!!"})
                    lReto := .F.
                    nCont++
                    cSenha := space(10)
                endif
            enddo
            if (lReto)
                begin sequence
                if oRegistro:FieldGet('nivel') == "0"
                    break
                endif
                if empty(oRegistro:fieldget('saida'))
                    break
                endif
                nDias := SqlToDate(oRegistro:FieldGet('saida')) - date()
                if (nDias > 1) .and. (nDias < 6)
                    Mens({"Seu Acesso Vencera em",strzero(nDias,2,0)+[ Dias!]})
                elseif (nDias = 1)
                    Mens({"Seu Acesso Vencera Amanha"})
                elseif (nDias = 0)
                    tone(900,4)
                    Mens({"Seu Acesso Vence Hoje!","Caso nao a atualize","seu Acesso Sera Bloqueado!"})
                elseif (nDias < 0)
                    if oRegistro:FieldGet('bloqueio') = [S]
                        Mens({"Seu Acesso Esta Bloqueado","Acesso Negado"})
                        lReto := .F.
                    else
                        tone(1000,1)
                        tone(800,3)
                        tone(600,2)
                        Mens({"Seu Acesso Sera Bloqueado","Apartir de Hoje"})
                        
                        cQuery := "UPDATE administrativo.pwusuarios "
                        cQuery += "SET bloqueio = 'S' "
                        cQuery += "WHERE registro = "+StringToSql(cCodi)
                        Msg(.t.)
                        Msg("Aguarde: Bloqueando acesso ao sistema")
                        oServer:StartTransaction()
                        if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
                            oServer:Rollback()
                            Msg(.f.)
                            lReto := .F.
                        endif
                        Msg(.f.)
                        oServer:Commit()
                    endif
                endif
                if (nDias < 6)
                    INKEY(0.5)
                endif
            end sequence
         endif
      endif
   endif
   RestWindow(sTela)
   return lReto
//****************************************************************************
/*
  PwChange()

  Altera a Senha do Usuario.
*/
function PwChange()
   local GetList := { },cSenha := space(10),cSen1 := space(10),cSen2 := space(10), cTela
   local cQuery,oQuery,oRegistro
   
    cQuery := "SELECT * FROM administrativo.pwusuarios"
    cQuery += " WHERE registro = "+"'"+PwRegt+"'"
    oQuery := oServer:Query(cQuery)
    if oQuery:Neterr()
        Mens({"Erro: Acessar tabela de usu rios"})
        LogDeErro("pwusers",cQuery)
        oQuery:Destroy()
        return
    endif
    oRegistro := oQuery:GetRow()
   
   cTela := SaveWindow(10,10,15,56)
   Window(10,10,14,55)
   setcolor(Cor(11))
   @ 12,12 say [Digite Sua Senha Atual:]
   setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
   cSenha := GetSenha(12,36)
   if (! empty(cSenha))
      if cSenha == Cripto(oRegistro:FieldGet("senha"),10,1)
         scroll(11,11,13,54)
         setcolor(Cor(11))
         @ 12,12 say [Digite Sua Nova Senha:]
         setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
         cSen1 := GetSenha(12,36)
         if (! EMPTY( cSen1 ) )
            scroll(11,11,13,54)
            setcolor(Cor(11))
            @ 12,12 say [Confirme Sua Nova Senha:]
            setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
            cSen2 := GetSenha(12,38)
            if (cSen1 == cSen2)
               oQuery:destroy()
               cQuery := "UPDATE administrativo.pwusuarios "+chr(K_ENTER)+chr(K_CTRL_ENTER)
               cQuery += "SET senha = "+"'"+Cripto(cSen1,10,0)+"',"+chr(K_ENTER)+chr(K_CTRL_ENTER)
               cQuery += "entrada = "+DateToSql(date())+","+chr(K_ENTER)+chr(K_CTRL_ENTER)
               cQuery += "saida = "+DateToSql(date()+30)+","
               cQuery += "bloqueio = (CASE WHEN bloqueio = 'S' THEN ' ' ELSE 'S' END) "+chr(K_ENTER)+chr(K_CTRL_ENTER)
               cQuery += "WHERE registro = "+"'"+PwRegt+"'"
               Msg(.t.)
               Msg("Aguarde: Alterando a senha")
               oQuery := oServer:Query(cQuery)
               if oQuery:neterr()
                    Msg(.f.)
                    Mens({"Erro: Alterar senha"})
                    LogDeErro("pwusers",oQuery:ErrorMsg())
                    oQuery:Destroy()
                    return
                endif
                Msg(.f.)
            else
               Mens({"Senhas Nao Conferem!","Sera mantida a anterior"})
            endif
         endif
      else
         Mens({"Senha Nao Confere!"})
      endif
   endif
   RestWindow(cTela)
   return NIL
//***************************************************************************
function PwCadUs  //  Cadastro de novos Usuarios
   local GetList := { }, cRegt, cNome, cNivel, cTela,dSaida
   local cQuery,oQuery
   private aNive := { {"0", "Pleno   " }, {"1","Restrito"}}

   if !(PwNivel == "0")
      Mens({"Acesso Negado, Seu Nivel Nao Permite"})
      return NIL
   end
   cTela := SaveWindow()
   Window(08,21,15,61,"> InclusÆo de Usu rios <")
   setcolor(Cor(11))
   //           345678901234567890
   //                  3         3
   @ 10,23 say "   C¢digo:"
   @ 11,23 say "  Usu rio:"
   @ 12,23 say "    N¡vel:"
   @ 13,23 say "Expira em:"
   do while .t.
        cRegt := space(03)
        cNome := space(25)
        cNivel := [ ]
        dSaida := ctod(space(08))
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 10,34 get cRegt picture "@k 999" ;
            when Rodape("Esc-Encerra");
            valid NoEmpty(cRegt) .and. V_Zera(@cRegt) .and.;
            SqlBusca("registro= "+"'"+cRegt+"'","Nome",@oQuery,;
                "administrativo.pwusuarios",,,,{"Usu rio j  cadastrado"},.t.)            
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        @ 11,34 get cNome picture "@!"
        @ 12,34 get cNivel picture "9" VALID MenuArray(@cNivel,aNive)
        @ 13,34 get dSaida picture "@k";
                when cNivel = "1";
                valid NoEmpty(dSaida)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            loop
        endif
        if !Confirm("Confirma a InclusÆo")
            loop
        endif
        cQuery := " INSERT INTO administrativo.pwusuarios "
        cQuery += " (registro,nome,nivel,entrada,saida,senha)"
        cQuery += "VALUES "
        cQuery += "("
        cQuery += "'"+cRegt+"',"
        cQuery += "'"+cNome+"',"
        cQuery += "'"+cNivel+"',"
        cQuery += DateToSql(date())+","
        cQuery += DateToSql(dSaida)+","
        cQuery += "'"+cripto(REPLICATE("*",10),10,0)+"'"
        cQuery += ")"
        Msg(.t.)
        Msg("Aguarde: Incluindo usu rio")
        oServer:StartTransaction()
        if !ExecuteSql(cQuery,@oQuery,{"Falha ao cadastrar usu rio"},"sqlerro")
            oQuery:close()
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        oServer:Commit()
        Msg(.f.)
   enddo
   RestWindow(cTela)
   return NIL
//**************************************************************************
function PwAltUs()   // Alteracao de Usu rios
   local GetList := { }, cRegt, cNome, cNivel, cTela
   local cQuery,oQuery,oRegistro
   private aNive := { {"0", "Pleno   " }, {"1","Restrito"}}

   if !(PwNivel == "0")
      Mens({"Acesso Negado, Seu Nivel Nao Permite"})
      return
   end
   cTela := SaveWindow()
   Window(08,21,14,58,"> Altera‡„o de Usu rios <")
   setcolor(Cor(11))
   //           34567890123456
   //                  3
   @ 10,23 say " Codigo:"
   @ 11,23 say "Usuario:"
   @ 12,23 say "  Nivel:"
   while .t.
      cRegt := space(03)
      cNome := space(25)
      cNive := [ ]
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,32 get cRegt picture "@k 999";
                when Rodape("Esc-Encerra");
                valid NoEmpty(cRegt) .and. V_Zera(@cRegt)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
        cQuery := "SELECT nome,nivel FROM administrativo.pwusuarios "
        cQuery += "WHERE registro = "+StringToSql(cRegt)
        Msg(.t.)
        Msg("Aguarde: Pesquisando o usu rio")
        if !ExecuteSql(cQuery,@oQuery,{"Falha: pesquisar usu rio"},"sqlerro")
            Msg(.f.)
            loop
        endif
        Msg(.f.)
        if oQuery:lastrec() == 0
            Mens({"Usu rio nÆo cadastrado"})
            loop
        endif
        oRegistro := oQuery:getrow()
        cNome  := oRegistro:fieldget('nome')
        cNivel := oRegistro:fieldget('Nivel')
        @ 11,32 get cNome picture "@!"
        @ 12,32 get cNivel picture "9" VALID MenuArray(@cNivel,aNive)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            loop
        endif
        if !(Confirm("Confirma a altera‡Æo"))
            oQuery:destroy()
            loop
        endif
        cQuery := "UPDATE administrativo.pwusuarios "
        cQuery += "SET nome = "+StringToSql(cNome)+","
        cQuery += "nivel = "+StringToSql(cNivel)+" "
        cQuery += "WHERE registro = "+StringToSql(cRegt)
        oServer:StartTransaction()
        Msg(.t.)
        Msg("Aguarde: Gravando as informa‡äes")
        if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar"},"sqlerro")
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        oServer:Commit()
        Msg(.f.)
        Mens({"Altera‡Æo realizada com sucesso"})
    enddo
   RestWindow(cTela)
   RETURN NIL
//***************************************************************************
function PwExcUs()   // Rotina de Exclusao de Usuarios
   local GetList := { }, cRegt, cNome, cNive, netAces := netUser := .F.
   local cTela,cQuery,oQuery

   if !(PwNivel == "0")
      Mens({"Acesso Negado, Seu Nivel Nao Permite"})
      return
   end
   cTela := SaveWindow()
   Window(08,21,14,58,"> Exclus„o de Usu rios <")
   setcolor(Cor(11))
   //           345678901234567890
   //                  3
   @ 10,23 say " C¢digo:"
   @ 11,23 say "Usu rio:"
   @ 12,23 say "  N¡vel:"
    do WHILE .T.
      cRegt := space(03)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,32 get cRegt picture "@k 999";
                when Rodape("Esc-Encerra");
                valid V_Zera(@cRegt) .and. SqlBusca("registro = "+StringToSql(cRegt),"nome,nivel",@oQuery,;
                "administrativo.pwusuarios",,,,{"Usu rio nÆo cadastrado"},.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        cNome := oQuery:fieldget('Nome')
        cNive := oQuery:fieldget('Nivel')
        @ 11,32 say cNome picture "@X"
        @ 12,32 say cNive picture "9" + IIF(cNive = [0], [ Pleno   ],[ Restrito])
        if !Confirm("Confirma a Exclusao",2)
            loop
        endif
        cQuery := "DELETE FROM administrativo.pwusuarios "
        cQuery += "WHERE registro = "+StringToSql(cRegt)
        Msg(.t.)
        Msg("Aguarde: Excluindo usu rio")
        oServer:StartTransaction()
        if !ExecuteSql(cQuery,@oQuery,{"Falha: excluir usu rio"},"sqlerro")
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        cQuery := "DELETE FROM administrativo.pwacesso "
        cQuery += "WHERE registro = "+StringToSql(cRegt)
        if !ExecuteSql(cQuery,@oQuery,{"Falha: excluir usu rio"},"sqlerro")
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        oServer:Commit()
        Mens({"Usu rio exclu¡do com sucessso"})
    enddo
    RestWindow(cTela)
    RETURN NIL
//***************************************************************************
function PwConUs()   // Rotina de Consulta de Usuarios
   local GetList := { }, oBrow, oCol, nTecla, lFim := .F.,cTela
    local cQuery,oQuery

   if !(PwNivel == "0")
      Mens({"Acesso Negado, Seu Nivel Nao Permite"})
      return
   endif
   
   
   cTela := SaveWindow()
      
    oQuery := oServer:Query("SELECT * FROM administrativo.pwusuarios")
    if oQuery:NetErr()
        LogDeErro("pwusuarios",oQuery:ErrorMsg())
        Mens({"Falha: Acessar Tabela (PwUsuarios"})
        return
    endif
   Rodape("Esc-Encerrar")
   setcolor(Cor(5))
   Window(02,00,23,79,"> Consulta de Usuarios <")
   oBrow := TBrowseDB(03,01,22,78)
   oBrow:headSep := SEPH
   oBrow:footSep := SEPB
   oBrow:colSep  := SEPV
   oBrow:colorSpec := Cor(25)
    oCurRow := oQuery:GetRow( 1 )
    oBrow:SkipBlock := {| n | oCurRow := SkipperQuery( @n, oQuery ), n }
    oBrow:GoBottomBlock := {|| oCurRow := oQuery:GetRow( oQuery:LastRec() ), 1 }
    oBrow:GoTopBlock := {|| oCurRow := oQuery:GetRow( 1 ), 1 }
   
   oBrow:addcolumn(tbcolumnnew("C¢digo"   ,{|| oQuery:FieldGet('Registro') }))
   oBrow:addcolumn(tbcolumnnew("Usu rio"  ,{|| oQuery:FieldGet('NOME') }))
   oBrow:addcolumn(tbcolumnnew("N¡vel"    ,{|| oQuery:FieldGet('Nivel') }))
   oBrow:addcolumn(tbcolumnnew("Situa‡„o" ,{|| IIF(oQuery:FieldGet('Bloqueio')=[ ],"Ativo    ","Bloqueado") }))
   oBrow:addcolumn(tbcolumnnew("Senha"    ,{|| iif(oQuery:FieldGet('Nivel') == "1",cripto(oQuery:FieldGet('senha'),10,1),iif(oQuery:FieldGet('Registro') == PwRegt,cripto(oQuery:FieldGet('senha'),10,1),replicate("*",10)))}))
   while (! lFim)
      while ( ! oBrow:stabilize() )
         nTecla := inkey()
         if ( nTecla != 0 )
            exit
         endif
      end
      aRect := {obrow:rowPos,1,obrow:rowPos,5}
      obrow:colorRect(aRect,{2,2})
      if ( oBrow:stable )
         if ( oBrow:hitTop .or. oBrow:hitBottom )
            tone(1200,1)
         endif
         nTecla := inkey(0)
      endif
      do case
         case nTecla == K_DOWN
            oBrow:down()
         case nTecla == K_UP
            oBrow:up()
         case nTecla == K_PGDN
            oBrow:pageDown()
         case nTecla == K_PGUP
            oBrow:pageUp()
         case nTecla == K_CTRL_PGUP
            oBrow:goTop()
         case nTecla == K_CTRL_PGDN
            oBrow:goBottom()
         case nTecla == K_RIGHT
            oBrow:right()
         case nTecla == K_LEFT
            oBrow:left()
         case nTecla == K_HOME
            oBrow:home()
         case nTecla == K_END
            oBrow:end()
         case nTecla == K_CTRL_LEFT
            oBrow:panLeft()
         case nTecla == K_CTRL_RIGHT
            oBrow:panRight()
         case nTecla == K_CTRL_HOME
            oBrow:panHome()
         case nTecla == K_CTRL_END
            oBrow:panEnd()
         case nTecla == K_ESC   // ESC pressionado - Encerra a Consulta
            lFim := .T.
      ENDcase
      obrow:refreshcurrent()
   end
   RestWindow(cTela)
   return NIL
//***************************************************************************
function PwLibUs()   // Liberacao de Bloqueios da Senha do Usuarios
   local GetList := { },cTela := SaveWindow()
   local cRegt, cNome, cNive,cQuery,oQuery,dSaida

   if !(PwNivel == "0")
      Mens({"Acesso Negado, Seu Nivel Nao Permite"})
      return
   end
   Window(08,21,15,61,"> Libera‡„o de Usu rios <")
   setcolor(Cor(11))
   //           34567890123456
   //                  3
   @ 10,23 say "   C¢digo:"
   @ 11,23 say "  Usu rio:"
   @ 12,23 say "    N¡vel:"
   @ 13,23 say "Expira em:"
   while .t.
      cRegt := space(03)
      cNome := space(25)
      cNive := [ ]
      dSaida := ctod(space(08))
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,34 get cRegt picture "@k 999";
            when Rodape("Esc-Encerra");
            valid NoEmpty(cRegt) .and. V_Zera(@cRegt)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
        cQuery := "SELECT nome,nivel,saida FROM administrativo.pwusuarios "
        cQuery += "WHERE registro = "+StringToSql(cRegt)
        if !ExecuteSql(cQuery,@oQuery,{"Falha: Pesquisar usu rio"},"sqlerro")
            loop
        endif
        cNome := oQuery:fieldget('nome')
        cNive := oQuery:fieldget('nivel')
        dSaida := oQuery:fieldget('saida')
        @ 11,34 say cNome picture "@X"
        @ 12,34 say cNive picture "9" + IIF(cNive = [0], [ Pleno   ],[ Restrito])
        @ 13,34 get dSaida picture "@k"
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        if !Confirm( "Confirma a Liberacao" )
            loop
        endif
        cQuery := "UPDATE administrativo.pwusuarios "
        cQuery += "SET "
        if empty(dSaida)
            cQuery += " saida = NULL,"
        else
            cQuery += "saida = "+DateToSql(dSaida)+","
        endif
        cQuery += "bloqueio = ' ' "
        cQuery += "WHERE registro = "+StringToSql(cRegt)
        oServer:StartTransaction()
        if !ExecuteSql(cQuery,@oQuery,{"Falha: Liberar usu rio"},"sqlerro")
            oServer:Rollback()
            loop
        endif
        oServer:Commit()
        Mens({"Libera‡Æo realizada com sucesso"})
    enddo
    RestWindow(cTela)
    return NIL
//***************************************************************************
function PwManAce()  // Manutencao dos Acessos ao Sistema
    local GetList := { },cRegt,nI,cTela, cScreen,cConsole
    local aCampo  := {},aTitulo := {},aMascara := {}
    local cQuery,oQuery,oRegistro,oQUsuarios,oQProcessos,oQueryAcesso 
   private aStatus := {},aRotina := {}, aCodigos := {}

   if !(PwNivel == "0")
      Mens({"Acesso Negado, Seu Nivel Nao Permite"})
      return
   end
   cScreen := SaveWindow()
   Window(08,21,14,58,"> Manuten‡„o de Acessos <")
   setcolor(Cor(11))
   //           345678901234567890
   //                  3
   @ 10,23 say " C¢digo:"
   @ 11,23 say "Usu rio:"
   @ 12,23 say "  N¡vel:"
    do while .t.
        aCodigos := {}
        cRotina  := {}
        aStatus  := {}
        cRegt    := space(03)
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 10,32 get cRegt picture "@k 999";
            when Rodape("Esc-Encerra");
            valid NoEmpty(cRegt) .and. V_Zera(@cRegt)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        cQuery := "SELECT * FROM administrativo.pwusuarios "
        cQuery += "WHERE registro = "+StringToSql(cRegt)
        if !ExecuteSql(cQuery,@oQUsuarios,{"Falha: acessar"},"sqlerro")
            loop
        endif
        @ 11,32 say oQUsuarios:FieldGet('nome') picture "@!"
        @ 12,32 say oQUsuarios:FieldGet('nivel') picture "9"
        if oQUsuarios:FieldGet('nivel') == "0"
            Mens({"Nivel Pleno...","Acesso Ilimitado"})
            loop
        endif
        cQuery := "SELECT codigo,nome FROM administrativo.pwprocessos "
        cQuery += "ORDER BY codigo "
        if !ExecuteSql(cQuery,@oQProcessos,{"Falha: acessar tabela pwprocessos"},"sqlerro")
            loop
        endif
        do while !oQProcessos:eof()
            cConteudo := oQProcessos:FieldGet(2)
            nLenField := oQProcessos:FieldLen(2)
            nLenGet := len(cConteudo)
            aadd(aRotina,cConteudo+space(nLenField-nLenGet))
            aadd(aCodigos,oQProcessos:FieldGet('codigo'))
            aadd(aStatus,space(1))
            oQProcessos:skip(1)
        enddo
        cQueryAcesso := "SELECT * FROM administrativo.pwacesso "
        cQueryAcesso += " WHERE registro = "+StringToSql(cRegt)
        if !ExecuteSql(cQueryAcesso,@oQueryAcesso,{"Falha: acessar acessos"},"sqlerro")
            loop
        endif
        if oQueryAcesso:LastRec() > 0
            do while !oQueryAcesso:eof()
                oRegAcesso := oQueryAcesso:GetRow()
                nPosicao := ascan(aCodigos,oRegAcesso:Fieldget('rotina'))
                if nPosicao > 0
                    aStatus[nPosicao] := ">"
                endif
                oQueryAcesso:skip(1)
            enddo
        endif
        oQueryAcesso:Close()
        aCampo   := { "aStatus","aRotina"}
        aTitulo  := { " ", "Rotinas" }
        aMascara := { "@k","@K" }
        cTela := SaveWindow()
        Rodape("ENTER-Marca/Desmarca | F2-Confirma | F3-Abandona | F7-Marca todos")
        Window(02,20,30,77,"> Tabela de Rotinas do Sistema <")
        do while .t.
            Edita_Vet(04,21,29,76,aCampo,aTitulo,aMascara,"fAcesso",,,2)
            if lastkey() == K_F2
                if Confirm("Confirma as Rotinas a Serem Liberadas")
                    Msg(.t.)
                    Msg("Aguarde: Gravando os dados")
                    cQueryAcesso := "DELETE FROM administrativo.pwacesso "
                    cQueryAcesso += "WHERE registro = "+"'"+cRegt+"'"
                    oQueryAcesso := oServer:Query(cQueryAcesso)
                    if oQueryAcesso:neterr()
                        Msg(.f.)
                        Mens({"Falha: Tabela PwAcesso"})
                        loop
                    endif
                    oQueryAcesso:Close()
                    for nI := 1 to len(aCodigos)
                        if aStatus[nI] == ">"
                            cQueryAcesso := "INSERT INTO administrativo.pwacesso "
                            cQueryAcesso += "VALUES "
                            cQueryAcesso += "("
                            cQueryAcesso += "'"+cRegt+"',"
                            cQueryAcesso += "'"+aCodigos[nI]+"'"
                            cQueryAcesso += ")"
                            oQueryAcesso := oServer:Query(cQueryAcesso)
                            if oQueryAcesso:neterr()
                                Msg(.f.)
                                Mens({"Falha: Gravar rotinas"})
                                exit
                            endif
                        endif
                    next
                    Msg(.f.)
                    exit
                endif
            elseif lastkey() == K_F3
                exit
            endif
        enddo
        RestWindow(cTela)
    enddo
   //RestVideo()
   RestWindow(cScreen)
   RETURN NIL
//***************************************************************************
function fAcesso( Pos_H, Pos_V, Ln, Cl, Tecla )
   local cCampo, nItens := 0,nI

    if Tecla == K_ENTER
      aStatus[Pos_V] := iif(aStatus[Pos_V] == space(01),">",space(01))
      return(3)
    
    elseif Tecla == K_F2
      return(0)
      
    elseif Tecla == K_F3
      return(0)
      
    // Marca todos
    elseif Tecla == K_F7
        for nI := 1 to len(aStatus)
            aStatus[nI] := ">"
        next
        return(3)
    endif
Return(1)
//***************************************************************************
function ClKey(cStr,cSenha,lModo) // Criptografia de Textos
local GetList := { }, cCript, nX, cAscii, cLenSenha :=LEN(TRIM(cSenha))
   if empty(cSenha)
      return .F.
   endif
   cCript := " "
   for nX := 1 to len(cStr)
      if lModo   // lModo .T. Criptografa
         cAscii := asc(substr(cStr,nX,1))+asc(substr(cSenha,(nX % cLenSenha)+1,1))
      else       // lModo .F. Decripta
         cAscii := asc(substr(cStr,nX,1))-asc(substr(cSenha,(nX % cLenSenha)+1,1))
      endif
      cCript = cCript + CHR(cAscii)
   NEXT nX
RETURN (cStr := cCript)
//***************************************************************************
function GetSenha(nLin,nCol) // Recebe a Senha do Usuario
   local GetList := { }, cSenha := [ ], nI, nChar, nCol1
   SaveVideo()

   nCol1 := nCol
   setcursor(0)
   @ nLin,nCol say replicate(chr(176),10)
   nI := 1
   while nI <= 10
      nChar := inkey(0)
      do case
         case nChar == K_BS         // Retrocesso
            if nCol1 <= nCol
               //TONE(921,3)
               LOOP
            else
               //TONE(643,4)
               nCol1--
               nI--
               cSenha := SUBSTR(cSenha,1,LEN(cSenha)-1)
               @ nLin,nCol1 say CHR(176)
               LOOP
            endif
         case nChar == K_ENTER
            exit
         case nChar == 42
            //TONE(10 * nChar, 3)
            @ nLin , nCol1 say [*]
            cSenha +=CHR(nChar)
            nCol1++ ; nI++
         case nChar >= 48 .AND. nChar <=57
            //TONE(20 * nChar, 3)
            @ nLin , nCol1 say [*]
            cSenha +=CHR(nChar)
            nCol1++ ; nI++
         case nChar >= 97 .AND. nChar <=122
            //TONE(20 * nChar, 3)
            @ nLin , nCol1 say [*]
            cSenha +=CHR(nChar)
            nCol1++ ; nI++
         case nChar >= 65 .AND. nChar <= 90
            //TONE(25 * nChar, 2)
            @ nLin , nCol1 say [*]
            cSenha +=CHR(nChar)
            nCol1++ ; nI++
         OTHERWISE
            TONE(921,3)
            LOOP
      ENDcase
   END
   cSenha := LTRIM(cSenha)
   if LEN(cSenha) < 10
      cSenha := cSenha +space(10-LEN(cSenha))
   endif
   cSenha := cSenha
   RestVideo()
RETURN cSenha

/*
  EOF------> PASSWORD.prg
*/
