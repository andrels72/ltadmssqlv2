#include "fileio.ch"
procedure main
    local cQuery
    private oQuery
    
    set delete on
    hIni := HB_ReadIni("configbanco.ini",,,.f.)
    cHost := hIni["conexao"]["Hostname"] 
    cDataBase := hIni["conexao"]["Database"] 
    cUser := hIni["conexao"]["username"] 
    cPass := hIni["conexao"]["password"] 
    nPort := hIni["conexao"]["port"]   

    
    ? "Aguarde: conectando ao banco de dados"
    oServer := TPQServer():New(cHost,cDataBase,cUser,cPass,nPort)    
    if oServer:NetErr()
        ? "Erro ao conectar ao banco de dados"
        oServer:Destroy()
        return
    endif
    
    ? "aqui"
    inkey(0)
    
    Tb_Natureza()
    Tb_Produtos()
    //TabelaProdutos()    
    
    oServer:close()
    return
    
    
procedure Tb_Natureza
        local oQuery,cQuery
        
    cQuery := "truncate table administrativo.natureza; "
    if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar "},"sqlerro")
        quit 
    endif
    ? "Importando Produtos"
    use dados\Natureza alias lixo new
    do while lixo->(!eof())
        cQuery := "INSERT INTO administrativo.natureza "
        cQuery += "(cfop, tipo, operacao, aliquota,local, gerdup, altcus, bxaest, obs1, obs2, obs3, obs4, obs5, obs6) "
        cQuery += "VALUES("+StringToSql(lixo->cfop)+","
        cquery += StringToSql(lixo->tipo)+","
        cQuery += StringToSql(lixo->operacao)+","
        cQuery += NumberToSql(lixo->aliquota,5,2)+","
        cQuery += StringToSql(lixo->local)+","
        cQuery += StringToSql(lixo->gerdup)+","
        cQuery += StringToSql(lixo->altcus)+","
        cQuery += StringToSql(lixo->bxaest)+","
        cQuery += StringToSql(lixo->obs1)+","
        cQuery += StringToSql(lixo->obs2)+","
        cQuery += StringToSql(lixo->obs3)+","
        cQuery += StringToSql(lixo->obs4)+","
        cQuery += StringToSql(lixo->obs5)+","
        cQuery += StringToSql(lixo->obs6)
        cQuery += ")"
        if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar "},"sqlerro")
            ? "erro no produto"
            quit 
        endif
        oQuery:Destroy()
        lixo->(dbskip())
    enddo
    lixo->(dbCloseAre())
return
        
        
    
   
    

