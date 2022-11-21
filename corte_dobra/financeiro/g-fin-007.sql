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
    bp.name,
    sum(il.cof_linenetamtconverted*i.multiplier) AS valor_total
FROM 
    rv_c_invoice i
LEFT JOIN
    c_bpartner bp ON bp.c_bpartner_id = i.c_bpartner_id
LEFT JOIN C_DocType tdd ON
   (tdd.c_doctype_id = i.c_doctypetarget_id)
LEFT JOIN
    rv_c_invoiceline il ON i.c_invoice_id = il.c_invoice_id
where
    il.isdescription = 'N' 
and
    trunc(i.dateinvoiced) = trunc(now())
and 
    i.issotrx = 'N'
and 
    i.docstatus IN ('CO','CL')
and 
    i.cof_ExibirEmRelatorios = 'Y'
AND
   tdd.DocBaseType IN ('API' ) -- filtra tipo de documento Normal e devolução
AND
   i.ad_client_id = (SELECT s.ad_client_id
                  from ad_session s 
                  where s.ad_session_id = {{LOGON}})
group by 
  bp.name
order by 
  valor_total desc
    
