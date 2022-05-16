
procedure main

use dados\nfe_nota
index on chave to nfe_nota
use dados\nfe_prod
index on chave to nfe_prod
use dados\produtos
zap
index on codbar to produtos
close all 

use dados\nfe_nota alias nfe_nota new
set index to nfe_nota
use dados\nfe_prod alias nfe_prod new
set index to nfe_prod
use dados\produtos alias produtos new
set index to produtos
nContador := 1
do while nfe_nota->(!eof())
	nfe_prod->(dbsetorder(1),dbseek(nfe_nota->chave))
	do while nfe_nota->chave == nfe_prod->chave .and. nfe_prod->(!eof())
		if !produtos->(dbsetorder(1),dbseek(nfe_prod->ean))
			produtos->(dbappend())
			produtos->codpro := strzero(nContador,6)
			produtos->codbar := nfe_prod->ean
			produtos->despro := nfe_prod->descri
			produtos->fanpro := left(nfe_prod->descri,50)
			produtos->pcoven := nfe_prod->unidade * 1.30
			produtos->pcocal := nfe_prod->unidade * 1.30
			produtos->embpro := "UND"
			produtos->qteemb := 1
			produtos->codncm := nfe_prod->ncm
			produtos->cest   := nfe_prod->cest
			produtos->ctrles := "S"
			produtos->origem := "0"
			produtos->ativo := "S"
			cLixo := alltrim(nfe_prod->cst)
			if len(cLixo) = 2
				if cLixo == "00"
					produtos->cst := "102"
					produtos->natsaident := "003"
				elseif cLixo == "10" .or. cLixo = "30" .or. cLixo = "60"
					produtos->cst := "500"
					produtos->natsaident := "006"
				elseif cLixo == "40"
					produtos->cst := "400"
					produtos->natsaident := "003"
				endif
			elseif len(cLixo) == 3
				if cLixo = "101"
					produtos->cst := "102"
					produtos->natsaident := "003"
				endif
			endif
			nContador += 1

		endif
		nfe_prod->(dbskip())
	enddo
	nfe_nota->(dbskip())
enddo
return
