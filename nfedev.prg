/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 7.00
 * Identificacao: Manutencao de Nota fiscal de devolu‡Æo
 * Prefixo......: LTADM
 * Programa.....: NfeDev.prg
 * Autor........: Andre Lucas Souza
 * Data.........: 12 de Fevereiro de 2017
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

#define CRLF chr(K_ENTER)+chr(K_CTRL_ENTER)

procedure ConNfeDev(lAbrir,lRetorno)
   local oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados,cTela2
   local nCursor := setcursor(),cCor := setcolor(),cCodCaixa,Sai_Mnu := .f.
   local aTitulo := {},aCampo := {},aMascara := {},Inicio,Fim,nPedido1,nPedido2,cFiltro
   local nLin1,nCol1,nLin2,nCol2
   private nRecno

    if lAbrir
        if !AbrirArquivos()
            return
        endif
    else
        setcursor(SC_NONE)
    endif
    select NfeDev
    set order to 1
    goto top
    if lAbrir
      Rodape("Esc-Encerrar")
   else
      Rodape("Esc-Encerra | ENTER-Transfere")
   end
   setcolor(cor(5))
   nLin1 := 02
   nCol1 := 00
   nLin2 := 33
   nCol2 := 100
   Window(nLin1,nCol1,nLin2,nCol2,"> Consulta de Notas Fiscais <")
    oBrow := TBrowseDB(nLin1+1,nCol1+1,nLin2-7,nCol2-1)
    oBrow:headSep := SEPH
    oBrow:footSep := SEPB
    oBrow:colSep  := SEPV
    oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)
       
    oCol := TBColumnNew("Controle",{|| NfeDev->NumCon})
    oCol:colorblock := {|| iif( NfeDev->Autorizado,{1,2},{3,2})}   
	oBrow:addcolumn(oCol)

    oCol := TBColumnNew("Nota/Serie"    ,{|| NfeDev->NumNot+'/'+NfeDev->serie})
    oCol:colorblock := {|| iif( NfeDev->Autorizado,{1,2},{3,2})}   
	oBrow:addcolumn(oCol)
    
    oCol := TBColumnNew("Emissao" ,{|| NfeDev->DtaEmi})
    oCol:colorblock := {|| iif( NfeDev->Autorizado,{1,2},{3,2})}   
	oBrow:addcolumn(oCol)
    
    oCol := tbcolumnnew("Fornecedor" ,;
        {|| Fornecedor->(dbsetorder(1),dbseek(NfeDev->CodFor),NfeDev->CodFor+"-"+left(Fornecedor->RazFor,30))})
    oCol:colorblock := {|| iif( NfeDev->Autorizado,{1,2},{3,2})}   
	oBrow:addcolumn(oCol)
    
    oCol := TBColumnNew("Valor da;Nota" ,{|| NfeDev->vNf})
    oCol:colorblock := {|| iif( NfeDev->Autorizado,{1,2},{3,2})}   
	oBrow:addcolumn(oCol)
    
    setcolor(Cor(26))
    scroll(nLin2-1,nCol1+1,nLin2-1,nCol2-1,0)
    Centro(nLin2-1,nCol1+1,nCol2-1,"F3-Visualizar Itens")
    do while (! lFim)
        do while ( ! oBrow:stabilize() )
            nTecla := INKEY()
            if ( nTecla != 0 )
                exit
            endif
        enddo
        @ nLin2-6,01 say " Situacao: "+NfeDev->CStat Color Cor(11)
        @ nLin2-5,01 say "   Motivo: "+NfeDev->XMotivo color Cor(11)
        
        if empty(NfeDev->chnfe)
            @ nLin2-4,01 say "    Chave: "+space(50) color Cor(11)
        else
            @ nLin2-4,01 say "    Chave: "+transform(NfeDev->chnfe,"9999.9999.9999.9999.9999.9999.9999.9999.9999.9999") color Cor(11)
        endif
        @ nLin2-3,01 say "Protocolo: "+NfeDev->NProt color Cor(11)
        @ nLin2-2,01 say "Data/Hora: "+NfeDev->DhRecBto color Cor(11)
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
            	   if lRetorno
               		   cDados := nfeven->NumCon
               	    else
               		   cDados := NfeVen->NumNot
               	    endif
                    keyboard (cDados)+chr(K_ENTER)
                    lFim := .t.
                endif
            elseif nTecla == K_F3
                //VerItemNot(nfeven->NumCon)
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
    return
