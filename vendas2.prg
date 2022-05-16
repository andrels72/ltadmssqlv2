*-------------
* M¢dulo_____: Vendas
* An lise____: Dino
* Programa‡„o: Dino
* Criado em__: 06/08/2001
*-------------
#include "setcurs.ch"
#include "inkey.ch"

Function Vendas()
   local cTela := SaveWindow()
   public TModulo:=0, TefCheque:= .f.
   private MCanDsc:=.f., MStatus:=[On-Line], xtCOD, MNumPed:=Space(10), OItens:={}, ;
           MChamaPed:=.f., MCanTEF:=.f.,;
           Arq_Soli, MCgcCpf:=MCodVen:=[  ], MNumCup:=Space(06), MTotChe:=0

   if !AbrirArquivos()
      return
   end
   XTCod:=20
   * --- Declaracao Variaveis
   private cStatus  := ""       //  Status diversos de operacoes fiscais
   private VQtdPro  := {}       //  Vetor de Quantidades
   private VCodPro  := {}       //  Vetor de Codigos
   private VDesPro  := {}       //  Vetor de Descricao
   private VPcoPro  := {}       //  Vetor de Valores Unitarios BRUTOS
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
   private cCodItm  := Space(13)//  Codigo do material (para Get)
   private nQtd     := 0     //  Quantidade vendida (para Get)
   private nPrecoUni:= 0.00     //  Preco Unitario (para display)
   private MDscIte  := 0.00     //  Desconto do Item (%)
   private nValDesc := 0.00     //  Desconto do Item (valor)
   private nPrecoTot:= 0.00     //  Preco Total (para display)
   private nCont    := 0        //  Contador

   CNumPdv := "0001" // Acbr_NumSerie()

   Begin Sequence
      set key K_F4  to ConProduto()
      Set Key K_F2  to Calc()                // Calculadora
      Set Key K_F6  to CancelaItem()           // Cancelamento de itens
      Set Key K_F8  to Canc_Cupom()          // Cancelamento de Cupom em andamento
      Set Key K_F10 to Desc_Item()           // Desconto no item
      Set Key K_F12 to ChamaPedido()
      xitem:=MSeqIte
      xlin:=3
      ***********************************
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
         * --- Solicita os Itens
         MSeqIte    := 0
         cCodItm    := Space(13)
         nCont      := 0
         nQtd       := 0
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
         Begin Sequence
            cNumCupom := "001" //Acbr_NumCupom()
            @ 02,35 say [N§ Cupom: ] + cnumcupom
            Lnha:=0
            Do While .t.
               MTotTkt  := MTotCre := MTotTro := MTotCar := 0.0
               MTotChv  := MTotChp := MTotDin := 0.00
               cCodItm  := Space(13)
               nQtd     := 0
               lExecuta := .F.
               If MSeqIte = 0
                  Cor := SaveScreen(09,02,14,78)
                  Banner(09,[CAIXA LIVRE]) //,C_CDFnd)
               ElseIf MSeqIte = 1
                  RestScreen(09,02,14,78,cor)
               endif
               Set Device to Screen
               MSeqIte++
               do while .t.
                  @ 22, 01 say MSeqIte pict [99]
                  setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
                  @ 22, 04 Get ccoditm pict "@!" when Rodape("F4-Produtos|F6-C.Item³F8-C.CF And.³F10-Dsc.Item|F12-Pedido") valid valid_item(@cCodItm,@nPrecoUni,@MDscIte,@nValDesc,@nQtd) .and. !Empty(ccoditm)
                  @ 22, 18 get nQtd picture "@ke 9,999,999" when Rodape("")
                  setcursor(SC_NORMAL)
                  read
                  setcursor(SC_NONE)
                  if lastkey() == K_ESC
                     exit
                  endif
                  /*
                  if !Confirm("Confirma a infoma‡Æo")
                     loop
                  endif
                  */
                  
                  if Produtos->Controla == "S"
                  	if nQtd > Produtos->QteAc01
                     	Mens({"Produto sem saldo suficiente"})
                     	cCodItm := space(13)
                     	nQtd    := 0
                     	loop
                  	endif
                  	
                  	// ** baixa no estoque
                  	if !AtualizaSaldo(cCodItm,.t.,nQtd)
                     	loop
                  	endif
                  endif
                  exit
               enddo
               If MSeqIte = 1
                  RestScreen(09,02,14,78,cor)
                  TelaSubTotal(16)
               endif
               If MSeqIte>1
                  Set Key K_F5 to CancelaItem()
               endif
               Tesc(1)
               If LastKey() == K_ESC
                  cCodItm := Space(13)
               endif
               If empty(cCodItm)
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
                  Aviso_1( 13,, 18,, [A t e n ‡ „ o !], [Limite m xido de itens, feche o cupom.], { [  ^Ok!  ] }, 1, .t., .t. )
                  MSeqIte--
                  Loop
               endif
               If XLin>=14
                  Scroll(05,01,14,78,1)
               Else
                  XLin++
               endif
               @ XLin,01 say MSeqIte pict [99]
               @ XLin,04 say Left(CCodItm,13)
               @ XLin,19 say Pad(Produtos->DesPro,34) pict [@!]
               @ XLin,56 say NQtd pict [@E 99999.999]
               @ XLin,70 say (NPrecoUni-NValDesc)*NQtd pict [@e 99,999.99]
               Tributa->(dbsetorder(1),dbseek(Produtos->CodTrib))
               aadd(VCodPro,cCodItm)
               aadd(VQtdPro,nQtd)
               aadd(VPcoPro,NPRECOUNI)
               aadd(VDscUni,nValDesc)
               aadd(VCodFis,Tributa->TipTrib)
               aadd(VDesPro,Produtos->DesPro)
               aadd(aUndPro,Produtos->EmbPro)
               /*
               If MSeqIte = 1
                   Acbr_AbreCupom()
               endif
               Acbr_VendeItem(vCodPro[MSeqIte],vDesPro[MSeqIte],;
                              VCodFis[MSeqIte],VQtdPro[MSeqIte],;
                              VPcoPro[MSeqIte],0,aUndPro[MSeqIte])
               */             
               MSubTot += (VPcoPro[MSeqIte] - VDscUni[MSeqIte]) * VQtdPro[MSeqIte]
               MSubTot := Round(MSubTot,2)
               Sub_Banner(17,44,Transf(MSubTot,"@E 99,999.99"),1)
               GravaCupom()
            EndDo
            XLin:=4
            * --- VerIfica Cancelamento de Cupom/Operacao
            If MSeqIte = 0
               Break
            endif
            Set Device to Screen
            * --- Salva Area da Janela
            Tel_Troco := SaveScreen( 06, 10, 18, 73 )
            Cor_Ant   := setcolor()
            Sombra(06,10,17,72)
            Window( 06, 10, 17, 72, [ (T R O C O)]) //, 5, [ ş Esc - Retorna], C_CDTit, C_CDFnd )
            @ 15,14 say "Total:"
            @ 15,22 say MSubTot pict "@e 999,999,999.99"
            @ 15,47 say "Pago :"
            @ 15,54 say MTotCup pict "@e 999,999,999.99"
            Sub_Banner(10,13,Transf(MVlrTro,"@E 999,999,999.99"),1)
            setcolor( Cor_Ant )
            Acbr_SubTotalizaCupom()
            Acbr_EfetuaPagamento(mTotCup,"01")
            Acbr_FechaCupom()
            inkey(0.10)
            AtualizaCupom()
            cNumCupom := Acbr_NumCupom()
            RestScreen( 06, 10, 18, 73, Tel_Troco )
          END SEQUENCE
          * --- VerIfica se ha itens
          If MSeqIte == 0
             Exit                         // Nao ha itens - Exit
          endif
          * --- Redimensiona os Work Arrays
          ASIZE(VCodPro,0)
          ASIZE(VQtdPro,0)
          ASIZE(VPcoPro,0)
          ASIZE(VDscUni,0)
          ASIZE(VCodFis,0)
          ASIZE(VDesPro,0)
          asize(aUndPro,0)
          MTotDsc := 0.00
       EndDo
       * --- Desabilita Hot-Keys
       Set Key K_AST to
       Set Key K_F5 to
       Set Key K_F8 to
   END SEQUENCE
   Fecha_Dados()
   RestWindow(cTela)
   return

