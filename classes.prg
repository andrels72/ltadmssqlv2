#include "hbclass.ch"
/*
	Classes de Clientes
*/
class TCliente
	data cCodCli
	data cTipCli
	data cBloCli  
	data dDatCli  
	data cNomCli  
	data cApeCli  
	data cEndCli  
    data cCompl		
	data cBaiCli

	data nIdCidade
	data cCepCli  
	data cTelCli1 
	data cTelCli2 
	data cFaxCli  
	data cEMaCli  
	data cCelCli  
	data cConCli  
	data cIEsCli  
	data cRgCli   
	data dNasCli  
	data cSpcCli  
	data nLimite  
	data cObs     
	data cNumCli
	data cCgcCli
	data cCpfCli
	data nIdNatureza
	data nIdVendedor
	data cIndIEDest
    data cIndIFinal
    data nidGrupoCli
	data cPReferenci    // ** ponto de referencia do endereco principal    
	data cCobranca 
	data cEntrega
    // ** Endereco para cobranÁa
    data cEnderCobra
    data cComplCobra
    data cNumerCobra
    data cBairrCobra
    data cReferCobra
    data nIdCidCobra
    data cCepCobra
    data cFone1Cobra
    data cFone2Cobra
    data cFaxCobra
    data cCelulaCobra
    // ** Endereco para entrega
    data cEnderEntre
    data cComplEntre
    data cNumerEntre
    data cBairrEntre
    data cReferEntre
    data nIdCidEntre
    data cCepEntre
    data cFone1Entre
    data cFone2Entre
    data cFaxEntre
    data cCelulaEntre
	
	method new()
	method RecuperarDados()
endclass
//***********************************************************************************************
method new() class TCliente

	::cCodCli  := space(04)
	::cTipCli  := "J"
	::cBloCli  := "N"
	::dDatCli  := date()
	::cNomCli  := space(60)
	::cApeCli  := spac(40)
	::cEndCli  := space(60)
	::cBaiCli  := space(60)
    ::cCompl    := space(60) // ** Complemento do endereco	
	::nIdCidade  := 0
	::cCepCli  := space(08)
	::cTelCli1 := space(11)
	::cTelCli2 := space(11)
	::cFaxCli  := space(11)
	::cEMaCli  := space(40)
	::cCelCli  := space(11)
	::cConCli  := space(35)
	::cIEsCli  := space(14)
	::cRgCli   := space(15)
	::dNasCli  := ctod(space(08))
	::cSpcCli  := 'N'
	::nLimite  := 0
	::cObs     := space(50)
	::cNumCli  := space(06)
	::cCgcCli  := space(14)	
	::cCpfCli  := space(11)
	::nIdNatureza := 0
	::nIdVendedor := 0
	::cIndIEDest   := "1"
    ::cIndIFinal   := "0"   // ** 
    ::nIdGrupoCli  :=  0
	::cPReferenci  := space(40)  // ** ponto de referencia do endereÁo principal
	::cCobranca    := "S"
	::cEntrega     := "S"
	// ** Endereco para cobranÁa
	::cEnderCobra  := space(60)
	::cNumerCobra  := space(06)	
	::cComplCobra  := space(60)
	::cBairrCobra  := space(60)
	::cReferCobra  := space(40)
	::nIdCidCobra := 0
	::cCepCobra    := space(08)
	::cFone1Cobra  := space(11)
	::cFone2Cobra  := space(11)
	::cFaxCobra    := space(11)
	::cCelulaCobra := space(11)
	// ** Endereco para entrega
	::cEnderEntre  := space(60)
	::cNumerEntre  := space(06)	
	::cComplEntre  := space(60)
	::cBairrEntre  := space(60)
	::cReferEntre  := space(40)
	::nIdCidEntre := 0
	::cCepEntre    := space(08)
	::cFone1Entre  := space(11)
	::cFone2Entre  := space(11)
	::cFaxEntre    := space(11)
	::cCelulaEntre := space(11)
return self

