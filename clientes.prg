/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.00
 * Identificacao: Manutencao de Clientes
 * Prefixo......: Ltadm
 * Programa.....: Clientes.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 18 de Agosto de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConCliente(lAbrir)
	local getlist := {},oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados
	local nCursor := setcursor(),cCor := setcolor(),cQuery,oQuery
	local nLin1 := 04,nCol1 := 00,nLin2 := 30,nCol2 := 85
	local cTipo := '1',aTipo,cPesquisa
	private nRecno
 
	if !lAbrir
		setcursor(SC_NONE)
	endif

	cQuery := "SELECT id FROM administrativo.clientes LIMIT 1"
	Msg(.t.)
	Msg("Aguarde: Pesquisando clientes ")
	if !ExecuteSql(cQuery,@oQuery,{"Falha: pesquisar informa‡äes"},"sqlerro")
		oQuery:Close()
		Msg(.f.)
		return
	endif
	Msg(.f.)
	if oQuery:Lastrec() = 0
		Mens({"Tabela de clientes vazia"})
		oQuery:Close()
		return
	endif
	 
	Window(02,00,30,85,"> Consulta de Clientes <")
	setcolor(Cor(11))
	 //           1234567890123456789012345678901234567890123456789012345678901234567890
	 //                    1         2
	@ 03,01 say "Pesquisar:              "
	@ 04,01 say replicate(chr(196),84)
	cPesquisa := space(40)
	 
	 setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
	 @ 03,12 get cTipo picture "@k 9";
				 valid MenuArray(@cTipo,{{"1","   Nome:"},{"2","Apelido:"}},,,row(),col()+1)
	 @ 03,23 get cPesquisa picture "@K!"
	 setcursor(SC_NORMAL)
	 read
	 setcursor(SC_NONE)
	 if lastkey() == K_ESC    
		 if !lAbrir
			 setcursor(nCursor)
			 setcolor(cCor)
		 endif
		 RestWindow( cTela )
		 return
	 endif
	cQuery := "SELECT id, nomcli, apecli " 
	cQuery += "FROM administrativo.clientes "
	if cTipo = "1"
		if !empty(cPesquisa)
			cQuery += " WHERE NomCli LIKE '%"+rtrim(cPesquisa)+"%'"
		endif
	else
		if !empty(cPesquisa)
			cQuery += " WHERE ApeCli LIKE '%"+rtrim(cPesquisa)+"%'"
		endif
	endif
	if cTipo = "1" // Nome
		cQuery += "ORDER BY NomCli"
	else
		cquery += " ORDER BY ApeCli "
	endif
	Msg(.t.)
	Msg("Aguarde: Pesquisando clientes ")
	if !ExecuteSql(cQuery,@oQuery,{"Falha: pesquisar informa‡äes"},"sqlerro")
		oQuery:Close()
		Msg(.f.)
		return
	endif
	Msg(.f.)
	if oQuery:Lastrec() = 0
		if !empty(cPesquisa)
			Mens({"NÆo existe informa‡Æo"})
			oQuery:Close()
			RestWindow(cTela)
			return
		endif
	endif
	 if lAbrir
		 Rodape("Esc-Encerrar")
	 else
		 Rodape("Esc-Encerra | ENTER-Transfere")
	 endif
	Pos := 1
	setcolor(cor(5))
	oBrow := TBrowseDB(nLin1+1,nCol1+1,nLin2-2,nCol2-1)
	oBrow:headSep := chr(194)+chr(196)
	oBrow:colSep  := chr(179)
	oBrow:footSep := chr(193)+chr(196)
	oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)
	oCurRow := oQuery:GetRow( 1 )
	oBrow:SkipBlock := {| n | oCurRow := SkipperQuery( @n, oQuery ), n }
	oBrow:GoBottomBlock := {|| oCurRow := oQuery:GetRow( oQuery:LastRec() ), 1 }
	oBrow:GoTopBlock := {|| oCurRow := oQuery:GetRow( 1 ), 1 }
	oBrow:addcolumn(TBColumnNew("Nome" ,{|| oQuery:fieldget("nomcli") }))
	oBrow:addcolumn(TBColumnNew("Apelido" ,{|| oQuery:fieldget("ApeCli") }))
	setcolor(Cor(26))
	SCROLL(nLin2-1,01,nLin2-1,nCol2-1,0)
	Centro(nLin2-1,01,78,"F3-Visualizar")
	 do WHILE (! lFim)
		 ForceStable(oBrow)
		 if ( obrow:hittop .or. obrow:hitbottom )
			 tone(1200,1)
		 endif
		 aRect := { oBrow:rowPos,1,oBrow:rowPos,2}
		 oBrow:colorRect(aRect,{2,2})
		 cTecla := chr((nTecla := inkey(0)))
		 if !OnKey( nTecla,oBrow)
		 endif
		 if nTecla == K_F3
			 VerCliente(oQuery)
		 elseif nTecla == K_ENTER
			 if !lAbrir
				 cDados := str(oQuery:FieldGet('codcli'))
				 keyboard (cDados)+chr(K_ENTER)
				 lFim := .t.
			 endif
		 elseif nTecla == K_ESC
			 lFim := .t.
		 endif
		 oBrow:refreshcurrent()
	 enddo
	 if !lAbrir
		 setcursor(nCursor)
		 setcolor(cCor)
	 else
		 oQuery:close()
	 endif
	 RestWindow( cTela )
