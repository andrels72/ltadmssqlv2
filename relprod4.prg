/*************************************************************************
         Sistema: Administrativo
   Identifica‡Æo: Relat¢rio de Ranking do Produto
         Prefixo: LTADM
        Programa: RelProd4.PRG
           Autor: Andre Lucas Souza
            Data: 15 de Julho de 2004
   Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure RelProd4
   local getlist := {},cTela := SaveWindow()
   private cCodFor,cCodGru,dDataI,dDataF,nQtd

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenCidades()
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
    if !OpenItemPed()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenFornecedor()
        FechaDados()
        Msg(.f.)
        return
    endif
   Msg(.f.)
   if PwNivel == "0"
      DesativaF9()
   end
   AtivaF4()
   Window(07,13,15,65)
   setcolor(Cor(11))
   //           123456789012345678901234567890
   //                    3         4
   @ 09,15 say "  Fornecedor:"
   @ 10,15 say "       Grupo:"
   @ 11,15 say "Data Inicial:"
   @ 12,15 say "  Data Final:"
   @ 13,15 say "  Quantidade:"
   while .t.
      cCodFor := space(04)
      cCodGru := space(03)
      dDataI  := date()
      dDataF  := date()
      nQtd    := 999
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 09,29 get cCodFor picture "@k 9999" when Rodape("Esc-Encerra | F4-Fornecedores") valid vFornece()
      @ 10,29 get cCodGru picture "@k 999" when Rodape("Esc-Encerra | F4-Grupos") valid vGrupo()
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
// *****************************************************************************
static procedure Imprima
   local cTela := SaveWindow(),lCabec := .t.,nVideo
   local nTecla := 0,lFornece,lGrupo,nI,nMedia,nPeso,nAcumu := 0
   local nTotPco := 0,nTotQtd := 0
   private nPagina := 1,cEst,nValTot := 0

   
   //if Ver_Imp(@nVideo)
      T_IPorta := "USB"
      lFornece := iif(empty(cCodFor),".t.","Produtos->CodFor == cCodFor")
      lGrupo   := iif(empty(cCodGru),".t.","Produtos->CodGru == cCodGru")
      set exclusive on
      use dados\tmp04 alias tmp04 new
      zap
      index on codpro to dados\tmp04
      Tmp04->(dbclosearea())
      set exclusive off
      use dados\tmp04 alias tmp04 new
      set index to dados\tmp04
      Produtos->(dbsetorder(1),dbgotop())
      Calibra(12,10,.t.,"Aguarde: Processando")
      nI := 1
      while Produtos->(!eof())
         Calibra(12,10,.f.,,nI,Produtos->(lastrec()))
         if &lFornece. .and. &lGrupo.
            ItemPed->(dbsetorder(3),dbseek(Produtos->CodPro))
            while ItemPed->CodPro == Produtos->CodPro .and. ItemPed->(!eof())
               if ItemPed->DtaSai >= dDataI .and. ItemPed->DtaSai <= dDataF
                  if !Tmp04->(dbsetorder(1),dbseek(Produtos->CodPro))
                     while !Tmp04->(Adiciona())
                     end
                     Tmp04->CodPro := Produtos->CodPro
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
               end
               ItemPed->(dbskip())
            end
         end
         Produtos->(dbskip())
         nI += 1
      end
		// ** dbselectarea("Tmp04")
		

// **      sum Pco to nValTot
// **      index on nValTot-Pco to dados\tmp04
		index on descend(Pco) to dados\tmp04
      dbgotop()
		nI := 1
		Tmp04->(dbsetorder(1),dbgotop())
		do while Tmp04->(!eof())
			nValTot += Tmp04->Pco
			Tmp04->(dbskip())
			nI += 1
			if nI >= (nQtd+1)
				exit
			endif
			
		enddo
   nOnde := OndeImprimir()
   if nOnde == -27
      return
   elseif nOnde == 2
      ImprimaUSB()
      return
   endif
   if Ver_Imp(@nVideo) 
     
		
		
		nMedia := 0
		nPeso  := 0
		nAcumu := 0
		nTotPco := 0
		nTotQtd := 0   
      nI := 1
      begin sequence
         Set Device to Print
         tmp04->(dbgotop())
         while tmp04->(!eof()) // ** .and. nI <= nQtd
            if lCabec
               cabec(140,cEmpFantasia,{str(nQtd,3)+" Produtos mais Vendidos"+" - de "+dtoc(dDataI)+" a "+dtoc(dDataF),;
                     "Fornecedor: "+iif(!empty(cCodFor),cCodFor+"-"+left(Fornecedor->RazFor,20),"Todos")+" Grupo: "+iif(!empty(cCodGru),cCodGru+"-"+left(Grupos->NomGru,20),"Todos")})
               @ prow()+1,00 say replicate("=",136)
               //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
               //                           1         2         3         4         5         6         7         8         9         0         1         2         3
               @ prow()+1,00 say "Ordem Codigo Descricao                                           Embalagem      Qtde.          Total          Media   Peso(%) aCumu.(%)"
               //                   123 123456 12345678901234567890123456789012345678901234567890  123 x 123  9,999,999 999,999,999.99 999,999,999.99  9,999.99  9,999.99
               //                                                                                  Total:    99,999,999 999,999,999.99                 9,999.99
               @ prow()+1,00 say replicate("=",136)
               lCabec := .f.
            end
            Produtos->(dbsetorder(1),dbseek(Tmp04->CodPro))
            nMedia  := iif(Tmp04->Qtd == 0,0,Tmp04->Pco/Tmp04->Qtd)
            nPeso   := iif(nValTot == 0,0,(Tmp04->Pco*100)/nValTot)
            nAcumu  += nPeso
            nTotPco += Tmp04->Pco
            nTotQtd += Tmp04->Qtd
            @ prow()+1,002 say nI picture "999"
            @ prow()  ,006 say Tmp04->CodPro
            @ prow()  ,013 say Produtos->DesPro
            @ prow()  ,065 say Produtos->EmbPro+" x "+str(Produtos->QteEmb,3)
            @ prow()  ,076 say Tmp04->Qtd picture "@e 9,999,999"
            @ prow()  ,086 say Tmp04->Pco picture "@e 999,999,999.99"
            @ prow()  ,101 say nMedia     picture "@e 999,999,999.99"
            @ prow()  ,117 say nPeso      picture "@e 9,999.99"
            @ prow()  ,127 say nAcumu     picture "@e 9,999.99"
            Tmp04->(dbskip())
            nI += 1
            if nI >= (nQtd+1)
            	exit
            endif
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
// **      @ prow()  ,102 say nMedia  picture "@e 999,999,999.99"
      @ prow()  ,117 say nPeso   picture "@e 9,999.99"
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
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,150)
      end
   end
   RestWindow(cTela)
   return
// *****************************************************************************
static function vFornece

   if empty(cCodFor)
      @ 09,33 say space(31)
      return(.t.)
   end
   if !Busca(Zera(@cCodFor),"Fornece",1,09,33,"'-'+left(Fornecedor->RazFor,30)",{"Fornecedor Nao Cadastrado"},.f.,.f.,.f.)
      return(.f.)
   end
   return(.t.)
// *****************************************************************************
static function vGrupo

   if empty(cCodGru)
      @ 10,32 say space(21)
      return(.t.)
   end
   if !Busca(Zera(@cCodGru),"Grupos",1,10,32,"'-'+left(Grupos->NomGru,20)",{"Grupo Nao Cadastrado"},.f.,.f.,.f.)
      return(.f.)
   end
   return(.t.)
   
static procedure ImprimaUSB
   local lCabec := .t.,nPagina := 2,cPrinter,nTotal := 0.00
   local nI := 1
   private oPrinter,cFont

   if !IniciaImpressora()
      return
   endif
   tmp04->(dbgotop())
   nTotPco := 0
   nTotQtd := 0
   nAcumu  := 0
	while tmp04->(!eof()) // ** .and. nI <= nQtd
		if lCabec
			oPrinter:setfont(cFont,,11)
               cabecUSB(80,cEmpFantasia,{str(nQtd,3)+" Produtos mais Vendidos"+" - de "+dtoc(dDataI)+" a "+dtoc(dDataF),;
                     "Fornecedor: "+iif(!empty(cCodFor),cCodFor+"-"+left(Fornecedor->RazFor,20),"Todos")+" Grupo: "+iif(!empty(cCodGru),cCodGru+"-"+left(Grupos->NomGru,20),"Todos")})
               oPrinter:setfont(cFont,,18)
               ImpLinha(oPrinter:prow()+1,00,replicate("=",136))
               //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
               //                           1         2         3         4         5         6         7         8         9         0         1         2         3
               ImpLinha(oPrinter:prow()+1,00,"Ordem Codigo Descricao                                           Embalagem      Qtde.          Total          Media   Peso(%) aCumu.(%)")
               //                   123 123456 12345678901234567890123456789012345678901234567890  123 x 123  9,999,999 999,999,999.99 999,999,999.99  9,999.99  9,999.99
               //                                                                                  Total:    99,999,999 999,999,999.99                 9,999.99
               ImpLinha(oPrinter:prow()+1,00,replicate("=",136))
               lCabec := .f.
		endif
            Produtos->(dbsetorder(1),dbseek(Tmp04->CodPro))
            nMedia  := iif(Tmp04->Qtd == 0,0,Tmp04->Pco/Tmp04->Qtd)
            nPeso   := iif(nValTot == 0,0,(Tmp04->Pco*100)/nValTot)
            nAcumu  += nPeso
            nTotPco += Tmp04->Pco
            nTotQtd += Tmp04->Qtd
            ImpLinha(oPrinter:prow()+1,002,transform(nI,"999"))
            ImpLinha(oPrinter:prow()  ,006,Tmp04->CodPro)
            ImpLinha(oPrinter:prow()  ,013,Produtos->DesPro)
            ImpLinha(oPrinter:prow()  ,065,Produtos->EmbPro+" x "+str(Produtos->QteEmb,3))
            ImpLinha(oPrinter:prow()  ,076,transform(Tmp04->Qtd,"@e 9,999,999"))
            ImpLinha(oPrinter:prow()  ,086,transform(Tmp04->Pco,"@e 999,999,999.99"))
            ImpLinha(oPrinter:prow()  ,101,transform(nMedia,"@e 999,999,999.99"))
            ImpLinha(oPrinter:prow()  ,117,transform(nPeso,"@e 9,999.99"))
            ImpLinha(oPrinter:prow()  ,127,transform(nAcumu,"@e 9,999.99"))
            Tmp04->(dbskip())
            nI += 1
            if nI >= (nQtd+1)
            	exit
            endif
            if oPrinter:prow() > 54
               nPagina++
               lCabec := .t.
               oPrinter:newpage()
            endif
	enddo
	nMedia  := iif(nTotQtd == 0,0,nTotPco/nTotQtd)
	nPeso   := iif(nTotPco == 0,0,nTotPco/nValTot*100)
	ImpLinha(oPrinter:prow()+1,000,replicate("-",136))
	ImpLinha(oPrinter:prow()+1,065,"Total:")
	ImpLinha(oPrinter:prow()  ,075,transform(nTotQtd,"@e 99,999,999"))
	ImpLinha(oPrinter:prow()  ,086,transform(nTotPco,"@e 999,999,999.99"))

	ImpLinha(oPrinter:prow()  ,117,transform(nPeso,"@e 9,999.99"))
	oPrinter:enddoc()
	oPrinter:Destroy()
	return

   
   
   
   
   
   
   
   

//** Fim do Arquivo
