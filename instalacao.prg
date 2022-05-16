
function CriarDbfs

    if !IsDirectory("dados")
        if DirMake("dados6") <> 0
            Mens({"Erro na criacao do diretorio do bancos de dados"})
            Return(.f.)
        endif
    endif
    Dbf_Empresa()
    
    Dbf_DetpagtoNfe()
    Dbf_NfeDevRef()
    Dbf_NfeEntrada()
    Dbf_Orcamentos()
    Dbf_NfeDev()
    Dbf_NfeDevItem()
    Dbf_Sequenci()
    Dbf_Plano()
    dbf_Banco()
    Dbf_BaixaGeral()
    Dbf_BxaDupPa()
    Dbf_BxaDupRe()
    Dbf_Caixa()
    Dbf_Cce()
    Dbf_Cfop()
    Dbf_Cheques()
    Dbf_Clientes()
    Dbf_Cmp_Ite()
    Dbf_Compra()
    Dbf_CorIven()
    Dbf_CredCartao()
    Dbf_DetpagtoNfce()
    Dbf_DetpagtoNfe()
    Dbf_DupPag()
    Dbf_DupRec()
    Dbf_Estados()
    Dbf_Fabricantes()
    Dbf_Fornece()
    Dbf_FpagCxa()
    Dbf_GrupoCli()
    Dbf_Grupos()
    Dbf_HistBan()
    Dbf_ItemNego()
    Dbf_ItemOrcamentos()
    Dbf_ItemPed()
    Dbf_Laboratorio()
    Dbf_MovBan()
    Dbf_MovCxa()
    Dbf_Natureza()
    Dbf_Negoci()
    Dbf_Negociad()
return .t.


static procedure Dbf_Negociad
    local aStru := {}
    
    if !file(cDiretorio+"negociad.dbf")
        aadd(aStru,{"CODIGO"      ,"C",003,00})
        aadd(aStru,{"NOME"        ,"C",030,00})
        dbcreate(cDiretorio+"negociad",aStru)
    endif
return

static procedure Dbf_Negoci
    local aStru := {}
    
    if !file(cDiretorio+"negoci.dbf")
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

static procedure Dbf_Natureza
    local aStru := {}
    
    if !file(cDiretorio+"natureza.dbf")
        aadd(aStru,{"CODNAT"      ,"C",003,00})
        aadd(aStru,{"DESCRICAO"   ,"C",080,00})
        aadd(aStru,{"CFOP"        ,"C",004,00})
        aadd(aStru,{"TIPO"        ,"C",001,00})
        aadd(aStru,{"OPERACAO"    ,"C",001,00})
        aadd(aStru,{"ALIQUOTA"    ,"N",005,02})
        aadd(aStru,{"LOCAL"       ,"C",001,00})
        aadd(aStru,{"GERDUP"      ,"C",001,00})
        aadd(aStru,{"ALTCUS"      ,"C",001,00})
        aadd(aStru,{"BXAEST"      ,"C",001,00})
        aadd(aStru,{"OBS1"        ,"C",090,00})
        aadd(aStru,{"OBS2"        ,"C",090,00})
        aadd(aStru,{"OBS3"        ,"C",090,00})
        aadd(aStru,{"OBS4"        ,"C",090,00})
        aadd(aStru,{"OBS5"        ,"C",090,00})
        aadd(aStru,{"OBS6"        ,"C",090,00})
        dbcreate(cDiretorio+"natureza",aStru)
    endif
return

static procedure Dbf_MovCxa
    local aStru := {}
    
    if !file(cDiretorio+"movcxa.dbf")
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

static procedure Dbf_MovBan
    local aStru := {}
    
    if !file(cDiretorio+"movban.dbf")
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

static procedure Dbf_Laboratorio
    local aStru := {}
    
    if !file(cDiretorio+"laboratorio.dbf")
        aadd(aStru,{"CODLAB"      ,"C",004,00})
        aadd(aStru,{"NOMLAB"      ,"C",040,00})
        dbcreate(cDiretorio+"laborario",aStru)
    endif
return

static procedure Dbf_ItemPed
    local aStru := {}
    
    if !file(cDiretorio+"itemped.dbf")
        aadd(astru,{"NUMPED"      ,"C",009,00})
        aadd(astru,{"CODITEM"     ,"C",013,00})
        aadd(astru,{"CODPRO"      ,"C",006,00})
        aadd(astru,{"DSCPRO"      ,"N",006,02})
        aadd(astru,{"QTDPRO"      ,"N",015,03})
        aadd(astru,{"PCOVEN"      ,"N",015,03})
        aadd(astru,{"PCOLIQ"      ,"N",015,03})
        aadd(astru,{"PCOLIQ"      ,"N",015,03})
        aadd(astru,{"DTASAI"      ,"D",008,00})
        aadd(astru,{"VALDESC"     ,"N",015,02})
        aadd(astru,{"CUSTO"       ,"N",015,03})
        dbcreate(cDiretorio+"itemped",aStru)
    endif
return

static procedure Dbf_ItemOrcamentos
    local aStru := {}
    
    if !file(cDiretorio+"itemorcamentos.dbf")
        aadd(aStru,{"ID"          ,"C",009,00})
        aadd(aStru,{"CODITEM"     ,"C",013,00})
        aadd(aStru,{"CODPRO"      ,"C",006,00})
        aadd(aStru,{"DSCPRO"      ,"N",006,02})
        aadd(aStru,{"QTDPRO"      ,"N",015,03})
        aadd(aStru,{"PCOVEN"      ,"N",015,03})
        aadd(aStru,{"PCOLIQ"      ,"N",015,03})
        aadd(aStru,{"DTASAI"      ,"D",008,00})
        aadd(aStru,{"VALDESC"     ,"N",015,02})
        aadd(aStru,{"CUSTO"       ,"N",015,03})
        dbcreate(cDiretorio+"itemorcamentos",aStru)
    endif
