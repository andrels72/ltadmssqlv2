/*************************************************************************
 * Sistema......: Emissor de Cupom Fiscal
 * Versao.......: 2.00
 * Identificacao: EmissÆo de Leituras Fiscais
 * Prefixo......: LTCUPOM
 * Programa.....: Leitura.prg
 * Autor........: Andre Lucas Souza
 * Data.........: 08 de Julho de 2008
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"       // Inclusao do Arquivo Header Padrao
#include "inkey.ch"   // Header para manipulacao de Teclas
#include "setcurs.ch"


procedure LeituraMFR
   local getlist := {},cTela := SaveWindow()
   local nInicio,nFinal,cSimples

   Window(07,27,13,52)
   setcolor(Cor(11))
   //           9012345678901234567
   //            3         4
   @ 09,29 say "Redu‡Æo inicial:"
   @ 10,29 say "  Redu‡Æo final:"
   @ 11,29 say " Simplificada ?:"
   while .t.
      nInicio  := 1
      nFinal   := 9999
      cSimples := "N"
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 09,46 get nInicio  picture "@k 9999" valid nInicio > 0
      @ 10,46 get nFinal   picture "@k 9999" valid nFinal >= nInicio
      @ 11,46 get cSimples picture "@k!" valid cSimples $ "SN"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as informa‡äes")
         loop
      end
      Acbr_LeituraMemoriaFiscal({nInicio,nFinal,(cSimples == "S")})
      exit
   end
   RestWindow(cTela)
   return

//** Leitura de Mem¢ria fiscal por data
procedure LeituraMFD
   local getlist := {},cTela := SaveWindow()
   local dDataI,dDataF,cSimples

   Window(09,26,15,53)
   setcolor(Cor(11))
   //           12345678901234567
   //                    4
   @ 11,28 say "Data inicial:"
   @ 12,28 say "  Data final:"
   @ 13,28 say "    Simples :"
   while .t.
      dDataI   := date()
      dDataF   := date()
      cSimples := "N"
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,42 get dDataI picture "@k"
      @ 12,42 get dDataF picture "@k" valid dDataF >= dDataI
      @ 13,42 get cSimples picture "@k!" valid NoEmpty(cSimples)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma as informa‡äes")
         loop
      end
      Acbr_LeituraMemoriaFiscal({dDataI,dDataF,(cSimples == "S")})
      exit
   end
   RestWindow(cTela)
   return

