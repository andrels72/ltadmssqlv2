/*
     Modulo: Importa◊'o de XML
    Anòlise: Andr' Lucas Souza
Programa◊'o: Andr' Lucas Souza
     Criado: 10 de julho de 2012
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "fileio.ch"
#include "hbxml.ch"

static procedure RelacionarProdutos // Relaciona produtos

    nfe_prod->(dbgotop())
    do while nfe_prod->(!eof())
        if Fornecedor->(dbsetorder(4),dbseek(nfe_prod->cnpj))
            if !ProdutoFornecedor->(dbsetorder(3),dbseek(Fornecedor->CodFor+nfe_prod->codigo))
                if Produtos->(dbsetorder(5),dbseek(nfe_prod->Ean))
                    do while ProdutoFornecedor->(!Adiciona())
                    enddo
                    ProdutoFornecedor->CodFor := Fornecedor->CodFor
                    ProdutoFornecedor->ProdFor := nfe_prod->Codigo
                    ProdutoFornecedor->CodPro := Produtos->CodPro
                endif
            endif
        endif
        nfe_prod->(dbskip())
    enddo
    return
    
   
static procedure RelacionarProdutos2
	local nLinha1,nColuna1,nLina2,nColuna2
	local aCampo := {},aTitulo := {},aMascara := {}
	private aCodFor := {},aProdFor := {},aDesPro := {},aCodPro := {},aDescPro := {}
	
	Msg(.t.)
	Msg("Aguarde: Relacionando produtos")
	nfe_prod->(dbgotop())
	do while nfe_prod->(!eof())
		Fornecedor->(dbsetorder(4),dbseek(nfe_prod->cnpj))
		if !ProdutoFornecedor->(dbsetorder(3),dbseek(Fornecedor->CodFor+nfe_prod->codigo))
			aadd(aProdFor,nfe_prod->codigo)
			aadd(aDesPro,left(nfe_prod->descri,60))
			aadd(aCodPro,space(06))
			aadd(aDescPro,space(20))
		endif
		nfe_prod->(dbskip())
	enddo
	if len(aProdFor) > 0
		aadd(aCampo,"aProdFor")
		aadd(aCampo,"aDesPro")
		
		aadd(aTitulo,"Prod do;Fornecedor")
		aadd(aTitulo,"Descricao do;Produto")
		
		aadd(aMascara,"@k")
		aadd(aMascara,"@k")
		nLinha1  := 10
		nColuna1 := 00
		nLinha2  := maxrow()-1
		nColuna2 := 90
		Window(nLinha1,nColuna1,nLinha2,nColuna2,HB_AnsiToOem("> Produtos n'o relacionados <"))
		Edita_Vet(nLinha1+1,nColuna1+1,nLinha2-1,nColuna2-1,aCampo,aTitulo,aMascara,[XAPAGARU])

	endif
	Msg(.f.)
	return
	
// *********************************************************************************************************
static procedure AtualizarFornecedor
	local cCodFor,lIncluir := .f.

    Msg(.t.)
    Msg("Aguarde: Atualizando dados do fornecedor")
    nfe_emit->(dbgotop())
    do while nfe_emit->(!eof())
        if !Fornecedor->(dbsetorder(4),dbseek(nfe_emit->Cnpj))
            lIncluir := .t.
            do while !Sequencia->(Trava_Reg())
            enddo
            Sequencia->CodFor += 1
            cCodFor := strzero(Sequencia->CodFor,4,0)
            do while Fornecedor->(!Adiciona())
            enddo
            Fornecedor->CodFor  := cCodFor
            Fornecedor->DatFor  := date()
            Fornecedor->RazFor  := nfe_emit->xNome
            Fornecedor->FanFor  := nfe_emit->xfant
            Fornecedor->EndFor  := nfe_emit->xlgr
            Fornecedor->BaiFor  := nfe_emit->xbairro
	
            Cidades->(dbsetorder(4),dbseek(nfe_emit->cmun))
            Fornecedor->CodCid  := Cidades->CodCid
            Fornecedor->CepFor  := nfe_emit->cep
            Fornecedor->TelFor1 := nfe_emit->fone
	
            Fornecedor->CgCFor  := nfe_emit->cnpj            
            Fornecedor->IesFor  := nfe_emit->ie
            Fornecedor->Compl   := nfe_emit->xcpl
            Fornecedor->Numero  := nfe_emit->nro
            // cÆdigo de regime tribut~rio
            Fornecedor->crt     := nfe_emit->crt
            if len(alltrim(nfe_emit->cnpj)) < 14
                Fornecedor->Tipo  := "F"
            else
                Fornecedor->Tipo := "J"
            endif
            Fornecedor->(dbcommit())
            Fornecedor->(dbunlock())
            Sequencia->(dbunlock())
        endif
        nfe_emit->(dbskip())
    enddo
    Msg(.f.)
	return
//*****************************************************************************
static function RetornaConteudoXml(cFileName,cCampo)
   LOCAL hFile, cXml
   LOCAL xmlDoc, xmlIter , xmlNode, cNode, cAttrib, cValue, oCampo, oConteudo

   if !file(cFileName)
      Alert("Arquivo "+cFileName+" nao encontrado !")
      Return(" ")
   end
   cNode := NIL
   cAttrib := NIL
   cValue := NIL
   hFile := FOpen( cFileName )
   xmlDoc := TXmlDocument():New( hFile )
   IF xmlDoc:nStatus != 1
      Alert("erro ao ler XML ")
      Return(Nil)
   ENDIF
   xmlIter := TXmlIterator():New( xmlDoc:oRoot )
   xmlNode := xmlIter:Find()
   DO WHILE xmlNode != NIL
      xPath := alltrim(upper(xmlNode:Path()))
      xPath := substr(xPath,at("/NFE/",xPath),len(xPath))
      if xPath == cCampo
         return(xmlNode:cData)
      endif
      /*
      if !empty(xmlNode:cData)
         if subs(xmlNode:cData,1,1) # "<"
            oCampo :=xmlNode:cName
            oConteudo:=xmlNode:cData
         endif
      else
         oCampo :=xmlNode:cName
        oConteudo:=""
      endif
      if oCampo == cCampo
         return(oConteudo)
      endif
      */
      xmlNode := xmlIter:Next()                        // joga pro proximo campo
   ENDDO
   Return(" ")
    
//************************************************************

procedure VerificarProdutos

    nfe_prod->(dbgotop())
    do while nfe_prod->(!eof())
        if !Produtos->(dbsetorder(5),dbseek(nfe_prod->ean))
            @ 30,20 say nfe_prod->descri
            Mens({"Produto nao cadastrado"})
        endif
        nfe_prod->(dbskip())
    enddo
    return
