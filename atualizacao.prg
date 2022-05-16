#include "inkey.ch"

procedure AtualizaDbf
    
    
    AtuNfce() 
    AtuSequencia()
//    AtuCompra()
//    AtuDupPag()
      AtuPedidos()
      Atu_Itemped()
    AtuFornecedor()
    AtuProdutos()
    AtuCmp_ite()
    AtuNFe()
    Atu_nfe_prod()
    atu_nfeVen()
    Atu_NfeDevItem()
    Atu_MovBan()
    
return


static procedure Atu_MovBan
    private aLixo := {}
    
    aadd(aLixo,{"dtabal","d",08,0})
    Msg(.t.)
    Msg("Aguarde: Atualizando MovBan")
    Atualizar("dados\","MovBan")
    Msg(.f.)
    
    if !Use_dbf(cDiretorio,"movban",.t.,.t.,"lixo")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return
	endif
    Msg(.t.)
    Msg("Atualizando os dados")
    Lixo->(dbgotop())
    do while Lixo->(!eof())
        if empty(Lixo->DtaBal)
            Lixo->DtaBal := Lixo->DtaMov
        endif
        Lixo->(dbskip())
    enddo
    Msg(.f.)
    return


static procedure Atu_NfeVen
    private aLixo := {}
    
    aadd(aLixo,{"VBC"        ,"N",013,02})
    aadd(aLixo,{"VICMS"      ,"N",013,02})
    aadd(aLixo,{"VICMSDESON"  ,"N",013,02})
    aadd(aLixo,{"VBCST"       ,"N",013,02})
    aadd(aLixo,{"VST"         ,"N",013,02})
    aadd(aLixo,{"VPROD"       ,"N",013,02})
    aadd(aLixo,{"VFRETE"      ,"N",013,02})
    aadd(aLixo,{"VSEG"        ,"N",013,02})
    aadd(aLixo,{"VDESC"       ,"N",013,02})
    aadd(aLixo,{"VII"         ,"N",013,02})
    aadd(aLixo,{"VIPI"        ,"N",013,02})
    aadd(aLixo,{"VPIS"        ,"N",013,02})
    aadd(aLixo,{"VCOFINS"     ,"N",013,02})
    aadd(aLixo,{"VOUTRO"      ,"N",013,02})
    aadd(aLixo,{"VNF"         ,"N",013,02})
    Msg(.t.)
    Msg("Aguarde: Atualizando NFE")
    Atualizar("dados\","nfeven")
    Msg(.f.)
    return




static procedure Atu_ItemPed
    private aLixo := {}
    
    aadd(aLixo,{"custo","n",15,03})
    Msg(.t.)
    Msg("Aguarde: Atualizando ITEMPED")
    Atualizar("dados\","itemped")
    Msg(.f.)
    return

static procedure Atu_nfe_prod
    private aLixo := {}
    
    aadd(aLixo,{"cest","c",07,00})
    Msg(.t.)
    Msg("Aguarde: Atualizando NFE_PROD")
    Atualizar("dados\","nfe_prod")
    Msg(.f.)
    return


static procedure AtuNFe
    private aLixo := {}
    
    aadd(aLixo,{"AUTORIZADO"  ,"L",001,00})
    aadd(aLixo,{"serie","c",003,00})
    ? "Arquivo nfe: "
    Atualizar("dados\","nfeven")
    return

        
static procedure AtuNfce
    private aLixo := {}
    
    aadd(aLixo,{"serie","c",03,0})
    Msg(.t.)
    Msg("Aguarde: Atualizando NFCE")
    Atualizar("dados\","nfce")
    Msg(.f.)
    return


static procedure AtuProdutos
    private aLixo := {}
    
    aadd(aLixo,{"cest","c",07,0})
    aadd(aLixo,{"pis","c",02,0})
    aadd(aLixo,{"pisaliq","n",05,02})
    aadd(aLixo,{"cofins","c",02,00})
    aadd(aLixo,{"cofinsaliq","n",05,02})
    aadd(aLixo,{"codfab","c",03,00}) // c¢digo do fabricante
    aadd(aLixo,{"prodbalanc","c",04,0}) 
    Msg(.t.)
    Msg("Aguarde: Atualizando PRODUTOS.DBF")
    Atualizar("dados\","produtos")
    msg(.f.)
    return


    
static procedure AtuFornecedor
    private aLixo := {}
    
    aadd(aLixo,{"tipo","c",01,0})
    aadd(aLixo,{"IndIEDest","c",01,0})
    
    ? "Arquivo fornecedor: "
    Atualizar("dados\","fornece")
    return
    
    
    
    
static procedure AtuPedidos
    private aLixo := {}
    
    aadd(aLixo,{"finalizado","l",01,0})
    aadd(aLixo,{"tpv","n",01,0})
    Msg(.t.)
    Msg("Aguarde: Atualizando Pedidos")
    Atualizar("dados\","pedidos")
    Msg(.f.)
    return
    

static procedure AtuCompra
    private aLixo := {}

    aadd(aLixo,{"CHAVENFE","C",44,0})
    ? "Arquivo de compra: "
    Atualizar("dados\","compra")
    return
    
static procedure AtuCmp_ite
    private aLixo := {}
    
    aadd(aLixo,{"chavenfe","c",44,0})
    
    ? "Arquivo cmp_ite: "
    Atualizar("dados\","cmp_ite")
    return
    

static procedure AtuDupPag
    private aLixo := {}

    aadd(aLixo,{"CHAVENFE","C",44,0})
    ? "Arquivo de dupl. a pagar: "
    Atualizar("dados\","duppag")
    return






// ******************************************************************************
static procedure AtuSequencia
   private aLixo   := {}

   // Versao 6.0
   //           1234567890
   
    aadd(aLixo,{"CodNatNFCe","c",03,00})
    aadd(aLixo,{"LancPdv","n",10,00})
    aadd(aLixo,{"SerieNfe","c",03,0})  // campo 47
    aadd(aLixo,{"copiasNfe","n",02,0}) // campo 48
    aadd(aLixo,{"obsnfce1","c",60,0})
    aadd(aLixo,{"obsnfce2","c",60,0})
    aadd(aLixo,{"obsnfce3","c",60,0})
    // Flag indicando se o pedido dar† baixa no estoque f°sico
    // .t. - sim dar† baixa
    // .f. - n∆o dar† baixa
    aadd(aLixo,{"lancnfedev","n",10,0})
    aadd(aLixo,{"pedidobe","l",01,0}) 
    aadd(aLixo,{"codfab","n",03,0})
    aadd(aLixo,{"modrecibo","c",01,0})
    // 08/03/2021
    aadd(aLixo,{"idorca","n",09,0})
    // modelo de impress∆o da proposta
    aadd(aLixo,{"modpropost","c",01,0})
    aadd(aLixo,{"tipo_estoq","n",01,0})
    aadd(aLixo,{"lancnfeent","n",10,0})
    aadd(aLixo,{"venc_certi","d",08,0})
    ? "Arquivo de Item de sequencia: "
    Atualizar("dados\","sequenci")
	return

    

static procedure Dbf_Nfeven
    private aLixo := {}
    
        
    aadd(aLixo,{"NUMCON"      ,"C",010,00})
    aadd(aLixo,{"NUMNOT"      ,"C",009,00})
    aadd(aLixo,{"CODCLI"      ,"C",004,00})
    aadd(aLixo,{"CODVEN"      ,"C",002,00})
    aadd(aLixo,{"CODNAT"      ,"C",003,00})
    aadd(aLixo,{"DTAEMI"      ,"D",008,00})
    aadd(aLixo,{"DTASAI"      ,"D",008,00})
    aadd(aLixo,{"BASNOR"      ,"N",011,02})
    aadd(aLixo,{"BASSUB"      ,"N",011,02})
    aadd(aLixo,{"ICMNOR"      ,"N",010,02})
    aadd(aLixo,{"ICMSUB"      ,"N",010,02})
    aadd(aLixo,{"TOTPRO"      ,"N",011,02})
    aadd(aLixo,{"TOTNOT"      ,"N",011,02})
    aadd(aLixo,{"FRENOT"      ,"N",010,02})
    aadd(aLixo,{"SEGNOT"      ,"N",010,02})
    aadd(aLixo,{"TIPFRE"      ,"C",001,00})
    aadd(aLixo,{"QTDVOL"      ,"N",008,02})
    aadd(aLixo,{"ESPVOL"      ,"C",010,00})
    aadd(aLixo,{"MARVOL"      ,"C",010,00})
    aadd(aLixo,{"NUMVOL"      ,"N",005,00})
    aadd(aLixo,{"PESBRU"      ,"N",009,03})
    aadd(aLixo,{"PESLIQ"      ,"N",009,03})
    aadd(aLixo,{"CODTRA"      ,"C",002,00})
    aadd(aLixo,{"OBSNOT1"     ,"C",050,00})
    aadd(aLixo,{"OBSNOT2"     ,"C",050,00})
    aadd(aLixo,{"OBSNOT3"     ,"C",050,00})
    aadd(aLixo,{"OBSNOT4"     ,"C",050,00})
    aadd(aLixo,{"OBSNOT5"     ,"C",050,00})
    aadd(aLixo,{"OBSNOT6"     ,"C",050,00})
    aadd(aLixo,{"CANNOT"      ,"C",001,00})
    aadd(aLixo,{"DSCNO1"      ,"N",010,02})
    aadd(aLixo,{"DSCNO2"      ,"N",005,02})
    aadd(aLixo,{"ACRNO1"      ,"N",010,02})
    aadd(aLixo,{"ACRNO2"      ,"N",005,02})
    aadd(aLixo,{"ENTPLA"      ,"N",011,02})
    aadd(aLixo,{"TIPENT"      ,"C",001,00})
    aadd(aLixo,{"TIPPAR"      ,"C",001,00})
    aadd(aLixo,{"CONCOR"      ,"C",001,00})
    aadd(aLixo,{"COMVEN"      ,"N",005,02})
    aadd(aLixo,{"IPINOT"      ,"N",010,02})
    aadd(aLixo,{"TIPNOT"      ,"C",001,00})
    aadd(aLixo,{"CODUSU"      ,"C",002,00})
    aadd(aLixo,{"GERDUP"      ,"L",001,00})
    aadd(aLixo,{"NOTIMP"      ,"L",001,00})
    aadd(aLixo,{"NREC"        ,"C",020,00})
    aadd(aLixo,{"CSTAT"       ,"C",003,00})
    aadd(aLixo,{"XMOTIVO"     ,"C",040,00})
    aadd(aLixo,{"CHNFE"       ,"C",044,00})
    aadd(aLixo,{"DHRECBTO"    ,"C",040,00})
    aadd(aLixo,{"NPROT"       ,"C",040,00})
    aadd(aLixo,{"DIGVAL"      ,"C",040,00})
    aadd(aLixo,{"ARQUIVO"     ,"C",060,00})
    aadd(aLixo,{"CANCELADA"   ,"L",001,00})
    aadd(aLixo,{"NPROTCA"     ,"C",015,00})
    aadd(aLixo,{"DHRECBTOCA"  ,"C",010,00})
    aadd(aLixo,{"CSTATCA"     ,"C",003,00})
    aadd(aLixo,{"XMOTIVOCA"   ,"C",010,00})
    aadd(aLixo,{"AUTORIZADO"  ,"L",001,00})
    aadd(aLixo,{"serie","c",003,00})

    ? "Arquivo NFEVEN: "
    Atualizar("dados\","nfeven")
    return


static procedure Atu_NfeDevItem
   private aLixo   := {}

    aadd(aLixo,{"BCIPI","N",13,2})
    aadd(aLixo,{"PIPI","N",8,4})
    aadd(aLixo,{"VIPI","N",13,2})
       
    Msg(.t.)
    Msg("Aguarde: Atualizando NFEDEVITEM")
    Atualizar("dados\","nfedevitem")
    Msg(.f.)
	return






static procedure Atualizar(cDiretorio,cDbf)
    local cBusca,lAtualiza := .f.


    if !file(cDiretorio+cDbf+".dbf")
        Mens({"Arquivo: "+cDiretorio+cDbf+" n∆o criado"})
        return
    endif

	use (cDiretorio)+cDbf
	copy to (cDiretorio)+cDbf sdf
	copy structure extended to dados\lixo
	close all
    
	use dados\lixo alias lixo
	index on field_name to dados\lixo
	close all
	use dados\lixo alias lixo
	set index to dados\lixo
	for nI := 1 to len(aLixo)
		if len(aLixo[nI][1]) < 10
			cBusca := aLixo[nI][1]+space(10-len(aLixo[nI][1]))
		else
			cBusca := aLixo[nI][1]
		endif
		if !lixo->(dbsetorder(1),dbseek(upper(cBusca)))
			Lixo->(dbappend())
			Lixo->Field_Name := aLixo[nI][1]
			Lixo->Field_Type := aLixo[nI][2]
			Lixo->Field_Len  := aLixo[nI][3]
			Lixo->Field_Dec  := aLixo[nI][4]
			Lixo->(dbcommit())
            lAtualiza := .t.
		endif
	next
	close all
    if lAtualiza
        if file(cDiretorio+cDbf+".bkp")
            ferase(cDiretorio+cDbf+".bkp")
        endif
        rename (cDiretorio)+cDbf+".dbf" to (cDiretorio)+cDbf+".bkp"
        create (cDiretorio)+cDbf from dados\lixo
        use (cDiretorio)+cDbf
        append from (cDiretorio)+cDbf sdf
       // ?? " Atualizado "
    else
       // ?? " OK"
    endif
	return




