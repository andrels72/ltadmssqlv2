/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 3.00
 * Identificacao: Relat¢rio de Conferencia de Estoque
 * Prefixo......: LTADM
 * Programa.....: Relprod1.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 15 de Julho de 2004
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure RelProd9
   local getlist := {},cTela := SaveWindow()
   private cDifer,cCodFor,cCodGru

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !OpenCidades()
      FechaDados()
      Msg(.f.)
      return
   endif
   if !OpenFornecedor()
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
   if !OpenSubGrupo()
      FechaDados()
      Msg(.f.)
      return
   endif
   Msg(.f.)
	If Aviso_1(09,,14,,"Atencao!",[Imprimir Relat¢rio de Estoque Inicial ?],{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1   
		Imprima()
	endif
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   endif
   FechaDados()
   RestWindow(cTela)
   return
// *****************************************************************************
static procedure Imprima
	local cTela := SaveWindow(),nVideo
	local lEstCid,nCont := 0,lSaldo,cLixo,cCampo,cEstoque,nCalc,nTotLine
    private nPagina := 1,cEst,lFornec,lGrupo,lDifer,lImpGru := .t.,lCabec := .t.
	nTecla := 0
	nTotLine := iif(left(T_IPorta,3) == "USB",100,54)

   if Ver_Imp(@nVideo)

      lFornec := iif(empty(cCodFor),".t.","Produtos->CodFor == cCodFor")
      lGrupo  := iif(empty(cCodGru),".t.","Produtos->CodGru == cCodGru")
      lDifer  := iif(cDifer == "N",".t.","!(Produtos->QteAc01 == Produtos->QteAc02)")
      
      Processar()
      
      if nVideo == 3
      	Msg(.t.)
      	Msg("Aguarde: Imprimindo")
      	cImpressoraPadrao := ImpressoraPadrao()
      	ImprimaUSB(cImpressoraPadrao)
      	Msg(.f.)
      	return
      endif
      begin sequence
         Set Device to Print
         Tmp01->(dbgotop())
         while Tmp01->(!eof())
            if lCabec
               cabec(140,cEmpFantasia,"Conferenca do Estoque")
               if !(left(T_IPorta,3) == "USB")
                  @ prow(),pcol() say T_ICONDI
               end
               @ prow()+1,00 say replicate("=",136)
               //                    01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
               //                              1         2         3         4         5         6         7         8         9         0         1         2         3
               if !lGeral
                  @ prow()+1,00 say "Codigo  Descricao                                           Und. x Qtde.  Fornecedor                 Preco    Estoque"
                  //                 123456  12345678901234567890123456789012345678901234567890  123  x 123    12345678901234567890  999,999.99  9,999,999  __________
               else
               //                    01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
               //                              1         2         3         4         5         6         7         8         9         0         1         2         3
                  @ prow()+1,00 say "Codigo Descricao                                           Und. x Qtde Fornecedor                 Preco    Estoque      Saldo  Diferenca"
                  //                 123456 12345678901234567890123456789012345678901234567890  123  x 123  12345678901234567890  999,999.99  9,999,999  9,999,999  9,999,999
               end
               @ prow()+1,00 say replicate("=",136)
               lCabec := .f.
            end
            if lImpGru
               @ prow()+1,001 say "<< "+Tmp01->CodGru+"-"+Tmp01->Ordem+" >>"
               lImpGru := .f.
               cLixo := Tmp01->Ordem
               @ prow()+1,00 say ""
            end
            Produtos->(dbsetorder(1),dbseek(Tmp01->CodPro))
            Fornece->(dbsetorder(1),dbseek(Produtos->CodFor))
            if !lGeral
               @ prow()+1,000 say Tmp01->CodPro
               @ prow()  ,008 say Tmp01->DesPro
               @ prow()  ,060 say Produtos->EmbPro
               @ prow()  ,065 say "x"
               @ prow()  ,067 say Produtos->QteEmb picture "999"
               @ prow()  ,074 say left(Fornece->RazFor,20)
               @ prow()  ,096 say Produtos->PcoVen picture "@e 999,999.99"
               @ prow()  ,108 say Produtos->QteAc01 picture "@e 9,999,999"
               @ prow()  ,119 say "__________"
            else
               @ prow()+1,000 say Tmp01->CodPro
               @ prow()  ,007 say Tmp01->DesPro
               @ prow()  ,059 say Produtos->EmbPro
               @ prow()  ,064 say "x"
               @ prow()  ,066 say Produtos->QteEmb picture "999"
               @ prow()  ,071 say left(Fornece->RazFor,20)
               @ prow()  ,093 say Produtos->PcoVen  picture "@e 999,999.99"
               @ prow()  ,105 say Produtos->QteAc01 picture "@e 9,999,999"
               @ prow()  ,116 say Produtos->QteAc02 picture "@e 9,999,999"
               @ prow()  ,127 say Produtos->QteAc01-Produtos->QteAc02 picture "@e 9,999,999"
            end
            Tmp01->(dbskip())
            if prow() > nTotLine
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
            if !(Tmp01->Ordem == cLixo)
               lImpGru := .t.
               @ prow()+1,00 say ""
            end
         end
      end sequence
      if !(left(T_IPorta,3) == "USB")
         @ prow(),pcol() say T_ICONDF
      end
      FimPrinter(80)
      if !(left(T_IPorta,3) == "USB")
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
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,maxrow()-1,maxcol(),150)
      end
   end
   RestWindow(cTela)
   return
   
   
static procedure Processar

	
	if !Use_Dbf(cDiretorio,"tmp01",.t.,.t.,"tmp01")
		Mens({"Arquivo para impressao indisponivel","Tente novamente"})
		return
	endif
	index on ordem+CodGru+ordef+despro to dados\tmp01
	Tmp01->(dbclosearea())
	if !Use_Dbf(cDiretorio,"tmp01",.t.,.t.,"tmp01")
		Mens({"Arquivo para impressao indisponivel","Tente novamente"})
		return
	endif
	set index to dados\tmp01
	Produtos->(dbsetorder(1),dbgotop())
	do while Produtos->(!eof())
		if Produtos->QtdEstI01 > 0 .or. Produtos->QtdEstI02 > 0
			Grupos->(dbsetorder(1),dbseek(Produtos->CodGru))
			tmp01->(dbappend())
			tmp01->CodPro := Produtos->CodPro
			tmp01->DesPro := Produtos->DesPro
			tmp01->CodGru := Produtos->CodGru
			tmp01->Ordem  := Grupos->NomGru
			tmp01->OrdeF  := "A"+space(29)
		endif
		Produtos->(dbskip())
	enddo
	return

static procedure ImprimaUSB(cImpressoraPadrao)
	private oPrinter,cPrinter,cFont,nPagina := 1
	
	if !IniciaImpressora(cImpressoraPadrao,.t.)
		return
	endif
	Tmp01->(dbgotop())
         while Tmp01->(!eof())
            if lCabec
            	oPrinter:setfont(cFont,,11)
               CabecUsb(80,cEmpFantasia,"Conferenca do Estoque")
               oPrinter:setFont(cFont,,18)               
               ImpLinha(oPrinter:prow()+1,00,replicate("=",136))
               //                    01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
               //                              1         2         3         4         5         6         7         8         9         0         1         2         3
               if !lGeral
                  ImpLinha(oPrinter:prow()+1,00,"Codigo  Descricao                                           Und. x Qtde.  Fornecedor                 Preco    Estoque ")
                  //                             123456  12345678901234567890123456789012345678901234567890  123  x 123    12345678901234567890  999,999.99  9,999,999  __________
               else
               //                    01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
               //                              1         2         3         4         5         6         7         8         9         0         1         2         3
                 ImpLinha(oPrinter:prow()+1,00,"Codigo Descricao                                           Und. x Qtde Fornecedor                 Preco    Estoque      Saldo  Diferenca")
                  //                 123456 12345678901234567890123456789012345678901234567890  123  x 123  12345678901234567890  999,999.99  9,999,999  9,999,999  9,999,999
               endif
               ImpLinha(oPrinter:prow()+1,00,replicate("=",136))
               lCabec := .f.
            endif
            if lImpGru
               ImpLinha(oPrinter:prow()+1,001,"<< "+Tmp01->CodGru+"-"+Tmp01->Ordem+" >>")
               lImpGru := .f.
               cLixo := Tmp01->Ordem
               ImpLinha(oPrinter:prow()+1,00,"")
            endif
            Produtos->(dbsetorder(1),dbseek(Tmp01->CodPro))
            Fornece->(dbsetorder(1),dbseek(Produtos->CodFor))
            if !lGeral
               ImpLinha(oPrinter:prow()+1,000,Tmp01->CodPro)
               ImpLinha(oPrinter:prow()  ,008,Tmp01->DesPro)
               ImpLinha(oPrinter:prow()  ,060,Produtos->EmbPro)
               ImpLinha(oPrinter:prow()  ,065,"x")
               ImpLinha(oPrinter:prow()  ,067,transform(Produtos->QteEmb,"999"))
               ImpLinha(oPrinter:prow()  ,074,left(Fornece->RazFor,20))
               ImpLinha(oPrinter:prow()  ,096,transform(Produtos->PcoVen,"@e 999,999.99"))
               ImpLinha(oPrinter:prow()  ,108,transform(Produtos->QteAc01,"@e 99,999.999"))
               ImpLinha(oPrinter:prow()  ,119,"__________")
            else
               ImpLinha(oPrinter:prow()+1,000,Tmp01->CodPro)
               ImpLinha(oPrinter:prow()  ,007,Tmp01->DesPro)
               ImpLinha(oPrinter:prow()  ,059,Produtos->EmbPro)
               ImpLinha(oPrinter:prow()  ,064,"x")
               ImpLinha(oPrinter:prow()  ,066,transform(Produtos->QteEmb,"999"))
               ImpLinha(oPrinter:prow()  ,071,left(Fornece->RazFor,20))
               ImpLinha(oPrinter:prow()  ,093,transform(Produtos->PcoVen,"@e 999,999.99"))
               ImpLinha(oPrinter:prow()  ,105,transform(Produtos->QteAc01,"@e 9,999,999"))
               ImpLinha(oPrinter:prow()  ,116,transform(Produtos->QteAc02,"@e 9,999,999"))
               ImpLinha(oPrinter:prow()  ,127,transform(Produtos->QteAc01-Produtos->QteAc02,"@e 9,999,999"))
            endif
            Tmp01->(dbskip())
            if oPrinter:prow() > 60
               nPagina++
               lCabec := .t.
               oPrinter:NewPage()
            endif
            if !(Tmp01->Ordem == cLixo)
               lImpGru := .t.
               ImpLinha(oPrinter:prow()+1,00,"")
            endif
         enddo
      	oPrinter:EndDoc()
      	oPrinter:Destroy()
         

//** Fim do Arquivo.
