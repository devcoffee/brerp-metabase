/*
######################################################################################################################################
GRAFICO: Saldos Bancários por tipo de conta
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Soma dos pagamentos completados, fechados , estornados e  anulados, classificando o saldo conciliado, não conciliado e 
projetado(conciliado + não conciliado)  agrupando por conta corrente, organização e classificação da conta bancária (Dinheiro, cheque, conta corrente e poupança)
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.Valores tratatos para  conversão em operações de multimoeda
######################################################################################################################################
*/
WITH pagamentos as (
    SELECT 
        CASE 
            WHEN p.isReceipt = 'Y' THEN 
                 currencyconvert(p.payamt , p.c_currency_id, 297::numeric, p.datetrx::date::timestamp with time zone, p.c_conversiontype_id, p.ad_client_id, p.ad_org_id)
            ELSE 
                 currencyconvert((  p.payamt * -1 ), p.c_currency_id, 297::numeric, p.datetrx::date::timestamp with time zone, p.c_conversiontype_id, p.ad_client_id, p.ad_org_id)
        END as Valor,
        CASE 
            WHEN p.isreconciled = 'N'  THEN
                'NCC'
            ELSE
                'CC'
        END as Tipo,
        ba.name as Conta,
        org.name as orgname,
        bb.name as BancoName,
        (select t.Name from ad_ref_list_trl t left join ad_ref_list l on t.ad_ref_list_id = l.ad_ref_list_id where l.AD_Reference_ID='216' and l.value=ba.BankAccountType and t.ad_language = 'pt_BR') as tipoconta
    FROM 
        C_Payment p 
    LEFT JOIN
        C_BankAccount ba ON ba.C_BankAccount_ID = p.C_BankAccount_ID
    LEFT JOIN
       C_Bank bb ON bb.C_Bank_ID=ba.C_Bank_ID
        
    LEFT JOIN 
        ad_org org  on org.ad_org_id=ba.ad_org_id
    WHERE 
        p.docstatus IN  ('CO', 'CL','RE','VO')
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
)

SELECT 
    
    sum(case when p.Tipo='CC' then p.valor else 0 end) as  "Valor Conciliado",
    sum(case when p.tipo='NCC' then p.valor  else 0 end) as "Valor Não Conciliado",
    sum(p.valor) as "Saldo Projetado" ,
    p.tipoconta
FROM 
    pagamentos p
GROUP by
      p.tipoconta
ORDER BY
   "Saldo Projetado" asc