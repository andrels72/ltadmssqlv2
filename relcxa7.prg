/*************************************************************************
 * Sistema......: Fluxo de Caixa
 * Versao.......: 2.00
 * Identificacao: Relatorios de Resumo do Movimento do Caixa
 * Prefixo......: LtAdm
 * Programa.....: RelCxa7.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 15 de MarÎo de 2004
 * Copyright (C): LT - LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"
#include "setcurs.ch"

procedure RelCxa7()
   local getlist := {},cTela := SaveWindow()
   local dDataI := date(),dDataF := date(),cCodCaixa,cCodHist,cTipHist
   local cSldAnter

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenCaixa()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenHistCxa()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenMovCxa()
      FechaDados()
      Msg(.f.)
      return
   endif
   Msg(.f.)
   AtivaF4()
   Window(08,14,14,64,"> Resumo do Movimento do Caixa <")
   setcolor(Cor(11))
   //           6789012345678901234567890123456789012345678901234567890123456789012345678
   //               2         3         4         5         6         7
   @ 10,16 say "Data Inicial:"
   @ 11,16 say "  Data Final:"
   @ 12,16 say "       Caixa:"
   while .t.
      cCodCaixa := space(02)
      cTipHist := space(01)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 10,30 get dDataI picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDataI)
      @ 11,30 get dDataF picture "@k" valid dDataF >= dDataI
      @ 12,30 get cCodCaixa picture "@k 99" when Rodape("Esc-Encerra | F4-Caixas") valid iif(lastkey() == K_UP,.t.,Busca(Zera(@cCodCaixa),"Caixa",1,12,33,"Caixa->NomCaixa",{"Caixa Nao Cadastrado"},.f.,.t.,.f.))
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
      Imprima(cCodCaixa,dDataI,dDataF)
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
//****************************************************************************
static procedure Imprima(cCodCaixa,dDataI,dDataF)
   local cTela := SaveWindow(),nTecla := 0,nVideo,nRecno,dData,cImpressoraPadrao
   private aCodHist := {},aEntrada := {},aSaida := {},nPos := 0,nSaldo := 0,lCabec := .t.
   private nPagina := 1 

   set softseek on
   MovCaixa->(dbsetorder(3),dbseek(cCodCaixa+dtos(dDataI)))
   if MovCaixa->(eof()) .or. MovCaixa->Data > dDataF .or. !(MovCaixa->CodCaixa == cCodCaixa)
      Mens({"Nao Existe Movimento"})
      set softseek off
      return
   end
   set softseek off
   Msg(.t.)
   Msg("Aguarde : Estou selecionando as informacoes")
   MovCaixa->(dbsetorder(3),dbgotop())
   while MovCaixa->(!eof())
      if MovCaixa->Data >= dDataI .and. MovCaixa->Data <= dDataF .and. MovCaixa->CodCaixa == cCodCaixa
         nPos := ascan(aCodHist,MovCaixa->CodHisto)
         if !(nPos == 0)
            if MovCaixa->Tipo == "1" // Credito
               aEntrada[nPos] += MovCaixa->Valor
            else
               aSaida[nPos] += MovCaixa->Valor
            end
         else
            aadd(aCodHist,MovCaixa->CodHisto)
            if MovCaixa->Tipo == "1" // Credito
               aadd(aEntrada,MovCaixa->Valor)
               aadd(aSaida  ,0)
            else
               aadd(aSaida  ,MovCaixa->Valor)
               aadd(aEntrada,0)
            end
         end
      end
      MovCaixa->(dbskip())
   end
   Msg(.f.)
   nPos := 1
        if Ver_Imp2(@nVideo,2)
            if nVideo = 1
                cImpressoraPadrao := ImpressoraPadrao()
                ImprimaUSB(cCodCaixa,dDataI,dDataF,cImpressoraPadrao)
                return
            endif
         begin sequence
         Set Device to Print
         while .t.
            if lCabec
               cabec(96,cEmpFantasia,{"RESUMO DO MOVIMENTO POR HISTORICO",;
                     "Caixa..........: "+cCodCaixa+"-"+Caixa->NomCaixa,"Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)},.f.)
               @ prow()+1,00 say replicate("=",96)
               oPrinter:SetFont(cFont,,13)
               //                 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
               //                           1         2         3         4         5         6         7         8         9
               @ prow()+1,00 SAY "Historico                                                    Entrada        Saida         Saldo"
               //                 123-12345678901234567890123456789012345678901234567890 99,999,999.99 9,999,999.99 99,999,999.99
               //                                                                 Total: 99,999,999.99 9,999,999.99 99,999,999.99
               @ prow()+1,00 say replicate("=",96)
               lCabec := .f.
            end
            Historico->(dbsetorder(1),dbseek(aCodHist[nPos]))
            @ prow()+1,00 say aCodHist[nPos]
            @ prow()  ,04 say Historico->NomHist
            @ prow()  ,55 say aEntrada[nPos] picture "@e 99,999,999.99"
            @ prow()  ,69 say aSaida[nPos]   picture "@e 99,999,999.99"
            nSaldo += aEntrada[nPos]-aSaida[nPos]
            @ prow()  ,82 say nSaldo picture "@e 99,999,999.99"
            nPos += 1
            if prow() > 55
               nPagina++
               lCabec := .t.
               if !(left(T_IPorta,3) == "USB")
                  eject
               else
                  setprc(00,00)
                  eject
               end
            end
            if nPos > len(aCodHist)
               exit
            end
         end
         end sequence
         @ prow()+1,00 say replicate("-",96)
         @ prow()+1,48 say "Total:"
         @ prow()  ,55 say Soma_Vetor(aEntrada) picture "@e 99,999,999.99"
         @ prow()  ,69 say Soma_Vetor(aSaida)   picture "@e 99,999,999.99"
         @ prow()  ,82 say Soma_Vetor(aEntrada)-Soma_Vetor(aSaida) picture "@e 99,999,999.99"
         FimPrinter(96)
         eject
         Set Printer to
         set device to screen
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,33,100,150)
      endif
   RestWindow(cTela)
   return


static procedure ImprimaUSB(cCodCaixa,dDataI,dDataF,cImpressoraPadrao)
    private oPrinter,cPrinter,cFont
    
   if !IniciaImpressora(cImpressoraPadrao)
      return
   endif
   Msg(.t.)
   Msg("Aguarde: Imprimindo Rel¢rio")
    do while .t.
        if lCabec
            oPrinter:SetFont(cFont,,11)
            CabecUSB(80,cEmpFantasia,{"RESUMO DO MOVIMENTO POR HISTORICO",;
                     "Caixa..........: "+cCodCaixa+"-"+Caixa->NomCaixa,"Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)},.f.)
            ImpLinha(oPrinter:prow()+1,00,replicate("=",80))
            //                 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
            //                           1         2         3         4         5         6         7         8         9
            oPrinter:SetFont(cFont,,13)
            ImpLinha(oPrinter:prow()+1,00,"Historico                                                    Entrada        Saida         Saldo")
            //                 123-12345678901234567890123456789012345678901234567890 99,999,999.99 9,999,999.99 99,999,999.99
            //                                                                 Total: 99,999,999.99 9,999,999.99 99,999,999.99
            oPrinter:SetFont(cFont,,11)
            ImpLinha(oPrinter:prow()+1,00,replicate("=",80))
            oPrinter:SetFont(cFont,,13)
            lCabec := .f.
        endif
        Historico->(dbsetorder(1),dbseek(aCodHist[nPos]))
        ImpLinha(oPrinter:prow()+1,00,aCodHist[nPos])
        ImpLinha(oPrinter:prow()  ,04,Historico->NomHist)
        ImpLinha(oPrinter:prow()  ,55,transform(aEntrada[nPos],"@e 99,999,999.99"))
        ImpLinha(oPrinter:prow()  ,69,transform(aSaida[nPos],"@e 99,999,999.99"))
        nSaldo += aEntrada[nPos]-aSaida[nPos]
        ImpLinha(oPrinter:prow()  ,82,transform(nSaldo,"@e 99,999,999.99"))
        nPos += 1
        if oPrinter:prow() > 55
            nPagina++
            lCabec := .t.
            oPrinter:NewPage()
        endif
        if nPos > len(aCodHist)
            exit
        endif
    enddo
    ImpLinha(oPrinter:prow()+1,00,replicate("-",96))
    ImpLinha(oPrinter:prow()+1,48,"Total:")
    ImpLinha(oPrinter:prow()  ,55,transform(Soma_Vetor(aEntrada),"@e 99,999,999.99"))
    ImpLinha(oPrinter:prow()  ,69,transform(Soma_Vetor(aSaida),"@e 99,999,999.99"))
    ImpLinha(oPrinter:prow()  ,82,transform(Soma_Vetor(aEntrada)-Soma_Vetor(aSaida),"@e 99,999,999.99"))
	oPrinter:enddoc()
	oPrinter:Destroy()
    Msg(.f.)
    return


 
//** Fim do Arquivo.
