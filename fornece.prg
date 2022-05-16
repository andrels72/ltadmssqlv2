/*************************************************************************
 * Sistema......: Controle de Ceramica
 * Versao.......: 2.00
 * Identificacao: Manutencao de Fornecedores
 * Prefixo......: LtSCC
 * Programa.....: Fornece.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 18 de Agosto de 2003
 * Copyright (C): LT - Tecnologia Ltda.
*/
#include "lucas.ch"
#include "inkey.ch"
#include "setcurs.ch"

procedure ConFornecedor(lAbrir)
   local GetList := {},oBrow,oCol,nTecla,lFim := .F.,cTela := savewindow(),cDados
   local nCursor := setcursor(),cCor := setcolor()
   local cQuery,oQuery,nLin1 := 02,nCol1 := 00,nLin2 := 30,nCol2 := 100
   local cTipo := '1',aTipo,cPesquisa

   if !lAbrir
       setcursor(SC_NONE)
   endif    
   
   Window(nLin1,nCol1,nLin2,nCol2,"> Consulta de Fornecedores <")
   setcolor(Cor(11))
   //           1234567890123456789012345678901234567890123456789012345678901234567890
   //                    1         2
   @ 03,01 say "Pesquisar:              "
   @ 04,01 say replicate(chr(196),99)
   cPesquisa := space(40)
   
   setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
   @ 03,12 get cTipo picture "@k 9";
               valid MenuArray(@cTipo,{{"1","   RazÆo:"},{"2","Fantasia:"}},,,row(),col()+1)
   @ 03,25 get cPesquisa picture "@K!"
   setcursor(SC_NORMAL)
   read
   setcursor(SC_NONE)
   if lastkey() == K_ESC    
       if !lAbrir
           setcursor(nCursor)
           setcolor(cCor)
       endif
       RestWindow( cTela )
       return
   endif
   cQuery := "SELECT f.id,f.DatFor,f.RazFor,f.FanFor,f.EndFor,f.BaiFor,f.idcidade,cidades.nomcid,cidades.estcid,"
   cQuery += "f.CepFor,f.TelFor1,f.TelFor2,f.FaxFor,f.EMaFor,f.ConFor,f.CelFor,f.CgcFor,f.IEsFor,f.Obs "
   cQuery += "FROM administrativo.fornecedores f"
   cQuery += " INNER JOIN administrativo.cidades cidades ON( f.idcidade = cidades.codcid) " 
   if cTipo = "1"
       if !empty(cPesquisa)
           cQuery += " WHERE RazFor LIKE '%"+rtrim(cPesquisa)+"%'"
       endif
   else
       if !empty(cPesquisa)
           cQuery += " WHERE FanFor LIKE '%"+rtrim(cPesquisa)+"%'"
       endif
   endif
   if cTipo = "1" // Raz’o
       cQuery += "ORDER BY RazFor"
   else // Fantasia
       cquery += " ORDER BY FanFor "
   endif
   Msg(.t.)
   Msg("Aguarde: pesquisando as informa?„es")
   if !ExecuteSql(cQuery,@oQuery,{"Falha: pesquisar fornecedor"},"sqlerro")
       oQuery:close()
       Msg(.f.)
       RestWindow(cTela)
       return
   endif
   Msg(.f.)
   if oQuery:Lastrec() = 0
       Mens({"NÆo existe informa‡Æo pesquisada"})
       oQuery:close()
       RestWindow(cTela)
       return
   endif
   if lAbrir
     Rodape("Esc-Encerrar | F3-Visualizar")
   else
     Rodape("Esc-Encerra | ENTER-Transf. | F3-Visualizar")
   end
   setcolor(cor(5))
   oBrow := TBrowseDB(nLin1+3,nCol1+1,nLin2-1,nCol2-1)
   oBrow:headSep := chr(194)+chr(196)
   oBrow:colSep  := chr(179)
   oBrow:footSep := chr(193)+chr(196)
   oBrow:colorSpec := COR(25)+","+cor(6)+","+Cor(9)+",N,"+cor(6)+","+Cor(6)
   oBrow:SkipBlock := {| n | oCurRow := SkipperQuery( @n, oQuery ), n }
   oBrow:GoBottomBlock := {|| oCurRow := oQuery:GetRow( oQuery:LastRec() ), 1 }
   oBrow:GoTopBlock := {|| oCurRow := oQuery:GetRow( 1 ), 1 }
   oBrow:addcolumn(TBColumnNew("Razao Social" ,{|| oQuery:FieldGet('RazFor') }))
   oColuna := tbcolumnnew("Fantasia",{|| oQuery:FieldGet('FanFor')})
   oColuna:width := 36
   oBrow:addcolumn(oColuna)
   do WHILE (! lFim)
       ForceStable(oBrow)
       if ( obrow:hittop .or. obrow:hitbottom )
           tone(1200,1)
       endif
       aRect := { oBrow:rowPos,1,oBrow:rowPos,2}
       oBrow:colorRect(aRect,{2,2})
       cTecla := chr((nTecla := inkey(0)))
       if !OnKey( nTecla,oBrow)
       endif
       if nTecla == K_F3
           VerFor(oQuery)
      elseif nTecla == K_ENTER
         if !lAbrir
            cDados := str(oQuery:fieldget('codFor'))
            keyboard (cDados)+chr(K_ENTER)
            lFim := .t.
         endif
      elseif nTecla == K_ESC
         lFim := .t.
      endif
      oBrow:refreshcurrent()
   enddo
   if !lAbrir
       setcursor(nCursor)
       setcolor(cCor)
   endif
   RestWindow( cTela )
