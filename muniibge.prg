/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.00
 * Identificacao: Manuten‡Æo de Cidades
 * Prefixo......: LtAdm
 * Programa.....: Cidades.prg
 * Autor........: Andre Lucas Souza
 * Data.........: 23 de Setembro de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConMuniIbge(lAbrir,lIncluir)
   local getlist := {},oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados
   local nCursor := setcursor(),cCor := setcolor(),xTecla
   local nLin1   := 02,nCol1 := 15,nLin2 := maxrow()-1,nCol2 := 79
   private nRecno

   if lAbrir
      if !AbrirArquivos()
         return
      end
   else
      setcursor(SC_NONE)
   end
   select MuniBge
   set order to 2
   goto top
   if lAbrir
      Rodape("Esc-Encerrar")
   else
      if lIncluir
         Rodape("Esc-Encerra | ENTER-Transfere | F7-Incluir")
      else
         Rodape("Esc-Encerra | ENTER-Transfere")
      end
   end
   setcolor(cor(5))
   Window(nLin1,nCol1,nLin2,nCol2,"> Consulta de Munic¡pios IBGE <")
   oBrow := TBrowseDB(nLin1+1,nCol1+1,nLin2-1,nCol2-1)
   oBrow:headSep := SEPH
   oBrow:colSep  := SEPV
   oBrow:colorSpec := ConVertCor(Cor(25))+","+ConVertCor(Cor(31))
   oBrow:addcolumn(TBColumnNew("Codigo",{|| MuniBge->CodMun}))
   oBrow:addcolumn(TBColumnNew("Cidade",{|| MuniBge->DesMun}))
   oBrow:addcolumn(tbcolumnnew("Estado",{|| MuniBge->EstMun}))
   AddKeyAction(K_ESC,    {|| lFim := .t.})
   AddKeyAction(K_ALT_X,  {|| xTecla := ""})
   AddKeyAction(K_CTRL_H, {|| IF((nLen := LEN(xTecla)) > 0,((xTecla := SUBSTR(xTecla, 1, --nLen)), MuniBge->(SeekIt(xTecla, .T., oBrow))),NIL) })
   xTecla := ""
   @ nLin2,nCol1+02 say "["
   @ nLin2,nCol1+33 say "]"
   WHILE (! lFim)
      @ nLin2,nCol1+3 say padr(xTecla,30) color COR(5)
      ForceStable(oBrow)
      if ( obrow:hittop .or. obrow:hitbottom )
         tone(1200,1)
      end
      cTecla := chr((nTecla := inkey(0)))
      if (nTecla >= 32 .and. nTecla <= 93) .or. (nTecla >= 96 .and. nTecla <= 125)
         if nTecla >= 97 .and. nTecla <= 122
            cTecla := chr(nTecla-32)
         end
      end
      if !OnKey( nTecla,oBrow)
         if !(nTecla == K_ENTER)
            if (nTecla >= 32 .and. nTecla <= 93) .or. (nTecla >= 96 .and. nTecla <= 125)
               xTecla += cTecla
               nRec := MuniBge->(Recno())
               if !MuniBge->(SeekIt(xTecla,.T.,obrow))
                  MuniBge->(dbgoto(nRec))
               end
            end
         end
      end
      if nTecla == K_ENTER
         if !lAbrir
            cDados := MuniBge->CodMun
            keyboard (cDados)
            lFim := .t.
         end
      elseif nTecla == K_F7 .and. lIncluir .and. !lAbrir
            //IncCidades(.f.)
            //Cidades->(dbsetorder(2))
            oBrow:refreshall()
      elseif nTecla == K_ESC
         lFim := .t.
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
// ****************************************************************************
procedure IncMuniIbge(lAbrir)
   local getlist := {},cTela := SaveWindow()
   local cCodMun,cDesMun,cEstMun

   if lAbrir
      if !AbrirArquivos()
         return
      end
   end
   DesativaF9()
   AtivaF4()
   TelaMuniIbge(1)
   while .t.
      cCodMun := space(07)
      cDesMun := space(40)
      cEstMun := space(02)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,24 get cCodMun picture "@k 9999999" when Rodape("Esc-Encerra | F4-Munic¡pios IBGE") valid Busca(@cCodMun,"MuniBge",1,,,,{"Munic¡pio IBGE j  cadastrado"},.f.,.f.,.t.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      @ 11,24 get cDesMun picture "@k!" when Rodape("Esc-Encerra") valid NoEmpty(cDesMun)
      @ 12,24 get cEstMun picture "@k!" when Rodape("Esc-Encerra | F4-Estados") valid Busca(cEstMun,"Estados",1,12,27,"Estados->NomEst",{"Estado Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      end
      if !Confirm("Confirma a InclusÆo")
         loop
      end
      // ***********************************************************************
      while !MuniBge->(Adiciona())
      end
      MuniBge->CodMuni := cCodMun
      MuniBge->DesMun  := cDesMun
      MuniBge->EstMun  := cEstMun
      MuniBge->(dbcommit())
      MuniBge->(dbunlock())
      Grava_Log(cDiretorio,"Municipio IBGE|Incluir|Codigo "+cCodMun,MuniBge->(recno()))
      if !lAbrir
         exit
      end
   end
   if lAbrir
      DesativaF4()
      if PwNivel == "0"
         AtivaF9()
         lGeral := .f.
      end
      FechaDados()
   end
   RestWindow(cTela)
   return
// ****************************************************************************
procedure AltMuniIbge
   local getlist := {},cTela := SaveWindow()
   local cCodMun,cDesMun,cEstMun

   if !AbrirArquivos()
      return
   end
   DesativaF9()
   AtivaF4()
   TelaMuniIbge(2)
   while .t.
      cCodMun := space(07)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,24 get cCodMun picture "@k 9999999" when Rodape("Esc-Encerra | F4-Munic¡pios IBGE") valid Busca(@cCodMun,"MuniBge",1,,,,{"Munic¡pio IBGE nÆo cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      cDesMun := MuniBge->DesMun
      cEstMun := Munibge->EstMun
      @ 11,24 get cDesMun picture "@k!" when Rodape("Esc-Encerra")              valid NoEmpty(cDesMun)
      @ 12,24 get cEstMun picture "@k!" when Rodape("Esc-Encerra | F4-Estados") valid Busca(cEstMun,"Estados",1,12,27,"Estados->NomEst",{"Estado Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      endif
      if !Confirm("Confirma a Altera‡Æo")
         loop
      endif
      do while !MuniBge->(Trava_Reg())
      enddo
      MuniBge->DesMun := cDesMun
      MuniBge->EstMun := cEstMun
      MuniBge->(dbcommit())
      MuniBge->(dbunlock())
      Grava_Log(cDiretorio,"Munic¡pio IBGE|Alterar|Codigo "+cCodMun,MuniBge->(recno()))
   end
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   end
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
procedure ExcMuniIbge
   local getlist := {},cTela := SaveWindow()
   local cCodMun

   if !AbrirArquivos()
      return
   end
   Msg(.f.)
   DesativaF9()
   AtivaF4()
   TelaMuniIbge(3)
   while .t.
      cCodMun := space(07)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,24 get cCodMun picture "@k 9999999" when Rodape("Esc-Encerra | F4-Munic¡pios IBGE") valid Busca(@cCodMun,"MuniBge",1,,,,{"Munic¡pio IBGE nÆo cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      @ 11,24 say Munibge->DesMun
      @ 12,24 say MuniBge->EstMun
      if !Confirm("Confirma a ExclusÆo",2)
         loop
      end
      while !MuniBge->(Trava_Reg())
      end
      MuniBge->(dbdelete())
      MuniBge->(dbcommit())
      MuniBge->(dbunlock())
      Grava_Log(cDiretorio,"Munic¡pio IBGE|Excluir|Codigo "+cCodMun,MuniBge->(recno()))
   end
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   end
   FechaDados()
   RestWindow(cTela)
   return
// ****************************************************************************
procedure TelaMuniIbge( nModo)
   local aTitulos := {"Inclusao","Alteracao","Exclusao"}

   Window(08,14,14,70,"> " + aTitulos[ nModo ] + " de Munic¡pios IBGE <")
   setcolor(Cor(11))
   //           678901234567890123456789012345678901234567890123456789012345678
   //               2         3         3         4         5         6         7
   @ 10,16 say "Codigo:"
   @ 11,16 say "Cidade:"
   @ 12,16 say "Estado:"
   return
// ****************************************************************************
static function AbrirArquivos

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !(Abre_Dados(cDiretorio,"Estados",1,aNumIdx[03],"Estados",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return(.f.)
   end
   if !(Abre_Dados(cDiretorio,"MuniBge",1,aNumIdx[39],"MuniBge",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return(.f.)
   end
   Msg(.f.)
   return(.t.)

//** Fim do Arquivo.