method RecuperarDados class TCliente
		
	::cTipCli   := Clientes->TipCli
	::cCgcCli   := Clientes->CgcCli
	::cCpfCli   := Clientes->CpfCli
	::cBloCli   := Clientes->BloCli
	::dDatCli   := Clientes->DatCli
	::cNomCli   := Clientes->NomCli
	::cApeCli   := Clientes->ApeCli
	::cEndCli   := Clientes->EndCli
	::cBaiCli   := Clientes->BaiCli
	::cCodCid   := Clientes->CodCid
	::cCepCli   := Clientes->CepCli
	::cTelCli1  := Clientes->TelCli1
	::cTelCli2  := Clientes->TelCli2
	::cFaxCli   := Clientes->FaxCli
	::cEmaCli   := Clientes->EmaCli
	::cCelCli   := Clientes->CelCli
	::cConCli   := Clientes->ConCli
	::cIesCli   := Clientes->IesCli
	::cRgCli    := Clientes->RgCli
	::dNasCli   := Clientes->NasCli
	::cSpcCli   := Clientes->SpcCli
	::nLimite   := Clientes->Limite
	::cObs      := Clientes->Obs
	::nIdVendedor  := Clientes->CodVen
	::cCodNat   := Clientes->CodNat
	::cNumCli   := Clientes->NumCli
	::cIndIEDest := Clientes->IndIEDest 
	::cIndIFinal  := Clientes->IndiFinal
	::cCompl     := Clientes->Compl // ** complemento do endereco
	::cGrupoCli  := Clientes->GrupoCli
	::cPReferenci  := Clientes->PReferenci // ** ponto de referencia do endereÁo principal
	// ** Endereco para cobranca
	::cCobranca    := Clientes->Cobranca
	::cEnderCobra  := Clientes->EnderCobra
	::cNumerCobra  := Clientes->NumerCobra
	::cComplCobra  := Clientes->ComplCobra
	::cBairrCobra  := Clientes->BairrCobra
	::cReferCobra  := Clientes->ReferCobra
	::cCodCidCobra := Clientes->CodCidCobr
	::cCepCobra    := Clientes->CepCobra
	::cFone1Cobra  := Clientes->Fone1Cobra
	::cFone2Cobra  := Clientes->Fone2Cobra
	::cFaxCobra    := Clientes->FaxCobra
	::cCelulaCobra := Clientes->CelulaCobr
	// ** Endereco para entrega
	::cEntrega     := Clientes->Entrega
	::cEnderEntre  := Clientes->EnderEntre
	::cNumerEntre  := Clientes->NumerEntre
	::cComplEntre  := Clientes->ComplEntre
	::cBairrEntre  := Clientes->BairrEntre
	::cReferEntre  := Clientes->ReferEntre
	::cCodCidEntre := Clientes->CodCidEntr
	::cCepEntre    := Clientes->CepEntre
	::cFone1Entre  := Clientes->Fone1Entre
	::cFone2Entre  := Clientes->Fone2Entre
	::cFaxEntre    := Clientes->FaxEntre
	::cCelulaEntre := Clientes->CelulaEntr
return(.t.)
// *********************************************************************************************************	
class TFornecedor

	data nId
	data dDatFor 	
	data cRazFor 
	data cFanFor 
	data cEndFor 
	data cBaiFor 
	data nIdCidade
	data cCepFor 
	data cTelFor1
	data cTelFor2
	data cFaxFor 
	data cEMaFor 
	data cCelFor 
	data cConFor 
	data cCgcFor 
	data cIEsFor 
	data cObs   
	data cCompl
	data cNumero
	data cCrt 
	data cTipo
    data cIndIEDest
	method new()
	method RecuperarDados
endclass	
//***********************************************************************************************
method new() class TFornecedor

	::nId  := 0
	::dDatFor  := date()
	::cRazFor  := space(60)
	::cFanFor  := spac(40)
	::cEndFor  := space(60)
	::cBaiFor  := space(60)
	::nIdCidade := 0
	::cCepFor  := space(08)
	::cTelFor1 := space(11)
	::cTelFor2 := space(11)
	::cFaxFor  := space(11)
	::cEMaFor  := space(40)
	::cCelFor  := space(11)
	::cConFor  := space(35)
	::cCgcFor  := space(14)
	::cIEsFor  := space(14)
	::cObs     := space(50)
	::cCompl   := space(60) // ** Complemento do endereco
	::cNumero  := space(06)
	::cCrt := space(01)
	::cTipo := space(01)
    ::cIndIEDest := space(01)
return self
//***********************************************************************************************
method RecuperarDados(nId,oQ) class TFornecedor

	if !SqlBusca("id = "+NumberToSql(nId),"Datfor,razfor,fanfor,endfor,baifor,idcidade,cepfor,telfor1,telfor2,faxfor,"+;
		"emafor,celfor,confor,cgcfor,iesfor,obs,compl,numero,indiedest",@oQ,"administrativo.fornecedores",,,,{"Fornecedor n∆o cadastrado"},.f.)
		return(.f.)
	endif
	::dDatFor  := oQ:fieldget('datfor')
	::cRazFor  := oQ:fieldget('razfor')
	::cFanFor  := oQ:fieldget('fanfor')
	::cEndFor  := oQ:fieldget('endfor')
	::cBaiFor  := oQ:fieldget('baifor')
	::nIdCidade := oQ:fieldget('idcidade')
	::cCepFor  := oQ:fieldget('cep')
	::cTelFor1 := oQ:fieldget('telfor1')
	::cTelFor2 := oQ:fieldget('telfor2')
	::cFaxFor  := oQ:fieldget('faxfor')
	::cEMaFor  := oQ:fieldget('emafor')
	::cCelFor  := oQ:fieldget('celfor')
	::cConFor  := oQ:fieldget('confor')
	::cCgcFor  := oQ:fieldget('cgcfor')
	::cIEsFor  := oQ:fieldget('iesfor')
	::cObs     := oQ:fieldget('obs')
	::cCompl   := oQ:fieldget('compl')
	::cNumero  := oQ:fieldget('numero')
	::cCrt := oQ:fieldget('crt')
	::cTipo := oQ:fieldget('tipo')
    ::cIndIEDest := oQ:fieldget('indiedest')
return(.t.)

	
// ** Fim do Arquivo.