RETURN
// *****************************************************************************
procedure IncFornecedor
	local getlist := {},cTela := SaveWindow()
	local lLimpa := .t.
	private oFornecedr
	
   if PwNivel == "0"
      DesativaF9()
   endif
   AtivaF4()      
   TelaFornecedor(1)
	do while .t.
		if lLimpa
			oFornecedor := TFornecedor():new()
			lLimpa := .f.
		endif
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      oQuery := oServer:Query("SELECT Last_value FROM administrativo.fornecedores_id_seq")
      nId := oQuery:fieldget('last_value')
      @ 05,12 say nId picture "9999"
		if !GetFornecedor(.t.)
			exit
		endif
      if !Confirm("Confirma a Inclusao")
        	loop
      endif
      Msg(.t.)
      Msg("Aguarde: Gravando as informa‡äes")
      oServer:StartTransaction()
      if !GravarFornecedor(.t.)
         oServer:Rollback()
         Msg(.f.)
         loop
      endif
      oServer:Commit()
      Msg(.f.)
      //Grava_Log(cDiretorio,"Fornecedor|Incluir|Codigo "+oFornecedor:cCodFor,Fornecedor->(recno()))
      lLimpa := .t.
   end
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   end
   RestWindow(cTela)
return
// *****************************************************************************
procedure AltFornecedor
   local getlist := {},cTela := SaveWindow()
	private oFornecedor,cQuery,oQuery

   if PwNivel == "0"
      DesativaF9()
   end
   AtivaF4()
   TelaFornecedor(2)
	do while .t.
		oFornecedor := TFornecedor():new()
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 05,12 get oFornecedor:nId picture "@k 9999";
      			when Rodape("Esc-Encerra | F4-Fornecedores");
               valid SqlBusca("id = "+NumberToSql(oFornecedor:nId),"id",@oQuery,"administrativo.fornecedores",,,,{"Fornecedor nÆo cadastrado"},.f.)               
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      if !oFornecedor:RecuperarDados(oFornecedor:nId,@oQuery)
         loop
      endif
		if !GetFornecedor(.t.)
			loop
		endif
      if !Confirm("Confirma a Alteracao")
         loop
      endif
      Msg(.t.)
      Msg("Aguarde: Gravando as informa‡äes")
      oServer:StartTransaction()
      if !GravarFornecedor(.f.)
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      oServer:Commit()
      Msg(.f.)
		//Grava_Log(cDiretorio,"Fornecedor|Alterar|Codigo "+oFornecedor:cCodFor,Fornecedor->(recno()))
	enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   end
   RestWindow(cTela)
