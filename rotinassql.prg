/*************************************************************************
         Sistema: Administrativo
   Identifica◊'o: Modulo de Rotinas
         Prefixo: Ltadm
        Programa: ROTINAS.PRG
           Autor: Andre Lucas Souza
            Data: 16 DE NOVEMBRO DE 2002
   Copyright (C): LUCAS Tecnologia  - 2002
*/
#include "lucas.CH"       // Inclusao do Arquivo Header Padrao
#include "inkey.ch"
#include "setcurs.ch"
#include "hbgtinfo.ch"
#include "winuser.ch"
#include "fileio.ch"
#include "common.ch"
#include "Directry.ch"


function ConfiBanco
    local getlist := {},cTela := SaveWindow()
    local cQuery,oQuery,hIni
    
    
    if !file("configbanco.ini")
        cHost := space(30)
        cDataBase := space(30)
        cUser := space(30)
        cPass := space(30)
        nPort := 0
    else
        hIni := HB_ReadIni("configbanco.ini",,,.f.)
        cHost := hIni["conexao"]["Hostname"]
        cHost := cHost+space(30-len(cHost)) 
        cDataBase := hIni["conexao"]["Database"] 
        cDataBase := cDataBase+space(30-len(cDataBase))
        cUser := hIni["conexao"]["username"]
        cUser  := cUser+space(30-len(cUser)) 
        cPass := Cripto(hIni["conexao"]["password"],10,1)
        cPass := cPass+space(30-len(cPass)) 
        nPort := val(hIni["conexao"]["port"])
    endif
    Window(08,10,16,80)
    setcolor(Cor(11))
    //           23456789012345678901234567890
    //                   2         3         4
    @ 10,12 say "Nome do Banco de dados:"
    @ 11,12 say "        IP do servidor:"
    @ 12,12 say "                 Porta:"
    @ 13,12 say "               Usu†rio:"
    @ 14,12 say "                 Senha:"
    do while .t.
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 10,36 get cDataBase
        @ 11,36 get cHost
        @ 12,36 get nPort picture "@k 9999"
        @ 13,36 get cUser
        @ 14,36 get cPass
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            return(.f.)
        endif
        if !Confirm("Confirma as informaá‰es")
            loop
        endif
        hIni := Hash()
        hIni["conexao"] := Hash()
        hIni["conexao"]["Hostname"] := cHost
        hIni["conexao"]["Database"] := cDataBase
        hIni["conexao"]["username"] := cUser
        hIni["conexao"]["password"] := Cripto(cPass,10,0)
        hIni["conexao"]["port"] := alltrim(str(nPort))
        HB_WriteIni( "configbanco.ini", hIni,,,.f.)
        exit
    enddo
    RestWindow(cTela)
	return(.t.)





function AtualizarExecutavel
    local cQuery,oQuery
    local aInfoFile 
    
    cQuery := "SELECT data_executavel,hora_executavel "
    cQuery += "FROM administrativo.empresa"
    if !ExecuteSql(cQuery,@oQuery,{"Falha: tabela de empresa"},"sqlerro")
        return(.f.)
    endif
    aInfoFile := directory("ltadm.exe")
    cQuery := "UPDATE administrativo.empresa "
    cQuery += "SET data_executavel = "+DateToSql(aInfoFile[1,3])+","
    cQuery += "hora_executavel ="+StringToSql(aInfoFile[1,4])
    if !ExecuteSql(cQuery,@oQuery,{"Falha: tabela de empresa"},"sqlerro")
        return(.f.)
    endif
    return(.t.)
//*******************************************************************************
function VerificarAtualizacao
    local cQuery,oQuery    
    local aInfofile,lAtualiza := .f.
    
    cQuery := "SELECT data_executavel,hora_executavel "
    cQuery += "FROM administrativo.empresa "
    if !ExecuteSql(cQuery,@oQuery,{"Falha: verificaá∆o da atualizacao"},"sqlerro")
        return(.f.)
    endif
    if oQuery:lastrec() > 0
        aInfofile := directory("ltadm.exe")
        if aInfoFile[1,3] < oQuery:fieldget('data_executavel')
            lAtualiza := .t.
        endif     
        if oQuery:fieldget('hora_executavel') < aInfoFile[1,4]  
            lAtualiza := .t.
        endif
        if lAtualiza
            //wvw_messagebox( 0,"Existe uma atualizaá∆o do sistema,Favor saia do sistema e execute a atualizaá∆o", "ATENÄ«O" )
            Mens({"Existe uma atualizaá∆o do sistema","Favor saia do sistema e execute a atualizaá∆o"})
            return(.t.)
        endif
    endif
    return(.t.)


