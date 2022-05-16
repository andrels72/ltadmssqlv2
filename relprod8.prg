/*************************************************************************
         Sistema: Administrativo
   Identifica‡Æo: Relat¢rio de produtos (Preço de custo e venda)
         Prefixo: LTADM
        Programa: RelProd8.prg
           Autor: Andre Lucas Souza
            Data: 30 de Julho de 2015
   Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure RelProd8
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
    if !OpenFornecedor()
        FechaDados()
        Msg(.f.)
        return
    endif
   Msg(.f.)
	DesativaF9()
   AtivaF4()
   Window(07,13,12,65,"> Produtos (Preco de Custo/Venda) <")
   setcolor(Cor(11))
   //           123456789012345678901234567890
   //                    3         4
   @ 09,15 say "  Fornecedor:"
   @ 10,15 say "       Grupo:"
	do while .t.
      cCodFor := space(04)
      cCodGru := space(03)
      dDataI  := date()
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 09,29 get cCodFor picture "@k 9999" when Rodape("Esc-Encerra | F4-Fornecedores") valid vFornece()
      @ 10,29 get cCodGru picture "@k 999" when Rodape("Esc-Encerra | F4-Grupos") valid vGrupo()
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      if !Confirm("Confirma as Informacoes")
         loop
      endif
      Processar()
      Imprimir()
      exit
   enddo
   DesativaF4()
   FechaDados()
	if PwNivel == "0"
		AtivaF9()
		lGeral := .f.
   endif
   RestWindow(cTela)
   return
   
// *****************************************************************************
static procedure Processar
   local cTela := SaveWindow()
   local lEstCid,nCont := 0,lImpGru := .t.,cLixo
   local cCampo,cEstoque,nCalc,nSubTotal := 0,nTotal := 0,nLixo
   private nPagina := 2,cEst,lSaldo,lFornece,lGrupo
   nTecla := 0

   lFornec := iif(empty(cCodFor),".t.","Produtos->CodFor == cCodFor")
   lGrupo  := iif(empty(cCodGru),".t.","Produtos->CodGru == cCodGru")

   
	if !Use_dbf(cDiretorio,"tmp05",.t.,.t.,"Tmp05")
		Mens({"Arquivo para impressao indisponivel","Tente novamente"})
		return
	endif
	zap
	index on despro to (cDiretorio)+"tmp05"
	index on codpro to (cDiretorio)+"tmp052"
	Tmp05->(dbclosearea())
	if !Use_dbf(cDiretorio,"tmp05",.t.,.t.,"Tmp05")
		Mens({"Arquivo para impressao indisponivel","Tente novamente"})
		return
	endif
   set index to (cDiretorio)+"tmp05",(cDiretorio)+"tmp052"
   
   Produtos->(dbsetorder(1),dbgotop())
   Msg(.t.)
   Msg("Aguarde: Verificando as Informacoes")
	do while Produtos->(!eof())
		if &lFornec. .and. &lGrupo.
			Tmp05->(dbappend())
			tmp05->CodPro := Produtos->CodPro
			tmp05->DesPro := Produtos->DesPro
			tmp05->CodGru := Produtos->CodGru
			tmp05->OrdeF  := "A"+space(29)
		endif
		Produtos->(dbskip())
	enddo
   dbcommitall()
   Msg(.f.)
   return
   
static procedure Imprimir   
	local cTela := SaveWindow(),nVideo,lCabec := .t.
	local nTotalCusto,nTotalVenda
   private nPagina := 1,cEst,lSaldo,lFornece,lGrupo

   
	nTotalCusto := 0.000
	nTotalVenda := 0.000
	if Ver_Imp(@nVideo)
		if nVideo == 3
			ImprimaUSB()
			return
		endif
      begin sequence
         Set Device to Print
         tmp05->(dbsetorder(1),dbgotop())
         while tmp05->(!eof()) 
            if lCabec
               cabec(80,cEmpFantasia,{"Relatorio de produtos (preco de custo/venda) "+iif(!lGeral," ","1"),;
                     "Fornecedor: "+iif(!empty(cCodFor),cCodFor+"-"+left(Fornece->RazFor,20),"Todos")+" Grupo: "+iif(!empty(cCodGru),cCodGru+"-"+left(Grupos->NomGru,20),"Todos")})
               @ prow()+1,00 say replicate("=",91)
               //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
               //                           1         2         3         4         5         6         7         8         9         0         1         2         3
               @ prow()+1,00 say "                                                                      Preco de    Preco de"
               @ prow()+1,00 say "Codigo Descricao                                           Embalagem  Custo       Venda"
               //                 123456 12345678901234567890123456789012345678901234567890  123 x 123  99,999.999  99,999.99
               //                                                                                  Total:    99,999,999 999,999,999.99                 9,999.99
               @ prow()+1,00 say replicate("=",91)
               lCabec := .f.
            end
            Produtos->(dbsetorder(1),dbseek(Tmp05->CodPro))
            @ prow()+1,000 say Tmp05->CodPro
            @ prow()  ,007 say Produtos->DesPro
            @ prow()  ,059 say Produtos->EmbPro+" x "+str(Produtos->QteEmb,3)
            @ prow()  ,070 say Produtos->PcoNot picture "@e 99,999.999"
            @ prow()  ,082 say Produtos->PcoVen picture "@e 99,999.99"
            if lGeral
            	nTotalCusto += (Produtos->PcoNot * Produtos->QteAc02)
            	nTotalVenda += (Produtos->PcoVen * Produtos->QteAc02)
            else
            	nTotalCusto += (Produtos->PcoNot * Produtos->QteAc01)
            	nTotalVenda += (Produtos->PcoVen * Produtos->QteAc01)
            endif
            Tmp05->(dbskip())
            if prow() > 66
               nPagina++
               lCabec := .t.
               eject
            endif
         enddo
      end sequence
      FimPrinter(91)
      @ prow()+1,00 say "Valor total preco de custo: "+transform(nTotalCusto,"@e 999,999,999.99")
      @ prow()+1,00 say "Valor total preco de venda: "+transform(nTotalVenda,"@e 999,999,999.99")
      eject
      set printer to
      set device to screen
      if nVideo == 1
         Fim_Imp(140)
      elseif nVideo == 2
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,maxrow()-1,maxcol(),500)
      endif
   endif
   RestWindow(cTela)
   
static procedure ImprimaUSB

	local lCabec := .t.,nPagina := 1,cPrinter,nTotal := 0.00
	local nTotalCusto,nTotalVenda
	private oPrinter,cFont
	
	if !IniciaImpressora()
		return
	endif
	nTotalCusto := 0.000
	nTotalVenda := 0.000
	tmp05->(dbsetorder(1),dbgotop())
	while tmp05->(!eof()) 
		if lCabec
			oPrinter:setfont(cFont,,13)
			cabecUSb(91,cEmpFantasia,{"Relatorio de produtos (preco de custo/venda) "+iif(!lGeral," ","1"),;
                     "Fornecedor: "+iif(!empty(cCodFor),cCodFor+"-"+left(Fornece->RazFor,20),"Todos")+" Grupo: "+iif(!empty(cCodGru),cCodGru+"-"+left(Grupos->NomGru,20),"Todos")})
            ImpLinha(oPrinter:prow()+1,00,replicate("=",91))
            
               //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
               //                           1         2         3         4         5         6         7         8         9         0         1         2         3
			ImpLinha(oPrinter:prow()+1,00,"                                                                      Preco de    Preco de")
            ImpLinha(oPrinter:prow()+1,00,"Codigo Descricao                                           Embalagem  Custo       Venda")
               //                 123456 12345678901234567890123456789012345678901234567890  123 x 123  999,999.99"
               //                                                                                  Total:    99,999,999 999,999,999.99                 9,999.99
            ImpLinha(oPrinter:prow()+1,00,replicate("=",91))
               lCabec := .f.
		endif
        Produtos->(dbsetorder(1),dbseek(Tmp05->CodPro))
        ImpLinha(oPrinter:prow()+1,000,Tmp05->CodPro)
        ImpLinha(oPrinter:prow()  ,007,Produtos->DesPro)
        ImpLinha(oPrinter:prow()  ,059,Produtos->EmbPro+" x "+str(Produtos->QteEmb,3))
		ImpLinha(oPrinter:prow()  ,070,transform(Produtos->PcoNot,"@e 99,999.999"))
		ImpLinha(oPrinter:prow()  ,082,transform(Produtos->PcoVen,"@e 99,999.99"))
		if lGeral
			nTotalCusto += (Produtos->PcoNot * Produtos->QteAc02)
			nTotalVenda += (Produtos->PcoVen * Produtos->QteAc02)
		else
			nTotalCusto += (Produtos->PcoNot * Produtos->QteAc01)
			nTotalVenda += (Produtos->PcoVen * Produtos->QteAc01)
		endif
        tmp05->(dbskip())
		if oPrinter:prow() > 64
           nPagina++
           lCabec := .t.
           oPrinter:newpage()
        endif
	enddo
	ImpLinha(oPrinter:prow()+1,00,replicate("=",91))	
	ImpLinha(oPrinter:prow()+1,00,"Valor total preco de custo: "+transform(nTotalCusto,"@e 999,999,999.99"))
	ImpLinha(oPrinter:prow()+1,00,"Valor total preco de venda: "+transform(nTotalVenda,"@e 999,999,999.99"))
	oPrinter:setfont(cFont,,13)	
	oPrinter:enddoc()
	oPrinter:Destroy()
	return
// *****************************************************************************
static function vFornece

   if empty(cCodFor)
      @ 09,33 say space(31)
      return(.t.)
   end
   if !Busca(Zera(@cCodFor),"Fornece",1,09,33,"'-'+left(Fornece->RazFor,30)",{"Fornecedor Nao Cadastrado"},.f.,.f.,.f.)
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
// ** 