Function Valid_Item(cCodItm,nPrecoUni,MDscIte,nValDesc,nQtd)
   Local i,ACodv,j,nqtemb,CCodAnt:=Space(9),codtmp:=[],nval:=0

   If LastKey() == K_ESC
      cCodItm = Space(13)
      Return .t.
   end
   If Empty(cCodItm)
      lExecuta = .t.
      Return .t.
   endif
   if len(alltrim(cCodItm)) <= 6
		cCodItm := strzero(val(cCodItm),6)
		if !Produtos->(dbsetorder(1),dbseek(cCodItm))
			Mens({"Produto nÆo cadastrado"})
			cCodItm = Space(13)
			LExecuta=.f.
			Return .f.
		endif
	else
		if !Produtos->(dbsetorder(5),dbseek(cCoditm))
			Mens({"Produto nÆo cadastrado"})
			cCodItm = Space(13)
			LExecuta=.f.
			Return .f.
		endif
   endif
   /*
   if !(ascan(VCodPro,cCodItm) == 0)
      Mens({"Produto ja lan‡ado"})
      cCodItm = Space(13)
      LExecuta=.f.
      Return .f.
   endif
   */
   nPrecoUni := Round2(Produtos->PcoCal,2)
   @ 22,29 say Produtos->DesPro pict [@!]
   @ 22,70 say nPrecoUni Pict [@e 99,999.99]
   if Produtos->QteAc01 == 0.00
      Mens({"Produto sem saldo"})
      cCodItm := space(13)
      return(.f.)
   end
   lExecuta=.T.
   Return .T.

