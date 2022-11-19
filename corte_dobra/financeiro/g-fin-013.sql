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
WHERE
    pay.docstatus in ('CO', 'CL') 
AND 
    pay.isreceipt = 'Y' 
AND 
    paymentavailable(pay.c_payment_id) > 0
AND
     pay.ad_client_id = (SELECT s.ad_client_id
                  from ad_session s 
                  where s.ad_session_id = {{LOGON}})        