procedure InfoConexao2
return



function ConectarAoBancoDeDados
    local hIni //,cHost,cDataBase,cUser,cPass,nPort
    local cQuery,oQuery
    
    if !file("configbanco.ini")
        hIni := Hash()
        hIni["conexao"] := Hash()
        hIni["conexao"]["Hostname"] := "localhost"
        hIni["conexao"]["Database"] := "Ceramica"
        hIni["conexao"]["username"] := "postgres"
        hIni["conexao"]["password"] := "postgres"
        hIni["conexao"]["port"] := "5432"
        HB_WriteIni( "configbanco.ini", hIni,,,.f.)
    endif
    hIni := HB_ReadIni("configbanco.ini",,,.f.)
    cHost := hIni["conexao"]["Hostname"] 
    cDataBase := hIni["conexao"]["Database"] 
    cUser := hIni["conexao"]["username"] 
    cPass := Cripto(hIni["conexao"]["password"],10,1) //hIni["conexao"]["password"] 
    nPort := val(hIni["conexao"]["port"])
	Msg(.t.)
	Msg("Aguarde: Iniciando o Banco de Dados")
	oServer := TPQServer():New(cHost,cDataBase,cUser,cPass,nPort)
	if oServer:NetErr()
		Msg(.f.)
		Mens({"Erro ao conectar ao Banco de Dados"})
        LogDeErro("sqlerro",oServer:ErrorMsg())
        oServer:Close()
		return(.f.)
	endif
	Msg(.f.)
    lBancoConectado := .t.
	return(.t.)


function Grava_LogSql(Operacao,nRotina,nValor)
    local cTela := SaveWindow(),cQuery,oQuery
    
    
    nRotina := iif(nRotina == NIL,0,nRotina)
    nValor := iif(nValor == NIL,0,nValor)

    cQuery := "INSERT INTO administrativo.opelog "
    cQuery += "(estlog,datlog,horlog,codlog,opelog,nivlog,atilog) "    
    cQuery += " VALUES ('"
    cQuery += RetiraAcentos(alltrim(substr(netname(),1,8)))+"',"
    cQuery += DateToSql(date())+","
    cQuery += StringToSql(time())+","
    cQuery += StringToSql(PwRegt)+","
    cQuery += StringToSql(rtrim(PwNome))+","
    cQuery += StringToSql(PwNivel)+","
    cQuery += StringToSql(Operacao)
    cQuery += ")"
    if !ExecuteSql(cQuery,@oQuery,{"Erro: gravar o log"},"sqlerro")
        RestWindow(cTela)
        return(.f.)
    endif
    Return(.t.)


function DateToSql(dDate)
    
    if empty(dDate)
        return("NULL")
    endif
    return(StringToSql(strzero(year(dDate),4)+"-"+strzero(month(dDate),2)+"-"+strzero(day(dDate),2)))
//*******************************************************************************    
function SqlToDate(dDate)
    local dRetorno
    if empty(dDate)
        dRetorno := ctod(space(08))
    else
        dRetorno := ctod(strzero(day(dDate),2)+"/"+strzero(month(dDate),2)+"/"+strzero( year(dDate),4))
    endif
return(dRetorno)
//*******************************************************************************
function NumberToSql(nVal,nTam,nDec)
    local lRetorno
    
    if nTam = NIL .and. nDec = NIL
        lRetorno := StringToSql(alltrim(str(nVal)))
    else
        lRetorno := StringToSql(alltrim(str(nVal,iif(nTam = 0,0,nTam ),iif(nDec==nil, 0, nDec))))
    endif
return(lRetorno)    
//*******************************************************************************    
function StringToSql(cVar)
    return("'"+cVar+"'")
//*******************************************************************************    

*-------------------------*
function ntrim(nVal, nTam,nDec)
    return alltrim(str(nVal,iif(nTam = 0,0,nTam ),iif(nDec==nil, 0, nDec)))

