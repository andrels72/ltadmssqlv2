* PRG......................: IMPACBR
* CLASSE...................: Impressora Fiscal com ACBrMonitor
* DESC.....................: Abre porta, envia comandos, fecha porta
* PREFIXO..................: IBR
* EXPORTADORA..............: IBR_*
* CONSTRUTORA..............: IBR_INIT()
* DESTRUTORA...............: IBR_END()
* AUTOR....................: DANIEL SIMOES DE ALMEIDA
* DATA.....................: JANEIRO DE 2006
* USA......................:
* NOTAS....................: Deve ser compilada com /n uma vez que utiliza
*                            estatica externa. Nao ha construtora.
*                            Trapaceamos e inicializamos com uma estatica
*                            externa!

#include "fileio.ch"
#include "commands.ch"

#define  ETX chr(3)
#define  CR  chr(13)
#define  LF  chr(10)

#define ENT_TXT  'ENT.TXT'
#define SAI_TXT  'SAI.TXT'
#define TMP_TXT  'ENT.TMP'

Static sENDER   := ''  ,;
       SEM_ERRO := .F. ,;
       sSECHORA := 0   ,;
       sRETHORA := ''  ,;
       sSECCOO  := 0   ,;
       sNUMCUPOM:= ''  ,;
       sSECEST  := 0   ,;
       sESTADO  := ''  ,;
       sMODELO  := ''

#ifdef __XHARBOUR__
Static sSOCKET
#endif

************************************************************************
Function IBR_INIT(ENDERECO)   // Abre a comunicação com o ACBrmonitor
* ENDERECO -> Diretorio ( quando usando TXT)  Ex: C:\ACBR\ , ou
*             IP:PORTA  (Socket) Ex: 192.168.0.1:3434
************************************************************************
   Local P, RET := .T., TFIM, IP, PORTA, RESP

   if ! empty(sENDER)  // J  est  aberto...
      return .t.
   endif

   SEM_ERRO := .F.
   sENDER   := alltrim(ENDERECO)
   sMODELO  := ''
   IP       := ''
   PORTA    := 0

   #ifdef __XHARBOUR__
   if ! (PATH_DEL $ sENDER)   /// Abrir comunicacao TCP/IP
      P := at(':',sENDER)
      if P = 0
         P := len(sENDER)+1
      endif

      IP    := substr(sENDER,1,P-1)
      if empty(IP)
         RET := .F.
      else
         PORTA := val(substr(sENDER,P+1))
         if PORTA = 0
            PORTA := 3434
         endif

         inetinit()
         RET := .F.

         TFIM := Seconds() + 5             /// Tenta conectar durante 5 segundos ///
         do while Seconds() < TFIM .and. ! RET
            sSOCKET := inetconnect(IP,PORTA)
            RET     := (ineterrorcode(sSOCKET) = 0)

            millisec(250)
         enddo
      endif

      if RET
         InetSetTimeout( sSOCKET, 3000 )   // Timeout de Recepção 3 seg //
         RESP := InetRecvEndBlock( sSOCKET, ETX )
         RET  := ('ACBrMonitor' $ RESP )   // Recebeu as boas vindas ?
      endif
   endif
   #endif

   if PATH_DEL $ sENDER   /// Abrir comunicacao TXT
      if right(sENDER,1) <> PATH_DEL
         sENDER := sENDER + PATH_DEL
      endif
   endif

   if ! RET
      sENDER := ''
   endif

   return RET

************************************************************************
Function IBR_END()   // Fecha a porta da Impressora
* Encerra a comunicacao com a impressora, nao precisa de parametros
************************************************************************

#ifdef __XHARBOUR__
if ! PATH_DEL $ sENDER   /// Fechar comunicacao TCP/IP
   if ! empty(sENDER)
      inetsendall( sSocket, 'ACBR.bye' )
   endif

   if sSOCKET <> NIL
      inetclose(sSOCKET)
      inetdestroy(sSOCKET)
      inetcleanup()
      millisec(20)
      sSOCKET := NIL
   endif
endif
#endif

sENDER  := ''
sMODELO := ''

return .t.

************************************************************************
Function IBR_ABERTA()   // Retorna .t. se a COM ja est  aberta
************************************************************************

