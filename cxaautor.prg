/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 3.00
 * Identificacao: Manutencao de Autorizacao de Manuten‡Æo dos Lan‡amentos dos caixa
 * Prefixo......: LTADM
 * Programa.....: CxaAutor.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 04 de Dezembro de 2003
 * Copyright (C): LT - LUCAS Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"


procedure ConCxaAuto
   local cTela := SaveWindow()

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !(Abre_Dados(cDiretorio,"Caixa",1,1,"Caixa",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   if !(Abre_Dados(cDiretorio,"CxaAutor",1,1,"CxaAutor",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   Msg(.f.)
   ViewCxaAuto()
   FechaDados()
   RestWindow(cTela)
//******************************************************************************
procedure IncCxaAuto
   local getlist := {},cTela := SaveWindow()
   local cCodCxa,cCodUsu

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !(Abre_Dados(cDiretorio,"Caixa",1,1,"Caixa",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   if !(Abre_Dados(cDiretorio,"CxaAutor",1,1,"CxaAutor",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   Msg(.f.)
   AtivaF4()
   TelCxaAuto(1)
   while .t.
      cCodCxa := space(02)
      cCodUsu := space(03)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,28 get cCodCxa picture "@k 99" when Rodape("Esc-Encerra | F4-Caixas") valid Busca(Zera(@cCodCxa),"Caixa",1,11,31,"Caixa->NomCaixa",{"Caixa Nao Cadastrado"},.f.,.t.,.f.)
      @ 12,28 get cCodUsu picture "@k 999" when Rodape("Esc-Encerra") valid vUsuario(@cCodUsu)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if CxaAutor->(dbsetorder(1),dbseek(cCodCxa+cCodUsu))
         Mens({"Autorizacao Ja Cadastrada"})
         loop
      end
      if !Confirm("Confirma a Inclusao")
         loop
      end
      if CxaAutor->(Adiciona())
         CxaAutor->CodCxa := cCodCxa
         CxaAutor->CodUsu := cCodUsu
         CxaAutor->(dbcommit())
         CxaAutor->(dbunlock())
      end
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
//******************************************************************************
procedure ExcCxaAuto
   local getlist := {},cTela := SaveWindow()
   local cCodCxa,cCodUsu

   Msg(.t.)
   Msg("Aguarde : Abrindo o Arquivo")
   if !(Abre_Dados(cDiretorio,"Caixa",1,1,"Caixa",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   if !(Abre_Dados(cDiretorio,"CxaAutor",1,1,"CxaAutor",1,.f.) == 0)
      FechaDados()
      Msg(.f.)
      return
   end
   Msg(.f.)
   AtivaF4()
   TelCxaAuto(3)
   while .t.
      cCodCxa := space(02)
      cCodUsu := space(03)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,28 get cCodCxa picture "@k 99" when Rodape("Esc-Encerra | F4-Caixas") valid Busca(Zera(@cCodCxa),"Caixa",1,11,31,"Caixa->NomCaixa",{"Caixa Nao Cadastrado"},.f.,.t.,.f.)
      @ 12,28 get cCodUsu picture "@k 999" when Rodape("Esc-Encerra") valid vUsuario(@cCodUsu)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !CxaAutor->(dbsetorder(1),dbseek(cCodCxa+cCodUsu))
         Mens({"Autorizacao Nao Cadastrada"})
         loop
      end
      if !Confirm("Confirma a Exclusao")
         loop
      end
      if CxaAutor->(Trava_Reg())
         CxaAutor->(dbdelete())
         CxaAutor->(dbcommit())
         CxaAutor->(dbunlock())
      end
   end
   DesativaF4()
   FechaDados()
   RestWindow(cTela)
   return
//******************************************************************************
procedure TelCxaAuto( nModo )
   local cTitulo, aTitulos := { "InclusÆo" , "Altera‡Æo" , "ExclusÆo" }

   Window(09,17,14,62," "+aTitulos[nModo]+" de Autorizacao ")
   setcolor(Cor(11))
   //           901234567890123456789
   //            2        3
   @ 11,19 say "  Caixa:"
   @ 12,19 say "Usuario:"
   return
//******************************************************************************
static function vUsuario(cCodUsu)

   if !Busca(Zera(@cCodUsu),"PwUsers",1,12,32,"PwUsers->Nome",{"Usuario Nao Cadastrado"},.f.,.f.,.f.)
      return(.f.)
   end
   if PwUsers->Nivel == "0"
      Mens({"Usuario de Nivel Pleno"})
      return(.f.)
   end
   PwUsers->(dbsetorder(1),dbseek(PwRegt))
   return(.t.)

//** Fim do Arquivo.
