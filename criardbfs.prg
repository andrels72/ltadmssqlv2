#include "lucas.CH"       // Inclusao do Arquivo Header Padrao
#include "inkey.ch"
#include "setcurs.ch"



procedure main

	private aStru := {},cDiretorio := "dados\"
	private Arq_Sen := if(empty(netname()),[Ervidor],right(alltrim(netname()),7))
    
    
	

	DbfBanco()
	DbfHistBan() 
	DbfEstados()
	DbfSequenci()
	// ** Carta de Correção eletrónica
	if !file(cDiretorio+"cce.dbf")
		aStru := {}
		aadd(aStru,{"Nota","c",09,0})
		aadd(aStru,{"Sequencia","n",2,0})
		aadd(aStru,{"Data","d",08,0})
		aadd(aStru,{"Hora","c",10,0})
		aadd(aStru,{"Texto1","c",76,0})
		aadd(aStru,{"Texto2","c",76,0})
		aadd(aStru,{"Texto3","c",76,0})
		aadd(aStru,{"Texto4","c",76,0})
		aadd(aStru,{"Texto5","c",76,0})
		aadd(aStru,{"Texto6","c",76,0})
		aadd(aStru,{"Texto7","c",76,0})
		aadd(aStru,{"Texto8","c",76,0})
		aadd(aStru,{"Texto9","c",76,0})
		aadd(aStru,{"Texto10","c",76,0})
		aadd(aStru,{"Texto11","c",76,0})
		aadd(aStru,{"Texto12","c",76,0})
		aadd(aStru,{"Texto13","c",76,0})
		aadd(aStru,{"cStat","c",3,0})
		aadd(aStru,{"dhRegEvent","c",40,0})
		aadd(aStru,{"protocolo","c",15,0})
		dbcreate(cDiretorio+"cce",aStru)
	endif
	// ** Notas fiscais inutilizada
	if !file(cDiretorio+"nfeinut.dbf")
		aStru := {}
		aadd(aStru,{"Numero","n",09,0})
		aadd(aStru,{"Ano","n",02,0})
		aadd(aStru,{"Modelo","n",02,0})
		aadd(aStru,{"Serie","n",03,0})
		aadd(aStru,{"data","d",08,0})
		aadd(aStru,{"inutilizad","l",01,0})
		aadd(aStru,{"DhRecbto","c",40,0})
		aadd(aStru,{"protocolo","c",15,0})
		aadd(aStru,{"texto1","c",76,0})
		aadd(aStru,{"texto2","c",76,0})
		aadd(aStru,{"texto3","c",76,0})
		aadd(aStru,{"texto4","c",76,0})
		aadd(aStru,{"texto5","c",76,0})
		aadd(aStru,{"texto6","c",76,0})
		aadd(aStru,{"texto7","c",76,0})
		aadd(aStru,{"texto8","c",76,0})
		aadd(aStru,{"texto9","c",76,0})
		aadd(aStru,{"texto10","c",76,0})
		aadd(aStru,{"texto11","c",76,0})		
		aadd(aStru,{"texto12","c",76,0})
		aadd(aStru,{"texto13","c",76,0})		
		dbcreate(cDiretorio+"nfeinut",aStru)
	endif
	// ** Arquivo para processamento ************************************************************************
	aStru := {}
	aadd(aStru,{"CodCli","c",4,0})
	aadd(aStru,{"NumDup","c",13,0})
	aadd(aStru,{"DtaVen","d",08,0})
	aadd(aStru,{"Dtapag","d",08,0})
	aadd(aStru,{"ValPag","n",12,2})
	aadd(aStru,{"DtaEmi","d",08,0})
	aadd(aStru,{"ValDup","n",12,2})
	dbcreate(cDiretorio+Arq_Sen+"6",aStru)
	// ** Baixa Geral *************************************************************************************
	if !file(cDiretorio+"baixageral.dbf")
		aStru := {}
		aadd(aStru,{"codigo","C",13,0})
		aadd(aStru,{"CodCli","C",04,0})
		aadd(aStru,{"dta_baixa","d",08,0}) // ** Data da baixa
		aadd(aStru,{"vlr_pago","N",15,2})  // ** Valor pago
		aadd(aStru,{"vlr_dupl","N",15,2})  // ** Valor total das duplicatas selecionadas
		aadd(aStru,{"juros","N",15,2})	// ** Valor dos juros	
		aadd(aStru,{"desconto","N",15,2})  // ** Valor do desconto
		aadd(aStru,{"obs","C",80,0})
		dbcreate(cDiretorio+"baixageral",aStru)
	endif
	DbfProdutos()
	DbfVendedor()
	DbfEmpresa()
	DbfClientes()
	DbfFornecedor()
	DbfDupRec()
	DbfNatureza()
	DbfSitTrib()
	DbfLaboratorio()
	DbfGrupoCli()
	DbfGrupos()
	DbfSubGrupo()
	DbfUnidMed()
	dbfPedidos()
	DbfItemPed()
	DbfPlano()
	DbfCheques()
	DbfMovBan()
	DbfFPagCxa()
	DbfHistCxa()
	DbfDupPag()
	DbfMovCxa()
	DbfCaixa()
	DbfBxaDupPa()
	DbfCredCartao()
	DbfTranspo()
	//DbfOrcamen()
	//DbfItemOrca()
    DbfOrcamentos()
    DbfItemOrcamentos()
	DbfBxaDupRe()
	DbfCompra()
	DbfCmp_ite()
	DbfNegociad()
	DbfNegoci()
	DbfItemNego()
	DbfNfeVen()
	DbfNfeItem()
	DbfNfceItem()
	DbfNfce()
	Dbfdetpagtonfce()
	Dbffpagtonfce()
	Dbfcoriven()
	Dbfopelog()
	DbfTmp01()
	DbfProdFor()
	DbfCFOP()
    DbfPdvNfce()
    DbfPdvNfceItem()
    Fabricante()
    DbfTmp23()
    DbfTmp24()
    Dbf_Fabricantes()
    dbfNfeEntrada()
    DbfNfeItemEntrada()
    dbfFabricantes()
    DbfTemp34()
	return
	
static procedure Fabricante

    if !file(cDiretorio+"fabricante.dbf")
        aadd(aStru,{"codigo","c",03,0})
		aadd(aStru,{"nome","c",30,0})
		dbcreate(cDiretorio+"fabricantes",aStru)
	endif
	return

        
    	
static procedure DbfCFOP
	
	if !file(cDiretorio+"cfop.dbf")
		aStru := {}
		aadd(aStru,{"cfop","c",04,00})
		aadd(aStru,{"descricao","C",80,00})
		dbcreate(cDiretorio+"cfop",aStru)
	endif
	return
	

static procedur DbfProdFor
	local aStru := {}
	
	if !file(cDiretorio+"prodfor.dbf")
		aStru := {}
		aadd(aStru,{"codfor","c",04,00})
		aadd(aStru,{"prodfor","c",13,00})
		aadd(aStru,{"codpro","c",06,00})
		dbcreate(cDiretorio+"prodfor",aStru)
	endif
	return
	
procedure DbfTmp01

	aStru := {}
	aadd(aStru,{"CODPRO"      ,"C",06,00})
	aadd(aStru,{"DESPRO"      ,"C",50,00})
	aadd(aStru,{"CODGRU"      ,"C",03,00})
	aadd(aStru,{"ORDEM"       ,"C",30,00})
	aadd(aStru,{"ORDEF"       ,"C",30,00})
	dbcreate(cDiretorio+"tmp01",aStru)
	return

procedure Dbfopelog
	// ** Log do operador
	if !file(cDiretorio+"opelog.dbf")
		aStru := {}
		aadd(aStru,{"ESTLOG"      ,"C",008,00})
		aadd(aStru,{"DATLOG"      ,"D",008,00})
		aadd(aStru,{"HORLOG"      ,"C",008,00})
		aadd(aStru,{"CODLOG"      ,"C",003,00})
		aadd(aStru,{"OPELOG"      ,"C",025,00})
		aadd(aStru,{"NIVLOG"      ,"C",001,00})
		aadd(aStru,{"ATILOG"      ,"C",080,00})
		dbcreate(cDiretorio+"opelog",aStru)
	endif
	
procedure Dbfcoriven
	if !file(cDiretorio+"coriven.dbf")
		aStru := {}
		aadd(aStru,{"codpro","n",6,0})
		aadd(aStru,{"data","d",08,0})
		aadd(aStru,{"quantidade","n",9,2})
		dbcreate(cDiretorio+"coriven",aStru)
	endif
	
// ***************************************************************************************************	
procedure Dbffpagtonfce

	if !file(cDiretorio+"fpagtonfce.dbf")
		aStru := {}
		aadd(aStru,{"codpagto","c",02,0}) // ** código do pagamento
		aadd(aStru,{"despagto","c",20,0}) // ** descrição do pagamento
		aadd(aStru,{"cartao","c",01,0})
		dbcreate(cDiretorio+"fpagtonfce",aStru)
	endif
	return
	
// **********************************************************************************************************		
procedure Dbfdetpagtonfce
	if !file(cDiretorio+"detpagtonfce.dbf")
		aStru := {}
		aadd(aStru,{"numcon","c",10,0})
		aadd(aStru,{"codpagto","c",02,0})
		aadd(aStru,{"codicred","c",02,0})  // ** codigo da credenciadora do cartao
		aadd(aStru,{"vlrpagto","n",15,2})
		aadd(aStru,{"bandeira","c",02,0})
		aadd(aStru,{"autoriza","c",20,0})
		dbcreate(cDiretorio+"detpagtonfce",aStru)
	endif
	return

