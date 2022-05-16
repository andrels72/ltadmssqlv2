/*************************************************************************
         Sistema: Controle Administrativo
          VersÆo: 2.00
   Identifica‡Æo: Modulo de Carta de correção eletronica
         Prefixo: CCE
        Programa: CCE.PRG
           Autor: Andre Lucas Souza
            Data: 22 de Junho de 2013
   Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"


procedure IncluirCartaCorrecao
	local getlist := {}, cTela := SaveWindow()
	local cNrNFE,cTexto1,cTexto2,cTexto3,cTexto4,cTexto5,cTexto6,cTexto7,cTexto8
	local cTexto9,cTexto10,cTexto11,cTexto12,cTexto13,lLimpar := .t.
	local dData,cHora,nSequencia := 0
	

	
	Msg(.t.)
	Msg("Aguarde: Abrindo os arquivos")
    if !OpenNfeVen()
		FechaDados()
		Msg(.f.)
		return
	endif
    if !OpenClientes()
		FechaDados()
		Msg(.f.)
		return
	endif
    if !OpenCCe()
		FechaDados()
		Msg(.f.)
		return
	endif
    if !OpenSequencia()
		FechaDados()
		Msg(.f.)
		return
	endif
	
	Msg(.f.)
	AtivaF4()
	Window(02,00,22,79," Carta de Correcao ")
	setcolor(Cor(11))
	//           234567890123456789012345678901234567890123456789012345678901234567890123456789
	//                   1         2         3         4         5         6         7
	@ 04,02 say "Numero da Nota :            Data :            Hora :           Nr Seq.:"
	@ 06,02 say TracoCentro(" Correcao ",77,chr(196))
	
	do while .t.
		dData := date()
		cHora := time()
		nSequencia := 0
		if lLimpar
			cNrNFE := space(09)
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
			lLimpar := .f.
		endif
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		@ 04,37 say dData
		@ 04,55 say cHora
		@ 04,19 get cNrNFE picture "@k 999999999" when rodape("ESC-Encerrar | F4-Notas") valid Busca(Zera(@cNrNFE),"nfeven",3,,,,{"Nota Fiscal Nao Cadastrado"},.f.,.f.,.f.)
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		if !NfeVen->NFeTransmi
			Mens({"Nota Fiscal Nao transmitida"})
			loop
		endif
		nSequencia := SeqEvento(cNrNFE)
		@ 04,75 say nSequencia picture "99"
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
		if !Confirm("Confirma as informacoes")
			loop
		endif
		if !Testa_Internet()
			Mens({"Sem acesso a internet","Carta de Correcao nao pode enviada"})
			loop
		endif
        if !Status_NFeNFCe(Sequencia->dirNFe)
			loop
		endif
		cComando := ""
		cComando += "[CCE]"                             + chr(K_ENTER)+chr(K_CTRL_ENTER)
		cComando += "IdLote=1"                          + chr(K_ENTER)+chr(K_CTRL_ENTER)
		cComando += "[EVENTO001]"                       + chr(K_ENTER)+chr(K_CTRL_ENTER)
		cComando += "chNFe="+NfeVen->ChNFe              + chr(K_ENTER)+chr(K_CTRL_ENTER)
		cComando += "cOrgao="+substr(NFEVen->ChNFE,1,2) + chr(K_ENTER)+chr(K_CTRL_ENTER)
		cComando += "CNPJ="+clCGCLoj                    + chr(K_ENTER)+chr(K_CTRL_ENTER)
		cComando += "dhEvento="+dtoc(dDAta)+cHora       + chr(K_ENTER)+chr(K_CTRL_ENTER)
		cComando += "nSeqEvento="+alltrim(str(nSequencia)) + chr(K_ENTER)+chr(K_CTRL_ENTER)
		cTexto := ""
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
		cComando := ""
		cComando += "[CCE]"                             + chr(K_ENTER)+chr(K_CTRL_ENTER)
		cComando += "IdLote=1"                          + chr(K_ENTER)+chr(K_CTRL_ENTER)
		cComando += "[EVENTO001]"                       + chr(K_ENTER)+chr(K_CTRL_ENTER)
		cComando += "chNFe="+NfeVen->ChNFe              + chr(K_ENTER)+chr(K_CTRL_ENTER)
		cComando += "cOrgao="+substr(NFEVen->ChNFE,1,2) + chr(K_ENTER)+chr(K_CTRL_ENTER)
		cComando += "CNPJ="+clCGCLoj                    + chr(K_ENTER)+chr(K_CTRL_ENTER)
		cComando += "dhEvento="+dtoc(dDAta)+cHora       + chr(K_ENTER)+chr(K_CTRL_ENTER)
        cComando += "tpEvento=110110" + chr(K_ENTER)+chr(K_CTRL_ENTER)
		cComando += "nSeqEvento="+alltrim(str(nSequencia)) + chr(K_ENTER)+chr(K_CTRL_ENTER)
		cComando += "xCorrecao="+cTexto
        
		AcbrNFe_EnviarEvento(rtrim(Sequencia->DirNFE),cComando)
		cRetorno := Mon_Ret(rtrim(Sequencia->DirNFE),"sainfe.txt",Sequencia->Tempo)
	    if !Men_Ok(cRetorno)
            Msg(.f.)
            LerErro(rtrim(Sequencia->DirNFe),"sainfe.txt")
            return(.f.)
        endif
		nProt       := RetornoSefaz("nProt",rtrim(Sequencia->DirNFE)+"\sainfe.txt")
		dhRegEvento := RetornoSefaz("dhRegEvento",rtrim(Sequencia->DirNFE)+"\sainfe.txt")
		cStat       := RetornoSefaz("cStat",rtrim(Sequencia->DirNFE)+"\sainfe.txt")
		xMotivo     := RetornoSefaz("xMotivo",rtrim(Sequencia->DirNFE)+"\sainfe.txt")
        
		do while !CartaDeCorrecao->(Adiciona())
		enddo
		CartaDeCorrecao->nota    := cNrNFe
		CartaDeCorrecao->sequencia := nSequencia
		CartaDeCorrecao->Data    := dData
		CartaDeCorrecao->Hora    := cHora
		CartaDeCorrecao->texto1  := cTexto1
		CartaDeCorrecao->texto2  := cTexto2
		CartaDeCorrecao->texto3  := cTexto3
		CartaDeCorrecao->texto4  := cTexto4
		CartaDeCorrecao->texto5  := cTexto5
		CartaDeCorrecao->texto6  := cTexto6
		CartaDeCorrecao->texto7  := cTexto7
		CartaDeCorrecao->texto8  := cTexto8
		CartaDeCorrecao->texto9  := cTexto9
		CartaDeCorrecao->texto10 := cTexto10
		CartaDeCorrecao->texto11 := cTexto11
		CartaDeCorrecao->texto12 := cTexto12
		CartaDeCorrecao->texto13 := cTexto13
		
		CartaDeCorrecao->Protocolo := nProt
		CartaDeCorrecao->dhRegEvent := dhRegEvento
		CartaDeCorrecao->cStat      := cStat
		CartaDeCorrecao->(dbcommit())
		CartaDeCorrecao->(dbunlock())
		Mens({substr(xMotivo,1,40)})
		lLimpar := .t.
	enddo
	DesativaF4()
	FechaDados()
	RestWindow(cTela)
	return
	
static function SeqEvento(cNota)
	local nSeqEvento := 1

	if CartaDeCorrecao->(dbgotop(),dbsetorder(1),dbseek(cNota))
		do while CartaDeCorrecao->Nota == cNota .and. CartaDeCorrecao->(!eof())
			nSeqEvento := CartaDeCorrecao->Sequencia + 1
			CartaDeCorrecao->(dbskip())
		enddo
	else
		nSeqEvento := 1
	endif
	return(nSeqEvento)
	
	
procedure ImprimirCartaDeCorrecao
	local getlist := {}, cTela := SaveWindow()
	local cNrNota,nSequencia
	
	Msg(.t.)
	Msg("Aguarde: Abrindo os arquivos")
    if !OpenCce()
		FechaDados()
		Msg(.f.)
		return
	endif
    if !OpenNfeVen()
		FechaDados()
		Msg(.f.)
		return
	endif
    if !OpenSequencia()
		FechaDados()
		Msg(.f.)
		return
	endif
	Msg(.f.)
	Window(07,08,16,69," Imprimir Carta de Correcao ")
	setcolor(Cor(11))
	//           01234567890123456789012345678901234567890123456789012345678901234567890123456789
	//                     2         3         4         5         6         7
	@ 09,10 say "  Nr. da Nota:"
	@ 10,10 say "Nr. Sequencia:"
	@ 11,10 say "         Data:"
	@ 12,10 say "         Hora:"
	@ 13,10 say "Nr. Protocolo:"
	@ 14,10 say "    Data/Hora:"
	do while .t.
		cNrNota    := space(09)
		nSequencia := 0
		setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))		
		@ 09,25 get cNrNota    picture "@k 999999999" valid V_Zera(@cNrNota)
		@ 10,25 get nSequencia picture "@k 99"
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		if !NFeVen->(dbsetorder(3),dbseek(cNrNota))
			Mens({"Nota Fiscal Nao cadastrada"})
		endif
		if !CartaDeCorrecao->(dbsetorder(2),dbseek(cNrNota+str(nSequencia,2,0)))
			Mens({"Carta de Correcao para a sequencia","Nao transmitida"})
			loop
		endif
		@ 11,25 say CartaDeCorrecao->Data
		@ 12,25 say CartaDeCorrecao->Hora
		@ 13,25 say CartaDeCorrecao->Protocolo
		@ 14,25 say CartaDeCorrecao->dhRegEvent
		if !Confirm("Confirma os dados")
			loop
		endif
		if !Testa_Internet()
			Mens({"Sem acesso a internet","Carta de Correcao nao pode enviada"})
			loop
		endif
        if !Status_NFeNFCe(Sequencia->dirNFe)
			loop
		endif
		
		Msg(.t.)
		Msg("Aguarde: Imprimindo Carta de Correcao")
        // envento de carta de corre‡Æo
        AcbrNFe_ImprimirEvento(rtrim(Sequencia->DirNFE),rtrim(Sequencia->DirCCe),NfeVen->ChNfe,nSequencia,110110)
		Msg(.f.)
		cRetorno := Mon_Ret(rtrim(Sequencia->DirNFE),"sainfe.txt",Sequencia->Tempo)
        if !Men_Ok(cRetorno)
		  Msg(.f.)
		  LerErro(rtrim(cDirXml),"sainfe.txt")
          loop
	   endif
        Msg(.f.)
		Mens({"Carta de Correcao","Impressao com sucesso"})
	enddo
	DesativaF4()
	FechaDados()
	RestWindow(cTela)
return
		
		
	


	
	
// ** Fim do arquivo