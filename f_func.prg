#include "inkey.ch"
#include "autcaixa.ch"
#define F_BLOCK 134

*-------------
* M¢dulo_____: Funcoes para ECFs
* An lise____: Dino
* Programa‡„o: Dino
* Criado em__: 06/08/2001
*-------------
******* (0) Comandos Relacionados ao Cupom fiscal.
******* (1) Comandos Relacionados com Impressao e Relatorios.
******* (2) Comandos Relacionados com os Estados do ECF.
******* (3) Comandos Relacionados com Parametriza‡oes.
******* (4) Comandos Relacionados com Informa‡oes do ECF.
******* (5) Comandos Relacionados com Informa‡oes do ECF.



Function Abre1(Dados)
Local Buffer:=Space(3),Status:=0,K, Erro:=.f., Tipo, Atv:=.f.
Clear Typeahead
CFErro:=.f.
If Dados=Nil
   Dados:=[]
Endif
I_Print(0, 0,Chr(27)+"1X{")
Inkey(25)
k:=Len(Dados)
Do While k>0
//   Status=wrpdv(tEsc+[2A])
   If Status<>0
*      Clear Typeahead
*      Tipo = Aviso_1( 10,, 15,, [A T E N C A O !], [Impressora n„o responde. Tente novamente?], { [ ^S I M ], [ ^N A O ]  }, 1, .t. )
*      If Tipo=1
*         Atv:=.t.
*         Loop
*      Else
*         Erro:=.t.
*      EndIf
   Else
      If Atv
         Fecha1()
         Return .f.
      EndIf
      Inkey(0.5)
      I_Print(00,0,Left(Dados,48))
   EndIf
   If Erro
      ErroImp:=.t.
      FERASE("Error.txt")
      F1:=FCreate("Error.txt")
      FClose(F1)
     // V_EnviaConf(0,TModulo)
      Return .f.
   EndIf
   If K>48
      Dados:=Substr(Dados,49)
   End
   K-=48
Enddo
Clear Typeahead
Return .t.


Function Fecha1()
Local Buffer:=Space(3),Status:=0
CFErro:=.f.
Do While .t.
//   Status=wrpdv(tEsc+[2A])
   If Status<>0
*      Clear Typeahead
*      If Aviso_1( 15,, 20,, [A t e n ‡ „ o !], "Impressora n„o responde. Tente novamente?", { [ ^Sim ], [ ^N„o ] }, 1, .t. )=1
*         Loop
*      Else
*         FERASE("Error.txt")
*         F1:=FCreate("Error.txt")
*         FClose(F1)
*         V_EnviaConf(0,TModulo)
*         Return .f.
*      EndIf
   EndIf
   I_print(00,00,tEsc+[}])
   I_Print(0, 0,Chr(27)+"1X")
   Exit
EndDo


********************************************
*(0) Comandos Relacionados ao Cupom fiscal.*
********************************************
******* Cancelamento de Itens

Function Cancelamento(tipo,fcodigo,ftipo,fii,fqtd,fdesconto,fvalor)
If C_VSeqImp = 1
i_print(00,00,tEsc+[0CI]+fcodigo+ftipo+fii+fqtd+fdesconto+fvalor)
ret_pa010()
return(stat_op())
ElseIf C_VSeqImp = 2
   If Tipo=[I]
      Bt_CncItem(FCodigo)
   Else
      If Bt_CpAberto()
         I_Print(00,00,[10|0000|00000000000000|A])
      Endif
      I_Print(00,00,[14])
   EndIf
   If Asc(Gstatus)#0
      Return [1]
   Else
      Return [0]
   Endif
Endif


******* Fecha Cupom Fiscal de Venda

Function FechaCupom()
If C_VSeqImp=1
   i_print(00,00,tEsc+[0F])
   ret_pa010()
   return(stat_op())
ElseIf C_VSeqImp=2
*   Return(if(bt_feccup1(),[0],[1]))
Endif

Function bt_FecCup1(ValorP,Recebido,AD,Mensagem)
Local Buffer:='',Status:=0
Buffer+=;
right('0000'+ltrim(str(ValorP*100,4)),4)+;
right('00000000000000'+ltrim(str(Recebido*100,14)),14)+;
AD+;
Mensagem
I_Print(0,0,[10|]+Buffer)
Freads(@Buffer,03,@status)
If status>0
   CFErro:=.t.
   Return .f.
Else
   Return .t.
Endif


***** Registro de Item de Venda

Function RegItem(fcodigo,ftexto,ftipo,fdesconto,fvalor)
priv xvlr1:=StrZero(Fvalor*100,9)
priv xdesc1:=StrZero(FDesconto*100,9)
i_print(00,00,tEsc+[0I]+fcodigo+[ ]+ftexto+chr(13)+ftipo+xdesc1+xvlr1)
*ret_pa010()
*return(stat_op())

Function bt_VendeItem(Dados)
Local Buffer:='',nb,status:=0
CFErro:=.f.
I_Print(0,0,[09|]+Dados)
ComandoOk()
Return 0


****** Forma de Pagamento

function Pagamento(ftipo,fvalor)
i_print(00,00,tEsc+[0P]+strzero(ftipo,1)+chr(13)+chr(13)+strzero(fvalor*100,12))
ret_pa010()
return(stat_op())

****** Total do Cupom de Venda

function TotalCupom()
i_print(00,00,tEsc+[0T])
return(ret_pa010())

****** Abre Cupom Fiscal de Venda

function AbreCupom()
i_print(00,00,tEsc+[0V])
Return


********************************************************
* (1) Comandos Relacionados com Impressao e Relatorios.*
********************************************************

****** Leitura da Memoria Fiscal

FUNCTION LE_MEMFIS(dDtIni,dDtFim)
LOCAL cDtIni:=cDtFim:="",Buffer:=Space(3)
If C_VSeqImp=1
   IF dDtIni==NIL .OR. EMPTY(dDtIni)
      cDtIni:="00000000"
   ELSE
      cDtIni:=DTOS(dDtIni)
   ENDIF
   IF dDtFim==NIL .OR. EMPTY(dDtFim)
      cDtFim:="99999999"
   ELSE
      cDtFim:=DTOS(dDtFim)
   ENDIF
   i_print(0,0,chr(27)+[1L]+dtoc(date())+cDtIni+cDtFim)
   RET_PA010()
   RETURN STAT_OP()
ElseIf C_VSeqImp=2
   IF dDtIni==NIL .OR. EMPTY(dDtIni)
      cDtIni:="010154"
   ELSE
      cDtIni:=DTOC(dDtIni)
      CDtIni:=Left(cDtini,2)+Substr(cDtIni,4,2)+Right(cDtIni,2)
   ENDIF
   IF dDtFim==NIL .OR. EMPTY(dDtFim)
      cDtFim:="311253"
   ELSE
      CDtFim:=Dtoc(dDtaFim)
      CDtFim:=Left(CDtFim,2)+Substr(CDtFim,4,2)+Right(CDtFim,2)
   ENDIF
   I_Print(0,0,[08|]+CDtIni+CDtFim+[I])
   Freads(@Buffer,00,@status)
   If status>0
      CFErro:=.t.
      Return .f.
   Else
      Return .t.
   Endif
Endif

FUNCTION GT_DIA
LOCAL nGt:=0.00,nGtAnt:=0.00,CFeRRO:=.F.
If C_VSeqImp=1
   nGt=VAL(LdTotalizador("01"))/100
   IF !(STAT_OP() $ "03")
      Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "Erro de Leitura do GT. Codigo de erro ( "+STAT_OP()+" )", { [  ^Ok!  ] }, 1, .t., .t. )
   ENDIF
   nGtAnt=VAL(LdTotalizador("09"))/100
   IF !(STAT_OP() $ "03")
      Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "Erro de Leitura do GT DIA ANTERIOR. Codigo de erro ( "+STAT_OP()+" )", { [  ^Ok!  ] }, 1, .t., .t. )
   ENDIF
   RETURN(nGt-nGtAnt)
ElseIf C_VSeqImp=2
*   nGtANT=bt_Gta()
*   If CFErro
*      Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "Erro de Leitura do GT DIA ANTERIOR.", { [  ^Ok!  ] }, 1, .t., .t. )
*      Return 0
*   EndIf
   ngt=bt_Gt()
   If CFErro
      Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "Erro de Leitura do GT.", { [  ^Ok!  ] }, 1, .t., .t. )
      Return 0
   EndIf
*   Return(ngt-ngtant)
   Return(ngt)
EndIf

FUNCTION RODAPE_FISCAL(cTpDesc,nPercVlr)
If C_VSeqImp=1
   i_print(0,0,chr(27)+[01]+cTpDesc)
   IF cTpDesc # "S"
      i_print(0,0,STRZERO(INT(nPercVlr*100),IF(cTpDesc = "P",4,9)))
   ENDIF
   RET_PA010()
   RETURN STAT_OP()
ElseIf C_VSeqImp=2
   Return Nil
Endif


FUNCTION LE_TOTALIZADOR(TOTALIZADOR,ADICIONA,Nome)
Local Vart:={},MNome:=Pad(Nome,19),i,Novo,Valor:=0
IF ADICIONA == NIL
   ADICIONA = .F.
ENDIF
If C_VSeqImp=1
   i_print(0,0,chr(27)+[02]+TOTALIZADOR+"NN"+IF(ADICIONA,"S","N")+"N")
   RETURN RET_PA010()
ElseIf C_VSeqImp=2
   Bt_DesTot(@VarT)
   If Adiciona
      Novo:=.t.
      For i=1 to Len(VarT)
          If At(MNome,Vart[i])
             Novo:=.f.
             Exit
          Endif
      Next
      If Novo
         bt_Inseret(Totalizador,Nome)
      Endif
   Endif
   Bt_Lertt(Totalizador,@Valor)
   Return Valor
EndIf

FUNCTION DTPDV()
LOCAL dDtPdv := CTOD("")
If C_VSeqImp=1
   SET DATE JAPAN
   dDtPdv:=CTOD(TRANS(ALLTRIM(LE_TOTALIZADOR("24",.F.)),"@R 9999/99/99"))
   SET DATE BRITISH
   RETURN dDtPdv
ElseIf C_VSeqImp=2
   Return Bt_Data()
Endif

FUNCTION NEWDTPDV()
LOCAL dDtPdv := CTOD("")
If C_VSeqImp=1
   SET DATE JAPAN
   dDtPdv:=CTOD(TRANS(ALLTRIM(LdData([24])),"@R 9999/99/99"))
   SET DATE BRITISH
   RETURN dDtPdv
ElseIf C_VSeqImp=2
   Return Bt_DataMov()
Endif
   
FUNCTION NUM_CUPOM()
LOCAL cRetCod := ""
If C_VSeqImp=1
   I_Print(00,00,tEsc+[4t003])
   Return(ret_pa010())
ElseIf C_VSeqImp=2
   Do While .t.
      Bt_NumCup(@CRetCod)
      ComandoOk()
      If Val(CretCod)>0
         Exit
      Endif
      TInkey(0.5)
   EndDo
   Return CretCod
ElseIf C_VSeqImp=3
   MNumCup:=StrZero(Val(Imp_Z(Chr(27)+'.271}',.t.,14,4))+1,6)
   Return MNumCup
ElseIf C_VSeqImp=4
//**   Vet:=StatusCup()
   NC:=StrZero(Vet[4],6)
   Return NC
Else
   MNumCup:=[999999]
   Return MNumCup
