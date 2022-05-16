/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 3.00
 * Identificacao: Manutencao de Notas Fiscais - Saida
 * Prefixo......: LTADM
 * Programa.....: CAIXA.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 28 DE DEZEMBRO DE 2002
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"
#include "setcurs.ch"

function GeraNFE(cNumCon)
   Local Tel_Ant := SaveScreen( 00, 00, 24, 79 ), Tel_Ant1
   local lInternet := .f.
   local cNaturaNota

   #define CRLF chr(K_ENTER)+chr(K_CTRL_ENTER)

   if !nfeven->(dbsetorder(1),dbseek(cNumCon))
      return
   end

   lInternet := Testa_Internet()
   if !lInternet
      return
   end

   Clientes->(dbsetorder(1),dbseek(nfeven->CodCli))
   Transpo->(dbsetorder(1),dbseek(nfeven->CodTra))
   Natureza->(dbsetorder(1),dbseek(nfeven->CodNat))
   Cidades->(dbsetorder(1),dbseek(Clientes->CodCid))
   cCFOPNota := Natureza->Cfop

   cComando := ""
   cComando += 'NFE.CriarNFe("[Identificacao]'      +CRLF
   cComando += 'NaturezaOperacao='+Natureza->Descricao +CRLF
   cComando += 'Modelo=55'                          +CRLF
   cComando += 'Serie=001'                            +CRLF
   cComando += 'Codigo='+nfeven->numnot             +CRLF
   cComando += 'Numero='+nfeven->NumNot            +CRLF
   cComando += 'Serie=1'                            +CRLF
   cComando += 'Emissao='+dtoc(nfeven->DtaEmi)     +CRLF
   cComando += 'Saida='+iif(empty(nfeven->DtaSai)," ",dtoc(nfeven->DtaSai))+CRLF
   cComando += 'Tipo=1'         +CRLF
   cComando += 'FormaPag=0'     +CRLF // 0=Avista 1-Aprazo 2-Outros
	cComando += 'idDest='+iif(Natureza->Local = "D",'1','2')+CRLF

   cComando += 'Finalidade=1'   +CRLF // 0-Producao, 1-Homologacao
   cComando += 'indFinal='+Clientes->IndiFinal+CRLF

   cComando += '[Emitente]'   +CRLF
   
	if Sequencia->TipoAmb == "2"
		//cComando += 'CNPJ=99999999000191'+CRLF
		//cComando += 'IE=00'+CRLF
        cComando += 'CNPJ='+cEmpCnpj+CRLF
		cComando += 'IE=00'+CRLF
		cComando += 'Razao= NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL'+CRLF
	else
		cComando += 'CNPJ='+cEmpCnpj+CRLF
		cComando += 'IE='+cEmpIe+CRLF
		cComando += 'Razao='+cEmpRazao+CRLF
    endif
    Cidades->(dbsetorder(1),dbseek(cEmpCodCid))
    cComando += 'Fantasia='    +cEmpFantasia+CRLF
    cComando += 'Fone='        +cEmpTelefone1+CRLF
    cComando += 'CEP='         +cEmpCep+CRLF
    cComando += 'Logradouro='  +cEmpEndereco+CRLF
    cComando += 'Numero='      +cEmpNumero+CRLF
    cComando += 'Complemento='            +CRLF
    cComando += 'Bairro='      +cEmpBairro+CRLF
    cComando += 'CidadeCod='   +Cidades->CodIbge+CRLF
    cComando += 'Cidade='      +Cidades->NomCid+CRLF
    cComando += 'UF='          +cEmpEstCid+CRLF
    cComando += 'PaisCod=1058'            +CRLF
    cComando += 'Pais=BRASIL'             +CRLF
    cComando += 'Crt='         +cEmpCrt+CRLF

   // DESTINATµRIO
   Cidades->(dbsetorder(1),dbseek(Clientes->CodCid))
   cComando += '[Destinatario]'+CRLF
	// ** Ambiente de Produção
	if Sequencia->TipoAmb == "1"
		// ** Pessoa Juridica
		if Clientes->TipCli == "J"
			cComando += 'CNPJ='+Clientes->CGCCli+CRLF
			
			/*
			
			if empty(Clientes->IESCli)
				cComando += 'IE=ISENTO'+CRLF
				cComando += 'indIEDest=2'+CRLF  // ** NFE 3.10
			else
				cComando += 'IE='+Clientes->IESCli+CRLF
				cComando += 'indIEDest=1'+CRLF  // ** NFE 3.10
			endif
			*/
		// ** Pessoa Física
		else
			cComando += 'CNPJ='+Clientes->CPFCli+CRLF
			
			// **cComando += 'indIEDest=9'+CRLF     // ** NFE 3.10
      endif
		if Clientes->indIEDest == "1"
			cComando += 'IE='+Clientes->IESCli+CRLF
		endif
		cComando += 'indIEDest='+Clientes->indIEDest+CRLF  // ** NFE 3.10

      cComando += 'NomeRazao='+Clientes->NomCli +CRLF
   else
      cComando += 'CNPJ=99999999000191'+CRLF
      cComando += 'indIEDest=9'+CRLF
      // **cComando += 'IE='+CRLF
      cComando += 'Razao= NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL'+CRLF
   endif
   cComando += 'Fone='+Clientes->TelCli1     +CRLF
   cComando += 'CEP='+Clientes->CepCli       +CRLF
   cComando += 'Logradouro='+Clientes->EndCli+CRLF
   cComando += 'Numero='+Clientes->NumCli    +CRLF
   cComando += 'Bairro='+Clientes->BaiCli    +CRLF
   cComando += 'CidadeCod='+Cidades->CodIbge  +CRLF
   cComando += 'Cidade='+Cidades->NomCid     +CRLF
   cComando += 'UF='+Cidades->EstCid         +CRLF
   cComando += 'PaisCod=1058'                +CRLF
   cComando += 'Pais=BRASIL'                 +CRLF

   nBaseICMS  := 0
   nValorICMS := 0
   nValorDoTributos := 0.00
   nValorTotalDoTributos := 0.00

   // Produtos
   nfeitem->(dbsetorder(1),dbseek(nfeven->NumCon))
   nContador := 1
	while nfeitem->NumCon == nfeven->NumCon .and. nfeitem->(!eof())
		Produtos->(dbsetorder(1),dbseek(nfeitem->CodPro))

		cQuantidade    := rtrim(alltrim(str(nfeitem->QtdPro,15,4)))
		cValorUnitario := rtrim(alltrim(str(round(nfeitem->PcoPro,2),12,2)))
		cValorTotal    := rtrim(alltrim(str(nfeitem->TotPro,12,2)))
		cValorDesconto := rtrim(alltrim(str(nfeitem->Desconto,15,2)))
		
		// ** Calcula o valor total dos tributos
		/*
		if ibpt->(dbsetorder(1),dbseek(Produtos->CodNCM))
			nValorDoTributos := round(((nfeitem->TotPro * ibpt->aliqnac) / 100),2)
			nValorTotalDoTributos += nValorDoTributos
		endif
		*/
		

		cComando += '[Produto'      +strzero(nContador,3)+']'+CRLF
		cComando += 'CFOP='         +Natureza->Cfop        +CRLF
		cComando += 'Codigo='       +nfeitem->CodPro        +CRLF
		cComando += 'NCM='+Produtos->CodNCM+CRLF
		cComando += 'Descricao='    +Produtos->DesPro        +CRLF
		cComando += 'Unidade='      +Produtos->EmbPro        +CRLF
		cComando += 'Quantidade='   +cQuantidade             +CRLF
		cComando += 'ValorUnitario='+cValorUnitario          +CRLF
		cComando += 'ValorTotal='   +cValorTotal             +CRLF
		cComando += 'vDesc='+cValorDesconto          +CRLF
		cComando += 'vTotTrib='+rtrim(alltrim(str(nValorDoTributos,12,2)))+CRLF

		cBaseICMS  := rtrim(alltrim(str(nfeitem->baseicms,12,2)))
		cAliquota  := rtrim(alltrim(str(nfeitem->AliSai,5,2)))
      
		cValorICMS := rtrim(alltrim(str(nfeitem->ValorIcms,12,2)))

		nBaseICMS  += val(cBaseICMS)  //   nfeitem->baseicms
		nValorICMS += val(cValorICMS) //nfeitem->valoricms
		
		// **nTotalDesconto += nfeitem->Desconto

		cComando +='[ICMS'+strzero(nContador,3)+']'+CRLF
		cComando += 'CSOSN='+NfeItem->Cst+CRLF
		cComando +='ValorBase='+cBaseIcms+CRLF
		cComando +='Aliquota='+cAliquota+CRLF
      cComando +='Valor='+cValorICMS+CRLF

      nfeitem->(dbskip())
      nContador += 1
   enddo
   cBaseICMS  := rtrim(alltrim(str(nBaseICMS,12,2)))
   cValorICMS := rtrim(alltrim(str(nValorICMS,12,2)))

   cBasSub := rtrim(alltrim(str(nfeven->BasSub,12,2)))
   cICMSub := rtrim(alltrim(str(nfeven->ICMSub,12,2)))
   cTotPro := rtrim(alltrim(str(nfeven->TotPro,12,2)))
   cTotNot := rtrim(alltrim(str(nfeven->TotNot,12,2)))
   cTotalDesconto := rtrim(alltrim(str(nfeven->dscno1,15,2)))

   cComando +='[Total]'+CRLF
   cComando += 'BaseICMS='             +cBaseICMS+CRLF
   cComando += 'ValorICMS='            +cValorICMS+CRLF
   cComando += 'ValorProduto='         +cTotPro+CRLF
   cComando += 'BaseICMSSubstituicao=' +cBasSub+CRLF
   cComando += 'ValorICMSSubstituicao='+cICMSub+CRLF
   cComando += 'ValorFrete=0.00'       +CRLF
   cComando += 'ValorSeguro=0.00'      +CRLF
	cComando += 'ValorDesconto='        +cTotalDesconto+CRLF
	cComando += 'ValorNota='            +cTotNot+CRLF
	// **cComando += 'vTotTrib='+rtrim(alltrim(str(nValorTotalDoTributos,12,2)))+CRLF   


   //Dados do Transportador
   cComando += '[Transportador]'+CRLF
   cComando += 'FretePorConta=' +nfeven->TipFre+CRLF
   cComando += 'CnpjCpf='       +Transpo->CGCTra+CRLF
   cComando += 'NomeRazao='     +Transpo->NomTra+CRLF
   cComando += 'IE='            +Transpo->InsTra+CRLF
   cComando += 'Endereco='      +Transpo->EndTra+CRLF
   cComando += 'Cidade='        +Transpo->CidTra+CRLF
   cComando += 'UF='            +Transpo->EstTra+CRLF
   cComando += 'Placa='         +Transpo->PlaTra+CRLF
   cComando += 'UFPlaca='       +Transpo->EstPla+CRLF
   
	if !empty(nfeven->qtdvol)

		cComando += '[Volume001]'+CRLF
		cComando += 'Quantidade=' +rtrim(alltrim(str(nfeven->qtdvol,12)))+CRLF
		cComando += 'Especie='    +nfeven->EspVol+CRLF
		cComando += 'Marca='      +nfeven->MarVol+CRLF
		cComando += 'Numeracao='  +rtrim(alltrim(str(nfeven->NumVol)))+CRLF
		cComando += 'PesoLiquido='+rtrim(alltrim(str(nfeven->PesLiq,12,2)))+CRLF
		cComando += 'PesoBruto='  +rtrim(alltrim(str(nfeven->PesBru,12,2)))+CRLF
	endif

	cDadosAdicionais := ""
	cDadosAdicionais += nfeven->ObsNot1+";"
	if !empty(nfeven->ObsNot2)
		cDadosAdicionais += nfeven->ObsNot2 + ";"
	endif
	if !empty(nfeven->ObsNot3)
      cDadosAdicionais += nfeven->ObsNot3 + ";"
   end
   if !empty(nfeven->ObsNot4)
      cDadosAdicionais += nfeven->ObsNot4 + ";"
   end
   if !empty(nfeven->ObsNot5)
      cDadosAdicionais += nfeven->ObsNot5 + ";"
   end
   if !empty(nfeven->ObsNot6)
      cDadosAdicionais += nfeven->ObsNot6 + ";"
   end
   cComando +='[DadosAdicionais]'+CRLF
   cComando +='Complemento='+cDadosAdicionais+CRLF

   if File(cDiretorioNFE+"\sainfe.txt")
      FErase(cDiretorioNFE+"\sainfe.txt")
   endif
	MemoWrit(cDiretorioNFE+"\entnfe.txt",cComando )
	MemoWrit(cDiretorioNFE+"\entrada.txt",cComando )
   lRetorno := RetornoCriaNFe(cDiretorioNFE)
   cArqNFE  := RetornaNFE(cDiretorioNFE)
   if !lRetorno
      return(.f.)
   end
   return(.t.)

