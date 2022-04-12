SELECT
    ss.Name as estagio,
    count(*) as quantidade_total,
    sum(o.OpportunityAmt) as valor_oportunidades
FROM
    C_Opportunity o
LEFT JOIN
    C_SalesStage ss ON ss.C_SalesStage_ID = o.C_SalesStage_ID
WHERE
    o.isclosed = 'N'
GROUP BY
    estagio
ORDER BY
    valor_oportunidades DESC