procedure Tb_Produtos
    local oQuery,cQuery
    
    //if !oServer:TableExists("produtos")
    //    ? "Tabela produtos nÆo existe"
    //    return
    //endif
    cQuery := "truncate table administrativo.produtos; "
    if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar "},"sqlerro")
        quit 
    endif
    ? "Importando Produtos"
    use dados\produtos alias lixo new
    do while lixo->(!eof())
        cQuery := "insert into administrativo.produtos"
        cQuery += "("
        cQuery += "despro,"
        cQUery += "fanpro,"
        cQuery += "dtapro,"
        cQuery += "pctcom,"
        cQuery += "pctdsc,"  
        cQuery += "pcoven, " 
        cQuery += "pcoini, " 
        cQuery += "pcocus, " 
        cQuery += "pcoprz, " 
        cQuery += "refpro, " 
        cQuery += "locpro, " 
        cQuery += "pcobru, " 
        cQuery += "pcocub, " 
        cQuery += "pcopro, " 
        cQuery += "qteac01, " 
        cQuery += "qteac02, " 
        cQuery += "pcoinv, " 
        cQuery += "qteiv01, " 
        cQuery += "qteiv02, " 
        cQuery += "cusmed01, " 
        cQuery += "cusmed02, " 
        cQuery += "qtere01, " 
        cQuery += "qtere02, " 
        cQuery += "embpro, " 
        cQuery += "qteemb, " 
        cQuery += "pesliq, " 
        cQuery += "pesbru, " 
        cQuery += "icmsub, " 
        cQuery += "lucpro, " 
        cQuery += "alidtr, " 
        cQuery += "alifor, " 
        cQuery += "perred, " 
        cQuery += "ipipro, " 
        cQuery += "qtdmin, " 
        cQuery += "qtdmax, " 
        cQuery += "parmax, " 
        cQuery += "tabesp, " 
        cQuery += "qteant, " 
        cQuery += "ultsai, " 
        cQuery += "ultent, " 
        cQuery += "idultfor, " 
        cQuery += "ultpco, " 
        cQuery += "ultqtd, " 
        cQuery += "salreq, " 
        cQuery += "numvendped, " 
        cQuery += "idfornecedor, " 
        cQuery += "idgrupo, " 
        cQuery += "idsubgrupo,"  
        cQuery += "codbar,"  
        cQuery += "codncm, " 
        cQuery += "pctprz, " 
        cQuery += "obspro, " 
        cQuery += "dtaalt, " 
        cQuery += "pcocal, " 
        cQuery += "pconot, " 
        cQuery += "pernot, " 
        cQuery += "pctfre, " 
        cQuery += "pcosug, " 
        cQuery += "creicm, " 
        cQuery += "ctrles, " 
        cQuery += "idcst, " 
        cQuery += "codlab, " 
        cQuery += "origem, " 
        cQuery += "ativo," 
        cQuery += "estoqlote, " 
        cQuery += "idsimilar, " 
        cQuery += "natsaident, " 
        cQuery += "natsaifora, " 
        cQuery += "natentdent, " 
        cQuery += "natentfora, " 
        cQuery += "qtdesti01, " 
        cQuery += "qtdesti02, " 
        cQuery += "cest, " 
        cQuery += "pis, " 
        cQuery += "pisaliq, " 
        cQuery += "cofins, " 
        cQuery += "cofinsaliq, " 
        cQuery += "idfabricante, " 
        cQuery += "prodbalanc" 

        cQuery += ") "
        cQuery += " values ("
        cQuery += StringToSql(RetiraAcentos(Lixo->despro))+","
        cQuery += StringToSql(RetiraAcentos(lixo->fanpro))+","
        cQuery += iif(empty(Lixo->dtapro),"NULL",DateToSql(Lixo->dtapro)) +","
        cQuery += NumberToSql(lixo->pctcom,5,2) +","
        cQuery += NumberToSql(lixo->pctdsc,5,2) +","
        cQuery += NumberToSql(lixo->pcoven,11,3) +","
        cQuery += NumberToSql(lixo->pcoini,11,3)  +","
        cQuery += NumberToSql(lixo->pcocus,11,3)  +","
        cQuery += NumberToSql(lixo->pcoprz,11,3) +"," 
        cQuery += StringToSql(lixo->refpro) +","
        cQuery += StringToSql(lixo->locpro) +","
        cQuery += NumberToSql(lixo->pcobru,11,2)  +","
        cQuery += NumberToSql(lixo->pcocub,11,2)  +","
        cQuery += NumberToSql(lixo->pcopro,11,2) +","
        cQuery += NumberToSql(lixo->qteac01,15,3) +","
        cQuery += NumberToSql(lixo->qteac02,15,3)  +","
        cQuery += NumberToSql(lixo->pcoinv,11,2) +","
        cQuery += NumberToSql(lixo->qteiv01,15,3)  +","
        cQuery += NumberToSql(lixo->qteiv02,15,3) +","
        cQuery += NumberToSql(lixo->cusmed01,15,3) +","
        cQuery += NumberToSql(lixo->cusmed02, 15,3) +","
        cQuery += NumberToSql(lixo->qtere01,15,3) +","
        cQuery += NumberToSql(lixo->qtere02,15,3) +","
        cQuery += StringToSql(lixo->embpro) +","
        cQuery += NumberToSql(lixo->qteemb,3,0) +","
        cQuery += NumberToSql(lixo->pesliq,9,3) +","
        cQuery += NumberToSql(lixo->pesbru,9,3) +","
        cQuery += NumberToSql(lixo->icmsub,5,2) +","
        cQuery += NumberToSql(lixo->lucpro,6,2) +","
        cQuery += NumberToSql(lixo->alidtr,5,2) +","
        cQuery += NumberToSql(lixo->alifor,5,2) +","
        cQuery += NumberToSql(lixo->perred,5,2) +","
        cQuery += NumberToSql(lixo->ipipro,6,2) +","
        cQuery += NumberToSql(lixo->qtdmin,8,2) +","
        cQuery += NumberToSql(lixo->qtdmax,8,2) +","
        cQuery += NumberToSql(lixo->parmax,2,0) +","
        cQuery += StringToSql(lixo->tabesp)+","
        cQuery += NumberToSql(lixo->qteant,10,0) +","
        cQuery += DateToSql(lixo->ultsai) +","
        cQuery += DateToSql(lixo->ultent) +","
        cQuery += NumberToSql(val(lixo->ultfor)) +","
        cQuery += NumberToSql(lixo->ultpco,11,2) +","
        cQuery += NumberToSql(lixo->ultqtd,10,0) +","
        cQuery += NumberToSql(lixo->salreq,11,2) +","
        cQuery += StringToSql(lixo->numvendped)+","
        cQuery += NumberToSql(val(lixo->codfor)) +","
        cQuery += NumberToSql(val(lixo->codgru)) +","
        cQuery += NumberToSql(val(lixo->subgru)) +","
        cQuery += StringToSql(lixo->codbar) +","
        cQuery += StringToSql(lixo->codncm) +","
        cQuery += NumberToSql(lixo->pctprz,5,2) +","
        cQuery += StringToSql(lixo->obspro) +","
        cQuery += DateToSql(lixo->dtaalt) +","
        cQuery += NumberToSql(lixo->pcocal,15,3) +","
        cQuery += NumberToSql(lixo->pconot,15,3) +","
        cQuery += NumberToSql(lixo->pernot,6,2) +","
        cQuery += NumberToSql(lixo->pctfre,5,2) +","
        cQuery += NumberToSql(lixo->pcosug,15,3) +","
        cQuery += NumberToSql(lixo->creicm,5,2) +","
        cQuery += StringToSql(lixo->ctrles) +","
        cQuery += NumberToSql(val(lixo->cst)) +","
        cQuery += StringToSql(lixo->codlab ) +","
        cQuery += StringToSql(lixo->origem) +","
        cQuery += StringToSql(lixo->ativo) +","
        cQuery += StringToSql(lixo->estoqlote) +","
        cQuery += NumberToSql(val(lixo->similar))+","
        cQuery += NumberToSql(val(lixo->natsaident))+","
        cQuery += NumberToSql(val(lixo->natsaifora))+","
        cQuery += NumberToSql(val(lixo->natentdent))+","
        cQuery += NumberToSql(val(lixo->natentfora))+","
        cQuery += NumberToSql(lixo->qtdesti01,15,3)+","
        cQuery += NumberToSql(lixo->qtdesti02,15,3)+","
        cQuery += StringToSql(lixo->cest)+","
        cQuery += StringToSql(lixo->pis)+","
        cQuery += NumberToSql(lixo->pisaliq,5,2) +","
        cQuery += StringToSql(lixo->cofins)+","
        cQuery += NumberToSql(lixo->cofinsaliq,5,2) +","
        cQuery += NumberToSql(val(lixo->codfab))+","
        cQuery += NumberToSql(val(lixo->prodbalanc))
        cQuery += ")"
        if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar "},"sqlerro")
            ? "erro no produto"
            quit 
        endif
        oQuery:Destroy()
        lixo->(dbskip())
    enddo
    ? "Tabela Produtos importada com sucesso"    
    oQuery:Destroy()
    Lixo->(dbclosearea())
