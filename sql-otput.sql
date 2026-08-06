SET SESSION group_concat_max_len = 1000000;

SELECT GROUP_CONCAT(
         CONCAT(",CONCAT('$',SUM(IF(tld='",tld,"',amt,NULL))) `.",tld," (",raw,"/year) x ",n,"`")
         ORDER BY amt DESC, tld SEPARATOR '')
INTO @c
FROM (
  SELECT p.tld tld, p.price raw,
         CAST(REPLACE(p.price,'$','') AS DECIMAL(10,2)) amt,
         COUNT(*) n
  FROM domains d
  JOIN prices p ON p.tld = SUBSTRING_INDEX(d.name,'.',-1)
  WHERE d.expiration_date LIKE '2022-08%'
  GROUP BY p.tld, p.price
) x;

SET @s = CONCAT('SELECT a.username', IFNULL(@c,''), '
FROM accounts a
LEFT JOIN (
  SELECT d.account_id aid,
         p.tld tld,
         CAST(REPLACE(p.price,''$'','''') AS DECIMAL(10,2)) amt
  FROM domains d
  JOIN prices p ON p.tld = SUBSTRING_INDEX(d.name,''.'',-1)
  WHERE d.expiration_date LIKE ''2022-08%''
) v ON aid = a.id
GROUP BY a.id, a.username
ORDER BY 1');

PREPARE q FROM @s;
EXECUTE q;
DEALLOCATE PREPARE q;