function ExecuteSql(cQuery,oQuery,cMensErro,cFileErro)
    
    oQuery := oServer:Query(cQuery)
    if oQuery:neterr()
        if !(cMensErro == NIL)
            Mens(cMensErro)
        endif
        if !(cFileErro == NIL)
            LogDeErro(cFileErro,oQuery:ErrorMsg())
            LogDeErro(cFileErro+"2",cQuery)
        endif
        oQuery:Destroy()
        return(.f.)
    else
        LogDeErro(cFileErro+"2",cQuery)
    endif
    return(.t.)

procedure LogDeErro(cNameTable,cQuery)

    nHandle := FCreate(cNameTable+".log")
    FWrite( nHandle, "Error: " + cQuery )
    FClose( nHandle )
    return

function SkipperQuery( nSkip, oQuery )
   LOCAL i := 0

   DO CASE
   CASE nSkip == 0 .OR. oQuery:LastRec() == 0
      oQuery:Skip( 0 )
   CASE nSkip > 0
      DO WHILE i < nSkip           // Skip Foward
         //DAVID: change in TMySQLquery:eof() definition  if oQuery:eof()
         IF oQuery:recno() == oQuery:lastrec()
            EXIT
         ENDIF
         oQuery:Skip( 1 )
         i++
      ENDDO
   CASE nSkip < 0
      DO WHILE i > nSkip           // Skip backward
         //DAVID: change in TMySQLquery:bof() definition  if oQuery:bof()
         IF oQuery:recno() == 1
            EXIT
         ENDIF
         oQuery:Skip( -1 )
         i--
      ENDDO
   ENDCASE
   nSkip := i
   RETURN oQuery:GetRow( oQuery:RecNo() )

function ViewTableSql(oQuery, nLine1, nCol1, nLine2, nCol2, cTitulo, nPosicao2,cRetorno, aCampo, aTitulo, aMascara,lColuna)
    local cSaveTela := SaveWindow(),nset := set(_SET_CURSOR)
    local cColor := setcolor(),nTecla,cDados,oObj,nXi,cCampo
    local oCurRow

   setcursor( SC_NONE )
   setcolor(ConVertCor(Cor(5)))
   Window( nLine1, nCol1, nLine2, nCol2, cTitulo )
   oObj := TBROWSEDB(nLine1+1,nCol1+1,nLine2-iif(lColuna == NIL,1,2),nCol2-1)
    oObj:headSep := SEPH
    oObj:colSep  := SEPV
    oObj:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)
    oCurRow := oQuery:GetRow( 1 )
    oObj:SkipBlock := {| n | oCurRow := SkipperQuery( @n, oQuery ), n }
    oObj:GoBottomBlock := {|| oCurRow := oQuery:GetRow( oQuery:LastRec() ), 1 }
    oObj:GoTopBlock := {|| oCurRow := oQuery:GetRow( 1 ), 1 }
   if !( cRetorno == NIL )
      Rodape("Esc-Encerra | ENTER-Transfere")
   else
      Rodape("Esc-Encerra")
   end
   for nXi := 1 to len( aCampo )
      cCampo := "Transf( oQuery:FieldGet('" + aCampo[ nXi ] + "'), [" + aMascara[nXi] + "])"
      oObj:addcolumn( tbcolumnNew( aTitulo[nXi], &( "{||" + cCampo + "}")))
   next
   if !( lColuna == NIL)
      aTab := TabHNew(nLine2-1,nCol1+1,nCol2-1,setcolor(ConVertCor(Cor(28))),1)
      TabHDisplay(aTab)
   end
    do while .t.
        do while ( ! oObj:stabilize() )
            nTecla := inkey()
            if ( nTecla != 0 )
                exit
            endif
        enddo
        if !( nPosicao2 == NIL )
            aRect := { oObj:rowPos , 1 , oObj:rowPos , nPosicao2 }
            oObj:colorRect( aRect , { 2 , 2 } )
        endif
        if ( oObj:stable )
            if ( oObj:hitTop .or. oObj:hitBottom )
                tone(1200,1)
            endif
            nTecla := inkey(0)
        endif
        if !TBMoveCursor(nTecla,oObj)  // ** Controle de teclagens
            if nTecla == K_ESC
                exit
            elseif nTecla == K_ENTER
                if !( cRetorno == NIL )
                    // ** cDados := &cRetorno.
                    if valtype(oQuery:FieldGet(cRetorno)) == "N"
                        cDados := str(oQuery:FieldGet(cRetorno))
                      else
                        cDados := oQuery:FieldGet(cRetorno)
                      endif
                    Keyboard ( cdados ) + chr( K_ENTER )
                    exit
                endif
            elseif nTecla == K_F3
                Calc()
            endif
        endif
        if !(lColuna == NIL)
            if nTecla == K_RIGHT
                tabHupdate(aTab,oObj:colpos,oObj:colcount,.t.)
            elseif nTecla == K_LEFT
                tabHupdate(aTab,oObj:colpos,oObj:colcount,.t.)
            endif
        endif
        if !( nPosicao2 == NIL )
            oObj:refreshcurrent()
        endif
    enddo
   set(_SET_CURSOR,nset)
   RestVideo()
   setcolor( cColor )
   RestWindow( cSaveTela )
