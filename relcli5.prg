/*************************************************************************
         Sistema: Administrativo
   Identifica‡Æo: Relat¢rio de Ranking de Clientes
         Prefixo: LTADM
        Programa: RelCli5.PRG
           Autor: Andre Lucas Souza
            Data: 27 de Julho de 2004
   Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure RelCli5
   local getlist := {},cTela := SaveWindow()
   private cCodCid,cCodVen,dDataI,dDataF,nQtd

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenCidades()
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
    if !OpenVendedor()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenClientes()
      FechaDados()
      Msg(.f.)
      return
   end
   Msg(.f.)
   if PwNivel == "0"
      DesativaF9()
   end
   AtivaF4()
   Window(07,13,15,65)
   setcolor(Cor(11))
   //           123456789012345678901234567890
   //                    3         4
   @ 09,15 say "      Cidade:"
   @ 10,15 say "    Vendedor:"
   @ 11,15 say "Data Inicial:"
   @ 12,15 say "  Data Final:"
   @ 13,15 say "  Quantidade:"
   while .t.
      cCodCid := space(04)
      cCodVen := space(02)
      dDataI  := date()
      dDataF  := date()
      nQtd    := 999
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 09,29 get cCodCid picture "@k 9999" when Rodape("Esc-Encerra | F4-Cidades") valid vCidades()
      @ 10,29 get cCodVen picture "@k 99" when Rodape("Esc-Encerra | F4-Vendedores") valid vVendedor()
      @ 11,29 get dDataI  picture "@k"     when Rodape("Esc-Encerra")
      @ 12,29 get dDataF  picture "@k"     valid iif(lastkey() == K_UP,.t.,dDataF >= dDataI)
      @ 13,29 get nQtd    picture "@k 999" valid iif(lastkey() == K_UP,.t.,nQtd > 0)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
      Imprima()
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
//*****************************************************************************
static procedure Imprima
   local cTela := SaveWindow(),lCabec := .t.,nVideo
   local nTecla := 0,lCidade,lVendedor,nI,nMedia,nPeso,nAcumu := 0
   local nTotPco := 0,nTotQtd := 0
   private nPagina := 1,cEst

   if Ver_Imp(@nVideo)
      T_IPorta := "USB"
      lVendedor := iif(empty(cCodVen),".t.","Pedidos->CodVen == cCodVen")
      set exclusive on
      use dados\tmp04 alias tmp04 new
      zap
      index on CodCli to dados\tmp04
      Tmp04->(dbclosearea())
      set exclusive off
      use dados\tmp04 alias tmp04 new
      set index to dados\tmp04
      Pedidos->(dbsetorder(2),dbgotop())
      Calibra(12,10,.t.,"Aguarde: Processando")
      nI := 1
      while Pedidos->(!eof())
         Calibra(12,10,.f.,,nI,Pedidos->(lastrec()))
         if Pedidos->Data >= dDataI .and. Pedidos->Data <= dDataF .and. &lVendedor.
            if !empty(cCodCid)
               if Clientes->(dbsetorder(1),dbseek(Pedidos->CodCli))
                  if !(Clientes->CodCid == cCodCid)
                     Pedidos->(dbskip())
                     nI += 1
                     loop
                  end
               end
            end
            ItemPed->(dbsetorder(1),dbseek(Pedidos->NumPed))
            while ItemPed->NumPed == Pedidos->NumPed .and. ItemPed->(!eof())
               if !Tmp04->(dbsetorder(1),dbseek(Pedidos->CodCli))
                  while !Tmp04->(Adiciona())
                  end
                  Tmp04->CodCli := Pedidos->CodCli
                  Tmp04->Qtd    := ItemPed->QtdPro
                  Tmp04->Pco    := ItemPed->QtdPro*ItemPed->PcoVen
                  Tmp04->(dbunlock())
               else
                  while !Tmp04->(Trava_Reg())
                  end
                  Tmp04->Qtd += ItemPed->QtdPro
                  Tmp04->Pco += (ItemPed->QtdPro*ItemPed->PcoVen)
                  Tmp04->(dbunlock())
               end
               ItemPed->(dbskip())
            end
         end
         Pedidos->(dbskip())
         nI += 1
      end
      dbselectarea("Tmp04")
      sum Pco to nValTot
      index on nValTot-Pco to dados\tmp04
      dbgotop()
      nI := 1
      begin sequence
         Set Device to Print
         tmp04->(dbgotop())
         while tmp04->(!eof()) .and. nI <= nQtd
            if lCabec
               cabec(140,cEmpFantasia,{str(nQtd,3)+" mais Clientes"+" - de "+dtoc(dDataI)+" a "+dtoc(dDataF),;
                     "Cidade: "+iif(!empty(cCodCid),cCodCid+"-"+left(Cidades->NomCid,20),"Todas")+" Vendedor: "+iif(!empty(cCodVen),cCodVen+"-"+Vendedor->Nome,"Todos")})
               @ prow()+1,00 say replicate("=",136)
               //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
               //                           1         2         3         4         5         6         7         8         9         0         1         2         3
               @ prow()+1,00 say "Ordem Codigo Cliente                                                            Qtde.          Total          Media   Peso(%) aCumu.(%)"
               //                   123 123456 12345678901234567890123456789012345678901234567890             9,999,999 999,999,999.99 999,999,999.99  9,999.99  9,999.99
               //                                                                                  Total:    99,999,999 999,999,999.99                 9,999.99
               @ prow()+1,00 say replicate("=",136)
               lCabec := .f.
            end
            Clientes->(dbsetorder(1),dbseek(Tmp04->CodCli))
            nMedia  := iif(Tmp04->Qtd == 0,0,Tmp04->Pco/Tmp04->Qtd)
            nPeso   := iif(nValTot == 0,0,Tmp04->Pco/nValTot*100)
            nAcumu  += nPeso
            nTotPco += Tmp04->Pco
            nTotQtd += Tmp04->Qtd
            @ prow()+1,002 say nI picture "999"
            @ prow()  ,006 say Tmp04->CodCli
            @ prow()  ,013 say Clientes->NomCli
            @ prow()  ,076 say Tmp04->Qtd picture "@e 9,999,999"
            @ prow()  ,086 say Tmp04->Pco picture "@e 999,999,999.99"
            @ prow()  ,101 say nMedia     picture "@e 999,999,999.99"
            @ prow()  ,117 say nPeso      picture "@e 9,999.99"
            @ prow()  ,127 say nAcumu     picture "@e 9,999.99"
            Tmp04->(dbskip())
            nI += 1
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
      nMedia  := iif(nTotQtd == 0,0,nTotPco/nTotQtd)
      nPeso   := iif(nTotPco == 0,0,nTotPco/nValTot*100)
      @ prow()+1,000 say replicate("-",136)
      @ prow()+1,065 say "Total:"
      @ prow()  ,075 say nTotQtd picture "@e 99,999,999"
      @ prow()  ,086 say nTotPco picture "@e 999,999,999.99"
      @ prow()  ,102 say nMedia  picture "@e 999,999,999.99"
      @ prow()  ,117 say nPeso   picture "@e 9,999.99"
      @ prow()+1,00 say ""
      FimPrinter(136)
      if !(left(T_IPorta,3) == "USB")
         @ prow(),pcol() say T_ICONDF
         eject
      else
         setprc(00,00)
      end
      set printer to
      set device to screen
      if nVideo == 1
         Fim_Imp(140)
      elseif nVideo == 2
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,150)
      end
   end
   RestWindow(cTela)
   return
//*****************************************************************************
static function vCidades

   if empty(cCodCid)
      @ 09,33 say space(31)
      @ 09,33 say "-Todas"
      return(.t.)
   end
   if !Busca(Zera(@cCodCid),"Cidades",1,09,33,"'-'+left(Cidades->NomCid,30)",{"Cidade Nao Cadastrada"},.f.,.f.,.f.)
      return(.f.)
   end
   return(.t.)
//*****************************************************************************
static function vVendedor

   if empty(cCodVen)
      @ 10,31 say space(21)
      @ 10,31 say "-Todos"
      return(.t.)
   end
   if !Busca(Zera(@cCodVen),"Vendedor",1,10,31,"'-'+Vendedor->Nome",{"Vendedor Nao Cadastrado"},.f.,.f.,.f.)
      return(.f.)
   end
   return(.t.)

//** Fim do Arquivo
