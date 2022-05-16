/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 3.00
 * Identificacao: Manutencao de Notas Fiscais - Saida
 * Prefixo......: LTADM
 * Programa.....: CAIXA.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 28 DE DEZEMBRO DE 2002
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "Fileio.ch"
#define CRLF chr(K_ENTER)+chr(K_CTRL_ENTER)

procedure ConNfeEntrada(lAbrir,lRetorno)
   local oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados,cTela2
   local nCursor := setcursor(),cCor := setcolor(),cCodCaixa,Sai_Mnu := .f.
   local aTitulo := {},aCampo := {},aMascara := {},Inicio,Fim,nPedido1,nPedido2,cFiltro
   local Item[05],aV_Zer[08],nLin1,nCol1,nLin2,nCol2
   private nRecno

   if lAbrir
      Msg(.t.)
      Msg("Aguarde : Abrindo o Arquivo")
        if !OpenCidades()
            FechaDados()
            Msg(.f.)
            return
        endif
        if !OpenGrupos()
            FechaDados()
            Msg(.f.)
            return
        endif
      // ** Compras
        if !OpenClientes()
            FechaDados()
            Msg(.f.)
            return
        endif
      // ** Iten da Compra
        if !OpenVendedor()
            FechaDados()
            Msg(.f.)
            return
        endif
      // ** Natureza Fiscal
        if !OpenProdutos()
            FechaDados()
            Msg(.f.)
            return
        endif
        if !OpenSubGrupo()
            FechaDados()
            Msg(.f.)
            return
        endif
        if !OpenNfeEntrada()
            FechaDados()
            Msg(.f.)
            return
        endif
        if !OpenNfeItemEntrada()
            FechaDados()
            Msg(.f.)
            return
        endif
        if !OpenNatureza()
            FechaDados()
            Msg(.f.)
            return
        endif
        if !OpenSitTrib()
            FechaDados()
            Msg(.f.)
            return
        endif
        if !OpenSequencia()
            FechaDados()
            Msg(.f.)
            return
        endif
        if !OpenTranspo()
            FechaDados()
            Msg(.f.)
            return
        endif
        if !OpenDupRec()
            FechaDados()
            Msg(.f.)
            return
        endif
      Msg(.f.)
   else
      setcursor(SC_NONE)
   endif
   select nfeentrada
   set order to 1
   dbgobottom()
   if lAbrir
      Rodape("Esc-Encerrar")
   else
      Rodape("Esc-Encerra | ENTER-Transfere")
   end
   setcolor(cor(5))
   nLin1 := 02
   nCol1 := 00
   nLin2 := maxrow()-1
   nCol2 := 100
   Window(nLin1,nCol1,nLin2,nCol2,"> Consulta de Notas Fiscais <")
    oBrow := TBrowseDB(nLin1+1,nCol1+1,nLin2-7,nCol2-1)
    oBrow:headSep := SEPH
    oBrow:footSep := SEPB
    oBrow:colSep  := SEPV
    oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)   
    oCol := TBColumnNew("Controle",{|| nfeentrada->NumCon})
    oCol:colorblock := {|| iif( nfeentrada->Autorizado,{1,2},{3,2})}   
	oBrow:addcolumn(oCol)

    oCol := TBColumnNew("Nota"    ,{|| nfeentrada->NumNot})
    oCol:colorblock := {|| iif( nfeentrada->Autorizado,{1,2},{3,2})}   
	oBrow:addcolumn(oCol)
    
    oCol := TBColumnNew("Emissao" ,{|| nfeentrada->DtaEmi})
    oCol:colorblock := {|| iif( nfeentrada->Autorizado,{1,2},{3,2})}   
	oBrow:addcolumn(oCol)
    
    oCol := tbcolumnnew("Cliente" ,{|| Clientes->(dbsetorder(1),dbseek(nfeentrada->CodCli),nfeentrada->CodCli+"-"+left(Clientes->NomCli,30))})
    oCol:colorblock := {|| iif( nfeentrada->Autorizado,{1,2},{3,2})}   
	oBrow:addcolumn(oCol)
    
    oCol := TBColumnNew("Valor da;Nota" ,{|| transform(nfeentrada->TotNot,"@e 999,999.99")})
    oCol:colorblock := {|| iif( nfeentrada->Autorizado,{1,2},{3,2})}   
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
        @ nLin2-6,01 say " Situacao: "+nfeentrada->CStat Color Cor(11)
        @ nLin2-5,01 say "   Motivo: "+nfeentrada->XMotivo color Cor(11)
        
        if empty(nfeentrada->chnfe)
            @ nLin2-4,01 say "    Chave: "+space(50) color Cor(11)
        else
            @ nLin2-4,01 say "    Chave: "+transform(nfeentrada->chnfe,"9999.9999.9999.9999.9999.9999.9999.9999.9999.9999") color Cor(11)
        endif
        @ nLin2-3,01 say "Protocolo: "+nfeentrada->NProt color Cor(11)
        @ nLin2-2,01 say "Data/Hora: "+nfeentrada->DhRecBto color Cor(11)
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
               		   cDados := nfeentrada->NumCon
               	    else
               		   cDados := nfeentrada->NumNot
               	    endif
                    keyboard (cDados)+chr(K_ENTER)
                    lFim := .t.
                endif
            elseif nTecla == K_F3
                VerItemNot(nfeentrada->NumCon)
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