//*****************************************************************************
procedure ExcluirXml
    local getlist := {},cTela := SaveWindow()
    local cChave
    
    Msg(.t.)
    Msg("Aguarde: Abrindo arquivos")
    if !OpenTabelaNfe_Nota()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenTabelaNfe_Emit()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenTabelaNfe_Prod()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenTabelaNfe_Dupl()
        FechaDados()
        Msg(.f.)
        return
    endif
    Msg(.f.)
    Window(10,03,17,79)
    setcolor(Cor(11))
    //           567890123456789012345678901234567890
    //                1         2         3         4
    @ 12,05 say "     Chave:"
    @ 13,05 say "      Nota:            serie:"
    @ 14,05 say "   Emiss'o:" 
    @ 15,05 say "Fornecedor:"
    do while .t.
        cChave := space(44)
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 12,18 get cChave picture "@k" 
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        if !nfe_nota->(dbsetorder(1),dbseek(cChave))
            Mens({"Arquivo XML n'o importado"})
            loop
        endif
        nfe_emit->(dbsetorder(1),dbseek(cChave))
        @ 13,18 say nfe_nota->numero
        @ 13,35 say nfe_nota->serie
        @ 14,18 say nfe_nota->emissao
        @ 15,18 say nfe_emit->xnome
        if !Confirm("Confirma os dados")
            loop
        endif
        Msg(.t.)
        Msg("Aguarde: Excluindo o XML")
        do while nfe_nota->(!Trava_Reg())
        enddo
        nfe_prod->(dbsetorder(1),dbseek(cChave))
        do while nfe_prod->chave == cChave .and. nfe_prod->(!eof())
            do while nfe_prod->(!Trava_Reg())
            enddo
            nfe_prod->(dbdelete())
            nfe_prod->(dbcommit())
            nfe_prod->(dbunlock())
            nfe_prod->(dbskip())
        enddo
        nfe_emit->(dbsetorder(1),dbseek(cChave))
        do while nfe_emit->(!Trava_Reg())
        enddo
        nfe_emit->(dbdelete())
        nfe_emit->(dbcommit())
        nfe_emit->(dbunlock())
        nfe_dupl->(dbsetorder(1),dbseek(cChave))
        do while nfe_dupl->chave == cChave .and. nfe_dupl->(!eof())
            do while nfe_dupl->(!Trava_Reg())
            enddo
            nfe_dupl->(dbdelete())
            nfe_dupl->(dbcommit())
            nfe_dupl->(dbunlock())
            nfe_dupl->(dbskip())
        enddo
        nfe_nota->(dbdelete())
        nfe_nota->(dbcommit())
        nfe_nota->(dbunlock())
        Msg(.f.)
        Mens({"Chave excluda com sucesso"})
    enddo
    FechaDados()
    RestWindow(cTela)
    return    
// ****************************************************************************
procedure ConXml
    local getlist := {},cTela := SaveWindow(),cTela2
    local cChave := space(44)
    local aCampo  := {},aTitulo := {},aMascara := {}
    private aVetor1 := {},aVetor2 := {},aVetor3 := {},aVetor4 := {},aVetor5 := {}
    private aVetor6 := {},aVetor7 := {},aVetor8 := {},aVetor9 := {}
    
    Msg(.t.)
    Msg("Aguarde: Abrindo arquivos")
    if !OpenTabelaNfe_Nota()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenTabelaNfe_Emit()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenTabelaNfe_Prod()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenTabelaNfe_Dupl()
        FechaDados()
        Msg(.f.)
        return
    endif
    Msg(.f.)
    Window(02,00,33,100,"> Consultar XML de Entrada <")
    setcolor(Cor(11))
    //           1234567890123456789012345678901234567890
    //                    1         2         3         4
    @ 04,01 say "     Chave:"
    @ 05,01 say "      Nota:             serie:"
    @ 06,01 say "   Emiss∆o:" 
    @ 07,01 say "Fornecedor:"
    @ 08,01 say "     Valor:"
    @ 09,01 say replicate(chr(196),99)
    do while .t.
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 04,13 get cChave picture "@r 9999.9999.9999.9999.9999.9999.9999.9999.9999.9999.9999" 
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        if !nfe_nota->(dbsetorder(1),dbseek(cChave))
            Mens({"Arquivo XML n∆o importado"})
            loop
        endif
        nfe_emit->(dbsetorder(1),dbseek(cChave))
        @ 05,13 say val(nfe_nota->numero) picture "@e 999,999,999"
        @ 05,32 say nfe_nota->serie
        @ 06,13 say nfe_nota->emissao
        @ 07,13 say nfe_emit->xnome
        @ 08,13 say nfe_nota->vr_cont picture "@e 999,999,999.99"
        //cChave := space(44)
        nfe_prod->(dbsetorder(1),dbseek(cChave))
        do while nfe_prod->chave == cChave .and. nfe_prod->(!eof())
            //aadd(aVetor1,nfe_prod->nritem)
            aadd(aVetor1,nfe_prod->codigo)
            aadd(aVetor2,left(nfe_prod->descri,80))
            aadd(aVetor3,nfe_prod->ncm)
            aadd(aVetor4,nfe_prod->orig+nfe_prod->cst)
            aadd(aVetor5,nfe_prod->cfop)
            aadd(aVetor6,nfe_prod->und)
            aadd(aVetor7,nfe_prod->qtd)
            aadd(aVetor8,nfe_prod->unidade)
            aadd(aVetor9,nfe_prod->vrtotal)
            nfe_prod->(dbskip())             
        enddo
        aadd(aTitulo,"Codigo do;Prod")
        aadd(aTitulo,"Descricao do produto;Serviáos")
        aadd(aTitulo,"NCM")
        aadd(aTitulo,"CST")
        aadd(aTitulo,"CFOP")
        aadd(aTitulo,"Und")
        aadd(aTitulo,"Quantidade")
        aadd(aTitulo,"Valor;Unit†rio")
        aadd(aTitulo,"Valor;Total")
        
        aadd(aCampo,"aVetor1")
        aadd(aCampo,"aVetor2")
        aadd(aCampo,"aVetor3")
        aadd(aCampo,"aVetor4")
        aadd(aCampo,"aVetor5")
        aadd(aCampo,"aVetor6")
        aadd(aCampo,"aVetor7")
        aadd(aCampo,"aVetor8")
        aadd(aCampo,"aVetor9")
        
        
        aadd(aMascara,"@!")
        aadd(aMascara,"@!")
        aadd(aMascara,"@!")
        aadd(aMascara,"@!")
        aadd(aMascara,"@!")
        aadd(aMascara,"@!") 
        aadd(aMascara,"@e 99,999.99") //        ,"@e 99,999.999","@e 99,999.999","@e 9,999,999.99"}
        aadd(aMascara,"@e 99,999.99")
        aadd(aMascara,"@3 99,999.99")
        cTela2 := SaveWindow()
        Rodape("Esc-Encerra")
        Edita_Vet(10,01,32,099,aCampo,aTitulo,aMascara, [XAPAGARU])
        
    enddo
    FechaDados()
    RestWindow(cTela)
    return    
