-- Step 1: build the pivot column list
SET @cols = NULL;

SELECT GROUP_CONCAT(col ORDER BY p DESC, tld ASC SEPARATOR ',\n       ')
INTO @cols
FROM (
    SELECT d.tld,
           CAST(REPLACE(pr.price, '$', '') AS DECIMAL(10,2)) AS p,
           CONCAT(
             'CONCAT(''$'', FORMAT(SUM(CASE WHEN t.tld = ''', d.tld,
             ''' THEN t.price END), 2)) AS `.', d.tld,
             ' ($', FORMAT(CAST(REPLACE(pr.price, '$', '') AS DECIMAL(10,2)), 2),
             '/year) x ', COUNT(*), '`'
           ) AS col
    FROM (
        SELECT SUBSTRING_INDEX(name, '.', -1) AS tld
        FROM domains
        WHERE LEFT(expiration_date, 7) = '2022-08'
    ) d
    JOIN prices pr ON pr.tld = d.tld
    GROUP BY d.tld, p
) x;

-- Step 2: assemble and run the pivot
SET @sql = CONCAT(
'SELECT a.username,
       ', IFNULL(@cols, 'NULL'), '
 FROM accounts a
 LEFT JOIN (
     SELECT dm.account_id,
            SUBSTRING_INDEX(dm.name, ''.'', -1) AS tld,
            CAST(REPLACE(pr.price, ''$'', '''') AS DECIMAL(10,2)) AS price
     FROM domains dm
     JOIN prices pr ON pr.tld = SUBSTRING_INDEX(dm.name, ''.'', -1)
     WHERE LEFT(dm.expiration_date, 7) = ''2022-08''
 ) t ON t.account_id = a.id
 GROUP BY a.id, a.username
 ORDER BY a.username');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
