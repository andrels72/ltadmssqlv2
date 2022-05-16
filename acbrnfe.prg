#include "inkey.ch"
#define CRLF chr(K_ENTER)+chr(K_CTRL_ENTER)

procedure ACBR_NFE_LerIni(cDirMonitor)

	cComando := "NFE.LERINI"+CRLF
	memowrit(cDirMonitor+"\entnfe.txt",cComando)
	return
	
	
function AcbrNFe_ImprimirEvento(cDirMonitor,cDirCCe,cChave,nSequencia,nEvento)
	private cCmd,cComando

	if file(cDirMonitor+"\sainfe.txt")
		ferase(cDirMonitor+"\sainfe.txt")
	endif
	cCmd := cDirCCe+"\"+cChave+alltrim(str(nEvento))+alltrim(str(nSequencia,2))+"-procEventoNFE.xml"
	cComando := 'NFE.IMPRIMIREVENTO("&cCmd")'+CRLF
	memowrit(cDirMonitor+"\entnfe.txt",cComando )
	return(.f.)   



procedure AcbrNFe_EnviarEmail(cDirMonitor,cEmailDestino,cArqXML,cEnviaPDF,cAssunto,cEmailsCopias)
	privat cCmd,cComando
	
	if file(cDirMonitor+"\sainfe.txt")
		ferase(cDirMonitor+"\sainfe.txt")
	endif
	cEmailDestino := rtrim(cEmailDestino)
	cArqXML       := cDirMonitor+"\"+cArqXML+"-nfe.xml"
	if cAssunto == NIL
		cCmd := cEmailDestino+[","]+cArqXML+[","]+"1"
	else
		cCmd := cEmailDestino+[","]+cArqXML+[","]+"1"+[","]+rtrim(cAssunto)
	endif
	cComando      := 'NFE.ENVIAREMAIL("&cCmd")'+CRLF
	memowrit(cDirMonitor+"\entnfe.txt",cComando)
	memowrit(cDirMonitor+"\entrada.txt",cComando)	
	return
// *****************************************************************************
function Testa_Internet()
   local cTela := SaveWindow(),pSocket,lNet

   Msg(.t.)
   Msg("Aguarde: Testando conexao com a Internet")
   INetInit()
   lNet    := .T.
   pSocket := INetConnect( "www.google.com.br", 80 )

   If INetErrorCode( pSocket ) <> 0
      Msg(.f.)
      Mens({"Internet Falhou!"})
      lNet := .F.
   else
      Msg(.f.)
   Endif
   INetClose( pSocket )
   INetCleanUp()
   RestWindow(cTela)
   Return ( lNet )
// *****************************************************************************
*-------------------------------------------------*
* Armazena Campo de Retorno SEFAZ em uma Variavel *
*-------------------------------------------------*
function RetornoSEFAZ( xCampo, xArquivo )
	local cArquivo

   nLineLen  := 78
   nTabSize  :=  8
   lWrap     := .T.
   
	cArquivo := memoread(xArquivo)
	nContLin  := MLCount( cArquivo, nLineLen, nTabSize, lWrap )
	xAux      := ""
	nReverse  := nContLin + 1 // Ler Texto de Baixo Para Cima, ( Exatidao, Retornar Campos Corretamente ) )

   For x := 1 To nContLin

       cLin := MemoLine( cArquivo, nLineLen, nReverse -= 1, nTabSize, lWrap )

       If AT( upper(xCampo), upper(cLin) ) > 0

          xAux := SubStr( cLin, Len( xCampo ) + 2,78)  //78 )

          If !Empty( xAux )
              Exit
          Endif

       Endif

  Next

  xCampo := If( !Empty( xAux ), AllTrim( xAux ), "" )

Return ( xCampo )