procedure DbfNfce  // NFC-e

	if !file(cDiretorio+"nfce.dbf")
		astru := {}
		
		aadd(aStru,{"NUMCON"      ,"C",010,000})
		aadd(aStru,{"NUMNOT"      ,"C",009,000})
		aadd(aStru,{"NumPed"      ,"c",009,000}) // ** Numero do Pedido
		aadd(aStru,{"CODCLI"      ,"C",004,000})
		aadd(aStru,{"CODVEN"      ,"C",002,000})
		aadd(aStru,{"CODNAT"      ,"C",003,000})
		aadd(aStru,{"DTAEMI"      ,"D",008,000})
		aadd(aStru,{"DTASAI"      ,"D",008,000})
		aadd(aStru,{"BASNOR"      ,"N",011,002})
		aadd(aStru,{"BASSUB"      ,"N",011,002})
		aadd(aStru,{"ICMNOR"      ,"N",010,002})
		aadd(aStru,{"ICMSUB"      ,"N",010,002})
		aadd(aStru,{"TOTPRO"      ,"N",011,002})
		aadd(aStru,{"TOTNOT"      ,"N",011,002})
        
        
		aadd(aStru,{"TIPFRE"      ,"C",001,000})
        
		aadd(aStru,{"OBSNOT1"     ,"C",050,000})
		aadd(aStru,{"OBSNOT2"     ,"C",050,000})
		aadd(aStru,{"OBSNOT3"     ,"C",050,000})
		aadd(aStru,{"OBSNOT4"     ,"C",050,000})
		aadd(aStru,{"OBSNOT5"     ,"C",050,000})
		aadd(aStru,{"OBSNOT6"     ,"C",050,000})
        
		aadd(aStru,{"DSCNO1"      ,"N",010,002})
		aadd(aStru,{"DSCNO2"      ,"N",005,002})
		aadd(aStru,{"ACRNO1"      ,"N",010,002})
		aadd(aStru,{"ACRNO2"      ,"N",005,002})
		aadd(aStru,{"ENTPLA"      ,"N",011,002})
		aadd(aStru,{"TIPENT"      ,"C",001,000})
		aadd(aStru,{"TIPPAR"      ,"C",001,000})
		aadd(aStru,{"COMVEN"      ,"N",005,002})
		aadd(aStru,{"IPINOT"      ,"N",010,002})
		aadd(aStru,{"TIPNOT"      ,"C",001,000})
		aadd(aStru,{"BASI00"      ,"N",012,002})
		aadd(aStru,{"BASI07"      ,"N",012,002})
		aadd(aStru,{"BASI17"      ,"N",012,002})
		aadd(aStru,{"BASI25"      ,"N",012,002})
		aadd(aStru,{"BASI12"      ,"N",012,002})
		aadd(aStru,{"CODUSU"      ,"C",002,000})
		aadd(aStru,{"AUTORIZADO"  ,"L",001,000})
		aadd(aStru,{"CSTAT"       ,"C",003,000})
		aadd(aStru,{"NREC"        ,"C",020,000})
		aadd(aStru,{"XMOTIVO"     ,"C",040,000})
		aadd(aStru,{"CHNFCE"      ,"C",044,000})
		aadd(aStru,{"DHRECBTO"    ,"C",040,000})
		aadd(aStru,{"NPROT"       ,"C",040,000})
		aadd(aStru,{"DIGVAL"      ,"C",040,000})
		aadd(aStru,{"ARQUIVO"     ,"C",080,000})
		aadd(aStru,{"NFECA"       ,"L",001,000})
		aadd(aStru,{"NPROTCA"     ,"C",015,000})
		aadd(aStru,{"DHRECBTOCA"  ,"C",010,000})
		aadd(aStru,{"CSTATCA"     ,"C",003,000})
		aadd(aStru,{"XMOTIVOCA"   ,"C",010,000})
		aadd(aStru,{"OBSCAN1"     ,"C",080,000})
		aadd(aStru,{"OBSCAN2"     ,"C",080,000})
		aadd(aStru,{"OBSCAN3"     ,"C",080,000})
		aadd(aStru,{"CANCELADA"   ,"L",001,000})
		dbcreate(cDiretorio+"nfce",aStru)
	endif
	return

procedure DbfNfceItem

	if !file(cDiretorio+"nfceitem.dbf")
		aStru := {}
		aadd(aStru,{"NUMCON"      ,"C",10,00})
		aadd(aStru,{"CODCLI"      ,"C",04,00})
		aadd(aStru,{"CodItem"     ,"C",13,00}) // ** código do item ( pode ser codigo ou código de barras)
		aadd(aStru,{"CODPRO"      ,"C",06,00}) // ** codigo do produto no cadastro do produtos
		aadd(aStru,{"QTDPRO"      ,"N",15,03}) // ** quantidade 
		aadd(aStru,{"PcoVen"      ,"N",15,03}) // ** Preco de venda - Nota
		aadd(aStru,{"DSCPRO"      ,"N",06,02}) // ** Desconto (%)
		aadd(aStru,{"PcoLiq"      ,"N",15,03}) // ** Preço líquido
		aadd(aStru,{"Desconto"    ,"n",15,02}) // ** desconto (R$)
		aadd(aStru,{"TOTPRO"      ,"N",15,02})
		aadd(aStru,{"CODNAT"      ,"C",03,00})
		aadd(aStru,{"CODVEN"      ,"C",02,00})
		aadd(aStru,{"ALISAI"      ,"N",05,02})
		aadd(aStru,{"DTAMOV"      ,"D",08,00}) // ** data da emissao
		aadd(aStru,{"BXAREQ"      ,"C",01,00})
		aadd(aStru,{"BASEICMS"    ,"N",15,02})
		aadd(aStru,{"VALORICMS"   ,"N",15,02})
		aadd(aStru,{"IPI"         ,"N",05,02})
		aadd(aStru,{"CSTSIMPLES"  ,"C",03,00})
		aadd(aStru,{"CANCELADA"   ,"L",01,00})
		dbcreate(cDiretorio+"nfceitem",aStru)
	endif
	return
	
procedure DbfNfeItem

	if !file(cDiretorio+"nfeitem.dbf")
		aStru := {}	
        
        aadd(aStru,{"NUMCON"      ,"C",010,000})
        aadd(aStru,{"CODCLI"      ,"C",004,000})
        aadd(aStru,{"CODPRO"      ,"C",006,000})
        aadd(aStru,{"QTDPRO"      ,"N",008,002})
        aadd(aStru,{"PCOPRO"      ,"N",009,004})
        aadd(aStru,{"PCOCUS"      ,"N",009,002})
        aadd(aStru,{"CODNAT"      ,"C",003,000})
        aadd(aStru,{"CODVEN"      ,"C",002,000})
        aadd(aStru,{"ALISAI"      ,"N",005,002})
        aadd(aStru,{"DTAMOV"      ,"D",008,000})
        aadd(aStru,{"CANNOT"      ,"C",001,000})
        aadd(aStru,{"BXAREQ"      ,"C",001,000})
        aadd(aStru,{"DSCPRO"      ,"N",005,002})
        aadd(aStru,{"TOTPRO"      ,"N",011,002})
        aadd(aStru,{"CST"         ,"C",003,000})
        aadd(aStru,{"BASEICMS"    ,"N",015,002})
        aadd(aStru,{"VALORICMS"   ,"N",015,002})
        aadd(aStru,{"IPI"         ,"N",005,002})
        aadd(aStru,{"DESCONTO"    ,"N",012,002})
		dbcreate(cDiretorio+"nfeitem",aStru)
	endif
	return
		
procedure DbfNfeVen

	if !file(cDiretorio+"nfeven.dbf")
		aStru := {}
        aadd(aStru,{"NUMCON"      ,"C",010,000})
        aadd(aStru,{"NUMNOT"      ,"C",009,000})
        aadd(aStru,{"CODCLI"      ,"C",004,000})
        aadd(aStru,{"CODVEN"      ,"C",002,000})
        aadd(aStru,{"CODNAT"      ,"C",003,000})
        aadd(aStru,{"DTAEMI"      ,"D",008,000})
        aadd(aStru,{"DTASAI"      ,"D",008,000})
        aadd(aStru,{"BASNOR"      ,"N",011,002})
        aadd(aStru,{"BASSUB"      ,"N",011,002})
        aadd(aStru,{"ICMNOR"      ,"N",010,002})
        aadd(aStru,{"ICMSUB"      ,"N",010,002})
        aadd(aStru,{"TOTPRO"      ,"N",011,002})
        aadd(aStru,{"TOTNOT"      ,"N",011,002})
        aadd(aStru,{"FRENOT"      ,"N",010,002})
        aadd(aStru,{"SEGNOT"      ,"N",010,002})
        aadd(aStru,{"TIPFRE"      ,"C",001,000})
        aadd(aStru,{"QTDVOL"      ,"N",008,002})
        aadd(aStru,{"ESPVOL"      ,"C",010,000})
        aadd(aStru,{"MARVOL"      ,"C",010,000})
        aadd(aStru,{"NUMVOL"      ,"N",005,000})
        aadd(aStru,{"PESBRU"      ,"N",009,003})
        aadd(aStru,{"PESLIQ"      ,"N",009,003})
        aadd(aStru,{"CODTRA"      ,"C",002,000})
        aadd(aStru,{"OBSNOT1"     ,"C",050,000})
        aadd(aStru,{"OBSNOT2"     ,"C",050,000})
        aadd(aStru,{"OBSNOT3"     ,"C",050,000})
        aadd(aStru,{"OBSNOT4"     ,"C",050,000})
        aadd(aStru,{"OBSNOT5"     ,"C",050,000})
        aadd(aStru,{"OBSNOT6"     ,"C",050,000})
        aadd(aStru,{"CANNOT"      ,"C",001,000})
        aadd(aStru,{"DSCNO1"      ,"N",010,002})
        aadd(aStru,{"DSCNO2"      ,"N",005,002})
        aadd(aStru,{"ACRNO1"      ,"N",010,002})
        aadd(aStru,{"ACRNO2"      ,"N",005,002})
        aadd(aStru,{"ENTPLA"      ,"N",011,002})
        aadd(aStru,{"TIPENT"      ,"C",001,000})
        aadd(aStru,{"TIPPAR"      ,"C",001,000})
        aadd(aStru,{"CONCOR"      ,"C",001,000})
        aadd(aStru,{"COMVEN"      ,"N",005,002})
        aadd(aStru,{"IPINOT"      ,"N",010,002})
        aadd(aStru,{"TIPNOT"      ,"C",001,000})
        aadd(aStru,{"CODUSU"      ,"C",002,000})
        aadd(aStru,{"GERDUP"      ,"L",001,000})
        aadd(aStru,{"NOTIMP"      ,"L",001,000})
        aadd(aStru,{"NREC"        ,"C",020,000})
        aadd(aStru,{"CSTAT"       ,"C",003,000})
        aadd(aStru,{"XMOTIVO"     ,"C",040,000})
        aadd(aStru,{"CHNFE"       ,"C",044,000})
        aadd(aStru,{"DHRECBTO"    ,"C",040,000})
        aadd(aStru,{"NPROT"       ,"C",040,000})
        aadd(aStru,{"DIGVAL"      ,"C",040,000})
        aadd(aStru,{"ARQUIVO"     ,"C",060,000})
        aadd(aStru,{"CANCELADA"   ,"L",001,000})
        aadd(aStru,{"NPROTCA"     ,"C",015,000})
        aadd(aStru,{"DHRECBTOCA"  ,"C",010,000})
        aadd(aStru,{"CSTATCA"     ,"C",003,000})
        aadd(aStru,{"XMOTIVOCA"   ,"C",010,000})
        aadd(aStru,{"AUTORIZADO"  ,"L",001,000})
		dbcreate(cDiretorio+"nfeven",aStru)
	endif
	return
	