RETURN
// ****************************************************************************
procedure IncCliente
   local getlist := {},cTela := SaveWindow()
   local lLimpa := .t.,cQuery,oQuery
   private oCliente,nId

   if PwNivel == "0"
      DesativaF9()
   endif 
   AtivaF4()
   TelCliente(1)
	do while .t.
		if lLimpa
			oCliente := TCliente():new()
			lLimpa := .f.
		endif
      	setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
		oQuery := oServer:Query("SELECT Last_value FROM administrativo.clientes_id_seq")
		nId := oQuery:fieldget('last_value')
      	@ 04,11 say nId picture "9999"
      	@ 04,27 get oCliente:cTipCli picture "@k!" valid oCliente:cTipCli $ "FJ"
      	setcursor(SC_NORMAL)
      	read
		if lastkey() == K_ESC
			exit
		endif
		if oCliente:cTipCli == "J"
			@ 13,11 get oCliente:cCgcCli picture "@r 99.999.999/9999-99";
            		when Rodape("Esc-Encerra | Deixe em branco caso queira cadastrar");
					valid iif(empty(oCliente:cCgcCli),.t.,SqlBusca("cgccli = "+StringToSql(oCliente:cCgcCli),"nomcli",;
							@oQuery,"administrativo.clientes",,,,{"Cliente j  cadastrado"},.t.))
		else
			@ 14,11 get oCliente:cCpfCli picture "@r 999.999.999-99";
                	when Rodape("Esc-Encerra | Deixe em branco caso queira cadastrar");
					valid iif(empty(oCliente:cCpfCli),.t.,SqlBusca("cgccli = "+StringToSql(oCliente:cCpfCli),"nomcli",;
						@oQuery,"administrativo.clientes",,,,{"Cliente j  cadastrado"},.t.))
		endif
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		if !GetClientes(.t.)
			exit
		endif
		if !Confirm("Confirma a Inclusao")
			loop
		endif
        Msg(.t.)
        Msg("Aguarde: Gravando as informa‡äes")
        oServer:StartTransaction()
        if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar "},"sqlerro")
            oQuery:Close()
            oServer:Rollback()
            Msg(.f.)
            loop
        endif
		if !GravarClientes(.t.)
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
	if PwNivel == "0"
		AtivaF9()
		lGeral := .f.
	endif
	RestWindow(cTela)
