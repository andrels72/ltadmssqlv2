/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.00
 * Identificacao: Modulo de Rotinas
 * Prefixo......: LtSCC
 * Programa.....: ROTINAS.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 16 DE NOVEMBRO DE 2002
 * Copyright (C): LUCAS Tecnologia  - 2002
*/
#include "lucas.CH"       // Inclusao do Arquivo Header Padrao
#include "inkey.ch"
#include "setcurs.ch"

procedure ManParamet
   local getlist := {},cTela := SaveWindow()
   local cLimDsc, cChvPro, cDirCxa, cFixImp, cTempo, cSaiLoj, cLojPdr
   local cGerDup, cPerSld, cTestIm, cLptNot, cTamPag, cAltPco, cAtrCli
   local cNumVia, nValPis, nValCof, cQueNot, cAtuPcoV,cLptPed
   local nNumNot, cIcmsNot,cMCupom1,cMCupom2,cMCupom3,cModImpProp
   local cImpRecibo,cModRecibo,cModProposta

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !(Abre_Dados(cDiretorio,"Printer",1,2,"Printer",1,.t.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   if !OpenSequencia()
      FechaDados()
      Msg(.f.)
      return
   end
   Msg(.f.)
   Window(02,00,27,79,"> Parametros do Sistema <")
   setcolor(Cor(11))
   //            23456789012345678901234567890123456789012345678901
   //                    1         2         3         4         5
   @ 04,02 say "               Chave de Busca p/ Produtos:"
   @ 05,02 say "   Limite M ximo de Desconto na Venda (%):"
   @ 06,02 say "Escolher Impressora na Hora da Impress„o?:"
   @ 07,02 say "      Atualizar Preco de Venda na Entrada:"
   @ 08,02 say "  Fazer Pergunta Quando Gerar Duplicatas?:"
   @ 09,02 say "      Testar Antes a Porta da Impressora?:"
   @ 10,02 say "   Local Padr„o para Imprimir Nota Fiscal:"
   @ 11,02 say "       Local Padr„o para Imprimir Pedidos:"
   @ 12,02 say "     Local padrao para Imprimir Orcamento:"
   
   @ 13,02 say "              Tamanho da P gina do Pedido: "
   @ 14,02 say "Permitir Alterar Pre‡o de Venda na Sa¡da?: "
   @ 15,02 say "        Permitir Atraso em Duplicatas At‚:        dia(s)"
   @ 16,02 say "                           Numero de Vias:        via(s)"
   @ 17,02 say "                                      PIS:"
   @ 18,02 say "                                   COFINS:"
   @ 19,02 say "          Modelo de impressao da Proposta:"
   @ 20,02 say "         Imprimir recibo na venda a vista:"
   @ 21,02 say "            Modelo de impressÆo do recibo:"
   @ 22,02 say "          Modelo de impressÆo da proposta:"
   
   @ 23,01 say replicate(chr(196),78)
   @ 23,01 say " Mensagem para CUPOM NAO FISCAL " color Cor(26)
   
   while .t.
      cChvPro  := Str(C_VChvPro,1)
      cLimDsc  := C_VLimDsc
      cDirCxa  := Pad(C_VCaixa,30)
      cFixImp  := C_VFixImp
      cAtuPcoV := C_VAtuPcoV
      cSaiLoj  := C_VSaiLoj
      cLojPdr  := C_VLojPdr
      cGerDup  := C_VGerDup
      cPerSld  := C_VPerSld
      cTestIm  := C_VTestIm
      cLptNot  := T_VLptNot
      cLptPed  := T_VLptPed
      cLptOrc  := Sequencia->LptOrc
      cTamPag  := Str(C_VTamPag,1)
      cAltPco  := C_VAltPco
      cAtrCLi  := C_VAtrCli
      cNumVia  := C_VNumVia
      nValPis  := C_VValPis
      nValCof  := C_VValCof
      cQueNot  := C_VQueNot
      cIcmsNot := C_VICMSCa
      nNumNot := Sequencia->NumNot
      cMCupom1 := Sequencia->MCupom1
      cMCupom2 := Sequencia->MCupom2
      cMCupom3 := Sequencia->MCupom3
      cModImpProp := Sequencia->ModImpProp // ** Modelo de impressão da proposta
      cImpRecibo  := Sequencia->ImpRecibo
      cModRecibo := Sequencia->ModRecibo
      cModProposta := Sequencia->ModPropost
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 04,45 get cChvPro   picture "@!"        valid MenuArray(@cChvPro,{{"1","C¢digo"},{"2","Barras"}},04,45,04,47)
      @ 05,45 get cLimDsc   picture "@R 99.99"
      @ 06,45 get cFixImp   picture "@!"        valid MenuArray(@cFixImp,{{"S","Sim"},{"N","Nao"}},06,45,06,45)
      @ 07,45 get cAtuPcoV  picture "@!"        valid MenuArray(@cAtuPcoV,{{"S","Sim"},{"N","Nao"}},07,45,07,45)
      @ 08,45 get cGerDup   picture "@!"        valid MenuArray(@cGerDup,{{"S","Sim"},{"N","Nao"}},08,45,08,45)
      @ 09,45 get cTestIm   picture "@!"        valid Menuarray(@cTestIm,{{"S","Sim"},{"N","Nao"}},09,45,09,45)
      @ 10,45 get cLptNot   picture "@!"        Valid V_SeleImp( @cLptNot )
      @ 11,45 get cLptPed   picture "@!"        valid V_SeleImp(@cLptPed)
      @ 12,45 get cLptOrc   picture "@!"        valid V_SeleImp(@cLptOrc)
      @ 13,45 get cTamPag   picture "@R 9"      valid MenuArray(@cTamPag,{{"1","33-Linhas"},{"2","66-Linhas"}},13,45,13,47)
      @ 14,45 get cAltPco   picture "@!"        valid MenuArray(@cAltPco,{{"S","Sim"},{"N","Nao"}},14,45,14,45)
      @ 15,45 Get cAtrCli   picture "@RK99"     Valid !Empty(cAtrCli) .and. Vld_Zera(@cAtrCli)
      @ 16,45 Get cNumVia   picture "@RK99"     Valid !Empty(cNumVia) .and. Vld_Zera(@cNumVia)
      @ 17,45 Get nValPis   picture "@R 99.99%"
      @ 18,45 Get nValCof   picture "@R 99.99%"
      @ 19,45 get cModImpProp picture "@k 9";
                valid MenuArray(@cModImpProp,{{"1","Normal          "},{"2","Cupom Nao Fiscal"},{"3","Grafico"}})
                
        @ 20,45 get cImpRecibo picture "@k!";
                valid MenuArray(@cImpRecibo,{{"S","Sim"},{"N","Nao"}})
        @ 21,45 get cModRecibo picture "@k9";
                valid MenuArray(@cModRecibo,{{"1","Folha A4"},{"2","Cupom nÆo fiscal"}})
        // Modelo de impressÆo da proposta
        @ 22,45 get cModProposta picture "@k9";
                valid MenuArray(@cModProposta,{{"1","Folha A4"},{"2","Cupom nÆo fiscal"}})
        
        @ 24,01 get cMCupom1  picture "@k"
        @ 25,01 get cMCupom2  picture "@k"
        @ 26,01 get cMCupom3  picture "@k"
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        if !Confirm("Confirmas as Informacoes")
            loop
      endif
      C_VChvPro  := Val(cChvPro)
      C_VLimDsc  := cLimDsc
      C_VFixImp  := cFixImp
      C_VAtuPcoV := cAtuPcoV
      C_VGerDup  := cGerDup
      C_VTestIm  := cTestIm
      T_VLptNot  := cLptNot
      T_VLptPed  := cLptPed
      C_VTamPag  := Val(cTamPag)
      C_VAltPco  := cAltPco
      C_VAtrCli  := cAtrCli
      C_VNumVia  := cNumVia
      C_VValPis  := nValPis
      C_VValCof  := nValCof
      C_VQueNot  := cQueNot
      C_VICMSCa  := cIcmsNot
      Save All Like C_* to &Arq_CFG
      Save All Like T_* to &ArqTerm
      while !Sequencia->(Trava_Reg())
      end
      Sequencia->NumNot := nNumNot
      Sequencia->LptOrc := cLptOrc
      Sequencia->MCupom1 := cMCupom1
      Sequencia->MCupom2 := cMCupom2
      Sequencia->MCupom3 := cMCupom3
      Sequencia->ModImpProp := cModImpProp
      Sequencia->ImpRecibo := cImpRecibo
      Sequencia->ModRecibo := cModRecibo
      Sequencia->ModPropost := cModProposta
      Sequencia->(dbunlock())
      exit
   end
   FechaDados()
   RestWindow(cTela)
   return
//*****************************************************************************
Function V_SeleImp(Porta)
   Local Loc_Imp := {}, Tel_Ant, Opcao, Var

   If Empty(Porta)
      Tel_Ant := SaveScreen( 09, 50, 20, 78 )
      Printer->(dbgotop())
      while Printer->(!EoF())
         AAdd(Loc_Imp, Printer->LocImp )
         Printer->(dbskip())
      EndDo
      Opcao := Menu_VR( 09, 50, 20, 78, Loc_Imp, 0, Cor(2),Cor(3),Cor(15), 1 )
      If Opcao > 0
         Porta:=Loc_Imp[Opcao]
      EndIf
      RestScreen( 09, 50, 20, 78, Tel_Ant )
   EndIf
   Return .t.

//** Fim do Arquivo.
