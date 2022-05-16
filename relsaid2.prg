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

procedure RelSaid2
   local getlist := {},cTela := SaveWindow()
   private cCodCli,dDataI,dDataF,cResumi

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenClientes()
      FechaDados()
      Msg(.f.)
      return
   end
   if !OpenProdutos()
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
   AtivaF4()
   Window(09,03,16,66)
   setcolor(Cor(11))
   //           56789012345678901234567890123456789012345678901234567890123456789012345678
   //                1         2         3         4         5         6         7
   @ 11,05 say "     Cliente:"
   @ 12,05 say "Data Inicial:"
   @ 13,05 say "  Data Final:"
   @ 14,05 say "    Resumido:"
   while .t.
      cCodCli := space(04)
      dDataI  := ctod(space(08))
      dDataF  := ctod(space(08))
      cResumi := "S"
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,19 get cCodCli picture "@k 9999" when Rodape("Esc-Encerra | F4-Clientes") valid vCliente(@cCodCli)
      @ 12,19 get dDataI  picture "@k"      when Rodape("Esc-Encerra") valid iif(lastkey() == K_UP,.t.,NoEmpty(dDataI))
      @ 13,19 get dDataF  picture "@k" valid iif(lastkey() == K_UP,.t.,dDataF >= dDataI)
      @ 14,19 get cResumi picture "@k!" valid MenuArray(@cResumi,{{"S","Sim"},{"N","Nao"}},14,19)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
      if cResumi == "S"
         Imprima()
      else
         Imprima2()
      end
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// *****************************************************************************
static procedure Imprima
   local nVideo,lCabec := .t.,nTotal := 0,nQtd := 0,nTecla := 0
   local lCondicao,lData := .t.,dData,nTotal2 := 0,nQtd2 := 0
   private nPagina := 1

   if !empty(cCodCli)
      set softseek on
      nfeven->(dbsetorder(4),dbseek(cCodCli+dtos(dDataI)))
      if nfeven->(eof()) .or. !(cCodCli == nfeven->CodCli) .or. nfeven->DtaEmi > dDataF
         set softseek off
         Mens({"Nao Existe Nota"})
         return
      end
      lCondicao := "nfeven->CodCli == cCodCli .and. nfeven->DtaEmi >= dDataI .and. nfeven->DtaEmi <= dDataF"
   else
      set softseek on
      nfeven->(dbsetorder(6),dbseek(dtos(dDataI)))
      if nfeven->(eof()) .or. nfeven->DtaEmi > dDataF
         set softseek off
         Mens({"Nao Existe Nota"})
         return
      end
      lCondicao := "nfeven->DtaEmi >= dDataI .and. nfeven->DtaEmi <= dDataF"
   end
   set softseek off
   if Ver_Imp(@nVideo)
      T_IPorta := "USB"
      begin sequence
         Msg(.t.)
         if nVideo == 1
            Msg("Aguarde: Imprimindo (Esc-Cancela)")
         else
            Msg("Aguarde: Gerando o Relatorio (Esc-Cancela)")
         end
         set device to printer
         while nfeven->(!eof())
            if &lCondicao. .and. !(nfeven->CanNot == "S")
               if lCabec
                  cabec(96,cEmpFantasia,{"Relatorio de Notas de Saida - Nao Resumido","Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
                  @ prow()+1,00 say replicate("=", 96 )
                  //                 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
                  //                           1         2         3         4         5         6         7         8         9         0         1
                  @ prow()+1,00 SAY "Numero    Data        Cliente                                             Valor"
                  //                 123456789 99/99/9999  1234 1234567890123456789012345678901234567890  999,999.99   999,999.99
                  //                                                                            Total : 9,999,999.99
                  @ prow()+1,00 say replicate("=",96)
                  lCabec := .f.
               end
               if lData
                  dData := nfeven->DtaEmi
                  lData := .f.
                  nQtd2 += 1
               end
               Clientes->(dbsetorder(1),dbseek(nfeven->CodCli))
               @ prow()+1,00 say nfeven->NumNot
               @ prow()  ,10 say nfeven->DtaEmi
               @ prow()  ,22 say nfeven->CodCli
               @ prow()  ,27 say Clientes->NomCli
               @ prow()  ,69 say nfeven->TotNot picture "@e 999,999.99"
               nTotal += nfeven->TotNot
               nTotal2 += nfeven->TotNot
               nQtd += 1
            end
            nfeven->(dbskip())
            if !lData
               if !(dData == nfeven->DtaEmi)
               	/*
                  @ prow() ,80 say nTotal2 picture "@e 999,999.99"
                */
                  nTotal2 := 0
                  lData := .t.
               endif
            endif
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
            if prow() > 55
               nPagina += 1
               lCabec := .t.
               if !(left(T_IPorta,3) == "USB")
                  eject
               else
                  @ prow()+1,00 say ""
                  setprc(00,00)
                  eject
               end
            end
         end
         @ prow()+1,00 say replicate("-",96)
         @ prow()+1,00 say "Listadas : "+transform(nQtd,"@e 999,999")
         @ prow()  ,59 say "Total : "+transform(nTotal,"@e 9,999,999.99")
      end sequence
      if nTecla == K_ESC
         FimPrinter(96,"Impressao Cancelada")
      else
         FimPrinter(96)
      end
      if !(left(T_IPorta,3) == "USB")
         eject
      else
         @ prow()+1,00 say ""
         setprc(00,00)
      end
      set printer to
      set device to screen
      Msg(.f.)
      if nVideo == 1
         Fim_Imp(96)
      elseif nVideo == 2
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,140)
      end
   end
   return
// *****************************************************************************
static procedure Imprima2
   local nVideo,lCabec := .t.,nTotal := 0,nQtd := 0,nTecla := 0
   local lCondicao
   private nPagina := 1

   if !empty(cCodCli)
      set softseek on
      nfeven->(dbsetorder(4),dbseek(cCodCli+dtos(dDataI)))
      if nfeven->(eof()) .or. !(cCodCli == nfeven->CodCli) .or. nfeven->DtaEmi > dDataF
         set softseek off
         Mens({"Nao Existe Nota"})
         return
      end
      lCondicao := "nfeven->CodCli == cCodCli .and. nfeven->DtaEmi >= dDataI .and. nfeven->DtaEmi <= dDataF .and. !(nfeven->CanNot == 'S')"
   else
      set softseek on
      nfeven->(dbsetorder(6),dbseek(dtos(dDataI)))
      if nfeven->(eof()) .or. nfeven->DtaEmi > dDataF
         set softseek off
         Mens({"Nao Existe Nota"})
         return
      end
      lCondicao := "nfeven->DtaEmi >= dDataI .and. nfeven->DtaEmi <= dDataF .and. !(nfeven->CanNot == 'S')"
   end
   set softseek off
   if Ver_Imp(@nVideo)
      T_IPorta := "USB"
      begin sequence
         Msg(.t.)
         if nVideo == 1
            Msg("Aguarde: Imprimindo (Esc-Cancela)")
         else
            Msg("Aguarde: Gerando o Relatorio (Esc-Cancela)")
         end
         set device to printer
         while nfeven->(!eof())
            if &lCondicao.
               if lCabec
                  cabec(140,cEmpFantasia,{"Relatorio de Notas de Saida - Resumido","Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
                  @ prow()+1,00 say replicate("=", 140)
                  //                 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
                  //                           1         2         3         4         5         6         7         8         9         0         1
                  @ prow()+1,00 SAY "Numero    Data        Cliente                                        Valor"
                  //                 123456789 99/99/9999  1234 1234567890123456789012345678901234567890  999,999.99
                  //
                  //                         1234567890 12345678901234567890123456789012345678901234567890  999,999  99,999.999  9,999,999.99
                  @ prow()+1,00 say replicate("=",140)
                  lCabec := .f.
               end
               Clientes->(dbsetorder(1),dbseek(nfeven->CodCli))
               @ prow()+1,00 say nfeven->NumNot
               @ prow()  ,10 say nfeven->DtaEmi
               @ prow()  ,22 say nfeven->CodCli
               @ prow()  ,27 say Clientes->NomCli
               @ prow()  ,69 say nfeven->TotNot picture "@e 999,999.99"
               @ prow()+1,10 say "Chave : "+transform(nfeven->ChNfe,"@r 9999.9999.9999.9999.9999.9999.9999.9999.9999.9999.9999")
               if nfeitem->(dbsetorder(1),dbseek(nfeven->NumCon))
                  @ prow()+1,00 say ""
                  while nfeitem->NumCon == nfeven->NumCon .and. nfeitem->(!eof())
                     Produtos->(dbsetorder(1),dbseek(nfeitem->CodPro))
                     @ prow()+1,08 say nfeitem->CodPro
                     @ prow()  ,19 say Produtos->DesPro
                     @ prow()  ,71 say nfeitem->QtdPro picture "@e 999,999"
                     @ prow()  ,80 say nfeitem->PcoPro picture "@e 99,999.99"
                     @ prow()  ,92 say nfeitem->PcoPro * nfeitem->QtdPro picture "@e 9,999,999.99"
                     nfeitem->(dbskip())
                     if prow() > 55
                        if !(left(T_IPorta,3) == "USB")
                           eject
                        else
                           setprc(00,00)
                           eject
                        end
                     end
                  end
                  @ prow()+1,00 say ""
               end
               nTotal += nfeven->TotNot
               nQtd += 1
            end
            nfeven->(dbskip())
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
            if prow() > 55
               nPagina += 1
               lCabec := .t.
               if !(left(T_IPorta,3) == "USB")
                  eject
               else
                  setprc(00,00)
                  eject
               end
            end
         end
         @ prow()+1,00 say replicate("-",140)
         @ prow()+1,00 say "Listadas : "+transform(nQtd,"@e 999,999")
         @ prow()  ,57 say "Total : "+transform(nTotal,"@e 9,999,999.99")
      end sequence
      if nTecla == K_ESC
         FimPrinter(136,"Impressao Cancelada")
      else
         FimPrinter(136)
      end
      if !(left(T_IPorta,3) == "USB")
         eject
      else
         @ prow()+1,00 say ""
         setprc(00,00)
      end
      set printer to
      set device to screen
      Msg(.f.)
      if nVideo == 1
         Fim_Imp(140)
      elseif nVideo == 2
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,140)
      end
   end
   return
// *****************************************************************************
static function vCliente(cCodCli)

   if empty(cCodCli)
      @ 11,23 say space(41)
   else
      if !Busca(Zera(@cCodCli),"Clientes",1,11,23,"'-'+Clientes->NomCli",{"Cliente Nao Cadastrado"},.f.,.f.,.f.)
         return(.f.)
      end
   end
   return(.t.)
//** Fim do Arquivo.