return
// *****************************************************************************
procedure AltCliente
	local getlist := {},cTela := SaveWindow()
	private oCliente,nId,oQuery,cQuery
   
   if PwNivel == "0"
      DesativaF9()
   endif
   AtivaF4()
   TelCliente(2)
	do while .t.
		oCliente := TCliente():new()
      	cCodCli := space(04)
      	setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      	@ 04,11 get cCodCli picture "@k 9999";
      			when Rodape("Esc-Encerra | F4-Clientes");
      			valid Busca(Zera(@cCodCli),"Clientes",1,,,,{"Cliente Nao Cadastrado"},.f.,.f.,.f.)
      	setcursor(SC_NORMAL)
      	read
      	setcursor(SC_NONE)
      	if lastkey() == K_ESC
         	exit
      	endif
      	oCliente:RecuperarDados()
      	@ 04,27 say oCliente:cTipCli 
		if oCliente:cTipCli == "J"
			@ 13,11 get oCliente:cCgcCli picture "@r 99.999.999/9999-99"
		else
			@ 14,11 get oCliente:cCpfCli picture "@r 999.999.999-99"
		endif
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		if oCliente:cTipCli == "J"
            if !empty(oCliente:cCgcCli)
                if !(oCliente:cCgcCli == Clientes->CgcCli)
                    if Clientes->(dbsetorder(4),dbseek(oCliente:cCgcCli))
                        Mens({"CNPJ ja cadastrado"})
                        loop
                    endif
                endif
            endif
		else
            if !empty(oCliente:cCpfCli)
                if !(oCliente:cCpfCli == Clientes->CpfCli)  
                    if Clientes->(dbsetorder(3),dbseek(oCliente:cCpfCli))
                        Mens({"CPF ja cadastrado"})
                        loop
                    endif
                endif
            endif
		endif
		if !GetClientes(.t.)
			loop
		endif
		if !Confirm("Confirma a Alteracao")
			loop
		endif
		GravarClientes(.f.)
		Grava_Log(cDiretorio,"Clientes|Alterar|Codigo "+cCodCli,Clientes->(recno()))
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
procedure ExcCliente
   local getlist := {},cTela := SaveWindow()
   local cCodCli
   private oCliente
   
	if !AbrirArquivos()
		return
	endif
	   
	if PwNivel == "0"
		DesativaF9()
	endif
	AtivaF4()
	TelCliente(3)
	do while .t.
		oCliente := TCliente():new()
		cCodCli := space(04)
      	setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      	@ 04,11 get cCodCli picture "@k 9999";
      			when Rodape("Esc-Encerra | F4-Clientes");
      			valid Busca(Zera(@cCodCli),"Clientes",1,,,,{"Cliente Nao Cadastrado"},.f.,.f.,.f.)
      	setcursor(SC_NORMAL)
      	read
      	setcursor(SC_NONE)
      	if lastkey() == K_ESC
         	exit
      	endif
      	oCliente:RecuperarDados()
      	@ 04,27 say oCliente:cTipCli 
		@ 13,11 say oCliente:cCgcCli picture "@r 99.999.999/9999-99"
		@ 14,11 say oCliente:cCpfCli picture "@r 999.999.999-99"
		GetClientes(.f.)
      	if !Confirm("Confirma a Exclusao",2)
         	loop
      	endif
      	do while !Clientes->(Trava_Reg())
      	enddo
      	Clientes->(dbdelete())
      	Clientes->(dbcommit())
      	Clientes->(dbunlock())
      	Grava_Log(cDiretorio,"Clientes|Excluir|Codigo "+cCodCli,Clientes->(recno()))
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
procedure VerCliente()
   local cTela := SaveWindow(),cCodCli

   TelCliente(4)
   MosCli()
   Rodape(space(20)+"Pressione Qualquer Tecla para Continuar")
   Inkey(0)
   RestWindow(cTela)
   return
// *****************************************************************************
static procedure MosCli

	Cidades->(dbsetorder(1),dbseek(Clientes->CodCid))
	Natureza->(dbsetorder(1),dbseek(Clientes->CodNat))
	Vendedor->(dbsetorder(1),dbseek(Clientes->CodVen))
   
	@ 04,49 say Clientes->IndIFinal 
	@ 04,62 say Clientes->BloCli  picture "@k!" 
	@ 04,75 say Clientes->DatCli  picture "@k"
	@ 05,12 say Clientes->NomCli  picture "@k" 
	@ 06,12 say Clientes->ApeCli  picture "@k"
	@ 07,12 say Clientes->EndCli  picture "@k"
	@ 07,82 say Clientes->NumCli  picture "@k"
	@ 08,12 say Clientes->Compl   picture "@k"
	@ 09,12 say Clientes->BaiCli  picture "@k"
	@ 10,12 say Clientes->CodCid