return

static procedure Dbf_ItemNego
    local aStru := {}
    
    if !file(cDiretorio+"itemnego.dbf")
        aadd(aStru,{"LANCNEG"     ,"C",006,00})
        aadd(aStru,{"LANCHE"      ,"C",006,00})
        dbcreate(cDiretorio+"itemnego",aStru)
    endif
return

static procedure Dbf_HistCxa
    local aStru := {}
    
    if !file(cDiretorio+"histcxa.dbf")
        aadd(aStru,{"CODHIST"     ,"C",003,00})
        aadd(aStru,{"NOMHIST"     ,"C",030,00})
        aadd(aStru,{"TIPHIST"     ,"C",001,00})
        dbcreate(cDiretorio+"histcxa",aStru)
    endif
return

static procedure Dbf_HistBan
    local aStru := {}
    
    if !file(cDiretorio+"histban.dbf")
        aadd(aStru,{"CODHIS"      ,"C",003,00})
        aadd(aStru,{"DESHIS"      ,"C",020,00})
        aadd(aStru,{"TIPHIS"      ,"C",001,00})
        dbcreate(cDiretorio+"histban",aStru)
    endif
return

static procedure Dbf_Grupos
    local aStru := {}
    
    if !file(cDiretorio+"grupos.dbf")
        aadd(aStru,{"CODGRU"      ,"C",003,0})
        aadd(aStru,{"NOMGRU"      ,"C",030,0})
        dbcreate(cDiretorio+"grupos",aStru)
    endif
return

static procedure Dbf_GrupoCli
    local aStru := {}
    
    if !file(cDiretorio+"grupocli.dbf")
        aadd(aStru,{"CODIGO"      ,"C",003,00})
        aadd(aStru,{"DESCRICAO"   ,"C",030,00})
        dbcreate(cDiretorio+"grupocli",aStru)
    endif
return

static procedure Dbf_FpagCxa
    local aStru := {}
    
    if !file(cDiretorio+"fpagcxa.dbf")
        aadd(aStru,{"CODPAGTO"    ,"C",002,00})
        aadd(aStru,{"NOMPAGTO"    ,"C",030,00})
        dbcreate(cDiretorio+"fpagcxa",aStru)
    endif
return

static procedure Dbf_Fornece
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
        aadd(aStru,{"CRT"         ,"C",001,00})
        aadd(aStru,{"TIPO"        ,"C",001,00})
        aadd(aStru,{"INDIEDEST"   ,"C",001,00})
        dbcreate(cDiretorio+"fornece",aStru)
    endif
return

static procedure Dbf_Fabricantes
    local aStru := {}
    
    if !file(cDiretorio+"fabricantes.dbf")
        aadd(aStru,{"CODPRO"      ,"C",006,00})
        aadd(aStru,{"DESPRO"      ,"C",050,00})
        aadd(aStru,{"CODGRU"      ,"C",003,00})
        aadd(aStru,{"ORDEM"       ,"C",030,00})
        aadd(aStru,{"ORDEF"       ,"C",030,00})
        aadd(aStru,{"CODIGO"      ,"C",003,00})
        aadd(aStru,{"NOME"        ,"C",030,00})
        dbcreate(cDiretorio+"fabricantes",aStru)
    endif
return

static procedure Dbf_Estados
    local aStru := {}
    
    if !file(cDiretorio+"estados.dbf")
        aadd(aStru,{"CODEST"      ,"C",002,00})
        aadd(aStru,{"NOMEST"      ,"C",035,00})
        dbcreate(cDiretorio+"estados",aStru)
    endif
return

static procedure Dbf_DupRec
    local aStru := {}
    
    if !file(cDiretorio+"duprec.dbf")
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


static procedure Dbf_DupPag
    local aStru := {}
    
    if !file(cDiretorio+"duppag.dbf")
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
        aadd(aStru,{"CHAVENFE"    ,"C",044,00})
        aadd(aStru,{"CHAVENFE"    ,"C",044,00})
        dbcreate(cDiretorio+"duppag",aStru)
    endif
return

static procedure Dbf_DetpagtoNfce
    local aStru := {}
    
    if !file(cDiretorio+"detpagtonfce.dbf")
        aadd(aStru,{"NUMCON"      ,"C",010,00})
        aadd(aStru,{"CODPAGTO"    ,"C",002,00})
        aadd(aStru,{"CODICRED"    ,"C",002,00})
        aadd(aStru,{"VLRPAGTO"    ,"N",015,02})
        aadd(aStru,{"BANDEIRA"    ,"C",002,00})
        aadd(aStru,{"AUTORIZA"    ,"C",020,00})
        dbcreate(cDiretorio+"detpagtonfce",aStru)
    endif
return

static procedure Dbf_CredCartao
    local aStru := {}
    
    if !file(cDiretorio+"credcartao.dbf")
        aadd(aStru,{"CODIGO"      ,"C",002,00})
        aadd(aStru,{"CNPJ"        ,"C",014,00})
        aadd(aStru,{"NOME"        ,"C",030,00})
        dbcreate(cDiretorio+"credcartao",aStru)
    endif
return

static procedure Dbf_CorIven
    local aStru := {}
    
    if !file(cDiretorio+"coriven.dbf")
        aadd(aStru,{"CODPRO"      ,"N",006,00})
        aadd(aStru,{"DATA"        ,"D",008,00})
        aadd(aStru,{"QUANTIDADE"  ,"N",009,02})
        dbcreate(cDiretorio+"coriven",aStru)
    endif
