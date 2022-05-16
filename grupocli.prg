/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 3.00
 * Identificacao: Manutencao de Grupos de Produtos
 * Prefixo......: LTADM
 * Programa.....: Grupos.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 05 de Mar‡o de 2004
 * Copyright (C): LT - LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConGrupoCliente(lAbrir)
   local oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados
   local nCursor := setcursor(),cCor := setcolor()
   local nLin1 := 02,nCol1 := 35,nLin2 := maxrow()-1,nCol2 := 79
   private nRecno

	if lAbrir
		if !AbrirArquivos()
			return
		endif
	else
		setcursor(SC_NONE)
	endif
   select GrupoCliente
   set order to 2
   goto top
	if lAbrir
		Rodape("Esc-Encerrar")
	else
		Rodape("Esc-Encerra | ENTER-Transfere")
	endif
   setcolor(cor(5))
   Window(nLin1,nCol1,nLin2,nCol2,"> Consulta de grupos de clientes <")
   oBrow := tbrowsedb(nLin1+1,nCol1+1,nLin2-1,nCol2-1)
   oBrow:headSep   := SEPH
   oBrow:colSep    := SEPV
   oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)   
   oBrow:addcolumn(tbcolumnnew("Codigo",{|| GrupoCliente->codigo }))
   oBrow:addcolumn(tbcolumnnew("Descricao",{|| GrupoCliente->Descricao }))
   AddKeyAction(K_ESC,    {|| lFim := .t.})
   AddKeyAction(K_ALT_X,  {|| xTecla := ""})
   AddKeyAction(K_CTRL_H, {|| if((nLen := len(xTecla)) > 0,((xTecla := substr(xTecla, 1, --nLen)), GrupoCliente->(SeekIt(xTecla, .T., oBrow))),NIL) })
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
               nRec := GrupoCliente->(Recno())
               if !GrupoCliente->(SeekIt(xTecla,.T.,obrow))
                  GrupoCliente->(dbgoto(nRec))
               end
            end
         end
      end
      if nTecla == K_ENTER
         if !lAbrir
            cDados := GrupoCliente->Codigo
            keyboard (cDados)
            lFim := .t.
         endif
      elseif nTecla == K_ESC
         lFim := .t.
      endif
   end
   if !lAbrir
      setcursor(nCursor)
      setcolor(cCor)
   else
      FechaDados()
   endif
   RestWindow( cTela )
   return
// ****************************************************************************
procedure IncGrupoCliente
   local getlist := {},cTela := SaveWindow()
   local cCodigo,cDescricao
   
	if !AbrirArquivos()
		return
	endif   
   	AtivaF4()
   	TelGrupoCliente(1)
   	while .t.
      cDescricao := space(30)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      if (Sequencia->GrupoCli+1) > 999
         Mens({"Limite de Grupos Esgotado","Favor Entrar em Contato com o Programador"})
         exit
      end
      cCodigo := strzero(Sequencia->GrupoCli+1,3)
      @ 11,30 say cCodigo picture "@k 999" 
      @ 12,30 get cDescricao picture "@k" when Rodape("Esc-Encerra")
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
      	exit
      endif
      if !Confirm("Confirma a Inclusao")
         loop
      endif
      	do while Sequencia->(!Trava_Reg())
      	enddo
      	Sequencia->Grupocli += 1
      	Sequencia->(dbunlock())
		cCodigo:= strzero(Sequencia->Grupocli)
		do while !GrupoCliente->(Adiciona())
		enddo
      	GrupoCliente->codigo    := cCodigo
      	GrupoCliente->descricao := cDescricao
      	GrupoCliente->(dbcommit())
      	GrupoCliente->(dbunlock())
   enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   endif
   FechaDados()
   RestWindow(cTela)
   return
// *****************************************************************************
procedure AltGrupoCliente
   local getlist := {},cTela := SaveWindow()
   local cCodigo,cDescricao

	if !AbrirArquivos()
		return
	endif
	if PwNivel == "0"
		DesativaF9()
	endif
	AtivaF4()
   	TelGrupoCliente(2)
   while .t.
      cCodigo := space(03)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,30 get cCodigo picture "@k 999";
      		when Rodape("Esc-Encerra | F4-Grupos de Clientes");
      		valid Busca(Zera(@cCodigo),"GrupoCliente",1,,,,{"Grupo Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      cDescricao := GrupoCliente->Descricao
      @ 12,30 get cDescricao picture "@k" when Rodape("Esc-Encerra")
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      endif
      if !Confirm("Confirma a Alteracao")
         loop
      endif
      do while !GrupoCliente->(Trava_Reg())
      enddo
      GrupoCliente->Descricao := cDescricao
      GrupoCliente->(dbcommit())
      GrupoCliente->(dbunlock())
   end
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   end
   FechaDados()
   RestWindow(cTela)
   return
// *****************************************************************************
procedure ExcGrupoCliente
   local getlist := {},cTela := SaveWindow()
   local cCodigo
   
	if !AbrirArquivos()
		return
	endif
   Msg(.f.)
   if PwNivel == "0"
      DesativaF9()
   end
   AtivaF4()
   TelGrupoCliente(3)
   while .t.
      cCodigo := space(03)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,30 get cCodigo picture "@k 999";
      			when Rodape("Esc-Encerra | F4-Grupos de clientes");
      			valid Busca(Zera(@cCodigo),"GrupoCliente",1,,,,{"Grupo Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      @ 12,30 say GrupoCliente->Descricao picture "@k!"
      if !Confirm("Confirma a Exclusao",2)
         loop
      endif
      do while !GrupoCliente->(Trava_Reg())
      enddo
      GrupoCliente->(dbdelete())
      GrupoCliente->(dbcommit())
      GrupoCliente->(dbunlock())
   enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   endif
   FechaDados()
   RestWindow(cTela)
   return
// *****************************************************************************
static procedure TelGrupoCliente(nModo)
   local aTitulos := {"InclusÆo","Altera‡Æo","ExclusÆo"}

   Window(09,17,14,61,"> "+aTitulos[nModo]+" de grupos de clientes <")
   setcolor(Cor(11))
   @ 11,19 say "   Codigo:"
   @ 12,19 say "Descricao:"
   return
   
static function AbrirArquivos
   
   	Msg(.t.)
   	Msg("Aguarde : Abrindo o Arquivo")
   	if !OpenGrupoCli()
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
   

//** Fim do Arquivo.