Function Desconto(PPer,Pdes,Pval)
   Local GetList:={},tela_Ant:=SaveScreen(13,24,20,73),Escolha,mpct,mval,Ok:=.f.,xcan
   Cor_Ant = SetColor( C_CDFnd + [, ] + C_CDEdi + [,,, ] + C_CDFnd )

   Sombra(13,24,19,72)
   Caixa_Smp( 13, 24, 19, 72, [ D E S C O N T O ], 5, [ ş Esc - Retorna], C_CDTit, C_CDFnd )
   @ 14,26 SAY Alltrim(estoque->DesPro)
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
            Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "Valor m ximo para desconto ‚ de R$"+Transf(Max,"@E 999,999.99"), { [  ^Ok!  ] }, 1, .t., .t. )
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

Static Function Lim(Per)
   If Per>C_VLimDsc
      Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "Percentual m ximo para desconto ‚ de "+Transf(C_VLimDsc,"@E 99.99")+"%", { [  ^Ok!  ] }, 1, .t., .t. )
      RETURN .F.
   end
   Return .t.

Function SubTot()
   Local cTecla  := "", cMsg   := "", Tel_Subt := SaveScreen( 03, 01, 16, 79 ),;
         V_Cmp1[09], V_Tit1[09], V_Msc1[09]
   local cCorAntes
   Public Inc1_ := .t., Tipo := [ ]
   private nValor:= 0.00

   MTotChv := 0.00         // Recebimentos em Cheques (por venda)
   MTotChp := 0.00         // Recebimentos em Cheques Pre-Datados (por venda)
   MTotDin := 0.00         // Recebimentos em Dinheiro (por venda)
   MTotTro := 0.00         // Recebimentos em Trocas (por venda)
   MTotTkt := 0.00         // Recebimentos em Tickets (por venda)
   MTotCar := 0.00         // Recebimentos em Cartao Credito (por venda)
   MTotCre := 0.00         // Recebimentos em Crediario (por venda)
   MVlrPag := 0.00         // Valor Pago
   MVlrTro := 0.00         // Troco
   Sombra(03,01,15,78)
   cCorAntes := setcolor()
   Window( 03, 01, 15, 78, " P A G A M E N T O S "," ş Esc-Retorna | Escolha a op‡„o (1,2,3,4,5,6,7,9) ")
   @ 04,03 say [(1)-Dinheiro..........:]
   @ 05,03 say [(2)-Cheque a Vista....:]
   @ 06,03 say [(3)-Cheque a Prazo....:]
   @ 07,03 say [(4)-Cartao(TEF).......:]
   @ 08,03 say [(5)-Ticket............:]
   @ 09,03 say [(6)-Troca.............:]
   @ 10,03 say [(7)-Carteira..........:]
   @ 11,49 say [Valor Pago...:]
   @ 12,03 say [(9)-Desconto..........:]
   @ 12,49 say [Saldo........:]
   Do While .t.
      SUB_BANNER(05,42,Transf(MSubTot-MTotDsc,"@E 99,999.99"),1)
      @ 11,64 say MTotCup PICT "@E 99,999.99"
      If MSubTot - MTotCup > 0.00
         @ 12,49 say [Saldo........:]
      Else
         @ 12,49 say [Troco........:]
      end
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
      Do While ! ((cTecla := UPPER(CHR(INKEY(0)))) $ "12345679")
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
      end
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
      end
      If MTotDin > 0
         @ 04, 27 say MTotDin    Pict "@E 99,999.99"
      end
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
               Aviso_1( 13,, 18,, [       A t e n ‡ „ o !       ], "Troco m ximo permitido R$ "+Transf(MTotDin,[@E 9,999.99]), { [  ^Ok!  ] }, 1, .t., .t. )
               MTotTro := MTotTkt := nRecCrd := MTotCar := MTotCup := 0.00
               MVlrTro := MTotChv := MTotChp := MTotDin := MTotCre := 0.00
               Loop
            end
         ElseIf MTotChv > MSubTot .or. MTotChp > MSubTot .or. MTotCre > MSubTot .or. MTotCar > MSubTot
            Aviso_1( 13,, 18,, [       A t e n ‡ „ o !       ], "Valor do cr‚dito, ‚ superior ao da compra", { [  ^Ok!  ] }, 1, .t., .t. )
            MTotTro := MTotTkt := nRecCrd := MTotCar := MTotCup := 0.00
            MVlrTro := MTotChv := MTotChp := MTotDin := MTotCre := 0.00
            Loop
         end
         If MVlrTro <= 0
            @ 12,49 say [Saldo........:]
         Else
            @ 12,49 say [Troco........:]
         end
         @ 11,64 say MTotCup Pict "@E 99,999.99"
         @ 12,64 say Abs((MSubTot-MTotDsc) - MTotCup) Pict "@E 99,999.99"
         Exit
      end
   EndDo
   If LastKey() == K_ESC
      RestScreen( 03, 01, 16, 79, Tel_Subt )
      cTecla=2
      Return .f.
   end
   Do While .t.
      Sub_BANNER(05,42,Transf(MSubTot-MTotDsc,"@E 99,999.99"),1)
      If Aviso_1( 15,, 20,, [A t e n ‡ „ o !], [  Confirma Totais?  ], { [ ^Sim ], [ ^N„o ] }, 1, .t. )=1
         cTecla=1
      Else
         cTecla=2
      end
      Exit
   EndDo
   RestScreen( 03, 01, 16, 79, Tel_Subt )
   Return (cTecla = 1)

