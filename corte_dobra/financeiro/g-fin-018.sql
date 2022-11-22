/*
######################################################################################################################################
GRAFICO:CDevoluções e Créditos  Faturamento dia corrente
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Lista e agrupa por tipo de documento as devoluções AP lançadas no dia corrrente, para documentos completados e fechados,
que devem ser exibidos em relatório , independente se possuem produtos ou finalidades na linhas.
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.Os valores estão
tratados para operações  multimoedas.
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
    i.docstatus IN ('CO','CL')

and 
    i.cof_ExibirEmRelatorios = 'Y'
AND
   tdd.DocBaseType IN ('APC' ) -- filtra tipo de documento Normal e devolução
AND
   i.ad_client_id = (SELECT s.ad_client_id
                  from ad_session s 
                  where s.ad_session_id = {{LOGON}})
group by 
  tdd.name
order by 
  valor_total desc
    