return( NIL )
   

/*
  if !Busca(Zera(@cCodCid),"Cidades",1,09,18,"Cidades->NomCid",{"Cidade Nao Cadastrada"},.f.,.f.,.f.)
  cDados
  NomeTabela
  Linha  - apresenta◊'o
  Coluna - apresentacao
  cFieldPes - Campo de pesquisa
  cFieldRet - Campo de Retorno
  aMensagem
  lTipoDePesquisa - .t.
  lLimite 
   
*/
function SqlBusca(cPesquisa,cCampo,poQuery,cNomeTabela,nLinha,nColuna,aFieldRet,aMenssagem,;
        lTipoPesquisa,nLimite,cMensagem)
    local oTabela,cQuery,oQueri,lMensagem
    
    lMensagem := iif(cMensagem = NIL,.f.,.t.)
    
    cQuery := "SELECT "
    cQuery += cCampo 
    cQuery += " FROM "
    cQuery += cNomeTabela+' '
    cQuery += " WHERE "+cPesquisa
    if !(nLimite = NIL)
        cQuery += " LIMIT "+NumberToSql(nLimite)
    endif
    if lMensagem
        Msg(.t.)
        Msg(cMensagem)
    endif
    poQuery := oServer:Query(cQuery)
    if poQuery:NetErr()
        if lMensagem
            Msg(.f.)
        endif
        Mens({"Erro na pesquisa"})
        LogDeErro('sqlerro',poQuery:ErrorMsg())
        LogDeErro('sqlerro2',cQuery)
		poQuery:Destroy()
        return(.f.)
    else
        LogDeErro('sqlerro2',cQuery)
	endif
    if lMensagem
        Msg(.f.)
    endif
    if lTipoPesquisa  // Pesquisa se ja existe
        if poQuery:LastRec() > 0
            if !(aMenssagem == NIL)
                Mens(aMenssagem)
            endif
            poQuery:Destroy()
            return(.f.)
        endif
    else              // pesquisa se n'o existe
        if poQuery:Lastrec() == 0
            if !(aMenssagem == NIL)
                Mens(aMenssagem)
            endif
		    poQuery:Destroy()
            return(.f.)
        endif
    endif
    if !(aFieldRet == NIL)
        if !(nLinha = NIL) .and. !(nColuna == NIL)
            if aFieldRet[2] == 0
                @ nLinha,nColuna say poQuery:FieldGet(aFieldRet[1])
            else
                @ nLinha,nColuna say left(poQuery:FieldGet(aFieldRet[1]),aFieldRet[2])
            endif
        endif
    endif
return(.t.)