procedure DbfItemNego

	if !file(cDiretorio+"itemnego.dbf")
		aStru := {}
		aadd(aStru,{"LANCNEG"     ,"C",006,00})
		aadd(aStru,{"LANCHE"      ,"C",006,00})
		dbcreate(cDiretorio+"itemnego",aStru)
	endif
	return
	
procedure DbfNegoci

	if !file(cDiretorio+"negoci.dbf")
		aStru := {}
		aadd(aStru,{"LANCNEG"     ,"C",006,00})
		aadd(aStru,{"DATA"        ,"D",008,00})
		aadd(aStru,{"CODNEG"      ,"C",003,00})
		aadd(aStru,{"TAXA"        ,"N",005,02})
		aadd(aStru,{"VALCHE"      ,"N",012,02})
		aadd(aStru,{"VALJUR"      ,"N",012,02})
		aadd(aStru,{"VALLIQ"      ,"N",012,02})
		dbcreate(cDiretorio+"negoci",aStru)
	endif
	return

procedure DbfNegociad

	if !file(cDiretorio+"negociad.dbf")
		aStru := {}
		aadd(aStru,{"CODIGO"      ,"C",003,00})
		aadd(aStru,{"NOME"        ,"C",030,00})
		dbcreate(cDiretorio+"negociad",aStru)
	endif
	return
	
procedure DbfCmp_Ite // Item de compras
	local aStru := {}
	
	if !file(cDiretorio+"cmp_ite.dbf")
		aadd(aStru,{"CHAVE"       ,"C",06,00}) // ** Chave de lançamento da nota
		aadd(aStru,{"DTAENT"      ,"D",08,00}) // ** Data de entrada
		aadd(aStru,{"PRODFOR"     ,"C",13,00}) // ** Código do produto do fornecedor na nota
        aadd(aStru,{"CodItem"     ,"c",13,00})
		aadd(aStru,{"CODPRO"      ,"C",06,00}) // ** Código do produto
		aadd(aStru,{"CST"         ,"C",03,00}) // ** CST do item referente a nota
		aadd(aStru,{"CFOP"        ,"C",04,00})
		aadd(aStru,{"QUANTIDADE"  ,"N",15,03}) // ** Quantidade do item
		aadd(aStru,{"CODLAB"      ,"C",04,00})
		aadd(aStru,{"LOTE"        ,"C",20,00})
		aadd(aStru,{"FABRICACAO"  ,"D",08,00})
		aadd(aStru,{"VALIDADE"    ,"D",08,00})
		aadd(aStru,{"FRETE"       ,"N",15,02}) // ** Valor do frete do item
		aadd(aStru,{"SEGURO"      ,"N",15,02}) // ** VAlor do seguro do item
		aadd(aStru,{"DESCONTO"    ,"N",15,02}) // ** Valor do desconto do item
		aadd(aStru,{"OUTROS"      ,"N",15,02})
		aadd(aStru,{"CUSTO"       ,"N",15,02})
		aadd(aStru,{"ALIICMS"     ,"N",06,02})
		aadd(aStru,{"BASEICMS"    ,"N",15,02})
		aadd(aStru,{"VALORICMS"   ,"N",15,02})
		aadd(aStru,{"ALIPI"       ,"N",06,02})  // ** Alíquota do ipi
		aadd(aStru,{"BASEIPI"     ,"N",15,02})  // ** Base de calculo do ipi
		aadd(aStru,{"VALORIPI"    ,"N",15,02})  // ** VAlor do ipi
		dbcreate(cDiretorio+"cmp_ite",aStru)
	endif
	return

procedure DbfCompra // Compra
	local aStru := {}
	
	if !file(cDiretorio+"compra.dbf")
		aadd(aStru,{"CHAVE"       ,"C",06,00})
		aadd(aStru,{"CODFOR"      ,"C",04,00})
		aadd(aStru,{"NUMNOT"      ,"C",09,00})
		aadd(aStru,{"MODELO"      ,"C",02,00})
		aadd(aStru,{"SERIE"       ,"C",03,00})
		aadd(aStru,{"SUBSERIE"    ,"C",02,00})
		aadd(aStru,{"DTAENT"      ,"D",08,00})
		aadd(aStru,{"DTAEMI"      ,"D",08,00})
		aadd(aStru,{"DTADOC"      ,"D",08,00})
		aadd(aStru,{"PAGTO"       ,"C",01,00})
		aadd(aStru,{"NUMPAR"      ,"N",02,00})
		aadd(aStru,{"MODFRETE"    ,"C",01,00})
		aadd(aStru,{"CODNAT"      ,"C",03,00}) // ** Natureza da operação
		aadd(aStru,{"BASEICMS"    ,"N",15,02})
		aadd(aStru,{"VALORICMS"   ,"N",15,02})
		aadd(aStru,{"BASEICMSST"  ,"N",15,02})
		aadd(aStru,{"VALICMSST"   ,"N",15,02})
		aadd(aStru,{"TOTALPROD"   ,"N",15,02})
		aadd(aStru,{"FRETE"       ,"N",15,02})
		aadd(aStru,{"SEGURO"      ,"N",15,02})
		aadd(aStru,{"DESCONTO"    ,"N",15,02})
		aadd(aStru,{"OUTRASDESP"  ,"N",15,02})
		aadd(aStru,{"IPI"         ,"N",15,02})
		aadd(aStru,{"TOTALNOTA"   ,"N",15,02})
		aadd(aStru,{"SN"          ,"L",01,00})
		dbcreate(cDiretorio+"compra",aStru)
	endif
	return


procedure DbfBxaDupRe

	if !file(cDiretorio+"bxadupre.dbf")
		aStru := {}
		aadd(aStru,{"CODCLI"      ,"C",004,00})
		aadd(aStru,{"NUMDUP"      ,"C",016,00})
		aadd(aStru,{"CODBCO"      ,"C",003,00})
		aadd(aStru,{"NUMAGE"      ,"C",010,00})
		aadd(aStru,{"NUMCON"      ,"C",015,00})
		aadd(aStru,{"NUMCHQ"      ,"C",010,00})
		aadd(aStru,{"NOMCON"      ,"C",040,00})
		aadd(aStru,{"TIPOCOBRA"   ,"C",001,00})
		aadd(aStru,{"DTAEMI"      ,"D",008,00})
		aadd(aStru,{"DTAVEN"      ,"D",008,00})
		aadd(aStru,{"VALDUP"      ,"N",012,02})
		aadd(aStru,{"DTAPAG"      ,"D",008,00})
		aadd(aStru,{"VALJUR"      ,"N",009,02})
		aadd(aStru,{"VALDES"      ,"N",009,02})
		aadd(aStru,{"VALPAG"      ,"N",012,02})
		aadd(aStru,{"OBSBAI"      ,"C",050,00})
		aadd(aStru,{"RECIBO"      ,"C",013,00})
		aadd(aStru,{"LANCXA"      ,"C",006,00})
		dbcreate(cDiretorio+"bxadupre",aStru)
	endif
	return
	
procedure DbfItemOrca

	if !file(cDiretorio+"itemorca.dbf")
		aStru := {}
		aadd(aStru,{"NUMPED"      ,"C",006,00})
		aadd(aStru,{"CODPRO"      ,"C",006,00})
		aadd(aStru,{"LOJSAI"      ,"C",002,00})
		aadd(aStru,{"SLDPRO"      ,"N",010,00})
		aadd(aStru,{"DSCPRO"      ,"N",005,02})
		aadd(aStru,{"QTDPRO"      ,"N",012,02})
		aadd(aStru,{"PCOVEN"      ,"N",012,03})
		aadd(aStru,{"DTASAI"      ,"D",008,00})
		dbcreate(cDiretorio+"itemorca",aStru)
	endif
	return
	
procedure DbfOrcamen

	if !file(cDiretorio+"orcamen.dbf")
		aStru := {}
		
		aadd(aStru,{"NUMPED"      ,"C",006,00})
		aadd(aStru,{"CODCLI"      ,"C",004,00})
		aadd(aStru,{"DATA"        ,"D",008,00})
		aadd(aStru,{"CODVEN"      ,"C",002,00})
		aadd(aStru,{"VALDESC"     ,"N",012,02})
		aadd(aStru,{"PERDESC"     ,"N",005,02})
		aadd(aStru,{"ENTRADA"     ,"N",012,02})
		aadd(aStru,{"SUBTOTAL"    ,"N",012,02})
		aadd(aStru,{"TOTAL"       ,"N",012,02})
		aadd(aStru,{"CODPLA"      ,"C",002,00})
		aadd(aStru,{"OBS"         ,"C",050,00})
		aadd(aStru,{"TIPOCOBRA"   ,"C",001,00})
		aadd(aStru,{"NOTAFISCAL"  ,"C",006,00})
		aadd(aStru,{"FLAG"        ,"C",001,00})
		aadd(aStru,{"ABERTO"      ,"C",001,00})
		aadd(aStru,{"LANCXA"      ,"C",006,00})
		aadd(aStru,{"CP_VEN"      ,"N",005,02})
		aadd(aStru,{"CV_VEN"      ,"N",005,02})
		aadd(aStru,{"FATCOM"      ,"N",006,02})
		dbcreate(cDiretorio+"orcamen",aStru)
	endif
	return
	

procedure DbfTranspo
	
	if !file(cDiretorio+"transpo.dbf")
		aStru := {}
		aadd(aStru,{"CODTRA"      ,"C",002,00})
		aadd(aStru,{"NOMTRA"      ,"C",040,00})
		aadd(aStru,{"ENDTRA"      ,"C",040,00})
		aadd(aStru,{"CIDTRA"      ,"C",020,00})
		aadd(aStru,{"ESTTRA"      ,"C",002,00})
		aadd(aStru,{"PLATRA"      ,"C",007,00})
		aadd(aStru,{"VIATRA"      ,"C",018,00})
		aadd(aStru,{"INSTRA"      ,"C",018,00})
		aadd(aStru,{"ESTPLA"      ,"C",002,00})
		aadd(aStru,{"CGCTRA"      ,"C",014,00})
		aadd(aStru,{"TELTRA"      ,"C",011,00})
		dbcreate(cDiretorio+"transpo",aStru)
	endif
	return
	
	