return ! empty(sENDER)

************************************************************************
Function IBR_OK(RESP)   // Retorna .T. se a String inicia com OK:
************************************************************************
   return (substr(RESP,1,3) == 'OK:')

************************************************************************
Function IBR_MODELO()   // Retorna .t. se a COM ja est  aberta
   if empty(sMODELO)
      sMODELO := lower(alltrim(substr(Acbr_Comando('modelo'),4)))
   endif

   return sMODELO

//*****************************************************************************
function Acbr_Ativar  //** Ativa o ECF
   return( IBR_OK(Acbr_Comando('Ativar')))

//*****************************************************************************
Function IBR_ZERA()   // Reseta Impressora em ERRO, Retorna .t. se OK
   return IBR_OK( Acbr_Comando( 'CorrigeEstadoErro', , 40 ))

************************************************************************
Function Acbr_LeituraX()   // Imprime relatorio de Leitura X, retorna .t. se ok
   local lRet,nOpcao

   nOpcao := Aviso_1( 10,, 15,, [Aten‡„o!], [Emitir Leitura X  ?    ], { [ ^Sim ], [ ^Nao ] }, 2, .t. )
   if nOpcao == -27 .or. nOpcao == 2
      return
   end
   Msg(.t.)
   Msg("Aguarde: Emitindo Leitura X")
   lRet := Acbr_Comando("LeituraX",,45)
   Msg(.f.)
   return IBR_OK( lRet)

//*****************************************************************************
Function Acbr_Reducaoz()   // Imprime relatorio de Reducao Z, retorna .t. se ok
   local lRet,nOpcao

   nOpcao := Aviso_1( 10,, 15,, [Aten‡„o!], [Emitir Redu‡Æo Z X  ?    ], { [ ^Sim ], [ ^Nao ] }, 2, .t. )
   if nOpcao == -27 .or. nOpcao == 2
      return
   end
   Msg(.t.)
   Msg("Aguarde: Emitindo Redu‡Æo Z")
   lRet := Acbr_Comando( 'ReducaoZ', {dtoc(date())+' '+time()}, 40 )
   Msg(.f.)
   return IBR_OK(lRet)

//*****************************************************************************
function Acbr_Ativo
   local cRet,lRetorno

   SEM_ERRO := .F.
   cRet    := Acbr_Comando('Ativo')
   if left(cRet,3) == "OK:"
      lRetorno := ("TRUE" $ upper(alltrim(cRet)))
   else
      lRetorno := .f.
   end
   return(lRetorno)


************************************************************************
Function Acbr_Estado()
* Retorna .t. se Iniciou o Fechamento do Cupom e estiver esperando
* Formas de Pagamento
************************************************************************
Local RET

if sSECEST <> seconds()
   RET := Acbr_Comando( 'Estado' )
   if left(RET,3) == 'OK:'
      sESTADO := upper(alltrim(substr(RET,5)))
      sSECEST := seconds()
   else
      sESTADO := ''
   endif
endif

return sESTADO

************************************************************************
Function Acbr_Data()   // Le a Data gravada na Impressora
* Retorna a data da impressora no tipo DATE
************************************************************************
   Local RET

   if sSECHORA <> seconds()
      RET := Acbr_Comando( 'DataHora' )
      if left(RET,3) == 'OK:'
         sRETHORA := RET
         sSECHORA := seconds()
      else
         sRETHORA := ''
      endif
   endif
   return ctod(substr(sRETHORA,5,8))

************************************************************************
Function Acbr_Hora()   // Le a Hora gravada na Impressora
* Retorna uma string com a hora da impressora
************************************************************************
   Local RET

   if sSECHORA <> seconds()
      RET := Acbr_Comando( 'DataHora' )
      if left(RET,3) == 'OK:'
         sRETHORA := RET
         sSECHORA := seconds()
      else
         sRETHORA := ''
      endif
   endif
   return substr(sRETHORA,14,8)
************************************************************************
Function Acbr_NumCupom()   // Le o Numero do ultimo Cupom,
* Retorna string tamanho 6 com o numero do ultimo cupom
************************************************************************
   Local RET

   if sSECCOO <> seconds()
      RET := Acbr_Comando( 'NumCupom' )
      if left(RET,3) == 'OK:'
         sNUMCUPOM := StrZero(val(substr(RET,5)),6)
         sSECCOO   := seconds()
      else
         sNUMCUPOM := '000000'
      endif
   endif
   return sNUMCUPOM

