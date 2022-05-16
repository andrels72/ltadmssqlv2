/*************************************************************************
        Sistema: Administrativo
  Identificacao: Relatorio de Atividades do Usuario
        Prefixo: Ltadm
       Programa: Relativ.PRG
          Autor: Andre Lucas Souza
           Data: 28 de Maio de 2003
  Copyright (C): LT-Tecnologia Ltda.
*/
#include "inkey.ch"
#include "setcurs.ch"

procedure RelAtiv()
   local getlist := {},cTela := SaveWindow()
   local dDataI := date(),dDataF := date()
   private cCodUse

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !(Abre_Dados(cDiretorio,"OpeLog",1,1,"OpeLog",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   Msg(.f.)
   AtivaF4()
   Window(06,06,12,60,chr(16)+" Atividades do Usuario "+chr(17))
   setcolor(Cor(11))
   //           89012345678901234567890123456789012345678901234567890123456789012345678
   //             1         2         3         4         5         6         7
   @ 08,08 say "Data Inicial:"
   @ 09,08 say "  Data Final:"
   @ 10,08 say "     Usuario:"
   while .t.
      cCodUse := space(03)
      cRotina := "00001"  // Vari vel P£blica
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 08,22 get dDataI picture "@k" when Rodape("Esc-Encerra") valid NoEmpty(dDataI)
      @ 09,22 get dDataF picture "@k" valid dDataF >= dDataI
      @ 10,22 get cCodUse picture "@k 999" when Rodape("Esc-Encerra") valid iif(lastkey() == K_UP,.t.,iif(empty(cCodUse),.t.,Busca(Zera(@cCodUse),"PwUsers",1,10,27,"PwUsers->Nome",{"Usuario Nao Cadastrado"},.f.,.t.,.f.)))
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as Informacoes")
         loop
      end
      Imprima(dDataI,dDataF)
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
//****************************************************************************
static procedure Imprima(dDataI,dDataF)
   local cTela := SaveWindow(),nVideo,lCabec := .t.,lCodUse,nTecla := 0
   private nPagina := 1

   lCodUse := iif(empty(cCodUse),".t.","OpeLog->CodLog == cCodUse")
   If Aviso_1(09,,14,,[Aten‡„o!],[Imprimir Atividades do Usuario ?],{"  ^Sim  ","  ^N„o  "},1,.t.) == 2
      return
   end
   If Ver_Imp(@nVideo)
      Msg(.t.)
      if nVideo == 1
         Msg("Aguarde: Imprimindo (Esc-Cancela)")
      else
         Msg("Aguarde: Gerando o Relatorio (Esc-Cancela)")
      end
      begin sequence
         Set Soft On
         OpeLog->(dbsetorder(1),dbseek(dtos(dDataI)))
         Set Soft Off
         Set Device to Print
         while OpeLog->(!eof()) .and. OpeLog->DatLog <= dDataF
            if &lCodUse.
               if lCabec
                  cabec(140,cEmpFantasia,{"Relatorio de Atividades do Usuario","Usuario: "+iif(empty(cCodUse),"Todos",cCodUse+"-"+PwUsers->Nome),"Periodo: "+dtoc(dDataI)+" a "+dtoc(dDataF)},.f.)
                  @ prow()+1,00   say replicate("=",135)
                  if !(left(T_IPorta,3) == "USB")
                     @ prow(),pcol() say T_ICONDI
                  end
                  //                 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
                  //                           1         2         3         4         5         6         7         8         9         0         1         2         3
                  @ prow()+1,00 SAY " Estacao Data       Hora     Usuario                       N Atividade"
                  //                 12345678 99/99/9999 99:99:99 123 1234567890123456789012345 1 123456789012345678901234567890123456789012345678901234567890123456789012345
                  @ prow()+1,00   say replicate("=",iif(nVideo == 1,80,134))
                  lCabec := .f.
               end
               PwUsers->(dbsetorder(1),dbseek(OpeLog->CodLog))
               @ prow()+1,000 say OpeLog->EstLog
               @ prow()  ,009 say OpeLog->DatLog
               @ prow()  ,020 say OpeLog->HorLog
               @ prow()  ,029 say OpeLog->CodLog
               @ prow()  ,033 say PwUsers->Nome
               @ prow()  ,059 say OpeLog->NivLog
               @ prow()  ,061 say OpeLog->AtiLog
            end
            OpeLog->(dbskip())
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
               @ prow()+1,00 say replicate("=",135)
               lCabec := .t.
               nPagina += 1
               if !(left(T_IPorta,3) == "USB")
                  eject
               else
                  setprc(00,00)
               end
            end
         end
      end sequence
      if nTecla == K_ESC
         FimPrinter(135,"Impressao Cancelada")
      else
         FimPrinter(135)
      end
      if !(left(T_IPorta,3) == "USB")
         @ prow(),pcol() say T_ICONDF
         eject
      else
         setprc(00,00)
      end
      set printer to
      set device to screen
      Msg(.f.)
      if nVideo == 1
         Fim_Imp(140)
      elseif nVideo == 2
         Ve_Txt("c:\tmp\",Arq_Sen+".prn",02,00,23,79,250)
      end
   end
   RestWindow(cTela)
   return

//** Fim do Arquivo.