return
// *****************************************************************************
procedure ExcFornecedor
   local getlist := {},cTela := SaveWindow()
   local cQuery,oQuery
	private oFornecedor

   if PwNivel == "0"
      DesativaF9()
   endif
   AtivaF4()
   TelaFornecedor(3)
	do while .t.
		oFornecedor := TFornecedor():new()
      setcolor(Cor(8)+","+Cor(9)+",,,"+Cor(8))
      @ 05,12 get oFornecedor:nId picture "@k 9999";
      		when Rodape("Esc-Encerra | F4-Fornecedores");
            valid SqlBusca("id = "+NumberToSql(oFornecedor:nId),"id",@oQuery,"administrativo.fornecedores",,,,{"Fornecedor nÆo cadastrado"},.f.)
      setcursor(SC_NORMAL)
      read
      setcursor(SC_NONE)
      if lastkey() == K_ESC
         exit
      endif
      if !oFornecedor:RecuperarDados(oFornecedor:nId,@oQuery)
         loop
      endif
      if !GetFornecedor(.f.)
         loop
      endif
      if !Confirm("Confirma a Exclusao",2)
         loop
      endif
      /*
        if Compra->(dbsetorder(7),dbseek(oFornecedor:cCodFor))
            Mens({"Fornecedor nÆo pode ser exclu¡do",;
                    "Existe nota fiscal de entrada"})
            loop
        endif
      */
      cQuery := "DELETE FROM administrativo.fornecedores WHERE id = "+NumberToSql(oFornecedor:nId)
      Msg(.t.)
      Msg("Aguarde: Gravando as informa‡äes")
      oServer:StartTransaction()
      if !ExecuteSql(cQuery,@oQuery,{"Erro: Incluir (caixa)"},"sqlerro")
          oQuery:Close()
          oServer:Rollback()
          Msg(.f.)
          loop
      endif
      if !Grava_Log(cDiretorio,"Cadastros|Fornecedores|Excluir|Codigo "+str(oFornecedor:nId,4))
         oServer:Rollback()
         Msg(.f.)
         loop
     endif
      oServer:Commit()
      Msg(.f.)
      Mens({"Excluido com sucesso"})
   enddo
   DesativaF4()
   if PwNivel == "0"
      AtivaF9()
      lGeral := .f.
   endif
   RestWindow(cTela)
return
// *****************************************************************************
procedure VerFor()
   loca cTela := SaveWindow(),cCodCli

   TelaFornecedor(4)
   MosFor()
   Rodape(space(20)+"Pressione Qualquer Tecla para Continuar")
   Inkey(0)
   RestWindow(cTela)
   return
// *****************************************************************************
static procedure MosFor

   Cidades->(dbsetorder(1),dbseek(Fornecedor->CodCid))

   @ 05,12 say Fornecedor->CodFor
   @ 05,50 say Fornecedor->DatFor
   @ 06,12 say Fornecedor->RazFor
   @ 07,12 say Fornecedor->FanFor
   @ 08,12 say Fornecedor->EndFor
   @ 09,12 say Fornecedor->BaiFor
   @ 10,12 say Fornecedor->CodCid
   @ 10,18 say Cidades->NomCid
   @ 10,69 say Cidades->EstCid
   @ 11,12 say Fornecedor->CepFor  picture "@kr 99999-999"
   @ 12,12 say Fornecedor->TelFor1 picture "@kr (999)9999-9999"
   @ 12,31 say Fornecedor->TelFor2 picture "@kr (999)9999-9999"
   @ 13,12 say Fornecedor->FaxFor  picture "@kr (999)9999-9999"
   @ 14,12 say Fornecedor->EMaFor  picture "@k"
   @ 15,12 say Fornecedor->ConFor  picture "@k"
   @ 16,12 say Fornecedor->CelFor  picture "@k"
   @ 17,12 say Fornecedor->CgcFor  picture "@r 99.999.999/9999-99"
   @ 18,12 say Fornecedor->IEsFor  picture "@k"
   @ 19,12 say Fornecedor->Obs     picture "@k!"
   return
