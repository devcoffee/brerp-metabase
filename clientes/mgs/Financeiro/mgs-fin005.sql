/*
######################################################################################################################################
GRAFICO: Contas a receber semanal- vencimento D-7 até D+7
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Lista os itens em aberto a recer, convertidos para moeda corrente(R$), vencidos até 7 dias e a vencer até 7 dias  e que componham 
fluxo de caixa,descartando os  memorando de créditos (valor >0).
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
Valores tratatos para  conversão em operações de multimoeda

######################################################################################################################################
*/

select
  sum(oi.cof_openamtconverted)
   
FROM
    rv_openitem oi
WHERE
    oi.issotrx = 'Y'
AND
    oi.cof_ComposesCashFlow = 'Y'
AND 
    oi.cof_openamtconverted >0
AND 
     (duedate > now()-7 and duedate < now() + 7 )

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