******* Efetuar o Recebimento do Valor
Function RECEBTO(cTecla)
   Local Tel_Receb := SaveScreen( 15, 20, 20, 61 )
   local aPagto := {"Dinheiro..",;  // 1
                 "Cheque....",;  // 2
                 "Cheque-Pre",;  // 3
                 "Cartao....",;  // 4
                 "Ticket....",;  // 5
                 "Troca.....",;  // 6
                 "Carteira..",;  // 7
                 "Desconto.."}   // 9
   // --- Se desconto solicita senha do Supervisor da Loja
   // ** If cTecla = "9" .and. Permissao([D E S C O N T O])=.f.
   // **   Return 0
   // ** end
   Cor_Ant := setcolor()
   Sombra(15,20,19,60)
   Window( 15, 20, 19, 60, [ (R E C E B I M E N T O)])
   @ 17,26 say "Valor em " + aPagto[AT(cTecla,"12345679")] + ":" Get nValor PICT "@EK 99,999.99"
   SetCursor(SC_NORMAL)
   Read
   SetCursor(SC_NONE)
   If nValor # 0
      If cTecla = "9" .AND. nValor >= MSubTot
         Mens({[A t e n ‡ „ o !],"Valor de desconto MAIOR que total do Cupom"})
         nValor = 0
      Else
      end
   Else
      KEYBOARD K_ESC
      INKEY()
   end
   SetColor( Cor_Ant )
   RestScreen(15, 20, 20, 61, Tel_Receb)
   Return nValor

