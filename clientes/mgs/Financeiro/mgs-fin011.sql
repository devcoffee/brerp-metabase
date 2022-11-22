*
######################################################################################################################################
GRAFICO:Contas a pagar em aberto (Risco)
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS::Efetua a somatória de todos os  itens em aberto AP, considerando os registros que consideream compõem fluxo de caixa 
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
Valores tratatos para  conversão em operações de multimoeda
######################################################################################################################################
*/

select
  sum(oi.cof_openamtconverted)
FROM
    rv_openitem oi
WHERE
    oi.issotrx = 'N'
AND
    oi.cof_ComposesCashFlow = 'Y'
AND 
         (case WHEN {{TipoP}}='01' then 
                        oi.ad_org_id IN (1000001) 
           WHEN {{TipoP}}='02' then 
                        oi.ad_org_id IN (5000000) 
           WHEN {{TipoP}}='03' then 
                        oi.ad_org_id IN (5000004) 
           WHEN {{TipoP}}='98' then 
                        oi.ad_org_id IN (5000000,1000001) 
           else 
                        oi.ad_org_id IN (5000004,5000000,1000001)
        end )     