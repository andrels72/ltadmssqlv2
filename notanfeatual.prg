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

procedure ConNotaNFE(lAbrir,lRetorno)
   local oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados,cTela2
   local nCursor := setcursor(),cCor := setcolor(),cCodCaixa,Sai_Mnu := .f.
   local aTitulo := {},aCampo := {},aMascara := {},Inicio,Fim,nPedido1,nPedido2,cFiltro
   local Item[05],aV_Zer[08],nLin1,nCol1,nLin2,nCol2
   private nRecno

   if lAbrir
      Msg(.t.)
      Msg("Aguarde : Abrindo o Arquivo")
      if !(Abre_Dados(cDiretorio,"Cidades",1,aNumIdx[04],"Cidades",1,.f.) == 0)
         FechaDados()
         Msg(.f.)
         return
      end
      if !(Abre_Dados( cDiretorio,"Grupos",1,aNumIdx[21],"Grupos",1,.f.) == 0)
         FechaDados()
         Msg(.f.)
         return
      end
      // ** Compras
      if !(Abre_Dados(cDiretorio,"Clientes",1,aNumIdx[05],"Clientes",1,.f.) == 0)
         FechaDados()
         Msg(.f.)
         return
      end
      // ** Iten da Compra
      if !(Abre_Dados(cDiretorio,"Vendedor",1,aNumIdx[09],"Vendedor",1,.f.) == 0)
         FechaDados()
         Msg(.f.)
         return
      end
      // ** Natureza Fiscal
      if !(Abre_Dados(cDiretorio,"Produtos",1,aNumIdx[06],"Produtos",1,.f.) == 0)
         FechaDados()
         Msg(.f.)
         return
      end
      if !(Abre_Dados(cDiretorio,"SubGrupo",1,aNumIdx[22],"SubGrupo",1,.f.) == 0)
         FechaDados()
         Msg(.f.)
         return
      end
      if !(Abre_Dados(cDiretorio,"nfeven",1,aNumIdx[40],"nfeven",1,.f.) == 0)
         FechaDados()
         Msg(.f.)
         return
      end
      if !(Abre_Dados(cDiretorio,"nfeitem",1,aNumIdx[41],"nfeitem",1,.f.) == 0)
         FechaDados()
         Msg(.f.)
         return
      end
      if !(Abre_Dados(cDiretorio,"Natureza",1,aNumIdx[24],"Natureza",1,.f.) == 0)
         FechaDados()
         Msg(.f.)
         return
      end
      if !(Abre_Dados(cDiretorio,"SitTrib",1,aNumIdx[23],"SitTrib",1,.f.) == 0)
         FechaDados()
         Msg(.f.)
         return
      end
      if !(Abre_Dados(cDiretorio,"Sequenci",0,0,"Sequencia",0,.f.) == 0)
         FechaDados()
         Msg(.f.)
         return
      end
      if !(Abre_Dados(cDiretorio,"Transpo",1,aNumIdx[20],"Transpo",1,.f.) == 0)
         FechaDados()
         Msg(.f.)
         return
      end
      if !(Abre_Dados(cDiretorio,"DupRec",1,aNumIdx[10],"DupRec",1,.f.) == 0)
         FechaDados()
         Msg(.f.)
         return
      end
      Msg(.f.)
   else
      setcursor(SC_NONE)
   end
   select nfeven
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
   nLin2 := 23
   nCol2 := 79
   Window(nLin1,nCol1,nLin2,nCol2,chr(16)+" Consulta de Notas Fiscais "+CHR(17))
   oBrow := TBrowseDB(03,01,19,78)
   oBrow:headSep := SEPH
   oBrow:footSep := SEPB
   oBrow:colSep  := SEPV
   oBrow:colorSpec := ConVertCor(Cor(25))+","+ConVertCor(Cor(31))
   oBrow:addcolumn(TBColumnNew("Controle",{|| nfeven->NumCon }))
   oBrow:addcolumn(TBColumnNew("Nota"    ,{|| nfeven->NumNot+" "+iif(nfeven->CanNot == "S","C"," ") }))
   oBrow:addcolumn(TBColumnNew("Emissao" ,{|| nfeven->DtaEmi}))
   oBrow:addcolumn(tbcolumnnew("Cliente" ,{|| Clientes->(dbsetorder(1),dbseek(nfeven->CodCli),nfeven->CodCli+"-"+left(Clientes->NomCli,30))}))
   oBrow:addcolumn(TBColumnNew("Valor da;Nota" ,{|| nfeven->TotNot}))
   aTab := TabHNew(20,01,78,setcolor(cor(28)),1)
   TabHDisplay(aTab)
   setcolor(Cor(26))
   scroll(21,01,22,78,0)
   Centro(22,01,78,"F3-Visualizar Itens | F10-Opcoes")
   while (! lFim)
      while ( ! oBrow:stabilize() )
         nTecla := INKEY()
         if ( nTecla != 0 )
            exit
         endif
      end
      if ( oBrow:stable )
         if ( oBrow:hitTop .OR. oBrow:hitBottom )
            tone(1200,1)
         endif
         nTecla := inkey(0)
      endif
      if !TBMoveCursor(nTecla,oBrow)
         if nTecla == K_ESC
            if Sai_Mnu
               set index to &cDiretorio.nfeven1,&cDiretorio.nfeven2,&cDiretorio.nfeven3,&cDiretorio.nfeven4,&cDiretorio.nfeven5
            end
            lFim := .t.
         elseif nTecla == K_ENTER
            if !lAbrir
            	if lRetorno
               		cDados := nfeven->NumCon
               	else
               		cDados := NfeVen->NumNot
               	endif
               if Sai_Mnu
                  set index to &cDiretorio.nfeven1,&cDiretorio.nfeven2,&cDiretorio.nfeven3,&cDiretorio.nfeven4,&cDiretorio.nfeven5
               endif
               keyboard (cDados)+chr(K_ENTER)
               lFim := .t.
            end
         elseif nTecla == K_F3
            VerItemNot(nfeven->NumCon)
         elseif nTecla == K_F10
            cTela2 := SaveWindow()
            Sai_Mnu = .f.
            Do While !Sai_Mnu
               Item[01] = [ ^Localiza           ]
               Item[02] = [ ^Ordena             ]
               Item[03] = [ ^Filtra             ]
               Item[04] = [ ^Cancela filtro     ]
               Item[05] = [ Congela/^Descongela ]
               Opcao := Menu_Vert(nLin1,nCol2- 21,Item,0,Cor(2),Cor(3),Cor(15),Cor(16),1, .f. )
               If Opcao < 0
                  Sai_Mnu = .t.
               ElseIf Opcao == 1
                  DB_Local(aCampo,aTitulo,aMascara,aV_Zer,{{1},{2},{3}},nLin1+2,nCol2-26,cFiltro)
                  If LastKey() = 27
                     Sai_Mnu = .f.
                  Else
                     N_Reg = RecNo()
                     oBrow:RowPos := 1
                     oBrow:RefreshAll()
                     Do While !oBrow:Stabilize()
                     EndDo
                     oBrow:RefreshAll()
                     Go N_Reg
                     Sai_Mnu = .t.
                  EndIf
               ElseIf Opcao = 2
                  DB_Ordena(aCampo,aTitulo,aMascara,{{1},{2},{3}},nLin1+2,nCol2-26,cFiltro,cDiretorio)
                  xrecno=recn()
                  If LastKey() = 27
                     Sai_Mnu = .f.
                  Else
                     goto xrecno
                     oBrow:RefreshAll()
         *           oBrow:GoTop()
                     Sai_Mnu = .t.
                  EndIf
               ElseIf Opcao = 3
                  Retorno = DB_Filtra(aCampo,aTitulo,aMascara,aV_Zer,Len({{1},{2},{3}}),nLin1+2,nCol2-26,cDiretorio)
                  cFiltro = If( Empty( Retorno ),cFiltro,Retorno)
                  If LastKey() = 27
                     Sai_Mnu = .f.
                  Else
                     oBrow:GoTop()
                     Sai_Mnu = .t.
                  EndIf
               ElseIf Opcao = 4
                  DB_CFiltra(Len({{1},{2},{3}}),cDiretorio,cFiltro,"MovCxa")
                  If LastKey() == K_ESC
                     Sai_Mnu = .f.
                  Else
                     oBrow:GoTop()
                     Sai_Mnu = .t.
                  EndIf
               ElseIf Opcao = 5
                  If oBrow:Freeze = 0
                     Col_Mov = oBrow:ColPos
                     Obj_Col := oBrow:GetColumn( Col_Mov )
                     If oBrow:ColPos > 1
                        oBrow:DelColumn( Col_Mov )
                        oBrow:InsColumn( 1, Obj_Col )
                     EndIf
                     oBrow:Freeze++
                     oBrow:GetColumn( 2 ):ColSep  := SEPV
                     oBrow:GetColumn( 2 ):HeadSep := SEPH
                     oBrow:Configure()
                  Else
                     If Col_Mov > 1
                        oBrow:DelColumn( 1 )
                        oBrow:InsColumn( Col_Mov, Obj_Col )
                     EndIf
                     oBrow:Freeze--
                     oBrow:GetColumn( 2 ):ColSep  := SEPV
                     oBrow:GetColumn( 2 ):HeadSep := SEPH
                     oBrow:Configure()
                  EndIf
                  Sai_Mnu = .t.
               EndIf
               RestWindow(cTela2)
            EndDo
         end
      end
      if nTecla == K_RIGHT
         tabHupdate(aTab,obrow:colpos,obrow:colcount,.t.)
      elseif nTecla == K_LEFT
         tabHupdate(aTab,obrow:colpos,obrow:colcount,.t.)
      end
   end
   if !lAbrir
      setcursor(nCursor)
      setcolor(cCor)
   else
      FechaDados()
   end
   RestWindow( cTela )
   return

