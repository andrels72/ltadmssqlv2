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

procedure RelSaida3
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
    Msg(.f.)
    AtivaF4()
    Window(10,03,16,40)
    setcolor(Cor(11))
   //           56789012345678901234567890123456789012345678901234567890123456789012345678
   //                1         2         3         4         5         6         7
   @ 12,05 say "Data Inicial:"
   @ 13,05 say "  Data Final:"
   @ 14,05 say "    Situa‡Æo:"
   while .t.
      cCodCli := space(04)
      dDataI  := ctod(space(08))
      dDataF  := ctod(space(08))
      cSituacao := "A"
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 12,19 get dDataI  picture "@k"      when Rodape("Esc-Encerra") valid iif(lastkey() == K_UP,.t.,NoEmpty(dDataI))
      @ 13,19 get dDataF  picture "@k" valid iif(lastkey() == K_UP,.t.,dDataF >= dDataI)
      @ 14,19 get cSituacao picture "@k!";
            valid MenuArray(@cSituacao,{{"A","Autorizada"},{"C","Cancelada "}},14,19)
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
    local cTela := SaveWindow()
   local nVideo,lCabec := .t.,nTotal := 0,nQtd := 0,nTecla := 0
   local lCondicao,lData := .t.,dData,nTotal2 := 0,nQtd2 := 0,cTexto
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
    cTexto := iif(cSituacao == "A","Autorizadas","Canceladas") 
    Processar()
    Temp06->(dbgotop())
    If Aviso_1(09,,14,,[Aten‡Æo!],[Imprimir Relat¢rio ?],{ [  ^Sim  ], [  ^NÆo ] }, 1, .t. ) = 1    
        if Ver_Imp2(@nVideo,2)
            if nVideo == 1
                cImpressoraPadrao := ImpressoraPadrao()
            endif       
            oFrPrn := frReportManager():new()
            oFrPrn:LoadLangRes( 'brazil.xml')                     //arquivo de idioma
            oFrPrn:SetWorkArea("Temp06",select("Temp06"))
            oFrprn:LoadFromFile('saida_periodo.fr3')
            oFrPrn:AddVariable("variaveis","empresa","'"+cEmpFantasia+"'")
            oFrPrn:AddVariable("variaveis","datainicial","'"+dtoc(dDatai)+"'")
            oFrPrn:AddVariable("variaveis","datafinal","'"+dtoc(dDataf)+"'")
            oFrPrn:AddVariable("variaveis","texto","'"+cTexto+"'")
            Msg(.t.)
            Msg("Aguarde: gerando o relat¢rio")
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
    Temp06->(dbclosearea())
    RestWindow(cTela)
    return

static procedure Processar

    if !Use_Dbf(cDiretorio,"tmp"+Arq_Sen+"06",.t.,.t.,"Temp06")
        Mens({"Arquivo de impress’o indipon­vel","Tente novamente"})
        return
    endif
    zap
    index on Emissao to (cDiretorio)+"tmp"+Arq_Sen+"06"
    Temp06->(dbclosearea())
    if !Use_Dbf(cDiretorio,"tmp"+Arq_Sen+"06",.t.,.t.,"Temp06")
        Mens({"Arquivo de impress’o indipon­vel","Tente novamente"})
        return
    endif
    set index to (cDiretorio)+"tmp"+Arq_Sen+"06"
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
            Temp06->(dbappend())
            Temp06->Emissao := Nfce->DtaEmi
            Temp06->Numero  := Nfce->NumNot
            Temp06->Modelo  := "65"
            Temp06->Serie   := Nfce->Serie
            if Nfce->Autorizado
                Temp06->Situacao  := "A"
            endif
            if Nfce->Cancelada
                Temp06->Situacao := "C"
            endif
            Temp06->Chave   := Nfce->ChNfce
            Temp06->vNf     := Nfce->TotNot
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
            Temp06->(dbappend())
            Temp06->Emissao := PdvNfce->Data
            Temp06->Numero  := PdvNfce->Nfce
            Temp06->Modelo  := "65"
            Temp06->Serie   := PdvNfce->Serie
            if PdvNfce->Autorizado
                Temp06->Situacao  := "A"
            endif
            if PdvNfce->Cancelada
                Temp06->Situacao := "C"
            endif
            Temp06->Chave   := PdvNfce->Chave
            Temp06->vNf     := PdvNfce->TotCup
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
        Temp06->(dbappend())
        Temp06->Emissao := NfeVen->DtaEmi
        Temp06->Numero  := NfeVen->NumNot
        Temp06->Modelo  := "55"
        Temp06->Serie   := NfeVen->Serie
        if NfeVen->Autorizado
            Temp06->Situacao  := "A"
        endif
        if Nfeven->Cancelada
            Temp06->Situacao := "C"
        endif
        Temp06->Chave   := Nfeven->ChNfe
        Temp06->vNf     := Nfeven->TotNot
        Nfeven->(dbskip())
    enddo
    return
    
//** Fim do Arquivo.
