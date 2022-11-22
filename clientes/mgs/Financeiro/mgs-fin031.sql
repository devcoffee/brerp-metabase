/*
######################################################################################################################################
GRAFICO: Clientes com Limite de Crédito Acima de 70%
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Lista Parceiros de negócio classificados como cliente, que NÂO estejam como sem verificação de crédito e que o limite 
de crédito utilizado é maior que 80% do total concedido
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
######################################################################################################################################
*/

select
    bp.name as "Parceiro",
    bp.totalopenbalance as "Saldo Aberto Atual",
    bp.SO_CreditLimit as "Limite Crédito Atual",
    (   select
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
            oi.daysdue >1
        and
            oi.c_bpartner_id=bp.c_bpartner_id
    ) as "Valor Atrasado >= 2"   
FROM
    c_bpartner bp
where 
    bp.TotalOpenBalance > (bp.so_creditlimit* 0.7) 
and 
    bp.TotalOpenBalance>=0 
and 
    bp.SOCreditStatus<>'X' 
AND
    IsCustomer='Y'
AND
    (case WHEN {{TipoP}}='01' then 
                        bp.ad_org_id IN (1000001,0) 
           WHEN {{TipoP}}='02' then 
                        bp.ad_org_id IN (5000000,0) 
           WHEN {{TipoP}}='03' then 
                        bp.ad_org_id IN (5000004,0) 
           WHEN {{TipoP}}='98' then 
                        bp.ad_org_id IN (5000000,1000001,0) 
           else 
                        bp.ad_org_id IN (5000004,5000000,1000001,0)
           end )     
ORDER BY
   bp.TotalOpenBalance desc,
   bp.so_creditlimit