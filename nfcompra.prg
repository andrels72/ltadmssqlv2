/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 3.00
 * Identificacao: Manutencao de Compras (Entradas)
 * Prefixo......: LTADM
 * Programa.....: Entradas.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 05 de Mar‡o de 2004
 * Copyright (C): LT - LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure IncNFCompr
   local cTela := SaveWindow()
   local cCodFor,cNumNot,cEspEnt,cSerie,cSubSer,dDtaEmi,dDtaEnt,cCodMod
   local cCodNat,cObsNot,aCampo[13],aTitulo[13],aMascara[13]
   private aCodigo[10],aDesPro[10],aQtdUnd[10],aTriPro[10],aQtdPro[10]
   private aIPIPro[10],aDscPro[10],aLucPro[10],aPcoBru[10],aCusIni[10]
   private aPcoCus[10],aPcoVen[10],aDtaVal[10],aTotLiq[10],VVencmto, VParcela
   private nValNot,nVlrFre,nPisNot,nFinNot,nICMCre,nICMDeb,nDscNot,nOutDsp
   private nLucro1

   Msg(.t.)
   Msg("Aguarde: Abrindo o(s) Arquivo(s)")
   if !(Abre_Dados(cDiretorio,"Fornece",1,4,"Fornece",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   if !(Abre_Dados(cDiretorio,"Produtos",1,2,"Produtos",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   Msg(.f.)
   AtivaF4()
   TelNFCompr(1)
   while .t.
      cCodFor := space(04)
      cNumNot := space(06)
      cEspEnt := "1"
      cSerie  := space(03)
      cSubSer := space(02)
      dDtaEmi := ctod(space(08))
      dDtaEnt := ctod(space(08))
      cCodMod := space(02)
      cCodNat := space(02)
      cObsNot := space(30)
      nValNot := 0
      nVlrFre := 0
      nPisNot := 0.65
      nFinNot := 2.0
      nOutDsp := 0
      nDscNot := 0
      nICMCre := 0
      nICMDeb := 17
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 03,16 get cCodFor picture "@k 9999" when Rodape("Esc-Encerra | F4-Fornecedores") valid Busca(Zera(@cCodFor),"Fornece",1,03,21,"Fornece->RazFor",{"Fornecedor Nao Cadastrado"},.f.,.f.,.f.)
      @ 04,16 get cNumNot picture "@k 999999" when Rodape("Esc-Encerra") valid V_Zera(@cNumNot)
      @ 04,33 get cEspEnt picture "@k 9" valid MenuArray(@cEspEnt,{{"1","NF"},{"3","D1"},{"4","D2"}},04,33,04,35)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      @ 05,16 get cSerie  picture "@k!"
      @ 05,20 get cSubSer picture "@k!"
      @ 05,33 get dDtaEmi picture "@k"
      @ 05,55 get dDtaEnt picture "@k"
      @ 05,76 get cCodMod picture "@k 99"
      @ 06,16 get cCodNat picture "@k 99"
      @ 07,16 get cObsNot picture "@k!"
      @ 09,16 get nValNot picture "@ke 999,999,999.99"
      @ 09,58 get nVlrFre picture "@ke 999,999,999.99"
      @ 10,16 get nPisNot picture "@r 99.99"
      @ 10,58 get nFinNot picture "@r 99.99"
      @ 11,16 get nOutDsp picture "@r 99.99"
      @ 11,58 get nDscNot picture "@ke 999,999,999.99"
      @ 12,16 get nICMCre picture "@r 99.99"
      @ 12,58 get nICMDeb picture "@r 99.99"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      end
      nLucro1 = ( 100 - ( nICMDeb + nPISNot + nFINNot ) ) / 100
      AFill( aCodigo, Space( 06 ))
      AFill( aDesPro, Space( 40 ))
      AFill( aQtdUnd, Space( 09 ))
      AFill( aTriPro, [  ] )
      AFill( aQtdPro, 0 )
      AFill( aIPIPro, 0 )
      AFill( aDscPro, 0 )
      AFill( aLucPro, 0 )
      AFill( aPcoBru, 0 )
      AFill( aCusIni, 0 )
      AFill( aPcoCus, 0 )
      AFill( aPcoVen, 0 )
      AFill( aTotLiq, 0 )

      aCampo[01] = [aCodigo]
      aCampo[02] = [aDesPro]
      aCampo[03] = [aQtdUnd]
      aCampo[04] = [aTriPro]
      aCampo[05] = [aQtdPro]
      aCampo[06] = [aIPIPro]
      aCampo[07] = [aDscPro]
      aCampo[08] = [aLucPro]
      aCampo[09] = [aPcoBru]
      aCampo[10] = [aCusIni]
      aCampo[11] = [aPcoCus]
      aCampo[12] = [aPcoVen]
      aCampo[13] = [aTotLiq]
      *----------
      aTitulo[01] = [C¢digo]
      aTitulo[02] = [Descri‡„o]
      aTitulo[03] = [Qtd. x Und.]
      aTitulo[04] = [Trib.]
      aTitulo[05] = [Qtde.]
      aTitulo[06] = [IPI]
      aTitulo[07] = [Desconto]
      aTitulo[08] = [Lucro]
      aTitulo[09] = [P‡o. Bruto]
      aTitulo[10] = [Custo Inicial]
      aTitulo[11] = [P‡o. Custo]
      aTitulo[12] = [P‡o. Venda]
      aTitulo[13] = [Total]
      *----------
      aMascara[01] = [@R 999.999]
      aMascara[02] = [@!]
      aMascara[03] = [@X]
      aMascara[04] = [99]
      aMascara[05] = [@R 99,999.99]
      aMascara[06] = [99.99]
      aMascara[07] = [99.99]
      aMascara[08] = [99.99]
      aMascara[09] = [@R 999,999.99]
      aMascara[10] = [@R 999,999.99]
      aMascara[11] = [@R 999,999.99]
      aMascara[12] = [@R 999,999.99]
      aMascara[13] = [@R 99,999,999.99]
      setcolor(Cor(26))
      Centro(21,01,78," F2-Confirma | F4-Inclui | F6-Exclui | F8-Abandona ")
      Rodape("Esc-Encerra")
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      while .t.
         Edita_Vet(14,01,20,78,aCampo,aTitulo,aMascara,"NFC_Ite",,,,1)
         if lastkey() == K_F8
            exit
         end
      end
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
//*****************************************************************************
Function NFC_Ite( Pos_H, Pos_V, Ln, Cl, Tecla )
   Local IPI, Dsc, Fre, Out, MLucro2,cCodPro2

   If Tecla == K_ENTER
      If Pos_H = 1
         cCodPro2 := aCodigo[Pos_V]
         @ Ln, Cl Get cCodPro2 picture "@R 999.999" when Rodape("Esc-Encerra | F4-Produtos") valid Busca(cCodPro2,"Produtos",1,,,,{"Produto Nao Cadastrado"},.f.,.f.,.f.)
         setcursor(SC_NORMAL)
         read
         setcursor(SC_NONE)
         if !(LastKey() == K_ESC)
            if !Empty( cCodPro2 )
               aCodigo[Pos_V] := cCodPro2
               aDesPro[Pos_V] := Produtos->DesPro
               aQtdUnd[Pos_V] := Str( Produtos->QteEmb, 3 ) + " x " + Produtos->EmbPro
               aTriPro[Pos_V] := Produtos->CodFis
               aIPIPro[Pos_V] := Produtos->IPIPro
               aLucPro[Pos_V] := Produtos->LucPro  //** % Lucro
               KeyBoard Replica( Chr( 04 ), 4 ) + Chr( 13 )
            else
               KeyBoard Chr( 04 ) + Chr( 13 )
            end
            Return( 3 )
         end
      //** Quantidade
      elseif Pos_H = 5
         if !Empty( aCodigo[Pos_V] )
            cCampo = aQtdPro[Pos_V]
            @ Ln, Cl Get cCampo Pict [@R 99,999.99] Valid !Empty( cCampo ) .and. LastKey() # 27
            setcursor(SC_NORMAL)
            read
            setcursor(SC_NONE)
            if !(LastKey() == K_ESC)
               if !Empty( cCampo )
                  aQtdPro[Pos_V] := cCampo
                  aTotLiq[Pos_V] := aQtdPro[Pos_V] * aPcoBru[Pos_V]
                  @ 22,64 Say Soma_Vetor( aTotLiq ) picture "@e 999,999,999.99"
               end
               KeyBoard Chr( 04 ) + Chr( 13 )
               Return( 3 )
            end
         end
      //** IPI
      elseif Pos_H = 6
         if !Empty( aCodigo[Pos_V] )
            cCampo = aIPIPro[Pos_V]
            @ Ln, Cl Get cCampo Pict [@R 99.99]
            setcursor(SC_NORMAL)
            read
            setcursor(SC_NONE)
            if !(LastKey() == K_ESC)
               aIPIPro[Pos_V] := cCampo
               IPI := aPcoBru[Pos_V] * ( aIPIPro[Pos_V] / 100 )
               Dsc := aPcoBru[Pos_V] * ( aDscPro[Pos_V] / 100 )
               MLucro2 = ( 100 - ( nICMDeb + aLucPro[Pos_V] + nPISNot + nFINNot ) ) / 100
               aCusIni[Pos_V] := aPcoBru[Pos_V] - Dsc
               aCusIni[Pos_V] := aCusIni[Pos_V] - ( aCusIni[Pos_V] * ( nDscNot / 100 ) )
               Fre := ( aCusIni[Pos_V] + IPI ) * ( Percent(nVlrFre,nValNot,0) / 100 )
               Out := aCusIni[Pos_V] * ( nOutDsp / 100 )
               aPcoCus[Pos_V] := aCusIni[Pos_V] - ( aCusIni[Pos_V] * ( nICMCre / 100 ) )
               aPcoCus[Pos_V] := aPcoCus[Pos_V] + IPI
               aPcoCus[Pos_V] := aPcoCus[Pos_V] + Fre
               aPcoCus[Pos_V] := aPcoCus[Pos_V] + Out
               aPcoCus[Pos_V] := aPcoCus[Pos_V] / nLucro1
               if aLucPro[Pos_V] <= 0
                  aPcoVen[Pos_V] := aPcoCus[Pos_V]
               else
                  aPcoVen[Pos_V] := aCusIni[Pos_V] - ( aCusIni[Pos_V] * ( nICMCre / 100 ) )
                  aPcoVen[Pos_V] := aPcoVen[Pos_V] + IPI
                  aPcoVen[Pos_V] := aPcoVen[Pos_V] + Fre
                  aPcoVen[Pos_V] := aPcoVen[Pos_V] + Out
                  aPcoVen[Pos_V] := aPcoVen[Pos_V] / MLucro2
               end
               aTotLiq[Pos_V] := aQtdPro[Pos_V] * aPcoBru[Pos_V]
               @ 22,64 Say Soma_Vetor( aTotLiq ) picture "@e 999,999,999.99"
               KeyBoard Chr( 04 ) + Chr( 13 )
               Return( 3 )
            end
         end
      //** % Desconto
      elseif Pos_H = 7
         if !Empty( aCodigo[Pos_V] )
            cCampo = aDscPro[Pos_V]
            @ Ln, Cl Get cCampo Pict [99.99]
            Le_Get()
            if LastKey() # 27
               aDscPro[Pos_V] := cCampo
               IPI := aPcoBru[Pos_V] * ( aIPIPro[Pos_V] / 100 )
               Dsc := aPcoBru[Pos_V] * ( aDscPro[Pos_V] / 100 )
               MLucro2 := ( 100 - ( nICMDeb + aLucPro[Pos_V] + nPISNot + nFINNot ) ) / 100
               aCusIni[Pos_V] := aPcoBru[Pos_V] - Dsc
               aCusIni[Pos_V] := aCusIni[Pos_V] - ( aCusIni[Pos_V] * ( nDscNot / 100 ) )
               Fre := ( aCusIni[Pos_V] + IPI ) * ( Percent(nVlrFre,nValNot,0) / 100 )
               Out := aCusIni[Pos_V] * ( nOutDsp / 100 )
               aPcoCus[Pos_V] := aCusIni[Pos_V] - ( aCusIni[Pos_V] * ( nICMCre / 100 ) )
               aPcoCus[Pos_V] := aPcoCus[Pos_V] + IPI
               aPcoCus[Pos_V] := aPcoCus[Pos_V] + Fre
               aPcoCus[Pos_V] := aPcoCus[Pos_V] + Out
               aPcoCus[Pos_V] := aPcoCus[Pos_V] / nLucro1
               if aLucPro[Pos_V] <= 0
                  aPcoVen[Pos_V] := aPcoCus[Pos_V]
               else
                  aPcoVen[Pos_V] := aCusIni[Pos_V] - ( aCusIni[Pos_V] * ( nICMCre / 100 ) )
                  aPcoVen[Pos_V] := aPcoVen[Pos_V] + IPI
                  aPcoVen[Pos_V] := aPcoVen[Pos_V] + Fre
                  aPcoVen[Pos_V] := aPcoVen[Pos_V] + Out
                  aPcoVen[Pos_V] := aPcoVen[Pos_V] / MLucro2
               end
               aTotLiq[Pos_V] := aQtdPro[Pos_V] * aPcoBru[Pos_V]
               @ 22,64 Say Soma_Vetor( aTotLiq ) picture "@e 999,999,999.99"
               KeyBoard Chr( 04 ) + Chr( 13 )
               Return( 3 )
            end
         end
      //** Lucro
      elseif Pos_H = 8
         if !Empty( aCodigo[Pos_V] )
            cCampo = aLucPro[Pos_V]
            @ Ln, Cl Get cCampo Pict [99.99]
            setcursor(SC_NORMAL)
            read
            setcursor(SC_NONE)
            if !(lastKey() == K_ESC)
               aLucPro[Pos_V] = cCampo
               IPI := aPcoBru[Pos_V] * ( aIPIPro[Pos_V] / 100 )
               Dsc := aPcoBru[Pos_V] * ( aDscPro[Pos_V] / 100 )
               MLucro2 = ( 100 - ( nICMDeb + aLucPro[Pos_V] + nPISNot + nFINNot ) ) / 100
               aCusIni[Pos_V] := aPcoBru[Pos_V] - Dsc
               aCusIni[Pos_V] := aCusIni[Pos_V] - ( aCusIni[Pos_V] * ( nDscNot / 100 ) )
               Fre := ( aCusIni[Pos_V] + IPI ) * ( Percent(nVlrFre,nValNot,0) / 100 )
               Out := aCusIni[Pos_V] * ( nOutDsp / 100 )
               aPcoCus[Pos_V] := aCusIni[Pos_V] - ( aCusIni[Pos_V] * ( nICMCre / 100 ) )
               aPcoCus[Pos_V] := aPcoCus[Pos_V] + IPI
               aPcoCus[Pos_V] := aPcoCus[Pos_V] + Fre
               aPcoCus[Pos_V] := aPcoCus[Pos_V] + Out
               aPcoCus[Pos_V] := aPcoCus[Pos_V] / nLucro1
               if aLucPro[Pos_V] <= 0
                  aPcoVen[Pos_V] := aPcoCus[Pos_V]
               else
                  aPcoVen[Pos_V] := aCusIni[Pos_V] - ( aCusIni[Pos_V] * ( nICMCre / 100 ) )
                  aPcoVen[Pos_V] := aPcoVen[Pos_V] + IPI
                  aPcoVen[Pos_V] := aPcoVen[Pos_V] + Fre
                  aPcoVen[Pos_V] := aPcoVen[Pos_V] + Out
                  aPcoVen[Pos_V] := aPcoVen[Pos_V] / MLucro2
               end
               aTotLiq[Pos_V] := aQtdPro[Pos_V] * aPcoBru[Pos_V]
               @ 22,64 Say Soma_Vetor( aTotLiq ) picture "@e 999,999,999.99"
               KeyBoard Chr( 04 ) + Chr( 13 )
               Return( 3 )
            end
         end
      //** Preco Bruto
      elseif Pos_H = 9
         if !Empty( aCodigo[Pos_V] )
            cCampo := aPcoBru[Pos_V]
            @ Ln, Cl Get cCampo Pict [999,999.99] Valid !Empty( cCampo )
            Le_Get()
            if LastKey() # 27
               aPcoBru[Pos_V] := cCampo
               IPI := aPcoBru[Pos_V] * ( aIPIPro[Pos_V] / 100 )
               Dsc := aPcoBru[Pos_V] * ( aDscPro[Pos_V] / 100 )
               MLucro2 = ( 100 - ( nICMDeb + aLucPro[Pos_V] + nPISNot + nFINNot ) ) / 100
               aCusIni[Pos_V] := aPcoBru[Pos_V] - Dsc
               aCusIni[Pos_V] := aCusIni[Pos_V] - ( aCusIni[Pos_V] * ( nDscNot / 100 ) )
               Fre := ( aCusIni[Pos_V] + IPI ) * ( Percent(nVlrFre,nValNot,0) / 100 )
               Out := aCusIni[Pos_V] * ( nOutDsp / 100 )
               aPcoCus[Pos_V] := aCusIni[Pos_V] - ( aCusIni[Pos_V] * ( nICMCre / 100 ) )
               aPcoCus[Pos_V] := aPcoCus[Pos_V] + IPI
               aPcoCus[Pos_V] := aPcoCus[Pos_V] + Fre
               aPcoCus[Pos_V] := aPcoCus[Pos_V] + Out
               aPcoCus[Pos_V] := aPcoCus[Pos_V] / nLucro1
               if aLucPro[Pos_V] <= 0
                  aPcoVen[Pos_V] := aPcoCus[Pos_V]
               else
                  aPcoVen[Pos_V] := aCusIni[Pos_V] - ( aCusIni[Pos_V] * ( nICMCre / 100 ) )
                  aPcoVen[Pos_V] := aPcoVen[Pos_V] + IPI
                  aPcoVen[Pos_V] := aPcoVen[Pos_V] + Fre
                  aPcoVen[Pos_V] := aPcoVen[Pos_V] + Out
                  aPcoVen[Pos_V] := aPcoVen[Pos_V] / MLucro2
               end
               aTotLiq[Pos_V] := aQtdPro[Pos_V] * aPcoBru[Pos_V]
               @ 22,64 Say Soma_Vetor( aTotLiq ) picture "@e 999,999,999.99"
               KeyBoard Replica( Chr( 04 ), 3 ) + Chr( 13 )
               Return( 3 )
            end
         end
      elseif Pos_H = 11
   //      cCampo = VPcoCus[Pos_V]
   //      @ Ln, Cl Get cCampo Pict [999,999.99] Valid !Empty( cCampo )
   //      Le_Get()
   //      if LastKey() # 27
   //         VPcoCus[Pos_V] = cCampo
   //         VTotLiq[Pos_V] = aQtdPro[Pos_V] * VPcoCus[Pos_V]
   //         @ 21, 61 Say Soma_Vetor( VTotLiq ) Pict [@R 99,999,999.99]
   //         KeyBoard Chr( 04 ) + Chr( 13 )
   //         Return( 3 )
   //      end
      elseif Pos_H = 12
         if !Empty( aCodigo[Pos_V] )
            cCampo := aPcoVen[Pos_V]
            @ Ln, Cl Get cCampo Pict [999,999.99] Valid !Empty( cCampo )
            Le_Get()
            if LastKey() # 27
               aPcoVen[Pos_V] = cCampo
               keyboard chr(K_DOWN)+replicate(chr(K_LEFT),Pos_H-1)+chr(K_ENTER)
               Return( 3 )
            end
         end
      end
      Return( 2 )
   elseif Tecla == K_F2
      N_Itens := Len( aCodigo )
      Brancos := 0
      For Laco := 1 to N_Itens
          if !empty(aCodigo[Laco]) .and. (Empty(aQtdPro[Laco]) .or. Empty( aPcoBru[Laco] ) )
             Aviso_1( 10,, 15,, [Aten‡„o!], [N„o s„o permitidos quantidades ou pre‡os zerados.], { [  ^Ok!  ] }, 1, .t., .t. )
             Return( 1 )
          elseif Empty( aCodigo[Laco] )
             ++Brancos
          end
      Next
      if Brancos == N_Itens
         Aviso_1( 10,, 15,, [Aten‡„o!], [N„o ‚ permitido gravar nota sem ¡tens.], { [  ^Ok!  ] }, 1, .t., .t. )
         Return( 1 )
      end
      Return( 0 )
   //** Inclui Itens
   elseif Tecla == K_F4
      if Len( aCodigo ) < 4095
         N_Itens = Len( aCodigo ) + 1
         asize(aCodigo,N_Itens )
         asize(aDesPro,N_Itens )
         asize(aQtdUnd,N_Itens )
         asize(aTriPro,N_Itens )
         asize(aQtdPro,N_Itens )
         asize(aIPIPro,N_Itens )
         asize(aDscPro,N_Itens )
         asize(aAcrAta,N_Itens )
         asize(aPcoBru,N_Itens )
         asize(aCusIni,N_Itens )
         asize(aPcoCus,N_Itens )
         asize(aPcoVen,N_Itens )
         asize(aTotLiq,N_Itens )
         ains(aCodigo,Pos_V + 1 )
         ains(aDesPro,Pos_V + 1 )
         ains(aQtdUnd,Pos_V + 1 )
         ains(aTriPro,Pos_V + 1 )
         ains(aQtdPro,Pos_V + 1 )
         ains(aIPIPro,Pos_V + 1 )
         ains(aDscPro,Pos_V + 1 )
         ains(aAcrAta,Pos_V + 1 )
         ains(aPcoBru,Pos_V + 1 )
         ains(aCusIni,Pos_V + 1 )
         ains(aPcoCus,Pos_V + 1 )
         ains(aPcoVen,Pos_V + 1 )
         ains(aTotLiq,Pos_V + 1 )
         aCodigo[Pos_V+1] = Space( 06 )
         aDesPro[Pos_V+1] = Space( 40 )
         aQtdUnd[Pos_V+1] = Space( 09 )
         aTriPro[Pos_V+1] = [  ]
         aQtdPro[Pos_V+1] = 0
         aIPIPro[Pos_V+1] = 0
         aDscPro[Pos_V+1] = 0
         VAcrAta[Pos_V+1] = 0
         VPcoBru[Pos_V+1] = 0
         VCusIni[Pos_V+1] = 0
         VPcoCus[Pos_V+1] = 0
         VPcoVen[Pos_V+1] = 0
         VTotLiq[Pos_V+1] = 0
         Keyboard Chr( 24 ) + Chr( 13 )
         Return( 3 )
      end
   //** Exclui Itens
   elseif Tecla == K_F6
      if Len( aCodigo ) > 1
         adel( aCodigo, Pos_V )
         adel( aDesPro, Pos_V )
         adel( aQtdUnd, Pos_V )
         adel( aTriPro, Pos_V )
         adel( aQtdPro, Pos_V )
         adel( aIPIPro, Pos_V )
         adel( aDscPro, Pos_V )
         adel( aAcrAta, Pos_V )
         adel( aPcoBru, Pos_V )
         adel( aCusIni, Pos_V )
         adel( aPcoCus, Pos_V )
         adel( aPcoVen, Pos_V )
         adel( aTotLiq, Pos_V )
         N_Itens = Len( aCodigo ) - 1
         asize( aCodigo, N_Itens )
         asize( aDesPro, N_Itens )
         asize( aQtdUnd, N_Itens )
         asize( aTriPro, N_Itens )
         asize( aQtdPro, N_Itens )
         asize( aIPIPro, N_Itens )
         asize( aDscPro, N_Itens )
         asize( aAcrAta, N_Itens )
         asize( aPcoBru, N_Itens )
         asize( aCusIni, N_Itens )
         asize( aPcoCus, N_Itens )
         asize( aPcoVen, N_Itens )
         asize( aTotLiq, N_Itens )
         @ 22,64 Say Soma_Vetor( aTotLiq ) picture "@e 999,999,999.99"
         Return( 3 )
      end
   elseif Tecla == K_F8
      return(0)
   end
   Return( 1 )
//*****************************************************************************
procedure TelNFCompr(nModo)
   local aTitulos := {"Inclusao","Alteracao","Exclusao"}

   Window(02,00,23,79," "+aTitulos[nModo]+" de Entrada - Compra ")
   setcolor(Cor(11))
   //           12345678901234567890123456789012345678901234567890123456789012345678901234567890
   //                    1         2         3         4         5         6         7
   @ 03,01 say "   Fornecedor:"
   @ 04,01 say "  Nota Fiscal:         Especie:"
   @ 05,01 say "    Serie/Sub:    /    Emissao:              Entrada:              Modelo:   "
   @ 06,01 say "     Natureza:"
   @ 07,01 say "   Observacao:                                 Ano AIDF:       N§ AIDF:      "
   @ 08,01 say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
   @ 09,01 say "        Valor:                                    Frete:"
   @ 10,01 say "          PIS:      %                          F.Social:      %"
   @ 11,01 say "  Outras Desp:                                 Desconto:"
   @ 12,01 say " Credito ICMS:      %                       Debito ICMS:      %"
   @ 13,01 say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
   @ 21,01 say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
   @ 22,01 say " Parcelas:                                              Total:                "
   return

//** Fim do Arquivo.