************************************************************************
Function IBR_SUBTOTAL()   // Retorna o Subtotal do cupom aberto
   Local WSTR

   WSTR := substr(Acbr_Comando( 'SubTotal' ),5)
   return val(StrTran(WSTR,',','.'))

************************************************************************
Function IBR_TOTALPAG()   // Retorna o Total de Pagamentos efetuados
   Local WSTR

   WSTR := substr(Acbr_Comando( 'TotalPago' ),5)
   return val(StrTran(WSTR,',','.'))

************************************************************************
Function IBR_NUM_CAIXA()   // Le o Numero do caixa
* Retorna string tamanho 4 com o numero do caixa da impressora,
* geralmente '0001' a nao ser que no estabelecimento existam 2 impressoras
************************************************************************
   Static sNumECF := ''

   if val(sNumECF) = 0
      sNumECF := StrZero(val(substr(Acbr_Comando( 'NumECF' ),5)),4)
   endif
   return sNumECF

************************************************************************
Function Acbr_NumSerie()   // Retorna o Numero de S‚rie da Impressora
************************************************************************
   Static sNumSerie := ''

   if empty(sNumSerie)
      sNumSerie := Alltrim(substr(Acbr_Comando( 'NumSerie' ),5))
   endif
   return sNumSerie

************************************************************************
Function IBR_VERSAO()   // Le o Numero de versao da impressora 4 dig.
************************************************************************
Static sVersao := ''

if empty(sVersao)
   sVersao := Alltrim(substr(Acbr_Comando( 'NumVersao' ),5))
endif

return sVersao

************************************************************************
Function Acbr_PoucoPapel()  // Retorna .t. se for pouco papel
************************************************************************
   return (upper(substr(Acbr_Comando( 'PoucoPapel' ),5,5)) = 'TRUE')

************************************************************************
Function IBR_CUPOM_ABERTO()  // Retorna .t. se cupom estiver aberto
************************************************************************
   return (Acbr_Estado() = 'ESTVENDA')

************************************************************************
Function IBR_PODE_ABRIR()  // Retorna .t. se pode abrir novo cupom
************************************************************************
   return IBR_OK( Acbr_Comando( 'TestaPodeAbrirCupom' ) )

************************************************************************
Function Acbr_AbreCupom(WCGC)   // Abre Cupom Fiscal, Retorna .t. se ok
* Descri‡Æo => WCGC, SE RECEBIDO imprime o CGC do cliente no cabecalho
************************************************************************
   sSECCOO := 0
   return IBR_OK( Acbr_Comando( 'AbreCupom') )

************************************************************************
Function IBR_ACHA_PG(WPAGAMENTO,WVINC)  // Retorna codigo do Totalizador (String 2)
* equivalente a Forma de Pagamento passada se nao encontrar tenta cadastrar
* se conseguir retorna o novo numero, se nao conseguir encontrar nem
* cadastrar retorna "  "
* WPAGAMENTO -> String de 16, com Pagamento a localizar/Cadastra.
* WVINC -> Passado por referencia, Informa.T. se a Forma de Pagamento pode
*          imprimir Cupom Fiscal Vinculado
************************************************************************
Local RET_IMP, RET:=''

SEM_ERRO := .T.
RET_IMP  := Acbr_Comando( 'AchaFPGDescricao',{alltrim(WPAGAMENTO)}, 8 )
SEM_ERRO := .F.
if IBR_OK( RET_IMP )
   RET_IMP := substr(RET_IMP,5)

   if ! empty(RET_IMP)
      RET   := alltrim(substr(RET_IMP,1,4))
      WVINC := (substr(RET_IMP,5,1)<>' ')
   endif
endif

return RET

************************************************************************
Function IBR_ACHA_CNF(WDESCRICAO,WVINC)  // Retorna codigo do CNF
* WDESCRICAO -> String de 16, com CNF a localizar
* WVINC -> Passado por referencia, Informa.T. se a Forma de Pagamento pode
*          imprimir Cupom Fiscal Vinculado
************************************************************************
Static VET_CNF:={}
Local RET_IMP,P,S,RET

