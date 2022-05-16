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

procedure RelPed1
   local getlist := {},cTela := SaveWindow()
   local dDataI,dDataF
   private nVideo,cFileTemp

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenClientes()
      FechaDados()
      Msg(.f.)
      return
   endif
    if !OpenPlano()
        FechaDados()
        Msg(.f.)
        return
    endif
   if !OpenPedidos()
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
      dDataI := date()
      dDataF := date()
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,42 get dDataI picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDataI)
      @ 12,42 get dDataF picture "@k" valid iif(lastkey() == K_UP,.t.,dDataF >= dDataI)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      endif
        if !Processa(dDataI,dDataF)
            loop
        endif
        Imprima(dDataI,dDataF)
    enddo
    FechaDados()
    RestWindow(cTela)
    return
// *****************************************************************************
static procedure Imprima(dDataI,dDataF)
   local lCabec := .t.,nTotal := 0,nQtd := 0,nTecla := 0
   local cImpressora,oFrPrn
   private nPagina := 1

   If Aviso_1(09,,14,, [Aten‡Æo!],[Imprimir propostas por per¡odo ?],{ [  ^Sim  ], [  ^NÆo  ]},1,.t.) == 1
        // ** Abre o arquivo em modo exclusivo
        if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"01",.t.,.t.,"Temp01")
            Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
            return
        endif
        Temp01->(dbgotop())
        if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"08",.t.,.t.,"Temp08")
            Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
            return
        endif
        Temp08->(dbgotop())
        
        if Ver_Imp2(@nVideo)
            if nVideo == 1
                cImpressoraPadrao := ImpressoraPadrao()
            endif
            oFrPrn := frReportManager():new()
            oFrPrn:LoadLangRes( 'brazil.xml')                     // arquivo de idioma
            oFrPrn:SetWorkArea("Temp01",select("temp01"))
            oFrPrn:SetWorkArea("Temp08",select("temp08"))
            //oFrPrn:SetWorkArea("pedidos",select("pedidos"))
            oFrprn:LoadFromFile('pedidos_periodo.fr3')
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
        Temp01->(dbclosearea())
        Temp08->(dbclosearea())
	endif
	return
//*****************************************************************************
static function Processa(dDataI,dDataF)

   set softseek on
   Pedidos->(dbsetorder(2),dbseek(dDataI))
   if Pedidos->Data > dDataF
      set softseek off
      Mens({"Nao Existe Pedidos Nesse Periodo"})
      return(.f.)
   endif
   set softseek off

	// ** Abre o arquivo em modo exclusivo
    //cDiretorio+"tmp"+Arq_Sen+"01"
	if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"01",.t.,.t.,"Temp01")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return(.f.)
	endif
    zap
    Temp01->(dbclosearea())
    
    if !Use_Dbf(cDiretorio,"tmp"+Arq_Sen+"08",.t.,.t.,"Temp08")
        Mens({"Arquivo de impress’o indipon­vel","Tente novamente"})
        return
    endif
    zap
    index on codpla to (cDiretorio+"tmp"+Arq_Sen)+"08"
    Temp08->(dbclosearea())
	// ** Abre o arquivo em modo exclusivo
	if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"01",.t.,.t.,"Temp01")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return(.f.)
	endif
    if !Use_Dbf(cDiretorio,"tmp"+Arq_Sen+"08",.t.,.t.,"Temp08")
        Mens({"Arquivo de impress’o indipon­vel","Tente novamente"})
        return
    endif
    set index to (cDiretorio+"tmp"+Arq_Sen)+"08"
    do while Pedidos->Data >= dDataI .and. Pedidos->Data <= dDataF .and. Pedidos->(!Eof())
        Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
        Temp01->(dbappend())
        Temp01->Pedido := Pedidos->NumPed
        Temp01->data := Pedidos->Data
        Temp01->Codcli := Pedidos->CodCli
        Temp01->Nomcli := Clientes->nomcli
        Temp01->valor := Pedidos->Total
        Plano->(dbsetorder(1),dbseek(Pedidos->CodPla))
        if !Temp08->(dbsetorder(1),dbseek(Pedidos->CodPla))
            Temp08->(dbappend())
            Temp08->CodPla := Pedidos->CodPla
            Temp08->DesPla := Plano->DesPLa
            Temp08->valor := Pedidos->Total
            Temp08->(dbcommit())
        else
            Temp08->DesPla := Plano->DesPLa
            Temp08->Valor += Pedidos->Total
        endif
        Pedidos->(dbskip())
    enddo
    Temp01->(dbclosearea())
    Temp08->(dbclosearea())
    return(.t.)
    
static procedure DbfTemp07
    
   aStru := {}
   aadd(aStru,{"pedido","c",06,00}) // ** data de lancammento
   aadd(aStru,{"data","d",08,0})
   aadd(aStru,{"codcli","c",04,0})
   aadd(aStru,{"nomcli","c",40,0})
   aadd(aStru,{"valor","n",15,2})
   cFileTemp := CreateTemp(1)
   dbcreate(cDiretorio+cFileTemp,aStru)
   return
    

//** Fim do Arquivo.
