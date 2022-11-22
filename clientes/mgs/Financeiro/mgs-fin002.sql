/*
######################################################################################################################################
GRAFICO: Saldo geral de caixas e Bancos
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Soma dos pagamentos completados, fechados , estornados e  anulados, de contas que compõem fluo de caixa para criar
o saldo acumulado das empresas. 
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
Valores tratatos para  conversão em operações de multimoeda
######################################################################################################################################
*/

select 
     sum( currencyconvert(p.payamt , p.c_currency_id, 297::numeric, p.datetrx::date::timestamp with time zone, p.c_conversiontype_id, p.ad_client_id, p.ad_org_id))
from 
     rv_payment p 
left join c_bankaccount ba on ba.c_bankaccount_id = p.c_bankaccount_id
    WHERE 
        p.docstatus IN  ('CO', 'CL','RE','VO')
    AND
        ba.cof_ComposesCashFlow = 'Y'  
    AND
        ba.isactive='Y'
    AND
      (case WHEN {{TipoP}}='01' then 
                        ba.ad_org_id IN (1000001) 
           WHEN {{TipoP}}='02' then 
                        ba.ad_org_id IN (5000000) 
           WHEN {{TipoP}}='03' then 
                        ba.ad_org_id IN (5000004) 
           WHEN {{TipoP}}='98' then 
                        ba.ad_org_id IN (5000000,1000001) 
           else 
                        ba.ad_org_id IN (5000004,5000000,1000001)
           end )     
