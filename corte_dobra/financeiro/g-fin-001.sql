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
        bb.name as BancoName
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
  )
SELECT 
    p.BancoName as banco,
    p.orgname,
    p.conta,
    sum(case when p.Tipo='CC' then p.valor else 0 end) as  "Valor Conciliado",
    sum(case when p.tipo='NCC' then p.valor  else 0 end) as "Valor Não Conciliado",
    sum(p.valor) as "Saldo Projetado" 
    
FROM 
    pagamentos p
GROUP by
       p.orgname, banco,p.conta
ORDER BY
    p.orgname, banco,p.conta,"Saldo Projetado" asc