#include "hbclass.ch"

class TProdutos
	data nIdGrupo
	data cCodPro 
	data cFanPro 
	data cDesPro 
	data cEmbPro 
	data cEdiPro 
	data nQteEmb 
	data nPcoSug 
	data nPcoPrz 
	data nCusMed 
	data nPcoNot
	data nPcoCus  // ** preço de custo 
	data nPcoVen 
	data nPcoCal 
	data nAliDtr 
	data nAliFor 
	data nPctCom 
	data nPctDsc 
	data cCodFis 
	data cTabEsp 
	data nICMSub 
	data nPerRed 
	data nIPIPro 
	data nPcoPro  // Pre‡o promo‡Æo
    data dDtaPro  // validade da promo‡Æo
	data nPesBru 
	data nPesLiq 
	data cRefPro 
	data nQtdMin 
	data nQtdMax 
	data nParMax
    data dUltEnt // Data da Ultima compra
    data dUltSai // data da Ultima saida
    data nUltQtd // ultima quantidade comprada 
	data nIdFornecedor // Codigo do fornecedor
	data cLocPro 
	data nLucPro 
	data cCodBar 
	data cCodMap 
	data nPctPrz 
	data nIdSubGrupo // sub grupo de produtos
	data cObsPro 
	data nPctFre 
	data nPerNot 
	data nCreICM 
	data cCtrlEs 
	data cCodNCM   // c¢digo ncm
    data cCest     // c¢digo cest  
	data nIdCst    
	data cCodLab 
	data cOrigem
	data cAtivo
	data cEstoqLote
	data nIdSimilar
	data nIdNatSaiDent   // ** Natureza de operacao - saida dentro do estado
	data nIdNatSaiFora   // ** Natureza de operacao - saida fora do estado
	data nIdNatEntDent   // ** Natureza de operacao - entrada dentro do estado
	data nIdNatEntFora   // ** Natureza de operacao - entrada dentro do estado
    data cPis
    data nPisAliq
    data cCofins
    data nCofinsAliq
    data nProdBalanca // c½digo do produto na balanÎa
    data nIdFabricante // c¢digo do fabricante
    data cUltFor // Ultimo fornecedor a comprar
	method new()
	method RecuperarDados
endclass	

method new() class TProdutos
	::nIdGrupo := 0  // ** Código do grupo
	::cCodPro := Space(06)
	::cFanPro := space(50)
	::cDesPro := Space(120)
	::cEmbPro := Space(04)
	::cEdiPro := SPace(30)
	::nQteEmb := 0
	::nPcoSug := 0
	::nPcoPrz := 0
	::nCusMed := 0
	::nPcoNot := 0
	::nPcoCus := 0.000   // ** preço de custo
	::nPcoVen := 0.000   // ** Preço de venda
	::nPcoCal := 0.000   // ** Preço calculado ou preço de nota
	::nAliDtr := 0
	::nAliFor := 0
	::nPctCom := 0
	::nPctDsc := 0
	::cCodFis := Space( 02 )
	::cTabEsp := Space( 01 )
	::nICMSub := 0
	::nPerRed := 0
	::nIPIPro := 0
	::nPcoPro := 0 // pre‡o promo‡Æo
    ::dDtaPro := ctod(space(08)) // validade da promo‡Æo 
	::nPesBru := 0
	::nPesLiq := 0
	::cRefPro := Space( 15 )
	::nQtdMin := 0 // Quantidde minina no estoque
	::nQtdMax := 0 // Quantiade maxima no estoque
	::nParMax := 0
	::nIdFornecedor := 0 // Codigo do fornecedor
	::cLocPro := Space( 05 )
	::nLucPro := 0          // ** Margem de Lucro
	::cCodBar := space(14)  // ** Codigo EAN
	::cCodMap := space(07)  // ** Mapa Fisiografico
	::nPctPrz := 0          // ** Percentual de Venda a Prazo
	::nIdSubGrupo := 0     // ** codigo do sub-grupo de produtos
	::cObsPro := space(40)     // ** Observa‡Æo do produto
	::nPctFre := 0             // ** Percentual de Frete
	::nPerNot := 0             // ** Percentual para o Preco de Nota
	::nCreICM := 0             // ** Cr‚dito de ICMS
	::cCtrlEs := "S"           // ** Controla estoque
	::cCodNCM    := space(08)
    ::cCest      := space(07)
	::nIdCst    := 0
	::cCodLab := space(04)     // ** Codigo do fabricante
	::cOrigem := space(01)
	::cAtivo  := "S"
	::cEstoqLote := "N"        // ** Controla o estoque por lote
	::nIdSimilar := 0 // ** Codigo do produto similar
	::nIdNatSaiDent := 0  // ** Natureza de operacao - saida dentro do estado
	::nIdNatSaiFora := 0  // ** Natureza de operacao - saida fora do estado
	::nIdNatEntDent := 0  // ** Natureza de operacao - entrada dentro do estado
	::nIdNatEntFora := 0  // ** Natureza de operacao - entrada dentro do estado
    ::cPis := space(02)
    ::nPisAliq := 0.00
    ::cCofins := space(02)
    ::nCofinsAliq := 0.00
    ::nProdBalanca := space(04) // c¢digo do produto na balan‡a toledo
    ::nIdFabricante := 0 // c¢digo do fabricante
    ::nUltQtd := 0  // Ultima quantidade comprada
    ::dUltEnt := ctod(space(08))
    ::cUltFor := space(04) // £ltimo fornecedor a comprar
