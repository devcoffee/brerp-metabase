WITH 
pagamentos AS (
    SELECT 
        CASE  WHEN p.isReceipt = 'Y' THEN  'Receber' ELSE 'Pagar' 			 END as tipo,
        CASE  WHEN p.isReceipt = 'Y' THEN   p.payamt  ELSE   p.payamt * -1   END as valor,
        DATE_PART('day',now()::timestamp - p.datetrx::timestamp) as aging
    FROM   C_Payment p 
    WHERE   p.docstatus IN  ('CO', 'CL')
    AND p.datetrx >= now() - INTERVAL '180 DAY'
),
pagamentos2 AS (
    SELECT
        tipo, valor,
        CASE  -- 0-0
            WHEN p.aging = 0 THEN 1 -- 1-5
            WHEN p.aging > 0 and p.aging < 6     THEN 2 -- 1-15
            WHEN p.aging > 5 and p.aging < 16    THEN 3 -- 1-30
            WHEN p.aging > 15 and p.aging < 31   THEN 4 -- 1-60
            WHEN p.aging > 30 and p.aging < 61   THEN 5 -- 1-90
            WHEN p.aging > 60 and p.aging < 91   THEN 6 -- 1-120
            WHEN p.aging > 90 and p.aging < 121  THEN 7 -- 1-180
            WHEN p.aging > 120 and p.aging < 181 THEN 8
        END as aging
    FROM  pagamentos p
)
select tipo,json_valores.key, json_valores.value::jsonb::text::numeric  from (  
		SELECT 
		    tipo,
		    json_build_object(
			    'zero', coalesce(SUM (CASE WHEN p.aging = 1 THEN p.valor ELSE 0 END),0) , 
			    'um_cinco', coalesce(SUM (CASE WHEN p.aging = 2 THEN p.valor ELSE 0 END),0), 
			    'um_quinze', coalesce( SUM (CASE WHEN p.aging IN (2,3) THEN p.valor ELSE 0 END),0),
			    'um_trinta', coalesce(SUM (CASE WHEN p.aging IN (2,3,4) THEN p.valor ELSE 0 END),0),
			    'um_sesenta', coalesce(SUM (CASE WHEN p.aging IN (2,3,4,5) THEN p.valor ELSE 0 END),0),
			    'um_noventa', coalesce(SUM (CASE WHEN p.aging IN (2,3,4,5,6) THEN p.valor ELSE 0 END),0),
			    'um_centoevinte', coalesce(SUM (CASE WHEN p.aging IN (2,3,4,5,6,7) THEN p.valor ELSE 0 END),0),
			    'um_centoeoitenta', coalesce(SUM (CASE WHEN p.aging IN (2,3,4,5,6,7,8) THEN p.valor ELSE 0 END),0)
		    ) AS dados 
		FROM pagamentos2 p
		GROUP BY  p.tipo 
) AS resultado 
INNER JOIN LATERAL (
 	SELECT * FROM json_each(resultado.dados)
) AS json_valores ON 1=1
ORDER BY resultado.tipo;
