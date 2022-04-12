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
    sum(CASE 
        WHEN tipo = 'Não Conciliado'  THEN
            p.valor
        ELSE
            0
    END) as valorNaoConciliado,
    sum(CASE 
        WHEN tipo = 'Conciliado'  THEN
            p.valor
        ELSE
            0
    END) as valorConciliado,
    sum(p.valor) as valorProjetado
FROM 
    pagamentos p
GROUP by
    p.conta