// ** 	Credenciadoras de Cartao de Crédito/Débito
procedure DbfCredCartao
	
	if !file(cDiretorio+"credcartao.dbf")
		aStru := {}
		aadd(aStru,{"Codigo","c",02,0})
		aadd(aStru,{"Cnpj","c",14,0})
		aadd(aStru,{"Nome","c",30,0})
		dbcreate(cDiretorio+"credcartao",aStru)
	endif
	return
	
procedure DbfBxaDupPa

	if !file(cDiretorio+"bxaduppa.dbf")	
		aStru := {}
		aadd(aStru,{"CODFOR"      ,"C",004,00})
		aadd(aStru,{"NUMDUP"      ,"C",012,00})
		aadd(aStru,{"CODBCO"      ,"C",003,00})
		aadd(aStru,{"CODAGE"      ,"C",010,00})
		aadd(aStru,{"CODCON"      ,"C",010,00})
		aadd(aStru,{"NUMCHQ"      ,"C",010,00})
		aadd(aStru,{"EMITENTE"    ,"C",040,00})
		aadd(aStru,{"TIPOCOBRA"   ,"C",001,00})
		aadd(aStru,{"DTAEMI"      ,"D",008,00})
		aadd(aStru,{"DTAVEN"      ,"D",008,00})
		aadd(aStru,{"VALDUP"      ,"N",012,02})
		aadd(aStru,{"DTAPAG"      ,"D",008,00})
		aadd(aStru,{"VALJUR"      ,"N",009,02})
		aadd(aStru,{"VALDES"      ,"N",009,02})
		aadd(aStru,{"VALPAG"      ,"N",012,02})
		aadd(aStru,{"LANCXA"      ,"C",006,00})
		dbcreate(cDiretorio+"bxaduppa",aStru)
	endif
	return
	

static procedure DbfDupRec
	
	if !file(cDiretorio+"duprec.dbf")
		aStru := {}
		aadd(aStru,{"CODCLI"      ,"C",004,00})
		aadd(aStru,{"NUMDUP"      ,"C",016,00})
		aadd(aStru,{"CODBCO"      ,"C",003,00})
		aadd(aStru,{"NUMAGE"      ,"C",010,00})
		aadd(aStru,{"NUMCON"      ,"C",015,00})
		aadd(aStru,{"NUMCHQ"      ,"C",010,00})
		aadd(aStru,{"NOMCON"      ,"C",040,00})
		aadd(aStru,{"CODVEN"      ,"C",002,00})
		aadd(aStru,{"TIPOCOBRA"   ,"C",001,00})
		aadd(aStru,{"DTAEMI"      ,"D",008,00})
		aadd(aStru,{"DTAVEN"      ,"D",008,00})
		aadd(aStru,{"VALDUP"      ,"N",012,02})
		aadd(aStru,{"DTAPAG"      ,"D",008,00})
		aadd(aStru,{"VALJUR"      ,"N",009,02})
		aadd(aStru,{"VALDES"      ,"N",009,02})
		aadd(aStru,{"VALPAG"      ,"N",012,02})
		aadd(aStru,{"NOTFIS"      ,"C",006,00})
		aadd(aStru,{"TAXPER"      ,"N",005,02})
		aadd(aStru,{"CANDUP"      ,"C",001,00})
		aadd(aStru,{"COMVEN"      ,"N",005,02})
		aadd(aStru,{"OBSBAI"      ,"C",050,00})
		aadd(aStru,{"COMPAGTO"    ,"C",001,00})
		aadd(aStru,{"TRIPLICATA"  ,"C",013,00})
		aadd(aStru,{"PEDIDO"      ,"C",001,00})
		aadd(aStru,{"CODUSU"      ,"C",003,00})
		aadd(aStru,{"CONCLUIDO"   ,"C",001,00})
		aadd(aStru,{"RECIBO"      ,"C",013,00})
		aadd(aStru,{"LANCXA"      ,"C",006,00})
		dbcreate(cDiretorio+"duprec",aStru)
	endif
	return
	
procedure DbfCaixa
	
	if !file(cDiretorio+"caixa.dbf")
		aStru := {}
		aadd(aStru,{"CODCAIXA"    ,"C",002,00})
		aadd(aStru,{"NOMCAIXA"    ,"C",030,00})
		aadd(aStru,{"SLDCAIXA"    ,"N",015,02})
		dbcreate(cDiretorio+"caixa",aStru)
	endif
	return
	
	
procedure DbfMovCxa

	if !file(cDiretorio+"movcxa.dbf")
		aStru := {}
		aadd(aStru,{"LANCAMENTO"  ,"C",006,00})
		aadd(aStru,{"DATA"        ,"D",008,00})
		aadd(aStru,{"CODCAIXA"    ,"C",002,00})
		aadd(aStru,{"CODHISTO"    ,"C",003,00})
		aadd(aStru,{"COMPLEMEN1"  ,"C",050,00})
		aadd(aStru,{"COMPLEMEN2"  ,"C",050,00})
		aadd(aStru,{"TIPO"        ,"C",001,00})
		aadd(aStru,{"VALOR"       ,"N",012,02})
		aadd(aStru,{"CODPAGTO"    ,"C",002,00})
		aadd(aStru,{"FECHADO"     ,"C",001,00})
		aadd(aStru,{"ALTERA"      ,"L",001,00})
		aadd(aStru,{"BANCO"       ,"L",001,00})
		dbcreate(cDiretorio+"movcxa",aStru)
	endif
	return
	
	
procedure DbfDupPag

	if !file(cDiretorio+"duppag.dbf")
		aStru := {}
		aadd(aStru,{"CODFOR"      ,"C",004,00})
		aadd(aStru,{"NUMDUP"      ,"C",012,00})
		aadd(aStru,{"DOCUME"      ,"C",012,00})
		aadd(aStru,{"DTAEMI"      ,"D",008,00})
		aadd(aStru,{"DTAVEN"      ,"D",008,00})
		aadd(aStru,{"VALDUP"      ,"N",012,02})
		aadd(aStru,{"TIPPAG"      ,"C",001,00})
		aadd(aStru,{"CODBCO"      ,"C",003,00})
		aadd(aStru,{"CODAGE"      ,"C",010,00})
		aadd(aStru,{"CODCON"      ,"C",010,00})
		aadd(aStru,{"NUMCHQ"      ,"C",010,00})
		aadd(aStru,{"DTAPAG"      ,"D",008,00})
		aadd(aStru,{"VALJUR"      ,"N",009,02})
		aadd(aStru,{"VALDES"      ,"N",009,02})
		aadd(aStru,{"VALPAG"      ,"N",012,02})
		aadd(aStru,{"SITREG"      ,"C",001,00})
		aadd(aStru,{"OBSBAI"      ,"C",050,00})
		aadd(aStru,{"CANDUP"      ,"C",001,00})
		aadd(aStru,{"OBSDOC"      ,"C",050,00})
		dbcreate(cDiretorio+"duppag",aStru)
	endif
	return
	
static procedure DbfHistCxa

	if !file(cDiretorio+"histcxa.dbf")
		aStru := {}
		aadd(aStru,{"CODHIST"     ,"C",003,00})
		aadd(aStru,{"NOMHIST"     ,"C",030,00})
		aadd(aStru,{"TIPHIST"     ,"C",001,00})
		dbcreate(cDiretorio+"histcxa",aStru)
	endif
	return
	

procedure DbfFPagCxa

	if !file(cDiretorio+"fpagcxa.dbf")
		aStru := {}
		aadd(aStru,{"CODPAGTO"    ,"C",002,00})
		aadd(aStru,{"NOMPAGTO"    ,"C",030,00})
		dbcreate(cDiretorio+"fpagcxa",aStru)
	endif
	return
		
procedure DbfMovBan

	if !file(cDiretorio+"movban.dbf")
		aStru := {}
		aadd(aStru,{"NUMDOC"      ,"C",010,00})
		aadd(aStru,{"CODBCO"      ,"C",003,00})
		aadd(aStru,{"NUMAGE"      ,"C",010,00})
		aadd(aStru,{"NUMCON"      ,"C",010,00})
		aadd(aStru,{"DTAMOV"      ,"D",008,00})
		aadd(aStru,{"CODHIS"      ,"C",003,00})
		aadd(aStru,{"COMPL"       ,"C",020,00})
		aadd(aStru,{"VLRMOV"      ,"N",012,02})
		aadd(aStru,{"OBSMOV"      ,"C",050,00})
		aadd(aStru,{"SLDANT"      ,"N",012,02})
		dbcreate(cDiretorio+"movban",aStru)
	endif
	return
	

procedure DbfCheques

	if !file(cDiretorio+"cheques.dbf")
		aStru := {}
		aadd(aStru,{"CODBCO"      ,"C",003,00})
		aadd(aStru,{"NUMAGE"      ,"C",004,00})
		aadd(aStru,{"NUMCON"      ,"C",015,00})
		aadd(aStru,{"NUMCHQ"      ,"C",010,00})
		aadd(aStru,{"SITCHQ"      ,"C",001,00})
		aadd(aStru,{"DTAEMI"      ,"D",008,00})
		aadd(aStru,{"DTAVEN"      ,"D",008,00})
		aadd(aStru,{"DTADEV"      ,"D",008,00})
		aadd(aStru,{"VALCHQ"      ,"N",012,02})
		aadd(aStru,{"DTAPAG"      ,"D",008,00})
		aadd(aStru,{"VALJUR"      ,"N",009,02})
		aadd(aStru,{"VALDES"      ,"N",009,02})
		aadd(aStru,{"VALPAG"      ,"N",012,02})
		aadd(aStru,{"CODCLI"      ,"C",004,00})
		aadd(aStru,{"OBSERV"      ,"C",040,00})
		aadd(aStru,{"OBSER2"      ,"C",040,00})
		aadd(aStru,{"LANCXA"      ,"C",006,00})
		aadd(aStru,{"RECIBO"      ,"C",013,00})
		aadd(aStru,{"SITCHQ2"     ,"C",001,00})
		aadd(aStru,{"DTADEV2"     ,"D",008,00})
		aadd(aStru,{"LANCHE"      ,"C",006,00})
		aadd(aStru,{"DTANEG"      ,"D",008,00})
		aadd(aStru,{"CODNEG"      ,"C",003,00})
		dbcreate(cDiretorio+"cheques",aStru)
	endif
	return
	
	
