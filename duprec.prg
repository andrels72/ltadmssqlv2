/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.00
 * Identificacao: Manutencao de Duplicatas a Receber
 * Prefixo......: LtAdm
 * Programa.....: DupRec.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 03 de Setembro de 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.CH"       // Inclusao do Arquivo Header Padrao
#include "inkey.CH"   // Header para manipulacao de Teclas
#include "setcurs.ch"
#define CRLF chr(K_ENTER)+chr(K_CTRL_ENTER)

procedure ConDupRec(lAbrir,lRetorno)
   local oBrow,oCol,nTecla,lFim := .F.,aRect,cTela := SaveWindow(),aTab
   local nCursor := setcursor(),cCor := setcolor(),cDados1,cDados2
   local nLinha1 := 02,nColuna1 := 00,nLinha2 := maxrow()-1,nColuna2 := maxcol() - 1
   private lRefresh := .f.

   if lAbrir
      Msg(.t.)
      Msg("Aguarde : Abrindo o Arquivo")
      if !OpenClientes()
         FechaDados()
         Msg(.f.)
         return
      endif
      if !OpenCidades()
         FechaDados()
         Msg(.f.)
         return
      endif
      if !OpenDupRec()
         FechaDados()
         Msg(.f.)
         return
      endif
      if !OpenBxaDupRe()
         FechaDados()
         Msg(.f.)
         return
      endif
      Msg(.f.)
   else
      setcursor(SC_NONE)
   end
   select DupRec
   set order to 1
   goto top
   Rodape("Esc-Encerra")
   setcolor(cor(5))
    nLinha1  := 02
    nColuna1 := 00
    nLinha2  := 33
    nColuna2 := 100
   Window(nLinha1,nColuna1,nLinha2,nColuna2,"> Consulta de Duplicatas a Receber <")
   oBrow := TBrowseDB(nLinha1+1,nColuna1+1,nLinha2-4,nColuna2-1)
   oBrow:headSep := chr(194)+chr(196)
   oBrow:colSep  := chr(179)
   oBrow:footSep := chr(193)+chr(196)
   oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)
   oColuna := TBColumnNew("Codigo" ,{|| DupRec->CodCli})
   oColuna:colorblock := {|| iif( !empty(DupRec->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   // *-------------------------------------------------------------------------
   oColuna := TBColumnNew("Cliente" ,{|| Clientes->(dbsetorder(1),dbseek(DupRec->CodCli),Clientes->ApeCli)})
   oColuna:colorblock := {|| iif( !empty(DupRec->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   // *-------------------------------------------------------------------------
   oColuna := tbcolumnnew("Duplicata",{|| DupRec->NumDup})
   oColuna:colorblock := {|| iif( !empty(DupRec->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   // *-------------------------------------------------------------------------
   oColuna := tbcolumnnew("Emissao",{|| DupRec->DtaEmi })
   oColuna:colorblock := {|| iif( !empty(DupRec->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   // *-------------------------------------------------------------------------
   oColuna := tbcolumnnew("Vencimento",{|| DupRec->DtaVen })
   oColuna:colorblock := {|| iif( !empty(DupRec->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   // *-------------------------------------------------------------------------
   oColuna := tbcolumnnew("Valor",{|| transform(DupRec->ValDup,"@e 999,999.99") })
   oColuna:colorblock := {|| iif( !empty(DupRec->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   // *-------------------------------------------------------------------------
   oColuna := tbcolumnnew("Pagamento",{|| DupRec->DtaPag })
   oColuna:colorblock := {|| iif( !empty(DupRec->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   // *-------------------------------------------------------------------------
   oColuna := tbcolumnnew("Valor Pago",{|| transform(DupRec->ValPag,"@e 999,999.99")})
   oColuna:colorblock := {|| iif( !empty(DupRec->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   // *-------------------------------------------------------------------------
   oColuna := tbcolumnnew("Juros",{|| transform(DupRec->ValJur,"@e 999,999.99")})
   oColuna:colorblock := {|| iif( !empty(DupRec->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   // *-------------------------------------------------------------------------
   oColuna := tbcolumnnew("Desconto",{|| transform(DupRec->ValDes,"@e 999,999.99")})
   oColuna:colorblock := {|| iif( !empty(DupRec->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   aTab := TabHNew(nLinha2-3,nColuna1+1,nColuna2-1,setcolor(cor(28)),1)
   TabHDisplay(aTab)
   setcolor(Cor(26))
   scroll(nLinha2-2,nColuna1+1,nLinha2-1,nColuna2-1,0)
	Centro(nLinha2-1,nColuna1+1,nColuna2-1,"F2-Visualiza Baixa")
	while (! lFim)
		do while ( ! oBrow:stabilize() )
			nTecla := INKEY()
         	if ( nTecla != 0 )
            	exit
         	endif
      	enddo
      	if ( oBrow:stable )
         	if ( oBrow:hitTop .OR. oBrow:hitBottom )
            	tone(1200,1)
         	endif
         	nTecla := INKEY(0)
      	endif
      	if !TBMoveCursor(nTecla,oBrow)
         	if nTecla == K_ESC   // ESC pressionado - Encerra a Consulta
            	lFim := .T.
         	elseif nTecla == K_ENTER
            	if !lAbrir .and. lRetorno
               		cDados1 := DupRec->CodCli
               		cDados2 := DupRec->NumDup
               		keyboard (cDados1)+chr(K_ENTER)+(cDados2)+chr(K_ENTER)
               		lFim := .t.
            	endif
         	elseif nTecla == K_F2
            	VerBaixa(DupRec->CodCli,DupRec->NumDup)
         	endif
		elseif nTecla == K_RIGHT
			tabHupdate(aTab,obrow:colpos,obrow:colcount,.t.)
		elseif nTecla == K_LEFT
			tabHupdate(aTab,obrow:colpos,obrow:colcount,.t.)
		endif
	enddo
	if lAbrir
		FechaDados()
	else
		setcursor(nCursor)
      	setcolor(cCor)
   	endif
   	RestWindow(cTela)
   	return
// ****************************************************************************
procedure IncDupRec
   local getlist := {},cTela := SaveWindow()
   local nIdCliente,cDuplicata,dEmissao,dVencimento,nValor,cObservacao
   local cQuery,oQuery

   AtivaF4()
   TelDupRec(1,1)
   do while .t.
      nIdCliente := 0
      cDuplicata := space(15)
      dEmissao := ctod(space(08))
      dVencimento := ctod(space(08))
      nValor := 0.00
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 09,23 get nIdCliente picture "@k 9999";
      			when Rodape("Esc-Encerra | F4-Clientes");
               valid SqlBusca("id = "+NumberToSql(nIdCliente),"apecli",@oQuery,;
                     "administrativo.clientes",row(),col()+1,{"apecli",0},{"Cliente nÆo cadastrado"},.f.)
      @ 10,23 get cDuplicata picture "@k!";
               when Rodape("Esc-Encerra");
                  valid NoEmpty(cDuplicata) .and. ;
                  SqlBusca("idcliente = "+NumberToSql(nIdCliente)+" AND duplicata ="+StringToSql(cDuplicata),"idcliete",;
                     @oQuery,"administrativo.clientes",,,,{"Duplicata j  cadastrada"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      @ 11,23 get dEmissao picture "@k"
      @ 12,23 get dVencimento picture "@k"
      @ 13,23 get nValor picture "@ke 999,999.99"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      endif
      if !Confirm("Confirma a Inclus’o")
         loop
      endif
      cQuery := "INSERT INTO financeiro.duplicatas_areceber (idcliente,duplicata,emissao,vencimento,valor,observaocao) "
      cQuery += "VALUES ("+NumberToSql(nIdCliente)+","+StringToSql(cDuplicata)+","+DateToSql(dEmissao)+","+;
         DateToSql(dVencimento)+","+NumberToSql(nValor,15,2)+","+StringToSql(cObservacao)+")"
      Msg(.t.)
      Msg("Aguarde: Gravando as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar "},"sqlerro")
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop
      endif
      oServer:Commit()
      oQuery:Close()
      MSg(.f.)
   enddo 
   DesativaF4()
   RestWindow(cTela)
return
// ****************************************************************************
procedure AltDupRec
   local getlist := {},cTela := SaveWindow()
   local cCodCli,cNumDup,dDtaEmi,dDtaVen,nValDup
   private xBaixa := .t.
   
   
	if !AbrirArquivos()
		return
	endif
   AtivaF4()
   TelDupRec(2,1)
   while .t.
      cCodCli    := space(04)
      cNumDup    := space(16)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 09,23 get cCodCli picture "@k 9999";
      			when Rodape("Esc-Encerra | F4-Duplicatas");
      			valid Busca(Zera(@cCodCli),"Clientes",1,row(),col(),"'-'+Clientes->ApeCli",{"Cliente Nao Cadastro"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      @ 10,23 get cNumDup picture "@k!";
      			when Rodape("Esc-Encerra");
      			valid vDupRec(@cNumDup,cCodCli) .and. Busca(cCodCli+cNumDup,"DupRec",1,,,,{"Duplicata Nao Cadastrada"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      end
      if !empty(DupRec->DtaPag)
         Mens({"Duplicata Ja Baixada"})
         loop
      end
      if DupRec->Pedido == "S"
         Mens({"Duplicata Pertence ao Pedido","Alteracao Nao Permitida"})
         loop
      end
      dDtaEmi    := DupRec->DtaEmi
      dDtaVen    := DupRec->DtaVen
      nValDup    := DupRec->ValDup
      @ 11,23 get dDtaEmi picture "@k"
      @ 12,23 get dDtaVen picture "@k"
      @ 13,23 get nValDup picture "@ke 999,999.99"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      endif
      if !Confirm("Confirma a AlteraÎ’o")
         loop
      endif
      do while DupRec->(!Trava_Reg())
      enddo
      DupRec->DtaEmi    := dDtaEmi
      DupRec->DtaVen    := dDtaVen
      DupRec->ValDup    := nValDup
      DupRec->(dbcommit())
      DupRec->(dbunlock())
      Grava_Log(cDiretorio,"Dupl.Receber|Alterar|Duplicata "+cNumDup,Clientes->(recno()))
   end
   DesativaF4()
   dbcommitall()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
procedure ExcDupRec
   local getlist := {},cTela := SaveWindow()
   local cCodCli,cNumDup
   
	if !AbrirArquivos()
		return
	endif
   AtivaF4()
   TelDupRec(2,1)
   while .t.
      cCodCli    := space(04)
      cNumDup    := space(16)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 09,23 get cCodCli picture "@k 9999";
      			when Rodape("Esc-Encerra | F4-Duplicatas");
      			valid Busca(Zera(@cCodCli),"Clientes",1,09,27,"'-'+Clientes->ApeCli",{"Cliente Nao Cadastro"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      @ 10,23 get cNumDup picture "@k!";
      			when Rodape("Esc-Encerra");
      			valid vDupRec(@cNumDup,cCodCli) .and. Busca(cCodCli+cNumDup,"DupRec",1,,,,{"Duplicata Nao Cadastrada"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      endif
      if !empty(DupRec->DtaPag)
         Mens({"Duplicata Ja Baixada"})
         loop
      endif
      if DupRec->Pedido == "S"
         Mens({"Duplicata Pertence ao Pedido","Alteracao Nao Permitida"})
         loop
      endif
      @ 11,23 say DupRec->DtaEmi picture "@k"
      @ 12,23 say DupRec->DtaVen picture "@k"
      @ 13,23 say DupRec->ValDup picture "@ke 999,999.99"
      if !Confirm("Confirma a Exclus’o",2)
         loop
      endif
      while !DupRec->(Trava_Reg())
      enddo
      DupRec->(dbdelete())
      DupRec->(dbcommit())
      DupRec->(dbunlock())
      Grava_Log(cDiretorio,"Dupl.Receber|Excluir|Duplicata "+cNumDup,Clientes->(recno()))
   enddo
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
procedure BxaDupRec  // ** Baixa da Duplicata
   local getlist := {},cTela := SaveWindow()
   local cCodCli,nValPag,dDtaPag,nValJur,nValDes,cObsBai,cTriPli
   local cTipoCobra,aCampo := {},aTitulo := {},aMascara := {},cLanCxa,nI
   private aTipoCo := {},aCodBco := {},aNumAge := {},aNumCon := {},aNumChq := {}
   private aDtaVen := {},aValPag := {},cNumDup,xBaixa := .t.

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
	if !OpenClientes()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenCidades()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenDupRec()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenBxaDupRe()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenBanco()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenCheques()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenCaixa()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenMovCxa()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenHistCxa()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenNatureza()
		FechaDados()
		Msg(.f.)
		return
	endif
    if !OpenVendedor()
        FechaDados()
        msg(.f.)
        return
    endif
	if !OpenSequencia()
		FechaDados()
		Msg(.f.)
		return
	endif
   Msg(.f.)
   AtivaF4()
   restore from (Arq_Sen)+"r" additive
   TelDupRec(4,2)
   while .t.
      cCodCli := space(04)
      cNumDup := space(16)
      nValPag := 0
      dDtaPag := date()
      nValJur := 0
      nValDes := 0
      cObsBai := space(50)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 04,14 get cCodCli picture "@k 9999";
      			when Rodape("Esc-Encerra | F4-Clientes");
      			valid Busca(Zera(@cCodCli),"Clientes",1,row(),col(),"'-'+Clientes->ApeCli",{"Cliente Nao Cadastro"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      @ 05,14 get cNumDup picture "@k!";
      			when Rodape("Esc-Encerra");
      			valid xApagar(@cNumDup,cCodCli) .and. Busca(cCodCli+cNumDup,"DupRec",1,,,,{"Duplicata Nao Cadastrada"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      endif
      @ 06,14 say DupRec->DtaEmi
      @ 06,38 say DupRec->DtaVen
      @ 06,60 say DupRec->ValDup picture "@ke 999,999.99"
      @ 07,14 get nValJur picture "@ke 999,999.99"
      @ 08,14 get nValDes picture "@ke 999,999.99" valid vDesc(nValJur,nValDes,DupRec->ValDup,08,38)
      @ 09,14 get nValPag picture "@ke 999,999.99" valid iif(lastkey() == K_UP,.t.,NoEmpty(nValPag))
      @ 09,38 get dDtaPag picture "@k" valid iif(lastkey() == K_UP,.t.,NoEmpty(dDtaPag) .and. vDataMov(dDtaPag))
      @ 10,14 get cObsBai picture "@k!"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      end
      lLimpa := .t.
      aTipoCo  := {}
      aCodBco  := {}
      aNumAge  := {}
      aNumCon  := {}
      aNumChq  := {}
      aDtaVen  := {}
      aValPag  := {}
      aadd(aTipoCo,space(01))
      aadd(aCodBco,space(03))
      aadd(aNumAge,space(04))
      aadd(aNumCon,space(15))
      aadd(aNumChq,space(10))
      aadd(aDtaVen,ctod(space(08)))
      aadd(aValPag,0)
      // *------------------------------------
      aCampo   := {"aTipoCo","aCodBco","aNumAge","aNumCon" ,"aNumChq"  ,"aDtaVen"   ,"aValPag"}
      aTitulo  := {"Tipo"   ,"Banco"  ,"Agencia","Nõ Conta","Nõ Cheque","Vencimento","Vlr. Pago"}
      aMascara := {"@!"     ,"@k 999" ,"@!"     ,"@!"      ,"@!"       ,"@!"        ,"@e 999,999.99"}
      Rodape("F2-Confirma | F4-Inclui | F6-Exclui | F8-Abandona")
      lGrava := .f.
      while .t.
         Edita_Vet(12,01,32,78,aCampo,aTitulo,aMascara,"vBaixa",,.t.,,2)
         if lastkey() == K_F2
            if Soma_Vetor(aValPag) < nValPag
               If Aviso_1(17,,22,,"Aten‡Æo!","Valor Total dos Lancamentos Menor que o Total da Duplicata, continuar?",{"  ^Sim  ","  ^NÆo  "},2,.t.) = 2
                  loop
               end
            end
            if !Confirm("Confirma o(s) Lancamento(s) para a Baixa")
               loop
            end
            lGrava := .t.
            exit
         elseif lastkey() == K_F8
            exit
         end
      end
      if !lGrava
         loop
      end
      while !DupRec->(Trava_Reg())
      end
      DupRec->ValPag := nValPag
      DupRec->DtaPag := dDtaPag
      DupRec->ValJur := nValJur
      DupRec->ValDes := nValDes
      DupRec->ObsBai := cObsBai
      DupRec->(dbcommit())
      DupRec->(dbunlock())
      Grava_Log(cDiretorio,"Dupl.Receber|Baixa|Duplicata "+cNumDup,Clientes->(recno()))
        if nValPag < ((DupRec->ValDup+nValJur)-nValDes)
            Mens({"Valor pago menor","Ser  gerada triplicata"})
        
         //if Aviso_1(09,,14,,"AtenÎ"o!","Valor Pago Menor. Gerar Triplicata ?",{ "  ^Sim  ","  ^N"o  "},1,.t.) == 1
         if .t.
            dDtaEmi    := DupRec->DtaEmi
            dDtaVen    := DupRec->DtaVen
            nValDup    := (DupRec->ValDup+nValJur)-nValDes
            cTipoCobra := DupRec->TipoCobra
            if right(alltrim(cNumDup),1) $ "0123456789"
               do while !DupRec->(Adiciona())
               enddo
               DupRec->CodCli    := cCodCli
               DupRec->NumDup    := alltrim(cNumDup)+"A"
               DupRec->TipoCobra := cTipoCobra
               DupRec->DtaEmi    := dDtaEmi
               DupRec->DtaVen    := dDtaVen
               DupRec->ValDup    := nValDup-nValPag
               DupRec->Pedido    := "S"
               DupRec->(dbcommit())
               DupRec->(dbunlock())
               cTriPli := DupRec->NumDup
            else
               nI := 1
               do while .t.
                  if !DupRec->(dbsetorder(1),dbseek(cCodCli+left(alltrim(cNumDup),len(alltrim(cNumDup))-1)+chr(asc(right(alltrim(cNumDup),1))+nI)))
                     do while !DupRec->(Adiciona())
                     enddo
                     DupRec->CodCli    := cCodCli
                     DupRec->NumDup    := left(alltrim(cNumDup),len(alltrim(cNumDup))-1)+chr(asc(right(alltrim(cNumDup),1))+nI)
                     DupRec->TipoCobra := cTipoCobra
                     DupRec->DtaEmi    := dDtaEmi
                     DupRec->DtaVen    := dDtaVen
                     DupRec->ValDup    := nValDup - nValPag
                     DupRec->Pedido    := "S"
                     DupRec->(dbcommit())
                     DupRec->(dbunlock())
                     cTriPli := DupRec->NumDup
                     exit
                  else
                     nI += 1
                  endif
               enddo
            endif
            if DupRec->(dbsetorder(1),dbseek(cCodCli+cNumDup))
               do while !DupRec->(Trava_Reg())
               enddo
               DupRec->TriPlicata := cTriPli
               DupRec->(dbunlock())
            endif
         endif
      endif
      for nI := 1 to len(aTipoCo)
         if !empty(aTipoCo[nI])
            do while !BxaDupRe->(Adiciona())
            enddo
            cLanCxa := space(06)
            // ** Gera o Lancamento no Movimento do Caixa
            if !empty(aValPag[nI])
               LancMovCxa(@cLanCxa,dDtaPag,cRCodCxa,cRCodHis,aNumChq[nI],aCodBco[nI],aNumAge[nI],aNumCon[nI],aValPag[nI],aTipoCo[nI])
            end
            BxaDupRe->CodCli    := cCodCli
            BxaDupRe->NumDup    := cNumDup
            BxaDupRe->CodBco    := aCodBco[nI]
            BxaDupRe->NumAge    := aNumAge[nI]
            BxaDupRe->NumCon    := aNumCon[nI]
            BxaDupRe->NumChq    := aNumChq[nI]
            BxaDupRe->TipoCobra := aTipoCo[nI]
            BxaDupRe->DtaVen    := aDtaVen[nI]
            BxaDupRe->ValPag    := aValPag[nI]
            BxaDupRe->DtaPag    := dDtaPag  //aDtaPag[nI]
            BxaDupRe->LanCxa    := cLanCxa
            BxaDupRe->(dbcommit())
            BxaDupRe->(dbunlock())
            Grava_Log(cDiretorio,"Dupl.Receber|Baixa|Cliente "+cCodCli+" Duplicata "+cNumDup,BxaDupRe->(recno()))
         end
      next
      iRecibo(cCodCli,cNumDup)
   end
   DesativaF4()
   dbcommitall()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
procedure ImpRecibo  // ** Impress’o do Recibo
   local getlist := {},cTela := SaveWindow()
   local cNumDup,nI

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
	if !OpenClientes()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenCidades()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenDupRec()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenBxaDupRe()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenBanco()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenCheques()
		FechaDados()
		Msg(.f.)
		return
	endif
    IF !OpenSequencia()
        FechaDados()
        Msg(.f.)
        return
    endif
   Msg(.f.)
   AtivaF4()
   Window(09,23,13,60," ImpressÆo do recibo ")
   setcolor(Cor(11))
   @ 11,25 say "N§ da Duplicata:"
   while .t.
      cNumDup := space(16)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,42 get cNumDup picture "@k!";
      			when Rodape("Esc-Encerra | F4-Duplicatas");
      			valid Busca(cNumDup,"DupRec",2,,,,{"Duplicata Nao Cadastrada"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      if empty(DupRec->DtaPag)
         Mens({"Duplicata Nao Baixada"})
         loop
      endif
      iRecibo(DupRec->CodCli,cNumDup)
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
procedure CbxDupRec  // Cancelamento da Baixa de Duplicata
   local getlist := {},cTela := SaveWindow()
   local cCodCli,cNumDup,nValPag,dDtaPag,nValJur,nValDes,cObsBai,cLanCxa,nI
   private xBaixa := .t.

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
	if !OpenClientes()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenCidades()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenDupRec()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenBxaDupRe()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenBanco()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenCheques()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenCaixa()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenMovCxa()
		FechaDados()
		Msg(.f.)
		return
	endif
	if !OpenHistCxa()
		FechaDados()
		Msg(.f.)
		return
	endif
   Msg(.f.)
   AtivaF4()
   TelDupRec(5,3)
   while .t.
      cCodCli := space(04)
      cNumDup := space(16)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 04,14 get cCodCli picture "@k 9999";
      		when Rodape("Esc-Encerra | F4-Clientes");
      		valid Busca(Zera(@cCodCli),"Clientes",1,row(),col(),"'-'+Clientes->ApeCli",{"Cliente Nao Cadastro"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      @ 05,14 get cNumDup picture "@k!" when Rodape("Esc-Encerra") valid xApago(@cNumDup,cCodCli) .and. Busca(cCodCli+cNumDup,"DupRec",1,,,,{"Duplicata Nao Cadastrada"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      end
      // ** Verifica se o movimento do caixa esta aberto
      if !vDataMov(DupRec->DtaPag)
         loop
      end
      cLanCxa := DupRec->LanCxa
      Banco->(dbsetorder(1),dbseek(DupRec->CodBco+DupRec->NumAge+DupRec->NumCon))
      @ 05,38 say DupRec->TipoCobra
      MenuArray(DupRec->TipoCobra,{{"1","Dinheiro        "},{"2","Duplicata       "},{"3","Cheque          "},{"4","Nota Promissoria"},{"5","Nota de Debito  "}},05,40,05,40)
      @ 06,14 say DupRec->CodBco
      @ 06,38 say DupRec->NumAge
      @ 06,60 say DupRec->NumCon
      @ 07,14 say DupRec->NumChq
      @ 07,38 say Banco->NomCon
      @ 08,14 say DupRec->DtaEmi
      @ 08,38 say DupRec->DtaVen
      @ 08,60 say DupRec->ValDup picture "@ke 999,999.99"
      @ 09,14 say DupRec->ValJur picture "@ke 999,999.99"
      @ 10,14 say DupRec->ValDes picture "@ke 999,999.99"
      @ 11,14 say DupRec->ValPag picture "@ke 999,999.99"
      @ 11,38 say DupRec->DtaPag picture "@k"
      @ 12,14 say DupRec->ObsBai picture "@k!"
      if !Confirm("Confirma o Cancelamento da Baixa",2)
         loop
      end
      // ** Se for triplicata
      if !empty(subst(cNumDup,13,1))
         if MovCaixa->(dbsetorder(1),dbseek(DupRec->LanCxa))
            if Caixa->(dbsetorder(1),dbseek(MovCaixa->CodCaixa))
               while !Caixa->(Trava_Reg())
               end
               Caixa->SldCaixa -= MovCaixa->Valor
               Caixa->(dbcommit())
               Caixa->(dbunlock())
            end
            while !MovCaixa->(Trava_Reg())
            end
            MovCaixa->(dbdelete())
            MovCaixa->(dbcommit())
            MovCaixa->(dbunlock())
         end
         while !DupRec->(Trava_Reg())
         end
         DupRec->ValPag := 0
         DupRec->DtaPag := ctod(space(08))
         DupRec->ValJur := 0
         DupRec->ValDes := 0
         DupRec->ObsBai := space(50)
         DupRec->(dbcommit())
         DupRec->(dbunlock())
         if BxaDupRe->(dbsetorder(1),dbseek(cCodCli+cNumDup))
            while BxaDupRe->CodCli == cCodCli .and. BxaDupRe->NumDup == cNumDup .and. BxaDupRe->(!eof())
               while !BxaDupRe->(Trava_Reg())
               end
               if BxaDupRe->TipoCobra == "2" // Cheque
                  if Cheques->(dbsetorder(1),dbseek(BxaDupRe->CodBco+BxaDupRe->NumAge+BxaDupRe->NumCon+BxaDupRe->NumChq))
                     while !Cheques->(Trava_Reg())
                     end
                     Cheques->(dbdelete())
                     Cheques->(dbunlock())
                  end
               end
               BxaDupRe->(dbdelete())
               BxaDupRe->(dbcommit())
               BxaDupRe->(dbunlock())
               BxaDupRe->(dbskip())
            end
         end
      else
         while DupRec->CodCli == cCodCli .and. left(DupRec->NumDup,12) == left(cNumDup,12) .and. DupRec->(!eof())
            if BxaDupRe->(dbsetorder(1),dbseek(cCodCli+cNumDup))
               while BxaDupRe->CodCli == cCodCli .and. BxaDupRe->NumDup == cNumDup .and. BxaDupRe->(!eof())
                  // ** Apaga o movimento do caixa gerado automaticamente
                  DeleMovCxa()
                  if Cheques->(dbsetorder(1),dbseek(BxaDupRe->CodBco+BxaDupRe->NumAge+BxaDupRe->NumCon))
                     while !Cheques->(Trava_Reg())
                     end
                     Cheques->(dbdelete())
                     Cheques->(dbcommit())
                     Cheques->(dbunlock())
                  end
                  while !BxaDupRe->(Trava_Reg())
                  end
                  BxaDupRe->(dbdelete())
                  BxaDupRe->(dbcommit())
                  BxaDupRe->(dbunlock())
                  BxaDupRe->(dbskip())
               end
            end
            if !empty(right(DupRec->NumDup,1))
               while !DupRec->(Trava_Reg())
               end
               DupRec->(dbdelete())
               DupRec->(dbcommit())
               DupRec->(dbunlock())
            else
               while !DupRec->(Trava_Reg())
               end
               DupRec->ValPag := 0
               DupRec->DtaPag := ctod(space(08))
               DupRec->ValJur := 0
               DupRec->ValDes := 0
               DupRec->ObsBai := space(50)
               DupRec->(dbcommit())
               DupRec->(dbunlock())
            end
            DupRec->(dbskip())
         end
      end
   end
   DesativaF4()
   dbcommitall()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
procedure TelDupRec(nModo,nTipo)
   local aTitulos := {"Inclusao","Alteracao","Exclusao","Efetua Baixa","Cancela Baixa","Visualizacao"}
   local nLinha

   if nTipo == 1
      Window(07,09,15,69,"> " + aTitulos[ nModo ] + " de Duplicata a Receber <")
      setcolor(Cor(11))
      //           123456789012345678901234567890123456789012345678
      //                    2         3         4         5         6         7
      @ 09,11 say "   Cliente:"
      @ 10,11 say " Duplicata:"
      @ 11,11 say "   Emissao:"
      @ 12,11 say "Vencimento:"
      @ 13,11 say "     Valor:"
   elseif nTipo == 2
      Window(02,00,33,79,"> " + aTitulos[ nModo ] + " de Duplicata a Receber <")
      setcolor(Cor(11))
      //           234567890123456789012345678901234567890123456789012345678901234567890
      //                   1         2         3         4         5         6         7
      @ 04,02 say "   Cliente:"
      @ 05,02 say " Duplicata:"
      @ 06,02 say "   Emissao:             Vencimento:                Valor:"
      @ 07,02 say "     Juros:"
      @ 08,02 say "  Desconto:             Vlr. Total:"
      @ 09,02 say " Vlr. Pago:             Data Pagto:             Digitado:"
      @ 10,02 say "Observacao:"
      @ 11,01 say TracoCentro("[ Lancamento(s) para a Baixa ]",78,chr(196))
//      @ 11,01 say "1234567890123456789012345678901234567890123456789012345678901234567890"
      //                    1         2         3         4         5         6
      @ 12,01 say "     Tipo Banco Agencia Nõ Conta        Nõ Cheque  Vencimento Vlr. Pago"
      @ 13,01 say replicate(chr(196),78)
      @ 13,10 say chr(194)
      @ 13,16 say chr(194)
      @ 13,24 say chr(194)
      @ 13,40 say chr(194)
      @ 13,51 say chr(194)
      @ 13,62 say chr(194)
      for nI := 14 to 32
         @ nI,10 say chr(179)
         @ nI,16 say chr(179)
         @ nI,24 say chr(179)
         @ nI,40 say chr(179)
         @ nI,51 say chr(179)
         @ nI,62 say chr(179)
      next
      
   elseif nTipo == 3
      Window(02,00,14,79,"> " + aTitulos[ nModo ] + " de Duplicata a Receber <")
      setcolor(Cor(11))
      //           234567890123456789012345678901234567890123456789012345678901234567890
      //                   1         2         3         4         5         6         7
      @ 04,02 say "   Cliente:"
      @ 05,02 say " Duplicata:                   Tipo:"
      @ 06,02 say "     Banco:                Agencia:             Nõ Conta:"
      @ 07,02 say " Nõ Cheque:               Emitente:"
      @ 08,02 say "   Emissao:             Vencimento:                Valor:"
      @ 09,02 say "     Juros:"
      @ 10,02 say "  Desconto:             Vlr. Total:"
      @ 11,02 say " Vlr. Pago:             Data Pagto:"
      @ 12,02 say "Observacao:"
   end
   return
// ****************************************************************************
Function vBaixa(Pos_H,Pos_V,Ln,Cl,Tecla)
   Local GetList := {},cCampo,cCor := setcolor(),cCodigo
   If Tecla = K_ENTER
      if Pos_H == 1
         cCampo := aTipoCo[Pos_V]
         @ ln,cl get cCampo picture "@k 9" valid MenuArray(@cCampo,{{"1","Dinheiro"},{"2","Cheque"},{"3","Deposito"}},Ln,Cl)
         setcursor(SC_NORMAL)
         read
         setcursor(SC_NONE)
         if !(lastkey() == K_ESC)
            aTipoCo[pos_v] := cCampo
            if aTipoCo[Pos_V] $ "13"
               keyboard replicate(chr(K_RIGHT),12)+chr(K_ENTER)
            else
               keyboard chr(K_RIGHT)+chr(K_ENTER)
            end
            return(2)
         end
      // ** Codigo do Banco
      elseif Pos_H == 2 .and. aTipoCo[Pos_V] == "2"
         cCampo := aCodBco[pos_v]
         @ ln,Cl get cCampo picture "@k 999" valid V_Zera(@cCampo)
         setcursor(SC_NORMAL)
         read
         setcursor(SC_NONE)
         if !(lastkey() == K_ESC)
            Banco->(dbsetorder(1),dbseek(cCampo))
            aCodBco[Pos_V] := cCampo
            keyboard chr(K_RIGHT)+chr(K_ENTER)
            return(2)
         end
      // ** Agencia
      elseif Pos_H == 3 .and. aTipoCo[Pos_V] == "2"
         cCampo := aNumAge[Pos_V]
         @ ln,Cl get cCampo picture "@k!" valid V_Zera(@cCampo)
         setcursor(SC_NORMAL)
         read
         setcursor(SC_NONE)
         if !(lastkey() == K_ESC)
            aNumAge[pos_v] := cCampo
            keyboard chr(K_RIGHT)+chr(K_ENTER)
            return(2)
         end
      // ** Conta
      elseif Pos_H == 4 .and. aTipoCo[Pos_V] == "2"
         cCampo := aNumCon[pos_v]
         @ ln,Cl get cCampo picture "@k!"
         setcursor(SC_NORMAL)
         read
         setcursor(SC_NONE)
         if !(lastkey() == K_ESC)
            aNumCon[Pos_V] := cCampo
            keyboard chr(K_RIGHT)+chr(K_ENTER)
            return(2)
         end
      // ** Cheque
      elseif Pos_H == 5 .and. aTipoCo[Pos_V] == "2"
         cCampo := aNumChq[pos_v]
         @ ln,Cl get cCampo picture "@k!"
         setcursor(SC_NORMAL)
         read
         setcursor(SC_NONE)
         if !(lastkey() == K_ESC)
            aNumChq[Pos_V] := cCampo
            keyboard chr(K_RIGHT)+chr(K_ENTER)
            return(2)
         end
      // ** Data de Vencimento
      elseif Pos_H == 6 .and. aTipoCo[Pos_V] == "2"
         cCampo := aDtaVen[pos_v]
         @ ln,Cl get cCampo picture "@k"
         setcursor(SC_NORMAL)
         read
         setcursor(SC_NONE)
         if !(lastkey() == K_ESC)
            aDtaVen[Pos_V] := cCampo
            keyboard chr(K_RIGHT)+chr(K_ENTER)
            return(2)
         end
      // ** Valor Pago
      elseif Pos_H == 7
         cCampo := aValPag[pos_v]
         @ ln,Cl get cCampo picture "@ke 999,999.99"
         setcursor(SC_NORMAL)
         read
         setcursor(SC_NONE)
         if !(lastkey() == K_ESC)
            aValPag[Pos_V] := cCampo
            @ 09,60 say Soma_Vetor(aValPag) picture "@e 999,999.99"
            return(2)
         end
      end
   elseif Tecla == K_F4
      if !Confirm("Incluir Novo Lancamento")
         return(0)
      end
      if !empty(aTipoCo[pos_v])
         nItens := len(aTipoCo)+1
         asize(aTipoCo,nItens)
         asize(aCodBco,nItens)
         asize(aNumAge,nItens)
         asize(aNumCon,nItens)
         asize(aNumChq,nItens)
         asize(aDtaVen,nItens)
         asize(aValPag,nItens)
         ains(aTipoCo,Pos_V+1)
         ains(aCodBco,Pos_V+1)
         ains(aNumAge,Pos_V+1)
         ains(aNumCon,Pos_V+1)
         ains(aNumChq,Pos_V+1)
         ains(aDtaVen,Pos_V+1)
         ains(aValPag,Pos_V+1)
         aTipoCo[Pos_V+1] := space(01)
         aCodBco[Pos_V+1] := space(03)
         aNumAge[Pos_V+1] := space(04)
         aNumCon[Pos_V+1] := space(15)
         aNumChq[Pos_V+1] := space(10)
         aDtaVen[Pos_V+1] := ctod(space(08))
         aValPag[Pos_V+1] := 0
         keyboard chr(K_DOWN)+replicate(chr(K_LEFT),Pos_H-1)+chr(K_ENTER)
         return( 3 )
      end
   elseif Tecla == K_F6
      if !Confirm("Excluir Lancamento")
         return(0)
      end
      if len(aTipoCo) == 1
         aTipoCo[Pos_V] := space(01)
         aCodBco[Pos_V] := space(03)
         aNumAge[Pos_V] := space(04)
         aNumCon[Pos_V] := space(15)
         aNumChq[Pos_V] := space(10)
         aDtaVen[Pos_V] := ctod(space(08))
         aValPag[Pos_V] := 0
         return(3)
      end
      adel(aTipoCo,Pos_V)
      adel(aCodBco,Pos_V)
      adel(aNumAge,Pos_V)
      adel(aNumCon,Pos_V)
      adel(aNumChq,Pos_V)
      adel(aDtaVen,Pos_V)
      adel(aValPag,Pos_V)
      nItens := len(aTipoCo)-1

      asize(aTipoCo,nItens)
      asize(aCodBco,nItens)
      asize(aNumAge,nItens)
      asize(aNumChq,nItens)
      asize(aDtaVen,nItens)
      asize(aNumCon,nItens)
      asize(aValPag,nItens)
      return(3)
   elseif Tecla == K_F2
      return(0)
   elseif Tecla == K_F11
      Calc()
   elseif Tecla == K_F8
      return(0)
   EndIf
   Return( 1 )
   
static function xApagar(cNumDup,cCodCli) // Mostra as Duplicatas a Pagar
   Local cCor := setcolor(),aVetor1,aVetor2,cTela,nI
   local aCampo  := {},aTitulo := {},aMascara := {}
   private aDupl := {},aEmissao := {},aVenc := {},aValor := {}
   Private nPos

   if !xbaixa
      return !empty(cNumDup)
   endif
   if empty(cNumDup)
      DupRec->(dbsetorder(1),dbseek(cCodCli))
      while DupRec->CodCli == cCodCli .and. DupRec->(!eof())
         if empty(DupRec->DtaPag)
            aadd(aDupl   ,DupRec->NumDup)
            aadd(aEmissao,DupRec->DtaEmi)
            aadd(aVenc   ,DupRec->DtaVen)
            aadd(aValor  ,DupRec->ValDup)
         Endif
         DupRec->(dbskip())
      Enddo
      if len(aDupl) == 0
         Mens({"Nao Existe Duplicatas a Receber"})
         return(.f.)
      endif
      if len(aDupl) == 1
         cNumDup := aDupl[1]
         return(.t.)
      endif
      aVetor1 := {}
      for nI := 1 to len(aDupl)
         aadd(aVetor1,{aDupl[nI],aEmissao[nI],aVenc[nI],aValor[nI]})
      next
      aVetor2   := asort(aVetor1,,,{|x,y| x[3] < y[3]})
      aDupl     := {}
      aEmissao  := {}
      aVenc     := {}
      aValor    := {}
      for nI := 1 to len(aVetor2)
         aadd(aDupl    ,aVetor2[nI][1])
         aadd(aEmissao ,aVetor2[nI][2])
         aadd(aVenc    ,aVetor2[nI][3])
         aadd(aValor   ,aVetor2[nI][4])
      next
      aCampo   := {"aDupl"    ,"aEmissao","aVenc"    ,"aValor"}
      aTitulo  := {"Duplicata","Emissao","Vencimento","Valor"}
      aMascara := {"@!"       ,"@!"     ,"@!"        ,"@e 999,999.99"}
      cTela := SaveWindow()
      Rodape("Esc-Encerra | ENTER-Seleciona")
      Window(02,19,33,79,"> Selecao de Duplicatas <")
      @ 33,59 say space(20)
      @ 33,59 say " Total: "+transform(Soma_Vetor(aValor),"@e 999,999.99")
      Edita_Vet(03,20,32,78,aCampo,aTitulo,aMascara, [XAPAGARU],,,4)
      RestWindow(cTela)
      if nPos == 0
         setcolor(cCor)
         return(.f.)
      endif
      cNumDup := aDupl[nPos]
   Endif
   setcolor(cCor)
   Return .t.
// ****************************************************************************
   
   
// ****************************************************************************
static function xApagarV(cNumDup,cCodCli) // Mostra as Duplicatas a Pagar
   Local cCor := setcolor(),aVetor1,aVetor2,cTela,nI
   local aCampo  := {},aTitulo := {},aMascara := {}
   private aDupl := {},aEmissao := {},aVenc := {},aValor := {}
   Private nPos

   if !xbaixa
      return !empty(cNumDup)
   endif
   if empty(cNumDup)
      DupRec->(dbseek(cCodCli))
      do while DupRec->CodCli == cCodCli .and. DupRec->(!eof())
         if empty(DupRec->DtaPag)
            aadd(aDupl   ,DupRec->NumDup)
            aadd(aEmissao,DupRec->DtaEmi)
            aadd(aVenc   ,DupRec->DtaVen)
            aadd(aValor  ,DupRec->ValDup)
         Endif
         DupRec->(dbskip())
      Enddo
      if len(aDupl) == 0
         Mens({"Nao Existe Duplicatas a Receber"})
         return(.f.)
      endif
      if len(aDupl) == 1
         cNumDup := aDupl[1]
         return(.t.)
      endif
      aVetor1 := {}
      for nI := 1 to len(aDupl)
         aadd(aVetor1,{aDupl[nI],aEmissao[nI],aVenc[nI],aValor[nI]})
      next
      aVetor2   := asort(aVetor1,,,{|x,y| x[3] < y[3]})
      aDupl     := {}
      aEmissao  := {}
      aVenc     := {}
      aValor    := {}
      for nI := 1 to len(aVetor2)
         aadd(aDupl    ,aVetor2[nI][1])
         aadd(aEmissao ,aVetor2[nI][2])
         aadd(aVenc    ,aVetor2[nI][3])
         aadd(aValor   ,aVetor2[nI][4])
      next
      aCampo   := {"aDupl"    ,"aEmissao","aVenc"    ,"aValor"}
      aTitulo  := {"Duplicata","Emissao","Vencimento","Valor"}
      aMascara := {"@!"       ,"@!"     ,"@!"        ,"@e 999,999.99"}
      cTela := SaveWindow()
      Rodape("Esc-Encerra | ENTER-Seleciona")
      Window(02,19,33,79,"> Selecao de Duplicatas <")
      @ 30,57 say space(20)
      @ 30,57 say " Total: "+transform(Soma_Vetor(aValor),"@e 999,999.99")
      Edita_Vet(03,20,30,78,aCampo,aTitulo,aMascara, [XAPAGARU],,,4)
      RestWindow(cTela)
      if nPos == 0
         setcolor(cCor)
         return(.f.)
      endif
      cNumDup := aDupl[nPos]
   Endif
   setcolor(cCor)
   Return .t.
// ****************************************************************************
static function xapago(cNumDup,cCodCli)
   Local cCor := setcolor(),aVetor1,aVetor2,cTela,nI,aCampo  := {},aTitulo := {},aMascara := {}
   private aDupl := {},aEmissao := {},aVenc := {},aValor := {},aDtaPag := {}
   private aValPag := {},nPos

   if !xbaixa
      return !empty(cNumDup)
   end
   if empty(cNumDup)
      if !DupRec->(dbseek(cCodCli))
         Mens({"Nao Existe Duplicatas"})
         return(.f.)
      end
      while DupRec->CodCli == cCodCli .and. DupRec->(!eof())
         if !empty(DupRec->DtaPag)
            aadd(aDupl   ,DupRec->NumDup)
            aadd(aEmissao,DupRec->DtaEmi)
            aadd(aVenc   ,DupRec->DtaVen)
            aadd(aValor  ,DupRec->ValDup)
            aadd(aDtaPag ,DupRec->DtaPag)
            aadd(aValPag ,DupRec->ValPag)
         Endif
         DupRec->(dbskip())
      Enddo
      if len(aDupl) == 1
         cNumDup := aDupl[1]
         return(.t.)
      end
      if len(aDupl) == 0
         Mens({"Nao existe Duplicatas Baixadas"})
         return(.f.)
      end
      aVetor1 := {}
      for nI := 1 to len(aDupl)
         aadd(aVetor1,{aDupl[nI],aEmissao[nI],aVenc[nI],aDtaPag[nI],aValor[nI],aValPag[nI]})
      next
      aVetor2 := asort(aVetor1,,,{|x,y| x[3] < y[3]})
      aDupl    := {}
      aEmissao := {}
      aVenc    := {}
      aDtaPag  := {}
      aValor   := {}
      aValPag  := {}
      for nI := 1 to len(aVetor2)
         aadd(aDupl   ,aVetor2[nI][1])
         aadd(aEmissao,aVetor2[nI][2])
         aadd(aVenc   ,aVetor2[nI][3])
         aadd(aDtaPag ,aVetor2[nI][4])
         aadd(aValor  ,aVetor2[nI][5])
         aadd(aValPag ,aVetor2[nI][6])
      next
      aCampo   := {"aDupl"    ,"aEmissao","aVenc"     ,"aDtaPag"  ,"aValor","aValPag"}
      aTitulo  := {"Duplicata","Emissao" ,"Vencimento","Pagamento","Valor" ,"Vlr. Pago"}
      aMascara := {"@!"       ,"@!"      ,"@!"        ,"@!"       ,"@e 999,999.99","@e 999,999.99"}
      cTela := SaveWindow()
      Rodape("Esc-Encerra | ENTER-Seleciona")
      Window(02,05,23,79,chr(16)+" Selecao de Duplicatas Pagas "+chr(17))
      Edita_Vet(03,06,22,78,aCampo,aTitulo,aMascara, [XAPAGARU],,,6,2)
      RestWindow(cTela)
      if nPos == 0
         setcolor(cCor)
         return(.f.)
      end
      cNumDup := aDupl[nPos]
   Endif
   setcolor(cCor)
   Return .t.
// ****************************************************************************
Function xapagaru( Pos_H, Pos_V, Ln, Cl, Tecla )

   If Tecla = 13
      nPos := pos_v
      Return( 0 )
   ElseIf Tecla = 27
      nPos := 0
      Return( 0 )
   EndIf
   Return( 1 )
// ****************************************************************************
procedure iRecibo(cCodCli,cNumDup)  // Impressao do Recibo
   local cTela := SaveWindow()
   local nVideo,lCabec := .t.,cTexto,cExtenso,nDinheiro := 0,nCheque := 0
   local nDeposito := 0,nRecno,nVia := 1
   private nPagina := 1

   nTecla := 0
   if Aviso_1(09,,14,,"Aten‡Æo!","   Imprimir Recibo ?   ",{"  ^Sim  ","  ^NÆo  "},1,.t.) == 1
        if Sequencia->ModRecibo = "2"
            iReciboNaoFiscal(cCodCli,cNumDup)
            RestWindow(cTela)
            return
        endif
      lUSB := (left(T_IPorta,3) == "USB")
      if lUSB
         iReciboUSB(cCodCli,cNumDup)
         RestWindow(cTela)
         return
      endif
      If Ver_Imp(@nVideo)
         if nVideo == 1
            nVia := nVias()
         end
         begin sequence
            Msg(.t.)
            Msg("Aguarde: Imprimindo Recibo")
            Set Device to Print
            for nX := 1 to nVia
               nDinheiro := 0
               nCheque   := 0
               nDeposito := 0
               DupRec->(dbsetorder(1),dbseek(cCodCli+cNumDup))
               BxaDupRe->(dbsetorder(1),dbseek(cCodCli+cNumDup))
               nRecno := BxaDupRe->(recno())
               while BxaDupRe->CodCli == cCodCli .and. BxaDupRe->NumDup == cNumDup .and. BxaDupRe->(!eof())
                  if BxaDupRe->TipoCobra == "1"
                     nDinheiro += BxaDupRe->ValPag
                  elseif BxaDupRe->TipoCobra == "2"
                     if BxaDupRe->ValDup > 0
                        nCheque += BxaDupRe->ValDup
                     end
                     if BxaDupRe->ValPag > 0
                        nCheque += BxaDupRe->ValPag
                     end
                  elseif BxaDupRe->TipoCobra == "3"
                     nDeposito += BxaDupRe->ValPag
                  end
                  BxaDupRe->(dbskip())
               end
               BxaDupRe->(dbgoto(nRecno))
               Clientes->(dbsetorder(1),dbseek(cCodCli))
               cExtenso := Extenso2(DupRec->ValPag,.t.,.t.)
               cTexto := "        Recebemos de "+rtrim(Clientes->NomCli)+" a importancia de R$ "+rtrim(transform(DupRec->ValPag,"@e 999,999.99"))+" ( "+cExtenso+" ), referente ao pagamento "+iif(!empty(DupRec->Triplicata),"Parcial","Total")+" da Duplicata Nr. "+DupRec->NumDup+" do Pedido Nr. "+subst(DupRec->NumDup,1,6)+", Conforme abaixo descrito:"
               @ prow(),00 say CHR(27)+CHR(67)+CHR(33)
               @ prow(),pcol() say T_ICPP10+T_ICondF
               @ prow()+1,000  say T_ICondI+T_IExpI+rtrim(cEmpFantasia)+T_IExpF+T_ICondF
               @ prow()+1,000  say T_ICONDI+rtrim(clEndLoj)+" "+rtrim(clMunLoj)+"/"+clEstLoj+" Fone: "+rtrim(clTelLoj)+T_ICONDF
               @ prow()+1,000  say T_ICONDI+"C.G.C..: "+transform(clCGCLoj,"@R 99.999.999/9999-99")+" Insc.Estadual: "+clInsLoj+T_ICONDF
               @ prow()+2,035  say T_ICONDF+T_IEXPI+"RECIBO"+T_IEXPF+T_ICONDF
               @ prow()+2,059  say T_ICONDI+T_IEXPI+"No.: "+cNumDup+T_IEXPF+T_ICONDF
               @ prow()+2,000  say ""
               for nI := 1 to mlcount(cTexto,80)
                  if nI == 1
                     @ prow()+1,00 say memoline(cTexto,80,nI)
                  else
                     @ prow()+1,00 say memoline(cTexto,80,nI)
                  end
               next
               @ prow()+2,00 say TracoCentro("[ Demostrativo de Pagamento ]",80,"-")
               // 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
               //           1         2         3         4         5         6         7         8         9
               // Valor Total da Duplicata: 999,999.99    |               Valor Recebido em Dinheiro: 999,999.99
               //   Juros/Multa por Atraso: 999,999.99    |                 Valor Recebido em Cheque: 999,999.99
               //       Desconto Concedido: 999,999.99    |         Valor Recebido em Conta/Corrente: 999,999.99
               //  Total Devido ate a Data: 999,999.99    |    Saldo Devedor - Trip - 1234567890123 : 999,999.99
               @ prow(),pcol() say T_ICPP12
               @ prow()+1,00 say "Valor Total da Duplicata: "+transform(DupRec->ValDup,"@e 999,999.99")
               @ prow()  ,40 say "|"
               @ prow()  ,56 say "Valor Recebido em Dinheiro: "+transform(nDinheiro,"@e 999,999.99")
               @ prow()+1,00 say "   Juro/Multa por Atrazo: "+transform(DupRec->ValJur,"@e 999,999.99")
               @ prow()  ,40 say "|"
               @ prow()  ,58 say "Valor Recebido em Cheque: "+transform(nCheque,"@e 999,999.99")
               @ prow()+1,00 say "      Desconto Concedido: "+transform(DupRec->ValDes,"@e 999,999.99")
               @ prow()  ,40 say "|"
               @ prow()  ,50 say "Valor Recebido em Conta/Corrente: "+transform(nDeposito,"@e 999,999.99")
               @ prow()+1,01 say "Total Devido ate a Data: "+transform((DupRec->ValDup+DupRec->ValJur)-DupRec->ValDes,"@e 999,999.99")
               if !empty(DupRec->Triplicata)
                  @ prow(),45 say "Saldo Devedor - Trip - "+DupRec->Triplicata+" : "
                  DupRec->(dbsetorder(1),dbseek(cCodCli+DupRec->Triplicata))
                  @ prow(),84 say DupRec->ValDup picture "@e 999,999.99"
               end
               @ prow(),pcol() say T_ICPP10
               if nCheque > 0
                  @ prow()+2,00 say TracoCentro("[ Demostrativo do(s) Cheque(s) recebido(s) ]",80,"-")
                  @ prow(),pcol() say T_ICondI
                  //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                  //                           1         2         3         4         5         6         7         8         9         0         1         2         3
                  @ prow()+1,00 say "Emitente ------------------------------------ Banco ----- Agencia ---------- Conta ----- No. Cheque ----- Vencimento ----- Valor ------"
                  //                 1234567890123456789012345678901234567890        123          1234       1234567890       1234567890       99/99/9999       999.999.99
                  while BxaDupRe->CodCli == cCodCli .and. BxaDupRe->NumDup == cNumDup .and. BxaDupRe->(!eof())
                     if !(BxaDupRe->TipoCobra == "2")
                        BxaDupRe->(dbskip())
                        loop
                     end
                     @ prow()+1,000 say BxaDupRe->NomCon
                     @ prow()  ,048 say BxaDupRe->CodBco
                     @ prow()  ,061 say BxaDupRe->NumAge
                     @ prow()  ,072 say BxaDupRe->NumCon
                     @ prow()  ,089 say BxaDupRe->NumChq
                     @ prow()  ,106 say BxaDupRe->DtaVen
                     if BxaDupRe->ValDup > 0
                        @ prow()  ,123 say BxaDupRe->ValDup picture "@e 999,999.99"
                     end
                     if BxaDupRe->ValPag > 0
                        @ prow()  ,123 say BxaDupRe->ValPag picture "@e 999,999.99"
                     end
                     BxaDupRe->(dbskip())
                  end
               end
               DupRec->(dbsetorder(1),dbseek(cCodCli+cNumDup))
               if nCheque == 0
                  @ prow(),pcol() say T_ICondI
               end
               @ prow()+1,00 say replicate("-",136)
               @ prow(),pcol() say T_ICondF
               @ prow()+2,00 say rtrim(clMunLoj)+"( "+clEstLoj+" ), "+DatPort(DupRec->DtaPag,0)
               @ prow()+1,40 say "_____________________________"
               @ prow()+1,40 say PwNome
               @ prow()+2,00 say "Obs.: "+DupRec->ObsBai
               eject
               @ prow(),pcol() say chr(27)+chr(67)+chr(66)
            next
         end sequence
         Set Printer to
         set device to screen
         if nVideo == 1
            Fim_Imp()
         elseif nVideo == 2
            Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,140)
         end
      end
   end
   RestWindow(cTela)
   return
// ****************************************************************************
static procedure VerBaixa(cCodCli,cNumDup)
   local cTela := SaveWindow()
   local aTitulo := {},aCampo := {},aMascara := {}
   private aTipoCobra := {},aCodBco := {},aNumAge := {},aNumCon := {},aNumChq := {}
   private aNomCon    := {},aDtaEmi := {},aDtaVen := {},aValDup := {},aDtaPag := {}
   private aValPag    := {}

   if !BxaDupRe->(dbsetorder(1),dbseek(cCodCli+cNumDup))
      Mens({"Nao Existe Baixa"})
      return
   end
   while BxaDupRe->CodCli == cCodCli .and. BxaDupRe->NumDup == cNumDup .and. BxaDupRe->(!eof())
      if BxaDupRe->TipoCobra == "1"
         aadd(aTipoCobra,"Dinheiro")
      elseif BxaDupRe->TipoCobra == "2"
         aadd(aTipoCobra,"Cheque  ")
      elseif BxaDupRe->TipoCobra == "3"
         aadd(aTipoCobra,"Deposito")
      end
      aadd(aCodBco,BxaDupRe->CodBco)
      aadd(aNumAge,BxaDupRe->NumAge)
      aadd(aNumCon,BxaDupRe->NumCon)
      aadd(aNumChq,BxaDupRe->NumChq)
      aadd(aNomCon,BxaDupRe->NomCon)
      aadd(aDtaEmi,BxaDupRe->DtaEmi)
      aadd(aDtaVen,BxaDupRe->DtaVen)
      aadd(aValDup,BxaDupRe->ValDup)
      aadd(aDtaPag,BxaDupRe->DtaPag)
      aadd(aValPag,BxaDupRe->ValPag)
      BxaDupRe->(dbskip())
   end
   aTitulo  := {"Tipo"      ,"Banco"  ,"Agencia","Nõ Conta","Nõ Cheque","Emitente","Emissao" ,"Vencimento","Valor"        ,"Pagamento","Valor Pago"}
   aCampo   := {"aTipoCobra","aCodBco","aNumAge","aNumCon" ,"aNumChq"  ,"aNomCon","aDtaEmi","aDtaVen"   ,"aValDup"      ,"aDtaPag"  ,"aValPag"}
   aMascara := {"@!"        ,"@!"     ,"@!"     ,"@!"      ,"@!"       ,"@!"       ,"@!"     ,"@!"        ,"@e 999,999.99","@!"       ,"@e 999,999.99"}
   Window(12,00,23,79,"> Lista de Baixas <")
   Edita_Vet(13,01,22,78,aCampo,aTitulo,aMascara,"VerBaixa2",,.t.,,2)
   RestWindow(cTela)
   return
// ****************************************************************************
static function V_Bco(cCodBco)

   if !Busca(@cCodBco,"Banco",1,09,27,"Banco->NomBco",{"Banco Nao Cadastrado"}, .t., .t., .f., .f. )
      lBco := .t.
      Return( .t. )
   end
   cNomBco := Banco->NomBco
   return( .t. )
// ****************************************************************************
static function vBcoNumAge(cCodBco,cNumAge,cNumCon)

   if !Busca(cCodBco+cNumAge+cNumCon,"Banco",1,,,,{"Banco/Agencia/Conta Nao Cadastrado"},.f.,.f.,.f.)
      If Aviso_1(14,,19,, [AtenÎ"o!],"   Cadastra Banco/Agencia/Conta ?   ", { [  ^Sim  ], [  ^N"o  ] }, 2, .t. ) = 1
         IncBancos(.f.)
         return(.f.)
      else
      return(.f.)
      end
   end
   @ 13,23 say Banco->NomCon
   return(.t.)
// ****************************************************************************
static function V_Bco2(cCodBco,Pos_V,lTrue)

   if !Busca(@cCodBco,"Banco",1,,,,{"Banco Nao Cadastrado"}, .t., .t., .f., .f. )
      if lTrue
         If Aviso_1(14,,19,, [AtenÎ"o!],"   Cadastra o Banco ?   ", { [  ^Sim  ], [  ^N"o  ] }, 2, .t. ) = 1
            IncBancos(.f.)
            Return(.f.)
         else
            return(.f.)
         end
      end
   end
   aNomBco[Pos_V] := Banco->NomBco
   Return( .t. )
// ****************************************************************************
static function vCheque(cCodBco,cNumAge,cNumCon,cNumChq)

   if !(cCodBco == DupRec->CodBco) .or. !(cNumAge == DupRec->NumAge) .or. !(cNumCon == DupRec->NumCon) .or. !(cNumChq == DupRec->NumChq)
      if !Busca(cCodBco+cNumAge+cNumCon+cNumChq,"Cheques",1,,,,{"Cheque Ja Cadastrado"},.f.,.f.,.t.)
         return(.f.)
      end
   end
   return(.t.)
// ****************************************************************************
procedure ConfLancRx // Configura o Lancamento no Caixa
   local getlist := {},cTela := SaveWindow()

    Msg(.t.)
    Msg("Aguarde : Abrindo o Arquivo")
    if !OpenCaixa()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenHistCxa()
        FechaDados()
        Msg(.f.)
        return
    endif
    Msg(.f.)
   restore from (Arq_Sen)+"r" additive
   AtivaF4()
   Window(09,14,14,64," Conf. Lanc. no Caixa ")
   setcolor(Cor(11))
   //           67890123456789012345678901234567890123456789012345678
   //               2         3         4         5         6         7
   @ 11,16 say "    Caixa:"
   @ 12,16 say "Historico:"
   while .t.
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,27 get cRCodCxa picture "@k 99" when Rodape("Esc-Encerra | F4-Caixas") valid Busca(Zera(@cRCodCxa),"Caixa",1,11,31,"Caixa->NomCaixa",{"Caixa Nao Cadastrado"},.f.,.f.,.f.)
      @ 12,27 get cRCodHis picture "@k 999" when Rodape("Esc-Encerra | F4-Historicos") valid Busca(Zera(@cRCodHis),"Historico",1,12,31,"Historico->NomHist",{"Historic Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
      save to (Arq_Sen)+"r" all like cRCod*
      exit
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
Function VerBaixa2( Pos_H, Pos_V, Ln, Cl, Tecla )

   if Tecla == K_ESC
      return(0)
   end
   return(1)
// ****************************************************************************
function vDupRec(cNumDup,cCodCli)
   Local cCor := setcolor(),aVetor1,aVetor2,cTela,nI,aCampo  := {},aTitulo := {},aMascara := {}
   private aDupl := {},aEmissao := {},aVenc := {},aValor := {},aDtaPag := {}
   private aValPag := {},nPos

   if empty(cNumDup)
      // **if !DupRec->(dbsetorder(1),dbseek(cCodCli+"N"))
      if !DupRec->(dbsetorder(1),dbseek(cCodCli))
         Mens({"Nao Existe Duplicatas"})
         return(.f.)
      endif
      while DupRec->CodCli == cCodCli .and. DupRec->Pedido == "N" .and. DupRec->(!eof())
         if empty(DupRec->DtaPag)
            aadd(aDupl   ,DupRec->NumDup)
            aadd(aEmissao,DupRec->DtaEmi)
            aadd(aVenc   ,DupRec->DtaVen)
            aadd(aValor  ,DupRec->ValDup)
         endif
         DupRec->(dbskip())
      Enddo
      if len(aDupl) == 1
         cNumDup := aDupl[1]
         return(.t.)
      endif
      if len(aDupl) == 0
         Mens({"Nao Existe Duplicatas"})
         return(.f.)
      endif
      aVetor1 := {}
      for nI := 1 to len(aDupl)
         aadd(aVetor1,{aDupl[nI],aEmissao[nI],aVenc[nI],aValor[nI]})
      next
      aVetor2 := asort(aVetor1,,,{|x,y| x[3] < y[3]})
      aDupl    := {}
      aEmissao := {}
      aVenc    := {}
      aValor   := {}
      for nI := 1 to len(aVetor2)
         aadd(aDupl   ,aVetor2[nI][1])
         aadd(aEmissao,aVetor2[nI][2])
         aadd(aVenc   ,aVetor2[nI][3])
         aadd(aValor  ,aVetor2[nI][4])
      next
      aCampo   := {"aDupl"    ,"aEmissao","aVenc"     ,"aValor"}
      aTitulo  := {"Duplicata","Emissao" ,"Vencimento","Valor"}
      aMascara := {"@!"       ,"@!"      ,"@!"        ,"@e 999,999.99"}
      cTela := SaveWindow()
      Rodape("Esc-Encerra | ENTER-Seleciona")
      Window(02,25,maxrow()-1,79,"> Selecao de Duplicatas <")
      @ maxrow()-1,57 say space(20)
      @ maxrow()-1,57 say " Total: "+transform(Soma_Vetor(aValor),"@e 999,999.99")
      Edita_Vet(03,26,maxrow()-2,78,aCampo,aTitulo,aMascara, [XAPAGARU],,,4,2)
      RestWindow(cTela)
      if nPos == 0
         setcolor(cCor)
         return(.f.)
      endif
      cNumDup := aDupl[nPos]
   Endif
   setcolor(cCor)
   Return .t.
// ****************************************************************************
// ** LanÎamento Automÿtico no Caixa
// ****************************************************************************
procedure LancMovCxa(cLanCxa,dDtaMov,cCCodCx2,cCCodHi2,cNumChq,cCodBco,cNumAge,cNumCon,nValor,cTipo)

   if !empty(cCCodCx2) .and. !empty(cCCodHi2)
      if Caixa->(dbsetorder(1),dbseek(cCCodCx2))
         HistCxa->(dbsetorder(1),dbseek(cCCodHi2))
         while !Sequencia->(Trava_Reg())
         end
         Sequencia->LancMovCxa += 1
         Sequencia->(dbunlock())
         cLanCxa := strzero(Sequencia->LancMovCxa,6)
         while !MovCaixa->(Adiciona())
         end
         MovCaixa->Lancamento := cLanCxa
         MovCaixa->Data       := dDtaMov
         MovCaixa->CodCaixa   := cCCodCx2
         MovCaixa->CodHisto   := cCCodHi2
         if cTipo == "1"     // Dinheiro
            MovCaixa->Complemen1 := cNumDup
         elseif cTipo == "2" // Cheques
            MovCaixa->Complemen1 := cNumDup+" Cheque "+cCodBco+"/"+cNumAge+"/"+cNumCon+"/"+subst(rtrim(cNumChq),1,4)
            MovCaixa->Complemen2 := subs(rtrim(cNumChq),5,6)
         elseif cTipo == "3" // Deposito
            MovCaixa->Complemen1 := cNumDup+" Deposito"
         end
         if HistCxa->TipHist == "R"
            MovCaixa->Tipo := "1"
         elseif HistCxa->TipHist == "D"
            MovCaixa->Tipo := "2"
         end
         MovCaixa->Valor := nValor
         if cTipo == "1"         // Dinheiro
            MovCaixa->CodPagto := "01"
         elseif cTipo == "2"     // Cheque
            MovCaixa->CodPagto := "02"
         elseif cTipo == "3"     // Deposito
            MovCaixa->CodPagto := "03"
         end
         MovCaixa->(dbcommit())
         MovCaixa->(dbunlock())
         // ** Atualiza o Saldo do Caixa
         while !Caixa->(Trava_Reg())
         end
         Caixa->SldCaixa += MovCaixa->Valor
         Caixa->(dbcommit())
         Caixa->(dbunlock())
      end
   end
   return
// ****************************************************************************
// ** Retira o lanÎamento do movimento do caixa
static procedure DeleMovCxa

   if !empty(BxaDupRe->LanCxa)
      if MovCaixa->(dbsetorder(1),dbseek(BxaDupRe->LanCxa))
         if Caixa->(dbsetorder(1),dbseek(MovCaixa->CodCaixa))
            while !Caixa->(Trava_Reg())
            end
            Caixa->SldCaixa -= MovCaixa->Valor
            Caixa->(dbcommit())
            Caixa->(dbunlock())
         end
         // ** Trava o registro e apaga o movimento
         while !MovCaixa->(Trava_Reg())
         end
         MovCaixa->(dbdelete())
         MovCaixa->(dbcommit())
         MovCaixa->(dbunlock())
      end
   end
   return
// ****************************************************************************
procedure iReciboUSB(cCodCli,cNumDup)
   local cTela := SaveWindow(),aPrn,lCabec := .t.
   local cTexto,cExtenso,nDinheiro := 0,nCheque := 0
   local nDeposito := 0,nRecno,nVia := 1,nQualidade
   private nPagina := 1
   private oPrinter

   aPrn := getprinters()

   Window(08,08,18,42," Selecione a Impressora ")
   resp   := achoice(10,10,16,40,aPrn)
   if resp == 0
      RestWindow(cTela)
      return
   endif
   RestWindow(cTela)
   nQualidade := QualidadeImpressao()
   if nQualidade == -27
      return
   endif
   oPrinter := Win32Prn():New(aPrn[Resp])
   cFont:= 'Courier New'
   nlinha := 1
   oPrinter:Landscape:= .F.
   oPrinter:FormType := 9
   oPrinter:Copies   := 1
   oPrinter:SetPrintQuality(nQualidade)
   IF !oPrinter:Create()
       Alert("Cannot Create Printer")
       RestWindow(cTela)
       return
   ELSE
      IF !oPrinter:startDoc('Win32Prn(Doc name in Printer Properties)')
         Alert("StartDoc() failed")
         RestWindow(cTela)
         return
      endif
   endif
   begin sequence
      Msg(.t.)
      Msg("Aguarde: Imprimindo Recibo")
      nDinheiro := 0
      nCheque   := 0
      nDeposito := 0
      DupRec->(dbsetorder(1),dbseek(cCodCli+cNumDup))
      BxaDupRe->(dbsetorder(1),dbseek(cCodCli+cNumDup))
      nRecno := BxaDupRe->(recno())
      while BxaDupRe->CodCli == cCodCli .and. BxaDupRe->NumDup == cNumDup .and. BxaDupRe->(!eof())
         if BxaDupRe->TipoCobra == "1"
            nDinheiro += BxaDupRe->ValPag
         elseif BxaDupRe->TipoCobra == "2"
            if BxaDupRe->ValDup > 0
               nCheque += BxaDupRe->ValDup
            endif
            if BxaDupRe->ValPag > 0
               nCheque += BxaDupRe->ValPag
            endif
         elseif BxaDupRe->TipoCobra == "3"
            nDeposito += BxaDupRe->ValPag
         endif
         BxaDupRe->(dbskip())
      enddo
      BxaDupRe->(dbgoto(nRecno))
      Clientes->(dbsetorder(1),dbseek(cCodCli))
      cExtenso := Extenso2(DupRec->ValPag,.t.,.t.)
      cTexto := "        Recebemos de "+rtrim(Clientes->NomCli)+" a importancia de R$ "+rtrim(transform(DupRec->ValPag,"@e 999,999.99"))+" ( "+cExtenso+" ), referente ao pagamento "+iif(!empty(DupRec->Triplicata),"Parcial","Total")+" da Duplicata Nr. "+DupRec->NumDup+" do Pedido Nr. "+subst(DupRec->NumDup,1,6)+", Conforme abaixo descrito:"

      oPrinter:SetFont(cFont,,11)
      ImpNegrito(oPrinter:prow()+1,00,rtrim(cEmpFantasia))

      oPrinter:SetFont(cFont,,18)
      ImpLinha(oPrinter:prow()+1,000,rtrim(clEndLoj)+" "+rtrim(clMunLoj)+"/"+clEstLoj+" Fone: "+rtrim(clTelLoj))
      ImpLinha(oPrinter:prow()+1,000,"C.G.C..: "+transform(clCGCLoj,"@R 99.999.999/9999-99")+" Insc.Estadual: "+clInsLoj)

      oPrinter:SetFont(cFont,,11)
      ImpNegrito(oPrinter:prow()+3,035,"RECIBO")
      ImpNegrito(oPrinter:prow()+2,059,"No.: "+cNumDup)


      oPrinter:SetFont(cFont,,13)
      ImpLinha(oPrinter:prow()+2,000,"")
      for nI := 1 to mlcount(cTexto,80)
         if nI == 1
            ImpLinha(oPrinter:prow()+1,00,memoline(cTexto,100,nI))
         else
            ImpLinha(oPrinter:prow()+1,00,memoline(cTexto,100,nI))
         endif
      next
      ImpLinha(oPrinter:prow()+2,00,TracoCentro("[ Demostrativo de Pagamento ]",100,"-"))
      // 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
      //           1         2         3         4         5         6         7         8         9
      // Valor Total da Duplicata: 999,999.99    |               Valor Recebido em Dinheiro: 999,999.99
      //   Juros/Multa por Atraso: 999,999.99    |                 Valor Recebido em Cheque: 999,999.99
      //       Desconto Concedido: 999,999.99    |         Valor Recebido em Conta/Corrente: 999,999.99
      //  Total Devido ate a Data: 999,999.99    |    Saldo Devedor - Trip - 1234567890123 : 999,999.99
     // @ prow(),pcol() say T_ICPP12
      ImpLinha(oPrinter:prow()+1,00,"Valor Total da Duplicata: "+transform(DupRec->ValDup,"@e 999,999.99"))
      ImpLinha(oPrinter:prow()  ,40,"|")
      ImpLinha(oPrinter:prow()  ,56,"Valor Recebido em Dinheiro: "+transform(nDinheiro,"@e 999,999.99"))
      ImpLinha(oPrinter:prow()+1,00,"   Juro/Multa por Atrazo: "+transform(DupRec->ValJur,"@e 999,999.99"))
      ImpLinha(oPrinter:prow()  ,40,"|")
      ImpLinha(oPrinter:prow()  ,58,"Valor Recebido em Cheque: "+transform(nCheque,"@e 999,999.99"))
      ImpLinha(oPrinter:prow()+1,00,"      Desconto Concedido: "+transform(DupRec->ValDes,"@e 999,999.99"))
      ImpLinha(oPrinter:prow()  ,40,"|")
      ImpLinha(oPrinter:prow()  ,50,"Valor Recebido em Conta/Corrente: "+transform(nDeposito,"@e 999,999.99"))
      ImpLinha(oPrinter:prow()+1,01,"Total Devido ate a Data: "+transform((DupRec->ValDup+DupRec->ValJur)-DupRec->ValDes,"@e 999,999.99"))
      if !empty(DupRec->Triplicata)
         ImpLinha(oPrinter:prow(),45,"Saldo Devedor - Trip - "+DupRec->Triplicata+" : ")
         DupRec->(dbsetorder(1),dbseek(cCodCli+DupRec->Triplicata))
         ImpLinha(oPrinter:prow(),84,transform(DupRec->ValDup,"@e 999,999.99"))
      end
      if nCheque > 0
         ImpLinha(oPrinter:prow()+2,00,TracoCentro("[ Demostrativo do(s) Cheque(s) recebido(s) ]",100,"-"))
         //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
         //                           1         2         3         4         5         6         7         8         9         0         1         2         3
         ImpLinha(oPrinter:prow()+1,00,"Emitente ------------------------------------ Banco ----- Agencia ---------- Conta ----- No. Cheque ----- Vencimento ----- Valor ------")
         //                 1234567890123456789012345678901234567890        123          1234       1234567890       1234567890       99/99/9999       999.999.99
         while BxaDupRe->CodCli == cCodCli .and. BxaDupRe->NumDup == cNumDup .and. BxaDupRe->(!eof())
            if !(BxaDupRe->TipoCobra == "2")
               BxaDupRe->(dbskip())
               loop
            end
            ImpLinha(oPrinter:prow()+1,000,BxaDupRe->NomCon)
            ImpLinha(oPrinter:prow()  ,048,BxaDupRe->CodBco)
            ImpLinha(oPrinter:prow()  ,061,BxaDupRe->NumAge)
            ImpLinha(oPrinter:prow()  ,072,BxaDupRe->NumCon)
            ImpLinha(oPrinter:prow()  ,089,BxaDupRe->NumChq)
            ImpLinha(oPrinter:prow()  ,106,BxaDupRe->DtaVen)
            if BxaDupRe->ValDup > 0
               ImpLinha(oPrinter:prow()  ,123,transform(BxaDupRe->ValDup,"@e 999,999.99"))
            end
            if BxaDupRe->ValPag > 0
               ImpLinha(oPrinter:prow()  ,123,transform(BxaDupRe->ValPag,"@e 999,999.99"))
            end
            BxaDupRe->(dbskip())
         end
      end
      DupRec->(dbsetorder(1),dbseek(cCodCli+cNumDup))
      ImpLinha(oPrinter:prow()+1,00,replicate("-",100))
      ImpLinha(oPrinter:prow()+2,00,rtrim(clMunLoj)+"( "+clEstLoj+" ), "+DatPort(DupRec->DtaPag,0))
      ImpLinha(oPrinter:prow()+1,40,"-----------------------------")
      ImpLinha(oPrinter:prow()+1,40,PwNome)
      ImpLinha(oPrinter:prow()+2,00,"Obs.: "+DupRec->ObsBai)
      oPrinter:enddoc()
      oPrinter:Destroy()
   end sequence
   Msg(.f.)
   
   
   
procedure ImprimirCarne
    local getlist := {},cTela := SaveWindow()
    local cNumPed,cObs1,cObs2,cObs3,lLimpa := .t.
    
    Msg(.t.)
    Msg("Aguarde: Abrindo os arquivos")
    if !OpenClientes()
        FechaDados()
        Msg(.f.)
        FechaDados()
        return
    endif
    if !OpenPedidos()
        FechaDados()
        Msg(.f.)
        FechaDados()
        return
    endif
    if !OpenDupRec()
        FechaDados()
        Msg(.f.)
        FechaDados()
        return
    endif
    if !OpenPlano()
        FechaDados()
        Msg(.f.)
        FechaDados()
        return
    endif
    Msg(.f.)
    AtivaF4()
    Window(08,00,20,72," Impress’o do Carn^")
    setcolor(Cor(11))
    //           12345678901234567890
    @ 10,01 say "Nr. da Proposta:"
    @ 11,01 say "        Cliente:"
    @ 12,01 say "Data de Emiss’o:"
    @ 13,01 say "          Valor:"
    @ 14,01 say "Forma de Pagto.:"
    @ 15,01 say "Nr. de Parcelas:"
    @ 16,01 say replicate(chr(196),71)
    @ 16,01 say "ObservaÎ’o"
    do while .t.
        cNumPed := space(09)
        if lLimpa
            cObs1 := space(70)
            cObs2 := space(70)
            cObs3 := space(70)
            lLimpa := .f.
        endif
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 10,18 get cNumPed picture "@k 999999999";
            valid Busca(Zera(@cNumPed),"Pedidos",1,,,,{"Numero Nao Cadastrado"},.f.,.f.,.f.)
        read
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        if !Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
            Mens({"Cliente n’o cadastrado"})
            loop
        endif
        if !Plano->(dbsetorder(1),dbseek(Pedidos->CodPla))
            Mens({"Plano de Pagamento n’o cadastrado"})
            loop
        endif
        if Plano->TipOpe = "1"
            Mens({"Pagamento Avista nao emite carn^"})
            loop
        endif
        if !DupRec->(dbsetorder(1),dbseek(Pedidos->CodCli+cNumPed))
            Mens({"Duplicata n’o cadastrada"})
            loop
        endif
        @ 11,18 say Pedidos->CodCli+"-"+Clientes->ApeCli
        @ 12,18 say Pedidos->data
        @ 13,18 say Pedidos->Total picture "@e 999,999,999.99"
        @ 14,18 say Pedidos->CodPla+"-"+Plano->DesPla
        @ 15,18 say Plano->NumPar
        
        @ 17,01 get cObs1 picture "@k!"
        @ 18,01 get cObs2 picture "@k!"
        @ 19,01 get cObs3 picture "@k!"
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            loop
        endif
        if !Confirm("Confirma as informaÎ„es",2)
            loop
        endif
        Msg(.t.)
        Msg("Aguarde: Gerando o Carn^")
        aStru := {}
        aadd(aStru,{"documento","c",16,0})
        aadd(aStru,{"emissao","d",08,0})
        aadd(aStru,{"vencimento","d",08,0})
        aadd(aStru,{"valor","n",15,2})
        aadd(aStru,{"parcela","c",02,0})
        aadd(aStru,{"parcelatot","c",02,0})
        aadd(aStru,{"NomLoj","c",70,0})
        aadd(aStru,{"NomCli","c",70,0})
        aadd(aStru,{"Obs1","c",70,0})
        aadd(aStru,{"Obs2","c",70,0})
        aadd(aStru,{"Obs3","c",70,0})
        cArquivo := "carne"
        dbcreate(cDiretorio+cArquivo,aStru)
        
        if !Use_Dbf(cDiretorio,cArquivo,.t.,.t.,"Temp")
            Msg(.f.)
            Mens({"Arquivo de impress’o indipon­vel","Tente novamente"})
            loop
        endif
        zap
        Temp->(dbclosearea())
        if !Use_Dbf(cDiretorio,cArquivo,.t.,.t.,"Temp")
            Msg(.f.)
            Mens({"Arquivo de impress’o indipon­vel","Tente novamente"})
            loop
        endif
        do while DupRec->CodCli == Pedidos->CodCli .and. left(DupRec->NumDup,9) == cNumPed .and. DupRec->(!eof()) 
            do while Temp->(!Adiciona())
            enddo
            Temp->Documento := DupRec->NumDup
            Temp->Emissao := DupRec->DtaEmi
            Temp->Vencimento := DupRec->DtaVen
            Temp->Valor := DupRec->ValDup
            Temp->parcela := substr(DupRec->NumDup,11,02)
            Temp->parcelatot := substr(DupRec->NumDup,14,02)
            Temp->NomLoj := cEmpFantasia
            Temp->NomCli := Clientes->ApeCli
            Temp->Obs1 := cObs1
            Temp->Obs2 := cObs2
            Temp->Obs3 := cObs3
            Temp->(dbunlock())
            DupRec->(dbskip())
        enddo
        Temp->(dbclosearea())
        oFrPrn := frReportManager():new()
        oFrPrn:SetIcon(1)                                     //­cone da janela do FRH
//        oFrPrn:LoadLangRes( 'brazil.xml')                     //arquivo de idioma
        oFrPrn:SetWorkArea("Temp",  select("Carne"))
        oFrPrn:LoadFromFile('fastreport\CarneDePagamento3.fr3')            // para leitura direta de arquivo FR3
        oFrPrn:PrepareReport()
        oFrPrn:PreviewOptions:SetAllowEdit( .F. )             // inibe o bot’o de ediÎ’o do relat½rio pelo usuÿrio
        //oFrPrn:AddVariable( "MeusDados", "Empresa",  "teste "  )
        oFrPrn:SetVariable("Empresa","Teste")
        //oFrPrn:PrintOptions:SetShowDialog(.F.)
        oFrPrn:DesignReport()
        //oFrPrn:ShowReport()                                   // aqui para gerar o preview do relat½rio.
        oFrPrn:Print(.t.)
        oFrPrn:DestroyFR()
        Ferase(cDiretorio+cArquivo+".dbf")
        Msg(.f.)
        lLimpa := .t.
    enddo
    FechaDados()
    RestWindow(cTela)
    return
    
    
static function AbrirArquivos

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenClientes()
      FechaDados()
      Msg(.f.)
      return(.f.)
   endif
   if !OpenCidades()
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
   
   
procedure IReciboNaoFiscal(cCodCli,cNumDup)
    local nContador := 1,nDesc := 0
    
    Clientes->(dbsetorder(1),dbseek(cCodCli))
    //Plano->(dbsetorder(1),dbseek(Pedidos->CodPla))
    Cidades->(dbsetorder(1),dbseek(cEmpCodcid))
    DupRec->(dbsetorder(1),dbseek(cCodCli+cNumDup))
    
    cComando := ""
    cComando += 'ESCPOS.ativar' + CRLF
    cComando += 'ESCPOS.imprimirlinha("</zera>")' + CRLF
    cComando += 'ESCPOS.imprimirlinha("</ce><e>'+left(rtrim(cEmpFantasia),38)+'</e>")'+CRLF
    cComando += 'ESCPOS.imprimirlinha("</ae><c>'+rtrim(cEmpEndereco)+","+cEmpNumero+rtrim(cEmpBairro)+" "+rtrim(Cidades->NomCid)+"-"+;
                    Cidades->EstCid+'</c>")'+CRLF
    cComando += 'ESCPOS.imprimirlinha("<c>'+"Fone: "+transform(cEmpTelefone1,"@r (999)99999-9999")+' '+;
            transform(cEmpTelefone2,"@r (999)99999-9999")+'</c>")'+CRLF
    cComando += 'ESCPOS.imprimirlinha("</linha_simples>")'+CRLF            
    cComando += 'ESCPOS.imprimirlinha('+PADC("COMPROVANTE DE PAGAMENTO", 48 )+')'+CRLF
    cComando += 'ESCPOS.imprimirlinha('+"    Cliente: "+DupRec->CodCli+" "+left(Clientes->NomCli,30)+')'+CRLF
    cComando += 'ESCPOS.imprimirlinha("</linha_simples>")'+CRLF        
    cComando += 'ESCPOS.imprimirlinha('+" Duplicata: "+DupRec->NumDup+')'+CRLF
    cComando += 'ESCPOS.imprimirlinha('+"Vencimento: "+dtoc(DupRec->DtaVen)+')'+CRLF
    cValDup := transform(DupRec->ValDup,"@e 999,999.99")
    cValPag := transform(DupRec->ValPag,"@e 999,999.99") 
    cComando += 'ESCPOS.imprimirlinha("'+"    Valor: "+cValDup+'")'+CRLF
    cComando += 'ESCPOS.imprimirlinha('+"Data Pagto: "+dtoc(DupRec->DtaPag)+')'+CRLF
    cComando += 'ESCPOS.imprimirlinha("'+"Valor Pago: "+cValDup+'")'+CRLF
    cComando += 'ESCPOS.imprimirlinha("</linha_simples>")'+CRLF
    //cComando += 'ESCPOS.imprimirlinha("</pular_linhas>")'+CRLF
    cComando += 'ESCPOS.imprimirlinha("</pular_linhas>")'+CRLF
    cComando += 'ESCPOS.imprimirlinha('+"          ------------------------------------"+')'+CRLF
    cComando += 'ESCPOS.imprimirlinha('+"                Assinatura do caixa           "+')'+CRLF
    cComando += 'ESCPOS.imprimirlinha("</pular_linhas>")'+CRLF
    cComando += 'ESCPOS.imprimirlinha("</corte_total>")'+CRLF
    cComando += 'ESCPOS.desativar'+CRLF
    
    Memowrit(rtrim(Sequencia->dirnfe)+"\escpos.txt",cComando)
    MemoWrit(rtrim(Sequencia->dirnfe)+"\entnfe.txt",cComando)
    return
   
   

//** Fim do Arquivo
