/*
######################################################################################################################################
GRAFICO: Compras e obrigações lançada no dia Corrente
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: lista lançamentos de contas a pagar  realizados no dia, descartando  memorandos de créditos, considerando documentos 
completados e fechados e apenas que exibem em relatórios.
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
Valores tratatos para  conversão em operações de multimoeda
######################################################################################################################################
*/

SELECT
    TDD.name,
    sum(il.cof_linenetamtconverted*i.multiplier) AS valor_total
FROM 
    rv_c_invoice i
LEFT JOIN C_DocType tdd ON
    (tdd.c_doctype_id = i.c_doctypetarget_id)
LEFT JOIN
    rv_c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
where
    il.isdescription = 'N' 
and
    trunc(i.dateinvoiced) =trunc(now())
and 
    i.issotrx = 'N'
and 
    i.docstatus IN ('CO','CL') -- completado e fechado
and 
    i.cof_ExibirEmRelatorios = 'Y' -- exibe em relatórios
AND
   tdd.DocBaseType IN ('API' ) -- filtra tipo de documento Normal e devolução
AND
   i.ad_client_id = (SELECT s.ad_client_id
                  from ad_session s 
                  where s.ad_session_id = {{LOGON}})
group by 
  tdd.name
order by 
  valor_total desc
    