return

static procedure Dbf_Compra
    local aStru := {}
    
    if !file(cDiretorio+"compra.dbf")
        aadd(aStru,{"CHAVE"       ,"C",006,00})
        aadd(aStru,{"CODFOR"      ,"C",004,00})
        aadd(aStru,{"NUMNOT"      ,"C",009,00})
        aadd(aStru,{"MODELO"      ,"C",002,00})
        aadd(aStru,{"SERIE"       ,"C",003,00})
        aadd(aStru,{"SUBSERIE"    ,"C",002,00})
        aadd(aStru,{"DTAENT"      ,"D",008,00})
        aadd(aStru,{"DTAEMI"      ,"D",008,00})
        aadd(aStru,{"DTADOC"      ,"D",008,00})
        aadd(aStru,{"PAGTO"       ,"C",001,00})
        aadd(aStru,{"NUMPAR"      ,"N",002,00})
        aadd(aStru,{"MODFRETE"    ,"C",001,00})
        aadd(aStru,{"CODNAT"      ,"C",003,00})
        aadd(aStru,{"BASEICMS"    ,"N",015,02})
        aadd(aStru,{"VALORICMS"   ,"N",015,02})
        aadd(aStru,{"BASEICMSST"  ,"N",015,02})
        aadd(aStru,{"VALICMSST"   ,"N",015,02})
        aadd(aStru,{"TOTALPROD"   ,"N",015,02})
        aadd(aStru,{"FRETE"       ,"N",015,02})
        aadd(aStru,{"SEGURO"      ,"N",015,02})
        aadd(aStru,{"DESCONTO"    ,"N",015,02})
        aadd(aStru,{"OUTRASDESP"  ,"N",015,02})
        aadd(aStru,{"IPI"         ,"N",015,02})
        aadd(aStru,{"TOTALNOTA"   ,"N",015,02})
        aadd(aStru,{"SN"          ,"L",001,00})
        aadd(aStru,{"CHAVENFE"    ,"C",044,00})
        dbcreate(cDiretorio+"compra",aStru)
    endif
return

static procedure Dbf_Cmp_Ite
    local aStru := {}
    
    if !file(cDiretorio+"cmp_ite.dbf")
        aadd(aStru,{"CHAVE"       ,"C",006,00})
        aadd(aStru,{"DTAENT"      ,"D",008,00})
        aadd(aStru,{"PRODFOR"     ,"C",013,00})
        aadd(aStru,{"CODITEM"     ,"C",013,00})
        aadd(aStru,{"CODPRO"      ,"C",006,00})
        aadd(aStru,{"CST"         ,"C",003,00})
        aadd(aStru,{"CFOP"        ,"C",004,00})
        aadd(aStru,{"QUANTIDADE"  ,"N",015,03})
        aadd(aStru,{"CODLAB"      ,"C",004,00})
        aadd(aStru,{"LOTE"        ,"C",020,00})
        aadd(aStru,{"FABRICACAO"  ,"D",008,00})
        aadd(aStru,{"VALIDADE"    ,"D",008,00})
        aadd(aStru,{"FRETE"       ,"N",015,02})
        aadd(aStru,{"SEGURO"      ,"N",015,02})
        aadd(aStru,{"DESCONTO"    ,"N",015,02})
        aadd(aStru,{"OUTROS"      ,"N",015,02})
        aadd(aStru,{"CUSTO"       ,"N",015,02})
        aadd(aStru,{"ALIICMS"     ,"N",006,02})
        aadd(aStru,{"BASEICMS"    ,"N",015,02})
        aadd(aStru,{"VALORICMS"   ,"N",015,02})
        aadd(aStru,{"ALIPI"       ,"N",006,02})
        aadd(aStru,{"BASEIPI"     ,"N",015,02})
        aadd(aStru,{"VALORIPI"    ,"N",015,02})
        aadd(aStru,{"QTD"         ,"N",015,03})
        aadd(aStru,{"CHAVENFE"    ,"C",044,00})
        dbcreate(cDiretorio+"cmp_ite",aStru)
    endif
return