// ****************************************************************************
procedure ImportarXml
    local aArquivos,nI,cFileName,cTela := SaveWindow(),cTela2
    private cNumeroNota,cCnpj,cModelo,cSerie,dEmissao,cChaveNfe


    Msg(.t.)
    Msg("Aguarde: Abrindo os arquivos")
	if !OpenTabelaNfe_Text()
		FechaDados()
		Msg(.f.)
        return
    endif
    Msg(.f.)
    aArquivos := directory("importxml\*.xml")
    AtivaF4()
    cTela2 := SaveWindow()
    Msg("Aguarde: Importando XML")   
    Calibra(10,10,.t.,"Aguarde: Importando XML")
    nXmlRecebidos := 0 
    lErro := .f.
	for nI := 1 to len(aArquivos)
        cFileName := 'importxml\'+aArquivos[nI][1]
        
        nfe_text->(dbzap())
        if recebeXML(cFileName)  // Transfere o XML para um arquivo
            nfe_text->(dbsetorder(1))
            // verificar se o cnpj do destinatrio ' o mesmo da empresa
            //if NFE_TEXT->(dbseek("/NFE/INFNFE/DEST/CNPJ"),alltrim(nfe_text->conteudo)) == cEmpCnpj
                nXmlRecebidos += 1
                cChaveNfe := NFE_TEXT->(dbseek("/NFEPROC/PROTNFE/INFPROT/CHNFE"),alltrim(nfe_text->conteudo))
                if !nfe_nota(cChaveNfe) // dados do cabeûalho da nota
                    lErro := .t.
                    exit
                endif
                /*
                nfe_prod(cChaveNfe) 
                nfe_Emit(cChaveNfe)
                nfe_dupl()
                */
            //endif
        endif
        Calibra(10,10,.f.,,nI,len(aArquivos))
    next
    RestWindow(cTela2)
    if lErro
       return
    endif 
    if nXmlRecebidos = 0
        Mens({"N'o existe XML para o destinatario"})
        DesativaF4()
        FechaDados()
        RestWindow(cTela)
        return
    else
        Mens({"Total de "+str(nXmlRecebidos,3,0)+" importado(s)"})
    endif
    FechaDados()
    RestWindow(cTela)
    return
//*********************************************************************************************
procedure AtualizarProdutoXml
    local cTela := SaveWindow()
    private aNota :={},aCodigo := {},aCodBarra := {},aDescricao := {}
    private aNcm := {},aEmbPro := {},aQteEmb := {},aCst := {},aNat := {}
    private aPcoVen := {},aOrig := {},aNatFora := {},aPcoCust := {},aQuant := {}
    private aCstNfeProd := {},aVrTotal := {},aUnd := {},aCest := {},aCfop := {}

    // Dados dos produtos sem codigo    
    private aNota2 := {},aSayCodigo2 := {},aSayDescricao2 := {},aSayDescricao22 := {}
    private aSayNcm2 := {},aSayChave2 := {}
    private aSayCfop2 := {},aSayCst2 := {},aSayOrig2 := {},aSayCodFor2 := {},aSayUnd2 := {}
    private aSayQtd2 := {},aSayVlrUnit2 := {},aSayVrTotal2 := {}
    private aGetCodigo2 := {},aGetCst2:= {},aGetNat2 := {},aGetPcoVen2 := {},aGetCodBarra2 := {}
    private aGetEmbPro2 := {},aGetQteEmb2 := {}
    
    Msg(.t.)
    Msg("Aguarde: Abrindo os arquivos")
    if !OpenTabelaNfe_Nota()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenTabelaNfe_Emit()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenTabelaNfe_Prod()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenTabelaNfe_Dupl()
        FechaDados()
        Msg(.f.)
        return
    endif
	if !OpenSequencia()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenUnidadeDeMedida()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenSitTrib()
		FechaDados()
		Msg(.f.)
		return
	endif
    if !OpenFornecedor()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenCidades()
        FechaDados()
        Msg(.f.)
        return
    endif
	if !OpenNatureza()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenProdutos()
		FechaDados()
		Msg(.f.)
        return
	endif
    if !OpenProdutoFornecedor()
        FechaDados()
        Msg(.f.)
        return
    endif
    Msg(.f.)
    AtualizarFornecedor()
    
    ProcessarProdutos()

    ProdutosSemCodigoDeBarras()
    
    ProdutosComCodigoDeBarras()
    
    DesativaF4()
    FechaDados()
    RestWindow(cTela)
    return
//*********************************************************************************************
static procedure ProcessarProdutosComEAN

    // fun◊'o verificar e campo do codigo de ' valid e n'o for vazio
    if VerificarEAN(nfe_prod->ean)
        // verifica se o produto n'o esta cadastro
        if !Produtos->(dbsetorder(5),dbseek(nfe_prod->ean))
            nfe_nota->(dbsetorder(1),dbseek(nfe_prod->chave))
            if ascan(aCodBarra,nfe_prod->ean) == 0
                aadd(aNota,transform(strzero(val(nfe_nota->numero)),"@r 999.999.999")+" "+nfe_nota->serie+' '+dtoc(nfe_nota->emissao))
                aadd(aCodigo,nfe_prod->codigo)
                aadd(aCodBarra,nfe_prod->ean)
                aadd(aDescricao,left(nfe_prod->descri,50))
                aadd(aNcm,nfe_prod->ncm)
                aadd(aEmbPro,space(04))
                aadd(aQteEmb,0)
                aadd(aCst,space(03))
                aadd(aNat,space(03))
                aadd(aNatFora,space(03))
                aadd(aPcoVen,0.00)
                aadd(aOrig,nfe_prod->orig)
                aadd(aCstNfeProd,nfe_prod->cst)
                aadd(aPcoCust,nfe_prod->unidade)
                aadd(aQuant,nfe_prod->Qtd)
                aadd(aVrTotal,nfe_prod->vrtotal)
                aadd(aUnd,nfe_prod->und)
                aadd(aCest,nfe_prod->cest)
                aadd(aCfop,nfe_prod->cfop)
            endif
        // se produto estiver cadastrado.
        else
            // se o ncm for diferente do que esta no arquivo de produtos
            // faz a atualiza◊'o 
            if !(Produtos->codncm == nfe_prod->ncm)
                do while Produtos->(!Trava_Reg())
                enddo
                Produtos->CodNcm := nfe_prod->ncm
                Produtos->(dbcommit())
                Produtos->(dbunlock())
            endif
        endif
    endif
    return
//****************************************************************************************    
static procedure ProcessarProdutosSemEAN

    if !VerificarEAN(nfe_prod->ean)
        nfe_emit->(dbsetorder(1),dbseek(nfe_prod->chave))
        Fornecedor->(dbsetorder(4),dbseek(nfe_emit->cnpj))
        // verifica se tem o produto do fornecedor esta cadastrado ou relacionando
        if !ProdutoFornecedor->(dbsetorder(3),dbseek(Fornecedor->CodFor+nfe_prod->codigo))
            if empty(ProdutoFornecedor->CodPro)
                nfe_nota->(dbsetorder(1),dbseek(nfe_prod->chave))
                aadd(aNota2,transform(strzero(val(nfe_nota->numero),9),"@r 999.999.999")+"-"+nfe_nota->serie)
                aadd(aSayCodigo2,nfe_prod->codigo)
                aadd(aSayDescricao2,left(nfe_prod->descri,50))
                aadd(aSayDescricao22,nfe_prod->descri)
                aadd(aSayNcm2,nfe_prod->ncm)
                aadd(aSayCst2,nfe_prod->cst)
                aadd(aSayCfop2,nfe_prod->cfop)
                aadd(aSayOrig2,nfe_prod->orig)
                aadd(aSayUnd2,nfe_prod->und)
                aadd(aSayCodFor2,Fornecedor->CodFor)
                aadd(aSayQtd2,nfe_prod->qtd)
                aadd(aSayVlrUnit2,nfe_prod->unidade)
                aadd(aSayVrTotal2,nfe_prod->vrtotal)
                aadd(aGetCodigo2,space(6))
                aadd(aGetCodBarra2,nfe_prod->ean)                
                aadd(aGetEmbPro2,space(04))
                aadd(aGetQteEmb2,0)
                aadd(aGetCst2,space(03))
                aadd(aGetNat2,space(03))
                aadd(aGetPcoVen2,0.00)
            endif
        endif
    endif
    return