return self

method RecuperarDados(oQ) class TProdutos

	::cAtivo := oQ:Fieldget('ativo')
	::cDesPro := oQ:Fieldget('DesPro')  // // ** Descricao do produtio
	::cFanPro := oQ:Fieldget('Fanpro')  // ** Descrição reduzida do produto
	::cEmbPro  := oQ:fieldget('EmbPro') // ** Unidade de medida			
	::nQteEmb  := oQ:fieldget('QteEmb') // ** Quantidade da embalagem				
	::nIdSimilar := oQ:Fieldget('idsimilar')  // ** Código do produto similar
    ::nProdBalanca := oQ:Fieldget('prodbalanc')  // c¢digo do produto na balan‡a toledo
	::nIdFornecedor := oQ:Fieldget('idfornecedor') // ** codigo doFornecedor
	::nIdGrupo := oQ:Fieldget('idgrupo') // ** Codigo do grupo do produtos
    ::nIdFabricante := oQ:Fieldget('idfabricante') // C¢digo do Fabricante
	::cCodBar := oQ:Fieldget('codbar') // ** Codigo de barras			
	::nIdSubGrupo := oQ:Fieldget('idsubgrupo') // ** Codigo do sub-grupo de produtos					
	::cLocPro := oQ:Fieldget('locpro') // Localiza‡Æo do produto
	::cRefPro := oQ:Fieldget('refpro')
	::nParMax := oQ:Fieldget('parmax')
	::cTabEsp := oQ:Fieldget('tabesp') // Tabela especial
	::nPctFre := oQ:Fieldget('pctfre') // percentual de frete
    ::cCtrlEs := oQ:Fieldget('ctrles')
	::nCreICM := oQ:Fieldget('creicm')   // ** Cr‚dito de ICMS
	::nLucPro := oQ:Fieldget('lucpro')
	::nPerNot := oQ:Fieldget('pernot')
	::nPcoCus := oQ:Fieldget('pcocus') // preco de custo
	::nPcoCal := oQ:Fieldget('pcocal') // ** Preço Calculado - Preço na nota
	::nPctPrz := oQ:Fieldget('pctprz')
	::nPcoSug := oQ:Fieldget('pcosug')
	::nPcoVen := oQ:Fieldget('pcoven')
	::nCusMed := oQ:Fieldget('cusmed02')
	::nPcoPrz := oQ:Fieldget('pcoprz')
	::nPcoPro := oQ:Fieldget('pcopro')  // pre‡o da promo‡Æo
   	::dDtaPro := oQ:Fieldget('dtapro')  // Data de validade da promo‡Æo
	::nPesBru := oQ:Fieldget('pesbru') // Peso bruto
	::nPesLiq := oQ:Fieldget('pesliq') // Peso liquido
	::nPctDsc := oQ:Fieldget('pctdsc') // ** Percentual de Desconto
	::nPctCom := oQ:Fieldget('pctcom') // ** Percentual de Comissao do produto
	::nQtdMin := oQ:Fieldget('qtdmin') // ** Quantidade pro estoque minimo      
	::nQtdMax := oQ:Fieldget('qtdmax') // ** Quantidade pro estoque maximo
	::cCodNCM := oQ:Fieldget('codncm') // ** NCM
    ::cCest  := oQ:Fieldget('cest') // C¢digo CEST
	::cOrigem := oQ:Fieldget('origem')  // Origem da mercadoria
	::cObsPro := oQ:Fieldget('obspro')
	
	// ** Situacao Tributária **************************************************************************
	::nIdCst := oQ:Fieldget('idcst')
	::nAliDtr := oQ:Fieldget('alidtr')
	::nAliFor := oQ:Fieldget('alifor')
    // PIS
    ::cPis := oQ:Fieldget('pis')
    ::nPisAliq := oQ:Fieldget('pisaliq')
	::nPerRed := oQ:Fieldget('perred')
    // COFINS
    ::cCofins := oQ:Fieldget('cofins')
    ::nCofinsAliq := oQ:Fieldget('cofinsaliq')
	::nICMSub := oQ:Fieldget('icmsub')

	::nIPIPro := oQ:Fieldget('ipipro')
	::nIdNatSaiDent := oQ:Fieldget('natsaident') // ** Natureza de operação saída dentro do estado
	::nIdNatSaiFora := oQ:Fieldget('natsaifora') // ** Natureza de operação saída fora do estado
	::nIdNatEntDent := oQ:Fieldget('natentdent') // ** Natureza de operacao entrada dentro do estado
	::nIdNatEntFora := oQ:Fieldget('natentfora') // ** Natureza operacao entrada fora do estado
return .t.
	
// ** Fim do Arquivo.