static procedure Dbf_Clientes
    local aStru := {}
    
    if !file(cDiretorio+"clientes.dbf")
        aadd(aStru,{"CODCLI"      ,"C",004,00})
        aadd(aStru,{"TIPCLI"      ,"C",001,00})
        aadd(aStru,{"BLOCLI"      ,"C",001,00})
        aadd(aStru,{"DATCLI"      ,"D",008,00})
        aadd(aStru,{"NOMCLI"      ,"C",060,00})
        aadd(aStru,{"APECLI"      ,"C",040,00})
        aadd(aStru,{"ENDCLI"      ,"C",060,00})
        aadd(aStru,{"COMPL"       ,"C",060,00})
        aadd(aStru,{"NUMCLI"      ,"C",006,00})
        aadd(aStru,{"BAICLI"      ,"C",060,00})
        aadd(aStru,{"CODCID"      ,"C",004,00})
        aadd(aStru,{"CEPCLI"      ,"C",008,00})
        aadd(aStru,{"TELCLI1"     ,"C",011,00})
        aadd(aStru,{"TELCLI2"     ,"C",011,00})
        aadd(aStru,{"FAXCLI"      ,"C",011,00})
        aadd(aStru,{"EMACLI"      ,"C",040,00})
        aadd(aStru,{"CELCLI"      ,"C",015,00})
        aadd(aStru,{"CONCLI"      ,"C",035,00})
        aadd(aStru,{"CGCCLI"      ,"C",014,00})
        aadd(aStru,{"IESCLI"      ,"C",014,00})
        aadd(aStru,{"CPFCLI"      ,"C",011,00})
        aadd(aStru,{"RGCLI"       ,"C",015,00})
        aadd(aStru,{"NASCLI"      ,"D",008,00})
        aadd(aStru,{"SPCCLI"      ,"C",001,00})
        aadd(aStru,{"SERASA"      ,"C",001,00})
        aadd(aStru,{"LIMITE"      ,"N",012,02})
        aadd(aStru,{"OBS"         ,"C",050,00})
        aadd(aStru,{"CODPAIS"     ,"C",004,00})
        aadd(aStru,{"XPAIS"       ,"C",020,00})
        aadd(aStru,{"CODCOB"      ,"C",002,00})
        aadd(aStru,{"CODVEN"      ,"C",002,00})
        aadd(aStru,{"CODNAT"      ,"C",003,00})
        aadd(aStru,{"INDIEDEST"   ,"C",001,00})
        aadd(aStru,{"INDIFINAL"   ,"C",001,00})
        aadd(aStru,{"GRUPOCLI"    ,"C",003,00})
        aadd(aStru,{"PREFERENCI"  ,"C",040,00})
        aadd(aStru,{"COBRANCA"    ,"C",001,00})
        aadd(aStru,{"ENDERCOBRA"  ,"C",060,00})
        aadd(aStru,{"NUMERCOBRA"  ,"C",006,00})
        aadd(aStru,{"COMPLCOBRA"  ,"C",060,00})
        aadd(aStru,{"BAIRRCOBRA"  ,"C",060,00})
        aadd(aStru,{"REFERCOBRA"  ,"C",040,00})
        aadd(aStru,{"CODCIDCOBR"  ,"C",004,00})
        aadd(aStru,{"CEPCOBRA"    ,"C",008,00})
        aadd(aStru,{"FONE1COBRA"  ,"C",011,00})
        aadd(aStru,{"FONE2COBRA"  ,"C",011,00})
        aadd(aStru,{"FAXCOBRA"    ,"C",011,00})
        aadd(aStru,{"CELULACOBR"  ,"C",011,00})
        aadd(aStru,{"ENTREGA"     ,"C",001,00})
        aadd(aStru,{"ENDERENTRE"  ,"C",060,00})
        aadd(aStru,{"NUMERENTRE"  ,"C",006,00})
        aadd(aStru,{"COMPLENTRE"  ,"C",060,00})
        aadd(aStru,{"BAIRRENTRE"  ,"C",060,00})
        aadd(aStru,{"REFERENTRE"  ,"C",040,00})
        aadd(aStru,{"CODCIDENTR"  ,"C",004,00})
        aadd(aStru,{"CEPENTRE"    ,"C",008,00})
        aadd(aStru,{"FONE1ENTRE"  ,"C",011,00})
        aadd(aStru,{"FONE2ENTRE"  ,"C",011,00})
        aadd(aStru,{"FAXENTRE"    ,"C",011,00})
        aadd(aStru,{"CELULAENTR"  ,"C",011,00})
        dbcreate(cDiretorio+"clientes",aStru)
    endif
return

static procedure Dbf_Cheques
    local aStru := {}
    
    if !file(cDiretorio+"cheques.dbf")
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

static procedure Dbf_Cfop
    local aStru := {}
    
    if !file(cDiretorio+"cfop.dbf")
        aadd(aStru,{"CFOP"        ,"C",004,00})
        aadd(aStru,{"DESCRICAO"   ,"C",080,00})
        dbcreate(cDiretorio+"cfop",aStru)
    endif
return

static procedure Dbf_Cce
    local aStru := {}
    
    if !file(cDiretorio+"cce.dbf")
        aadd(aStru,{"NOTA"        ,"C",009,00})
        aadd(aStru,{"SEQUENCIA"   ,"N",002,00})
        aadd(aStru,{"DATA"        ,"D",008,00})
        aadd(aStru,{"HORA"        ,"C",010,00})
        aadd(aStru,{"TEXTO1"      ,"C",076,00})
        aadd(aStru,{"TEXTO2"      ,"C",076,00}) 
        aadd(aStru,{"TEXTO3"      ,"C",076,00}) 
        aadd(aStru,{"TEXTO4"      ,"C",076,00}) 
        aadd(aStru,{"TEXTO5"      ,"C",076,00}) 
        aadd(aStru,{"TEXTO6"      ,"C",076,00}) 
        aadd(aStru,{"TEXTO7"      ,"C",076,00}) 
        aadd(aStru,{"TEXTO8"      ,"C",076,00}) 
        aadd(aStru,{"TEXTO9"      ,"C",076,00}) 
        aadd(aStru,{"TEXTO10"     ,"C",076,00}) 
        aadd(aStru,{"TEXTO11"     ,"C",076,00}) 
        aadd(aStru,{"TEXTO12"     ,"C",076,00}) 
        aadd(aStru,{"TEXTO13"     ,"C",076,00})
        aadd(aStru,{"CSTAT"       ,"C",003,00})
        aadd(aStru,{"DHREGEVENT"  ,"C",040,00})
        aadd(aStru,{"PROTOCOLO"   ,"C",015,00})
        dbcreate(cDiretorio+"cce",aStru)
    endif
return

static procedure Dbf_Caixa
    local aStru := {}
    
    if !file(cDiretorio+"caixa.dbf")
        aadd(aStru,{"CODCAIXA"    ,"C",002,00})
        aadd(aStru,{"NOMCAIXA"    ,"C",030,00})
        aadd(aStru,{"SLDCAIXA"    ,"N",015,02})
        dbcreate(cDiretorio+"caixa",aStru)
    endif
