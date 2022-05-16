

function tb_administrativo

    if !schema_Administrativo()
        return(.f.)
    endif

    if !Tb_PwAcesso()
        return(.f.)
    endif
return(.t.)

function schema_Administrativo
    local oQuery

    Msg(.t.)
    Msg("Aguarde: tabela de Acessos")
    if !ExecuteSql("create schema if not exists administrativo AUTHORIZATION postgres;",@oQuery,{"Erro: Criar Tabela PwAcess"},"sqlerro")
        Msg(.f.)
        return(.f.)
    endif
    Msg(.f.)
return(.t.)




function Tb_PwAcesso
    local oQuery,cQuery
    
        cQuery := "CREATE TABLE IF NOT EXISTS administrativo.pwacesso "
        cQuery += "("
        cQuery += "registro CHARACTER(03),"
        cQuery += "rotina CHARACTER(20)"
        cQuery += ");"
        cQuery += " COMMENT ON TABLE pwacesso "
        cQuery += "IS 'Tabela com o codigos dos usuarios e quais sao as rotinas liberadas pra eles'"
        Msg(.t.)
        Msg("Aguarde: tabela de Acessos")
        if !ExecuteSql(cQuery,@oQuery,{"Erro: Criar Tabela PwAcess"},"sqlerro")
            Msg(.f.)
            return(.f.)
        endif
        Msg(.f.)
    return(.t.)

function Tb_PwProcessos
    local oQuery,cQuery
    
        cQuery := "CREATE TABLE IF NOT EXISTS pwprocessos "
        cQuery += "("
        cQuery += "codigo CHARACTER(20),"
        cQuery += "nome CHARACTER(50)"
        cQuery += ");"
        cQuery += " COMMENT ON TABLE pwprocessos"
        cQuery += " IS 'Tabela com as rotinas de acesso a serem liberadas aos usuarios, quando eles tem acesso restrito'"    
        Msg(.t.)
        Msg("Criando a tabela de rotinas")
        if !ExecuteSql(cQuery,@oQuery,{"Erro: Criar Tabela PwProc"},"sqlerro")
            Msg(.f.)
            return(.f.)
        endif
        Msg(.f.)
    return(.t.)


function Tb_PwUsuarios
    local oQuery,cQuery
    
    cQuery := "CREATE TABLE IF NOT EXISTS pwusuarios "
    cQuery += "("
    cQuery += "registro CHARACTER(03),"
    cQuery += "nome CHARACTER(25),"
    cQuery += "nivel CHARACTER(01),"
    cQuery += "senha CHARACTER(10),"
    cQuery += "entrada DATE,"
    cQuery += "saida DATE,"
    cQuery += "bloqueio CHARACTER(01),"
    cQuery += "log CHARACTER(01),"
    cQuery += "abend CHARACTER(01),"
    cQuery += "CONSTRAINT pk_pwusuarios_registro PRIMARY KEY (registro)"
    cQuery += ")"
    Msg(.t.)
    Msg("Aguarde: Criando tabela de Usuÿrios")
    if !ExecuteSql(cQuery,@oQuery,{"Erro: Criar Tabela PwUsuarios"},"sqlerro")
        Msg(.f.)
        return(.f.)
    endif
    Msg(.f.)
return(.t.)

function tb_Empresa
    local cQuery,oQuery

    cQuery := "create table if not exists administrativo.empresa "
    cQuery += "("
    cQuery += "razao CHARACTER(60),"
    cQuery += "endereco CHARACTER(60),"
    cQuery += "numero CHARACTER(06),"
    cQuery += "complend CHARACTER(60),"
    cQuery += "bairro CHARACTER(60),"
    cQuery += "idcidade INTEGER,"
    cQuery += "cidade CHARACTER(40),"
    cQuery += "estcid CHARACTER(2),"
    cQuery += "cep CHARACTER(08),"
    cQuery += "telefone1 CHARACTER(12),"
    cQuery += "telefone2 CHARACTER(12),"
    cQuery += "email CHARACTER(40),"
    cQuery += "cnpj CHARACTER(14),"
    cQuery += "ie CHARACTER(14),"
    cQuery += "im CHARACTER(15),"
    cQuery += "cnae CHARACTER(07),"
    cQuery += "crt CHARACTER(01),"
    cQuery += "fantasia CHARACTER(60)"
    cQuery += ");"
    Msg(.t.)
    Msg("Aguarde: Criando tabela de Empresa")
    if !ExecuteSql(cQuery,@oQuery,{"Erro: Criar Tabela PwUsuarios"},"sqlerro")
        Msg(.f.)
        return(.f.)
    endif
    Msg(.f.)
return(.t.)

