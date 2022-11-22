/*
######################################################################################################################################
GRAFICO: Compras e obrigações lançadas no mes corrente
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: lista lançamentos de contas a pagar  realizados no mês corrente, descartando  memorandos de créditos, considerando documentos 
completados e fechados e apenas que exibem em relatórios.
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
Valores tratatos para  conversão em operações de multimoeda
######################################################################################################################################
*/

SELECT
    tdd.name,
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
    i.dateinvoiced>= date_trunc('month',current_date) 
and 
    i.issotrx = 'N'
and 
    i.docstatus IN ('CO','CL')
and 
    i.cof_ExibirEmRelatorios = 'Y'
AND
   tdd.DocBaseType IN ('API' ) -- filtra tipo de documento Normal e devolução

AND
    (case WHEN {{TipoP}}='01' then 
                        i.ad_org_id IN (1000001) 
           WHEN {{TipoP}}='02' then 
                        i.ad_org_id IN (5000000) 
           WHEN {{TipoP}}='03' then 
                        i.ad_org_id IN (5000004) 
           WHEN {{TipoP}}='98' then 
                        i.ad_org_id IN (5000000,1000001) 
           else 
                        i.ad_org_id IN (5000004,5000000,1000001)
           end )     
group by 
  tdd.name
order by 
  valor_total desc
    