function LerDadosEmpresa
    local cQuery,oQuery
    local lVazio
    
    cQuery := "SELECT "
    cQuery += "razao,fantasia,endereco,numero,complend,bairro,idcidade,estcid, "
    cQuery += "cidade,cep,telefone1,telefone2,email,cnpj,ie,im,cnae,crt,tipo_estoq "
    cQuery += "FROM administrativo.empresa "
    if !ExecuteSql(cQuery,@oQuery,{"Falha ao acessar tabela empresa"},"sqlerro")
        oQuery:close()
        return(.f.)
    endif  
    if oQuery:Lastrec() = 0
        lIncluir := .t.
    else
        lIncluir := .f.
    endif
	cEmpRazao    := iif(lIncluir,space(60),oQuery:fieldget('Razao'))
    cEmpFantasia := iif(lIncluir,"** EMPRESA NAO DEFINIDA **",oQuery:fieldget('Fantasia'))    
	cEmpEndereco := iif(lIncluir,space(60),oQuery:fieldget('Endereco')) 
	cEmpnumero   := iif(lIncluir,space(06),oQuery:fieldget('numero')   )
	cEmpComplend := iif(lIncluir,space(60),oQuery:Fieldget('Complend') )
	cEmpBairro   := iif(lIncluir,space(60),oQuery:fieldget('Bairro'))   
	cEmpCodcid   := iif(lIncluir,0,oQuery:fieldget('Codcid'))
    cEmpEstCid   := iif(lIncluir,space(02),oQuery:fieldget('estcid'))    
    cEmpCidade   := iif(lIncluir,space(40),oQuery:fieldget('cidade')) 
	cEmpCep      := iif(lIncluir,space(08),oQuery:fieldget('Cep'))  
	cEmpTelefone1 := iif(lIncluir,space(12),oQuery:fieldget('Telefone1'))
	cEmpTelefone2 := iif(lIncluir,space(12),oQuery:fieldget('Telefone2'))
	cEmpEmail     := iif(lIncluir,space(40),oQuery:fieldget('email'))    
	cEmpCnpj     := iif(lIncluir,space(14),oQuery:fieldget('Cnpj'))     
	cEmpIe       := iif(lIncluir,space(14),oQuery:fieldget('Ie'))       
	cEmpIm       := iif(lIncluir,space(15),oQuery:fieldget('Im'))       
	cEmpCnae     := iif(lIncluir,space(07),oQuery:fieldget('Cnae'))     
	cEmpCrt      := iif(lIncluir,space(01),oQuery:fieldget('Crt'))
    nTipoEstoque := iif(lIncluir,0,oQuery:fieldget('tipo_estoq'))
return(.t.)
    
procedure InfoConexao
    local cTela := SaveWindow(),cNomebanco,cIpServidor,nPortaConexao,cVersao,oQuery
    LOCAL oPanel1, oLabel1, oLabel2, oLabel3, oPanel2, oLabel4, oButton1, oLabel5, oLabel6, oLabel7, oLabel8, oLabel9, oLabel10
    local aInfofile
    
    local oQuery2
    local cVersao1,cVersao2
    
    cQuery := "select current_database(),inet_server_addr(),inet_server_port(),version();"
    if !ExecuteSql(cQuery,@oQuery,{"Falha ao acessar banco "},"sqlerro")
        oQuery:close()
        return
    endif
    cQuery := " (SELECT" 
	cQuery += " datname                                   AS banco,"
	cQuery += " pg_database_size(datname)                 AS tamanho,"
	cQuery += "  pg_size_pretty(pg_database_size(datname)) AS tamanho_pretty"
    cQuery += " FROM pg_database"
    cQuery += " WHERE datname NOT IN ('template0', 'template1', 'postgres')"
    cQuery += " ORDER BY tamanho DESC, banco ASC) "
    cQuery += " UNION ALL "
    cQuery += " (SELECT "
    cQuery += "   'TOTAL'                                        AS banco,"
    cQuery += "   sum(pg_database_size(datname))                 AS tamanho,"
    cQuery += "    pg_size_pretty(sum(pg_database_size(datname))) AS tamanho_pretty"
    cQuery += "       FROM pg_database "
    cQuery += "  WHERE datname NOT IN ('template0', 'template1', 'postgres')); "
    if !ExecuteSql(cQuery,@oQuery2,{"Falha ao acessar banco"},"sqlerro")
        oQuery:close()
        return
    endif
    cNomebanco    := oQuery:fieldget(oQuery:fieldname(1))
    cIpServidor   := oQuery:fieldget(oQuery:Fieldname(2))
    cIpServidor   := iif("::1" $ cIpServidor,"localhost",cIpServidor)
    nPortaConexao := oQuery:fieldget(oQuery:Fieldname(3))
    cVersao := oQuery:fieldget(oQuery:Fieldname(4))
    cVersao1 := substr(cVersao,1,at(',',cVersao))
    cVersao2 := rtrim(substr(cVersao,at(',',cVersao)+1))
    aInfofile := directory("ltadm.exe")
    
    Window(10,05,20,80," Informaá∆o do sistema ")
    setcolor(Cor(11))
    @ 12,07 say "   Banco de dados: "+cNomebanco
    @ 13,07 say "         Servidor: "+cHost
    @ 14,07 say "            Porta: "+str(nPortaConexao)
    @ 15,07 say "           Vers∆o: "+cVersao1
    @ 16,07 say "                 : "+cVersao2
    @ 17,07 say "Tamanho do banco : "+transform(oQuery2:fieldget('tamanho_pretty'),"@e 999,999,999")
    @ 18,07 say "Vers∆o do sistema: "+dtoc(aInfoFile[1,3])+'-'+aInfoFile[1,4]
    inkey(0)
    RestWindow(cTela) 