// **				when Rodape("Esc-Encerra | F4-Cidades");
// **				valid Busca(Zera(@oCliente:cCodCid),"Cidades",1,row(),col(),;
// **					"'-'+Cidades->NomCid+' Estado: '+Cidades->EstCid",{"Cidade Nao Cadastrada"},.f.,.f.,.f.)
	@ 11,12 say Clientes->CepCli  picture "@kr 99999-999"
	@ 11,37 say Clientes->TelCli1 picture "@kr (999)9999-9999"
	@ 11,55 say Clientes->TelCli2 picture "@kr (999)9999-9999"
	@ 12,12 say Clientes->FaxCli  picture "@kr (999)9999-9999"
	@ 12,37 say Clientes->CelCli  picture "@k"
	@ 13,12 say Clientes->EMaCli  picture "@k"
	@ 14,12 say Clientes->ConCli  picture "@k"
	@ 15,46 say Clientes->IndIEDest 
	@ 16,12 say Clientes->IEsCli  picture "@k" 
	@ 18,12 say Clientes->RgCli   picture "@k" 
	@ 19,12 say Clientes->NasCli  picture "@k"
	@ 19,44 say Clientes->CodNat
	@ 20,12 say Clientes->SpcCli  picture "@k!"
	@ 20,44 say Clientes->CodVen  picture "@k 99"
	@ 21,12 say Clientes->Limite  picture "@ke 999,999,999.99"
	@ 22,12 say Clientes->Obs     picture "@k!"
return
// *****************************************************************************
procedure TelCliente(nModo )
   local cTitulo, aTitulos := {"InclusÆo","Altera‡Æo","ExclusÆo","Visualizacao" }

   Window(02,00,33,100,"> "+aTitulos[nModo]+" de Clientes <")
   setcolor(Cor(11))
   //            1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
   //                     1         2         3         4         5         6         7        8          9         0
	@ 04,01 say "  C½digo:           Tipo:    Consumidor Final:    Bloqueio:    Cadastro:"
	@ 05,01 say "    Nome:"
	@ 06,01 say "Fantasia:"
	@ 07,01 say "Endereco:                                                              Numero:"
	@ 08,01 say "  Compl.:"
	@ 09,01 say "  Bairro:"
	@ 10,01 say "  Cidade:"
	@ 11,01 say "     Cep:           Fone:                  Fax:                 Celular:"
	@ 12,01 say "  E-Mail:                                           Contato: "
    
	@ 13,01 say "    CNPJ:                         I.Est.:                 Tipo Contrib.:"
	@ 14,01 say "  C.P.F.:                           R.G.:"
	@ 15,01 say "Dta Nasc:                          Grupo:"
	@ 16,01 say "     SPC:                       Natureza:                      Vendedor:"
	@ 17,01 say "  Limite:                       Cobranca:"
	@ 18,01 say "    Obs.:"
    
	@ 20,01 say replicate(chr(196),99)
	@ 20,01 say " Endereco de Cobranca " color Cor(26)
	@ 20,25 say " Usar endereco principal ?   "
	@ 21,01 say "Endereco:                                                               Numero:"
	@ 22,01 say "  Compl.:"
	@ 23,01 say "  Bairro:"
	@ 24,01 say "  Cidade:"
	@ 25,01 say "     Cep:           Fone:                  Fax:                 Celular:"
    	
	@ 26,01 say replicate(chr(196),99)
	@ 26,01 say " Endereco para Entrega " color Cor(26)
	@ 26,25 say " Usar endereco principal ?   "
	@ 27,01 say "Endereco:                                                               Numero:"
	@ 28,01 say "  Compl.:"
	@ 29,01 say "  Bairro:"
	@ 30,01 say "  Cidade:"
	@ 31,01 say "     Cep:           Fone:                  Fax:                 Celular:"		
