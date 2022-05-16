
procedure CriarTabelas

    if !TabelaDadosEmpresa()
        quit
    endif
    if !TabelaOpeLog()
        quit
    endif
    if !TabelaEstados()
        quit
    endif
    if !TabelaCidades()
        quit
    endif
    if !TabelaPlano()
        quit
    endif
    return
    
function TabelaPwUsuarios                     
    local oQuery,cQuery
    
    cQuery := "create table pwusuarios "
    cQuery += "("
    cQuery += "registro varchar(03),"
    cQuery += "nome varchar(30),"
    cQuery += "nivel varchar(01),"
    cQuery += "senha varchar(10),"
    cQuery += "entrada date,"
    cQuery += "saida date,"
    cQuery += "bloqueio varchar(01),"
    cQuery += "log varchar(01),"
    cQuery += "abend varchar(01),"
    cQuery += "constraint pwusuarios_pk PRIMARY KEY (registro)"
    cQuery += ")"
    Msg(.t.)
    Msg("Aguarde: Criando tabela de Usuÿrios")
    if !ExecuteSql(cQuery,@oQuery,{"Erro: Criar Tabela PwUsuarios"},"pwusuarios")
        Msg(.f.)
        return(.f.)
    endif
    Msg(.f.)
    return(.t.)
    
function TabelaPwAcesso
    local oQuery,cQuery
    
    cQuery := "create table pwacesso "
    cQuery += "("
    cQuery += "registro varchar(03),"
    cQuery += "rotina varchar(20)"
    cQuery += ");"
    cQuery += " COMMENT ON TABLE pwacesso "
    cQuery += "IS 'Tabela com o codigos dos usuarios e quais sao as rotinas liberadas pra eles'"
    Msg(.t.)
    Msg("Aguarde: Criando a tabela de Acessos")
    if !ExecuteSql(cQuery,@oQuery,{"Erro: Criar Tabela PwAcess"},"pwacess")
        Msg(.f.)
        return(.f.)
    endif
    Msg(.f.)
    return(.t.)

function TabelaPwProcessos
    local oQuery,cQuery
    
    cQuery := "create table pwprocessos "
    cQuery += "("
    cQuery += "codigo varchar(20),"
    cQuery += "nome varchar(50)"
    cQuery += ");"
    cQuery += " COMMENT ON TABLE pwprocessos"
    cQuery += " IS 'Tabela com as rotinas de acesso a serem liberadas aos usuarios, quando eles tem acesso restrito'"    
    Msg(.t.)
    Msg("Criando a tabela de rotinas")
    if !ExecuteSql(cQuery,@oQuery,{"Erro: Criar Tabela PwProc"},"PwProc")
        Msg(.f.)
        return(.f.)
    endif
    Msg(.f.)
    return(.t.)
    
function TabelaOpelog
    local oQuery,cQuery
    
    if !oServer:TableExists("opelog")
        Msg(.t.)
        Msg("Criando tabela OPELOG")
        cQuery := "CREATE TABLE opelog "
        cQuery += "(" 
        cQuery += "estlog character(8),"
        cQuery += "datlog date,"
        cQuery += "horlog character(8),"
        cQuery += "codlog character(3),"
        cQuery += "opelog character(25),"
        cQuery += "nivlog character(1),"
        cQuery += "atilog character(200)"
        cQuery += ")"
        if !ExecuteSql(cQuery,@oQuery,{"Erro: Criar Tabela Opelog"},"opelog")        
            Msg(.f.)
            return(.f.)
        endif
        Msg(.f.)
    endif
    return(.t.)
    
    
function TabelaEstados
    local oQuery,cQuery
    
    if !oServer:TableExists("estados")
        cQuery := "create table estados"
        cQuery += "("
        cQuery += "codest character(02),"
        cQuery += "descricao character(35),"
        cQuery += "constraint estados_pk primary key(codest)"
        cQuery += ");"
        cQuery += "create index estados_codest "
        cQuery += "on estados "
        cQuery += "using btree "
        cQuery += "(codest);"
        Msg(.t.)
        Msg("Aguarde: Criando tabela estados")
        if !ExecuteSql(cQuery,@oQuery,{"Erro: Criar Tabela PwProc"},"PwProc")
            Msg(.f.)
            return(.f.)
        endif
        Msg(.f.)
    endif
    return(.t.)
    