procedure DbfPlano()
	
	// ** Planos de Pagamento	
	if !file(cDiretorio+"plano.dbf")
		aStru := {}
		aadd(aStru,{"CODPLA"      ,"C",002,00})
		aadd(aStru,{"DESPLA"      ,"C",030,00})
		aadd(aStru,{"NUMPAR"      ,"N",002,00})
		aadd(aStru,{"TOTPAR"      ,"N",002,00})
		aadd(aStru,{"PRAPAR"      ,"N",002,00})
		aadd(aStru,{"FATATU"      ,"N",011,04})
		aadd(aStru,{"TIPOPE"      ,"C",001,00})
		aadd(aStru,{"PERENT"      ,"C",001,00})
		aadd(aStru,{"PRZPRI"      ,"N",002,00})
		aadd(aStru,{"FATCOM"      ,"N",006,02})
		dbcreate(cDiretorio+"plano",aStru)
	endif
	
	
procedure DbfPedidos // Pedidos
	
	if !file(cDiretorio+"pedidos.dbf")
		aStru := {}
		aadd(aStru,{"NUMPED"      ,"C",009,00}) // 01
		aadd(aStru,{"CODCLI"      ,"C",004,00})
		aadd(aStru,{"DATA"        ,"D",008,00})
		aadd(aStru,{"CODVEN"      ,"C",002,00})
		aadd(aStru,{"VALDESC"     ,"N",012,02})
		aadd(aStru,{"PERDESC"     ,"N",005,02})
		aadd(aStru,{"ENTRADA"     ,"N",012,02})
		aadd(aStru,{"SUBTOTAL"    ,"N",012,02})
		aadd(aStru,{"TOTAL"       ,"N",012,02})
		aadd(aStru,{"CODPLA"      ,"C",002,00})
		aadd(aStru,{"OBS"         ,"C",050,00})
		aadd(aStru,{"TIPOCOBRA"   ,"C",001,00})
		aadd(aStru,{"NOTAFISCAL"  ,"C",006,00})
		aadd(aStru,{"FLAG"        ,"C",001,00})
		aadd(aStru,{"ABERTO"      ,"C",001,00})
		aadd(aStru,{"LANCXA"      ,"C",006,00})
		aadd(aStru,{"CP_VEN"      ,"N",005,02})
		aadd(aStru,{"CV_VEN"      ,"N",005,02})
		aadd(aStru,{"FATCOM"      ,"N",006,02})
		aadd(aStru,{"finalizado"  ,"L",001,00})
		dbcreate(cDiretorio+"pedidos",aStru)
	endif
	return

procedure DbfItemPed // Itens do pedido
	
	if !file(cDiretorio+"itemped.dbf")		
		aStru := {}
		aadd(aStru,{"NumPed"      ,"C",09,00}) // ** Numero do pedido
		aadd(aStru,{"CodItem"     ,"C",13,00}) // ** Código do item (Numerico ou Codigo de barras)
		aadd(aStru,{"CodPro"      ,"C",06,00}) // ** Código fo produto
		aadd(aStru,{"DscPro"      ,"N",06,02}) // ** % desconto
		aadd(aStru,{"QTDPRO"      ,"N",15,03}) // ** Quantidade do produto
		aadd(aStru,{"PCOVEN"      ,"N",15,03}) // ** preco de venda
		aadd(aStru,{"PcoLiq"      ,"N",15,03}) // ** preço líquido 
		aadd(aStru,{"DTASAI"      ,"D",08,00}) // ** Data da saida
        aadd(aStru,{"ValDesc"     ,"N",15,02}) // ** Valor do Desconto
		dbcreate(cDiretorio+"itemped",aStru)
	endif
	return
	
procedure DbfLaboratorio

	if !file(cDiretorio+"laboratorio.dbf")
		aStru := {}
		aadd(aStru,{"CodLab","c",04,0})
		aadd(aStru,{"NomLab","c",40,0})
		dbcreate(cDiretorio+"laboratorio",aStru)
	endif
	return

	
	
procedure DbfGrupos
	
	// ** Grupo de produtos ***********************************************************************************
	if !file(cDiretorio+"grupos.dbf")
		aStru := {}
		aadd(aStru,{"codgru","c",03,0})
		aadd(aStru,{"nomgru","c",30,0})
		dbcreate(cDiretorio+"grupos",aStru)
	endif
	return
	
procedure DbfSubGrupo
	// ** Sub Grupo de produtos ********************************************************************************
	if !file(cDiretorio+"subgrupo.dbf")
		aStru := {}
		aadd(aStru,{"codsubgru","c",03,0})
		aadd(aStru,{"nomsubgru","c",30,0})
		dbcreate(cDiretorio+"subgrupo",aStru)
	endif
	return
	
procedure DbfUnidMed
	// ** Unidade de Medida de produtos	***********************************************************************
	if !file(cDiretorio+"unidmed.dbf")
		aStru := {}
		aadd(aStru,{"CODMED"      ,"C",004,00})
		aadd(aStru,{"DESMED"      ,"C",015,00})
		dbcreate(cDiretorio+"unidmed",aStru)
	endif
	return
	
	
	
static procedure DbfGrupoCli  // ** grupo de clientes
	
	if !file(cDiretorio+"grupocli.dbf")
		aStru := {}
		aadd(aStru,{"codigo","c",3,0})
		aadd(aStru,{"descricao","c",30,0})
		dbcreate(cDiretorio+"grupocli",aStru)
	endif
	return
	
static procedure DbfSitTrib  // Situacao tributaria

	if !file(cDiretorio+"sittrib.dbf")
		aStru := {}
		aadd(aStru,{"CodFis","c",3,0})
		aadd(aStru,{"DesFis","c",60,0})
		dbcreate(cDiretorio+"sittrib",aStru)
	endif
	return
	

static procedure DbfNatureza
	
	if !file(cDiretorio+"natureza.dbf")
		aStru := {}
		aadd(aStru,{"codnat"      ,"C",03,00})
		aadd(aStru,{"Descricao"   ,"C",80,00})
		aadd(aStru,{"CFOP"        ,"C",04,00})
		aadd(aStru,{"tipo"        ,"C",01,00})
		aadd(aStru,{"operacao"    ,"C",01,00})
		aadd(aStru,{"aliquota"    ,"N",05,02})
		aadd(aStru,{"local"       ,"C",01,00})
		aadd(aStru,{"GERDUP"      ,"C",01,00})
		aadd(aStru,{"ALTCUS"      ,"C",01,00})
		aadd(aStru,{"BXAEST"      ,"C",01,00})
		aadd(aStru,{"OBS1"        ,"C",90,00})
		aadd(aStru,{"OBS2"        ,"C",90,00})
		aadd(aStru,{"OBS3"        ,"C",90,00})
		aadd(aStru,{"OBS4"        ,"C",90,00})
		aadd(aStru,{"OBS5"        ,"C",90,00})
		aadd(aStru,{"OBS6"        ,"C",90,00})
		dbcreate(cDiretorio+"natureza",aStru)
	endif
	return
		

static procedure DbfFornecedor
	local aStru := {}

	if !file(cDiretorio+"fornece.dbf")
		aadd(aStru,{"CODFOR"      ,"C",004,00})
		aadd(aStru,{"DATFOR"      ,"D",008,00})
		aadd(aStru,{"RAZFOR"      ,"C",060,00})
		aadd(aStru,{"FANFOR"      ,"C",040,00})
		aadd(aStru,{"ENDFOR"      ,"C",060,00})
		aadd(aStru,{"BAIFOR"      ,"C",060,00})
		aadd(aStru,{"CODCID"      ,"C",004,00})
		aadd(aStru,{"CEPFOR"      ,"C",008,00})
		aadd(aStru,{"TELFOR1"     ,"C",011,00})
		aadd(aStru,{"TELFOR2"     ,"C",011,00})
		aadd(aStru,{"FAXFOR"      ,"C",011,00})
		aadd(aStru,{"EMAFOR"      ,"C",040,00})
		aadd(aStru,{"CELFOR"      ,"C",015,00})
		aadd(aStru,{"CONFOR"      ,"C",035,00})
		aadd(aStru,{"CGCFOR"      ,"C",014,00})
		aadd(aStru,{"IESFOR"      ,"C",014,00})
		aadd(aStru,{"OBS"         ,"C",050,00})
		aadd(aStru,{"COMPL"       ,"C",060,00})
		aadd(aStru,{"NUMERO"      ,"C",006,00})
		dbcreate(cDiretorio+"fornece",aStru)
	endif
	return

procedure DbfClientes

	if !file(cDiretorio+"clientes.dbf")		
		aStru := {;
		{"CODCLI"      ,"C",004,00},;
		{"TIPCLI"      ,"C",001,00},;
		{"BLOCLI"      ,"C",001,00},;
		{"DATCLI"      ,"D",008,00},;
		{"NOMCLI"      ,"C",060,00},;
		{"APECLI"      ,"C",040,00},;
		{"ENDCLI"      ,"C",060,00},;
		{"COMPL"       ,"C",060,00},;
		{"NUMCLI"      ,"C",006,00},;
		{"BAICLI"      ,"C",060,00},;
		{"CODCID"      ,"C",004,00},;
		{"CEPCLI"      ,"C",008,00},;
		{"TELCLI1"     ,"C",011,00},;
		{"TELCLI2"     ,"C",011,00},;
		{"FAXCLI"      ,"C",011,00},;
		{"EMACLI"      ,"C",040,00},;
		{"CELCLI"      ,"C",015,00},;
		{"CONCLI"      ,"C",035,00},;
		{"CGCCLI"      ,"C",014,00},;
		{"IESCLI"      ,"C",014,00},;
		{"CPFCLI"      ,"C",011,00},;
		{"RGCLI"       ,"C",015,00},;
		{"NASCLI"      ,"D",008,00},;
		{"SPCCLI"      ,"C",001,00},;
		{"SERASA"      ,"C",001,00},;
		{"LIMITE"      ,"N",012,02},;
		{"OBS"         ,"C",050,00},;
		{"CODPAIS"     ,"C",004,00},;
		{"XPAIS"       ,"C",020,00},;
		{"CODCOB"      ,"C",002,00},;
		{"CODVEN"      ,"C",002,00},;
		{"CODNAT"      ,"C",003,00},;
		{"INDIEDEST"   ,"C",001,00},;
		{"INDIFINAL"   ,"C",001,00},;
		{"GRUPOCLI"    ,"C",003,00},;
		{"PREFERENCI"  ,"C",040,00},;
		{"COBRANCA"    ,"C",001,00},;
		{"ENDERCOBRA"  ,"C",060,00},;
		{"NUMERCOBRA"  ,"C",006,00},;
		{"COMPLCOBRA"  ,"C",060,00},;
		{"BAIRRCOBRA"  ,"C",060,00},;
		{"REFERCOBRA"  ,"C",040,00},;
		{"CODCIDCOBR"  ,"C",004,00},;
		{"CEPCOBRA"    ,"C",008,00},;
		{"FONE1COBRA"  ,"C",011,00},;
		{"FONE2COBRA"  ,"C",011,00},;
		{"FAXCOBRA"    ,"C",011,00},;
		{"CELULACOBR"  ,"C",011,00},;
		{"ENTREGA"     ,"C",001,00},;
		{"ENDERENTRE"  ,"C",060,00},;
		{"NUMERENTRE"  ,"C",006,00},;
		{"COMPLENTRE"  ,"C",060,00},;
		{"BAIRRENTRE"  ,"C",060,00},;
		{"REFERENTRE"  ,"C",040,00},;
		{"CODCIDENTR"  ,"C",004,00},;
		{"CEPENTRE"    ,"C",008,00},;
		{"FONE1ENTRE"  ,"C",011,00},;
		{"FONE2ENTRE"  ,"C",011,00},;
		{"FAXENTRE"    ,"C",011,00},;
		{"CELULAENTR"  ,"C",011,00};
		}
		dbcreate(cDiretorio+"clientes",aStru)
	endif
	return
	