//**************************************************************************
procedure IncNfeDev
    local getlist := {},cTela := SaveWindow()
    local lLimpa := .t.
    private cNumCon,cCodFor,dDtaEmi,dDtaSai,cCodNat,lIncluir := .t.
    
    private cTipFre
    private cCodTra
    private cObsNot1
    private cObsNot2
    private cObsNot3
    private cObsNot4
    private cObsNot5
    private cObsNot6
    // Grupo de Volumes
    private nqVol
    private cesp
    private cMarca
    private cnVol
    private nPesoL
    private nPesoB
    
    // Grupo Totais da NF-e
    private nvBc   // Base de calculo do ICMS
    private nvICMS // Valor total do icms
    private nvICMSDeson // Valor total do ICMS desonerado
    private nvBCST // Base de cÿlculo do ICMS ST
    private nvSt // Valor total do ICMS ST
    private nvProd // Valor total dos produtos e servicos
    private nvFrete // Valor total do frete
    private nvSeg // Valor total do seguro
    private nvDesc // Valor total do desconto
    private nvII // Valor total II
    private nvIPI // Valor total do IPI
    private nvPis // Valor total do PIS
    private nvCofins // Valor da COFINS
    private nvOutro // Outras despesas acessorias
    private nvNF // Valor total da nota
    
    Private aCodPro := {} // C½digo do produto
    private aDesPro := {} // descriÎ’o do produto
    private aQtdEmb := {} // unidade e embalagem do produto
    private aQtdPro := {} // quantidade do produto
    private aPcoPro := {} // preÎo de venda do produto
    private aDscPro := {} // Percentual do desconto
    private aPcoLiq := {} // PreÎo Liquido
    private aTotPro := {} // Valor Total bruto do produto
    
    private aFrete  := {}   // Valor do frete
    private aSeguro := {}   // Valor do seguro
    private aDesconto := {} // Valor do desconto (quando houver)
    private aOutro := {}    // Outras despesas acessorias
    
    private aCfop := {}
    
    private aCst := {}
    private aModBc  := {}
    private avBc    := {}  // Valor da base do icms
    private apRedBC := {} // Percentual de reduÎ’o de BC
    private apICMS  := {}  // Aliquota do imposto
    private avICMS  := {} // Valor do imposto
    private amodBCST := {}
    private apMVAST   := {} // Percentual da margem de valor
    private apRedBCST := {} // Percentual de reduÎ’o de BC
    private avBCST     := {} // Valor da BC do ICMS ST
    private apICMSST   := {} // Aliquota do imposto do ICMS ST
    private avICMSST   := {} // Valor do ICMS ST
    private apCredSN   := {} // Al­quota aplicÿvel de cÿlculo do credito
    private avCredICMS := {} // Valor cr'dito do ICMS que pode
    
    // IPI
    private aCstIPI := {}
    private acEnqIPI := {}
    private aBcIpi := {} // Valor da BC do IPI
    private apIPI := {} // aliquota do IPI 
    private avIPI := {} // valor do IPI
    
    
    // PIS
    private aCstPis := {}
    private aAliPis := {}
    
    // COFINS
    private aCstCofins := {}
    private aAliCofins := {}
    
    // Chave da(s) notas fiscais referenciadas
    private aChaveNfeRef := {} 
     
    // Variavel para a criacao da Nfe   
    private cComando
    // ** declara Variaveis de retorno do acbr    
    private cNRec    // n£mero do recibo
    private cCStat
    private cXMotivo // 
    private cChNfe  // chave da acesso
    private cDhRec  // data e hora do recebimento
    private cNProt  // n£mero do protocolo

    if !AbrirArquivos()
        return
    endif
        
    TelaNfeDev(1)
    AtivaF4()
    do while .t.
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        if lLimpa
            cCodFor := space(04)
            dDtaEmi := date()
            dDtaSai := ctod(space(08))
            cCodNat := space(03)
            cTipFre := space(01)
            cCodTra := space(02)
            
            cObsNot1 := Space( 90 )
            cObsNot2 := Space( 90 )
            cObsNot3 := Space( 90 )
            cObsNot4 := Space( 90 )
            cObsNot5 := Space( 90 )
            cObsNot6 := Space( 90 )
            
            // Grupo de volumes transportados
            nqVol  := 0
            cesp   := space(60)
            cMarca := space(60)
            cnVol  := space(60)
            nPesoL := 0
            nPesoB := 0
            
            aCodPro   := {}
            aDesPro   := {}
            aQtdEmb   := {}
            aQtdPro   := {}
            aPcoPro   := {} // preÎo bruto
            aDscPro   := {} // Percentual de desconto
            aPcoLiq   := {} // PreÎo l­quido
            aTotPro   := {} // valor total bruto
            aFrete    := {}
            aSeguro   := {}
            aDesconto := {} // Valor do Desconto
            aOutro    := {}
            aBcIcms   := {} // base de cÿlculo do icms
            aVlIcms   := {} // valor do icms
            
            aCst := {}
            aCfop := {}
            aModBc  := {}
            avBc    := {}  // Valor da base do icms
            apRedBC := {} // Percentual de reduÎ’o de BC
            apICMS  := {}  // Aliquota do imposto
            avICMS  := {} // Valor do imposto
            amodBCST := {}
            apMVAST   := {} // Percentual da margem de valor
            apRedBCST := {} // Percentual de reduÎ’o de BC
            avBCST     := {} // Valor da BC do ICMS ST
            apICMSST   := {} // Aliquota do imposto do ICMS ST
            avICMSST   := {} // Valor do ICMS ST
            apCredSN   := {} // Al­quota aplicÿvel de cÿlculo do credito
            avCredICMS := {} // Valor cr'dito do ICMS que pode
            // IPI            
            aCstIPI := {}
            acEnqIPI := {}
            aBcIpi := {} // Valor da BC do IPI
            apIPI := {} // aliquota do IPI 
            avIPI := {} // valor do IPI
            
            // PIS
            aCstPis := {}
            aAliPis := {}
            // COFINS
            aCstCofins := {}
            aAliCofins := {}
            
            aChaveNfeRef := {}
            
             
        endif
        if Sequencia->LancNfeDev+1 > 9999999999
            Mens({"Numero de lan‡amento atingido","Favor chamar SUPORTE"})
            loop
        endif
        @ 03,13 say strzero(Sequencia->LancNfeDev+1,9)
        
        @ 05,13 get cCodFor picture "@k 9999";
                    when Rodape("Esc-Encerra | F4-Fornecedores");
                    valid Busca(Zera(@cCodfor),"Fornecedor",1,row(),col(),"'-'+Fornecedor->RazFor",{"Fornecedor nÆo cadastrado"},.f.,.f.,.f.)
        @ 06,13 get cCodNat picture "@k 999";
                    when Rodape("Esc-Encerra | F4-Natureza");
                    valid ValidNatureza(@cCodNat) 
        @ 07,13 get dDtaEmi picture "@k";
                    when Rodape("Esc-Encerra")
        @ 07,38 get dDtaSai picture "@k"
        setcursor(SC_NONE)
        read
        setcursor(SC_NORMAL)
        if lastkey() == K_ESC
            exit
        endif
        if lLimpa
            aadd(aCodPro,space(06))
            aadd(aDesPro,Space(50))
            aadd(aQtdEmb,space(08))
            aadd(aQtdPro,0 )
            aadd(aPcoPro,0 )
            aadd(aDscPro,0 ) // Percentual de desconto
            aadd(aPcoLiq,0 ) // preÎo l­quido
            aadd(aDesconto,0) // Valor do Desconto
            aadd(aFrete,0)
            aadd(aSeguro,0)
            aadd(aOutro,0)
            aadd(aTotPro,0)
            aadd(aBcIcms,0) // base de calculo do icms
            aadd(aVlIcms,0) // valor do ICMS
            aadd(aCst,space(03))
            aadd(aCfop,space(04))
            aadd(aModBc,space(01))
            aadd(avBc,0)  // Valor da base do icms
            aadd(apRedBC,0) // Percentual de reduÎ’o de BC
            aadd(apICMS,0)  // Aliquota do imposto
            aadd(avICMS,0) // Valor do imposto
            aadd(amodBCST,space(01))
            aadd(apMVAST,0)// Percentual da margem de valor
            aadd(apRedBCST,0) // Percentual de reduÎ’o de BC
            aadd(avBCST,0)// Valor da BC do ICMS ST
            aadd(apICMSST,0) // Aliquota do imposto do ICMS ST
            aadd(avICMSST,0) // Valor do ICMS ST
            aadd(apCredSN,0) // Al­quota aplicÿvel de cÿlculo do credito
            aadd(avCredICMS,0) // Valor cr'dito do ICMS que pode
            aadd(aCstIPI,space(02)) // IPI
            aadd(acEnqIPI,space(03)) // IPI
            aadd(aBcIpi,0) // Valor da BC do IPI
            aadd(apIPI,0) // aliquota do IPI 
            aadd(avIPI,0) // valor do IPI

            aadd(aCstPis,space(02)) // PIS
            aadd(aAliPis,0) // PIS
            aadd(aCstCofins,space(02)) // COFINS
            aadd(aAliCofins,0) // COFINS
            aadd(aChaveNfeRef,space(44)) 
        endif
        if !NfeDevRef()
            loop
        endif
        if !GetItem()
            loop
        endif
        // Total da NF-e
        nvBc     := Soma_Veto2(avBC) // Base de calculo do ICMS
        nvICMS   := Soma_Veto2(avICMS)// Valor total do icms
        nvICMSDeson := 0 // Valor total do ICMS desonerado
        nvBCST   := Soma_Veto2(avBCST) // Base de cÿlculo do ICMS ST
        nvSt     := Soma_Veto2(avICMSST) // Valor total do ICMS ST
        nvProd   := Soma_Veto2(aTotPro)   // Valor total dos produtos e servicos
        nvFrete  := Soma_Veto2(aFrete)    // Valor total do frete
        nvSeg    := Soma_Veto2(aSeguro)   // Valor total do seguro
        nvDesc   := Soma_Veto2(aDesconto) // Valor total do desconto
        nvII     := 0 // Valor total II
        nvIPI    := Soma_Veto2(avIPI) // Valor total do IPI
        nvPis    := 0 // Valor total do PIS
        nvCofins := 0 // Valor da COFINS
        nvOutro  := Soma_Veto2(aOutro) // Outras despesas acessorias
        // Valor total da nota
        nvNF      := (((nvProd-nvDesc)-nvICMSDeson)+nvST+nvFrete+nvSeg+nvOutro+;
                        nvII+nvIPI)
        
        GravarNFE(.t.)
        GravarItensNFE(.t.)
        GravarNfeDevRef(.t.)
        If Aviso_1( 17,, 22,, [AtenÎ"o!],[Transmitir a NFE ?], { [  ^Sim  ], [  ^N’o  ] }, 1, .t. ) = 1
			if Sequencia->TestarInte == "S"
				lInternet := Testa_Internet()
         		if !lInternet
            		loop
         		endif
         	endif
            NfeDev->(dbsetorder(1),dbseek(cNumCon))
            do while NfeDev->(!Trava_Reg())
            enddo
            do while Sequencia->(!Trava_Reg())
            enddo
            Sequencia->NumNFE  := Sequencia->NumNfe + 1
            NfeDev->NumNot := strzero(Sequencia->NumNfe,09)
            NfeDev->Serie  := Sequencia->SerieNfe
            Sequencia->(dbunlock())
            NfeDev->(dbunlock())
            
            MontarNfeDev()
            
        endif
    enddo
    DesativaF4()
    FechaDados()
    RestWindow(cTela)
    return
//*************************************************************************
procedure AltNfeDev
    local getlist := {},cTela := SaveWindow()
    local lLimpa := .t.
    private cNumCon,cCodFor,dDtaEmi,dDtaSai,cCodNat,lIncluir := .t.
    
    private cTipFre
    private cCodTra
    private cObsNot1
    private cObsNot2
    private cObsNot3
    private cObsNot4
    private cObsNot5
    private cObsNot6
    // Grupo de Volumes
    private nqVol
    private cesp
    private cMarca
    private cnVol
    private nPesoL
    private nPesoB
    
    // Grupo Totais da NF-e
    private nvBc   // Base de calculo do ICMS
    private nvICMS // Valor total do icms
    private nvICMSDeson // Valor total do ICMS desonerado
    private nvBCST // Base de cÿlculo do ICMS ST
    private nvSt // Valor total do ICMS ST
    private nvProd // Valor total dos produtos e servicos
    private nvFrete // Valor total do frete
    private nvSeg // Valor total do seguro
    private nvDesc // Valor total do desconto
    private nvII // Valor total II
    private nvIPI // Valor total do IPI
    private nvPis // Valor total do PIS
    private nvCofins // Valor da COFINS
    private nvOutro // Outras despesas acessorias
    private nvNF // Valor total da nota
    
    Private aCodPro := {} // C½digo do produto
    private aDesPro := {} // descriÎ’o do produto
    private aQtdEmb := {} // unidade e embalagem do produto
    private aQtdPro := {} // quantidade do produto
    private aPcoPro := {} // preÎo de venda do produto
    private aDscPro := {} // Percentual do desconto
    private aPcoLiq := {} // PreÎo Liquido
    private aTotPro := {} // Valor Total bruto do produto
    
    private aFrete  := {}   // Valor do frete
    private aSeguro := {}   // Valor do seguro
    private aDesconto := {} // Valor do desconto (quando houver)
    private aOutro := {}    // Outras despesas acessorias
    
    private aCfop := {}
    
    private aCst := {}
    private aModBc  := {}
    private avBc    := {}  // Valor da base do icms
    private apRedBC := {} // Percentual de reduÎ’o de BC
    private apICMS  := {}  // Aliquota do imposto
    private avICMS  := {} // Valor do imposto
    private amodBCST := {}
    private apMVAST   := {} // Percentual da margem de valor
    private apRedBCST := {} // Percentual de reduÎ’o de BC
    private avBCST     := {} // Valor da BC do ICMS ST
    private apICMSST   := {} // Aliquota do imposto do ICMS ST
    private avICMSST   := {} // Valor do ICMS ST
    private apCredSN   := {} // Al­quota aplicÿvel de cÿlculo do credito
    private avCredICMS := {} // Valor cr'dito do ICMS que pode
    
    // IPI
    private aCstIPI := {}
    private acEnqIPI := {}
    
    // PIS
    private aCstPis := {}
    private aAliPis := {}
    
    // COFINS
    private aCstCofins := {}
    private aAliCofins := {}
    
    // Chave da(s) notas fiscais referenciadas
    private aChaveNfeRef := {} 
     
    // Variavel para a criacao da Nfe   
    private cComando
    // ** declara Variaveis de retorno do acbr    
    private cNRec    // n£mero do recibo
    private cCStat
    private cXMotivo // 
    private cChNfe  // chave da acesso
    private cDhRec  // data e hora do recebimento
    private cNProt  // n£mero do protocolo

    if !AbrirArquivos()
        return
    endif
        
    TelaNfeDev(2)
    AtivaF4()
    do while .t.
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        cNumCon := space(10)
        if lLimpa
            cCodFor := space(04)
            dDtaEmi := date()
            dDtaSai := ctod(space(08))
            cCodNat := space(03)
            cTipFre := space(01)
            cCodTra := space(02)
            
            cObsNot1 := Space( 90 )
            cObsNot2 := Space( 90 )
            cObsNot3 := Space( 90 )
            cObsNot4 := Space( 90 )
            cObsNot5 := Space( 90 )
            cObsNot6 := Space( 90 )
            
            // Grupo de volumes transportados
            nqVol  := 0
            cesp   := space(60)
            cMarca := space(60)
            cnVol  := space(60)
            nPesoL := 0
            nPesoB := 0
        endif
        @ 03,13 get cNumCon picture "@k 9999999999";
                valid Busca(Zera(@cNumCon),"NfeDev",1,,,,{"Controle nÆo cadastrado"},.f.,.f.,.f.)
        setcursor(SC_NONE)
        read
        setcursor(SC_NORMAL)
        if lastkey() == K_ESC
            exit
        endif
        cCodFor := NfeDev->CodFor
        cCodNat := NfeDev->CodNat
        dDtaEmi := NfeDev->DtaEmi
        dDtaSai := NfeDev->DtaSai
        
        aCodPro   := {} // 1
        aDesPro   := {} // 2
        aQtdEmb   := {} // 3
        aQtdPro   := {} // 4
        aPcoPro   := {} // 5 preÎo bruto
        aDscPro   := {} // 6 Percentual de desconto
        aPcoLiq   := {} // 7 PreÎo l­quido
        aTotPro   := {} // 8 valor total bruto
        aFrete    := {} // 9
        aSeguro   := {} // 10
        aDesconto := {} // 11 Valor do Desconto
        aOutro    := {} // 12 
        aBcIcms   := {} // 13 base de cÿlculo do icms
        aVlIcms   := {} // 14 valor do icms
        aCst      := {}  // 15
        aCfop      := {} // 16
        aModBc     := {} // 17
        avBc       := {}  // 18 Valor da base do icms
        apRedBC    := {} // 19 Percentual de reduÎ’o de BC
        apICMS     := {}  // 20 Aliquota do imposto
        avICMS     := {} // 21 Valor do imposto
        amodBCST   := {} // 22
        apMVAST    := {} // 23 Percentual da margem de valor
        apRedBCST  := {} // 24 Percentual de reduÎ’o de BC
        avBCST     := {} // 25 Valor da BC do ICMS ST
        apICMSST   := {} // 26 Aliquota do imposto do ICMS ST
        avICMSST   := {} // 27 Valor do ICMS ST
        apCredSN   := {} // 28 Al­quota aplicÿvel de cÿlculo do credito
        avCredICMS := {} // 29 Valor cr'dito do ICMS que pode
        aCstIPI    := {} // 30  IPI
        acEnqIPI   := {} // 31  IPI
        aCstPis    := {} // 32  PIS 
        aAliPis    := {} // 33  PIS
        aCstCofins := {} // 34  COFINS
        aAliCofins := {} // 35  COFINS 
        if !NfeDevItem->(dbsetorder(1),dbseek(cNumCon))
            Mens({"Problema com os itens","Favor avisar o SUPORTE"})
            loop
        endif
        do while NfeDevItem->NumCon == cNumCon .and. NfeDevItem->(!eof())
            Produtos->(dbsetorder(1),dbseek(nfedevitem->CodPro))
            aadd(aCodPro,nfedevitem->CodPro) // 01
            aadd(aDesPro,Produtos->FanPro)
            aadd(aQtdPro,nfedevitem->QtdPro) // 02
            aadd(aPcoPro,nfedevitem->PcoPro) // 03
            aadd(aPcoLiq,nfedevitem->PcoLiq) // 04
            aadd(aDscPro,nfedevitem->DscPro) // 05 
            aadd(aFrete,nfedevitem->frete)   // 06
            aadd(aSeguro,nfedevitem->Seguro) // 07
            aadd(aOutro,nfedevitem->Outro)   // 08
            aadd(aDesconto,nfedevitem->Desconto) // 09
            aadd(aTotPro,nfedevitem->TotPro) // 10
            aadd(aCfop,nfedevitem->cfop) // 11
            aadd(aCst,nfedevitem->Cst) // 12
            aadd(aModBc,nfedevitem->ModBc) // 13
            aadd(avBC,nfedevitem->vBC)  // 14 Valor da base do icms
            aadd(apRedBC,nfedevitem->pRedBc) // 15 Percentual de reduÎ’o de BC
            aadd(apICMS,nfedevitem->pICMS)  // 16 Aliquota do imposto
            aadd(avICMS,nfedevitem->vICMS) // 17 Valor do imposto
            aadd(amodBCST,nfedevitem->modBCST) // 18 
            aadd(apMVAST,nfedevitem->pMVAST) // 19 Percentual da margem de valor
            aadd(apRedBCST,nfedevitem->pRedBCST) // 20 Percentual de reduÎ’o de BC
            aadd(avBCST,nfedevitem->vBCST)// 21 Valor da BC do ICMS ST
            aadd(apICMSST,nfedevitem->pICMSST) // 22 Aliquota do imposto do ICMS ST
            aadd(avICMSST,nfedevitem->vICMSST) // 23 Valor do ICMS ST
            aadd(apCredSN,nfedevitem->pCredSN) // 24 Al­quota aplicÿvel de cÿlculo do credito
            aadd(avCredICMS,nfedevitem->vCredICMS) // 25 Valor cr'dito do ICMS que pode
            aadd(aCstIpi,nfedevitem->CstIpi)  // 26 IPI
            aadd(acEnqIpi,nfedevitem->cEnqIPI) // 27 IPI
            aadd(aCstPis,nfedevitem->CstPis) // 28 Pis
            aadd(aAliPis,nfedevitem->AliPis) // 29 Pis
            aadd(aCstCofins,nfedevitem->CstCofins) // 30 COFINS
            aadd(aAliCofins,nfedevitem->AliCofins) // 31 COFINS
            NfeDevItem->(dbskip())
        enddo
        aChaveNfeRef := {}
        NfeDevRef->(dbsetorder(1),dbseek(cNumCon))
        do while NfeDevRef->NumCon == cNumCon .and. NfeDevRef->(!eof())
            aadd(aChaveNfeRef,NfeDevRef->Chave)
            NfeDevRef->(dbskip())
        enddo
        @ 05,13 get cCodFor picture "@k 9999";
                    when Rodape("Esc-Encerra | F4-Fornecedores");
                    valid Busca(Zera(@cCodfor),"Fornecedor",1,row(),col(),"'-'+Fornecedor->RazFor",{"Fornecedor nÆo cadastrado"},.f.,.f.,.f.)
        @ 06,13 get cCodNat picture "@k 999";
                    when Rodape("Esc-Encerra | F4-Natureza");
                    valid ValidNatureza(@cCodNat) 
        @ 07,13 get dDtaEmi picture "@k";
                    when Rodape("Esc-Encerra")
        @ 07,38 get dDtaSai picture "@k"
        setcursor(SC_NONE)
        read
        setcursor(SC_NORMAL)
        if lastkey() == K_ESC
            exit
        endif
        if !NfeDevRef()
            loop
        endif
        if !GetItem()
            loop
        endif
        // Total da NF-e
        nvBc     := Soma_Veto2(avBC) // Base de calculo do ICMS
        nvICMS   := Soma_Veto2(avICMS)// Valor total do icms
        nvICMSDeson := 0 // Valor total do ICMS desonerado
        nvBCST   := Soma_Veto2(avBCST) // Base de cÿlculo do ICMS ST
        nvSt     := Soma_Veto2(avICMSST) // Valor total do ICMS ST
        nvProd   := Soma_Veto2(aPcoPro)   // Valor total dos produtos e servicos
        nvFrete  := Soma_Veto2(aFrete)    // Valor total do frete
        nvSeg    := Soma_Veto2(aSeguro)   // Valor total do seguro
        nvDesc   := Soma_Veto2(aDesconto) // Valor total do desconto
        nvII     := 0 // Valor total II
        nvIPI    := 0 // Valor total do IPI
        nvPis    := 0 // Valor total do PIS
        nvCofins := 0 // Valor da COFINS
        nvOutro  := Soma_Veto2(aOutro) // Outras despesas acessorias
        // Valor total da nota
        nvNF      := (((nvProd-nvDesc)-nvICMSDeson)+nvST+nvFrete+nvSeg+nvOutro+;
                        nvII+nvIPI)
        
        GravarNFE(.t.)
        GravarItensNFE(.t.)
        GravarNfeDevRef(.t.)
        If Aviso_1( 17,, 22,, [AtenÎ"o!],[Transmitir a NFE ?], { [  ^Sim  ], [  ^N’o  ] }, 1, .t. ) = 1
			if Sequencia->TestarInte == "S"
				lInternet := Testa_Internet()
         		if !lInternet
            		loop
         		endif
         	endif
            NfeDev->(dbsetorder(1),dbseek(cNumCon))
            do while NfeDev->(!Trava_Reg())
            enddo
            do while Sequencia->(!Trava_Reg())
            enddo
            Sequencia->NumNFE  := Sequencia->NumNfe + 1
            NfeDev->NumNot := strzero(Sequencia->NumNfe,09)
            NfeDev->Serie  := Sequencia->SerieNfe
            Sequencia->(dbunlock())
            NfeDev->(dbunlock())
            
            MontarNfeDev()
            
        endif
    enddo
    DesativaF4()
    FechaDados()
    RestWindow(cTela)
    return
//**************************************************************************
procedure ExcNfeDev // Exclui lan‡amento da nota
    local getlist := {},cTela := SaveWindow()
    local cNumCon
    
    Msg(.t.)
    Msg("Aguarde : Abrindo o Arquivo")
    if !OpenFornecedor()
        Msg(.f.)
        FechaDados()
        return
    endif
    if !OpenProdutos()
        Msg(.f.)
        FechaDados()
        return
    endif
    if !Open_NfeDev()
        Msg(.f.)
        FechaDados()
        return
    endif
    if !Open_NfeDevItem()
        Msg(.f.)
        FechaDados()
        return
    endif
    Msg(.f.)
    AtivaF4()
    Window(08,09,15,70," Excluir lan‡amento ")
    setcolor(Cor(11))
    @ 10,11 say "N§ Controle:"
    @ 11,11 say " Fornecedor:"
    @ 12,11 say "       Data:"
    @ 13,11 say "      Valor:"
    do while .t.
        cNumCon := Space( 10 )
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 10,24 get cNumCon picture "@k 9999999999";
                valid Busca(Zera(@cNumCon),"nfedev",1,,,,{"Controle Nao Cadastrado"},.f.,.f.,.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        Fornecedor->(dbsetorder(1),dbseek(NfeDev->CodFor))
        @ 11,24 say NfeDev->CodFor+"-"+left(Fornecedor->RazFor,40)
        @ 12,24 say NfeDev->DtaSai
        @ 13,24 say NfeDev->vNf picture "@e 999,999.99"
        if !Confirm("Confirma as informa‡äes",2)
            loop
        endif
        if NfeDev->Autorizado
            Mens({"Nota fiscal ja autorizada","Op‡Æo nÆo permitida"})
            loop
        endif
        if NfeDev->Cancelada
            Mens({"Nota fiscal j  cancelada","Op‡Æo nÆo permitida"})
            loop
        endif
        if !NfeDevItem->(dbsetorder(1),dbseek(cNumCon))
            Mens({"Problemas com os itens","Favor chamar o SUPORTE"})
            loop
        endif
        Msg(.t.)
        Msg("Aguarde: Excluindo lan‡amento")
        do while NfeDev->(!Trava_Reg())
        enddo
        Produtos->(dbsetorder(1))
        do while NfeDevItem->NumCon == cNumCon .and. NfeDevItem->(!eof())
            Produtos->(dbseek(NfeDevItem->CodPro))
            do while Produtos->(!Trava_Reg())
            enddo
            if Produtos->CtrLes == "S"
                Produtos->QteAc01 := Produtos->QteAc01 + NfeDevItem->QtdPro
                Produtos->QteAc02 := Produtos->QteAc02 + NfeDevItem->QtdPro
            endif
            Produtos->(dbunlock())
            do while NfeDevItem->(!Trava_Reg())
            enddo
            NfeDevItem->(dbdelete())
            NfeDevItem->(dbcommit())
            NfeDevItem->(dbunlock())
            NfeDevItem->(dbskip())
        enddo
        NfeDev->(dbdelete())
        NfeDev->(dbcommit())
        NfeDev->(dbunlock())
        Msg(.f.)
    enddo
    DesativaF4()
    if PwNivel == "0"
        AtivaF9()
    endif
    FechaDados()
    RestWindow(cTela)
    return
//**************************************************************************    
procedure TraNfeDev // Transmitir NFE
    local getlist := {},cTela := SaveWindow()
    local cNumCon
    
    // ** declara Variaveis de retorno do acbr    
    private cNRec    // n£mero do recibo
    private cCStat
    private cXMotivo // 
    private cChNfe  // chave da acesso
    private cDhRec  // data e hora do recebimento
    private cNProt  // n£mero do protocolo

	private cComando
    
    if !AbrirArquivos()
        return
    endif
    AtivaF4()
    Window(08,09,15,70," Transmitir NFE ")
   setcolor(Cor(11))
   @ 10,11 say "N§ Controle:"
   @ 11,11 say " Fornecedor:"
   @ 12,11 say "       Data:"
   @ 13,11 say "      Valor:"
    do while .t.
        cNumCon := Space( 10 )
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 10,24 get cNumCon picture "@k 9999999999";
            valid Busca(Zera(@cNumCon),"nfedev",1,,,,{"Controle Nao Cadastrado"},.f.,.f.,.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        Fornecedor->(dbsetorder(1),dbseek(NfeDev->CodFor))
        @ 11,24 say NfeDev->CodFor+"-"+left(Fornecedor->RazFor,40)
        @ 12,24 say NfeDev->DtaEmi
        @ 13,24 say NfeDev->vNf picture "@e 999,999.99"
        if !Confirm("Confirma as informa‡äes")
            loop
        endif
        if NfeDev->Autorizado
            Mens({"Nota fiscal ja autorizada"})
            loop
        endif
        if NfeDev->Cancelada
            Mens({"Nota fiscal jÿ cancelada"})
            loop
        endif
		if Sequencia->TestarInte == "S"
			lInternet := Testa_Internet()
         	if !lInternet
            	loop
         	endif
		endif
        if empty(NfeDev->NumNot)
            do while NfeDev->(!Trava_Reg())
            enddo
            do while Sequencia->(!Trava_Reg())
            enddo
            Sequencia->NumNFE  := Sequencia->NumNfe + 1
            NfeDev->NumNot := strzero(Sequencia->NumNfe,09)
            NfeDev->Serie  := Sequencia->SerieNfe
            Sequencia->(dbunlock())
            NfeDev->(dbunlock())
        endif
        MontarNfeDev()
        // ** verifica o status de conexÆo com a secret ria da fazenda
        if !Status_NFeNFCe(Sequencia->DirNfe) 
			loop
		endif
        
        if !CriarNfe()
            loop
        endif
//        Mens({"aqui"})
        do while Nfedev->(!Trava_Reg())
        enddo
        Nfedev->ChNfe := cChNfe
        Nfedev->(dbcommit())
        Nfedev->(dbunlock())
        if !AssinarNfe()
            loop
        endif
        if !ValidarNfe()
            loop
        endif
        //Mens({"Aqui"})
		if !TransmitirNFe()
            do while Nfedev->(!Trava_Reg())
            enddo
            Nfedev->Cstat    := cCStat
            Nfedev->Xmotivo := cXMotivo
            Nfedev->(dbcommit())
            Nfedev->(dbunlock())
			loop
		endif
        cCStat    := RetornoSEFAZ("CStat",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
        cXMotivo  := RetornoSEFAZ("XMotivo",rtrim(Sequencia->dirNFe)+"\sainfe.txt") 
        cChNFe    := RetornoSEFAZ("ChNFe",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
        cNProt    := RetornoSEFAZ("NProt",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
        cDhRecbto := RetornoSEFAZ("DhRecbto",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
		do while NFedev->(!Trava_Reg())
		enddo
		Nfedev->Autorizado := iif(cCStat == "100",.t.,.f.)
        Nfedev->CStat      := cCStat
        Nfedev->XMotivo    := cXMotivo
		Nfedev->ChNfe      := cChNFe
		Nfedev->DhRecbto   := cDhRecbto
		Nfedev->NProt      := cNProt
		Nfedev->(dbcommit())
		Nfedev->(dbunlock())
        ImprimirNFe(cChNfe)
    enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   end
   FechaDados()
   RestWindow(cTela)
   return
//******************************************************************************    
procedure TelaNfeDev(nModo)
    local cTitulo, aTitulos := {"InclusÆo","Altera‡Æo","ExclusÆo","Impressao"}
    
    
    Window(02,00,33,100,"> "+aTitulos[nModo]+" de NF-e de devolu‡Æo <")
    setcolor(Cor(11))
    //           1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
    //                    1         2         3         4         5         6         7         8         9
    @ 03,01 say "  Controle:           -                             Nota/Modelo:       /"
    @ 04,01 say replicate(chr(196),99)
    @ 05,01 say "Fornecedor:"
    @ 06,01 say "  Natureza:"
    @ 07,01 say "   Emissao:                   Saida:"
    @ 08,01 say replicate(chr(196),99)
    @ 28,01 say replicate(chr(196),99)
    @ 29,01 say "  Base ICMS:              Tot. ICMS:             B. ICMS ST:            Tot. ICMS ST:"
    @ 30,01 say " Tot. Prod.:             Tot. Frete:              Total IPI:                Tot. PIS:"
    @ 31,01 say "Tot. COFINS:            Tot. Seguro:            Tot. Desco.:             Tot. Outras:"
    @ 32,01 say "  Tot. Nota:"
    return
    
static function AbrirArquivos

    Msg(.t.)
    Msg("Aguarde: Abrindo os arquivos")
    if !OpenFornecedor()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenSequencia()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenProdutos()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenCfop()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenNatureza()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !Open_NfeDev()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !Open_NfeDevItem()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !Open_NfeDevRef()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenTranspo()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenCidades()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    Msg(.f.)
    return(.t.)

static function ValidNatureza(cCodNat)

    if !Busca(Zera(@cCodNat),"Natureza",1,row(),col(),"'-'+Natureza->Descricao",{"Natureza Nao Cadastrada"},.f.,.f.,.f.)
        return(.f.)
    endif
    if !(Natureza->Operacao == "D")
        Mens({"Natureza incompativel com a opera‡Æo"})
        return(.f.)
    endif
    return(.t.)    
    
static function GetItem
    local aCampo   := {},aTitulo  := {},aMascara := {}
    
    aadd(aCampo,"aCodPro")  // 1
    aadd(aCampo,"aDesPro")  // 2
    aadd(aCampo,"aPcoPro")  // 3 Preco unitario
    aadd(aCampo,"aDscPro")  // 4 Percentual do desconto
    aadd(aCampo,"aQtdPro")  // 5 Quantidade
    aadd(aCampo,"aPcoLiq")  // 6 PreÎo liquifo
    aadd(aCampo,"aTotPro")  // 10 - Total bruto
    
    aadd(aTitulo,"C¢digo")       // 1
    aadd(aTitulo,"Descri‡Æo ")   // 2
    aadd(aTitulo,"Pco.Unit")     // 3
    aadd(aTitulo,"(%)Desc.")     // 4
    aadd(aTitulo,"Qtde.")        // 5
    aadd(aTitulo,"P‡o. Liquido") // 6
    aadd(aTitulo,"Total")        // 7
    
    aadd(aMascara,"@k 999999")      // 1
    aadd(aMascara,"@!S40")          // 2
    aadd(aMascara,"@E 999,999.999") // 3 preÎo unitario
    aadd(aMascara,"@e 999.99")      // 4 Desconto
    aadd(aMascara,"@E 99,999.999")  // 5 PreÎo liquido
    aadd(aMascara,"@E 99,999.999")  // 6 PreÎo liquido
    aadd(aMascara,"@E 9,999,999.99") // 7 Valor Total
    //@ 21,01 say replicate(chr(196),119)
    @ 28,01 say " F2-Confirma | F4-Inclui | F6-Exclui | F8-Abandona " color Cor(26) 
    Rodape("Esc-Encerra")
    setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
    // se for inclus’o de produtos
    if lIncluir
        keyboard chr(K_ENTER)
    endif
    do while .t.
        Edita_Vet(09,01,27,99,aCampo,aTitulo,aMascara,"NfeDevItem",,,,1)
        if lastkey() == K_F2
            if !Confirm("Confirma os Itens da Nota")
                loop
            endif
            if !Pega2()
                loop
            endif
            exit
        elseif lastkey() == K_F8
            exit
        endif
    enddo
    if lastkey() == K_F8
        return(.f.)
    endif
    return(.t.)

function NfeDevItem( Pos_H, Pos_V, Ln, Cl, nTecla )
   Local Laco, Verif := .f.

    If nTecla == K_ENTER
        // ** Codigo do Produto
        If Pos_H = 1
            cCampo := aCodPro[Pos_V]
            @ Ln,Cl get cCampo picture "@k 999999";
                    when Rodape("Esc-Encerra | F4-Produtos");
                    valid Busca(Zera(@cCampo),"Produtos",1,,,,{"Produto Nao Cadastrado"},.f.,.f.,.f.) .and. vCodigo(cCampo,Pos_V)
            setcursor(SC_NORMAL)
            read
            setcursor(SC_NONE)
            if !(lastkey() == K_ESC)
                Rodape("Esc-Encerra")
                aCodPro[Pos_V] := cCampo
                aDesPro[pos_v] := Produtos->FanPro
                //aPcoPro[Pos_V] := Produtos->PcoVen
                //aCst[Pos_V]    := Produtos->Cst
                if !TelaGet(Pos_V)
                    return(2)
                endif
                //CalcularICMS(Pos_V)
                if lIncluir
                    AdicionarItem(Pos_V)
                    keyboard chr(K_DOWN)+replicate(chr(K_LEFT),Pos_H-1)+chr(K_ENTER)
                endif
                Return( 3 )
            EndIf
        endif
    elseif nTecla = K_F2
        N_Itens = Len( aCodPro )
        Brancos = 0
        For Laco = 1 to Len( aCodPro )
            If !Empty( aCodPro[Laco] ) .and. ( Empty( aQtdPro[Laco] ) .or. Empty( aPcoPro[Laco] ) )
                Aviso_1( 10,, 15,, [AtenÎ"o!], [N"o s"o permitidos quantidades ou preÎos zerados.], { [  ^Ok!  ] }, 1, .t., .t. )
                Return( 1 )
            ElseIf Empty( aCodPro[Laco] )
                ++Brancos
            EndIf
        Next
        If Brancos = N_Itens
            Aviso_1( 10,, 15,, [AtenÎ"o!], [N"o ' permitido gravar nota sem ­tens.], { [  ^Ok!  ] }, 1, .t., .t. )
            Return( 1 )
        EndIf
        Return( 0 )
    // Adiciona Itens
    elseif nTecla == K_F4
		if !Confirm("Confirma a InclusÆo do produto")
         	return(0)
      	endif
        AdicionarItem(Pos_V)
        keyboard chr(K_DOWN)+replicate(chr(K_LEFT),Pos_H-1)+chr(K_ENTER)
        return( 3 )
    // Confirma os itens
    elseif nTecla == K_F2
        return(0)
    // Abandona a operaÎ’o
    elseif nTecla == K_F8
        return(0)
    // Exclui o item
    elseif nTecla == K_F6
        If Len( aCodPro ) > 1
            if !Confirm("Confirma a Exclusao do Item")
                return(0)
            endif
            adel(aCodPro,Pos_V)
            adel(aDesPro,Pos_V)
            adel(aQtdEmb,Pos_V)
            adel(aQtdPro,Pos_V)
            adel(aPcoPro,Pos_V) // preÎo bruto
            adel(aDscPro,Pos_V) // Percentual de desconto
            adel(aPcoLiq,Pos_V) // PreÎo l­quido
            adel(aTotPro,Pos_V) // valor total bruto
            adel(aFrete,Pos_V)
            adel(aSeguro,Pos_V)
            adel(aDesconto,Pos_V)// Valor do Desconto
            adel(aOutro,Pos_V)
            adel(aCfop,Pos_V)
            adel(aCst,Pos_V)
            adel(aModBc,Pos_V)
            adel(avBc,Pos_V)  // Valor da base do icms
            adel(apRedBC,Pos_V) // Percentual de reduÎ’o de BC
            adel(apICMS,Pos_V)  // Aliquota do imposto
            adel(avICMS,Pos_V) // Valor do imposto
            adel(amodBCST,Pos_V)
            adel(apMVAST,Pos_V)// Percentual da margem de valor
            adel(apRedBCST,Pos_V) // Percentual de reduÎ’o de BC
            adel(avBCST,Pos_V)// Valor da BC do ICMS ST
            adel(apICMSST,Pos_V) // Aliquota do imposto do ICMS ST
            adel(avICMSST,Pos_V) // Valor do ICMS ST
            adel(apCredSN,Pos_V) // Al­quota aplicÿvel de cÿlculo do credito
            adel(avCredICMS,Pos_V) // Valor cr'dito do ICMS que pode
            // IPI
            adel(aCstIPI,Pos_V)
            adel(acEnqIPI,Pos_V)
            
            // PIS
            adel(aCstPis,Pos_V)
            adel(aAliPis,Pos_V)
            
            // COFINS
            adel(aCstCofins,Pos_V)
            adel(aAliCofins,Pos_V) 
            return( 3 )
        EndIf
    EndIf
    Return( 1 )
    
static procedure AdicionarItem(nPosicao)
	local N_Itens := Len( aCodPro ) + 1
    
    
    aadd(aCodPro,space(06))
    aadd(aDesPro,space(37)) // 2
    aadd(aPcoPro,0) // 3 Preco unitario
    aadd(aDscPro,0) // 4 Percentual do desconto
    aadd(aQtdPro,0) // 5 Quantidade
    aadd(aPcoLiq,0) // 6 PreÎo liquifo
    aadd(aTotPro,0) // 10 - Total bruto
    aadd(aDesconto,0) // Valor do Desconto
    aadd(aSeguro,0)
    aadd(aFrete,0)
    aadd(aOutro,0)
    
    aadd(aCfop,space(04))
    aadd(aCst,space(03))
    aadd(aModBc,space(01))
    aadd(avBc,0) // Valor da base do icms
    aadd(apRedBC,0) // Percentual de reduÎ’o de BC
    aadd(apICMS,0) // Aliquota do imposto
    aadd(avICMS,0) // Valor do imposto
    aadd(amodBCST,space(01))
    aadd(apMVAST,0) // Percentual da margem de valor
    aadd(apRedBCST,0) // Percentual de reduÎ’o de BC
    aadd(avBCST,0) // Valor da BC do ICMS ST
    aadd(apICMSST,0) // Aliquota do imposto do ICMS ST
    aadd(avICMSST,0) // Valor do ICMS ST
    aadd(apCredSN,0) // Al­quota aplicÿvel de cÿlculo do credito
    aadd(avCredICMS,0) // Valor cr'dito do ICMS que pode
    // IPI
    aadd(aCstIPI,space(02))
    aadd(acEnqIPI,space(03))
            
    // PIS
    aadd(aCstPis,space(02))
    aadd(aAliPis,0)
            
    // COFINS
    aadd(aCstCofins,space(02))
    aadd(aAliCofins,0) 
	return
    
static function Pega2
   local getlist := {},cTela := SaveWindow(),lRetorno

   Window(09,03,27,96," Dados Complementares ")
   setcolor(Cor(11))
   //           678901234567890123456789012345678901234567890123456789012345678901234
   //               1         2         3         4         5         6         7
   @ 11,06 say "       Frete:"
   @ 12,06 say "Transportado:"
   @ 13,06 say replicate(chr(196),90)
   @ 13,04 say "[ Volumes Transportados ]" color Cor(26)
   @ 14,06 say "  Quantidade:"
   @ 15,06 say "     Esp'cie:"
   @ 16,06 say "       Marca:"
   @ 17,06 say "   NumeraÎ’o:"
   @ 18,06 say "  Peso Liqu.:                        Peso Bruto:"
   @ 19,04 say replicate(chr(196),91)
   @ 19,04 say "[ Dados Adicionais ] " color Cor(26)
   while .t.
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 11,20 get cTipFre picture "@k!" valid MenuArray(@cTipFre,{{"0","Por conta do Emitente              "},;
      			{"1","Por conta do Destinatario/Remetente"},;
      			{"2","Por conta de Terceiros             "},;
      			{"9","Sem frete                          "}},row(),col(),row(),col()+1)
        @ 12,20 get cCodTra picture "@k 99" when iif( cTipFre == "9",.f.,Rodape("Esc-Encerra | F4-Transportadora")) valid Busca(Zera(@cCodTra),"Transpo",1,12,22,"'-'+Transpo->NomTra",{"Transportadora Nao Cadastrada"},.f.,.f.,.f.)
        @ 14,20 get nqVol  picture "@k 999999999999999"
        @ 15,20 get cesp picture "@k"
        @ 16,20 get cMarca picture "@k"
        @ 17,20 get cnVol picture "@k" 
        @ 18,20 get nPesoL picture "@k 999,999,999,999.999"
        @ 18,55 get nPesoB picture "@k 999,999,999,999.999" 
        @ 20,05 get cObsNot1 picture "@k!"
        @ 21,05 get cObsNot2 picture "@k!"
        @ 22,05 get cObsNot3 picture "@k!"
        @ 23,05 get cObsNot4 picture "@k!"
        @ 24,05 get cObsNot5 picture "@k!"
        @ 25,05 get cObsNot6 picture "@k!"
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            lRetorno := .f.
            exit
        endif
        if !Confirm("Confirma as Informacoes")
            loop
        endif
      lRetorno := .t.
      exit
   end
   RestWindow(cTela)
   return(lRetorno)

static function vCodigo(cCodProd,pos_v)  // Verifica se o item ja foi cadastrado

   if !(ascan(aCodPro,cCodProd) == 0) .and. !(aCodPro[pos_v] == cCodProd)
      Mens({"Item Ja Cadastrado"})
      return(.f.)
   end
   return(.t.)

static function TelaGet(Pos_V)
    local cTela := SaveWindow()
    local nDesconto,nQuantidade,nSeguro,nFrete,nOutro,lLimpa := .t.
    local lRetorno := .t.,nTotal,nPcoPro,nDesc := 0,cCfop2
    local nPcoLiq
    // ICMS
    local cCst
    local cModBc
    local npRedBC  // Percentual de reduÎ’o de BC
    local nvBC
    local npICMS   // Aliquota do imposto
    local nvICMS   // Valor do imposto
    local cmodBCST 
    local npMVAST  // Percentual da margem de valor
    local npRedBCST := {} // Percentual de reduÎ’o de BC
    local nvBCST     := {} // Valor da BC do ICMS ST
    local npICMSST   := {} // Aliquota do imposto do ICMS ST
    local nvICMSST   := {} // Valor do ICMS ST
    
    
    // IPI
    local cCstIPI,cEnqIPI
    local nBcIpi // Valor da BC do IPI
    local npIPI  // aliquota do IPI 
    local nvIPI  // valor do IPI

    // PIS
    local cCstPis,nAliPis
    // COFINS
    local cCstCofins,nAliCofins 
    
    
    Window(01,00,33,96,"> Lan‡ar produtos <")
    setcolor(Cor(11))
    //           123456789012345678901234567890123456789012345678901234567890123456789012345678901234
    //                    1         2         3         4         5         6         7         8
    @ 03,01 say "         Codigo:"
    @ 04,01 say "      Descricao:"
    @ 05,01 say "        Unidade:"
    @ 06,01 say "           CFOP:" 
    @ 07,01 say " Pre‡o Unitario:                     Desc. (%):                  Valor L¡quido:"
    @ 08,01 say "     Quantidade:"
    @ 09,01 say "         Seguro:                         Frete:                       Despesas:" 
    @ 10,01 say "    Valor Total:"
    @ 11,01 say replicate(chr(196),95)
    @ 11,01 say " ICMS " color Cor(26)
    @ 12,01 say "            CST:                    Modalidade:"
    @ 13,01 say "% Red.Base ICMS:                  Base de ICMS:"
    @ 14,01 say "    Aliquota(%):                 Valor do ICMS:"
    @ 15,01 say " Mod.BC ICMS ST:            %Red. Base ICMS ST:               Aliquota ICMS ST:"
    @ 16,01 say "           %MVA:               Base de ICMS ST:                  Valor ICMS ST:"
    @ 17,01 say replicate(chr(196),95)
    @ 17,01 say " IPI " color Cor(26)
    @ 18,01 say "            Cst:                           Codigo de Enquadramento:"
    @ 19,01 say "Base de calculo:"
    @ 20,01 say "    Aliquota(%):                  Valor do IPI:"
    @ 21,01 say replicate(chr(196),95)
    @ 21,01 say " PIS " color Cor(26)
    @ 22,01 say "            Cst:"
    @ 23,01 say "Base de calculo:"                   
    @ 24,01 say "    Aliquota(%):                  Valor do PIS:"
    @ 25,01 say replicate(chr(196),95)    
    @ 25,01 say " COFINS " color Cor(26)
    @ 26,01 say "            Cst:"
    @ 27,01 say "Base de calculo:"
    @ 28,01 say "    Aliquota(%):               Valor do COFINS:"
    do while .t.
        if lLimpa
            lLimpa      := .f.
            nDesconto   := iif(empty(aDscPro[Pos_V]),0,aDscPro[Pos_V])
            nQuantidade := iif(empty(aQtdPro[Pos_V]),0,aQtdPro[Pos_V])
            nSeguro     := iif(empty(aSeguro[Pos_V]),0,aSeguro[Pos_V])
            nFrete      := iif(empty(aFrete[Pos_V]),0,aFrete[Pos_V])
            nOutro      := iif(empty(aOutro[Pos_V]),0,aOutro[Pos_V])
            nPcoPro     := iif(empty(aPcoPro[Pos_V]),0,aPcoPro[Pos_V]) 
            nPcoLiq     := iif(empty(aPcoLiq[Pos_v]),0,aPcoLiq[Pos_V])
            nDesc       := 0
            cCfop2      := aCfop[Pos_V]
            cCst        := iif(empty(aCst[pos_v]),space(03),aCst[pos_v])
            cModBc      := iif(empty(aModBc[pos_v]),space(01),aModBc[pos_v])
            npRedBC     := iif(empty(apRedBc[pos_v]),0,apRedBc[pos_v]) // Percentual de reduÎ’o de BC
            nvBC        := avBc[pos_v]
            npICMS      := iif(empty(apICMS[pos_v]),0,apICMS[pos_v]) // Aliquota do imposto
            nvICMS      := iif(empty(avICMS[pos_v]),0,avICMS[pos_v]) // Valor do imposto
            cmodBCST    := iif(empty(amodBCST[pos_v]),space(01),amodBCST[pos_v]) 
            npMVAST     := iif(empty(apMVAST[pos_v]),0,apMVAST[pos_v]) // Percentual da margem de valor
            npRedBCST   := iif(empty(apRedBCST[pos_v]),0,apRedBCST[pos_v]) // Percentual de reduÎ’o de BC
            nvBCST      := avBCST[pos_V] // Valor da BC do ICMS ST
            npICMSST    := apICMSST[pos_v] // Aliquota do imposto do ICMS ST
            nvICMSST    := avICMSST[pos_v] // Valor do ICMS ST
            // IPI
            cCstIpi     := iif(empty(aCstIpi[Pos_V]),space(02),aCstIpi[Pos_V])
            cEnqIPI     := iif(empty(acEnqIPi[Pos_V]),space(03),acEnqIpi[Pos_V])
            nBcIpi      := iif(empty(aBcIpi[Pos_V]),0,aBcIpi[Pos_V]) // Valor da BC do IPI
            npIPI       := iif(empty(apIPI[Pos_V]),0,apIPI[Pos_V]) // aliquota do IPI 
            nvIPI       := iif(empty(avIPI[Pos_V]),0,avIPI[Pos_V]) // valor do IPI
            
            /*
            // PIS
            cCstPis := iif(empty(aCstPis[Pos_V]),space(02),aCstPis[Pos_V])
            nAliPis := iif(empty(aAliPis[Pos_V]),0.00,aAliPis[Pos_V])
            // COFINS
            cCstCofins := iif(empty(aCstCofins[Pos_V]),Produtos->CstCofins,aCstCofins[Pos_V])
            nAliCofins := iif(empty(aAliCofins[Pos_V]),Produtos->AliCofins,aAliCofins[Pos_V])
            */
            cCstIpi     := aCstIpi[Pos_V]
            cEnqIPI     := acEnqIpi[Pos_V]
            // PIS
            cCstPis := aCstPis[Pos_V]
            nAliPis := aAliPis[Pos_V]
            // COFINS
            cCstCofins := aCstCofins[Pos_V]
            nAliCofins := aAliCofins[Pos_V]
            
        endif
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        Produtos->(dbsetorder(1),dbseek(aCodPro[Pos_V]))
        @ 03,18 say aCodPro[Pos_V]
        @ 04,18 say aDesPro[Pos_V]
        @ 05,18 say Produtos->EmbPro
        
        @ 06,18 get cCfop2 picture "@k 9999";
                when Rodape("Esc-Encerra | F4-CFOP");
                valid Busca(@cCfop2,"Cfop",1,row(),col()+1,"left(Cfop->Descricao,68)",;
                    {"CFOP n’o cadastrado"},.f.,.f.,.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            lRetorno := .f.
            exit
        endif
        @ 07,18 get nPcoPro picture "@E 999,999.9999";
                valid NoEmpty(nPcoPro) 
        @ 07,49 get nDesconto picture "@ke 999.99"
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            loop
        endif
        if nDesconto > 0
            nPcoLiq := round(nPcoPro-(round(nPcoPro*(nDesconto/100),3)),3)
        else
            nPcoLiq := nPcoPro
        endif
        @ 07,81 say nPcoLiq ;
                    picture "@E 999,999.9999";
                    color Cor(26)
                    
        @ 08,18 get nQuantidade;
                    picture "@E 999,999.999";
                    valid NoEmpty(nQuantidade)
        @ 09,18 get nSeguro picture "@ke 999,999.99"
        @ 09,49 get nFrete picture "@ke 999,999.99"
        @ 09,81 get nOutro picture "@ke 999,999.99"    
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            loop
        endif
        // calcula o Desconto em valores
        nDesc  := (nPcoPro*nQuantidade)-(nPcoLiq*nQuantidade)
        nTotal := nPcoLiq*nQuantidade 
        nTotal := (nTotal+nSeguro+nFrete+nOutro)-nDesc
        @ 10,18 say nTotal picture "@e 999,999.99"
        
        // ICMS
        @ 12,18 get cCst picture "@k 999"
        @ 12,49 get cModBc picture "@k 9"; 
            valid MenuArray(@cModBc,{;
            {"0","Margem do Valor agregado(%)"},;
            {"1","Pauta(Valor)               "},;
            {"2","Pre‡o Tabelado Max. (valor)"},;
            {"3","Valor da opera‡Æo"}})
        @ 13,18 get npRedBC  picture "@k 999.99"  // Percentual de reduÎ’o de BC
        @ 13,49 get nvBC picture "@ke 999,999.99"
        @ 14,18 get npICMS picture "@k 999.99"   // Aliquota do imposto
        @ 14,49 get nvICMS picture "@ke 999,999.99" // Valor do imposto
        // ICMS ST
        @ 15,18 get cmodBCST picture "@k 9";
            valid iif(empty(cModBCST),.t.,MenuArray(@cModBCST,{;
            {"0","Pre‡o tabelado ou m ximo sugerido"},;
            {"1","Lista Negativa (valor)           "},;
            {"2","Lista Positiva (valor)           "},;
            {"3","Lista Neutra Agregado (%)        "},;
            {"4","Margem Valor Agregado (%)        "}}))
        
        @ 15,49 get npRedBCST picture "@k 999.99" // Percentual de reduÎ’o de BC
        @ 15,81 get npICMSST picture "@ke 999.99" // Aliquota do imposto do ICMS ST        
        @ 16,18 get npMVAST picture "@k 999.99" // Percentual da margem de valor
        @ 16,49 get nvBCST picture "@ke 999,999.99" // Valor da BC do ICMS ST
        @ 16,81 get nvICMSST picture "@ke 999,999.99" // Valor do ICMS ST
            
        // IPI
        @ 18,18 get cCstIPI picture "@k 99"
        @ 18,69 get cEnqIPI picture "@k 999"
        @ 19,18 get nBcIpi  picture "@ke 999,999.99" // Valor da BC do IPI
        @ 20,18 get npIPI picture "@ke 999.99" // aliquota do IPI 
        @ 20,49 get nvIPI picture "@ke 999,999.99"  // valor do IPI

        
        // PIS
        @ 22,18 get cCstPis picture "@k 99"
        @ 24,18 get nAliPis picture "@k 999.99"
        
        // COFINS
        @ 26,18 get cCstCofins picture "@k 99"
        @ 28,18 get nAliCofins picture "@k 999.99"
          
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            loop
        endif
        if !Confirm("Confirma os dados")
            loop
        endif
        aPcoPro[Pos_V] := nPcoPro
        aDscPro[Pos_V] := nDesconto  // Percentual do Desconto
        aPcoLiq[Pos_V] := nPcoLiq  // pre‡o l¡quido
        aQtdPro[Pos_V] := nQuantidade // quantidade
        aSeguro[Pos_V] := nSeguro // seguro 
        aFrete[Pos_v]  := nFrete // frete
        aOutro[Pos_V]  := nOutro // outro
        aDesconto[Pos_V] := (aPcoPro[Pos_V]*aQtdPro[Pos_V])-(aPcoLiq[Pos_V]*aQtdPro[Pos_V])        
        aTotPro[Pos_V] := aQtdPro[Pos_V]*aPcoPro[Pos_V]
        
        // ICMS
        aCst[Pos_V]   := cCst
        aCfop[Pos_V] := cCfop2
        aModBc[Pos_V] := cModBC
        apRedBC[Pos_V] := npRedBc // Percentual de reduÎ’o de BC
        avBc[Pos_V] := nvBC 
        apICMS[Pos_V] := npICMS  // Aliquota do imposto
        avICMS[Pos_V] := nvICMS  // Valor do imposto
        aModBCST[Pos_V] := cmodBCST 
        apRedBCST[Pos_V] := npRedBCST // Percentual de reduÎ’o de BC
        apICMSST[Pos_V] := npICMSST  // Aliquota do imposto do ICMS ST        
        apMVAST[Pos_V] := npMVAST  // Percentual da margem de valor
        avBCST[Pos_V] := nvBCST // Valor da BC do ICMS ST
        avICMSST[Pos_V] := nvICMSST  // Valor do ICMS ST

        
        // IPI
        aCstIpi[Pos_V] := cCstIpi
        acEnqIpi[Pos_V] := cEnqIpi
        aBcIpi[Pos_V] := nBcIpi // Valor da BC do IPI
        apIPI[Pos_V] := npIPI   // aliquota do IPI 
        avIPI[Pos_V] := nvIPI    // valor do IPI
        
        // PIS
        aCstPis[Pos_V] := cCstPis
        aAliPis[Pos_v] := nAliPis
        // COFINS
        aCstCofins[Pos_V] := cCstCofins
        aAliCofins[Pos_V] := nAliCofins
        
        exit
    enddo
    RestWindow(cTela)
    return(lRetorno)    
//***************************************************************************    
static procedure GravarItensNFE(lModo)
    local nI

    if lModo
        For nI := 1 to len(aCodPro)
            If !empty( aCodPro[nI] )
                do while !nfedevitem->(Adiciona())
                enddo                          
                nfedevitem->NumCon := cNumCon
                nfedevitem->CodPro := aCodPro[nI] // 1
                nfedevitem->QtdPro := aQtdPro[nI] // 2
                nfedevitem->PcoPro := aPcoPro[nI] // 3
                nfedevitem->PcoLiq := aPcoLiq[nI] // 4
                nfedevitem->DscPro := aDscPro[nI] // 5
                nfedevitem->frete  := aFrete[nI] // 6
                nfedevitem->Seguro := aSeguro[nI] // 7
                nfedevitem->Outro  := aOutro[nI] // 8
                nfedevitem->Desconto := aDesconto[nI] // 9
                nfedevitem->TotPro := aTotPro[nI] // 10
                nfedevitem->cfop := aCfop[nI] // 11
                nfedevitem->Cst := aCst[nI] // 12
                nfedevitem->ModBc := aModBc[nI] // 13
                nfedevitem->vBC :=  avBc[nI]  // 14 Valor da base do icms
                nfedevitem->pRedBc := apRedBC[nI] // 15 Percentual de reduÎ’o de BC
                nfedevitem->pICMS := apICMS[nI]  // 16 Aliquota do imposto
                nfedevitem->vICMS := avICMS[nI] // 17 Valor do imposto
                nfedevitem->modBCST := amodBCST[nI] // 18 
                nfedevitem->pMVAST := apMVAST[nI] // 19 Percentual da margem de valor
                nfedevitem->pRedBCST := apRedBCST[nI] // 20 Percentual de reduÎ’o de BC
                nfedevitem->vBCST := avBCST[nI]// 21 Valor da BC do ICMS ST
                nfedevitem->pICMSST := apICMSST[nI] // 22 Aliquota do imposto do ICMS ST
                nfedevitem->vICMSST := avICMSST[nI] // 23 Valor do ICMS ST
                nfedevitem->pCredSN := apCredSN[nI] // 24 l­quota aplicÿvel de cÿlculo do credito
                nfedevitem->vCredICMS := avCredICMS[nI] // 25 Valor cr'dito do ICMS que pode
                
                // IPI
                nfedevitem->CstIpi := aCstIpi[nI] // 26
                nfedevitem->cEnqIPI := acEnqIpi[nI] // 27
                nfedevitem->bcipi := aBcIpi[nI]
                nfedevitem->pIPI := apIPI[nI]
                nfedevitem->vIPI := avIPI[nI] 
                
                // Pis
                nfedevitem->CstPis := aCstPis[nI] // 28 
                nfedevitem->AliPis := aAliPis[nI] // 29
                // COFINS
                nfedevitem->CstCofins := aCstCofins[nI] // 30
                nfedevitem->AliCofins := aAliCofins[nI] // 31
                
                nfedevitem->(dbcommit())
                nfedevitem->(dbunlock())
                Produtos->(dbsetorder(1),dbseek(aCodPro[nI]))
                if Produtos->CtrLes == "S"
                    do while Produtos->(!Trava_Reg())
                    enddo
                    Produtos->QteAc01 := Produtos->QteAc01 - aQtdPro[nI]
                    Produtos->QteAc02 := Produtos->QteAc02 - aQtdPro[nI]
                    Produtos->(dbcommit())
                    Produtos->(dbunlock())
                endif
            endif
        Next    
    else        
        nfedevitem->(dbsetorder(1),dbseek(cNumCon))
        do while nfedevitem->NumCon == cNumCon .and. nfedevitem->(!eof())
            do while nfedevitem->(!Trava_Reg())
            enddo
            nfedevitem->(dbdelete())
            nfedevitem->(dbcommit())
            nfedevitem->(dbunlock())
            nfedevitem->(dbskip())
        enddo
        GravarItensNFE(.t.)
    endif
    return

static procedure GravarNfe(lModo) // Grava cabe‡alho da nota
    
    // se for modo de inclusÆo
    if lModo
        do while Sequencia->(!Trava_Reg())
        enddo
        Sequencia->LancNfeDev := Sequencia->LancNfeDev + 1
        cNumCon := strzero(Sequencia->LancNfeDev,10)
        Sequencia->(dbunlock())
        @ 03,11 say cNumCon
        do while nfedev->(!Adiciona())
        enddo
        nfedev->NumCon  := cNumCon
    else
        nfedev->(dbsetorder(1),dbseek(cNumCon))
        do while nfedev->(!Trava_Reg())
        enddo
    endif
    nfedev->CodFor  := cCodFor
    nfedev->CodNat  := cCodNat
    nfedev->DtaEmi  := dDtaEmi
    nfedev->DtaSai  := dDtaSai
    
    NfeDev->tpNf := "1"  // Tipo de opera‡Æo 0 = Entrada 1 = Saida
    
        // Total da NF-e    
        nfedev->vBC        := nvBc // Base de calculo do ICMS    
        nfedev->vICMS      := nvICMS// Valor total do icms    
        nfedev->vICMSDeson := nvICMSDeson // Valor total do ICMS desonerado    
        nfedev->vBCST      := nvBCST // Base de cÿlculo do ICMS ST    
        nfedev->vSt        := nvST   // Valor total do ICMS ST    
        nfedev->vProd      := nvProd // Valor total dos produtos e servicos    
        nfedev->vFrete     := nvFrete // Valor total do frete    
        nfedev->vSeg       := nvSeg // Valor total do seguro    
        nfedev->vDesc      := nvDesc // Valor total do desconto    
        nfedev->vII        := nvII // Valor total II    
        nfedev->vIPI       := nvIPI // Valor total do IPI    
        nfedev->vPis       := nvPis // Valor total do PIS    
        nfedev->vCofins    := nvCofins // Valor da COFINS    
        nfedev->vOutro     := nvOutro // Outras despesas acessorias    
        nfedev->vNF        := nvNF // Valor total da nota          
    
        nfedev->CodTra  := cCodTra
        nfedev->TipFre  := cTipFre
        // Grupo de volumes
        nfedev->qVol    := nqVol  
        nfedev->esp     := cesp 
        nfedev->Marca   := cMarca
        nfedev->nVol    := cnVol  
        nfedev->PesoL   := nPesoL 
        nfedev->PesoB   := nPesoB  
        
        
        nfedev->ObsNot1 := cObsNot1
        nfedev->ObsNot2 := cObsNot2
        nfedev->ObsNot3 := cObsNot3
        nfedev->ObsNot4 := cObsNot4
        nfedev->ObsNot5 := cObsNot5
        nfedev->ObsNot6 := cObsNot6
        nfedev->ConCluido := .t.
        nfedev->(dbcommit())
        nfedev->(dbunlock())
    return


static function NfeDevRef
    local cTela := SaveWindow()
    local nLinha1,nColuna1,nLinha2,nColuna2,lRetorno := .t.
    private aTitulo := {},aCampo := {},aMascara := {}
    
    aadd(aTitulo,"Chave")
    aadd(aCampo,"aChaveNfeRef")
    aadd(aMascara,"@k")
    
    nLinha1  := 10
    nColuna1 := 05
    nLinha2  := 29
    nColuna2 := 79
    Window(nLinha1,nColuna1,nLinha2,nColuna2," Relacao de NF-e ")
    @ nLinha2,nColuna1+1 say " F2-Confirma | F6-Adiciona | F8-Excluir | F10-Cancela " color Cor(26)
    setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
	// **keyboard chr(K_ENTER)
    do while .t.
        Edita_Vet(nLinha1+1,nColuna1+1,nLinha2-1,nColuna2-1,aCampo,aTitulo,aMascara,"vNfeRef",,,,2)
        if lastkey() == K_F10
            lRetorno := .f.
            exit
        elseif lastkey() == K_F2
            if !Confirm("Confirma a(s) chave(s)")
                loop
            endif
            exit
	   endif
	enddo
    RestWindow(cTela)
    return(lRetorno)
    
function vNfeRef(Pos_H,Pos_V,Ln,Cl,Tecla) 
    local GetList := {},cCampo,cCor := setcolor(),nI,lBranco := .f.

    If Tecla = K_ENTER
        // Nœmero da nota fiscal
        if Pos_H == 1
			cCampo := aChaveNfeRef[Pos_V]
			@ ln,cl get cCampo picture "@k";
                    valid NoEmpty(cCampo)
         	setcursor(SC_NORMAL)
         	read
         	setcursor(SC_NONE)
         	if !(lastkey() == K_ESC)
                aChaveNfeRef[Pos_V] := cCampo
                if Pos_v >= len(aChaveNfeRef)
                  	nItens := len(aChaveNfeRef)+1
                  	asize(aChaveNfeRef,nItens)
                  	ains(aChaveNfeRef,Pos_V+1)
                  	aChaveNfeRef[Pos_V+1] := space(44)
                    keyboard chr(K_DOWN)+replicate(chr(K_LEFT),Pos_H-1)+chr(K_ENTER)
                    return(3)
                endif
                
         	endif
        // Data da nota fiscal
         endif
    elseif Tecla == K_F6 .and. !lIncluir // Adiciona
        if !Confirm("Confirma a InclusÆo")
         	return(0)
      	endif
		if !empty(aChaveNfeRef[pos_v])
			nItens := len(aChaveNfeRef)+1
			asize(aChaveNfeRef,nItens)
            ains(aChaveNfeRef,Pos_V+1)
            aChaveNfeRef[Pos_V+1]    := space(44)
            keyboard chr(K_DOWN)+replicate(chr(K_LEFT),Pos_H-1)+chr(K_ENTER)
            return( 3 )
        endif
   elseif Tecla == K_F8 // Exclui
        if !Confirm("Confirma a ExclusÆo")
			return(0)
		endif
		if len(aChaveNfeRef) == 1
            aChaveNfeRef[Pos_V] := space(44)
         	return(3)
		endif
        adel(aChaveNfeRef,Pos_V)
		nItens := len(aChaveNfeRef)-1
		asize(aChaveNfeRef,nItens)
		return(3)
    elseif Tecla == K_F2 // Confirma
        /*
        for nI := 1 to len(aNfe)
            if empty(aNfe[nI])
                Mens({"Chave da NF-e n’o pode ser em branco"})
                lBranco := .t.
                exit
            endif
            if empty(aDtaNfe[nI])
                Mens({"Data da NF-e n’o pode ser em branco}"})
                lBranco := .t.
                exit
            endif
        next
        */
        return(0)
    elseif Tecla == K_F10 // Abandona
        return(0)
    EndIf
    if lastkey() == K_ESC .and. !lIncluir
        if len(aChaveNfeRef) > 1
            if empty(aChaveNfeRef[Pos_V])
                adel(aChaveNfeRef,Pos_V)
                nItens := len(aChaveNfeRef)-1
                asize(aChaveNfeRef,nItens)
                return(3)
            endif
        endif
    endif
    Return( 1 )


static procedure GravarNfeDevRef(lModo)
    local nI

    if lModo
        for nI := 1 to len(aChaveNfeRef)
            if !empty(aChaveNfeRef[nI])
                do while NfeDevRef->(!Adiciona())
                enddo
                NfeDevRef->NumCon := cNumCon
                NfeDevRef->Chave := aChaveNfeRef[nI]
                NfeDevRef->(dbcommit())            
                NfeDevRef->(dbunlock())
            endif
        next
    else
        do while NfeDevRef->NumCon == cNumCon .and. NfeDevRef->(!eof())
            do while NfeDevRef->(!Trava_Reg())
            enddo
            NfeDevRef->(dbdelete())
            NfeDevRef->(dbcommit())
            NfeDevRef->(dbunlock())
            Nfedevref->(dbskip())
        enddo
        GravarNfeDevRef(.t.)
    endif
    return
            
static procedure MontarNfeDev
    private nContador

    Fornecedor->(dbsetorder(1),dbseek(nfedev->CodFor))
    Transpo->(dbsetorder(1),dbseek(nfedev->CodTra))
    Cidades->(dbsetorder(1),dbseek(Fornecedor->CodCid))
    Natureza->(dbsetorder(1),dbseek(nfedev->CodNat))
    Cfop->(dbsetorder(1),dbseek(Natureza->cfop))

    cComando := ""
    // Identifica‡Æo da nota ---------------------------------------------
    cComando += "[Identificacao]"+chr(K_ENTER)+chr(K_CTRL_ENTER)
    cComando += "cUF="+cEmpEstCid+chr(K_ENTER)+chr(K_CTRL_ENTER)
    cComando += 'natOp='+left(Cfop->Descricao,60)+chr(K_ENTER)+chr(K_CTRL_ENTER)
    // Forma de pagamento 
    // 0 - Avusta
    // 1-A prazo
    // 2=Outros
    cComando += "IndPag=0"+chr(K_ENTER)+chr(K_CTRL_ENTER)
    
   cComando += 'Modelo=55'+chr(K_ENTER)+chr(K_CTRL_ENTER) 
   cComando += 'Serie='+nfedev->Serie+chr(K_ENTER)+chr(K_CTRL_ENTER)
   cComando += 'nNF='+nfedev->NumNot+chr(K_ENTER)+chr(K_CTRL_ENTER)
   cComando += 'Emissao='+dtoc(nfedev->DtaEmi)+chr(K_ENTER)+chr(K_CTRL_ENTER)
    if !empty(nfedev->DtaSai)
        cComando += 'Saida='+dtoc(nfedev->DtaSai)+chr(K_ENTER)+chr(K_CTRL_ENTER)
    endif
    // Tipo de operaÎ’o 0=Entrada,1=Saida
    cComando += 'tpNf='+nfedev->tpNF+chr(K_ENTER)+chr(K_CTRL_ENTER)
    // Identificador de local de destino da operaÎ’o
    // 1=Opera‡Æo interna;
    // 2=Opera‡Æo interestadual;
    // 3=Opera‡Æo com exterior
    if Natureza->Local == "D"    
	   cComando += 'idDest=1'+chr(K_ENTER)+chr(K_CTRL_ENTER)
    elseif Natureza->Local == "F"
        cComando += 'IdDest=2'+chr(K_ENTER)+chr(K_CTRL_ENTER)
    endif
    
    // Formato de Impress’o do DANFE
    // 0=Sem gera‡Æo de DANFE;
    // 1=DANFE normal, Retrato;
    // 2=DANFE normal, Paisagem;
    // 3=DANFE Simplificado;
    // 4=DANFE NFC-e;
    // 5=DANFE NFC-e em mensagem eletr“nica (o envio de mensagem eletr“nica 
    //   pode ser feita de forma simultƒnea com a impressÆo do DANFE; usar o
    //   tpImp=5 quando esta for a £nica forma de disponibiliza‡Æo do DANFE)    
    cComando += "tpImp=1"+chr(K_ENTER)+chr(K_CTRL_ENTER)
    
    // Tipo de Emiss’o da NF-e
    // 1=EmissÆo normal (nÆo em contingˆncia);
    // 2=Contingˆncia FS-IA, com impressÆo do DANFE em formul rio de seguran‡a;
    // 3=Contingˆncia SCAN (Sistema de Contingˆncia do Ambiente Nacional);
    // 4=Contingˆncia DPEC (Declara‡Æo Pr‚via da EmissÆo em Contingˆncia);
    // 5=Contingˆncia FS-DA, com impressÆo do DANFE em formul rio de seguran‡a;
    // 6=Contingˆncia SVC-AN (SEFAZ Virtual de Contingˆncia do AN);
    // 7=Contingˆncia SVC-RS (SEFAZ Virtual de Contingˆncia do RS);    
    // 9=Contingˆncia off-line da NFC-e (as demais op‡äes de contingˆncia sÆo v lidas tamb‚m para a NFC-e).
    //   Para a NFC-e somente estÆo dispon¡veis e sÆo v lidas as op‡äes de contingˆncia 5 e 9.
    cComando += "tpEmis=1"+chr(K_ENTER)+chr(K_CTRL_ENTER)
    
    // 28 - IdentificaÎ’o do Ambiente
    cComando += "tpAmb="+Sequencia->TipoAmb+chr(K_ENTER)+chr(K_CTRL_ENTER)
    
    // 29 - Finalidade de emiss’o da NF-e
    // 1=NF-e normal;
    // 2=NF-e complementar;
    // 3=NF-e de ajuste;
    // 4=Devolu‡Æo de mercadoria    
    cComando += "finNFe=4"+chr(K_ENTER)+chr(K_CTRL_ENTER)
    
    // Indica operaÎ’o com Consumidor final
    // 0 - Normal
    // 1 - Consumidor Final
    cComando += 'indFinal=0'+chr(K_ENTER)+chr(K_CTRL_ENTER)
    
    // Indicador de presenÎa do comprador no estabelecimento comercial no 
    // momento da operaÎ’o
    // 0=NÆo se aplica (por exemplo, Nota Fiscal complementar ou de ajuste);
    // 1=Opera‡Æo presencial;
    // 2=Opera‡Æo nÆo presencial, pela Internet;
    // 3=Opera‡Æo nÆo presencial, Teleatendimento;
    // 4=NFC-e em opera‡Æo com entrega a domic¡lio;
    // 9=Opera‡Æo nÆo presencial, outros    
    cComando += "indPres=1"+chr(K_ENTER)+chr(K_CTRL_ENTER)
    
    // DOCUMENTOS FISCAIS REFERENCIADOS -----------------------------------
    NfeDevRef->(dbsetorder(1),dbseek(NfeDev->NumCon))
    nContador := 1
    do while NfeDevRef->NumCon == NfeDev->NumCon .and. NfeDevRef->(!eof())
        cComando += '[NFRef'+strzero(nContador,3)+']'+chr(K_ENTER)+chr(K_CTRL_ENTER)
        cComando += 'Tipo=NFE'+chr(K_ENTER)+chr(K_CTRL_ENTER)
        cComando += 'refNFe='+NfeDevRef->Chave+chr(K_ENTER)+chr(K_CTRL_ENTER)
        NfeDevRef->(dbskip())
        nContador += 1
    enddo
    
    
        
    // EMITENTE --------------------------------------------------------------
    cComando += '[Emitente]'   +chr(K_ENTER)+chr(K_CTRL_ENTER)
	if Sequencia->TipoAmb == "2"
        cComando += 'CNPJ='+cEmpCnpj+chr(K_ENTER)+chr(K_CTRL_ENTER)
		cComando += "IE="+cEmpIe+chr(K_ENTER)+chr(K_CTRL_ENTER)
		cComando += 'Razao= NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL'+CRLF
	else
		cComando += 'CNPJ='+cEmpCnpj+CRLF
		cComando += 'IE='+cEmpIe+CRLF
		cComando += 'Razao='+cEmpRazao+CRLF
    endif
    Cidades->(dbsetorder(1),dbseek(cEmpCodCid))
    cComando += 'Fantasia='    +cEmpFantasia+CRLF
    cComando += 'Fone='        +cEmpTelefone1+CRLF
    cComando += 'CEP='         +cEmpCep+CRLF
    cComando += 'Logradouro='  +cEmpEndereco+CRLF
    cComando += 'Numero='      +cEmpNumero+CRLF
    cComando += 'Complemento='            +CRLF
    cComando += 'Bairro='      +cEmpBairro+CRLF
    cComando += 'CidadeCod='   +Cidades->CodIbge+CRLF
    cComando += 'Cidade='      +Cidades->NomCid+CRLF
    cComando += 'UF='          +cEmpEstCid+CRLF
    cComando += 'PaisCod=1058'            +CRLF
    cComando += 'Pais=BRASIL'             +CRLF
    cComando += 'Crt='         +cEmpCrt+CRLF

    // DESTINATæRIO --------------------------------------------------------
    Cidades->(dbsetorder(1),dbseek(Fornecedor->CodCid))
    cComando += '[Destinatario]'+CRLF
	// ** Ambiente de Produ‡Æo
	if Sequencia->TipoAmb == "1"
		// ** Pessoa Juridica
		cComando += 'CNPJ='+Fornecedor->CgcFor+CRLF
		cComando += 'IE='+Fornecedor->IESFor+CRLF
		cComando += 'indIEDest='+Fornecedor->indIEDest+CRLF  // ** NFE 3.10
        cComando += 'NomeRazao='+Fornecedor->RazFor +CRLF
   else
      cComando += 'CNPJ=99999999000191'+CRLF
      cComando += 'indIEDest=9'+CRLF
      cComando += 'Razao= NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL'+CRLF
   endif
   cComando += 'Fone='+Fornecedor->TelFor1     +CRLF
   cComando += 'CEP='+Fornecedor->CepFor       +CRLF
   cComando += 'Logradouro='+Fornecedor->EndFor+CRLF
   cComando += 'Numero='+Fornecedor->Numero+CRLF
   cComando += 'Bairro='+Fornecedor->BaiFor   +CRLF
   cComando += 'CidadeCod='+Cidades->CodIbge  +CRLF
   cComando += 'Cidade='+Cidades->NomCid     +CRLF
   cComando += 'UF='+Cidades->EstCid         +CRLF
   cComando += 'PaisCod=1058'                +CRLF
   cComando += 'Pais=BRASIL'                 +CRLF
   
   // Produtos -------------------------------------------------------------
   nValorDoTributos := 0

   NfeDevItem->(dbsetorder(1),dbseek(nfedev->NumCon))
   nContador := 1
	while nfedevitem->NumCon == nfedev->NumCon .and. nfedevitem->(!eof())
		Produtos->(dbsetorder(1),dbseek(nfedevitem->CodPro))
		cComando += '[Produto'      +strzero(nContador,3)+']'+CRLF
		cComando += 'CFOP='+nfedevitem->Cfop+CRLF
		cComando += 'Codigo='+nfedevitem->CodPro+CRLF
		cComando += 'NCM='+Produtos->CodNCM+CRLF
		cComando += 'Descricao='    +Produtos->DesPro+CRLF
		cComando += 'Unidade='+Produtos->EmbPro+CRLF
		cComando += 'Quantidade='+rtrim(alltrim(str(nfedevitem->QtdPro,15,3)))+CRLF
		cComando += 'ValorUnitario='+rtrim(alltrim(str(round(nfedevitem->PcoPro,2),13,2)))+CRLF
		cComando += 'ValorTotal='   +rtrim(alltrim(str(nfedevitem->TotPro,13,2)))+CRLF
		cComando += 'vDesc='+rtrim(alltrim(str(nfedevitem->Desconto,13,2)))+CRLF
        cComando += 'vOutro='+rtrim(alltrim(str(nfedevitem->Outro,13,2)))+CRLF
		cComando += 'vTotTrib='+rtrim(alltrim(str(nValorDoTributos,13,2)))+CRLF
        
	    cComando +='[ICMS'+strzero(nContador,3)+']'+CRLF
        cComando += "orig="+Produtos->Origem+CRLF
        cComando += 'CSOSN='+nfedevitem->Cst+CRLF
        cComando += 'modBC='+nfedevitem->ModBc+CRLF
        cComando += 'vBc='+rtrim(alltrim(str(nfedevitem->vBc,13,2)))+CRLF
        cComando += 'pRedBC='+rtrim(alltrim(str(nfedevitem->pRedBc,9,4)))+CRLF
        cComando += 'pICMS='+rtrim(alltrim(str(nfedevitem->pICMS,9,4)))+CRLF
        cComando += 'vICMS='+rtrim(alltrim(str(nfedevitem->vICMS,13,2)))+CRLF
        
        cComando += 'modBCST='+nfedevitem->ModBCST+CRLF
        cComando += 'pMVAST='+rtrim(alltrim(str(nfedevitem->pMVAST,9,4)))+CRLF
        cComando += 'pRedBCST='+rtrim(alltrim(str(nfedevitem->pRedBCST,9,4)))+CRLF
        cComando += 'vBCST='+rtrim(alltrim(str(nfedevitem->vBCST,13,2)))+CRLF
        cComando += 'pICMSST='+rtrim(alltrim(str(nfedevitem->pICMSST,9,4)))+CRLF
        cComando += 'vICMSST='+rtrim(alltrim(str(nfedevitem->vICMSST,13,2)))+CRLF
        
        cComando += "[PIS"+strzero(nContador,3)+"]"+chr(K_ENTER)+chr(K_CTRL_ENTER)
        cComando += 'CST='+nfedevitem->CstPis+CRLF

        cComando += "[COFINS"+strzero(nContador,3)+"]"+chr(K_ENTER)+chr(K_CTRL_ENTER)
        cComando += 'CST='+nfedevitem->CstCofins+CRLF
        
        if !empty(nfedevitem->cstIPI)
            cComando += "[IPI"+strzero(nContador,3)+"]"+chr(K_ENTER)+chr(K_CTRL_ENTER)
            cComando += "CST="+nfedevitem->cstIPI+chr(K_ENTER)+chr(K_CTRL_ENTER)
            cComando += "cEnq="+nfeDevItem->cEnqIPI+chr(K_ENTER)+chr(K_CTRL_ENTER)
            cComando += "vBC="+rtrim(alltrim(str(nfeDevItem->BcIPI,13,2)))+chr(K_ENTER)+chr(K_CTRL_ENTER)
            cComando += "pIPI="+rtrim(alltrim(str(nfeDevItem->pIPI,9,4)))+CRLF
            cComando += "vIPI="+rtrim(alltrim(str(nfeDevItem->vIPI,13,2)))+CRLF
        endif
        nfedevitem->(dbskip())
        nContador += 1
   enddo
   cComando +='[Total]'+CRLF
   // Base de calculo do ICMS
   cComando += 'vBc='+rtrim(alltrim(str(nfedev->vBC,13,2)))+CRLF
   // // Valor total do ICMS
   cComando += 'vICMS='+rtrim(alltrim(str(nfedev->vICMS,13,2)))+CRLF
   // Valor tota do ICMS desonerado
   cComando += "vICMSDeson="+rtrim(alltrim(str(nfedev->vICMSDeson,13,2)))+CRLF
   // base de Calculo do ICMS ST
   cComando += "vBCST="+rtrim(alltrim(str(nfedev->vBCST,13,2)))+CRLF
   // Valor total do ICMS ST
   cComando += "vST="+rtrim(alltrim(str(nfedev->vST,13,2)))+CRLF
   // Valor total do produtos e serviÎos
   cComando += 'vProd='+rtrim(alltrim(str(nfedev->vProd,13,2)))+CRLF
   // Frete                                    
   cComando += 'vFrete='+rtrim(alltrim(str(nfedev->vFrete,13,2)))+CRLF
   // Seguro
   cComando += 'vSeg='+rtrim(alltrim(str(nfedev->vSeg,13,2)))+CRLF
   // Desconto
   cComando += 'vDesc='+rtrim(alltrim(str(nfedev->vDesc,13,2)))+CRLF
   cComando += "vII="+rtrim(alltrim(str(nfedev->vII,13,2)))+CRLF
   cComando += "vIPI="+rtrim(alltrim(str(nfedev->vIpi,13,2)))+CRLF
   cComando += "vPis="+rtrim(alltrim(str(nfedev->vpis,13,2)))+CRLF
   cComando += "vCofins="+rtrim(alltrim(str(nfedev->vCofins),13,2))+CRLF
   // Outras despesas
   cComando += 'vOutro='+rtrim(alltrim(str(nfedev->vOutro,13,2)))+CRLF
   // Valor total da Nota
   cComando += 'vNF='+rtrim(alltrim(str(nfedev->vNF,13,2)))+CRLF


    //Dados do Transportador ----------------------------------------------
    cComando += '[Transportador]'+CRLF
    cComando += 'FretePorConta=' +nfedev->TipFre+CRLF
    cComando += 'CnpjCpf='       +Transpo->CGCTra+CRLF
    cComando += 'NomeRazao='     +Transpo->NomTra+CRLF
    cComando += 'IE='            +Transpo->InsTra+CRLF
    cComando += 'Endereco='      +Transpo->EndTra+CRLF
    cComando += 'Cidade='        +Transpo->CidTra+CRLF
    cComando += 'UF='            +Transpo->EstTra+CRLF
    cComando += 'Placa='         +Transpo->PlaTra+CRLF
    cComando += 'UFPlaca='       +Transpo->EstPla+CRLF
    
    
    // Detalhe de pagamento
    cComando += "[Pag001"+"]"+CRLF
    cComando += "tPag=90"+CRLF
    cComando += "vPag=0.00"+CRLF
    
   
    // Grupo de volumes transportdados ------------------------------------
    if !empty(nfedev->qvol)
        cComando += "[VOLUME001]"+CRLF
        cComando += "qVol="+rtrim(alltrim(str(nfedev->qvol,15,0)))+CRLF
        cComando += "esp="+nfedev->esp+CRLF
        cComando += "marca="+nfedev->marca+CRLF
        cComando += "nVol="+nfedev->nVol+CRLF
        cComando += "pesoL="+rtrim(alltrim(str(nfedev->pesoL,12,3)))+CRLF
        cComando += "pesoB="+rtrim(alltrim(str(nfedev->pesoB,12,3)))+CRLF
    endif

    // Dados Adicionais ---------------------------------------------------    
	cDadosAdicionais := ""
	cDadosAdicionais += nfedev->ObsNot1+";"
	if !empty(nfedev->ObsNot2)
		cDadosAdicionais += nfedev->ObsNot2 + ";"
	endif
	if !empty(nfedev->ObsNot3)
      cDadosAdicionais += nfedev->ObsNot3 + ";"
   end
   if !empty(nfedev->ObsNot4)
      cDadosAdicionais += nfedev->ObsNot4 + ";"
   end
   if !empty(nfedev->ObsNot5)
      cDadosAdicionais += nfedev->ObsNot5 + ";"
   end
   if !empty(nfedev->ObsNot6)
      cDadosAdicionais += nfedev->ObsNot6 + ";"
   end
   cComando +='[DadosAdicionais]'+CRLF
   cComando +='Complemento='+cDadosAdicionais+CRLF
   return

static function ImprimirNFe(cChave)
    local cArquivoXML
	
    cArquivoXML := rtrim(Sequencia->DirNFe)+'\'+cChave+'-nfe.xml' 	
	Msg(.t.)
	Msg("Aguarde: Imprimindo ")
	AcbrNFe_ImprimirDanfe(rtrim(Sequencia->DirNFe),cArquivoXML)
	Msg(.f.)
	return(.t.)

static function CriarNFe
    local cRetorno
    
    // cChNfe - variavel private declara na rotina que chama essa

    
    Msg(.t.)
	Msg("Aguarde: Criando NF-e")
	AcbrNFe_CriarNFe(rtrim(Sequencia->dirnfe),cComando)
    cRetorno := Mon_Ret(rtrim(Sequencia->dirNFe),"sainfe.txt",Sequencia->Tempo)
	if !MEN_OK(cRetorno)
		Msg(.f.)
		LerErro(rtrim(Sequencia->DirNFe),"sainfe.txt")
		return(.f.)
	endif
	Msg(.f.)
    cChNfe := substr(cRetorno,(rat('\',cRetorno)+1),44)
	return(.t.)

/*
    Assina uma NFe. Arquivo assinado ser  salvo na pasta configurada na aba 
    WebService na op‡Æo "Salvar Arquivos de Envio e Resposta
    cChNfe - Variavel declara na rotina que chama essa
*/
         
static function AssinarNFe
    local cRetorno,cArquivoXML
	Msg(.t.)
	Msg("Aguarde: Assinando NF-e")
	cArquivoXML := rtrim(Sequencia->DirEnvResp)+'\'+cChNfe+'-nfe.xml'
	AcbrNFe_AssinarNFe(rtrim(Sequencia->DirNFe),cArquivoXML)
    cRetorno := Mon_Ret(rtrim(Sequencia->dirNFe),"sainfe.txt",Sequencia->Tempo)
	if !Men_Ok(cRetorno)
		Msg(.f.)
		LerErro(rtrim(Sequencia->DirNFe),"sainfe.txt")
		return(.f.)
	endif
	Msg(.f.)
	return(.t.)
         
static function ValidarNFe
	local cRetorno,cArquivoXML
	// Variavel "cArquivoXML" declarada como private no opcao de TransmitirNFCe,IncNFCe
    // cChNfe - Variavel declara na rotina que chama essa
    cArquivoXML := rtrim(Sequencia->DirEnvResp)+'\'+cChNfe+'-nfe.xml'
	Msg(.t.)
	Msg("Aguarde: Validando NF-e")
	AcbrNFe_ValidarNFe(rtrim(Sequencia->DirNFe),cArquivoXML)
    cRetorno := Mon_Ret(rtrim(Sequencia->dirNFe),"sainfe.txt",Sequencia->Tempo)
	if !Men_Ok(cRetorno)
		Msg(.f.)
		LerErro(rtrim(Sequencia->DirNFe),"sainfe.txt")			
		return(.f.)
	endif
	Msg(.f.)
	return(.t.)
         
static function TransmitirNFe
	local cRetorno,cArquivoXML

    // Inicializa variaveis privadas
    cNRec    := "" // n£mero do recibo
    cCStat   := ""
    cXMotivo := "" // 
    cDhRec   := "" // data e hora do recebimento
    cNProt   := "" // n£mero do protocolo
    // ** arquivo ja assinado e validado 
    cArquivoXML := rtrim(Sequencia->DirEnvResp)+'\'+cChNfe+'-nfe.xml'    
    
	Msg(.t.)
	Msg("Aguarde: Transmitindo NF-e")
    AcbrNFe_EnviarNFe(rtrim(Sequencia->DirNFe),cArquivoXML,0,0,0,"",1)
    cRetorno := Mon_Ret(rtrim(Sequencia->dirNFe),"sainfe.txt",Sequencia->Tempo)
	if !Men_Ok(cRetorno)
		Msg(.f.)
		LerErro(rtrim(Sequencia->DirNFe),"sainfe.txt")
		return(.f.)
	else
        cCStat   := RetornoSEFAZ("CStat",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
        cXMotivo := RetornoSEFAZ("XMotivo",rtrim(Sequencia->dirNFe)+"\sainfe.txt") 
		if !(cCStat == "100")
			MostrarErro(cCStat,cXMotivo)
			Msg(.f.)
			return(.f.)
		endif
	endif
	Msg(.f.)
	return(.t.)
    
procedure StatusServicoNFe
	local lInternet,cRetorno,cCStat,cXMotivo

	Msg(.t.)
	Msg("Aguarde : Abrindo o Arquivo")
	if !OpenSequencia()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
	Msg(.f.)
	if Sequencia->TestarInte == "S"
		lInternet := Testa_Internet()
         if !lInternet
            return
         endif
	endif
	Msg(.t.)
	Msg("Aguarde: Verificando a Comunicacao com a SEFAZ")
	AcbrNFe_StatusServico(rtrim(Sequencia->DirNFE))
    cRetorno := Mon_Ret(rtrim(Sequencia->dirNFE),"sainfe.txt",Sequencia->Tempo)
	if !Men_Ok(cRetorno)
		Msg(.f.)
		LerErro(rtrim(Sequencia->DirNFE),"sainfe.txt")
		FechaDados()
		return
	endif
	Msg(.f.)
	cCStat   := MEN_RET( "CStat", cRetorno )
	cXMotivo := MEN_RET( "XMotivo", cRetorno )
	MostrarErro(cCStat,cXMotivo)	
	FechaDados()
	return
    
procedure CanNfeDev
   local getlist := {},cTela := SaveWindow()
   local cNumCon,cMotivo
   private cCStat,cXMotivo,cNProt,cDhRecbto

    Msg(.t.)
    Msg("Aguarde: Abrindo os arquivos")
    if !OpenFornecedor()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenSequencia()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenProdutos()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !Open_NfeDev()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !Open_NfeDevItem()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !Open_NfeDevRef()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenTranspo()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenCidades()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    Msg(.f.)
    AtivaF4()
    Window(07,07,17,72," Cancelar NF-e ")
    setcolor(Cor(11))
   @ 09,09 say "    N§ Controle:"
   @ 10,09 say "        N§ Nota:"
   @ 11,09 say "     Fornecedor:"
   @ 12,09 say "Data de Emissao:"
   @ 13,09 say "  Data de Sa¡da:"
   @ 14,09 say "          Valor:"
   @ 15,09 say "        Motivo :"
   while .t.
      cNumCon := Space(10)
      cMotivo := space(40)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 09,26 get cNumCon picture "@k 9999999999";
                when Rodape("Esc-Encerra | F4-Notas ");
                valid Busca(Zera(@cNumCon),"nfedev",1,,,,{"Controle Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      Fornecedor->(dbsetorder(1),dbseek(nfedev->CodFor))
      nfedevitem->(dbsetorder(1),dbseek(cNumCon))
      @ 10,26 say nfedev->NumNot
      @ 11,26 say nfedev->CodFor+"-"+left(Fornecedor->RazFor,40)
      @ 12,26 say nfedev->DtaEmi
      @ 13,26 say nfedev->DtaSai
      @ 14,26 say nfedev->VNF picture "@e 999,999.99"
        if !Nfedev->Autorizado
            Mens({"Nota fiscal nÆo autorizada"})
            loop
        endif
        if Nfedev->Cancelada
            Mens({"Nota Ja Cancelada"})
            loop
        endif
        @ 15,26 get cMotivo picture "@k";
            valid iif(!empty(cMotivo),;
            iif(len(rtrim(cMotivo)) < 15,(Mens({"Caracter m¡nimo ‚ 15"}),.f.),.t.),.t.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            loop
        endif
        if !Confirm("Confirma o Cancelamento",2)
            loop
        endif
		if Sequencia->TestarInte == "S"
			lInternet := Testa_Internet()
			if !lInternet
				loop
			endif
		endif
        if !Status_NFeNFCe(Sequencia->DirNfe)
			loop
		endif
		Msg(.t.)
		Msg("Aguarde: Cancelando NF-e")
        AcbrNFE_CancelarNFe(rtrim(Sequencia->DirNFe),NfeDev->ChNfe,rtrim(cMotivo),cEmpCnpj)
        cRetorno := Mon_Ret(rtrim(Sequencia->dirNFe),"sainfe.txt",Sequencia->Tempo)
		if !Men_Ok(cRetorno)
			Msg(.f.)
			LerErro(rtrim(Sequencia->DirNFe),"sainfe.txt")
			loop
		endif
		Msg(.f.)
        cCStat    := RetornoSEFAZ("CStat",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
        cXMotivo  := RetornoSEFAZ("XMotivo",rtrim(Sequencia->dirNFe)+"\sainfe.txt") 
        cNProt    := RetornoSEFAZ("NProt",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
        cDhRecbto := RetornoSEFAZ("DhRecbto",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
		if !(cCStat == "135")
			MostrarErro(cCStat,cXMotivo)
			loop
		endif
		if empty(cNProt)
			Mens({"Problema com Protocolo de Cancelamento","Favor repetir o cancelamento"})
			loop
		endif
		do while Nfedev->(!Trava_Reg())
		enddo
      	nfedev->Cancelada   := .t.
        nfedev->CStat      := cCStat
        nfedev->XMotivo    := cXMotivo
		nfedev->DhRecbto   := cDhRecbto
		nfedev->NProt      := cNProt
      	nfedev->(dbunlock())
        nfedevitem->(dbsetorder(1),dbseek(cNumCon))
        do while nfedevitem->NumCon == cNumCon .and. nfedevitem->(!eof())
            do while !nfedevitem->(Trava_Reg())
            enddo
            if Produtos->(dbsetorder(1),dbseek(nfedevitem->CodPro))
                if Produtos->CtrlEs == "S"
                    do while !Produtos->(Trava_Reg())
                    enddo
                    Produtos->QteAc01 += nfedevitem->QtdPro
                    Produtos->(dbunlock())
                endif
            endif
            nfedevitem->(dbdelete())
            nfedevitem->(dbcommit())
            nfedevitem->(dbunlock())
            nfedevitem->(dbskip())
        enddo
        Mens({"Nota fiscal cancelada"})
    enddo
    DesativaF4()
    if PwNivel == "0"
        AtivaF9()
    endif
    FechaDados()
    RestWindow(cTela)
    return

procedure SefazDev
	local getlist := {},cTela := SaveWindow()
	local cNrNota,cStatus

	Msg(.t.)
	Msg("Aguarde : Abrindo o Arquivo")
    if !OpenFornecedor()
		FechaDados()
		Msg(.f.)
		return
	endif
    if !OpenSequencia()
		FechaDados()
		Msg(.f.)
		return
	endif
    if !Open_NfeDev()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !Open_NfeDevItem()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !Open_NfeDevRef()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
	Msg(.f.)
	AtivaF4()
	Window(08,09,21,70," Consultar NFe na Sefaz ")
	setcolor(Cor(11))
	@ 10,11 say "Nr. da Nota:"
	@ 11,11 say " Fornecedor:"
	@ 12,11 say "       Data:"
	@ 13,11 say "      Valor:"
	@ 14,10 say replicate(chr(196),60)
	@ 15,11 say "    Retorno:"
	@ 16,11 say "     Status:"
	@ 17,11 say "     Motivo:"
	@ 18,11 say "  Protocolo:"
	@ 19,11 say "  Data/Hora:"
	do while .t.
		cNrNota  := Space( 9)
		cEmail   := space(60)
		cAssunto := space(60)
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 10,24 get cNrNota picture "@k 999999999";
                    valid Busca(Zera(@cNrNota),"nfedev",3,,,,{"Nota Fiscal nao Cadastrada"},.f.,.f.,.f.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		Fornecedor->(dbsetorder(1),dbseek(nfedev->CodFor))
		if !nfedev->Autorizado
			Mens({"Nota fiscal nÆo autorizada"})
 			loop
		endif
		cEmail := Fornecedor->EmaFor+space(20)
		@ 11,24 say nfedev->CodFor+"-"+left(Fornecedor->RazFor,40)
		@ 12,24 say nfedev->DtaSai
		@ 13,24 say nfedev->vNF picture "@e 999,999.99"
		if !Confirm("Confirma as Informacoes")
			loop
		endif
		if Sequencia->TestarInte == "S"
			lInternet := Testa_Internet()
         	if !lInternet
            	loop
         	endif
		endif
        // ** verifica o status de conexão com a secretária da fazenda
        if !Status_NFeNFCe(Sequencia->DirNfe)
			loop
		endif
		Msg(.t.)
		Msg("Aguarde: Consultando NF-e na SEFAZ")
		AcbrNFe_ConsultarNFe(rtrim(Sequencia->DirNFe),nfedev->ChNFe)
        cRetorno  := Mon_Ret(rtrim(Sequencia->dirNFe),"sainfe.txt",Sequencia->Tempo)
		if !Men_Ok(cRetorno)
			Msg(.f.)
			LerErro(rtrim(Sequencia->DirNFe),"sainfe.txt")
			loop
		endif
		Msg(.f.)
        cCStat    := RetornoSEFAZ("CStat",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
		cNProt    := RetornoSEFAZ("NProt",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
		cDhRecbto := RetornoSEFAZ("DhRecbto",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
		cXMotivo  := RetornoSEFAZ("XMotivo",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
		@ 15,24 say space(10)
		@ 15,24 say substr(cRetorno,1,at(":",cRetorno))
		@ 16,24 say cCStat
		@ 17,24 say cXMotivo
		@ 18,24 say cNProt
		@ 19,24 say cDhRecbto
        do while NfeDev->(!Trava_Reg())
        enddo
        if cCstat == "100"
			NfeDev->Autorizado := .t.
        elseif cCstat == "101"
            NfeDev->Cancelada   := .t.
        endif
        NfeDev->CStat      := cCStat
        NfeDev->XMotivo    := cXMotivo
		NfeDev->DhRecbto   := cDhRecbto
		NfeDev->NProt      := cNProt
        NfeDev->(dbcommit())
        NfeDev->(dbunlock())
	enddo
	DesativaF4()
	if PwNivel == "0"
		AtivaF9()
	endif
	FechaDados()
	RestWindow(cTela)
	return

procedure ImpNfeDev
    local getlist := {},cTela := SaveWindow()
    local cNumCon,nCopia

    Msg(.t.)
    Msg("Aguarde : Abrindo o Arquivo")
    if !OpenFornecedor()
        Msg(.f.)
        FechaDados()
        return
    endif
    if !OpenSequencia()
        Msg(.f.)
        FechaDados()
        return
    endif
    if !Open_NfeDev()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !Open_NfeDevItem()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !Open_NfeDevRef()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    Msg(.f.)
    AtivaF4()
    Window(08,09,15,70," Imprimir NFE ")
    setcolor(Cor(11))
    @ 10,11 say "N§ Controle:"
    @ 11,11 say " Fornecedor:"
    @ 12,11 say "       Data:"
    @ 13,11 say "      Valor:"
    do while .t.
        cNumCon := Space( 10 )
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 10,24 get cNumCon picture "@k 9999999999";
                valid Busca(Zera(@cNumCon),"nfedev",1,,,,{"Controle Nao Cadastrado"},.f.,.f.,.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        Fornecedor->(dbsetorder(1),dbseek(nfedev->CodFor))
        @ 11,24 say nfedev->CodFor+"-"+left(Fornecedor->RazFor,40)
        @ 12,24 say nfedev->DtaEmi
        @ 13,24 say nfedev->vnf picture "@e 999,999.99"
        if !nfedev->Autorizado
            Mens({"Nota fiscal nÆo autorizada"})
            loop
        endif
        if !Confirm("Confirma a ImpressÆo")
            loop
        endif
        if Sequencia->TestarInte == "S"
			lInternet := Testa_Internet()
         	if !lInternet
            	loop
         	endif
		endif
        ImprimirNFe(nfedev->ChNfe)
    enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   endif
   FechaDados()
   RestWindow(cTela)
   return

// Fim do arquivo.