//*************************************************************************************        
procedure ProcessarProdutos
    // variòveis para produtos com codigo de barras mas n'o cadastro
    local nI := 0,nA := 0
    
    
    Calibra(10,10,.t.,"Aguarde: Processando os produtos")
    
    nfe_prod->(dbgotop())
    nI := 0 
    nA := nfe_prod->(lastrec())
    
    do while nfe_prod->(!eof())
        ProcessarProdutosComEAN()
        ProcessarProdutosSemEAN()
        Calibra(10,10,.f.,,nI,nA)
        nfe_prod->(dbskip())
        nI += 1
    enddo
    return
    
procedure ProdutosComCodigoDeBarras

    local aTitulo := {},aCampo := {},aMascara := {}
    
    if len(aNota) > 0
        Mens({"Existe "+alltrim(str(len(aNota)))+" produtos com c¢digo de barras n∆o cadastrado"})
    else
        return
    endif
    aTitulo  := {"Nr.Nota - Serie - Emissao","Codigo","Descricao"}
    aCampo   := {"aNota","aCodigo","aDescricao"}
    aMascara := {"@!","@!","@!"}
    cTela := SaveWindow()
    Rodape("Esc-Encerra ")
    Window(03,00,33,100,"> Produtos com c¢digo de barras n∆o cadastrados no sistema <")
    @ 33,05 say "F8-Sair | ENTER-Cadastrar " color Cor(26)
    do while .t.
        Edita_Vet(04,01,32,98,aCampo,aTitulo,aMascara,"vProdXml",,,3)
        if lastkey() == K_F8 
            exit
        elseif lastkey() == K_F2
            if !Confirm("Confirma os produtos")
                loop
            endif
            exit
        endif
    enddo
    if lastkey() == K_F8
        DesativaF4()
        FechaDados()
        RestWindow(cTela)
        return
    endif
    return
//******************************************************************************
function vProdXml(Pos_H,Pos_V,Ln,Cl,Tecla) // Gets dos Itens do Pedido
   Local GetList := {},cCampo,cCor := setcolor(),cCodigo,cLixo

	If Tecla = K_ENTER
		// ** Codigo do Produto
		if Pos_H == 1 .or. Pos_H == 2 .or. Pos_H == 3
            TelaProdXml(Pos_V)
         endif
   elseif Tecla == K_F8
      return(0)
   EndIf
   Return( 1 )
//******************************************************************************
procedure TelaProdXml(nPosicao)
    local cTela := SaveWindow()
    local cEmbPro,nQtdEmb,cCst,cNat,nPcoVenda,cNatFora
    
    AtivaF4()
    Window(08,00,25,78,"> Produto <")
    setcolor(Cor(11))
    //           1234567890123456789012345678901234567890123456789012345678901234567890123456789
    //                    1         2         3         4         5         6         7
    @ 10,01 say "        C¢digo:"
    @ 11,01 say "C¢d. de barras:"
    @ 12,01 say "     Descriá∆o:"
    @ 13,01 say "           NCM:            CEST:           CST/CSOSN:    CFOP:"
    @ 14,01 say "    Quantidade:              Valor Unitario:"
    @ 15,01 say "   Valor Total:"
    @ 16,01 say "       Unidade:"
    @ 17,01 say replicate(chr(196),77) 
    @ 18,01 say "            Embalagem:      x"
    @ 19,01 say "                  CST:"
    @ 20,01 say "       Preáo de venda:"
    @ 21,01 say "Nat. dentro do estado:" 
    @ 22,01 say "  Nat. fora do estado:"
    
    do while .t.
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))    
        @ 10,17 say aCodigo[nPosicao]
        @ 11,17 say aCodBarra[nPosicao]
        @ 12,17 say left(aDescricao[nPosicao],60)
        @ 13,17 say aNcm[nPosicao]
        @ 13,34 say aCest[nPosicao]
        @ 13,55 say aCstNfeProd[nPosicao]
        @ 13,64 say aCfop[nPosicao]
        @ 14,17 say aQuant[nPosicao] picture "@e 999,999.999" 
        @ 14,46 say aPcoCust[nPosicao] picture "@e 999,999,999.999"
        @ 15,17 say aVrTotal[nPosicao] picture "@e 999,999,999.999"
        @ 16,17 say aUnd[nPosicao]        
         
        cEmbPro := aEmbPro[nPosicao]
        nQteEmb := aQteEmb[nPosicao]
        cCst    := aCst[nPosicao]
        nQteEmb := aQteEmb[nPosicao]
        cNat    := aNat[nPosicao]
        nPcoVenda := aPcoVen[nPosicao]
        cNatFora := aNatFora[nPosicao]
        // **************************************** 
        @ 18,24 get cEmbPro picture "@k!";
				when Rodape("Esc-Encerra | F4-Unidades de Medidas");
				valid NoEmpty(cEmbPro) .and. Busca(cEmbPro,"UnidadeDeMedida",1,,,,;
					{"Unidade de Medida nao cadastrada"},.f.,.f.,.f.)
        
        @ 18,31 get nQteEmb picture "@k 999";
            valid NoEmpty(nQteEmb)
            
        @ 19,24 get cCst picture "@k 999";
			when Rodape("Es-Encerra | F4-Sit.Tributaria");
			valid Busca(@cCst,"SitTrib",1,row(),col(),"'-'+left(SitTrib->DesFis,50)",;
				{"Situacao tributaria nao cadastrada"},.f.,.f.,.f.)
                
        @ 20,24 get nPcoVenda picture "@ke 999,999.99";
                when Rodape("Esc-Encerra");
                valid NoEmpty(nPcoVenda)
                
        
        @ 21,24 get cNat picture "@k 999";
				when Rodape("Esc-Encerra | F4-Natureza de Operacao");
				valid iif(empty(cNat),.t.,Busca(Zera(@cNat),"Natureza",1,row(),col(),"'  CFOP: '+Natureza->Cfop",;
					{"Natureza Nao Cadastrada"},.f.,.f.,.f.))
        @ 22,24 get cNatFora picture "@k 999";
				when Rodape("Esc-Encerra | F4-Natureza de Operacao");
				valid iif(empty(cNatFora),.t.,Busca(Zera(@cNatFora),"Natureza",1,row(),col(),"'  CFOP: '+Natureza->Cfop",;
					{"Natureza Nao Cadastrada"},.f.,.f.,.f.))
        
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE) 
        if lastkey() == K_ESC
            exit
        endif
        if !Confirm("Confirma os dados")
            loop
        endif
        aEmbPro[nPosicao] := cEmbPro
        aQteEmb[nPosicao] := nQteEmb
        aCst[nPosicao] := cCst
        aNat[nPosicao] := cNat
        aPcoVen[nPosicao] := nPcoVenda
        aNatFora[nPosicao] := cNatFora
        if !Produtos->(dbsetorder(5),dbseek(aCodbarra[nposicao]))
            do while Sequencia->(!Trava_Reg())
            enddo
            Sequencia->Produtos +=1
            do while Produtos->(!Adiciona())
            enddo
            Produtos->CodPro := strzero(Sequencia->Produtos,6)
            Produtos->DesPro := aDescricao[nPosicao]
            Produtos->FanPro := left(aDescricao[nPosicao],50)
            Produtos->PcoVen := nPcoVenda
            Produtos->PcoCal := nPcoVenda
            Produtos->CodFis := cNat
            Produtos->EmbPro := cEmbPro
            Produtos->QteEmb := nQteEmb
            Produtos->CodBar := aCodBarra[nPosicao]
            Produtos->CodNcm := aNcm[nPosicao]
            Produtos->Cest := aCest[nPosicao]
            Produtos->CtrLes := "S"
            Produtos->Cst := cCst
            Produtos->Origem := aOrig[nPosicao]
            Produtos->Ativo := "S"
            Produtos->NatSaiDent := cNat
            Produtos->NatSaiFora := cNatFora
            Produtos->(dbunlock())
            Produtos->(dbcommit())
            Sequencia->(dbunlock())
        else
            do while Produtos->(!Trava_Reg())
            enddo
            Produtos->PcoVen := nPcoVenda
            Produtos->PcoCal := nPcoVenda
            Produtos->CodFis := cNat
            Produtos->EmbPro := cEmbPro
            Produtos->QteEmb := nQteEmb
            Produtos->CodBar := aCodBarra[nPosicao]
            Produtos->CodNcm := aNcm[nPosicao]
            Produtos->CtrLes := "S"
            Produtos->Cst := cCst
            Produtos->Origem := aOrig[nPosicao]
            Produtos->Ativo := "S"
            Produtos->NatSaiDent := cNat
            Produtos->NatSaiFora := cNatFora
            Produtos->(dbcommit())
            Produtos->(dbunlock())
        endif
        exit
    enddo
    DesativaF4()
    RestWindow(cTela)
    return
