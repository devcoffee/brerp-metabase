/*
######################################################################################################################################
GRAFICO: Saldos Bancários por tipo de conta
AUTOR: Bruno Luis Ferreira
COMENTÁRIOS: Soma dos pagamentos completados, fechados , estornados e  anulados, classificando o saldo conciliado, não conciliado e 
projetado(conciliado + não conciliado)  agrupando por conta corrente, organização e classificação da conta bancária (Dinheiro, cheque, conta corrente e poupança)
O Filtro ocorre apenas por empresa do usuário logado, assim os valore refletem a consolidação de todas as Organizações.Valores tratatos para  conversão em operações de multimoeda

######################################################################################################################################
*/
WITH pagamentos as (
    SELECT 
        CASE 
            WHEN p.isReceipt = 'Y' THEN 
                 currencyconvert(p.payamt , p.c_currency_id, 297::numeric, p.datetrx::date::timestamp with time zone, p.c_conversiontype_id, p.ad_client_id, p.ad_org_id)
            ELSE 
                 currencyconvert((  p.payamt * -1 ), p.c_currency_id, 297::numeric, p.datetrx::date::timestamp with time zone, p.c_conversiontype_id, p.ad_client_id, p.ad_org_id)
        END as Valor,
        CASE 
            WHEN p.isreconciled = 'N'  THEN
                'NCC'
            ELSE
                'CC'
        END as Tipo,
        ba.name as Conta,
        org.name as orgname,
        bb.name as BancoName,
        (select t.Name from ad_ref_list_trl t left join ad_ref_list l on t.ad_ref_list_id = l.ad_ref_list_id where l.AD_Reference_ID='216' and l.value=ba.BankAccountType and t.ad_language = 'pt_BR') as tipoconta
        --ba.BankAccountType as tipoconta

    FROM 
        C_Payment p 
    LEFT JOIN
        C_BankAccount ba ON ba.C_BankAccount_ID = p.C_BankAccount_ID
    LEFT JOIN
       C_Bank bb ON bb.C_Bank_ID=ba.C_Bank_ID
    LEFT JOIN   
        ad_org org  on org.ad_org_id=ba.ad_org_id
       --  join utilizada para garantir os dados dos parametros de organização e empresa, assim como a sessão esteja válida 
    LEFT JOIN
        ad_session s on s.ad_session_uu = {{ad_session_uu}}  and s.ad_client_id = {{ad_client_id}} 
    WHERE 
        p.docstatus IN  ('CO', 'CL','RE','VO')
    AND
        ba.cof_ComposesCashFlow = 'Y' 
    AND
        ba.isactive='Y'
    and 
        s.processed = 'N' -- valida que sessão esta ativa
    and 
        ba.ad_client_id = {{ad_client_id}} -- garante que os registros são da empresa logada
    and
        ba  .ad_org_id = any(string_to_array({{ad_org_id}}, ',')::int[]) -- permite consolidar diversas organizações ou sempre traz da empresa logada 

)
SELECT 
    --p.BancoName as banco,
    --p.orgname,
    --p.conta,
    sum(case when p.Tipo='CC' then p.valor else 0 end) as  "Valor Conciliado",
    sum(case when p.tipo='NCC' then p.valor  else 0 end) as "Valor Não Conciliado",
    sum(p.valor) as "Saldo Projetado" ,
    p.tipoconta
FROM 
    pagamentos p
GROUP by
      p.tipoconta
ORDER BY
   "Saldo Projetado" asc