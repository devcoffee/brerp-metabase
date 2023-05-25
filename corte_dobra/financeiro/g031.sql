/*
######################################################################################################################################
GRAFICO: Clientes com Limite de Crédito Acima de 80%
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
LEFT JOIN   --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}} 
where 
    bp.TotalOpenBalance > (bp.so_creditlimit* 0.8) 
and 
    bp.TotalOpenBalance>=0 
and 
    bp.SOCreditStatus<>'X' 
AND
    IsCustomer='Y'
AND
    s.processed = 'N' -- valida que sessão esta ativa
and 
    bp.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
and
    bp.ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 
  
ORDER BY
   bp.TotalOpenBalance desc,
   bp.so_creditlimit