//*************************************************************************************************    
static function VerificarEAN(cCodBarras)
    local nI
    
    if empty(cCodBarras)
        return(.f.)
    endif
    for nI := 1 to len(rtrim(cCodBarras))
        if !(substr(cCodBarras,nI,1) $ "01234567890")
            return(.f.)
        endif
    next
    return(.t.)
//*************************************************************************************************    
static procedure ProdutosSemCodigoDeBarras
    local nI := 0,aTitulo := {},aCampo := {},aMascara := {}
    
    if len(aNota2) > 0
        Mens({"Existe "+alltrim(str(len(aNota2)))+" produtos sem c¢digo de barras na nota"})
    else
        return
    endif
    aadd(aTitulo,"Nr.Nota-Serie")
    aadd(aTitulo,"Codigo")
    aadd(aTitulo,"Descricao")
    aadd(aCampo,"aNota2")
    aadd(aCampo,"aSayCodigo2")
    aadd(aCampo,"aSayDescricao2")
    aadd(aMascara,"@!")
    aadd(aMascara,"@!")
    aadd(aMascara,"@!")
    cTela := SaveWindow()
    Rodape("Esc-Encerra")
    Window(03,00,33,100,"> Produtos sem c¢digo de barras <")
    @ 33,05 say " F2-Confirma | F8-Encerrar | ENTER-Cadastra " color Cor(26)
    do while .t.
        Edita_Vet(04,01,32,98,aCampo,aTitulo,aMascara,"vProdXml2",,.f.,3)
        if lastkey() == K_F8 
            exit
        elseif lastkey() == K_F2
            if !Confirm("Confirma os produtos")
                loop
            endif
            exit
        endif
    enddo
    if lastkey() == K_F8
        RestWindow(cTela)
        return
    endif
    Msg(.t.)
    Msg("Aguarde: Gravando produtos")
    for nI := 1 to len(aSayCodigo2)
        if !empty(aGetEmbPro2[nI])
            if empty(aGetCodigo2[nI])
                do while Sequencia->(!Trava_Reg())
                enddo
                Sequencia->Produtos += 1
                do while Produtos->(!Adiciona())
                enddo
                Produtos->CodPro := strzero(Sequencia->Produtos,6,0)
                Produtos->DesPro := aSayDescricao22[nI]
                Produtos->FanPro := aSayDescricao2[nI]
                Produtos->EmbPro := aGetEmbPro2[nI]
                Produtos->QteEmb := aGetQteEmb2[nI]
                Produtos->PcoVen := aGetPcoVen2[nI]   // ** Preûo de Venda
                Produtos->CodBar := aGetCodBarra2[nI]   // ** Codigo de Barras
                Produtos->PcoCal := aGetPcoVen2[nI]   // ** Preûo Calculado
                Produtos->CtrlEs := "S"   // ** Controla estoque
                Produtos->CodNCM := aSayNcm2[nI]   // ** Codigo do NCM
                Produtos->Origem := aSayOrig2[nI]   // ** Origem da mercadoria
                Produtos->Ativo  := "S"
                Produtos->NatSaiDent := aGetNat2[nI]
                Produtos->Cst := aGetCst2[nI]   
                Produtos->(dbcommit())
                Produtos->(dbunlock())
                do while ProdutoFornecedor->(!Adiciona())
                enddo
                ProdutoFornecedor->CodFor := aSayCodFor2[nI]
                ProdutoFornecedor->ProdFor := aSayCodigo2[nI]
                ProdutoFornecedor->CodPro  := strzero(Sequencia->Produtos,6,0)
                ProdutoFornecedor->(dbcommit())
                ProdutoFornecedor->(dbunlock())
                Sequencia->(dbunlock())
            else
                if !ProdutoFornecedor->(dbsetorder(1),dbseek(aSayCodFor2[nI]+aSayCodigo2[nI]+aGetCodigo2[nI]))
                    do while ProdutoFornecedor->(!Adiciona())
                    enddo
                    ProdutoFornecedor->CodFor := aSayCodFor2[nI]
                    ProdutoFornecedor->ProdFor := aSayCodigo2[nI]
                    ProdutoFornecedor->CodPro  := aGetCodigo2[nI]
                    ProdutoFornecedor->(dbcommit())
                    ProdutoFornecedor->(dbunlock())
                endif
            endif
        endif
    next
    Msg(.f.)
    return
    
function vProdXml2(Pos_H,Pos_V,Ln,Cl,Tecla) // Gets dos Itens do Pedido
    Local GetList := {},cCampo,cCor := setcolor(),cCodigo,cLixo

    if Tecla == K_ENTER
        if Pos_H == 1 .or. Pos_H == 2 .or. Pos_H == 3
            TelaProdXmlSem(Pos_V)
        endif
    elseif Tecla == K_F2 .or. Tecla == K_F8
        return(0)
    EndIf
    Return( 1 )
    
