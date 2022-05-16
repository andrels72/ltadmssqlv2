/*************************************************************************
         Sistema: Administrativo
          Versao: 2.00
   Identificacao: Modulo de Rotinas
         Prefixo: LtSCC
        Programa: ROTINAS.PRG
           Autor: Andre Lucas Souza
            Data: 16 DE NOVEMBRO DE 2002
   Copyright (C): LUCAS Tecnologia  - 2002
*/
#include "lucas.ch"       // Inclusao do Arquivo Header Padrao
#include "inkey.ch"
#include "setcurs.ch"
#include "estoque.ch"
#include "fileio.ch"
#include "hbxml.ch"
#include "Directry.ch"


#define CRLF chr(K_ENTER)+chr(K_CTRL_ENTER)
static s_nNormalMaxrow := 34
static s_nNormalMaxcol := 135

function NumeroDeCopias(nLinha,nColuna)
    local getlist := {},cTela := SaveWindow(), nCopia := 1

    Window(nLinha,nColuna,nLinha+4,nColuna+30)
    setcolor(Cor(11))
    @ nLinha+2,nColuna+2 say "Nœmero de c½pias :"
    setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
    @ nLinha+2,nColuna+21 get nCopia picture "@k 99"
    setcursor(SC_NORMAL)
    read
    setcursor(SC_NONE)
    if lastkey() == K_ESC
        nCopia := 1
    endif
    RestWindow(cTela)
return(nCopia)


function vCidades(nCodCid,nLinha,nColuna)
    local oQCidade
    
    if !SqlBusca("codcid = "+NumberToSql(nCodCid),"nomcid,estcid",@oQCidade,;
           "administrativo.cidades",,,,{"Cidade n’o cadastrada"},.f.)
          return(.f.)
    endif
    @ nLinha,nColuna say oQCidade:fieldget('nomcid')+" "+oQCidade:fieldget('estcid')
 return(.t.)
