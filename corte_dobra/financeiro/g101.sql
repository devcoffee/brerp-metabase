/*
######################################################################################################################################
GRAFICO: Contas a pagar semanal em atraso D-7 até D+7
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Lista os itens em aberto a pagar, convertidos para moeda corrente(R$), vencidos até 7 dias e a vencer até 7 dias  e que 
componham fluxo de caixa, descartando os  memorando de créditos (valor >0).
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.
Valores tratatos para  conversão em operações de multimoeda
######################################################################################################################################
*/

WITH fluxo as (

select
	1 as idnu,
	--ad_client_id,
	--ad_org_id,
	--documento, 
	trunc(data) as data,
--	sum(coalesce(valor,0)) as valor,
--	IsSOTrx,
--	ordem,
   SUM(CASE WHEN temp.documento='SALDO' THEN temp.valor ELSE 0 end) AS SLD,
   SUM(CASE WHEN temp.documento='PAGAR' THEN temp.valor ELSE 0 end) AS PGTO,
   SUM(CASE WHEN temp.documento='RECEBER' THEN temp.valor ELSE 0 end) AS RECEBER,
   SUM(CASE WHEN temp.documento='PGTOPLANO' THEN temp.valor ELSE 0 end) AS PGTOPLANO,
   SUM(CASE WHEN temp.documento='RECPLANOCAIXA' THEN temp.valor ELSE 0 end) RECPLANO,
   SUM(CASE WHEN temp.documento='RECDETCREDITO' THEN temp.valor ELSE 0 end) AS RECCREDTRAN,
   SUM(CASE WHEN temp.documento='PGTOCHEQUE' THEN temp.valor ELSE 0 end) AS PGTOCHEQ,
   SUM(temp.valor) as TTdia


	
 FROM
(
	SELECT
		'01' as ordem,
		'SALDO'  /*|| b.Name || ' - ' || ba.accountno*/ as documento,
		ba.ad_client_id,
		ba.ad_org_id,
		trunc(now()) as data,
		round(currencyConvert(ba.currentbalance,ba.C_Currency_ID,  297::numeric , trunc(now()) ,114,ba.AD_Client_ID,ba.AD_Org_ID),2)  + (

		CASE WHEN   
		 /*Busca saldo não conciliado*/ 
		  'Y'= 'Y' THEN  COALESCE((SELECT SUM(COALESCE(currencyconvert(COALESCE((CASE WHEN p.isReceipt = 'Y' THEN p.payamt ELSE p.payamt * -1 END), 0), p.C_Currency_ID,   297::numeric,  p.datetrx, p.C_ConversionType_ID, p.AD_Client_ID, p.AD_Org_ID),0)) 
								FROM C_Payment p 
								LEFT JOIN C_DocType  dt ON  dt.C_DocType_ID = p.C_DocType_ID
								WHERE p.isreconciled = 'N' 
										AND p.docstatus IN  ('CO', 'CL', 'RE') 
										AND (p.TenderType NOT IN ('K', 'C') OR 
										 (p.tendertype = 'C' AND (p.cof_CreditDate <=  trunc(now())  OR p.cof_CreditDate IS NULL )) OR (dt.DocBaseType = 'ARR' AND p.TenderType = 'K'))
										AND p.C_BankAccount_ID = ba.C_BankAccount_ID),0)
		 	ELSE 0 END
		) as valor,
		NULL AS IsSOTRX
	FROM
		c_bankaccount ba
	LEFT JOIN c_bank b ON (b.c_bank_id = ba.c_bank_id)
	WHERE ba.cof_ComposesCashFlow	 = 'Y'
UNION
	SELECT
		'04' as ordem,
		'PAGAR' as documento,
		oi.ad_client_id,
		oi.ad_org_id,
		oi.duedate as data,
		--considera projeção passada
		CASE WHEN ('N'= 'N' AND oi.duedate < trunc(now()))  THEN
		    0
		ELSE
			sum(currencyConvert(oi.openamt,oi.C_Currency_ID,  297::numeric,trunc(now()) ,oi.C_ConversionType_ID,oi.AD_Client_ID,oi.AD_Org_ID) * -1)
		END as valor,
		oi.isSOTrx
	FROM
		rv_openitem oi
	LEFT JOIN
		cof_titulo t ON (t.COF_Titulo_ID = oi.COF_Titulo_ID)
	WHERE
		oi.issotrx = 'N'
	AND
		(t.cof_BillFoldType IS NULL OR t.cof_BillFoldType = 'CS')
	AND
		(oi.cof_ComposesCashFlow = 'Y')
	AND
		(oi.cof_ExibirEmRelatorios = 'Y' OR  (oi.cof_ExibirEmRelatorios is null))
	GROUP BY ordem, documento, oi.ad_client_id,oi.ad_org_id, oi.duedate, oi.isSOTrx
UNION
	SELECT
	    '05' as ordem,
	    'RECEBER' as documento,
	    oi.ad_client_id,
	    oi.ad_org_id,
	   CASE WHEN t_integer is not null THEN 
	    	oi.duedate + interval '1 day' * (bai.t_integer + cu.COF_DiasADeslocar) 
		ELSE
			oi.duedate  + interval '1 day' *  cu.COF_DiasADeslocar
		END,
	CASE WHEN ( 'N'='N' AND oi.duedate < trunc(Now())) THEN
	    0
	ELSE
	    SUM(currencyConvert(oi.openamt,oi.C_Currency_ID,  297::numeric ,  trunc(now()) ,oi.C_ConversionType_ID,oi.AD_Client_ID,oi.AD_Org_ID))
	END,
	oi.isSOTrx
	FROM
	    rv_openitem oi
	LEFT JOIN
	    cof_titulo t ON (t.COF_Titulo_ID = oi.COF_Titulo_ID) AND t.IsValid = 'Y'
	LEFT join
	    COF_C_BankIntegration bai on (bai.COF_C_BankIntegration_ID = t.COF_C_BankIntegration_ID)
	LEFT JOIN 
		COF_C_Custody cu ON (oi.COF_C_Custody_ID = cu.COF_C_Custody_ID)
	WHERE
	    oi.issotrx = 'Y'
	AND
	    (t.cof_BillFoldType IS NULL OR t.cof_BillFoldType = 'CS')
	AND
	    (oi.cof_ComposesCashFlow = 'Y')
	AND
	    (oi.cof_ExibirEmRelatorios ='Y' OR  (oi.cof_ExibirEmRelatorios is null))
	GROUP BY ordem, documento, oi.ad_client_id,oi.ad_org_id, oi.duedate, oi.isSOTrx, bai.t_integer, cu.cof_diasadeslocar
/*UNION
	SELECT
		'03' as ordem,
		'PAGAMENTO',
		pv.ad_client_id,
		pv.ad_org_id,
		CASE WHEN 'N' = 'N' THEN
			trunc(now())
		ELSE
			Date('01/01/1970')
		END,
		CASE WHEN ('N' = 'N') THEN
			0
		ELSE
			coalesce(currencyConvert(paymentavailable(pv.c_payment_id),pv.C_Currency_ID,  297::numeric ,pv.datetrx,pv.C_ConversionType_ID,pv.AD_Client_ID,pv.AD_Org_ID),0)*-1
		END,
		pv.IsReceipt
	FROM
		c_payment_v pv
	WHERE
		pv.DocStatus IN ('CO','CL') AND pv.IsAllocated='N' AND pv.isReceipt = 'N'
UNION
	SELECT
		'02' as ordem,
		'RECEBIMENTO',
		pv.ad_client_id,
		pv.ad_org_id,
		CASE WHEN 'N' = 'N' THEN
			trunc(now())
		ELSE
			Date('01/01/1970')
		END,
		CASE WHEN ('N' = 'N') THEN
			0
		ELSE
			coalesce(currencyConvert(paymentavailable(pv.c_payment_id),pv.C_Currency_ID,  297::numeric ,pv.datetrx,pv.C_ConversionType_ID,pv.AD_Client_ID,pv.AD_Org_ID),0)*-1
		END,
		pv.isReceipt
	FROM
		c_payment_v pv
	WHERE
		pv.DocStatus IN ('CO','CL') AND pv.IsAllocated='N' AND pv.isReceipt = 'Y'*/
UNION
	Select
		'07' as ordem,
		'RECPLANOCAIXA',
		CP.ad_client_id,
		CP.ad_org_id,
		CPL.DateTrx,
        coalesce(cpl.linetotalamt,0),
        CP.IsSOTrx		
	From
		C_CashPlan CP JOIN C_CashPlanLine CPL ON (CP.C_CashPlan_ID = CPL.C_CashPlan_ID)
	WHERE
		CP.IsSOTrx = 'Y'
		 AND  'Y' = 'Y'
		 AND NOT EXISTS (Select 1 From C_Invoice i Where i.C_CashPlanLine_ID = CPL.C_CashPlanLine_ID AND i.DocStatus not in('RE','VO'))
		 AND CPL.DateTrx >= trunc(now()) 
UNION
	Select
		'08' as ordem,
		'PGTOPLANO',
		CP.ad_client_id,
		CP.ad_org_id,
		CPL.DateTrx,
		coalesce(cpl.linetotalamt,0)*-1,
		CP.IsSOTrx		
	From
		C_CashPlan CP JOIN C_CashPlanLine CPL ON (CP.C_CashPlan_ID = CPL.C_CashPlan_ID)
	WHERE
		CP.IsSOTrx = 'N'
		AND  'Y' = 'Y'
		 AND NOT EXISTS (Select 1 From C_Invoice i Where i.C_CashPlanLine_ID = CPL.C_CashPlanLine_ID AND i.DocStatus not in('RE','VO'))
    	 AND CPL.DateTrx >= trunc(now())
UNION
		SELECT
		'09' as ordem,
		'RECDETCREDITO',
		pv.ad_client_id,
		pv.ad_org_id,
		CASE WHEN 'N'= 'N' THEN
			pv.cof_creditDate
		ELSE
			Date('01/01/1970')
		END,
		coalesce(currencyConvert(pv.PayAmt,pv.C_Currency_ID,  297::numeric ,pv.cof_creditdate,pv.C_ConversionType_ID,pv.AD_Client_ID,pv.AD_Org_ID),0),
		pv.isReceipt
	FROM
		c_payment_v pv
	left join c_bankaccount ba on pv.c_bankaccount_id = ba.c_bankaccount_id
	where pv.DocStatus IN ('CO','CL') and pv.isreceipt = 'Y'
	 --and ba.cof_contatransitoriacredito = 'Y'
	and (select count(bsl.c_bankstatementline_id) from c_bankstatementline bsl left join c_bankstatement bs on bsl.c_bankstatement_id = bs.c_bankstatement_id where c_payment_id = pv.c_payment_id and bs.docstatus in ('CO', 'CL')) <=0
	and(pv.cof_CreditDate::date > trunc(now()) and pv.cof_creditDate::date <=trunc(now()) + interval '30 days' )
	and pv.IsAllocated='Y' 
	and pv.tendertype in ('K', 'C')
UNION
		SELECT
		'10' as ordem,
		'PGTOCHEQUE',
		cc.ad_client_id,
		cc.ad_org_id,
		CASE WHEN cc.dateto >=  trunc(now())  THEN
			cc.dateTo
		ELSE
			 trunc(now())
		END,
		sum(COALESCE(totalamt,0)) * -1,
		p.isReceipt
	FROM
		COF_C_ControlCheck cc
	INNER JOIN C_Payment p ON (cc.COF_Payment_ID = p.C_Payment_ID AND p.DocStatus IN ('CO','CL') and p.isreceipt = 'N' and p.tendertype = 'K' and p.isreconciled = 'N')
    WHERE changedate IS NULL 
    and cc.cof_dateresubmit2 IS NULL
    GROUP BY cc.ad_client_id, cc.ad_org_id, cc.dateto, p.isreceipt
) as temp
LEFT JOIN   --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
    ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}} 
WHERE
  s.processed = 'N' -- valida que sessão esta ativa
and 
    temp.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
and
    temp.ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 
        
	--PROJEÇÃO PASSADA
AND 
    CASE WHEN 'N' = 'N' THEN
        (temp.data::Date >= trunc(now()) AND temp.data::Date <= trunc(now()) + interval '30 days')
    ELSE
    	(temp.data::Date >= '01/01/1970' AND temp.Data::Date <= trunc(now()) + interval '30 days')
    END
GROUP BY
	--ad_client_id,ad_org_id, ordem, documento, data, isSOTrx
	idnu,temp.data
ORDER BY
	data
)

Select 
     *,
      sum(FLUXO.TTdia) OVER (PARTITION BY fluxo.idnu order by fluxo.data) AS ACUM
FROM
     fluxo
