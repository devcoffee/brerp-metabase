/*
######################################################################################################################################
GRAFICO: Clientes com Limite de Crédito Acima de 80%
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: 
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
    bp.TotalOpenBalance > (bp.so_creditlimit* 0.8) 
and 
    bp.TotalOpenBalance>0 
and 
    bp.SOCreditStatus<>'X' 
AND
    IsCustomer='Y'
AND
    bp.ad_client_id = (SELECT s.ad_client_id
                  from ad_session s 
                  where s.ad_session_id = {{LOGON}})        
ORDER BY
   bp.TotalOpenBalance desc,
   bp.so_creditlimit