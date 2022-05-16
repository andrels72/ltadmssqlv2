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

procedure RelLucroVenda
   local getlist := {},cTela := SaveWindow()
   local dDataI,dDataF

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenProdutos()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenPedidos()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenItemPed()
        FechaDados()
        Msg(.f.)
        return
    endif
   Msg(.f.)
   Window(09,26,14,53)
   setcolor(Cor(11))
   //           56789012345678901234567890123456789012345678901234567890123456789012345678
   //                 2         3         4         5         6         7
   @ 11,28 say "Data Inicial:"
   @ 12,28 say "  Data Final:"
   while .t.
      dDataI := ctod(space(08))
      dDataF := ctod(space(08))
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,42 get dDataI picture "@k" valid NoEmpty(dDataI)
      @ 12,42 get dDataF picture "@k" valid dDataF >= dDataI
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
        if !Processar(dDataI,dDataF)
            loop
        endif
        Imprima(dDataI,dDataF)
        exit
   end
   FechaDados()
   RestWindow(cTela)
   return
   
   
static function Processar(dDataI,dDataF)

   set softseek on
   Pedidos->(dbsetorder(2),dbseek(dDataI))
   if Pedidos->Data > dDataF
      set softseek off
      Mens({"Nao Existe Proposta(s) Nesse Periodo"})
      return(.f.)
   end
   set softseek off

    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"29",.t.,.t.,"Temp29")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return(.f.)
	endif
	zap
	Temp29->(dbclosearea())
    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"29",.t.,.t.,"Temp29")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return(.f.)
	endif
    Msg(.t.)
    Msg("Aguarde: processando o relat¢rio")
    do while Pedidos->Data >= dDataI .and. Pedidos->Data <= dDataF .and. Pedidos->(!eof())
        if ItemPed->(dbsetorder(1),dbseek(Pedidos->NumPed))
            do while ItemPed->NumPed == Pedidos->NumPed .and. ItemPed->(!eof())
                Produtos->(dbsetorder(1),dbseek(ItemPed->CodPro))
                Temp29->(dbappend())
                Temp29->pedido := ItemPed->Numped
                Temp29->codpro := ItemPed->CodPro
                Temp29->fanpro := Produtos->FanPro
                Temp29->quantidade := ItemPed->qtdpro
                Temp29->custo := ItemPed->Custo*ItemPed->QtdPro 
                Temp29->venda := ItemPed->PcoLiq*ItemPed->QtdPro 
                Temp29->lucro := Temp29->venda-Temp29->custo
                 
                ItemPed->(dbskip())
            enddo
        endif
        Pedidos->(dbskip())
    enddo
    Temp29->(dbclosearea())
    Msg(.f.)
    return(.t.)


static procedure Imprima(dDataI,dDataF)
    local cTela := SaveWindow(),nVideo

    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"29",.t.,.t.,"Temp29")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return
	endif
   If Aviso_1(09,,14,,"Aten‡Æo!","Imprimir relat¢io ?",{ [  ^Sim  ], [  ^Nao ] }, 1, .t. ) = 1
      If Ver_Imp2(@nVideo)
            if nVideo == 1
                cImpressoraPadrao := ImpressoraPadrao()
            endif
            oFrPrn := frReportManager():new()
            oFrPrn:LoadLangRes( 'brazil.xml')                     //arquivo de idioma
            oFrPrn:SetWorkArea("Temp29",select("Temp29"))
            oFrprn:LoadFromFile('rellucrovenda.fr3')
            oFrPrn:AddVariable("variaveis","empresa","'"+cEmpRazao+"'")
            oFrPrn:AddVariable("variaveis","datainicial","'"+dtoc(dDatai)+"'")
            oFrPrn:AddVariable("variaveis","datafinal","'"+dtoc(dDataf)+"'")
            Msg(.t.)
            Msg("Aguarde: Gerando o relatorio")
            oFrPrn:PrepareReport()
            Msg(.f.)
            //oFrPrn:DesignReport()                                 // aqui para "desenhar" o relat?rio
            oFrPrn:PreviewOptions:SetAllowEdit( .F. )
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
            oFrPrn:DestroyFR()
        endif      
    endif
    Temp29->(dbclosearea())
    FechaDados()
    RestWindow(cTela)
    return

//** Fim do Arquivo.
