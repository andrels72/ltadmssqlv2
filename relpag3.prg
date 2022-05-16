/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.2
 * Identificacao: Relatorios de Contas a Pagar (Extrato do Fornecedor)
 * Prefixo......: LtAdm
 * Programa.....: RelPag3.prg
 * Autor........: Andre Lucas Souza
 * Data.........: 17 de Fevereiro de 2004
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure RelPag3
   local getlist := {},cTela := SaveWindow()
   private cCodFor,dDataI,dDataF
   private nTotAPagar,nTotPago 
    

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenFornecedor()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenCidades()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenDupPag()
        FechaDados()
        Msg(.f.)
        return
    endif
   Msg(.f.)
   AtivaF4()
   Window(08,10,14,72,"> Extrato do Fornecedor <")
   setcolor(Cor(11))
   //           0123456789012345678901234567890
   //                     2
   @ 10,12 say "  Fornecedor:"
   @ 11,12 say "Data Inicial:"
   @ 12,12 say "  Data Final:"
   while .t.
      cCodFor := space(04)
      dDataI  := date()
      dDataF  := date()
      cQual   := space(01)
      nTotAPagar := 0.00 
      nTotPago := 0.00
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,26 get cCodFor picture "@k 9999";
                when Rodape("Esc-Encerra | F4-Fornecedores");
                valid Busca(Zera(@cCodFor),"Fornecedor",1,10,31,"left(Fornecedor->RazFor,40)",{"Fornecedore Nao Cadastrado"},.f.,.f.,.f.)
      @ 11,26 get dDataI  picture "@k" when Rodape("Esc-Encerra")
      @ 12,26 get dDataF  picture "@k" valid iif(lastkey() == K_UP,.t.,dDataF >= dDataI)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
        if !Processar()
            loop
        endif
      Imprima()
      exit
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
//*****************************************************************************
static procedure Imprima
    local nVideo

    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"35",.t.,.t.,"Temp35")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return
	endif
    If Aviso_1(09,,14,,[Aten‡Æo!],[Imprimir Relat¢rio ?],{ [  ^Sim  ], [  ^NÆo  ] }, 1, .t. ) = 1
        If Ver_Imp2(@nVideo)
            if nVideo == 1
                cImpressoraPadrao := ImpressoraPadrao()
            endif
            oFrPrn := frReportManager():new()
            oFrPrn:LoadLangRes( 'brazil.xml')                     //arquivo de idioma
            oFrPrn:SetWorkArea("Temp35",select("Temp35"))
            oFrprn:LoadFromFile('fornecedor_extrato.fr3')
            oFrPrn:AddVariable("variaveis","empresa","'"+cEmpRazao+"'")
            oFrPrn:AddVariable("variaveis","datainicial","'"+dtoc(dDatai)+"'")
            oFrPrn:AddVariable("variaveis","datafinal","'"+dtoc(dDataf)+"'")
            oFrPrn:AddVariable("variaveis","fornecedor","'"+cCodFor+" "+Fornecedor->RazFor+ "'")
            oFrPrn:AddVariable("variaveis","pago","'"+transform(nTotPago,"@e 999,999,999.99")+"'")
            oFrPrn:AddVariable("variaveis","apagar","'"+transform(nTotAPagar,"@e 999,999,999.99")+"'")
            
            Msg(.t.)
            Msg("Aguarde: Gerando o relat¢rio")
            oFrPrn:PrepareReport()
            Msg(.f.)
            //oFrPrn:DesignReport()                                 // aqui para "desenhar" o relat¢rio
            oFrPrn:PreviewOptions:SetAllowEdit( .F. )
            if nVideo == 2
                oFrPrn:ShowReport()
            else
                // se a impress’o for na impressora padr’o
                if !empty(cImpressoraPadrao)
                    oFrPrn:PrintOptions:SetShowDialog(.f.)
                else
                    oFrPrn:PrintOptions:SetShowDialog(.t.)
                endif
                oFrPrn:Print( .T. )
            endif
            oFrPrn:DestroyFR()
        endif
    endif
    Temp35->(dbclosearea())
    return



static function Processar
   local nVideo,nTecla := 0,lCabec := .t.
   private nPagina := 1

   set softseek on
   DupPag->(dbsetorder(4),dbseek(dtos(dDataI)))
   if DupPag->DtaVen > dDataF .or. DupPag->(eof())
      set softseek off
      Mens({"Nao Existe Nada Pago"})
      return(.f.)
   endif
   set softseek off
    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"35",.t.,.t.,"Temp35")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return(.f.)
	endif
	zap
	Temp35->(dbclosearea())
    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"35",.t.,.t.,"Temp35")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return(.f.)
	endif
    do while DupPag->(!eof())
        if DupPag->CodFor == cCodFor .and. DupPag->DtaVen >= dDataI .and. DupPag->DtaVen <= dDataF
            Temp35->(dbappend())
            Temp35->NumDup := DupPag->NumDup
            Temp35->Docume := DupPag->Docume
            Temp35->Dtaemi := DupPag->DtaEmi
            Temp35->DtaVen := DupPag->DtaVen
            Temp35->ValDup := DupPag->ValDup 
            Temp35->DtaPag := DupPag->DtaPag
            Temp35->ValPag := DupPag->ValPag 
            if DupPag->ValPag == 0
                nTotAPagar += DupPag->ValDup
            else
                nTotPago   += DupPag->ValPag
            endif
        endif
        DupPag->(dbskip())
    enddo
    Temp35->(dbclosearea())
return(.t.)

//** Fim do Arquivo.
