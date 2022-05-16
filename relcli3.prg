/*************************************************************************
 * Sistema......: Automacao Comercial
 * Versao.......: 2.00
 * Identificacao: Relatorios de Clientes Por Cidade
 * Prefixo......: SA
 * Programa.....: RELCCLI.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 30 de Junho de 2004
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "inkey.ch"
#include "setcurs.ch"

procedure RelCli3()
   local getlist := {},cTela := SaveWindow()
   local cCodCid

   T_IPorta := "USB"
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
   if !OpenVendedor()
      FechaDados()
      Msg(.f.)
      return
   endif
   Msg(.f.)
   AtivaF4()
   Window(09,11,13,67," Clientes por Cidade ")
   setcolor(Cor(11))
   @ 11,13 say "Cidade:"
   while .t.
      cCodCid := space(04)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,21 get cCodCid picture "@k 9999" when Rodape("Esc-Encerra | F4-Cidades") valid Busca(Zera(@cCodCid),"Cidades",1,11,26,"Cidades->NomCid",{"Cidade Nao Cadastrada"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Clientes->(dbsetorder(6),dbseek(cCodCid))
         Mens({"Nao Existe Clientes Cadastrados"})
         loop
      end
      if !Confirm("Confirma a Informa‡„o")
         loop
      end
      Imprima(cCodCid)
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
// *****************************************************************************
static procedure Imprima(cCodCid)
   local nVideo,lCabec := .t.,lTem := .f.,nTecla := 0,nQtd := 0
   private nPagina := 1

   Clientes->(dbsetorder(7),dbgotop())
   If Aviso_1( 09,,14,,[Aten‡„o!],[Imprimir Clientes por Cidade?],{[  ^Sim  ],[  ^N„o  ]},1,.t.) == 1
      If Ver_Imp(@nVideo)
         T_IPorta := "USB"
         begin sequence
            Msg(.t.)
            if nVideo == 1
               Msg("Aguarde: Imprimindo (Esc-Cancela)")
            else
               Msg("Aguarde: Gerando o Relatorio (Esc-Cancela")
            end
            Set Device to Print
            while Clientes->(!eof())
               if Clientes->CodCid == cCodCid
                  if lCabec
                     cabec(140,cEmpFantasia,{"Relacao de Clientes por Cidade ","Cidade: "+cCodCid+"-"+rtrim(Cidades->NomCid)})
                     if !(left(T_IPorta,3) == "USB")
                        @ prow(),pcol() say T_ICONDI
                     end
                     @ prow()+1,00 say replicate("=",136)
                     lCabec := .f.
                  end
                  Cidades->(dbsetorder(1),dbseek(Clientes->CodCid))
                  Vendedor->(dbsetorder(1),dbseek(Clientes->CodVen))
                  @ prow()+1,00 say "  Codigo: "+Clientes->CodCli+" Nome: "+Clientes->NomCli+ " Fantasia: "+Clientes->ApeCli
                  @ prow()+1,00 say "Endereco: "+Clientes->EndCli+space(11)+"   Bairro: "+Clientes->BaiCli
                  @ prow()+1,00 say "  Cidade: "+Clientes->CodCid+"-"+Cidades->NomCid+space(08)+" Estado: "+Cidades->EstCid+" Cep: "+transform(Clientes->CepCli,"@r 99999-999")
                  @ prow()+1,00 say "    Fone: "+transform(Clientes->TelCli1,"@r (999)9999-9999")+" / "+transform(Clientes->TelCli2,"@r (999)9999-9999")+space(25)+" Fax: "+transform(Clientes->FaxCli,"@kr (99)9999-9999")+" Celular: "+Clientes->CelCli
                  @ prow()+1,00 say "  C.G.C.: "+transform(Clientes->CgcCli,"@r 99.999.999/9999-99")+"  I. Est.: "+Clientes->IesCli+space(09)+"  C.P.F.: "+transform(Clientes->CpfCli,"@r 999.999.999-99")+"   R.G.: "+Clientes->RgCli
                  @ prow()+1,00 say " Contato: "+Clientes->ConCli+space(17)+"Vendedor: "+Clientes->CodVen+" - "+Vendedor->Nome
                  @ prow()+1,000 say replicate("-",136)
                  if !lTem
                     lTem := .t.
                  end
                  nQtd += 1
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
            @ prow()+1,00 say "Listados : "+transform(nQtd,"@e 999,999")
            @ prow()+1,00 say ""
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
            Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,150)
         end
      end
   end
   return

//** Fim do Arquivo.
