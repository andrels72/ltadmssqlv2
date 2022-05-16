/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.00
 * Identificacao: Manuten‡Æo de Naturezas Fiscais
 * Prefixo......: LtAdm
 * Programa.....: Natureza.prg
 * Autor........: Andre Lucas Souza
 * Data.........: 24 de Novembro de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConNatureza(lAbrir)
	local acampo   := {"id","cfop","descricao"}
	local atitulo  := { "C¢digo","cfop","Descricao"}
	local amascara := { "999","9999","@"}
	local nCursor := setcursor(),cCor := setcolor(),cQuery
	private oQuery
 
	cQuery := "SELECT id,i.cfop,SUBSTRING(cfop.descricao,1,60) AS descricao FROM administrativo.natureza i "
	cQuery += "INNER JOIN administrativo.cfop cfop ON ( i.cfop = cfop.cfop ) "
	Msg(.t.)
	Msg("Aguarde: pesquisando")
	if !ExecuteSql(cQuery,@oQuery,{"Falha: pesquisa "},"sqlerro")
	   Msg(.f.)
	   return
	endif
	Msg(.f.)
	if oQuery:lastrec() = 0
	   Mens({"Tabela vazia"})
	   return
	endif
	ViewTableSql(oQuery,02,01,31,79,"> Natureza <",3,iif(!lAbrir,"id",NIL),aCampo,aTitulo,aMascara)
	setcursor(nCursor)
	setcolor(cCor)
return

// ****************************************************************************
procedure IncNatureza
	local gelist := {},cTela := SaveWindow()
	private nId,nCfop,cTipo,cOperacao,cLocal,cGerDup,cAltCus,cBxaEst
	private nAliquota,cObs1,cObs2,cObs3,cObs4,cObs5,cObs6,cQuery,oQuery
	
	DesativaF9()
	AtivaF4()
	TelNatureza(1)
	do while .t.
    	nCfop := 0
      	cTipo      := space(01)
      	cOperacao  := space(01)
    	cLocal     := space(01)
    	cGerDup    := space(01)
    	cAltCus    := space(01)
    	cBxaEst    := space(01)
    	nAliquota   := 0
    	cObs1 := space(90)
    	cObs2 := space(90)
    	cObs3 := space(90)
    	cObs4 := space(90)
    	cObs5 := space(90)
    	cObs6 := space(90)
    	setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		oQuery := oServer:Query("SELECT Last_value FROM administrativo.natureza_id_seq")
		nId := oQuery:fieldget('last_value')
		@ 07,19 say nId picture "999"
		if !GetNatureza()
			exit
		endif
		if !Confirm("Confirma a Inclusao")
			loop
		endif
        Msg(.t.)
        Msg("Aguarde: Gravando as informa‡äes")
		GravarNatureza(.t.)
        oServer:StartTransaction()
        if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        if !Grava_LogSql("Cadastros|Fiscal|Natureza|Incluir: "+str(nId))
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop
         endif
        oServer:Commit()
        oQuery:Close()
        Msg(.f.)
	enddo
	DesativaF4()
	if PwNivel == "0"
		AtivaF9()
	endif
	RestWindow(cTela)
return
// ****************************************************************************
procedure AltNatureza
	local gelist := {},cTela := SaveWindow()
	private nId,nCfop,cTipo,cOperacao,cLocal,cGerDup,cAltCus,cBxaEst
	private nAliquota,cObs1,cObs2,cObs3,cObs4,cObs5,cObs6,cQuery,oQuery
   
   DesativaF9()
   AtivaF4()
   TelNatureza(2)
   do while .t.
    	nId := 0
      	setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      	@ 07,19 get nId picture "@k 999";
      				when Rodape("Esc-Encerra | F4-Natureza Fiscal");
					  valid SqlBusca("id = "+NumberToSql(nId),"CFOP,TIPO,OPERACAO,ALIQUOTA,LOCAL,GERDUP,"+;
					  	"ALTCUS,BXAEST,OBS1,OBS2,OBS3,OBS4,OBS5,OBS6",@oQuery,;
					  "administrativo.natureza",,,,{"Natureza nÆo cadastrada"},.f.)
    	setcursor(SC_NORMAL)
      	read
    	setcursor(SC_NONE)
    	if lastkey() == K_ESC
    		exit
    	endif
		nCfop := oQuery:fieldget('Cfop')
		cTipo := oQuery:fieldget('Tipo')
		cOperacao := oQuery:fieldget('Operacao')
		nAliquota := oQuery:fieldget('Aliquota')
		cLocal    := oQuery:fieldget('Local')
		cGerDup   := oQuery:fieldget('GerDup')
		cAltCus   := oQuery:fieldget('AltCus')
		cBxaEst   := oQuery:fieldget('BxaEst')
		cObs1 := oQuery:fieldget('Obs1')
		cObs2 := oQuery:fieldget('Obs2')
		cObs3 := oQuery:fieldget('Obs3')
		cObs4 := oQuery:fieldget('Obs4')
		cObs5 := oQuery:fieldget('Obs5')
		cObs6 := oQuery:fieldget('Obs6')
		if !GetNatureza()
			loop
		endif
      	if !Confirm("Confirma a Alteracao")
         	loop
		endif
        Msg(.t.)
        Msg("Aguarde: Gravando as informa‡äes")
		GravarNatureza(.f.)
        oServer:StartTransaction()
        if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        if !Grava_LogSql("Cadastros|Fiscal|Natureza|Alterar|Codigo : "+str(nId))
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
    	oServer:Commit()
        oQuery:Close()
        Msg(.f.)
		Mens({"Altera‡Æo realizada com sucesso"})
   enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   endif
   RestWindow(cTela)
