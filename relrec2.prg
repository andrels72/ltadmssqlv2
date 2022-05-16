/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.2
 * Identificacao: Relatorios de Contas a Receber por dia
 * Prefixo......: LtAdm
 * Programa.....: Bancos.prg
 * Autor........: Andre Lucas Souza
 * Data.........: 23 de Setembro de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure RelRec2
   local getlist := {},cTela := SaveWindow()
   local nVideo,cTitulo
   private dDataI,dDataF,nQual

   nQual := Aviso_1(14,,19,,"Aten‡„o!","    Listar quais duplicatas?    ",{" ^Recebidas "," ^A receber "},1,.t.)
   if nQual == -27
      FechaDados()
      return
   elseif nQual == 1
      cTitulo := "> Recebido <"
   elseif nQual == 2
      cTitulo := "> A Receber <"
   end
   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenClientes()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenCidades()
      FechaDados()
      Msg(.f.)
      return
   endif
    if !OpenDupRec()
      FechaDados()
      Msg(.f.)
      return
   end
   Msg(.f.)
   AtivaF4()
   Window(09,26,14,53,cTitulo)
   setcolor(Cor(11))
   //           0123456789012345678901234567890
   //                     2
   @ 11,28 say "Data Inicial:"
   @ 12,28 say "  Data Final:"
   while .t.
      dDataI  := date()
      dDataF  := date()
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,42 get dDataI  picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDataI)
      @ 12,42 get dDataF  picture "@k" valid iif(lastkey() == K_UP,.t.,dDataF >= dDataI)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
        if !Processar(dDataI,dDataF,nQual)
            loop
        endif
        Imprima(dDataI,dDataF,nQual)
        exit
    enddo
    DesativaF4()
    FechaDados()
    RestWindow(cTela)
   return
   

static function Processar
   
    set softseek on
    if nQual == 1
        DupRec->(dbsetorder(3),dbseek(dDataI))
        if DupRec->DtaPag > dDataF
            set softseek off
            Mens({"Nao Existe Nada a Recebido nesse periodo"})
            return(.f.)
        endif
        lCondicao := "DupRec->DtaPag >= dDataI .and. DupRec->DtaPag <= dDataF"
        cTitRel   := "Relatorio de Duplicatas a Receber ( Recebido )"
    elseif nQual == 2
        DupRec->(dbsetorder(4),dbseek(dDataI))
        if DupRec->DtaVen > dDataF
            set softseek off
            Mens({"Nao Existe Nada a Receber nesse periodo"})
            return(.f.)
        endif
        lCondicao := "DupRec->DtaVen >= dDataI .and. DupRec->DtaVen <= dDataF .and. empty(DupRec->DtaPag)"
        cTitRel   := "Relatorio de Duplicatas a Receber ( A Receber )"
    endif
    set softseek off
    
    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"12",.t.,.t.,"Temp12")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return(.f.)
	endif
	zap
	index on data2 to (cDiretorio+"tmp"+Arq_Sen)+"12"
	Temp12->(dbclosearea())
	// ** Abre o arquivo em modo exclusivo
	if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"12",.t.,.t.,"Temp12")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return(.f.)
	endif
	set index to (cDiretorio+"tmp"+Arq_Sen)+"12"
    Msg(.t.)
    Msg("Aguarde: Processandos as infoma‡äes")
    do while DupRec->(!eof())
        if &lCondicao.
            Clientes->(dbsetorder(1),dbseek(DupRec->CodCli))
            Temp12->(dbappend())
            Temp12->CodCli := DupRec->CodCli
            Temp12->NomCli := Clientes->NomCli
            Temp12->NumDup := DupRec->NumDup
            if nQual == 1 // Data de vencimento
                Temp12->Data1 := DupRec->DtaVen
                Temp12->Data2 := DupRec->DtaPag
                Temp12->Valor := DupRec->ValPag
            elseif nQual == 2
                Temp12->Data1 := DupRec->DtaEmi
                Temp12->Data2 := DupRec->DtaVen
                Temp12->Valor := DupRec->ValDup
            endif
        endif
        DupRec->(dbskip())
    enddo
    Msg(.f.)
    if Temp12->(lastrec()) = 0
        Temp12->(dbclosearea())
        Mens({"NÆo existe duplicata nesse per¡odo"})
        return(.f.)
    endif
    Temp12->(dbclosearea())
    return(.t.)
    
// ****************************************************************************
static procedure Imprima
   local nVideo,nTecla := 0,lCabec := .t.,dData,lData := .t.,lTem := .f.,nTotal := 0
   local nGeral := 0,cTitRel
   private nPagina := 1,lCondicao

    If Aviso_1(09,,14,,[Aten‡„o!],[Imprimir Relat¢rio de Duplicatas a Receber. ?],{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
        if Ver_Imp2(@nVideo)
            // ** Abre o arquivo em modo exclusivo
            if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"12",.t.,.t.,"Temp12")
                Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
                return
            endif
            set index to (cDiretorio+"tmp"+Arq_Sen)+"12"
            if nVideo == 1
                cImpressoraPadrao := ImpressoraPadrao()
            endif
            oFrPrn := frReportManager():new()
            oFrPrn:LoadLangRes( 'brazil.xml')                     //arquivo de idioma
            oFrPrn:SetWorkArea("Temp12",select("temp12"))
            if nQual = 1
                oFrprn:LoadFromFile('duplicata_receber21.fr3')
            else
                oFrprn:LoadFromFile('duplicata_receber22.fr3')
            endif
            oFrPrn:AddVariable("variaveis","datainicial","'"+dtoc(dDatai)+"'")
            oFrPrn:AddVariable("variaveis","datafinal","'"+dtoc(dDataf)+"'")
            oFrPrn:AddVariable("variaveis","empresa","'"+cEmpRazao+"'")
            oFrPrn:PrepareReport()
            //oFrPrn:DesignReport()                                 // aqui para "desenhar" o relatório
            oFrPrn:PreviewOptions:SetAllowEdit( .F. )
            if nVideo == 2
                oFrPrn:ShowReport()
            else
                // se a impressÆo for na impressora padrÆo
                if !empty(cImpressoraPadrao)
                    oFrPrn:PrintOptions:SetShowDialog(.f.)
                else
                    oFrPrn:PrintOptions:SetShowDialog(.t.)
                endif
                oFrPrn:Print( .T. )
            endif
            oFrPrn:DestroyFR()
        endif
        Temp12->(dbclosearea())
    endif
    return

// ** Fim do Arquivo 
