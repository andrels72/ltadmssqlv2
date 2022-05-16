/*************************************************************************
        Sistema: Administrativo
   Identifica‡Æo: Relat¢rio de Ficha de Produtos
         Prefixo: LTADM
        Programa: Relprod3.PRG
           Autor: Andre Lucas Souza
            Data: 26 de Julho de 2004
   Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure RelProd3
   local getlist := {},cTela := SaveWindow()
   private cCodPro,dDataI,dDataF,cTipo,cEstoqAnterior,nTotAnt

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenFornecedor()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenProdutos()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenGrupos()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenSubGrupo()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenCompra()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenCmp_Ite()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenClientes()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenVendedor()
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
    if !OpenNfeven()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenNfeItem()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenNfce()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenNfceItem()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenPdvNfce()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenPdvNfceItem()
        FechaDados()
        Msg(.f.)
        return
    endif
   Msg(.f.)
   if PwNivel == "0"
      DesativaF9()
   end
   AtivaF4()
   Window(08,03,17,75)
   setcolor(Cor(11))
   //           56789012345678901234567890
   //                1         2         3
   @ 10,05 say "       Produto:"
   @ 11,05 say "     Descrição:"
   @ 12,05 say "  Data Inicial:"
   @ 13,05 say "    Data Final:"
   @ 14,05 say "          Tipo:"
   @ 15,05 say "Saldo Anterior:"
   while .t.
      cCodPro := space(13)
      dDataI  := date()
      dDataF  := date()
      cTipo   := space(01)
      cEstoqAnterior := "N"
      nTotAnt := 0 
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,21 get cCodPro picture "@k";
                when Rodape("Esc-Encerra | F4-Produtos");
                valid BuscarCodigo(@cCodPro) .and. Busca(Produtos->CodPro,"Produtos",1,11,21,"Produtos->FanPro",{"Produto Nao Cadastrado"},.f.,.f.,.f.)
      @ 12,21 get dDataI  picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDataI)
      @ 13,21 get dDataF  picture "@k" valid dDataF >= dDataI
      @ 14,21 get cTipo   picture "@k!" valid MenuArray(@cTipo,{{"E","Entrada"},{"S","Saida  "},{"T","Todos  "}},13,28,row(),col()+1)
      @ 15,21 get cEstoqAnterior picture "@k!" valid cEstoqAnterior $ "SN"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      if !Confirm("Confirma as Informacoes")
         loop
      endif
      cCodPro := Produtos->CodPro
      
        if !Processar()
            loop
        endif
        Imprima()
        exit
    enddo
    DesativaF4()
    if PwNivel == "0"
        AtivaF9()
        lGeral := .f.
    endif
    FechaDados()
    RestWindow(cTela)
return
// ****************************************************************************
static function Processar
   local cTela := SaveWindow(),lCabec := .t.,nVideo
   local nTecla := 0,lImp := .t.,nTotEnt := 0,nTotSai := 0
        
        
    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"03",.t.,.t.,"Temp03")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return(.f.)
	endif
	zap
    index on data to (cDiretorio+"tmp"+Arq_Sen)+"03" 
	Temp03->(dbclosearea())
    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"03",.t.,.t.,"Temp03")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return(.f.)
	endif
    set index to (cDiretorio+"tmp"+Arq_Sen)+"03"
    
    if cTipo $ "E|T"
        Msg(.t.)
        Msg("Aguarde: Processando Entrada")
        Cmp_Ite->(dbsetorder(2),dbgotop())
        do while Cmp_Ite->(!eof())
            if Cmp_Ite->CodPro == cCodPro
                if nTipoEstoque = 0
                    if !lGeral
                        if Compra->(dbsetorder(1),dbseek(Cmp_Ite->Chave))
                            if Compra->SN
                                Cmp_Ite->(dbskip())
                                loop
                            endif                                                
                        endif
                    endif
                    Compra->(dbsetorder(1),dbseek(Cmp_Ite->Chave))
                    Fornecedor->(dbsetorder(1),dbseek(Compra->CodFor))
                    Temp03->(dbappend())
                    Temp03->Chave  := Compra->Chave
                    Temp03->Tipo   := "E"
                    Temp03->Data   := Cmp_Ite->DtaEnt
                    Temp03->Documento := "NF "+Compra->NumNot
                    Temp03->CliFor := Compra->CodFor+"-"+left(Fornecedor->RazFor,30)
                    Temp03->QtdPro := Cmp_Ite->Quantidade
                    Temp03->PcoPro := Cmp_Ite->Custo
                    Temp03->total := (Cmp_Ite->Custo*Cmp_Ite->Quantidade)
                elseif nTipoEstoque = 1
                    Compra->(dbsetorder(1),dbseek(Cmp_Ite->Chave))
                    Fornecedor->(dbsetorder(1),dbseek(Compra->CodFor))
                    Temp03->(dbappend())
                    Temp03->Chave  := Compra->Chave
                    Temp03->Tipo   := "E"
                    Temp03->Data   := Cmp_Ite->DtaEnt
                    Temp03->Documento := "NF "+Compra->NumNot
                    Temp03->CliFor := Compra->CodFor+"-"+left(Fornecedor->RazFor,30)
                    Temp03->QtdPro := Cmp_Ite->Quantidade
                    Temp03->PcoPro := Cmp_Ite->Custo
                    Temp03->total := (Cmp_Ite->Custo*Cmp_Ite->Quantidade)
                endif
            endif
            Cmp_Ite->(dbskip())
        enddo
        Msg(.f.)
    endif
    if cTipo $ "S|T"
        if nTipoEstoque = 0
            if !lGeral
                ProcessarNfe()
                Nfce()
                ProcessarPdv()
            else
                ItemPed->(dbsetorder(4),dbgotop())
                do while ItemPed->(!eof())
                    if ItemPed->CodPro == cCodPro
                        Pedidos->(dbsetorder(1),dbseek(ItemPed->NumPed))
                        Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
                        Vendedor->(dbsetorder(1),dbseek(Clientes->CodVen))
                        Temp03->(dbappend())
                        Temp03->Chave  := ItemPed->NumPed
                        Temp03->Tipo   := "S"
                        Temp03->Data   := ItemPed->DtaSai
                        Temp03->Documento := "PE "+ItemPed->NumPed
                        Temp03->CodVen := Clientes->CodVen+"-"+left(Vendedor->Nome,18)
                        Temp03->CliFor := Pedidos->CodCli+"-"+left(Clientes->NomCli,30)
                        Temp03->QtdPro := ItemPed->QtdPro
                        Temp03->PcoPro := ItemPed->PcoVen
                        Temp03->Total := ItemPed->PcoVen * ItemPed->QtdPro
                    endif
                    ItemPed->(dbskip())
                enddo
            endif
        // se o estoque for fisico
        elseif nTipoEstoque = 1
            ItemPed->(dbsetorder(4),dbgotop())
            do while ItemPed->(!eof())
                if ItemPed->CodPro == cCodPro
                    Pedidos->(dbsetorder(1),dbseek(ItemPed->NumPed))
                    Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
                    Vendedor->(dbsetorder(1),dbseek(Clientes->CodVen))
                    Temp03->(dbappend())
                    Temp03->Chave  := ItemPed->NumPed
                    Temp03->Tipo   := "S"
                    Temp03->Data   := ItemPed->DtaSai
                    Temp03->Documento := "PE "+ItemPed->NumPed
                    Temp03->CodVen := Clientes->CodVen+"-"+left(Vendedor->Nome,18)
                    Temp03->CliFor := Pedidos->CodCli+"-"+left(Clientes->NomCli,30)
                    Temp03->QtdPro := ItemPed->QtdPro
                    Temp03->PcoPro := ItemPed->PcoVen
                    Temp03->Total := ItemPed->PcoVen * ItemPed->QtdPro
                endif
                ItemPed->(dbskip())
            enddo
        endif
    endif
    if cEstoqAnterior = "S"
        Msg(.t.)
        Msg("Aguarde: Calculando Saldo Anterior")
        Temp03->(dbgotop())
        do while Temp03->(!eof())
            if Temp03->Data < dDataI
                if Temp03->Tipo == "E"
                    nTotAnt += Temp03->QtdPro
                else
                    nTotAnt -= Temp03->QtdPro
                endif
            else
                exit
            endif
            Temp03->(dbskip())
        enddo
        if lGeral
            nTotAnt += Produtos->QtdEstI02
        else
            nTotAnt += Produtos->QtdEstI01
        endif
        Msg(.f.)
    endif
    Temp03->(dbclosearea())
return(.t.)

static procedure Imprima
    local nVideo

    if !Use_dbf(cDiretorio,"tmp"+Arq_Sen+"03",.t.,.t.,"Temp03")
		Mens({"Arquivo de Impressao indisponivel","Tente novamente"})
		return(.f.)
	endif
    set index to (cDiretorio+"tmp"+Arq_Sen)+"03"
    set filter to data >= dDataI .and. Data <= dDataF
    dbgotop()
    If Aviso_1(09,,14,,[Aten‡Æo!],[Imprimir Relat¢rio ?],{ [  ^Sim  ], [  ^NÆo  ] }, 1, .t. ) = 1
        If Ver_Imp2(@nVideo)
            if nVideo == 1
                cImpressoraPadrao := ImpressoraPadrao()
            endif
            oFrPrn := frReportManager():new()
            oFrPrn:LoadLangRes( 'brazil.xml')                     //arquivo de idioma
            oFrPrn:SetWorkArea("Temp03",select("Temp03"))
            oFrprn:LoadFromFile('fichadeprodutos.fr3')
            oFrPrn:AddVariable("variaveis","empresa","'"+cEmpRazao+"'")
            oFrPrn:AddVariable("variaveis","datainicial","'"+dtoc(dDatai)+"'")
            oFrPrn:AddVariable("variaveis","datafinal","'"+dtoc(dDataf)+"'")
            oFrPrn:AddVariable("variaveis","produto","'"+Produtos->CodPro+"-"+Produtos->FanPro+"'")
            oFrPrn:AddVariable("variaveis","saldoanterior","'"+transform(nTotAnt,"@e 999,999.999")+"'")
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
    Temp03->(dbclosearea())
return

        






static procedure ImprimaVELHO
   local cTela := SaveWindow(),lCabec := .t.,nVideo
   local nTecla := 0,lImp := .t.,nTotEnt := 0,nTotSai := 0,nTotAnt := 0
   private nPagina := 1

    if Ver_Imp(@nVideo)
        T_IPorta := "USB"
        
        if !Use_dbf(cDiretorio,"Temp03",.t.,.t.,"Temp03")
            Mens({"Arquivo para impressao indisponivel","Tente novamente"})
            return
        endif
        zap
        index on data to dados\Temp03
        Temp03->(dbclosearea())
        if !Use_dbf(cDiretorio,"Temp03",.t.,.t.,"Temp03")
            Mens({"Arquivo para impressao indisponivel","Tente novamente"})
            return
        endif
        set index to dados\Temp03
        if cTipo $ "E|T"
            Msg(.t.)
            Msg("Aguarde: Processando Entrada")
            Cmp_Ite->(dbsetorder(2),dbgotop())
            do while Cmp_Ite->(!eof())
                if Cmp_Ite->CodPro == cCodPro
                    if nTipoEstoque = 0
                        if !lGeral
                            if Compra->(dbsetorder(1),dbseek(Cmp_Ite->Chave))
                                if Compra->SN
                                    Cmp_Ite->(dbskip())
                                    loop
                                endif
                            endif
                        endif
                        Compra->(dbsetorder(1),dbseek(Cmp_Ite->Chave))
                        Fornecedor->(dbsetorder(1),dbseek(Compra->CodFor))
                        Temp03->(dbappend())
                        Temp03->Chave  := Compra->Chave
                        Temp03->Tipo   := "E"
                        Temp03->Data   := Cmp_Ite->DtaEnt
                        Temp03->Documento := "NF "+Compra->NumNot
                        Temp03->CliFor := Compra->CodFor+"-"+left(Fornecedor->RazFor,30)
                        Temp03->QtdPro := Cmp_Ite->Quantidade
                        Temp03->PcoPro := Cmp_Ite->Custo
                    elseif nTipoEstoque = 1
                        Compra->(dbsetorder(1),dbseek(Cmp_Ite->Chave))
                        Fornecedor->(dbsetorder(1),dbseek(Compra->CodFor))
                        Temp03->(dbappend())
                        Temp03->Chave  := Compra->Chave
                        Temp03->Tipo   := "E"
                        Temp03->Data   := Cmp_Ite->DtaEnt
                        Temp03->Documento := "NF "+Compra->NumNot
                        Temp03->CliFor := Compra->CodFor+"-"+left(Fornecedor->RazFor,30)
                        Temp03->QtdPro := Cmp_Ite->Quantidade
                        Temp03->PcoPro := Cmp_Ite->Custo
                    endif
                endif
                Cmp_Ite->(dbskip())
            enddo
            Msg(.f.)
        endif
        if cTipo $ "S|T"
            if nTipoEstoque = 0
                if !lGeral
                    ProcessarNfe()
                    Nfce()
                    ProcessarPdv()
                else
                    ItemPed->(dbsetorder(4),dbgotop())
                    while ItemPed->(!eof())
                        if ItemPed->CodPro == cCodPro
                            Pedidos->(dbsetorder(1),dbseek(ItemPed->NumPed))
                            Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
                            Vendedor->(dbsetorder(1),dbseek(Clientes->CodVen))
                            Temp03->(dbappend())
                            Temp03->Chave  := ItemPed->NumPed
                            Temp03->Tipo   := "S"
                            Temp03->Data   := ItemPed->DtaSai
                            Temp03->Documento := "PE "+ItemPed->NumPed
                            Temp03->CodVen := Clientes->CodVen+"-"+left(Vendedor->Nome,18)
                            Temp03->CliFor := Pedidos->CodCli+"-"+left(Clientes->NomCli,30)
                            Temp03->QtdPro := ItemPed->QtdPro
                            Temp03->PcoPro := ItemPed->PcoVen
                        endif
                        ItemPed->(dbskip())
                    enddo
                endif
            // se o estoque for fisico
            elseif nTipoEstoque = 1
                ItemPed->(dbsetorder(4),dbgotop())
                do while ItemPed->(!eof())
                    if ItemPed->CodPro == cCodPro
                        Pedidos->(dbsetorder(1),dbseek(ItemPed->NumPed))
                        Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
                        Vendedor->(dbsetorder(1),dbseek(Clientes->CodVen))
                        Temp03->(dbappend())
                        Temp03->Chave  := ItemPed->NumPed
                        Temp03->Tipo   := "S"
                        Temp03->Data   := ItemPed->DtaSai
                        Temp03->Documento := "PE "+ItemPed->NumPed
                        Temp03->CodVen := Clientes->CodVen+"-"+left(Vendedor->Nome,18)
                        Temp03->CliFor := Pedidos->CodCli+"-"+left(Clientes->NomCli,30)
                        Temp03->QtdPro := ItemPed->QtdPro
                        Temp03->PcoPro := ItemPed->PcoVen
                    endif
                    ItemPed->(dbskip())
                enddo
            endif
      end
        if cEstoqAnterior = "S"
            Msg(.t.)
            Msg("Aguarde: Calculando Saldo Anterior")
            Temp03->(dbgotop())
            do while Temp03->(!eof())
                if Temp03->Data < dDataI
                    if Temp03->Tipo == "E"
                        nTotAnt += Temp03->QtdPro
                    else
                        nTotAnt -= Temp03->QtdPro
                    endif
                else
                    exit
                endif
                Temp03->(dbskip())
            enddo
            if lGeral
                nTotAnt += Produtos->QtdEstI02
            else
                nTotAnt += Produtos->QtdEstI01
            endif
            Msg(.f.)
        endif
        Temp03->(dbgotop())
        
        
        begin sequence
         Set Device to Print
         Temp03->(dbgotop())
         set softseek on
         Temp03->(dbsetorder(1),dbseek(dDataI))
         set softseek off
         while Temp03->(!eof())
            if Temp03->Data >= dDataI .and. Temp03->Data <= dDataF
               if lCabec
                  cabec(140,cEmpFantasia,{"Ficha do Produto - "+iif(!lGeral,"0","1"),"No Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
                  if !(left(T_IPorta,3) == "USB")
                     @ prow(),pcol() say T_ICONDI
                  end
                  @ prow()+1,00 say replicate("=",136)
                  //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                  //                           1         2         3         4         5         6         7         8         9         0         1         2         3
                  @ prow()+1,00 say "Chave  T Data       Documento     Vendedor              Fornecedor/Cliente                        Qtde.       Preco           Total"
                  //                 123456 X 99/99/9999 1234567890123 12-123456789012345678 1234-123456789012345678901234567890  99,999,999  99,999.999  999,999,999.99
                  //                                                                                                                              Saldo Anterior: 999,999,999
                  @ prow()+1,00 say replicate("=",136)
                  lCabec := .f.
               end
                if lImp
                    @ prow()+1,00 say Produtos->CodPro+"-"+Produtos->FanPro+" "+Produtos->EmbPro+" x "+str(Produtos->QteEmb,3)
                    if !empty(nTotAnt)
                        @ prow()+1,109 say "Saldo Anterior: "+transform(nTotAnt,"@e 999,999,999")
                    endif
                    @ prow()+1,00 say ""
                    lImp := .f.
                endif
               @ prow()+1,000 say Temp03->Chave
               @ prow()  ,007 say Temp03->Tipo
               @ prow()  ,009 say Temp03->Data
               @ prow()  ,020 say Temp03->Documento
               @ prow()  ,034 say Temp03->CodVen
               @ prow()  ,056 say Temp03->CliFor
               @ prow()  ,098 say iif(Temp03->Tipo = "E",Temp03->QtdPro,(Temp03->QtdPro*-1)) picture "@e 99,999,999"
               @ prow()  ,110 say Temp03->PcoPro picture "@e 99,999.999"
               @ prow()  ,122 say Temp03->QtdPro*Temp03->PcoPro picture "@e 999,999,999.99"
               if Temp03->Tipo == "E"
                  nTotEnt += Temp03->QtdPro
               else
                  nTotSai += Temp03->QtdPro
               end
            end
            Temp03->(dbskip())
            if prow() > 54
               nPagina++
               lCabec := .t.
               if !(left(T_IPorta,3) == "USB")
                  @ prow(),pcol() say T_ICONDF
                  eject
               else
                  @ prow()+1,00 say ""
                  setprc(00,00)
                  eject
               end
            end
         end
      end sequence
      @ prow()+1,00 say replicate("-",136)
      @ prow()+1,00 say "   Saldo Anterior: "+transform(nTotAnt,"@e 999,999,999")
      @ prow()+1,00 say "Saldo de Entradas: "+transform(nTotEnt,"@e 999,999,999")
      @ prow()+1,00 say "  Saldo de Saidas: "+transform(nTotSai,"@e 999,999,999")
      @ prow()+1,00 say "      Saldo Atual: "+transform((nTotAnt+nTotEnt)-nTotSai,"@e 999,999,999")
      FimPrinter(136)
      if !(left(T_IPorta,3) == "USB")
         @ prow(),pcol() say T_ICONDF
         eject
      else
         @ prow()+1,00 say ""
         setprc(00,00)
      end
      set printer to
      set device to screen
      if nVideo == 1
         Fim_Imp(140)
      elseif nVideo == 2
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,maxrow()-1,maxcol(),150)
      end
   end
   RestWindow(cTela)
   return
   
   
static procedure ProcessarNfe

    // ** nota fiscal eletronica
    Msg(.t.)
    Msg("Aguarde: Processando NF-e (saida)")
    if nfeitem->(dbsetorder(3),dbseek(cCodPro))
        do while nfeitem->codpro == cCodPro .and. nfeitem->(!eof())
            if nfeven->(dbsetorder(1),dbseek(nfeitem->NumCon))
                if nfeven->autorizado .and. !nfeven->Cancelada 
                    Clientes->(dbsetorder(1),dbseek(nfeven->CodCli))
                    Vendedor->(dbsetorder(1),dbseek(Clientes->CodVen))
                    Temp03->(dbappend())
                    Temp03->Chave  := strzero(val(nfeitem->NumCon),6)
                    Temp03->Tipo   := "S"
                    Temp03->Data   := nfeven->DtaEmi
                    Temp03->Documento := "NFE "+Nfeven->NumNot
                    Temp03->CodVen := Clientes->CodVen+"-"+left(Vendedor->Nome,18)
                    Temp03->CliFor := nfeven->CodCli+"-"+left(Clientes->NomCli,30)
                    Temp03->QtdPro := nfeitem->QtdPro
                    Temp03->PcoPro := nfeitem->PcoPro
                    Temp03->total := nfeitem->PcoPro*nfeitem->QtdPro 
                endif
            endif
            nfeitem->(dbskip())
        enddo
        nfeitem->(dbskip())
    endif
    Msg(.f.)
    return
    
static procedure Nfce

//    Msg(.t.)
//    Msg("Aguarde: Processando NFc-e")

    if NfceItem->(dbsetorder(3),dbseek(cCodPro))
        do while NfceItem->CodPro == cCodPro .and. NfceItem->(!eof())
            if Nfce->(dbsetorder(1),dbseek(NfceItem->NumCon))
                if Nfce->Autorizado .and. !Nfce->Cancelada
                    Clientes->(dbsetorder(1),dbseek(nfce->codcli))
                    Temp03->(dbappend())
                    Temp03->Chave  := strzero(val(NfceItem->NumCon),6)
                    Temp03->Tipo   := "S"
                    Temp03->Data   := Nfce->DtaEmi
                    Temp03->Documento := "NFCE "+;
                        strzero(val(Nfce->NumNot),9,0)
                    //Temp03->CodVen := Clientes->CodVen+"-"+left(Vendedor->Nome,18)
                    Temp03->CliFor := nfce->CodCli+"-"+left(Clientes->NomCli,30)
                    Temp03->QtdPro := NfceItem->QtdPro
                    Temp03->PcoPro := nfceitem->PcoLiq
                    Temp03->Total := NfceItem->PcoLiq * Nfceitem->QtdPro
                endif
            endif
            NfceItem->(dbskip())
        enddo
    endif
    return
    
static procedure ProcessarPdv

    // 
    if cEstoqAnterior == "N"
        set softseek on
        PdvNfce->(dbsetorder(2),dbseek(dtos(dDataI)))
        if PdvNfce->Data > dDataF
            set softseek off
            return
        endif
        set softseek off
        PdvNfceItem->(dbsetorder(2))
        do while PdvNfce->Data >= dDataI .and. PdvNfce->Data <= dDataF .and. PdvNfce->(!eof())
            if PdvNfce->Autorizado .and. !PdvNfce->Cancelada
                if PdvNfceItem->(dbseek(PdvNfce->Lanc+cCodPro))
                    do while PdvNfceItem->Lanc == PdvNfce->Lanc .and. PdvNfceItem->CodPro == cCodPro .and. PdvNfceItem->(!eof())
                        Clientes->(dbsetorder(1),dbseek(PdvNfce->codcli))
                        Temp03->(dbappend())
                        Temp03->Chave  := strzero(val(PdvNfce->Lanc),6)
                        Temp03->Tipo   := "S"
                        Temp03->Data   := PdvNfce->Data
                        Temp03->Documento := "NFCE "+strzero(val(PdvNfce->Nfce),9,0)
                        Temp03->CliFor := PdvNfce->CodCli+"-"+left(Clientes->NomCli,30)
                        Temp03->QtdPro := PdvNfceItem->QtdPro
                        Temp03->PcoPro := PdvNfceItem->PcoLiq
                        Temp03->total := PdvNfceItem->PcoLiq*PdvNfceItem->QtdPro 
                        PdvNfceItem->(dbskip())
                    enddo
                endif
            endif
            PdvNfce->(dbskip())
        enddo
    else
        if !PdvNfceItem->(dbsetorder(3),dbseek(cCodPro))
            return
        endif
        PdvNfce->(dbsetorder(1))
        do while PdvNfceItem->CodPro == cCodPro .and. PdvNfceItem->(!eof())
            if PdvNfce->(dbseek(PdvNfceItem->Lanc)) 
                if PdvNfce->Autorizado .and. !PdvNfce->Cancelada
                    Clientes->(dbsetorder(1),dbseek(PdvNfce->codcli))
                    Temp03->(dbappend())
                    Temp03->Chave  := strzero(val(PdvNfce->Lanc),6)
                    Temp03->Tipo   := "S"
                    Temp03->Data   := PdvNfce->Data
                    Temp03->Documento := "NFCE "+strzero(val(PdvNfce->Nfce),9,0)
                    Temp03->CliFor := PdvNfce->CodCli+"-"+left(Clientes->NomCli,30)
                    Temp03->QtdPro := PdvNfceItem->QtdPro
                    Temp03->PcoPro := PdvNfceItem->PcoLiq
                    Temp03->total := PdvNfceItem->PcoLiq*PdvNfceItem->QtdPro
                endif
            endif
            PdvNfceItem->(dbskip())
        enddo
    endif
    return
    

//** Fim do Arquivo.