function TransmitirNFE(cArqNFE,cNumCon)
   private cXML

   if cArqNFE == NIL
      cXML := RetornaNFE(cDiretorioNFE)
   else
      cXML := cArqNFE
   end
   Msg(.t.)
   Msg("Aguarde: Transmitindo a nota fiscal eletr“nica")
//   Acbr_NFE_EnviarNFe(cDiretorioNFE,cXML,val(cNumCon), 1, 1, 0)
   Acbr_NFE_EnviarNFe(cDiretorioNFE,cXML,0, 1, 1)
   while !file(cDiretorioNFE+"\sainfe.txt")
      if file(cDiretorioNFE+"\sainfe.txt")
         exit
      end
      inkey(0.05)
   end
   Msg(.f.)
   vMsg := MemoRead(cDiretorioNFE+"\sainfe.txt")

   // Retorna Campos SEFAZ //
   // Grava Status Retorno //
   cNRec    := Ret_Sefaz( "NRec" , vMsg )
   _Stat_   := Ret_SEFAZ( "CStat", vMsg )  // Auxiliar
   cCStat   := SubStr( _Stat_, 1, 3 )      // Pegar Cod CStat Corretamente / Quando Linux
   cXMotivo := Psq_CStat( cCStat )
   cChNfe   := Ret_Sefaz( "ChNFe"   , vMsg )
   cDhRec   := Ret_SEFAZ( "DhRecbto", vMsg )
   cNProt   := Ret_SEFAZ( "NProt"   , vMsg )
   cDigVal  := Ret_SEFAZ( "DigVal"  , vMsg )

   if !(cCStat == "100")
      Mens({"NFe N„o Autorizada !!!","Consulte a NFe."})
      return(.f.)
   else
   end
   return(.t.)

// ** Fim do arquivo.