procedure TelaProdXmlSem(nPosicao)
    local cTela := SaveWindow()
    local cEmbPro,nQtdEmb,cCst,cNat,nPcoVenda,cCodPro := space(06)
    local cCodBarras := space(14)
    
    AtivaF4()
    Window(10,00,30,81,"> Produto <")
    setcolor(Cor(11))
    //           123456789012345678901234567890123456789012345678901234567890
    //                    1         2         3         4         5         6
    @ 12,01 say "         C¢digo:"
    @ 13,01 say "      Descriá∆o:"
    @ 14,01 say "            NCM:"
    @ 15,01 say "           CFOP:            CST:"
    @ 16,01 say "        Unidade:"
    @ 17,01 say "     Quantidade:"
    @ 18,01 say " Valor unitario:"
    @ 19,01 say "    Valor total:"
    @ 20,01 say replicate(chr(196),80)
    @ 21,01 say "Cod. no sistema:"
    @ 22,01 say "      Descriá∆o:"
    @ 23,01 say " Cod. de Barras:"
    @ 24,01 say "      Embalagem:      x"
    @ 25,01 say "           Cst :"
    @ 26,01 say "  Nat. de sa°da:"
    @ 27,01 say " Preáo de venda:"
    do while .t.
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))    
        @ 12,18 say aSayCodigo2[nPosicao]
        @ 13,18 say left(aSayDescricao2[nPosicao],60)
        @ 14,18 say aSayNcm2[nPosicao]
        
        
        @ 15,18 say aSayCfop2[nPosicao]
        @ 15,34 say aSayCst2[nPosicao]
        
        @ 16,18 say aSayUnd2[nPosicao]
        @ 17,18 say aSayQtd2[nPosicao] picture "@e 999,999,999.9999"
        @ 18,18 say aSayVlrUnit2[nPosicao] picture "@e 999,999,999.9999"
        @ 19,18 say aSayVrtotal2[nPosicao] picture "@e 9,999,999,999.99"

        cCodPro   := aGetCodigo2[nPosicao]
        cCst      := aGetCst2[nPosicao]
        cCodBarra := aGetCodBarra2[nPosicao]        
        cEmbPro   := aGetEmbPro2[nPosicao]
        nQteEmb   := aGetQteEmb2[nPosicao]
        cNat      := aGetNat2[nPosicao]
        nPcoVenda := aGetPcoVen2[nPosicao]
        // ****************************************
        @ 21,18 get cCodPro picture "@k 999999"; 
					when Rodape("Esc-Encerra | F4-Produtos | Deixe em branco caso produto seja novo") ;
	  				valid iif(empty(cCodPro),.t.,Busca(Zera(@cCodPro),"Produtos",1,22,18,"left(produtos->despro,60)",{"Produto Nao Cadastrado"},.f.,.f.,.f.))
                    
        @ 23,18 get cCodBarras picture "@k";
                    when Rodape("Esc-Encerra")
        
        @ 24,18 get cEmbPro picture "@k!";
				when Rodape("Esc-Encerra | F4-Unidades de Medidas");
				valid NoEmpty(cEmbPro) .and. Busca(cEmbPro,"UnidadeDeMedida",1,,,,;
					{"Unidade de Medida nao cadastrada"},.f.,.f.,.f.)
        
        @ 24,25 get nQteEmb picture "@k 999";
                    valid NoEmpty(nQteEmb)
                    
        @ 25,18 get cCst picture "@k 999";
                when Rodape("Esc-Encerra")
        
        @ 26,18 get cNat picture "@k 999";
				when Rodape("Esc-Encerra | F4-Natureza de Operacao");
				valid iif(empty(cNat),.t.,Busca(Zera(@cNat),"Natureza",1,row(),col(),"'  CFOP: '+Natureza->Cfop",;
					{"Natureza Nao Cadastrada"},.f.,.f.,.f.))
        
        @ 27,18 get nPcoVenda picture "@ke 999,999.99";
                when Rodape("Esc-Encerra")
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE) 
        if lastkey() == K_ESC
            exit
        endif
        if !Confirm("Confirma os dados")
            loop
        endif
        aGetCodigo2[nPosicao] := cCodPro
        aGetCodBarra2[nPosicao] := cCodBarras                
        aGetEmbPro2[nPosicao] := cEmbPro
        aGetQteEmb2[nPosicao] := nQteEmb
        aGetCst2[nPosicao] := cCst
        aGetNat2[nPosicao] := cNat
        aGetPcoVen2[nPosicao] := nPcoVenda
        exit
    enddo
    DesativaF4()
    RestWindow(cTela)
    return

//************************************************************
static function recebeXML( cFileName, cNode, cAttrib, cValue, cData )
//********************************************************************************
       LOCAL hFile, cXml
       LOCAL xmlDoc, xmlIter , xmlNode
    
       SET EXACT OFF
    
       IF cFileName == NIL
          cFileName := "teste.xml"
       ENDIF
    
       // this can happen if I call xmltest filename "" cdata
       IF ValType( cNode ) == "C" .and. Len( cNode ) == 0
          cNode := NIL
       ENDIF
    
       // this can happen if I call xmltest filename "" cdata
       IF ValType( cAttrib ) == "C" .and. Len( cAttrib ) == 0
          cAttrib := NIL
       ENDIF
    
       // this can happen if I call xmltest filename "" cdata
       IF ValType( cValue ) == "C" .and. Len( cValue ) == 0
          cValue := NIL
       ENDIF
    
       hFile := FOpen( cFileName )
    
       IF hFile == -1
          @3, 10 SAY "Nao Localizou o arquivo:"
          @3, 34 say  cFileName
          @4,10 SAY "Finalizando o processo"
          Inkey( 0 )
          RETURN(.f.)
       ENDIF
       xmlDoc := TXmlDocument():New( hFile )
       IF xmlDoc:nStatus != HBXML_STATUS_OK
          fclose(hFile)
          return(.f.)
          //@10,10 SAY "Error While Processing File: "
          //@11,10 SAY "          On Line: " + AllTrim( Str( xmlDoc:nLine ) )
          //@12,10 SAY "            Error: " + HB_XmlErrorDesc( xmlDoc:nError )
          //@13,10 SAY " Tag Error on tag: " + xmlDoc:oErrorNode:cName
          //@14,10 SAY "Tag Begun on line: " + AllTrim( Str( xmlDoc:oErrorNode:nBeginLine ) )
          //@15,10 SAY "Program Terminating, press any key"
          //Inkey( 0 )
          //RETURN
       ENDIF
       xmlIter := TXmlIterator():New( xmlDoc:oRoot )
       xmlNode := xmlIter:Find()
       xcont:=""
       DO WHILE xmlNode != NIL
          cXml := xmlNode:Path()
          IF cXml == NIL
             cXml :=  "(Node without path)"
          ENDIF
          xvar1:= Alltrim( Str( xmlNode:nType ) )
          xvar2:= xmlNode:cName
          xvar3:= ValToPrg( xmlNode:aAttributes )
          xvar4:= xmlNode:cData
          xchave:=alltrim(upper(cXml))
          xvar5:= SUBSTR(xchave,at("/NFE/",xchave),LEN(CXML))
          if xvar1=nil
             xvar1:=""
          endif
          if xvar2=nil
             xvar2:=""
          endif
          if xvar3=nil
             xvar3:=""
          endif
          if xvar4=nil
             xvar4:=""
          endif
          if xvar5=nil
             xvar5:=""
          endif
          xchave:=alltrim(upper(xvar5))
          nfe_text->(dbappend())
          nfe_text->campo := upper(xvar2)
          nfe_text->tipo  := upper(xvar3)
          nfe_text->conteudo := xvar4
          nfe_text->chave := xchave
          if alltrim(upper(xvar2))="DET"   //Inicio do Campo Produtos pegar o contador a incluir na chave
             xcont=strzero(val(substr(xvar3,15,3)),3)
          endif
          if alltrim(upper(xvar2))="TOTAL"   //Final,totalizando e zerando o XCONT nao totalizar mais o DET que sao os produtos.
             xcont=""
          endif
          if !empty(xcont)
             nfe_text->chave := xchave+xcont
          endif
          xmlNode := xmlIter:Next()
       ENDDO
    
       IF cNode != NIL .or. cAttrib != NIL .or. cValue != NIL .or. cData != NIL
          xmlIter := TXmlIteratorRegex():New( xmlDoc:oRoot )
          IF cNode != NIL
                cNode := HB_RegexComp( cNode )
          ENDIF
          IF cAttrib != NIL
                cAttrib := HB_RegexComp( cAttrib )
          ENDIF
          IF cValue != NIL
                cValue := HB_RegexComp( cValue )
          ENDIF
          IF cData != NIL
                cData := HB_RegexComp( cData )
          ENDIF
          xmlNode := xmlIter:Find( cNode, cAttrib, cValue, cData )
          WHILE xmlNode != NIL
       *        ? "Found node ", xmlNode:Path() , ValToPrg( xmlNode:ToArray() )
                xmlNode := xmlIter:Next()
          ENDDO
       ENDIF
       fclose(hFile)
       RETURN(.t.)

