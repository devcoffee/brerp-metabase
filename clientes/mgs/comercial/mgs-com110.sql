SELECT
    --bp.name,
    --pp.name,
    --u.name as representante,
    rg.name as regiao,
    sum(cust.cof_total) as valor_venda_mercadoria,
    --valor de venda de mercadoria
    sum(cof_impostos) as valor_impostos_inclusos,
    --impostos inclusos (icms, pis , cofins, difal) 
    sum(cof_custototal) as custo_mercadoria,
    -- custo do produto
    --sum(cof_margem_c_impostos) as margem_bruta_contribuicao, --Valor de venda sem impostos  Não inclusos (ipi,st) deduzido o custo 
    sum(cof_margem_s_impostos) as margem_liquida_contribuicao,
    -- margem de contribuição - Valor de venda mercadoria dezudidos os valores de impostos,
    sum(cof_margem_s_impostos) / sum(cust.cof_total) as perc_margem_liquida --max (mt.Amount) as Meta,
    --sum(cust.cof_total)/max(mt.amount) as Percmeta
FROM
    cof_rv_faturamentoprodutomargem cust
    left join m_product pp on pp.m_product_id = cust.m_product_id
    left join c_bpartner bp on bp.c_bpartner_id = cust.c_bpartner_id
    left join C_AcctSchema esq on esq.C_AcctSchema_ID = cust.C_AcctSchema_ID
    left JOIN c_invoice ci on ci.c_invoice_id = cust.c_invoice_id
    LEFT JOIN ad_user u ON u.ad_user_id = ci.SalesRep_ID
    LEFT JOIN COF_MetaRepresentante mt on mt.C_BPartner_ID = u.C_BPartner_ID
    left join C_BPartner_Location cbl on cbl.C_BPartner_Location_id = ci.C_BPartner_Location_id
    left join C_SalesRegion rg on rg.C_SalesRegion_id = cbl.C_SalesRegion_ID
    left join M_CostElement el on el.M_CostElement_iD = cust.M_CostElement_iD
WHERE
    --cust.ad_client_id=5000012
    --and
    el.CostingMethod = 'I'
    and cust.dateinvoiced >= coalesce(
        [[ {{dtfat1}},]]date_trunc('month',current_date)) 
[[ and cust.dateinvoiced  <=  {{datfat2}} ]]

and 
    ci.issotrx = 'Y'
and 
   cust.docstatus IN ('CO','CL')
and 
   cust.cof_ExibirEmRelatorios = 'Y'
and 
    cust.ad_org_id=1000001
and 
    cust.docbasetype in ('ARI')
and 
    cust.m_product_id > 0 
and 
    (mt.COF_TipoMetaRepresentante_ID=1000000 or mt.COF_TipoMetaRepresentante_Id is null )
--and
 -- cust.documentno='143198'
group by
    regiao
order by 
  perc_margem_liquida desc