procedure IncNotaNFE
   local getlist := {},cTela := SaveWindow()
   local llimpa := .t.
   local cCodCli,cSerNot,cSubSer,cCodMod,dDtaEmi,dDtaSai
   local aCampo := {},aTitulo := {},aMascara := {},cNumPed,lGeradaNFE
   local lTransmitirNFE
   Private MTransf:=.f., Operacao1, Operacao2
   Private MCodLoj, cNumCon, cNumNot, MCodVen, MDtaEmi, MDtaSai,cEstCli,cCodNat
   private nTotPro, nBasNor, nBasSub, nICMNor, nICMSub, MTotNot, nFreNot, MSegNot
   private MOutDsp, MIPINot, MAliICM,  MPesLiq, MPesBru, cTipFre, cObsNot1,cCodTra
   private cObsNot2, cObsNot3, cObsNot4, cObsNot5, cObsNot6, MCodPla, MCFONat, nDscNot
   private MBruPro,nQtdVol,cEspVol,cMarVol,nNumVol
   Private Operacao, VCliente, VVencmto, VParcela, Tela_P, MNumPar, MPrzPar, MValTot, Saiu := .f.
   Private aCodPro := {},aDesPro := {},aQtdEmb := {},aQtdPro := {}
   private aAliSai := {},aPcoPro := {},VDscPro := {},aTotPro := {}
   private aDesconto := {}
   private aCST    := {},aBaseIcms := {},aValorICMS := {},aIPI    := {}
   private VVencmto, VParcela, VChaves[25]
   private MNumPar, MEntPla, nAliq07, nAliq12, nAliq17, nAliq25, nAliq00, MGerDup
   private lEntrada := .f.


    if !AbrirArquivos()
        return
    endif
   AtivaF4()
   Window(02,00,33,120,"> Inclus∆o de Nota Fiscal Eletrìnica <")
   setcolor(Cor(11))
   //           12345678901234567890123456789012345678901234567890123456789012345678901234567890
   //                    1         2         3         4         5         6         7         8
   @ 03,01 say "Controle:           -                             Nota/Modelo:       /"
   @ 04,01 say replicate(chr(196),119)
   @ 05,01 say " Cliente:                                         "
   @ 06,01 say "Natureza:"
   @ 07,01 say " Emissao:                   Saida:"
   @ 08,01 say "   Frete:                Desconto:"
   @ 09,01 say replicate(chr(196),119) 