if empty(VET_CNF)
   SEM_ERRO := .T.
   RET_IMP := Acbr_Comando( 'ComprovantesNaoFiscais', ,  5 )
   SEM_ERRO := .F.
   if IBR_OK( RET_IMP )
      RET_IMP := substr(RET_IMP,5)

      do while ! empty(RET_IMP)
         P := at('|',RET_IMP)
         if P = 0
            P := len(RET_IMP)+1
         endif

         S := substr(RET_IMP,1,P-1)

         aadd(VET_CNF, {substr(S,1,4), (substr(S,5,1)<>' '), Alltrim(substr(S,6))} )
         RET_IMP := substr(RET_IMP,P+1)
      enddo
   endif
endif

WDESCRICAO := Alltrim(upper(WDESCRICAO))
POS        := ascan(VET_CNF,{|x|upper(x[3])==WDESCRICAO .and. ;
                                iif(IBR_MODELO() == 'ecfschalter',! x[2],.t.) })
WVINC      := .F.
RET        := ''
if POS > 0
   RET   := alltrim(VET_CNF[POS,1])
   WVINC := VET_CNF[POS,2]
endif

return RET

************************************************************************
Function IBR_FECHANDO()
* Retorna .t. se Iniciou o Fechamento do Cupom e estiver esperando
* Formas de Pagamento
************************************************************************
return (Acbr_Estado() = 'ESTPAGAMENTO')

************************************************************************
Function Acbr_SubTotalizaCupom( WDESC_ACRES )
* Inicia FECHAMENTO de Cupom Fiscal com Formas de Pagto, retorna .t. se OK
* WDESC_ACRES -> Numerico, Desconto/Acrescimo em VALOR, concedido para o
*                cliente. Se positivo ACRESCIMO senao DESCONTO
   return IBR_OK( Acbr_Comando( 'SubTotalizaCupom',{WDESC_ACRES}, 5 ))

************************************************************************
Function Acbr_EfetuaPagamento( WVALOR, WCODFPG, WOBS, WVINC )
* Efetua Pagamento em Cupom. Deve ser executada apos IBR_INI_FECHA
* Retorna .t. se OK
* WVALOR -> Valor Numerico pago pela Forma de Pagamento
* WCODFPG -> Codigo da Forma de Pagamento, pode ser achado com IBR_ACHA_PG
* WOBS -> Texto de 80 caracteres para OBS
* WVINC -> Boleano, se .t. ter  Cupom NAO Fiscal vinculado a esta FPG
*          (nao ‚ necess rio na Bematech)
   return IBR_OK( Acbr_Comando( 'EfetuaPagamento',{WCODFPG, WVALOR, WOBS, WVINC}) )

************************************************************************
Function Acbr_FechaCupom( WMSG, WCOLUNAS )
* FECHA Cupom Fiscal, retorna .t. se OK
* WMSG -> String, Mensagem promocional, linhas separadas por '|'
*         checagem de colunas ‚ feita por IMF_FIM_FECHA
* WCOLUNAS -> ajustada por PAI IMF_FIM_FECHA
   sSECCOO := 0
   return IBR_OK( Acbr_Comando( 'FechaCupom',{WMSG}, 20 ) )

************************************************************************
Function Acbr_VendeItem(WCODIGO,WDESCRICAO,WALIQ,WQTD,WVALOR_UNIT,WDESCONTO,WUN)
* Efetua venda de itens no cupom Fiscal, retorna .t. se OK
* WCODIGO -> String, Codigo do produto 13 caracteres
* WDESCRICAO -> String, Descricao do produto 29 caracteres
* WALIQ -> % da aliquita a ser impressa, a rotina acha o totalizador
   * Se a aliquota for numerica, procura o totalizador, senao,
   * usa o propria aliquota que foi passada ('01','02','FF','NN',...)
   * FF - Totalizador de Substituicao Tributaria,
   * II - Totalizador parcial de Isen‡ao
   * NN - Totalizador parcial de NAO incidencia