procedure DbfEmpresa

	if !file(cDiretorio+"empresa.dbf")
		aStru := {}
				
		aadd(aStru,{"RAZAO"       ,"C",60,000})
		aadd(aStru,{"ENDERECO"    ,"C",60,000})
		aadd(aStru,{"NUMERO"      ,"C",06,000})
		aadd(aStru,{"COMPLEND"    ,"C",60,000})
		aadd(aStru,{"BAIRRO"      ,"C",60,000})
		aadd(aStru,{"CODCID"      ,"C",04,000})
		aadd(aStru,{"ESTCID"      ,"C",02,000})
		aadd(aStru,{"CEP"         ,"C",08,000})
		aadd(aStru,{"TELEFONE1"   ,"C",11,000})
		aadd(aStru,{"TELEFONE2"   ,"C",11,000})
		aadd(aStru,{"EMAIL"       ,"C",40,000})
		aadd(aStru,{"CNPJ"        ,"C",14,000})
		aadd(aStru,{"IE"          ,"C",14,000})
		aadd(aStru,{"IM"          ,"C",15,000})
		aadd(aStru,{"CNAE"        ,"C",07,000})
		aadd(aStru,{"CRT"         ,"C",01,000})
		dbcreate(cDiretorio+"empresa",aStru)
	endif
	return

	
static procedure DbfVendedor

	if !file(cDiretorio+"vendedor.dbf")
		aStru := {}
		aadd(aStru,{"CODIGO"      ,"C",002,00})
		aadd(aStru,{"NOME"        ,"C",020,00})
		aadd(aStru,{"CV_VEN"      ,"N",005,02})
		aadd(aStru,{"CP_VEN"      ,"N",005,02})
		dbcreate(cDiretorio+"vendedor",aStru)
	endif
	return

	
static procedure DbfProdutos

	if !file(cDiretorio+"produtos.dbf")
		aStru := {}
		aadd(aStru,{"CODPRO"      ,"C",006,00}) // ** código do produto
		aadd(aStru,{"DESPRO"      ,"C",120,00}) // ** descrição do produto
		aadd(aStru,{"FANPRO"      ,"C",050,00}) // ** apelido ou nome fantasia do produto
		aadd(aStru,{"DTAPRO"      ,"D",008,00}) // ** data de cadastramento do produto
		aadd(aStru,{"PCTCOM"      ,"N",005,02}) // ** % de comissão
		aadd(aStru,{"PCTDSC"      ,"N",005,02}) // ** % do desconto máximo concedido
		aadd(aStru,{"PCOVEN"      ,"N",011,03}) // ** preço de venda
		aadd(aStru,{"PCOINI"      ,"N",011,03}) // ** preço inicial
		aadd(aStru,{"PCOCUS"      ,"N",011,03}) // ** preço de custo
		aadd(aStru,{"PCOPRZ"      ,"N",011,03}) // ** preço a prazo
		aadd(aStru,{"REFPRO"      ,"C",015,00}) // ** referência do produto
		aadd(aStru,{"LOCPRO"      ,"C",005,00}) // ** local do produto
		aadd(aStru,{"PCOBRU"      ,"N",011,02})
		aadd(aStru,{"PCOCUB"      ,"N",011,02})
		aadd(aStru,{"PCOPRO"      ,"N",011,02})
		aadd(aStru,{"QTEAC01"     ,"N",015,03})
		aadd(aStru,{"QTEAC02"     ,"N",015,03})
		aadd(aStru,{"PCOINV"      ,"N",011,02})
		aadd(aStru,{"QTEIV01"     ,"N",015,03})
		aadd(aStru,{"QTEIV02"     ,"N",015,03})
		aadd(aStru,{"CUSMED01"    ,"N",015,03})
		aadd(aStru,{"CUSMED02"    ,"N",015,03})
		aadd(aStru,{"QTERE01"     ,"N",015,03})
		aadd(aStru,{"QTERE02"     ,"N",015,03})
		aadd(aStru,{"EMBPRO"      ,"C",004,00}) // ** embalagem do produto
		aadd(aStru,{"QTEEMB"      ,"N",003,00}) // ** quantidade de produto na embalagem
		aadd(aStru,{"PESLIQ"      ,"N",009,03}) // ** peso líquído
		aadd(aStru,{"PESBRU"      ,"N",009,03}) // ** peso bruto
		aadd(aStru,{"ICMSUB"      ,"N",005,02})
		aadd(aStru,{"LUCPRO"      ,"N",006,02})
		aadd(aStru,{"CODFIS"      ,"C",002,00})
		aadd(aStru,{"ALIDTR"      ,"N",005,02})
		aadd(aStru,{"ALIFOR"      ,"N",005,02})
		aadd(aStru,{"PERRED"      ,"N",005,02})
		aadd(aStru,{"IPIPRO"      ,"N",006,02})
		aadd(aStru,{"QTDMIN"      ,"N",008,02})
		aadd(aStru,{"QTDMAX"      ,"N",008,02}) // ** Quantidade máxima no estoque
		aadd(aStru,{"PARMAX"      ,"N",002,00}) // ** Quantidade mínima no estoque
		aadd(aStru,{"TABESP"      ,"C",001,00})
		aadd(aStru,{"QTEANT"      ,"N",010,00})
		aadd(aStru,{"SITTRIF"     ,"C",002,00})
		aadd(aStru,{"SITTRID"     ,"C",002,00})
		aadd(aStru,{"ULTSAI"      ,"D",008,00})
		aadd(aStru,{"ULTENT"      ,"D",008,00})
		aadd(aStru,{"ULTFOR"      ,"C",004,00})
		aadd(aStru,{"ULTPCO"      ,"N",011,02})
		aadd(aStru,{"ULTQTD"      ,"N",010,00})
		aadd(aStru,{"PENENT"      ,"D",008,00})
		aadd(aStru,{"PENFOR"      ,"C",004,00})
		aadd(aStru,{"PENPCO"      ,"N",011,02})
		aadd(aStru,{"PENQTD"      ,"N",010,00})
		aadd(aStru,{"ANTENT"      ,"D",008,00})
		aadd(aStru,{"ANTFOR"      ,"C",004,00})
		aadd(aStru,{"ANTPCO"      ,"N",015,03})
		aadd(aStru,{"ANTQTD"      ,"N",015,03})
		aadd(aStru,{"SALREQ"      ,"N",011,02})
		aadd(aStru,{"TIPPES"      ,"C",001,00})
		aadd(aStru,{"NUMVENDPED"  ,"C",010,00})
		aadd(aStru,{"CODFOR"      ,"C",004,00}) // ** Código do fornecedor
		aadd(aStru,{"CODGRU"      ,"C",003,00}) // ** Código do grupo do produto
		aadd(aStru,{"SUBGRU"      ,"C",003,00}) // ** Código do sub-grupo do produto
		aadd(aStru,{"CODBAR"      ,"C",013,00}) // ** Código de barras
		aadd(aStru,{"CODMAP"      ,"C",007,00}) // ** Código do mapa fisigráfico
		aadd(aStru,{"CODNCM"      ,"C",008,00}) // ** Código do NCM
		aadd(aStru,{"PCTPRZ"      ,"N",005,02})
		aadd(aStru,{"OBSPRO"      ,"C",040,00}) // ** Observação do produto
		aadd(aStru,{"DTAALT"      ,"D",008,00})
		aadd(aStru,{"PCOCAL"      ,"N",015,03}) // ** Preço calculado
		aadd(aStru,{"PCONOT"      ,"N",015,03})
		aadd(aStru,{"PERNOT"      ,"N",006,02})
		aadd(aStru,{"PCTFRE"      ,"N",005,02})
		aadd(aStru,{"PCOSUG"      ,"N",015,03}) // ** preço sugerido
		aadd(aStru,{"CREICM"      ,"N",005,02})
		aadd(aStru,{"CTRLES"      ,"C",001,00})
		aadd(aStru,{"CST"         ,"C",003,00}) // ** Código da situação tributaria
		aadd(aStru,{"CODLAB"      ,"C",004,00})
		aadd(aStru,{"ORIGEM"      ,"C",001,00}) // ** Origem do produto de acordo com a legislação
		aadd(aStru,{"ATIVO"       ,"C",001,00})
		aadd(aStru,{"ESTOQLOTE"   ,"C",001,00})
		aadd(aStru,{"Similar"     ,"c",006,00})
		aadd(aStru,{"NatSaiDent"  ,"c",003,00})
		aadd(aStru,{"NatSaiFora"  ,"c",003,00})
		aadd(aStru,{"NatEntDent"  ,"c",003,00})
		aadd(aStru,{"NatEntFora"  ,"c",003,00})
		aadd(aStru,{"QtdEstI01"   ,"N",015,03}) // ** Quantidade do Estoque Inicial Fiscal
		aadd(aStru,{"QtdEstI02"   ,"N",015,03}) // ** Quantidade do estoque inicial fisico
		dbcreate(cDiretorio+"produtos.dbf",aStru)
	endif
	return

