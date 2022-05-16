/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.2
 * Identificacao: Relatorios de Contas a Pagar por dia
 * Prefixo......: LtAdm
 * Programa.....: RelPag2.prg
 * Autor........: Andre Lucas Souza
 * Data.........: 16 de Fevereiro de 2004
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure RelPag2
   local getlist := {},cTela := SaveWindow()
   local nVideo,cTitulo
   private dDataI,dDataF,nQual

   nQual := Aviso_1(14,,19,,"Aten‡„o!","    Listar quais duplicatas?    ",{" ^Pagas  "," ^A Pagar "},1,.t.)
   if nQual == -27
      FechaDados()
      return
   end
   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenFornecedor()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenCidades()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenDupPag()
        FechaDados()
        Msg(.f.)
        return
    endif
   Msg(.f.)
   AtivaF4()
   Window(09,26,14,53)
   setcolor(Cor(11))
   //           0123456789012345678901234567890
   //                     2
   @ 11,28 say "Data Inicial:"
   @ 12,28 say "  Data Final:"
   while .t.
      dDataI  := date()
      dDataF  := date()
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,42 get dDataI  picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDataI)
      @ 12,42 get dDataF  picture "@k" valid iif(lastkey() == K_UP,.t.,dDataF >= dDataI)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
      Imprima1()
      exit
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
//****************************************************************************
static procedure Imprima1
   local nVideo,nTecla := 0,lCabec := .t.,dData,lData := .t.,lTem := .f.,nTotal := 0
   local nGeral := 0,cTitRel
   private nPagina := 1,lCondicao

   set softseek on
   if nQual == 1
      DupPag->(dbsetorder(3),dbseek(dDataI))
      if DupPag->DtaPag > dDataF
         set softseek off
         Mens({"Nao Existe Nada a pago nesse periodo"})
         return
      end
      lCondicao := "DupPag->DtaPag >= dDataI .and. DupPag->DtaPag <= dDataF"
      cTitRel   := "Relatorio de Duplicatas a Pagar ( Pagas )"
   elseif nQual == 2
      DupPag->(dbsetorder(4),dbseek(dDataI))
      if DupPag->DtaVen > dDataF
         set softseek off
         Mens({"Nao Existe Nada a Pagar nesse periodo"})
         return
      end
      lCondicao := "DupPag->DtaVen >= dDataI .and. DupPag->DtaVen <= dDataF .and. empty(DupPag->DtaPag)"
      cTitRel   := "Relatorio de Duplicatas a Pagar ( A Pagar )"
   end
   set softseek off
   if Ver_Imp(@nVideo)
      T_IPorta := "USB"
      begin sequence
         Msg(.t.)
         if nVideo == 2
            Msg("Aguarde: Gerando o Relatorio (Esc-Cancela)")
         else
            Msg("Aguarde: Imprimindo (Esc-Cancela)")
         end
         set device to printer
         while DupPag->(!eof())
            if &lCondicao.
               if lCabec
                  cabec(96,cEmpFantasia,{cTitRel,"No Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
                  //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                  //                           1         2         3         4         5         6         7         8         9         0         1         2         3
                  @ prow()+1,00 say replicate("=",96)
                  if nQual == 1
                     @ prow()+1,00 say "Fornecedor                                    Duplicata     Vencimento   Pagamento       Valor"
                     //                 1234 1234567890123456789012345678901234567890 1234567890123 99/99/9999  99/99/9999  999,999.99
                  elseif nQual == 2
                     @ prow()+1,00 say "Fornecedor                                    Duplicata        Emissao  Vencimento       Valor"
                     //                 1234 1234567890123456789012345678901234567890 1234567890123 99/99/9999  99/99/9999  999,999.99
                  end
                  //                                                                                                   ------------
                  //                                                                                    Total do Dia : 9,999,999.99
                  //                                                                                     Total Geral : 9,999,999.99
                  @ prow()+1,00 say replicate("=",96)
                  lCabec := .f.
               end
               if lData
//                  if nQual == 1
                     dData := iif(nQual == 1,DupPag->DtaPag,DupPag->DtaVen)
                     @ prow()+1,00 say "===> Data : "+dtoc(dData)+" << "+DatPort(dData,2)+" >>"
                     lData := .f.
//                  end
               end
               Fornecedor->(dbsetorder(1),dbseek(DupPag->CodFor))
               @ prow()+1,00 say DupPag->CodFor
               @ prow()  ,05 say left(Fornecedor->RazFor,40)
               @ prow()  ,46 say DupPag->NumDup
               if nQual == 1
                  @ prow()  ,60 say DupPag->DtaVen
                  @ prow()  ,72 say DupPag->DtaPag
                  @ prow()  ,84 say DupPag->ValPag picture "@e 999,999.99"
                  nTotal += DupPag->ValPag
                  nGeral += DupPag->ValPag
               elseif nQual == 2
                  @ prow()  ,60 say DupPag->DtaEmi
                  @ prow()  ,72 say DupPag->DtaVen
                  @ prow()  ,84 say DupPag->ValDup picture "@e 999,999.99"
                  nTotal += DupPag->ValDup
                  nGeral += DupPag->ValDup
               end
               lTem := .t.
            end
            DupPag->(dbskip())
            nTecla := inkey()
            if nTecla == K_ESC
               set device to screen
               keyboard " "
               If Aviso_1( 16,, 21,, [Aten‡„o!], [Deseja abortar a impress„o?], { [  ^Sim  ], [  ^N„o  ] }, 2, .t., .t. ) = 1
                  set device to print
                  nTecla := K_ESC
                  break
               else
                  nTecla := 0
                  Set Device to Print
               end
            end
            if prow() > 56
               lCabec := .t.
               nPagina += 1
               if !(left(T_IPorta,3) == "USB")
                  //@ prow(),pcol() say &cpi10.
                  eject
               else
                  setprc(00,00)
                  eject
               end
            end
            if lTem
               if !(iif(nQual == 1,DupPag->DtaPag,DupPag->DtaVen) == dData)
                  @ prow()+1,82 say replicate("-",12)
                  @ prow()+1,67 say "Total do Dia : "+transform(nTotal,"@e 9,999,999.99")
                  lData := .t.
                  nTotal := 0
               end
            end
            lTem := .f.
         end
         if nGeral > 0
            @ prow()+1,82 say replicate("-",12)
            @ prow()+1,68 say "Total Geral : "+transform(nGeral,"@e 9,999,999.99")
         end
      end sequence
      if !(left(T_IPorta,3) == "USB")
         @ prow(),pcol() say &cpi10.
      end
      if nTecla == K_ESC
         FimPrinter(iif(nVideo == 1,80,96),"Impressao Cancelada")
      else
         FimPrinter(iif(nVideo == 1,80,96))
      end
      @ prow()+1,00 say ""
      if !(left(T_IPorta,3) == "USB")
         eject
      else
         setprc(00,00)
      end
      set printer to
      set device to screen
      Msg(.f.)
      if nVideo == 1
         Fim_Imp(96)
      elseif nVideo == 2
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,30,100,120)
      end
   end
   return

//** Fim do Arquivo.