return





































*-------------------*
function d2pg(dDate)
*-------------------*
    return strzero(year(dDate),4)+"-"+strzero(month(dDate),2)+"-"+strzero(day(dDate),2) 



*-------------------------*
function ntrim(nVal, nTam,nDec)
*-------------------------*
//return iif(nVal==0,alltrim(0,nTam,nDec),alltrim(str(nVal,iif(nTam = 0,0,nTam ),iif(nDec==nil, 0, nDec))))
return alltrim(str(nVal,iif(nTam = 0,0,nTam ),iif(nDec==nil, 0, nDec)))
	
FUNCTION RetiraAcentos(cCampo) 
cCampot:=cCampo 
cCampot:=xAcentos(cCampot,'á','a')   // 88
cCampot:=xAcentos(cCampot,'à','a')    
cCampot:=xAcentos(cCampot,'ã','a') 
cCampot:=xAcentos(cCampot,'â','a')   
cCampot:=xAcentos(cCampot,'Á','A')    
cCampot:=xAcentos(cCampot,'À','A')    
cCampot:=xAcentos(cCampot,'Ã','A') 
cCampot:=xAcentos(cCampot,'Â','A')   
cCampot:=xAcentos(cCampot,'ã','a')
cCampot:=xAcentos(cCampot,'µ','A')
cCampot:=xAcentos(cCampot,'','E')
cCampot:=xAcentos(cCampot,'€','C')
cCampot:=xAcentos(cCampot,'‚','e')
cCampot:=xAcentos(cCampot,'','e')
cCampot:=xAcentos(cCampot,' ','a')
cCampot:=xAcentos(cCampot,'‡','c')
cCampot:=xAcentos(cCampot,'Æ','a')
//cCampot:=xAcentos(cCampot,'ˆ','e')
                                    