static procedure DbfBanco		
		
	// ** Bancos
	if !file(cDiretorio+"banco.dbf")
		aStru := {}
		aadd(aStru,{"CODBCO"      ,"C",003,00})
		aadd(aStru,{"NUMAGE"      ,"C",004,00})
		aadd(aStru,{"NUMCON"      ,"C",015,00})
		aadd(aStru,{"NOMBCO"      ,"C",030,00})
		aadd(aStru,{"NOMAGE"      ,"C",020,00})
		aadd(aStru,{"PRABCO"      ,"C",020,00})
		aadd(aStru,{"NOMCON"      ,"C",030,00})
		aadd(aStru,{"SLDBCO"      ,"N",012,02})
		aadd(aStru,{"LIXO"        ,"C",004,00})
		dbcreate(cDiretorio+"banco",aStru)
	endif
	return
// ** Historico de Movimento bancario *********************************************************************	
static procedure DbfHistBan	
	
	if !file(cDiretorio+"histban.dbf")
		aStru := {}
		aadd(aStru,{"CODHIS"      ,"C",003,00})
		aadd(aStru,{"DESHIS"      ,"C",020,00})
		aadd(aStru,{"TIPHIS"      ,"C",001,00})
		dbcreate(cDiretorio+"histban",aStru)
	endif
	return
// ** Estados **********************************************************************************************
static procedure DbfEstados	
	
	if !file(cDiretorio+"estados.dbf")
		aStru := {}
		aadd(aStru,{"CODEST"      ,"C",002,00})
		aadd(aStru,{"NOMEST"      ,"C",035,00})
		dbcreate(cDiretorio+"estados",aStru)
	endif
	return
	
static procedure DbfSequenci
	
	// ** Arquivo de sequencia e configuracao
	if !file(cDiretorio+"sequenci.dbf")
		aStru := {}
		aadd(aStru,{"CODCLI"      ,"N",04,00})
		aadd(aStru,{"CODFOR"      ,"N",04,00})
		aadd(aStru,{"CODCID"      ,"N",04,00})
		aadd(aStru,{"LANCXA"      ,"N",06,00})
		aadd(aStru,{"LANCEN"      ,"N",06,00})
		aadd(aStru,{"NUMPED"      ,"N",09,00})
		aadd(aStru,{"NUMNOT"      ,"N",06,00})
		aadd(aStru,{"LANCNO"      ,"N",10,00})
		aadd(aStru,{"LANCMOVCXA"  ,"N",06,00})
		aadd(aStru,{"LANCHE"      ,"N",06,00})
		aadd(aStru,{"NUMORC"      ,"N",06,00})
		aadd(aStru,{"LANCNFA"     ,"N",06,00})
		aadd(aStru,{"LANCNFE"     ,"N",10,00})
		aadd(aStru,{"NUMNFE"      ,"N",09,00})
		aadd(aStru,{"TIPOAMB"     ,"C",01,00})
		aadd(aStru,{"DIRNFE"      ,"C",40,00})
		aadd(aStru,{"DIRCAN"      ,"C",40,00})
		aadd(aStru,{"DIRPDF"      ,"C",40,00})
		aadd(aStru,{"DIRINU"      ,"C",40,00})
		aadd(aStru,{"DIRDPE"      ,"C",40,00})
		aadd(aStru,{"DIRCCE"      ,"C",40,00})
		aadd(aStru,{"LPTORC"      ,"C",25,00})
		aadd(aStru,{"LANCNFCE"    ,"N",10,00})  // ** Numeracao do lançamento da nfc-e
		aadd(aStru,{"NUMNFCE"     ,"N",09,00})  // ** Numeração da nfc-e
		aadd(aStru,{"TipoAmbNFc"  ,"C",01,00})  // ** Tipo do ambiente da NFC-e: 1-Produção 2-Homologação
		aadd(aStru,{"TESTARINTE"  ,"C",01,00})
		aadd(aStru,{"DIRENVRESP"  ,"C",40,00})
		aadd(aStru,{"TEMPO"       ,"N",06,00})
		aadd(aStru,{"baixageral"  ,"N",13,00})
		aadd(aStru,{"GRUPOS"      ,"N",03,00})
		aadd(aStru,{"SUBGRUPOS"   ,"N",03,00})
		aadd(aStru,{"PRODUTOS"    ,"N",06,00})
		aadd(aStru,{"GRUPOCLI"    ,"N",03,00})
		aadd(aStru,{"grupopro"    ,"n",03,00})
		aadd(aStru,{"subgrpro"    ,"n",03,00})
		aadd(aStru,{"plano"       ,"n",02,00})
		aadd(aStru,{"CodNat"      ,"n",03,00})
        aadd(aStru,{"mcupom1","c",48,0})
        aadd(aStru,{"mcupom2","c",48,0})
        aadd(aStru,{"mcupom3","c",48,0})
		dbcreate(cDiretorio+"sequenci",aStru)
        use (cDiretorio)+"sequenci"
        dbappend()
        close
	endif
	return


static procedure DbfPdvNfce	
	
	if !file(cDiretorio+"pdvnfce.dbf")
		aStru := {}
        aadd(aStru,{"LANC"        ,"C",010,00})
        aadd(aStru,{"NFCE"        ,"C",009,00})
        aadd(aStru,{"SERIE"       ,"C",003,00})
        aadd(aStru,{"CODNAT"      ,"C",003,00})
        aadd(aStru,{"CODOPE"      ,"C",002,00})
        aadd(aStru,{"DATA"        ,"D",008,00})
        aadd(aStru,{"HORA"        ,"C",008,00})
        aadd(aStru,{"TOTCUP"      ,"N",015,02})
        aadd(aStru,{"CANCUP"      ,"C",001,00})
        aadd(aStru,{"TOTDES"      ,"N",015,02})
        aadd(aStru,{"TRANSF"      ,"L",001,00})
        aadd(aStru,{"VLRDIN"      ,"N",015,02})
        aadd(aStru,{"VLRCHV"      ,"N",015,02})
        aadd(aStru,{"VLRCHP"      ,"N",015,02})
        aadd(aStru,{"VLRCAR"      ,"N",015,02})
        aadd(aStru,{"VLRTRO"      ,"N",015,02})
        aadd(aStru,{"VLRCRE"      ,"N",015,02})
        aadd(aStru,{"VLRTIK"      ,"N",015,02})
        aadd(aStru,{"TIPCAR"      ,"C",014,00})
        aadd(aStru,{"CGCCPF"      ,"C",014,00})
        aadd(aStru,{"STATUS"      ,"C",010,00})
        aadd(aStru,{"VTROCO"      ,"N",015,02})
        aadd(aStru,{"NUMPED"      ,"C",010,00})
        aadd(aStru,{"NUMODS"      ,"C",010,00})
        aadd(aStru,{"CODVEN"      ,"C",002,00})
        aadd(aStru,{"CHAVE"       ,"C",044,00})
        aadd(aStru,{"AUTORIZADO"  ,"L",001,00})
        aadd(aStru,{"CANCELADA"   ,"L",001,00})
        aadd(aStru,{"CSTAT"       ,"C",003,00})
        aadd(aStru,{"NREC"        ,"C",020,00})
        aadd(aStru,{"XMOTIVO"     ,"C",100,00})
        aadd(aStru,{"DHRECBTO"    ,"C",040,00})
        aadd(aStru,{"NPROT"       ,"C",040,00})
        aadd(aStru,{"NPROTCA"     ,"C",015,00})
        aadd(aStru,{"DHRECBTOCA"  ,"C",010,00})
        aadd(aStru,{"CSTATCA"     ,"C",003,00})
        aadd(aStru,{"OBSCAN1"     ,"C",080,00})
        aadd(aStru,{"OBSCAN2"     ,"C",080,00})
        aadd(aStru,{"OBSCAN3"     ,"C",080,00})
        aadd(aStru,{"CODCLI"      ,"C",004,00})
		dbcreate(cDiretorio+"pdvnfce",aStru)
	endif
	return
    
static procedure DbfPdvNfceItem	
	
	if !file(cDiretorio+"pdvnfceitem.dbf")
		aStru := {}
        aadd(aStru,{"LANC"        ,"C",010,00})
        aadd(aStru,{"CODITEM"     ,"C",013,00})
        aadd(aStru,{"CODPRO"      ,"C",006,00})
        aadd(aStru,{"QTDPRO"      ,"N",015,03})
        aadd(aStru,{"PCOVEN"      ,"N",015,03})
        aadd(aStru,{"DSCPRO"      ,"N",006,02})
        aadd(aStru,{"PCOLIQ"      ,"N",015,03})
        aadd(aStru,{"DESCONTO"    ,"N",015,02})
        aadd(aStru,{"TOTPRO"      ,"N",015,02})
        aadd(aStru,{"CST"         ,"C",003,00})
        aadd(aStru,{"ALIQUOTA"    ,"N",005,02})
        aadd(aStru,{"BASEICMS"    ,"N",015,03})
        aadd(aStru,{"VALORICMS"   ,"N",015,02})
        dbcreate(cDiretorio+"pdvnfceitem",aStru)
    endif
    return
    
	
static procedure DbfTmp23
    // Impress’o do pedido
    local aStru := {}
    
    aadd(aStru,{"ordem","C",03,00})
    aadd(aStru,{"codprod","C",16,0})
    aadd(aStru,{"descricao","C",50,00})
    aadd(aStru,{"unidade","C",03,00})
    aadd(aStru,{"quantidade","n",08,03})
    aadd(aStru,{"valor","n",12,02})
    aadd(aStru,{"total","n",12,02})
    dbcreate(cDiretorio+"tmp"+Arq_Sen+"23",aStru)
    return
    
static procedure DbfTmp24

    local aStru := {}
    
    aadd(aStru,{"numdup1","C",13,00})
    aadd(aStru,{"Dtaven1","d",08,0})
    aadd(aStru,{"Valdup1","n",12,02})
    aadd(aStru,{"numdup2","C",13,00})
    aadd(aStru,{"Dtaven2","d",08,0})
    aadd(aStru,{"Valdup2","n",12,02})
    dbcreate(cDiretorio+"tmp"+Arq_Sen+"24",aStru)
    return
    
static procedure Dbf_Fabricantes
    local aStru := {}

    aadd(aStru,{"CODPRO","C",06,0})
    aadd(aStru,{"DESPRO","C",50,0})
    aadd(aStru,{"CODGRU","C",03,0})
    aadd(aStru,{"ORDEM","C",30,0})
    aadd(aStru,{"ORDEF","C",30,0})
    aadd(aStru,{"CODIGO","C",03,0})
    aadd(aStru,{"NOME","C",30,0})
    dbcreate(cDiretorio+"fabricantes",aStru)
    return
    
    
