/*************************************************************************
         Sistema: Administrativo
          Versao: 2.00
   Identificacao: Modulo de Rotinas
         Prefixo: LtSCC
        Programa: ROTINAS.PRG
           Autor: Andre Lucas Souza
            Data: 16 DE NOVEMBRO DE 2002
   Copyright (C): LUCAS Tecnologia  - 2002
*/
#include "lucas.CH"       // Inclusao do Arquivo Header Padrao
#include "inkey.ch"
#include "setcurs.ch"

procedure teste2

    OpenSequencia()
                        cStat     := RetornoSEFAZ("CStat",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
                        cXMotivo  := RetornoSEFAZ("XMotivo",rtrim(Sequencia->dirNFe)+"\sainfe.txt") 
                        cChNFe    := RetornoSEFAZ("ChNFe",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
                        cNProt    := RetornoSEFAZ("NProt",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
                        cDhRecbto := RetornoSEFAZ("DhRecbto",rtrim(Sequencia->dirNFe)+"\sainfe.txt")
    
    
    Mens({cChNfe})
    FechaDados()
    return 
    
procedure teste

    Mens({"row() :"+str(wvw_maxmaxrow()+1),"col() :"+str(wvw_maxmaxcol()+1),;
    (WVW_GetFontInfo())[1]})
    return


function LerDadosEmpresa(lAbrir)
    local lVazio

   if lAbrir
      if !(Abre_Dados(cDiretorio,"empresa",0,0,"empresa",0,.f.) == 0)
         FechaDados()
         Msg(.f.)
         return(.f.)
      endif
   endif
	cEmpRazao     := Empresa->Razao
    cEmpFantasia  := iif(empty(Empresa->Fantasia),"Empresa Nao Definida",Empresa->Fantasia)    
	cEmpEndereco  := Empresa->Endereco 
	cEmpnumero    := Empresa->numero   
	cEmpComplend  := Empresa->Complend 
	cEmpBairro    := Empresa->Bairro   
	cEmpCodcid    := Empresa->Codcid   
	cEmpEstCid    := Empresa->EstCid
	cEmpCep       := Empresa->Cep
	cEmpTelefone1 := Empresa->Telefone1
	cEmpTelefone2 := Empresa->Telefone2
	cEmpEmail     := Empresa->Email
	cEmpCnpj      := Empresa->Cnpj     
	cEmpIe        := Empresa->Ie       
	cEmpIm        := Empresa->Im       
	cEmpCnae      := Empresa->Cnae     
	cEmpCrt       := Empresa->Crt      
    if lAbrir
        Empresa->(dbclosearea())
    endif
    return(.t.)             

function AtivaF9
   setkey( K_F9, { |pcProg,pnLine,pcVar| AtivaFisc() } )
   return(NIL)
// ****************************************************************************
function DesativaF9
   setkey(K_F9,NIL)
   return(NIL)

procedure CriarDbf
    
    DbfPdvNfce()
    DbfPdvNfceItem()
    return

static procedure DbfPdvNFceItem
    local aStru := {}
    
    if !file(cDiretorio+"pdvnfceitem.dbf")
        aadd(aStru,{"lanc","C",10,00})
        aadd(aStru,{"CodItem","c",13,0})  // Codigo do item
        aadd(aStru,{"CODPRO","C",06,00})  // Codigo do produto
        aadd(aStru,{"QTDPRO","N",015,03}) // Quantidade do item
        aadd(aStru,{"pcoven","n",015,03}) // pre�o de venda
        aadd(aStru,{"dscpro","n",06,02}) // % desconto
        aadd(aStru,{"pcoliq","n",15,03}) // pre�o l�quido
        aadd(aStru,{"desconto","n",15,02}) // valor do desconto
        aadd(aStru,{"totpro","n",15,02}) // pre�o total
        aadd(aStru,{"cst","c",03,0})
        
        aadd(aStru,{"aliquota","n",05,2})
        aadd(aStru,{"baseicms","n",15,3}) // base de icms
        aadd(aStru,{"valoricms","n",15,2})
        dbcreate(cDiretorio+"pdvnfceitem",aStru)
    endif
    return

static procedure DbfPdvNFce
    local aStru := {}
    
    if !file(cDiretorio+"pdvnfce.dbf")
        aadd(aStru,{"lanc"      ,"C",10,0})
        aadd(aStru,{"nfce","c",09,0})
        aadd(aStru,{"serie","c",03,0})
        aadd(aStru,{"CodNat","c",03,0}) // codigo da natureza de opera��o
        aadd(aStru,{"CODOPE","C",002,00})
        aadd(aStru,{"data","D",008,00})  // data de emissao
        aadd(aStru,{"hora","C",008,00})  // hora de emissao
        aadd(aStru,{"TOTCUP","N",015,02}) // valor total
        aadd(aStru,{"CANCUP","C",001,00})
        aadd(aStru,{"TOTDES","N",015,02}) // total do desconto
        aadd(aStru,{"TRANSF","L",001,00})
        aadd(aStru,{"VLRDIN","N",015,02}) // Valor em Dinheiro
        aadd(aStru,{"VLRCHV","N",015,02})
        aadd(aStru,{"VLRCHP","N",015,02})
        aadd(aStru,{"VLRCAR","N",015,02})
        aadd(aStru,{"VLRTRO","N",015,02})
        aadd(aStru,{"VLRCRE","N",015,02})
        aadd(aStru,{"VLRTIK","N",015,02})
        aadd(aStru,{"TIPCAR","C",014,00})
        aadd(aStru,{"CGCCPF","C",014,00})
        aadd(aStru,{"STATUS","C",010,00})
        aadd(aStru,{"VTROCO","N",015,02})
        aadd(aStru,{"NUMPED","C",010,00})
        aadd(aStru,{"NUMODS","C",010,00})
        aadd(aStru,{"CODVEN","C",002,00})
        aadd(aStru,{"chave","C",044,000}) // chave de acesso
		aadd(aStru,{"AUTORIZADO" ,"L",001,000})
        aadd(aStru,{"CANCELADA"   ,"L",001,000})
		aadd(aStru,{"CSTAT","C",003,000})
		aadd(aStru,{"NREC","C",020,000})
		aadd(aStru,{"XMOTIVO","C",100,000})
		aadd(aStru,{"DHRECBTO","C",040,000})
		aadd(aStru,{"NPROT"       ,"C",040,000})
		aadd(aStru,{"NPROTCA"     ,"C",015,000})
		aadd(aStru,{"DHRECBTOCA"  ,"C",010,000})
		aadd(aStru,{"CSTATCA"     ,"C",003,000})
		aadd(aStru,{"OBSCAN1"     ,"C",080,000})
		aadd(aStru,{"OBSCAN2"     ,"C",080,000})
		aadd(aStru,{"OBSCAN3"     ,"C",080,000})
        aadd(aStru,{"codcli","c",04,0})
        aadd(aStru,{"geral","l",01,0})
        dbcreate(cDiretorio+"pdvnfce",aStru)
    endif
    return


function Round2(nValor,nDecimal)
   nDecimal := 7-nDecimal
   nvalor := substr(str(nvalor,20,7),1,(20-nDecimal))
   return(val(nvalor))
// *****************************************************************************
function SUB_BANNER(LIN,COL,STRING,ESPACEJAMENTO)
PRIVATE LEN_CARAC,NUM,I
DECLARE L[4],S[4]
IF PCOUNT() = 3
   ESPACEJAMENTO = 1
ENDIF
AFILL(S,"")
FOR I = 1 TO LEN(STRING)
    NUM = SUBS(STRING,I,1)
    IF NUM = " "
       L[1] =  "   "
       L[2] =  "   "
       L[3] =  "   "
       L[4] =  "   "
    ELSEIF NUM = "-"
       L[1] =  "   "
       L[2] =  "���"
       L[3] =  "   "
       L[4] =  "   "
    ELSEIF NUM = "1"
       L[1] =  "�� "
       L[2] =  " � "
       L[3] =  " � "
       L[4] =  "���"
    ELSEIF NUM = "2"
       L[1] =  "���"
       L[2] =  "���"
       L[3] =  "�  "
       L[4] =  "���"
    ELSEIF NUM = "3"
       L[1] =  "���"
       L[2] =  "���"
       L[3] =  "  �"
       L[4] =  "���"
    ELSEIF NUM = "4"
       L[1] =  "� �"
       L[2] =  "���"
       L[3] =  "  �"
       L[4] =  "  �"
    ELSEIF NUM = "5"
       L[1] =  "���"
       L[2] =  "���"
       L[3] =  "  �"
       L[4] =  "���"
    ELSEIF NUM = "6"
       L[1] =  "�  "
       L[2] =  "���"
       L[3] =  "� �"
       L[4] =  "���"
    ELSEIF NUM = "7"
       L[1] =  "���"
       L[2] =  "  �"
       L[3] =  "  �"
       L[4] =  "  �"
    ELSEIF NUM = "8"
       L[1] =  "���"
       L[2] =  "���"
       L[3] =  "� �"
       L[4] =  "���"
    ELSEIF NUM = "9"
       L[1] =  "���"
       L[2] =  "���"
       L[3] =  "  �"
       L[4] =  "���"
    ELSEIF NUM = "0"
       L[1] =  "���"
       L[2] =  "� �"
       L[3] =  "� �"
       L[4] =  "���"
    ELSEIF NUM = ":"
       L[1] =  " "
       L[2] =  "�"
       L[3] =  "�"
       L[4] =  " "
    ELSEIF NUM = ","
       L[1] =  "  "
       L[2] =  "  "
       L[3] =  "  "
       L[4] =  "��"
    ELSEIF NUM = "."
       L[1] =  " "
       L[2] =  " "
       L[3] =  " "
       L[4] =  "�"
    ENDIF
    S[1] = S[1] + L[1] + SPACE(ESPACEJAMENTO)
    S[2] = S[2] + L[2] + SPACE(ESPACEJAMENTO)
    S[3] = S[3] + L[3] + SPACE(ESPACEJAMENTO)
    S[4] = S[4] + L[4] + SPACE(ESPACEJAMENTO)
    IF NUM = ","
       S[1] = SPACE(1) + S[1]
       S[2] = SPACE(1) + S[2]
       S[3] = SPACE(1) + S[3]
       S[4] = SPACE(1) + S[4]
    ELSEIF NUM = "."
       S[1] = SPACE(2) + S[1]
       S[2] = SPACE(2) + S[2]
       S[3] = SPACE(2) + S[3]
       S[4] = SPACE(2) + S[4]
    ENDIF
NEXT I
S[1] = SUBS(S[1] , 1 , LEN(S[1]) - ESPACEJAMENTO)
S[2] = SUBS(S[2] , 1 , LEN(S[2]) - ESPACEJAMENTO)
S[3] = SUBS(S[3] , 1 , LEN(S[3]) - ESPACEJAMENTO)
S[4] = SUBS(S[4] , 1 , LEN(S[4]) - ESPACEJAMENTO)
@ LIN  ,COL SAY S[1]
@ LIN+1,COL SAY S[2]
@ LIN+2,COL SAY S[3]
@ LIN+3,COL SAY S[4]
RETURN

// *****************************************************************************


procedure ConProdutoPdv(lAbrir,lRetorno,lTabela)
   local getlist := {},oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados1
   local cDados2,nCursor := setcursor(),cCor := setcolor(),lTop,cTela2,lSaiMenu
   local aItem[05],aCampo := {},aTitulo := {},aMascara := {}
   local nLinhaI,nColunaI,nLinhaF,nColunaF,nI

   private nRecno

   setcursor(SC_NONE)
   select Produtos
    if !lGeral  // Fiscal
        set order to 8
        //set order to 6
        //dbsetfilter({ || Produtos->QteAc01 > 0})
    else
        set order to 7
        //set order to 6
        //dbsetfilter({|| Produtos->QteAc02 > 0})
    endif
   goto top
   Rodape("Esc-Encerra | ENTER-Transfere")
   nLinhaI  := 04
   nColunaI := 00
   nLinhaF  := maxrow()-1
   nColunaF := 100
   lRetorno := iif(lRetorno == NIL,.f.,lRetorno)
   n_Itens := lastrec()
   Pos := 1
   setcolor(cor(2))
   Window(nLinhaI,nColunaI,nLinhaF,nColunaF," Consulta de Produtos ")
   oBrow := TBrowseDB(nLinhaI+1,nColunaI+1,nLinhaF-1,nColunaF-1)
   oBrow:headSep := chr(194)+chr(196)
   oBrow:colSep  := chr(179)
   oBrow:footSep := chr(193)+chr(196)
   oBrow:colorSpec := Cor(2)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)

   oColuna := tbcolumnnew("C�digo", {|| Produtos->CodPro })
   oColuna:colorblock := {|| iif( Produtos->QteAc01 == 0,{3,2},{1,2})}
   oBrow:addcolumn(oColuna)

   oColuna := tbcolumnnew("Descri��o" ,{|| Produtos->FanPro})
   oColuna:colorblock := {|| iif( Produtos->QteAc01 == 0,{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   
   	oColuna := tbcolumnnew("Emb. x Qtde.",{|| Produtos->EmbPro+" x "+str(Produtos->QteEmb,3)  })
	oColuna:colorblock := {|| iif( Produtos->QteAc01 == 0,{3,2},{1,2})}
	oBrow:addcolumn(oColuna)

   oColuna := tbcolumnnew("Pre�o",{|| transform(Produtos->PcoCal,"@e 99,999.99")})
   oColuna:colorblock := {|| iif( Produtos->QteAc01 == 0,{3,2},{1,2})}
   oBrow:addcolumn(oColuna)
   
    if !lGeral  // estoque Fiscal
        oColuna := tbcolumnnew("Estoque",{|| transform(Produtos->QteAc01,"@e 999,999.999")})
        oColuna:colorblock := {|| iif( Produtos->QteAc01 == 0,{3,2},{1,2})}
        oBrow:addcolumn(oColuna)
    else  // estoque fisico
        oColuna := tbcolumnnew("Estoque",{|| transform(Produtos->QteAc02,"@e 999,999.999")})
        oColuna:colorblock := {|| iif( Produtos->QteAc02 == 0,{3,2},{1,2})}
        oBrow:addcolumn(oColuna)
    endif    
    AddKeyAction(K_ESC,    {|| lFim := .t.})
    AddKeyAction(K_ALT_X,  {|| xTecla := ""})
    AddKeyAction(K_CTRL_H, {|| if((nLen := len(xTecla)) > 0,((xTecla := substr(xTecla, 1, --nLen)), Produtos->(SeekIt(xTecla,.T.,oBrow))),NIL) })
    xTecla := ""
    do WHILE (! lFim)
        @ nLinhaF,nColunaI+1 say padr("[ Pesquisar: "+ xTecla,53)+"]" color Cor(11)
        ForceStable(oBrow)
        if ( obrow:hittop .or. obrow:hitbottom )
            tone(1200,1)
        endif
        aRect := { oBrow:rowPos,1,oBrow:rowPos,5}
        oBrow:colorRect(aRect,{2,2})
        cTecla := chr((nTecla := inkey(0)))
        if (nTecla >= 32 .and. nTecla <= 93) .or. (nTecla >= 96 .and. nTecla <= 125)
            if nTecla >= 97 .and. nTecla <= 122
                cTecla := chr(nTecla-32)
            endif
        endif
        if !OnKey( nTecla,oBrow)
            if !(nTecla == K_ENTER)
                if (nTecla >= 32 .and. nTecla <= 93) .or. (nTecla >= 96 .and. nTecla <= 125)
                    xTecla += cTecla
                    nRec := Produtos->(Recno())
                    if !Produtos->(SeekIt(xTecla,.T.,obrow))
                        Produtos->(dbgoto(nRec))
                    endif
                endif
            endif
        endif
        if nTecla == K_ENTER
            cDados := Produtos->CodPro
            keyboard (cDados)+chr(K_ENTER)
            lFim := .t.
        elseif nTecla == K_ESC
            lFim := .t.
        endif
        oBrow:refreshcurrent()
    enddo
    //Produtos->(DbClearFilter())
   setcursor(nCursor)
   setcolor(cCor)
   RestWindow( cTela )
   return

procedure View(pcProc,pnLine,pcVar)

   if pcProc $ "VENDAS" .and. pcVar $ "CCODITM"
      ConProdutoPDV(.f.)
   endif
   return

function tesc(logica)
*SET CURSOR ON
*RETURN .T.
if logica=0
   set cursor on
elseif logica=1
   set cursor off
endif
return(.t.)


procedure ConfiguraAmbiente2
GTSetupFonte()
return

procedure ConfiguraAmbiente
    local nResult,hIni,cFonte,nAltura,nLargura,nPeso,nLinhas
    local nColunas,lCarregouFonte


    if !file("ltpdv"+netname()+".ini")
        hIni := Hash()
        hIni["Ambiente"]            := Hash()
        hIni["Ambiente"]["Fonte"]   := "Courier New"
        hIni["Ambiente"]["Altura"]  := "20"
        hIni["Ambiente"]["Largura"] := "10"
        hIni["Ambiente"]["Peso"]    := "400"
        hIni["Ambiente"]["Linhas"]  := "35"
        hIni["Ambiente"]["Colunas"] := "101"
        HB_WriteIni( "ltpdv"+netname()+".ini", hIni,,,.f.)
    endif
    hIni := HB_ReadIni("ltpdv"+netname()+".ini",,,.f.)
    cFonte  := hIni["Ambiente"]["Fonte"] 
    nAltura := val(hIni["Ambiente"]["Altura"])
    nLargura := val(hIni["Ambiente"]["Largura"]) 
    nPeso := val(hIni["Ambiente"]["Peso"])
    nLinhas := val(hIni["Ambiente"]["Linhas"]) 
    nColunas := val(hIni["Ambiente"]["Colunas"])  
    p_nNormalMaxrow := val(hIni["Ambiente"]["Linhas"]) 
    n_nNormalMaxcol := val(hIni["Ambiente"]["Colunas"]) 
    lCarregouFonte := wvw_SetFont(,cFonte,nAltura,nLargura) //, DEFAULT_QUALITY )
    
    //a := wvw_SetFont(,'Courier New' ,20,10) //, DEFAULT_QUALITY )
    //wvw_SetFont('Lucida Console' , 20, 10,400) //, DEFAULT_QUALITY )
/*    
	aLixo := WVW_GetFontInfo()
	? aLixo[1], " cFontFace Nome da fonte ( por ex. Arial )."
	? alixo[2], " cFontHeight Altura da fonte. "
	? alixo[3], " nFontWidth Largura da fonte."
	? alixo[4], " nFontWieght Peso da fonte."
	? alixo[5], " cFontQuality Qualidade da fonte."
	? alixo[6], " PTEXTSIZE->x Largura da fonte em pixels."
	? alixo[7],"  PTEXESIZE->y Tamanho da fonte em pixels"
	
	inkey(0)
*/
    if !lCarregouFonte
        Mens({"Problema com a Fonte"})
        clear
        quit
    endif
    wvw_NoClose()
    wvw_size_ready(.t.)
    wvw_setmaincoord(.T.)
	WVW_SetCodePage(,255)
	wvw_settitle( , "LT-PDV - Modulo de Vendas" )
	//lResult := setmode(wvw_maxmaxrow()+1,wvw_maxmaxcol()+1)
    //lResult := setmode(p_nNormalMaxrow, p_nNormalMaxcol)
    //lResult := setmode(nLinhas,nColunas)
    lResult := setmode(p_nNormalMaxrow,p_nNormalMaxcol)
    
    if !lResult
        Mens({"Problema com o setmode"})
        FechaDados()
        clear
        quit
    endif
    return

   
Function GTSetupFonte()
   Local nFontHeight, nFontWidth
   nFontHeight := Int( WVW_GetScreenHeight() - 76 ) / 40
   nFontWidth  := Int( WVW_GetScreenWidth() - 1 ) / 120
   WVW_SetFont(,"Courier New", nFontHeight, nFontWidth )
   WVW_setcodepage(, 255)
   setmode(40,120)
   Return NIL
   
   
//
// FUNCAO     : WVW_Size()
// PARAMETROS : nWindow - N� da janela
//              hWnd    -
//              message -
//              wParam  -
//              lParam  -
// DESCRICAO  : Funcao CALLBACK que eh chamada depois que o tamanho da janela eh
//              alterado ( como quando for maximizada ou minimizada )
// RETORNO    :
//
***********************************************************
FUNCTION WVW_SIZE( nWindow, hWnd, message, wParam, lParam )
***********************************************************
   local cScreen, maxsavedscrrow, maxsavedscrcol, lNeedReset := .f.

   if !WVW_SIZE_READY()
      return NIL
   endif
   if nWindow # 0
      return NIL
   endif

   WVW_SIZE_READY(.F.)

   do case
      case wParam == 2 // Maximizar a janela
         if ( maxcol() # wvw_maxmaxcol() .or. maxrow() # wvw_maxmaxrow() )
            maxsavedscrrow := min( min( p_nNormalMaxrow, wvw_maxmaxrow() ), maxrow() )
            maxsavedscrcol := min( min( p_nNormalMaxcol, wvw_maxmaxcol() ), maxcol() )
            cScreen        := savescreen( 0, 0, maxsavedscrrow,  maxsavedscrcol )
            if setmode( wvw_maxmaxrow()+1, wvw_maxmaxcol()+1 )
               restscreen( 0, 0, maxsavedscrrow, maxsavedscrcol, cScreen )
            endif
         endif
      case wParam == 0 // Restaurar o Tamanho da Janela
         if ( maxcol() # p_nNormalMaxcol .or. maxrow() # p_nNormalMaxrow )
            maxsavedscrrow := min( p_nNormalMaxrow, maxrow() )
            maxsavedscrcol := min( p_nNormalMaxcol, maxcol() )
            cScreen        := savescreen( 0, 0, maxsavedscrrow, maxsavedscrcol )
            if setmode( p_nNormalMaxrow+1, p_nNormalMaxcol+1 )
               restscreen( 0, 0, maxsavedscrrow, maxsavedscrcol, cScreen )
            endif
         endif
      otherwise
   endcase
   WVW_SIZE_READY(.T.)
RETURN NIL
   
   
   
   
FUNCTION BANNER( nLin, cString, cCor )
LOCAL aChar[128][6],cTxt,i,nLinha,cCorAnt
LOCAL aTxt := {}, nMaxLin := nCol := 0

cCorAnt := SETCOLOR()

AEVAL(aChar, { | a | a[1] := "", a[2] := "", a[3] := "", a[4] := "", a[5] := "", a[6] := ""})

aChar[32][1] = "      "
aChar[32][2] = "      "
aChar[32][3] = "      "
aChar[32][4] = "      "
aChar[32][5] = "      "
aChar[32][6] = "      "

aChar[33][1] = "  ��Ŀ  "
aChar[33][2] = "  �� �  "
aChar[33][3] = "  �� �  "
aChar[33][4] = "   ���  "
aChar[33][5] = "  ��Ŀ  "
aChar[33][6] = "   ���  "

aChar[34][1] = " �ۿ �ۿ"
aChar[34][2] = " �ݳ �ݳ"
aChar[34][3] = "  ��  ��"
aChar[34][4] = "        "
aChar[34][5] = "        "
aChar[34][6] = "        "

aChar[39][1] = "  �ۿ  "
aChar[39][2] = "  �ݳ  "
aChar[39][3] = "   ��  "
aChar[39][4] = "       "
aChar[39][5] = "       "
aChar[39][6] = "       "

aChar[44][1] = "        "
aChar[44][2] = "        "
aChar[44][3] = "        "
aChar[44][4] = "        "
aChar[44][5] = "  ��Ŀ  "
aChar[44][6] = "   ���  "

aChar[45][1] = "        "
aChar[45][2] = "        "
aChar[45][3] = "������Ŀ"
aChar[45][4] = " �������"
aChar[45][5] = "        "
aChar[45][6] = "        "

aChar[46][1] = "        "
aChar[46][2] = "        "
aChar[46][3] = "        "
aChar[46][4] = "        "
aChar[46][5] = "  ��Ŀ  "
aChar[46][6] = "   ���  "

aChar[47][1] = "    �����"
aChar[47][2] = "   ����� "
aChar[47][3] = "  �����  "
aChar[47][4] = " �����   "
aChar[47][5] = "�����    "
aChar[47][6] = "����     "

aChar[48][1] = "������Ŀ"
aChar[48][2] = "�� ��� �"
aChar[48][3] = "�� ��� �"
aChar[48][4] = "�� ��� �"
aChar[48][5] = "������ �"
aChar[48][6] = " �������"

aChar[49][1] = "����Ŀ  "
aChar[49][2] = " ��� �  "
aChar[49][3] = "  �� �  "
aChar[49][4] = "  �� �  "
aChar[49][5] = "������Ŀ"
aChar[49][6] = " �������"

aChar[50][1] = "������Ŀ"
aChar[50][2] = " ����� �"
aChar[50][3] = "������ �"
aChar[50][4] = "�� �����"
aChar[50][5] = "������Ŀ"
aChar[50][6] = " �������"

aChar[51][1] = "������Ŀ"
aChar[51][2] = " ����� �"
aChar[51][3] = "������ �"
aChar[51][4] = " ����� �"
aChar[51][5] = "������ �"
aChar[51][6] = " �������"

aChar[52][1] = "�ۿ ��Ŀ"
aChar[52][2] = "�۳ �� �"
aChar[52][3] = "������ �"
aChar[52][4] = " ����� �"
aChar[52][5] = "    �� �"
aChar[52][6] = "     ���"

aChar[53][1] = "������Ŀ"
aChar[53][2] = "�� �����"
aChar[53][3] = "������Ŀ"
aChar[53][4] = " ����� �"
aChar[53][5] = "������ �"
aChar[53][6] = " �������"

aChar[54][1] = "������Ŀ"
aChar[54][2] = "�� �����"
aChar[54][3] = "������Ŀ"
aChar[54][4] = "�� ��� �"
aChar[54][5] = "������ �"
aChar[54][6] = " �������"

aChar[55][1] = "������Ŀ"
aChar[55][2] = " ����� �"
aChar[55][3] = "    �� �"
aChar[55][4] = "    �� �"
aChar[55][5] = "    �� �"
aChar[55][6] = "     ���"

aChar[56][1] = "������Ŀ"
aChar[56][2] = "�� ��� �"
aChar[56][3] = "������ �"
aChar[56][4] = "�� ��� �"
aChar[56][5] = "������ �"
aChar[56][6] = " �������"

aChar[57][1] = "������Ŀ"
aChar[57][2] = "�� ��� �"
aChar[57][3] = "������ �"
aChar[57][4] = " ����� �"
aChar[57][5] = "    �� �"
aChar[57][6] = "     ���"

aChar[58][1] = "        "
aChar[58][2] = "  ��Ŀ  "
aChar[58][3] = "   ���  "
aChar[58][4] = "  ��Ŀ  "
aChar[58][5] = "   ���  "
aChar[58][6] = "        "

aChar[59][1] = "��Ŀ"
aChar[59][2] = " ���"
aChar[59][3] = "    "
aChar[59][4] = "    "
aChar[59][5] = "��Ŀ"
aChar[59][6] = " ���"

aChar[61][1] = "        "
aChar[61][2] = "������Ŀ"
aChar[61][3] = " �������"
aChar[61][4] = "������Ŀ"
aChar[61][5] = " �������"
aChar[61][6] = "        "

aChar[65][1] = "��������"
aChar[65][2] = "���ۿ���"
aChar[65][3] = "��������"
aChar[65][4] = "���ۿ���"
aChar[65][5] = "���۳���"
aChar[65][6] = "��������"

aChar[66][1] = "��������"
aChar[66][2] = "���ۿ���"
aChar[66][3] = "��������"
aChar[66][4] = "���ۿ���"
aChar[66][5] = "��������"
aChar[66][6] = "��������"

aChar[67][1] = "�������"
aChar[67][2] = "�������"
aChar[67][3] = "����   "
aChar[67][4] = "����   "
aChar[67][5] = "�������"
aChar[67][6] = "�������"

aChar[68][1] = "������� "
aChar[68][2] = "���ۿ���"
aChar[68][3] = "���۳���"
aChar[68][4] = "���۳���"
aChar[68][5] = "������� "
aChar[68][6] = "������  "

aChar[69][1] = "�������"
aChar[69][2] = "�������"
aChar[69][3] = "������ "
aChar[69][4] = "������ "
aChar[69][5] = "�������"
aChar[69][6] = "�������"

aChar[70][1] = "�������"
aChar[70][2] = "�������"
aChar[70][3] = "������ "
aChar[70][4] = "������ "
aChar[70][5] = "����   "
aChar[70][6] = "����   "

aChar[71][1] = "��������"
aChar[71][2] = "��������"
aChar[71][3] = "��������"
aChar[71][4] = "���۳���"
aChar[71][5] = "��������"
aChar[71][6] = "������� "

aChar[72][1] = "��������"
aChar[72][2] = "���۳���"
aChar[72][3] = "��������"
aChar[72][4] = "���ۿ���"
aChar[72][5] = "���۳���"
aChar[72][6] = "��������"

aChar[73][1] = "����"
aChar[73][2] = "����"
aChar[73][3] = "����"
aChar[73][4] = "����"
aChar[73][5] = "����"
aChar[73][6] = "����"

aChar[74][1] = "    ����"
aChar[74][2] = "    ����"
aChar[74][3] = "    ����"
aChar[74][4] = "���۳���"
aChar[74][5] = "��������"
aChar[74][6] = "��������"

aChar[75][1] = "��������"
aChar[75][2] = "���۳���"
aChar[75][3] = "��������"
aChar[75][4] = "���۳���"
aChar[75][5] = "���۳���"
aChar[75][6] = "��������"

aChar[76][1] = "����   "
aChar[76][2] = "����   "
aChar[76][3] = "����   "
aChar[76][4] = "����   "
aChar[76][5] = "�������"
aChar[76][6] = "�������"

aChar[77][1] = "�����������"
aChar[77][2] = "���ۿ�ۿ���"
aChar[77][3] = "���۳�۳���"
aChar[77][4] = "���۳�۳���"
aChar[77][5] = "���۳�۳���"
aChar[77][6] = "�����������"

aChar[78][1] = "������� "
aChar[78][2] = "���ۿ���"
aChar[78][3] = "���۳���"
aChar[78][4] = "���۳���"
aChar[78][5] = "���۳���"
aChar[78][6] = "��������"

aChar[79][1] = "��������"
aChar[79][2] = "���ۿ���"
aChar[79][3] = "���۳���"
aChar[79][4] = "���۳���"
aChar[79][5] = "��������"
aChar[79][6] = "��������"

aChar[80][1] = "��������"
aChar[80][2] = "���ۿ���"
aChar[80][3] = "��������"
aChar[80][4] = "��������"
aChar[80][5] = "����    "
aChar[80][6] = "����    "

aChar[81][1] = "�������� "
aChar[81][2] = "���ۿ��� "
aChar[81][3] = "���۳��� "
aChar[81][4] = "���۳��� "
aChar[81][5] = "���������"
aChar[81][6] = "�������� "

aChar[82][1] = "��������"
aChar[82][2] = "���ۿ���"
aChar[82][3] = "��������"
aChar[82][4] = "���ۿ���"
aChar[82][5] = "���۳���"
aChar[82][6] = "��������"

aChar[83][1] = "�������"
aChar[83][2] = "�������"
aChar[83][3] = "�������"
aChar[83][4] = "��Ŀ���"
aChar[83][5] = "�������"
aChar[83][6] = "�������"

aChar[84][1] = "��������"
aChar[84][2] = "�Ŀ�����"
aChar[84][3] = "  ����  "
aChar[84][4] = "  ����  "
aChar[84][5] = "  ����  "
aChar[84][6] = "  ����  "

aChar[85][1] = "��������"
aChar[85][2] = "���۳���"
aChar[85][3] = "���۳���"
aChar[85][4] = "���۳���"
aChar[85][5] = "��������"
aChar[85][6] = "��������"

aChar[86][1] = "��������"
aChar[86][2] = "���۳���"
aChar[86][3] = "���۳���"
aChar[86][4] = "���۳���"
aChar[86][5] = "������� "
aChar[86][6] = " ������ "

aChar[87][1] = "�����������"
aChar[87][2] = "���۳�۳���"
aChar[87][3] = "���۳�۳���"
aChar[87][4] = "���۳�۳���"
aChar[87][5] = "�����������"
aChar[87][6] = "�����������"

aChar[88][1] = "��������"
aChar[88][2] = "���۳���"
aChar[88][3] = "������� "
aChar[88][4] = "���ۿ���"
aChar[88][5] = "���۳���"
aChar[88][6] = "��������"

aChar[89][1] = "��������"
aChar[89][2] = "���۳���"
aChar[89][3] = "������� "
aChar[89][4] = " �����  "
aChar[89][5] = "  ����  "
aChar[89][6] = "  ����  "

aChar[90][1] = "��������"
aChar[90][2] = "���Ŀ���"
aChar[90][3] = "  ������"
aChar[90][4] = "������  "
aChar[90][5] = "��������"
aChar[90][6] = "��������"

* --- Mostra a String
IF PCOUNT()  < 3
   cCor := SETCOLOR()
ENDIF

FOR nLinha = 1 TO 6
    cTxt := ""
    * --- Limpa a variavel de retorno
    FOR i = 1 TO LEN(cString)
        cTxt += aChar[ASC(UPPER(SUBS(cString,i,1)))][nLinha]
    NEXT i

    IF LEN(cTxt) > nMaxLin
       nMaxLin := LEN(cTxt)
    ENDIF

    aadd(aTxt,cTxt)

NEXT nLinha
//nCol := (80-nMaxLin) / 2
nCol := (95-nMaxLin) / 2
AEVAL(aTxt,{|x| DEVPOS(nLin++,nCol),DEVOUT(x,cCor) })
SETCOLOR(cCorAnt)
RETURN .T.
   
      


// Fim do arquivo   
   