* WQTD -> Numerico, Quantidade a ser impressa, a rotina ajusta a mascara
* WVALOR_UNIT -> Numerico, Valor Unitario do Produto, a rotina ajusta a mascara
* WDESCONTO -> Numerico, Desconto em % para aplicar, a rotina ajusta a mascara
* WUN - Descricao da unidade (se nulo assume 'UN')
************************************************************************

return IBR_OK( Acbr_Comando( 'VendeItem',{WCODIGO, WDESCRICAO, WALIQ, WQTD,;
                                         WVALOR_UNIT, WDESCONTO, WUN} ) )

************************************************************************
Function IBR_ACHA_ALIQ(WALIQ)  // Retorna codigo do Totalizador (String 2)
* equivalente a WALIQ passada, se nao encontrar volta "  "
* WALIQ -> Numerico, % do ICMS a localizar o Totalizador.
************************************************************************
Static VET_ALIQ
Local POS:=0

if VET_ALIQ = NIL
   VET_ALIQ := IBR_ALIQ()
endif

POS := ascan(VET_ALIQ,{|x|x[1] = WALIQ})

return iif(empty(POS),"  ",VET_ALIQ[POS,2])

************************************************************************
Function IBR_ALIQ()  // Retorna vetor bi-dimensional com os codigos
* das aliquotas no formato {ALIQ(N 5,2),COD_ALIQ(C 2)}
* Fun‡ao de uso interno, pela funcao (IBR_ACHA_ALIQ())
************************************************************************
Local RET_IMP,VET_RET:={},P,S

RET_IMP := Acbr_Comando( 'CarregaAliquotas', , 10 )
if IBR_OK( RET_IMP)
   RET_IMP := substr(RET_IMP,5)

   do while ! empty(RET_IMP)
      P := at('|',RET_IMP)
      if P = 0
         P := len(RET_IMP)+1
      endif

      S := substr(RET_IMP,1,P-1)

      aadd(VET_RET, {val(strtran(substr(S,6,6),',','.')), substr(S,1,4)} )
      RET_IMP := substr(RET_IMP,P+1)
   enddo
endif
return VET_RET

//****************************************************************************
function Acbr_LeituraMemoriaFiscal(aParamentro)
   local nOpcao,lRetorno

   nOpcao := Aviso_1( 14,, 19,, [Aten‡„o!], [Emitir Leitura de Memoria Fiscal  ?    ], { [ ^Sim ], [ ^Nao ] }, 2, .t. )
   if nOpcao == -27 .or. nOpcao == 2
      return
   end
   Msg(.t.)
   Msg("Aguarde: Emitindo Leitura de Memoria Fiscal")
   lRetorno := Acbr_Comando("LeituraMemoriaFiscal",aParamentro)
   Msg(.f.)
   return(NIL)

***********************************************************************
Function Acbr_CancelaCupom()  // Cancela Cupom fiscal, retorna .t. se ok
   local cRet

   Msg(.t.)
   Msg("Aguare: Cancelando o cupom fiscal")
   cRet := Acbr_Comando("CancelaCupom",,14)
   Msg(.f.)
   return IBR_OK( cRet)
************************************************************************
Function Acbr_CancelaItemVendido(WITEM)  // Cancela Item do Cupom fiscal, retona .t. se ok
* WITEM -> Numerico com Codigo sequencial do Item a cancaler
*  Ex.: 1 cancela o primeiro item vendido.
************************************************************************
   return IBR_OK( Acbr_Comando( 'CancelaItemVendido',{WITEM}) )