function nfe_nota(cChave)
    local cQuery,oQuery

    cQuery := "SELECT chave from administrativo.nfe_nota WHERE chave = "+StringToSql(cChave)
    if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
        oQuery:Close()
        return(.f.)
    endif
    if oQuery:lastrec() > 0
        return(.t.)
    endif
    cQuery := "INSERT INTO administrativo.nfe_nota (chave,numero,cnpj,modelo,serie,crt,emissao,"
    cQuery += "saida,indpag,bc,icms,bcst,st,prod,vr_cont,frete,seg,desconto,ii,ipi,pis,cofins,tiponf,modfrete) "
    cQuery += "VALUES ("
    cQuery += StringToSql(cChave)+","
    cQuery += StringToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/IDE/NNF"),strzero(val(alltrim(NFE_TEXT->conteudo)),9)))+","
    cQuery += StringToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/EMIT/CNPJ" ),alltrim(NFE_TEXT->conteudo)))+","
    cQuery += StringToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/IDE/MOD" ),alltrim(NFE_TEXT->conteudo)))+","
    cQuery += StringToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/IDE/SERIE" ),strzero(val(alltrim(NFE_TEXT->conteudo)),3,0)))+","
    cQuery += StringToSql(nfe_text->(dbseek("/NFE/INFNFE/EMIT/CRT"),alltrim(nfe_text->conteudo)))+","
    cQuery += DateToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/IDE/DHEMI" ),ctod(substr(NFE_TEXT->conteudo,9,2)+"/"+substr(NFE_TEXT->conteudo,6,2)+"/"+substr(NFE_TEXT->conteudo,1,4))))+","
    cQuery += DateToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/IDE/DHEMI"),ctod(substr(NFE_TEXT->conteudo,9,2)+"/"+substr(NFE_TEXT->conteudo,6,2)+"/"+substr(NFE_TEXT->conteudo,1,4))))+","
    cQuery += StringToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/IDE/INDPAG"),alltrim(NFE_TEXT->conteudo)))+","
    cQuery += NumberToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/TOTAL/ICMSTOT/VBC"),val(ALLTRIM(NFE_TEXT->conteudo))),12,2)+","
    cQuery += NumberToSql(nfe_text->(dbseek("/NFE/INFNFE/TOTAL/ICMSTOT/VICMS"),val(alltrim(NFE_TEXT->conteudo))),12,2)+","
    cQuery += NumberToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/TOTAL/ICMSTOT/VBCST"),val(alltrim(NFE_TEXT->conteudo))),12,2)+","
    cQuery += NumberToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/TOTAL/ICMSTOT/VST"),val(ALLTRIM(NFE_TEXT->conteudo))),12,2)+","
    cQuery += NumberToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/TOTAL/ICMSTOT/VPROD"),val(ALLTRIM(NFE_TEXT->conteudo))),12,2)+","
    cQuery += NumberToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/TOTAL/ICMSTOT/VNF"), val(ALLTRIM(NFE_TEXT->conteudo))),12,2)+","
    cQuery += NumberToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/TOTAL/ICMSTOT/VFRETE" ),val(ALLTRIM(NFE_TEXT->conteudo))),12,2)+","
    cQuery += NumberToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/TOTAL/ICMSTOT/VSEG"),val(ALLTRIM(NFE_TEXT->conteudo))),12,2)+","
    cQuery += NumberToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/TOTAL/ICMSTOT/VDESC"),val(ALLTRIM(NFE_TEXT->conteudo))),12,2)+","
    cQuery += NumberToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/TOTAL/ICMSTOT/VII"), val(ALLTRIM(NFE_TEXT->conteudo))),12,2)+","
    // ipi
    cQuery += NumberToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/TOTAL/ICMSTOT/VIPI"),val(ALLTRIM(NFE_TEXT->conteudo))),12,2)+","
    // Pis
    cQuery += NumberToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/TOTAL/ICMSTOT/VPIS"), val(ALLTRIM(NFE_TEXT->conteudo))),12,2)+","
    // confins
    cQuery += NumberToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/TOTAL/ICMSTOT/VCOFINS"), val(ALLTRIM(NFE_TEXT->conteudo))),12,2)+","
    cQuery += StringToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/IDE/TPNF"),alltrim(NFE_TEXT->conteudo)))+","
    cQuery += StringToSql(nfe_text->(dbseek("/NFE/INFNFE/TRANSP/MODFRETE"),alltrim(nfe_text->conteudo)))
    cQuery += ")"
    oServer:StartTransaction()
    if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
        oQuery:Close()
        oServer:Rollback()
        return(.f.)
    endif
    oServer:Commit()
return(.t.)
           