cCampot:=xAcentos(cCampot,'é','e')   
cCampot:=xAcentos(cCampot,'è','e')  
cCampot:=xAcentos(cCampot,'ê','e')  
cCampot:=xAcentos(cCampot,'É','E')   
cCampot:=xAcentos(cCampot,'È','E')  
cCampot:=xAcentos(cCampot,'Ê','E')  
 
cCampot:=xAcentos(cCampot,'ì','i')     
cCampot:=xAcentos(cCampot,'í','i')  
cCampot:=xAcentos(cCampot,'Ì','I')   
cCampot:=xAcentos(cCampot,'Í','I')  
 
cCampot:=xAcentos(cCampot,'ó','o')   
cCampot:=xAcentos(cCampot,'ò','o')  
cCampot:=xAcentos(cCampot,'õ','o')   
cCampot:=xAcentos(cCampot,'ô','o')  
cCampot:=xAcentos(cCampot,'Ó','O')  
cCampot:=xAcentos(cCampot,'Ò','O')  
cCampot:=xAcentos(cCampot,'Õ','O')   
cCampot:=xAcentos(cCampot,'Ô','O')  

cCampot:=xAcentos(cCampot,'ç','c')  
cCampot:=xAcentos(cCampot,'Ç','A')

cCampot:=xAcentos(cCampot,"'"," ")
cCampot:=xAcentos(cCampot,"º"," ")
cCampot:=xAcentos(cCampot,"ª"," ")   
RETURN cCampot

FUNCTION xAcentos(texto,campo,novo)
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

function ExecuteSql(cQuery,oQuery,cMensErro,cFileErro)
    
    oQuery := oServer:Query(cQuery)
    if oQuery:neterr()
        if !(cMensErro == NIL)
            Alert(cMensErro)
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

function DateToSql(dDate)
    
    if empty(dDate)
        return("NULL")
    endif
return(StringToSql(strzero(year(dDate),4)+"-"+strzero(month(dDate),2)+"-"+strzero(day(dDate),2)))
    
procedure LogDeErro(cNameTable,cQuery)

    nHandle := FCreate(cNameTable+".log")
    FWrite( nHandle, "Error: " + cQuery )
    FClose( nHandle )
    return