return
// ****************************************************************************
procedure ExcNatureza
   local gelist := {},cTela := SaveWindow()
   local nId,cQuery,oQuery,oQuery2

   
   DesativaF9()
   AtivaF4()
   TelNatureza(3)
	do while .t.
		nId := 0
      	setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      	@ 07,19 get nId picture "@k 99";
		  		when Rodape("Esc-Encerra | F4-Natureza Fiscal");
				valid SqlBusca("id = "+NumberToSql(nId),"CFOP,TIPO,OPERACAO,ALIQUOTA,LOCAL,GERDUP,"+;
				  "ALTCUS,BXAEST,OBS1,OBS2,OBS3,OBS4,OBS5,OBS6)",@oQuery,;
			  "administrativo.natureza",,,,{"Natureza nÆo cadastrada"},.f.)
      	setcursor(SC_NORMAL)
      	read
      	setcursor(SC_NONE)
      	if lastkey() == K_ESC
         	exit
		endif
		cQuery := "SELECT natsaident FROM administrativo.produtos WHERE natsaident = "+NumberToSql(nId)
        if !ExecuteSql(cQuery,@oQuery2,{"Erro: Incluir (caixa)"},"sqlerro")
            loop
        endif
		if oQuery2:lastrec() > 0
			Mens({"Existe produto"})
			loop
		endif
		cQuery := "SELECT natsaifora FROM administrativo.produtos WHERE natsaifora = "+NumberToSql(nId)
        if !ExecuteSql(cQuery,@oQuery2,{"Erro: Incluir (caixa)"},"sqlerro")
            loop
        endif
		if oQuery2:lastrec() > 0
			Mens({"Existe produto"})
			loop
		endif
		cQuery := "SELECT natentdent FROM administrativo.produtos WHERE natentdent = "+NumberToSql(nId)
        if !ExecuteSql(cQuery,@oQuery2,{"Erro: Incluir (caixa)"},"sqlerro")
            loop
        endif
		if oQuery2:lastrec() > 0
			Mens({"Existe produto"})
			loop
		endif
		cQuery := "SELECT natentfora FROM administrativo.produtos WHERE natentfora = "+NumberToSql(nId)
        if !ExecuteSql(cQuery,@oQuery2,{"Erro: Incluir (caixa)"},"sqlerro")
            loop
        endif
		if oQuery2:lastrec() > 0
			Mens({"Existe produto"})
			loop
		endif
    	@ 08,19 say oQuery:fieldget('cfop')
    	@ 09,19 say oQuery:fieldget('Tipo')
    	@ 10,19 say oQuery:fieldget('Operacao')
		@ 11,19 say oQuery:fieldget('Aliquota') picture "@k 99.99"
    	@ 12,19 say oQuery:fieldget('Local') 
    	@ 13,19 say oQuery:fieldget('GerDup')
    	@ 14,19 say oQuery:fieldget('AltCus')
    	@ 15,19 say oQuery:fieldget('BxaEst')
    	if !Confirm("Confirma a Exclusao",2)
    		loop
    	endif
		cQuery := "DELETE FROM administrativo.natureza WHERE id = "+NumberToSql(nId)
        Msg(.t.)
        Msg("Aguarde: Excluindo as informa‡äes")
        oServer:StartTransaction()
        if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
        if !Grava_LogSql("Cadastros|Fiscal|Natureza|Excluir|Codigo : "+str(nId))
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
    	oServer:Commit()
        oQuery:Close()
        Msg(.f.)
		Mens({"ExclusÆo realizada com sucesso"})
	enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   end
   RestWindow(cTela)
return
// ****************************************************************************
procedure TelNatureza( nModo)
   local aTitulos := {"Inclusao","Alteracao","Exclusao"}

   Window(05,00,24,92,"> " + aTitulos[ nModo ] + " de Natureza Fiscal <")
   setcolor(Cor(11))
   //            12345678901234567890123456789012345678901234567890123456789012345678
   //                     1        2         3         4         5         6         7
	@ 07,01 say "          Codigo:"
	@ 08,01 say "          C.F.O.:"	
	@ 09,01 say "            Tipo:"
	@ 10,01 say "        Operacao:"
	@ 11,01 say "        Aliquota:"
	@ 12,01 say "           Local:"
	@ 13,01 say "Gerar Duplicatas:"
	@ 14,01 say "  Alterar Precos:"
	@ 15,01 say " Alterar Estoque:"
	@ 16,01 say replicate(chr(196),91)
	@ 16,01 say " Observacao " color Cor(26)
