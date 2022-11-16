   select 
     sum(p.payamt) 
from 
     rv_payment p 
left join c_bankaccount ba on ba.c_bankaccount_id = p.c_bankaccount_id
    WHERE 
        p.docstatus IN  ('CO', 'CL','RE','VO')
    AND        ba.cof_ComposesCashFlow = 'Y'  
    AND
        ba.isactive='Y'
AND
     p.ad_client_id = (SELECT s.ad_client_id
                  from ad_session s 
                  where s.ad_session_id = {{LOGON}})     
