/*************************************************************************
 * Sistema......: Administrativo
 * Identificacao: Relatorio de Pedidos de por Periodo
 * Prefixo......: LtAdm
 * Programa.....: RelPed1.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 22 de Novembro de 2003
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"
#include "setcurs.ch"

procedure RelProdB
   local getlist := {},cTela := SaveWindow()
    private cCodCli,dDataI,dDataF,cSituacao

    Msg(.t.)
    Msg("Aguarde : Abrindo o Arquivo")
    if !OpenProdutos()
        FechaDados()
        Msg(.f.)
        return
    endif
    Msg(.f.)
    Imprima()
    FechaDados()
    RestWindow(cTela)
return
// *****************************************************************************
static procedure Imprima
   local lCabec := .t.,nTotal := 0,nQtd := 0,nTecla := 0
   local cImpressora,oFrPrn,nVideo
   private nPagina := 1

   If Aviso_1(09,,14,, [Aten‡Æo!],[Imprimir relatorio ?],{ [  ^Sim  ], [  ^NÆo  ]},1,.t.) == 1
        // ** Abre o arquivo em modo exclusivo
        if Ver_Imp2(@nVideo)
            if nVideo == 1
                cImpressoraPadrao := ImpressoraPadrao()
            endif
            Produtos->(dbsetorder(2))
            oFrPrn := frReportManager():new()
            oFrPrn:LoadLangRes( 'brazil.xml')                     // arquivo de idioma
            oFrPrn:SetWorkArea("Produtos",select("produtos"))
            oFrprn:LoadFromFile('produtos_relacao.fr3')
            oFrPrn:AddVariable("variaveis","empresa","'"+cEmpFantasia+"'")
            
            // Pede a Impressora para Esolher uma Virtual, pois nao gera o .PDF aqui
            oFrPrn:PreviewOptions:SetAllowEdit( .F. )
            Msg(.t.)
            Msg("Aguarde: Gerando o relat¢rio")
            oFrPrn:PrepareReport()
            //oFrPrn:DesignReport()                                 // aqui para "desenhar" o relat?rio
            Msg(.f.)
            if nVideo == 2
                oFrPrn:ShowReport()
            else
                // se a impress?o for na impressora padr?o
                if !empty(cImpressoraPadrao)
                    oFrPrn:PrintOptions:SetShowDialog(.f.)
                else
                    oFrPrn:PrintOptions:SetShowDialog(.t.)
                endif
                oFrPrn:Print( .T. )
            endif
        endif
        oFrPrn:DestroyFR()
	endif
	return
   
   
static procedure Processar

    if !Use_Dbf(cDiretorio,"tmp"+Arq_Sen+"30",.t.,.t.,"Temp30")
        Mens({"Arquivo de impress’o indipon­vel","Tente novamente"})
        return
    endif
    zap
    index on codpro to (cDiretorio)+"tmp06"
    Temp30->(dbclosearea())
    if !Use_Dbf(cDiretorio,"tmp"+Arq_Sen+"30",.t.,.t.,"Temp30")
        Mens({"Arquivo de impress’o indipon­vel","Tente novamente"})
        return
    endif
    set index to (cDiretorio)+"tmp06"

    if lNfce 
        do while Nfce->DtaEmi >= dDataI .and. Nfce->DtaEmi <= dDataF .and. Nfce->(!eof())
            if cSituacao == "A"
                if !Nfce->Autorizado
                    Nfce->(dbskip())
                    loop
                elseif Nfce->Autorizado .and. Nfce->Cancelada
                    Nfce->(dbskip())
                    loop
                endif
            else
                if !Nfce->Autorizado
                    Nfce->(dbskip())
                    loop
                elseif Nfce->Autorizado .and. !Nfce->Cancelada
                    Nfce->(dbskip())
                    loop
                endif
            endif
            if nfceitem->(dbsetorder(1),dbseek(Nfce->NumCon))
                do while nfceitem->NumCon == Nfce->NumCon .and. nfceitem->(!eof())
                    if !Temp30->(dbsetorder(1),dbseek(nfceitem->codpro))
                        Produtos->(dbsetorder(1),dbseek(nfceitem->codpro))
                        Temp30->(dbappend())
                        Temp30->codpro := nfceitem->codpro
                        Temp30->despro := produtos->despro
                        Temp30->quantidade := nfceitem->qtdpro
                    else
                        Temp30->quantidade += nfceitem->qtdpro
                    endif
                    nfceitem->(dbskip())
                enddo
            endif
            NFce->(dbskip())
        enddo
    endif
    // PdvNfce
    if lPdvNfce
        do while PdvNfce->Data >= dDataI .and. PdvNfce->Data <= dDataF .and. PdvNfce->(!eof())
            // se for sem nota
            if PdvNfce->Geral
                PdvNFce->(dbskip())
                loop
            endif
            if !PdvNfce->Autorizado
                PdvNfce->(dbskip())
                loop
            endif
            if cSituacao == "A"
                if PdvNfce->Autorizado .and. PdvNfce->Cancelada
                    PdvNfce->(dbskip())
                    loop
                endif
            // se for cancelada
            else
                if PdvNfce->Autoriazado .and. !PdvNfce->Cancelada
                    PdvNfce->(dbskip())
                    loop
                endif
            endif
            if PdvNfceItem->(dbsetorder(1),dbseek(Nfce->NumCon))
                do while pdvnfceitem->NumCon == Nfce->NumCon .and. pdvnfceitem->(!eof())
                    if !Temp30->(dbsetorder(1),dbseek(pdvnfceitem->codpro))
                        Temp30->(dbappend())
                        Temp30->codpro := pdvnfceitem->codpro
                    endif
                    pdvnfceitem->(dbskip())
                enddo
            endif
            
            PdvNfce->(dbskip())
        enddo
    endif
    
    
    // NF-e
    do while NfeVen->DtaEmi >= dDataI .and. NfeVen->DtaEmi <= dDataF ;
            .and. NfeVen->(!eof())
        if !NfeVen->Autorizado
            NfeVen->(dbskip())
            loop
        endif
        if NfeVen->Autorizado .and. nfeven->cancelada
            nfeven->(dbskip())
            loop
        endif
        if nfeitem->(dbsetorder(1),dbseek(nfeven->numcon))
            do while nfeitem->numcon == nfeven->numcon .and. nfeitem->(!eof())
                if !Temp30->(dbsetorder(1),dbseek(nfeitem->codpro))
                    Produtos->(dbsetorder(1),dbseek(nfeitem->codpro))
                    Temp30->(dbappend())
                    Temp30->codpro := nfeitem->codpro
                    Temp30->despro := produtos->despro
                    Temp30->quantidade := nfeitem->qtdpro
                else
                    Temp30->quantidade += nfeitem->qtdpro
                endif
                nfeitem->(dbskip())
            enddo
        endif
        Nfeven->(dbskip())
    enddo
return
    

    
//** Fim do Arquivo.
