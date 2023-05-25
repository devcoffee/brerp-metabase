/*
######################################################################################################################################
GRAFICO:Recebimentos não alocados
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Lista  e soma os saldos dos pagamentos (AR) com saldos a alocar, completados e fechados.
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
Valores tratatos para  conversão em operações de multimoeda.
######################################################################################################################################
*/

select
  sum(paymentavailable(pay.c_payment_id))
FROM
    C_Payment pay
LEFT JOIN   --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}} 
WHERE
    pay.docstatus in ('CO', 'CL') 
AND 
    pay.isreceipt = 'Y' 
AND 
    paymentavailable(pay.c_payment_id) > 0
and 
    s.processed = 'N' -- valida que sessão esta ativa
and 
    pay.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
and
    pay.ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 