******* Mostrar a Tela de Vendas
Function TL_VENDAS()
   Local nColFim := 67

   If XTCOD > 7
      nColFim += (XTCOD-7)
   end
   Return

Function CancelaItem()
   Local nItSel:=0,cCorAnt,nI:=0,aItem:={},aSelec:={},nColFim:=68

   If MSubTot = 0
      Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "N„o h  cupom fiscal aberto.", { [  ^Ok!  ] }, 1, .t., .t. )
      Return .f.
   end

   // ** If Permissao([Cancelamento de Item.])=.f.
   // **   Return .f.
   // ** end

   Set Key K_F5 To
   AEVal(VCodPro,{|elem| ++nI,aadd(aitem,[ ]+str(nI,3)+[  ]+pad(elem,6)+[  ]+if(empty(VDesPro[nI]),"*ÄÄÄÄÄÄÄÄÄÄ C A N C E L A D O ÄÄÄÄÄÄÄÄ-*",VDesPro[nI])+space(4)+transform(VQtdPro[nI],[999,999])+[ ]+transform(VPcoPro[nI]*VQtdPro[nI],[@e 999,999.99])+[ ]),aadd(aSelec,!empty(VDesPro[nI]))})
   AEVal(aSelec,{|true| if(true,nItSel++,0)})
   Tel_Ant:=SaveScreen(08,00,19,79)
   If Len(aitem)==1 .or. nItSel==1
      Mens({[A t e n ‡ „ o !], "Para cancelar todos os itens, use a tecla F6"})
      Return .f.
   Else
      Cor_Ant := setcolor()
      Sombra(08,00,18,78)
      Window( 08, 00, 18, 78, [Selecione o item a ser cancelado])
      NI := Achoice(09,01,17,77,AItem,ASelec)
   end
   If NI=0
      Restscreen(08,00,19,79,Tel_Ant)
      Set key K_F5 to CancelaItem()
      Return .f.
   end
   if !Produtos->(dbsetorder(1),dbseek(VCodPro[nI]))
      Mens({"A t e n ‡ Æ o!","Item nÆo cadastrado"})
      Restscreen(08,00,19,79,Tel_Ant)
      set key K_F5 to CancelaItem()
      return .f.
   end
   If Aviso_1( 15,, 20,, [A t e n ‡ „ o!], "Confirma Cancelamento do Item "+STRZERO(nI,3)+" ?", { [ ^Sim ], [ ^N„o ] }, 1, .t. )=1
      if Acbr_CancelaItemVendido(nI)
         if VendIte->(dbsetorder(4),dbseek(cNumPdv+cNumCupom+VCodPro[nI]))
            while VendIte->(!Trava_Reg())
            end
            VendIte->CanCup := "S"
            VendIte->(dbcommit())
            VendIte->(dbunlock())
         end
         AtualizaSaldo(VCodPro[nI],.f.,VQtdPro[nI])
         * --- Subtrai do Sub-Total do Cupom
         MSubTot -= (VPcoPro[nI]-VDscUni[nI])*VQtdPro[nI]
         MSubTot := Round(MSubTot,2)
         VCodPro[nI] = SPACE(09)
         VQtdPro[nI] = 0
         VPcoPro[nI] = 0.00
         VDscUni[nI] = 0.00
         VDesPro[nI] = ""
         aUndPro[nI] := space(03)
      end
   end
   RestScreen(08,00,19,79,Tel_Ant)
   SET KEY K_F5 TO CancelaItem()
   SetCursor( 1 )
   SUB_BANNER(16,44,Transf(MSubTot,"@E 99,999.99"),1)
   Return .f.

