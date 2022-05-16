*-------------
* M©dulo_____: Vendas
*-------------
#include "setcurs.ch"
#include "inkey.ch"
#include "lucas.ch"

#define CRLF chr(K_ENTER)+chr(K_CTRL_ENTER)
#define K_AST            42     // *

procedure Vendas()
    local cTela := SaveWindow()
    public TModulo:=0, TefCheque:= .f.
    private cLanc
    private cNFCe   // Numero da nfce
    private cSerie  // s'rie da nfce
    private MCanDsc:=.f.
    private MStatus:=[On-Line]
    private xtCOD := 20
    private MNumPed:=Space(10)
    private OItens:={}
    private MChamaPed:=.f.
    private MCanTEF:=.f.
    private Arq_Soli
    private MCgcCpf:=[  ]
    private MCodVen:=[  ]
    private MNumCup:=Space(06)
    private MTotChe:=0
    // ** declara Variaveis de retorno do acbr    
    private cNRec    // nomero do recibo
    private cCStat
    private cXMotivo // 
    private cChNfe  // chave da acesso
    private cDhRec  // data e hora do recebimento
    private cNProt  // nomero do protocolo
    private cComando
    
   * --- Declaracao Variaveis
    private cStatus  := ""       //  Status diversos de operacoes fiscais
    
    private aCodITem := {} // Codigo do item
    private aDesPro  := {}
    private aCodPro  := {} //  Vetor de Codigos
    private aQtdPro  := {} //  Vetor de Quantidades
    private aPcoVen  := {} // prežo de venda bruto
    private aDscPro  := {} // Desconto do produto
    private aValDsc  := {} // Valor do desconto
	private aPcoLiq  := {} // Valor Liquido de venda
    private aTotPro  := {} // Valor total do item
    private aCstPro  := {}
    
    
    private VPcoPro  := {}       //  Valores Unitarios BRUTOS
    private VDscUni  := {}       //  Vetor de DESCONTOS Unitarios
    private VCodFis  := {}       //  Vetor de Codigos de Tributacao
    private aUndPro  := {}       //  Vetor de Unidade do produto
    
    private MTotChp  := 0.00     //  Receb. Cheques Pre-datados (por venda)
    private MTotChv  := 0.00     //  Recebimentos em Cheques (por venda)
    private MTotDin  := 0.00     //  Recebimentos em Dinheiro (por venda)
    private MTotTro  := 0.00     //  Recebimentos em Trocas (por venda)
    private MTotTkt  := 0.00     //  Recebimentos em Tickets (por venda)
    private MTotCar  := 0.00     //  Recebimentos em Cartao de Credito (por venda)
    private MTotCre  := 0.00     //  Recebimentos em Crediario (por venda)
    private MSubTot  := 0.00     //  Sub-total
    private MTotDsc  := 0.00     //  Desconto de pe de nota
    private MTotCup  := 0.00     //  Total de Creditos
    private MVlrTro  := 0.00     //  Troco
    private MSeqIte  := 0        //  Sequencial do Item a ser vendido
    private nMaxItem := 999      //  Max.Itens armazenados CMOS
    private cCodItem  := Space(14)//  Codigo do material (para Get)
    private nQtd     := 1     //  Quantidade vendida (para Get)
    private nPrecoUni:= 0.00     //  Preco Unitario (para display)
    private MDscIte  := 0.00     //  Desconto do Item (%)
    private nValDesc := 0.00     //  Desconto do Item (valor)
    private nPrecoTot:= 0.00     //  Preco Total (para display)
    private nCont    := 0        //  Contador
    private cCodCli  := "0001"   //  C©digo do cliente sonsumidor
    
    if !AbrirArquivos()
        return
    endif

    CNumPdv := "123456789012345" // Acbr_NumSerie()

	Begin Sequence
	
        set key K_AST to Quantidade()
        set key K_F2  to SangriaDoCaixa()
        set key K_F3  to DadosConsumidor()
        set key K_F4  to ConProdutoPdv()
        //Set Key K_F2  to Calc()                // Calculadora
        Set Key K_F6  to CancelaItem()           // Cancelamento de itens
        Set Key K_F8  to Canc_Cupom()          // Cancelamento de Cupom em andamento
        Set Key K_F10 to Desc_Item()           // Desconto no item
        Set Key K_F12 to ChamaPedido()
    
        AtivaF9()
        xitem:=MSeqIte
        xlin:=4
        MSubTot := Round(MSubTot,2)
        If MSeqIte > 0
            Restore Screen
        endif
        Do While .t.
            cNumCupom := "001" //Acbr_NumCupom()
            Tela()
            Tl_Vendas()
            xsubtotal:=0
            tesc(0)
            // Solicita os Itens
            MSeqIte    := 0
            cCodItem    := Space(14)
            nCont      := 0
            nQtd       := 1
            MTotChv    := 0.00
            MTotChp    := 0.00
            MTotDin    := 0.00
            MTotTro    := 0.00
            MTotTkt    := 0.00
            MTotCre    := 0.00
            MTotCar    := 0.00
            MTotDsc    := 0.00
            MTotCup    := 0.00
            MVlrTro    := 0.00
            MDscIte    := 0.00
            nValDesc   := 0.00
            nPrecoTot  := 0.00
            MSubTot    := 0.00
            MNumOds    := MNumPed:=Space(10)
            MNumCup    := Space(06)
            cCodCli    := "0001" 
         
            Begin Sequence
                cLanc  := strzero(Sequencia->LancPdv+1,10,0)  //Acbr_NumCupom()
                @ 02,14 say cLanc
                Lnha:=0
                Do While .t.
                    MTotTkt  := 0.0 
                    MTotCre  := 0.0 
                    MTotTro  := 0.0 
                    MTotCar  := 0.0
                    MTotChv  := 0.0 
                    MTotChp  := 0.0 
                    MTotDin  := 0.0
                    cCodItem  := Space(14)
                    nQtd     := 1.000
                    lExecuta := .F.
                    If MSeqIte = 0
                        Cor := SaveScreen(09,02,21,90)
                        Banner(11,[CAIXA LIVRE]) //,C_CDFnd)
                    elseif MSeqIte = 1
                        RestScreen(09,02,21,90,cor)
                    endif
                    Set Device to Screen
                    MSeqIte++
                    do while .t.
                        @ 29, 01 say MSeqIte pict [99]
                        @ 29, 21 say nQtd picture "@k 999,999.999"
                        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
                        Set Key K_AST to Quantidade()                  
                        @ 29, 04 Get cCodItem pict "@!";
                            valid valid_item(@cCodItem,@nPrecoUni,@MDscIte,@nValDesc,@nQtd);
                                .and. !Empty(cCodItem) 
                        setcursor(SC_NORMAL)
                        read
                        setcursor(SC_NONE)
                        if lastkey() == K_ESC
                            exit
                        endif
                        if Produtos->CtrLes == "S"
                            if !AtualizaSaldo(cCodItem,.t.,nQtd)
                    	       loop
                  	         endif
                             exit
                        else
                            exit
                        endif
                    enddo
                    If MSeqIte = 1
                        RestScreen(09,02,21,90,cor)
                        TelaSubTotal(23)
                    endif
                    If MSeqIte>1
                        Set Key K_F5 to CancelaItem()
                    endif
                    Tesc(1)
                    If LastKey() == K_ESC
                        cCodItem := Space(14)
                    endif
                    If empty(cCodItem)
                        * --- Nao. VerIfica se ha venda em curso ...
                        If MSeqIte = 1
                            MSeqIte = 0
                            exit
                        endif
                        * --- Chama Sub-Total ...
                        If SUBTOT()
                            Exit
                        endif
                        * --- Limpa Display
                        MSeqIte--
                        loop
                    endif
                    * --- VerIfica se atingiu numero maximo de Itens
                    If MSeqIte > nMaxItem
                        Aviso_1( 13,, 18,, [A t e n z " o !], [Limite m~xido de itens, feche o cupom.], { [  ^Ok!  ] }, 1, .t., .t. )
                        MSeqIte--
                        Loop
                    endif
                    If XLin >= 21 //21
                        Scroll(05,01,21,78,1)
                    Else
                        XLin++
                    endif
                    @ XLin,01 say MSeqIte pict [99]
                    @ XLin,05 say Left(cCodItem,13)
                    @ XLin,16 say Produtos->FanPro pict [@!]
                    @ XLin,71 say NQtd pict [@E 999,999.999]
                    @ XLin,89 say (NPrecoUni-NValDesc)*NQtd pict [@e 99,999.99]
                    //MSubTot += (VPcoPro[MSeqIte] - aValDsc[MSeqIte]) * aQtdPro[MSeqIte]
                    MSubTot += ((NPrecoUni-NValDesc)*NQtd) 
                    MSubTot := Round(MSubTot,2)
                    Sub_Banner(24,59,Transf(MSubTot,"@E 99,999.99"),1)
                    GravaCupom()
                EndDo
                XLin := 4
                * --- VerIfica Cancelamento de Cupom/Operacao
                If MSeqIte = 0
                    Break
                endif
                Set Device to Screen
                * --- Salva Area da Janela
                Tel_Troco := SaveScreen( 06, 10, 18, 73 )
                Cor_Ant   := setcolor()
                Sombra(06,10,17,72)
                Window( 06, 10, 17, 72, [ (T R O C O)]) //, 5, [ × Esc - Retorna], C_CDTit, C_CDFnd )
                @ 15,14 say "Total:"
                @ 15,22 say MSubTot pict "@e 999,999,999.99"
                @ 15,47 say "Pago :"
                @ 15,54 say MTotCup pict "@e 999,999,999.99"
                Sub_Banner(10,13,Transf(MVlrTro,"@E 999,999,999.99"),1)
                inkey(0)
                setcolor( Cor_Ant )
                inkey(0.10)
                AtualizaCupom()
                // ***
                // se for venda estoque fisico
                if lGeral
                    If Aviso_1( 17,, 22,,"Atenž'o !",[        Imprimir ?        ], { [  ^Sim  ], [  ^N'o  ] }, 1, .t. ) = 1
                        ICupomNaoFiscal(cLanc)
                    endif
                // se nao e for fiscal 
                else
                    If Aviso_1( 17,, 22,,"Atenž'o", [Transmitir NFC-e ?], { [  ^Sim  ], [  ^N'o  ] }, 1, .t. ) = 1
                        do while Sequencia->(!Trava_Reg())
                        enddo
                        cNFCe  := strzero(Sequencia->NumNFCe+1,09,0)
                        
                        if PdvNfce->(dbsetorder(1),dbseek(cLanc))
                            do while PdvNfce->(!Trava_Reg())
                            enddo
                            PdvNfce->Nfce  := cNFCe
                            PdvNfce->Serie := Sequencia->SerieNfce
                            PdvNfce->(dbcommit())
                            PdvNfce->(dbunlock())
                        endif
                        MontarNFCe()
                        // se n'o conseguir criar NFce
                        if !Criar_NFeNFCe(rtrim(Sequencia->dirNFe),@cChNfe,cComando)
                            // apaga o numero e s'rie da nota
                            do while PdvNfce->(!Trava_Reg())
                            enddo
                            PdvNfce->Nfce := space(09)
                            PdvNfce->Serie := space(03)
                            PdvNfce->(dbunlock())
                            Sequencia->(dbunlock())
                            break
			            endif
                        do while PdvNfce->(!Trava_Reg())
                        enddo
                        PdvNfce->Chave := cChNfe 
                        PdvNfce->(dbcommit())
                        PdvNfce->(dbunlock())
                        // *********
                        if !Assinar_NFeNFCe(rtrim(Sequencia->DirEnvResp),rtrim(Sequencia->dirNFe),cChNfe)             
                            // apaga o numero e s'rie da nota
                            do while PdvNfce->(!Trava_Reg())
                            enddo
                            PdvNfce->Nfce := space(09)
                            PdvNfce->Serie := space(03)
                            PdvNfce->(dbunlock())
                            Sequencia->(dbunlock())
                            break
			             endif
                         if !Validar_NFeNFCe(rtrim(Sequencia->DirEnvResp),rtrim(Sequencia->dirNFe),cChNfe)
                            // apaga o numero e s'rie da nota
                            do while PdvNfce->(!Trava_Reg())
                            enddo
                            PdvNfce->Nfce := space(09)
                            PdvNfce->Serie := space(03)
                            PdvNfce->(dbunlock())
                            Sequencia->(dbunlock())
                            break
			             endif
                         //Mens({"aqui"})
                         if !Transmitir_NFeNFCe(rtrim(Sequencia->DirEnvResp),rtrim(Sequencia->dirNFe),cChNfe)
                            // Grava o Status e o motivo do erro/rejeiž'o
                            do while PdvNfce->(!Trava_Reg())
                            enddo
                            PdvNfce->Nfce := space(09)
                            PdvNfce->Serie := space(03)
                            
                            PdvNfce->Cstat   := cCStat
                            PdvNfce->Xmotivo := cXMotivo
                            PdvNfce->(dbcommit())
                            PdvNfce->(dbunlock())
                            Sequencia->(dbunlock())
                            break
			            endif
                        cStat     := RetornoSEFAZ("CStat",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
                        cXMotivo  := RetornoSEFAZ("XMotivo",rtrim(Sequencia->dirNFe)+"\sainfe.txt") 
                        cNProt    := RetornoSEFAZ("NProt",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
                        cDhRecbto := RetornoSEFAZ("DhRecbto",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
			            do while !PdvNfce->(Trava_Reg())
			            enddo
			            Pdvnfce->Autorizado := iif(cCStat == "100",.t.,.f.)
                        Pdvnfce->CStat      := cCStat
                        Pdvnfce->XMotivo    := cXMotivo
                        Pdvnfce->Chave      := cChNFe
                        Pdvnfce->DhRecbto   := cDhRecbto
                        Pdvnfce->NProt      := cNProt
                        Pdvnfce->(dbcommit())
                        Pdvnfce->(dbunlock())
                        // se tudo for Ok
                        // Atualiza a sequencia da nota
                        Sequencia->NumNFCe := val(cNFCe)
                        // Libera o arquivo de sequencia
                        Sequencia->(dbunlock())
                        
                        If Aviso_1( 17,, 22,,"Aten‡Æo"," Imprimir NFC-e ?", { [  ^Sim  ], [  ^NÆo  ] }, 1, .t. ) = 1
                            Imprimir_NFeNFCe(Sequencia->DirNfe,cChNfe)
                        endif
                    endif
                endif
                RestScreen( 06, 10, 18, 73, Tel_Troco )
            END SEQUENCE
            // VerIfica se ha itens
            If MSeqIte == 0
                Exit                         // Nao ha itens - Exit
            endif
            // Redimensiona os Work Arrays
            asize(aCodITem,0) // Codigo do item
            asize(aDesPro,0) // descriž'o do produto
            asize(aCodPro,0) //  Vetor de Codigos
            asize(aQtdPro,0) //  Vetor de Quantidades
            asize(aPcoVen,0) // prežo de venda bruto
            asize(aDscPro,0) // Desconto do produto
            asize(aValDsc,0) // Valor do desconto
            asize(aPcoLiq,0) // Valor Liquido de venda
            asize(aTotPro,0) // Valor total do item
            asize(aCstPro,0) // Codigo de Situaž'o tributaria do produto
            asize(VPcoPro,0)
            asize(VCodFis,0)
            asize(aUndPro,0)
            /*
            if lGeral
                lGeral := .f.  // Fiscal
                MStatus := "On-Line "
                @ 02,71 say MStatus
            endif
            */
        EndDo
        * --- Desabilita Hot-Keys
        Set Key K_AST to
        Set Key K_F5 to
        Set Key K_F8 to
    END SEQUENCE
    FechaDados()
    RestWindow(cTela)
    return
//******************************************************************************
function Valid_Item(cCodItem,nPrecoUni,MDscIte,nValDesc,nQtd)
   Local i,ACodv,j,nqtemb,CCodAnt:=Space(9),codtmp:=[],nval:=0

   If LastKey() == K_ESC
      cCodItem = Space(14)
      Return .t.
   endif
   If Empty(cCodItem)
      lExecuta = .t.
      Return .t.
   endif
   if len(alltrim(cCodItem)) <= 6
		cCodItem := strzero(val(cCodItem),6)
		if !Produtos->(dbsetorder(1),dbseek(cCodItem))
			Mens({"Produto n'o cadastrado"})
			cCodItem = Space(14)
			LExecuta=.f.
			Return .f.
		endif
	else
		if !Produtos->(dbsetorder(5),dbseek(cCodItem))
			Mens({"Produto n'o cadastrado"})
			cCodItem = Space(14)
			LExecuta=.f.
			Return .f.
		endif
   endif
    if Produtos->CtrLes == "S"
        // se for estoque fÐsico
        if lGeral
            if Produtos->QteAc02 == 0
                Mens({"Produto sem saldo"})
                cCodItem := space(14)
                return(.f.)
            endif
        // se nao e for estoque fiscal
		else
            if Produtos->QteAc01 == 0
                Mens({"Produto sem saldo"})
                cCodItem := space(14)
                return(.f.)
            endif
		endif
	endif
    nPrecoUni := Round2(Produtos->PcoCal,2)
    nValDesc  := 0 // valor do desconto
    // Desconto do item
    If MCanDsc
        If !Desconto(@MDscIte,@NValDesc,NprecoUni)
            NValDesc  := Val(Str(MDscIte*NPrecoUni/100,10,2))            // Valor do Desconto
        EndIf
    EndIf
    @ 29,34 say Produtos->FanPro pict [@!]
    @ 29,91 say nPrecoUni Pict [@e 99,999.99]
    aadd(aCodItem,cCodItem)
    aadd(aCodPro,Produtos->CodPro)
    aadd(aDesPro,Produtos->DesPro)
    aadd(aCstPro,Produtos->Cst)  
    aadd(aPcoven,nPrecoUni)
    aadd(aDscPro,MDscIte)    // ** % de desconto
    aadd(aPcoLiq,iif(MDscIte > 0,round(nPrecoUni-(round(nPrecoUni*(MDscIte/100),2)),2),nPrecoUni))
    aadd(aQtdPro,nQtd)       // Quantidade do produto
    aadd(aValDsc,nValDesc)   // valor do desconto
    aadd(VPcoPro,NPRECOUNI)  // prežo de venda bruto
    aadd(VCodFis," ")
    aadd(aUndPro,Produtos->EmbPro)
    lExecuta=.T.
    Return .T.
//******************************************************************************
Function Desconto(PPer,Pdes,Pval)
   Local GetList:={},tela_Ant:=SaveScreen(13,24,20,73),Escolha,mpct,mval,Ok:=.f.,xcan
   
   //Cor_Ant = SetColor( C_CDFnd + [, ] + C_CDEdi + [,,, ] + C_CDFnd )

   // Sombra(13,24,19,72)
   // Caixa_Smp( 13, 24, 19, 72, [ D E S C O N T O ], 5, [ × Esc - Retorna], C_CDTit, C_CDFnd )
    Window( 13, 24, 19, 72, [ D E S C O N T O ])   
   @ 14,26 SAY Alltrim(Produtos->FanPro)
   @ 15,26 SAY [     Preco de Venda:    ]+Transf(pval,[@e 999,999.99])
   @ 16,25 to 16,71
   @ 17,26 SAY "Desconto em Percentual ou Valor"
   @ 17,38 Prompt  "Percentual"
   @ 17,52 Prompt  "Valor"
   If Pdes>0
      Keyb Chr(13)
   end
   Menu to Escolha
   If Escolha=1
      Mpct=0
      @ 18, 26 say "Informe o Percentual: "
      @ 18, 48 Get Mpct Pict [@e 99.99] Valid LIM(MPct)
      SetCursor(SC_NORMAL)
      Read
      SetCursor(SC_NONE)
      If !(Lastkey() == K_ESC .or. mpct=0)
         PPer=Mpct
         PDes=round(Val(Str(Pper*Pval/100,10,2)),2)
         Ok:=.t.
      end
   Elseif Escolha=2
      MDes=PDes
      @ 18, 26 say "Informe o Valor_____: "
      Do while .t.
         @ 18, 48 Get MDes Pict [@e 999,999.99] Valid MDes>=0 .and. MDes<=PVal
         SetCursor(SC_NORMAL)
         Read
         SetCursor(SC_NONE)
         Lim=round((mdes/PVal)*100,2)
         Max=round(PVal*(C_VLimDsc/100),2)
         If Lim>C_VLimDsc
            Aviso_1( 13,, 18,, [A t e n z " o !], "Valor m~ximo para desconto ' de R$"+Transf(Max,"@E 999,999.99"), { [  ^Ok!  ] }, 1, .t., .t. )
            Loop
         end
         Exit
      EndDo
      If !(Lastkey() == K_ESC .or. mDes=0)
         PDes=MDes
         Ok:=.t.
      end
   end
   MCanDsc=.f.
   RestScreen(13,24,20,73,tela_Ant)
   @ 18,01 say Space(27)
   Return Ok
//******************************************************************************
Static Function Lim(Per)
    /*
   If Per>C_VLimDsc
      Aviso_1( 13,, 18,, [A t e n z " o !], "Percentual m~ximo para desconto ' de "+Transf(C_VLimDsc,"@E 99.99")+"%", { [  ^Ok!  ] }, 1, .t., .t. )
      RETURN .F.
   endif
   */
   Return .t.
//******************************************************************************
/*
 Formas de Pagamento da Nfc-e
 
 01 - Dinheiro
 02 - Cheque
 03 - Cart'o de Cr'dito
 04 - Cart'o de D'bito
 05 - Cr'dito loja
 10 - Vale alimentaž'o
 11 - Vale refeiž'o
 12 - Vale presente
 13 - Vale combustÐvel
 99 - Outros
*/
Function SubTot()
   Local cTecla  := "", cMsg   := "", Tel_Subt := SaveScreen( 03, 01, 16, 79 ),;
         V_Cmp1[09], V_Tit1[09], V_Msc1[09]
   local cCorAntes
   Public Inc1_ := .t., Tipo := [ ]
   private nValor:= 0.00

	MTotDin := 0.00         // Recebimentos em Dinheiro (por venda)
	MTotChv := 0.00         // Recebimentos em Cheques (por venda)
	MTotCar := 0.00         // Recebimentos em Cartao Credito (por venda)
   	
   MTotChp := 0.00         // Recebimentos em Cheques Pre-Datados (por venda)
   
   MTotTro := 0.00         // Recebimentos em Trocas (por venda)
   MTotTkt := 0.00         // Recebimentos em Tickets (por venda)

   MTotCre := 0.00         // Recebimentos em Crediario (por venda)
   
   MVlrPag := 0.00         // Valor Pago
   MVlrTro := 0.00         // Troco
   Sombra(03,01,15,78)
   cCorAntes := setcolor()
   Window(03, 01, 15, 78, " P A G A M E N T O S "," Esc-Retorna | Escolha a op‡Æo (1,2,3,4,5,6,7,9)")
   @ 04,03 say "(1)-Dinheiro..........:"
   @ 05,03 say "(2)-Cheque............:"
   @ 06,03 say "(3)-Cartao de Credito.:"
   @ 07,03 say "(4)-Cartao de Debito..:"
   @ 08,03 say "(5)-Credito Loja......:"
   // **@ 09,03 say "......................:"
   // **@ 10,03 say "......................:"
   @ 11,49 say "Valor Pago...:"
   // **@ 12,03 say "(9)-Desconto..........:"
   @ 12,49 say "Saldo........:"
   Do While .t.
      SUB_BANNER(05,42,Transf(MSubTot-MTotDsc,"@E 99,999.99"),1)
      @ 11,64 say MTotCup PICT "@E 99,999.99"
      If MSubTot - MTotCup > 0.00
         @ 12,49 say [Saldo........:]
      Else
         @ 12,49 say [Troco........:]
      endif
      @ 04,27 say MTotDin    Pict "@E 99,999.99"
      @ 05,27 say MTotChv    Pict "@E 99,999.99"
      @ 06,27 say MTotChp    Pict "@E 99,999.99"
      @ 07,27 say MTotCar    Pict "@E 99,999.99"
      @ 08,27 say MTotTkt    Pict "@E 99,999.99"
      @ 09,27 say MTotTro    Pict "@E 99,999.99"
      @ 10,27 say MTotCre    Pict "@E 99,999.99"
      @ 12,27 say MTotDsc    Pict "@E 99,999.99"
      @ 12,64 say ABS((MSubTot-MTotDsc) - MTotCup) PICT "@E 99,999.99"
      * --- Espera Tecla do Usuario
      Do While ! ((cTecla := UPPER(CHR(INKEY(0)))) $ "12345")
      EndDo
      * --- Teclou ESC
      If LastKey() == K_ESC
         RestScreen( 03, 01, 16, 79, Tel_Subt )
         MTotChv := 0.00         //  Recebimentos em Cheques (por venda)
         MTotChp := 0.00         //  Recebimentos em Cheques Pre-Datados (por venda)
         MTotDin := 0.00         //  Recebimentos em Dinheiro (por venda)
         MTotTro := 0.00         //  Recebimentos em Trocas (por venda)
         MTotTkt := 0.00         //  Recebimentos em Tickets (por venda)
         MTotCre := 0.00         //  Recebimentos em Crediario (por venda)
         MTotCar := 0.00         //  Recebimentos em Cartao Credito (por venda)
         MTotCup := 0.00         //  Total do Cupom
         MVlrTro := 0.00         //  Troco
         Return(.f.)
      endif
		if cTecla $ "34"
			Mens({"Opcao nao disponivel ainda"})
			RestScreen( 03, 01, 16, 79, Tel_Subt )
         	MTotChv := 0.00         //  Recebimentos em Cheques (por venda)
         	MTotChp := 0.00         //  Recebimentos em Cheques Pre-Datados (por venda)
         	MTotDin := 0.00         //  Recebimentos em Dinheiro (por venda)
         	MTotTro := 0.00         //  Recebimentos em Trocas (por venda)
         	MTotTkt := 0.00         //  Recebimentos em Tickets (por venda)
         	MTotCre := 0.00         //  Recebimentos em Crediario (por venda)
         	MTotCar := 0.00         //  Recebimentos em Cartao Credito (por venda)
         	MTotCup := 0.00         //  Total do Cupom
         	MVlrTro := 0.00         //  Troco
         	Return(.f.)
         endif
      * --- VerIfica as Teclas de Recebimento
      MVlrPag := Recebto(cTecla)
      nvalor:=0
      Do Case
         Case cTecla == "1"           // Dinheiro
              MTotDin += MVlrPag
         Case cTecla == "2"           // cHeque
              MTotChv  += MVlrPag
         Case cTecla == "3"           // cheque Pre-datado
              MTotChp  += MVlrPag
         Case cTecla == "4"           // Cartao
              MTotCar += MVlrPag
         Case cTecla == "5"           // Ticket
              MTotTkt += MVlrPag
         Case cTecla == "6"           // trOca
              MTotTro += MVlrPag
         Case cTecla == "7"           // Carteira
              MTotCre += MVlrPag
         Case cTecla == "9"           //  dEsconto
              MTotDsc := MVlrPag
      EndCase
      If MSubTot - MTotCup > 0.00
         @ 12, 49 say [Saldo........:]
      Else
         @ 12, 49 say [Troco........:]
      endif
      If MTotDin > 0
         @ 04, 27 say MTotDin    Pict "@E 99,999.99"
      endif
      @ 05, 27 say MTotChv Pict "@E 99,999.99"
      @ 06, 27 say MTotChp Pict "@E 99,999.99"
      @ 07, 27 say MTotCar Pict "@E 99,999.99"
      @ 08, 27 say MTotTkt Pict "@E 99,999.99"
      @ 09, 27 say MTotTro Pict "@E 99,999.99"
      @ 10, 27 say MTotCre Pict "@E 99,999.99"
      @ 11, 64 say MTotCup Pict "@E 99,999.99"
      @ 12, 27 say MTotDsc Pict "@E 99,999.99"
      @ 12, 64 say Abs((MSubTot-MTotDsc) - MTotCup) Pict "@E 99,999.99"
      MTotCup = Round(MTotDin + MTotChv + MTotChp + MTotCar + MTotTkt + MTotTro + MTotCre,2)
      MVlrTro = MTotCup - (MSubTot-MTotDsc)
      If MVlrTro >= 0
         If MTotDin > 0
            If MVlrTro > MTotDin
               Aviso_1( 13,, 18,, [       A t e n z " o !       ], "Troco m~ximo permitido R$ "+Transf(MTotDin,[@E 9,999.99]), { [  ^Ok!  ] }, 1, .t., .t. )
               MTotTro := MTotTkt := nRecCrd := MTotCar := MTotCup := 0.00
               MVlrTro := MTotChv := MTotChp := MTotDin := MTotCre := 0.00
               Loop
            endif
         ElseIf MTotChv > MSubTot .or. MTotChp > MSubTot .or. MTotCre > MSubTot .or. MTotCar > MSubTot
            Aviso_1( 13,, 18,, [       A t e n z " o !       ], "Valor do cr'dito, ' superior ao da compra", { [  ^Ok!  ] }, 1, .t., .t. )
            MTotTro := MTotTkt := nRecCrd := MTotCar := MTotCup := 0.00
            MVlrTro := MTotChv := MTotChp := MTotDin := MTotCre := 0.00
            Loop
         endif
         If MVlrTro <= 0
            @ 12,49 say [Saldo........:]
         Else
            @ 12,49 say [Troco........:]
         endif
         @ 11,64 say MTotCup Pict "@E 99,999.99"
         @ 12,64 say Abs((MSubTot-MTotDsc) - MTotCup) Pict "@E 99,999.99"
         Exit
      endif
   EndDo
   If LastKey() == K_ESC
      RestScreen( 03, 01, 16, 79, Tel_Subt )
      cTecla=2
      Return .f.
   endif
   Do While .t.
      Sub_BANNER(05,42,Transf(MSubTot-MTotDsc,"@E 99,999.99"),1)
      If Aviso_1( 15,, 20,,"A t e n ž ' o !", "  Confirma Totais?  ", { " ^Sim ", " ^N'o " }, 1, .t. )=1
         cTecla=1
      Else
         cTecla=2
      endif
      Exit
   EndDo
   RestScreen( 03, 01, 16, 79, Tel_Subt )
   Return (cTecla = 1)
//******************************************************************************
******* Efetuar o Recebimento do Valor
Function RECEBTO(cTecla)
   Local Tel_Receb := SaveScreen( 15, 20, 20, 61 )
   local aPagto := {"Dinheiro..",;  // 1
                 	"Cheque....",;  // 2
                 	"Cartao de Credito",;  // 3
                 	"Cartao de Debito",;  // 4
                 	"Credito Loja"}  // 5
                 
   Cor_Ant := setcolor()
   Sombra(15,20,19,60)
   Window( 15, 20, 19, 60, [ (R E C E B I M E N T O)])
   @ 17,22 say "Valor em " + aPagto[AT(cTecla,"12345")] + ":" Get nValor PICT "@EK 99,999.99"
   SetCursor(SC_NORMAL)
   Read
   SetCursor(SC_NONE)
   If nValor # 0
      If cTecla = "9" .AND. nValor >= MSubTot
         Mens({[A t e n z " o !],"Valor de desconto MAIOR que total do Cupom"})
         nValor = 0
      Else
      endif
   Else
      KEYBOARD K_ESC
      INKEY()
   endif
   SetColor( Cor_Ant )
   RestScreen(15, 20, 20, 61, Tel_Receb)
   Return nValor
//******************************************************************************
******* Mostrar a Tela de Vendas
Function TL_VENDAS()
   Local nColFim := 67

   If XTCOD > 7
      nColFim += (XTCOD-7)
   endif
   Return
//******************************************************************************
Function CancelaItem()
   Local nItSel:=0,cCorAnt,nI:=0,aItem:={},aSelec:={},nColFim:=68

   If MSubTot = 0
      Aviso_1( 13,, 18,,"A t e n ž ' o !","N'o h~~ cupom fiscal aberto.", { "  ^Ok!  " }, 1, .t., .t. )
      Return .f.
   endif
	Set Key K_F5 To
	AEVal(aCodPro,{|elem| ++nI,aadd(aitem,[ ]+str(nI,3)+[ ]+pad(elem,13)+[  ]+if(empty(aDesPro[nI]),"*ZZZZZZZZZZ C A N C E L A D O ZZZZZZZZ-*",Pad(aDesPro[nI],34))+space(4)+transform(aQtdPro[nI],[999,999.999])+[ ]+transform(VPcoPro[nI]*aQtdPro[nI],[@e 999,999.99])+[ ]),aadd(aSelec,!empty(aDesPro[nI]))})  
	AEVal(aSelec,{|true| if(true,nItSel++,0)})
	Tel_Ant:=SaveScreen(08,00,19,89)
	If Len(aitem)==1 .or. nItSel==1
      	Mens({[A t e n z " o !], "Para cancelar todos os itens, use a tecla F6"})
      	Return .f.
   	Else
      	Cor_Ant := setcolor()
      	Sombra(08,00,18,88)
      	Window( 08, 00, 18, 88,"> Selecione o item a ser cancelado <")
      	NI := Achoice(09,01,17,87,AItem,ASelec)
   	endif
   	If NI=0
      	Restscreen(08,00,19,89,Tel_Ant)
      	Set key K_F5 to CancelaItem()
      	Return .f.
   	endif
	if len(alltrim(aCodPro[nI])) <= 6
		if !Produtos->(dbsetorder(1),dbseek(aCodPro[nI]))
      		Mens({"A t e n z ' o!","Item n'o cadastrado"})
      		Restscreen(08,00,19,89,Tel_Ant)
      		set key K_F5 to CancelaItem()
      		return .f.
      	endif
	else
	 	if !Produtos->(dbsetorder(5),dbseek(aCodPro[nI]))
      		Mens({"A t e n ž ' o !","Item n'o cadastrado"})
      		Restscreen(08,00,19,89,Tel_Ant)
      		set key K_F5 to CancelaItem()
      		return .f.
      	endif
   	endif
	If Aviso_1( 15,, 20,, "A t e n ž ' o !", "Confirma Cancelamento do Item "+STRZERO(nI,3)+" ?", { [ ^Sim ], [ ^N'o ] }, 1, .t. )=1
      //if Acbr_CancelaItemVendido(nI)
         if PdvNfceItem->(dbsetorder(2),dbseek(cNumPdv+aCodPro[nI]))
            do while PdvNfceItem->(!Trava_Reg())
            enddo
            PdvNfceItem->CanCup := "S"
            PdvNfceItem->(dbcommit())
            PdvNfceItem->(dbunlock())
         endif
         AtualizaSaldo(aCodPro[nI],.f.,aQtdPro[nI])
         * --- Subtrai do Sub-Total do Cupom
         MSubTot -= (VPcoPro[nI]-aValDsc[nI])*aQtdPro[nI]
         MSubTot := Round(MSubTot,2)
         aCodPro[nI] = SPACE(09)
         aQtdPro[nI] = 0
         VPcoPro[nI] = 0.00
         aDesPro[nI] = ""
         aUndPro[nI] := space(03)
      //endif
   endif
   RestScreen(08,00,19,89,Tel_Ant)
   SET KEY K_F5 TO CancelaItem()
   SetCursor( 1 )
   SUB_BANNER(24,59,Transf(MSubTot,"@E 99,999.99"),1)
   Return .f.
//*******************************************************************************
/*
    Canc_Cupom()
    Efetua o cancelamento da venda em adamento
*/
Function CANC_CUPOM()
  If MSubTot = 0
      Aviso_1( 13,, 18,, "A t e n ž ' o !", "N'o h~ venda em aberta", { [  ^Ok!  ] }, 1, .t., .t. )
      Set Key K_F6 TO CANC_CUPOM()
      Return .F.
   endif
   Do While .T.
        If Aviso_1( 15,, 20,,"A t e n ž ' o !", "Confirma Cancelamento da Venda ?", { [  ^Sim  ], [  ^N'o  ] }, 1, .t. )=2
            Set Key K_F6 TO CANC_CUPOM
            Exit
        endif
        If LastKey()== K_ESC
            Exit
        endif
        if MSeqIte > 0
            if PdvNfce->(dbsetorder(1),dbseek(cLanc))
                Msg(.t.)
                Msg("Aguarde: Cancelando a venda")
                do while PdvNfce->(!Trava_Reg())
                enddo
                if PdvNfceItem->(dbsetorder(1),dbseek(cLanc))
                    do while PdvNfceItem->Lanc == cLanc .and. PdvNfceItem->(!eof())
                        do while PdvNfceItem->(!Trava_Reg())
                        enddo
                        AtualizaSaldo(PdvNfceItem->CodPro,.f.,PdvNfceItem->QtdPro)
                        PdvNfceItem->(dbdelete())
					    PdvNfceItem->(dbcommit())
                        PdvNfceItem->(dbunlock())
                        PdvNfceItem->(dbskip())
				    enddo
                endif
                PdvNfce->(dbdelete())
                PdvNfce->(dbcommit())
                PdvNfce->(dbunlock())
                Msg(.f.)
            endif
      endif
      cCodItem:=Space(14)
      XLin:=4
      Break
      SET KEY K_F6 TO CANC_CUPOM
      Exit
   end
   SetCursor( 1 )
   Return Nil
//******************************************************************************
******* Efetuar o Cancelamento de Cupom Encerrado
Static Function Desc_Item()

	// ** If C_VAciDsc
	// ** 	Return .f.
	// ** end
   // ** If Permissao([DESCONTO])=.f.
   // **   Return .f.
   // ** end
   // ** @ 18,01 say [Desconto do Item Ativado] Color "B*"
   MCanDsc:=.t.
   Return
//******************************************************************************
/*
    DadosConsumidor
    Adiciona os dados do cliente na Nfc-e, Cpf e Nome
*/
procedure DadosConsumidor
	local Cor_Ant := setcolor(),cTela := SaveWindow()
	local getlist := {},cCpf,cNome,lEncontrou := .f.
	
	set key K_F3 to
	Window(07,10,12,80," Dados do consumidor ")
    setcolor(Cor(11))
    @ 09,12 say " CPF:"
    @ 10,12 say "Nome:"
    if Clientes->(dbsetorder(1),dbseek(cCodCli))
        cCpf := Clientes->CpfCli
        cNome := Clientes->NomCli
    endif
    do while .t.
        lEncontrou := .f.
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 09,18 get cCpf picture "@KR 999.999.999-99";
                when Rodape("Esc-Encerra")
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        // verifica se o consumidor esta cadastrado
        if Clientes->(dbsetorder(3),dbseek(cCpf))
            cNome      := Clientes->NomCli
            cCodCli    := Clientes->CodCli
            lEncontrou := .t.
            @ 10,18 say cNome
            If Aviso_1( 15,,20,,[Atencao!],"Confirma os dados do consumidor ?",{ [  ^Sim  ], [  ^Nao  ] }, 2, .t. ) = 2
                loop
            endif
            exit
        endif
        @ 10,18 get cNome picture "@k"
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            loop
        endif
        If Aviso_1( 15,,20,,[Atencao!],"Confirma os dados do consumidor ?",{ [  ^Sim  ], [  ^Nao  ] }, 2, .t. ) = 2
            loop
        endif
        // se n'o estiver cadastrado inclui no cadastro de 
        // clientes.
        if !lEncontrou
            do while Sequencia->(!Trava_Reg())
            enddo
            Sequencia->CodCli += 1
            cCodCli := strzero(Sequencia->CodCli,04,0)
            do while Clientes->(!Adiciona())
            enddo
            Clientes->CodCli := cCodCli
            Clientes->TipCli := "F"
            Clientes->BloCli := "N"
            Clientes->DatCli := date()
            Clientes->NomCli := cNome
            Clientes->CpfCli := cCpf
            //Clientes->CodNat :=
            Clientes->IndieDest := "9"
            Clientes->IndiFinal := "1"
            Clientes->Cobranca := "S"
            Clientes->Entrega  := "S" 
            Clientes->(dbcommit())
            Clientes->(dbunlock())
            Sequencia->(dbunlock())
            exit
        endif
    enddo
	set key K_F3 to DadosConsumidor()
	setcolor(Cor_Ant)
	RestWindow(cTela)
	return
//******************************************************************************
procedure ChamaPedido()
   Local Cor_Ant := setcolor(),cTela := SaveWindow()
   local getlist := {},cNumPed := space(06)

   If MSeqIte>1
      Return
   end
   Set Key K_F12 to
   set key K_F4 to
   Window( 07, 24, 11, 55," Importar Pedido ")
   while .t.
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 09, 26 say "N§ do Pedido : " get cNumPed Pict [@K9];
                when Rodape("Esc-Encerra");
                Valid Busca(Zera(@cNumPed),"Pedidos",1,,,,{"Pedido n'o cadastrado"},.f.,.f.,.f.)
      SetCursor(SC_NORMAL)
      read
      SetCursor(SC_NONE)
      If LastKey() == K_ESC
         Set Key K_F12 to ChamaPedido()
         set key K_F4  to ConProdutoPdv()
         SetColor( Cor_Ant )
         RestWindow(cTela)
         Return
      endif
      if !Pedidos->(dbsetorder(1),dbseek(cNumPed))
         Mens({"Pedido n'o cadastrado"})
         loop
      endif
      if !Confirm("Confirma a informaz'o")
         loop
      endif
      setcolor( Cor_Ant )
      RestWindow(cTela)
      Exit
   EndDo
   MTotPro:=0
   MChamaPed:=.t.
   XLin++
   ItemPed->(dbsetorder(1),dbseek(cNumPed))
   while ItemPed->NumPed == cNumPed .and. Itemped->(!eof())
      If MSeqIte = 0
         Banner(11,[CAIXA LIVRE],C_CDFnd)
      ElseIf MSeqIte = 1
         restscreen(09,02,14,90,cor)
      end
      If XLin>=15
         scroll(05,01,14,78,1)
         Xlin := 14
      end
      Produtos->(dbsetorder(1),dbseek(ItemPed->CodPro))
      Tributa->(dbsetorder(1),dbseek(Produtos->CodTrib))
      if !(Produtos->QteAc01 == 0)
         if ItemPed->QtdPro > Produtos->QteAc01
            nQtd := Produtos->QteAc01
         else
            nQtd := ItemPed->QtdPro
         end
         aadd(aCodPro,ItemPed->CodPro)
         aadd(aQtdPro,nQtd)
         aadd(VPcoPro,Round2(Produtos->Pcoven,2))
         aadd(aValDsc,0)
         aadd(VCodFis,Tributa->TipTrib)
         aadd(aDesPro,Produtos->DesPro)
         aadd(aUndPro,Produtos->EmbPro)
         @ XLin,01 say MSeqIte Pict [99]
         @ XLin,04 say aCodPro[MSeqIte]
         @ XLin,19 say Pad(aDesPro[MSeqIte],34) Pict [@!]
         @ XLin,56 say aQtdPro[MSeqIte]         Pict [@E 99999.999]
         @ XLin,70 say (VPcoPro[MSeqIte]-aValDsc[MSeqIte])*aQtdPro[MSeqIte] Pict [@e 99,999.99]
         If MSeqIte = 1
            Acbr_AbreCupom()
         end
         Acbr_VendeItem(aCodPro[MSeqIte],aDesPro[MSeqIte],VCodFis[MSeqIte],;
                        aQtdPro[MSeqIte],VPcoPro[MSeqIte],0,aUndPro[MSeqIte])
         MSubTot += (VPcoPro[MSeqIte] - aValDsc[MSeqIte]) * aQtdPro[MSeqIte]
         MSubTot := Round(MSubTot,2)
         Sub_Banner(16,44,Transf(MSubTot,"@E 99,999.99"),1)
         MSeqIte++
         XLin++
      end
      ItemPed->(dbskip())
   EndDo
   set key K_F12 to ChamaPedido()
   set key K_F4  to ConProdutoPdv()
   Keyb Chr(27)
   Return Nil
//******************************************************************************
/*
    GravaCupom
    Grava a venda 
*/
procedure GravaCupom

    Msg(.t.)
    Msg("Aguarde: Gravando os dados")
    if !PdvNfce->(dbsetorder(1),dbseek(cLanc))
        do while !PdvNfce->(Adiciona())
        enddo
        PdvNfce->Lanc := cLanc  // ** Numero do lanžamento
        PdvNfce->Data := date() // **Acbr_Data()
        PdvNfce->Hora := time() // ** Acbr_Hora()
        PdvNfce->CodNat := Sequencia->CodNatNfce
        PdvNfce->CodCli := cCodCli
        PdvNfce->Geral  := lGeral
        PdvNfce->(dbcommit())
        PdvNfce->(dbunlock())
    endif
    Produtos->(dbsetorder(1),dbseek(aCodPro[MSeqIte]))
    do while !PdvNfceItem->(Adiciona())
    enddo
    PdvNfceItem->lanc := cLanc
    PdvNfceItem->CodItem := aCodItem[MSeqIte]
    PdvNfceItem->CODPRO := aCodPro[MSeqIte]
    PdvNfceItem->QTDPRO := aQtdPro[MSeqIte]
    PdvNfceItem->PcoVen := aPcoVen[MSeqIte]
    PdvNfceItem->DscPro := aDscPro[MSeqIte]
    PdvNfceItem->PcoLiq := aPcoLiq[MSeqIte]
    PdvNfceItem->Desconto := aValDsc[MSeqIte]
    PdvNfceItem->TotPro   := aPcoLiq[MSeqIte]*aQtdPro[MSeqIte]
    PdvNfceItem->Cst      := aCstPro[MSeqIte] 
   
    // 101 - Tributada pelo Simples Nacional com permiss'o de cr'dito
    if Produtos->Cst == "101"
    
    // 102 - Tributada pelo Simples Nacional sem permiss'o de 
    //       cr'dito
    elseif Produtos->Cst == "102"
    
    // 103 - Isenž'o do ICMS no Simples Nacional para faixa de 
    //       receita bruta
    elseif Produtos->Cst == "103"
   
    // 201 - Tributada pelo Simples Nacional com permiss'o de 
    //       cr'dito e com cobranža do ICMS por substituiž'o tribut~ria
    elseif Produtos->Cst == "201"      
   
   
    // 202 - Tributada pelo Simples Nacional sem permiss'o de 
    //       cr'dito e com cobranža do ICMS por substituiž'o tribut~ria
    elseif Produtos->Cst == "202"
   
   
    // 203 - Isenž'o do ICMS no Simples Nacional para faixa de 
    //       receita bruta e com cobranža do ICMS por substituiž'o tribut~ria
    elseif Produtos->Cst == "203"
           
    // 300 - Imunie
    elseif Produtos->Cst == "300"
    
    // 400 - N'o tributada pelo Simples Nacional
    elseif Produtos->Cst == "400"
   
    // 500 - ICMS cobrado anteriormente por substituiž'o tribut~ria 
    //       (substituÐdo) ou por antecipaž'o
    elseif Produtos->Cst == "500"
    
    // 900 -- Outros
    elseif Produtos->Cst == "900"
    endif
   
    PdvNfceItem->(dbcommit())
    PdvNfceItem->(dbunlock())
    do while Sequencia->(!Trava_Reg())
    enddo
    Sequencia->LancPdv := val(cLanc)
    Sequencia->(dbunlock())
    dbcommitall()
    Msg(.f.)
    return
//******************************************************************************
procedure AtualizaCupom()

   if PdvNfce->(dbsetorder(1),dbseek(cLanc))
      do while !PdvNfce->(Trava_Reg())
      enddo
      PdvNfce->TOTCUP := MSubTot
      PdvNfce->TOTDES := MTotDsc
      PdvNfce->VLRDIN := MTotDin
      PdvNfce->VLRCHV := MTotChv
      PdvNfce->VLRCHP := MTotChp
      PdvNfce->VLRTRO := MTotTro
      PdvNfce->VLRTIK := MTotTkt
      PdvNfce->VLRCAR := MTotCar
      PdvNfce->VLRCRE := MTotCre
      PdvNfce->VTROCO := ABS(MVlrTro)
      PdvNfce->STATUS := MSTATUS
      PdvNfce->TRANSF := MChamaPed
      PdvNfce->CODVEN := MCodVen
      PdvNfce->CGCCPF := MCgcCpf
      PdvNfce->NumPed := MNumPed
      PdvNfce->NumOds := MNumOds
      PdvNfce->(dbcommit())
      PdvNfce->(dbunlock())
   endif
   return
//******************************************************************************
function AtualizaSaldo(cCodigo,lTipo,nQuant)
   local nContador,lTravou

   nContador := 30
   lTravou   :=.f.
   Produtos->(dbsetorder(1),dbseek(cCodigo))
   do while nContador > 0
      If Produtos->(Rlock())
         lTravou:=.t.
         Exit
      endif
      nContador--
      Inkey(0.5)
   enddo
	if lTravou
        // se lTipo = .t. dar baixa no estoque
		if lTipo
            // se o produto controla o estoque
			if Produtos->CtrLes == "S"
                // se for estoque fiscal 
                if !lGeral
				    if nQuant > Produtos->QteAc01
					   Mens({"Saldo insuficiente"})
					   lTravou := .f.
				    else
					   Produtos->QteAc01 := Produtos->QteAc01 - nQuant
                        // se tiver quantidade no fisico dar baixa
                        if nQuant <= Produtos->QteAc02
                            Produtos->QteAc02 := Produtos->QteAc02 - nQuant
                        endif
				    endif
                // se for estoque fisico
                else
                    if nQuant > Produtos->QteAc02
					   Mens({"Saldo insuficiente"})
					   lTravou := .f.
				    else
					   Produtos->QteAc02 := Produtos->QteAc02 - nQuant
				    endif
                endif
            endif

        // sen'o retorna para o estoque
		else
			if Produtos->CtrLes == "S"
                // se for estoque fisico
                if lGeral
                    Produtos->QteAc02 := Produtos->QteAc02 + nQuant
                // sen'o for estoque fiscal
                else
                    Produtos->QteAc01 := Produtos->QteAc01 + nQuant
                    Produtos->QteAc02 := Produtos->QteAc02 + nQuant
                endif
			endif
		endif
	endif
	Produtos->(dbunlock())
	return(lTravou)
//******************************************************************************
procedure Tela

   Window( 01,00,33,100, [ (Venda de Produtos) ]) //," F5-C.Item?F6-C.CF And.?F10-Dsc.Item|F12-Pedido?Ctrl+F12-Anula Pedido ")
   setcolor(Cor(11))
    //           1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
    //                    1         2         3         4         5         6         7         8         9         0
    @ 02,01 say "N§ Controle:             N§ NFCe:              Serie:        Status.: "+MStatus
    @ 03,01 say replicate(chr(196),99) Color Cor(11)
    @ 04,01 say space(99) color Cor(2)
    //@ 04,01 say "N„-C®digo---------Descriž'o do Produto-------------------------Quantidade--------Valor Total" color Cor(2)
    @ 04,01 say "N§  C¢digo     Descri‡Æo do Produto                                    Quantidade     Valor Total" color Cor(2)
    //@ 05,01 say "123 123456     12345678901234567890123456789012345678901234567890     999,999.999       99,999.99"
    //           1234567890123456789012345678901234567890123456789012345678901234567890123456789
    //                    1         2         3         4         5         6         7
    //@ 28,01 say "N„--C®digo-----------Quantidade--Descriž'o-------------------------------------------Valor Unit~rio" color Cor(2)
    @ 28,01 say space(99) color Cor(2)
    @ 28,01 say "N§  C¢digo           Quantidade  Descri‡Æo                                           Valor Unit rio" color Cor(2)
    //           123 12345678901234  999,999,999  12345678901234567890123456789012345678901234567890       99,999.99
    @ 30,01 say replicate(chr(196),99) Color Cor(11)
    @ 31,01 say "F3-Informa Consumidor           F4-Produtos   F6-Excluir produto  (*)-Quantidade"
    @ 32,01 say "F8-Cancela Venda em andamento  F10-Desconto  F12-Importar pedido"
   return
//******************************************************************************
function AbrirArquivos

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenProdutos()
      FechaDados()
      Msg(.f.)
      return(.f.)
   endif
   if !OpenClientes()
      FechaDados()
      Msg(.f.)
      return(.f.)
   endif
   if !OpenPedidos()
      FechaDados()
      Msg(.f.)
      return(.f.)
   endif
   if !OpenItemPed()
      FechaDados()
      Msg(.f.)
      return(.f.)
    endif
    if !OpenPdvNfce()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenPdvNfceItem()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenSequencia()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
    if !OpenNatureza()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OPenEmpresa()
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
//******************************************************************************
procedure TelaSubTotal(nLinha)

   @ nLinha,01 say replicate("Ä",99)
   @ ++nLinha,01 SAY "ÚÂÄÄ¿Ú¿  ¿ÂÂÄÄ¿  ÚÄÂÂÄ¿ÚÂÄÄ¿ÚÄÂÂÄ¿ÚÂÄÄ¿Ú¿"
   @ ++nLinha,01 SAY "ÀÁÄÂ¿Ã´  ³ÃÅÄÄ´ -  Ã´  Ã´  ³  Ã´  ÃÅÄÄ´Ã´"
   @ ++nLinha,01 SAY "ÀÄÄÁÙÀÁÄÄÙÁÁÄÄÙ    ÀÙ  ÀÁÄÄÙ  ÀÙ  ÀÙ  ÙÀÁÄÄ"
   return

Function Quantidade()
	Local GetList:={},Ok1:=.f.
	NQtd=1
	@ 29, 21 Get NQtd pict "@e 999,999.999" valid NQtd>0
	SetCursor( 1 )
	Read
	SetCursor( 0 )
	If !LastKey()=27
		Ok1:=.t.
	EndIf
	SetCursor( 1 )
	Return Ok1   
//******************************************************************************
/*
    MontarNFCe
    Monta o arquivo da NFC-e
*/   
static procedure MontarNFCe
    local nContador

	Natureza->(dbsetorder(1),dbseek(Sequencia->CodNatNfce))
	cComando := ""
	cComando += "[infNFE]"                           +CRLF
	cComando += "[Identificacao]"                    +CRLF
	cComando += 'NaturezaOperacao='+Natureza->Descricao +CRLF
	cComando += "Modelo=65"                          +CRLF
	cComando += "Serie="+Sequencia->SerieNfce+CRLF
    cComando += "nNF="+PdvNfce->nfce+CRLF
    
	// ** Data Emissao
	cComando += "Emissao="+dtoc(PdvNfce->Data)+" "+time()   + CRLF
	cComando += "indFinal="+Clientes->IndiFinal+CRLF
	cComando += "IndPres=1"+CRLF
	cComando += 'FormaPag=0'+CRLF // ** 0=Avista 1-Aprazo 2-Outros
	cComando += "tpAmb="+Sequencia->TipoAmbNfc+ CRLF // ** Identificaž'o do Ambiente 1-Produžao 2-Homologaž'o
	// ** Formato de impress'o do danfe
	cComando += "tpImp=4"+CRLF
	
	// ** Dados do Emitente
	cComando += "[Emitente]"+CRLF
	cComando += 'CNPJ='        +Empresa->Cnpj+CRLF
	cComando += 'IE='          +Empresa->Ie  +CRLF
	cComando += 'Razao='       +Empresa->Razao +CRLF
    if !empty(Empresa->Fantasia)
        cComando += 'xFant='+Empresa->Fantasia+CRLF
    endif
	// **cComando += 'Fantasia='    +clNomLoj  +CRLF
	if !empty(Empresa->Telefone1)
		cComando += 'Fone='+Empresa->Telefone1+CRLF
	endif
	cComando += 'CEP='         +Empresa->Cep+CRLF
	cComando += 'Logradouro='  +Empresa->Endereco+CRLF
	cComando += 'Numero='      +Empresa->Numero+CRLF
	if !empty(Empresa->Complend)
		cComando += 'Complemento='+Empresa->Complend+CRLF
	endif
	cComando += 'Bairro='+Empresa->Bairro+CRLF
    
	Cidades->(dbsetorder(1),dbseek(Empresa->CodCid))
    
	cComando += 'CidadeCod='+Cidades->CodIbge +CRLF
	cComando += 'Cidade='+Cidades->NomCid+CRLF
	cComando += 'UF='+Cidades->EstCid+CRLF
	cComando += 'PaisCod=1058'+CRLF
	cComando += 'Pais=BRASIL'+CRLF
	cComando += 'Crt='+Empresa->Crt+CRLF
		
    //Clientes->(dbsetorder(1),dbseek("0001"))
    Clientes->(dbsetorder(1),dbseek(PdvNfce->CodCli))
    
    
	// ** DESTINAT'RIO
    if Clientes->TipCli == "F"
        if !(Clientes->CpfCli == "00000000000")
            cComando += '[Destinatario]'+CRLF
            cComando += 'CNPJCPF='+Clientes->CpfCli+CRLF
            cComando += 'xNome='+Clientes->NomCli+CRLF
            cComando += 'indIEDest='+Clientes->indIEDest+CRLF
        endif
    endif
	nBaseICMS  := 0
	nValorICMS := 0
	nValorDoTributos := 0.00
	nValorTotalDoTributos := 0.00

    // Produtos
	PdvNfceItem->(dbsetorder(1),dbseek(cLanc))
	nContador := 1
	do while PdvNfceItem->Lanc == cLanc .and. PdvNfceItem->(!eof())
		Produtos->(dbsetorder(1),dbseek(PdvNfceItem->CodPro))
		cQuantidade := rtrim(alltrim(str(PdvNfceItem->QtdPro,15,4)))
        
		//cValorUnitario := rtrim(alltrim(str(round(nfceitem->PcoLiq,2),12,2)))
        
		cValorTotal    := rtrim(alltrim(str(PdvNfceItem->TotPro,12,2)))
		cValorDesconto := rtrim(alltrim(str(PdvNfceItem->Desconto,15,2)))
        if PdvNfceItem->desconto > 0
            cValorUnitario := rtrim(alltrim(str(round(PdvNfceItem->PcoVen,2),12,2)))
        else
            cValorUnitario := rtrim(alltrim(str(round(PdvNfceItem->PcoLiq,2),12,2)))
        endif
		
		// ** Calcula o valor total dos tributos
		/*
		if ibpt->(dbsetorder(1),dbseek(Produtos->CodNCM))
			nValorDoTributos := round(((nfeitem->TotPro * ibpt->aliqnac) / 100),2)
			nValorTotalDoTributos += nValorDoTributos
		endif
		*/
		Natureza->(dbsetorder(1),dbseek(Produtos->NatSaiDent))
		cComando += '[Produto'+strzero(nContador,3)+']'+CRLF
        if empty(Produtos->CodBar)
            cComando += 'cEAN=SEM GTIN'+CRLF
        else
            cComando += 'cEAN='+Produtos->CodBar+CRLF
        endif
		cComando += 'CFOP='+Natureza->Cfop+CRLF
		cComando += 'Codigo='+PdvNfceItem->CodPro+CRLF
		cComando += 'NCM='+Produtos->CodNCM+CRLF

        // ** Se o ambiente for de homologacao        
        if Sequencia->TipoAmbNfc == "2"
            if nContador == 1
                cComando += 'Descricao='+'NOTA FISCAL EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL'+CRLF
            else
                cComando += 'Descricao='+Produtos->DesPro+CRLF
            endif
        else
            cComando += 'Descricao='+Produtos->DesPro+CRLF
        endif            
		cComando += 'Unidade='      +Produtos->EmbPro+CRLF
		cComando += 'Quantidade='   +cQuantidade+CRLF
		cComando += 'ValorUnitario='+cValorUnitario          +CRLF
		cComando += 'ValorTotal='   +cValorTotal             +CRLF
		cComando += 'vDesc='+cValorDesconto          +CRLF
		cComando += 'vTotTrib='+rtrim(alltrim(str(nValorDoTributos,12,2)))+CRLF
        if empty(Produtos->CodBar)
            cComando += 'cEANTrib=SEM GTIN'+CRLF
        else
            cComando += 'cEANTrib='+Produtos->CodBar+CRLF
        endif
		cBaseICMS  := rtrim(alltrim(str(PdvNfceItem->baseicms,12,2)))
		cAliquota  := rtrim(alltrim(str(PdvNfceItem->Aliquota,5,2)))
      
		cValorICMS := rtrim(alltrim(str(PdvNfceItem->ValorIcms,12,2)))

		nBaseICMS  += val(cBaseICMS)  //   nfeitem->baseicms
		nValorICMS += val(cValorICMS) //nfeitem->valoricms
		
		// **nTotalDesconto += nfeitem->Desconto

		cComando +='[ICMS'+strzero(nContador,3)+']'+CRLF
		cComando += 'CSOSN='+PdvNfceItem->Cst+CRLF
		cComando +='ValorBase='+cBaseIcms+CRLF
		cComando +='Aliquota='+cAliquota+CRLF
		cComando +='Valor='+cValorICMS+CRLF
        
        if !empty(Produtos->Pis)
            cComando += '[PIS'+strzero(nContador,3)+']'+CRLF
            cComando += 'CST='+Produtos->Pis+CRLF
            cComando += 'ValorBase=0.00'+CRLF
            cComando += 'Aliquota=0.00'+CRLF
            cComando += 'Valor=0.00'+CRLF
        endif
        if !empty(Produtos->Cofins)
            cComando += '[COFINS'+strzero(nContador,3)+']'+CRLF
            cComando += 'CST='+Produtos->Pis+CRLF
            cComando += 'ValorBase=0.00'+CRLF
            cComando += 'Aliquota=0.00'+CRLF
            cComando += 'Valor=0.00'+CRLF
        endif
        
        

		PdvNfceItem->(dbskip())
		nContador += 1
	enddo
	cBaseICMS  := rtrim(alltrim(str(nBaseICMS,12,2)))
	cValorICMS := rtrim(alltrim(str(nValorICMS,12,2)))

    /*
	cBasSub := rtrim(alltrim(str(PdvNFce->BasSub,12,2)))
	cICMSub := rtrim(alltrim(str(PdvNFce->ICMSub,12,2)))
    */
	cBasSub := rtrim(alltrim(str(0.00,12,2)))
	cICMSub := rtrim(alltrim(str(0.00,12,2)))
    
	cTotPro := rtrim(alltrim(str(PdvNFce->TotCup,12,2)))
	cTotNot := rtrim(alltrim(str(PdvNFce->TotCup,12,2)))
	cTotalDesconto := rtrim(alltrim(str(PdvNFce->TotDes,15,2)))

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
	
	// ** Detalhamento de Pagamento
	nContador := 0
    aCodPagto := {}
    aValPagto := {}
    // Formas de pagamento
    // 01 - Dinheiro
    if MTotDin > 0
        aadd(aCodPagto,"01")
        aadd(aValPagto,pdvnfce->totcup) // refer o calculo
    endif
    // 02 - 
    for nContador := 1 to len(aCodPagto)
		cComando += "[Pag"+strzero(nContador,3)+"]"+CRLF
		cComando += "tPag="+aCodPagto[nContador]+CRLF
		cComando += "vPag="+rtrim(alltrim(str(aValPagto[nContador],13,2)))+ CRLF
        // ** se for cart'o de cr'dito/d'bito
        /*
        if DetPagtoNfce->CodPagto $ "03|04"
            CredCartao->(dbsetorder(1),dbseek(DetPagtoNfce->CodiCred))
            cComando += "[card]" + CRLF
            cComando += "CNPJ"+CredCartao->Cnpj+CRLF
            cComando += "tBand="+DetPagtoNfce->Bandeira+CRLF
            cComando += "cAut="+DetPagtoNfce->Autoriza+CRLF
        endif
		DetPagtoNfce->(dbskip())
        */
	next
    
	// ** Dados do Transportador
	cComando += '[Transportador]'+CRLF
	cComando += 'FretePorConta=9' +CRLF
return
//******************************************************************************
procedure MostrarErro(cCodigo,cMotivo)
	local cTela := SaveWindow()
	
	Window(09,00,14,79," Retorno ")
	setcolor(Cor(11))
	@ 11,01 say "Codigo: "+cCodigo
	@ 12,01 say "Motivo: "+cMotivo
	inkey(0)
	RestWindow(cTela)
	return
//******************************************************************************
procedure ConNFce(lAbrir)
    local oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados,cTela2
    local nCursor := setcursor(),cCor := setcolor(),lSaiMenu := .f.
    local nLinha1,nColuna1,nLinha2,nColuna2

	if lAbrir
		if !AbrirArquivos()
			return
		endif
	else
		setcursor(SC_NONE)
	endif
    select PdvNfce
    set order to 1
    dbgobottom()
    Rodape(iif(lAbrir,"Esc-Encerra","Esc-Encerra | ENTER-Transfere"))
    nLinha1  := 02
    nColuna1 := 00
    nLinha2  := maxrow()-1  // 23
    nColuna2 := 100
    setcolor(cor(5))
    Window(nLinha1,nColuna1,nLinha2,nColuna2,"> Consulta de NFC-e <")
    oBrow := TBrowseDB(nLinha1+1,nColuna1+1,nLinha2-7,nColuna2-1)
    oBrow:headSep := SEPH
    oBrow:footSep := SEPB
    oBrow:colSep  := SEPV
    oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)
    oCol := tbcolumnnew("Nr. Controle",{|| PdvNfce->Lanc})
    oCol:colorblock := {|| iif( pdvnfce->Autorizado,{1,2},{3,2})}   
	oBrow:addcolumn(oCol)
    
	oCol := tbcolumnnew("Nr. NFC-e",{|| pdvnfce->nfce})
    oCol:colorblock := {|| iif( pdvnfce->Autorizado,{1,2},{3,2})}
    oBrow:addcolumn(oCol)
    
	oCol := tbcolumnnew("Cliente",;
		{|| pdvNFce->CodCli+"-"+Clientes->(dbsetorder(1),dbseek(pdvNFCe->CodCli),left(Clientes->NomCli,40))})
    oCol:colorblock := {|| iif( pdvnfce->Autorizado,{1,2},{3,2})}
    oBrow:addcolumn(oCol)
        
        
	oCol := tbcolumnnew("Emissao",{|| pdvnfce->data})
    oCol:colorblock := {|| iif( pdvnfce->Autorizado,{1,2},{3,2})}
    oBrow:addcolumn(oCol)
    
	oCol := tbcolumnnew("Valor",{|| transform(pdvNFce->Totcup,"@e 999,999.99")})
    oCol:colorblock := {|| iif( pdvnfce->Autorizado,{1,2},{3,2})}
    oBrow:addcolumn(oCol)
    
    setcolor(Cor(26))
    scroll(nLinha2-1,nColuna1+1,nLinha2-1,nColuna2-1,0)
    Centro(nLinha2-1,nColuna1+1,nColuna2-1,"F3-Visualizar Itens")
    do while (! lFim)
        do while ( ! oBrow:stabilize() )
            nTecla := INKEY()
            if ( nTecla != 0 )
                exit
            endif
        enddo
        @ nLinha2-6,01 say " Situacao: "+pdvnfce->CStat Color Cor(11)
        @ nLinha2-5,01 say "   Motivo: "+left(pdvnfce->XMotivo,80) color Cor(11)
        
        if empty(pdvnfce->chave)
            @ nLinha2-4,01 say "    Chave: "+space(50) color Cor(11)
        else
            @ nLinha2-4,01 say "    Chave: "+transform(pdvnfce->chave,"9999.9999.9999.9999.9999.9999.9999.9999.9999.9999") color Cor(11)
        endif
        @ nLinha2-3,01 say "Protocolo: "+pdvnfce->NProt color Cor(11)
        @ nLinha2-2,01 say "Data/Hora: "+pdvnfce->DhRecBto color Cor(11)
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
                    cDados := NFCe->NumPed
                    keyboard (cDados)+chr(K_ENTER)
                    lFim := .t.
                endif
            elseif nTecla == K_F2
                //VerPedido()
            elseif nTecla == K_F3
                VerItens(PdvNfce->Lanc)
            elseif nTecla == K_F10
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
//******************************************************************************   
procedure TransNFCe // ** Faz transmiss'o
	local getlist := {}, cTela := SaveWindow()
    local cNfce,lNfce := .f.,cCodNumerico
	private cLanc
    private MTotDin  := 0.00     //  Recebimentos em Dinheiro (por venda)
        
    // ** declara Variaveis de retorno do acbr    
    private cNRec    // nomero do recibo
    private cCStat
    private cXMotivo // 
    private cChNfe  // chave da acesso
    private cDhRec  // data e hora do recebimento
    private cNProt  // nomero do protocolo
	private cComando
	
	if !AbrirArquivos()
		FechaDados()
		return
	endif

	AtivaF4()
	Window(08,09,15,70,"> Transmitir NFCe <")
   setcolor(Cor(11))
   @ 10,11 say "N§ Controle:"
   @ 11,11 say "    Cliente:"
   @ 12,11 say "       Data:"
   @ 13,11 say "      Valor:"
    do while .t.
        cLanc    := Space(10)
        cNRec    := "" // nomero do recibo
        cCStat   := ""
        cXMotivo := "" // 
        cChNfe   := "" // chave da acesso
        cDhRec   := "" // data e hora do recebimento
        cNProt   := "" // nomero do protocolo
        lNfce    := .f.
        
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 10,24 get cLanc picture "@k 9999999999";
            valid Busca(Zera(@cLanc),"pdvnfce",1,,,,{"Controle Nao Cadastrado"},.f.,.f.,.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        Clientes->(dbsetorder(1),dbseek(pdvnfce->CodCli))
        @ 11,24 say pdvnfce->CodCli+"-"+Clientes->ApeCli
        @ 12,24 say pdvnfce->data
        @ 13,24 say pdvnfce->TotCup picture "@e 999,999.99"
        if pdvnfce->Autorizado
            Mens({"Nota fiscal ja transmitida"})
            loop
        endif
        if pdvnfce->Cancelada
            Mens({"Nota cancelada"})
            loop
        endif
        if !(pdvnfce->Data == date()) 
            if Aviso_1( 17,, 22,, [Atenz"o!],"Data de emiss'o diferente da data atual, atualiza data?", { [  ^Sim  ], [  ^N'o  ] }, 1, .t. ) == 1
                do while pdvnfce->(!Trava_Reg())
                enddo
                pdvnfce->Data := date()
                pdvnfce->(dbcommit())
                pdvnfce->(dbunlock())
            else
                loop
            endif
        endif
        if !Confirm("Confirma as informa‡äes")
            loop
        endif
		if Sequencia->TestarInte == "S"
			lInternet := Testa_Internet()
         	if !lInternet
            	loop
         	endif
		endif
        MTotDin := PdvNfce->VlrDin
        
        // trava o arquivo de sequencia
        do while Sequencia->(!Trava_Reg())
        enddo
        cNFCe  := strzero(Sequencia->NumNFCe+1,09,0)
        
        // trava o registro do pdv
        do while PdvNfce->(!Trava_Reg())
        enddo
        PdvNfce->Nfce  := cNFCe
        PdvNfce->Serie := Sequencia->SerieNfce
        
        // ** Monta a nota fiscal de comsunidor eletronica
        MontarNFCe()
        
        // ** verifica o status de conex'o com a secret~ria da fazenda
        //if !StatusServico()
        if !Status_NFeNFCe(Sequencia->DirNfe)
            do while PdvNfce->(!Trava_Reg()) 
            enddo
            PdvNfce->Nfce := space(09)
            PdvNfce->Serie := space(03)
            PdvNfce->(dbcommit())
            PdvNfce->(dbunlock())
            Sequencia->(dbunlock())
			loop
		endif
        
        if !Criar_NFeNFCe(rtrim(Sequencia->dirNFe),@cChNfe,cComando)        
            PdvNfce->Nfce := space(09)
            PdvNfce->Serie := space(03)
            PdvNfce->(dbcommit())
            PdvNfce->(dbunlock())
            Sequencia->(dbunlock())
			loop
		endif
        
        // ** grava o numero da chave de acesso gerada em CriarNFCe
        PdvNfce->Chave := cChNfe
         
        // *********
        if !Assinar_NFeNFCe(rtrim(Sequencia->DirEnvResp),rtrim(Sequencia->dirNFe),cChNfe)             
            PdvNfce->Nfce := space(09)
            PdvNfce->Serie := space(03)
            PdvNfce->(dbcommit())
            PdvNfce->(dbunlock())
            Sequencia->(dbunlock())
			loop
		endif
        
        if !Validar_NFeNFCe(rtrim(Sequencia->DirEnvResp),rtrim(Sequencia->dirNFe),cChNfe)        
            PdvNfce->Nfce := space(09)
            PdvNfce->Serie := space(03)
            PdvNfce->(dbcommit())
            PdvNfce->(dbunlock())
            Sequencia->(dbunlock())
			loop
		endif
        
        // Transmite a nfe/nfce
        if !Transmitir_NFeNFCe(rtrim(Sequencia->DirEnvResp),rtrim(Sequencia->dirNFe),cChNfe)
            PdvNfce->Nfce := space(09)
            PdvNfce->Serie := space(03)
            pdvnfce->Cstat   := cCStat
            pdvnfce->Xmotivo := cXMotivo
            pdvnfce->(dbcommit())
            pdvnfce->(dbunlock())
            Sequencia->(dbunlock())
			loop
		endif
        // Nomero do protocolo de autorizacao
        cNProt    := RetornoSEFAZ("NProt",rtrim(Sequencia->dirNFe)+"\sainfe.txt")   
		cDhRecbto := RetornoSEFAZ("DhRecbto",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
        
		pdvnfce->Autorizado := .t.
		pdvnfce->DhRecbto   := cDhRecbto
		pdvnfce->NProt      := cNProt
		pdvnfce->(dbcommit())
		pdvnfce->(dbunlock())
        
        Sequencia->NumNFCe := val(cNFCe)
        // Libera o arquivo de sequencia
        Sequencia->(dbunlock())
        If Aviso_1( 17,, 22,,"Atenž'o !",[        Imprimir NFC-e ?        ], { [  ^Sim  ], [  ^N'o  ] }, 1, .t. ) = 1
            Imprimir_NFeNFCe(Sequencia->dirNFe,cChNfe)
        endif
   enddo
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
//******************************************************************************
/*
    ExcluirVenda
    Faz a exclus'o da venda
    Obs: s® faz a exclus'o se a venda n'o foi gerada a nfc-e 
*/   
procedure ExcluirVenda // ** Excluir a venda
	local getlist := {}, cTela := SaveWindow()
	local cLanc

	if !AbrirArquivos()
		FechaDados()
		return
	endif

	AtivaF4()
	Window(08,09,15,70,"> Excluir Venda <")
    setcolor(Cor(11))
    @ 10,11 say "N„ Controle:"
    @ 11,11 say "    Cliente:"
    @ 12,11 say "       Data:"
    @ 13,11 say "      Valor:"
    do while .t.
        cLanc    := Space(10)
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 10,24 get cLanc picture "@k 9999999999";
            when Rodape("Esc-Encerrar");
            valid Busca(Zera(@cLanc),"pdvnfce",1,,,,{"Controle Nao Cadastrado"},.f.,.f.,.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        Clientes->(dbsetorder(1),dbseek(Pdvnfce->CodCli))
        @ 11,24 say pdvnfce->CodCli+"-"+left(Clientes->NomCli,40)
        @ 12,24 say pdvnfce->data
        @ 13,24 say pdvnfce->TotCup picture "@e 999,999.99"
        if !Confirm("Confirma a exclus'o",2)
            loop
        endif
        if !PdvNfce->Geral
            if pdvnfce->Autorizado
                Mens({"Nota fiscal j~ transmitida","exclus'o n'o permitida"})
                loop
            endif
            if pdvnfce->Cancelada
                Mens({"Nota cancelada","exclus'o n'o permitida"})
                loop
            endif
        endif
        Msg(.t.)
        Msg("Aguarde: Excluindo Venda")
        do while pdvnfce->(!Trava_Reg())
        enddo
        pdvnfceitem->(dbsetorder(1),dbseek(cLanc))
        do while pdvnfceitem->Lanc == cLanc .and. pdvnfceitem->(!eof())
            do while pdvnfceitem->(!Trava_Reg())
            enddo
            if produtos->(dbsetorder(1),dbseek(pdvnfceitem->CodPro))
                // se controla o estoque
                if Produtos->CtrlEs == "S"
                    do while Produtos->(!Trava_Reg())
                    enddo
                    // se a venda for do estoque fisico
                    if PdvNfce->Geral
                        Produtos->QteAc02 += PdvNfceItem->QtdPro
                    // sen'o se for fiscal, retorna pro dois estoque
                    else
                        Produtos->QteAc01 += PdvNfceItem->QtdPro
                        Produtos->QteAc02 += PdvNfceItem->QtdPro
                    endif
                    Produtos->(dbcommit())
                    Produtos->(dbunlock())
                endif
            endif
            pdvnfceitem->(dbdelete())
            pdvnfceitem->(dbcommit())
            pdvnfceitem->(dbunlock())
            pdvnfceitem->(dbskip())
        enddo
        pdvnfce->(dbdelete())
        pdvnfce->(dbcommit())
        pdvnfce->(dbunlock())
        Msg(.f.)
   enddo
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
//******************************************************************************   
procedure StatusServicoNFCe
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
    if !Status_NFeNFCe(Sequencia->DirNfe)
        FechaDados()
        return
    endif
    cCStat := RetornoSEFAZ("CStat",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
	cXMotivo := RetornoSEFAZ("XMotivo",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
	MostrarErro(cCStat,cXMotivo)	
	FechaDados()
	return
// **********************************************************************************************************
// ** Consulta a NFC-e na SEFAZ
// **********************************************************************************************************
procedure ConNFCeSEFAZ
	local getlist := {},cTela := SaveWindow()
	local cNrNota,cStatus
	
	
	if !AbrirArquivos()
		return
	endif
	AtivaF4()
	Window(08,09,20,70,"> Consultar NFC-e na Sefaz <")
	setcolor(Cor(11))
	@ 10,11 say "Nr. Controle:"
	@ 11,11 say "     Cliente:"
	@ 12,11 say "        Data:"
	@ 13,11 say "       Valor:"
	@ 14,10 say replicate(chr(196),60)
	@ 15,11 say "      Status:"
	@ 16,11 say "      Motivo:"
	@ 17,11 say "   Protocolo:"
	@ 18,11 say "   Data/Hora:"
	do while .t.
		cControle := Space(10)
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 10,25 get cControle picture "@k 9999999999";
                when Rodape("ESC-Encerrar");
                valid Busca(Zera(@cControle),"pdvnfce",1,,,,{"Nota Fiscal nao Cadastrada"},.f.,.f.,.f.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		Clientes->(dbsetorder(1),dbseek(pdvnfce->CodCli))
		@ 11,25 say Pdvnfce->CodCli+"-"+left(Clientes->NomCli,40)
		@ 12,25 say Pdvnfce->Data
		@ 13,25 say Pdvnfce->TotCup picture "@e 999,999.99"
		if !Confirm("Confirma as Informacoes")
			loop
		endif
		if Sequencia->TestarInte == "S"
			lInternet := Testa_Internet()
         	if !lInternet
            	loop
         	endif
		endif
        // ** verifica o status de conex'o com a secret~ria da fazenda
        
        if !Status_NFeNFCe(Sequencia->DirNfe)
            loop
        endif
        //if !StatusServico()  
		//	loop
		//endif
        
        if !Consultar_NFeNFCe(Sequencia->DirNFe,Pdvnfce->Chave)
            loop
        endif
        cCStat    := RetornoSEFAZ("CStat",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
		cNProt    := RetornoSEFAZ("NProt",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
		cDhRecbto := RetornoSEFAZ("DhRecbto",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
		cXMotivo  := RetornoSEFAZ("XMotivo",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
		@ 15,25 say cCStat
		@ 16,25 say cXMotivo
		@ 17,25 say cNProt
		@ 18,25 say cDhRecbto
        
		do while !Pdvnfce->(Trava_Reg())
		enddo
        if cCStat == "100"
            Pdvnfce->Autorizado  := .t.
        endif
        if cCStat == "101"
            Pdvnfce->Cancelada := .t.
        endif
		Pdvnfce->NProt       := cNProt
        Pdvnfce->DhRecbto    := cDhRecbto
		Pdvnfce->CStat       := cCStat
        Pdvnfce->xmotivo     := cXMotivo
		Pdvnfce->(dbunlock())
	enddo
	DesativaF4()
	FechaDados()
	RestWindow(cTela)
	return
// **********************************************************************************************************
procedure ImpNFCe // ** Imprime o DANFE
	local getlist := {}, cTela := SaveWindow()
	local cControle,cArquivoXML
	
	if !AbrirArquivos()
		FechaDados()
		return
	endif

	AtivaF4()
	Window(08,09,15,70,"> Imprimir DANFE NFCe <")
   setcolor(Cor(11))
   @ 10,11 say "N§ Controle:"
   @ 11,11 say "    Cliente:"
   @ 12,11 say "       Data:"
   @ 13,11 say "      Valor:"
    while .t.
        cControle := Space( 10 )
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 10,24 get cControle picture "@k 9999999999";
                valid Busca(Zera(@cControle),"pdvnfce",1,,,,{"Controle Nao Cadastrado"},.f.,.f.,.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        // se n'o for geral = fiscal
        if !pdvnfce->Geral
            if !pdvnfce->Autorizado
                Mens({"Nota fiscal nao transmitida"})
                loop
            endif
        endif
        Clientes->(dbsetorder(1),dbseek(pdvnfce->CodCli))
        @ 11,24 say pdvnfce->CodCli+"-"+left(Clientes->NomCli,40)
        @ 12,24 say pdvnfce->Data
        @ 13,24 say pdvnfce->TotCup picture "@e 999,999.99"
		if !Confirm("Confirma os Dados")
			loop
		endif
        if !pdvnfce->Geral
            Imprimir_NFeNFCe(Sequencia->dirNFe,pdvnfce->Chave)
        else
            ICupomNaoFiscal(cControle)
        endif
   enddo
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
//******************************************************************************
procedure CanNFCe
    local getlist := {},cTela := SaveWindow()
    local cNrNota,cObsCan1,cObsCan2,cObsCan3,lLimpa := .t.
    private cCStat,cXMotivo,cNProt,cDhRecbto
   
   
	if !AbrirArquivos()
		return
	endif
    AtivaF4()
    Window(08,00,20,92,"> Cancela NFC-e <")
    setcolor(Cor(11))
   //           2345678901234567890
   @ 10,02 say "N§ Nota:"
   @ 11,02 say "Cliente:"
   @ 12,02 say "EmissÆo:"
   @ 13,02 say "  Sa¡da:"
   @ 14,02 say "  Valor:"
   @ 15,01 say replicate(chr(196),90)
   @ 16,02 say "Motivo :"
	do while .t.
		if lLimpa
			cNrNota := Space(09)
      		cObsCan1 := space(80)
      		cObsCan2 := space(80)
      		cObsCan3 := space(80)
      		lLimpa := .f.
      	endif
      	setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      	@ 10,11 get cNrNota picture "@k 999999999";
            when Rodape("Esc-Encerra | F4-Notas ");
            valid Busca(Zera(@cNrNota),"Pdvnfce",1,,,,{"Nota Nao Cadastrada"},.f.,.f.,.f.)
      	setcursor(SC_NORMAL)
      	read
      	setcursor(SC_NONE)
      	if lastkey() == K_ESC
         	exit
      	endif
      	Clientes->(dbsetorder(1),dbseek(nfce->CodCli))
      	nfceitem->(dbsetorder(1),dbseek(nfce->numnot))
      	@ 11,11 say nfce->CodCli+"-"+Clientes->NomCli
      	@ 12,11 say nfce->DtaEmi
      	@ 13,11 say nfce->DtaSai
      	@ 14,11 say nfce->TotNot picture "@e 999,999.99"
      	if !nfce->autorizado
         	Mens({"Nota fiscal n'o autorizada"})
         	loop
      	endif
      	if nfce->Cancelada
         	Mens({"Nota Ja Cancelada"})
         	loop
      	endif
		@ 16,11 get cObsCan1 picture "@k" when Rodape("Esc-Encerra")
		@ 17,11 get cObsCan2 picture "@k"
		@ 18,11 get cObsCan3 picture "@k"
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			loop
		endif
		if empty(cObsCan1+cObsCan2+cObsCan3)
			Mens({"Obrigatorio o preenchimento do Motivo do Cancelamento"})
			loop
		endif
		if len(rtrim(cObsCan1)+rtrim(cObsCan2)+rtrim(cObsCan3)) < 15
			Mens({"Caracter m¥nimo ' 15"})
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
		//if !StatusServico()
        if !Status_NFeNFCe(Sequencia->DirNfe)
			loop
		endif
		cTexto := ""
		if !empty(cObsCan1)
			cTexto += cObsCan1 + iif(!empty(cObsCan2),";","")
		endif
		if !empty(cObsCan2)
			cTexto += cObsCan2 + iif(!empty(cObsCan3),";","")
		endif
		if !empty(cObsCan3)
			cTexto += rtrim(cObsCan3)
		endif
		Msg(.t.)
		Msg("Aguarde: Cancelando NFC-e")
        AcbrNFE_CancelarNFe(rtrim(Sequencia->DirNFe),nfce->ChNfce,rtrim(cTexto),cEmpCnpj)
		cRetorno := Mon_Ret(rtrim(Sequencia->dirNFe),"sainfe.txt",Sequencia->Tempo)
		if !Men_Ok(cRetorno)
			Msg(.f.)
			LerErro(rtrim(Sequencia->DirNFe),"sainfe.txt")
			loop
		endif
		Msg(.f.)
		cCStat    := MEN_RET("CStat",cRetorno)
		cXMotivo  := MEN_RET( "XMotivo",cRetorno)
		cNProt    := MEN_RET( "NProt",cRetorno)
		cDhRecbto := MEN_RET("DhRecbto",cRetorno)
		if !(cCStat == "135")
			MostrarErro(cCStat,cXMotivo)
			loop
		endif
		if empty(cNProt)
			Mens({"Problema com Protocolo de Cancelamento","Favor repetir o cancelamento"})
			loop
		endif
		do while !nfce->(Trava_Reg())
		enddo
      	nfce->Cancelada   := .t.
      	nfce->NProtca    := cNProt     // ** nomero do protocolo de cancelando
      	nfce->DhRecbtoca := cDhRecbto  // ** Data e hora do cancelamento
      	nfce->CStatca    := cCStat     // ** c¸digo de retorno da operacao
      	nfce->XMotivoca  := cXMotivo   // ** Mensagem do retorno da operaz'o
      	nfce->(dbunlock())
      	nfceitem->(dbsetorder(1),dbseek(cNrNota))
		do while nfceitem->NumCon == cNrNota .and. nfceitem->(!eof())
			do while !nfceitem->(Trava_Reg())
			enddo
         	nfceitem->Cancelada := .t.
			if Produtos->(dbsetorder(1),dbseek(nfceitem->CodPro))
				if Produtos->CtrlEs == "S"
					do while !Produtos->(Trava_Reg())
                  	enddo
                  	Produtos->QteAc01 += nfeitem->QtdPro
                    Produtos->QteAc02 += nfeitem->QtdPro  
                  	Produtos->(dbunlock())
               	endif
            endif
         	nfceitem->(dbunlock())
         	nfceitem->(dbskip())
      	enddo
      	Mens({"Nota fiscal cancelada"})
      	lLimpa := .t.
	enddo
    DesativaF4()
    FechaDados()
    RestWindow(cTela)
    return
//******************************************************************************    
procedure VerItens(cNumero)
   Local cCor := setcolor(),cTela := SaveWindow()
   local aCampo  := {},aTitulo := {},aMascara := {},nnI := 1
   local nLinha1 := 04,nColuna1 := 10,nLinha2 := maxrow()-2,nColuna2 := 100
   private aVetor1 := {},aVetor2 := {},aVetor3 := {},aVetor4 := {},aVetor5 := {}
   private aVetor6 := {}

   PdvNfceItem->(dbsetorder(1),dbseek(cNumero))
   do while PdvNfceItem->Lanc == cNumero .and. PdvNfceItem->(!eof())
      Produtos->(dbsetorder(1),dbseek(PdvNfceItem->CodPro))
      aadd(aVetor1,nnI)
      aadd(aVetor2,PdvNfceItem->CodItem)
      aadd(aVetor3,left(Produtos->FanPro,34))
      aadd(aVetor4,PdvNfceItem->QtdPro)
      aadd(aVetor5,PdvNfceItem->PcoLiq)
      PdvNfceItem->(dbskip())
      nnI += 1
   enddo
   aTitulo  := {"Item"   ," Codigo" ,"Descricao","Qtde."    ,"Pco. Venda"}
   aCampo   := {"aVetor1","aVetor2","aVetor3"  ,"aVetor4"   ,"aVetor5"}
   aMascara := {"999"    ,"@!"     ,"@!"       ,"@e 999,999.999","@e 99,999.99"}
   cTela := SaveWindow()
   Rodape("Esc-Encerra")
   Window(nLinha1,nColuna1,nLinha2,nColuna2,"> Itens da NFC-e <")
   Edita_Vet(nLinha1+1,nColuna1+1,nLinha2-1,nColuna2-1,aCampo,aTitulo,aMascara, [XAPAGARU],,.f.,5)
   RestWindow(cTela)
   setcolor(cCor)
   Return
//******************************************************************************    
Function xapagaru( Pos_H, Pos_V, Ln, Cl, Tecla )

   If Tecla = 13
      nPos := pos_v
      Return( 0 )
   ElseIf Tecla = 27
      nPos := 0
      Return( 0 )
   EndIf
   Return( 1 )
//******************************************************************************    
procedure ICupomNaoFiscal(cNumPed) // Imprime cupom n'o fiscal
    local nContador := 1,nDesc := 0
    Clientes->(dbsetorder(1),dbseek(PdvNfce->CodCli))
    Cidades->(dbsetorder(1),dbseek(Empresa->CodCid))
    
    cComando := ""
    cComando += 'ESCPOS.ativar' + CRLF
    cComando += 'ESCPOS.imprimirlinha("</zera>")' + CRLF
    cComando += 'ESCPOS.imprimirlinha("</ce><e>'+left(rtrim(cEmpFantasia),38)+'</e>")'+CRLF
    cComando += 'ESCPOS.imprimirlinha("</ae><c>'+rtrim(Empresa->Endereco)+","+Empresa->Numero+rtrim(Empresa->Bairro)+" "+rtrim(Cidades->NomCid)+"-"+;
                    Cidades->EstCid+'</c>")'+CRLF
    
    /*
    cComando += 'ESCPOS.imprimirlinha("<c>'+"Fone: "+transform(cEmpTelefone1,"@r (999)9999-9999")+' '+;
            transform(cEmpTelefone2,"@r (999)99999-9999")+'</c>")'+CRLF
    */
    cComando += 'ESCPOS.imprimirlinha("</linha_simples>")'+CRLF            
    cComando += 'ESCPOS.imprimirlinha('+PADC("CUPOM NAO FISCAL", 48 )+')'+CRLF
    cComando += 'ESCPOS.imprimirlinha('+"  Lanc. PDV: "+cNumPed+" "+dtoc(Pedidos->Data)+" "+time()+')'+CRLF
    cComando += 'ESCPOS.imprimirlinha('+"    Cliente: "+Pedidos->CodCli+" "+left(Clientes->NomCli,30)+')'+CRLF
    cComando += 'ESCPOS.imprimirlinha("</linha_simples>")'+CRLF
    cComando += 'ESCPOS.imprimirlinha("'+'#|COD|DESC|QTD|UN|VL UN R$|(VLTR R$)*|VL ITEM R$"'+')'+CRLF
    cComando += 'ESCPOS.imprimirlinha("</linha_simples>")'+CRLF    
    PdvNfceItem->(dbsetorder(1),dbseek(cNumPed))
    do while PdvNfceItem->Lanc == cNumPed .and. PdvNfceItem->(!eof())
        Produtos->(dbsetorder(1),dbseek(PdvNfceItem->CodPro))
        cComando += 'ESCPOS.imprimirlinha('+'"<c>'+strzero(nContador,3,0)+;
                    space(02)+ItemPed->CodItem+;
                    space(02)+left(Produtos->FanPro,30)+'</c>")'+CRLF
        cComando += 'ESCPOS.imprimirlinha('+'"<c>'+;
                    transform(PdvNfceItem->QtdPro,"@e 99,999.999")+;
                    space(02)+Produtos->EmbPro+;
                    space(02)+'X'+;
                    space(02)+transform(PdvNfceItem->PcoLiq,"@e 99,999.999")+;
                    space(02)+transform(PdvNfceItem->PcoLiq*PdvNfceItem->QtdPro,"@e 999,999.99")+;
                    '</c>")'+CRLF
        PdvNfceItem->(dbskip())
        if PdvNfceItem->(eof())
            exit
        endif
        nContador += 1
    enddo
    cTexto   := 'Itens: '+strzero(nContador,3,0)+space(15)+'Sub-Total:'+transform(PdvNfce->TOTCUP,"@e 999,999.99")
    cComando += 'ESCPOS.imprimirlinha("'+cTexto+'")'+CRLF
    cComando += 'ESCPOS.imprimirlinha("<n>'+space(24)+"    Total: "+transform(PdvNfce->TotCup,"@e 999,999.99")+'</n>")'+CRLF
//    cComando += 'ESCPOS.imprimirlinha("'+"Pagamento: "+Plano->DesPla+'")'+CRLF
    if !empty(Sequencia->MCupom1) .or. !empty(Sequencia->MCupom2) .or. !empty(Sequencia->MCupom3)
        cComando += 'ESCPOS.imprimirlinha("</linha_simples>")'+CRLF
        if !empty(Sequencia->MCupom1)
            cComando += 'ESCPOS.imprimirlinha("</ce> '+rtrim(Sequencia->MCupom1)+'")'+CRLF
        endif
        if !empty(Sequencia->MCupom2)
            cComando += 'ESCPOS.imprimirlinha("</ce> '+rtrim(Sequencia->MCupom2)+'")'+CRLF
        endif
        if !empty(Sequencia->MCupom3)
            cComando += 'ESCPOS.imprimirlinha("</ce> '+rtrim(Sequencia->MCupom3)+'")'+CRLF
        endif
    endif
    cComando += 'ESCPOS.imprimirlinha("</pular_linhas>")'+CRLF
    cComando += 'ESCPOS.imprimirlinha("</corte_total>")'+CRLF
    cComando += 'ESCPOS.desativar'+CRLF
    Memowrit(rtrim(Sequencia->dirnfe)+"\escpos.txt",cComando)
    MemoWrit(rtrim(Sequencia->dirnfe)+"\entnfe.txt",cComando)
    return
//******************************************************************************    
procedure AtivaFisc

    // se n'o houver venda em andamento 
    if MSeqIte == 1
        if lGeral
            Mens({"Funcao Desativada"})
            lGeral := .f.  // Fiscal
            MStatus := "On-Line "
        else
            Mens({"Funcao Ativada"})
            lGeral  := .t. // Nao Fiscal
            MStatus := "Off-Line"
        endif
        @ 02,71 say MStatus
    endif
    return
//******************************************************************************    
procedure SangriaDoCaixa
    local cTela := SaveWindow()
    
    Window(10,10,15,60," Sangria do Caixa ")
    inkey(0)
    RestWindow(cTela)
    return

function VerificaSaldo(nQt)

    // se o produto controla o estoque
    if Produtos->CtrLes == "S"
        if lGeral  // verifica o estoque fÑsico
            if nQt > Produtos->QteAc02
                Mens({"Produto sem saldo suficiente"})
                cCodItem := space(14)
                nQtd     := 0
                return(.f.)
            endif
        else
            if nQt > Produtos->QteAc01
                Mens({"Produto sem saldo suficiente"})
                cCodItem := space(14)
                nQtd     := 0
                return(.f.)
            endif
        endif
    endif
    return(.t.)
    
    

//** Fim do arquivo.