procedure DbfOrcamentos // Pedidos
	
	if !file(cDiretorio+"orcamentos.dbf")
		aStru := {}
		aadd(aStru,{"id"      ,"C",009,00}) // 01
		aadd(aStru,{"CODCLI"      ,"C",004,00})
		aadd(aStru,{"DATA"        ,"D",008,00})
		aadd(aStru,{"CODVEN"      ,"C",002,00})
		aadd(aStru,{"VALDESC"     ,"N",012,02})
		aadd(aStru,{"PERDESC"     ,"N",005,02})
		aadd(aStru,{"ENTRADA"     ,"N",012,02})
		aadd(aStru,{"SUBTOTAL"    ,"N",012,02})
		aadd(aStru,{"TOTAL"       ,"N",012,02})
		aadd(aStru,{"CODPLA"      ,"C",002,00})
		aadd(aStru,{"OBS"         ,"C",050,00})
		aadd(aStru,{"TIPOCOBRA"   ,"C",001,00})
		aadd(aStru,{"NOTAFISCAL"  ,"C",006,00})
		aadd(aStru,{"FLAG"        ,"C",001,00})
		aadd(aStru,{"ABERTO"      ,"C",001,00})
		aadd(aStru,{"LANCXA"      ,"C",006,00})
		aadd(aStru,{"CP_VEN"      ,"N",005,02})
		aadd(aStru,{"CV_VEN"      ,"N",005,02})
		aadd(aStru,{"FATCOM"      ,"N",006,02})
		aadd(aStru,{"finalizado"  ,"L",001,00})
		dbcreate(cDiretorio+"orcamentos",aStru)
	endif
	return

procedure DbfItemOrcamentos // Itens do pedido
	
	if !file(cDiretorio+"itemorcamentos.dbf")		
		aStru := {}
		aadd(aStru,{"id"      ,"C",09,00}) // ** Numero do pedido
		aadd(aStru,{"CodItem"     ,"C",13,00}) // ** Código do item (Numerico ou Codigo de barras)
		aadd(aStru,{"CodPro"      ,"C",06,00}) // ** Código fo produto
		aadd(aStru,{"DscPro"      ,"N",06,02}) // ** % desconto
		aadd(aStru,{"QTDPRO"      ,"N",15,03}) // ** Quantidade do produto
		aadd(aStru,{"PCOVEN"      ,"N",15,03}) // ** preco de venda
		aadd(aStru,{"PcoLiq"      ,"N",15,03}) // ** preço líquido 
		aadd(aStru,{"DTASAI"      ,"D",08,00}) // ** Data da saida
        aadd(aStru,{"ValDesc"     ,"N",15,02}) // ** Valor do Desconto
        aadd(aStru,{"Custo","N",15,3}) 
		dbcreate(cDiretorio+"itemorcamentos",aStru)
	endif
	return
    
procedure DbfNfeEntrada
    local aStru := {}
        
    if !file(cDiretorio+"nfeentrada.dbf")
      aadd(aStru,{"NUMCON"      ,"C",10,0})
      aadd(aStru,{"NUMNOT"      ,"C",09,0})
      aadd(aStru,{"SERIE"       ,"C",03,0})
      aadd(aStru,{"CODCLI"      ,"C",04,0})
      aadd(aStru,{"CODNAT"      ,"C",03,0})
      aadd(aStru,{"DTAEMI"      ,"D",08,0})
      aadd(aStru,{"DTASAI"      ,"D",08,0})
      aadd(aStru,{"TPNF"        ,"C",01,0})
      aadd(aStru,{"IDDEST"      ,"C",01,0})
      aadd(aStru,{"VBC"         ,"N",13,2})
      aadd(aStru,{"VICMS"       ,"N",13,2})
      aadd(aStru,{"VICMSDESON"  ,"N",13,2})
      aadd(aStru,{"VBCST"       ,"N",13,2})
      aadd(aStru,{"VST"         ,"N",13,2})
      aadd(aStru,{"VPROD"       ,"N",13,2})
      aadd(aStru,{"VFRETE"      ,"N",13,2})
      aadd(aStru,{"VSEG"        ,"N",13,2})
      aadd(aStru,{"VDESC"       ,"N",13,2})
      aadd(aStru,{"VII"         ,"N",13,2})
      aadd(aStru,{"VIPI"        ,"N",13,2})
      aadd(aStru,{"VPIS"        ,"N",13,2})
      aadd(aStru,{"VCOFINS"     ,"N",13,2})
      aadd(aStru,{"VOUTRO"      ,"N",13,2})
      aadd(aStru,{"VNF"         ,"N",13,2})
      aadd(aStru,{"TIPFRE"      ,"C",01,0})
      aadd(aStru,{"QVOL"        ,"N",15,0})
      aadd(aStru,{"ESP"         ,"C",60,0})
      aadd(aStru,{"MARCA"       ,"C",60,0})
      aadd(aStru,{"NVOL"        ,"C",60,0})
      aadd(aStru,{"PESOL"       ,"N",12,3})
      aadd(aStru,{"PESOB"       ,"N",12,3})
      aadd(aStru,{"CODTRA"      ,"C",02,0})
      aadd(aStru,{"OBSNOT1"     ,"C",90,0})
      aadd(aStru,{"OBSNOT2"     ,"C",90,0})
      aadd(aStru,{"OBSNOT3"     ,"C",90,0})
      aadd(aStru,{"OBSNOT4"     ,"C",90,0})
      aadd(aStru,{"OBSNOT5"     ,"C",90,0})
      aadd(aStru,{"OBSNOT6"     ,"C",90,0})
      aadd(aStru,{"AUTORIZADO"  ,"L",01,0})
      aadd(aStru,{"CANCELADA"   ,"L",01,0})
      aadd(aStru,{"NREC"        ,"C",20,0})
      aadd(aStru,{"CSTAT"       ,"C",03,0})
      aadd(aStru,{"XMOTIVO"     ,"C",40,0})
      aadd(aStru,{"CHNFE"       ,"C",44,0})
      aadd(aStru,{"DHRECBTO"    ,"C",40,0})
      aadd(aStru,{"NPROT"       ,"C",40,0})
      aadd(aStru,{"DIGVAL"      ,"C",40,0})
      aadd(aStru,{"ARQUIVO"     ,"C",60,0})
      aadd(aStru,{"NPROTCA"     ,"C",15,0})
      aadd(aStru,{"DHRECBTOCA"  ,"C",10,0})
      aadd(aStru,{"CSTATCA"     ,"C",03,0})
      aadd(aStru,{"XMOTIVOCA"   ,"C",10,0})
        aadd(aStru,{"CONCLUIDO"   ,"L",01,0})
		dbcreate(cDiretorio+"nfeentrada",aStru)
	endif
	return
        
procedure dbfNfeItemEntrada
    local aStru := {}
        
        
    if !file(cDiretorio+"nfeitementrada.dbf")
        aadd(aStru,{"NUMCON"      ,"C",010,000})
        aadd(aStru,{"CODPRO"      ,"C",006,000})
        aadd(aStru,{"QTDPRO"      ,"N",013,003})
        aadd(aStru,{"PCOPRO"      ,"N",013,003})
        aadd(aStru,{"PCOLIQ"      ,"N",013,003})
        aadd(aStru,{"DSCPRO"      ,"N",005,002})
        aadd(aStru,{"FRETE"       ,"N",013,002})
        aadd(aStru,{"SEGURO"      ,"N",013,002})
        aadd(aStru,{"OUTRO"       ,"N",013,002})
        aadd(aStru,{"DESCONTO"    ,"N",013,002})
        aadd(aStru,{"VPROD"       ,"N",013,002})
        aadd(aStru,{"CFOP"        ,"C",004,000})
        aadd(aStru,{"CST"         ,"C",002,000})
        aadd(aStru,{"MODBC"       ,"C",001,000})
        aadd(aStru,{"VBC"         ,"N",013,002})
        aadd(aStru,{"PREDBC"      ,"N",008,004})
        aadd(aStru,{"PICMS"       ,"N",008,004})
        aadd(aStru,{"VICMS"       ,"N",013,002})
        aadd(aStru,{"MODBCST"     ,"C",001,000})
        aadd(aStru,{"PMVAST"      ,"N",008,004})
        aadd(aStru,{"PREDBCST"    ,"N",008,004})
        aadd(aStru,{"VBCST"       ,"N",013,002})
        aadd(aStru,{"PICMSST"     ,"N",008,004})
        aadd(aStru,{"VICMSST"     ,"N",013,002})
        aadd(aStru,{"PCREDSN"     ,"N",008,004})
        aadd(aStru,{"VCREDICMS"   ,"N",013,002})
        aadd(aStru,{"CSTIPI"      ,"C",002,000})
        aadd(aStru,{"CENQIPI"     ,"C",003,000})
        aadd(aStru,{"CSTPIS"      ,"C",002,000})
        aadd(aStru,{"VBCPIS"      ,"N",013,002})
        aadd(aStru,{"ALIPIS"      ,"N",005,002})
        aadd(aStru,{"VPIS"        ,"N",013,002})
        aadd(aStru,{"CSTCOFINS"   ,"C",002,000})
        aadd(aStru,{"VBCCOFINS"   ,"N",013,002})
        aadd(aStru,{"ALICOFINS"   ,"N",005,002})
        aadd(aStru,{"VCOFINS"     ,"N",013,002})
		dbcreate(cDiretorio+"nfeitementrada",aStru)
	endif
	return
    
procedure dbfFabricantes
    local aStru := {}
        
    if !file(cDiretorio+"fabricantes.dbf")
        aadd(aStru,{ "CODPRO"      ,"C",006,00})
        aadd(aStru,{"DESPRO"      ,"C",050,00})
        aadd(aStru,{"CODGRU"      ,"C",003,00})
        aadd(aStru,{"ORDEM"       ,"C",030,00})
        aadd(aStru,{"ORDEF"       ,"C",030,00})
        aadd(aStru,{"CODIGO"      ,"C",003,00})
        aadd(aStru,{"NOME"        ,"C",030,00})
		dbcreate(cDiretorio+"fabricantes",aStru)
	endif
	return
    
procedure DbfTemp34
    local aStru := {}
    
    aadd(aStru,{"numdoc","c",10,0})
    aadd(astru,{"balancete","d",08,0})
    aadd(astru,{"data","d",08,0})
    aadd(astru,{"historico","c",75,0})
    aadd(astru,{"quantidade","n",12,3})
    aadd(aStru,{"valor","n",12,2})
    aadd(aStru,{"tipo","c",01,0})
    aadd(aStru,{"saldo","n",15,02})
    dbcreate(cDiretorio+"tmp"+Arq_Sen+"34",aStru)
    return

    
        
    

// Fim do arquivo.
