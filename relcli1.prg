/*************************************************************************
 * Sistema......: Automacao Comercial
 * Versao.......: 2.00
 * Identificacao: Relatorios de Clientes (Cadastro)
 * Prefixo......: SA
 * Programa.....: RELCCLI.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 01 DE MAIO DE 2002
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"

procedure RelCli1()
   local cTela := SaveWindow(),nVideo,lCabec := .t.,lTem := .f.,nTecla := 0
   private nPagina := 1

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenClientes()
      FechaDados()
      Msg(.f.)
      Return
   EndIf
   if !OpenCidades()
      FechaDados()
      Msg(.f.)
      return
   endif
   Msg(.f.)
   If Aviso_1( 09,,14,,[Aten‡„o!],[Imprimir relat¢rio do Cadastro de Clientes?],{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
      nOrdem := Aviso_1(09,,14,,"Aten‡„o!","Escolha a Ordem do Relatorio.",{" ^Alfabetica "," ^Numerica "},1,.t.)
      if nOrdem == 1
         nOrdem := 2
      elseif nOrdem == 2
         nOrdem := 1
      end
      If Ver_Imp(@nVideo)
         T_IPorta := "USB"
         Clientes->(dbsetorder(nOrdem),dbgotop())
         begin sequence
            Msg(.t.)
            if nVideo == 1
               Msg("Aguarde: Imprimindo (Esc-Cancela)")
            else
               Msg("Aguarde: Gerando o Relatorio (Esc-Cancela)")
            end
            Set Device to Print
            while Clientes->(!eof())
               if lCabec
                  cabec(140,cEmpFantasia,"Relacao de Clientes por Ordem "+iif(nOrdem == 1,"( Alfabetica )","( Numerica )"))
                  if !(left(T_IPorta,3) == "USB")
                     @ prow(),pcol() say T_ICONDI
                  end
                  @ prow()+1,00 say replicate("=",136)
                  lCabec := .f.
               end
               Cidades->(dbsetorder(1),dbseek(Clientes->CodCid))
               @ prow()+1,000 say "  Codigo: "+Clientes->CodCli+" Tipo: "+Clientes->TipCli+" Bloqueio: "+Clientes->BloCli
               @ prow()  ,056 say "Cadastro: "+dtoc(Clientes->DatCli)
               @ prow()+1,000 say "    Nome: "+Clientes->NomCli
               @ prow()  ,056 say " Apelido: "+Clientes->ApeCli
               @ prow()+1,000 say "Endereco: "+Clientes->EndCli
               @ prow()  ,056 say "  Bairro: "+Clientes->BaiCli
               @ prow()+1,000 say "  Cidade: "+Clientes->CodCid+"-"+Cidades->NomCid
               @ prow()  ,056 say "  Estado: "+Cidades->EstCid
               @ prow()+1,000 say "     Cep: "+transform(Clientes->CepCli,"@r 99999-999")
               @ prow()  ,021 say "Fone: "+transform(Clientes->TelCli1,"@r (999)9999-9999")+"/"+transform(Clientes->TelCli2,"@r (999)9999-9999")
               @ prow()  ,056 say "     Fax: "+transform(Clientes->FaxCli,"@kr (99)9999-9999")
               @ prow()  ,082 say "Celular: "+Clientes->CelCli
               @ prow()+1,000 say "  E-Mail: "+Clientes->EmaCli
               @ prow()  ,056 say " Contato: "+Clientes->ConCli
               @ prow()+1,000 say "  C.G.C.: "+transform(Clientes->CgcCli,"@r 99.999.999/9999-99")
               @ prow()  ,056 say " I. Est.: "+Clientes->IesCli
               @ prow()+1,000 say "  C.P.F.: "+transform(Clientes->CpfCli,"@r 999.999.999-99")
               @ prow()  ,056 say "    R.G.: "+Clientes->RgCli
               @ prow()+1,000 say "     SPC: "+Clientes->SpcCli
               @ prow()  ,056 say "     Obs: "+Clientes->Obs
               @ prow()+1,000 say replicate("-",136)
               if !lTem
                  lTem := .t.
               end
               Clientes->(dbskip())
               if prow() > 55
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
               nTecla := inkey()
               if nTecla == K_ESC
                  set device to screen
                  keyboard " "
                  if Aviso_1( 16,, 21,, [Aten‡„o!], [Deseja abortar a impress„o?], { [  ^Sim  ], [  ^N„o  ] }, 2, .t., .t. ) = 1
                     set device to print
                     nTecla := K_ESC
                     break
                  else
                     nTecla := 0
                     Set Device to Print
                  end
               end
            end
         end sequence
         if lTem .and. nTecla == K_ESC
            FimPrinter(135,"Impressao Cancelada")
         elseif lTem .and. !(nTecla == K_ESC)
            FimPrinter(135)
         end
         if !(left(T_IPorta,3) == "USB")
            @ prow(),pcol() say T_ICONDF
            eject
         else
            setprc(00,00)
         end
         Set Printer to
         set device to screen
         Msg(.f.)
         if nVideo == 1
            Fim_Imp(140)
         elseif nVideo == 2
            Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,140)
         end
      end
   end
   FechaDados()
   RestWindow(cTela)
   return

//** Fim do Arquivo.
