/*************************************************************************
 * Sistema......: Fluxo de Caixa
 * Versao.......: 3.00
 * Identificacao: Manutencao de Formas de Pagamento
 * Prefixo......: LtFCaixa
 * Programa.....: FORMAPAG.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 28 DE DEZEMBRO DE 2002
 * Copyright (C): LUCAS Tecnologia Ltda.
*/
#include "LUCAS.CH"       // Inclusao do Arquivo Header Padrao
#include "INKEY.CH"   // Header para manipulacao de Teclas
#include "setcurs.ch"

procedure ConFPagCxa
   local cTela := SaveWindow()

   ViewFPag(.f.)
   RestWindow(cTela)
return
// ****************************************************************************
procedure IncFPagCxa
   local getlist := {},cTela := SaveWindow()
   local nId,cDescricao,cQuery,oQuery

   AtivaF4()
   TelFPagCxa(1)
   do while .t.
      nId := 0
      cDescricao := space(30)
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      cQuery := "SELECT last_value FROM financeiro.formapagtocaixa_id_seq "
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
         exit
      endif  
      nId := oQuery:fieldget('last_value')
      @ 11,31 say nId picture "@k 99"
      @ 12,31 get cDescricao picture "@k!";
                  when Rodape("Esc-Encerra")
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      end
      if !Confirm("Confirma a InclusÆo")
         loop
      end
      cQuery := "INSERT INTO financeiro.formapagtocaixa (descricao) VALUES ("+StringToSql(cDescricao)+")"
      Msg(.t.)
      Msg("Aguarde: Gravando as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      if !Grava_LogSql("Cadastros|Financeiro|Caixa|Formas de pagamento|Incluir|Codigo: "+str(nId))
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
       endif
      oServer:Commit()
      oQuery:Close()
      Msg(.f.)
   end
   DesativaF4()
   RestWindow(cTela)
return
// ****************************************************************************
procedure AltFPagCxa
   local getlist := {},cTela := SaveWindow()
   local nId,cDescricao,cQuery,oQuery

   AtivaF4()
   TelFPagCxa(2)
   while .t.
      nId := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,31 get nId picture "@k 99";
                     when Rodape("Esc-Encerra | F4-Formas de Pagamento");
                     valid SqlBusca("id = "+NumberToSql(nId),"descricao",@oQuery,;
                     "financeiro.formapagtocaixa",,,,{"Forna de pagamento nÆo cadastrada"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif 
      cDescricao := oQuery:fieldget('descricao')
      @ 12,31 get cDescricao picture "@k!";
                  when Rodape("Esc-Encerra")
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         loop
      endif
      if !Confirm("Confirma a Altera‡Æo")
         loop
      endif 
      cQuery := "UPDATE financeiro.formapagtocaixa (descricao) VALUES ("+StringToSql(cDescricao)+")"
      cQuery += " WHERE id = "+NumberToSql(nId)
      Msg(.t.)
      Msg("Aguarde: Gravando as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      if !Grava_LogSql("Cadastros|Financeiro|Caixa|Formas de pagamento|Alterar|Codigo: "+str(nId))
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
   RestWindow(cTela)
return
// ****************************************************************************
procedure ExcFPagCxa
   local getlist := {},cTela := SaveWindow()
   local nId,cQuery,oQuery

   AtivaF4()
   TelFPagCxa(3)
   do while .t.
      nId := 0
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 11,31 get nId picture "@k 99";
               when Rodape("Esc-Encerra | F4-Formas de Pagamento");
               valid SqlBusca("id = "+NumberToSql(nId),"descricao",@oQuery,;
               "financeiro.formapagtocaixa",,,,{"Forna de pagamento nÆo cadastrada"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif 
      @ 12,31 say oQuery:fieldget('descricao')
      if !Confirm("Confirma a ExclusÆo",2)
         loop
      endif 
      cQuery := "DELETE FROM financeiro.formapagtocaixa WHERE id = "+NumberToSql(nId)
      Msg(.t.)
      Msg("Aguarde: Excluindo as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      if !Grava_LogSql("Cadastros|Financeiro|Caixa|Formas de pagamento|Excluir|Codigo: "+str(nId))
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
       endif
      oServer:Commit()
      oQuery:Close()
   enddo
   DesativaF4()
   RestWindow(cTela)
return
// ****************************************************************************
procedure TelFPagCxa( nModo )
   local cTitulo, aTitulos := { "InclusÆo" , "Altera‡Æo" , "ExclusÆo" }

   Window(09,18,14,63,"> "+aTitulos[nModo]+" de Formas de Pagamento <")
   setcolor(Cor(11))
   //           901234567890123456789
   //            2         3
   @ 11,19 say "    C¢digo:"
   @ 12,19 say " Descricao:"
return

// ** Fim do Arquivo.