//   @ 09,01 say "123456789012345678901234567890123456789012345678901234567890123456789012345678"
   //                    1         2         3         4         5         6         7
//   @ 10,01 say " C¢digo DescriáÑo                             Qtde.   Pco. Venda Total"
   @ 11,01 say replicate(chr(196),119)
   @ 11,08 say chr(194)
   @ 11,46 say chr(194)
   @ 11,54 say chr(194)
   @ 11,65 say chr(194)
   for nI := 12 to 20
      @ nI,08 say chr(179)
      @ nI,46 say chr(179)
      @ nI,54 say chr(179)
      @ nI,65 say chr(179)
   next
   @ 21,01 say replicate(chr(196),119)
   @ 22,01 say "                                                   Total:"
   while .t.
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      lGeradaNFE     := .f.
      lTransmitirNFE := .f.
      if lLimpa
         cNumCon := Space( 10 )
         MCodLoj := Substr(C_VLojPdr,10,2)
         cNumNot := Space( 06 )
         cCodCli := space(04)
         cSerNot := "1  "
         cSubSer := space(02)
         dDtaEmi := date()
         dDtaSai := ctod(space(08))
         cCodMod := "01"
         MCodVen := Space( 02 )
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
         cNumPed := space(06)
      end
      nTotPro = 0
      nBasNor = 0
      nBasSub = 0
      nICMSub = 0
      nICMNor = 0
      MAliICM = 0
      MPesLiq = 0
      MPesBru = 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      if (Sequencia->LancNFE+1) > 9999999999
         Mens({"Limite de Lancamento Esgotado"})
         exit
      end
      cNumCon := strzero(Sequencia->LancNFE+1,10)
      cNumNot := strzero(Sequencia->NumNFE+1,9,0)
      @ 03,11 say cNumCon
      //@ 03,22 get cNumPed picture "@k 999999" when Rodape("Esc-Encerra | F4-Propostas") valid iif(empty(cNumPed),.t.,Busca(Zera(@cNumPed),"Pedidos",1,,,,{"Numero Nao Cadastrado"},.f.,.f.,.f.))
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      if !empty(cNumPed)
         if !NotaPedido(cNumPed)
            loop
         endif
         cCodCli := Pedidos->CodCli
      else
         if lLimpa
            aadd(aCodPro,space(06))
            aadd(aDesPro,Space(37))
            aadd(aQtdEmb,space(08))
            aadd(aAliSai,0)
            aadd(aQtdPro, 1 )
            aadd(aPcoPro, 0 )
            aadd(VDscPro, 0 )
            aadd(aDesconto,0)
            aadd(aTotPro, 0 )
			aadd(aCst,space(03))
            aadd(aBaseIcms,0)
            aadd(aValorICMS,0)
            aadd(aIPI,0)
         endif
      endif
      @ 03,64 say cNumNot
      @ 08,36 say Soma_Vetor(aDesconto) picture "@e 99,999,999.99"
      
      //@ 03,75 get cCodMod picture "@k!" when Rodape("Esc-Encerra")
      //@ 04,64 get cSerNot picture "@k!"
      //@ 04,68 get cSubSer picture "@k!"
      
      @ 05,11 get cCodCli picture "@k 9999" when Rodape("Esc-Encerra | F4-Clientes") valid vCliente(@cCodCli)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      @ 07,11 get dDtaEmi picture "@k" when .f.
      @ 07,36 get dDtaSai picture "@k" when Rodape("Esc-Encerra")
      @ 08,11 get nFreNot picture "@e 99,999,999.99"
