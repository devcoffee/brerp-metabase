/*
######################################################################################################################################
GRAFICO:Pagamentos não alocados
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Lista  e soma os saldos dos pagamentos (AP) com saldos a alocar, completados e fechados .
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
    pay.isreceipt = 'N' 
AND 
    paymentavailable(pay.c_payment_id) < 0
AND 
         (case WHEN {{TipoP}}='01' then 
                        pay.ad_org_id IN (1000001) 
           WHEN {{TipoP}}='02' then 
                        pay.ad_org_id IN (5000000) 
           WHEN {{TipoP}}='03' then 
                        pay.ad_org_id IN (5000004) 
           WHEN {{TipoP}}='98' then 
                        pay.ad_org_id IN (5000000,1000001) 
           else 
                        pay.ad_org_id IN (5000004,5000000,1000001)
        end )     