EndIf

FUNCTION IMP_REGISTER(cEdicao)
i_print(0,0,chr(27)+[10S]+cEdicao)
RET_PA010()
RETURN STAT_OP()

FUNCTION PARM_ALIQPDV(cLeEscreve,nIcms,nAliq)
Local Aliq:={},i:=0,Existe:=.f.
If C_VSeqImp=1
   i_print(0,0,chr(27)+[0P]+cLeEscreve+STRZERO(nIcms,2))
   IF cLeEscreve == "E"
      i_print(0,0,STRZERO(nAliq*100,4))
   ENDIF
   IF cLeEscreve == "L"
      RETURN RET_PA010()
   ELSE
      RET_PA010()
      RETURN STAT_OP()              // Chama rotina que apenas retorna status
   ENDIF
ElseIf C_VSeqImp=2
   Bt_LeAliq(@Aliq)
   If CLeEscreve =='E'
      For i:=1 to Len(Aliq)
          If Aliq[i]=nAliq
             Existe:=.t.
          Endif
      Next
      If (Nicms)>Len(Aliq) .and. !Existe
         Bt_AddAliq(nAliq)
      Endif
   Else
      If NIcms>Len(Aliq)
         Return -1
      Else
         Return Aliq[Nicms]
      Endif
   Endif
Endif

FUNCTION PARM_NUMPDV(cLeEscreve,xNumPdv)
If C_VSeqImp=1
   i_print(0,0,chr(27)+[0P]+cLeEscreve+[12])
   if cLeEscreve == "E"
      i_print(0,0,xNumPdv)
   endif
   IF cLeEscreve == "L"
      RETURN RET_PA010()
   ELSE
      RET_PA010()
      RETURN STAT_OP()
   ENDIF
ElseIf C_VSeqImp=2
   If CleEscreve=='L'
      Return(Bt_NSerie())
   Endif
Endif

FUNCTION PARM_TOBUF(cCodPar,cnValor)
If C_VSeqImp=1
   i_print(0,0,chr(27)+[B]+cCodPar+IF(VALTYPE(cnValor)=="N",STRZERO(cnValor,2),cnValor))
Endif
RETURN "0"

FUNCTION PARM_CLICH(cCodOpr,nIndPar,cString)
Local Atual:=''
If C_VSeqImp=1
   * --- Se Mensagem do Cliche ...
   IF nIndPar > 6 .AND. nIndPar < 9
      cString := PADC(ALLTRIM(cString),nTAMMSG)
   ENDIF
   i_print(0,0,chr(27)+[0C]+cCodOpr+STR(nIndPar,1))
   IF cCodOpr == "E"                   // Se Operacao de Escrita ...
      i_print(0,0,STRZERO(LEN(cString),2)+cString)
   ENDIF
   IF cCodOpr == "L"
      RETURN RET_PA010()                  // Retorna Parametro Solicitado
   ELSE
      RET_PA010()                         // Escreve o Parametro
      RETURN STAT_OP()                    // Retorna Status
   ENDIF
ElseIf C_VSeqImp=2
   Atual:=Bt_Cliche()
   If CCodOpr=[L]
      Return Atual
   Endif
   Return Nil
Endif

Function EVlrSIcms(tipo,vlr,Nome)
priv xvlr1:=strzero(vlr*100,9)
If C_VSeqImp=1
   i_print(00,00,tEsc+[7I]+tipo+xvlr1)
   ret_pa010()
   return(stat_op())
Endif

Function Via(Mod,Tit,Linhas)
If Mod=1
   If C_VSeqImp=1
      I_print(00,00,tEsc+[7V]+Tit+Chr(13)+Linhas+"}")
      ret_pa010()
      return(stat_op())
   Endif
Else
   If C_VSeqImp=1
      I_print(00,00,tEsc+[7v])
      ret_pa010()
      return(stat_op())
   Endif
EndIf

FUNCTION IMP_CLICHE()
If C_VSeqImp=1
   i_print(0,0,chr(27)+[1C])
   RET_PA010()
   RETURN STAT_OP()
ElseIf C_VSeqImp=2
   Return Nil
Endif

FUNCTION CLICHE_NFISCL()
If C_VSeqImp=1
   i_print(0,0,chr(27)+[1C])
   RET_PA010()
   RETURN STAT_OP()                    // Retorna Status
Endif

FUNCTION CLICHE_FISCAL()
If C_VSeqImp=1
   i_print(0,0,chr(27)+[1F]+tEsc)
   RET_PA010()
   RETURN STAT_OP()                    // Retorna Status
Endif

FUNCTION ABRE_CX(dDtAbert)
If C_VSeqImp=1
   i_print(0,0,chr(27)+[09]+STR(YEAR(dDtAbert),4)+STRZERO(MONTH(dDtAbert),2)+STRZERO(DAY(dDtAbert),2))
   RET_PA010()
   RETURN STAT_OP()
EndIf

Function Troca_Bobina()
Local cStPri := STPRIOR()
If cStPri == "1"
   Aviso_1( 13,, 18,, [A t e n ‡ „ o !], [   Caixa est  fechado.  ], { [  ^Ok!  ] }, 1, .t., .t. )
   Return
EndIf
//** If Permissao([Troca de Bobina])=.f.
//**   Return .f.
//** EndIf
DO WHILE .T.
   If Aviso_1( 15,, 20,, [A t e n ‡ „ o !], "Confirma Troca de Bobina?", { [ ^Sim ], [ ^N„o ] }, 1, .t. )=2
      Loop
   EndIf
   If Lastkey()=27
      Exit
   EndIf
   ESPapel([E])
   If C_VSeqImp=1
      Salta_Picote()
   Endif
   DO WHILE Aviso_1( 15,, 20,, [A t e n ‡ „ o !], "Certifique-se de Que Ha Uma Nova Bobina na Impressora. Confirma Troca ?", { [ ^Sim ], [ ^N„o ] }, 1, .t. )=2
   ENDDO
   While .t.
      If C_VSeqImp=1
         I_print(0,0,chr(27)+[O]+chr(27)+[E])
         If pa010_ret() $ [12]
            Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "Impressora Ainda Est  Sem Papel. Verifique", { [  ^Ok!  ] }, 1, .t., .t. )
            Loop
         EndIf
      ElseIf C_VSeqImp=2
         If bt_FimPapel() .or. Bt_Papel()
            Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "Impressora Ainda Est  Sem Papel. Verifique", { [  ^Ok!  ] }, 1, .t., .t. )
            Loop
         EndIf
      ElseIf C_VSeqImp=3
         Leitura_X()
      ElseIf C_VSeqImp=4
         Leitura_X()
      Endif
      Exit
   End
   ESPapel([S])
   If C_VSeqImp=1
      Salta_Picote()
   Endif
   EXIT
EndDo
Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ FUNCTION CMOS_ALOC                                                    ³
³ ==================                                                    ³
³                                                                       ³
³ Objetivo  : Alocar variavel na Memoria CMOS                           ³
³ Parametros: cAreaCmos - Nome da Area                                  ³
³             nTamArea  - Tamanho da Area                               ³
³                                                                       ³
³ Retorna...: Status da Operacao                                        ³
³                                                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

FUNCTION CMOS_ALOC(cAreaCmos,nTamArea,Valor)
If C_VSeqImp=1
   i_print(0,0,chr(27)+[ZA]+left(cAreaCmos,5)+STRZERO(nTamArea,5))
   RET_PA010()
   RETURN STAT_OP()
ElseIf C_VSeqImp=2
   Bt_nomeiat(nTamArea,CAreaCmos)
   If !CFerro
      Bt_Inseret(nTamArea,Valor)
   Endif
Endif
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ FUNCTION FREE_CMOS                                                    ³
³ ==================                                                    ³
³                                                                       ³
³ Objetivo  : Liberar CMOS alocada                                      ³
³ Parametros: cAreaCmos - Nome da Area                                  ³
³                                                                       ³
³ Retorna...: Status da Operacao                                        ³
³                                                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

FUNCTION FREE_CMOS(cAreaCmos)
If C_VSeqImp=1
   i_print(0,0,chr(27)+[ZD]+left(cAreaCmos,5))
   RET_PA010()
   RETURN STAT_OP()
elseIf C_VSeqImp=2
   return [0]
endif

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ FUNCTION CMOS_WRITE                                                   ³
³ ===================                                                   ³
³                                                                       ³
³ Objetivo  : Escrever na CMOS                                          ³
³ Parametros: cAreaCmos - Nome da Area                                  ³
³             nOffSet   - Deslocamento na CMOS                          ³
³             cString   - String a Gravar                               ³
³                                                                       ³
³ Retorna...: Status da Operacao                                        ³
³                                                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

FUNCTION CMOS_WRITE(cAreaCmos,nOffSet,cString)
LOCAL cOffSet := "00000",cor
Private Var:='K_'+cAreaCmos
If C_VSeqImp=1
   IF nOffSet # NIL
      cOffSet := STRZERO(nOffSet,5)
   ENDIF
   i_print(0,0,chr(27)+[ZE]+left(cAreaCmos,5)+cOffSet+STRZERO(LEN(cString),5)+cString)
   RET_PA010()
   RETURN STAT_OP()
Elseif C_VSeqImp=2
   If Noffset>0
      &Var.+=Cstring
   Else
      &Var.=Cstring
   Endif
   Cor:=Setcolor([G+*])
   @ 22, 64 Say [Cmos]
   Save to c:\cmos\CMOS ALL LIKE K_*
   @ 22, 64 Say [    ]
   SetColor(Cor)
   Return 0
Endif
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ FUNCTION INIT_CMOS                                                    ³
³ ==================                                                    ³
³                                                                       ³
³ Objetivo  : Inicializar CMOS                                          ³
³ Parametros: Nil (Void)                                                ³
³                                                                       ³
³ Retorna...: Status da Operacao                                        ³
³                                                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

FUNCTION INIT_CMOS()
If C_VSeqImp=1
   i_print(0,0,chr(27)+[ZC])
   RET_PA010()
   RETURN STAT_OP()
Elseif C_VSeqImp=2
   Begin Sequence
      K_OPEAT=0
      K_STPDV=[0]
      K_STPRG=[M]
      K_TPVDA=0
      K_ITVDA=0
      K_ERROG=[0]
      K_CUPOM=0
      K_TCPOM=0
      K_ANTES=0
      K_ITENS={}
   END SEQUENCE
   Return [0]
Endif

Function InitKVar(Variavel)
Local Valor
Private Var1
If Variavel='K_OPEAT'
   Valor:=0
ElseIf Variavel='K_STPDV'
   Valor:=[0]
ElseIf Variavel='K_OPEAT'
   Valor:=0
ElseIf Variavel='K_STPDV'
   Valor:=[0]
ElseIf Variavel='K_STPRG'
   Valor:=[M]
ElseIf Variavel='K_TPVDA'
   Valor:=0
ElseIf Variavel='K_ITVDA'
   Valor:=[0000]
ElseIf Variavel='K_ERROG'
   Valor:=[0]
ElseIf Variavel='K_CUPOM'
   Valor:=0
ElseIf Variavel='K_TCPOM'
   Valor:=0
ElseIf Variavel='K_ANTES'
   Valor:=0
ElseIf Variavel='K_ITENS'
   Valor:={}
