/*************************************************************************
 *       Sistema: Administrativo
 * Identifica‡Æo: Manuten‡Æo de Cheques
 *       Prefixo: LtAdm
 *      Programa: Cheques.prg
 *         Autor: Andre Lucas Souza
 *          Data: 17 de Novembro de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConCheques(lAbrir)
   local oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow()
   local cDados,nCursor := setcursor(),cCor := setcolor()
   private nRecno

   if lAbrir
      Msg(.t.)
      Msg("Aguarde : Abrindo o Arquivo")
        if !OpenCheques()
            FechaDados()
            Msg(.f.)
            return
        endif
        if !OpenBanco()
            FechaDados()
            Msg(.f.)
            return
        endif
        if !OpenClientes()
            FechaDados()
            Msg(.f.)
            return
        endif
        if !OpenNegociad()
            FechaDados()
            Msg(.f.)
            return
        endif
        if !OpenItemNego()
            FechaDados()
            Msg(.f.)
            return
        endif
      Msg(.f.)
   else
      setcursor(SC_NONE)
   end
   select Cheques
   Cheques->(dbsetorder(13),dbgotop())
   Rodape(iif(lAbrir,"Esc-Encerrar","Esc-Encerra | ENTER-Transfere"))
   setcolor(cor(5))
   Window(02,00,23,79,chr(16)+" Consulta de Cheques "+CHR(17))
   oBrow := TBrowseDB(03,01,19,78)

   oBrow:headSep := "ÂÄ"
   oBrow:footSep := "ÁÄ"
   oBrow:colSep  := "³"

   oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)
   oColuna := tbcolumnnew("Lanc.",{|| Cheques->LanChe })
   oColuna:colorblock := {|| iif(Cheques->SitChq == "2",{3,2},{1,2})}
   oBrow:addcolumn(oColuna)

   oColuna := TBColumnNew("Bco.",{|| Cheques->CodBco })
   oColuna:colorblock := {|| iif(Cheques->SitChq == "2",{3,2},{1,2})}
   oBrow:addcolumn(oColuna)

   oColuna := TBColumnNew("Agˆncia",{|| Cheques->NumAge })
   oColuna:colorblock := {|| iif(Cheques->SitChq == "2",{3,2},{1,2})}
   oBrow:addcolumn(oColuna)

   oColuna := TBColumnNew("N§ Conta",{|| Cheques->NumCon })
   oColuna:colorblock := {|| iif(Cheques->SitChq == "2",{3,2},{1,2})}
   oBrow:addcolumn(oColuna)

   oColuna := TBColumnNew("N§ Cheque",{|| Cheques->NumChq })
   oColuna:colorblock := {|| iif(Cheques->SitChq == "2",{3,2},{1,2})}
   oBrow:addcolumn(oColuna)

   oColuna := TBColumnNew("Correnstista",{|| Banco->(dbsetorder(1),dbseek(Cheques->CodBco+Cheques->NumAge+Cheques->NumCon),Banco->NomCon)})
   oColuna:colorblock := {|| iif(Cheques->SitChq == "2",{3,2},{1,2})}
   oBrow:addcolumn(oColuna)

   oColuna := TBColumnNew("Vencimento",{|| Cheques->DtaVen })
   oColuna:colorblock := {|| iif(Cheques->SitChq == "2",{3,2},{1,2})}
   oBrow:addcolumn(oColuna)

   oColuna := tbcolumnnew("Valor",{|| transform(Cheques->ValChq,"@e 999,999.99")})
   oColuna:colorblock := {|| iif(Cheques->SitChq == "2",{3,2},{1,2})}
   oBrow:addcolumn(oColuna)

   oColuna := tbcolumnnew("Sit.",{|| Cheques->SitChq })
   oColuna:colorblock := {|| iif(Cheques->SitChq == "2",{3,2},{1,2})}
   oBrow:addcolumn(oColuna)

   oColuna := tbcolumnnew("Situacao",{|| iif(Cheques->SitChq == "1","A Compensar",iif(Cheques->SitChq == "2","Compensado",iif(Cheques->SitChq == "3","Devolvido",iif(Cheques->SitChq == "5","Negociado",""))))})
   oColuna:colorblock := {|| iif(Cheques->SitChq == "2",{3,2},{1,2})}
   oBrow:addcolumn(oColuna)

   oColuna := tbcolumnnew("Devolvido",{|| Cheques->DtaDev })
   oColuna:colorblock := {|| iif(Cheques->SitChq == "2",{3,2},{1,2})}
   oBrow:addcolumn(oColuna)

   aTab := TabHNew(20,01,78,setcolor(cor(28)),1)
   TabHDisplay(aTab)
   setcolor(Cor(26))
   scroll(21,01,22,78,0)
   Centro(22,01,78,"F2-Visualizar | F3-Consulta")
   while (! lFim)
      while ( ! oBrow:stabilize() )
         nTecla := inkey()
         IF ( nTecla != 0 )
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
            lFim := .t.
         elseif nTecla == K_ENTER .and. !lAbrir
            cDados := Cheques->LanChe
            keyboard (cDados)+chr(K_ENTER)
            lFim := .t.
         elseif nTecla == K_F2
            VerCheques()
         elseif nTecla == K_F3
            Encontre()
            if !(nRecno == 0 )
               SetHilite(oBrow,nRecno)
            end
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
   RETURN
// ****************************************************************************
static procedure Encontre // Pesquisa de Clientes
   local getlist := {}
   local nOpcao := 1 , lTrue := .f. , nCont , cTela , nLin := 17
   local cBusca, cCor := setcolor()
   local nOrder := Cheques->(indexord())

   SaveVideo()
   begin sequence
   cTela := SaveWindow(nLin,00,nLin+4,79 )
   setcolor(Cor(11))
   Imp_Cen(nLin,00,79,"Pesquisa de Clientes",Cor(3), .t. )
   Quadro(nLin+1,00,nLin+4,79,[         ],4,Cor(2))
   scroll(nLin+2,10,nLin,75)
   //             45678901234567890
   setcolor(Cor(2))
   @ nLin+2,02 SAY [Ordem de Busca:]
   setcolor(Cor(2)+","+Cor(3))
   @ nLin+2,col()+1 prompt " Cheque "
   MENU TO nOpcao
   if nOpcao == 0
      nRecno := 0
   elseif nOpcao == 1   // C.G.C./C.P.F.
      cBusca := space(10)
      setcolor(Cor(2))
      scroll(nLin+2,01,nLin+2,75)
      //             0123456789012345678901234567890
      @ nLin+2,02 say "N§ Cheque:"
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ nLin+2,Col()+2 get cBusca picture "@k!"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         nRecno := 0
         break
      end
      if Cheques->(dbsetorder(13),dbseek(cBusca))
         nRecno := Cheques->(recno())
      else
         nRecno := 0
      end
   endif
   Cheques->(dbsetorder(nOrder))
   end sequence
   RestWindow( cTela )
   RestVideo()
   RETURN
// ****************************************************************************
procedure IncCheques
   local getlist := {},cTela := SaveWindow()
   local cCodBco,cNumAge,cNumCon,cNumChq,cNomCon,cCodCli,dDtaEmi,dDtaVen,nValChq
   local cObserv,lLimpa := .t.,cSitChq,dDtaDev,cLanc
   
   
	if !AbrirArquivos()
		return
	endif
   AtivaF4()
   TelCheques(1,1)
   while .t.
      if lLimpa
         cCodBco := space(03)
         cNumAge := space(04)
         cNumCon := space(15)
         cNumChq := space(10)
         cCodCli := space(04)
         dDtaEmi := ctod(space(08))
         dDtaVen := ctod(space(08))
         dDtaDev := ctod(space(08))
         nValChq := 0
         cObserv := space(40)
         cSitChq := space(01)
      end
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      if (Sequencia->LanChe+1) > 999999
         Mens({"Limite de Cheques Esgotado","Favor entrar em contato com o Programado"})
         exit
      end
      @ 06,24 say strzero(Sequencia->LanChe+1,6) picture "999999"
      @ 07,24 get cCodBco picture "@k 999"   when Rodape("Esc-Encerra | F4-Banco/Agencia/Conta") valid V_Bco(@cCodBco,.t.,07,28)
      @ 08,24 get cNumAge picture "@k"       when Rodape("Esc-Encerra") valid V_Zera(@cNumAge)
      @ 09,24 get cNumCon picture "@k"       valid iif(lastkey() == K_UP,.t.,vBcoNumAge(cCodBco,cNumAge,cNumCon,.t.,11,24))
      @ 10,24 get cNumChq picture "@k"       valid iif(lastkey() == K_UP,.t.,Busca(cCodBco+cNumAge+cNumCon+cNumChq,"Cheques",1,,,,{"Cheque Ja Cadastrado"},.f.,.f.,.t.))
      @ 10,48 get cSitChq picture "@k9"      valid MenuArray(@cSitChq,{{"1","A Compensar"},{"3","Devolvido  "}},10,48,10,50)
      @ 12,24 get cCodCli picture "@k 9999"  when Rodape("Esc-Encerra | F4-Clientes")  valid iif(empty(cCodCli),.t.,Busca(Zera(@cCodCli),"Clientes",1,12,29,"Clientes->NomCli",{"Cliente Nao Cadastrado"},.f.,.f.,.f.))
      @ 13,24 get dDtaEmi picture "@k"       when Rodape("Esc-Encerra")
      @ 14,24 get dDtaVen picture "@k"
      @ 14,48 get dDtaDev picture "@k"       when cSitChq == "3"
      @ 15,24 get nValChq picture "@ke 999,999.99"
      @ 16,24 get cObserv picture "@k!"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma a Inclusao")
         loop
      end
      while !Sequencia->(Trava_Reg())
      end
      Sequencia->LanChe += 1
      Sequencia->(dbunlock())
      cLanc := strzero(Sequencia->LanChe,6)
      @ 06,24 say cLanc
      
      while !Cheques->(Adiciona())
      end
      Cheques->LanChe := cLanc
      Cheques->CodBco := cCodBco
      Cheques->NumAge := cNumAge
      Cheques->NumCon := cNumCon
      Cheques->NumChq := cNumChq
      Cheques->SitChq := cSitChq
      Cheques->DtaEmi := dDtaEmi
      Cheques->DtaVen := dDtaVen
      Cheques->DtaDev := dDtaDev
      Cheques->ValChq := nValChq
      Cheques->CodCli := cCodCli
      Cheques->Observ := cObserv
      Cheques->(dbcommit())
      Cheques->(dbunlock())
      Grava_Log(cDiretorio,"Cheques|Incluir|Banco "+cCodBco+" Agencia "+cNumAge+" Conta "+cNumCon+" Cheque "+cNumChq,Cheques->(recno()))
      lLimpa := .t.
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
procedure AltCheques
   local getlist := {},cTela := SaveWindow()
   local cCodBco,cNumAge,cNumCon,cNumChq,cNomCon,cCodCli,dDtaEmi,dDtaVen,nValChq
   local cObserv,lLimpa := .t.,cSitChq,dDtaDev,cLanChe

   
	if !AbrirArquivos()
		return
	endif
   AtivaF4()
   TelCheques(2,1)
   while .t.
      cLanChe := space(06)
      cCodBco := space(03)
      cNumAge := space(04)
      cNumCon := space(15)
      cNumChq := space(10)
      cCodCli := space(04)
      dDtaEmi := ctod(space(08))
      dDtaVen := ctod(space(08))
      dDtaDev := ctod(space(08))
      cSitChq := space(1)
      nValChq := 0
      cObserv := space(40)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 06,24 get cLanChe picture "999999" when Rodape("Esc-Encerra | F4-Cheques") valid Busca(Zera(@cLanChe),"Cheques",9,,,,{"Lancamento Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !empty(Cheques->DtaPag)
         Mens({"Cheque Ja Baixado"})
         loop
      end
      if Cheques->SitChq == "5"
         Mens({"Cheque Negociado"})
         loop
      end
      V_Bco(Cheques->CodBco,.f.,07,28)
      vBcoNumAge(Cheques->CodBco,Cheques->NumAge,Cheques->NumCon,.t.,11,24)
      @ 07,24 say Cheques->CodBco picture "@k 999"
      @ 08,24 say Cheques->NumAge picture "@k"
      @ 09,24 say Cheques->NumCon
      @ 10,24 say Cheques->NumChq
      cSitChq := Cheques->SitChq
      cNomCon := Banco->NomCon
      cCodCli := Cheques->CodCli
      dDtaEmi := Cheques->DtaEmi
      dDtaVen := Cheques->DtaVen
      dDtaDev := Cheques->DtaDev
      nValChq := Cheques->ValChq
      cObserv := Cheques->Observ
      @ 10,48 get cSitChq picture "@k9" when Rodape("Esc-Encerra") valid MenuArray(@cSitChq,{{"1","A Compensar"},{"3","Devolvido  "}},10,48,10,50)
      @ 12,24 get cCodCli picture "@k 9999"  when Rodape("Esc-Encerra | F4-Clientes")  valid iif(empty(cCodCli),.t.,Busca(Zera(@cCodCli),"Clientes",1,12,29,"Clientes->NomCli",{"Cliente Nao Cadastrado"},.f.,.f.,.f.))
      @ 13,24 get dDtaEmi picture "@k" when Rodape("Esc-Encerra")
      @ 14,24 get dDtaVen picture "@k"
      @ 14,48 get dDtaDev picture "@k" when cSitChq == "3"
      @ 15,24 get nValChq picture "@ke 999,999.99"
      @ 16,24 get cObserv picture "@k!"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      end
      if !Confirm("Confirma a Altera‡Æo")
         loop
      end
      while !Cheques->(Trava_Reg())
      end
      Cheques->SitChq := cSitChq
      Cheques->DtaEmi := dDtaEmi
      Cheques->DtaVen := dDtaVen
      if cSitChq == "3"
         Cheques->DtaDev := dDtaDev
      else
         Cheques->DtaDev := ctod(space(08))
      end
      Cheques->ValChq := nValChq
      Cheques->CodCli := cCodCli
      Cheques->Observ := cObserv
      Cheques->(dbcommit())
      Cheques->(dbunlock())
      Grava_Log(cDiretorio,"Cheques|Alterar|Banco "+cCodBco+" Agencia "+cNumAge+" Conta "+cNumCon+" Cheque "+cNumChq,Cheques->(recno()))
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
procedure ExcCheques
   local getlist := {},cTela := SaveWindow()
   local cLanChe

 
	if !AbrirArquivos()
		return
	endif
   AtivaF4()
   TelCheques(3,1)
   while .t.
      cLanChe := space(06)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 06,24 get cLanChe picture "999999" when Rodape("Esc-Encerra | F4-Cheques") valid Busca(Zera(@cLanChe),"Cheques",9,,,,{"Lancamento Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !empty(Cheques->DtaPag)
         Mens({"Cheque Ja Baixado"})
         loop
      end
      if Cheques->SitChq == "5"
         Mens({"Cheque Negociado"})
         loop
      end
      V_Bco(Cheques->CodBco,.f.,07,28)
      vBcoNumAge(Cheques->CodBco,Cheques->NumAge,Cheques->NumCon,.t.,11,24)
      @ 07,24 say Cheques->CodBco picture "@k 999"
      @ 08,24 say Cheques->NumAge picture "@k"
      @ 09,24 say Cheques->NumCon
      @ 10,24 say Cheques->NumChq
      Clientes->(dbsetorder(1),dbseek(Cheques->CodCli))
      @ 10,48 say Cheques->SitChq
      MenuArray(Cheques->SitChq,{{"1","A Compensar"},{"3","Devolvido  "}},10,48,10,50)
      @ 12,24 say Cheques->CodCli
      @ 12,29 say Clientes->NomCli
      @ 13,24 say Cheques->DtaEmi
      @ 14,24 say Cheques->DtaVen
      @ 14,48 say Cheques->DtaDev
      @ 15,24 say Cheques->ValChq picture "@ke 999,999.99"
      @ 16,24 say Cheques->Observ picture "@k!"
      if !Confirm("Confirma a Exclusao",2)
         loop
      end
      while !Cheques->(Trava_Reg())
      end
      Cheques->(dbdelete())
      Cheques->(dbcommit())
      Cheques->(dbunlock())
      Grava_Log(cDiretorio,"Cheques|Excluir|Banco|Lancamento "+cLanChe,Cheques->(recno()))
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
procedure BxaCheques  // ** Baixa de Cheques
   local getlist := {},cTela := SaveWindow()
   local cLanChe,cCodBco,cNumAge,cNumCon,cNumChq,dDtapag,nValJur,nValDes,nValPag,cObser2
   local lLimpa := .t.,lRecibo := .f.,cRecibo,cLanCxa

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
    if !OpenNegociad()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenItemNego()
        FechaDados()
        Msg(.f.)
        return
    endif
   Msg(.f.)
   restore from (Arq_Sen)+"r" additive
   AtivaF4()
   TelCheques(4,2)
   while .t.
      if lLimpa
         cLanChe := space(06)
         cCodBco := space(03)
         cNumAge := space(04)
         cNumCon := space(15)
         cNumChq := space(10)
         dDtapag := date()
         nValJur := 0
         nValDes := 0
         nValPag := 0
         cObserv := space(40)
         cObser2 := space(40)
         lRecibo := .f.
         cLanCxa := space(06)
      end
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 04,24 get cLanChe picture "@k 999999" when Rodape("Esc-Encerra | F4-Cheques") valid Busca(Zera(@cLanChe),"Cheques",9,,,,{"Lan‡amento NÆo Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !empty(Cheques->DtaPag)
         Mens({"Cheque Ja Baixado"})
         loop
      end
      if Cheques->SitChq == "5"
         Mens({"Cheque Negociado"})
         loop
      end
      cCodBco := Cheques->CodBco
      cNumAge := Cheques->NumAge
      cNumCon := Cheques->NumCon
      cNumChq := Cheques->NumChq
      Banco->(dbsetorder(1),dbseek(cCodBco))
      vBcoNumAge(Cheques->CodBco,Cheques->NumAge,Cheques->NumCon,.t.,09,24)
      @ 05,24 say cCodBco
      @ 05,28 say Banco->NomBco
      @ 06,24 say cNumAge
      @ 07,24 say cNumCon
      @ 08,24 say cNumChq
      @ 08,47 say Cheques->SitChq
      //@ 11,17 say Banco->NomCon picture "@k!"
      @ 10,24 say Cheques->CodCli picture "@k 9999"
      Clientes->(dbsetorder(1),dbseek(Cheques->CodCli))
      @ 10,29 say Clientes->NomCli
      @ 11,24 say Cheques->DtaEmi
      @ 12,24 say Cheques->DtaVen
      @ 13,24 say Cheques->ValChq picture "@ke 999,999.99"
      @ 14,24 say Cheques->Observ picture "@k!"
      @ 16,24 get dDtaPag picture "@k"
      @ 17,24 get nValJur picture "@ke 999,999.99"
      @ 18,24 get nValDes picture "@ke 999,999.99"
      @ 19,24 get nValPag picture "@ke 999,999.99" valid NoEmpty(nValPag)
      @ 20,24 get cObser2 picture "@k!"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      end
      if !Confirm("Confirma a Baixa")
         loop
      end
      if Cheques->SitChq == "3"
         lRecibo := .t.
      end
      if lRecibo
         if Sequenci->(Lastrec()) == 0
            cRecibo := strzero(1,13)
            while !Sequenci->(Adiciona())
            end
            Sequenci->Recibo := cRecibo
            Sequenci->(dbunlock())
         else
            while !Sequenci->(Trava_Reg())
            end
            cRecibo := strzero(val(Sequenci->Recibo)+1,13)
            Sequenci->Recibo := cRecibo
            Sequenci->(dbunlock())
         end
      end
      while !Cheques->(Trava_Reg())
      end
      Cheques->SitChq2 := Cheques->SitChq
      Cheques->DtaDev2 := Cheques->DtaDev
      Cheques->DtaDev  := ctod(space(08))
      Cheques->SitChq  := "2"
      Cheques->DtaPag  := dDtaPag
      Cheques->ValJur  := nValJur
      Cheques->ValDes  := nValDes
      Cheques->ValPag  := nValPag
      Cheques->Obser2  := cObser2
      Cheques->LanCxa  := cLanCxa
      if lRecibo
         Cheques->Recibo  := cRecibo
      end
      Cheques->(dbcommit())
      Cheques->(dbunlock())
      Grava_Log(cDiretorio,"Cheques|Baixa|Banco "+cCodBco+" Agencia "+alltrim(cNumAge)+" Conta "+alltrim(cNumCon)+" Cheque "+alltrim(cNumChq),Cheques->(recno()))
      lLimpa := .t.
      if lRecibo
         iRecibo(cCodBco,cNumAge,cNumCon,cNumChq,cRecibo)
      end
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
procedure CxaCheques  // ** Cancela baixa de cheques
   local getlist := {},cTela := SaveWindow()
   local cCodBco,cNumAge,cNumCon,cNumChq,dDtapag,nValJur,nValDes,nValPag,cObser2
   local lLimpa := .t.
   private cNomBco,lBco := .f.,lNomCon := .f.

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
   if !OpenItemNego()
      FechaDados()
      Msg(.f.)
      return
   endif
   Msg(.f.)
   AtivaF4()
   TelCheques(5,2)
   while .t.
      cCodBco := space(03)
      cNumAge := space(04)
      cNumCon := space(15)
      cNumChq := space(10)
      cNomCon := space(30)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 05,24 get cCodBco picture "@k 999" when Rodape("Esc-Encerra | F4-Cheques") valid V_Bco(@cCodBco,.f.,05,28)
      @ 06,24 get cNumAge picture "@k" when Rodape("Esc-Encerra")
      @ 07,24 get cNumCon picture "@k" valid vBcoNumAge(cCodBco,cNumAge,cNumCon,.f.,09,24)
      @ 08,24 get cNumChq picture "@k" valid Busca(cCodBco+cNumAge+cNumCon+cNumChq,"Cheques",1,,,,{"Cheque Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if empty(Cheques->DtaPag)
         Mens({"Cheque Nao Baixado"})
         loop
      end
      @ 08,47 say Cheques->SitChq
      @ 10,24 say Cheques->CodCli picture "@k 9999"
      Clientes->(dbsetorder(1),dbseek(Cheques->CodCli))
      @ 10,29 say Clientes->NomCli
      @ 11,24 say Cheques->DtaEmi
      @ 12,24 say Cheques->DtaVen
      @ 13,24 say Cheques->ValChq picture "@ke 999,999.99"
      @ 14,24 say Cheques->Observ picture "@k!"
      @ 16,24 say Cheques->DtaPag picture "@k"
      @ 17,24 say Cheques->ValJur picture "@ke 999,999.99"
      @ 18,24 say Cheques->ValDes picture "@ke 999,999.99"
      @ 19,24 say Cheques->ValPag picture "@ke 999,999.99"
      @ 20,24 say Cheques->Obser2 picture "@k!"
      if !Confirm("Confirma o Cancelamento da Baixa",2)
         loop
      end
      while !Cheques->(Trava_Reg())
      end
      Cheques->SitChq := "1"
      Cheques->DtaPag := ctod(space(08))
      Cheques->ValJur := 0
      Cheques->ValDes := 0
      Cheques->ValPag := 0
      Cheques->Obser2 := space(40)
      Cheques->Recibo := space(13)
      Cheques->SitChq := Cheques->SitChq2
      Cheques->DtaDev := Cheques->DtaDev2
      Cheques->(dbcommit())
      Cheques->(dbunlock())
      Grava_Log(cDiretorio,"Cheques|Cancela Baixa|Banco "+cCodBco+" Agencia "+alltrim(cNumAge)+" Conta "+alltrim(cNumCon)+" Cheque "+alltrim(cNumChq),Cheques->(recno()))
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
procedure VerCheques
   local cTela := SaveWindow()

   TelCheques(6,2)
   MosCheques()
   Rodape(space(20)+"Pressione Qualquer Tecla para Continuar")
   Inkey(0)
   RestWindow(cTela)
   return
// ****************************************************************************
static procedure MosCheques

   Clientes->(dbsetorder(1),dbseek(Cheques->CodCli))
   Banco->(dbsetorder(1),dbseek(Cheques->CodBco+Cheques->NumAge+Cheques->NumCon))
   Negociador->(dbsetorder(1),dbseek(Cheques->CodNeg))
   ItemNego->(dbsetorder(2),dbseek(Cheques->LanChe))

   @ 04,24 say Cheques->LanChe
   @ 05,24 say Cheques->CodBco
   @ 06,24 say Cheques->NumAge
   @ 07,24 say Cheques->NumCon
   @ 08,24 say Cheques->NumChq
   @ 08,47 say Cheques->SitChq
   @ 08,49 say space(20)
   if Cheques->SitChq == "1"
      @ 08,48 say "-A Compensar"
   elseif Cheques->SitChq == "2"
      @ 08,48 say "-Compensado "
   elseif Cheques->SitChq == "3"
      @ 08,48 say "-Devolvido  "
   elseif Cheques->SitChq == "5"
      @ 08,49 say Cheques->CodNeg+"-"+left(Negociador->Nome,15)
   end
   @ 09,24 say Banco->NomCon
   @ 10,24 say Cheques->CodCli picture "@k 9999"
   @ 10,29 say Clientes->NomCli
   @ 11,24 say Cheques->DtaEmi
   @ 11,48 say Cheques->DtaNeg
   @ 12,24 say Cheques->DtaVen
   @ 12,48 say ItemNego->LancNeg
   @ 13,24 say Cheques->ValChq picture "@ke 999,999.99"
   @ 14,24 say Cheques->Observ picture "@k!"
   @ 16,24 say Cheques->DtaPag picture "@k"
   @ 17,24 say Cheques->ValJur picture "@ke 999,999.99"
   @ 18,24 say Cheques->ValDes picture "@ke 999,999.99"
   @ 19,24 say Cheques->ValPag picture "@ke 999,999.99"
   @ 20,24 say Cheques->Obser2 picture "@k!"
   return
// ****************************************************************************
procedure ImpRChq  // Imprime o Recibo quando o cheque for Devolvido
   local getlist := {},cTela := SaveWindow()
   local cRecibo

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenClientes()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenCheques()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenBanco()
      FechaDados()
      Msg(.f.)
      return
   endif
   Msg(.f.)
   AtivaF4()
   Window(09,23,13,54)
   setcolor(Cor(11))
   //           56789012345678901234567890
   //                3         4         5
   @ 11,25 say "N§ do Recibo:"
   while .t.
      cRecibo := space(13)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,39 get cRecibo picture "@k!" when Rodape("Esc-Encerra | F4-Cheques Compensados (Devolvido)") valid Busca(Zera(@cRecibo),"Cheques",9,,,,{"Recibo Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma o Recibo")
         loop
      end
      Rodape("")
      iRecibo(Cheques->CodBco,Cheques->NumAge,Cheques->NumCon,Cheques->NumChq,cRecibo)
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
static procedure iRecibo(cCodBco,cNumAge,cNumCon,cNumChq,cRecibo)  // Impressao do Recibo
   local cTela := SaveWindow()
   local nVideo,cTexto,cExtenso,nVia := 1

   If Aviso_1(09,,14,,[Aten‡„o!],[Imprimir Recibo ?],{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
      If Ver_Imp(@nVideo)
         if nVideo == 1
            nVia := nVias()
         end
         begin sequence
            Msg(.t.)
            Msg("Aguarde: Imprimindo Recibo")
            if nVideo == 1
               set printer to lpt1
            end
            Set Device to Print
            for nX := 1 to nVia
               Cheques->(dbsetorder(1),dbseek(cCodBco+cNumAge+cNumCon+cNumChq))
               Clientes->(dbsetorder(1),dbseek(Cheques->CodCli))
               cExtenso := Extenso2(Cheques->ValPag,.t.,.t.)
               cTexto := "    Recebemos de "+rtrim(Clientes->NomCli)+" a importancia supra de R$ "+rtrim(transform(Cheques->ValPag,"@e 999,999.99"))+" ( "+cExtenso+" ), referente ao pagamento do cheque No. "+rtrim(Cheques->NumChq)+" Banco "+Cheques->CodBco+" Agencia "+rtrim(Cheques->NumAge)+" Conta "+Cheques->NumCon
               @ prow(),00 say CHR(27)+CHR(67)+CHR(33)
               @ prow(),pcol() say T_ICPP10+T_ICondF
               @ prow()+1,000 say T_ICondI+T_IExpI+rtrim(cEmpFantasia)+T_IExpF
               @ prow()+1,000 say rtrim(clEndLoj)+" "+rtrim(clMunloj)+"/"+clEstLoj+" Fone: "+rtrim(clTelLoj)
               @ prow()+1,000 say "C.G.C..: "+transform(clCGCLoj,"@R 99.999.999/9999-99")+" Insc.Estadual: "+clInsLoj
               @ prow()+4,50 say T_ICondF+T_IExpI+"RECIBO"+T_IExpI
               @ prow()+2,58 say T_ICondI+T_IExpI+"No.: "+cRecibo+T_IExpF+T_ICondF
               @ prow()+4,64 say T_ICondI+T_IExpI+"R$ "+transform(Cheques->ValPag,"@e 999,999.99")+T_IExpF+T_ICondF
               @ prow()+2,00 say ""
               for nI := 1 to mlcount(cTexto,80)
                  if nI == 1
                     @ prow()+1,00 say memoline(cTexto,80,nI)
                  else
                     @ prow()+1,00 say memoline(cTexto,80,nI)
                  end
               next
               @ prow(),pcol() say T_ICONDF
               @ prow()+3,00 say rtrim(clCidade)+"( "+clEstado+" ), "+DatPort(Cheques->DtaPag,0)
               @ prow()+3,40 say "_____________________________"
               @ prow()+1,40 say PwNome
               eject
               @ prow(),pcol() say chr(27)+chr(67)+chr(66)
            next
         end sequence
         Set Printer to
         set device to screen
         if nVideo == 2
            Ve_Txt("",Arq_Sen+".prn",02,00,23,79,140)
         end
      end
   end
   RestWindow(cTela)
   return
// ****************************************************************************
procedure TelCheques(nModo,nTipo)
   local aTitulos := {"InclusÆo","Altera‡Æo","ExclusÆo","Baixa","Cancela Baixa","Visualiza‡Æo"}

   if nTipo == 1
      Window(04,09,18,70," " + aTitulos[ nModo ] + " de Cheques ")
      setcolor(Cor(11))
      //           1234567890123456789012345678901234567890123456789012345678
      //                    2         3         4         5         6         7
      @ 06,11 say " Lan‡amento:"
      @ 07,11 say "      Banco:"
      @ 08,11 say " N§ Agˆncia:"
      @ 09,11 say "   N§ Conta:"
      @ 10,11 say "  N§ Cheque:               Situacao:"
      @ 11,11 say "Correntista:"
      @ 12,11 say "    Cliente:"
      @ 13,11 say "   Recebido:"
      @ 14,11 say " Vencimento:              Devolvido:"
      @ 15,11 say "      Valor:"
      @ 16,11 say " Observacao:"
   else
      Window(02,09,22,70," " + aTitulos[ nModo ] + " de Cheques ")
      setcolor(Cor(11))
      //           1234567890123456789012345678901234567890123456789012345678
      //                    2         3         4         5         6         7
      @ 04,11 say "   N§ Lanc.:"
      @ 05,11 say "      Banco:"
      @ 06,11 say " N§ Agˆncia:"
      @ 07,11 say "   N§ Conta:"
      @ 08,11 say "  N§ Cheque:              Situacao:"
      @ 09,11 say "Correntista:"
      @ 10,11 say "    Cliente:"
      @ 11,11 say "Recebimento:              Negociado:"
      @ 12,11 say " Vencimento:               N§ Lanc.:"
      @ 13,11 say "      Valor:"
      @ 14,11 say " Observacao:"
      @ 15,10 say TracoCentro("[ Informacoes da Baixa ]",60,chr(196))
      @ 16,11 say "  Pagamento:"
      @ 17,11 say "      Juros:"
      @ 18,11 say "   Desconto:"
      @ 19,11 say "   Vl. Pago:"
      @ 20,11 say " Observacao:"
   end
   return
// ****************************************************************************
Static Function V_Bco(cCodBco,lTrue,nLinha,nColuna)

   If !Busca(@cCodBco,"Banco",1,nLinha,nColuna,"Banco->NomBco",{"Banco Nao Cadastrado"}, .t., .t., .f., .f. )
      if lTrue
         If Aviso_1(14,,19,, [Aten‡„o!],"   Cadastra o Banco ?   ", { [  ^Sim  ], [  ^N„o  ] }, 2, .t. ) = 1
            IncBancos(.f.)
            Return(.f.)
         else
            return(.f.)
         end
      end
   end
   Return( .t. )
// ****************************************************************************
static function vBcoNumAge(cCodBco,cNumAge,cNumCon,lTrue,nLinha,nColuna)

   if !Busca(cCodBco+cNumAge+cNumCon,"Banco",1,nLinha,nColuna,"Banco->NomCon",{"Banco/Agencia/Conta Nao Cadastrado"},.f.,.f.,.f.)
      if lTrue
         If Aviso_1(14,,19,,"Aten‡„o!","   Cadastra Banco/Agencia/Conta ?   ",{"  ^Sim  ","  ^N„o  "},2,.t.) == 1
            IncBancos(.f.,cCodBco,cNumAge,cNumCon)
            return(.f.)
         else
            return(.f.)
         end
      end
   end
   return(.t.)
// ****************************************************************************
procedure ConfLancCx // Configura o Lancamento no Caixa
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
   restore from (Arq_Sen)+"c" additive
   AtivaF4()
   Window(09,14,14,64," Conf. Lanc. no Caixa ")
   setcolor(Cor(11))
   //           67890123456789012345678901234567890123456789012345678
   //               2         3         4         5         6         7
   @ 11,16 say "    Caixa:"
   @ 12,16 say "Historico:"
   while .t.
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,27 get cCCodCxa picture "@k 99" when Rodape("Esc-Encerra | F4-Caixas") valid Busca(Zera(@cCCodCxa),"Caixa",1,11,31,"Caixa->NomCaixa",{"Caixa Nao Cadastrado"},.f.,.f.,.f.)
      @ 12,27 get cCCodHis picture "@k 999" when Rodape("Esc-Encerra | F4-Historicos") valid Busca(Zera(@cCCodHis),"Historico",1,12,31,"Historico->NomHist",{"Historic Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
      save to (Arq_Sen)+"c" all like cCCod*
      exit
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
procedure xCheques
   Local cCor := setcolor()
   local aCampo  := {},aTitulo := {},aMascara := {}
   private aVetor1  := {},aVetor2  := {},aVetor3  := {},aVetor4  := {},aVetor5  := {}
   private aVetor6  := {},aVetor7  := {},aVetor8  := {},aVetor9  := {},aVetor10 := {}
   private aVetor11 := {},aVetor12 := {},aVetor13 := {},aVetor14 := {},aVetor15 := {}
   private aVetor16 := {},aVetor17 := {},aVetor18 := {}
   Private nPos

   Cheques->(dbsetorder(1),dbgotop())
   while Cheques->(!eof())
      if !empty(Cheques->Recibo)
         Banco->(dbsetorder(1),dbseek(Cheques->CodBco+Cheques->NumAge+Cheques->NumCon))

         aadd(aVetor1,Cheques->CodBco)
         aadd(aVetor2,Cheques->NumAge)
         aadd(aVetor3,Cheques->NumCon)
         aadd(aVetor4,Banco->NomCon)
         aadd(aVetor5,Cheques->NumChq)
         aadd(aVetor6,Cheques->Recibo)
         aadd(aVetor7,Cheques->DtaEmi)
         aadd(aVetor8,Cheques->DtaVen)
         aadd(aVetor9,transform(Cheques->ValChq,"@e 999,999.99"))
         aadd(aVetor10,Cheques->Observ)
         aadd(aVetor11,Cheques->DtaPag)
         aadd(aVetor12,transform(Cheques->ValJur,"@e 999,999.99"))
         aadd(aVetor13,transform(Cheques->ValDes,"@e 999,999.99"))
         aadd(aVetor14,transform(Cheques->ValPag,"@e 999,999.99"))
         aadd(aVetor15,Cheques->Obser2)
         aadd(aVetor16,Cheques->SitChq)
         aadd(aVetor17,iif(Cheques->SitChq == "1","A Compensar",iif(Cheques->SitChq == "2","Compensado",iif(Cheques->SitChq == "3","Devolvido",""))))
         aadd(aVetor18,Cheques->DtaDev)
      end
      Cheques->(dbskip())
   end
   if len(aVetor1) == 0
      Mens({"Nao Existe Cheques"})
      return
   end
   aadd(aCampo,"aVetor1")
   aadd(aCampo,"aVetor2")
   aadd(aCampo,"aVetor3")
   aadd(aCampo,"aVetor4")
   aadd(aCampo,"aVetor5")
   aadd(aCampo,"aVetor6")
   aadd(aCampo,"aVetor7")
   aadd(aCampo,"aVetor8")
   aadd(aCampo,"aVetor9")
   aadd(aCampo,"aVetor10")
   aadd(aCampo,"aVetor11")
   aadd(aCampo,"aVetor12")
   aadd(aCampo,"aVetor13")
   aadd(aCampo,"aVetor14")
   aadd(aCampo,"aVetor15")
   aadd(aCampo,"aVetor16")
   aadd(aCampo,"aVetor17")
   aadd(aCampo,"aVetor18")

   aadd(aTitulo,"Banco")
   aadd(aTitulo,"N§ Agˆncia")
   aadd(aTitulo,"N§ Conta")
   aadd(aTitulo,"Correnstista")
   aadd(aTitulo,"N§ Cheque")
   aadd(aTitulo,"N§ Recibo")
   aadd(aTitulo,"Emissao")
   aadd(aTitulo,"Vencimento")
   aadd(aTitulo,"Valor")
   aadd(aTitulo,"Observacao")
   aadd(aTitulo,"Pagamento")
   aadd(aTitulo,"Juros")
   aadd(aTitulo,"Desconto")
   aadd(aTitulo,"Valor Pago")
   aadd(aTitulo,"Observacao da Baixa")
   aadd(aTitulo,"Sit.")
   aadd(aTitulo,"Situacao")
   aadd(aTitulo,"Devolvido")

   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   cTela := SaveWindow()
   Rodape("Esc-Encerra | ENTER-Seleciona | 2-Visualiza Entrega")
   Window(06,00,23,79,chr(16)+" Relacao de Cheques "+chr(17))
   Edita_Vet(07,01,22,78,aCampo,aTitulo,aMascara,"dbEntrega",,.t.)
   RestWindow(cTela)
   if nPos == 0
      setcolor(cCor)
      return
   else
      cDados := aVetor6[nPos]
      keyboard (cDados)+chr(K_ENTER)
   end
   setcolor(cCor)
   Return

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
    if !OpenBanco()
        FechaDados()
        Msg(.f.)
        return(.f.)
   endif
    if !OpenCheques()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenNegociad()  // Negociador
        FechaDados()
        Msg(.f.)
        return(.f.)
   endif
    if !OpenItemNego()
        FechaDados()
        Msg(.f.)
        return(.f.)
   endif
    if !OpenSequencia()
        FechaDados()
        Msg(.f.)
        return(.f.)
   endif
   Msg(.f.)
   return(.t.)
   


// ** Fim do Arquivo.