// *****************************************************************************
procedure TelaFornecedor(nModo )
   local cTitulo, aTitulos := { "InclusÆo","Altera‡Æo","ExclusÆo","Visualizacao" }

   Window(03,00,21,90,"> "+aTitulos[nModo]+" de Fornecedores <")
   setcolor(Cor(11))
   //           23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
   //                   1         2         3         4         5         6         7         8
   @ 05,02 say "  C¢digo:                             Cadastro:"
   @ 06,02 say "  Razao :"
   @ 07,02 say "Fantasia:"
   @ 08,02 say "Endereco:                                                               Numero:"
   @ 09,02 say "  compl.:"
   @ 10,02 say "  Bairro:"
   @ 11,02 say "  Cidade:"
   @ 12,02 say "     Cep:"
   @ 13,02 say "    Fone:                  /"
   @ 14,02 say "     Fax:"
   @ 15,02 say "  E-Mail:"
   @ 16,02 say " Contato:"
   @ 17,02 say " Celular:"
   @ 18,02 say "   CNPJ.:                             Tipo Contrib.:"
   @ 19,02 say " I. Est.:"
   @ 20,02 say "    Obs.:"
   return
// *****************************************************************************
static procedure vCidade(cCodCid)

   if !Busca(Zera(@cCodCid),"Cidades",1,10,18,"Cidades->NomCid",{"Cidade Nao Cadastrada"},.f.,.f.,.f.)
      return(.f.)
   end
   @ 10,69 say Cidades->EstCid
   return(.t.)
// ************************************************************************************************
function GetFornecedor(lGet)
   local oQCidade
   
	@ 05,50 get oFornecedor:dDatFor picture "@k" when Rodape("Esc-Encerra")
	@ 06,12 get oFornecedor:cRazFor picture "@k"
	@ 07,12 get oFornecedor:cFanFor picture "@k";
		valid iif(empty(oFornecedor:cFanFor),(oFornecedor:cFanFor := oFornecedor:cRazFor,.t.),.t.)
	@ 08,12 get oFornecedor:cEndFor picture "@k"
	@ 08,82 get oFornecedor:cNumero picture "@k"
	@ 09,12 get oFornecedor:cCompl picture "@k"
	
	@ 10,12 get oFornecedor:cBaiFor picture "@k"
	@ 11,12 get oFornecedor:nIdCidade picture "@k 9999";
		         when Rodape("Esc-Encerra | F4-Cidades");
               valid vCidades(oFornecedor:nIdCidade,row(),col()+1)
	@ 12,12 get oFornecedor:cCepFor picture "@kr 99999-999" when Rodape("Esc-Encerra")
	@ 13,12 get oFornecedor:cTelFor1 picture "@kr (999)9999-9999"
	@ 13,31 get oFornecedor:cTelFor2 picture "@kr (999)9999-9999"
	@ 14,12 get oFornecedor:cFaxFor picture "@kr (999)9999-9999"
	@ 15,12 get oFornecedor:cEMaFor picture "@k"
	@ 16,12 get oFornecedor:cConFor picture "@k"
	@ 17,12 get oFornecedor:cCelFor picture "@k"
	@ 18,12 get oFornecedor:cCgcFor picture "@r 99.999.999/9999-99"
    @ 18,55 get oFornecedor:cIndIEDest picture "@k 9"; 
        	   valid MenuArray(@oFornecedor:cIndIEDest,{;
    			{"1","Contribuinte ICMS  "},;
    			{"2","Contribuinte ISENTO"},;
    			{"9","Nao Contribuinte   "}})
	@ 19,12 get oFornecedor:cIEsFor picture "@k"
	@ 20,12 get oFornecedor:cObs picture "@k!"
	if lGet
		setcursor(SC_NORMAL)
		read
		setcursor(SC_NONE)
		if lastkey() == K_ESC
			return(.f.)
		endif
	else
		clear gets
	endif
