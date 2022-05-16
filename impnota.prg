
procedure main

use dados\compra
zap
index on chavenfe to compra

use dados\cmp_ite
zap
index on chavenfe to cmp_ite

use dados\nfe_nota 
index on chave to nfe_nota

use dados\nfe_prod 
index on chave to nfe_prod

use dados\fornece
index on cgcfor to fornece

use dados\produtos 
index on codbar to produtos

close all 
//---------------------------
use dados\compra alias compra new
set index to compra

use dados\cmp_ite alias cmp_ite new
set index to cmp_ite

use dados\nfe_nota alias nfe_nota new
set index to nfe_nota

use dados\nfe_prod alias nfe_prod new
set index to nfe_prod

use dados\fornece alias fornece new
set index to fornece

use dados\produtos alias produtos new
set index to produtos

nChave := 1
do while nfe_nota->(!eof())

	if fornece->(dbsetorder(1),dbseek(nfe_nota->cnpj))
		compra->(dbAppend())
		compra->chave := strzero(nChave,6)
		compra->codfor := fornece->codfor
		compra->numnot := strzero(val(nfe_nota->numero),9)
		compra->modelo := nfe_nota->modelo
		compra->serie := nfe_nota->serie
		compra->dtaent := nfe_nota->saida    // data de entrada
		compra->dtaemi := nfe_nota->emissao // data de emissão

		compra->sn := .f.
		compra->totalnota := nfe_nota->vr_cont


		if nfe_prod->(dbsetorder(1),dbseek(nfe_nota->chave))
			do while nfe_prod->chave == nfe_nota->chave .and. nfe_prod->(!eof()) 
				produtos->(dbsetorder(1),dbseek(nfe_prod->ean))
				cmp_ite->(dbappend())
				cmp_ite->chave := strzero(nChave,6)
				cmp_ite->dtaent := nfe_nota->saida   // data de entrada
				// cmp_ite->prodfor  
				// cmp_ite->coditem
				cmp_ite->codpro := produtos->codpro
				//cmp_ite->cst := 
				//cmp_ite->cfop
				cmp_ite->quantidade := nfe_prod->qtd 
				//cmp_ite->codlab
				//cmp_ite->lote
				//cmp_ite->fabricacao // data
				//cmp_ite->validade 
				//cmp_ite->frete 
				//cmp_ite->seguro
				//cmp_ite->desconto
				//cmp_ite->outros 
				cmp_ite->custo := nfe_prod->unidade
				nfe_prod->(dbskip())
			enddo
		endif

		nChave += 1
	endif
	nfe_nota->(dbskip())
enddo
close all 
return