//*****************************************************************************************************
procedure testar_1

  mens({"aqui"})
  AcbrNFe_EnviarNFe("F:\Acbrxml\xml\","28210830525936000105650010000001241377187745",0,0,1)
return
  


procedure InfoCertificado
    local cTela := SaveWindow()
	local cRetorno,dData
    
    if !OpenSequencia()
        FechaDados()
        return
    endif
	Msg(.t.)
	Msg("Aguarde: Verificando")
	AcbrNFe_CertificadoVencimento(rtrim(Sequencia->DirNFE))
	cRetorno := Mon_Ret(rtrim(Sequencia->dirNFE),"sainfe.txt",Sequencia->Tempo)
	if !Men_Ok(cRetorno)
		Msg(.f.)
		LerErro(rtrim(Sequencia->DirNFE),"sainfe.txt")
		return(.f.)
	endif
    dData := ctod(substr(cRetorno,5,10))
    AcbrNfe_Versao(rtrim(Sequencia->DirNFE))    
	cRetorno := Mon_Ret(rtrim(Sequencia->dirNFE),"sainfe.txt",Sequencia->Tempo)
	if !Men_Ok(cRetorno)
		Msg(.f.)
		LerErro(rtrim(Sequencia->DirNFE),"sainfe.txt")
		return(.f.)
	endif
    Mens({str(len(cRetorno))})
    cRetorno := rtrim(cRetorno)
    Mens({str(len(rtrim(cRetorno)))})
    FechaDados()
	Msg(.f.)
	return(.t.)
    
    
    
    RestWindow(cTela)
return



function AtualizaSaldoFisico(cCod,lInc,nQuantidade)
    local cQuery,oQuery

    cQuery := "SELECT id,Ctrles,Qteac02 FROM administrativo.produtos WHERE id = "+NumberToSql(cCod)
    Msg(.t.)
    Msg("Aguarde: Pesquisando as informa‡äes")
    if !ExecuteSql(cQuery,@oQuery,{"Falha: pesquisa"},"sqlerro")
        Msg(.f.)
        return(.f.)
    endif
    msg(.f.)
    if oQuery:fieldGet('CtrLes') = 'S'
        cQuery := "UPDATE administrativo.pedidos SET "
        if lInc
            cQuery += "qteac02 = qteac02 + "+NumberToSql(nQuantidade)
        else
            cQuery += "qteac02 = qteac02 - "+NumberToSql(nQuantidade)
        endif
        Msg(.t.)
        Msg("Aguarde: Atualizando o saldo")
        if !ExecuteSql(cQuery,@oQuery,{"Falha: pesquisa"},"sqlerro")
            Msg(.f.)
            return(.f.)
        endif
        msg(.f.)
    endif
return(.t.)
//***********************************************************************************************
function Random( nLimite )
  static nGuarda:= 1
  local I
  local nResult
  if ValType( nLimite ) # [N]
    nLimite:= 100
  endif
  I:= Seconds()
  while nLimite > I
    I:= I * 100 +Seconds()
  enddo

  nGuarda:= (nGuarda +I) / (nResult:= nGuarda * I % nLimite +1)
  nResult:= Int( nResult )
return nResult
//***********************************************************************************************
procedure teste

    Mens({"row() :"+str(wvw_maxmaxrow()+1),"col() :"+str(wvw_maxmaxcol()+1),;
    "Width :"+str(WVW_GetScreenWidth()),"Height : "+str(WVW_GetScreenHeight())})
return
//***********************************************************************************************
procedure ExportaXml
    local getlist := {},cTela := SaveWindow()
    local cAttrib,nSize,dCdate,nCTime,dMDate,nMTime
    local cMesAno,cModelo,aArquivos := {},aFiles,Contador 

    Msg(.t.)    
    Msg("Aguarde: Abrindo arquivos")
    if !OpenSequencia()
        FechaDados()
        return
    endif
    if !OpenEmpresa()
        FechaDados()
        return
    endif
    if !OpenCidades()
        FechaDados()
        return
    endif
    Msg(.f.)
    Window(08,00,14,29)
    setcolor(Cor(11))
    //           2345678901234567890
    //                   1         2
    @ 10,02 say "         Mes/Ano:"  
    @ 11,02 say "          Modelo:"
    @ 12,02 say "Letra da unidade:"
    do while .t.
        cMesAno := space(06)
        cModelo := space(02)
        cDriver := space(01)
        aArquivos := {}
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 10,20 get cMesAno picture "@kr 99/9999"
        @ 11,20 get cModelo picture "@k 99";
                valid MenuArray(@cModelo,{{"55","NF-e "},{"65","NFc-e"},{"57","CT-e "}})
        @ 12,20 get cDriver picture "@k!"
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        if !IsDisk(cDriver)
            Mens({"Unidade n'o disponivel"})
            loop
        endif
        if !Confirm("Confirma as informaÎ„es")
            loop
        endif
        Cidades->(dbsetorder(1),dbseek(Empresa->Codcid))
        aArquivos := directory(rtrim(Sequencia->dirnfe)+"\"+;
                left(Cidades->CodIbge,2)+;
                right(cMesAno,2)+left(cMesAno,2)+Empresa->Cnpj+;
                cModelo+"*.xml")
        if len(aArquivos) == 0
            Mens({"N'o existe arquivo para exportar"})
            loop
        endif
        aFiles := {}
        for nContador := 1 to len(aArquivos)
			aadd(aFiles,rtrim(Sequencia->dirnfe)+'\'+aArquivos[nContador,1])
		next
		nLen   := Len( aFiles )
		cTela2 := SaveWindow()
		Calibra(10,10,.t.,"Aguarde: Criando o Arquivo de Backup")
        if cModelo = "55"
            cArquivo := "NFE"+cMesAno
        elseif cModelo == "65"
            cArquivo := "NFCE"+cMesAno
        elseif cModelo == "57"
            cArquivo := "CTE"+cMesAno
        endif
		HB_ZIPFILE(cArquivo,;
               aFiles,;
                    9,;
              {|cFile,nPos| Calibra(10,10,.f.,,nPos,nLen)  },.t.,,.t. )
        cArquivo := alltrim(cArquivo)+".zip"
		filestats(cArquivo,@cAttrib, @nSize, @dCDate, @nCTime, @dMDate, @nMTime )
        RestWindow(cTela2)		
		Msg(.t.)
		Msg("Aguarde: Copiando o Backup")
		filecopy(cArquivo,cDriver+":\"+cArquivo)
		Msg(.f.)
    enddo
    FechaDados()
    RestWindow(cTela)
    return
//***********************************************************************************************    
function BuscarCodigo(cCodPro,lMostrarDescricao,oQuery)
    local cQuery,cCampo

    cCampo := "id, despro,fanpro,dtapro,pctcom,pctdsc,pcoven,pcoini,pcocus,pcoprz,refpro,locpro,pcobru, pcocub, "
    cCampo += "pcopro,qteac01,qteac02,pcoinv,qteiv01,qteiv02,cusmed01,cusmed02,qtere01,qtere02,embpro,"
    cCampo += "qteemb,pesliq,pesbru,icmsub,lucpro,alidtr,alifor,perred,ipipro, qtdmin,qtdmax,parmax,"
    cCampo += "tabesp,qteant,ultsai,ultent,idultfor,ultpco,ultqtd, salreq,numvendped,idfornecedor,idgrupo," 
    cCampo += "idsubgrupo,codbar,codncm, pctprz,obspro,dtaalt,pcocal,pconot,pernot,pctfre,pcosug,creicm, "
    cCampo += "ctrles,idcst,codlab,origem,ativo,estoqlote,idsimilar,natsaident,natsaifora,natentdent,"
    cCampo += "natentfora, qtdesti01,qtdesti02,cest,pis,pisaliq,cofins,cofinsaliq,idfabricante,prodbalanc"

    if IsDigit(cCodPro)
        if len(alltrim(cCodPro)) <= 6
            cCodPro := strzero(val(cCodPro),6)
            if !SqlBusca("id = "+NumberToSql(val(cCodPro)),cCampo,@oQuery,"administrativo.produtos",,,,{"Produto nÆo cadastrado"},.f.)
                return(.f.)
            endif
			cCodPro := cCodPro+space(14-len(cCodPro))
		else
            if !SqlBusca("codbar = "+StringToSql(cCodPro),cCampo,@oQuery,"administrativo.produtos",,,,{"Produto nÆo cadastrado"},.f.)
                return(.f.)
            endif
		endif
	else
		if !Busca(cCodPro,"Produtos",5,,,,{"Produto nÆo cadastrado"},.f.,.f.,.f.)
            return(.f.)
		endif
	endif
return(.t.)
//***********************************************************************************************
procedure TmpDbfs
    local aStru := {}
    

    aStru := {}
    aadd(aStru,{"CODPRO","C",006,00})
    aadd(aStru,{"DESPRO","C",050,00})
    aadd(aStru,{"ENTRADA","N",015,3})
    aadd(aStru,{"SAIDA","N",015,3})
    aadd(aStru,{"custo","n",15,2}) // pre×o de custo
    dbcreate(cDiretorio+"tmp02",aStru)
        
    aStru := {}
    aadd(aStru,{"CHAVE"       ,"C",006,00})
    aadd(aStru,{"TIPO"        ,"C",001,00})
    aadd(aStru,{"DATA"        ,"D",008,00})
    aadd(aStru,{"DOCUMENTO"   ,"C",014,00})
    aadd(aStru,{"CODVEN"      ,"C",021,00})
    aadd(aStru,{"CLIFOR"      ,"C",035,00})
    aadd(aStru,{"QTDPRO"      ,"N",015,03})
    aadd(aStru,{"PCOPRO"      ,"N",012,03})
    dbcreate(cDiretorio+"tmp03",aStru)
    
    aStru := {}
    aadd(aStru,{"CODPRO","C",006,0})
    aadd(aStru,{"DESPRO","C",050,0})
    aadd(aStru,{"EMBPRO","C",04,0})
    aadd(aStru,{"CODGRU","C",003,0})
    aadd(aStru,{"ORDEM","C",030,0})
    aadd(aStru,{"ORDEF","C",030,0})
    aadd(aStru,{"QTEAC01","N",15,3})
    aadd(aStru,{"QTEAC02","N",15,3})
    aadd(aStru,{"DATA01","D",008,0})
    aadd(aStru,{"PCONOT01","N",011,3})
    aadd(aStru,{"DATA02","D",008,0})
    aadd(aStru,{"PCONOT02","N",011,3})
    dbcreate(cDiretorio+"tmp05",aStru)
return
//***********************************************************************************************    
function ValidProduto(cCampo)
	
	if len(alltrim(cCampo)) <= 6
		cCampo := left(cCampo,6) //strzero(val(cCampo),6)
        if IsDigit(cCampo)
            if !Busca(Zera(@cCampo),"Produtos",1,,,,{"Produtos Nao Cadastrado"},.f.,.f.,.f.)
                return(.f.)
            endif
            cCampo := cCampo+space(13-len(cCampo))
        else
            cCampo := cCampo+space(13-len(cCampo))
            if !Busca(cCampo,"Produtos",5,,,,{"Produtos Nao Cadastrado"},.f.,.f.,.f.)
                return(.f.)
            endif
        endif
	else
		if !Busca(cCampo,"Produtos",5,,,,{"Produtos Nao Cadastrado"},.f.,.f.,.f.)
			return(.f.)
		endif
	endif
	return(.t.)
// *************************************************************    
procedure SaveConfig

   Msg(.t.)
   Msg("Aguarde: Salvando a Configuracao")
   save all like C_* to config.cfg
   Msg(.f.)
   Mens({"Configura× o Salva"})
return
// ****************************************************************************
function AtivaF9
   setkey( K_F9, { |pcProg,pnLine,pcVar| AtivaFisc() } )
return(NIL)
// ****************************************************************************
function DesativaF9
   setkey(K_F9,NIL)
return(NIL)
// ****************************************************************************
FUNCTION CALC_PRV(PCO_NT0,IPI00,FRTE00,CR_ICM00,MARG00,FAT00,AGREG00,nAliDtr,nPcoCal,nPcoSug)

	if Marg00 = 0.00 .and. FAT00 == 0.00
		return(.t.)
	endif
	
MPCONOT     := PCO_NT0
MCR_ICM     := CR_ICM00
MIPI        := IPI00
MFRETE      := FRTE00
CALC_DBICM  := nAliDtr
XCALC_CRICM := (MPCONOT*MCR_ICM)/100
XCALC_DBICM := (MPCONOT*CALC_DBICM)/100

SUBTOT      := MPCONOT //-(XCALC_CRICM-XCALC_DBICM)
XFRETE      := (MPCONOT*MFRETE)/100
C_IPI       := (MPCONOT*MIPI)/100
MAGREG00    := (MPCONOT*AGREG00)/100
NDBCRICM    := (MPCONOT*(CALC_DBICM-CR_ICM00))/100

TOTAL       := SUBTOT+C_IPI+XFRETE+MAGREG00+NDBCRICM
CALC_IMPFE  := C_VValPis+C_VValCof

XLIXO     := MPCONOT
XLIXO     += (MPCONOT * (CALC_DBICM-CR_ICM00))/100
XLIXO     += (XLIXO * IPI00) /100
XLIXO     += (XLIXO * FRTE00) / 100
XLIXO     += (XLIXO * CALC_IMPFE) / 100
XLIXO     += (XLIXO * MARG00) /100

//SUBTVA      := (CALC_DBICM-Cr_ICM00)+CALC_IMPFE+MARG00
SUBTVA      := CALC_IMPFE+MARG00

X_CUSNOT    := MPCONOT+((MPCONOT*FAT00)/100)
FATVDA      := 100-SUBTVA
FATVDA      := 100/FATVDA
FATCUST     := 100-X_CUSNOT
FATCUST     := 100/FATCUST
//MCUS_NOT    := FATCUST*TOTAL
MCUS_NOT    := X_CUSNOT
nPcoSug     := FATVDA*TOTAL
nPcoSug     := XLIXO //FATVDA*TOTAL
*MCUS_NOT=MCUS_NOT/MPCO_SUG+((MCUS_NOT*FAT00)/100)
nPcoCal     := MCUS_NOT
RETURN .T.
// ****************************************************************************
procedure AtivaFisc

   if lGeral
      Mens({"Funcao Desativada"})
      lGeral := .f.  // Fiscal
   else
      Mens({"Funcao Ativada"})
      lGeral := .t. // Nao Fiscal
   end
return
// ****************************************************************************
function vDataMov(dData) // Verifica se o Caixa Esta Fechado

   if MovCaixa->(dbsetorder(2),dbseek(dData))
      if MovCaixa->Fechado == "S"
         Mens({"  Movimento Fechado  "})
         return(.f.)
      end
   end
return(.t.)
// ****************************************************************************
function eCaracter(cPar)
   local nI

   for nI := 1 to len(rtrim(cPar))
      if asc(subst(cPar,nI,1)) >= 48 .and. asc(subst(cPar,nI,1)) <= 57
         return(.f.)
      end
   next
return(.t.)
// ****************************************************************************
function vDesc(nValJur,nValDes,nValDup,nLinha,nColuna)

   @ nLinha,nColuna say nValDup+nValJur-nValDes picture "@e 999,999.99"
return(.t.)
// ****************************************************************************
function VerDebitos(cCodCli)  // Verifica as duplicatas a receber do cliente
   local nValor := 0

   // ** Verifica o Limite do Cliente
   if DupRec->(dbsetorder(5),dbseek(cCodCli+dtos(ctod(space(08)))))
      while DupRec->CodCli == cCodCli .and. DupRec->(!eof())
         if empty(DupRec->DtaPag)
            nValor += DupRec->ValDup
         end
         DupRec->(dbskip())
      end
   end
return(nValor)
// ****************************************************************************
procedure View(pcProc,pnLine,pcVar)

    // Orçamentos
    if pcProc $ "ALTORCAMENTOS|EXCORCAMENTOS|IMPORCAMENTOS" .and. pcVar $ "CNUMPED"
        ConOrcamentos(.f.)
    
	elseif pcProc $ "CANBAIXAGERAL|IMPBAIXAGERAL" .and. pcVar == "CCODIGODABAIXA"
		ConBaixaGeral(.f.)

	// ** Cidades
	elseif pcProc $ "INCCIDADES|ALTCIDADES|EXCCIDADES|RELCLI3|RELCLI5|GETCLIENTES|GETFORNECEDOR|EMPRESA|"+;
        "GETCLIENTES" .and. pcVar $ "CCODCID|OCLIENTE:CCODCID|OFORNECEDOR:NIDCIDADE|CEMPCODCID|OCLIENTE:CCODCIDENTRE|"+;
        "OCLIENTE:NIDCIDADE"
        ConCidades(.f.)

	// ** Clientes
	elseif pcProc $ "INCCLIENTE|ALTCLIENTE|EXCCLIENTE|INCPEDIDOS|ALTPEDIDOS|"+;
                    "BXADUPREC|RELCHEQ2|INCCHEQUES|ALTCHEQUES|RELCHEQ1|"+;
                    "INCDUPREC|RELPED2|RELREC1|RELREC3|INCORCAMEN|INCNOTASAI|"+;
                    "RELSAID2|INCNOTASAV|INCNOTANFE|GETCLIENTES|INCNFE|INCNFCE|"+;
                    "INCORCAMENTOS|ALTORCAMENTOS|INCNFEENTRADA";
                     .and. pcVar $ "CCODCLI|OCLIENTE:CCOD"
      ConCliente(.f.)


    // ** Produtos - Consulta de todos os produtos com saldo fiscal
    elseif pcProc $ "NFCEITEM|NFEITEM" .and. pcVar $ "CCAMPO"
        ConProdutoSaldoF(.f.,.t.) 
        
    // Produtos - consulta produtos com saldos fisicos
    elseif pcProc $ "VPEDIDO|INCTRANSFPROD|ALTTRANSFPROD" .and. pcVar $ "CCODIGO|CCODPRODS|CCODPRODE"
        ConProdutoSaldo(.f.,.t.)
    
        
	// ** Produtos - Consulta de todos os produtos com o sem saldo      
   elseif pcProc $ "ALTPRODUTO|RELPROD3|CMP_ITE|VORCAMEN|LANCESTOQINICIAL|INCLUIPRODUTO|"+;
        "VRELAPRODUTOS|INCPRODFOR|ALTPRODFOR|ALTERARPRECO|NFEITEM|TELAPRODXMLSEM|NFEDEVITEM|"+;
        "VORCAMENTOS|NFEITEMENTRADA" .and. ;
        pcVar $ "CCODPRO|CCODIGO|CCAMPO|OPRODUTOS:CCODPRO"
        ConProduto(.f.)
      
   // ** Fornecedores
   elseif pcProc $ "GETFORNECEDOR|ALTFORNECEDOR|EXCFORNECEDOR|INCDUPPAG|INCDUPPAG|ALTDUPPAG|BXADUPPAG|"+;
		"RELPAG1|RELPAG3|INCPRODUTO|ALTPRODUTO|INCCOMPRA|RELPROD1|RELPROD2|RELPROD4|RELCOMP3|RELPROD5|"+;
		"RELPROD6|RELPROD7|RELPROD8|GETPRODUTOS|INCPRODFOR|ALTPRODFOR|EXCPRODFOR|CONPRODFOR|INCNFEDEV" .and.;
		pcVar $ "CCODFOR|OFORNECEDOR:CCODFOR|OPRODUTOS:CCODFOR"
        ConFornecedor(.f.)

   // ** Planos de Pagamento
   elseif pcProc $ "INCPLANO|ALTPLANO|EXCPLANO|INCVINCPRE|ALTVINCPRE|INCPEDIDOS|ALTPEDIDOS|RELPED4|VPAR_ITE|"+;
		"GETPEDIDO" .and. pcVar $ "CCODPLA|CCODPLA"
        ConPlano(.f.)

   // ** Vendedores
   elseif pcProc $ "INCVENDEDOR|ALTVENDEDOR|EXCVENDEDOR|INCPEDIDOS|ALTPEDIDOS|RELPED3|"+;
        "INCORCAMEN|GETCLIENTES|RELCLI4|RELCOMI1|RELCLI5|INCORCAMENTOS|ALTORCAMENTOS" .and. pcVar $ "CCODIGO|CCODVEN|OCLIENTE:CCODVEN"
        ConVendedor(.f.)

	// ** Bancos
	elseif pcProc $ "INCBANCOS|ALTBANCOS|EXCBANCOS|INCMOVBAN|ALTMOVBAN|RELBAN3|INCCHEQUES|CALCBAN" .and. pcVar == "CCODBCO"
        ConBancos(.f.)
      
	// ** Caixa
	elseif pcproc $ "INCCAIXA|ALTCAIXA|EXCCAIXA|GETMOVCXA|RELCXA4|RELCXA5|CALCSALDO|CONMOVCXA|INCCXAAUTO|CONFLANCCX|CONFLANCPE|CONFLANCRX|CONFLANCAX" .and. pcVar $ "CCODCAIXA|CCODCXA|CCCODCXA|CPCODCXA|CRCODCXA|CACODCXA"
        View_Caixa(.t.)

   // ** Historicos do Caixa
   elseif pcproc $ "INCHISTCXA|ALTHISTCXA|EXCHISTCXA|GETMOVCXA|RELCXA4|RELCXA5|CONFLANCCX|CONFLANCPE|CONFLANCRX|CONFLANCAX" .and. pcvar $ "CCODHIST|CCCODHIS|CPCODHIS|CRCODHIS|CACODHIS"
        ConHistBan(.t.)

   // ** Formas de Pagamento (Caixa)
   elseif pcProc $ "INCFPAGCXA|ALTFPAGCXA|EXCFPAGCXA|GETMOVCXA|RELCXA4" .and. pcvar == "CCODPAGTO"
        ViewFPag(.t.)

   // ** Movimento do Caixa
   elseif pcProc $ "INCMOVCXA|ALTMOVCXA|EXCMOVCXA" .and. pcvar == "CLANC"
        ConMovCxa(.f.)

   // ** Historico Banc rio
   elseif pcProc $ "INCHISTBAN|ALTHISTBAN|EXCHISTBAN|INCMOVBAN|ALTMOVBAN|RELBAN3" .and. pcVar == "CCODHIS"
        ConHistBan(.t.)

   // ** Estados
   elseif pcProc $ "INCCIDADES|ALTCIDADES|RELCIDA|INCESTADOS|ALTESTADOS|EXCESTADOS|GETCIDADES" .and.;
   		pcVar $ "CESTCID|CCODEST"
      ViewEstado(.t.)

   elseif pcProc $ "ALTCHEQUES|EXCCHEQUES|BXACHEQUES|CXACHEQUES|TBNEGOCIA" .and. pcVar $ "CLANCHE|CCAMPO"
      ConCheques(.f.)

   elseif pcProc $ "INCTRANSPO|ALTTRANSPO|EXCTRANSPO|GETENTREGA|INCENTREGA|PEGA2" .and. pcVar $ "CCODTRA"
      ViewTransp(.t.)

   elseif pcProc $ "INCMOVBAN|ALTMOVBAN|EXCMOVBAN" .and. pcVar == "CNUMDOC"
      ConMovBan(.f.)

   elseif pcProc == "IMPRCHQ" .and. pcVar == "CRECIBO"
      xCheques()

   // ** Grupos de Produtos
	elseif pcProc $ "INCGRUPO|ALTGRUPO|EXCGRUPO|INCPRODUTO|ALTPRODUTO|RELPROD1|RELPROD2|RELPROD4|RELPROD5|"+;
			"RELPROD7|RELPROD8|GETPRODUTOS" .and. pcVar $ "CCODGRU|OPRODUTOS:CCODGRU|NCODGRU|NID"
      ConGrupo(.f.)

   // ** Situacao Tributaria
   elseif pcProc $ "INCSITTRIB|ALTSITTRIB|EXCSITTRIB|INCPRODUTO|ALTPRODUTO"+;
        "|GETPRODUTOS|TELAPRODXML" .and.;
		pcVar $ "CCODFIS|OPRODUTOS:CCST|CCST"
      ViewSitTri(.f.)

   // ** Naturezas Fiscais
   elseif pcProc $ "ALTNATUREZA|EXCNATUREZA|INCNOTAEC|INCCOMPRA|INCNOTASAI|GETCLIENTES|GETCOMPRA|GETPRODUTOS|"+;
        "INCNFCE|PARAMETRONFCE|IMPORTAPRODXML|TELAPRODXML|INCNFEDEV|INCNFEENTRADA" .and.;
           pcVar $ "CCODNAT|OCLIENTE:NIDNATUREZA|OPRODUTOS:CNATSAIDENT|OPRODUTOS:CNATSAIFORA|"+;
   				"OPRODUTOS:CNATENTDENT|OPRODUTOS:CNATENTFORA|CCODNATNFCE|CNAT|CNATFORA|NID"
        ConNatureza(.f.)

   // ** Local de Impressao
   elseif pcProc $ "INCLOCIMP|ALTLOCIMP|EXCLOCIMP" .and. pcVar == "CCODIMP"
      ViewLocImp(.t.)

   // ** Impressoras
   elseif pcProc $ "INCIMPRESS|ALTIMPRESS" .and. pcVar == "CINOMIMP"
      ViewImpres(.t.)

   // ** Sub-Grupo de Produtos
   elseif pcProc $ "GETPRODUTOS|ALTSUBGRUPO|EXCSUBGRUPO" .and. pcVar $ "OPRODUTOS:CSUBGRU|NID"
      ConSubGrupo(.f.)

   elseif pcProc $ "ALTCOMPRA|EXCCOMPRA" .and. pcVar $ "CLANCEN|CLANC"
      ConCompra(.f.)

   elseif pcProc $ "ALTDUPREC|EXCDUPREC" .and. pcVar == "CCODCLI"
      ConDupRec(.f.,.t.)

   elseif pcProc $ "INCNEGOCIAD|ALTNEGOCIAD|EXCNEGOCIAD|INCNEGOCI|RELCHEQ4" .and. pcVar $ "CCODIGO|CCODNEG"
      ViewNegoci(.t.)
      
    // ** Pedidos
    elseif pcProc $ "ALTPEDIDOS|EXCPEDIDOS|IMPPEDIDOS|IMPCUPOMNAOFISCAL|IMPPEDIDOS" .and. pcVar $ "CNUMPED"
        ConPedidos(.f.)
      
	elseif pcProc $ "CARTACORRECAO" .and. pcVar $ "CNRNFE"
		ConNotaNFE(.f.,.f.)
		
	// ** Unidade de Medida - Produtos
    elseif pcProc $ "ALTUNIDMED|GETPRODUTOS|INCNCM|ALTNCM|TELAPRODXML" .and.;
        pcVar $ "OPRODUTOS:CEMBPRO|CUNIDADE|CEMBPRO|CCODMED"
        ConUnidMed(.f.)
		
	// ** Grupo de clientes
	elseif pcProc $ "GETCLIENTES" .and. pcVar $ "OCLIENTE:NIDGRUPOCLI"
		ConGrupoCliente(.f.)
		
	// ** 
	elseif pcProc $ "INCCFOP|ALTCFOP|EXCCFOP|GETNATUREZA|INCLUIPRODUTO|ALTERAPRODUTO|"+;
        "TELAGET" .and. pcVar $ "CCFOP|CCFOP2"
		ConCFOP(.f.)
		
	// ** NCM
	elseif pcProc $ "INCNCM|ALTNCM|EXCNCM|GETPRODUTOS" .and. pcVar $ "OPRODUTOS:CCODNCM|CCODNCM"
		ConNCM(.f.)
        
    // NFCe
    elseif pcProc $ "ALTNFCE|EXCNFCE|TRANNFCE" .and. pcVar == "CNUMCON"
        ConNfce(.f.)
	
   endif
return
// ****************************************************************************
procedure InstSenha()

   local aRotinas := {}
   
aadd(aRotinas,{"10000","Cadastros"})                                         
aadd(aRotinas,{"11000","  Clientes"})                                         
aadd(aRotinas,{"11100","    Clientes"})                                        
aadd(aRotinas,{"11101","      Incluir"})                                        
aadd(aRotinas,{"11102","      Alterar"})                                        
aadd(aRotinas,{"11103","      Excluir"})                                        
aadd(aRotinas,{"11104","      Consultar"})                                      
aadd(aRotinas,{"11200","    Grupos"})                                          
aadd(aRotinas,{"11201","      Incluir"})                                        
aadd(aRotinas,{"11202","      Alterar"})                                        
aadd(aRotinas,{"11203","      Excluir"})                                        
aadd(aRotinas,{"11204","      Consultar"})
aadd(aRotinas,{"12000","  Fornecedores"})                                     
aadd(aRotinas,{"12001","    Incluir"})                                         
aadd(aRotinas,{"12002","    Alterar"})                                         
aadd(aRotinas,{"12003","    Excluir"})                                         
aadd(aRotinas,{"12004","    Consultar"}) 
aadd(aRotinas,{"13000","  Produtos"})                                         
aadd(aRotinas,{"13100","    Produtos"})                                        
aadd(aRotinas,{"13101","      Incluir"})                                        
aadd(aRotinas,{"13102","      Alterar"})                                        
aadd(aRotinas,{"13103","      Excluir"})                                        
aadd(aRotinas,{"13104","      Consulta geral"})                                 
aadd(aRotinas,{"13105","      Consulta com saldo"})                             
aadd(aRotinas,{"13106","      Estoque inicial"})                                
aadd(aRotinas,{"13107","      Reorganizar saldos"})                             
aadd(aRotinas,{"13108","      Alterar NCM"})                                    
aadd(aRotinas,{"13109","      Alterar precos"})                                 
aadd(aRotinas,{"13110"  ,"      Imprimir Etiquetas"})
aadd(aRotinas,{"13200"  ,"    Grupos"})                                          
aadd(aRotinas,{"13201"  ,"      Incluir"})                                        
aadd(aRotinas,{"13202"  ,"      Alterar"})                                        
aadd(aRotinas,{"13203"  ,"      Excluir"})                                        
aadd(aRotinas,{"13204"  ,"      Consultar"})
aadd(aRotinas,{"13300"  ,"    Sub-grupos"})                                      
aadd(aRotinas,{"13301"  ,"      Incluir"})                                        
aadd(aRotinas,{"13302"  ,"      Alterar"})                                        
aadd(aRotinas,{"13303"  ,"      Excluir"})                                        
aadd(aRotinas,{"13304"  ,"      Consultar"})
aadd(aRotinas,{"13400"  ,"    Fabricantes"})                                     
aadd(aRotinas,{"13401"  ,"      Incluir"})                                        
aadd(aRotinas,{"13402"  ,"      Alterar"})                                        
aadd(aRotinas,{"13403"  ,"      Excluir"})                                        
aadd(aRotinas,{"13404"  ,"      Consultar"})
aadd(aRotinas,{"13500"  ,"    Unidade de medida"})                               
aadd(aRotinas,{"13501"  ,"      Incluir"})                                        
aadd(aRotinas,{"13502"  ,"      Alterar"})                                        
aadd(aRotinas,{"13503"  ,"      Excluir"})                                        
aadd(aRotinas,{"13504"  ,"      Consultar"})
aadd(aRotinas,{"13600"  ,"    Produtos do fornecedor"})                          
aadd(aRotinas,{"13601"  ,"      Incluir"})                                        
aadd(aRotinas,{"13602"  ,"      Alterar"})                                        
aadd(aRotinas,{"13603"  ,"      Excluir"})                                        
aadd(aRotinas,{"13604"  ,"      Consultar"}) 
aadd(aRotinas,{"13700"  ,"    Importar XML"})                                    
aadd(aRotinas,{"13701"  ,"      Importar XML"})                                   
aadd(aRotinas,{"13702"  ,"      Atualizar dados"})                                
aadd(aRotinas,{"13703"  ,"      Excluir XML importado"})                          
aadd(aRotinas,{"13704"  ,"      Consultar XML"}) 
aadd(aRotinas,{"14000"  ," Cadastros/Financeiro"})                                       
aadd(aRotinas,{"14100"  ,"   Duplicatas"})                                      
aadd(aRotinas,{"14101"  ,"     A receber"})                                      
aadd(aRotinas,{"141011" ,"       Incluir"})                                       
aadd(aRotinas,{"141012" ,"       Alterar"})                                       
aadd(aRotinas,{"141013" ,"       Excluir"})                                       
aadd(aRotinas,{"141014" ,"       Consultar"})                                     
aadd(aRotinas,{"141015" ,"       Imprimir"})                                      
aadd(aRotinas,{"141016" ,"       Imprimir carne"})                                
aadd(aRotinas,{"141017" ,"       Baixa individual"})                              
aadd(aRotinas,{"1410171","         Baixar"})                                       
aadd(aRotinas,{"1410172","         Cancelar baixa"})                               
aadd(aRotinas,{"141018" ,"       Baixa selecionada"})                             
aadd(aRotinas,{"1410181","         Baixar"})                                       
aadd(aRotinas,{"1410182","         Imprimir recibo"})                              
aadd(aRotinas,{"1410183","         Consultar"})                                    
aadd(aRotinas,{"1410184","         Cancelar baixa"})                               
aadd(aRotinas,{"141019" ,"         Conf. lancamento no caixa"})
aadd(aRotinas,{"14102"  ,"     A pagar"})
aadd(aRotinas,{"141021" ,"       Incluir"})
aadd(aRotinas,{"141022" ,"       Alterar"})
aadd(aRotinas,{"141023" ,"       Excluir"})
aadd(aRotinas,{"141024" ,"       Consultar"})
aadd(aRotinas,{"141025" ,"       Baixar"})
aadd(aRotinas,{"141026" ,"         Cancelar baixa"})
aadd(aRotinas,{"141027" ,"         Conf. Lanc. no caixa"})
aadd(aRotinas,{"141028" ,"       Importar XML"})
aadd(aRotinas,{"14200"  ,"   Caixa"})
aadd(aRotinas,{"14210"  ,"     Caixa"})
aadd(aRotinas,{"14211"  ,"       Incluir"})
aadd(aRotinas,{"14212"  ,"       Alterar"})
aadd(aRotinas,{"14213"  ,"       Excluir"})
aadd(aRotinas,{"14214"  ,"       Consultar"})
aadd(aRotinas,{"14220"  ,"     Historico padrao"})
aadd(aRotinas,{"14221"  ,"       Incluir"})
aadd(aRotinas,{"14222"  ,"       Alterar"})
aadd(aRotinas,{"14223"  ,"       Excluir"})
aadd(aRotinas,{"14224"  ,"       Consultar"})
aadd(aRotinas,{"14230"  ,"     Formas de pagamento"})
aadd(aRotinas,{"14231"  ,"       Incluir"})
aadd(aRotinas,{"14232"  ,"       Alterar"})
aadd(aRotinas,{"14233"  ,"       Excluir"})
aadd(aRotinas,{"14234"  ,"       Consultar"})
aadd(aRotinas,{"14240"  ,"     Movimento"})
aadd(aRotinas,{"14241"  ,"       Incluir"})
aadd(aRotinas,{"14242"  ,"       Alterar"})
aadd(aRotinas,{"14243"  ,"       Excluir"})
aadd(aRotinas,{"14244"  ,"       Consultar"})
aadd(aRotinas,{"14245"  ,"       Recalcula saldo"})
aadd(aRotinas,{"14246"  ,"       Fechar movimento"})
aadd(aRotinas,{"14247"  ,"       Abrir movimento"})
aadd(aRotinas,{"14300"  ,"   Bancos"})
aadd(aRotinas,{"14310"  ,"     Bancos"})
aadd(aRotinas,{"143101" ,"       Incluir"})
aadd(aRotinas,{"143102" ,"       Alterar"})
aadd(aRotinas,{"143103" ,"       Excluir"})
aadd(aRotinas,{"143104" ,"       Consultar"})
aadd(aRotinas,{"14320"  ,"     Historico bancario"})
aadd(aRotinas,{"14321"  ,"       Incluir"})
aadd(aRotinas,{"14322"  ,"       Alterar"})
aadd(aRotinas,{"14323"  ,"       Excluir"})
aadd(aRotinas,{"14324"  ,"       Consultar"})
aadd(aRotinas,{"14330"  ,"     Movimento"})
aadd(aRotinas,{"14331"  ,"       Incluir"})
aadd(aRotinas,{"14332"  ,"       Alterar"})
aadd(aRotinas,{"14333"  ,"       Excluir"})
aadd(aRotinas,{"14334"  ,"       Consultar"})
aadd(aRotinas,{"14340"  ,"       Recalcular saldo"})
aadd(aRotinas,{"14400"  ,"   Cheques"})
aadd(aRotinas,{"14410"  ,"     Cheques"})
aadd(aRotinas,{"14411"  ,"       Incluir"})
aadd(aRotinas,{"14412"  ,"       Alterar"})
aadd(aRotinas,{"14413"  ,"       Excluir"})
aadd(aRotinas,{"14414"  ,"       Consultar"})
aadd(aRotinas,{"14415"  ,"       Baixar"})
aadd(aRotinas,{"14416"  ,"       Cancelar baixa"})
aadd(aRotinas,{"14417"  ,"       Imprimir recibo"})
aadd(aRotinas,{"14420"  ,"     Negociador"})
aadd(aRotinas,{"14421"  ,"       Incluir"})
aadd(aRotinas,{"14422"  ,"       Alterar"})
aadd(aRotinas,{"14423"  ,"       Excluir"})
aadd(aRotinas,{"14424"  ,"       Consultar"})
aadd(aRotinas,{"15100"  ," Cadastros/Entradas"})
aadd(aRotinas,{"15101"  ,"   Incluir"})
aadd(aRotinas,{"15102"  ,"   Alterar"})
aadd(aRotinas,{"15103"  ,"   Excluir"})
aadd(aRotinas,{"15104"  ,"   Consultar"})
aadd(aRotinas,{"16100"  ," Cadastros/Propostas"})
aadd(aRotinas,{"16101"  ,"   Incluir"})
aadd(aRotinas,{"16102"  ,"   Alterar"})
aadd(aRotinas,{"16103"  ,"   Excluir"})
aadd(aRotinas,{"16104"  ,"   Consultar"})
aadd(aRotinas,{"16105"  ,"   Imprimir"})


aadd(aRotinas,{"17100"  ," Cadastros/Propostas"})
aadd(aRotinas,{"17101"  ,"   Incluir"})
aadd(aRotinas,{"17102"  ,"   Alterar"})
aadd(aRotinas,{"17103"  ,"   Excluir"})
aadd(aRotinas,{"17104"  ,"   Consultar"})
aadd(aRotinas,{"17105"  ,"   Imprimir"})



aadd(aRotinas,{"18000"  ," Nota fiscal"})
aadd(aRotinas,{"18100"  ,"   Venda"})
aadd(aRotinas,{"18110"  ,"     Incluir"})
aadd(aRotinas,{"18120"  ,"     Alterar"})
aadd(aRotinas,{"18130"  ,"     Excluir"})
aadd(aRotinas,{"18140"  ,"     Consultar"})
aadd(aRotinas,{"18150"  ,"     Transmitir"})
aadd(aRotinas,{"18160"  ,"     Cancelar"})
aadd(aRotinas,{"18170"  ,"     Imprimir DANFE"})
aadd(aRotinas,{"18180"  ,"     Consultar na SEFAZ"})
aadd(aRotinas,{"18190"  ,"     Inutilizar NFE"})
aadd(aRotinas,{"181A0"  ,"     Consultar NFE inutilizada"})
aadd(aRotinas,{"181B0"  ,"     Carta de Correcao"})

aadd(aRotinas,{"19000"  ," Vendedores"})
aadd(aRotinas,{"19101"  ,"   Incluir"})
aadd(aRotinas,{"19102"  ,"   Alterar"})
aadd(aRotinas,{"19103"  ,"   Excluir"})
aadd(aRotinas,{"19104"  ,"   Consultar"})
//******************************************************************************
// Relatorios
//******************************************************************************
aadd(aRotinas,{"20000","Relatorios"})                 
aadd(aRotinas,{"21000","  Clientes "})
aadd(aRotinas,{"21100","    Cadastro"})
aadd(aRotinas,{"21200","    Telefones"})
aadd(aRotinas,{"21300","    Por cidade"})
aadd(aRotinas,{"21400","    Por vendedor"})
aadd(aRotinas,{"21400","    Ranking"})

aadd(aRotinas,{"22000","  Fornecedores"})
aadd(aRotinas,{"22100","    Cadastro"})
aadd(aRotinas,{"22200","    Telefones"})

aadd(aRotinas,{"23000","  Grupos"})

aadd(aRotinas,{"24000","  Produtos"})
aadd(aRotinas,{"24100","    Tabela de preços"})
aadd(aRotinas,{"24200","    Estoque Inicial"})
aadd(aRotinas,{"24300","    Conferenca do Estoque"})
aadd(aRotinas,{"24400","    Ficha do produto"})
aadd(aRotinas,{"24500","    Curva ABC"})
aadd(aRotinas,{"24600","    Inventario"})
aadd(aRotinas,{"24700","    Entrada/Saida"})
aadd(aRotinas,{"24800","    Saldos (estoque)"})
aadd(aRotinas,{"24900","    Produtos (Custo/venda)"})
aadd(aRotinas,{"24A00","    Produtos sem NCM"})
aadd(aRotinas,{"24B00","    Produtos NCM/CEST/CFOP/CST"})

aadd(aRotinas,{"25000","  Financeiro"})
aadd(aRotinas,{"25100","    Duplicatas"})
aadd(aRotinas,{"25110","      A receber"})
aadd(aRotinas,{"25111","        No Periodo por cliente"})
aadd(aRotinas,{"25112","        No Periodo por dia"})
aadd(aRotinas,{"25113","        Extrato do cliente"})

aadd(aRotinas,{"25120","      A pagar"})
aadd(aRotinas,{"25121","        No periodo por fornecedor"})
aadd(aRotinas,{"25122","        No Periodo por dia"})
aadd(aRotinas,{"25123","        Extrato do fornecedor"})


aadd(aRotinas,{"25200","    Caixa"})
aadd(aRotinas,{"25210","      Relatorio dos caixa"})
aadd(aRotinas,{"25220","      Relatorio dos historico padrao"})
aadd(aRotinas,{"25230","      Formas de pagamento"})
aadd(aRotinas,{"25240","      Conferencia do movimento do caixa"})
aadd(aRotinas,{"25250","      Resumo do movimento do caixa"})

aadd(aRotinas,{"25300","    Bancos"})
aadd(aRotinas,{"25310","      Bancos"})
aadd(aRotinas,{"25320","      Historico bancario"})
aadd(aRotinas,{"25330","      Movimento"})


aadd(aRotinas,{"25400","    Cheques"})
aadd(aRotinas,{"25500","    Comissão dos vendedores"})
aadd(aRotinas,{"25600","    Lucro presumido de vendas"})


aadd(aRotinas,{"26000","  Entrada"})
aadd(aRotinas,{"27000","  Saida"})
aadd(aRotinas,{"28000","  Cidades"})
aadd(aRotinas,{"29000","  Natureza fiscal"})
aadd(aRotinas,{"2A000","  Atividade do usuario"})









                       
aadd(aRotinas,{"30000"," Utilitarios"})
aadd(aRotinas,{"31000","  Plano de Senhas"})
aadd(aRotinas,{"32000","  Indexar arquivos"})
aadd(aRotinas,{"33000","  Compactar arquivos"})
aadd(aRotinas,{"34000","  Copia de seguraça"})

   PwInstall(aRotinas)
   return
   
procedure ConfiguraAmbiente2
    local nLargura,nTamanho

    //wvw_size_ready(.T.)
    wvw_setmaincoord(.T.)
    //wvw_SetPaintRefresh(0)
    
    wvw_NoClose()

    nTamanho := WVW_GetScreenWidth() // L^ o tamanho em pixel
    nLargura := WVW_GetScreenHeight() // L^ o largura em pixel
    /* 
    if wvw_GetScreenWidth() == 1024
     
        if WVW_GetScreenHeight() == 768
            WVW_SetFont(,'Ms Sans Serif', 16, 8 )
        endif
        
    elseif WVW_GetScreenWidth() == 1366
        if WVW_GetScreenHeight() == 768
            wvw_SetFont(,'Courier New',29,15)
        endif
	else
		wvw_SetFont(,'Courier New' , 20, 10, 400) //, DEFAULT_QUALITY )
	endif
    */
    ? "aqui"
    inkey(0)
    if wvw_GetScreenWidth() > 1024
        lFonte := wvw_SetFont(,'Courier New')
        
    elseif wvw_GetScreenWidth() >= 1024
        wvw_SetFont(,"Lucida Console",28,12,400)
    elseif wvw_GetScreenWidth() >= 800
        wvw_SetFont(,"Lucida Console",20,09,400)
    endif
    
    
        
	aLixo := WVW_GetFontInfo()
	? aLixo[1], " cFontFace Nome da fonte ( por ex. Arial )."
	? alixo[2], " cFontHeight Altura da fonte. "
	? alixo[3], " nFontWidth Largura da fonte."
	? alixo[4], " nFontWieght Peso da fonte."
	? alixo[5], " cFontQuality Qualidade da fonte."
	? alixo[6], " PTEXTSIZE->x Largura da fonte em pixels."
	? alixo[7],"  PTEXESIZE->y Tamanho da fonte em pixels"
	? wvw_maxmaxrow() , "linha"
	? wvw_maxmaxcol() , "coluna"
    ? nTamanho
    ? nLargura
    ? lFonte," mudou a fonte"
	inkey(0)
	WVW_SetCodePage(,255)
	wvw_settitle( , "LTADM - Sistema Administrativo" )
    setmode(wvw_maxmaxrow()+1,wvw_maxmaxcol()+1)
    
   return

procedure ConfiguraAmbiente
    local nLargura,nTamanho

    wvw_size_ready(.T.)
    wvw_setmaincoord(.T.)
    //wvw_SetPaintRefresh(0)
    
    //wvw_NoClose()

    nTamanho := WVW_GetScreenWidth() // L^ o tamanho em pixel
    nLargura := WVW_GetScreenHeight() // L^ o largura em pixel
    //Mens({"aqqui"})
  if nTamanho == 1024 
    if nLargura == 768
      Wvw_SetFont(,"Lucida Console",29,06)
      //Wvw_SetFont(,"Lucida Console",22,0,400,1)
    endif
  else
		wvw_SetFont(,'Courier New' , 20, 10, 400) //, DEFAULT_QUALITY )
	endif
    /*
	aLixo := WVW_GetFontInfo()
	? aLixo[1], " cFontFace Nome da fonte ( por ex. Arial )."
	? alixo[2], " cFontHeight Altura da fonte. "
	? alixo[3], " nFontWidth Largura da fonte."
	? alixo[4], " nFontWieght "Peso" da fonte."
	? alixo[5], " cFontQuality Qualidade da fonte."
	? alixo[6], " PTEXTSIZE->x Largura da fonte em pixels."
	? alixo[7],"  PTEXESIZE->y Tamanho da fonte em pixels"
	? maxrow() , "linha"
	? maxcol() , "coluna"
    ? nTamanho
    ? nLargura
	inkey(0)
    */
    /*
    setmode(s_nNormalMaxrow,s_nNormalMaxcol)
    do case
        case wvw_GetScreenWidth() >= 1024
            WVw_SetFont(,'courier New', 28, 14,,2)
        case wvw_GetScreenWidth() >= 800
            WVw_SetFont(,'Courier New', 20, 11,,2)
        otherwise
            WVw_SetFont(,'Courier New', 15,  7,,2)
    endcase
    */
    
	WVW_SetCodePage(,255)
	wvw_settitle( , "LTADM - Sistema Administrativo" )
    setmode(wvw_maxmaxrow()+1,wvw_maxmaxcol()+1)
    
    
    
   return








procedure diminfo()
  @ 0, 0 say "Window size: " + alltrim(str(maxrow()+1)) + " x " + alltrim(str(maxcol()+1)) + "   "
return


function PesqXML( cFileName, cNode )
   LOCAL cXml, oDoc, oNode,cRetorno

	if !file(cFileName)
		Mens({"Arquivo XML nao encontrado"})
		return(cRetorno)
	endif
	oDoc  := TXmlDocument():New( cFileName )
	oNode := oDoc:CurNode
	cRetorno := ""
	IF oDoc:nStatus != HBXML_STATUS_OK
		Mens({"Arquivo XML invalido"})
		return(cRetorno)
	ENDIF
   // **Navigating all nodes
	DO WHILE oNode != NIL
		cXml := oNode:Path()
		IF cXml == NIL
			cXml :=  "(Node without path)"
			exit
      	ENDIF
      	if upper(cXml) == upper(cNode)
      		cRetorno := oNode:cData
      		exit
      	endif
		oNode := oDoc:Next()
	ENDDO
	return(cRetorno)


    
                                                  
procedure ParametroAcbr
   local getlist := {},cTela := SaveWindow()
   local cDirXml,cDirCan,cDirPDF,cDirInu,cDirDpec,cDirEnvResp
   local cTestarInternet,nTempo,cDirCCe

    Msg(.t.)
    Msg("Aguarde : Abrindo o Arquivo")
    if !OpenSequencia()
        FechaDados()
        Msg(.f.)
        return
    endif
    Msg(.f.)
    AtivaF4()
    Window(07,00,19,79," Parametros do Acbr ")
    setcolor(Cor(11))
    //            2345678901234567890123456789012345678901234567890123456789012345678901234567890
    //                    1         2         3         4         5         6         7
    @ 09,02 say "          Diretorio do xml:"
	@ 10,02 say " Diretorio de cancelamento:"
	@ 11,02 say "          Diretorio de PDF:"
	@ 12,02 say " Diretorio de inutilizacao:"
	@ 13,02 say "Diretorio de arquivos DPEC:"
	@ 14,02 say " Dir. da Carta de Correcao:"
	@ 15,02 say "    Dir. de Envio/Resposta:"
	@ 16,02 say "Tempo de Espera (segundos):"
	@ 17,02 say "           Testar Internet:"
    do while .t.
        cDirXml         := Sequencia->DirNFe
        cDirCan         := Sequencia->DirCan
        cDirPDF         := Sequencia->DirPDF
        cDirInu         := Sequencia->DirInu
        cDirDPEC        := Sequencia->DirDPE
        cDirEnvResp     := Sequencia->DirEnvResp
        cTestarInternet := Sequencia->TestarInte
        nTempo          := Sequencia->Tempo
		cDirCCe         := Sequencia->DirCCe
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 09,30 get cDirXml picture "@kS45"
		@ 10,30 get cDirCan picture "@kS45"
		@ 11,30 get cDirPDF picture "@kS45"
		@ 12,30 get cDirInu picture "@kS45"
		@ 13,30 get cDirDPEC picture "@kS45"
		@ 14,30 get cDirCCe picture "@kS45"
		@ 15,30 get cDirEnvResp picture "@kS45"
		@ 16,30 get nTempo picture "@ke 999999"
		@ 17,30 get cTestarInternet picture "@k!";
            valid MenuArray(@cTestarInternet,{{"S","Sim"},{"N","Nao"}})
             
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		if !Confirm(hb_AnsiToOem("Confirmas as Informa× es"))
			loop
		endif
		if Sequencia->(lastrec()) = 0
			do while !Sequencia->(Adiciona())
			enddo
			Sequencia->(dbunlock())
		endif
        do while !Sequencia->(Trava_Reg())
        enddo
        Sequencia->DirNFe:= cDirXml
        Sequencia->DirCan := cDirCan
        Sequencia->DirPDF := cDirPDF
        Sequencia->DirInu  := cDirInu
        Sequencia->DirDPE := cDirDPEc
        Sequencia->DirEnvResp := cDirEnvResp
        Sequencia->testarinte := cTestarInternet
		Sequencia->Tempo := nTempo
		Sequencia->DirCCe := cDirCCE
		Sequencia->(dbunlock())
        exit
   enddo
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
    
procedure ParametroNFCe
    local getlist := {},cTela := SaveWindow()
    local nNumNFCe,cTipoAmbNfc,cSerieNfce,cLancNFCE,nCopiasNFCe
    local cCodNatNfce,cObs1,cObs2,cObs3,nLancPdv 

    Msg(.t.)
    Msg("Aguarde : Abrindo o Arquivo")
    if !OpenSequencia()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenNatureza()
        FechaDados()
        Msg(.f.)
        return
    endif
    Msg(.f.)
    AtivaF4()
    Window(07,00,20,79," Parametros da NFC-e ")
    setcolor(Cor(11))
    //            2345678901234567890123456789012345678901234567890123456789012345678901234567890
    //                    1         2         3         4         5         6         7
    @ 09,02 say "Tipo de ambiente:"
	@ 10,02 say "    Nr. de serie:"
	@ 11,02 say "          Numero:"
	@ 12,02 say " Nr. de controle:"
	@ 13,02 say "   Nr. de copias:"
    @ 14,02 say "    Controle PDV:"
    @ 15,02 say " Natureza da Op.:"
    @ 16,01 say replicate(chr(196),78)
	@ 16,02 say " Observa‡Æo "
    do while .t.
        cCodNatNfce := Sequencia->CodNatNFCe
        nNumNFCe    := Sequencia->NumNFCe
        cSerieNFce  := Sequencia->SerieNfce
        cTipoAmbNfc := Sequencia->TipoAmbNFc
        cLancNFCE   := Sequencia->LancNFCE
        nCopiasNFCe := Sequencia->CopiasNFCE
        cObs1 := Sequencia->ObsNfce1
        cObs2 := Sequencia->ObsNfce2
        cObs3 := Sequencia->ObsNfce3
        nLancPdv := Sequencia->LancPdv
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 09,20 get cTipoAmbNfc picture "@k 9";
                    when Rodape("Esc-Encerrar"); 
                    valid MenuArray(@cTipoAmbNfc,{{"1","Produ‡Æo   "},{"2","Homologa‡Æo "}},,,row(),col()+1)
        @ 10,20 get cSerieNfce picture "@k 999";
                    valid NoEmpty(cSerieNFce) .and. V_Zera(@cSerieNFce)
        @ 11,20 get nNumNFCe picture "@k 999,999,999"
        @ 12,20 get cLancNFCE picture "@k 9,999,999,999"
        @ 13,20 get nCopiasNFCE picture "@k 99";
                    valid NoEmpty(nCopiasNFCE) .and. nCopiasNFCE > 0
        @ 14,20 get nLancPdv picture "@k 9,999,999,999";
                    valid nLancPdv >= 0 
        @ 15,20 get cCodNatNfce picture "@k 999";
      			when Rodape("Esc-Encerra | F4-Natureza da Operacao");
      			valid Busca(Zera(@cCodNatNfce),"Natureza",1,row(),col(),"'-'+Natureza->Cfop+'-'+left(Natureza->Descricao,40)",;
      				{"Natureza da Operacao Nao cadastrada"},.f.,.f.,.f.)
        @ 17,02 get cObs1 picture "@k"
        @ 18,02 get cObs2 picture "@k"
        @ 19,02 get cObs3 picture "@k"            
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		if !Confirm("Confirmas as Informa‡äes")
			loop
		endif
		if Sequencia->(lastrec()) = 0
			do while !Sequencia->(Adiciona())
			enddo
			Sequencia->(dbunlock())
		endif
        do while !Sequencia->(Trava_Reg())
        enddo
        Sequencia->TipoAmbNFc := cTipoAmbNfc
        Sequencia->SerieNfce  := cSerieNfce
         Sequencia->NumNFCe   := nNumNFCe  
        Sequencia->LancNFCE   := cLancNFCE
        Sequencia->CopiasNFCE := nCopiasNFCE
        Sequencia->CodNatNFce := cCodNatNFce
        Sequencia->ObsNfce1 := cObs1
        Sequencia->ObsNfce2 := cObs2
        Sequencia->ObsNfce3 := cObs3
        Sequencia->LancPdv := nLancPdv
		Sequencia->(dbunlock())
        exit
   enddo
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return

procedure ParametroNFe
    local getlist := {},cTela := SaveWindow()
    local nNumNFE,cTipoAmb,cSerie,nLancNfe,nCopiasNfe
    
    Msg(.t.)
    Msg("Aguarde : Abrindo o Arquivo")
    if !OpenSequencia()
        FechaDados()
        Msg(.f.)
        return
    endif
    Msg(.f.)
    AtivaF4()
    Window(07,00,15,79," Parametros da NF-e ")
    setcolor(Cor(11))
    //            2345678901234567890123456789012345678901234567890123456789012345678901234567890
    //                    1         2         3         4         5         6         7
    @ 09,02 say "Tipo de ambiente:"
	@ 10,02 say "    Nr. de serie:"
	@ 11,02 say "          Numero:"
	@ 12,02 say " Nr. de controle:"
	@ 13,02 say "   Nr. de copias:"
    do while .t.
        nNumNFE  := Sequencia->NumNFE
        cTipoAmb := Sequencia->TipoAmb
        cSerie   := Sequencia->SerieNfe
        nLancNfe := Sequencia->LancNfe
        nCopiasNfe := Sequencia->CopiasNfe
        
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 09,20 get cTipoAmb picture "@k 9";
                    when Rodape("Esc-Encerrar"); 
                    valid MenuArray(@cTipoAmb,{{"1","Produ 'o   "},{"2","Homologa 'o"}},,,row(),col()+1)
        @ 10,20 get cSerie picture "@k 999";
                    valid NoEmpty(cSerie) .and. V_Zera(@cSerie)
        @ 11,20 get nNumNfe    picture "@k 999,999,999"
        @ 12,20 get nLancNfe   picture "@k 9,999,999,999"
        @ 13,20 get nCopiasNfe picture "@k 99";
                    valid NoEmpty(nCopiasNfe) .and. nCopiasNfe > 0
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		if !Confirm(hb_AnsiToOem("Confirmas as Informa× es"))
			loop
		endif
		if Sequencia->(lastrec()) = 0
			do while !Sequencia->(Adiciona())
			enddo
			Sequencia->(dbunlock())
		endif
        do while !Sequencia->(Trava_Reg())
        enddo
        Sequencia->NumNFE   := nNumNFE 
        Sequencia->TipoAmb  := cTipoAmb
        Sequencia->SerieNfe := cSerie 
        Sequencia->LancNfe  := nLancNfe
        Sequencia->CopiasNfe := nCopiasNfe
		Sequencia->(dbunlock())
        exit
   enddo
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
   
function Round2(nValor,nDecimal)
   nDecimal := 7-nDecimal
   nvalor := substr(str(nvalor,20,7),1,(20-nDecimal))
   return(val(nvalor))
   
   
procedure CriarTemp
    local aStru := {}
    
    if !file(cDiretorio+"nfedup.dbf")
        aStru := {}
        
        aadd(aStru,{"NumCon","c",10,0})
        aadd(aStru,{"dupl","c",60,0})
        aadd(aStru,{"data","d",8,0})
        aadd(aStru,{"valor","n",15,2})
        dbcreate(cDiretorio+"nfedupl",aStru)
    endif
    
    //DbfNfeEntrada() // nota de fiscal
    
    DbfNfeItemEntrada() // itens da nota fiscal de entrada
    //DbfOrcamentos()
    DbfItemOrcamentos() 
    
    // arquivos tempor rios
    DbfTemp01()  // Relatório de proposta por período
    DbfTemp03()
    DbfTemp08()
    DbfTmp07()
    DbfTemp06()
    Dbftmp12()
    DbfTmp23()
    DbfTmp24()
    DbfTemp26()
    DbfTmp27()
    DbfTemp29()
    DbfTempInventario()
    dbfTemp30()
    DbfTemp31()
    DbfTemp34()
    DbfTemp35()
    //************
    return


static procedure DbfTemp03
    local aStru := {}
    
    aadd(aStru,{"CHAVE","C",006,00})
    aadd(aStru,{"TIPO" ,"C",001,00})
    aadd(aStru,{"DATA","D",008,00})
    aadd(aStru,{"DOCUMENTO","C",014,00})
    aadd(aStru,{"CODVEN","C",021,00})
    aadd(aStru,{"CLIFOR","C",035,00})
    aadd(aStru,{"QTDPRO","N",015,03})
    aadd(aStru,{"PCOPRO","N",012,03})
    aadd(aStru,{"total","n",15,2})
   dbcreate(cDiretorio+"tmp"+Arq_Sen+"03",aStru)
return
    
    
static procedure DbfTemp31
    local aStru := {}
    
   aStru := {}
   aadd(aStru,{"data","d",08,0})
   aadd(aStru,{"lancamento","c",06,0})
   aadd(aStru,{"historico","c",90,2})
   aadd(aStru,{"entrada","n",15,2})
   aadd(aStru,{"saida","n",15,2})
   aadd(aStru,{"saldo","n",15,2})
   dbcreate(cDiretorio+"tmp"+Arq_Sen+"31",aStru)
return
        
    
static procedure DbfTemp35
    local aStru := {}
    
    aadd(aStru,{"NumDup","c",12,0})
    aadd(aStru,{"docume","c",12,0})
    aadd(aStru,{"DtaEmi","d",08,0})
    aadd(aStru,{"DtaVen","d",08,0})
    aadd(aStru,{"ValDup","n",12,02})
    aadd(aStru,{"DtaPag","d",08,0})
    aadd(aStru,{"ValPag","n",12,02})
    dbcreate(cDiretorio+"tmp"+Arq_Sen+"35",aStru)
return
    
    
procedure DbfTemp34
    local aStru := {}
    
    aadd(aStru,{"numdoc","c",10,0})
    aadd(astru,{"balancete","d",08,0})
    aadd(astru,{"data","d",08,0})
    aadd(astru,{"historico","c",75,0})
    aadd(astru,{"quantidade","n",12,3})
    aadd(aStru,{"valor","n",12,2})
    aadd(aStru,{"tipo","c",01,0})
    aadd(aStru,{"saldo","n",15,02})
    dbcreate(cDiretorio+"tmp"+Arq_Sen+"34",aStru)
    return
    
    
static procedure DbfTemp30
    local aStru := {}
    
    aadd(aStru,{"codpro","C",06,0})
    aadd(aStru,{"despro","C",120,0})
    aadd(aStru,{"quantidade","n",15,3})
   dbcreate(cDiretorio+"tmp"+Arq_Sen+"30",aStru)
return
    
    
// relatorio de proposta por periodo
static procedure DbfTemp01
    
   aStru := {}
   aadd(aStru,{"pedido","c",09,00}) // ** data de lancammento
   aadd(aStru,{"data","d",08,0})
   aadd(aStru,{"codcli","c",04,0})
   aadd(aStru,{"nomcli","c",40,0})
   aadd(aStru,{"valor","n",15,2})
   dbcreate(cDiretorio+"tmp"+Arq_Sen+"01",aStru)
   return

// relatorio de produtos vendidos (proposta)
static procedure DbfTemp02
    
   aStru := {}
   aadd(aStru,{"pedido","c",09,00}) // ** data de lancammento
   aadd(aStru,{"data","d",08,0})
   aadd(aStru,{"codpro","c",06,0})
   aadd(aStru,{"fanpro","c",50,0})
   aadd(aStru,{"qtdpro","n",15,3})
   aadd(aStru,{"pcoliq","n",15,3})
   aadd(aStru,{"valor","n",15,2})
   dbcreate(cDiretorio+"tmp"+Arq_Sen+"01",aStru)
   return
    

// relatorio Relped1
static procedure DbfTemp08
    
   aStru := {}
   aadd(aStru,{"codpla","c",02,00})
   aadd(aStru,{"despla","c",30,0})
   aadd(aStru,{"valor","n",15,2})
   dbcreate(cDiretorio+"tmp"+Arq_Sen+"08",aStru)
   return
    
static procedure DbfTemp06
    local aStru := {}
        
    aadd(aStru,{"Emissao","d",08,0})
    aadd(aStru,{"numero","c",09,0})
    aadd(aStru,{"modelo","c",02,0})
    aadd(aStru,{"serie","c",03,0})
    aadd(aStru,{"Situacao","c",01,0})
    aadd(aStru,{"chave","c",44,0})
    aadd(aStru,{"vNF","n",13,2})  // Valor total da nota
    dbcreate(cDiretorio+"tmp"+Arq_Sen+"06",aStru)
return
    
static procedure DbfTmp07
    local aStru := {}
    
    
   aadd(aStru,{"lanc","c",06,00})
   aadd(aStru,{"fornecedor","c",30,00})  
   aadd(aStru,{"Numnot","c",09,00})
   aadd(aStru,{"Modelo","c",02,00})
   aadd(aStru,{"serie","c",03,00})
   aadd(aStru,{"chave","c",50,00})
   aadd(aStru,{"dtaemi","d",08,00})
   aadd(aStru,{"dtaent","d",08,00})
   aadd(aStru,{"codnat","c",03,00})
   aadd(aStru,{"TotalNota","n",15,02})
   dbcreate(cDiretorio+"tmp"+Arq_sen+"07",aStru)
   return

// Relatorios Relrec2,relpag2
static procedure Dbftmp12
    local aStru := {}
    
    aadd(aStru,{"codcli","c",04,0})
    aadd(aStru,{"nomcli","c",40,0})
    aadd(aStru,{"numdup","c",40,0})
    aadd(aStru,{"data1","d",08,0})  // vencimento emissao
    aadd(aStru,{"data2","d",08,0})  // pagamento vencimento
    aadd(aStru,{"data3","d",08,0})  // data de pagamento
    aadd(aStru,{"valor","n",15,2})
    aadd(aStru,{"valor2","n",15,2})   
    dbcreate(cDiretorio+"tmp"+Arq_sen+"12",aStru)
    return
static procedure DbfTmp23
    // ImpressÆo do pedido
    local aStru := {}
    
    aadd(aStru,{"ordem","C",03,00})
    aadd(aStru,{"codpro","C",06,0})
    aadd(aStru,{"descricao","C",50,00})
    aadd(aStru,{"unidade","C",03,00})
    aadd(aStru,{"quantidade","n",08,03})
    aadd(aStru,{"valor","n",12,02})
    aadd(aStru,{"total","n",12,02})
    dbcreate(cDiretorio+"tmp"+Arq_Sen+"23",aStru)
    return
    
static procedure DbfTmp24

    local aStru := {}
    
    aadd(aStru,{"numdup1","C",13,00})
    aadd(aStru,{"Dtaven1","d",08,0})
    aadd(aStru,{"Valdup1","n",12,02})
    aadd(aStru,{"numdup2","C",13,00})
    aadd(aStru,{"Dtaven2","d",08,0})
    aadd(aStru,{"Valdup2","n",12,02})
    dbcreate(cDiretorio+"tmp"+Arq_Sen+"24",aStru)
    return

static procedure DbfTemp26
    local aStru := {}
    
   aadd(aStru,{"codfor","c",04,0})
   aadd(aStru,{"razfor","c",35,0})
   aadd(aStru,{"Numdup","c",16,0})
   aadd(aStru,{"data1","d",08,0})
   aadd(aStru,{"data2","d",08,0})
   aadd(aStru,{"data3","d",08,0})
   aadd(aStru,{"valor","n",12,2})
   dbcreate(cDiretorio+"tmp"+Arq_Sen+"26",aStru)
return
       

static procedure DbfTmp27
    local aStru := {}
    
    aadd(aStru,{"codcli","c",04,0})
    aadd(aStru,{"nomcli","c",40,0})
    aadd(aStru,{"Numdup","c",16,0})
    aadd(aStru,{"data1","d",08,0})
    aadd(aStru,{"data2","d",08,0})
    aadd(aStru,{"data3","d",08,0})
    aadd(aStru,{"valor","n",12,2})
    dbcreate(cDiretorio+"tmp"+Arq_Sen+"27",aStru)
    return

static procedure DbfTemp28
    local aStru := {}
    
    aadd(aStru,{"numero","c",04,0})
    aadd(aStru,{"data","c",40,0})
    aadd(aStru,{"Numdup","c",16,0})
    aadd(aStru,{"data1","d",08,0})
    aadd(aStru,{"data2","d",08,0})
    aadd(aStru,{"data3","d",08,0})
    aadd(aStru,{"valor","n",12,2})
    dbcreate(cDiretorio+"tmp"+Arq_Sen+"27",aStru)
    return

static procedure DbfTemp29
    local aStru := {}
    
    aadd(aStru,{"pedido","c",09,0})
    aadd(aStru,{"codpro","c",06,0})
    aadd(aStru,{"fanpro","c",50,0})
    aadd(aStru,{"quantidade","n",15,3})
    aadd(aStru,{"custo","n",15,3})
    aadd(aStru,{"venda","n",15,3})
    aadd(aStru,{"lucro","n",15,3})
    dbcreate(cDiretorio+"tmp"+Arq_Sen+"29",aStru)
    return

static procedure DbfTempInventario
    local aStru := {}
    
    aadd(aStru,{"CODPRO","C",06,00})
    aadd(aStru,{"DESPRO","C",050,00})
    aadd(aStru,{"EMBPRO","C",04,00})
    aadd(aStru,{"CODGRU","C",03,00})
    aadd(aStru,{"ORDEM" ,"C",30,00})
    aadd(aStru,{"ORDEF" ,"C",30,00})
    aadd(aStru,{"QTEAC01","N",015,03})
    aadd(aStru,{"QTEAC02","N",015,03})
    aadd(aStru,{"DATA01","D",008,00})
    aadd(aStru,{"PCONOT01","N",011,03})
    aadd(aStru,{"DATA02","D",008,00})
    aadd(aStru,{"PCONOT02","N",011,03})
    dbcreate(cDiretorio+"tmp"+Arq_Sen+"05",aStru)
    return


    
        
    
static procedure DbfNfeItemEntrada
    local aStru := {}
    
    if !file(cDiretorio+"nfeitementrada.dbf")
        aadd(aStru,{"NUMCON"      ,"C",010,0})
        aadd(aStru,{"CODCLI"      ,"C",004,0})
        aadd(aStru,{"CODPRO"      ,"C",006,0})
        aadd(aStru,{"QTDPRO"      ,"N",008,2})
        aadd(aStru,{"PCOPRO"      ,"N",009,4})
        aadd(aStru,{"PCOCUS"      ,"N",009,2})
        aadd(aStru,{"CODNAT"      ,"C",003,0})
        aadd(aStru,{"CODVEN"      ,"C",002,0})
        aadd(aStru,{"ALISAI"      ,"N",005,2})
        aadd(aStru,{"DTAMOV"      ,"D",008,0})
        aadd(aStru,{"CANNOT"      ,"C",001,0})
        aadd(aStru,{"BXAREQ"      ,"C",001,0})
        aadd(aStru,{"DSCPRO"      ,"N",005,2})
        aadd(aStru,{"TOTPRO"      ,"N",011,2})
        aadd(aStru,{"CST"         ,"C",003,0})
        aadd(aStru,{"BASEICMS"    ,"N",015,2})
        aadd(aStru,{"VALORICMS"   ,"N",015,2})
        aadd(aStru,{"IPI"         ,"N",005,2})
        aadd(aStru,{"Desconto","n",12,2})
        aadd(aStru,{"CodItem","c",14,0})
        dbcreate(cDiretorio+"nfeitementrada",aStru)
    endif
    return


static procedure DbfItemOrcamentos
    local aStru := {}
    
    if !file(cDiretorio+"itemorcamentos.dbf")
        aadd(aStru,{"ID"          ,"C",009,0})
        aadd(aStru,{"CODITEM"     ,"C",013,0})
        aadd(aStru,{"CODPRO"      ,"C",006,0})
        aadd(aStru,{"DSCPRO"      ,"N",006,2})
        aadd(aStru,{"QTDPRO"      ,"N",015,3})
        aadd(aStru,{"PCOVEN"      ,"N",015,3})
        aadd(aStru,{"PCOLIQ"      ,"N",015,3})
        aadd(aStru,{"DTASAI"      ,"D",008,0})
        aadd(aStru,{"VALDESC"     ,"N",015,2})
        aadd(aStru,{"CUSTO"       ,"N",015,3})
        dbcreate(cDiretorio+"itemorcamentos",aStru)
    endif
return

procedure TelaAbout
    local cVersaoAcbr

    #include "hbver.ch"
    
    if !OpenSequencia()
        FechaDados()
        return
    endif
    cVersaoAcbr := ""//AcbrNfe_Versao(Sequencia->DirNfe)
    Mens({HB_BuildInfo( _HB_VER_AS_STRING ),;
          "Data/Hora: "+HB_BuildInfo(_HB_VER_BUILD_DATE)+" "+HB_BuildInfo(_HB_VER_BUILD_TIME),;
          "               Compilador: "+HB_BuildInfo(_HB_VER_COMPILER),;
          "  Sistema operacional: "+HB_BuildInfo( _HB_VER_PLATFORM ),;
          "      Versao ACBR: "+cVersaoAcbr})
    FechaDados()
    return
    

    
FUNCTION CreateTemp( nMode )
    LOCAL cReto, cTime

    // db01183501.001
    do WHILE .T.
        cTime := TIME()       // 00:00:00
        cReto := "DB"+strzero(nMode,02) + SUBSTR( cTime , 1 , 2 ) + ;
                   SUBSTR( cTime , 4 , 2 ) + ;
                   SUBSTR( cTime , 7 , 2 ) + "." + PWRegt
        IF ! FILE( cReto )
            EXIT
        ENDIF
    ENDdo
    RETURN cReto
    

    
//
// FUNCAO     : Alerta()
// PARAMETROS : cMessage    - Mensagem para exibir
//              nNumButtons - N§ de botoes para exibir
// DESCRICAO  : Apresenta mensagem no centro da tela e um n§ de botoes para o
//              usuario escolher a acao.
// RETORNO    : Codigo numerico ( em winuser.ch ) : IDYES, IDNO, etc.
//
************************************************
function Alerta( cMessage, nNumButtons, nStyle )
************************************************
   local nCurButton

   default nNumButtons to MB_OK ,;
           nStyle      to MB_ICONHAND

   nCurButton := wvw_messagebox( 0, cMessage, "ATENÇÃO", nStyle + nNumButtons )
RETURN nCurButton
        
        
        
        

function Soma_Veto2( Vetor )
   local Laco, Retorno := 0, Tam_Vetor := LEN( Vetor )

   for Laco := 1 TO Tam_Vetor
      Retorno += round(Vetor[Laco],2)
   next
return( Retorno )
   
   
   
function RetiraAcentos(cCampo) 
    cCampot:=cCampo 
    cCampot:=xAcentos(cCampot,' ','a')   // 88
    cCampot:=xAcentos(cCampot,'…','a')    
    cCampot:=xAcentos(cCampot,'Æ','a') 
    cCampot:=xAcentos(cCampot,'ƒ','a')   
    cCampot:=xAcentos(cCampot,'µ','A')    
    cCampot:=xAcentos(cCampot,'·','A')    
    cCampot:=xAcentos(cCampot,'Ç','A') 
    cCampot:=xAcentos(cCampot,'¶','A')   
    cCampot:=xAcentos(cCampot,'Æ','a')
    cCampot:=xAcentos(cCampot,'æ','A')
    cCampot:=xAcentos(cCampot,'?','E')
    cCampot:=xAcentos(cCampot,'?','C')
    cCampot:=xAcentos(cCampot,'?','e')
    cCampot:=xAcentos(cCampot,'?','e')
    cCampot:=xAcentos(cCampot,'ÿ','a')
    cCampot:=xAcentos(cCampot,'?','c')
    cCampot:=xAcentos(cCampot,'’','a')
    cCampot:=xAcentos(cCampot,'­','i')       
    cCampot:=xAcentos(cCampot,'‚','e')   
    cCampot:=xAcentos(cCampot,'Š','e')  
    cCampot:=xAcentos(cCampot,'ˆ','e')  
    cCampot:=xAcentos(cCampot,'','E')   
    cCampot:=xAcentos(cCampot,'Ô','E')  
    cCampot:=xAcentos(cCampot,'Ò','E')  
    cCampot:=xAcentos(cCampot,'','i')     
    cCampot:=xAcentos(cCampot,'¡','i')             
    cCampot:=xAcentos(cCampot,'Þ','I')   
    cCampot:=xAcentos(cCampot,'Ö','I')  
    cCampot:=xAcentos(cCampot,'¢','o')   
    cCampot:=xAcentos(cCampot,'•','o')  
    cCampot:=xAcentos(cCampot,'ä','o')   
    cCampot:=xAcentos(cCampot,'“','o')  
    cCampot:=xAcentos(cCampot,'à','O')  
    cCampot:=xAcentos(cCampot,'ã','O')  
    cCampot:=xAcentos(cCampot,'å','O')   
    cCampot:=xAcentos(cCampot,'â','O')  
    cCampot:=xAcentos(cCampot,'‡','c')  
    cCampot:=xAcentos(cCampot,'€','A')
    cCampot:=xAcentos(cCampot,"'"," ")
    cCampot:=xAcentos(cCampot,"§"," ")
    cCampot:=xAcentos(cCampot,"¦"," ")
    cCampot:=xAcentos(cCampot,"õ"," ")
    cCampot:=xAcentos(cCampot,"'"," ")       
    cCampot:=xAcentos(cCampot,"`"," ")       
    cCampot:=xAcentos(cCampot,"?","C")
RETURN cCampot
    
    function xAcentos(texto,campo,novo)
    cTexto:=ALLTRIM(texto) 
    nLenTexto:=LEN(cTexto)
    nLenCampo:=LEN(campo) 
    DO WHILE nLenTexto > 0
       IF ( nBegin := AT ( campo , cTexto ) ) >0 
          cTexto=SUBSTR( cTexto , 0 , nBegin-1 )+novo+SUBSTR( cTexto , nBegin+nLenCampo )
          nLenTexto:=LEN(cTexto)
       ELSE
          nLenTexto:=0 
       ENDIF 
    ENDDO 
RETURN cTexto  
    
    
       
   
		
// ** Fim do Arquivo