return
// ****************************************************************************
static function GetNatureza
	// **
	@ 08,19 get nCfop picture "@k 9999";
				when Rodape("Esc-Encerra | F4-Tabela de CFOP");
				valid SqlBusca("cfop = "+NumberToSql(nCfop),"descricao",@oQuery,;
				"administrativo.cfop",row(),col()+1,{"descricao",60},{"CFOP nÆo cadastrado"},.f.)
	@ 09,19 get cTipo picture "@k!" ;
				valid MenuArray(@cTipo,{{"E","Entrada"},{"S","Saida  "}},row(),col(),row(),col()-1)
				
	@ 10,19 get cOperacao picture "@k!";
				valid iif(cTipo == "S",MenuArray(@cOperacao,{{"V","Venda   "},{"D","Devolucao"}},row(),col(),row(),col()-1),MenuArray(@cOperacao,{{"C","Compra"},{"D","Devolucao"}},row(),col(),row(),col()-1))
				
	@ 11,19 get nAliquota picture "@k 999.99"
	
	@ 12,19 get cLocal  picture "@k!";
				valid MenuArray(@cLocal,{{"D","Dentro do Estado"},{"F","Fora do Estado  "}},row(),col(),row(),col()-1)
				
	@ 13,19 get cGerDup picture "@k!";
				valid MenuArray(@cGerDup,{{"S","Sim"},{"N","Nao"}},row(),col(),row(),col()-1)
				
	@ 14,19 get cAltCus picture "@k!" valid MenuArray(@cAltCus,{{"S","Sim"},{"N","Nao"}},row(),col(),row(),col()-1)
	@ 15,19 get cBxaEst picture "@k!" valid MenuArray(@cBxaEst,{{"S","Sim"},{"N","Nao"}},row(),col(),row(),col()-1)
	@ 17,01 get cObs1 picture "@k!" 
	@ 18,01 get cObs2 picture "@k!"
	@ 19,01 get cObs3 picture "@k!"
	@ 20,01 get cObs4 picture "@k!"
	@ 21,01 get cObs5 picture "@k!"
	@ 22,01 get cObs6 picture "@k!"
	setcursor(SC_NORMAL)
	read
	setcursor(SC_NONE)
	if lastkey() == K_ESC
		return(.f.)
	endif
return(.t.)
// ****************************************************************************
static procedure GravarNatureza(lModo)

	if lModo
		cQuery := "INSERT INTO administrativo.natureza "
		cQuery += "( CFOP,TIPO,OPERACAO,ALIQUOTA,LOCAL,GERDUP,ALTCUS,BXAEST,OBS1,OBS2,OBS3,OBS4,OBS5,OBS6) "
		cQuery += " VALUES ("
		cQuery += NumberToSql(nCfop)+","
		cQuery += StringToSql(cTipo)+","
		cQuery += StringToSql(cOperacao)+","
		cQuery += NumberToSql(nAliquota,5,2)+","
		cQuery += StringToSql(cLocal)+","
		cQuery += StringToSql(cGerDup)+","
		cQuery += StringToSql(cAltCus)+","
		cQuery += StringToSql(cBxaEst)+","
		cQuery += StringToSql(cObs1)+","
		cQuery += StringToSql(cObs2)+","
		cQuery += StringToSql(cObs3)+","
		cQuery += StringToSql(cObs4)+","
		cQuery += StringToSql(cObs5)+","
		cQuery += StringToSql(cObs6)
		cQuery += ")"
	else
		cQuery := "UPDATE administrativo.natureza "
		cQuery += "set "
		cQuery += "cfop = "+NumberToSql(nCfop)+","
		cQuery += "tipo = "+StringToSql(cTipo)+","
		cQuery += "operacao = "+StringToSql(cOperacao)+","
		cQuery += "aliquota = "+NumberToSql(nAliquota,5,2)+","
		cQuery += "local = "+StringToSql(cLocal)+","
		cQuery += "gerdup = "+StringToSql(cGerDup)+","
		cQuery += "altcus = "+StringToSql(cAltCus)+","
		cQuery += "bxaest = "+StringToSql(cBxaEst)+","
		cQuery += "obs1 = "+StringToSql(cObs1)+","
		cQuery += "obs2 = "+StringToSql(cObs2)+","
		cQuery += "obs3 = "+StringToSql(cObs3)+","
		cQuery += "obs4 = "+StringToSql(cObs4)+","
		cQuery += "obs5 = "+StringToSql(cObs5)+","
		cQuery += "obs6 = "+StringToSql(cObs6)
		cQuery += " WHERE id = "+NumberToSql(nId)
	endif
return	  

//** Fim do Arquivo.