/*
   Sintaxe: MON_RET(<ExpC1> <,ExpN1>)
   Funcao.: Verifica Retorno do Monitor.
              ExpC1 = Arquivo de Saida/Retorno dos Comandos.
              ExpN1 = Tempo para Tentar LER o Arquivo.
   Local..: Variaveis locais utilizadas.
              cRet = Variavel de Retorno da Mensagem de Leitura ou Erro.
              nSec = Tempo em Segundos (seconds) para tentativa de ACESSO aos Arquivos.
   Retorna: String da Mensagem.
*/
function MON_RET( cDir, cArq, nTmp)
   LOCAL nSec, cRet:="",nContador := 0
   private cComando 

   // Formata os Dados passados.
   if cArq = NIL    // Nao veio Arquivo para LER?
      cArq := ""    // Nao vai LER nenhum Arquivo...
   endif
   if nTmp = NIL   // Nao veio o Tempo para tentar Gravar?
      nTmp := 4   // Entao definimos 10 Segundos como Padrao.
   endif
	do while .t.
		if File( cDir+"\"+cArq )               // Achou o Arquivo de Resposta?
			cRet := memoread( cDir+"\"+cArq )   // Entao vamos Ler o conte£do para a variavel.
			if cRet == ""              // Erro na Leitura do Arquivo?
                cRet := "ERRO: Leitura invalida do Arquivo de Resposta do Monitor."
                if file(cDir+"\entnfe.txt")
                    ferase(cDir+"\entnfe.txt")
                endif
                MemoWrit(cDir+"\sainfe.txt",cRet)
				exit                    // entao prossegue saindo do LOOP com o Erro de Resposta.
			else
				exit
			endif
		else
            My_Wait(nTmp)
            nContador += 1
            if nContador >= 5
                If Aviso_1( 17,, 22,,"Aten‡„o!","FALHA: Arquivo de resporta nÆo encontrado, tentar novamente ?", { [  ^Sim  ], [  ^NÆo  ] }, 1, .t. ) = 1
                    nContador := 0
                else
                    cRet := "ERRO: Arquivo de retorno nao encontrado, isso pode indicar que o ACBRMONITOR NÇO ESTEJA SENDO EXECUTADO"
                    cRet += ", favor executar o ACBRMONITOR OU LIGAR PRA O SUPORTE."
                    if file(cDir+"\entnfe.txt")
                        ferase(cDir+"\entnfe.txt")
                    endif
                    MemoWrit(cDir+"\sainfe.txt",cRet)
                    exit
                endif
            endif
		endif
	enddo
	return cRet
// *********************************************************************************************************
/*
   Sintaxe: MEN_OK_( <ExpC1> )
   Funcao.: Verifica se tudo OK nas Mensagens de Retorno.
              ExpC1 = Mensagem de Retorno para Verificar.
   Retorna: .t. se a String inicia com "OK:".
*/
function MEN_OK( cMen )
   // Testa se a Mensagem passada inicia com "OK:".
return ( substr(cMen, 1, 3) == 'OK:' )

// *********************************************************************************************************
/*
   Sintaxe: MEN_RET(<ExpC1> <,ExpC2>)
   Funcao.: Extrai um Dado na Mensagem de Retorno do Monitor.
              ExpC1 = Indice da Mensagem a Localizar.
              ExpC2 = Dados da Mensagem a Localizar.
   Local..: Variaveis locais utilizadas.
              cMen = Mensagem localizada.
              nLin = Quantidade de Linhas dos Dados da Mensagem a Verificar.
              iLin = Indice de Linhas do comando FOR/NEXT.
   Retorna: String com a Mensagem extraida.
*/
function Men_Ret( cInd, cDad )
   LOCAL cMen, nLin, iLin,nTamLin := 72

   // Conta a Quantidade de Linhas nos dados passados.
   nLin := mlcount(cDad, nTamLin ) //52)
   if nLin = 0     // Nenhuma linha? Entao...
      cMen := ""   // Nao tem nenhum dado a retornar.
   endif
   nReverse := nLin+1  // Ler Texto de Baixo Para Cima, ( Exatidao, Retornar Campos Corretamente ) )

   // Vamos percorrer toda a cadeia de caracteres e localizar o que queremos.
   for iLin := 1 to nLin
      // Extrai uma linha de texto de uma cadeia de caracteres ou campo memo.
      cMen := memoline(cDad, nTamLin, nReverse -= 1, .F.) // **cMen := memoline(cDad, 52, iLin, .F.)

      //if cInd $ cMen               // **Nesta linha contem o Indice que queremos?
      if upper(cInd) $ upper(cMen)   // ** Nesta linha contem o Indice que queremos?
         cMen := rtrim(substr(cMen,len(cInd)+2,len(cMen))) // ** Entao extraimos a Mensagem na Linha apos o "Indice=".
         exit   // E caimos fora...
      endif

      if iLin = nLin   // Chegou no final e nada de achar o que procurava?
         cMen := ""    // Entao, nao tem nenhum dado a retornar.
      endif
   next

return cMen
// *********************************************************************************************************
// ** Novas Funções
// *********************************************************************************************************
procedure AcbrNFe_StatusServico(cDiretorio)
	private cComando
   
	if file(cDiretorio+"\sainfe.txt")
		FErase(cDiretorio+"\sainfe.txt")
	endif
	cComando := ""
	cComando += 'NFe.StatusServico'+CRLF
	MemoWrit(cDiretorio+"\entnfe.txt",cComando )
	return
// *********************************************************************************************************    
procedure AcbrNfe_CertificadoVencimento(cDiretorio)
    private cComando
    
    if file(cDiretorio+"\sainfe.txt")
        ferase(cDiretorio+"\sainfe.txt")
    endif
    cComando := ""
    cComando += 'Nfe.CertificadoDataVencimento'+CRLF
    MemoWrit(cDiretorio+"\entnfe.txt",cComando )
return

procedure AcbrNfe_Versao(cDiretorioNfe)
    private cComando

    if file(cDiretorioNfe+"\sainfe.txt")
        ferase(cDiretorioNfe+"\sainfe.txt")
    endif
    cComando := 'NFe.Versao' // **+ CRLF
	MemoWrit(cDiretorioNFe+"\entnfe.txt",cComando )
return

// *********************************************************************************************************	
procedure AcbrNFe_InutilizarNFe(cDiretorioNFe,cCNPJ,cJustificativa,nAno,nModelo,nSerie,nNumero)
	private cComando,cCmd
	
	nAno    := alltrim(str(nAno,2))
	nModelo := alltrim(str(nModelo,2))
	nSerie  := alltrim(str(nSerie,3))
	nNumero := alltrim(str(nNumero,9))
	
	if file(cDiretorioNFe+"\sainfe.txt")
		ferase(cDiretorioNFe+"\sainfe.txt")
	endif
	cCmd := cCNPJ+[","]+cJustificativa+[",]+nAno+[,]+nModelo+[,]+nSerie+[,]+nNumero+[,]+nNumero
	cComando := 'NFe.InutilizarNFe("&cCmd)' // **+ CRLF
	MemoWrit(cDiretorioNFe+"\entnfe.txt",cComando )
	return
// *********************************************************************************************************
procedure AcbrNFe_CriarNFe(cDiretorio,cDados)
	private cComando
	
	if file(cDiretorio+"\sainfe.txt")
		ferase(cDiretorio+"\sainfe.txt")
	endif
	cComando := cDados
	cArquivo := 'NFe.CriarNFe("&cComando")'
	MemoWrit(cDiretorio+"\entrada.txt",cArquivo)	
	MemoWrit(cDiretorio+"\entnfe.txt",cArquivo)
	return
// *********************************************************************************************************	
procedure AcbrNFe_EnviarEvento(cDiretorio,cDados)
	private cComando
	
	if file(cDiretorio+"\sainfe.txt")
		ferase(cDiretorio+"\sainfe.txt")
	endif
	cComando := cDados
	cArquivo := 'NFe.EnviarEvento("&cComando")'
	memowrit(cDiretorio+"\entrada.txt",cArquivo)
	memowrit(cDiretorio+"\entnfe.txt",cArquivo)
	return
// *********************************************************************************************************	
procedure AcbrNFe_AssinarNFe(cDiretorioNFe,cArquivoXML)
	private cComando,cCmd
	
	if file(cDiretorioNFe+"\sainfe.txt")
		ferase(cDiretorioNFe+"\sainfe.txt")
	endif
	cCmd := cArquivoXML
	cComando := 'NFe.AssinarNFe("&cCmd")' // **+ CRLF
	MemoWrit(cDiretorioNFE+"\entnfe.txt",cComando )
	return
// *********************************************************************************************************	
procedure AcbrNFe_ValidarNFe(cDiretorioNFe,cArquivoXML)
	private cComando,cCmd
	
	if file(cDiretorioNFe+"\sainfe.txt")
		ferase(cDiretorioNFe+"\sainfe.txt")
	endif
	cCmd := cArquivoXML
	cComando := 'NFe.ValidarNFe("&cCmd")' // **+ CRLF
	MemoWrit(cDiretorioNFe+"\entnfe.txt",cComando )
	return
// *********************************************************************************************************
/*
PARAMETROS:
  1 - cDiretorioNFe
  2 - cXML - Caminho do arquivo XML a ser enviado.
  3 - nLote - N£mero do Lote
  4 - bAssina - Coloque 0 se nÆo quiser que o componente assine o arquivo. - Parƒmetro Opcional
  5 - nImprime - Coloque 1 se quiser que o DANFe seja impresso logo ap¢s a autoriza‡Æo - Parƒmetro Opcional
  6 - cImpressora - Informe o nome da impressora - Parƒmetro Opcional
  7 - bSincrono- Coloque 1 para indicar modo s¡ncrono e 0 para modo ass¡ncrono. 
  8 - bValidaXML- Coloque 1 para Validar e 0 para nÆo Validar. - Parƒmetro Opcional
  9 - bGerarNovoXML- Coloque 1 para Gerar um novo XML para envio e 0 para nÆo Gerar. - Parƒmetro Opcional
*/
procedure AcbrNFe_EnviarNFe(cDiretorioNFe,cXML,nLote,nAssina,nImprime,cImpressora,bSincrono,bValidaXML,bGerarNovoXML)
	private cComando,cCmd
	
	nLote    := str(nLote,1)
	nAssina  := str(nAssina,1) 
	nImprime := str(nImprime)
    
	if file(cDiretorioNFe+"\sainfe.txt")
		ferase(cDiretorioNFe+"\sainfe.txt")
	endif
    if valtype(cImpressora) = "U" .and. valtype(bSincrono) = "U"
       cCmd := cXML+[",]+nLote+[,]+nAssina+[,]+nImprime
    else
        cImpressora := "" 
        bSincrono := str(1,1)
        cCmd := cXML+[",]+nLote+[,]+nAssina+[,]+nImprime+[,]+cImpressora+[,]+bSincrono
    endif
	cComando := 'NFe.EnviarNFe("&cCmd)' // **+ CRLF
	MemoWrit(cDiretorioNFe+"\entnfe.txt",cComando )
	return
// **********************************************************************************************************	
procedure AcbrNFe_ImprimirDanfe(cDiretorioNFE,cArquivoXML)

	if file(cDiretorioNFE+"\sainfe.txt")
		ferase(cDiretorioNFE+"\sainfe.txt")
	endif
	cXml := cArquivoXML
	cDnf := 'NFe.ImprimirDanfe("&cXml")' + CRLF
	MemoWrit(cDiretorioNFE+"\entnfe.txt", cDnf )
	MemoWrit(cDiretorioNFE+"\entrada.txt", cDnf )
	Return(.t.)
// **********************************************************************************************************
/*
    AcbrNFe_ConsultarNFe(<cDir>,<xChv>)
*/		
procedure AcbrNFe_ConsultarNFe(cDir,xChv)

   if file(cDir+"\sainfe.txt")
      ferase(cDir+"\sainfe.txt")
   endif
   cXml := xChv
   cDnf := 'NFe.ConsultarNFe("&cXml")' + CRLF
   MemoWrit(cDir+"\entnfe.txt", cDnf )
   Return(.t.)
// *********************************************************************************************************
procedure AcbrNFE_CancelarNFe(cDiretorioNFe,cChave,cJustificativa,cCNPJ,nEvento)
	private cComando,cCmd
	
	if file(cDiretorioNFe+"\sainfe.txt")
		ferase(cDiretorioNFe+"\sainfe.txt")
	endif
	cCmd := cChave+[","]+cJustificativa+[","]+cCNPJ
	cComando := 'NFe.CancelarNFe("&cCmd")' // **+ CRLF
	MemoWrit(cDiretorioNFe+"\entnfe.txt",cComando )
	return
// *********************************************************************************************************
function Status_NFeNFCe(cDirXml)  // ** 
	local cRetorno

	Msg(.t.)
	Msg("Aguarde: Verificando a Comunicacao com a SEFAZ")
	AcbrNFe_StatusServico(rtrim(cDirXml))
	cRetorno := Mon_Ret(rtrim(cDirXml),"sainfe.txt",Sequencia->Tempo)
	if !Men_Ok(cRetorno)
		Msg(.f.)
		LerErro(rtrim(Sequencia->DirNFE),"sainfe.txt")
		return(.f.)
	endif
	Msg(.f.)
return(.t.)
/*
function StatusServico  // ** 
	local cRetorno

	Msg(.t.)
	Msg("Aguarde: Verificando a Comunicacao com a SEFAZ")
	AcbrNFe_StatusServico(rtrim(Sequencia->DirNFE))
	cRetorno := Mon_Ret(rtrim(Sequencia->dirNFE),"sainfe.txt",Sequencia->Tempo)
	if !Men_Ok(cRetorno)
		Msg(.f.)
		LerErro(rtrim(Sequencia->DirNFE),"sainfe.txt")
		return(.f.)
	endif
	Msg(.f.)
	return(.t.)
*/    
   
// *********************************************************************************************************	
procedure LerErro(cDiretorio,cArquivo)
	local cTela := SaveWindow(),cCor
	local cArquivo2,cMsg

	cArquivo2 := memoread(cDiretorio+"\"+cArquivo)
	
	vMsg  := hardcr(cArquivo2)
	cCor   := setcolor()
	cTela := SaveWindow()
	setcolor(Cor(2))
	Window(10,00,20,79," A t e n ‡ Æ o - ERRO ")
	memoedit(cArquivo2,11,01,19,78,.f.)
	setcolor(cCor)
	RestWindow(cTela)
	return

/*
   Sintaxe: MY_WAIT( <ExpC1> )
   Funcao.: Temporizador.
              ExpC1 = Tempo de Espera em Segundos (seconds).
   Retorna: .t. se Ok.
*/
function MY_WAIT( nSec )

   nSec := seconds() + nSec   // (24h * 60m * 60s) = 0 a 86399.
   do while .t.
      if (seconds() > nSec )   // Ja Ultrapassou o Tempo?
         exit                  // Entao Saimos do LOOP.
      endif
   enddo

return .t.	


//********************************************************************************   
/*
    Sintaxe: Assinar_NFeNFCe(<cDirResposta>,<cDirXml>,<cChave> )
    Funcao.: Faz a assinatura do arquivo xml, tanto da nfe como da nfce
        cDirResposta - Diretorio de reposta do acbr
        cDirXml- Diret¢rio de grava‡Æo do xml 
        cChave - Chave da nota para a cria‡Æo do xml
   Retorna: .t. se Ok.
*/
function Assinar_NFeNFCe(cDirResposta,cDirXml,cChave)
    local cRetorno,cArquivoXML
    
	Msg(.t.)
	Msg("Aguarde: Assinando NFE/NFC-e")
    
	cArquivoXML := rtrim(cDirResposta)+'\'+cChave+'-nfe.xml'
	AcbrNFe_AssinarNFe(rtrim(cDirXml),cArquivoXML)
    cRetorno := Mon_Ret(rtrim(cDirXml),"sainfe.txt",Sequencia->Tempo)
	if !Men_Ok(cRetorno)
		Msg(.f.)
		LerErro(rtrim(cDirXml),"sainfe.txt")
		return(.f.)
	endif
	Msg(.f.)
return(.t.)
//********************************************************************************
/*
    Sintaxe: ValidarNFeNFCe(<cDirResposta>,<cDirXml>,<cChave> )
    Funcao.: Faz a valida‡Æo do arquivo xml, tanto da nfe como da nfce
        cDirResposta - Diretorio de reposta do acbr
        cDirXml- Diret¢rio de grava‡Æo do xml 
        cChave - Chave da nota para a cria‡Æo do xml
   Retorna: .t. se Ok.
*/
function Validar_NFeNFCe(cDirResposta,cDirXml,cChave)
	local cRetorno,cArquivoXML
    
    
    cArquivoXML := rtrim(cDirResposta)+'\'+cChave+'-nfe.xml'
    
	Msg(.t.)
	Msg("Aguarde: Validando NFe/NFc-e")
	AcbrNFe_ValidarNFe(rtrim(cDirXml),cArquivoXML)
    cRetorno := Mon_Ret(rtrim(cDirXml),"sainfe.txt",Sequencia->Tempo)
	if !Men_Ok(cRetorno)
		Msg(.f.)
		LerErro(rtrim(cDirXml),"sainfe.txt")			
		return(.f.)
	endif
	Msg(.f.)
return(.t.)
//********************************************************************************
function Cancelar_NFeNFCe(cDirXml,cChave,cMotivo,cCNPJ)
    local cRetorno
    
    Msg(.t.)
	Msg("Aguarde: Cancelando NF-e")
    AcbrNFE_CancelarNFe(rtrim(cDirXml),cChave,rtrim(cMotivo),cCNPJ)
    cRetorno := Mon_Ret(rtrim(cDirXml),"sainfe.txt",Sequencia->Tempo)
	if !Men_Ok(cRetorno)
		Msg(.f.)
		LerErro(rtrim(cDirXml),"sainfe.txt")
        return(.f.)
	endif
    Msg(.f.)
return(.t.)
//********************************************************************************
/*
    Sintaxe: Criar_NFeNFCe(<cDirXml>,<cChave>,<cComando> )
    Funcao.: Faz a valida‡Æo do arquivo xml, tanto da nfe como da nfce
        cDirXml- Diret¢rio de grava‡Æo do xml 
        cChave - Chave da nota para a cria‡Æo do xml - passar por referencia
        cComando - comandos para a cria‡Æo do arquivo .txt da nota
   Retorna: .t. se Ok.
*/

function Criar_NFeNFCe(cDirXml,cChave,cComando)
    local cRetorno
    
    // cChNfe - variavel private declara na rotina que chama essa

    
    Msg(.t.)
	Msg("Aguarde: Criando NFE/NFC-e")
    
	AcbrNFe_CriarNFe(rtrim(cDirXml),cComando)
    
    cRetorno := Mon_Ret(rtrim(cDirXml),"sainfe.txt",Sequencia->Tempo)    
	if !MEN_OK(cRetorno)
		Msg(.f.)
		LerErro(rtrim(cDirXml),"sainfe.txt")
		return(.f.)
	endif
	Msg(.f.)
    cChave := substr(cRetorno,(rat('\',cRetorno)+1),44)
return(.t.)

//********************************************************************************
/*
    Sintaxe: Transmitir_NFeNFCe(<cDirResposta>,<cDirXml>,<cChave> )
    Funcao.: Faz a valida‡Æo do arquivo xml, tanto da nfe como da nfce
        cDirResposta - Diretorio de reposta do acbr
        cDirXml- Diret¢rio de grava‡Æo do xml 
        cChave - Chave da nota para a cria‡Æo do xml
   Retorna: .t. se Ok.
*/
function Transmitir_NFeNFCe(cDirResposta,cDirXml,cChave)
	local cRetorno,cArquivoXML

    // Inicializa variaveis privadas
    cNRec    := "" // número do recibo
    cCStat   := ""
    cXMotivo := "" // 
    cDhRec   := "" // data e hora do recebimento
    cNProt   := "" // número do protocolo
    
    // ** arquivo ja assinado e validado 
    cArquivoXML := rtrim(cDirResposta)+'\'+cChave+'-nfe.xml'    
    
	Msg(.t.)
	Msg("Aguarde: Transmitindo NFe/NFc-e")
    // metodo de transmissÆo assicrono
    AcbrNFe_EnviarNFe(rtrim(cDirXml),cArquivoXML,0,0,0,"",0)
    cRetorno := Mon_Ret(rtrim(cDirXml),"sainfe.txt",Sequencia->Tempo)
	if !Men_Ok(cRetorno)
		Msg(.f.)
		LerErro(rtrim(cDirXml),"sainfe.txt")
		return(.f.)
	else
        cCStat   := RetornoSEFAZ("CStat",rtrim(cDirXml)+"\sainfe.txt")
        cXMotivo := RetornoSEFAZ("XMotivo",rtrim(cDirXml)+"\sainfe.txt") 
		if !(cCStat == "100")
			MostrarErro(cCStat,cXMotivo)
			Msg(.f.)
			return(.f.)
		endif
	endif
	Msg(.f.)
return(.t.)

//********************************************************************************
/*
    Sintaxe: Transmitir_NFeNFCe(<cDirResposta>,<cDirXml>,<cChave> )
    Funcao.: Faz a valida‡Æo do arquivo xml, tanto da nfe como da nfce
        cDirResposta - Diretorio de reposta do acbr
        cDirXml- Diret¢rio de grava‡Æo do xml 
        cChave - Chave da nota para a cria‡Æo do xml
   Retorna: .t. se Ok.
*/
function Consultar_NFeNFCe(cDirXml,cChave)
    local cRetorno
    
	Msg(.t.)
	Msg("Aguarde: Consultando NFe/NFc-e na SEFAZ")
	AcbrNFe_ConsultarNFe(rtrim(cDirXml),cChave)
    cRetorno  := Mon_Ret(rtrim(cDirXml),"sainfe.txt",Sequencia->Tempo)
	if !Men_Ok(cRetorno)
		Msg(.f.)
		LerErro(rtrim(Sequencia->DirNFe),"sainfe.txt")
        return(.f.)
	endif
	Msg(.f.)
return(.t.)

//********************************************************************************
/*
    Sintaxe: Transmitir_NFeNFCe(<cDirResposta>,<cDirXml>,<cChave> )
    Funcao.: faz a impressÆo do DANFE 
        cDirXml- Diret¢rio de grava‡Æo do xml 
        cChave - Chave da nota para a cria‡Æo do xml
   Retorna: .t. se Ok.
*/
function Imprimir_NFeNFCe(cDirXml,cChave)
	
	Msg(.t.)
	Msg("Aguarde: Imprimindo NFe/NFc-e")
	AcbrNFe_ImprimirDanfe(rtrim(cDirXml),rtrim(cDirXml)+'\'+cChave+'-nfe.xml')
    Msg(.f.)
return(.t.)
   








	
// ** Fim do arquivo.