************************************************************************
Function Acbr_Comando(CMD,VET_PARAM,ESPERA,TENTA)
* Funcao de uso interno para enviar os comandos para a impressora e
* registrar os erros retornados pela mesma. Exibe os erros se existirem
************************************************************************
   Local RET_IMP, REQ, RESP, TEMPOR, TINI, TFIM, BLOCO, BYTES, I, TIPO_PARAM

   if empty(sENDER)
      if ! SEM_ERRO
         Mens({"Aten‡Æo","ACBrMonitor n†o foi inicializado."})
      endif
      return ''
   endif

   DEFAULT VET_PARAM   to {} ,;
            ESPERA      to 0  ,;
            TENTA       to .t.

   ///// Codificando CMD de acordo com o protocolo /////
   RET_IMP  := ''

   if ! ('.' $ left(CMD,5))   // Informou o Objeto no Inicio ?
      CMD := 'ECF.'+CMD       // Se nao informou assume ECF.
   endif

   if len(VET_PARAM) > 0
      CMD := CMD + '(' ;

      For I := 1 to len(VET_PARAM)
        TIPO_PARAM := valtype(VET_PARAM[I])

        if TIPO_PARAM = 'C'
           // Converte aspas para simples para aspas duplas, para o ACBrMonitor
           CMD := CMD + '"'+ StrTran( RTrim(VET_PARAM[I]), '"', '""' ) + '"'

        elseif TIPO_PARAM = 'N'
           CMD := CMD + strtran(alltrim(Str(VET_PARAM[I])),',','.')

        elseif TIPO_PARAM = 'D'
           CMD := CMD + dtoc( VET_PARAM[I] )

        elseif TIPO_PARAM = 'L'
           CMD := CMD + iif( VET_PARAM[I],'TRUE','FALSE')

        endif

        CMD := CMD + ', '
      next

      CMD := substr(CMD,1,len(CMD)-2) + ')'
   endif



   CMD := CMD + CR+LF

   if ! SEM_ERRO
      ESPERA := max(ESPERA,5)
   else
      TENTA := .F.
   endif

   if PATH_DEL $ sENDER               /// E' TXT ? ///
      REQ    := sENDER + ENT_TXT
      RESP   := sENDER + SAI_TXT
      TEMPOR := sENDER + TMP_TXT

      //////// Transmitindo o comando /////////
      TFIM := seconds() + 3    // Tenta apagar a Resposta anterior em ate 3 segundos
      do while file( RESP )
         if ferase( RESP ) = -1
            if (seconds() > TFIM)
               RET_IMP := 'ERRO: Nao foi possivel apagar o arquivo: ('+RESP+') '
            else
               millisec(20)
            endif
         endif
      enddo

      do while empty(RET_IMP)
         TFIM := seconds() + 3    // Tenta apagar a Requisicao anterior em ate 3 segundos
         do while file( REQ )
            if ferase( REQ ) = -1
               if (seconds() > TFIM)
                  RET_IMP := 'ERRO: Nao foi possivel apagar o arquivo: ('+REQ+') '
               else
                  millisec(20)
               endif
            endif
         enddo

         // Criando arquivo TEMPORARIO com a requisicao //
         if empty(RET_IMP)
            if ! Grava_ARQ(TEMPOR, CMD)
               RET_IMP := 'ERRO: Nao foi possivel criar o arquivo: ('+TEMPOR+') '
            endif
         endif

         // Renomeando arquivo TEMPORARIO para REQUISICAO //
         if empty(RET_IMP)
            if frename(TEMPOR, REQ) = -1
               RET_IMP := 'ERRO: Nao foi possivel renomear ('+TEMPOR+') para ('+REQ+') '
            endif
         endif

         // Espera ACBrMonitor apagar o arquivo de Requisicao em ate 7 segundos
         // Isso significa que ele LEU o arquivo de Requisicao
         TFIM := seconds() + 7
         do while empty(RET_IMP) .and. (seconds() <= TFIM) .and. file(REQ)
            millisec(20)
         enddo
         if file(REQ)
            if ! TENTA
               RET_IMP := 'ERRO: ACBrMonitor nao esta ativo'
            else
               if Aviso_1( 10,, 15,, [Aten‡„o!],"O ACBRMonitor nÆo est  ativo|Deseja tentar novamente  ?", { [ ^Sim ], [ ^Nao ] }, 1, .t. ) == 2
                  RET_IMP := 'ERRO: ACBrMonitor nao esta ativo'
               else
                  if ! file(REQ)  // ACBrMonitor "acordou" enquanto perguntava
                     exit
                  endif
               endif
            endif
         else
            exit
         endif
      enddo

      //////// Lendo a resposta ////////
      TINI   := Seconds()
      TELA   := savescreen(23,1,23,78)
      do while empty(RET_IMP)
         if file(RESP)
            RET_IMP := alltrim(memoread( RESP ))
         endif

         if empty(RET_IMP)
            if Seconds() > (TINI + 5)
                @ 24, 2 say pad('Aguardando resposta do ACBrMonitor:  '+; // '('+ProcName(2)+') '+;
                            Trim(str(TINI + ESPERA - seconds(),2)),77)
            endif

            if Seconds() > (TINI + ESPERA)
               restscreen(23,1,23,78,TELA)

               if ! TENTA
                  RET_IMP := 'ERRO: Sem resposta do ACBrMonitor em '+alltrim(str(ESPERA))+;
                             ' segundos (TimeOut)'
               else
                  if Aviso_1( 10,, 15,, [Aten‡„o!],"O ACBRMonitor nÆo est  respondendo|Deseja tentar novamente  ?", { [ ^Sim ], [ ^Nao ] }, 1, .t. ) == 2
                     RET_IMP := 'ERRO: Sem resposta do ACBrMonitor em '+alltrim(str(ESPERA))+;
                                ' segundos (TimeOut)'
                  else
                     TINI := Seconds()
                  endif
               endif
            endif
            millisec(20)
         endif
      enddo
      restscreen(23,1,23,78,TELA)

   //   ferase( strtran(RESP,'.TXT','.OLD') )
   //   frename( RESP, strtran(RESP,'.TXT','.OLD') )
      ferase( RESP )
   #IFDEF __XHARBOUR__

   else                                       //// TCP / IP (apenas xHarbour ) ///
      //////// Transmitindo o comando /////////
      InetSetTimeout( sSOCKET, 3000 )   // Timeout de Envio 3 seg //
      if inetsendall( sSocket, CMD ) <= 0
         RET_IMP := 'ERRO: Nao foi possivel transmitir dados para o ACBrMonitor|'+;
                    '('+AllTrim(Str(InetErrorCode( sSOCKET )))+') '+;
                    InetErrorDesc( sSOCKET ) + ETX
      endif

      //////// Lendo a resposta ////////
      InetSetTimeout( sSOCKET, 500 )
      TINI   := Seconds()
      TELA   := savescreen(23,1,23,78)
      do while (right(RET_IMP,1) <> ETX)
         BLOCO := space(64)

         BYTES   := inetrecv(sSOCKET, @BLOCO, 64)
         RET_IMP += left(BLOCO,BYTES)

         if Seconds() > (TINI + 5)
             @ 23, 2 say pad('Aguardando resposta do ACBrMonitor:  '+; // '('+ProcName(2)+') '+;
                         Trim(str(TINI + ESPERA - seconds(),2)),77) color COR_MENU
         endif
         if Seconds() > (TINI + ESPERA)
            restscreen(23,1,23,78,TELA)
            if ! TENTA
               RET_IMP := 'ERRO: Sem resposta do ACBrMonitor em '+alltrim(str(ESPERA))+;
                          ' segundos (TimeOut)' + ETX
            else
               if Aviso_1( 10,, 15,, [Aten‡„o!],"O ACBRMonitor nÆo est  respondendo|Deseja tentar novamente  ?", { [ ^Sim ], [ ^Nao ] }, 1, .t. ) == 2
                  RET_IMP := 'ERRO: Sem resposta do ACBrMonitor em '+alltrim(str(ESPERA))+;
                             ' segundos (TimeOut)' + ETX
               else
                  TINI := Seconds()
               endif
            endif
         endif
      enddo
      restscreen(23,1,23,78,TELA)
   #ENDIF
   endif

   //if substr(RET_IMP,1,3) <> 'OK:' .or. substr(RET_IMP,1,5) == 'ERRO:'
   //   ALERTA('RETORNO INVALIDO INIFIM|'+RET_IMP+'|'+ alltrim(memoread( RESP )) )
   //endif

   do while right(RET_IMP,1) $ CR+LF+ETX   // Remove sinalizadores do final
      RET_IMP := left(RET_IMP,len(RET_IMP)-1)
   enddo

   if ! SEM_ERRO
      MSG_ERRO := ''
      if substr(RET_IMP,1,5) == 'ERRO:'
         MSG_ERRO := substr(RET_IMP,5)
    //     MSG_ERRO := 'Erro ACBrMonitor|'+;  //  'Rotina ('+ProcName(2)+')|' //+;
    //                 //strtran(strtran( MUDA_ACENTOS(substr(RET_IMP,7)),CR,''),LF,'|')
      endif
      //** Alterado por Andr‚
      if ! empty(MSG_ERRO)
         Mens({"A t e n ‡ Æ o!",trim(MSG_ERRO)})
         //**ALERTA(MSG_ERRO,,,COR_ERRO)
         RET_IMP := ''
      endif
   endif

   //if substr(RET_IMP,1,3) <> 'OK:' .or. substr(RET_IMP,1,5) == 'ERRO:'
   //   ALERTA('RETORNO INVALIDO FIM|'+RET_IMP+'|'+ alltrim(memoread( RESP )) )
   //endif
   return RET_IMP




