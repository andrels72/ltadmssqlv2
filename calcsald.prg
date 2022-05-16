/*************************************************************************
         Sistema: Administrativo
          VersÆo: 3.00
   Identificacao: Reorganizar Saldo
         Prefixo: LtAdm
        Programa: CalcSald.prg
           Autor: Andre Lucas Souza
            Data: 16 DE NOVEMBRO DE 2002
   Copyright (C): LUCAS Tecnologia  - 2002
*/
#include "lucas.CH"       // Inclusao do Arquivo Header Padrao
#include "inkey.ch"
#include "setcurs.ch"

procedure ReorgSaldo
   local getlist := {},cTela := SaveWindow()
   local nTipo
   
   Mens({"Para a execu‡Æo desse rotina certifique-se que nÆo existam outo sistema","aberto caso existam feche para Reorganizar os Saldos"})

   nTipo := Aviso_1(10,,15,,"Aten‡„o!","       Escolha o tipo       ", {" ^Por Produto ","  ^Geral  "}, 1, .t. )
   if nTipo == -27
      return
   endif
    if nTipo == 1
        Mens({"Opacao Invalida"})
        return
    endif
	Msg(.t.)
	Msg("Aguarde : Abrindo o Arquivo")
    if !OpenProdutos(.t.)
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
    if !OpenItemPed()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenNFce()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenNFCeItem()
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
    if !OpenNfeVen()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenNfeItem()
        FechaDados()
        Msg(.f.)
        return
    endif
    Msg(.f.)    
	if nTipo == 1
        Mens({"Opacao Invalida"})
		//PorProduto()
	elseif nTipo == 2
		Geral()
	endif
	
	FechaDados()
   return