EndIf
Var1:=Variavel
&Var1.:=Valor
Save All Like K_* to c:\cmos\CMOS
Return .t.
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ FUNCTION CMOS_READ                                                    ³
³ ==================                                                    ³
³                                                                       ³
³ Objetivo  : Ler area da CMOS                                          ³
³ Parametros: cAreaCmos - Nome da area a ser lida                       ³
³             nOffSet   - Deslocamento na area                          ³
³             nTamStr   - Tamanho a ser lido                            ³
³                                                                       ³
³ Retorna...: Status da Operacao                                        ³
³                                                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

FUNCTION CMOS_READ(cAreaCmos,nOffSet,nTamStr)
LOCAL cString := "",cOffSet := "00000"
Private Var
If C_VSeqImp=1
   IF nOffSet # NIL
      cOffSet := STRZERO(nOffSet,5)
   ENDIF
   i_print(0,0,chr(27)+[ZL]+left(cAreaCmos,5)+cOffSet+strzero(nTamStr,5))
   cString:=RET_PA010()
   IF STAT_OP()#"0"
      RETURN ""
   ELSE
      RETURN LEFT(cString,nTamStr)
   ENDIF
ElseIf C_VSeqImp=2
   Var:='K_'+cAreaCmos
   If type(VAR)=[U]
      Public &Var.
      InitKvar(Var)
   Endif
   Return &Var.
Endif

****** Inicializa o PDV

FUNCTION INI_PDV
LOCAL cStPri := STPRIOR(),Aaux:={},ni:=0,aStatus1,aStatus2:={},AStatus:={}
If Tok
If C_VSeqImp=1
   cNUMPDV:=LDSerie()
   cStPri := STPRIOR()
   DO CASE
      CASE cStPri == "0"   // PDV Aberto
           dDTCAIXA := newdtpdv()
      CASE cStPri == "1"   // PDV Fechado
           RESTORE SCREEN
           Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "Caixa est  fechado. Fa‡a a Abertura do Caixa", { [  ^Ok!  ] }, 1, .t., .t. )
      CASE cStPri == "2"   // Erro de Check-Sum
           IF ERR_CKSM()
              RESTORE SCREEN
              DO WHILE .T.
                 Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "Erro CHECK-SUM de mem¢ria;Chame a Manuten‡„o", { [  ^Ok!  ] }, 1, .t., .t. )
              ENDDO
           ENDIF
      CASE cStPri == "3"   // Fim de Papel
      CASE cStPri == "4"   // Intervencao Tecnica
           RESTORE SCREEN
           DO WHILE .T.
              Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "PDV em Interven‡„o T‚cnica;CHAMAR MANUTEN€O", { [  ^Ok!  ] }, 1, .t., .t. )
           ENDDO
      CASE cStPri == "6"   // Estouro da EPROM Fiscal
           RESTORE SCREEN
           DO WHILE .T.
              Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "Mem¢ria Fiscal Cheia ou N„o Inicializada;CHAMAR MANUTEN€O", { [  ^Ok!  ] }, 1, .t., .t. )
           ENDDO
      CASE cStPri == "8"   // Eprom NAO Inicializada
           RESTORE SCREEN
           DO WHILE .T.
              Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "Mem¢ria Fiscal com problema ou N„o Inicializada;CHAMAR MANUTEN€O", { [  ^Ok!  ] }, 1, .t., .t. )
           ENDDO
   ENDCASE
ElseIf C_VSeqImp=2
   A=Bt_Nserie2(@CNUMPDV)
   If cNUMPDV==Space(15)
      TOk:=.f.
      Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "Problemas de Comunica‡„o", { [  ^Ok!  ] }, 1, .t., .t. )
      Return .t.
   Else
      @23,0 Say  "Inicializando Caixa ["+CNumPdv+"]"
   Endif
   BT_Status(Astatus1,Astatus2)
   AStatus:=Bt_Flag()
   DO CASE
      CASE !Astatus[4]
           dDTCAIXA := newdtpdv()
      CASE Astatus[4]
           RESTORE SCREEN
           Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "Caixa est  fechado.;Fa‡a a Abertura do Caixa", { [  ^Ok!  ] }, 1, .t., .t. )
      CASE aStatus2[6]
           RESTORE SCREEN
           DO WHILE .T.
              Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "Erro CHECK-SUM de mem¢ria;Chame a Manuten‡„o", { [  ^Ok!  ] }, 1, .t., .t. )
           ENDDO
      CASE Astatus1[8]
           RESTORE SCREEN
           DO WHILE .T.
              Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "Fim do Papel;Troque A Bobina", { [  ^Ok!  ] }, 1, .t., .t. )
           ENDDO
      CASE Bt_FlagIt()
           RESTORE SCREEN
           DO WHILE .T.
              Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "PDV em Interven‡„o T‚cnica;CHAMAR MANUTEN€O", { [  ^Ok!  ] }, 1, .t., .t. )
           ENDDO
      CASE AStatus[8]
           RESTORE SCREEN
           DO WHILE .T.
              Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "Mem¢ria Fiscal Cheia ou N„o Inicializada;CHAMAR MANUTEN€O", { [  ^Ok!  ] }, 1, .t., .t. )
           ENDDO
   ENDCASE
Endif
Endif
RETURN .T.


****** Imprime caracteres Customizados na Impressora

FUNCTION PROG_ALTERNAT(cCharSet)
If C_VSeqImp=1
   i_print(0,0,chr(27)+[SPA010]+chr(27)+[P]+cCharSet)
Endif
RETURN NIL


FUNCTION AVANCA_BOB()
If C_VSeqImp=1
   i_print(00,00,chr(10))
ElseIf C_VSeqImp=2
   i_print(00,00,chr(10))
ElseIf C_VSeqImp=3
   Imp_Z(tEsc+'.54}',.f.)
ElseIf C_VSeqImp=4
   //** LineFeed(1,1)
Endif
RETURN NIL

FUNCTION D_PRINT(nLin,nCol,xVar,cPict,lCenter)
return .t.
* --- Testa Parametro de Centralizacao
IF lCenter != NIL
   IF lCenter
      nCol := (40-LEN(TRANSF(xVar,cPict))) / 2 + 1
   ENDIF
ENDIF
i_print(0,0,chr(27)+[D]+chr(27)+[Y]+STRZERO(++nLin,2)+STRZERO(++nCol,2)+transform(xVar,cPict)+chr(27)+[Q])
RETURN .T.

FUNCTION D_LIMPA
LOCAL cCorAnt := SETCOLOR()
SETCOLOR(cCorAnt)
RETURN .T.

FUNCTION AUTENT(cString)
If C_VSeqImp=1
   i_print(0,0,chr(27)+[V]+cString+chr(13))
   RET_PA010()
   RETURN STAT_OP()
ElseIf C_VSeqImp=2
   Bt_Autentica()
Endif

FUNCTION SIMB_ALTER(cChar1,cChar2)
If C_VSeqImp=1
   RETURN CHR(27)+"U"+IF(EMPTY(cChar1),"",cChar1)+IF(EMPTY(cChar2),"",cChar2)+CHR(27)+"U"
ElseIf C_VSeqImp=2
   Return ''
Endif

Function AbreGave()
Local Usuario:=[]
If C_VHabGav = .f.
   Return .f.
EndIf
If C_VGavSen
   //** If !Permissao([Abrir Gaveta],@USUARIO)
   //**   Return(.f.)
   //** EndIf
EndIf
If C_VSeqImp=1
   I_Print(0,0,Chr(27)+[K])
ElseIf C_VSeqImp=2
   bt_AbreGaveta()
ElseIf C_VSeqImp=3
   Imp_Z(tEsc+'.21}',.f.)
Endif
Grava_Log( [Abertura da Gaveta por: ] + Usuario )
Return(.t.)

Function AbreGave2()
If C_VHabGav = .f.
   Return .f.
EndIf
If C_VSeqImp=1
   I_Print(0,0,Chr(27)+[K])
ElseIf C_VSeqImp=2
   bt_AbreGaveta()
ElseIf C_VSeqImp=3
   Imp_Z(tEsc+'.21}',.f.)
Endif
Return(.t.)

FUNCTION FECHA_GAVETA()
LOCAL cTlLimpa:=SAVESCREEN(00,00,24,79)
If !C_VHabGav
   Return .t.
Endif
If C_VSeqImp=1
   IF STAT_GAVETA() == "1"
      MSGBOX("Gaveta esta aberta.;;Feche-a !")
   ENDIF
   DO WHILE STAT_GAVETA()=="1"
      tinkey(1)
   ENDDO
   RESTSCREEN(00,00,24,79,cTlLimpa)
ElseIf C_VSeqImp=2
   IF !bt_GavAberta()
      MSGBOX("Gaveta esta aberta.;;Feche-a !")
      DO WHILE !bt_GavAberta()
         tinkey(1)
      ENDDO
   EndIf
   RESTSCREEN(00,00,24,79,cTlLimpa)
   return .t.
ElseIf C_VSeqImp=3
*   IF Imp_Z(tEsc+'.22}',.t.,6,1)<>"0"
*      MSGBOX("Gaveta esta aberta.;;Feche-a !")
*      DO WHILE Imp_Z(tEsc+'.22}',.t.,6,1)<>"0"
*         TInkey(1)
*      ENDDO
*   EndIf
*   RESTSCREEN(00,00,24,79,cTlLimpa)
   Return .t.
Endif
RETURN NIL


****** Verificar se Status da Gaveta do PDV

FUNCTION STAT_GAVETA
If !ComGav
   Return .T.
Endif
If C_VSeqImp=1
   i_print(0,0,chr(27)+[G])
   RET_PA010()
   RETURN STAT_OP()
ElseIf C_VSeqImp=2
   Return Bt_GavAberta()
Endif

FUNCTION STAT_IMP
LOCAL cStatRet,AStatus1:={},AsTAtus2:={}
If C_VSeqImp=1
   i_print(0,0,Kc_status)
   RET_PA010()
   cStatRet:=STAT_OP()
   RETURN cStatRet
ElseIf C_VSeqImp=2
   Bt_Status(@Astatus1,@Astatus2)
   If Astatus[4]
      Aviso_1( 13,, 18,, [A t e n ‡ „ o !], "Placa FISCAL n„o responde; Verifique a Impressora.", { [  ^Ok!  ] }, 1, .t., .t. )
   Endif
Endif

Function MsgBox(cMsg)
Local aMsg := {},nLinT := nColE := nLinB := nColD := i := nTamMax := x := 0, nOpcao := 0
cMsg = cMsg
aMsg := xDELIMIT(cMsg)
AEVAL(aMsg,{|cStr| nTamMax := MAX(LEN(ALLTRIM(cStr)),nTamMax)})
nTamMax := nTamMax + 2
nLinT   := 12-((LEN(aMsg)+3)/2)                            // Linha do Topo
nColE   := 30-((nTamMax+1)/2)                              // Coluna Esquerda
nLinb   := nLinT + LEN(aMsg)+2                             // Linha aBaixo
nColD   := nColE + nTamMax + 1                             // Coluna Direita
Tel_Ant := SaveScreen(nLinT,nColE-1,nLinB+1,nColD)
Cor_Ant := SetColor( C_CDFnd + [, ] + C_CDEdi + [,,, ] + C_CDFnd )
Caixa_Smp( nLinT,nColE,nLinB,nColD, "Aten‡„o", 5, [], C_CDTit, C_CDFnd )
x := nLinT + 1
AEVAL(aMsg,{|cStr| DEVPOS(x++,CENTER_TXTBOX(nColE,nColD,LEN(cStr))),DEVOUT(cStr,C_CDFnd)})
*RestScreen(nLinT,nColE-1,nLinB+1,nColD, Tel_Ant)
Return .t.

