/*************************************************************************
         Sistema: Administrativo
          VersÆo: 6.0
   Identifica‡Æo: Inutilização de Numeração de Notas Fiscais Eletrônicas
         Prefixo: LtAdm
        Programa: Pedidos.PRG
           Autor: Andre Lucas Souza
            Data: 04 de Novembro de 2014
   Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"


procedure NFeInutilizadaConsulta
	local cTela := SaveWindow()
	local oBrow,lFim := .f.,oColuna


	Msg(.t.)
	Msg("Aguarde : Abrindo o Arquivo")
	if !(Abre_Dados(cDiretorio,"nfeinut",1,2,"NFeInutilizada",1,.f.) == 0)
		FechaDados()
		Msg(.f.)
		return
	endif
	Msg(.f.)
	select NFeInutilizada
	set order to 1
	goto top
	Rodape("Esc-Encerra")

	setcolor(cor(5))
	Window(02,00,23,79,"> Consulta de NFE inutilizada <")
	oBrow := TBrowseDB(03,01,19,78)
	oBrow:headSep := SEPH
	oBrow:footSep := SEPB
	oBrow:colSep  := SEPV
	oBrow:colorSpec := ConVertCor(Cor(25))+","+ConVertCor(Cor(31))
	oBrow:addcolumn(tbcolumnnew("Numero"     ,{|| NFeInutilizada->Numero }))
	oBrow:addcolumn(tbcolumnnew("Modelo"     ,{|| NFeInutilizada->Modelo }))
	oBrow:addcolumn(tbcolumnnew("Serie"      ,{|| NFeInutilizada->Serie }))
	oBrow:addcolumn(tbcolumnnew("Ano"        ,{|| NFeInutilizada->Ano }))
	oColuna := tbcolumnnew("Data Hora"  ,{|| NFeInutilizada->DhRecbto })
	oColuna:width := 19
	oBrow:addcolumn(oColuna)
	oBrow:addcolumn(tbcolumnnew("Protocolo"  ,{|| NFeInutilizada->protocolo }))
	do while (! lFim)
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
			if nTecla == K_ESC
				lFim := .t.
			elseif nTecla == K_F10
			endif
		endif
	enddo
	FechaDados()
	RestWindow( cTela )
	RETURN

procedure NFeInutiliza
	local cTela := SaveWindow(),getlist := {}
	local cNumero,cModelo := "55", cSerie,cAno
	local cTexto1,cTexto2,cTexto3,cTexto4,cTexto5,cTexto6,cTexto7,cTexto8,cTexto9,cTexto10
	local cTexto11,cTexto12,cTexto13,lLimpa := .t.,dData

	Msg(.t.)
	Msg("Aguarde : Abrindo o Arquivo")
	if !(Abre_Dados(cDiretorio,"sequenci",0,0,"Sequencia",0,.f.) == 0)
		FechaDados()
		Msg(.f.)
		return
	endif
	if !(Abre_Dados(cDiretorio,"nfeinut",1,2,"NFeInutilizada",1,.f.) == 0)
		FechaDados()
		Msg(.f.)
		return
	endif
	Msg(.f.)
	AtivaF4()
	Window(02,00,22,79," Inutilizar Numeracao ")
	setcolor(Cor(11))
	//           234567890123456789012345678901234567890123456789012345678901234567890123456789
	//                   1         2         3         4         5         6         7
	@ 04,02 say "Numero:              Modelo:       Serie:        Ano:"
	@ 06,02 say TracoCentro(" Justificativa ",77,chr(196))
	do while .t.
		if lLimpa
			nNumero := 0
			nModelo := 55
			nSerie := 1
			nAno   := 0
			cTexto1 := space(76)
			cTexto2 := space(76)
			cTexto3 := space(76)
			cTexto4 := space(76)
			cTexto5 := space(76)
			cTexto6 := space(76)
			cTexto7 := space(76)
			cTexto8 := space(76)
			cTexto9 := space(76)
			cTexto10 := space(76)
			cTexto11 := space(76)
			cTexto12 := space(76)
			cTexto13 := space(76)
			cTexto   := ""
			lLimpa := .f.
		endif
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 04,10 get nNumero picture "@k 999999999" valid NoEmpty(nNumero)
		@ 04,31 get nModelo picture "@k 99" valid NoEmpty(nModelo)
		@ 04,44 get nSerie  picture "@k 999"
		@ 04,56 get nAno picture "@k 99" valid NoEmpty(nAno)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		if NFeInutilizada->(dbsetorder(1),dbseek(str(nNumero,9,0)+str(nModelo,2,0)+str(nSerie,3,0)+str(nAno,2,0)))
			Mens({"Numeracao Ja Inutilizada"})
			loop
		endif
		@ 08,02 get cTexto1 picture "@k" when Rodape("Esc-Encerra")
		@ 09,02 get cTexto2 picture "@k"
		@ 10,02 get cTexto3 picture "@k"
		@ 11,02 get cTexto4 picture "@k"
		@ 12,02 get cTexto5 picture "@k"
		@ 13,02 get cTexto6 picture "@k"
		@ 14,02 get cTexto7 picture "@k"
		@ 15,02 get cTexto8 picture "@k"
		@ 16,02 get cTexto9 picture "@k"
		@ 17,02 get cTexto10 picture "@k"
		@ 18,02 get cTexto11 picture "@k"
		@ 19,02 get cTexto12 picture "@k"
		@ 20,02 get cTexto13 picture "@k"
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			loop
		endif
		if !Confirm("Confirma as informaces")
			loop
		endif
        if !Status_NFeNFCe(cDirXmnl) 
            loop
        endif
		if !empty(cTexto1)
			cTexto += cTexto1
		endif
		if !empty(cTexto2)
			cTexto += cTexto2
		endif
		if !empty(cTexto3)
			cTexto += cTexto3
		endif
		if !empty(cTexto4)
			cTexto += cTexto4
		endif
		if !empty(cTexto5)
			cTexto += cTexto5
		endif
		if !empty(cTexto6)
			cTexto += cTexto6
		endif
		if !empty(cTexto7)
			cTexto += cTexto7
		endif
		if !empty(cTexto8)
			cTexto += cTexto8
		endif
		if !empty(cTexto9)
			cTexto += cTexto9
		endif
		if !empty(cTexto10)
			cTexto += cTexto10
		endif
		if !empty(cTexto11)
			cTexto += cTexto11
		endif
		if !empty(cTexto12)
			cTexto += cTexto12
		endif
		if !empty(cTexto13)
			cTexto += cTexto13
		endif
		Msg(.t.)
		Msg("Aguarde: Inutilizando Numeracao")
		AcbrNFe_InutilizarNFe(rtrim(Sequencia->DirNFE),clCGCLoj,cTexto,nAno,nModelo,nSerie,nNumero)
        cRetorno := Mon_Ret(rtrim(Sequencia->dirNFE),"sainfe.txt",Sequencia->Tempo)
		if !Men_Ok(cRetorno)
			Msg(.f.)
			LerErro(rtrim(Sequencia->DirNFe),"sainfe.txt")
			loop
		endif
		Msg(.f.)
		cCStat := RetornoSEFAZ("CStat",rtrim(Sequencia->dirNFE)+"\sainfe.txt")
		if !(cCStat == "102")
			Msg(.f.)
			LerErro(rtrim(Sequencia->DirNFe),"sainfe.txt")
			loop
		endif	
		cDhRecbto := RetornoSEFAZ("DhRecbto",rtrim(Sequencia->dirNFE)+"\sainfe.txt")
		cNProt    := RetornoSEFAZ("NProt",rtrim(Sequencia->dirNFE)+"\sainfe.txt")
		dData     := ctod(substr(cDhRecbto,1,2)+"/"+substr(cDhRecbto,4,2)+"/"+substr(cDhRecbto,7,4))
		
		do while !NFeInutilizada->(Adiciona())
		enddo
		
		NFeInutilizada->Numero := nNumero
		NFeInutilizada->Ano    := nAno
		NFeInutilizada->Modelo := nModelo
		NFeInutilizada->Serie  := nSerie
		NFeInutilizada->Data   := dData
		NFeInutilizada->inutilizad := .t.
		NFeInutilizada->DhRecbto := cDhRecbto
		NFeInutilizada->protocolo := cNProt
		NFeInutilizada->texto1 := cTexto1
		NFeInutilizada->texto2 := cTexto2
		NFeInutilizada->texto3 := cTexto3
		NFeInutilizada->texto4 := cTexto4
		NFeInutilizada->texto5 := cTexto5
		NFeInutilizada->texto6 := cTexto6
		NFeInutilizada->texto7 := cTexto7
		NFeInutilizada->texto8 := cTexto8
		NFeInutilizada->texto9 := cTexto9
		NFeInutilizada->texto10 := cTexto10
		NFeInutilizada->texto11 := cTexto11
		NFeInutilizada->texto12 := cTexto12
		NFeInutilizada->texto13 := cTexto13
		NFeInutilizada->(dbcommit())
		NFeInutilizada->(dbunlock())
		lLimpa := .t.
	enddo
	FechaDados()
	RestWindow(cTela)
	return
	
// ** Fim de arquivo.
	