return

static procedure Dbf_BxaDupRe
    local aStru := {}
    
    if !file(cDiretorio+"bxadupre.dbf")
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

static procedure Dbf_BxaDupPa
    local aStru := {}
    
    if !file(cDiretorio+"bxaduppa.dbf")
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

static procedure Dbf_BaixaGeral
    local aStru := {}
    
    if !file(cDiretorio+"baixageral.dbf")
        aadd(aStru,{"CODIGO"      ,"C",013,00})
        aadd(aStru,{"CODCLI"      ,"C",004,00})
        aadd(aStru,{"DTA_BAIXA"   ,"D",008,00})
        aadd(aStru,{"VLR_PAGO"    ,"N",015,02})
        aadd(aStru,{"VLR_DUPL"    ,"N",015,02})
        aadd(aStru,{"JUROS"       ,"N",015,02})
        aadd(aStru,{"DESCONTO"    ,"N",015,02})
        aadd(aStru,{"OBS"         ,"C",080,00})
        dbcreate(cDiretorio+"baixageral",aStru)
    endif
return

static procedure Dbf_Banco
    local aStru := {}
    
    if !file(cDiretorio+"banco.dbf")
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

// Plano de Pagamento
static procedure Dbf_Plano
    local aStru := {}
    
    if !file(cDiretorio+"plano.dbf")
    
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
return


static procedure Dbf_Sequenci
    local aStru := {}
    
    if !file(cDiretorio+"sequenci.dbf")
        aadd(aStru,{"CODCLI"      ,"N",004,00})
        aadd(aStru,{"CODFOR"      ,"N",004,00})
        aadd(aStru,{"CODCID"      ,"N",004,00})
        aadd(aStru,{"LANCXA"      ,"N",006,00})
        aadd(aStru,{"LANCEN"      ,"N",006,00})
        aadd(aStru,{"NUMPED"      ,"N",009,00})
        aadd(aStru,{"NUMNOT"      ,"N",006,00})
        aadd(aStru,{"LANCNO"      ,"N",010,00})
        aadd(aStru,{"LANCMOVCXA"  ,"N",006,00})
        aadd(aStru,{"LANCHE"      ,"N",006,00})
        aadd(aStru,{"NUMORC"      ,"N",006,00})
        aadd(aStru,{"LANCNFA"     ,"N",006,00})
        aadd(aStru,{"LANCNFE"     ,"N",010,00})
        aadd(aStru,{"NUMNFE"      ,"N",009,00})
        aadd(aStru,{"TIPOAMB"     ,"C",001,00})
        aadd(aStru,{"DIRNFE"      ,"C",040,00})
        aadd(aStru,{"DIRCAN"      ,"C",040,00})
        aadd(aStru,{"DIRPDF"      ,"C",040,00})
        aadd(aStru,{"DIRINU"      ,"C",040,00})
        aadd(aStru,{"DIRDPE"      ,"C",040,00})
        aadd(aStru,{"DIRCCE"      ,"C",040,00})
        aadd(aStru,{"LPTORC"      ,"C",025,00})
        aadd(aStru,{"LANCNFCE"    ,"N",010,00})
        aadd(aStru,{"NUMNFCE"     ,"N",009,00})
        aadd(aStru,{"TIPOAMBNFC"  ,"C",001,00})
        aadd(aStru,{"TESTARINTE"  ,"C",001,00})
        aadd(aStru,{"DIRENVRESP"  ,"C",040,00})
        aadd(aStru,{"TEMPO"       ,"N",006,00})
        aadd(aStru,{"BAIXAGERAL"  ,"N",013,00})
        aadd(aStru,{"GRUPOS"      ,"N",003,00})
        aadd(aStru,{"SUBGRUPOS"   ,"N",003,00})
        aadd(aStru,{"PRODUTOS"    ,"N",006,00})
        aadd(aStru,{"GRUPOCLI"    ,"N",003,00})
        aadd(aStru,{"GRUPOPRO"    ,"N",003,00})
        aadd(aStru,{"SUBGRPRO"    ,"N",003,00})
        aadd(aStru,{"PLANO"       ,"N",002,00})
        aadd(aStru,{"CODNAT"      ,"N",003,00})
        aadd(aStru,{"MCUPOM1"     ,"C",048,00})
        aadd(aStru,{"MCUPOM2"     ,"C",048,00})
        aadd(aStru,{"MCUPOM3"     ,"C",048,00})
        aadd(aStru,{"MODIMPPROP"  ,"C",001,00})
        aadd(aStru,{"IMPRECIBO"   ,"C",001,00})
        aadd(aStru,{"COPIASNFCE"  ,"N",002,00})
        aadd(aStru,{"SERIENFCE"   ,"C",003,00})
        aadd(aStru,{"CODNATNFCE"  ,"C",003,00})
        aadd(aStru,{"LANCPDV"     ,"N",010,00})
        aadd(aStru,{"SERIENFE"    ,"C",003,00})
        aadd(aStru,{"COPIASNFE"   ,"N",002,00})
        aadd(aStru,{"OBSNFCE1"    ,"C",060,00})
        aadd(aStru,{"OBSNFCE2"    ,"C",060,00})
        aadd(aStru,{"OBSNFCE3"    ,"C",060,00})
        aadd(aStru,{"CODNATNFCE"  ,"C",003,00})
        aadd(aStru,{"LANCPDV"     ,"N",010,00})
        aadd(aStru,{"SERIENFE"    ,"C",003,00})
        aadd(aStru,{"COPIASNFE"   ,"N",002,00})
        aadd(aStru,{"OBSNFCE1"    ,"C",060,00})
        aadd(aStru,{"OBSNFCE2"    ,"C",060,00})
        aadd(aStru,{"OBSNFCE3"    ,"C",060,00})
        aadd(aStru,{"LANCNFEDEV"  ,"N",010,00})
        aadd(aStru,{"PEDIDOBE"    ,"L",001,00})
        aadd(aStru,{"CODFAB"      ,"N",003,00})
        aadd(aStru,{"MODRECIBO"   ,"C",001,00})
        aadd(aStru,{"IDORCA"      ,"N",009,00})
        aadd(aStru,{"MODPROPOST"  ,"C",001,00})
        aadd(aStru,{"TIPO_ESTOQ"  ,"N",001,00})
        aadd(aStru,{"LANCNFEENT"  ,"N",010,00})
        dbcreate(cDiretorio+"sequenci",aStru)
    endif
