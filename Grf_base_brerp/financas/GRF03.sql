WITH pagamentos as (
    SELECT 
        CASE 
            WHEN p.isReceipt = 'Y' THEN 
                p.payamt 
            ELSE 
                p.payamt * -1 
        END as Valor,
        CASE 
            WHEN p.isreconciled = 'N'  THEN
                'Não Conciliado'
            ELSE
                'Conciliado'
        END as Tipo,
        ba.name as Conta
    FROM 
        C_Payment p 
    LEFT JOIN
        C_BankAccount ba ON ba.C_BankAccount_ID = p.C_BankAccount_ID
    WHERE 
        p.docstatus IN  ('CO', 'CL')
    AND
        ba.cof_ComposesCashFlow = 'Y'
)
SELECT 
    p.conta,
    sum(p.valor) as valorProjetado
FROM 
    pagamentos p
GROUP by
    p.conta
ORDER BY
    valorProjetado