Function xDELIMIT(cString,cDelimit)
Local x,a := {}
cDelimit := If(cDelimit=Nil,";",cDelimit)
While (x := At(cDelimit,cString)) # 0
      Aadd(a,Subs(cString,1,x-1))
      cString := Subs(cString,x+Len(cDelimit))
End
Aadd(a,Subs(cString,x+Len(cDelimit)))
Return (a)

Function center_txtbox(col_ini,col_fin,tam_txt)
Return((Int((col_fin - col_ini + 1)/2) - Int(tam_txt/2))+col_ini)


****** Verificar Status Prioritario da PA010

FUNCTION ST_PRI
i_print(0,0,chr(27)+[2P])
RET_PA010()
RETURN STAT_OP()


****** Verificar se PDV Aberto

FUNCTION PDV_OPEN
If C_VSeqImp=1
   i_print(0,0,chr(27)+[0S1])
   RET_PA010()
   RETURN STAT_OP() == "0"
ElseIf C_VSeqImp=2
   Return Bt_PdvOpen()
Endif


****** Verificar se ha Erro de Check-Sum

FUNCTION ERR_CKSM
LOCAL AStatus1:={},AsTAtus2:={}
If C_VSeqImp=1
   i_print(0,0,chr(27)+[2M])   && 0S2
   TONE(2300,2)
   tINKEY(0)
   RET_PA010()
   RETURN STAT_OP() == "1"
ElseIf C_VSeqImp=2
   Bt_Status(@Astatus1,@Astatus2)
   TONE(2300,2)
   tINKEY(0)
   Return Astatus2[6]
Endif

FUNCTION FIM_PAPEL
Local Aflag:={}
If C_VSeqImp=1
   i_print(0,0,chr(27)+[0S3])
   RET_PA010()
   RETURN STAT_OP() == "1"
ElseIf C_VSeqImp=2
   Bt_FimPapel()
Endif

function imp_online(cpar)
Local Aflag:={}
If C_VSeqImp=1
   i_print(0,0,chr(27)+[E],[@!],.f.)
   ret_pa010()
   return stat_op() $ cpar
ElseIf C_VSeqImp=2
   Bt_Flag(@Aflag)
   Return (!Bt_aFlag[5])
Endif

FUNCTION PDV_INTRV
If C_VSeqImp=1
   i_print(0,0,chr(27)+[0S4])
   RET_PA010()
   RETURN STAT_OP()=="1"
ElseIf C_VSeqImp=2
   Return Bt_IsInter()
Endif

FUNCTION MOD_FISCL
If C_VSeqImp=1
   i_print(0,0,chr(27)+[0S5])
   RET_PA010()
   RETURN STAT_OP() == "1"
ElseIf C_VSeqImp=2
   Return (Bt_IsFiscal())
Endif

FUNCTION EPROMFULL
Local Aflag:={}
If C_VSeqImp=1
   i_print(0,0,chr(27)+[0S6])
   RET_PA010()
   RETURN STAT_OP() == "1"
ElseIf C_VSeqImp=2
   Bt_Flag(@Aflag)
   Return (Bt_aFlag[8])
Endif

FUNCTION CUP_OPEN
Local Aflag:={}
If C_VSeqImp=1
   i_print(0,0,chr(27)+[2C])
   RET_PA010()
   RETURN STAT_OP() == "0"
ElseIf C_VSeqImp=2
   aFLAG:=Bt_Flag()
   Return (AFlag[1])
Endif

FUNCTION CUP_RECEM
Local Aflag:={}
If C_VSeqImp=1
   i_print(0,0,chr(27)+[2c])
   RET_PA010()
   RETURN STAT_OP()
Endif


FUNCTION INIEPROM
If C_VSeqImp=1
   i_print(0,0,chr(27)+[0S8])
   RET_PA010()
   RETURN STAT_OP() == "1"
ElseIf C_VSeqImp=2
   Return Bt_IsFiscal()
Endif

FUNCTION CLICHOK
iF C_VSeqImp=1
   i_print(0,0,chr(27)+[0S9])
   RET_PA010()
   RETURN STAT_OP() == "1"
ElseIf C_VSeqImp=2
   Return !Empty(Bt_Cliche())
EndIf

*********************************
function centra(texto,larg_linha)
texto=trim(texto)
if type("larg_linha")="U"
   larg_linha=80
endif
return((larg_linha-len(texto))/2)

FUNCTION I_PRINT(nLin,nCol,xVar,cPict,lCenter)
Local i,b,c,cor
If C_VSeqImp=1
   IF lCenter!=NIL
      IF lCenter
         xVar:=ALLTRIM(TRANSFORM(xVar,cPict))
         xvar1=space(25-(len(xVar)/2))+xVar
         xVar:=xvar1
         nCol:=25-(LEN(xVar)/2)
      ENDIF
   ENDIF
   N=1
   for j=1 to len(xVar)
      * ?N
//       yvar=wrpdv(substr(xVar,j,1))
     *  N++
   Next
ElseIf C_VSeqImp=2
    retorno_im:= ack:= nak:= st1:= st2:= Space(1)
    fwrite(fserial_out,chr(27)+chr(251)+xvar+'|'+chr(27),len(xvar)+4)
*    For contador1:= 1 To 3
*       fread(fserial_out,@retorno_im,1)
*       If (contador1 = 1)
*          If (Asc(retorno_im) = 21)
*             ? "Atencao... a impressora retornou 21d=15h=NAK"
*          EndIf
*       EndIf
*    Next
Endif
RETURN .T.

Function bcdtodecb(bcd,dec)
Local v:='',g,i,d:=if(dec=nil,2,dec)
For i=1 to len(bcd)
    v+=right([0]+ltrim(str(asc(substr(bcd,i,1)),2)),2)
Next
v=val(v)/(10^d)
Return v

Function bcdtodec(bcd,dec)
Local d:=if(dec=nil,2,dec)
Return val(bcd)/(10^d)

Function bt_Nserie
Local Buffer:=Space(15),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|00])
Freads(@Buffer,15,@status)
Return ValidaZ(Buffer)

Function bt_Nserie2(Buffer)
Local Buff:=Space(15),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|00])
Freads(@Buff,15,@status)
Buffer=Validaz(Pad(Alltrim(Buff),15))
Return .T.

Function bt_NRed()
Local Buffer:=Space(4),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|09])
Freads(@Buffer,4,@status)
Return StrZero(Val(Buffer)+1,6)

Function Validaz(Buffer)
Local i:=1,T:=Len(Buffer),c:=Space(15),p:=' '
c=[]
For i=1 to t
    p:=Substr(Buffer,i,1)
    c+=If(Asc(P)=0,' ',p)
Next
Return c

Function bt_Versao
Local Buffer:=space(4),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|01])
Freads(@Buffer,4,@status)
If asc(status)<>6
   CFErro:=.T.
   Return '0000'
Else
   Return Buffer
Endif

Function bt_Cgc
Local Buffer:=space(36),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|02])
Freads(@Buffer,33,@status)
If status>0
   CFErro:=.t.
   Return ''
Else
   Return left(Buffer,18)
Endif

Function bt_Ie
Local Buffer:=space(36),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|02])
Freads(@Buffer,33,@status)
If status>0
   CFErro:=.t.
   Return ''
Else
   Return Subs(Buffer,19)
Endif

Function bt_Gt
Local Buffer:=space(18),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|03])
Freads(@Buffer,18,@status)
Return Val(Buffer)/100

Function bt_Gta
Return

Function bt_NCan
Local Buffer:=space(14),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|04])
Freads(@Buffer,14,@status)
Return Val(Buffer)/100

Function bt_NDes
Local Buffer:=space(14),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|05])
Freads(@Buffer,14,@status)
Return Val(Buffer)/100


Function bt_CSequencia
Local Buffer:=space(06),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|06])
Freads(@Buffer,06,@status)
If status>0
   CFErro:=.t.
   Return 0
Else
   Return bcdtodec(Buffer,0)
Endif

Function bt_NONF
Local Buffer:=space(06),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|07])
Freads(@Buffer,06,@status)
If status>0
   CFErro:=.t.
   Return 0
Else
   Return Val(Buffer)
Endif

Function bt_NCC
Local Buffer:=space(04),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|08])
Freads(@Buffer,04,@status)
If status>0
   CFErro:=.t.
   Return 0
Else
   Return bcdtodec(Buffer,0)
Endif

Function bt_NIT
Local Buffer:=space(04),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|10])
Freads(@Buffer,04,@status)
If status>0
   CFErro:=.t.
   Return 0
Else
   Return val(Buffer)
Endif

Function bt_AddAliq(Aliq)
Local Buffer:=Right([0000]+Ltrim(Str(Aliq*100,4)),4),nb,status:=0
CFErro:=.f.
I_Print(0,0,[07|]+Buffer)
Freads(@Buffer,00,@status)
If status>0
   CFErro:=.t.
   Return .f.
Else
   Return .t.
Endif

Function bt_NSP
Local Buffer:=space(04),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|11])
Freads(@Buffer,04,@status)
If status>0
   CFErro:=.t.
   Return 0
Else
   Return bcdtodec(Buffer,0)
Endif

Function bt_NUIV
Local Buffer:=space(04),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|12])
Freads(@Buffer,04,@status)
If status>0
   CFErro:=.t.
   Return 0
Else
   Return bcdtodec(Buffer,0)
Endif

Function bt_NC
Local Buffer:=space(04),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|14])
Freads(@Buffer,04,@status)
If status>0
   CFErro:=.t.
   Return 0
Else
   Return bcdtodec(Buffer,0)
Endif

Function bt_NL
Local Buffer:=space(04),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|15])
Freads(@Buffer,04,@status)
If status>0
   CFErro:=.t.
   Return 0
Else
   Return bcdtodec(Buffer,0)
Endif

Function bt_MOEDA
Local Buffer:=space(02),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|16])
Freads(@Buffer,04,@status)
If status>0
   CFErro:=.t.
   Return '  '
Else
   Return Buffer
Endif

Function bt_DATA
Local Buffer:=space(12),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|23])
Freads(@Buffer,12,@status)
Return ctod(Transf(left(Buffer,6),[@r 99/99/99]))

Function bt_HORA
Local Buffer:=space(12),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|23])
Freads(@Buffer,12,@status)
If status>0
   CFErro:=.t.
   Return '00:00:00'
Else
   Return transf(Right(Buffer,6),[@r 99:99:99])
Endif

Function bt_DATAMOV
Local Buffer:=space(6),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|27])
Freads(@Buffer,6,@status)
If status>0
   CFErro:=.t.
   Return ctod('00/00/00')
Else
   Return ctod(transf(Buffer,[@r 99/99/99]))
Endif

Function bt_FLAG
Local Buffer:=space(01),status:=0
cferro:=.f.
do while .t.
   I_Print(0,0,[35|17])
   Freads(@Buffer,00,@status)
   If status>0
      CFErro:=.t.
      Return {.f.,.f.,.f.,.f.,.f.,.f.,.f.,.f.}
   Elseif status<0
      Loop
   Else
      Return ArrayByte(Buffer)
   Endif
Enddo

Function bt_FLAGIT
Local Buffer:=space(01),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|20])
Freads(@Buffer,01,@status)
If status>0
   CFErro:=.t.
   Return ' '
Else
   Return if(asc(Buffer)=85,.f.,.t.)
Endif

