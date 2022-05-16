/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.00
 * Identificacao: Manutená∆o de Transpotadora
 * Prefixo......: LtAdm
 * Programa.....: Bancos.prg
 * Autor........: Andre Lucas Souza
 * Data.........: 20 de Novembro de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConTranspo
   local cTela := SaveWindow()

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !(Abre_Dados(cDiretorio,"Transpo",1,2,"Transpo",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   Msg(.f.)
   ViewTransp(.f.)
   FechaDados()
   RestWindow(cTela)
//****************************************************************************
procedure IncTranspo
   local getlist := {},cTela := SaveWindow(),nCursor := setcursor()
   local cCodTra,cNomTra,cEndTra,cCidTra,cEstTra,cPlaTra,cEstPla,cInsTra
   local cCGCTra,cTelTra

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !(Abre_Dados(cDiretorio,"Transpo",1,2,"Transpo",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   Msg(.f.)
   DesativaF9()
   AtivaF4()
   TelTranspo(1)
   while .t.
      cNomTra := space(40)
      cEndTra := space(40)
      cCidTra := space(20)
      cEstTra := space(02)
      cPlaTra := space(07)
      cEstPla := space(02)
      cInsTra := space(16)
      cCGCTra := space(14)
      cTelTra := space(11)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      Transpo->(dbsetorder(1),dbgobottom())
      if Transpo->(eof())
         Transpo->(dbskip(-1))
      end
      cCodTra := strzero(val(Transpo->CodTra)+1,2)
      @ 07,27 get cCodTra picture "@k 99" when Rodape("Esc-Encerra | F4-Transpotadora")  valid Busca(Zera(@cCodTra),"Transpo",1,,,,{"Transpotadora Ja Cadastrada"},.f.,.f.,.t.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      @ 08,27 get cNomTra picture "@k!" when Rodape("Esc-Encerra")
      @ 09,27 get cEndTra picture "@k!"
      @ 10,27 get cCidTra picture "@k!"
      @ 11,27 get cEstTra picture "@k!"
      @ 12,27 get cPlaTra picture "@r AAA-9999"
      @ 12,36 get cEstPla picture "@k!"
      @ 13,27 get cInsTra picture "@k"
      @ 14,27 get cCGCTra picture "@r 99.999.999/9999-99"
      @ 15,27 get cTelTra picture "@kr (999)9999-9999"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      end
      if !Confirm("Confirma a Inclusao")
         loop
      end
      while !Transpo->(Adiciona())
      end
      Transpo->CodTra := cCodTra
      Transpo->NomTra := cNomTra
      Transpo->EndTra := cEndTra
      Transpo->CidTra := cCidTra
      Transpo->EstTra := cEstTra
      Transpo->PlaTra := cPlaTra
      Transpo->EstPla := cEstPla
      Transpo->InsTra := cInsTra
      Transpo->CGCTra := cCGCTra
      Transpo->TelTra := cTelTra
      Grava_Log(cDiretorio,"Transportadora|Incluir|Codigo "+cCodTra,Transpo->(recno()))
   end
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   end
   FechaDados()
   RestWindow(cTela)
   return
//****************************************************************************
procedure AltTranspo
   local getlist := {},cTela := SaveWindow(),nCursor := setcursor()
   local cCodTra,cNomTra,cEndTra,cCidTra,cEstTra,cPlaTra,cEstPla,cInsTra
   local cCGCTra,cTelTra

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !(Abre_Dados(cDiretorio,"Transpo",1,2,"Transpo",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   Msg(.f.)
   DesativaF9()
   AtivaF4()
   TelTranspo(2)
   while .t.
      cCodTra := space( 02 )
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 07,27 get cCodTra picture "@k 99" when Rodape("Esc-Encerra | F4-Transpotadora")  valid Busca(Zera(@cCodTra),"Transpo",1,,,,{"Transpotadora Nao Cadastrada"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      cNomTra := Transpo->NomTra
      cEndTra := Transpo->EndTra
      cCidTra := Transpo->CidTra
      cEstTra := Transpo->EstTra
      cPlaTra := Transpo->PlaTra
      cEstPla := Transpo->EstPla
      cInsTra := Transpo->InsTra
      cCGCTra := Transpo->CGCTra
      cTelTra := Transpo->TelTra
      @ 08,27 get cNomTra picture "@k!" when Rodape("Esc-Encerra")
      @ 09,27 get cEndTra picture "@k!"
      @ 10,27 get cCidTra picture "@k!"
      @ 11,27 get cEstTra picture "@k!"
      @ 12,27 get cPlaTra picture "@r AAA-9999"
      @ 12,36 get cEstPla picture "@k!"
      @ 13,27 get cInsTra picture "@k"
      @ 14,27 get cCGCTra picture "@r 99.999.999/9999-99"
      @ 15,27 get cTelTra picture "@kr (999)9999-9999"
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      end
      if !Confirm("Confirma a Alteracao")
         loop
      end
      while !Transpo->(Trava_Reg())
      end
      Transpo->NomTra := cNomTra
      Transpo->EndTra := cEndTra
      Transpo->CidTra := cCidTra
      Transpo->EstTra := cEstTra
      Transpo->PlaTra := cPlaTra
      Transpo->EstPla := cEstPla
      Transpo->InsTra := cInsTra
      Transpo->CGCTra := cCGCTra
      Transpo->TelTra := cTelTra
      Grava_Log(cDiretorio,"Transportadora|Alterar|Codigo "+cCodTra,Transpo->(recno()))
   end
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   end
   FechaDados()
   RestWindow(cTela)
   return
//****************************************************************************
procedure ExcTranspo
   local getlist := {},cTela := SaveWindow(),nCursor := setcursor()
   local cCodTra

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !(Abre_Dados(cDiretorio,"Transpo",1,2,"Transpo",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   Msg(.f.)
   DesativaF9()
   AtivaF4()
   TelTranspo(3)
   while .t.
      cCodTra := space( 02 )
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 07,27 get cCodTra picture "@k 99" when Rodape("Esc-Encerra | F4-Transpotadora")  valid Busca(Zera(@cCodTra),"Transpo",1,,,,{"Transpotadora Nao Cadastrada"},.f.,.f.,.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      @ 08,27 say Transpo->NomTra picture "@k!"
      @ 09,27 say Transpo->EndTra picture "@k!"
      @ 10,27 say Transpo->CidTra picture "@k!"
      @ 11,27 say Transpo->EstTra picture "@k!"
      @ 12,27 say Transpo->PlaTra picture "@r AAA-9999"
      @ 12,36 say Transpo->EstPla picture "@k!"
      @ 13,27 say Transpo->InsTra picture "@k"
      @ 14,27 say Transpo->CGCTra picture "@r 99.999.999/9999-99"
      @ 15,27 say Transpo->TelTra picture "@kr (999)9999-9999"
      if !Confirm("Confirma a Exclusao",2)
         loop
      end
      while !Transpo->(Trava_Reg())
      end
      Transpo->(dbdelete())
      Grava_Log(cDiretorio,"Transportadora|Excluir|Codigo "+cCodTra,Transpo->(recno()))
   end
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   end
   FechaDados()
   RestWindow(cTela)
   return
//****************************************************************************
procedure TelTranspo( nModo )
   local cTitulo, aTitulos := { "Inclus∆o" , "Alteraá∆o" , "Exclus∆o" }

   Window(05,10,17,68," "+aTitulos[nModo]+" de Transportadora ")
   setcolor(Cor(11))
   //           2345678901234567890123456789
   //                   2         3
   @ 07,12 say "       Codigo:"
   @ 08,12 say "         Nome:"
   @ 09,12 say "     Endereco:"
   @ 10,12 say "       Cidade:"
   @ 11,12 say "       Estado:"
   @ 12,12 say "Placa Veiculo:"
   @ 13,12 say "Insc.Estadual:"
   @ 14,12 say "       C.G.C.:"
   @ 15,12 say "     Telefone:"
   return

//** Fim do Arquivo.
