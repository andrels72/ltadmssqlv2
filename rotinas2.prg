/*************************************************************************
 * Sistema......: Administrativo
 * Versao.......: 2.00
 * Identificacao: Modulo de Rotinas 2
 * Prefixo......:
 * Programa.....: ROTINAS.PRG
 * Autor........: Andre Lucas Souza
 * Data.........: 16 DE NOVEMBRO DE 2002
 * Copyright (C): LUCAS Tecnologia  - 2002
*/
#include "lucas.CH"       // Inclusao do Arquivo Header Padrao
#include "inkey.ch"
#include "setcurs.ch"

Function Fim_Imp(nPapel)
   Private Spool,cLixo55,nCursor := setcursor()

   cLixo55 := Arq_Sen+".prn"
   if nPapel == NIL
      nPapel := 80
   end
   if left(T_IPorta,3) == "LPT"
      Spool := alltrim(T_IPorta)
   elseif !(left(T_IPorta,3) == "USB")
      Spoll := Alltrim(T_IPorta)+[\Spool.PRN]
   end
   if !(left(T_IPorta,3) == "USB")
      copy file c:\tmp\&cLixo55. to &Spool
   else
      if nPapel == 80
         run nodosimp c:\tmp\&cLixo55. 80
      elseif nPapel == 96
         run nodosimp c:\tmp\&cLixo55. 96
      elseif nPapel == 120
         run nodosimp c:\tmp\&cLixo55. 120
      elseif nPapel == 140
         run nodosimp c:\tmp\&cLixo55. 140
      elseif nPapel == 160
         run nodosimp c:\tmp\&cLixo55. 160
      end
   end
   setcursor(nCursor)
   Release NFile, Spool
   Return( .t. )
// ****************************************************************************
Function Ini_Imp()
   Public T_IImp, T_INomImp, T_IPorta, T_VLptNot,T_VLptPed

   T_VLptNot := Space(20)
   T_VLptPed := space(20)
   T_IImp    := [01]
   T_INomImp := [EPSON]
   T_IPorta  := [LPT1]
   Cria_IVar()
   Return Nil
// ****************************************************************************
Function Ini_Var()    // ** Variaveis de Parametros
   Public C_VDados ,C_VConta ,C_VChvPro,C_VLimDsc,C_VCaixa ,C_VCaiTef
   public C_VFixImp,C_VSerNot,C_VTempo ,C_VLojPdr,C_VSaiLoj,C_VGerDup
   public C_VPerSld,C_VTestIm,C_VTamPag,C_VAltPco,C_VAtrCli,C_VNumVia
   public C_VValCof,C_VValPis,C_VQueNot,C_VAtuPcoV, C_VICMSCa 

   ** Diret¢rios
   C_VDados := [\Estoque\]
   C_VConta := [\Contas\]
   C_VCaixa := [\Caixa\]
   ** Diversos
   C_VChvPro := 1     // ** Chave de Busca p/ Produtos
   C_VSerNot := 1
   C_VLimDsc := 0.00  // ** Limite M ximo de Desconto na Venda
   C_VCaiTef := [N]
   C_VFixImp := [N]   // ** Escolher Impressora na Hora da ImpressÆo
   C_VAtuPcoV := "N"  // ** Atualiza Preco de Venda na Entrada
   C_VTestIm := [S]
   C_VTempo  := 1
   C_VLojPdr := "01"
   C_VSailoj := [N]
   C_VGerDup := [S]
   C_VPerSld := [S]
   C_VTamPag := 2
   C_VAltPco := [S]
   C_VAtrCli := [01]
   C_VNumVia := [01]
   C_VValPis := 1.65  // ** PIS
   C_VValCof := 3.00  // ** COFINS
   C_VQueNot := [S]   // ** Permitir quebra de Nota Fiscal
   Return( Nil )
// ****************************************************************************
Function Ini_Eti()    // ** Variaveis de Etiqueta
***  Etiqueta.DBF
   Public C_LinIni, C_NumLin, C_NumCol, C_MgEsq1, C_MgEsq2, C_MgEsq3
   C_LinIni := 0
   C_NumLin := 3
   C_NumCol := 1
   C_MgEsq1 := 0
   C_MgEsq2 := 43
   C_MgEsq3 := 86
   Return( Nil )
