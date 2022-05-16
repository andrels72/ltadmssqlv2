/*************************************************************************
 * Sistema......: Administrativo
 * Identificacao: Manutencao de Movimento de Bancos
 * Prefixo......: LtfCaixa
 * Programa.....: MovBan.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 21 de Outubro de 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConMovBan(lAbrir)
   local oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados
   local nCursor := setcursor(),cCor := setcolor()
   local aTitulo := {},aCampo := {},aMascara := {},cFiltro,Sai_Mnu := .f.
   local Item[05],aV_Zer[8],nLin1,nCol1,nLin2,nCol2
   private nRecno

   if lAbrir
      if !AbrirArquivos()
         FechaDados()
         return
      endif
   else
      setcursor(SC_NONE)
   endif
   select MovBan
   set order to 1
   goto top
   Rodape(iif(lAbrir,"Esc-Encerrar | F2-Visualizar | F10-Opcoes","Esc-Encerra | ENTER-Transfere | F2-Visualizar | F10-Opcoes"))

   aadd(aCampo,"NumDoc")
   aadd(aCampo,"Dtos(DtaMov)")
   aadd(aCampo,"CodBco")
   aadd(aCampo,"NumAge")
   aadd(aCampo,"NumCon")
   aadd(aCampo,"CodHis")
   aadd(aCampo,"Compl")
   aadd(aCampo,"VlrMov")
   // *-------------------------------------------------------------------------
   aadd(aTitulo,"Lancamento")
   aadd(aTitulo,"Data")
   aadd(aTitulo,"Banco")
   aadd(aTitulo,"N§ Agencia")
   aadd(aTitulo,"N§ Conta")
   aadd(aTitulo,"Historico")
   aadd(aTitulo,"Complemento")
   aadd(aTitulo,"Valor")
   // *-------------------------------------------------------------------------
   aadd(aMascara,"@!")
   aadd(aMascara,"@k 99/99/999")
   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   aadd(aMascara,"@!")
   aadd(aMascara,"@e 999,999,999.99")
   // *-------------------------------------------------------------------------
   nLin1 := 02
   nCol1 := 00
   nLin2 := 33
   nCol2 := 100
   setcolor(cor(5))
   Window(nLin1,nCol1,nLin2,nCol2,"> Consulta de Movimento Bancario <")
   oBrow := TBrowseDB(nLin1+1,nCol1+1,nLin2-2,nCol2-1)
   oBrow:headSep   := SEPH
   oBrow:footSep   := SEPB
   oBrow:colSep    := SEPV
   oBrow:colorSpec := ConVertCor(Cor(25))+","+ConVertCor(Cor(31))
   oBrow:addcolumn(tbColumnnew("Lancamento"   ,{|| MovBan->NumDoc }))
   oBrow:addcolumn(tbColumnnew("Balancete"    ,{|| MovBan->DtaBal }))
   oBrow:addcolumn(tbColumnnew("Data"         ,{|| MovBan->Dtamov }))
   oBrow:addcolumn(tbColumnnew("Banco"        ,{|| MovBan->CodBco }))
   oBrow:addcolumn(tbColumnnew("Nome do Banco",{|| Banco->(dbsetorder(1),dbseek(MovBan->CodBco+MovBan->NumAge+MovBan->NumCon),Banco->NomBco)}))
   oBrow:addcolumn(tbColumnnew("N§ Agˆncia"   ,{|| MovBan->NumAge }))
   oBrow:addcolumn(tbColumnnew("N§ Conta"     ,{|| MovBan->NumCon }))
   oBrow:addcolumn(tbColumnnew("Cod.Histo"    ,{|| MovBan->CodHis }))
   oBrow:addcolumn(tbColumnnew("Historico"    ,{|| HistBan->(dbsetorder(1),dbseek(MovBan->CodHis),HistBan->DesHis)}))
   oBrow:addcolumn(tbColumnnew("Complemento"  ,{|| MovBan->Compl }))
   oBrow:addcolumn(tbColumnnew("Valor"        ,{|| transform(MovBan->VlrMov,"@e 999,999,999.99")}))
   oBrow:addcolumn(tbColumnnew("Observacao"   ,{|| MovBan->ObsMov}))
   aTab := TabHNew(nLin2-1,nCol1+1,nCol2-1,setcolor(cor(28)),1)
   TabHDisplay(aTab)
   setcolor(Cor(26))
   while (! lFim)
      while ( ! oBrow:stabilize() )
         nTecla := INKEY()
         IF ( nTecla != 0 )
            EXIT
         ENDIF
      END
      IF ( oBrow:stable )
         IF ( oBrow:hitTop .OR. oBrow:hitBottom )
            TONE(1200,1)
         ENDIF
         nTecla := INKEY(0)
      ENDIF
      if !TBMoveCursor(nTecla,oBrow)
         if nTecla == K_ESC
            if Sai_Mnu
               set index to &cDiretorio.MovBan1,&cDiretorio.MovBan2,&cDiretorio.MovBan3
            end
            lFim := .t.
         elseif nTecla == K_ENTER
            if !lAbrir
               cDados := MovBan->NumDoc
               if Sai_Mnu
                  set index to &cDiretorio.MovBan1,&cDiretorio.MovBan2,&cDiretorio.MovBan3
               end
               keyboard (cDados)+chr(K_ENTER)
               lFim := .t.
            end
         elseif nTecla == K_F2
            VerMovBan()
         elseif nTecla == K_F10
            cTela2 := SaveWindow()
            Sai_Mnu = .f.
            Do While !Sai_Mnu
               U_PosAjd = [AJDF10_]
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
               elseif Opcao = 4
                  DB_CFiltra(Len({{1},{2},{3}}),cDiretorio, cFiltro )
                  If LastKey() == K_ESC
                     Sai_Mnu = .f.
                  Else
                     oBrow:GoTop()
                     Sai_Mnu = .t.
                  EndIf
               elseif Opcao = 5
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
   RETURN
// ****************************************************************************
procedure IncMovBan
   local getlist := {},cTela := SaveWindow()
   local cNumDoc,dDtaBal,dDtaMov,cCodBco,cNumAge,cCodHis,cNumConm,cCompl,nVlrMov,cObsMov

   
	if !AbrirArquivos()
		FechaDados()
	endif
   AtivaF4()
   TelMovBan(1)
   while .t.
      cNumDoc := Space(10)
      dDtaBal := date()
      dDtaMov := Date()
      cCodBco := Space(03)
      cNumAge := Space(04)
      cNumCon := Space(15)
      cCodHis := Space(03)
      cCompl  := space(20)
      nVlrMov := 0
      cObsMov := Space( 50 )
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      MovBan->(dbsetorder(1),dbgobottom())
      if MovBan->(eof())
         MovBan->(dbskip(-1))
      end
      cNumDoc := strzero(val(MovBan->NumDoc)+1,10)
      @ 07,22 get cNumDoc picture "@k 9999999999" when Rodape("Esc-Encerra | F4-Lancamentos") valid Busca(Zera(@cNumDoc),"MovBan",1,,,,{"Lancamento Ja Cadastrado"},.f.,.f.,.t.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      @ 08,22 get dDtaBal picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDtaBal)
      @ 09,22 get dDtaMov picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDtaMov) //.and. vDataMov(dDtaMov)
      @ 10,22 get cCodBco picture "@k 999";
                valid NoEmpty(cCodBco) .and. Busca(@cCodBco,"Banco",1,10,27,"Banco->NomBco",{"Banco Nao Cadastrado"}, .t., .t., .f., .f. )
      @ 11,22 get cNumAge picture "@k";
                valid NoEmpty(cNumAge) .and. V_Zera(@cNumAge)
      @ 12,22 get cNumCon picture "@k";
                valid Busca(cCodBco+cNumAge+cNumCon,"Banco",1,,,,{"Banco/Agencia/Conta Nao Cadastrado"},.f.,.f.,.f.)
      @ 13,22 get cCodHis picture "@k 999";
                valid Busca(Zera(@cCodHis),"HistBan",1,13,27,"HistBan->DesHis",{"Historico Nao Cadastrado"},.f.,.f.,.f.)
      @ 14,22 get cCompl  picture "@k!"
      @ 15,22 get nVlrMov picture "@ke 999,999,999.99" valid NoEmpty(nVlrMov)
      @ 16,22 get cObsMov picture "@k!"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      end
      if !Confirm("Confirma a InclusÆo")
         loop
      end
      while !MovBan->(Adiciona())
      end
      MovBan->NumDoc := cNumDoc
      MovBan->DtaBal := dDtaBal
      MovBan->DtaMov := dDtaMov
      MovBan->CodBco := cCodBco
      MovBan->NumAge := cNumAge
      MovBan->NumCon := cNumCon
      MovBan->CodHis := cCodHis
      MovBan->Compl  := cCompl
      MovBan->VlrMov := nVlrMov
      MovBan->ObsMov := cObsMov
      MovBan->SldAnt := Banco->SldBco
      MovBan->(dbcommit())
      MovBan->(dbunlock())
      while !Banco->(Trava_Reg())
      end
      if HistBan->TipHis == "D"
         Banco->SldBco := Banco->SldBco - nVlrMov
      else
         Banco->SldBco := Banco->SldBco + nVlrMov
      end
      Banco->(dbcommit())
      Banco->(dbunlock())
   end
   DesativaF4()
   dbcommitall()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
procedure AltMovBan
   local getlist := {},cTela := SaveWindow()
   local cNumDoc,dDtaBal,dDtaMov,cCodBco,cNumAge,cCodHis,cNumConm,cCompl,nVlrMov,cObsMov
   local nMovAnt,lMudou

   
	if !AbrirArquivos()
		FechaDados()
		return
	endif
   AtivaF4()
   TelMovBan(2)
   while .t.
      cNumDoc := Space(10)
      lMudou  := .f.
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 07,22 get cNumDoc picture "@k 9999999999" when Rodape("Esc-Encerra | F4-Lancamentos") valid Busca(Zera(@cNumDoc),"MovBan",1,,,,{"Lancamento Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !vDataMov(MovBan->DtaMov)
         loop
      end
      dDtaBal := MovBan->DtaBal
      dDtaMov := MovBan->DtaMov
      cCodBco := MovBan->CodBco
      cNumAge := MovBan->NumAge
      cNumCon := MovBan->NumCon
      cCodHis := MovBan->CodHis
      cCompl  := MovBan->Compl
      nVlrMov := MovBan->VlrMov
      cObsMov := MovBan->ObsMov
      @ 08,22 get dDtaBal picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDtaBal)
      @ 09,22 get dDtaMov picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDtaMov) .and. vDataMov(dDtaMov)
      @ 10,22 get cCodBco picture "@k 999" valid NoEmpty(cCodBco) .and. Busca(@cCodBco,"Banco",1,10,27,"Banco->NomBco",{"Banco Nao Cadastrado"}, .t., .t., .f., .f. )
      @ 11,22 get cNumAge picture "@k"     valid NoEmpty(cNumAge) .and. V_Zera(@cNumAge)
      @ 12,22 get cNumCon picture "@k"     valid Busca(cCodBco+cNumAge+cNumCon,"Banco",1,,,,{"Banco/Agencia/Conta Nao Cadastrado"},.f.,.f.,.f.)
      @ 13,22 get cCodHis picture "@k 999" valid Busca(Zera(@cCodHis),"HistBan",1,13,27,"HistBan->DesHis",{"Historico Nao Cadastrado"},.f.,.f.,.f.)
      @ 14,22 get cCompl  picture "@k!"
      @ 15,22 get nVlrMov picture "@ke 999,999,999.99" valid NoEmpty(nVlrMov)
      @ 16,22 get cObsMov picture "@k!"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      end
      if !Confirm("Confirma a Altera‡Æo")
         loop
      end
      if !(MovBan->CodBco == cCodBco .and. MovBan->NumAge == cNumAge .and. MovBan->NumCon == cNumCon)
         if Banco->(dbsetorder(1),dbseek(MovBan->CodBco+MovBan->NumAge+MovBan->NumCon))
            while !Banco->(Trava_Reg())
            end
            if HistBan->TipHis == "D"
               Banco->SldBco := Banco->SldBco + MovBan->VlrMov
            else
               Banco->SldBco := Banco->SldBco - MovBan->VlrMov
            end
            Banco->(dbcommit())
            Banco->(dbunlock())
         end
         Banco->(dbsetorder(1),dbseek(cCodBco+cNumAge+cNumCon))
         lMudou := .t.
      end
      while !MovBan->(Trava_Reg())
      end
      if !lMudou
         nMovAnt := MovBan->VlrMov
      end
      MovBan->DtaBal := dDtaBal
      MovBan->DtaMov := dDtaMov
      MovBan->CodBco := cCodBco
      MovBan->NumAge := cNumAge
      MovBan->NumCon := cNumCon
      MovBan->CodHis := cCodHis
      MovBan->Compl  := cCompl
      MovBan->VlrMov := nVlrMov
      MovBan->ObsMov := cObsMov
      MovBan->(dbcommit())
      MovBan->(dbunlock())
      while !Banco->(Trava_Reg())
      end
      if HistBan->TipHis == "D"
         if !lMudou
            Banco->SldBco := Banco->SldBco + (nMovAnt-nVlrMov)
         else
            Banco->SldBco := Banco->SldBco - nVlrMov
         end
      else
         if !lMudou
            Banco->SldBco := Banco->SldBco + (nVlrMov-nMovAnt)
         else
            Banco->SldBco := Banco->SldBco + nVlrMov
         end
      end
      Banco->(dbcommit())
      Banco->(dbunlock())
   end
   DesativaF4()
   dbcommitall()
   FechaDados()
   RestWindow(cTela)
   return
// ******************************************************************************
procedure ExcMovBan
	local getlist := {},cTela := SaveWindow()
	local cNumDoc,nMovAnt
	
	if !AbrirArquivos()
		FechaDados()
		return
	endif
   AtivaF4()
   TelMovBan(3)
   while .t.
      cNumDoc := Space(10)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 07,22 get cNumDoc picture "@k 9999999999" when Rodape("Esc-Encerra | F4-Lancamentos") valid Busca(Zera(@cNumDoc),"MovBan",1,,,,{"Lancamento Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      if !Banco->(dbsetorder(1),dbseek(MovBan->CodBco+MovBan->NumAge+MovBan->NumCon))
         Mens({"Banco/Agencia/Conta Nao Cadastrado"})
         loop
      endif
      if !HistBan->(dbsetorder(1),dbseek(MovBan->CodHis))
         Mens({"Historico Nao Cadastrado"})
         loop
      endif
      @ 08,22 say MovBan->DtaBal
      @ 09,22 say MovBan->DtaMov
      @ 10,22 say MovBan->CodBco picture "@k 999"
      @ 11,22 say MovBan->NumAge picture "@k"
      @ 12,22 say MovBan->NumCon picture "@k"
      @ 13,22 say MovBan->CodHis picture "@k 999"
      @ 14,22 say MovBan->Compl  picture "@k!"
      @ 15,22 say MovBan->VlrMov picture "@ke 999,999,999.99"
      if !Confirm("Confirma a Exclusao",2)
         loop
      end
      while !MovBan->(Trava_Reg())
      enddo
      nMovAnt := MovBan->VlrMov
      MovBan->(dbdelete())
      MovBan->(dbcommit())
      MovBan->(dbunlock())
      while !Banco->(Trava_Reg())
      enddo
      if HistBan->TipHis == "D"
         Banco->SldBco := Banco->SldBco + nMovAnt
      else
         Banco->SldBco := Banco->SldBco - nMovAnt
      endif
      Banco->(dbcommit())
      Banco->(dbunlock())
   enddo
   DesativaF4()
   dbcommitall()
   FechaDados()
   RestWindow(cTela)
   return
// *****************************************************************************
procedure VerMovBan
   local cTela := SaveWindow()

   TelMovBan(4)
   MosMovBan(4)
   Rodape(space(20)+"Pressione Qualquer Tecla para Continuar")
   Inkey(0)
   RestWindow(cTela)
   return
// *****************************************************************************
static procedure MosMovBan

   Banco->(dbsetorder(1),dbseek(MovBan->CodBco))
   HistBan->(dbsetorder(1),dbseek(MovBan->CodHis))
   setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
   @ 07,22 say MovBan->NumDoc
   @ 08,22 say MovBan->DtaMov picture "@k"
   @ 09,22 say MovBan->CodBco picture "@k 999"
   @ 09,27 say Banco->NomBco
   @ 10,22 say MovBan->NumAge picture "@k"
   @ 11,22 say MovBan->NumCon picture "@k"
   @ 12,22 say MovBan->CodHis picture "@k 999"
   @ 12,27 say HistBan->DesHis
   @ 13,22 say MovBan->Compl  picture "@k!"
   @ 14,22 say MovBan->VlrMov picture "@ke 999,999,999.99"
   return
// ****************************************************************************
procedure TelMovBan( nModo )
   local cTitulo, aTitulos := {"InclusÆo","Altera‡Æo","ExclusÆo","Visualizacao" }

   Window(05,07,18,73,"> "+aTitulos[nModo]+" de Movimento Bancario <")
   setcolor(Cor(11))
   //           9012345678901234567890123456789012345678901234567890123456789012345678
   //            1         2         3         4         5         6         7
   @ 07,09 say " Lan‡amento:"
   @ 08,09 say "  Balancete:"
   @ 09,09 say "       Data:"
   @ 10,09 say "      Banco:"
   @ 11,09 say " N§ Agˆncia:"
   @ 12,09 say "N§ da Conta:"
   @ 13,09 say "  Historico:"
   @ 14,09 say "Complemento:"
   @ 15,09 say "      Valor:"
   @ 16,09 say " Observacao:"
   return
// ******************************************************************************
procedure CalcBan
   local getlist := {},cTela := SaveWindow()
   local cCodBco,cNumAge,cNumCon,nSaldo


    if !AbrirArquivos()
        return
    endif
   AtivaF4()
   Window(08,14,14,64)
   setcolor(Cor(11))
   @ 10,16 say "      Banco:"
   @ 11,16 say " N§ Agˆncia:"
   @ 12,16 say "N§ da Conta:"
   while .t.
      cCodBco := Space(03)
      cNumAge := Space(04)
      cNumCon := Space(15)
      nSaldo  := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,29 get cCodBco picture "@k 999";
                valid Busca(@cCodBco,"Banco",1,10,33,"Banco->NomBco",{"Banco Nao Cadastrado"}, .t., .t., .f., .f. )
      @ 11,29 get cNumAge picture "@k";
                valid NoEmpty(cNumAge) .and. V_Zera(@cNumAge)
      @ 12,29 get cNumCon picture "@k";
                valid Busca(cCodBco+cNumAge+cNumCon,"Banco",1,,,,{"Banco/Agencia/Conta Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
      while !Banco->(Trava_Reg())
      end
      Banco->SldBco := nSaldo
      Banco->(dbcommit())
      Banco->(dbunlock())
      MovBan->(dbsetorder(3),dbgotop())
      Msg(.t.)
      Msg("Aguarde: Recalculando o Saldo")
      while MovBan->(!eof())
         if MovBan->CodBco == cCodBco .and. MovBan->NumAge == cNumAge .and. MovBan->NumCon == cNumCon //.and. MovBan->(!eof())
            if HistBan->(dbsetorder(1),dbseek(MovBan->CodHis))
               if HistBan->TipHis == "D"
                  nSaldo -= MovBan->VlrMov
               else
                  nSaldo += MovBan->VlrMov
               end
            end
         end
         MovBan->(dbskip())
      end
      Msg(.f.)
      if Banco->(dbsetorder(1),dbseek(cCodBco+cNumAge+cNumCon))
         while !Banco->(Trava_Reg())
         end
         Banco->SldBco := nSaldo
         Banco->(dbcommit())
         Banco->(dbunlock())
      end
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
static function AbrirArquivos
   
   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenMovBan()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenBanco()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    if !OpenHistBan()
        FechaDados()
        Msg(.f.)
        return(.f.)
    endif
    Msg(.f.)
return(.t.)
//** Fim do Arquivo.