Static Function Grava_ARQ( WARQ, WTXT )
   Local HANDLE, RET := .T.

   HANDLE := fcreate(WARQ, FC_NORMAL )
   if HANDLE > 0
      fwrite(HANDLE, WTXT + chr(13) + chr(10) )
      RET := (ferror() = 0)
      fclose(HANDLE)
   endif
   RETURN RET

**************************************************************************
Function SEPARA_STR(STR_SEPARA,DELIMITADOR,FECHA_STR,COM_FECHA)
* Retorna vetor com strings separadas entre DELIMITADOR. As strings nao
* incluem o delimitador.
* STR_SEPARA -> String a separar,
* DELIMITADOR -> Caracter que divide a string
* FECHA_STR -> Caracter que fecha abas de uma separacao. Se nulo nao usa.
*               Util para ignorar os DELIMITADORES entre os FECHA_STR
* COM_FECHA -> Logico. Se verdadeiro, inclui as caracteres FECHA_STR na
*              string de retorno.
**************************************************************************
LOCAL PROX_DELIM,VSTR := {},PROX_FECHA,TEXTO

DEFAULT DELIMITADOR to ',',;
        FECHA_STR to '',;
        COM_FECHA to .t.

do while len(STR_SEPARA) > 0
   PROX_FECHA := 1
   if len(FECHA_STR) > 0    // Se possuir FECHA_STR localiza o proximo
      PROX_FECHA := NAT(FECHA_STR,STR_SEPARA,2)
      PROX_FECHA := iif(empty(PROX_FECHA),1,PROX_FECHA)
   endif