return
// *****************************************************************************
static function GetClientes(lGet)
	local oQuery

	@ 04,048 get oCliente:cIndIFinal picture "@k9";
			valid MenuArray(@oCliente:cIndIFinal,{{"0","Normal          "},{"1","Consumidor Final"}})
    @ 04,061 get oCliente:cBloCli  picture "@k!";
			valid MenuArray(@oCliente:cBlocli,{{"N","Nao"},{"S","Sim"}},04,46)
    @ 04,074 get oCliente:dDatCli  picture "@k"
    @ 05,011 get oCliente:cNomCli  picture "@k";
			valid NoEmpty(oCliente:cNomCli)
    @ 06,011 get oCliente:cApeCli  picture "@k";
    		valid iif(empty(oCliente:cApeCli),(oCliente:cApeCli := oCliente:cNomCli,.t.),.t.)
    		
    @ 07,011 get oCliente:cEndCli  picture "@k"
    @ 07,080 get oCliente:cNumCli  picture "@k"  valid NoEmpty(oCliente:cNumCli)
    
    @ 08,011 get oCliente:cCompl   picture "@k"
    @ 09,011 get oCliente:cBaiCli  picture "@k"
    // ** Codigo da cidade
    @ 10,011 get oCliente:nIdCidade  picture "@k 9999";
    			when Rodape("Esc-Encerra | F4-Cidades");
				valid  vCidades(oCliente:nIdCidade,row(),col()+1)
    @ 11,011 get oCliente:cCepCli  picture "@kr 99999-999" when Rodape("Esc-Encerra")
    @ 11,027 get oCliente:cTelCli1 picture "@kr (999)99999-9999"
    @ 11,049 get oCliente:cFaxCli  picture "@kr (999)99999-9999"
    @ 11,074 get oCliente:cCelCli  picture "@kR (999)99999-9999"
    
    
    @ 12,011 get oCliente:cEMaCli  picture "@k"
    @ 12,062 get oCliente:cConCli  picture "@k"
    
    
    @ 13,074 get oCliente:cIndIEDest picture "@k9";
            when iif(nTipoEstoque = 0,.t.,.f.);
    			valid MenuArray(@oCliente:cIndIEDest,{;
    			{"1","Contribuinte ICMS  "},;
    			{"2","Contribuinte ISENTO"},;
    			{"9","Nao Contribuinte   "}})
                
    @ 13,043 get oCliente:cIEsCli  picture "@k";
    			when oCliente:cIndIEDest <> "2" .and. oCliente:cTipCli == "J"
                
    
    @ 14,043 get oCliente:cRgCli picture "@k";
				when oCliente:cTipCli == "F"
    @ 15,011 get oCliente:dNasCli picture "@k";
				when oCliente:cTipCli == "F"      
    // ** Grupos de clientes
    @ 15,043 get oCliente:nIdGrupoCli picture "@k 999";
    			when Rodape("Esc-Encerrar | F4-Grupos de clientes");
				valid iif(empty(oCliente:nIdGrupoCli),.t.,SqlBusca("id = "+NumberToSql(oCliente:nIdGrupoCli),"descricao",@oQuery,;
					"administrativo.gruposclientes",row(),col()+1,{"descricao",16},{"Grupo nÆo cadastrado"},.f.))

	// ** SPC 
	@ 16,11 get oCliente:cSpcCli  picture "@k!";
      			when iif(oCliente:cTipCli == "F",Rodape("Esc-Encerra"),.f.);
      			Valid MenuArray(@oCliente:cSpcCli,{{"N","Nao"},{"S","Sim"}},19,13)
      			
    // ** Natureza fiscal  			
	@ 16,43 get oCliente:nIdNatureza  picture "@k 999";
      			when iif(nTipoEstoque = 0,Rodape("Esc-Encerra | F4-Natureza Fiscal"),.f.);
				valid SqlBusca("id = "+NumberToSql(oCliente:nIdNatureza),"descricao",@oQuery,;
			  	"administrativo.natureza",row(),col()+1,{"descricao",16},{"Natureza nÆo cadastrada"},.f.)
      				
	// ** Codigo do vendedor      			
	@ 16,74 get oCliente:nIdVendedor  picture "@k 99";
      			when Rodape("Esc-Encerra | F4-Vendedores");
      			valid iif(empty(oCliente:nIdVendedor),.t.,;
					SqlBusca("id = "+NumberToSql(oCliente:nIdVendedor),"nome",@oQuery,;
			  	"administrativo.vendedores",row(),col()+1,{"nome",16},{"Vendedor nÆo cadastrado"},.f.))
      
    @ 17,011 get oCliente:nLimite  picture "@ke 999,999,999.99" when Rodape("Esc-Encerra")
    @ 18,011 get oCliente:cObs     picture "@k!"
    
	// ** Endereco para cobranca *********************************	
	@ 20,052 get oCliente:cCobranca picture "@k!";
			valid MenuArray(@oCliente:cCobranca,{{"S","Sim"},{"N","Nao"}})
      
	@ 21,011 get oCliente:cEnderCobra  picture "@k";
				when oCliente:cCobranca == "N"
	@ 21,081 get oCliente:cNumerCobra  picture "@k";
				when oCliente:cCobranca == "N";	
				valid NoEmpty(oCliente:cNumerCobra)
      
	@ 22,011 get oCliente:cComplCobra picture "@k";
				when oCliente:cCobranca == "N"	
	@ 23,011 get oCliente:cBairrCobra picture "@k";
				when oCliente:cCobranca == "N"	
				
	@ 24,011 get oCliente:nIdCidCobra  picture "@k 9999";
      			when iif(oCliente:cCobranca == "N",Rodape("Esc-Encerra | F4-Cidades"),.f.);
      			valid Busca(Zera(@oCliente:cCodCidCobra),"Cidades",1,row(),col(),;
      				"'-'+Cidades->NomCid+' Estado: '+Cidades->EstCid",{"Cidade Nao Cadastrada"},.f.,.f.,.f.)
      				
	@ 25,011 get oCliente:cCepCobra picture "@kr 99999-999";
				when iif(oCliente:cCobranca == "N",Rodape("Esc-Encerra"),.f.)
	@ 25,027 get oCliente:cFone1Cobra picture "@kr (999)99999-9999";
				when oCliente:cCobranca == "N"	
	@ 25,049 get oCliente:cFaxCobra  picture "@kr (999)99999-9999";
				when oCliente:cCobranca == "N"	
	@ 25,074 get oCliente:cCelulaCobra   picture "@kR (999)99999-9999";
				when oCliente:cCobranca == "N"
    	
        
	// ** Endereco para entrega ********************************************************************
	@ 26,052 get oCliente:cEntrega picture "@k!" valid MenuArray(@oCliente:cEntrega,{{"S","Sim"},{"N","Nao"}})
        
	@ 27,011 get oCliente:cEnderEntre  picture "@k" when oCliente:cEntrega == "N"
	@ 27,081 get oCliente:cNumerEntre  picture "@k"	when oCliente:cEntrega == "N";	
				valid NoEmpty(oCliente:cNumerEntre)
      
	@ 28,011 get oCliente:cComplEntre   picture "@k" when oCliente:cEntrega == "N"	
	@ 29,011 get oCliente:cBairrEntre  picture "@k"  when oCliente:cEntrega == "N"	
				
	@ 30,011 get oCliente:nIdCidEntre  picture "@k 9999";
      			when iif(oCliente:cEntrega == "N",Rodape("Esc-Encerra | F4-Cidades"),.f.);
      			valid Busca(Zera(@oCliente:cCodCidEntre),"Cidades",1,row(),col(),;
      				"'-'+Cidades->NomCid+' Estado: '+Cidades->EstCid",{"Cidade Nao Cadastrada"},.f.,.f.,.f.)
      				
	@ 31,011 get oCliente:cCepEntre picture "@kr 99999-999";
				when iif(oCliente:cEntrega == "N",Rodape("Esc-Encerra"),.f.)
	@ 31,029 get oCliente:cFone1Entre picture "@kr (999)99999-9999" when oCliente:cEntrega == "N"	
	@ 31,049 get oCliente:cFaxEntre  picture "@kr (999)99999-9999"  when oCliente:cEntrega == "N"	
	@ 31,074 get oCliente:cCelulaEntre   picture "@kR (999)99999-9999" when oCliente:cEntrega == "N"
	if lGet
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			return(.f.)
		endif
	else
		clear gets
	endif
	return(.t.)
      