// ****************************************************************************
Function Ini_Not()    // ** Vari veis Nota Fiscal S‚rie énica
   Public C_NotArq  := [PADRAO], ;
       C_Qua_Ser := 10, ;
       C_Qua_Not := 10
   Return( Nil )
// ****************************************************************************
function cabec(nPapel,cEmpresa,cRelatorio,lCenter)
	local nI,cPagina,cData,nColuna

   if left(T_IPorta,3) == "LPT"
      cPagina := T_ICondI+"Pagina : "+strzero(nPagina,04,0)+T_ICondF
      cData   := T_ICondI+"Emissao : "+dtoc(date())+T_ICondF
   elseif left(T_IPorta,3) == "USB"
      cPagina := " Pagina: "+strzero(nPagina,04)
      cData   := "Emissao: "+dtoc(date())
   end
   lCenter := iif(lCenter == NIL,.t.,lCenter)
	if valtype( cEmpresa ) == "A"
      @ Prow()+1,00 say left(cEmpresa[1],55)
	else
	   @ prow()+1,00 say left(cEmpresa,55)
	end
	@ prow() ,(nPapel-len(cData))-4 say cData   //60 say "Emissao: "+dtoc(date())
	if valtype(cRelatorio) == "A"
	   for nI := 1 to len(cRelatorio)
         if nI == 1
			   @ prow()+1,00 say left(cRelatorio[nI],55)
            @ prow()  ,(nPapel-len(cPagina))-4 say cPagina         //61 say "Pagina: "+strzero(nPagina,4)
         else
			   @ prow()+1,00 say left(cRelatorio[nI],55)
         end
		next
	else
      @ prow()+1,00 say left(cRelatorio,55)
//      @ prow()  ,61 say "Pagina: "+strzero(nPagina,4)
      @ prow()  ,(nPapel-len(cPagina))-4 say cPagina         //61 say "Pagina: "+strzero(nPagina,4)
   end
	return( NIL )
// ****************************************************************************
// Testa a Porta de ImpressÆo
// Utiliza a Biblioteca Fast.lib funcao GetPrinter()
//
Function Testa_Lpt(Porta)

   If Substr(Porta,1,4)=[LPT1] .and. C_VTestIm=[S]
      if !IsPrinter()
         Do While .t.
            If Aviso_1( 15,, 20,, [Aten‡„o!], [Impressora n„o est  conectada!], { [  ^Repetir  ], [ ^Abandonar ] }, 1, .t., .t. ) = 1
               If IsPrinter()
                  Exit
               EndIf
            Else
               Return( .f. )
            EndIf
         EndDo
      EndIf
   EndIf
   Return(.t.)


function cabecUSB(nPapel,cEmpresa,cRelatorio,lCenter)
	local nContador,cPagina,cData,nColuna,nLixo := 1

   cPagina := "Pagina  : "+strzero(nPagina,10,0)
   cData   := "Emissao : "+dtoc(date())
   lCenter := iif(lCenter == NIL,.t.,lCenter)

	if valtype( cEmpresa ) == "A"
		for nContador := 1 to len( cEmpresa )
         ImpLinha(oPrinter:prow()+1,00,cEmpresa[nContador])
		next
	else
		ImpLinha(oPrinter:prow()+1,00,cEmpresa)
	end
	if valtype( cRelatorio ) == "A"
		for nContador := 1 to len( cRelatorio )
         if nContador == 1
		      ImpLinha(oPrinter:prow()+1,00,cRelatorio[ nContador ])
            ImpLinha(oPrinter:prow()  ,nPapel-20,cData)
         end
         if nContador == 2
		      ImpLinha(oPrinter:prow()+1,00,cRelatorio[ nContador ])
            ImpLinha(oPrinter:prow()  ,nPapel-20,cPagina)
         end
         if nContador > 2
		      ImpLinha(oPrinter:prow()+1,00,cRelatorio[ nContador ])
         end
		next
   else
      ImpLinha(oPrinter:prow()+1,00,cRelatorio)
      ImpLinha(oPrinter:prow()  ,nPapel-20,cData)
      ImpLinha(oPrinter:prow()+1,nPapel-20,cPagina)
	end
	return( NIL )