return


procedure TelaInicial
  LOCAL tApresenta,  oGroup1, oLabel2, oLabel1, oLabel3, oButton1
  STATIC Thisform
  /*
  
  #include "hwgui.ch"
  #include "common.ch"
    #ifdef __XHARBOUR__
        #include "ttable.ch"
    #endif
  
    INIT DIALOG oDlg TITLE "Form1" ;
    AT 350,182 SIZE 516,465 ;
     STYLE WS_SYSMENU+WS_SIZEBOX+WS_VISIBLE



   ACTIVATE DIALOG oDlg
   */

   return 


procedure backup
    local getlist := {},cTela :=SaveWindow()
    local cDestino,cNomeArquivo,cQuery,oQuery
    
    cDestino := cDir_Bkp
    Window(09,05,13,57)
	setcolor(Cor(11))
	//           789012345678901234567890
	//              1         2         3         4         5
	@ 11,07 say "Diret¢rio destino:"
    do while .t.
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))	
		@ 11,26 get cDestino picture "@k";
                valid Noempty(cDestino)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
            exit
		endif
        if !Confirm("Confirma a informaá∆o")
            loop
        endif
        cQuery := "UPDATE administrativo.empresa "
        cQuery += "SET "
        cQuery += "dir_Bkp = "+StringToSql(cDestino)
        Msg(.t.)
        Msg("Aguarde: Gravando a informaá∆o")
        oServer:StartTransaction()
        if !ExecuteSql(cQuery,@oQuery,{"Falha ao acessar tabela empresa"},"sqlerro")
            oQuery:close()
            oServer:Rollback()
            Msg(.f.)
            loop
        endif  
        oQuery:Close()
        oServer:Commit()
        Msg(.f.)
        cNomeArquivo := cDataBase+"_"+strzero(day(date()),2)+;
        strzero(month(date()),2)+str(year(date()),4)+"_"+;
        substr(time(),1,2)+substr(time(),4,2)+".backup" 
    
        nHandle=fcreate("backup.bat",0)
        fwrite(nHandle,"SET PGPASSWORD="+cPass+hb_osnewline())
        fwrite(nHandle,"pg_dump "+;
            " --host="+cHost+;
            " --port="+str(nPort)+;
            " --username="+cUser+;
            " --format custom"+;
            " --blobs"+;
            " --encoding=WIN1252"+;
            " --verbose"+;
            " --file="+rtrim(cDestino)+"\"+cNomeArquivo+" "+cDataBase+hb_osnewline())
        fwrite(nHandle,"exit")
        FClose( nHandle )
        cComando := "backup.bat"
        oServer:Close()
        Myrun("backup.bat")
        if !ConectarAoBancoDeDados()
            Mens({"O sistema ser† encerrado","Favor entrar novamente"})
            close all
		      setcursor(1)
		      set color to
		      cls
		      quit
	    endif
        exit
    enddo
    RestWindow(cTela)
    return

function MYRUN( cComando )
    local oShell, RET

    cComando := "start " + cComando
    oShell := CreateObject( "WScript.Shell" )
    RET := oShell:Run( "%comspec% /c " + cComando , 0, .T. )
    oShell := NIL
return iif( RET = 0, .T., .F. )
    


//** Fim do arquivo.