static function GravarClientes(lIncluir)
	local cQuery,oQuery

	if lIncluir      
		cQuery := "INSERT INTO FROM administrativo.clientes "
		cQuery += "(tipcli, blocli, datcli, nomcli ) "
		cQuery += "VALUES ("+StringToSql(oCliente:cTipCli)+","+StringToSql(oCliente:cBloCli)+","
		cQuery += DateToSql(oCliente:dDatCli)+","
		cQuery += StringToSql(oCliente:cNomCli)
	endif
	Msg(.t.)
	Msg("Aguarde: Gravando as informa‡äes")
	oServer:StartTransaction()
	if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar "},"sqlerro")
		oQuery:Close()
		oServer:Rollback()
		Msg(.f.)
		return(.f.)
	endif
	/*
	Clientes->TipCli  := oCliente:cTipCli
	Clientes->BloCli  := oCliente:cBloCli
	Clientes->DatCli  := oCliente:dDatCli
	Clientes->NomCli  := oCliente:cNomCli
	Clientes->ApeCli  := oCliente:cApeCli
	Clientes->EndCli  := oCliente:cEndCli
	Clientes->BaiCli  := oCliente:cBaiCli
	Clientes->CodCid  := oCliente:cCodCid
	Clientes->CepCli  := oCliente:cCepCli
	Clientes->TelCli1 := oCliente:cTelCli1
	Clientes->TelCli2 := oCliente:cTelCli2
	Clientes->FaxCli  := oCliente:cFaxCli
	Clientes->EmaCli  := oCliente:cEmaCli
	Clientes->CelCli  := oCliente:cCelCli
	Clientes->ConCli  := oCliente:cConCli
	if !lIncluir // ** se for altera‡Æo
		Clientes->CgCCli  := iif(oCliente:cTipCli == "F",space(14),oCliente:cCgCCli)
    	Clientes->IesCli  := iif(oCliente:cTipCli == "F",space(14),oCliente:cIesCli)
    	Clientes->CpfCli  := iif(oCliente:cTipCli == "J",space(14),oCliente:cCpfCli)
    	Clientes->RgCli   := iif(oCliente:cTipCli == "J",space(15),oCliente:cRgCli)
    	Clientes->NasCli  := iif(oCliente:cTipCli == "J",ctod(space(08)),oCliente:dNasCli)
    else
		Clientes->CgCCli  := oCliente:cCgCCli
      	Clientes->IesCli  := oCliente:cIesCli
      	Clientes->CpfCli  := oCliente:cCpfCli
      	Clientes->RgCli   := oCliente:cRgCli
      	Clientes->NasCli  := oCliente:dNasCli
	endif
	Clientes->SpcCli  := oCliente:cSpcCli
	Clientes->Limite  := oCliente:nLimite
	Clientes->Obs     := oCliente:cObs
	Clientes->CodVen  := oCliente:cCodVen
	Clientes->CodNat  := oCliente:cCodNat
	Clientes->NumCli  := oCliente:cNumCli
	Clientes->IndIEDest := oCliente:cIndIEDest
	Clientes->IndIFinal := oCliente:cIndIFinal
	Clientes->Compl     := oCliente:cCompl // ** complemento de endereco
	Clientes->GrupoCli  := oCliente:cGrupoCli       // ** Grupo de clientes
	Clientes->PReferenci := oCliente:cPReferenci // ** ponto de referencia do endere‡o principal	
	Clientes->Cobranca   := oCliente:cCobranca
	Clientes->Entrega    := oCliente:cEntrega
	if oCliente:cCobranca == "N"
		Clientes->EnderCobra := oCliente:cEnderCobra 
		Clientes->NumerCobra := oCliente:cNumerCobra 
		Clientes->ComplCobra := oCliente:cComplCobra 
		Clientes->BairrCobra := oCliente:cBairrCobra 
		Clientes->ReferCobra := oCliente:cReferCobra 
		Clientes->CodCidCobr := oCliente:cCodCidCobra
		Clientes->CepCobra   := oCliente:cCepCobra   
		Clientes->Fone1Cobra := oCliente:cFone1Cobra 
		Clientes->Fone2Cobra := oCliente:cFone2Cobra 
		Clientes->FaxCobra   := oCliente:cFaxCobra   
		Clientes->CelulaCobr := oCliente:cCelulaCobra
	endif
	if oCliente:cEntrega == "N"
		Clientes->EnderEntre := oCliente:cEnderEntre 
		Clientes->NumerEntre := oCliente:cNumerEntre 
		Clientes->ComplEntre := oCliente:cComplEntre 
		Clientes->BairrEntre := oCliente:cBairrEntre 
		Clientes->ReferEntre := oCliente:cReferEntre 
		Clientes->CodCidEntr := oCliente:cCodCidEntre
		Clientes->CepEntre   := oCliente:cCepEntre   
		Clientes->Fone1Entre := oCliente:cFone1Entre 
		Clientes->Fone2Entre := oCliente:cFone2Entre 
		Clientes->FaxEntre   := oCliente:cFaxEntre   
		Clientes->CelulaEntr := oCliente:cCelulaentre
	endif
	if lIncluir
		Sequencia->(dbunlock())
	endif
	Clientes->(dbcommit())
	Clientes->(dbunlock())
	*/
return(.t.)

static function AbrirArquivos
                   
   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
	if !OpenCidades()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
	if !OpenClientes()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
	if !OpenEstados()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
	if !OpenVendedor()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
	if !OpenGrupoCli()
		FechaDados()
		Msg(.f.)
		return(.f.)
	endif
	if !OpenNatureza()
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
