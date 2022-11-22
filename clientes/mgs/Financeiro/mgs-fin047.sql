SELECT 
    bp.name,
    sum( currencyconvert(pay.payamt , pay.c_currency_id, 297::numeric, pay.datetrx::date::timestamp with time zone, pay.c_conversiontype_id, pay.ad_client_id, pay.ad_org_id)) as "Pagamentos Dia"

FROM
    C_Payment pay
LEFT JOIN
    c_bpartner bp ON bp.c_bpartner_id = pay.c_bpartner_id
LEFT JOIN C_DocType tdd ON
    tdd.c_doctype_id = pay.c_doctype_id
WHERE
    pay.docstatus in ('CO', 'CL') 
AND 
    pay.isreceipt  = 'N' 
AND
    trunc(pay.datetrx)=trunc(now())
AND 
    tdd.cof_DocTypeBankTransfer='N'
 
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
GROUP BY
    bp.name
ORDER BY
    "Pagamentos Dia" desc