return



static procedure Dbf_Empresa
    local aStru := {}
    
    
    if !file(cDiretorio+"empresa.dbf")
        aadd(aStru,{"RAZAO"        ,"C",060,0})
        aadd(aStru,{ "ENDERECO"    ,"C",060,0})
        aadd(aStru,{"NUMERO"       ,"C",006,0})
        aadd(aStru,{"COMPLEND"     ,"C",060,0})
        aadd(aStru,{ "BAIRRO"      ,"C",060,0})
        aadd(aStru,{ "CODCID"      ,"C",004,0})
        aadd(aStru,{ "ESTCID"      ,"C",002,0})
        aadd(aStru,{ "CEP"         ,"C",008,0})
        aadd(aStru,{ "TELEFONE1"   ,"C",012,0})
        aadd(aStru,{ "TELEFONE2"   ,"C",012,0})
        aadd(aStru,{ "EMAIL"       ,"C",040,0})
        aadd(aStru,{ "CNPJ"        ,"C",014,0})
        aadd(aStru,{ "IE"          ,"C",014,0})
        aadd(aStru,{ "IM"          ,"C",015,0})
        aadd(aStru,{ "CNAE"        ,"C",007,0})
        aadd(aStru,{ "CRT"         ,"C",001,0})
        aadd(aStru,{ "FANTASIA"    ,"C",060,0})
        dbcreate(cDiretorio+"empresa",aStru)
    endif
return

procedure Dbf_DetpagtoNfe
	if !file(cDiretorio+"detpagtonfe.dbf")
		aStru := {}
		aadd(aStru,{"numcon","c",10,0})
		aadd(aStru,{"codpagto","c",02,0})
		aadd(aStru,{"codicred","c",02,0})  // ** codigo da credenciadora do cartao
		aadd(aStru,{"vlrpagto","n",15,2})
		aadd(aStru,{"bandeira","c",02,0})
		aadd(aStru,{"autoriza","c",20,0})
		dbcreate(cDiretorio+"detpagtonfe",aStru)
	endif
	return
    
/*
    arquivo de nota fiscal de devolu 'o notas referenciadas
*/
static procedure Dbf_NfeDevRef
    local aStru := {}
    
    if !file(cDiretorio+"nfedevref.dbf")
        aStru := {}
        aadd(aStru,{"numcon","c",10,0})
        aadd(aStru,{"chave","c",44,0})
        dbcreate(cDiretorio+"nfedevref",aStru)
    endif
    return
    
