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

procedure RelSaida4
   local getlist := {},cTela := SaveWindow()
    private cCodCli,dDataI,dDataF,cSituacao

    Msg(.t.)
    Msg("Aguarde : Abrindo o Arquivo")
    if !OpenProdutos()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenNfce()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenNFCeItem()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenPdvNfceItem()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenPdvNfce()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenNfeVen()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OPenNfeItem()
        FechaDados()
        Msg(.f.)
        return
    endif
    Msg(.f.)
    AtivaF4()
    Window(10,03,15,30)
    setcolor(Cor(11))
   //           56789012345678901234567890123456789012345678901234567890123456789012345678
   //                1         2         3         4         5         6         7
   @ 12,05 say "Data Inicial:"
   @ 13,05 say "  Data Final:"
   while .t.
      cCodCli := space(04)
      dDataI  := ctod(space(08))
      dDataF  := ctod(space(08))
      cSituacao := "A"
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 12,19 get dDataI  picture "@k"      when Rodape("Esc-Encerra") valid iif(lastkey() == K_UP,.t.,NoEmpty(dDataI))
      @ 13,19 get dDataF  picture "@k" valid iif(lastkey() == K_UP,.t.,dDataF >= dDataI)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      endif
        Imprima()
        exit
    enddo
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// *****************************************************************************
static procedure Imprima
   local nVideo,lCabec := .t.,nTotal := 0,nQtd := 0,nTecla := 0
   local lCondicao,lData := .t.,dData,nTotal2 := 0,nQtd2 := 0
   local lNfeVen := .t.
   private lPdvNfce := .t.,lNfce := .t.
   private nPagina := 1

    set softseek on
    Nfce->(dbsetorder(6),dbseek(dtos(dDataI)))
    if Nfce->DtaEmi > dDataF .or. Nfce->(eof())
         set softseek off
         lNfce := .f.
    endif
    set softseek on
    NfeVen->(dbsetorder(6),dbseek(dtos(dDataI)))
    if NfeVen->DtaEmi > dDataF .or. NfeVen->(eof())
         set softseek off
         lNfeVen := .f.
    endif
    set softseek on
    PdvNfce->(dbsetorder(2),dbseek(dtos(dDataI)))
    if PdvNfce->Data > dDataF .or. PdvNfce->(eof())
        set softseek off
        lPdvNfce := .f.
    endif
    set softseek on
    if !lNfce .and. !lNfeVen .and. !lPdvNfce
        set softseek off    
        Mens({"N’o existe nota(s) nesse per­odo"})
        return
    endif    
    set softseek off
    Processar()
    Temp30->(dbclosearea())
    Imprima2(dDataI,dDataF)
return
    
static procedure Imprima2(dDataI,dDataF)
   local lCabec := .t.,nTotal := 0,nQtd := 0,nTecla := 0
   local cImpressora,oFrPrn,nVideo
   private nPagina := 1

   If Aviso_1(09,,14,, [Aten‡Æo!],[Imprimir relatorio ?],{ [  ^Sim  ], [  ^NÆo  ]},1,.t.) == 1
        // ** Abre o arquivo em modo exclusivo
        if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"30",.t.,.t.,"Temp30")
            Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
            return
        endif
        Temp30->(dbgotop())
        
        if Ver_Imp2(@nVideo)
            if nVideo == 1
                cImpressoraPadrao := ImpressoraPadrao()
            endif
            oFrPrn := frReportManager():new()
            oFrPrn:LoadLangRes( 'brazil.xml')                     // arquivo de idioma
            oFrPrn:SetWorkArea("Temp30",select("temp30"))
            oFrprn:LoadFromFile('saida_produtos.fr3')
            oFrPrn:AddVariable("variaveis","datainicial","'"+dtoc(dDataI)+"'")
            oFrPrn:AddVariable("variaveis","datafinal","'"+dtoc(dDataF)+"'")
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
        Temp30->(dbclosearea())
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