function TabelaCidades
    local oQuery,cQuery
    
    if !oServer:TableExists("cidades")
        cQuery := "create sequence cidades_id_seq;"
        cQuery += "create table cidades"
        cQuery += "("
        cQuery += "id integer not null default nextval('cidades_id_seq'),"
        cQuery += "descricao character(40),"
        cQuery += "estado character(02),"
        cQuery += "vlrfrete numeric(15,2),"
        cQuery += "codibge integer,"
        cQuery += "constraint cidades_pk primary key(id)"
        cQuery += "); "
        cQuery += "comment on column cidades.vlrfrete is 'Valor do frete';"
        cQuery += "create index cidades_id "
        cQuery += "on cidades "
        cQuery += "using btree "
        cQuery += "(id);"
        Msg(.t.)
        Msg("Aguarde: Criando tabela cidades")
        if !ExecuteSql(cQuery,@oQuery,{"Erro: Criar Tabela cidades"},"cidades")
            Msg(.f.)
            return(.f.)
        endif
        Msg(.f.)
    endif
    return(.t.)

function TabelaPlano
    local oQuery,cQuery
    
    if !oServer:TableExists("plano")
        cQuery := "create sequence plano_id_seq;"
        cQuery += "create table plano "
        cQuery += "("
        cQuery += "id integer not null default nextval('plano_id_seq'),"
        cQuery += "DESPLA character(30),"
        cQuery += "NUMPAR integer,"
        cQuery += "TOTPAR integer,"
        cQuery += "PRAPAR integer,"
        cQuery += "FATATU numeric(11,04),"
        cQuery += "TIPOPE character(01),"
        cQuery += "PERENT character(01),"
        cQuery += "PRZPRI integer,"
        cQuery += "FATCOM numeric(06,02),"
        cQuery += "constraint plano_pk primary key(id)"
        cQuery += ");"
        cQuery += "comment on column plano.numpar is 'Numero de parcelas';"
        cQuery += "comment on column plano.fatatu is 'Fator de atualizacao';"
        cQuery += "comment on column plano.totpar is 'Total de parcelas';"
        cQuery += "create index plano_id on plano using btree (id);"
        Msg(.t.)
        Msg("Aguarde: Criando tabela plano")
        if !ExecuteSql(cQuery,@oQuery,{"Erro: Criar Tabela plano"},"plano")
            Msg(.f.)
            return(.f.)
        endif
        Msg(.f.)
    endif
    return(.t.)

function TabelaDadosEmpresa
    local oQuery,cQuery
    
    if !oServer:TableExists("dadosempresa")
    
        cQuery := "create table dadosempresa"
        cQuery += "("
        cQuery += "RAZAO character(60),"
        cQuery += "FANTASIA character(60),"
        cQuery += "ENDERECO character(60),"
        cQuery += "NUMERO character(06),"
        cQuery += "COMPLEND  character(60),"
        cQuery += "BAIRRO character(60),"
        cQuery += "idcidade integer,"
        cQuery += "ESTCID character(02),"
        cQuery += "CEP character(08),"
        cQuery += "TELEFONE1 character(12),"
        cQuery += "TELEFONE2 character(12),"
        cQuery += "EMAIL character(40),"
        cQuery += "CNPJ character(14),"
        cQuery += "IE character(14),"
        cQuery += "IM character(15),"
        cQuery += "CNAE character(07),"
        cQuery += "CRT character(01)"
        cQuery += ")"
        Msg(.t.)
        Msg("Aguarde: Criando tabela dadosempresa")
        if !ExecuteSql(cQuery,@oQuery,{"Erro: Criar Tabela dadosempresa"},"dadosempresa")
            Msg(.f.)
            return(.f.)
        endif
        Msg(.f.)
    endif
    return(.t.)





















    
        
// fim do arquivo    