/*******************************************************************************
 * Sistema......: Fluxo de Caixa
 * Versao.......: 2.00
 * Identificacao: Manutencao dos Dados da Empresa
 * Prefixo......: LtfCaixa
 * Programa.....: EMPRESA.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 21 DE ABRIL DE 2002
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"
#include "setcurs.ch"

procedure Empresa()
    local getlist := {}, cTela := SaveWindow()
    local cQuery,oQuery


    AtivaF4()
    Window(07,00,23,92,"> Dados da Empresa <")
    setcolor(Cor(11))
   //            123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
   //                     1         2         3         4         5         6         7         8 
	@ 09,01 say "Razao Social:"
    @ 10,01 say "    Fantasia:"
	@ 11,01 say "    Endereco:                                                               Numero:"
	@ 12,01 say " Complemento:"
	@ 13,01 say "      Bairro:"
	@ 14,01 say "      Cidade:                                                               Estado:"
	@ 15,01 say "      C.E.P.:"
	@ 16,01 say "    Telefone:                 /"
	@ 17,01 say "       Email:"
	@ 18,01 say "        CNPJ:                       Insc. Estadual:"
	@ 19,01 say "  Insc.Muni.:"
	@ 20,01 say "  CNA Fiscal:"
	@ 21,01 say "Regime Trib.:"
	do while .t.
        cQuery := "SELECT "
        cQuery += " Razao,Fantasia,Endereco,Numero,Complend,Bairro,idcidade,"
        cQuery += " EstCid,Cep,Telefone1,Telefone2,email,Cnpj,Ie,Im,Cnae,Crt "
        cQuery += "FROM administrativo.empresa "
        if !ExecuteSql(cQuery,@oQuery,{"Falha ao acessar Empresa "},"sqlerro")
            oQuery:close()
            exit
        endif
        if oQuery:Lastrec() = 0
            lIncluir := .t.
        else
            lIncluir := .f.
        endif
		cEmpRazao    := iif(lIncluir,space(60),oQuery:fieldget('Razao'))
        cEmpFantasia := iif(lIncluir,space(60),oQuery:fieldget('Fantasia'))    
		cEmpEndereco := iif(lIncluir,space(60),oQuery:fieldget('Endereco')) 
		cEmpnumero   := iif(lIncluir,space(06),oQuery:fieldget('numero')   )
		cEmpComplend := iif(lIncluir,space(60),oQuery:Fieldget('Complend') )
		cEmpBairro   := iif(lIncluir,space(60),oQuery:fieldget('Bairro'))   
		cEmpCodcid   := iif(lIncluir,0,oQuery:fieldget('idcidade'))
        cempCidade   := iif(lIncluir,space(40),oQuery:fieldget('cidade'))
        cEmpEstCid   := iif(lIncluir,space(02),oQuery:fieldget('estcid'))    
		cEmpCep      := iif(lIncluir,space(08),oQuery:fieldget('Cep'))  
		cEmpTelefone1 := iif(lIncluir,space(12),oQuery:fieldget('Telefone1'))
		cEmpTelefone2 := iif(lIncluir,space(12),oQuery:fieldget('Telefone2'))
		cEmpEmail     := iif(lIncluir,space(40),oQuery:fieldget('email'))    
		cEmpCnpj     := iif(lIncluir,space(14),oQuery:fieldget('Cnpj'))     
		cEmpIe       := iif(lIncluir,space(14),oQuery:fieldget('Ie'))       
		cEmpIm       := iif(lIncluir,space(15),oQuery:fieldget('Im'))       
		cEmpCnae     := iif(lIncluir,space(07),oQuery:fieldget('Cnae'))     
		cEmpCrt      := iif(lIncluir,space(01),oQuery:fieldget('Crt'))
      	setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      	@ 09,15 get cEmpRazao picture "@k";
                    when Rodape("Esc-Encerrar")
        @ 10,15 get cEmpFantasia picture "@k"
      	@ 11,15 get cEmpEndereco picture "@k"
      	@ 11,85 get cEmpNumero  picture "@k"
      	@ 12,15 get cEmpComplend  picture "@k"
      	@ 13,15 get cEmpBairro picture "@k";
      				when Rodape("Esc-Encerra")
      	@ 14,15 get cEmpCodCid picture "@k 9999";
      				when Rodape("Esc-Encerra | F4-Cidades");
      				valid vCidades(cEmpCodCid)
        @ 14,85 get cEmpEstCid when .f.
      	@ 15,15 get cEmpCep picture "@kr 99999-999";
      				when Rodape("Esc-Encerra")
      	@ 16,15 get cEmpTelefone1 picture "@r (999)99999-9999"
      	@ 16,33 get cEmpTelefone2 picture "@r (999)99999-9999"
      	@ 17,15 get cEmpEmail picture "@k"
      	@ 18,15 get cEmpCnpj picture "@r 99.999.999/9999-99"
      	@ 18,53 get cEmpIe picture "@k"
      	@ 19,15 get cEmpIm picture "@k"
      	@ 20,15 get cEmpCnae picture "@k 9999999"
      	@ 21,15 get cEmpCrt picture "@k 9";
      				valid MenuArray(@cEmpCrt,{;
					{"1","Simples Nacional                                        "},;
					{"2","Simples Nacional – excesso de sublimite de receita bruta"},;
					{"3","Regime Normal                                           "}})
      	setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			exit
		endif
		if !Confirm("Confirma as Informacoes da Empresa")
			loop
		endif
        if lIncluir
            cQuery := "INSERT INTO administrativo.empresa "
            cQuery += "(razao,fantasia,endereco,numero,complend,bairro,idcidade,cidade,estcid,cep,"
            cQuery += "telefone1,telefone2,email,cnpj,ie,im,cnae,crt) "             
            cQuery += "VALUES ("
            cQuery += StringToSql(cEmpRazao)+","
            cQuery += StringToSql(cEmpFantasia)+","    
            cQuery += StringToSql(cEmpEndereco)+"," 
            cQuery += StringToSql(+cEmpnumero)+","   
            cQuery += StringToSql(cEmpComplend)+"," 
            cQuery += StringToSql(cEmpBairro)+","   
            cQuery += NumberToSql(cEmpCodcid)+","
            cQuery += StringToSql(cEmpCidade)+","
            cQuery += StringToSql(cEmpEstCid)+","
            cQuery += StringToSql(cEmpCep)+","      
            cQuery += StringToSql(cEmpTelefone1)+","
            cQuery += StringToSql(cEmpTelefone2)+","
            cQuery += StringToSql(cEmpEmail)+","
            cQuery += StringToSql(cEmpCnpj)+","     
            cQuery += StringToSql(cEmpIe)+","       
            cQuery += StringToSql(cEmpIm)+","       
            cQuery += StringToSql(cEmpCnae)+","     
            cQuery += StringToSql(cEmpCrt)
            cQuery += ")"
        else
            cQuery := "UPDATE administrativo.empresa "
            cQuery += "SET "
            cQuery += "razao = "+StringToSql(cEmpRazao)+","
            cQuery += "fantasia = "+StringToSql(cEmpFantasia)+","    
            cQuery += "endereco = "+StringToSql(cEmpEndereco)+"," 
            cQuery += "numero ="+StringToSql(cEmpnumero)+","   
            cQuery += "complend ="+StringToSql(cEmpComplend)+"," 
            cQuery += "bairro ="+StringToSql(cEmpBairro)+","   
            cQuery += "idcidade ="+NumberToSql(cEmpCodcid)+","
            cQuery += "cidade = "+StringToSql(cEmpCidade)+","
            cQuery += "estcid ="+StringToSql(cEmpEstCid)+","
            cQuery += "cep = "+StringToSql(cEmpCep)+","      
            cQuery += "telefone1 ="+StringToSql(cEmpTelefone1)+","
            cQuery += "telefone2 ="+StringToSql(cEmpTelefone2)+","
            cQuery += "email ="+StringToSql(cEmpEmail)+","
            cQuery += "cnpj ="+StringToSql(cEmpCnpj)+","     
            cQuery += "ie ="+StringToSql(cEmpIe)+","       
            cQuery += "im ="+StringToSql(cEmpIm)+","       
            cQuery += "cnae ="+StringToSql(cEmpCnae)+","     
            cQuery += "crt ="+StringToSql(cEmpCrt)
        endif
        Msg(.t.)
        Msg("Aguarde: Gravando as informacoes ")
        oServer:StartTransaction()
        if !ExecuteSql(cQuery,@oQuery,{"Falha ao acessar tabela empresa"},"sqlerro")
            oQuery:close()
            oServer:Rollback()
            Msg(.f.)
            loop
        endif  
        oQuery:Close()
        oServer:Commit()
        Msg(.f.)
        LerDadosEmpresa()
        exit
	enddo
   	DesativaF4()
   	RestWindow(cTela)
return
//************************************************************************************
static function vCidades(nCodCid)
    local oQCidade
    
        
    if !SqlBusca("codcid = "+NumberToSql(nCodCid),"nomcid,estcid",@oQCidade,;
        "administrativo.cidades",row(),col()+1,{"nomcid",0},{"Cidade nÆo cadastrada"},.f.)
        return(.f.)
    endif
    cEmpEstCid := oQCidade:fieldget('estcid')
    cEmpCidade := oQCidade:fieldget('nomcid')
return(.t.)

//** Fim do Arquivo.
