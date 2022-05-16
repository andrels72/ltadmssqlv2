/*
    Arquivo: OpenDbfs.prg
    Descri‡Æo: Fun‡äes para abertura dos arquivos de banco de dados
    Autor: Andr‚ Lucas Souza
    Data: 07/11/2018
    
*/
function OpenFabricantes
    if !(Abre_Dados(cDiretorio,"fabricantes",1,2,"Fabricantes",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)


function OpenBaixaGeral
    if !(Abre_Dados(cDiretorio,"baixageral",1,1,"BaixaGeral",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
// *****************************************************************************
function OpenTranspo
    if !(Abre_Dados(cDiretorio,"transpo",1,2,"Transpo",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
// *****************************************************************************        
function OpenCredCartao
    if !(Abre_Dados(cDiretorio,"credcartao",1,3,"CredCartao",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
// *****************************************************************************
function OpenNfeVen
    if !(Abre_Dados(cDiretorio,"nfeven",1,6,"NfeVen",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
// *****************************************************************************    
function OPenNfeItem
    if !(Abre_Dados(cDiretorio,"nfeitem",1,3,"NfeItem",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
// *****************************************************************************
function OpenDetpagtonfe
    if !(Abre_Dados(cDiretorio,"detpagtonfe",1,1,"detpagtonfe",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
// *****************************************************************************    
function OpenNfeDevRef
    if !(Abre_Dados(cDiretorio,"nfedevref",1,1,"nfedevref",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
// *****************************************************************************
function OpenCidades
	if !(Abre_Dados(cDiretorio,"cidades",1,4,"Cidades",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *****************************************************************************
function OpenEstados	
	if !(Abre_Dados(cDiretorio,"estados",1,2,"Estados",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *****************************************************************************
function OpenSequencia	
	if !(Abre_Dados(cDiretorio,"sequenci",0,0,"Sequencia",0,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *****************************************************************************
function OpenTabelaNfe_Text
    if !(Abre_Dados(cDiretorio,"nfe_text",1,1,"nfe_text",1,.t.) == 0)
        return(.f.)
    endif
    return(.t.)
// *****************************************************************************
function OpenTabelaNfe_Nota
    if !(Abre_Dados(cDiretorio,"nfe_nota",1,1,"nfe_nota",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
// *****************************************************************************
function OpenTabelaNfe_Prod
    if !(Abre_Dados(cDiretorio,"nfe_prod",1,1,"nfe_prod",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
//******************************************************************************    
function OpenTabelaNfe_Emit
    if !(Abre_Dados(cDiretorio,"nfe_emit",1,1,"nfe_emit",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
//******************************************************************************
function OpenTabelaNfe_Dupl
    if !(Abre_Dados(cDiretorio,"nfe_dupl",1,1,"nfe_dupl",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
//******************************************************************************

function OpenPdvNfce
	if !(Abre_Dados(cDiretorio,"pdvnfce",1,2,"PdvNfce",0,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************    
function OpenPdvNfceItem
	if !(Abre_Dados(cDiretorio,"pdvnfceitem",1,3,"PdvNfceItem",0,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************	
function OpenNFCeItem
	if !(Abre_Dados(cDiretorio,"nfceitem",1,3,"nfceitem",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************         	    		
function OpenNFCe   
	if !(Abre_Dados(cDiretorio,"nfce",1,6,"nfce",1,.f.) == 0)   
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************         	    	
function OpenEmpresa
	if !(Abre_Dados(cDiretorio,"empresa",0,0,"empresa",0,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************         	    
function OpenMapaFis
	if !(Abre_Dados(cDiretorio,"MapaFis",1,2,"MapaFis",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************         	   
function OpenCfop
	if !(Abre_Dados(cDiretorio,"cfop",1,1,"Cfop",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)   
// *********************************************************************************************************         	
function OpenTabNCM
	if !(Abre_Dados(cDiretorio,"tabncm",1,2,"TabelaNCM",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)   
// *********************************************************************************************************         	
function OpenProdutoFornecedor
	if !(Abre_Dados(cDiretorio,"prodfor",1,3,"ProdutoFornecedor",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)   
// *********************************************************************************************************         	
function OpenCompra
	if !(Abre_Dados(cDiretorio,"compra",1,8,"Compra",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)   
// *********************************************************************************************************         	
function OpenCmp_Ite
	if !(Abre_Dados(cDiretorio,"cmp_ite",1,4,"Cmp_Ite",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)   
// *********************************************************************************************************         
function OpenGrupoCli
	if !(Abre_Dados(cDiretorio,"grupocli",1,2,"GrupoCliente",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)   
// *********************************************************************************************************            
function OpenNatureza
	if !(Abre_Dados(cDiretorio,"Natureza",1,3,"Natureza",1,.f.) == 0)   
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************         
function OpenVendedor
	if !(Abre_Dados(cDiretorio,"Vendedor",1,2,"Vendedor",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************            
function OpenPlano
	if !(Abre_Dados(cDiretorio,"plano",1,2,"Plano",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************         
function OpenPedidos // ** Pedidos   
	if !(Abre_Dados(cDiretorio,"pedidos",1,6,"Pedidos",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************      
function OpenItemPed // ** Itens do pedidos
	if !(Abre_Dados(cDiretorio,"itemped",1,5,"ItemPed",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************      
function OpenDupPag
	if !(Abre_Dados(cDiretorio,"duppag",1,7,"DupPag",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************      
function OpenBxaDupRe
	if !(Abre_Dados(cDiretorio,"bxadupre",1,4,"BxaDupRe",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************      
function OpenBanco
	if !(Abre_Dados(cDiretorio,"banco",1,1,"Banco",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************      
function OpenCheques
	if !(Abre_Dados(cDiretorio,"cheques",1,13,"Cheques",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************      
function OpenCaixa
	if !(Abre_Dados(cDiretorio,"caixa",1,1,"Caixa",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************      
function OpenHistCxa
	if !(Abre_Dados(cDiretorio,"histcxa",1,2,"Historico",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************      
function OpenMovCxa
	if !(Abre_Dados(cDiretorio,"movcxa",1,3,"MovCaixa",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************      
function OpenDupRec
	if !(Abre_Dados(cDiretorio,"DupRec",1,9,"DupRec",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************      
function OpenClientes
   if !(Abre_Dados(cDiretorio,"Clientes",1,8,"Clientes",1,.f.) == 0)
      return(.f.)
   endif
   return(.t.)
// *********************************************************************************************************   
function OpenProdutos(lExclusivo)
    
    if lExclusivo == NIL
        lExclusivo := .f.
    endif
	if !(Abre_Dados(cDiretorio,"produtos",1,11,"Produtos",1,lExclusivo) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************   
function OpenGrupos
	if !(Abre_Dados(cDiretorio,"grupos",1,2,"Grupos",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)                           
// *********************************************************************************************************   
function OpenSubGrupo
	if !(Abre_Dados(cDiretorio,"subgrupo",1,2,"SubGrupo",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************   	
function OpenFornecedor
	if !(Abre_Dados(cDiretorio,"fornece",1,4,"Fornecedor",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************   	
function OpenUnidadeDeMedida
	if !(Abre_Dados(cDiretorio,"unidmed",1,2,"UnidadeDeMedida",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************   	
function OpenSitTrib
	if !(Abre_Dados(cDiretorio,"sittrib",1,1,"SitTrib",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************   
function OpenHistBan
    if !(Abre_Dados(cDiretorio,"HistBan",1,2,"HistBan",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
// *********************************************************************************************************   
function OpenMovBan
    if !(Abre_Dados(cDiretorio,"movban",1,4,"MovBan",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
// *********************************************************************************************************   
function OpenBxaDupPa
    if !(Abre_Dados(cDiretorio,"bxaduppa",1,4,"BxaDupPa",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
// *********************************************************************************************************   
function OpenFPagCxa
    if !(Abre_Dados(cDiretorio,"FPagCxa",1,2,"FormaPag",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
// ****************************************************************************   
function OpenNegociad
    if !(Abre_Dados(cDiretorio,"Negociad",1,2,"Negociador",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
// ****************************************************************************   
function OpenItemNego
    if !(Abre_Dados(cDiretorio,"ItemNego",1,2,"Itemnego",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
// ****************************************************************************
function OpenNegoci    
    if !(Abre_Dados(cDiretorio,"Negoci",1,1,"Negocia",1,.f.) == 0)
        return(.f.)
   endif
   return(.t.)
// ****************************************************************************   
function OpenCCe
    if !(Abre_Dados(cDiretorio,"cce",1,2,"CartaDeCorrecao",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
    
// *************************************************************************
function Open_NfeDevRef
    if !(Abre_Dados(cDiretorio,"nfedevref",1,1,"NfeDevRef",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
// *************************************************************************
function Open_NfeDev  // Nota fiscal de devoluÎ’o
    if !(Abre_Dados(cDiretorio,"nfedev",1,6,"NfeDev",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
   
//**************************************************************************
function Open_NfeDevItem  // Nota fiscal de devoluÎ’o
    if !(Abre_Dados(cDiretorio,"nfedevitem",1,3,"NfeDevItem",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
   
function OpenOrcamentos // ** Pedidos   
	if !(Abre_Dados(cDiretorio,"orcamentos",1,5,"Orcamentos",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
// *********************************************************************************************************      
function OpenItemOrcamentos // ** Itens do pedidos
	if !(Abre_Dados(cDiretorio,"itemorcamentos",1,5,"ItemOrcamentos",1,.f.) == 0)
		return(.f.)
	endif
	return(.t.)
    
function OpenNfeEntrada
    if !(Abre_Dados(cDiretorio,"nfeentrada",1,6,"NfeEntrada",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
// *************************************************************************
function OpenNfeItemEntrada
    if !(Abre_Dados(cDiretorio,"nfeitementrada",1,1,"NfeItemEntrada",1,.f.) == 0)
        return(.f.)
    endif
    return(.t.)
    

    
    
// Fim do arquivo.