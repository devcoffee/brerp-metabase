/*
######################################################################################################################################
GRAFICO: Saldo geral de caixas e Bancos
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Soma os pagamentos completados, fechados , estornados e  anulados, de contas que compõem fluo de caixa para criar
o saldo acumulado das empresas. 
O Filtro ocorre apenas pela empresa, assim os valore refletem a consolidação de todas as Organizações.
######################################################################################################################################
*/
select 
     sum(p.payamt) 
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
     p.ad_client_id = (SELECT s.ad_client_id
                  from ad_session s 
                  where s.ad_session_id = {{LOGON}})     
