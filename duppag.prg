/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.00
 * Identificacao: Manutencao de Duplicatas a Pagar
 * Prefixo......: LtAdm
 * Programa.....: DupPag.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 03 de Setembro de 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.CH"       // Inclusao do Arquivo Header Padrao
#include "inkey.CH"   // Header para manipulacao de Teclas
#include "setcurs.ch"

procedure ConDupPag
   local oBrow,oCol,nTecla,lFim := .F.,aRect,cTela := savewindow(),aTab
	local nLinha1,nColuna1,nLinha2,nColuna2
   private lRefresh := .f.

	if !AbrirArquivos()
		return
	endif
	nLinha1  := 02
	nColuna1 := 00
	nLinha2  := 33 // 23
	nColuna2 := 100
   select DupPag
   set order to 1
   goto top
   Rodape("Esc-Encerra")
   setcolor(cor(5))
   Window(nLinha1,nColuna1,nLinha2,nColuna2,"> Consulta de Duplicatas a Pagar <")
   oBrow := TBrowseDB(nLinha1+1,nColuna1+1,nLinha2-3,nColuna2-1)
   oBrow:headSep := chr(194)+chr(196)
   oBrow:colSep  := chr(179)
   oBrow:footSep := chr(193)+chr(196)
   oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)
   oColuna := tbcolumnnew("Codigo" ,{|| DupPag->CodFor})
   oColuna:colorblock := {|| iif( !empty(DupPag->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   oColuna := tbcolumnnew("Fornecedor" ,{|| Fornecedor->(dbsetorder(1),dbseek(DupPag->CodFor),Fornecedor->RazFor)})
   oColuna:colorblock := {|| iif( !empty(DupPag->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   oColuna := tbcolumnnew("Duplicata",{|| DupPag->NumDup})
   oColuna:colorblock := {|| iif( !empty(DupPag->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   oColuna := tbcolumnnew("Documento",{|| DupPag->Docume})
   oColuna:colorblock := {|| iif( !empty(DupPag->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   oColuna := tbcolumnnew("Emissao",{|| DupPag->DtaEmi })
   oColuna:colorblock := {|| iif( !empty(DupPag->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   oColuna := tbcolumnnew("Vencimento",{|| DupPag->DtaVen })
   oColuna:colorblock := {|| iif( !empty(DupPag->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   oColuna := tbcolumnnew("Valor",{|| transform(DupPag->ValDup,"@e 999,999.99") })
   oColuna:colorblock := {|| iif( !empty(DupPag->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   oColuna := tbcolumnnew("Observacao",{|| DupPag->ObsDoc })
   oColuna:colorblock := {|| iif( !empty(DupPag->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   oColuna := tbcolumnnew("Pagamento",{|| DupPag->DtaPag })
   oColuna:colorblock := {|| iif( !empty(DupPag->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   oColuna := tbcolumnnew("Valor Pago",{|| transform(DupPag->ValPag,"@e 999,999.99")})
   oColuna:colorblock := {|| iif( !empty(DupPag->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   oColuna := tbcolumnnew("Juros",{|| transform(DupPag->ValJur,"@e 999,999.99")})
   oColuna:colorblock := {|| iif( !empty(DupPag->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   oColuna := tbcolumnnew("Desconto",{|| transform(DupPag->ValDes,"@e 999,999.99")})
   oColuna:colorblock := {|| iif( !empty(DupPag->DtaPag),{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   aTab := TabHNew(nLinha2-2,nColuna1+1,nColuna2-1,setcolor(cor(28)),1)
   TabHDisplay(aTab)
   setcolor(Cor(26))
   SCROLL(nLinha2-1,nColuna1+1,nLinha2-1,nColuna2-1,0)
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
         elseif nTecla == K_F2
            VerBaixa(DupPag->CodFor,DupPag->NumDup)
         endif
      elseif nTecla == K_RIGHT
         tabHupdate(aTab,obrow:colpos,obrow:colcount,.t.)
      elseif nTecla == K_LEFT
         tabHupdate(aTab,obrow:colpos,obrow:colcount,.t.)
      endif
   enddo
   FechaDados()
   RestWindow( cTela )
   return
// ****************************************************************************
procedure IncDupPag
	local getlist := {},cTela := SaveWindow()
	private nIdFornecedor,cDuplicata,dDtaEmi,dDtaVen,nValDup,cDocume,cObsDoc,cQuery,oQuery

   AtivaF4()
   TelDupPag(1,1)
   do while .t.
      nIdFornecedor := 0
      cDuplicata := space(12)
      dDtaEmi := date()
      dDtaVen := ctod(space(08))
      nValDup := 0
      cDocume := space(12)
      cObsDoc := space(50)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 08,21 get nIdFornecedor picture "@k 9999";
      		when Rodape("Esc-Encerra | F4-Fornecedores");
            valid SqlBusca("id = "+NumberToSql(nIdFornecedor),"fanFor",@oQuery,;
            "administrativo.fornecedores",row(),col()+1,{"fanfor",0},{"Fornecedor nÆo cadastrado"},.f.)
      @ 09,21 get cDuplicata picture "@k";
                  when Rodape("Esc-Encerra");
                  valid SqlBusca("idfornecedor = "+NumberToSql(nIdFornecedor)+" AND duplicata = "+;
                     StringToSql(cDuplicata),"duplicata",@oQuery,;
                  "financeiro.duplicatas_apagar",,,,{"Duplicata j  cadastrada"},.t.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
		if !GetDupPag()
			loop
		endif
      if !Confirm("Confirma a Inclusao")
         loop
      endif
      GravarDupPag(.t.) // gera uma query
      Msg(.t.)
      Msg("Aguarde: Gravando as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      /*
      if !Grava_LogSql("Cadastros|Financeiro|Caixa|Formas de pagamento|Alterar|Codigo: "+str(nId))
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
       endif
       */
      oServer:Commit()
      oQuery:Close()
      Msg(.f.)
   enddo
   DesativaF4()
   RestWindow(cTela)
return
// ****************************************************************************
procedure AltDupPag
   local getlist := {},cTela := SaveWindow()
   local cQuery
	private nIdFornecedor,cDuplicata,dDtaEmi,dDtaVen,nValDup,cDocume,cObsDoc,oQuery
	private xBaixa := .t.

   AtivaF4()
   TelDupPag(2,1)
   do while .t.
      //cChave  := space(05)
      nIdFornecedor := 0
      cDuplicata := space(12)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 08,21 get nIdFornecedor picture "@k 9999";
      			when Rodape("Esc-Encerra | F4-Fornecedores");
               valid SqlBusca("id = "+NumberToSql(nIdFornecedor),"fanFor",@oQuery,;
               "administrativo.fornecedores",row(),col()+1,{"fanfor",0},{"Fornecedor nÆo cadastrado"},.f.)
      @ 09,21 get cDuplicata picture "@k";
                  when Rodape("Esc-Encerra");
                  valid xDupPaga(@cDuplicata,nIdFornecedor) //.and. Busca(cCodFor+cNumDup,"DupPag",1,,,,{"Duplicata Nao Cadastrada"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      if !empty(DupPag->DtaPag)
         Mens({"Duplicata ja foi dado baixa"})
         loop
      endif
      cDocume := DupPag->Docume
      dDtaEmi := DupPag->DtaEmi
      dDtaVen := DupPag->DtaVen
      nValDup := DupPag->ValDup
      cObsDoc := DupPag->ObsDoc
		if !GetDupPag()
			loop
		endif
        if !Confirm("Confirma a Alteracao")
            loop
        endif
        GravarDupPag(.f.)
   enddo
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
procedure ExcDupPag
   local getlist := {},cTela := SaveWindow()
   local cChave,cCodFor,cNumDup,dDtaEmi,dDtaVen,nValDup,cDocume,cObsDoc
   private xBaixa := .t.
   
	if !AbrirArquivos()
		return
	endif
   AtivaF4()
   TelDupPag(3,1)
   while .t.
      cChave  := space(05)
      cCodFor := space(04)
      cNumDup := space(12)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 08,21 get cCodFor picture "@k 9999";
      			when Rodape("Esc-Encerra | F4-Fornecedores");
      			valid Busca(Zera(@cCodFor),"Fornecedor",1,08,26,"Fornecedor->RazFor",{"Fornecedor Nao Cadastrado"},.f.,.f.,.f.)
      @ 09,21 get cNumDup picture "@k" when Rodape("Esc-Encerra") valid xDupPaga(@cNumDup,cCodFor) .and. Busca(cCodFor+cNumDup,"DupPag",1,,,,{"Duplicata Nao Cadastrada"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !empty(DupPag->DtaPag)
         Mens({"Duplicata ja foi dado baixa"})
         loop
      end
      @ 10,21 say DupPag->Docume picture "@k!"
      @ 11,21 say DupPag->DtaEmi picture "@k"
      @ 12,21 say DupPag->DtaVen picture "@k"
      @ 13,21 say DupPag->ValDup picture "@ke 999,999.99"
      @ 14,21 say DupPag->ObsDoc picture "@k!"
      if !Confirm("Confirma a Exclusao")
         loop
      end
      while !DupPag->(Trava_Reg())
      end
      DupPag->(dbdelete())
      DupPag->(dbcommit())
      DupPag->(dbunlock())
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
procedure BxaDupPag  // ** Baixa da duplicata
   local getlist := {},cTela := SaveWindow()
   local cCodFor,nValPag,dDtaPag,nValJur,nValDes,cObsBai
   local aCampo := {},aTitulo := {},aMascara := {},nI
   private aTipoCo := {},aCodBco := {},aCodAge := {},aCodCon := {},aNumChq := {}
   private aDtaVen := {},aValPag := {},xBaixa := .t.,cLanCxa,cNumDup

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenCidades()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenFornecedor()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenDupPag()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenCheques()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenSequencia()
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
   restore from (Arq_Sen)+"a" additive
   TelDupPag(4,2)
   while .t.
      cCodFor := space(04)
      cNumDup := space(12)
      nValPag := 0
      dDtaPag := date()
      nValJur := 0
      nValDes := 0
      cObsBai := space(50)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 04,14 get cCodFor picture "@k 9999";
      			when Rodape("Esc-Encerra | F4-Fornecedores");
      			valid Busca(Zera(@cCodFor),"Fornecedor",1,04,22,"Fornecedor->RazFor",{"Fornecedor Nao Cadastrado"},.f.,.f.,.f.)
      @ 05,14 get cNumDup picture "@k" when Rodape("Esc-Encerra") valid xDupPaga(@cNumDup,cCodFor) .and. Busca(cCodFor+cNumDup,"DupPag",1,,,,{"Duplicata Nao Cadastrada"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !empty(DupPag->DtaPag)
         Mens({"Duplicata ja foi dado baixa"})
         loop
      end
      @ 06,14 say DupPag->Docume picture "@k!"
      @ 06,41 say DupPag->DtaEmi picture "@k"
      @ 07,14 say DupPag->DtaVen picture "@k"
      @ 07,41 say DupPag->ValDup picture "@ke 999,999.99"
      // ******************************
      @ 08,14 get nValJur picture "@ke 999,999.99"
      @ 09,14 get nValDes picture "@ke 999,999.99" valid vDesc(nValJur,nValDes,DupPag->ValDup,09,41)
      @ 10,14 get nValPag picture "@ke 999,999.99" valid NoEmpty(nValPag)
      @ 10,41 get dDtaPag picture "@k" valid NoEmpty(dDtaPag)
      @ 11,14 get cObsBai picture "@k!"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      end
      aTipoCo  := {}
      aCodBco  := {}
      aCodAge  := {}
      aCodCon  := {}
      aNumChq  := {}
      aDtaVen  := {}
      aValPag  := {}
      // ******************************
      aadd(aTipoCo,space(01))
      aadd(aCodBco,space(03))
      aadd(aCodAge,space(04))
      aadd(aCodCon,space(15))
      aadd(aNumChq,space(10))
      aadd(aDtaVen,ctod(space(08)))
      aadd(aValPag,0)
      // ******************************
      aCampo   := {"aTipoCo","aCodBco","aCodAge","aCodCon" ,"aNumChq"  ,"aDtaVen"   ,"aValPag"}
      aTitulo  := {"Tipo"   ,"Banco"  ,"Agencia","Nõ Conta","Nõ Cheque","Vencimento","Vlr. Pago"}
      aMascara := {"@!"     ,"999"    ,"@!"     ,"@!"      ,"@!"       ,"@!"        ,"@e 999,999.99" }
      Rodape("F2-Confirma | F4-Inclui | F6-Exclui | F8-Abandona")
      lGrava := .f.
      while .t.
         Edita_Vet(13,01,21,78,aCampo,aTitulo,aMascara,"vBaixaPag",,.t.,,2)
         if lastkey() == K_F2
            if !(Soma_Vetor(aValPag) == nValPag)
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
      if !Confirm("Confirma a Baixa da Duplicata")
         loop
      end
      while !DupPag->(Trava_Reg())
      end
      DupPag->ValPag := nValPag
      DupPag->DtaPag := dDtaPag
      DupPag->ValJur := nValJur
      DupPag->ValDes := nValDes
      DupPag->ObsBai := cObsBai
      DupPag->(dbcommit())
      DupPag->(dbunlock())
      Grava_Log(cDiretorio,"Dupl.A Pagar|Baixa|Duplicata "+cNumDup,DupPag->(recno()))
      for nI := 1 to len(aTipoCo)
         if !empty(aTipoCo[nI])
            // ** LanÎamento automÿtico para o caixa
            LancMovCxa(@cLanCxa,dDtaPag,cACodCxa,cACodHis,aNumChq[nI],aCodBco[nI],aCodAge[nI],aCodCon[nI],aValPag[nI],aTipoCo[nI])
            // **
            if aTipoCo[nI] == "2"
               if Cheques->(dbsetorder(1),dbseek(aCodBco[nI]+aCodAge[nI]+aCodCon[nI]+aNumChq[nI]))
                  while !Cheques->(Trava_Reg())
                  end
                  Cheques->SitChq2 := Cheques->SitChq
                  Cheques->DtaDev2 := Cheques->DtaDev
                  Cheques->DtaDev  := ctod(space(08))
                  Cheques->SitChq  := "2"
                  Cheques->DtaPag  := dDtaPag
                  Cheques->ValPag  := Cheques->ValChq
                  Cheques->(dbcommit())
                  Cheques->(dbunlock())
               end
            end
            while !BxaDupPa->(Adiciona())
            end
            BxaDupPa->CodFor    := cCodFor
            BxaDupPa->NumDup    := cNumDup
            BxaDupPa->CodBco    := aCodBco[nI]
            BxaDupPa->CodAge    := aCodAge[nI]
            BxaDupPa->CodCon    := aCodCon[nI]
            BxaDupPa->NumChq    := aNumChq[nI]
            BxaDupPa->TipoCobra := aTipoCo[nI]
            BxaDupPa->ValPag    := aValPag[nI]
            BxaDupPa->DtaPag    := dDtaPag
            BxaDupPa->LanCxa    := cLanCxa
            BxaDupPa->(dbcommit())
            BxaDupPa->(dbunlock())
         end
      next
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
procedure CbxDupPag  // ** Cancelamento de Dupl. a Pagar
   local getlist := {},cTela := SaveWindow()
   local cCodFor,cNumDup,nValPag,dDtaPag,nValJur,nValDes,cObsBai
   local aCampo := {},aTitulo := {},aMascara := {}
   private xBaixa := .t.
   private aTipoCo := {},aCodBco := {},aCodAge := {},aCodCon := {},aNumChq := {}
   private aEmiten := {},aDtaEmi := {},aDtaVen := {},aValDup := {},aValPag := {}
   private aDtaPag := {}

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenCidades()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenFornecedor()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenDupPag()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenBxaDupPa()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenCheques()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenSequencia()
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
   restore from (Arq_Sen)+"a" additive
   TelDupPag(5,2)
   while .t.
      cCodFor := space(04)
      cNumDup := space(12)
      nValPag := 0
      dDtaPag := date()
      nValJur := 0
      nValDes := 0
      cObsBai := space(50)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 04,14 get cCodFor picture "@k 9999";
      			when Rodape("Esc-Encerra | F4-Fornecedores");
      			valid Busca(Zera(@cCodFor),"Fornecedor",1,04,22,"Fornecedor->RazFor",{"Fornecedor Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      @ 05,14 get cNumDup picture "@k" when Rodape("Esc-Encerra") valid xDupPaga2(@cNumDup,cCodFor) .and. Busca(cCodFor+cNumDup,"DupPag",1,,,,{"Duplicata Nao Cadastrada"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      end
      // ** Verifica se o movimento do caixa esta aberto
      if !vDataMov(DupPag->DtaPag)
         loop
      end
      @ 06,14 say DupPag->Docume picture "@k!"
      @ 06,41 say DupPag->DtaEmi picture "@k"
      @ 07,14 say DupPag->DtaVen picture "@k"
      @ 07,41 say DupPag->ValDup picture "@ke 999,999.99"
      @ 08,14 say DupPag->ValJur picture "@ke 999,999.99"
      @ 09,14 say DupPag->ValDes picture "@ke 999,999.99"
      @ 10,14 say DupPag->ValPag picture "@ke 999,999.99"
      @ 10,41 say DupPag->DtaPag picture "@k"
      @ 11,14 say DupPag->ObsBai picture "@k!"
      VerBxaPag()
      if !Confirm("Confirma o Cancelamento da Baixa",2)
         loop
      end
      BxaDupPa->(dbsetorder(1),dbseek(DupPag->CodFor+DupPag->NumDup))
      while BxaDupPa->CodFor == DupPag->CodFor .and. BxaDupPa->NumDup == DupPag->NumDup .and. BxaDupPa->(!eof())
         if MovCaixa->(dbsetorder(1),dbseek(BxaDupPa->LanCxa))
            if Caixa->(dbsetorder(1),dbseek(MovCaixa->CodCaixa))
               while !Caixa->(Trava_Reg())
               end
               Caixa->SldCaixa += MovCaixa->Valor
               Caixa->(dbcommit())
               Caixa->(dbunlock())
            end
            while !MovCaixa->(Trava_Reg())
            end
            MovCaixa->(dbdelete())
            MovCaixa->(dbcommit())
            MovCaixa->(dbunlock())
         end
         if BxaDupPa->TipoCobra == "2"
            if Cheques->(dbsetorder(1),dbseek(BxaDupPa->CodBco+BxaDupPa->CodAge+BxaDupPa->CodCon+BxaDupPa->NumChq))
               while !Cheques->(Trava_Reg())
               end
               Cheques->DtaDev  := ctod(space(08))
               Cheques->SitChq  := "1"
               Cheques->DtaPag  := ctod(space(08))
               Cheques->ValPag  := 0
               Cheques->(dbcommit())
               Cheques->(dbunlock())
            end
         end
         while !BxaDupPa->(Trava_Reg())
         end
         BxaDupPa->(dbdelete())
         BxaDupPa->(dbcommit())
         BxaDupPa->(dbunlock())
         BxaDupPa->(dbskip())
      end
      while !DupPag->(Trava_Reg())
      end
      DupPag->ValPag := 0
      DupPag->DtaPag := ctod(space(08))
      DupPag->ValJur := 0
      DupPag->ValDes := 0
      DupPag->ObsBai := space(50)
      DupPag->(dbcommit())
      DupPag->(dbunlock())
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
static procedure verDupPag

   setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
   @ 10,16 say DupPag->Docume picture "@k!"
   @ 11,16 say DupPag->DtaEmi picture "@k"
   @ 12,16 say DupPag->DtaVen picture "@k"
   @ 13,16 say DupPag->ValDup picture "@ke 999,999.99"
   return
// ****************************************************************************
static procedure VerBxaPag
   local nLinha := 15

   setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
   scroll(nLinha,06,22,06,0)
   scroll(nLinha,11,22,13,0)
   scroll(nLinha,17,22,20,0)
   scroll(nLinha,25,22,39,0)
   scroll(nLinha,41,22,50,0)
   scroll(nLinha,52,22,61,0)
   scroll(nLinha,63,22,71,0)
   BxaDupPa->(dbsetorder(1),dbseek(DupPag->CodFor+DupPag->NumDup))
   while BxaDupPa->CodFor == DupPag->CodFor .and. BxaDupPa->NumDup == DupPag->NumDup .and. BxaDupPa->(!eof())
      Cheques->(dbsetorder(1),dbseek(BxaDupPa->CodBco+BxaDupPa->CodAge+BxaDupPa->CodCon+BxaDupPa->NumChq))
      @ nLinha,06 say BxaDupPa->TipoCobra
      @ nLinha,11 say BxaDupPa->CodBco
      @ nLinha,17 say BxaDupPa->CodAge
      @ nLinha,25 say BxaDupPa->CodCon
      @ nLinha,41 say BxaDupPa->NumChq
      @ nLinha,52 say Cheques->DtaVen
      @ nLinha,63 say BxaDupPa->ValPag picture "@e 999,999.99"
      BxaDupPa->(dbskip())
      nLinha += 1
      if nLinha >= 22
         exit
      end
   end
   return
// ****************************************************************************
procedure TelDupPag(nModo,nTipo)
   local aTitulos := {"Inclusao","Alteracao","Exclusao","Efetua Baixa","Cancela Baixa","Visualizacao"}
   local nI := 0

   if nTipo == 1
      Window(06,07,16,72,"> " + aTitulos[ nModo ] + " de Duplicata a Pagar <")
      setcolor(Cor(11))
      //           4567890123456789012345678901234567890123456789012345678
      //                 1         2         3         4         5         6         7
      @ 08,09 say "Fornecedor:"
      @ 09,09 say " Duplicata:"
      @ 10,09 say " Documento:"
      @ 11,09 say "   Emissao:"
      @ 12,09 say "Vencimento:"
      @ 13,09 say "     Valor:"
      @ 14,09 say "Observacao:"
   elseif nTipo == 2
      Window(02,00,23,79,"> "+aTitulos[nModo]+" de Duplicata a Pagar <")
      setcolor(Cor(11))
      //           234567890123456789012345678901234567890123456789012345678
      //                   1         2         3         4         5         6         7
      @ 04,02 say "Fornecedor:"
      @ 05,02 say " Duplicata:"
      @ 06,02 say " Documento:                   Emissao:"
      @ 07,02 say "Vencimento:                     Valor:"
      @ 08,02 say "     Juros:"
      @ 09,02 say "  Desconto:                 Vlr.Total:"
      @ 10,02 say "  Vlr.Pago:               Data Pagto.:"
      @ 11,02 say "Observacao:"
      @ 12,01 say TracoCentro("[ Informacoes para a Baixa ]",78,chr(196))
//    @ 12,01 say "1234567890123456789012345678901234567890123456789012345678901234567890"
      //                    1         2         3         4         5         6
      @ 13,01 say "     Tipo Banco Agencia Nõ Conta        Nõ Cheque  Vencimento Vlr. Pago"
      @ 14,01 say replicate(chr(196),78)
      @ 14,10 say chr(194)
      @ 14,16 say chr(194)
      @ 14,24 say chr(194)
      @ 14,40 say chr(194)
      @ 14,51 say chr(194)
      @ 14,62 say chr(194)
      for nI := 15 to 22
         @ nI,10 say chr(179)
         @ nI,16 say chr(179)
         @ nI,24 say chr(179)
         @ nI,40 say chr(179)
         @ nI,51 say chr(179)
         @ nI,62 say chr(179)
      next
   end
   return
// ****************************************************************************
function xDupPaga(cNumDup,nCodFor)
   Local cCor := setcolor(),aVetor1,aVetor2,cTela,nI
   local aCampo  := {},aTitulo := {},aMascara := {}
   local cQuery,oQuery
   private aDupl := {},aEmissao := {},aVenc := {},aValor := {},aDocu := {}
   Private nPos

   if !xbaixa
       return !empty(cNumDup)
   endif
   if empty(cNumDup)
       cQuery := "SELECT  duplicata,docume,dtaemi,dtaven,valdup "
       cQuery += "FROM financeiro.duplicatas_apagar " 
       cQuery += "WHERE idfornecedor = "+NumberToSql(nCodFor)
       cQuery += " AND dtapag IS NULL "
       cQuery += "ORDER BY dtaven"
       Msg(.t.)
       Msg("Aguarde: pesquisando duplicatas")
       if !ExecuteSql(cQuery,@oQuery,{"Falha: pesquisa duplicata(s)"},"sqlerro")
           oQuery:close()
           Msg(.f.)
           return(.f.)
       endif
       if oQuery:Lastrec() = 0
           Msg(.f.)
           Mens({"N’o existe duplicatas a pagar"})
           oQuery:Close()
           return(.f.)
       endif
       do while !oQuery:eof()
           aadd(aDupl   ,oQuery:fieldget('duplicata'))
           aadd(aDocu   ,oQuery:fieldget('docume'))
           aadd(aEmissao,oQuery:fieldget('dtaemi'))
           aadd(aVenc   ,oQuery:fieldget('dtaven'))
           aadd(aValor  ,oQuery:fieldget('ValDup'))
           oQuery:skip(1)
       Enddo
       Msg(.f.)
       if len(aDupl) == 1
           cNumDup := aDupl[1]
           return(.t.)
       endif
     aCampo   := {"aDupl"    ,"aDocu"    ,"aEmissao","aVenc"    ,"aValor"}
     aTitulo  := {"Duplicata","Documento","Emissao","Vencimento","Valor"}
     aMascara := {"@!"       ,"@!"       ,"@!"     ,"@!"        ,"@e 9,999,999.99"}
     cTela := SaveWindow()
     Rodape("Esc-Encerra | ENTER-Seleciona")
     Window(02,02,31,90,"> Selecao de Duplicatas <")
     @ 31,66 say " Total: "+transform(Soma_Vetor(aValor),"@e 9,999,999.99")
     Edita_Vet(03,03,30,89,aCampo,aTitulo,aMascara, [XAPAGARU],,,5)
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
Function vBaixaPag( Pos_H, Pos_V, Ln, Cl, Tecla )
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
               keyboard replicate(chr(K_RIGHT),6)+chr(K_ENTER)
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
         if lastkey() == K_ESC
            cLimpa(Pos_V)
         else
            aCodBco[pos_v] := cCampo
            keyboard chr(K_RIGHT)+chr(K_ENTER)
         end
         return(2)
      // ** Agencia
      elseif Pos_H == 3 .and. aTipoCo[Pos_V] == "2"
         cCampo := aCodAge[pos_v]
         @ ln,Cl get cCampo picture "@k 9999" valid V_Zera(@cCampo)
         setcursor(SC_NORMAL)
         read
         setcursor(SC_NONE)
         if lastkey() == K_ESC
            cLimpa(Pos_V)
         else
            aCodAge[pos_v] := cCampo
            keyboard chr(K_RIGHT)+chr(K_ENTER)
         end
         return(2)
      // ** Conta
      elseif Pos_H == 4 .and. aTipoCo[Pos_V] == "2"
         cCampo := aCodCon[pos_v]
         @ ln,Cl get cCampo picture "@k!" valid Busca(aCodBco[Pos_V]+aCodAge[Pos_V]+cCampo,"Cheques",2,,,,{"Banco/Agencia/Conta N’o Cadastrado"},.f.,.f.,.f.)
         setcursor(SC_NORMAL)
         read
         setcursor(SC_NONE)
         if lastkey() == K_ESC
            cLimpa(Pos_V)
         else
            aCodCon[pos_v] := cCampo
            keyboard chr(K_RIGHT)+chr(K_ENTER)
         end
         return(2)
      // ** Cheque
      elseif Pos_H == 5 .and. aTipoCo[Pos_V] == "2"
         cCampo := aNumChq[pos_v]
         @ ln,Cl get cCampo picture "@k!" valid Busca(aCodBco[Pos_V]+aCodAge[Pos_V]+aCodCon[Pos_V]+cCampo,"Cheques",1,,,,{"Cheque N’o Cadastrado"},.f.,.f.,.f.)
         setcursor(SC_NORMAL)
         read
         setcursor(SC_NONE)
         if lastkey() == K_ESC
            cLimpa(Pos_V)
         else
            aNumChq[Pos_V] := cCampo
            aDtaVen[Pos_V] := Cheques->DtaVen
            aValPag[Pos_V] := Cheques->ValChq
            keyboard chr(K_RIGHT)+chr(K_ENTER)
         end
         return(2)
      // ** Data de Vencimento
      elseif Pos_H == 6 .and. aTipoCo[Pos_V] == "2"
         cCampo := aDtaVen[pos_v]
         @ ln,Cl get cCampo picture "@k" when empty(cCampo)
         setcursor(SC_NORMAL)
         read
         setcursor(SC_NONE)
         if lastkey() == K_ESC
            cLimpa(Pos_V)
         else
            aDtaVen[Pos_V] := cCampo
            keyboard chr(K_RIGHT)+chr(K_ENTER)
         end
         return(2)
      // ** Valor Pago
      elseif Pos_H == 7
         cCampo := aValPag[pos_v]
         @ ln,Cl get cCampo picture "@ke 999,999.99"
         setcursor(SC_NORMAL)
         read
         setcursor(SC_NONE)
         if lastkey() == K_ESC
            cLimpa(Pos_V)
         else
            aValPag[Pos_V] := cCampo
         end
         return(2)
      end
   elseif Tecla == K_F4
      if !Confirm("Incluir Novo LanÎamento")
         return(0)
      end
      if !empty(aTipoCo[pos_v])
         nItens := len(aTipoCo)+1
         asize(aTipoCo,nItens)
         asize(aCodBco,nItens)
         asize(aCodAge,nItens)
         asize(aCodCon,nItens)
         asize(aNumChq,nItens)
         asize(aDtaVen,nItens)
         asize(aValPag,nItens)
         // ****************************
         ains(aTipoCo,Pos_V+1)
         ains(aCodBco,Pos_V+1)
         ains(aCodAge,Pos_V+1)
         ains(aCodCon,Pos_V+1)
         ains(aNumChq,Pos_V+1)
         ains(aDtaVen,Pos_V+1)
         ains(aValPag,Pos_V+1)
         // ****************************
         aTipoCo[Pos_V+1] := space(01)
         aCodBco[Pos_V+1] := space(03)
         aCodAge[Pos_V+1] := space(04)
         aCodCon[Pos_V+1] := space(15)
         aNumChq[Pos_V+1] := space(10)
         aDtaVen[Pos_V+1] := ctod(space(08))
         aValPag[Pos_V+1] := 0
         keyboard chr(K_DOWN)+replicate(chr(K_LEFT),Pos_H-1)+chr(K_ENTER)
         return( 3 )
      end
   elseif Tecla == K_F6
      if !Confirm("Excluir LanÎamento")
         return(0)
      end
      if len(aTipoCo) == 1
         aTipoCo[Pos_V] := space(01)
         aCodBco[Pos_V] := space(03)
         aCodAge[Pos_V] := space(04)
         aCodCon[Pos_V] := space(15)
         aNumChq[Pos_V] := space(10)
         aDtaVen[Pos_V] := ctod(space(08))
         aValPag[Pos_V] := 0
         return(3)
      end
      adel(aTipoCo,Pos_V)
      adel(aCodBco,Pos_V)
      adel(aCodAge,Pos_V)
      adel(aCodCon,Pos_V)
      adel(aNumChq,Pos_V)
      adel(aDtaVen,Pos_V)
      adel(aValPag,Pos_V)
      // ***************************
      nItens := len(aTipoCo)-1
      asize(aTipoCo,nItens)
      asize(aCodBco,nItens)
      asize(aCodAge,nItens)
      asize(aCodCon,nItens)
      asize(aNumChq,nItens)
      asize(aDtaVen,nItens)
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
// ****************************************************************************
static procedure cLimpa(nPosicao)

   aTipoCo[nPosicao] := space(01)
   aCodBco[nPosicao] := space(03)
   aCodAge[nPosicao] := space(04)
   aCodCon[nPosicao] := space(15)
   aNumChq[nPosicao] := space(10)
   aDtaVen[nPosicao] := ctod(space(08))
   aValPag[nPosicao] := 0
   return
// ****************************************************************************
static procedure VerBaixa(cCodFor,cNumDup)
   local cTela := SaveWindow(),aTitulo := {},aCampo := {},aMascara := {}
   private aTipoCobra := {},aCodBco := {},aNumAge := {},aNumCon := {},aNumChq := {}
   private aNomCon    := {},aDtaVen := {},aValPag := {}

   if !BxaDupPa->(dbsetorder(1),dbseek(cCodFor+cNumDup))
      Mens({"Nao Existe Baixa"})
      return
   end
   while BxaDupPa->CodFor == cCodFor .and. BxaDupPa->NumDup == cNumDup .and. BxaDupPa->(!eof())
      if BxaDupPa->TipoCobra == "1"
         aadd(aTipoCobra,"Dinheiro")
      elseif BxaDupPa->TipoCobra == "2"
         aadd(aTipoCobra,"Cheque  ")
      elseif BxaDupPa->TipoCobra == "3"
         aadd(aTipoCobra,"Deposito")
      end
      Cheques->(dbsetorder(1),dbseek(BxaDupPa->CodBco+BxaDupPa->CodAge+BxaDupPa->CodCon+BxaDupPa->NumChq))
      aadd(aCodBco,BxaDupPa->CodBco)
      aadd(aNumAge,BxaDupPa->CodAge)
      aadd(aNumCon,BxaDupPa->CodCon)
      aadd(aNumChq,BxaDupPa->NumChq)
      if Banco->(dbsetorder(1),dbseek(BxaDupPa->CodBco+BxaDupPa->CodAge+BxaDupPa->CodCon))
         aadd(aNomCon,Banco->NomCon)
      else
         aadd(aNomCon,space(30))
      end
      aadd(aDtaVen,Cheques->DtaVen)
      aadd(aValPag,BxaDupPa->ValPag)
      BxaDupPa->(dbskip())
   end
   if len(aTipoCobra) > 0
      aTitulo  := {"Tipo"      ,"Banco"  ,"Agencia","Nõ Conta","Nõ Cheque","Emitente","Vencimento","Valor Pago"}
      aCampo   := {"aTipoCobra","aCodBco","aNumAge","aNumCon" ,"aNumChq"  ,"aNomCon" ,"aDtaVen"   ,"aValPag"}
      aMascara := {"@!"        ,"@!"     ,"@!"     ,"@!"      ,"@!"       ,"@!"      ,"@!"        ,"@e 999,999.99"}
      Window(12,00,23,79," Lista de Baixas ")
      Edita_Vet(13,01,22,78,aCampo,aTitulo,aMascara,"VerBaixa2",,.t.,,)
      RestWindow(cTela)
   end
   return
// ****************************************************************************
// ** LanÎamento Automÿtico no Caixa
static procedure LancMovCxa(cLanCxa,dDtaMov,cCodCaixa,cCodHist,cNumChq,cCodBco,cNumAge,cNumCon,nValor,cTipo)

   if !empty(cCodCaixa) .and. !empty(cCodHist)
      if Caixa->(dbsetorder(1),dbseek(cCodCaixa))
         HistCxa->(dbsetorder(1),dbseek(cCodHist))
         while !Sequencia->(Trava_Reg())
         end
         Sequencia->LancMovCxa += 1
         Sequencia->(dbunlock())
         cLanCxa := strzero(Sequencia->LancMovCxa,6)
         while !MovCaixa->(Adiciona())
         end
         MovCaixa->Lancamento := cLanCxa
         MovCaixa->Data       := dDtaMov
         MovCaixa->CodCaixa   := cCodCaixa
         MovCaixa->CodHisto   := cCodHist
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
         Caixa->SldCaixa -= MovCaixa->Valor
         Caixa->(dbcommit())
         Caixa->(dbunlock())
      end
   end
   return
// ****************************************************************************
procedure ConfLancAx // Configura o Lancamento no Caixa
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
   restore from (Arq_Sen)+"a" additive
   AtivaF4()
   Window(09,14,14,64," Conf. Lanc. no Caixa ")
   setcolor(Cor(11))
   //           67890123456789012345678901234567890123456789012345678
   //               2         3         4         5         6         7
   @ 11,16 say "    Caixa:"
   @ 12,16 say "Historico:"
   while .t.
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,27 get cACodCxa picture "@k 99" when Rodape("Esc-Encerra | F4-Caixas") valid Busca(Zera(@cACodCxa),"Caixa",1,11,31,"Caixa->NomCaixa",{"Caixa Nao Cadastrado"},.f.,.f.,.f.)
      @ 12,27 get cACodHis picture "@k 999" when Rodape("Esc-Encerra | F4-Historicos") valid Busca(Zera(@cACodHis),"Historico",1,12,31,"Historico->NomHist",{"Historic Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
      save to (Arq_Sen)+"a" all like cACod*
      exit
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
Function xDupPaga2(cNumDup,cCodFor) // ** Mostra as duplicatas ja pagas
   Local cCor := setcolor(),aVetor1,aVetor2,cTela,nI
   local aCampo  := {},aTitulo := {},aMascara := {}
   private aDupl   := {},aEmissao := {},aVenc := {},aValor := {},aDocu := {}
   Private aDtaPag := {},nPos

   if !xbaixa
      return !empty(cNumDup)
   end
   if empty(cNumDup)
      if !DupPag->(dbseek(cCodFor))
         Mens({"Nao Existe Duplicatas"})
         return(.f.)
      end
      while DupPag->CodFor == cCodFor .and. DupPag->(!eof())
         if !empty(DupPag->DtaPag)
            aadd(aDupl   ,DupPag->NumDup)
            aadd(aDocu   ,DupPag->Docume)
            aadd(aEmissao,DupPag->DtaEmi)
            aadd(aVenc   ,DupPag->DtaVen)
            aadd(aDtaPag ,DupPag->DtaPag)
            aadd(aValor  ,DupPag->ValDup)
         Endif
         DupPag->(dbskip())
      Enddo
      if len(aDupl) == 0
         Mens({"Nao Existe Duplicatas a Baixadas"})
         return(.f.)
      end
      if len(aDupl) == 1
         cNumDup := aDupl[1]
         return(.t.)
      end
      aVetor1 := {}
      for nI := 1 to len(aDupl)
         aadd(aVetor1,{aDupl[nI],aDocu[nI],aEmissao[nI],aVenc[nI],aDtaPag[nI],aValor[nI]})
      next
      aVetor2   := asort(aVetor1,,,{|x,y| x[5] < y[5]})
      aDupl     := {}
      aDocu     := {}
      aEmissao  := {}
      aVenc     := {}
      aDtaPag   := {}
      aValor    := {}
      for nI := 1 to len(aVetor2)
         aadd(aDupl    ,aVetor2[nI][1])
         aadd(aDocu    ,aVetor2[nI][2])
         aadd(aEmissao ,aVetor2[nI][3])
         aadd(aVenc    ,aVetor2[nI][4])
         aadd(aDtaPag  ,aVetor2[nI][5])
         aadd(aValor   ,aVetor2[nI][6])
      next
      aCampo   := {"aDupl"    ,"aDocu"    ,"aEmissao","aVenc"    ,"aDtaPag"  ,"aValor"}
      aTitulo  := {"Duplicata","Documento","Emissao","Vencimento","Pagamento","Valor"}
      aMascara := {"@!"       ,"@!"       ,"@!"     ,"@!"        ,"@!"       ,"@e 999,999.99"}
      cTela := SaveWindow()
      Rodape("Esc-Encerra | ENTER-Seleciona")
      Window(02,05,23,79,chr(16)+" Selecao de Duplicatas "+chr(17))
      @ 23,57 say space(20)
      @ 23,57 say " Total: "+transform(Soma_Vetor(aValor),"@e 999,999.99")
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
static function AbrirArquivos

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenCidades()
      FechaDados()
      Msg(.f.)
      return(.f.)
   endif
   if !OpenFornecedor()
      FechaDados()
      Msg(.f.)
      return(.f.)
   endif
	if !OpenDupPag()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
   Msg(.f.)
   return(.t.)
   
static function GetDupPag
   @ 10,21 get cDocume picture "@k!"
   @ 11,21 get dDtaEmi picture "@k"
   @ 12,21 get dDtaVen picture "@k" valid NoEmpty(dDtaVen) .and. dDtaVen >= dDtaEmi
   @ 13,21 get nValDup picture "@ke 999,999.99" valid NoEmpty(nValDup)
   @ 14,21 get cObsDoc picture "@k!"
   setcursor(SC_NORMAL)
   read
   setcursor(SC_NONE)
	if lastkey() == K_ESC
		return(.f.)
	endif
return(.t.)
	
static procedure GravarDupPag(lIncluir)

	if lIncluir
      cQuery := "INSERT INTO financeiro.duplicatas_apagar (idfornecedor,duplicata,docume,dtaemi,dtaven,valdup,obsdoc) "
      cQuery += "VALUES ("+NumberToSql(nIdFornecedor)+","+StringToSql(cDuplicata)+","+StringToSql(cDocume)+","
      cQuery += DateToSql(dDtaEmi)+","+DateToSql(dDtaVen)+","+NumberToSql(nValDup,12,2)+","+StringToSql(cObsDoc)+")"
	endif
return

   

// ** Fim do Arquivo.
