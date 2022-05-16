#include "inkey.ch"
#include "setcurs.ch"


procedure RelProdPorCST
    local getlist := {},cTela := SaveWindow()
    local cCst
    
    Msg(.t.)
    Msg("Aguarde: Abrindo os arquivos")
    if !OpenSitTrib()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenProdutos()
        FechaDados()
        Msg(.f.)
        return
    endif
    if !OpenTabNCM()
        FechaDados()
        Msg(.f.)
        return
    endif
    Msg(.f.)
    Window(08,12,13,80)
    setcolor(Cor(11))
    //           456789012345678901234567890123456789012345678901234567890
    //                 2         3         4         5         4
    @ 10,14 say "      CST:"
    @ 11,14 say "Descri‡Æo:"
    do while .t.
        cCst := space(02)
        setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
        @ 10,25 get cCst picture "@k 99";
                when Rodape("Esc-Encerra | F4-Situa‡Æo tribut ria");
                valid Busca(Zera(@cCst),"SitTrib",1,11,25,"left(SitTrib->DesFis,55)",{"Situacao Tributaria Nao Cadastrada"},.f.,.f.,.f.)
        setcursor(SC_NORMAL)
        read
        setcursor(SC_NONE)
        if lastkey() == K_ESC
            exit
        endif
        if !Confirm("Confirma a Informa‡Æo")
            loop
        endif
        if !Produtos->(dbsetorder(12),dbseek(cCst))
            Mens({"NÆo existe produtos com essa CST"})
            loop
        endif
        Imprima(cCst)
    enddo
    FechaDados()
    RestWindow(cTela)
    return
    
static procedure Imprima(cCst)
   local cTela := SaveWindow(),nVideo,lCabec := .t.,nQtd := 0,nContador := 0
   private nPagina := 1
    
    
    Produtos->(dbsetorder(2),dbgotop())
    If Aviso_1(09,,14,,[Aten‡„o!],[Imprimir Relat¢rio de Produtos sem NCM ?],{ [  ^Sim  ], [  ^N„o  ] }, 1, .t. ) = 1
        If Ver_Imp(@nVideo,2)
            if !(nVideo = 2)
                Mens({"Op‡Æo inv lida"})
                FechaDados()
                RestWindow(cTela)
                return
            endif
         begin sequence
            Set Device to Print
            while Produtos->(!eof())
                if !(Produtos->Cst == cCst)
                    Produtos->(dbskip())
                    loop
                endif
                if lCabec
                    cabec(80,cEmpFantasia,"Produtos por Situacao Tributaria")
                    @ prow()+1,00 say replicate("=", 80 )
                    @ prow()+1,00 say "Situacao Tributaria: "+cCst+'-'+SitTrib->DesFis
                    @ prow()+1,00 say replicate("=", 80 )
                    //                 012345678901234567890123456789012345678901234567890123456789012345678901234567890
                    //                           1         2         3         4         5         6         7         8
                    @ prow()+1,00 SAY "Codigo.  Cod.Barras      NCM       CEST    Descricao"
                    //                 123456   12345678901234  12345678  1234567 1234567890123456789012345678901234567890
                    @ prow()+1,00 say replicate("=",80)
                    lCabec := .f.
                endif
                TabelaNCM->(dbsetorder(1),dbseek(Produtos->CodNcm))
                @ prow()+1,01 say Produtos->CodPro
                @ prow()  ,09 say Produtos->CodBar
                @ prow()  ,25 say Produtos->CodNCM
                @ prow()  ,35 say TabelaNCM->CEST
                @ prow()  ,43 say Produtos->DesPro
                if empty(TabelaNCM->cest)
                    nContador += 1
                endif
                nQtd += 1
                Produtos->(dbskip())
                if prow() > 55
                    @ prow()+1,00 say replicate('-',80)
                    nPagina++
                    eject
                    lCabec := .t.
                endif
            enddo
            FimPrinter(80)
            @ prow()+1,00 say "Listados : "+transform(nQtd,"@e 999,999")
            @ prow()+1,00 say " Sem CEST: "+transform(nContador,"@e 999,999")
            @ prow()+1,00 say ""
        end sequence
        eject
         set printer to
         set device to screen
         if nVideo == 1
            Fim_Imp(80)
         elseif nVideo == 2
            Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,maxrow()-1,maxcol()-1,200)
         end
      end
   end
   return
    
    
// Fim do arquivo.    
    


