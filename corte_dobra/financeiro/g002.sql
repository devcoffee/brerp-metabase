/*
######################################################################################################################################
GRAFICO: Saldo geral de caixas e Bancos
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Soma dos pagamentos completados, fechados , estornados e  anulados, de contas que compõem fluo de caixa para criar
o saldo acumulado das empresas. 
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.Valores tratatos para  conversão em operações de multimoeda

######################################################################################################################################
*/


select 
     sum( currencyconvert(p.payamt , p.c_currency_id, 297::numeric, p.datetrx::date::timestamp with time zone, p.c_conversiontype_id, p.ad_client_id, p.ad_org_id))
from 
     rv_payment p 
left join 
    c_bankaccount ba on ba.c_bankaccount_id = p.c_bankaccount_id
   --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
left join
        ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}} 
WHERE 
        p.docstatus IN  ('CO', 'CL','RE','VO')
    and
        ba.cof_ComposesCashFlow = 'Y'  
    and
        ba.isactive='Y'
    and 
        ba.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
    and 
        s.processed = 'N' -- valida que sessão esta ativa
    and
        ba.ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 