static procedure Dbf_NfeEntrada
    local aStru := {}
    
    if !file(cDiretorio+"nfeentrada.dbf")
        aadd(aStru,{"NUMCON"      ,"C",010,0})
        aadd(aStru,{"NUMNOT"      ,"C",009,0})
        
        aadd(aStru,{"CODCLI"      ,"C",004,0})
        aadd(aStru,{"CODVEN"      ,"C",002,0})
        aadd(aStru,{"CODNAT"      ,"C",003,0})
        aadd(aStru,{"DTAEMI"      ,"D",008,0})
        aadd(aStru,{"DTASAI"      ,"D",008,0})
        aadd(aStru,{"BASNOR"      ,"N",011,2})
        aadd(aStru,{"BASSUB"      ,"N",011,2})
        aadd(aStru,{"ICMNOR"      ,"N",010,2})
        aadd(aStru,{"ICMSUB"      ,"N",010,2})
        aadd(aStru,{"TOTPRO"      ,"N",011,2})
        aadd(aStru,{"TOTNOT"      ,"N",011,2})
        aadd(aStru,{"FRENOT"      ,"N",010,2})
        aadd(aStru,{"SEGNOT"      ,"N",010,2})
        aadd(aStru,{"TIPFRE"      ,"C",001,0})
        aadd(aStru,{"QTDVOL"      ,"N",008,2})
        aadd(aStru,{"ESPVOL"      ,"C",010,0})
        aadd(aStru,{"MARVOL"      ,"C",010,0})
        aadd(aStru,{"NUMVOL"      ,"N",005,0})
        aadd(aStru,{"PESBRU"      ,"N",009,3})
        aadd(aStru,{"PESLIQ"      ,"N",009,3})
        aadd(aStru,{"CODTRA"      ,"C",002,0})
        aadd(aStru,{"OBSNOT1"     ,"C",050,0})
        aadd(aStru,{"OBSNOT2"     ,"C",050,0})
        aadd(aStru,{"OBSNOT3"     ,"C",050,0})
        aadd(aStru,{"OBSNOT4"     ,"C",050,0})
        aadd(aStru,{"OBSNOT5"     ,"C",050,0})
        aadd(aStru,{"OBSNOT6"     ,"C",050,0})
        aadd(aStru,{"CANNOT"      ,"C",001,0})
        aadd(aStru,{"DSCNO1"      ,"N",010,2})
        aadd(aStru,{"DSCNO2"      ,"N",005,2})
        aadd(aStru,{"ACRNO1"      ,"N",010,2})
        aadd(aStru,{"ACRNO2"      ,"N",005,2})
        aadd(aStru,{"ENTPLA"      ,"N",011,2})
        aadd(aStru,{"TIPENT"      ,"C",001,0})
        aadd(aStru,{"TIPPAR"      ,"C",001,0})
        aadd(aStru,{"CONCOR"      ,"C",001,0})
        aadd(aStru,{"COMVEN"      ,"N",005,2})
        aadd(aStru,{"IPINOT"      ,"N",010,2})
        aadd(aStru,{"TIPNOT"      ,"C",001,0})
        aadd(aStru,{"BASI00"      ,"N",012,2})
        aadd(aStru,{"BASI07"      ,"N",012,2})
        aadd(aStru,{"BASI17"      ,"N",012,2})
        aadd(aStru,{"BASI25"      ,"N",012,2})
        aadd(aStru,{"BASI12"      ,"N",012,2})
        aadd(aStru,{"CODUSU"      ,"C",002,0})
        aadd(aStru,{"GERDUP"      ,"L",001,0})
        aadd(aStru,{"NOTIMP"      ,"L",001,0})
        aadd(aStru,{"NFEGERADA"   ,"L",001,0})
        aadd(aStru,{"NFETRANSMI"  ,"L",001,0})
        aadd(aStru,{"NFEIMPRIMI"  ,"L",001,0})
        aadd(aStru,{"NREC"        ,"C",020,0})
        aadd(aStru,{"CSTAT"       ,"C",003,0})
        aadd(aStru,{"XMOTIVO"     ,"C",040,0})
        aadd(aStru,{"CHNFE"       ,"C",044,0})
        aadd(aStru,{"DHRECBTO"    ,"C",040,0})
        aadd(aStru,{"NPROT"       ,"C",040,0})
        aadd(aStru,{"DIGVAL"      ,"C",040,0})
        aadd(aStru,{"ARQUIVO"     ,"C",060,0})
        aadd(aStru,{"NFECA"       ,"L",001,0})
        aadd(aStru,{"NPROTCA"     ,"C",015,0})
        aadd(aStru,{"DHRECBTOCA"  ,"C",010,0})
        aadd(aStru,{"CSTATCA"     ,"C",003,0})
        aadd(aStru,{"XMOTIVOCA"   ,"C",010,0})
        aadd(aStru,{"AUTORIZADO"  ,"L",001,0})
        aadd(aStru,{"SERIE"       ,"C",003,0})
        dbcreate(cDiretorio+"nfeentrada",aStru)
    endif
    return
    
    
static procedure Dbf_Orcamentos
    local aStru := {}
    
    if !file(cDiretorio+"orcamentos.dbf")
        aadd(aStru,{"ID"          ,"C",009,0})
        aadd(aStru,{"CODCLI"      ,"C",004,0})
        aadd(aStru,{"DATA"        ,"D",008,0})
        aadd(aStru,{"CODVEN"      ,"C",002,0})
        aadd(aStru,{"VALDESC"     ,"N",012,2})
        aadd(aStru,{"PERDESC"     ,"N",005,2})
        aadd(aStru,{"ENTRADA"     ,"N",012,2})
        aadd(aStru,{"SUBTOTAL"    ,"N",012,2})
        aadd(aStru,{"TOTAL"       ,"N",012,2})
        aadd(aStru,{"CODPLA"      ,"C",002,0})
        aadd(aStru,{"OBS"         ,"C",050,0})
        aadd(aStru,{"TIPOCOBRA"   ,"C",001,0})
        aadd(aStru,{"NOTAFISCAL"  ,"C",006,0})
        aadd(aStru,{"FLAG"        ,"C",001,0})
        aadd(aStru,{"ABERTO"      ,"C",001,0})
        aadd(aStru,{"LANCXA"      ,"C",006,0})
        aadd(aStru,{"CP_VEN"      ,"N",005,2})
        aadd(aStru,{"CV_VEN"      ,"N",005,2})
        aadd(aStru,{"FATCOM"      ,"N",006,2})
        aadd(aStru,{"FINALIZADO"  ,"L",001,0})
        dbcreate(cDiretorio+"orcamentos",aStru)
    endif
    return
    