// *****************************************************************************
static procedure PorProduto
   local getlist := {},cTela := SaveWindow()
   local cCodPro

   Window(09,07,14,71)
   setcolor(Cor(11))
   @ 11,09 say "   Codigo:"
   @ 12,09 say "Descri‡Æo:"
   while .t.
      cCodPro := space(06)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,20 get cCodPro picture "@k 999999";
                when Rodape("Esc-Encerra");
                valid Busca(Zera(@cCodPro),"Produtos",1,12,20,"Produtos->DesPro",{"Produto Nao Cadastrado"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      if !Confirm("Confirma a Informa‡„o")
         loop
      endif
      Msg(.t.)
      Msg("Aguarde: Zerando o Saldo")
      Produtos->QteAc01 := 0
      Produtos->QteAc02 := 0
      Msg(.f.)
      if Cmp_Ite->(dbsetorder(3),dbseek(cCodPro))
         Msg(.t.)
         Msg("Aguarde: Reorganizando Entradas")
         do while Cmp_Ite->CodPro == cCodPro .and. Cmp_Ite->(!eof())
            if Compra->(dbsetorder(1),dbseek(Cmp_Ite->Chave))
               if !Compra->SN
                  Produtos->QteAc01 += Cmp_Ite->QtdPro
                  Produtos->QteAc02 += Cmp_Ite->QtdPro
               else
                  Produtos->QteAc02 += Cmp_Ite->QtdPro
               endif
            endif
            Cmp_Ite->(dbskip())
         enddo
         Msg(.f.)
      endif
      Msg(.t.)
      Msg("Aguarde: Reorganizando Saidas")
      if ItemPed->(dbsetorder(3),dbseek(cCodPro))
         do while ItemPed->CodPro == cCodPro .and. ItemPed->(!eof())
            Produtos->QteAc02 -= ItemPed->QtdPro
            ItemPed->(dbskip())
         enddo
      endif
      if NF_SVite->(dbsetorder(3),dbseek(cCodPro))
         do while NF_SVite->CodPro == cCodPro .and. NF_SVite->(!eof())
            if !(NF_SVite->CanNot == "S")
               Produtos->QteAc01 -= NF_SVIte->QtdPro
            endif
            NF_SVIte->(dbskip())
         enddo
      endif
      if NFSViteA->(dbsetorder(3),dbseek(cCodPro))
         while NFSViteA->CodPro == cCodPro .and. NFSViteA->(!eof())
            Produtos->QteAc01 -= NFSVIteA->QtdPro
            NFSVIteA->(dbskip())
         end
      end
      Msg(.f.)
      exit
   end
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   end
   FechaDados()
   RestWindow(cTela)
   return
// *****************************************************************************
static procedure Geral

    ZerarEstoque()
    CalcularSaldoInicial()
    CalcularEntradas()
    // ** Calcular sa¡das
    // se for os dois estoque
    if nTipoEstoque = 0
        SaidaPedidos()
        SaidaNfce()
        SaidaNfcePdv()
        SaidaNfe()
    // se for o estoque fisico
    elseif nTipoEstoque = 1
        SaidaPedidos()
    endif
    return
    
static procedure ZerarEstoque

    Msg(.t.)
    Msg("Aguarde: Zerando Todos os Saldos")
    Produtos->(dbgotop())
    do while Produtos->(!eof())
        Produtos->QteAc01 := 0 // fiscal
        Produtos->QteAc02 := 0 // fisico
        Produtos->(dbskip())
    enddo
    Msg(.f.)
    return

static procedure CalcularSaldoInicial
	Msg(.t.)
	Msg("Aguarde: Calculando Saldo inicial")
	Produtos->(dbgotop())
	do while Produtos->(!eof())
        // se for os dois estoques
        if nTipoEstoque = 0
            Produtos->QteAc01 := Produtos->QtdEstI01
            Produtos->QteAc02 := Produtos->QtdEstI02
        // se for o nÆo fiscal
        elseif nTipoEstoque = 1
            Produtos->QteAc02 := Produtos->QtdEstI02
        endif
        Produtos->(dbskip())
	enddo
	Msg(.f.)
    return
    
static procedure CalcularEntradas
   
    Msg(.t.)
    Msg("Aguarde: Reorganizando Entradas")
    Compra->(dbsetorder(1),dbgotop())
    Cmp_Ite->(dbsetorder(1))
    Produtos->(dbsetorder(1))
    do while Compra->(!eof())
        if Cmp_ite->(dbseek(Compra->Chave))
            do while Cmp_ite->Chave == Compra->Chave .and. Cmp_Ite->(!eof())
                if Produtos->(dbseek(Cmp_Ite->CodPro))
                    // se o produto controla o estoque
                    if Produtos->CtrLes == "S"
                        // se for os dois estoques
                        if nTipoEstoque = 0
                            // ** se for com nota
                            if !Compra->SN
            	               // ** atualiza o estoque tanto fisico, quanto o fiscal
                                Produtos->QteAc01 += Cmp_Ite->Quantidade
                                Produtos->QteAc02 += Cmp_Ite->Quantidade
                            else
            	               // ** atualiza o estoque fisico
                                Produtos->QteAc02 += Cmp_Ite->Quantidade
                            endif
                        // se for o estoque fisico
                        elseif nTipoEstoque = 1
                            Produtos->QteAc02 += Cmp_ite->Quantidade
                        endif
                        // atualiza a data e pre‡o da ultima compra                                        
                        if empty(Produtos->UltEnt)
                            Produtos->UltEnt := Compra->Dtaemi
                            Produtos->PcoCus := Cmp_ite->Custo
                            Produtos->UltQtd := Cmp_ite->Quantidade
                            Produtos->UltFor := Compra->CodFor
                        else
                            if Compra->DtaEmi >= Produtos->UltEnt
                                Produtos->UltEnt := Compra->DtaEmi
                                Produtos->PcoCus := Cmp_ite->Custo
                                Produtos->UltQtd := Cmp_ite->Quantidade
                                Produtos->UltFor := Compra->CodFor
                            endif
                        endif
                    endif
                endif
                Cmp_Ite->(dbskip())
            enddo
        endif
        Compra->(dbskip())
    enddo
    Msg(.f.)
    return
    
    
static procedure SaidaPedidos
    
    Msg(.t.)
    Msg("Calculando saida: Pedidos")
    ItemPed->(dbgotop())
    do while ItemPed->(!eof())
        if Produtos->(dbsetorder(1),dbseek(ItemPed->CodPro))
            if Produtos->CtrLes == "S"
                Produtos->QteAc02 -= ItemPed->QtdPro
            endif
        endif
        ItemPed->(dbskip())
    enddo
    Msg(.f.)
    return
    
static procedure SaidaNFce
    local nSoma  := 0

    Msg(.t.)
    Msg("Calculando sa¡da: NFC-e")
    Nfce->(dbsetorder(1),dbgotop())
    NfceItem->(dbsetorder(1))
    Produtos->(dbsetorder(1))
    do while Nfce->(!eof())
        // Se for autorizada e nÆo cancelada
        // Diminui do estoque
        if Nfce->Autorizado .and. !Nfce->Cancelada
            NfceItem->(dbseek(Nfce->NumCon))
            do while NfceItem->NumCon == Nfce->NumCon .and. NfceItem->(!eof())
                if Produtos->(dbseek(NfceItem->CodPro))
                    // se o produto controla estoque
                    if Produtos->CtrLes == "S"
                        Produtos->QteAc01 -= NfceItem->QtdPro
                        nSoma += NfceItem->QtdPro
                        // sem nota Produtos->QteAc02 -= NfceItem->QtdPro
                        if NfceItem->QtdPro <= Produtos->QteAc02
                            Produtos->QteAc02 -= NfceItem->QtdPro
                        endif
                    endif
                endif
                NfceItem->(dbskip())
            enddo
        endif
        Nfce->(dbskip())
    enddo
    Msg(.f.)
    return
    
static procedure SaidaNfcePdv

    Msg(.t.)
    Msg("Calculando sa¡da: NFC-e PDV")
    PdvNfce->(dbgotop())
    do while PdvNfce->(!eof())
        // se for estoque f¡sico
        if PdvNfce->Geral
            if PdvNfceItem->(dbsetorder(1),dbseek(PdvNfce->Lanc))
                do while PdvNfceItem->Lanc == PdvNfce->Lanc .and. PdvNfceItem->(!eof())
                    if Produtos->(dbsetorder(1),dbseek(PdvNfceItem->CodPro))
                        if Produtos->CtrLes == "S"
                            Produtos->QteAc01 := Produtos->QteAc01 - PdvNfceItem->QtdPro
                        endif
                    endif
                    PdvNfceItem->(dbskip())
                enddo
            endif
        else
            // Se foi autorizada e nÆo foi cancelada
            if PdvNfce->Autorizado .and. !PdvNfce->Cancelada
                if PdvNfceItem->(dbsetorder(1),dbseek(PdvNfce->Lanc))
                    do while PdvNfceItem->Lanc == PdvNfce->Lanc .and. PdvNfceItem->(!eof())
                        if Produtos->(dbsetorder(1),dbseek(PdvNfceItem->CodPro))
                            if Produtos->CtrLes = "S"
                                Produtos->QteAc01 := Produtos->QteAc01 - PdvNfceItem->QtdPro
                                if Produtos->QteAc02 >= PdvNfceItem->QtdPro 
                                    Produtos->QteAc02 := Produtos->QteAc02 - PdvNfceItem->QtdPro
                                endif
                            endif
                        endif
                        PdvNfceItem->(dbskip())
                    enddo
                endif
            endif
        endif
        PdvNfce->(dbskip())
    enddo
    Msg(.f.)
    return
    
static procedure SaidaNfe

    Msg(.t.)
    Msg("Calculando sa¡da: NF-e")
    NfeVen->(dbsetorder(1))
    Produtos->(dbsetorder(1))
    NfeItem->(dbsetorder(1))
    do while NfeVen->(!eof())
        // se foi gerada e foi transmitida e nÆo foi cancelada
        // retira do estoque
        //if NfeVen->nfegerada .and. NfeVen->NFeTransmi .and. !(NfeVen->CanNot == "S")
        if nfeven->autorizado .and. !nfeven->Cancelada
            if NfeItem->(dbseek(NfeVen->NumCon))
                do while NfeItem->NumCon == NfeVen->NumCon .and. NfeItem->(!eof())
                    if Produtos->(dbseek(NfeItem->CodPro))
                        // ** se o produto controla estoque
                        if Produtos->CtrLes = "S"
                            Produtos->QteAc01 := Produtos->QteAc01 - NfeItem->QtdPro
                            if Produtos->QteAc02 <= NfeItem->QtdPro 
                                Produtos->QteAc02 := Produtos->QteAc02 - NfeItem->QtdPro
                            endif
                            Produtos->(dbcommit())
                        endif
                    endif
                    NfeItem->(dbskip())
                enddo
            endif
        endif
        NfeVen->(dbskip())
    enddo
    Msg(.f.)
    return

//** Fim do Arquivo.