//      @ 08,36 get nDscNot picture "@e 99,999,999.99"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      endif
      // ** Observaá∆o da Nota - Natureza
      cObsNot1 := Natureza->Obs1
      cObsNot2 := Natureza->Obs2
      cObsNot3 := Natureza->Obs3
      cObsNot4 := Natureza->Obs4
      cObsNot5 := Natureza->Obs5
      cObsNot6 := Natureza->Obs6
      aCampo   := {}
      aTitulo  := {}
      aMascara := {}
      aadd(aCampo,"aCodPro")    // ** 1
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
      aadd(aTitulo,"DescriáÑo ")     // ** 2
      aadd(aTitulo,"Qtde.")          // ** 3
      aadd(aTitulo,"Páo. Venda")     // ** 4
      aadd(aTitulo,"Desconto")       // ** 5
      aadd(aTitulo,"Total")          // ** 6
      aadd(aTitulo,"CST")            // ** 7
      aadd(aTitulo,"Aliq.ICMS")      // ** 8
      aadd(aTitulo,"Base ICMS")      // ** 9
      aadd(aTitulo,"Vl. ICMS")       // ** 10
      aadd(aTitulo,"Aliq.IPI")       // ** 11
      *----------
      aadd(aMascara,"@k 999999")       // ** 1
      aadd(aMascara,"@!S40")           // ** 2
      aadd(aMascara,"@E 999,999.999") // ** 3 Quantidade do produto
      aadd(aMascara,"@E 99,999.999")  // ** 4 Valor Unit·rio
      aadd(aMascara,"@e 99,999.99")    // ** 5 Desconto
      aadd(aMascara,"@E 9,999,999.99") // ** 6 Valor Total
      aadd(aMascara,"@!")              // ** 7
      aadd(aMascara,"999.99")          // ** 8 Aliquota de ICMS
      aadd(aMascara,"@E 999,999.99")    // ** 9
      aadd(aMascara,"@E 999,999.99")    // ** 10
      aadd(aMascara,"999.99")          // ** 11
      //setcolor(Cor(26))
      @ 21,01 say replicate(chr(196),119)
      //Centro(21,01,119," F2-Confirma | F4-Inclui | F6-Exclui | F8-Abandona ")
      @ 21,01 say " F2-Confirma | F4-Inclui | F6-Exclui | F8-Abandona " color Cor(26) 
      Rodape("Esc-Encerra")
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      keyboard chr(K_ENTER)
      while .t.
         Edita_Vet(10,01,20,119,aCampo,aTitulo,aMascara, [nfeitem],,,,1)
         if lastkey() == K_F2
            if !Confirm("Confirma os Itens da Nota")
               loop
            end
            if !Pega2()
               loop
            end
            exit
         elseif lastkey() == K_F8
            exit
         end
      end
      if lastkey() == K_F8
         loop
      end
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
      end
      Sequencia->LancNFE := val(cNumCon)
      Sequencia->NumNFE  := val(cNumNot)
      Sequencia->(dbunlock())
      cNumCon := strzero(Sequencia->LancNFE,10)
      cNumNot := strzero(Sequencia->NumNFE,9,0)
      @ 03,11 say cNumCon
      @ 03,64 say cNumNot
      while !nfeven->(Adiciona())
      end
      nfeven->NumCon  := cNumCon
      nfeven->NumNot  := cNumNot
      nfeven->CodCli  := cCodCli
      nfeven->CodVen  := Clientes->CodVen
      nfeven->CodNat  := cCodNat
      nfeven->DtaEmi  := dDtaEmi
      nfeven->DtaSai  := dDtaSai
      nfeven->BasNor  := nBaseICMS
      nfeven->ICMNor  := nValorICMS

//      nfeven->BasSub  := nBasSub
//      nfeven->FreNot  := nFreNot
//      nfeven->SegNot  := MSegNot

      nfeven->IPINot  := MIPINot
      nfeven->TotNot  := MTotNot

      nfeven->TotPro  := nTotPro
      nfeven->CodTra  := cCodTra
      nfeven->QtdVol  := nQtdVol
      nfeven->EspVol  := cEspVol
      nfeven->MarVol  := cMarVol
      nfeven->NumVol  := nNumVol
      nfeven->TipFre  := cTipFre
      nfeven->ObsNot1 := cObsNot1
      nfeven->ObsNot2 := cObsNot2
      nfeven->ObsNot3 := cObsNot3
      nfeven->ObsNot4 := cObsNot4
      nfeven->ObsNot5 := cObsNot5
      nfeven->ObsNot6 := cObsNot6
      nfeven->PesLiq  := MPesLiq
      nfeven->PesBru  := MPesBru
      nfeven->BasI00  := nAliq00
      nfeven->BasI07  := nAliq07
      nfeven->BasI12  := nAliq12
      nfeven->BasI17  := nAliq17
      nfeven->BasI25  := nAliq25
      
      
      
      // **If !Empty( nDscNot )
         nfeven->DscNo1 := Soma_Veto2(aDesconto)        // **nDscNot
         
      // **EndIf
      For Laco = 1 to len(aCodPro)
         If !empty( aCodPro[Laco] )
            Produtos->(dbsetorder(1),dbseek(aCodPro[Laco]))
            while !Produtos->(Trava_Reg())
            end
            while !nfeitem->(Adiciona())
            end
            nfeitem->NumCon := cNumCon
            nfeitem->CodCli := cCodCli
            nfeitem->AliSai := aAliSai[Laco]
            nfeitem->QtdPro := aQtdPro[Laco]
            nfeitem->PcoPro := aPcoPro[Laco]
            nfeitem->TotPro := aTotPro[Laco]
            nfeitem->PcoCus := Produtos->PcoCus
            nfeitem->CodNat := cCodNat
            nfeitem->CodVen := Clientes->CodVen
            nfeitem->DtaMov := dDtaEmi
            nfeitem->CodPro := aCodPro[Laco]
            
            nfeitem->Cst := aCst[Laco]
            
            nfeitem->baseicms := aBaseICms[laco]
            nfeitem->valoricms := avaloricms[laco]
            nfeitem->ipi := aipi[laco]
            nfeitem->desconto := aDesconto[Laco]
            
            nfeitem->(dbcommit())
            nfeitem->(dbunlock())

            // ** So atualiza o estoque quanto o ambiente da NFE for 1-produá∆o
            if Sequencia->TipoAMB == "1"
               if Produtos->CtrlEs == "S"
                  If Natureza->BxaEst = "S"
                     if Natureza->OpeNat = [V]
                        Produtos->QteAC01 -= aQtdPro[Laco]
                     elseif Natureza->OpeNat = [D]
                        Produtos->QteAC01 += aQtdPro[Laco]
                     endif
                  endif
               endif
            endif
         end
         Produtos->(dbunlock())
      Next
      nfeven->(dbcommit())
      nfeven->(dbunlock())
      If Aviso_1( 17,, 22,, [AtenáÑo!], [Gerar e transmitir a NFE ?], { [  ^Sim  ], [  ^N∆o  ] }, 1, .t. ) = 1
         lInternet := Testa_Internet()
         if !lInternet
            loop
         endif
         cDiretorioNFE := rtrim(Sequencia->DirNFE)
         if !StatusServico()
            loop
         endif
         lGeradaNFE := GeraNFE(cNumCon)
         if lGeradaNFE
            while !nfeven->(Trava_Reg())
            enddo
            nfeven->nfegerada := .t.
            nfeven->Arquivo   := cArqNFE
            nfeven->(dbunlock())
         else
            loop
         endif