// nota fiscal de devolu‡Æo
static procedure Dbf_NfeDev
    local aStru := {}
    
    if !file(cDiretorio+"nfedev.dbf")    
        aadd(aStru,{"NUMCON"      ,"C",010,00})
        aadd(aStru,{"NUMNOT"      ,"C",009,00})
        aadd(aStru,{"SERIE"       ,"C",003,00})
        aadd(aStru,{"CODFOR"      ,"C",004,00})
        aadd(aStru,{"CODNAT"      ,"C",003,00})
        aadd(aStru,{"DTAEMI"      ,"D",008,00})
        aadd(aStru,{"DTASAI"      ,"D",008,00})
        aadd(aStru,{"TPNF"        ,"C",001,00})
        aadd(aStru,{"IDDEST"      ,"C",001,00})
        aadd(aStru,{"VBC"         ,"N",013,02})
        aadd(aStru,{"VICMS"       ,"N",013,02})
        aadd(aStru,{"VICMSDESON"  ,"N",013,02})
        aadd(aStru,{"VBCST"       ,"N",013,02})
        aadd(aStru,{"VST"         ,"N",013,02})
        aadd(aStru,{"VPROD"       ,"N",013,02})
        aadd(aStru,{"VFRETE"      ,"N",013,02})
        aadd(aStru,{"VSEG"        ,"N",013,02})
        aadd(aStru,{"VDESC"       ,"N",013,02})
        aadd(aStru,{"VII"         ,"N",013,02})
        aadd(aStru,{"VIPI"        ,"N",013,02})
        aadd(aStru,{"VPIS"        ,"N",013,02})
        aadd(aStru,{"VCOFINS"     ,"N",013,02})
        aadd(aStru,{"VOUTRO"      ,"N",013,02})
        aadd(aStru,{"VNF"         ,"N",013,02})
        aadd(aStru,{"TIPFRE"      ,"C",001,00})
        aadd(aStru,{"QVOL"        ,"N",015,00})
        aadd(aStru,{"ESP"         ,"C",060,00})
        aadd(aStru,{"MARCA"       ,"C",060,00})
        aadd(aStru,{"NVOL"        ,"C",060,00})
        aadd(aStru,{"PESOL"       ,"N",012,03})
        aadd(aStru,{"PESOB"       ,"N",012,03})
        aadd(aStru,{"CODTRA"      ,"C",002,00})
        aadd(aStru,{"OBSNOT1"     ,"C",090,00})
        aadd(aStru,{"OBSNOT2"     ,"C",090,00})
        aadd(aStru,{"OBSNOT3"     ,"C",090,00})
        aadd(aStru,{"OBSNOT4"     ,"C",090,00})
        aadd(aStru,{"OBSNOT5"     ,"C",090,00})
        aadd(aStru,{"OBSNOT6"     ,"C",090,00})
        aadd(aStru,{"AUTORIZADO"  ,"L",001,00})
        aadd(aStru,{"CANCELADA"   ,"L",001,00})
        aadd(aStru,{"NREC"        ,"C",020,00})
        aadd(aStru,{"CSTAT"       ,"C",003,00})
        aadd(aStru,{"XMOTIVO"     ,"C",040,00})
        aadd(aStru,{"CHNFE"       ,"C",044,00})
        aadd(aStru,{"DHRECBTO"    ,"C",040,00})
        aadd(aStru,{"NPROT"       ,"C",040,00})
        aadd(aStru,{"DIGVAL"      ,"C",040,00})
        aadd(aStru,{"ARQUIVO"     ,"C",060,00})
        aadd(aStru,{"NPROTCA"     ,"C",015,00})
        aadd(aStru,{"DHRECBTOCA"  ,"C",010,00})
        aadd(aStru,{"CSTATCA"     ,"C",003,00})
        aadd(aStru,{"XMOTIVOCA"   ,"C",010,00})
        aadd(aStru,{"CONCLUIDO"   ,"L",001,00})
        dbcreate(cDiretorio+"nfedev",aStru)
    endif
    return

// itens da nota fiscal de devolu‡Æo })   
static procedure Dbf_NfeDevItem       
    local aStru := {}
    
    if !file(cDiretorio+"nfedevitem.dbf")
        aadd(aStru,{"NUMCON"      ,"C",010,00}) 
        aadd(aStru,{"CODPRO"      ,"C",006,00}) 
        aadd(aStru,{"QTDPRO"      ,"N",013,03}) 
        aadd(aStru,{"PCOPRO"      ,"N",013,04}) 
        aadd(aStru,{"PCOLIQ"      ,"N",013,04}) 
        aadd(aStru,{"DSCPRO"      ,"N",005,02}) 
        aadd(aStru,{"FRETE"       ,"N",013,02}) 
        aadd(aStru,{"SEGURO"      ,"N",013,02}) 
        aadd(aStru,{"OUTRO"       ,"N",013,02}) 
        aadd(aStru,{"DESCONTO"    ,"N",013,02}) 
        aadd(aStru,{"TOTPRO"      ,"N",011,02}) 
        aadd(aStru,{"CFOP"        ,"C",004,00}) 
        aadd(aStru,{"CST"         ,"C",003,00}) 
        aadd(aStru,{"MODBC"       ,"C",001,00}) 
        aadd(aStru,{"VBC"         ,"N",013,02}) 
        aadd(aStru,{"PREDBC"      ,"N",008,04}) 
        aadd(aStru,{"PICMS"       ,"N",008,04}) 
        aadd(aStru,{"VICMS"       ,"N",013,02}) 
        aadd(aStru,{"MODBCST"     ,"C",001,00}) 
        aadd(aStru,{"PMVAST"      ,"N",008,04}) 
        aadd(aStru,{"PREDBCST"    ,"N",008,04}) 
        aadd(aStru,{"VBCST"       ,"N",013,02}) 
        aadd(aStru,{"PICMSST"     ,"N",008,04}) 
        aadd(aStru,{"VICMSST"     ,"N",013,02}) 
        aadd(aStru,{"PCREDSN"     ,"N",008,04}) 
        aadd(aStru,{"VCREDICMS"   ,"N",013,02}) 
        aadd(aStru,{"CSTIPI"      ,"C",002,00}) 
        aadd(aStru,{"CENQIPI"     ,"C",003,00}) 
        aadd(aStru,{"BCIPI"       ,"N",013,02}) 
        aadd(aStru,{"PIPI"        ,"N",008,04}) 
        aadd(aStru,{"VIPI"        ,"N",013,02}) 
        aadd(aStru,{"CSTPIS"      ,"C",002,00}) 
        aadd(aStru,{"ALIPIS"      ,"N",005,02}) 
        aadd(aStru,{"CSTCOFINS"   ,"C",002,00}) 
        aadd(aStru,{"ALICOFINS"   ,"N",005,02})
        dbcreate(cDiretorio+"nfedevitem",aStru)
    endif
    return
    
    
    
    
// Fim do arquivo.    