Function bt_Cliche(Retorno)
Local Buffer:=space(186),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|13])
Freads(@Buffer,186,@status)
If status>0
   CFErro:=.t.
   Return ' '
Else
   Buffer=Pad(Buffer,186)
   If Retorno=Nil
      Return (Buffer!=Space(186))
   Else
      Retorno=Buffer
      Return Nil
   Endif
Endif

Function bt_Nomeiat(Item,Nome)
Local Buffer:=Space(3),Status:=0
CFErro:=.f.
I_Print(0,0,[40|#]+Str(Item,1)+Pad(Nome,19))
Freads(@Buffer,03,@status)
If status>0
   CFErro:=.t.
   Return .f.
Else
   Return .t.
Endif

Function bt_DesTot(Variavel)
Local Buffer:=space(171),nb,status:=0
CFErro:=.f.
I_Print(0,0,[35|25])
Freads(@Buffer,171,@status)
Variavel:={}
If status>0
   CFErro:=.t.
Else
   For nb=1 to 19
       AAdd(Variavel,Substr(Buffer,nb*19-18,19))
   Next
Endif
Return Nil

Function bt_LeAliq(Variavel)
Local Buffer:=space(68),nb,status:=0
CFErro:=.f.
I_Print(0,0,[26|53])
Freads(@Buffer,68,@status)
Variavel:={}
If status>0
   CFErro:=.t.
Else
   For nb=1 to Val(Left(Buffer,2))
       AAdd(Variavel,val(Substr(Buffer,nb*4-1,4))/100)
   Next
Endif
Return VAL(Left(Buffer,2))

Function bt_IsFiscal()
Local Buffer:=Space(1),Status:=0
CFErro:=.f.
I_Print(0,0,[35|21])
Freads(@Buffer,01,@status)
If status>0
   CFErro:=.t.
   Return .f.
Else
   Return (Buffer==[55])
Endif

Function bt_IsInter()
Local Buffer:=Space(1),Status:=0
CFErro:=.f.
I_Print(0,0,[35|20])
Freads(@Buffer,01,@status)
If status>0
   CFErro:=.t.
   Return .f.
Else
   Return (Buffer==[55])
Endif

Function bt_AbreCup()
Local Buffer:=Space(3),Status:=0
CFErro:=.f.
I_Print(0,0,[00])
Freads(@Buffer,03,@status)
If status>0
   CFErro:=.t.
   Return .f.
Else
   Tinkey(3)
   Return .t.
Endif

Function Tinkey(Tempo)
Local Teclado:='',Segundos:=Seconds()
If Tempo=0
   Return(Inkey(0))
Endif
do While Seconds()-Segundos<Tempo
EndDo
Return .t.

Function bt_VndItem(Codigo,Descricao,Aliquota,Quantidade,Preco,DescP,DescV)
Local Buffer:='',Status:=Space(3)
Buffer+=;
Pad(Codigo,13)+;
Pad(DesCricao,29)+;
Aliquota+;
right('0000000'+ltrim(str(Quantidade*100,7)),7)+;
right('00000000'+ltrim(str(Quantidade*100,8)),8)+;
right('0000'+ltrim(str(DescP*100,4)),4)+;
right('0000'+ltrim(str(Descv*100,4)),4)
I_Print(0,0,[09|]+Buffer)
Freads(@Buffer,03,@status)
If status>0
   CFErro:=.t.
   Return .f.
Else
   Return .t.
Endif

Function Bt_CncItem(Item)
Local Buffer:=Space(3),Status:=0
If Item=Nil
   I_Print(0,0,[13])
Else
   I_Print(0,0,[31|]+Item)
Endif
Freads(@Buffer,03,@Status)
If Status>0
   CFErro:=.t.
   Return .f.
Else
   Return .t.
Endif

Function Bt_NumCup(Numero)
Local Buffer:=Space(6),Status:=0,TimeOut:=20,XSecs:=Seconds(),T1:=0
Do While .t.
   I_Print(0,0,[30])
   Freads(@Buffer,06,@status)
   Numero=Val(Buffer)
   If Numero=0
      If (Seconds()-XSecs)>Timeout
         If T1=0
            t1:=1
            I_Print(0,0,[70])
            tINkey(0.5)
            Freads(@Buffer,00,@status)
            Loop
         EndIf
         CFErro:=.t.
         Numero=[000000]
         Return .f.
      EndIf
      tInkey(0.5)
      loop
   Endif
   Numero:=StrZero(Numero,6)
   Return .t.
EndDo

Function Bt_Papel
Local Status1:={},Status2:={}
Bt_Status(@Status1,@status2)
Return (Status1[7] .and. Bt_PapLin()>400)

Function Bt_paplin()
Local i,c,b:=' ',b1:=0,b2:=0
I_Print(0,0,[62|54])
TInkey(0.5)
Buffer=''
status=''
For i=1 to 5
    c=Fread(Fserial_in,@b,1)
    If C=0
       Exit
    Endif
    IF I=4
       b1=asc(b)
    elseif i=5
       b2=asc(b)
    ENDIF
Next
Return b1+b2*256

Function Freads(Buffer,Lchar,status,Prim)
Local i,c,b:=' ',Tempo,Retorno:={},RetPap:={}
If Prim=Nil
   Prim:=.f.
Endif
TInkey(0.1)
Buffer:=''
Gstatus:=''
For i=1 to If(Prim,4,3)
    c=Fread(Fserial_in,@b,1)
    If C=0
       Exit
    Endif
    If I=1 .and. Asc(b)<>6
       Status=-2
       Tempo:=Seconds()
       Do While Fread(Fserial_in,@b,1)>0
          tInkey(0.1)
          If (Seconds()-Tempo)>2
             Exit
          Endif
       EndDo
       Return [0]
    Endif
    if i>1
       GStatus+=b
       If (Prim .and. i=3) .or. (!prim .and. i=2)
          RetPap:=ArrayByte(b)
          @ 18, 01 Say If(RetPap[8],[Falta de papel!],"")
          @ 18, 01 Say If(RetPap[7],[Pouco papel!],"")
       else
          If i>=3
             Retorno:=ArrayByte(b)
          Endif
       Endif
    Endif
Next
If Len(gStatus)<2
   Status=-1
   @18,02 Say [F1]
   Return ''
Else
   If Prim
      Status:=asc(substr(Gstatus,2,1))+asc(substr(Gstatus,3,1))*256
   Else
      Status:=asc(substr(Gstatus,1,1))+asc(substr(Gstatus,2,1))*256
   Endif
   If Retorno[1]
      Return []
   Endif
EndIf
For i=1 to Lchar
    c=Fread(Fserial_in,@b,1)
    If C=0 &&.or. c=3
       Exit
    Endif
    Buffer+=b
Next
If Prim
   Buffer:=Right(GStatus,1)
Else
   Buffer:=IF(LCHAR=0,GSTATUS,Pad(Buffer,lCHAR))
Endif
Return i-1

Function Bt_FimPapel
Local Status1:={},Status2:={}
Bt_Status(@Status1,@status2)
Return Status1[8]

Function Bt_ExecOk(Status1,Status2)
Status1:={}
Status2:={}
Bt_Status(@Status1,@status2)
Return !Status2[1]

Function ComandoOk(Tempo)
local TmpSec:=Seconds(),Ok:=.f.,l1:={},l2:={},cor
If Tempo=Nil
   Tempo=0
Endif
Do While .t.
   If Bt_ExecOk(@l1,@l2)
      Ok:=.t.
      Exit
   Endif
   If TmpSec>0
      If Seconds()-TmpSec>Tempo
         Exit
      Endif
   Endif
   TInkey(0.1)
EndDo
@ 18, 01 Say If(l1[8],[Falta de papel!],"")
@ 18, 01 Say If(l2[7],[Pouco papel!],"")
Return Ok

Function bt_status(Status1,Status2)
Local Status:=0
I_Print(0,0,[19])
Gtstatus:='  '
Freads(@GTSTATUS,00,@status)
If status>0
   CFErro:=.t.
Endif
Status1=ArrayByte(Substr(Gtstatus,1,1))
Status2=ArrayByte(Substr(Gtstatus,2,1))
Return Status

Function ArrayByte(Buffer)
Local s,b,a:={.f.,.f.,.f.,.f.,.f.,.f.,.f.,.f.},tmp:=0
s=asc(Buffer)
For i=1 to 8
    Tmp:=mod(s,2)
    a[i]=(tmp>0)
    s=(s-Tmp)/2
    if s<=1
       a[i+1]=(s>0)
       exit
    endif
Next
Return a

Function bt_Inseret(Item,Valor)
Local Buffer:=Space(3),Status:=0
CFErro:=.f.
I_Print(0,0,[40|#]+Str(Item,1)+Pad(Nome,19))
Freads(@Buffer,03,@status)
If status>0
   CFErro:=.t.
   Return .f.
Else
   Return .t.
Endif

Function bt_Lertt(Item,Valor)
Local Totais:={}
CFErro:=.f.
Bt_PegaTotais(@Totais)
If status>0
   CFErro:=.t.
   Valor=-1
   Return .f.
Else
   Valor:=(Totais[5,Item])
   Return .t.
Endif

Function bt_LertIcm(Item,Valor)
Local Totais:={}
CFErro:=.f.
Bt_PegaTotais(@Totais)
If status>0
   CFErro:=.t.
   Valor=-1
   Return .f.
Else
   Valor:=(Totais[1,Item])
   Return .t.
Endif

Function Bt_Pegatotais(N)
Local Buffer:=Space(438),i,k,Status:=0
Totais:={{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},0,0,0,{0,0,0,0,0,0,0,0,0,0},0,0,0}
I_Print(0,0,[27])
Gtstatus:='  '
Freads(@Buffer,438,@status)
If status>0
   CFErro:=.t.
Endif
For i=1 to 16
    Totais[1,i]:=Val(Substr(Buffer,i*14-13,14))/100
Next
i:=16*14+1
Totais[2]:=Val(Substr(Buffer,i,14))/100
i+=14
Totais[3]:=Val(Substr(Buffer,i,14))/100
i+=14
Totais[4]:=Val(Substr(Buffer,i,14))/100
i+=14
For k=1 to 9
    Totais[5,k]:=Val(Substr(Buffer,i+(k*14),14))/100
Next
i+=(k*14)
Totais[6]:=Val(Substr(Buffer,i,14))/100
i+=14
Totais[7]:=Val(Substr(Buffer,i,14))/100
i+=14
Totais[8]:=Val(Substr(Buffer,i,18))/100
Return totais[1]


Function Bt_Tot(SEQ)
Local Buffer:=Space(300),i,k,Status:=Tot:=0
I_Print(0,0,[27])
Freads(@Buffer,300,@status)
TOT:=Val(Substr(Buffer,seq*14-13,14))/100
Return TOT


Function Bt_ReadX
Local Buffer:=Space(3),Status:=0
CFErro:=.f.
I_Print(0,0,[06])
Freads(@Buffer,00,@status)
If status>0
   CFErro:=.t.
   Return .f.
Else
   Return .t.
Endif

Function Bt_ReadZ
Local Buffer:=Space(3),Status:=0
CFErro:=.f.
I_Print(0,0,[05])
Freads(@Buffer,00,@status)
If status>0
   CFErro:=.t.
   Return .f.
Else
   Return .t.
Endif


Function Bt_Autentica
Local Buffer:=Space(3),Status:=0
CFErro:=.f.
I_Print(0,0,[16])
Freads(@Buffer,00,@status)
If status>0
   CFErro:=.t.
   Return .f.
Else
   Return .t.
Endif

Function Bt_AbreGaveta
Local Buffer:=Space(3),Status:=0
If !ComGav
   Return .t.
Endif
CFErro:=.f.
I_Print(0,0,[22|1])
Tinkey(0.5)
Freads(@Buffer,00,@status)
If status>0
   CFErro:=.t.
   Return .f.
Else
   Return .t.
Endif

Function Bt_AbreGa2
Local Buffer:=Space(3),Status:=0
If ComGav
   return .t.
Endif
CFErro:=.f.
I_Print(0,0,[22])
Tinkey(0.5)
Freads(@Buffer,00,@status)
If status>0
   CFErro:=.t.
   Return .f.
Else
   Return .t.
Endif

Function Bt_AbreSIcms(Dados)
Local Buffer:=Space(3),Status:=0,K
CFErro:=.f.
If Dados=Nil
   Dados:=[]
Endif
k:=Len(Dados)
Do While k>0
   I_Print(0,0,[20|]+Left(Dados,100))
   Freads(@Buffer,00,@status)
   If status>0
      If Aviso_1( 10,, 15,, [A t e n ‡ „ o !], "Impressao em erro. Continuar Impressao?", { [  ^Sim  ], [  ^N„o  ] }, 2, .t. )=1
         Loop
      Else
         Return .f.
      EndIf
   EndIf
   If K>100
      Dados:=Substr(Dados,101)
   End
   K-=100
Enddo
Return .t.

Function Bt_Abre1(Dados)
Local Buffer:=Space(3),Status:=0
CFErro:=.f.
If Dados=Nil
   Dados:=[]
Endif
k:=Len(Dados)
Do While k>0
   I_Print(0,0,[20|]+Left(Dados,100))
   Freads(@Buffer,00,@status)
   If Status>0 .and. Status<>64
*      If Aviso_1( 15,, 20,, [A t e n ‡ „ o !], "Impressora n„o responde. Tente novamente?", { [ ^Sim ], [ ^N„o ] }, 1, .t. )=1
*         Bt_Fecha1()
*         Return .f.
*      Else
*         FERASE("Error.txt")
*         F1:=FCreate("Error.txt")
*         FClose(F1)
*         V_EnviaConf(0,TModulo)
*         Exit
*      EndIf
   EndIf
   If K>100
      Dados:=Substr(Dados,101)
   End
   K-=100
Enddo
Return .t.


Function Bt_FechaSIcms()
Local Buffer:=Space(3),Status:=0
CFErro:=.f.
Do While .t.
   I_Print(0,0,[21])
   Freads(@Buffer,00,@status)
   If status>0
      If Aviso_1( 10,, 15,, [A t e n ‡ „ o !], "Impressao em erro. Continuar Impressao?", { [  ^Sim  ], [  ^N„o  ] }, 2, .t. )=1
         Loop
      Else
         Return .f.
      EndIf
   EndIf
   Exit
EndDo
Return .t.

Function Bt_Fecha1()
Local Buffer:=Space(3),Status:=0
CFErro:=.f.
Do While .t.
   I_Print(0,0,[21])
   Freads(@Buffer,00,@status)
   If Status<>0
*      Clear Typeahead
*      If Aviso_1( 15,, 20,, [A t e n ‡ „ o !], "Impressora n„o responde. Tente novamente?", { [ ^Sim ], [ ^N„o ] }, 1, .t. )=1
*         Loop
*      Else
*         FERASE("Error.txt")
*         F1:=FCreate("Error.txt")
*         FClose(F1)
*         V_EnviaConf(0,TModulo)
*         Return .f.
*      EndIf
   EndIf
   Exit
EndDo

Function Bt_Vinc(Dados)
Local Buffer:=Space(3),Status:=0,K, Erro:=.f., Tipo, Atv:=.f.
Clear Typeahead
CFErro:=.f.
If Dados=Nil
   Dados:=[]
Endif
k:=Len(Dados)
Do While k>0
   I_Print(0,0,[19])
   Freads(@Buffer,00,@status)
   If Status<>0
*      Clear Typeahead
*      Tipo = Aviso_1( 10,, 15,, [A T E N C A O !], [Impressora n„o responde. Tente novamente?], { [ ^S I M ], [ ^N A O ]  }, 1, .t. )
*      If Tipo=1
*         Atv:=.t.
*         Loop
*      Else
*         Erro:=.t.
*      EndIf
   Else
      If Atv
         Bt_Fecha1()
         Return .f.
      EndIf
      I_Print(0,0,[20|]+Left(Dados,48))
      Freads(@Buffer,00,@Status)
   EndIf
   If Erro
      ErroImp:=.t.
      FERASE("Error.txt")
      F1:=FCreate("Error.txt")
      FClose(F1)
      //V_EnviaConf(0,TModulo)
      Return .f.
   EndIf
   If K>48
      Dados:=Substr(Dados,49)
   End
   K-=48
Enddo
Clear Typeahead
Return .t.


Function Bt_GavAberta
Local Buffer:=Space(1),Status:=0
If !ComGav
   Return .t.
Endif
CFErro:=.f.
Do while .t.
   I_Print(0,0,[23])
   Freads(@Buffer,0,@status,.t.)
   If status>0
      CFErro:=.t.
      If CtipGav=[1]
         Return (asc(Buffer)=48)
      ElseIf CtipGav=[2]
         Return (asc(Buffer)=50)
      Endif
   ElseIf Status<0
      Tinkey(1)
      Loop
   Else
      If CtipGav=[1]
         Return (asc(Buffer)=48)
      ElseIf CtipGav=[2]
         Return (asc(Buffer)=50)
      Endif
   Endif
EndDo

Function bt_CpAberto()
Local Astatus:=bt_Flag()
Return Astatus[1]

Function bt_horVerao()
Local Astatus:=bt_Flag()
Return Astatus[3]

Function bt_PdvOpen()
Local Astatus:=bt_Flag()
Return  !Astatus[4]

Function Bt_IniPgt()
Local Buffer:=Space(2),Status:=0,i
For i:=1 to Len(FormasPgt)
    I_Print(0,0,[71|]+Pad(FormasPgt[i],16))
    Freads(@Buffer,03,@Status)
Next
Return Nil





******* Mostrar Hot-Keys
FUNCTION HOT_KEYS
@ 23,00 SAY SPACE(80) COLOR "N/W+"
RETURN NIL

Function Mostconfig()
Tel_Ant:=SaveScreen(00,00,24,79)
Cor_Ant = SetColor( C_CDFnd + [, ] + C_CDEdi + [,,, ] + C_CDFnd )
Caixa_Smp( 05, 08, 16, 72, [Status do ECF], 5, [ ş Esc - Retorna], C_CDTit, C_CDFnd )
@ 06,09 clear to 15,71
@ 06,10 say [ Status do ECF ]
@ 07,10 say [  Cupom Fiscal ]
@ 08,10 say [  Mudanca Data ]
@ 09,10 say [Memoria Fiscal ]
@ 10,10 say [Troca de Papel ]
@ 11,10 say [       Relogio ]
@ 12,10 say [ICMS Informado ]
@ 13,10 say [  Memoria CMOS ]
@ 14,10 say [  Razao Social ]
@ 15,10 say [St Prioritario ]
@ 06,41 say [   N§ de Serie ]
@ 07,41 say [Em Intervencao ]
@ 08,41 say [   STRAP de IT ]
@ 09,41 say [Impr com Ponto ]
@ 10,41 say [ Horario Verao ]
@ 11,41 say [Em Treinamento ]
@ 12,41 say [ N§ de Digitos ]
@ 13,41 say [Tipo do Codigo ]
xst:=StECF()
@ 06,25 say iif(xst=[0],[Aberto],[Fechado]) color [gr+/w]
xst:=StCupom()
@ 07,25 say iif(xst=[0],[Aberto],[Fechado]) color [gr+/w]
xst:=StRolData()
@ 08,25 say iif(xst=[0],[Nao],[Sim]) color [gr+/w]
xst:=StMemFis()
if xst=[0]
   @ 09,25 say [Ok] color [gr+/w]
elseif xst=[1]
   @ 09,25 say [Falta N§ Serie] color [gr+/w]
else
   @ 09,25 say [Falta Razao Social] color [gr+/w]
endif
xst:=StTrocPap()
@ 10,25 say iif(xst=[0],[Desligado],[Ligado]) color [gr+/w]
xst:=StRelogio()
@ 11,25 say iif(xst=[0],[Programado],[Nao Programado]) color [gr+/w]
xst:=StIcms()
@ 12,25 say iif(xst=[0],[Parametrizado],[Nao Parametrizado]) color [gr+/w]
xst:=StCmos()
@ 13,25 say iif(xst=[0],[Ok],[Erro de Check-Sum]) color [gr+/w]
xst:=StRazSoc()
@ 14,25 say iif(xst=[0],[Parametrizado],[Nao Parametrizado]) color [gr+/w]
xst:=StPrior()
if xst=[8]
   @ 15,25 say [Nao Ha Numero de Serie Gravado] color [gr+/w]
elseif xst=[2]
   @ 15,25 say [Erro de Check-Sum] color [gr+/w]
elseif xst=[9]
   @ 15,25 say [Nao Ha Razao Social Gravada] color [gr+/w]
elseif xst=[4]
   @ 15,25 say [Flag de Intervencao Tecnica Ligado] color [gr+/w]
elseif xst=[6]
   @ 15,25 say [EPROM Fiscla Sem Area Para GT do Dia] color [gr+/w]
elseif xst=[7]
   @ 15,25 say [Nao Ha Indice de ICMS Parametrizado] color [gr+/w]
elseif xst=[5]
   @ 15,25 say [Numero do ECF na Loja Nao Parametrizado] color [gr+/w]
elseif xst=[1]
   @ 15,25 say [ECF Fechado] color [gr+/w]
elseif xst=[3]
   @ 15,25 say [Flag de Troca de Papel Ligado] color [gr+/w]
elseif xst=[0]
   @ 15,25 say [ECF Aberto] color [gr+/w]
endif
xst:=StNumSerie()
@ 06,56 say iif(xst=[0],[Ok],[Nao Ha N§ Serie]) color [gr+/w]
xst:=StITecnica()
@ 07,56 say iif(xst=[0],[Fora de IT],[Em Intervencao]) color [gr+/w]
xst:=StSTRAP()
@ 08,56 say iif(xst=[0],[Desligado],[Ligado]) color [gr+/w]
xst:=StIPonto()
@ 09,56 say iif(xst=[0],[Nao],[Sim]) color [gr+/w]
xst:=StHorVerao()
@ 10,56 say iif(xst=[0],[Desligado],[Ligado]) color [gr+/w]
xst:=StTreino()
@ 11,56 say iif(xst=[0],[Desligado],[Ligado]) color [gr+/w]
xst:=St7Dig()
@ 12,56 say iif(xst=[0],[9],[7])+[ Digitos] color [gr+/w]
xst:=StEAN()
@ 13,56 say [EAN]+iif(xst=[0],[8],[13]) color [gr+/w]
tone(780,3)
tone(1510,2)
inkey(0)
restscreen(00,00,24,79,Tel_Ant)
return
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Checagem do Digito do Numero e Qual EAN Ativo                         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function ver_ean(numero,mensagem)
if checadig(numero)
   return(.t.)
endif
Aviso_1( 13,, 18,, [A t e n ‡ „ o !], mensagem, { [  ^Ok!  ] }, 1, .t., .t. )
return(.f.)
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Checagem do Digito Verificador do Codigo de Barras                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function checadig(numero)
tone(900,5)
priv xtam:=len(numero),xpares:=0,ximpares:=0
xtransnum:=numero
for t=1 to xtam-1 step 2
    xpares+=val(substr(xtransnum,t,1))
    if t+1<xtam
       ximpares+=val(substr(xtransnum,t+1,1))
    endif
next
xpares:=xpares*3
xresult:=xpares+ximpares
xtransres:=str(xresult,lennum(xresult))
xvaltres:=val(right(xtransres,1))
xdigito:=iif(empty(xvaltres),str(xvaltres,1),str(10-xvaltres,1))
return(xdigito=right(numero,1))

*################ Funcoes Fiscais #######################################

/*

              Cap¡tulo I  -  Comandos do M¢dulo Fiscal/ICMS

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Acrescimo Financeiro - Por Percentual ou Valor                        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function AcresFin(tipo,valor)
priv xvlr1:=strzero(valor*100,9)
i_print(00,00,tEsc+[0A]+tipo+iif(tipo=[P],strzero(valor,4,0),xvlr1))
ret_pa010()
return(stat_op())

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Desconto no Pe da Nota (Percentual/Valor)                             ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function DescPeNota(tipo,valor)
priv xvlr1:=strzero(valor*100,9)
i_print(00,00,tEsc+[0D]+tipo+iif(tipo=[P],strzero(valor,4,0),xvlr1))
ret_pa010()
return(stat_op())

* fDescPeP:=tEsc+[0DP]<pppp>         // Em Percentual
* fDescPeV:=tEsc+[0DV]<vvvvvvvvv>    // Em Valor

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Leitura do Numero de Itens Registrados                                ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function NumItens()
If C_VSeqImp=1
   i_print(00,00,tEsc+[0N])
   return(ret_pa010())
ElseIf C_VSeqImp=2
   Return Bt_NUiv()
Endif

* fNumItens:=tEsc+[0N]

/*

             Cap¡tulo II  -  Leituras X, Z e Memoria Fiscal

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Abre Terminal ECF                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function AbreTerm()
If C_VSeqImp=1
   i_print(00,00,tEsc+[1A]+tesc)
   ret_pa010()
   return(stat_op())
ElseIf C_VSeqImp=2
   return [0]
Endif

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Fecha Terminal ECF                                                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Function FechaTerm()
If C_VSeqImp=1
   i_print(00,00,tEsc+[1F]+TESC)
   ret_pa010()
   return(stat_op())
ElseIf C_VSeqImp=2
   Bt_ReadZ()
   Return [0]
ElseIf C_VSeqImp=3
   Imp_Z(tEsc+'.14}',.f.)
ElseIf C_VSeqImp=4
   //*** ReducaoZ(Pad(U_Usu,8))
Endif

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Leitura da Memoria Fiscal                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function LerMemFis(Tipo,datredi,datredf)
Local status:=0
CFErro:=.f.
If C_VSeqImp=1
   i_print(00,00,tEsc+[1L]+tipo+datredi+datredf)
   ret_pa010()
   return(stat_op())
ElseIf C_VSeqImp=2
   If tipo=[D]
      i_Print(0,0,[08|]+Right(Datredi,2)+Substr(DatRedi,5,2)+Substr(DatRedi,3,2)+;
                        Right(Datredf,2)+Substr(DatRedf,5,2)+Substr(DatRedf,3,2)+[I])
   Else
      I_Print(0,0,[08|00]+DatRedi+[00]+DatRedF+[I])
   Endif
   tInkey(30)
   Freads('',0,@status)
   If status>0
      CFErro:=.t.
      Return '1'
   Else
      Return '0'
   Endif
ElseIf C_VSeqImp=3
  If Tipo = "D"
     MDta1=Substr(datredi,1,2)+Substr(datredi,3,2)+Substr(datredi,7,2)
     MDta2=Substr(datredf,1,2)+Substr(datredf,3,2)+Substr(datredf,7,2)
     Imp_Z(tEsc+'.16'+MDta1+MDta2+'}',.f.)
  Else
     Imp_Z(tEsc+'.16'+datredi+datredf+'}',.f.)
  EndIf
ElseIf C_VSeqImp=4
  If Tipo = "D"
     MDta1=Substr(datredi,1,2)+Substr(datredi,3,2)+Substr(datredi,7,2)
     MDta2=Substr(datredf,1,2)+Substr(datredf,3,2)+Substr(datredf,7,2)
     Imp_Z(tEsc+'.16'+MDta1+MDta2+'}',.f.)
  Else
     Imp_Z(tEsc+'.16'+datredi+datredf+'}',.f.)
  EndIf
Endif
Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ E/S de Troca de Papel                                                 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function ESPapel(tipo)
If C_VSeqImp=1
   i_print(00,00,tEsc+[1P]+tipo)
   ret_pa010()
   return(stat_op())
ElseIf C_VSeqImp=2
   Ctit:=chr(14)+;
   If(Tipo=[E],"TROCA DE BOBINA","NOVA BOBINA")+chr(10)+;
   "Data..................:     "+Dtoc(Date())+chr(10)+;
   "Hora..................:       "+Time()+chr(10)+Chr(10)+;
   Replicate([-],48)+chr(10)+;
   "Supervisor............:     "+PAD(U_USU,10)+chr(10)+;
   Replicate([-],48)+chr(10)
   CAB_CUPOM(ctit,.F.)
   do While !Bt_FechaSIcms()
      inkey(1)
   EndDo
ElseIf C_VSeqImp=3
   cLin1 = Replica("-",40)
   cLin1 = "-------------TROCA DE BOBINA------------"
   cLin1 = "Operador...........:"+SPACE(02)+U_USU
   Leitura_X(cLin1)
ElseIf C_VSeqImp=4
   //LeitXGer(Pad(U_Usu,8))
   //ImpLinha("=========== TROCA DE BOBINA============")
   //ImpLinha(Left("Operador...........:"+SPACE(02)+U_USU,40))
   //** FimTrans(Pad(U_Usu,8))
   //** LineFeed(1,5)
EndIf


FUNCTION CAB_CUPOM(cTitulo,lFiscal)
LOCAL cLin,nCupom,cCodRet := ""
cLin=space(11)+[Operador: ]+pad(U_Usu,10)+Chr(10)
IF cTitulo = NIL
   CTitulo:=[]
EndIf
IF lFiscal
   //Bt_AbreCupom()
ELSE
   Bt_AbreSIcms(Clin+Chr(14)+cTitulo+Chr(10))
ENDIF
RETURN NIL


/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Emiss„o de Leitura X                                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Function Leitura_X(DADOS)
If C_VSeqImp=1
   If !empty(dados)
      I_Print(0, 0,Chr(27)+"1X{"+DADOS+"}")
   Else
      I_Print(0, 0,Chr(27)+"1X"+Chr(27))
   EndIf
   ret_pa010()
   return(stat_op())
ElseIf C_VSeqImp=2
   bt_readx()
   Return if(GTStatus#[  ],[1],[0])
ElseIf C_VSeqImp=3
   If !Empty(Dados)
      Imp_Z(tEsc+'.13S}',.f.)
      Imp_Z(tEsc+'.080'+Substr(Dados,1,40)+'}',.f.)
      Imp_Z(tEsc+'.080'+Substr(Dados,41,40)+'}',.f.)
      Imp_Z(tEsc+'.080'+Substr(Dados,81,40)+'}',.f.)
      Imp_Z(tEsc+'.080'+Substr(Dados,121,40)+'}',.f.)
      Imp_Z(tEsc+'.080'+Substr(Dados,161,40)+'}',.f.)
      Imp_Z(tEsc+'.080'+Substr(Dados,201,40)+'}',.f.)
      Imp_Z(tEsc+'.08}',.f.)
   Else
      Imp_Z(tEsc+'.13}',.f.)
  EndIf
ElseIf C_VSeqImp=4
  //LeituraX(Pad(U_Usu,8))
EndIf

/*

            Cap¡tulo III  -  Comandos Relacionados com Status

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Status do ECF                                                         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function StECF()
If C_VSeqImp=1
   i_print(00,00,tEsc+[2A])
   ret_pa010()
   return(stat_op())
ElseIf C_VSeqImp=2
   Return If(Bt_PdvOpen(),[0],[1])
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Status do Cupom Fiscal de Venda                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function StCupom()
If C_VSeqImp=1
   i_print(00,00,tEsc+[2C])
   ret_pa010()
   return(stat_op())
ElseIf C_VSeqImp=2
   Return if(bt_CpAberto(),[0],[1])
Endif

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Status do Rolamento de Data                                           ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function StRolData()
i_print(00,00,tEsc+[2D])
ret_pa010()
return(stat_op())

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Status da Memoria Fiscal                                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function StMemFis()
i_print(00,00,tEsc+[2E])
ret_pa010()
return(stat_op())

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Status do Flag Fiscal de Troca de Papel                               ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function StTrocPap()
If C_VSeqImp=1
   i_print(00,00,tEsc+[2F])
   ret_pa010()
   return(stat_op())
ElseIf C_VSeqImp=2
   Return If(Bt_Papel() .or. Bt_FimPapel(),[0],[1])
EndIf
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Status do Relogio                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function StRelogio()
i_print(00,00,tEsc+[2H])
ret_pa010()
return(stat_op())

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Status do Indice de ICMS Parametrizado                                ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function StIcms()
i_print(00,00,tEsc+[2I])
ret_pa010()
return(stat_op())

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Status da Memoria CMOS                                                ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function StCmos()
If C_VSeqImp=1
   i_print(00,00,tEsc+[2M])
   ret_pa010()
   return(stat_op())
ElseIf C_VSeqImp=2
   Return [0]
Endif
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Status Prioritario                                                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function StPrior()
Local Astatus1:={},Astatus2:={},Ok:=[0],i
If Abre_Dados( C_VDados, [Config], 1, 0, 11, 0, .f. ) # 0
   Fecha_Dados()
   Return( Nil )
EndIf
If C_VSeqImp=1
   i_print(00,00,tEsc+[2P])
   ret_pa010()
   return(stat_op())
ElseIf C_VSeqImp=2
   If C_VSitPdv="A"
      Ok:=[0]
   ElseIf C_VSitPdv="F"
      Ok:=[1]
   Endif
   Return Ok
ElseIf C_VSeqImp=3
   Status:=Imp_Z(tEsc+'.28}',.t.,18,1)
   If Status=[S]
      Return "2"
   ElseIf Status=[N]
      Return "0"
   Else
      Return "1"
   EndIf
EndIf
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Status da Razao Social                                                ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function StRazSoc()
i_print(00,00,tEsc+[2R])
ret_pa010()
return(stat_op())

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Status do Numero de Serie do Equipamento                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function StNumSerie()
i_print(00,00,tEsc+[2S])
ret_pa010()
return(stat_op())

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Status de Intervencao Tecnica                                         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function StITecnica()
i_print(00,00,tEsc+[2T])
ret_pa010()
return(stat_op())

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Status da Situacao do STRAP de Intervencao Tecnica                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function StSTRAP()
If C_VSeqImp=1
   i_print(00,00,tEsc+[2t])
   ret_pa010()
   return(stat_op())
ElseIf C_VSeqImp=2
   Return if(Bt_IsInter(),[0],[1])
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Status do Flag de Impressao com Ponto                                 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function StIPonto()
i_print(00,00,tEsc+[2U])
ret_pa010()
return(stat_op())

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Status de Horario de Verao 0/1                                        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function StHorVerao()
Local Flags
If C_VSeqImp=1
   i_print(00,00,tEsc+[2V])
   ret_pa010()
   return(stat_op())
ElseIf C_VSeqImp=2
   Return If(Bt_HorVerao(),[0],[1])
Endif
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Status do Flag de Treinamento                                         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function StTreino()
If C_VSeqImp=1
   i_print(00,00,tEsc+[2X])
   ret_pa010()
   return(stat_op())
ElseIf C_VSeqImp=2
   Return [0]
Endif

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Status do Flag de Sete Digitos                                        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function St7Dig()
i_print(00,00,tEsc+[2Y])
ret_pa010()
return(stat_op())

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Status do Tipo de Codigo do Produto                                   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function StEAN()
i_print(00,00,tEsc+[2Z])
ret_pa010()
return(stat_op())


/*

          Cap¡tulo IV  -  Comandos Relacionados com Parametrizacao


ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Parametrizacao de Cliche (Leitura/Escrita)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function ParCliche(tipo,ordem,tam,texto)
i_print(00,00,tEsc+[3C]+tipo+ordem+iif(tipo=[L],[],tam+texto))
return(ret_pa010())

/*
Indices:
         0 - Nome da Empresa     [48] *
         1 - Inscricao Federal   [16] *
         2 - Inscricao Estadual  [18] *
         3 - Inscricao Municipal [40]
         4 - Area de Endereco 1  [48] *
         5 - Endereco 2          [48]
         6 - Numero do ECF       [04] *

         * Campo Obrigatorio


ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Parametrizacao do Numero de Digitos de Item (7/0 ou 9/1 def)          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function ParNumDig(tipo)
i_print(00,00,tEsc+[3D]+tipo)
ret_pa010()
return(stat_op())

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Parametrizacao de Codigo Padrao EAN13/0 ou EAN8/1                     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function ParEAN(tipo)
i_print(00,00,tEsc+[3E]+tipo)
ret_pa010()
return(stat_op())

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Parametrizacao do Indice de ICMS                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function ParIndice(tipo,indice,vlr)
i_print(00,00,tEsc+[3I]+tipo+indice)
if tipo=[E]
   i_print(00,00,strzero(vlr*100,4))
endif
ret_pa010()
return(stat_op())

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Parametrizacao de Mensagem Promocional (1 a 8 linhas)                 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function ParMensagem(tipo,linha,texto)
i_print(00,00,tEsc+[3M]+tipo+linha+texto)
ret_pa010()
return(stat_op())

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Parametrizacao de Impressao com Ponto (c/1 ou s/0)                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function ParImpPonto(tipo)
i_print(00,00,tEsc+[3P]+tipo)
ret_pa010()
return(stat_op())

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Parametrizacao p/ Treinamento                                         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function ParTreino()
i_print(00,00,tEsc+[3T])
ret_pa010()
return(stat_op())

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Parametrizacao de Horario de Verao (Entrada/Saida) E/S                ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function HoraVerao(operacao)
If C_VSeqImp=1
   i_print(00,00,tEsc+[3V]+operacao)
   ret_pa010()
   return(stat_op())
ElseIf C_VSeqImp=2
   Return (bt_hora())
Endif

/*

    Capitulo VI - Comandos Relacionados a Operacoes Nao Sujeitas ao ICMS

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Abre Cupom Nao Sujeito ao ICMS                                        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Function AbreSIcms(tipo)
If C_VSeqImp=1
   I_print(00,00,tEsc+[7N]+tipo)
   Ret_pa010()
   Return(Stat_op())
ElseIf C_VSeqImp=2
   Return if(Bt_AbreSIcms(),[0],[1])
Endif

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Fecha Cupom Nao Sujeito ao ICMS                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function FechaSIcms()
If C_VSeqImp=1
   i_print(00,00,tEsc+[7F])
   ret_pa010()
   return(stat_op())
ElseIf C_VSeqImp=2
   Return Bt_FechaSIcms()
Endif
/*

                  Capitulo V - Leituras Diversas

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Leitura da Data do Sistema                                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function LdData()
If C_VSeqImp=1
   i_print(00,00,tEsc+[4D])
   return(ret_pa010())
ElseIf C_VSeqImp=2
   Return dtoc(bt_data())
Endif

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Identificacao do Firmware                                             ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function LdFirmware()
If C_VSeqImp=1
   i_print(00,00,tEsc+[4F])
   return(ret_pa010())
ElseIf C_VSeqImp=2
   Return (Bt_Versao())
Endif

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Leitura da Hora do Sistema                                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function LdHora()
If C_VSeqImp=1
   i_print(00,00,tEsc+[4H])
   return(ret_pa010())
ElseIf C_VSeqImp=2
   Return (Bt_Hora())
Endif

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Leitura do Numero de Serie do Equipamento                             ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function LdSerie()
i_print(00,00,tEsc+[4S])
return(ret_pa010())

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Leitura do Totalizador Fiscal                                         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function LdTotalizador(numero)
Local Valor:=0
If C_VSeqImp=1
   i_print(00,00,tEsc+[4T]+numero)
   return(ret_pa010())
ElseIf C_VSeqImp=2
   bt_LerTIcm(Numero,@Valor)
   Return Valor
Endif



/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Leitura do Totalizador Virtual                                        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
function LdTotalVirt(numero)
i_print(00,00,tEsc+[4V]+numero)
return(ret_pa010())

********************

function pa010_ret()
LOCAL cBuffer:=SPACE(41)
LOCAL nCodRet:=0
//nCodRet:=RdPdvBuf(cBuffer)
return left(cBuffer,1)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ FUNCTION RET_PA010                                                    ³
³ ==================                                                    ³
³                                                                       ³
³ Objetivo  : Le Buffer da PA010                                        ³
³ Parametros: Nil (Void)                                                ³
³                                                                       ³
³ Retorna...: Buffer Lido                                               ³
³                                                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

FUNCTION RET_PA010
LOCAL cBuffer := SPACE(41)
LOCAL nCodRet := 0
//nCodRet := RdPdvBuf(cBuffer)
STAT_OP(LEFT(cBuffer,1))
RETURN SUBS(cBuffer,2)

/*
Aadd(Vet,[])
Aadd(Vet,[])
Sele 4
Set Order to 1
Seek StrZero(val(MCodCli),4)
If !Found()
   Aviso_1( 13,, 18,, [Aten‡„o!], "Nao Exite Duplicatas deste Cliente!", { [  ^Ok!  ] }, 1, .t., .t. )
   RestScreen( 05, 02, 19, 72, Tel_Ant )
   SetCursor( 1 )
   Return .f.
EndIf
Do While !Eof() .and. CodCli == StrZero(val(MCodCli),4)
   If !Empty(DtaPag)
      Skip
      Loop
   EndIf
   If DtaVen<=Date()
      AAdd( Vet, [*]+[Dup.] + Pad(NumDup,12) + [ ] + Transf( ValDup, [@e 99,999,999.99] ) + [ - ] + DtoC( DtaVen ) )
      MTotVen+=ValDup
   Else
      AAdd( Vet, [ ]+[Dup.] + Pad(NumDup,12) + [ ] + Transf( ValDup, [@e 99,999,999.99] ) + [ - ] + DtoC( DtaVen ) )
      MTotAvc+=ValDup
   EndIf
   Skip
EndDo
Cor_Ext:=SetColor(C_CDFnd)
Vet[1]=[ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄRÄEÄSÄUÄMÄOÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ]
Vet[2]=[Total A vencer......: ]+Transf(MTotAvc, [@R 999,999,999.99])
Vet[3]=[Total Vencidos......: ]+Transf(MTotVen, [@R 999,999,999.99])
Vet[4]=[Limite de Credito...: ]+Transf(MLimCre, [@R 999,999,999.99])
Vet[5]=[Disponivel p/ Compra: ]+Transf(MLimCre-(MTotAvc+MTotVen), [@R 999,999,999.99])
N_Vet = Len(Vet)
If N_Vet>6
   Vet[6]=[ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄEÄXÄTÄRÄAÄTÄOÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ]
Else
   Adel(Vet[6])
   N_Vet--
Endif
AChoice( 08, 03, 18, 71, Vet )
SetColor(Cor_Ext)
RestScreen( 05, 02, 19, 72, Tel_Ant )
SetCursor( 1 )
*/

FUNCTION STAT_OP(_CodRet_)
STATIC cRetPa10 := ""
LOCAL cOldRtPa10 := ""
IF _CodRet_ == NIL
   RETURN cRetPa10
ENDIF
cOldRtPa10 := cRetPa10
cRetPa10   := _CodRet_
* --- Trata os codigos de retorno
DO CASE
   CASE EMPTY(cRetPa10)           // PA010 nao devolveu codigo de retorno
   ?
   CASE cRetPa10 = "2"            // Erro CMOS (CHECK-SUM)
   ?
   CASE cRetPa10 = "3"            // Impressora sem papel
        Aviso_1( 13,, 18,, [Aten‡„o!], "Fim de papel. Instale uma nova Bobina!", { [  ^Ok!  ] }, 1, .t., .t. )
        i_print(0,0,chr(27)+[O])
   CASE cRetPa10 = "4"            // Terminal sob intervencao tecnica
   ?
   CASE cRetPa10 = "6"            // Totalizadores perdidos (CMOS)
   ?
   CASE cRetPa10 = "7"            // TIME-OUT de impressora
        Aviso_1( 13,, 18,, [Aten‡„o!], "Time-Out de Impressora", { [  ^Ok!  ] }, 1, .t., .t. )
   CASE cRetPa10 = "8"            // Comando invalido
   ?
ENDCASE

RETURN(cOldRtPa10)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ FUNCTION CMOS_DISP                                                    ³
³ ==================                                                    ³
³                                                                       ³
³ Objetivo  : Obter quantidade de CMOS Disponivel                       ³
³ Parametros: Nil (Void)                                                ³
³                                                                       ³
³ Retorna...: Quantidade de CMOS Disponivel                             ³
³                                                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

FUNCTION CMOS_DISP
LOCAL nBytesCmos := 0
i_print(0,0,chr(27)+[ZT])
nBytesCmos:=VAL(RET_PA010())
IF STAT_OP()#"0"
   RETURN 0
ELSE
   RETURN nBytesCmos
ENDIF

FUNCTION TOT(NUMERO)
LOCAL VALOR:=0.00
VALOR=VAL(LdTotalizador(NUMERO))/100
return(VALOR)

Function Salta_Picote
If C_VSeqImp=1
   I_PRINT(00,00,Replicate(chr(10),7))
ElseIf C_VSeqImp=2
   I_PRINT(00,00,Replicate(chr(10)+chr(13),7))
Endif
Return Nil


*******************************************************************************
*               C O M A N D O S   E C F   Z A N T H U S   QZ100               *
*******************************************************************************

Function Imp_Z(Buffer,Ret,Pos1,Tam)
Pos1:=IIf(Pos1=Nil,1,Pos1)
Tam :=IIf(Pos1=Nil,128,Tam)
FD := FOpen('EASYAPF', 2)
FWrite(FD, @Buffer, Len(Buffer))
Retorno := [E]
If Ret
   Retorno := FReadStr(FD,128)
   Retorno := Substr(Retorno,Pos1,Tam)
EndIf
FClose(FD)
Return(Retorno)