//         exit   // ** PARA TESTAR A NOTA
         lTransmitirNFE := TransmitirNFE(,cNumCon)
         if !lTransmitirNFE
            loop
         endif
         while !nfeven->(Trava_Reg())
         enddo
         nfeven->NFeTransmi  := .t.
         nfeven->NRec        := cNRec
         nfeven->CStat       := cCStat
         nfeven->Xmotivo     := cXMotivo
         nfeven->ChNfe       := cChNfe
         nfeven->NProt       := cNProt
         nfeven->DigVal      := cDigVal
         nfeven->(dbunlock())
         nfeven->(dbcommit())
         if lTransmitirNFE
            Imp_DANFE(cDiretorioNFE,nfeven->ChNfe)
            while !nfeven->(Trava_Reg())
            end
            nfeven->NfeImprimi := .t.
            nfeven->(dbunlock())
         end
      end
   end
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   end
   FechaDados()
   RestWindow(cTela)
   return

procedure CancelaNFE
   local getlist := {},cTela := SaveWindow()
   local cNumCon,cMotivo
   private cCStat,cXMotivo,cNProt,cDhRecbto

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !(Abre_Dados(cDiretorio,"Cidades",1,aNumIdx[04],"Cidades",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   if !(Abre_Dados( cDiretorio,"Grupos",1,aNumIdx[21],"Grupos",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   // ** Compras
   if !(Abre_Dados(cDiretorio,"Clientes",1,aNumIdx[05],"Clientes",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   // ** Iten da Compra
   if !(Abre_Dados(cDiretorio,"Vendedor",1,aNumIdx[09],"Vendedor",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   // ** Natureza Fiscal
   if !(Abre_Dados(cDiretorio,"Produtos",1,aNumIdx[06],"Produtos",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   endif
   if !(Abre_Dados(cDiretorio,"SubGrupo",1,aNumIdx[22],"SubGrupo",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   endif
   if !(Abre_Dados(cDiretorio,"nfeven",1,aNumIdx[40],"nfeven",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   endif
   if !(Abre_Dados(cDiretorio,"nfeitem",1,aNumIdx[41],"nfeitem",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   endif
   if !(Abre_Dados(cDiretorio,"Natureza",1,aNumIdx[24],"Natureza",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   endif
   if !(Abre_Dados(cDiretorio,"SitTrib",1,aNumIdx[23],"SitTrib",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   endif
   if !(Abre_Dados(cDiretorio,"Sequenci",0,0,"Sequencia",0,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   endif
   if !(Abre_Dados(cDiretorio,"Transpo",1,aNumIdx[20],"Transpo",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   if !(Abre_Dados(cDiretorio,"DupRec",1,aNumIdx[10],"DupRec",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   Msg(.f.)
   AtivaF4()
   Window(07,07,17,72," Cancela NFe ")
   setcolor(Cor(11))
   @ 09,09 say "    Nß Controle:"
   @ 10,09 say "        Nß Nota:"
   @ 11,09 say "        Cliente:"
   @ 12,09 say "Data de Emissao:"
   @ 13,09 say "  Data de Sa°da:"
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
      end
      Clientes->(dbsetorder(1),dbseek(nfeven->CodCli))
      nfeitem->(dbsetorder(1),dbseek(cNumCon))
      @ 10,26 say nfeven->NumNot
      @ 11,26 say nfeven->CodCli+"-"+Clientes->NomCli
      @ 12,26 say nfeven->DtaEmi
      @ 13,26 say nfeven->DtaSai
      @ 14,26 say nfeven->TotNot picture "@e 999,999.99"
      if !nfeven->nfetransmi
         Mens({"Nota fiscal n∆o transmitida"})
         loop
      end
      if nfeven->CanNot == "S"
         Mens({"Nota Ja Cancelada"})
         loop
      end
      @ 15,26 get cMotivo picture "@k" valid iif(!empty(cMotivo),;
         iif(len(rtrim(cMotivo)) < 15,(Mens({"Caracter m°nimo Ç 15"}),.f.),.t.),.t.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      end
      if !Confirm("Confirma o Cancelamento",2)
         loop
      end
      cDiretorioNFE := rtrim(Sequencia->DirNFE)
      lInternet := Testa_Internet()
      if !lInternet
         loop
      end
        if !StatusServico()
            loop
        endif
      lCancelarNfe := ACBR_NFE_CancelarNfe(cDiretorioNFE,nfeven->ChNfe,cMotivo)
      if !lCancelarNfe
         loop
      end
      while !nfeven->(Trava_Reg())
      end
      nfeven->CanNot     := "S"
      nfeven->NProtca    := cNProt     // ** n£mero do protocolo de cancelando
      nfeven->DhRecbtoca := cDhRecbto  // ** Data e hora do cancelamento
      nfeven->CStatca    := cCStat     // ** c¢digo de retorno da operacao
      nfeven->XMotivoca  := cXMotivo   // ** Mensagem do retorno da operaá∆o
      nfeven->(dbunlock())
      nfeitem->(dbsetorder(1),dbseek(cNumCon))
      while nfeitem->NumCon == cNumCon .and. nfeitem->(!eof())
         while !nfeitem->(Trava_Reg())
         end
         nfeitem->CanNot := "S"
         // ** So atualiza o estoque quanto o ambiente da NFE for 1-produá∆o
         if Sequencia->TipoAMB == "1"
            if Produtos->(dbsetorder(1),dbseek(nfeitem->CodPro))
               if Produtos->CtrlEs == "S"
                  while !Produtos->(Trava_Reg())
                  end
                  Produtos->QteAc01 += nfeitem->QtdPro
                  Produtos->(dbunlock())
               end
            end
         end
         nfeitem->(dbunlock())
         nfeitem->(dbskip())
      end
      Mens({"Nota fiscal cancelada"})
   end
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   end
   FechaDados()
   RestWindow(cTela)
   return

procedure GeraTransNFE
   local getlist := {},cTela := SaveWindow()
   local cNumCon

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !(Abre_Dados(cDiretorio,"Cidades",1,aNumIdx[04],"Cidades",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   if !(Abre_Dados( cDiretorio,"Grupos",1,aNumIdx[21],"Grupos",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   // ** Compras
   if !(Abre_Dados(cDiretorio,"Clientes",1,aNumIdx[05],"Clientes",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   // ** Iten da Compra
   if !(Abre_Dados(cDiretorio,"Vendedor",1,aNumIdx[09],"Vendedor",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   // ** Natureza Fiscal
   if !(Abre_Dados(cDiretorio,"Produtos",1,aNumIdx[06],"Produtos",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   if !(Abre_Dados(cDiretorio,"SubGrupo",1,aNumIdx[22],"SubGrupo",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   if !(Abre_Dados(cDiretorio,"nfeven",1,aNumIdx[40],"nfeven",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   if !(Abre_Dados(cDiretorio,"nfeitem",1,aNumIdx[41],"nfeitem",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   if !(Abre_Dados(cDiretorio,"Natureza",1,aNumIdx[24],"Natureza",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   if !(Abre_Dados(cDiretorio,"SitTrib",1,aNumIdx[23],"SitTrib",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   if !(Abre_Dados(cDiretorio,"Sequenci",0,0,"Sequencia",0,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   if !(Abre_Dados(cDiretorio,"Transpo",1,aNumIdx[20],"Transpo",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   if !(Abre_Dados(cDiretorio,"DupRec",1,aNumIdx[10],"DupRec",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   endif
   /*
	if !(Abre_Dados(cDiretorio,"ibpt",1,aNumIdx[43],"ibpt",1,.f.) == 0)
		FechaDados()
		Msg(.f.)
		return
   endif
   */
   
   Msg(.f.)
   AtivaF4()
   Window(08,09,15,70," Gera/Transmitir/Imprimir NFE ")
   setcolor(Cor(11))
   @ 10,11 say "Nß Controle:"
   @ 11,11 say "    Cliente:"
   @ 12,11 say "       Data:"
   @ 13,11 say "      Valor:"
   while .t.
      cNumCon := Space( 10 )
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,24 get cNumCon picture "@k 9999999999" valid Busca(Zera(@cNumCon),"nfeven",1,,,,{"Controle Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      Clientes->(dbsetorder(1),dbseek(nfeven->CodCli))
      @ 11,24 say nfeven->CodCli+"-"+left(Clientes->NomCli,40)
      @ 12,24 say nfeven->DtaSai
      @ 13,24 say nfeven->TotNot picture "@e 999,999.99"
      if !Confirm("Confirma as informaá‰es")
         loop
      end
      if nfeven->NfeTransmi
         Mens({"Nota fiscal eletrìnica ja transmitida"})
         loop
      end
      lInternet := Testa_Internet()
      if !lInternet
         loop
     end
      cDiretorioNFE := rtrim(Sequencia->DirNFE)
        if !StatusServico()
            loop
        endif
      lGeradaNFE := GeraNFE(cNumCon)
      if lGeradaNFE
         while !nfeven->(Trava_Reg())
         end
         nfeven->nfegerada := .t.
         nfeven->(dbunlock())
      else
         loop
      end
      lTransmitirNFE := TransmitirNFE(,cNumCon)
      if !lTransmitirNFE
         loop
      end
      while !nfeven->(Trava_Reg())
      end
      nfeven->NFeTransmi  := .t.
      nfeven->NRec        := cNRec
      nfeven->CStat       := cCStat
      nfeven->Xmotivo     := cXMotivo
      nfeven->ChNfe       := cChNfe
      nfeven->NProt       := cNProt
      nfeven->DigVal      := cDigVal
      nfeven->(dbunlock())
      nfeven->(dbcommit())
      if lTransmitirNFE
         Imp_DANFE(cDiretorioNFE,nfeven->ChNfe)
         while !nfeven->(Trava_Reg())
         end
         nfeven->NfeImprimi := .t.
         nfeven->(dbunlock())
      end
   end
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   end
   FechaDados()
   RestWindow(cTela)
   return

procedure ImprimiDANFE
   local getlist := {},cTela := SaveWindow()
   local cNumCon,nCopia

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !(Abre_Dados(cDiretorio,"Clientes",1,aNumIdx[05],"Clientes",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   if !(Abre_Dados(cDiretorio,"nfeven",1,aNumIdx[40],"nfeven",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   if !(Abre_Dados(cDiretorio,"Sequenci",0,0,"Sequencia",0,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   Msg(.f.)
   AtivaF4()
   Window(08,09,15,70," Imprimir NFE ")
   setcolor(Cor(11))
   @ 10,11 say "Nß Controle:"
   @ 11,11 say "    Cliente:"
   @ 12,11 say "       Data:"
   @ 13,11 say "      Valor:"
   while .t.
      cNumCon := Space( 10 )
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,24 get cNumCon picture "@k 9999999999" valid Busca(Zera(@cNumCon),"nfeven",1,,,,{"Controle Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      Clientes->(dbsetorder(1),dbseek(nfeven->CodCli))
      @ 11,24 say nfeven->CodCli+"-"+Clientes->NomCli
      @ 12,24 say nfeven->DtaSai
      @ 13,24 say nfeven->TotNot picture "@e 999,999.99"
      if !nfeven->nfegerada
         Mens({"Nota fiscal eletrìnica n∆o gerada"})
         loop
      end
      if !nfeven->NfeTransmi
         Mens({"Nota fiscal eletrìnica n∆o transmitida"})
         loop
      end
      if nfeven->NfeImprimi
         If Aviso_1(17,,22,,[AtenáÑo!],[DANFE ja impresso, imprimir novamente ?], { [  ^Sim  ], [  ^N∆o  ] }, 1, .t. ) == 2
            loop
         end
      else
         if !Confirm("Confirma a Impress∆o")
            loop
         end
      end
      cDiretorioNFE := rtrim(Sequencia->DirNFE)
      Imp_DANFE(cDiretorioNFE,nfeven->ChNfe)
      
      // **ACBR_NFE_ImprimirDanfePDF(rtrim(Sequencia->DirNFE),nfeven->ChNfe)
   end
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   end
   FechaDados()
   RestWindow(cTela)
   return

procedure EnviarEmailNFE
	local getlist := {},cTela := SaveWindow()
	local cNrNota,cEmail,cAssunto

	Msg(.t.)
	Msg("Aguarde : Abrindo o Arquivo")
	if !(Abre_Dados(cDiretorio,"Clientes",1,aNumIdx[05],"Clientes",1,.f.) == 0)
		FechaDados()
		Msg(.f.)
		return
	endif
	if !(Abre_Dados(cDiretorio,"nfeven",1,aNumIdx[40],"nfeven",1,.f.) == 0)
		FechaDados()
		Msg(.f.)
		return
	endif
	if !(Abre_Dados(cDiretorio,"Sequenci",0,0,"Sequencia",0,.f.) == 0)
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
		@ 10,24 get cNrNota picture "@k 999999999" valid Busca(Zera(@cNrNota),"nfeven",3,,,,{"Nota Fiscal nao Cadastrada"},.f.,.f.,.f.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		Clientes->(dbsetorder(1),dbseek(nfeven->CodCli))
		if !nfeven->nfegerada
			Mens({"Nota fiscal eletrìnica n∆o gerada"})
 			loop
		endif
		if !nfeven->NfeTransmi
 			Mens({"Nota fiscal eletrìnica n∆o transmitida"})
			loop
		endif
		cEmail := Clientes->EmaCli+space(20)
		@ 11,24 say nfeven->CodCli+"-"+Clientes->NomCli
		@ 12,24 say nfeven->DtaSai
		@ 13,24 say nfeven->TotNot picture "@e 999,999.99"
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
        if !StatusServico()
            loop
        endif
		Msg(.t.)
		Msg("Aguarde: Enviando Email")
		ACBR_NFE_EnviarEMail(rtrim(Sequencia->DirNFE),cEmail,NFEven->ChNfe,1,cAssunto)
		Msg(.f.)
		cRetorno := Mon_Ret(rtrim(Sequencia->DirNFE)+"\sainfe.txt")
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
   end
   FechaDados()
   RestWindow(cTela)
   return
   
procedure ConsultarNFeSEFAZ
	local getlist := {},cTela := SaveWindow()
	local cNrNota,cStatus

	Msg(.t.)
	Msg("Aguarde : Abrindo o Arquivo")
	if !(Abre_Dados(cDiretorio,"Clientes",1,aNumIdx[05],"Clientes",1,.f.) == 0)
		FechaDados()
		Msg(.f.)
		return
	endif
	if !(Abre_Dados(cDiretorio,"nfeven",1,aNumIdx[40],"nfeven",1,.f.) == 0)
		FechaDados()
		Msg(.f.)
		return
	endif
	if !(Abre_Dados(cDiretorio,"Sequenci",0,0,"Sequencia",0,.f.) == 0)
		FechaDados()
		Msg(.f.)
		return
	endif
	Msg(.f.)
	AtivaF4()
	Window(08,09,20,70," Consultar NFe na Sefaz ")
	setcolor(Cor(11))
	@ 10,11 say "Nr. da Nota:"
	@ 11,11 say "    Cliente:"
	@ 12,11 say "       Data:"
	@ 13,11 say "      Valor:"
	@ 14,10 say replicate(chr(196),60)
	@ 15,11 say "    Retorno:"
	@ 16,11 say "     Status:"
	@ 17,11 say "  Protocolo:"
	@ 18,11 say "  Data/Hora:"
	do while .t.
		cNrNota  := Space( 9)
		cEmail   := space(60)
		cAssunto := space(60)
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 10,24 get cNrNota picture "@k 999999999" valid Busca(Zera(@cNrNota),"nfeven",3,,,,{"Nota Fiscal nao Cadastrada"},.f.,.f.,.f.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		Clientes->(dbsetorder(1),dbseek(nfeven->CodCli))
		if !nfeven->nfegerada
			Mens({"Nota fiscal eletrìnica n∆o gerada"})
 			loop
		endif
		if !nfeven->NfeTransmi
 			Mens({"Nota fiscal eletrìnica n∆o transmitida"})
			loop
		endif
		cEmail := Clientes->EmaCli+space(20)
		@ 11,24 say nfeven->CodCli+"-"+Clientes->NomCli
		@ 12,24 say nfeven->DtaSai
		@ 13,24 say nfeven->TotNot picture "@e 999,999.99"
		if !Confirm("Confirma as Informacoes")
			loop
		endif
		if !Testa_Internet()
			Mens({"Sem acesso a internet","Carta de Correcao nao pode enviada"})
			loop
		endif
        if !StatusServico()
            loop
        endif
        
		ACBR_NFE_ConsultarNFe(rtrim(Sequencia->DirNFE),NFEven->ChNfe)
		Msg(.t.)
		Msg("Aguarde: Consultando NFe na SEFAZ")
		cRetorno := Mon_Ret(rtrim(Sequencia->DirNFE)+"\sainfe.txt")
		if !Men_Ok(cRetorno)
			Msg(.f.)
			Mens({"Erro na consulta da NFe na SEFAZ","Favor tentar novamente"})
			loop
		endif
		Msg(.f.)
		cCStat    := RetornoSEFAZ("CStat",rtrim(Sequencia->DirNFE)+"\sainfe.txt")
		cNProt    := RetornoSEFAZ("NProt",rtrim(Sequencia->DirNFE)+"\sainfe.txt")
		cDhRecbto := RetornoSEFAZ("DhRecbto",rtrim(Sequencia->DirNFE)+"\sainfe.txt")
		@ 15,24 say space(10)
		@ 15,24 say substr(cRetorno,1,at(":",cRetorno))
		@ 16,24 say cCStat
		@ 17,24 say cNProt
		@ 18,24 say cDhRecbto
		Mens({"Consultar realizada com sucesso"})		
		if cStatus == "100"
			do while !nfeven->(Trava_Reg())
			enddo
			nfeven->NFeTransmi  := .t.
			nfeven->NRec        := cNProt
			nfeven->CStat       := cCStat
			nfeven->NProt       := cNProt
			nfeven->(dbunlock())
		endif
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
      Mens({"Erro no cadastro do cliente","N£mero do endereáo esta vazio"})
      return(.f.)
   end
   Cidades->(dbsetorder(1),dbseek(Clientes->CodCid))
   cEstCli := Cidades->EstCid
   cCodNat := Clientes->CodNat
   /*
   if empty(Cidades->CodMun)
      Mens({"Erro no cadastro da cidade","Codigo do munic°pio do IBGE n∆o cadastrado"})
      return(.f.)
   end
   if empty(Clientes->CodNat)
      Mens({"Natureza Fiscal do Cliente N∆o Cadastrada","Favor Verificar"})
      return(.f.)
   end
   */
   
   if !Natureza->(dbsetorder(1),dbseek(Clientes->CodNat))
      Mens({"Natureza Fiscal Nao Cadastrada"})
      return(.f.)
   end
   
   @ 06,11 say cCodNat+"-"+left(Natureza->Descricao,30)
   return(.t.)

Function nfeitem( Pos_H, Pos_V, Ln, Cl, nTecla )
   Local Laco, Verif := .f.

   If nTecla == K_ENTER
      // ** Codigo do Produto
      If Pos_H = 1
         cCampo := aCodPro[Pos_V]
         @ Ln,Cl get cCampo picture "@k 999999" when Rodape("Esc-Encerra | F4-Produtos") valid Busca(Zera(@cCampo),"Produtos",1,,,,{"Produto Nao Cadastrado"},.f.,.f.,.f.) .and. vCodigo(cCampo,Pos_V)
         setcursor(SC_NORMAL)
         read
         setcursor(SC_NONE)
         if !(lastkey() == K_ESC)
            Rodape("Esc-Encerra")
            aCodPro[Pos_V] := cCampo
            aDesPro[pos_v] := left(Produtos->DesPro,23)+"-> "+str(Produtos->QteEmb,3)+" x "+Produtos->EmbPro
            aPcoPro[Pos_V] := Produtos->PcoCal
            aCST[Pos_V] := Produtos->Cst
			if Natureza->Local == "F"
				aAliSai[Pos_V] := Produtos->AliFor
			elseif Natureza->Local == "D" 
				aAliSai[Pos_V] := Produtos->AliDtr
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
               @ 22,59 say Soma_Veto2(aTotPro) picture "@e 999,999,999.99"
               keyboard chr(K_RIGHT)+chr(K_ENTER)
               return(2)
            endif
         endif

      // ** Valor Unit†rio
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
               @ 22,59 say Soma_Veto2(aTotPro) picture "@e 999,999,999.99"
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

      // ** CST CÛdigo de SituaÁ„o tribut·ria
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
            end
         end

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
             Aviso_1( 10,, 15,, [AtenáÑo!], [NÑo sÑo permitidos quantidades ou preáos zerados.], { [  ^Ok!  ] }, 1, .t., .t. )
             Return( 1 )
          ElseIf Empty( aCodPro[Laco] )
             ++Brancos
          EndIf
      Next
      If Brancos = N_Itens
         Aviso_1( 10,, 15,, [AtenáÑo!], [NÑo Ç permitido gravar nota sem °tens.], { [  ^Ok!  ] }, 1, .t., .t. )
         Return( 1 )
      EndIf
      Return( 0 )
   ElseIf nTecla == K_F4
         N_Itens := Len( aCodPro ) + 1

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

         N_Itens := Len( aCodPro ) - 1
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

   nfeitem->(dbsetorder(1),dbseek(cNumCon))
   while nfeitem->NumCon == cNumCon .and. nfeitem->(!eof())
      Produtos->(dbsetorder(1),dbseek(nfeitem->CodPro))
      aadd(aVetor1,nfeitem->CodPro)
      aadd(aVetor2,left(Produtos->DesPro,23)+"-> "+str(Produtos->QteEmb,3)+" x "+Produtos->EmbPro)
      aadd(aVetor3,nfeitem->QtdPro)
      aadd(aVetor4,nfeitem->PcoPro)
      aadd(aVetor5,nfeitem->QtdPro*nfeitem->PcoPro)
      nfeitem->(dbskip())
   end
   aCampo   := { "aVetor1" ,"aVetor2"   ,"aVetor3"   ,"aVetor4"     ,"aVetor5"}
   aTitulo  := { "C¢digo"  ,"DescriáÑo ","Qtde."     ,"Páo. Venda"  ,"Total" }
   aMascara := {"@k 999999","@!S40"     ,"@E 999,999","@E 99,999.99","@E 9,999,999.99"}
   cTela := SaveWindow()
   Rodape("Esc-Encerra")
   Window(10,00,23,79,chr(16)+" Itens da Nota "+chr(17))
   Edita_Vet(11,01,22,78,aCampo,aTitulo,aMascara, [XAPAGARU],,.t.)
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
    if !OpenNfeVen()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenNfeItem()
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
    Msg(.f.)
    return(.t.)

// ** Fim do Arquivo.
