/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.0
 * Identificacao: Relat¢rio de Entradas - Produtos
 * Prefixo......: LtAdm
 * Programa.....: Bancos.prg
 * Autor........: Andre Lucas Souza
 * Data.........: 23 de Setembro de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure RelComp2
   local getlist := {},cTela := SaveWindow()
   local nVideo,cTitulo
   private dDataI,dDataF,nQual

   T_IPorta := "USB"
   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
    if !OpenProdutos()
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
   Msg(.f.)
   DesativaF9()
   AtivaF4()
   Window(09,26,14,53,cTitulo)
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
        if !Processar(dDataI,dDataF)
            exit
        endif
      Imprima1()
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
   
   
static function Processar(dDataI,dDataF)


	if !Use_dbf(cDiretorio,"tmp02",.t.,.t.,"tmp02")
		Mens({"Arquivo indisponivel","Tente novamente"})
		return(.f.)
	endif
    tmp02->(dbzap())
	index on codpro to (cDiretorio)+"tmp02"
    index on DesPro to (cDiretorio)+"tmp022"
	tmp02->(dbclosearea())
    
	if !Use_dbf(cDiretorio,"tmp02",.t.,.t.,"tmp02")
		Mens({"Arquivo indisponivel","Tente novamente"})
		return(.f.)
	endif
    set index to (cDiretorio)+"tmp02",(cDiretorio)+"tmp022"
    set softseek on
    Compra->(dbsetorder(6),dbseek(dDataI))
    if Compra->DtaEnt > dDataF .or. Compra->(eof())
        Mens({"Não existe informações nesse período"})
        set softseek off
        return(.f.)
    endif
    Cmp_Ite->(dbsetorder(1))
    Tmp02->(dbsetorder(1))
    Produtos->(dbsetorder(1))
    set softseek off
    Msg(.t.)                        
    Msg("Aguarde: Processando relatório")
    do while Compra->DtaEnt >= dDataI .and. Compra->DtaEnt <= dDataF .and. Compra->(!Eof())
        if !lGeral
            if Compra->SN
                Compra->(dbskip())
                loop
            endif
        endif
        if cmp_ite->(dbseek(Compra->Chave))
            do while Cmp_Ite->Chave == Compra->Chave .and. Cmp_ite->(!eof())
                Produtos->(dbseek(Cmp_Ite->CodPro))
                if !tmp02->(dbseek(Cmp_ite->CodPro))
                    tmp02->(dbappend())
                    tmp02->codpro := Cmp_ite->CodPro
                    tmp02->Despro := Produtos->FanPro
                    tmp02->entrada := Cmp_ite->Quantidade
                    tmp02->custo := cmp_ite->custo*cmp_ite->Quantidade
                    tmp02->(dbcommit())
                else
                    tmp02->entrada += Cmp_ite->Quantidade 
                    tmp02->custo += cmp_ite->custo*cmp_ite->Quantidade
                endif
                Cmp_Ite->(dbskip())
            enddo
        endif
        Compra->(dbskip())
    enddo
    Msg(.f.)
    return(.t.)
//****************************************************************************
static procedure Imprima1
   local nVideo,nTecla := 0,lCabec := .t.,dData,lData := .t.,nTotal := 0
   local nQtd := 0
   private nPagina := 1

   if Ver_Imp2(@nVideo,2)
        if nVideo == 1
            return
        endif
        begin sequence            
            Msg(.t.)
            Msg("Aguarde: Gerando o Relatorio (Esc-Cancela)")
            set device to printer
            Tmp02->(dbsetorder(2),dbgotop())
            do while Tmp02->(!eof())
                if lCabec
                    cabec(80,cEmpFantasia,{"Relatorio de Entrada (Produtos resumido)"+"-"+iif(!lGeral,"0","1"),"No Periodo de "+dtoc(dDataI)+" a "+dtoc(dDataF)})
                    @ prow()+1,00 say replicate("=",80)
                    //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                    //                           1         2         3         4         5         6         7         8         9         0         1         2         3
                    @ prow()+1,00 say "Codigo Descricao                                          Qtd. x  Und.      Qtd."
                    //                 123456 12345678901234567890123456789012345678901234567890 123  x 1234  9,999.999
                    //                                                                                                                                Total: 999,999,999.999
                    @ prow()+1,00 say replicate("=",80)
                    lCabec := .f.
                endif
                Produtos->(dbsetorder(1),dbseek(Tmp02->CodPro))
                @ prow()+1,000 say tmp02->CodPro
                @ prow()  ,007 say Tmp02->DesPro
                @ prow()  ,058 say Produtos->QteEmb picture "999"
                @ prow()  ,063 say "x"
                @ prow()  ,065 say Produtos->EmbPro
                @ prow()  ,071 say tmp02->Entrada picture "@e 9,999.999"
                
                nQtd += 1
                Tmp02->(dbskip())
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
                    endif
                endif
                if prow() > 50
                    lCabec  := .t.
                    nPagina += 1
                    eject
               endif
            enddo
      end sequence
      if nTecla == K_ESC
         FimPrinter(80,"Impressao Cancelada")
      else
         FimPrinter(80)
         @ prow()+1,00 say "Listados : "+transform(nQtd,"@e 999,999")
         @ prow()+1,00 say ""
      end
      eject
      set printer to
      set device to screen
      Msg(.f.)
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,30,100,200)
   end
   return

//** Fim do Arquivo.