***** Efetuar o Cancelamento de Cupom em andamento
Function CANC_CUPOM()
   If MSubTot = 0
      Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "N„o h  cupom fiscal aberto.", { [  ^Ok!  ] }, 1, .t., .t. )
      Set Key K_F6 TO CANC_CUPOM()
      Return .F.
   end
   Do While .T.
      // ** If Permissao([C A N C E L A M E N T O])=.f.
      // **   Exit
      // ** end
      If Aviso_1( 15,, 20,, [A t e n ‡ „ o !], "Confirma Cancelamento do Cupom ?", { [  ^Sim  ], [  ^N„o  ] }, 1, .t. )=2
         Set Key K_F6 TO CANC_CUPOM
         Exit
      end
      If LastKey()== K_ESC
         Exit
      end
      if MSeqIte > 0
         if Acbr_CancelaCupom()
            for nAI := 1 to len(VCodPro)
               if VendIte->(dbsetorder(4),dbseek(cNumPdv+cNumCupom+VCodPro[nAI]))
                  while VendIte->(!Trava_Reg())
                  end
                  VendIte->CanCup := "S"
                  VendIte->(dbcommit())
                  VendIte->(dbunlock())
                  AtualizaSaldo(VCodPro[nAI],.f.,VQtdPro[nAI])
               endif
            next
            VendCup->(dbsetorder(1),dbseek(cNumPdv+cNumCupom))
            while VendCup->(!Trava_Reg())
            end
            VendCup->CanCup := "S"
            VendCup->(dbcommit())
            VendCup->(dbunlock())
         endif
      endif
      CCodItm:=Space(13)
      XLin:=4
      Break
      SET KEY K_F6 TO CANC_CUPOM
      Exit
   end
   SetCursor( 1 )
   Return Nil

******* Efetuar o Cancelamento de Cupom Encerrado

Static Function Desc_Item()
   If C_VAciDsc
      Return .f.
   end
   // ** If Permissao([DESCONTO])=.f.
   // **   Return .f.
   // ** end
   @ 18,01 say [Desconto do Item Ativado] Color "B*"
   MCanDsc:=.t.
   Return

Function V_Sit(Cod, Ali)
Select 90
Seek Cod+Str(Ali)
If Found()
   If C_VSeqImp = 2
      Return Alltrim(CodImp)
   ElseIf C_VSeqImp = 4
      Return Left(CodImp,2)
   Else
      Return CodImp
   end
Else
   Return [99]
end

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
      @ 09, 26 say "N§ do Pedido : " get cNumPed Pict [@K9] when Rodape("Esc-Encerra") Valid Busca(Zera(@cNumPed),"Pedidos",1,,,,{"Pedido nÆo cadastrado"},.f.,.f.,.f.)
      SetCursor(SC_NORMAL)
      read
      SetCursor(SC_NONE)
      If LastKey() == K_ESC
         Set Key K_F12 to ChamaPedido()
         set key K_F4  to ConProduto()
         SetColor( Cor_Ant )
         RestWindow(cTela)
         Return
      end
      if !Pedidos->(dbsetorder(1),dbseek(cNumPed))
         Mens({"Pedido nÆo cadastrado"})
         loop
      end
      if !Confirm("Confirma a informa‡Æo")
         loop
      end
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
         Banner(09,[CAIXA LIVRE],C_CDFnd)
      ElseIf MSeqIte = 1
         restscreen(09,02,14,78,cor)
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
         aadd(VCodPro,ItemPed->CodPro)
         aadd(VQtdPro,nQtd)
         aadd(VPcoPro,Round2(Produtos->PcoCal,2))
         aadd(VDscUni,0)
         aadd(VCodFis,Tributa->TipTrib)
         aadd(VDesPro,Produtos->DesPro)
         aadd(aUndPro,Produtos->EmbPro)
         @ XLin,01 say MSeqIte Pict [99]
         @ XLin,04 say VCodPro[MSeqIte]
         @ XLin,19 say Pad(VDesPro[MSeqIte],34) Pict [@!]
         @ XLin,56 say VQtdPro[MSeqIte]         Pict [@E 99999.999]
         @ XLin,70 say (VPcoPro[MSeqIte]-VDscUni[MSeqIte])*VQtdPro[MSeqIte] Pict [@e 99,999.99]
         If MSeqIte = 1
            Acbr_AbreCupom()
         end
         Acbr_VendeItem(vCodPro[MSeqIte],vDesPro[MSeqIte],VCodFis[MSeqIte],;
                        VQtdPro[MSeqIte],VPcoPro[MSeqIte],0,aUndPro[MSeqIte])
         MSubTot += (VPcoPro[MSeqIte] - VDscUni[MSeqIte]) * VQtdPro[MSeqIte]
         MSubTot := Round(MSubTot,2)
         Sub_Banner(16,44,Transf(MSubTot,"@E 99,999.99"),1)
         MSeqIte++
         XLin++
      end
      ItemPed->(dbskip())
   EndDo
   set key K_F12 to ChamaPedido()
   set key K_F4  to ConProduto()
   Keyb Chr(27)
   Return Nil