procedure nfe_prod(cChave)
    local aCST := {},cQuery,oQuery
 
    
    cQuery := "select chave from administrativo.nfe_prod WHERE chave = "+StringToSql(cChave)
    if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
        oQuery:Close()
        return(.f.)
    endif
    if oQuery:lastrec() > 0
        return(.t.)
    endif
    cCnpjDest := NFE_TEXT->(dbseek("/NFE/INFNFE/DEST/CNPJ"), alltrim(NFE_TEXT->conteudo))
    for i = 1 to 999
        xi:=strzero(i,3)
        NFE_TEXT->(dbseek("/NFE/INFNFE/DET/PROD/XPROD"+xi) )
        if empty(alltrim(NFE_TEXT->conteudo))
            exit
        endif
        if nfe_text->(dbseek("/NFE/INFNFE/EMIT/CRT"),alltrim(nfe_text->conteudo)) $ "1|2"
            aCst := {"101","102","103","201","202","203","300","400","500","900"}
            for nI := 1 to len(aCst)
                if nfe_text->(dbseek("/NFE/INFNFE/DET/IMPOSTO/ICMS/ICMSSN"+aCST[nI]+"/CSOSN"+xi))
                    cCst := alltrim(nfe_text->conteudo)
                endif
            next
        // se for empresa do regime normal
        else
            aCst := {"00","10","20","30","40","41","50","51","60","70","90"}
            for nI := 1 to len(aCST)
                
                // Origem da mercadoria
                if nfe_text->(dbseek("/NFE/INFNFE/DET/IMPOSTO/ICMS/ICMS"+aCST[nI]+"/ORIG"+xi)) 
                    cOrig := alltrim(nfe_text->conteudo)
                endif
                // CST
                if nfe_text->(dbseek("/NFE/INFNFE/DET/IMPOSTO/ICMS/ICMS"+aCST[nI]+"/CST"+xi))
                    cCst := alltrim(nfe_text->conteudo) 
                endif
                // aliquota de icms
                if nfe_text->(dbseek("/NFE/INFNFE/DET/IMPOSTO/ICMS/ICMS"+aCST[nI]+"/PICMS"+xi))
                    nAlicm := val(alltrim(nfe_text->conteudo))
                endif 
                // Pis cst
                if nfe_text->(dbseek("/NFE/INFNFE/DET/IMPOSTO/PIS/PISALIQ/CST"+xi))
                    cPis_Cst := alltrim(nfe_text->conteudo)
                endif
                // Pis valor da base de calculo
                if nfe_text->(dbseek("/NFE/INFNFE/DET/IMPOSTO/PIS/PISALIQ/VBC"+xi))
                    nPis_vbc := val(alltrim(nfe_text->conteudo))
                endif
                // Pis aliquota
                if nfe_text->(dbseek("/NFE/INFNFE/DET/IMPOSTO/PIS/PISALIQ/PPIS"+xi))
                    nPis_ppis := val(alltrim(nfe_text->conteudo))
                endif
                // Pis valor
                if nfe_text->(dbseek("/NFE/INFNFE/DET/IMPOSTO/PIS/PISALIQ/VPIS"+xi))
                    npis_vpis := val(alltrim(nfe_text->conteudo)) 
                endif
                // Cofins cst
                if nfe_text->(dbseek("/NFE/INFNFE/DET/IMPOSTO/COFINS/COFINSALIQ/CST"+xi))
                    cCofins_cst := alltrim(nfe_text->conteudo)
                endif
                // Pis valor da base de calculo
                if nfe_text->(dbseek("/NFE/INFNFE/DET/IMPOSTO/COFINS/COFINSALIQ/VBC"+xi))
                    nCofins_vbc := val(alltrim(nfe_text->conteudo))
                endif
                // Pis aliquota
                if nfe_text->(dbseek("/NFE/INFNFE/DET/IMPOSTO/COFINS/COFINSALIQ/PCOFINS"+xi))
                    ncofins_p := val(alltrim(nfe_text->conteudo))
                endif
                // Pis valor
                if nfe_text->(dbseek("/NFE/INFNFE/DET/IMPOSTO/COFINS/COFINSALIQ/VCOFINS"+xi))
                    nCofins_v := val(alltrim(nfe_text->conteudo)) 
                endif
            next
        endif
        cQuery := "INSERT INTO administrativo.nfe_prod "
        cQuery += "(chave,codigo,nritem,ean,ncm,cest,und,descricao,orig,cfop,cst,qtd,unidade,vrtotal) "
        cQuery += "VALUES ("
        cQuery += StringToSql(cChave)+","
        cQuery += StringToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/DET/PROD/CPROD"+xi),conteudo))+','
        cQuery += NumberToSql(val(xi))+','
        cQuery += StringToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/DET/PROD/CEAN"+xi),alltrim(conteudo)))+","
        cQuery += StringToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/DET/PROD/NCM"+xi),alltrim(conteudo)))+","
        cQuery += StringToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/DET/PROD/CEST"+xi),alltrim(conteudo)))+","
        cQuery += StringToSql(nfe_text->(dbseek("/NFE/INFNFE/DET/PROD/UCOM"+xi),alltrim(nfe_text->conteudo)))+','
        cQuery += StringToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/DET/PROD/XPROD"+xi),alltrim(NFE_TEXT->conteudo)))+","
        cQuery += StringToSql(cOrig)+","
        cQuery += StringToSql(nfe_text->(dbseek("/NFE/INFNFE/DET/PROD/CFOP"+xi),alltrim(conteudo)))+","
        cQuery += StringToSql(cCst)+","
        // quantidade
        cQuery += NumberToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/DET/PROD/QCOM"+xi),val(alltrim(conteudo))),12,4)+","
        // unidade comercial
        cQuery += NumberToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/DET/PROD/VUNCOM"+xi),val(alltrim(conteudo))),15,4)+","
        // 
        cQuery += NumberToSql(NFE_TEXT->(dbseek("/NFE/INFNFE/DET/PROD/VPROD"+xi),VAL(alltrim(NFE_TEXT->conteudo))),12,2)


        cQuery += ");"
        oServer:StartTransaction()
        if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
            oQuery:Close()
            oServer:Rollback()
            return(.f.)
        endif
        oServer:Commit()
        /*
        nfe_prod->cfop    := NFE_TEXT->(dbseek("/NFE/INFNFE/DET/PROD/CFOP"+xi),alltrim(conteudo))
        nfe_prod->qtd     := xqtd

        nfe_prod->unidade := NFE_TEXT->(dbseek("/NFE/INFNFE/DET/PROD/VUNCOM"+xi),val(alltrim(conteudo)))
        nfe_prod->vrtotal := NFE_TEXT->(dbseek("/NFE/INFNFE/DET/PROD/VPROD"+xi),VAL(alltrim(NFE_TEXT->conteudo)))
             
             // rastreabilidade medicamentos
             nfe_prod->nLote := NFE_TEXT->(dbseek("/NFE/INFNFE/DET/PROD/RASTRO/NLOTE"+xi),alltrim(NFE_TEXT->conteudo))
             nfe_prod->qLote := NFE_TEXT->(dbseek("/NFE/INFNFE/DET/PROD/RASTRO/QLOTE"+xi),VAL(alltrim(NFE_TEXT->conteudo)))
             nfe_prod->dfab := NFE_TEXT->(dbseek("/NFE/INFNFE/DET/PROD/RASTRO/DFAB"+xi),ctod(substr(NFE_TEXT->conteudo,9,2)+"/"+substr(NFE_TEXT->conteudo,6,2)+"/"+substr(NFE_TEXT->conteudo,1,4)))
             nfe_prod->dval := NFE_TEXT->(dbseek("/NFE/INFNFE/DET/PROD/RASTRO/DVAL"+xi),ctod(substr(NFE_TEXT->conteudo,9,2)+"/"+substr(NFE_TEXT->conteudo,6,2)+"/"+substr(NFE_TEXT->conteudo,1,4)))
             nfe_prod->vpmc := NFE_TEXT->(dbseek("/NFE/INFNFE/DET/PROD/MED/VPMC"+xi),VAL(alltrim(NFE_TEXT->conteudo)))
             
             nfe_prod->(dbcommit())
             nfe_prod->(dbunlock())
        */
    next
return
 
             

//** Fim do arquivo