procedure IncNfeEntrada
    local getlist := {},cTela := SaveWindow()
    local llimpa := .t.
    local cCodCli,cSerNot,cSubSer,cCodMod,dDtaEmi,dDtaSai
    local aCampo := {},aTitulo := {},aMascara := {},cNumPed
    Private cNumCon, cNumNot, MDtaEmi, MDtaSai,cEstCli,cCodNat
    private nTotPro, nBasNor, nBasSub, nICMNor, nICMSub, MTotNot, nFreNot, MSegNot
    private MOutDsp, MIPINot, MAliICM,  MPesLiq, MPesBru, cTipFre, cObsNot1,cCodTra
    private cObsNot2, cObsNot3, cObsNot4, cObsNot5, cObsNot6, MCodPla, MCFONat, nDscNot
    private MBruPro,nQtdVol,cEspVol,cMarVol,nNumVol
    Private Operacao, VCliente, VVencmto, VParcela, Tela_P, MNumPar, MPrzPar, MValTot, Saiu := .f.
    Private aCodItem := {},aCodPro := {},aDesPro := {},aQtdEmb := {},aQtdPro := {}
    private aAliSai := {},aPcoPro := {},VDscPro := {},aTotPro := {}
    private aDesconto := {}
    private aCST    := {},aBaseIcms := {},aValorICMS := {},aIPI    := {}
    private VVencmto, VParcela, VChaves[25]
    private MNumPar, MEntPla, nAliq07, nAliq12, nAliq17, nAliq25, nAliq00, MGerDup
    private aCodNat := {} // Codigo da natureza
    private lEntrada := .f.

    // Variavel para a criacao da Nfe   
    private cComando
    // ** declara Variaveis de retorno do acbr    
    private cNRec    // número do recibo
    private cCStat
    private cXMotivo // 
    private cChNfe  // chave da acesso
    private cDhRec  // data e hora do recebimento
    private cNProt  // número do protocolo

    if !AbrirArquivos()
        return
    endif
    AtivaF4()
    TelaNfeEntrada(1)
    do while .t.
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      if lLimpa
         cNumCon := Space( 10 )
         cNumNot := Space( 06 )
         cCodCli := space(04)
         cCodNat := space(03)
         
         cSerNot := "1  "
         cSubSer := space(02)
         
         dDtaEmi := date()
         dDtaSai := ctod(space(08))
         
         cCodMod := "01"
         MCodPar := Space( 02 )
         nFreNot := 0
         MSegNot := 0
         cCodTra := Space( 02 )
         nQtdVol := 0
         cEspVol := Space( 10 )
         cMarVol := Space( 10 )
         nNumVol := 0
         MTipEnt := [1]
         MTipPar := [3]
         MEntPla := 0
         cTipFre := Space( 01 )
         MCodPla := Space( 02 )
         nDscNot := 0
         MBruPro := 0
         cObsNot1 := Space( 50 )
         cObsNot2 := Space( 50 )
         cObsNot3 := Space( 50 )
         cObsNot4 := Space( 50 )
         cObsNot5 := Space( 50 )
         cObsNot6 := Space( 50 )
         MIPINot  := 0
         nAliq07  := 0
         nAliq12  := 0
         nAliq17  := 0
         nAliq25  := 0
         nAliq00  := 0
         MGerDup  := .f.
         
         aCodItem := {}
         aCodPro  := {}
         aDesPro  := {}
         aAliSai  := {}
         aQtdEmb  := {}
         aQtdPro := {}
         aPcoPro := {}
         VDscPro := {}
         aTotPro := {}
         aCST    := {}
         aDesconto := {}
         aBaseIcms := {}
         aValorICMS := {}
         aIPI      := {}
         aCodNat := {}
         
            aadd(aCodItem,space(13))
            aadd(aCodPro,space(06))
            aadd(aDesPro,Space(37))
            aadd(aAliSai,0)
            aadd(aQtdPro,0)
            aadd(aPcoPro,0)
            aadd(aTotPro,0)
            aadd(aCST,space(03))
            aadd(aBaseIcms,0)
            aadd(aValorICMS,0)
            aadd(aIPI,0)
            aadd(aDesconto,0)
            aadd(aCodNat,space(03))
            lLimpa := .f.
        endif
      nTotPro = 0
      nBasNor = 0
      nBasSub = 0
      nICMSub = 0
      nICMNor = 0
      MAliICM = 0
      MPesLiq = 0
      MPesBru = 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      if (Sequencia->LancNfeEnt+1) > 9999999999
         Mens({"Limite de Lancamento Esgotado"})
         exit
      endif
      //cNumCon := strzero(Sequencia->LancNfeEnt+1,10)
      //cNumNot := strzero(Sequencia->NumNFE+1,9,0)
      //@ 03,11 say cNumCon
 //     @ 08,36 say Soma_Vetor(aDesconto) picture "@e 99,999,999.99"
      @ 05,11 get cCodCli picture "@k 9999" when Rodape("Esc-Encerra | F4-Clientes") valid vCliente(@cCodCli)
      @ 06,11 get cCodNat picture "@k";
                valid ValidNatureza(@cCodNat)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      @ 07,11 get dDtaEmi picture "@k";
                valid NoEmpty(dDtaEmi) 
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      endif
      // ** Observa‡Æo da Nota - Natureza
      cObsNot1 := Natureza->Obs1
      cObsNot2 := Natureza->Obs2
      cObsNot3 := Natureza->Obs3
      cObsNot4 := Natureza->Obs4
      cObsNot5 := Natureza->Obs5
      cObsNot6 := Natureza->Obs6
      aCampo   := {}
      aTitulo  := {}
      aMascara := {}
      
      aadd(aCampo,"aCodItem")    // ** 1
      aadd(aCampo,"aDesPro")    // ** 2
      aadd(aCampo,"aQtdPro")    // ** 3
      aadd(aCampo,"aPcoPro")    // ** 4
      aadd(aCampo,"aDesconto")  // ** 5
      aadd(aCampo,"aTotPro")    // ** 6
      aadd(aCampo,"aCST")       // ** 7
      aadd(aCampo,"aAliSai")    // ** 8
      aadd(aCampo,"aBaseICMS")  // ** 9
      aadd(aCampo,"aValorICMS") // ** 10
      aadd(aCampo,"aIPI")       // ** 11
      *----------
      aadd(aTitulo,"C¢digo")         // ** 1
      aadd(aTitulo,"Descri‡„o ")     // ** 2
      aadd(aTitulo,"Qtde.")          // ** 3
      aadd(aTitulo,"P‡o. Venda")     // ** 4
      aadd(aTitulo,"Desconto")       // ** 5
      aadd(aTitulo,"Total")          // ** 6
      aadd(aTitulo,"CST")            // ** 7
      aadd(aTitulo,"Aliq.ICMS")      // ** 8
      aadd(aTitulo,"Base ICMS")      // ** 9
      aadd(aTitulo,"Vl. ICMS")       // ** 10
      aadd(aTitulo,"Aliq.IPI")       // ** 11
      *----------
      aadd(aMascara,"@k!")       // ** 1
      aadd(aMascara,"@!S40")           // ** 2
      aadd(aMascara,"@E 999,999.999") // ** 3 Quantidade do produto
      aadd(aMascara,"@E 99,999.999")  // ** 4 Valor Unitário
      aadd(aMascara,"@e 99,999.99")    // ** 5 Desconto
      aadd(aMascara,"@E 9,999,999.99") // ** 6 Valor Total
      aadd(aMascara,"@!")              // ** 7
      aadd(aMascara,"999.99")          // ** 8 Aliquota de ICMS
      aadd(aMascara,"@E 999,999.99")    // ** 9
      aadd(aMascara,"@E 999,999.99")    // ** 10
      aadd(aMascara,"999.99")          // ** 11
      //setcolor(Cor(26))
      //@ 21,01 say replicate(chr(196),99)
      //Centro(21,01,119," F2-Confirma | F4-Inclui | F6-Exclui | F8-Abandona ")
      @ 31,01 say " F2-Confirma | F4-Inclui | F6-Exclui | F8-Abandona " color Cor(26) 
      Rodape("Esc-Encerra")
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      keyboard chr(K_ENTER)
        do while .t.
            Edita_Vet(10,01,30,99,aCampo,aTitulo,aMascara, [nfeitemEntrada],,,,1)
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
            loop
        endif
        nTotPro := Soma_Veto2(aTotPro)
        MBruPro := Soma_Veto2(aTotPro)
        nTotalDesconto := Soma_Veto2(aDesconto)
        If !Empty( nDscNot )
             nTotPro = MBruPro  // ** - nDscNot
        EndIf
        MTotNot := nTotPro - nTotalDesconto + nICMSub + MIPINot
        N_Ite := Len( aCodPro )
        Select 6
        MQtdVol :=  0 // ** Soma_Vetor( VQtdPro )
        MPerDsc := 0
        If !Empty( nDscNot )
            MPerDsc = nDscNot / MBruPro * 100
        EndIf
      nBaseICMS  := 0
      nValorICMS := 0
      nIPINot    := 0
      for nI := 1 to len(aCodPro)
         nBaseICMS += aBaseICMS[nI]
         nValorICMS += aValorICMS[nI]
         nIPINot    += (aTotPro[nI]*(aIPI[nI]/100))
      next
      while !Sequencia->(Trava_Reg())
      enddo
      Sequencia->LancNfeEnt := Sequencia->LancNfeEnt+1
      cNumCon := Sequencia->LancNfeEnt
      Sequencia->(dbunlock())
      
      @ 03,11 say cNumCon
      cNumCon := strzero(Sequencia->LancNfeEnt,10)
      @ 03,11 say cNumCon
      while !NfeEntrada->(Adiciona())
      enddo
      NfeEntrada->NumCon  := cNumCon
      NfeEntrada->NumNot  := cNumNot
      NfeEntrada->CodCli  := cCodCli
      NfeEntrada->CodVen  := Clientes->CodVen
      NfeEntrada->CodNat  := cCodNat
      NfeEntrada->DtaEmi  := dDtaEmi
      NfeEntrada->DtaSai  := dDtaSai
      NfeEntrada->BasNor  := nBaseICMS
      NfeEntrada->ICMNor  := nValorICMS
      NfeEntrada->IPINot  := MIPINot
      NfeEntrada->TotNot  := MTotNot
      NfeEntrada->TotPro  := nTotPro
      NfeEntrada->CodTra  := cCodTra
      NfeEntrada->QtdVol  := nQtdVol
      NfeEntrada->EspVol  := cEspVol
      NfeEntrada->MarVol  := cMarVol
      NfeEntrada->NumVol  := nNumVol
      NfeEntrada->TipFre  := cTipFre
      NfeEntrada->ObsNot1 := cObsNot1
      NfeEntrada->ObsNot2 := cObsNot2
      NfeEntrada->ObsNot3 := cObsNot3
      NfeEntrada->ObsNot4 := cObsNot4
      NfeEntrada->ObsNot5 := cObsNot5
      NfeEntrada->ObsNot6 := cObsNot6
      NfeEntrada->PesLiq  := MPesLiq
      NfeEntrada->PesBru  := MPesBru
        NfeEntrada->DscNo1 := Soma_Veto2(aDesconto)        // **nDscNot
        For Laco = 1 to len(aCodPro)
            If !empty( aCodPro[Laco] )
                Produtos->(dbsetorder(1),dbseek(aCodPro[Laco]))
                do while !Produtos->(Trava_Reg())
                enddo
                do while !NfeItemEntrada->(Adiciona())
                enddo
                NfeItemEntrada->NumCon := cNumCon
                NfeItemEntrada->CodCli := cCodCli
                NfeItemEntrada->AliSai := aAliSai[Laco]
                NfeItemEntrada->QtdPro := aQtdPro[Laco]
                NfeItemEntrada->PcoPro := aPcoPro[Laco]
                NfeItemEntrada->TotPro := aTotPro[Laco]
                NfeItemEntrada->PcoCus := Produtos->PcoCus
                NfeItemEntrada->CodNat := aCodNat[Laco]
                NfeItemEntrada->CodVen := Clientes->CodVen
                NfeItemEntrada->DtaMov := dDtaEmi
                NfeItemEntrada->CodPro   := aCodPro[Laco]
                NfeItemEntrada->Cst      := aCst[Laco]
                NfeItemEntrada->baseicms := aBaseICms[laco]
                NfeItemEntrada->valoricms := avaloricms[laco]
                NfeItemEntrada->ipi := aipi[laco]
                NfeItemEntrada->desconto := aDesconto[Laco]
                NfeItemEntrada->CodItem := aCodItem[Laco]
                NfeItemEntrada->(dbcommit())
                NfeItemEntrada->(dbunlock())
                // ** So atualiza o estoque quanto o ambiente da NFE for 1-produ‡Æo
                if Sequencia->TipoAMB == "1"
                    if Produtos->CtrlEs == "S"
                        Produtos->QteAC01 += aQtdPro[Laco]
                    endif
                endif
            endif
            Produtos->(dbunlock())
        Next
        NfeEntrada->(dbcommit())
        NfeEntrada->(dbunlock())
        If Aviso_1( 17,, 22,, [Aten‡„o!],[Transmitir a NFE ?], { [  ^Sim  ], [  ^NÆo  ] }, 1, .t. ) = 1
			if Sequencia->TestarInte == "S"
				lInternet := Testa_Internet()
         		if !lInternet
            		loop
         		endif
         	endif
            // trava o registro de sequencia do n£mero da nota
            do while Sequencia->(!Trava_Reg())
            enddo
            cNumNota := Sequencia->NumNfe+1
            
            // Busca o lancamento feito e trava o arquivo
            NfeEntrada->(dbsetorder(1),dbseek(cNumCon))
            do while NfeEntrada->(!Trava_Reg())
            enddo
            nfeentrada->numcon := cNumCon  // inclui o numero da nota 
            nfeentrada->NumNot := strzero(cNumNota,9)
            nfeEntrada->serie := Sequencia->SerieNfe
            
            // Monta o arquivo .INI da nota
            MontarNfe()
            
         	// ** verifica o status de conexão com a secretária da fazenda
            if !Status_NFeNFCe(Sequencia->DirNfe)
                nfeentrada->numcon := space(09)
                nfeentrada->serie := space(03)
                nfeentrada->(dbcommit())
                nfeentrada->(dbunlock())
                Sequencia->(dbunlock())
				loop
			endif
            if !Criar_NFeNFCe(rtrim(Sequencia->dirNFe),@cChNfe,cComando)
                nfeentrada->numcon := space(09)
                nfeentrada->serie := space(03)
                nfeentrada->(dbcommit())
                nfeentrada->(dbunlock())
                Sequencia->(dbunlock())
                loop
            endif
            // grava a chave da nota fiscal criada
            NfeEntrada->ChNfe := cChNfe
            
            if !Assinar_NFeNFCe(rtrim(Sequencia->DirEnvResp),rtrim(Sequencia->dirNFe),cChNfe)
                nfeentrada->numcon := space(09)
                nfeentrada->serie := space(03)
                nfeentrada->(dbcommit())
                nfeentrada->(dbunlock())
                Sequencia->(dbunlock())
                loop
            endif
            // faz a valida‡Æo da nota
            if !Validar_NFeNFCe(rtrim(Sequencia->DirEnvResp),rtrim(Sequencia->dirNFe),cChNfe)
                nfeentrada->numcon := space(09)
                nfeentrada->serie := space(03)
                nfeentrada->(dbcommit())
                nfeentrada->(dbunlock())
                Sequencia->(dbunlock())
                loop
            endif
            // faz a tramissÆo da nota
            if !Transmitir_NFeNFCe(rtrim(Sequencia->DirEnvResp),rtrim(Sequencia->dirNFe),cChNfe)
                nfeentrada->numcon  := space(09)
                nfeentrada->serie := space(03)
                NfeEntrada->Cstat := cCStat  // pega o codigo de rejei‡Æo
                NfeEntrada->Xmotivo := cXMotivo // pega a descricao da rejeicao
                NfeEntrada->(dbcommit())
                NfeEntrada->(dbunlock())
                Sequencia->(dbunlock())
				loop
			endif
            cCStat    := RetornoSEFAZ("cStat",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
            cXMotivo  := RetornoSEFAZ("XMotivo",rtrim(Sequencia->dirNFe)+"\sainfe.txt") 
            cNProt    := RetornoSEFAZ("NProt",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
            cDhRecbto := RetornoSEFAZ("DhRecbto",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
            
			NfeEntrada->Autorizado := iif(cCStat == "100",.t.,.f.)
            NfeEntrada->CStat      := cCStat
            NfeEntrada->XMotivo    := cXMotivo
			NfeEntrada->DhRecbto   := cDhRecbto
			NfeEntrada->NProt      := cNProt
			NfeEntrada->(dbcommit())
			NfeEntrada->(dbunlock())
            // Atualiza a sequencia da nota fiscal
            Sequencia->NumNfe := cNumNota
            Sequencia->(dbunlock())
            if Aviso_1( 17,, 22,, [Aten‡„o!],"Imprimir NFe ?", { [  ^Sim  ], [  ^NÆo  ] }, 1, .t. ) == 1
                Imprimir_NFeNFCe(rtrim(Sequencia->dirNFe),cChNfe)                           
            endif
         endif
    enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   endif
   FechaDados()
   RestWindow(cTela)
   return
   
procedure AltNfeEntrada
    return
    
    
    
//***************************************************************************
// Cancelar nota
//***************************************************************************
procedure CancNfeEntrada
   local getlist := {},cTela := SaveWindow()
   local cNumCon,cMotivo
   private cCStat,cXMotivo,cNProt,cDhRecbto

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenProdutos()
        Msg(.f.)
        FechaDados()
        return
    endif
    if !OpenNfeEntrada()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenNfeItemEntrada()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenSequencia()
        Msg(.f.)
        FechaDados()
        return
    endif
    if !OpenClientes()
        Msg(.f.)
        FechaDados()
        return
    endif
    
    Msg(.f.)
    AtivaF4()
    Window(07,07,17,72," Cancela NFe ")
    setcolor(Cor(11))
   @ 09,09 say "    N§ Controle:"
   @ 10,09 say "        N§ Nota:"
   @ 11,09 say "        Cliente:"
   @ 12,09 say "Data de Emissao:"
   @ 13,09 say "  Data de Sa¡da:"
   @ 14,09 say "          Valor:"
   @ 15,09 say "        Motivo :"
   while .t.
      cNumCon := Space(10)
      cMotivo := space(40)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 09,26 get cNumCon picture "@k 9999999999" when Rodape("Esc-Encerra | F4-Notas ") valid Busca(Zera(@cNumCon),"nfeven",1,,,,{"Controle Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      Clientes->(dbsetorder(1),dbseek(NfeEntrada->CodCli))
      NfeItemEntrada->(dbsetorder(1),dbseek(cNumCon))
      @ 10,26 say NfeEntrada->NumNot
      @ 11,26 say NfeEntrada->CodCli+"-"+left(Clientes->NomCli,40)
      @ 12,26 say NfeEntrada->DtaEmi
      @ 13,26 say NfeEntrada->DtaSai
      @ 14,26 say NfeEntrada->TotNot picture "@e 999,999.99"
        if !NfeEntrada->Autorizado
            Mens({"Nota fiscal nÆo autorizada"})
            loop
        endif
        if NfeEntrada->Cancelada
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
        if !Cancelar_NFeNFCe(Sequencia->DirNFe,NfeEntrada->ChNfe,cMotivo,cEmpCnpj)
            loop
        endif
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
		do while NfeEntrada->(!Trava_Reg())
		enddo
      	NfeEntrada->Cancelada   := .t.
        NfeEntrada->CStat      := cCStat
        NfeEntrada->XMotivo    := cXMotivo
		NfeEntrada->DhRecbto   := cDhRecbto
		NfeEntrada->NProt      := cNProt
      	NfeEntrada->(dbunlock())
        NfeItemEntrada->(dbsetorder(1),dbseek(cNumCon))
        do while NfeItemEntrada->NumCon == cNumCon .and. NfeItemEntrada->(!eof())
            do while !NfeItemEntrada->(Trava_Reg())
            enddo
            if Produtos->(dbsetorder(1),dbseek(NfeItemEntrada->CodPro))
                if Produtos->CtrlEs == "S"
                    do while !Produtos->(Trava_Reg())
                    enddo
                    Produtos->QteAc01 -= NfeItemEntrada->QtdPro
                    Produtos->(dbunlock())
                endif
            endif
            NfeItemEntrada->(dbdelete())
            NfeItemEntrada->(dbcommit())
            NfeItemEntrada->(dbunlock())
            NfeItemEntrada->(dbskip())
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

procedure TransNfeEntrada // Transmitir NFE
    local getlist := {},cTela := SaveWindow()
    local cNumCon,nNrNota
                         
    // ** declara Variaveis de retorno do acbr    
    private cNRec    // número do recibo
    private cCStat
    private cXMotivo // 
    private cChNfe  // chave da acesso
    private cDhRec  // data e hora do recebimento
    private cNProt  // número do protocolo

	private cComando


    if !AbrirArquivos()
        return
    endif
    AtivaF4()
    Window(08,09,15,70," Transmitir NFE ")
   setcolor(Cor(11))
   @ 10,11 say "N§ Controle:"
   @ 11,11 say "    Cliente:"
   @ 12,11 say "       Data:"
   @ 13,11 say "      Valor:"
   while .t.
      cNumCon := Space( 10 )
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,24 get cNumCon picture "@k 9999999999";
                valid Busca(Zera(@cNumCon),"nfeentrada",1,,,,{"Controle Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      Clientes->(dbsetorder(1),dbseek(NfeEntrada->CodCli))
      @ 11,24 say NfeEntrada->CodCli+"-"+left(Clientes->NomCli,40)
      @ 12,24 say NfeEntrada->DtaEmi
      @ 13,24 say NfeEntrada->TotNot picture "@e 999,999.99"
        if !Confirm("Confirma as informa‡äes")
            loop
        endif
        if NfeEntrada->Autorizado
            Mens({"Nota fiscal ja autorizada"})
            loop
        endif
        if NfeEntrada->Cancelada
            Mens({"Nota fiscal j  cancelada"})
            loop
        endif
		if Sequencia->TestarInte == "S"
			lInternet := Testa_Internet()
         	if !lInternet
            	loop
         	endif
		endif
        // trava o registro de sequencia do n£mero da nota
        do while Sequencia->(!Trava_Reg())
        enddo
        nNrNota := Sequencia->NumNfe+1
            
        // Busca o lancamento feito e trava o arquivo
        NfeEntrada->(dbsetorder(1),dbseek(cNumCon))
        do while NfeEntrada->(!Trava_Reg())
        enddo
        nfeentrada->NumNot := strzero(nNrNota,9)
        nfeEntrada->serie := Sequencia->SerieNfe
            
        // Monta o arquivo .INI da nota
        MontarNfe()
            
        // ** verifica o status de conexão com a secretária da fazenda
        if !Status_NFeNFCe(Sequencia->DirNfe)
            nfeentrada->numcon := space(09)
            nfeentrada->serie := space(03)
            nfeentrada->(dbcommit())
            nfeentrada->(dbunlock()) // destrava o registro  
            Sequencia->(dbunlock()) // destrava o arquivo de sequencia
			loop
		endif
        // cria o xml da nota
        if !Criar_NFeNFCe(rtrim(Sequencia->dirNFe),@cChNfe,cComando)        
            nfeentrada->numcon := space(09)
            nfeentrada->serie := space(03)
            nfeentrada->(dbcommit())
            nfeentrada->(dbunlock())
            Sequencia->(dbunlock()) // destrava o arquivo de sequencia
            loop
        endif
        NfeEntrada->ChNfe := cChNfe
        
        if !Assinar_NFeNFCe(rtrim(Sequencia->DirEnvResp),rtrim(Sequencia->dirNFe),cChNfe)
            nfeentrada->numcon := space(09)
            nfeentrada->serie := space(03)
            nfeentrada->(dbcommit())
            nfeentrada->(dbunlock())
            Sequencia->(dbunlock())
            loop
        endif
        // faz a valida‡Æo da nota
        if !Validar_NFeNFCe(rtrim(Sequencia->DirEnvResp),rtrim(Sequencia->dirNFe),cChNfe)
            nfeentrada->numcon := space(09)
            nfeentrada->serie := space(03)
            nfeentrada->(dbcommit())
            nfeentrada->(dbunlock())
            Sequencia->(dbunlock())
            loop
        endif
        // transmite a nota
        if !Transmitir_NFeNFCe(rtrim(Sequencia->DirEnvResp),rtrim(Sequencia->dirNFe),cChNfe)
            nfeentrada->numcon  := space(09)
            nfeentrada->serie := space(03)
            NfeEntrada->Cstat := cCStat  // pega o codigo de rejei‡Æo
            NfeEntrada->Xmotivo := cXMotivo // pega a descricao da rejeicao
            NfeEntrada->(dbcommit())
            NfeEntrada->(dbunlock())
            Sequencia->(dbunlock())
			loop
		endif
        cCStat    := RetornoSEFAZ("cStat",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
        cXMotivo  := RetornoSEFAZ("XMotivo",rtrim(Sequencia->dirNFe)+"\sainfe.txt") 
        cNProt    := RetornoSEFAZ("NProt",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
        cDhRecbto := RetornoSEFAZ("DhRecbto",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
            
		NfeEntrada->Autorizado := iif(cCStat == "100",.t.,.f.)
        NfeEntrada->CStat      := cCStat
        NfeEntrada->XMotivo    := cXMotivo
		NfeEntrada->DhRecbto   := cDhRecbto
		NfeEntrada->NProt      := cNProt
		NfeEntrada->(dbcommit())
		NfeEntrada->(dbunlock())
        // Atualiza a sequencia da nota fiscal
        Sequencia->NumNfe := nNrNota
        Sequencia->(dbunlock())
        if Aviso_1( 17,, 22,, [Aten‡„o!],"Imprimir NFe ?", { [  ^Sim  ], [  ^NÆo  ] }, 1, .t. ) == 1
            Imprimir_NFeNFCe(rtrim(Sequencia->dirNFe),cChNfe)                           
        endif
    enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   endif
   FechaDados()
   RestWindow(cTela)
   return

procedure ImpNfeEntrada
    local getlist := {},cTela := SaveWindow()
    local cNota,nCopia

    Msg(.t.)
    Msg("Aguarde : Abrindo o Arquivo")
    if !OpenClientes()
        Msg(.f.)
        FechaDados()
        return
    endif
    if !OpenNfeEntrada()
        Msg(.f.)
        FechaDados()
        return
    endif
    if !OpenSequencia()
        Msg(.f.)
        FechaDados()
        return
    endif
    Msg(.f.)
    AtivaF4()
    Window(08,09,15,70," Imprimir NFE ")
    setcolor(Cor(11))
    @ 10,11 say "    N§ Nota:"
    @ 11,11 say "    Cliente:"
    @ 12,11 say "       Data:"
    @ 13,11 say "      Valor:"
    do while .t.
        cNota := Space(9)
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 10,24 get cNota picture "@k 999999999";
                valid Busca(Zera(@cNota),"nfeentrada",3,,,,{"Nota nÆo cadastrada"},.f.,.f.,.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        end
        Clientes->(dbsetorder(1),dbseek(NfeEntrada->CodCli))
        @ 11,24 say NfeEntrada->CodCli+"-"+Clientes->NomCli
        @ 12,24 say NfeEntrada->DtaSai
        @ 13,24 say NfeEntrada->TotNot picture "@e 999,999.99"
        if !NfeEntrada->Autorizado
            Mens({"Nota fiscal nÆo autorizada"})
            loop
        endif
        if !Confirm("Confirma a ImpressÆo")
            loop
        endif
        Imprimir_NFeNFCe(rtrim(Sequencia->dirNFe),NfeEntrada->ChNfe)
    enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   endif
   FechaDados()
   RestWindow(cTela)
   return

procedure EnviarEmailNfeEntrada
	local getlist := {},cTela := SaveWindow()
	local cNrNota,cEmail,cAssunto

	Msg(.t.)
	Msg("Aguarde : Abrindo o Arquivo")
    if !OpenClientes()
		FechaDados()
		Msg(.f.)
		return
	endif
    if !OpenNfeVen()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenSequencia() 
		FechaDados()
		Msg(.f.)
		return
	endif
	Msg(.f.)
	AtivaF4()
	Window(08,09,18,70," Enviar NFe por email ")
	setcolor(Cor(11))
	@ 10,11 say "Nr. da Nota:"
	@ 11,11 say "    Cliente:"
	@ 12,11 say "       Data:"
	@ 13,11 say "      Valor:"
	@ 14,10 say replicate(chr(196),60)
	@ 15,11 say "     Email:"
	@ 16,11 say "   Assunto:"
	do while .t.
		cNrNota  := Space( 9)
		cEmail   := space(60)
		cAssunto := space(60)
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 10,24 get cNrNota picture "@k 999999999";
            valid Busca(Zera(@cNrNota),"nfeven",3,,,,{"Nota Fiscal nao Cadastrada"},.f.,.f.,.f.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		Clientes->(dbsetorder(1),dbseek(NfeEntrada->CodCli))
		if !NfeEntrada->nfegerada
			Mens({"Nota fiscal eletr“nica nÆo gerada"})
 			loop
		endif
		if !NfeEntrada->NfeTransmi
 			Mens({"Nota fiscal eletr“nica nÆo transmitida"})
			loop
		endif
		cEmail := Clientes->EmaCli+space(20)
		@ 11,24 say NfeEntrada->CodCli+"-"+Clientes->NomCli
		@ 12,24 say NfeEntrada->DtaSai
		@ 13,24 say NfeEntrada->TotNot picture "@e 999,999.99"
		@ 15,24 get cEmail picture "@KS45"
		@ 16,24 get cAssunto picture "@KS45"
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			loop
		endif
		if !Confirm("Confirma as Informacoes")
			loop
		endif
		if !Testa_Internet()
			Mens({"Sem acesso a internet","Carta de Correcao nao pode enviada"})
			loop
		endif
        if !Status_NFeNFCe(Sequencia->DirNfe)
            loop
        endif
		Msg(.t.)
		Msg("Aguarde: Enviando Email")
		AcbrNFe_EnviarEmail(rtrim(Sequencia->DirNFE),cEmail,NfeEntrada->ChNfe,1,cAssunto)
		Msg(.f.)
        cRetorno := Mon_Ret(rtrim(Sequencia->DirNFE),"sainfe.txt",Sequencia->Tempo)
		if !Men_Ok(cRetorno)
			Mens({"Email nao enviado, favor verificar"})
			loop
		else
			Mens({"Email enviando com sucesso"})
		endif
   enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   endif
   FechaDados()
   RestWindow(cTela)
   return
//*****************************************************************************
// Faz uma consulta na SEFAZ
//*****************************************************************************
procedure ConNfeEntradaSefaz
	local getlist := {},cTela := SaveWindow()
	local cNrNota,cStatus

	Msg(.t.)
	Msg("Aguarde : Abrindo o Arquivo")
    if !OpenClientes()
		FechaDados()
		Msg(.f.)
		return
	endif
    if !OpenNfeEntrada()
		FechaDados()
		Msg(.f.)
		return
	endif
    if !OpenSequencia()
		FechaDados()
		Msg(.f.)
		return
	endif
	Msg(.f.)
	AtivaF4()
	Window(08,09,21,70," Consultar NFe na Sefaz ")
	setcolor(Cor(11))
	@ 10,11 say "Nr. da Nota:"
	@ 11,11 say "    Cliente:"
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
                        valid Busca(Zera(@cNrNota),"nfeentrada",3,,,,{"Nota Fiscal nao Cadastrada"},.f.,.f.,.f.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		Clientes->(dbsetorder(1),dbseek(NfeEntrada->CodCli))
		if !NfeEntrada->Autorizado
			Mens({"Nota fiscal nÆo autorizada"})
 			loop
		endif
		cEmail := Clientes->EmaCli+space(20)
		@ 11,24 say NfeEntrada->CodCli+"-"+left(Clientes->NomCli,40)
		@ 12,24 say NfeEntrada->DtaSai
		@ 13,24 say NfeEntrada->TotNot picture "@e 999,999.99"
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
		AcbrNFe_ConsultarNFe(rtrim(Sequencia->DirNFe),NfeEntrada->ChNFe)
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
        do while NfeEntrada->(!Trava_Reg())
        enddo
        if cCstat == "100"
			NfeEntrada->Autorizado := .t.
        elseif cCstat == "101"
            NfeEntrada->Cancelada   := .t.
        endif
        NfeEntrada->CStat      := cCStat
        NfeEntrada->XMotivo    := cXMotivo
		NfeEntrada->DhRecbto   := cDhRecbto
		NfeEntrada->NProt      := cNProt
        
        NfeEntrada->(dbcommit())
        NfeEntrada->(dbunlock())
	enddo
	DesativaF4()
	if PwNivel == "0"
		AtivaF9()
	endif
	FechaDados()
	RestWindow(cTela)
	return
   
static function vCliente(cCodCli)

   if !Busca(Zera(@cCodCli),"Clientes",1,05,17,"left(Clientes->NomCli,30)",{"Cliente Nao Cadastrado"},.f.,.f.,.f.)
      return(.f.)
   end
   if empty(Clientes->NumCli)
      Mens({"Erro no cadastro do cliente","N£mero do endere‡o esta vazio"})
      return(.f.)
   end
   Cidades->(dbsetorder(1),dbseek(Clientes->CodCid))
   cEstCli := Cidades->EstCid
   return(.t.)
//********************************************************************************************   
static function ValidNatureza(cCodNat)

    if !Busca(Zera(@cCodNat),"Natureza",1,row(),col()+1,"Descricao",{"Natureza nÆo cadastrada"},.f.,.f.,.f.)
        return(.f.)
    endif
    if !(Natureza->tipo == "E")
        Mens({"Tipo de natureza incorreta para opera‡Æo"})
        return(.f.)
    endif
    return(.t.)
//********************************************************************************************    
static function vCampoNatureza

    if Natureza->Local = "D"
        if empty(Produtos->NatEntDent)
           Mens({"Campo natureza fiscal do produto","Para dentro do estado nÆo preenchido"})
           return(.f.)
        endif
    else
        if empty(Produtos->NatEntFora)
           Mens({"Campo natureza fiscal do produto","Para fora do estado nÆo preenchido"})
           return(.f.)
        endif
    endif
    return(.t.)
//********************************************************************************************        
function nfeitemEntrada( Pos_H, Pos_V, Ln, Cl, nTecla )
   Local Laco, Verif := .f.

   If nTecla == K_ENTER
      // ** Codigo do Produto
      If Pos_H = 1
         cCampo := aCodItem[Pos_V]
         @ Ln,Cl get cCampo picture "@k";
                    when Rodape("Esc-Encerra | F4-Produtos");
                    valid ValidProduto(@cCampo) .and. vCampoNatureza()
         setcursor(SC_NORMAL)
         read
         setcursor(SC_NONE)
         if !(lastkey() == K_ESC)
            Rodape("Esc-Encerra")
            aCodITem[Pos_V] := cCampo
            aCodPro[Pos_V] := Produtos->CodPro
            aDesPro[pos_v] := left(Produtos->DesPro,23)+"-> "+str(Produtos->QteEmb,3)+" x "+Produtos->EmbPro
            aPcoPro[Pos_V] := Produtos->PcoCal
            aCST[Pos_V] := Produtos->Cst
            // Fora do estado 
			if Natureza->Local == "F"
				aAliSai[Pos_V] := Produtos->AliFor
                aCodNat[Pos_V] := Produtos->NatEntFora
            // Dentro do estado
			elseif Natureza->Local == "D" 
				aAliSai[Pos_V] := Produtos->AliDtr
                aCodNat[Pos_V] := Produtos->NatEntDent
			endif
            KeyBoard Replica(chr(K_RIGHT),2)+chr(K_ENTER)
            Return( 3 )
         EndIf
      // ** Quantidade
      elseif Pos_H == 3
         If !Empty( aCodPro[Pos_V] )
            MCampo = aQtdPro[Pos_V]
            @ Ln, Cl Get MCampo Pict [@R 999,999.999] Valid NoEmpty( MCampo ) .and. vSaldo(mCampo,aCodPro[Pos_V])
            setcursor(SC_NORMAL)
            read
            setcursor(SC_NONE)
            if !(LastKey() == K_ESC)
               aQtdPro[Pos_V] := MCampo
               aTotPro[Pos_V] := round(aQtdPro[Pos_V] * aPcoPro[Pos_V],2)
               @ 32,59 say Soma_Veto2(aTotPro) picture "@e 999,999,999.99"
               keyboard chr(K_RIGHT)+chr(K_ENTER)
               return(2)
            endif
         endif

      // ** Valor Unit rio
      elseif Pos_H == 4
         if !empty(aCodPro[Pos_V])
            MCampo := aPcoPro[Pos_V]
            @ Ln,Cl get MCampo picture "@E 99,999.999"
            setcursor(SC_NORMAL)
            read
            setcursor(SC_NONE)
            if !(lastkey() == K_ESC)
               aPcoPro[Pos_V]  := MCampo
               aTotPro[Pos_V]  := round(aQtdPro[Pos_V] * aPcoPro[Pos_V],2)
               aBaseICMS[Pos_V] := aTotPro[Pos_V]
               @ 32,59 say Soma_Veto2(aTotPro) picture "@e 999,999,999.99"
               KeyBoard chr(K_RIGHT)+chr(K_ENTER)
               return(2)
            endif
         endif
         
		// ** Desconto
		elseif Pos_H == 5
			if !empty(aCodPro[Pos_V])
				MCampo := aDesconto[Pos_V]
				@ Ln,Cl get MCampo picture "@e 99,999.99"
				setcursor(SC_NORMAL)
				read
				setcursor(SC_NONE)
				if !(lastkey() == K_ESC)
					aDesconto[Pos_V] := MCampo
					@ 08,36 say Soma_Veto2(aDesconto) picture "@e 99,999,999.99"
					keyboard replicate(chr(K_RIGHT),2)+chr(K_ENTER)
					return(2)
				endif
			endif

      // ** CST Código de Situação tributária
		elseif Pos_H == 7
			If !Empty( aCodPro[Pos_V] )
            	MCampo = aCST[Pos_V]
            	@ Ln, Cl Get MCampo Pict [@!] Valid NoEmpty( MCampo )
            	setcursor(SC_NORMAL)
            	read
            	setcursor(SC_NONE)
				if !(LastKey() == K_ESC)
               		aCST[Pos_V] := MCampo
               			if aCST[Pos_V] $ "60"
               	   			aAliSai[Pos_V]    := 0
               				aBaseICMS[Pos_V]  := 0
                  			aValorICMS[Pos_V] := 0
                  		endif
               		keyboard chr(K_RIGHT)+chr(K_ENTER)
               		return(2)
               	endif
            endif

      // ** Aliquota do ICMS
      elseif Pos_H == 8
         If !Empty( aCodPro[Pos_V] )
            MCampo = aAliSai[Pos_V]
            @ Ln, Cl Get MCampo Pict "999.99"
            setcursor(SC_NORMAL)
            read
            setcursor(SC_NONE)
            if !(LastKey() == K_ESC)
               aAliSai[Pos_V] := MCampo
				if aAliSai[Pos_V] = 0
            		aBaseIcms[Pos_V]  := 0
            		aValorIcms[Pos_V] := 0
            	endif
               keyboard chr(K_RIGHT)+chr(K_ENTER)
               return(2)
            endif
         endif

      // ** Valor Base do ICMS
      elseif Pos_H == 9
         If !Empty( aCodPro[Pos_V] )
            MCampo = aBaseICMS[Pos_V]
            @ Ln, Cl Get MCampo Pict "@E 999,999.99"
            setcursor(SC_NORMAL)
            read
            setcursor(SC_NONE)
            if !(LastKey() == K_ESC)
               	aBaseICMS[Pos_V] := MCampo
               	aValorICMS[Pos_V] := round((aBaseICMS[Pos_V]*(aAliSai[Pos_V]/100)),2)
               keyboard chr(K_RIGHT)+chr(K_ENTER)
               return(2)
            endif
         endif

      // ** Valor do ICMS
      elseif Pos_H == 10
         If !Empty( aCodPro[Pos_V] )
            MCampo = aValorICMS[Pos_V]
            @ Ln, Cl Get MCampo Pict "@E 999,999.99"
            setcursor(SC_NORMAL)
            read
            setcursor(SC_NONE)
            if !(LastKey() == K_ESC)
               aValorICMS[Pos_V] := MCampo
               keyboard chr(K_RIGHT)+chr(K_ENTER)
               return(2)
            endif
         endif

      // ** Aliquota do IPI
      elseif Pos_H == 11
         If !Empty( aCodPro[Pos_V] )
            MCampo = aIPI[Pos_V]
            @ Ln, Cl Get MCampo Pict "999.99"
            setcursor(SC_NORMAL)
            read
            setcursor(SC_NONE)
            if !(LastKey() == K_ESC)
               aIPI[Pos_V] := MCampo
               if Pos_V >= len(aCodPro)
                  N_Itens := Len( aCodPro ) + 1
                  asize(aCodItem,n_Itens)
                  asize( aCodPro, N_Itens )
                  asize( aDesPro, N_Itens )
                  asize( aAliSai, N_Itens )
                  asize( aQtdPro, N_Itens )
                  asize( aPcoPro, N_Itens )
                  asize( aTotPro, N_Itens )
                  asize(aCST,N_Itens)
                  asize(aBaseICMS,N_Itens)
                  asize(aValorICMS,N_Itens)
                  asize(aIPI,N_Itens)
                  asize(aDesconto,N_Itens)
                  asize(aCodnat,N_Itens)

                  ains(aCodItem,Pos_V+1)
                  ains(aCodPro,Pos_V+1 )
                  ains(aDesPro,Pos_V+1 )
                  ains(aAliSai,Pos_V+1 )
                  ains(aQtdPro,Pos_V+1 )
                  ains(aPcoPro,Pos_V+1 )
                  ains(aTotPro,Pos_V+1 )
                  ains(aCST,Pos_V+1)
                  ains(aBaseICMS,Pos_V+1)
                  ains(aValorICMS,Pos_V+1)
                  ains(aIPI,Pos_V+1)
                  ains(aDesconto,Pos_V+1)
                  ains(aCodNat,Pos_V+1)

                  aCodItem[Pos_V+1] := space(13)
                  aCodPro[Pos_V+1]    := space(06)
                  aDesPro[Pos_V+1]    := Space(37)
                  aAliSai[Pos_V+1]    := 0
                  aQtdPro[Pos_V+1]    := 1
                  aPcoPro[Pos_V+1]    := 0
                  aTotPro[Pos_V+1]    := 0
                  aCST[Pos_V+1] := space(03)
                  aBaseIcms[Pos_V+1]  := 0
                  aValorICMS[Pos_V+1] := 0
                  aIPI[Pos_V+1]       := 0
                  aDesconto[Pos_V+1]  := 0
                  aCodNat[Pos_V+1] := space(03)

                  keyboard chr(K_DOWN)+replicate(chr(K_LEFT),Pos_H-1)+chr(K_ENTER)
                  Return( 3 )
               else
                  keyboard chr(K_DOWN)+replicate(chr(K_LEFT),Pos_H-1)+chr(K_ENTER)
               endif
            endif
         endif
         Return( 2 )
      EndIf
   elseif nTecla = K_F2
      N_Itens = Len( aCodPro )
      Brancos = 0
      For Laco = 1 to Len( aCodPro )
          If !Empty( aCodPro[Laco] ) .and. ( Empty( aQtdPro[Laco] ) .or. Empty( aPcoPro[Laco] ) )
             Aviso_1( 10,, 15,, [Aten‡„o!], [N„o s„o permitidos quantidades ou pre‡os zerados.], { [  ^Ok!  ] }, 1, .t., .t. )
             Return( 1 )
          ElseIf Empty( aCodPro[Laco] )
             ++Brancos
          EndIf
      Next
      If Brancos = N_Itens
         Aviso_1( 10,, 15,, [Aten‡„o!], [N„o ‚ permitido gravar nota sem ¡tens.], { [  ^Ok!  ] }, 1, .t., .t. )
         Return( 1 )
      EndIf
      Return( 0 )
   ElseIf nTecla == K_F4
         N_Itens := Len( aCodPro ) + 1

         asize( aCodpro,nItens)
         asize( aCodPro  ,N_Itens )
         asize( aDesPro  ,N_Itens )
         asize( aAliSai  ,N_Itens )
         asize( aQtdPro  ,N_Itens )
         asize( aPcoPro  ,N_Itens )
         asize( aTotPro  ,N_Itens )
         asize(aCST      ,N_Itens)
         asize(aBaseICMS ,N_Itens)
         asize(aValorICMS,N_Itens)
         asize(aIPI      ,N_Itens)
         asize(aDesconto ,N_Itens)
         asize(aCodNat,N_Itens)

         ains(aCodItem,Pos_V+1)
         ains(aCodPro,Pos_V+1 )
         ains(aDesPro,Pos_V+1 )
         ains(aAliSai,Pos_V+1 )
         ains(aQtdPro,Pos_V+1 )
         ains(aPcoPro,Pos_V+1 )
         ains(aTotPro,Pos_V+1 )
         ains(aCST,Pos_V+1)
         ains(aBaseICMS,Pos_V+1)
         ains(aValorICMS,Pos_V+1)
         ains(aIPI,Pos_V+1)
         ains(aDesconto,Pos_V+1)
         ains(aCodNat,Pos_V+1)

         aCodItem[Pos_V+1] := space(13)
         aCodPro[Pos_V+1]    := space(06)
         aDesPro[Pos_V+1]    := Space(37)
         aAliSai[Pos_V+1]    := 0
         aQtdPro[Pos_V+1]    := 1
         aPcoPro[Pos_V+1]    := 0
         aTotPro[Pos_V+1]    := 0
         aCST[Pos_V+1]       := space(03)
         aBaseIcms[Pos_V+1]  := 0
         aValorICMS[Pos_V+1] := 0
         aIPI[Pos_V+1]       := 0
         aDesconto[Pos_V+1]  := 0
         aCodNat[Pos_V+1] := space(03)
         keyboard Chr( 24 ) + Chr( 13 )
         Return( 3 )
   elseif nTecla == K_F2
      return(0)
   elseif nTecla == K_F8
      return(0)
   ElseIf nTecla == K_F6
      If Len( aCodPro ) > 1
         if !Confirm("Confirma a Exclusao do Item")
            return(0)
         end
         adel(aCodItem,Pos_V)
         adel( aCodPro   ,Pos_V )
         adel( aDesPro   ,Pos_V )
         adel( aAliSai   ,Pos_V )
         adel( aQtdPro   ,Pos_V )
         adel( aPcoPro   ,Pos_V )
         adel( aTotPro   ,Pos_V )
         adel( aCST      ,Pos_V )
         adel( aBaseICMS ,Pos_V)
         adel( aValorICMS,Pos_V)
         adel( aIPI      ,Pos_V)
         adel( aDesconto ,Pos_V)
         adel( aCodNat,Pos_V)

         N_Itens := Len( aCodPro ) - 1
         asize(aCodItem,n_Itens) 
         asize( aCodPro, N_Itens )
         asize( aDesPro, N_Itens )
         asize( aQtdEmb, N_Itens )
         asize( aAliSai, N_Itens )
         asize( aQtdPro, N_Itens )
         asize( aPcoPro, N_Itens )
         asize( aTotPro, N_Itens )
         asize( aCST,N_Itens)
         asize( aBaseICMS,N_Itens)
         asize( aValorICMS,N_Itens)
         asize( aIPI,N_Itens)
         asize( aDesconto,N_Itens)
         asize( aCodNat,N_Itens)
         return( 3 )
      EndIf
   EndIf
   Return( 1 )

static procedure vSaldo(nQtd,cCodPro)

   if !Busca(cCodPro,"Produtos",1,,,,{"Produto Nao Cadastrado"},.f.,.f.,.f.)
      return(.f.)
   end
   /*
	If Natureza->BxaEst = "S"
		if Natureza->OpeNat = [V]
			Produtos->QteAC01 -= aQtdPro[Laco]
		elseif Natureza->OpeNat = [D]
			Produtos->QteAC01 += aQtdPro[Laco]
		end
	end
	*/

   if Produtos->CtrlEs == "S"
      if nQtd > Produtos->QteAc01
         Mens({"Este produto Nao tem saldo suficiente"})
         return(.f.)
      end
   end
   return(.t.)

static function vCodigo(cCodProd,pos_v)  // Verifica se o item ja foi cadastrado

   if !(ascan(aCodPro,cCodProd) == 0) .and. !(aCodPro[pos_v] == cCodProd)
      Mens({"Item Ja Cadastrado"})
      return(.f.)
   end
   return(.t.)

static function Pega2
   local getlist := {},cTela := SaveWindow(),lRetorno

   Window(09,03,22,96," Dados Complementares ")
   setcolor(Cor(11))
   //           678901234567890123456789012345678901234567890123456789012345678901234
   //               1         2         3         4         5         6         7
   @ 11,06 say "       Frete:"
   @ 12,06 say "Transportado:"
   @ 13,06 say "       Qtde.:                   Especie:"
   @ 14,06 say "       Marca:                    Numero:"
   @ 15,04 say replicate(chr(196),91)
   @ 15,04 say "[ Dados Adicionais ]"
   ObsNota()
   while .t.
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,20 get cTipFre picture "@k!" valid MenuArray(@cTipFre,{{"0","Por conta do Emitente              "},;
      			{"1","Por conta do Destinatario/Remetente"},;
      			{"2","Por conta de Terceiros             "},;
      			{"9","Sem frete                          "}},row(),col(),row(),col()+1)
      @ 12,20 get cCodTra picture "@k 99" when iif( cTipFre == "9",.f.,Rodape("Esc-Encerra | F4-Transportadora")) valid Busca(Zera(@cCodTra),"Transpo",1,12,22,"'-'+Transpo->NomTra",{"Transportadora Nao Cadastrada"},.f.,.f.,.f.)
      @ 13,20 get nQtdVol picture "@k 99,999.99" when iif( cTipFre == "9",.f.,Rodape("Esc-Encerra"))
      @ 13,47 get cEspVol picture "@k!" when iif(cTipFre == "9",.f.,.t.)
      @ 14,20 get cMarVol picture "@k!" when iif(cTipFre == "9",.f.,.t.)
      @ 14,47 get nNumVol picture "@k 99999" when iif(cTipFre == "9",.f.,.t.)
      
      @ 16,05 get cObsNot1 picture "@k!"
      @ 17,05 get cObsNot2 picture "@k!"
      @ 18,05 get cObsNot3 picture "@k!"
      @ 19,05 get cObsNot4 picture "@k!"
      @ 20,05 get cObsNot5 picture "@k!"
      @ 21,05 get cObsNot6 picture "@k!"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         lRetorno := .f.
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
      lRetorno := .t.
      exit
   end
   RestWindow(cTela)
   return(lRetorno)

static procedure ObsNota
   local nI,cTexto1 := "Produtos ",lDoida := .f.

   /*
   for nI := 1 to len(aCodPro)
      if Produtos->(dbsetorder(1),dbseek(aCodPro[nI]))
         if Produtos->CodFis == "60"
            SitTrib->(dbsetorder(1),dbseek(Produtos->CodFis))
            cTexto1  += "/"+alltrim(str(val(aCodPro[nI])))
            lDoida   := .t.
            cObsNot5 := SitTrib->DesFis
         end
      end
   next
   */
   if lDoida
      for nI := 1 to mlcount(cTexto1,50)
         if nI == 1
            cObsNot1 := memoline(cTexto1,50,nI)
         elseif nI == 2
            cObsNot2 := memoline(cTexto1,50,nI)
         elseif nI == 3
            cObsNot3 := memoline(cTexto1,50,nI)
         elseif nI == 4
            cObsNot4 := memoline(cTexto1,50,nI)
         else
            cObsNot4 := memoline(cTexto1,50,nI)
         end
      next
   end
   return

static function Soma_Veto2( Vetor )
   local Laco, Retorno := 0, Tam_Vetor := LEN( Vetor )

   for Laco := 1 TO Tam_Vetor
      Retorno += round(Vetor[Laco],2)
   next
   return( Retorno )

static procedure VerItemNot(cNumCon)
   Local cCor := setcolor(),cTela := SaveWindow()
   local aCampo  := {},aTitulo := {},aMascara := {}
   private aVetor1 := {},aVetor2 := {},aVetor3 := {},aVetor4 := {},aVetor5 := {}
   private aVetor6 := {}

   NfeItemEntrada->(dbsetorder(1),dbseek(cNumCon))
   do while NfeItemEntrada->NumCon == cNumCon .and. NfeItemEntrada->(!eof())
      Produtos->(dbsetorder(1),dbseek(NfeItemEntrada->CodPro))
      aadd(aVetor1,NfeItemEntrada->CodPro)
      aadd(aVetor2,left(Produtos->DesPro,23)+"-> "+str(Produtos->QteEmb,3)+" x "+Produtos->EmbPro)
      aadd(aVetor3,NfeItemEntrada->QtdPro)
      aadd(aVetor4,NfeItemEntrada->PcoPro)
      aadd(aVetor5,NfeItemEntrada->QtdPro*NfeItemEntrada->PcoPro)
      NfeItemEntrada->(dbskip())
   enddo
   aCampo   := { "aVetor1" ,"aVetor2"   ,"aVetor3"   ,"aVetor4"     ,"aVetor5"}
   aTitulo  := { "C¢digo"  ,"Descri‡„o ","Qtde."     ,"P‡o. Venda"  ,"Total" }
   aMascara := {"@k 999999","@!S40"     ,"@e 999,999.99","@E 99,999.99","@E 9,999,999.99"}
   cTela := SaveWindow()
   Rodape("Esc-Encerra")
   Window(10,00,23,89,"> Itens da Nota <")
   Edita_Vet(11,01,22,88,aCampo,aTitulo,aMascara, [XAPAGARU],,.t.)
   RestWindow(cTela)
   setcolor(cCor)
   Return

static function NotaPedido(cNumPed)
   local nItens := 0,nQtd := 0

   ItemPed->(dbsetorder(1),dbseek(cNumPed))
   while ItemPed->NumPed == cNumPed .and. ItemPed->(!eof())
      Produtos->(dbsetorder(1),dbseek(ItemPed->CodPro))
      if !(Produtos->QteAc01 == 0)
         if ItemPed->QtdPro > Produtos->QteAc01
            nQtd := Produtos->QteAc01
         else
            nQtd := ItemPed->QtdPro
         end
         aadd(aCodPro,ItemPed->CodPro)
         aadd(aDesPro,left(Produtos->DesPro,23)+"->  "+str(Produtos->QteEmb,3)+" x "+Produtos->EmbPro)
         aadd(aPcoPro,Produtos->PcoCal)
         aadd(aQtdPro,nQtd)
         aadd(aTotPro,round(nQtd * Produtos->PcoCal,2))
         if Produtos->CodFis == "60"
            aadd(aAliSai,0)
         else
            if Natureza->Local == "F" .and. Clientes->TipCli == "F"
               aadd(aAliSai,Produtos->AliDtr)
            elseif Natureza->Local == "D" .and. Clientes->TipCli $ "FJ"
               aadd(aAliSai,0.00)
            elseif Natureza->Local == "F" .and. Clientes->TipCli == "J"
               aadd(aAliSai,Produtos->AliFor)
            end
         end
         nItens += 1
      end
      ItemPed->(dbskip())
   end
   if nItens == 0
      Mens({"Nao Existe Saldo Disponivel para o Pedido"})
      return(.f.)
   end
   return(.t.)
   
static function AbrirArquivos
   
    Msg(.t.)
    Msg("Aguarde : Abrindo o Arquivo")
    if !OpenCidades()
        Msg(.f.)
        FechaDados()
        return(.f.)
    endif
    if !OpenGrupos()
        Msg(.f.)
        FechaDados()
        return(.f.)
    endif
    if !OpenClientes()
        Msg(.f.)
        FechaDados()
        return(.f.)
    endif
    if !OpenVendedor()
        Msg(.f.)
        FechaDados()
        return(.f.)
    endif
    if !OpenProdutos()
        Msg(.f.)
        FechaDados()
        return(.f.)
    endif
    if !OpenSubGrupo()
        Msg(.f.)
        FechaDados()
        return(.f.)
    endif
    if !OpenNfeEntrada()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenNfeItemEntrada()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenNatureza()
        Msg(.f.)
        FechaDados()
        return(.f.)
    endif
    if !OpenSitTrib()
        Msg(.f.)
        FechaDados()
        return(.f.)
    endif
    if !OpenSequencia()
        Msg(.f.)
        FechaDados()
        return(.f.)
    endif
    if !OpenTranspo()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenDupRec()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenDetpagtonfe()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    Msg(.f.)
    return(.t.)

static procedure TelaNFeEntrada(nModo)
  local cTitulo, aTitulos := {"InclusÆo","Altera‡Æo","ExclusÆo","Impressao","Fechamento","Abertura","Visualiza‡Æo"},nI
     
    
   Window(02,00,33,100,"> "+aTitulos[nModo]+" de NF-e (Entrada) <")
   setcolor(Cor(11))
   //           12345678901234567890123456789012345678901234567890123456789012345678901234567890
   //                    1         2         3         4         5         6         7         8
   @ 03,01 say "Controle:           -                             Nota/Modelo:       /"
   @ 04,01 say replicate(chr(196),99)
   @ 05,01 say " Cliente:                                         "
   @ 06,01 say "Natureza:"
   @ 07,01 say "    Data:"   
   @ 08,01 say "   Frete:                Desconto:"
   @ 09,01 say replicate(chr(196),99) 
//   @ 09,01 say "123456789012345678901234567890123456789012345678901234567890123456789012345678"
   //                    1         2         3         4         5         6         7
//   @ 10,01 say " C¢digo Descri‡„o                             Qtde.   Pco. Venda Total"
   @ 11,01 say replicate(chr(196),99)
   //@ 11,08 say chr(194)
   //@ 11,46 say chr(194)
   //@ 11,54 say chr(194)
   //@ 11,65 say chr(194)
   //for nI := 12 to 20
   //   @ nI,08 say chr(179)
   //  @ nI,46 say chr(179)
   //   @ nI,54 say chr(179)
   //   @ nI,65 say chr(179)
   //next
   @ 31,01 say replicate(chr(196),99)
   @ 32,01 say "                                                   Total:"
    
    
    
static procedure MontarNfe
    local lForaDentro

   Clientes->(dbsetorder(1),dbseek(NfeEntrada->CodCli))
   Transpo->(dbsetorder(1),dbseek(NfeEntrada->CodTra))
   Natureza->(dbsetorder(1),dbseek(NfeEntrada->CodNat))
    if Natureza->Local == "D" // se operação for dentro do estado
        lDentro := .t.
    else
        lDentro := .f.
    endif
   Cidades->(dbsetorder(1),dbseek(Clientes->CodCid))
   cCFOPNota := Natureza->Cfop
   

    cComando := ""
    // Identifica‡Æo da nota
    cComando += "[Identificacao]"+CRLF
    cComando += "cUF="+cEmpEstCid+CRLF
    cComando += 'nNF='+NfeEntrada->numnot+CRLF
    cComando += 'NaturezaOperacao='+Natureza->Descricao +CRLF
    // Forma de pagamento - 0 - Avusta, 1-A prazo,2=Outros
    cComando += "IndPag=0"+CRLF
    
   cComando += 'Modelo=55'+CRLF
   cComando += 'Serie='+Sequencia->SerieNfe+CRLF
   cComando += 'Numero='+NfeEntrada->NumNot+CRLF
   cComando += 'Emissao='+dtoc(NfeEntrada->DtaEmi)     +CRLF
   
    // Tipo de opera‡Æo 0=Entrada,1=Saida
    cComando += "tpNf=0"+CRLF
    
    // Identificador de local de destino da opera‡Æo
	cComando += 'idDest='+iif(Natureza->Local = "D",'1','2')+CRLF
    
    // Formato de ImpressÆo do DANFE
    cComando += "tpImp=1"+CRLF
    
    // Tipo de EmissÆo da NF-e
    cComando += "tpEmis=1"+CRLF
    
    // 28 - Identifica‡Æo do Ambiente
    cComando += "tpAmb="+Sequencia->TipoAmb+CRLF
    
    // 29 - Finalidade de emissÆo da NF-e
    cComando += "finNFe=1"+CRLF
    
    // Indica opera‡Æo com Consumidor final
    cComando += 'indFinal='+Clientes->IndiFinal+CRLF
    
    // Indicador de presen‡a do comprador no estabelecimento comercial no 
    // momento da opera‡Æo
    cComando += "indPres=1"+CRLF    

    cComando += '[Emitente]'   +CRLF
	if Sequencia->TipoAmb == "2"
		//cComando += 'CNPJ=99999999000191'+CRLF
		//cComando += 'IE=00'+CRLF
        cComando += 'CNPJ='+cEmpCnpj+CRLF
		cComando += "IE="+cEmpIe+CRLF
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

    // DESTINATµRIO
    Cidades->(dbsetorder(1),dbseek(Clientes->CodCid))
    cComando += '[Destinatario]'+CRLF
   
	// ** Ambiente de Produção
	if Sequencia->TipoAmb == "1"
		// ** Pessoa Juridica
		if Clientes->TipCli == "J"
			cComando += 'CNPJ='+Clientes->CGCCli+CRLF
			
			/*
			
			if empty(Clientes->IESCli)
				cComando += 'IE=ISENTO'+CRLF
				cComando += 'indIEDest=2'+CRLF  // ** NFE 3.10
			else
				cComando += 'IE='+Clientes->IESCli+CRLF
				cComando += 'indIEDest=1'+CRLF  // ** NFE 3.10
			endif
			*/
		// ** Pessoa Física
		else
			cComando += 'CNPJ='+Clientes->CPFCli+CRLF
			
			// **cComando += 'indIEDest=9'+CRLF     // ** NFE 3.10
      endif
		if Clientes->indIEDest == "1"
			cComando += 'IE='+Clientes->IESCli+CRLF
		endif
		cComando += 'indIEDest='+Clientes->indIEDest+CRLF  // ** NFE 3.10

      cComando += 'NomeRazao='+Clientes->NomCli +CRLF
   else
      cComando += 'CNPJ=99999999000191'+CRLF
      cComando += 'indIEDest=9'+CRLF
      // **cComando += 'IE='+CRLF
      cComando += 'Razao= NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL'+CRLF
   endif
   cComando += 'Fone='+Clientes->TelCli1     +CRLF
   cComando += 'CEP='+Clientes->CepCli       +CRLF
   cComando += 'Logradouro='+Clientes->EndCli+CRLF
   cComando += 'Numero='+Clientes->NumCli    +CRLF
   cComando += 'Bairro='+Clientes->BaiCli    +CRLF
   cComando += 'CidadeCod='+Cidades->CodIbge  +CRLF
   cComando += 'Cidade='+Cidades->NomCid     +CRLF
   cComando += 'UF='+Cidades->EstCid         +CRLF
   cComando += 'PaisCod=1058'                +CRLF
   cComando += 'Pais=BRASIL'                 +CRLF

   nBaseICMS  := 0
   nValorICMS := 0
   nValorDoTributos := 0.00
   nValorTotalDoTributos := 0.00

   // Produtos
   NfeItemEntrada->(dbsetorder(1),dbseek(NfeEntrada->NumCon))
   nContador := 1
	while NfeItemEntrada->NumCon == NfeEntrada->NumCon .and. NfeItemEntrada->(!eof())
		Produtos->(dbsetorder(1),dbseek(NfeItemEntrada->CodPro))
		cQuantidade    := rtrim(alltrim(str(NfeItemEntrada->QtdPro,15,4)))
		cValorUnitario := rtrim(alltrim(str(round(NfeItemEntrada->PcoPro,2),12,2)))
		cValorTotal    := rtrim(alltrim(str(NfeItemEntrada->TotPro,12,2)))
		cValorDesconto := rtrim(alltrim(str(NfeItemEntrada->Desconto,15,2)))
        
		
		// ** Calcula o valor total dos tributos
		/*
		if ibpt->(dbsetorder(1),dbseek(Produtos->CodNCM))
			nValorDoTributos := round(((NfeItemEntrada->TotPro * ibpt->aliqnac) / 100),2)
			nValorTotalDoTributos += nValorDoTributos
		endif
		*/
		
        if lDentro 
            Natureza->(dbsetorder(1),dbseek(Produtos->NatEntDent))
            
        else
            Natureza->(dbsetorder(1),dbseek(Produtos->NatEntFora))
        endif
		cComando += '[Produto'      +strzero(nContador,3)+']'+CRLF
		cComando += 'CFOP='         +Natureza->Cfop        +CRLF
		cComando += 'Codigo='       +NfeItemEntrada->CodPro        +CRLF
        if empty(Produtos->CodBar)
            cComando += 'cEAN=SEM GTIN'+CRLF
        else
            cComando += 'cEAN='+Produtos->CodBar+CRLF
        endif
        if empty(Produtos->CodBar)
            cComando += 'cEANTrib=SEM GTIN'+CRLF
        else
            cComando += 'cEANTrib='+Produtos->CodBar+CRLF
        endif
		cComando += 'NCM='+Produtos->CodNCM+CRLF
		cComando += 'Descricao='    +Produtos->DesPro        +CRLF
		cComando += 'Unidade='      +Produtos->EmbPro        +CRLF
		cComando += 'Quantidade='   +cQuantidade             +CRLF
		cComando += 'ValorUnitario='+cValorUnitario          +CRLF
		cComando += 'ValorTotal='   +cValorTotal             +CRLF
		cComando += 'vDesc='+cValorDesconto          +CRLF
		cComando += 'vTotTrib='+rtrim(alltrim(str(nValorDoTributos,12,2)))+CRLF

		cBaseICMS  := rtrim(alltrim(str(NfeItemEntrada->baseicms,12,2)))
		cAliquota  := rtrim(alltrim(str(NfeItemEntrada->AliSai,5,2)))
      
		cValorICMS := rtrim(alltrim(str(NfeItemEntrada->ValorIcms,12,2)))

		nBaseICMS  += val(cBaseICMS)  //   NfeItemEntrada->baseicms
		nValorICMS += val(cValorICMS) //NfeItemEntrada->valoricms
		
		// **nTotalDesconto += NfeItemEntrada->Desconto
        // Tributa‡Æo
		cComando +='[ICMS'+strzero(nContador,3)+']'+CRLF
		cComando += 'CSOSN='+Produtos->Cst+CRLF
		cComando +='ValorBase='+cBaseIcms+CRLF
		cComando +='Aliquota='+cAliquota+CRLF
        cComando +='Valor='+cValorICMS+CRLF

      NfeItemEntrada->(dbskip())
      nContador += 1
   enddo
   cBaseICMS  := rtrim(alltrim(str(nBaseICMS,12,2)))
   cValorICMS := rtrim(alltrim(str(nValorICMS,12,2)))

   cBasSub := rtrim(alltrim(str(NfeEntrada->BasSub,12,2)))
   cICMSub := rtrim(alltrim(str(NfeEntrada->ICMSub,12,2)))
   cTotPro := rtrim(alltrim(str(NfeEntrada->TotPro,12,2)))
   cTotNot := rtrim(alltrim(str(NfeEntrada->TotNot,12,2)))
   cTotalDesconto := rtrim(alltrim(str(NfeEntrada->dscno1,15,2)))

   cComando +='[Total]'+CRLF
   cComando += 'BaseICMS='             +cBaseICMS+CRLF
   cComando += 'ValorICMS='            +cValorICMS+CRLF
   cComando += 'ValorProduto='         +cTotPro+CRLF
   cComando += 'BaseICMSSubstituicao=' +cBasSub+CRLF
   cComando += 'ValorICMSSubstituicao='+cICMSub+CRLF
   cComando += 'ValorFrete=0.00'       +CRLF
   cComando += 'ValorSeguro=0.00'      +CRLF
	cComando += 'ValorDesconto='        +cTotalDesconto+CRLF
	cComando += 'ValorNota='            +cTotNot+CRLF
	// **cComando += 'vTotTrib='+rtrim(alltrim(str(nValorTotalDoTributos,12,2)))+CRLF   

    // Forma de pagamento
    cComando += "[Pag001"+"]"+CRLF
    cComando += "tPag=90"+CRLF
    cComando += "vPag=0.00"+CRLF


   //Dados do Transportador
   cComando += '[Transportador]'+CRLF
   cComando += 'FretePorConta=' +NfeEntrada->TipFre+CRLF
   cComando += 'CnpjCpf='       +Transpo->CGCTra+CRLF
   cComando += 'NomeRazao='     +Transpo->NomTra+CRLF
   cComando += 'IE='            +Transpo->InsTra+CRLF
   cComando += 'Endereco='      +Transpo->EndTra+CRLF
   cComando += 'Cidade='        +Transpo->CidTra+CRLF
    cComando += 'UF='            +Transpo->EstTra+CRLF
    cComando += 'Placa='         +Transpo->PlaTra+CRLF
    cComando += 'UFPlaca='       +Transpo->EstPla+CRLF
   
	if !empty(NfeEntrada->qtdvol)

		cComando += '[Volume001]'+CRLF
		cComando += 'Quantidade=' +rtrim(alltrim(str(NfeEntrada->qtdvol,12)))+CRLF
		cComando += 'Especie='    +NfeEntrada->EspVol+CRLF
		cComando += 'Marca='      +NfeEntrada->MarVol+CRLF
		cComando += 'Numeracao='  +rtrim(alltrim(str(NfeEntrada->NumVol)))+CRLF
		cComando += 'PesoLiquido='+rtrim(alltrim(str(NfeEntrada->PesLiq,12,2)))+CRLF
		cComando += 'PesoBruto='  +rtrim(alltrim(str(NfeEntrada->PesBru,12,2)))+CRLF
	endif

	cDadosAdicionais := ""
	cDadosAdicionais += NfeEntrada->ObsNot1+";"
	if !empty(NfeEntrada->ObsNot2)
		cDadosAdicionais += NfeEntrada->ObsNot2 + ";"
	endif
	if !empty(NfeEntrada->ObsNot3)
      cDadosAdicionais += NfeEntrada->ObsNot3 + ";"
   end
   if !empty(NfeEntrada->ObsNot4)
      cDadosAdicionais += NfeEntrada->ObsNot4 + ";"
   end
   if !empty(NfeEntrada->ObsNot5)
      cDadosAdicionais += NfeEntrada->ObsNot5 + ";"
   end
   if !empty(NfeEntrada->ObsNot6)
      cDadosAdicionais += NfeEntrada->ObsNot6 + ";"
   end
   cComando +='[DadosAdicionais]'+CRLF
   cComando +='Complemento='+cDadosAdicionais+CRLF
return
    

// ** Fim do Arquivo.