return(.t.)
	
	
static function GravarFornecedor(lIncluir)
   local cQuery,oQuery
   
	if lIncluir
      cQuery := "INSERT INTO administrativo.fornecedores "
      cQuery += "(Datfor,razfor,fanfor,endfor,baifor,idcidade,cepfor,telfor1,telfor2,faxfor,emafor,celfor,confor,"
      cQuery += "cgcfor,iesfor,obs,compl,numero,indiedest) "
      cQuery += "VALUES ("
      cQuery += DateToSql(oFornecedor:dDatFor)+","
      cQuery += StringToSql(oFornecedor:cRazFor)+","
      cQuery += StringToSql(oFornecedor:cFanFor)+","
      cQuery += StringToSql(oFornecedor:cEndFor)+","
      cQuery += StringToSql(oFornecedor:cBaiFor)+","
      cQuery += NumberToSql(oFornecedor:nIdCidade)+","
      cQuery += StringToSql(oFornecedor:cCelFor)+","
      cQuery += StringToSql(oFornecedor:cTelFor1)+","
      cQuery += StringToSql(oFornecedor:cTelFor2)+","
      cQuery += StringToSql(oFornecedor:cFaxFor)+","
      cQuery += StringToSql(oFornecedor:cEMaFor)+","
      cQuery += StringToSql(oFornecedor:cCelFor)+","
      cQuery += StringToSql(oFornecedor:cConFor)+","
      cQuery += StringToSql(oFornecedor:cCgcFor)+","
      cQuery += StringToSql(oFornecedor:cIEsFor)+","
      cQuery += StringToSql(oFornecedor:cObs)+","
      cQuery += StringToSql(oFornecedor:cCompl)+","
      cQuery += StringToSql(oFornecedor:cNumero)+","
      cQuery += StringToSql(oFornecedor:cIndIEDest)
      cQuery += ")"
	else
      cQuery := "UPDATE administrativo.fornecedores "
      cQuery += " SET "
      cQuery += " datfor = "+DateToSql(oFornecedor:dDatFor)+","
      cQuery += "razfor = "+StringToSql(oFornecedor:cRazFor)+","
      cQuery += "fanfor = "+StringToSql(oFornecedor:cFanFor)+","
      cQuery += "endfor = "+StringToSql(oFornecedor:cEndFor)+","
      cQuery += "baifor = "+StringToSql(oFornecedor:cBaiFor)+","
      cQuery += "idcidade = "+NumberToSql(oFornecedor:nIdCidade)+","
      cQuery += "celfor = "+StringToSql(oFornecedor:cCelFor)+","
      cQuery += "telfor1 = "+StringToSql(oFornecedor:cTelFor1)+","
      cQuery += "telfor2 = "+StringToSql(oFornecedor:cTelFor2)+","
      cQuery += "faxfor = "+StringToSql(oFornecedor:cFaxFor)+","
      cQuery += "emafor = "+StringToSql(oFornecedor:cEMaFor)+","
      cQuery += "confor = "+StringToSql(oFornecedor:cConFor)+","
      cQuery += "cgcfor = "+StringToSql(oFornecedor:cCgcFor)+","
      cQuery += "iesfor = "+StringToSql(oFornecedor:cIEsFor)+","
      cQuery += "obs = "+StringToSql(oFornecedor:cObs)+","
      cQuery += "compl = "+StringToSql(oFornecedor:cCompl)+","
      cQuery += "numero = "+StringToSql(oFornecedor:cNumero)+","
      cQuery += "indiedest = "+StringToSql(oFornecedor:cIndIEDest)
      cQuery += " WHERE id = "+NumberToSql(oFornecedor:nId)
   endif
   if !ExecuteSql(cQuery,@oQuery,{"Falha: alterar "},"sqlerro")
      return(.f.)
   endif
return(.t.)

  
//** Fim do Arquivo.