procedure GravaCupom

   Msg(.t.)
   Msg("Aguarde: Gravando o Cupom")
   if !VendCup->(dbsetorder(1),dbseek(cNumPdv+cNumCupom))
      while !VendCup->(Adiciona())
      end
      VendCup->NumPdv := cNumPdv
      VendCup->NumCup := cNumCupom
      // ** VendCup->DtaCup := Acbr_Data()
      // ** VendCup->HorCup := Acbr_Hora()
      VendCup->(dbcommit())
      VendCup->(dbunlock())
   end
   while !VendIte->(Adiciona())
   end
   VendIte->NUMPDV := cNumPdv
   VendIte->NUMCUP := cNumCupom
   VendIte->DTACUP := date() // ** Acbr_Data()
   VendIte->CODPRO := vCodPro[MSeqIte]
   VendIte->QTDPRO := VQtdPro[MSeqIte]
   VendIte->PCOUNI := (VPcoPro[MSeqIte]-VDscUni[MSeqIte])
   VendIte->PCOTOT := (VPcoPro[MSeqIte]-VDscUni[MSeqIte])*VQtdPro[MSeqIte]
   VendIte->(dbcommit())
   VendIte->(dbunlock())
   dbcommitall()
   Msg(.f.)
   return

procedure AtualizaCupom()

   if VendCup->(dbsetorder(1),dbseek(cNumPdv+cNumCupom))
      while !VendCup->(Trava_Reg())
      end
      VendCup->TOTCUP := MSubTot
      VendCup->TOTDES := MTotDsc
      VendCup->VLRDIN := MTotDin
      VendCup->VLRCHV := MTotChv
      VendCup->VLRCHP := MTotChp
      VendCup->VLRTRO := MTotTro
      VendCup->VLRTIK := MTotTkt
      VendCup->VLRCAR := MTotCar
      VendCup->VLRCRE := MTotCre
      VendCup->VTROCO := ABS(MVlrTro)
      VendCup->STATUS := MSTATUS
      VendCup->TRANSF := MChamaPed
      VendCup->CODVEN := MCodVen
      VendCup->CGCCPF := MCgcCpf
      VendCup->NumPed := MNumPed
      VendCup->NumOds := MNumOds
      VendCup->(dbcommit())
      VendCup->(dbunlock())
   end
   return

function AtualizaSaldo(cCodigo,lTipo,nQuant)
   local nContador,lTravou

   nContador := 30
   lTravou   :=.f.
   Produtos->(dbsetorder(1),dbseek(cCodigo))
   while nContador > 0
      If Produtos->(Rlock())
         lTravou:=.t.
         Exit
      end
      nContador--
      Inkey(0.5)
   end
   if lTravou
      if lTipo
         if nQuant > Produtos->QteAc01
            Mens({"Saldo insuficiente"})
            lTravou := .f.
         else
            Produtos->QteAc01 := Produtos->QteAc01 - nQuant
         end
      else
         Produtos->QteAc01 := Produtos->QteAc01 + nQuant
      end
   end
   Produtos->(dbunlock())
   return(lTravou)

