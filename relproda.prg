

procedure RelprodA
    local cTela := SaveWindow(),nVideo


   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenProdutos()
      FechaDados()
      Msg(.f.)
      return
   endif
   Msg(.f.)
   Produtos->(dbsetorder(2),dbgotop())
   If Aviso_1(09,,14,,"Aten‡Æo!","Imprimir relat¢rio ?",{ [  ^Sim  ], [  ^Nao ] }, 1, .t. ) = 1
      If Ver_Imp2(@nVideo)
            if nVideo == 1
                cImpressoraPadrao := ImpressoraPadrao()
            endif
            oFrPrn := frReportManager():new()
            oFrPrn:LoadLangRes( 'brazil.xml')                     //arquivo de idioma
            oFrPrn:SetWorkArea("Produtos",select("Produtos"))
            oFrprn:LoadFromFile('relproda.fr3')
            oFrPrn:AddVariable("variaveis","empresa","'"+cEmpRazao+"'")
            oFrPrn:PrepareReport()
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
    FechaDados()
    RestWindow(cTela)
    return
   