****** Acha o proximo delimitador e adiciona o PROX_FECHA (comeco) ******
   PROX_DELIM := at(DELIMITADOR,substr(STR_SEPARA,PROX_FECHA))
   PROX_DELIM := iif(empty(PROX_DELIM),len(STR_SEPARA)+1,PROX_DELIM + PROX_FECHA - 1)
   TEXTO := substr(STR_SEPARA,1,PROX_DELIM - 1)

   if len(FECHA_STR) > 0 .and. ! COM_FECHA   // Verifica se tira os FECHA_STR
      TEXTO := strtran(TEXTO,FECHA_STR)
   endif

   TEXTO := iif(len(TEXTO) = 0,' ',TEXTO)
   aadd(VSTR,TEXTO)
   STR_SEPARA := substr(STR_SEPARA,PROX_DELIM + len(DELIMITADOR))
enddo

return VSTR

************************************************************************
Function NAT(CARACTER,TEXTO,OCORRENCIA) // Retorna a posicao da enesima
*                                          ocorrencia do caracter
* CARACTER - Caracter a ser localizado, TEXTO - Texto a ser pesquisado,
* OCORRENCIA - Numero da ocorrencia dentro do TEXTO, se a OCORRENCIA
* for 0 , retorna o numero de vezes que CARACTER aparace em TEXTO
************************************************************************
LOCAL POSICAO,RESTO,N_ACHADO,TAMTEXT,POSAT

DEFAULT OCORRENCIA to 1

N_ACHADO := 0
TAMTEXT := len(TEXTO)
POSICAO := 1
do while (N_ACHADO < OCORRENCIA) .or. (OCORRENCIA = 0)
   POSAT := at(CARACTER,substr(TEXTO,POSICAO,TAMTEXT))
   if POSAT = 0
      POSICAO := 1
      exit
   endif
   POSICAO += POSAT
   N_ACHADO++
enddo

if empty(OCORRENCIA)
   return N_ACHADO
endif

return POSICAO - 1