procedure Tela

   Window( 01, 00, 23, 79, [ (Venda de Produtos)]) //," F5-C.Item³F6-C.CF And.³F10-Dsc.Item|F12-Pedido³Ctrl+F12-Anula Pedido ")
   Window( 02, 81, 23, 115)
   setcolor(Cor(11))
   @ 04,83 say "F4 -Produtos"
   @ 05,83 say "F5 -Exclui o produto"
   @ 05,83 say "F8 -Cancela Venda em Adamento"
   @ 06,83 say "F10-Desconto no Item"
   @ 07,83 say "F12-Importar Pedido"
   @ 08,83 say "(*)-Altera quantidade"
   
   
   @ 02,01 say [N§ S‚rie: ] + CNumPdv
   @ 02,35 say [N§ Cupom: ] + cNumCupom
   @ 02,62 say [Status.: ]+MStatus
   //           12345678901234567890123456789012345678901234567890123456789012345678901234567890
   //                    1         2         3         4         5         6         7         8
   @ 03,01 say [N§ÄC¢digoÄÄÄÄÄÄÄÄÄDescri‡„o do ProdutoÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄQuantidadeÄÄÄValor Total] color Cor(2)
   //           1234567890123456789012345678901234567890123456789012345678901234567890123456789
   //                    1         2         3         4         5         6         7
   @ 21,01 say [N§ÄC¢digoÄÄÄÄÄÄÄÄQuantidade Descri‡„oÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄVlr.Unit] color Cor(2)
   //              1234567890123 999,999,99 1234567890123456789012345678901234567890  99,999.99
   return

/*
@ 05, 00 SAY "       ÚÄÂÂÄ¿ÚÂÄÄ¿ÚÂÄÄ¿ÚÂÄÄ¿ÚÂÄÄ¿"
@ 06, 00 SAY "         Ã´  ÃÅÄÂÙÃ´  ³Ã´   Ã´  ³"
@ 07, 00 SAY "         ÀÙ  ÀÙ À ÀÁÄÄÙÀÁÄÄÙÀÁÄÄÙ"
*/

function AbrirArquivos

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !(Abre_Dados(cDiretorio,"Produtos",1,aNumIdx[06],"Produtos",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return(.f.)
   end
   if !(Abre_Dados(cDiretorio,"Clientes",1,aNumIdx[05],"Clientes",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return(.f.)
   end
   if !(Abre_Dados(cDiretorio,"Pedidos",1,aNumIdx[25],"Pedidos",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return(.f.)
   end
   if !(Abre_Dados(cDiretorio,"Itemped",1,aNumIdx[26],"Itemped",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return(.f.)
   end
   if !(Abre_Dados(cDiretorio,"Tributa",1,aNumIdx[40],"Tributa",0,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return(.f.)
   end
   if !(Abre_Dados(cDiretorio,"VendCup",1,1,"VendCup",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return(.f.)
   end
   if !(Abre_Dados(cDiretorio,"VendIte",1,aNumIdx[46],"VendIte",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return(.f.)
   end
   Msg(.f.)
   return(.t.)

procedure TelaSubTotal(nLinha)

   @ nLinha,01 say replicate("Ä",78)
   @ ++nLinha,01 SAY "ÚÂÄÄ¿Ú¿  ¿ÂÂÄÄ¿  ÚÄÂÂÄ¿ÚÂÄÄ¿ÚÄÂÂÄ¿ÚÂÄÄ¿Ú¿"
   @ ++nLinha,01 SAY "ÀÁÄÂ¿Ã´  ³ÃÅÄÄ´ -  Ã´  Ã´  ³  Ã´  ÃÅÄÄ´Ã´"
   @ ++nLinha,01 SAY "ÀÄÄÁÙÀÁÄÄÙÁÁÄÄÙ    ÀÙ  ÀÁÄÄÙ  ÀÙ  ÀÙ  ÙÀÁÄÄ"
   return

//** Fim do arquivo.
