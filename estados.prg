/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.00
 * Identificacao: ManutenÎ’o de Estados
 * Prefixo......: LtAdm
 * Programa.....: Cidades.prg
 * Autor........: Andre Lucas Souza
 * Data.........: 23 de Setembro de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConEstados
   local cTela := SaveWindow()

   ViewEstado(.f.)
   RestWindow(cTela)
return
// ****************************************************************************
procedure IncEstados
   local getlist := {},cTela := SaveWindow()
   local cCodEst,cNomEst,cQuery,oQuery

   DesativaF9()
   AtivaF4()
   TelEstado(1)
   while .t.
      cCodEst := space(02)
      cNomEst := space(35)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,26 get cCodEst picture "@k!";
      		When Rodape("Esc-Encerra | F4-Estados");
            valid SqlBusca("codest = "+StringToSql(cCodEst),"nomest",@oQuery,;
            "administrativo.estados",,,,{"Estado j  cadastrado"},.t.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      @ 12,26 get cNomEst picture "@k!";
                  when Rodape("Esc-Encerra");
                  valid NoEmpty(cNomEst)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      end
      if !Confirm("Confirma a Inclusao")
         loop
      endif
      cQuery := "INSERT INTO administrativo.estados (codest,nomest) VALUES ("+StringToSql(cCodEst)+","+StringToSql(cNomEst)+")"
      Msg(.t.)
      Msg("Aguarde: Gravando as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      if !Grava_LogSql("Cadastros|Estados|Incluir|Estadoo : "+cCodEst)
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      oServer:Commit()
      oQuery:Close()
      Msg(.f.)

   enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   endif
   RestWindow(cTela)
return
// ****************************************************************************
procedure AltEstados
   local getlist := {},cTela := SaveWindow()
   local cCodEst,cNomEst,cQuery,oQuery

   DesativaF9()
   AtivaF4()
   TelEstado(2)
   do while .t.
      cCodEst := space(02)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,26 get cCodEst picture "@k!";
      		When Rodape("Esc-Encerra | F4-Estados");
            valid SqlBusca("codest = "+StringToSql(cCodEst),"nomest",@oQuery,;
            "administrativo.estados",,,,{"Estado nÆo cadastrado"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      cNomEst := oQuery:fieldget('NomEst')
      @ 12,26 get cNomEst picture "@k!";
                  when Rodape("Esc-Encerra");
                  valid NoEmpty(cNomEst)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      endif
      if !Confirm("Confirma a Alteracao")
         loop
      endif
      cQuery := "UPDATE administrativo.estados SET nomest = "+StringToSql(cNomEst)+" WHERE codest = "+StringToSql(cCodEst)
      Msg(.t.)
      Msg("Aguarde: Alterando as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      if !Grava_LogSql("Cadastros|Estados|Alterar|Estadoo : "+cCodEst)
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      oServer:Commit()
      oQuery:Close()
      Msg(.f.)
      Mens({"Altera‡Æo realizada com sucesso"})
   enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   end
   RestWindow(cTela)
return
// ****************************************************************************
procedure ExcEstados
   local getlist := {},cTela := SaveWindow()
   local cCodEst,cQuery,oQuery

   DesativaF9()
   AtivaF4()
   TelEstado(3)
   while .t.
      cCodEst := space(02)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,26 get cCodEst picture "@k!";
      		When Rodape("Esc-Encerra | F4-Estados");
            valid SqlBusca("codest = "+StringToSql(cCodEst),"nomest",@oQuery,;
            "administrativo.estados",,,,{"Estado nÆo cadastrado"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      @ 12,26 say oQuery:fieldget('NomEst')
      // pesquisa se existe cidades para este estado
      if !SqlBusca("estcid = "+StringToSql(cCodEst),"estcid",@oQuery,"administrativo.cidades",,,,,.t.,1)
         Mens({"Existe cidade(s) com esse estado","ExclusÆo nÆo ‚ permitida"})
         loop
      endif
      if !Confirm("Confirma a Excluir",2)
         loop
      endif
      cQuery := "DELETE FROM administrativo.estados WHERE codest = "+StringToSql(cCodEst)
      Msg(.t.)
      Msg("Aguarde: Alterando as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      if !Grava_LogSql("Cadastros|Estados|Excluir|Estadoo : "+cCodEst)
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      oServer:Commit()
      oQuery:Close()
      Msg(.f.)
      Mens({"ExclusÆo realizada com sucesso"})
   enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
   endif
   RestWindow(cTela)
return
// ****************************************************************************
procedure TelEstado( nModo)
   local aTitulos := {"Inclusao","Alteracao","Exclusao","Recalcular Comissao"}

   Window(09,16,14,62,"> " + aTitulos[ nModo ] + " de Estados <")
   setcolor(Cor(11))
   //           890123456789012345678901234567890123456789012345678
   //             2         3         4         5         6         7
   @ 11,18 say " Sigla:"
   @ 12,18 say "Estado:"
return

// ** Fim do Arquivo.
