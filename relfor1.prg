/*************************************************************************
 * Sistema......: Automacao Comercial
 * Versao.......: 2.00
 * Identificacao: Relatorios de Fornecedores (Cadastro)
 * Prefixo......: LtAdm
 * Programa.....: RelFor1.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 05 de Fevereiro de 2004
 * Copyright (C): LT - LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"

procedure RelFor1()
   local cTela := SaveWindow(),nVideo,lCabec := .t.,lTem := .f.,nTecla := 0
   private nPagina := 1

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenFornecedor()
      FechaDados()
      Msg(.f.)
      Return
   EndIf
   if !OPenCidades()
      FechaDados()
      Msg(.f.)
      return
   end
   Msg(.f.)
   If Aviso_1( 09,,14,,[AtenáÑo!],[Imprimir Relat¢rio do Cadastro de Fornecedores?],{ [  ^Sim  ], [  ^NÑo  ] }, 1, .t. ) = 1
      nOrdem := Aviso_1(09,,14,,"AtenáÑo!","Escolha a Ordem do Relatorio.",{" ^Alfabetica "," ^Numerica "},1,.t.)
        If Ver_Imp2(@nVideo)
            nOrdem := iif(nOrdem == 1,2,1)
            Fornecedor->(dbsetrelation("Cidades",{|| CodCid}))
            oFrPrn := frReportManager():new()
            oFrPrn:LoadLangRes( 'brazil.xml')                     //arquivo de idioma
            oFrPrn:SetWorkArea("Cidades", Select("Cidades"))
            oFrPrn:SetWorkArea("FORNECEDOR", Select("FORNECEDOR"))
            oFrPrn:SetResyncPair('Fornecedor', 'Cidades')  // Ativa o set relation no FastReport
            oFrprn:LoadFromFile('fornecedorescadastro.fr3')
            oFrPrn:AddVariable("variaveis","empresa","'"+cEmpRazao+"'")
            oFrPrn:AddVariable("variaveis","titulo",iif(nOrdem = 1,"'"+"Alfabetica"+"'","'"+"Numerica"+"'"))
            //oFrPrn:DesignReport()                                 // aqui para "desenhar" o relatÛrio
            oFrPrn:PreviewOptions:SetAllowEdit( .F. )
            oFrPrn:PrepareReport()
            if nVideo == 2      
                oFrPrn:ShowReport()
            else
                // se a impress∆o for na impressora padr∆o
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
    FechaDados()
    RestWindow(cTela)
    return

//** Fim do Arquivo.
