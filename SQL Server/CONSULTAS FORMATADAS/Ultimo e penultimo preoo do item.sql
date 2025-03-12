 
SELECT 
    T1.ItemCode,
    T2.Price AS PrecoAtual,
	T1.LogInstanc,
    LAG(T1.Price) OVER (PARTITION BY T1.ItemCode ORDER BY T1.LogInstanc DESC) AS PrecoAnterior
	
INTO #PriceHistory1
FROM  AIT1  T1
inner join OITM T0 on T0.ItemCode = t1.ItemCode and T0.ItmsGrpCod = 133 and T0.UpdateDate > '2025-02-25'
inner join ITM1 T2 ON T1.ItemCode = T2.ItemCode and T1.PriceList = T2.PriceList
WHERE    T1.Price > 0 ;

 
SELECT 
    *, ROW_NUMBER() OVER (PARTITION BY ItemCode ORDER BY LogInstanc desc) AS rn
INTO #PriceHistory
FROM #PriceHistory1    



SELECT 
    p1.ItemCode,
    p1.PrecoAtual,
    p2.PrecoAnterior,
    CASE 
        WHEN p2.PrecoAnterior > 0 THEN FORMAT(((p1.PrecoAtual - p2.PrecoAnterior) / p2.PrecoAnterior) * 100, '0.00')
        ELSE NULL
    END AS PercentualVariacao
FROM #PriceHistory p1 
LEFT JOIN #PriceHistory p2 ON p1.ItemCode = p2.ItemCode AND p1.rn = 1 AND p2.rn = 2
WHERE p1.rn = 1 and p2.PrecoAnterior is not null
order by PercentualVariacao;


Drop Table #PriceHistory1
Drop Table #PriceHistory
