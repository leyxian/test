mysql -uroot -p'' db

CREATE USER 'username'@'host' IDENTIFIED BY 'password';
GRANT privileges ON databasename.tablename TO 'username'@'host'
GRANT ALL ON *.* TO 'pig'@'%';

GRANT ALL PRIVILEGES ON *.* TO 'root'@'172.24.63.204' IDENTIFIED BY 'MJsujrctG6pU0OUG' WITH GRANT OPTION; FLUSH PRIVILEGES;

show variables like '%query%';
[mysqld]
log-slow-queries = /home/wwwlogs/mysql_slow_query.log
long_query_time=3

ALTER TABLE `table_name` ADD PRIMARY KEY ( `column` ) 
ALTER TABLE `table_name` ADD UNIQUE (`column`)
ALTER TABLE `table_name` ADD INDEX index_name ( `column` ) 
ALTER TABLE `table_name` ADD FULLTEXT ( `column`) 
ALTER TABLE `table_name` ADD INDEX index_name ( `column1`, `column2`, `column3` )

#·Ö¸î×Ö·û¼ÆËã
Select (length(oids) - length(replace(oids,',',''))+1) as onum 

##清除bin日志
reset master

####备份脚本####
#!/bin/sh
ID="root" #用户名
#PWD="root" #密码
DBS="db_zy audit" #数据库名字的列表，多个数据库用空格分开。
BACKPATH="/home/vagrant/Code/mysql" #保存备份的位置
DAY=7  #保留最近几天的备份
[ ! -d $backpath ] &&mkdir -p $BACKPATH  #判断备份目录是否存在，不存时新建目录。
cd $BACKPATH  #转到备份目录，这句话可以省略。可以直接将路径到命令的也行。
#生成备份文件的名字的前缀，不带后缀。
backupname=mysql_$(date +%Y-%m-%d)  
for db in $DBS;  #dbs是一个数据名字的集合。遍历所有的数据。
do
  mysqldump $db -u$ID -proot > $backupname_$db.sql  #备份单个数据为.sql文件。放到当前位置
done
#压缩所有sql文件
tar -czf $backupname.tar.gz *.sql
#删除所有的sql文件
rm -f *.sql
#得到要删除的太旧的备份的名字。
delname=mysql_$(date -d "$DAY day ago" +%Y-%m-%d).tar.gz
#删除文件
rm -f $delname

#### mysqldump
mysqldump -uroot -p123 -h192.131.1.9 --single-transaction --master-data=2 -R --no-data --databases vgos_mcenter vgos_statnum>11.dmp

--master-data=?
1 设定slave
2 注释设定slave语句

--single-transaction
备份时不锁表 无事务myisam表有影响

-R
导出存储过程以及自定义函数

--no-data
只导出表结构

--databases,-B
指定数据库

### 导入sql
source 资源路径

####
SELECT username,oid FROM tao86_order WHERE oid IN (473400,471658) ORDER BY INSTR(',473400,471658,',CONCAT(',',oid,','))

SET @sum = 0;SELECT max(id),SUM(num) FROM (SELECT id,num,@sum:=@sum+num mysum FROM tao86_jpsales ORDER BY id ASC) t WHERE mysum<=10

mysqlbinlog --start-date="2017-08-10 09:00:00" --stop-date="2017-08-10 09:30:00" mysql-bin.000016 > binlog16.txt

mysql_config_editor set --login-path=test --user=test_user  --host=127.0.0.1 --port=3306 --password


SELECT 
    o.id,o.tdate,o.goodcode,o.outnum,o.salePrice
    ,costprice=CAST(SUM((CASE WHEN i.SumInNum>o.Sumoutnum THEN o.Sumoutnum ELSE i.SumInNum END -CASE WHEN o.Sumoutnum-o.OutNum>i.SumInNum-i.InNum THEN o.Sumoutnum-o.OutNum ELSE i.SumInNum-i.InNum END)*i.Price)/o.outnum AS MONEY)
    ,costmoney=CAST(SUM((CASE WHEN i.SumInNum>o.Sumoutnum THEN o.Sumoutnum ELSE i.SumInNum END -CASE WHEN o.Sumoutnum-o.OutNum>i.SumInNum-i.InNum THEN o.Sumoutnum-o.OutNum ELSE i.SumInNum-i.InNum END)*i.Price) AS MONEY)
FROM 
(SELECT *,SumInNum=(SELECT SUM(InNum) FROM #in WHERE goodcode=i.goodcode AND id<=i.id) FROM #in AS i) AS i,
(SELECT *,Sumoutnum=(SELECT SUM(outnum) FROM #out WHERE goodcode=i.goodcode AND id<=i.id) FROM #out AS i) AS o
WHERE i.goodcode=o.goodcode AND i.SumInNum-i.InNum<o.Sumoutnum AND o.Sumoutnum-o.OutNum<i.SumInNum
GROUP BY o.id,o.tdate,o.goodcode,o.outnum,o.salePrice

show master status;
###################123456####################
mysqlbinlog --no-defaults --start-datetime="2016-11-17 00:00:00" --stop-datetime="2016-11-19 23:59:59" ./mysql-bin.000011 --result-file=mysql-bin.000011.sql

//定位日志记录
mysqlbinlog --no-defaults -v -v --base64-output=DECODE-ROWS mysql-bin.000167 | grep -A '10' 195993466

//定位坐标
grep -i "CHANGE MASTER TO" mysql.sql

//修改 slave
CHANGE MASTER TO MASTER_HOST='10.10.1.2',MASTER_USER='replicate',MASTER_PASSWORD='replpassword',MASTER_LOG_FILE='log-bin.log.000001',MASTER_LOG_POS=98

//同步跳过某个错误
STOP SLAVE;
SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1;
START SLAVE;
SHOW SLAVE STATUS

//先进先出存储过程
BEGIN
    #Routine body goes here...
    DECLARE sid INT;
    DECLARE pid INT;
    DECLARE pnum INT DEFAULT 0;
    DECLARE snum INT;
    DECLARE num INT;
    DECLARE depot INT;
    DECLARE sku VARCHAR(20);
    DECLARE p_unit_price DECIMAL;
    DECLARE s_unit_price DECIMAL;
    DECLARE pdate DATE;
    DECLARE sdate DATE;

    DECLARE done INT DEFAULT FALSE;
    DECLARE ma CURSOR FOR SELECT s.depot FROM tao86_jpsales s WHERE s.depot IN(5,6,7,8) GROUP BY s.depot;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN ma;
        get_ma: LOOP
            FETCH ma INTO depot;
            IF done THEN
                LEAVE get_ma;
            ELSE                
                -- SELECT depot;
                BEGIN
                    DECLARE done1 INT DEFAULT FALSE;
                    DECLARE mb CURSOR FOR SELECT s.sku FROM tao86_jpsales s LEFT JOIN tao86_v_jpverdate v ON s.depot=v.depot WHERE s.shipment>=v.mdate AND s.type IN (1,4) AND s.depot=depot AND s.sku>'' GROUP BY s.sku;
                    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done1 = TRUE;
                    OPEN mb;
                    get_mb: LOOP
                    FETCH mb INTO sku;
                    IF done1 THEN
                        LEAVE get_mb;
                    ELSE
                        BEGIN
                            DECLARE ynum INT DEFAULT 0;
                            DECLARE ppage INT DEFAULT 0;
                            DECLARE done2 INT DEFAULT FALSE;                
                            DECLARE mc CURSOR FOR SELECT s.id,s.num,s.unit_price,s.shipment FROM tao86_jpsales s LEFT JOIN tao86_v_jpverdate v ON s.depot=v.depot WHERE s.shipment>=v.mdate AND s.type IN (1,4) AND s.depot=depot AND s.sku=sku ORDER BY s.shipment ASC,id ASC;
                            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done2 = TRUE;
                            OPEN mc;
                            get_mc: LOOP
                            FETCH mc INTO sid,snum,s_unit_price,sdate;
                            IF done2 THEN
                                LEAVE get_mc;
                            ELSE
                                SET @osnum = snum;
                                IF ynum > 0 THEN
                                    IF snum > ynum THEN
                                        SET snum = snum - ynum;
                                        SET num = ynum;
                                        SET ynum = 0;
                                    ELSE                                        
                                        SET ynum = ynum - snum;
                                        SET num = snum;
                                        SET snum = 0;
                                    END IF;
                                    -- SELECT sid,@pid,snum,@pnum,depot,num,sku,@p_unit_price,s_unit_price,sdate,@pdate;
                                    CREATE TEMPORARY TABLE IF NOT EXISTS tao86_t_opij ENGINE = MEMORY SELECT @pid,sid,sku,depot,@pnum,@osnum,num,p_unit_price,s_unit_price,pdate,sdate;
                                END IF;
                                for_pur: BEGIN
                                    WHILE snum > 0 do
                                        SET @pur_sql = CONCAT('SELECT p.id,p.num,p.unit_price,CASE WHEN p.mvtime THEN p.mvtime WHEN p.ardtime THEN p.ardtime ELSE cdate END pdate FROM tao86_jppurchases p LEFT JOIN tao86_v_jpversion v ON p.depot=v.depot WHERE p.sku=\'',sku,'\' AND p.depot=',depot,' AND p.ver=v.ver AND p.deltime=\'0000-00-00 00:00:00\' ORDER BY pdate ASC,id ASC LIMIT ',ppage,',1 INTO @pid,@pnum,@p_unit_price,@pdate');
                                        PREPARE pq FROM @pur_sql;
                                        EXECUTE pq;
                                        DROP PREPARE pq;
                                        IF !@pid THEN
                                            LEAVE for_pur;
                                        ELSE
                                            SET pdate = @pdate;
                                            SET p_unit_price = @p_unit_price;
                                            IF snum >= @pnum THEN
                                                SET num = @pnum;
                                                SET ynum = 0;
                                            ELSEIF snum < @pnum THEN
                                                SET num = snum;
                                                SET ynum = @pnum - snum;
                                            END IF;
                                            -- SELECT sid,@pid,snum,@pnum,depot,num,sku,@p_unit_price,s_unit_price,sdate,pdate;
                                            CREATE TEMPORARY TABLE IF NOT EXISTS tao86_t_opij ENGINE = MEMORY SELECT @pid,sid,sku,depot,@pnum,snum,num,p_unit_price,s_unit_price,pdate,sdate;
                                            SET ppage = ppage + 1;
                                            SET snum = snum - @pnum;
                                        END IF;                                     
                                    END WHILE;
                                END;
                            END IF;
                            END LOOP get_mc;
                        END;
                    END IF;             
                    END LOOP get_mb;
                    CLOSE mb;
                END;
            END IF;
        END LOOP get_ma;
    CLOSE ma;
    TRUNCATE tao86_jpopij;
    INSERT INTO tao86_jpopij SELECT * FROM tao86_t_opij;
    DROP TABLE tao86_t_opij;
END
=======
mysql -uroot -p'' db

CREATE USER 'username'@'host' IDENTIFIED BY 'password';
GRANT privileges ON databasename.tablename TO 'username'@'host'
GRANT ALL ON *.* TO 'pig'@'%';

GRANT ALL PRIVILEGES ON *.* TO 'root'@'172.24.63.204' IDENTIFIED BY 'MJsujrctG6pU0OUG' WITH GRANT OPTION; FLUSH PRIVILEGES;

show variables like '%query%';
[mysqld]
log-slow-queries = /home/wwwlogs/mysql_slow_query.log
long_query_time=3

ALTER TABLE `table_name` ADD PRIMARY KEY ( `column` ) 
ALTER TABLE `table_name` ADD UNIQUE (`column`)
ALTER TABLE `table_name` ADD INDEX index_name ( `column` ) 
ALTER TABLE `table_name` ADD FULLTEXT ( `column`) 
ALTER TABLE `table_name` ADD INDEX index_name ( `column1`, `column2`, `column3` )

###
Select (length(oids) - length(replace(oids,',',''))+1) as onum 

##清除bin日志
reset master

####备份脚本####
#!/bin/sh
ID="root" #用户名
#PWD="root" #密码
DBS="db_zy audit" #数据库名字的列表，多个数据库用空格分开。
BACKPATH="/home/vagrant/Code/mysql" #保存备份的位置
DAY=7  #保留最近几天的备份
[ ! -d $backpath ] &&mkdir -p $BACKPATH  #判断备份目录是否存在，不存时新建目录。
cd $BACKPATH  #转到备份目录，这句话可以省略。可以直接将路径到命令的也行。
#生成备份文件的名字的前缀，不带后缀。
backupname=mysql_$(date +%Y-%m-%d)  
for db in $DBS;  #dbs是一个数据名字的集合。遍历所有的数据。
do
  mysqldump $db -u$ID -proot > $backupname_$db.sql  #备份单个数据为.sql文件。放到当前位置
done
#压缩所有sql文件
tar -czf $backupname.tar.gz *.sql
#删除所有的sql文件
rm -f *.sql
#得到要删除的太旧的备份的名字。
delname=mysql_$(date -d "$DAY day ago" +%Y-%m-%d).tar.gz
#删除文件
rm -f $delname

#### mysqldump
mysqldump -uroot -p123 -h192.131.1.9 --single-transaction --master-data=2 -R --no-data --databases vgos_mcenter vgos_statnum>11.dmp

--master-data=?
1 设定slave
2 注释设定slave语句

--single-transaction
备份时不锁表 无事务myisam表有影响

-R
导出存储过程以及自定义函数

--no-data
只导出表结构

--databases,-B
指定数据库

### 导入sql
source 资源路径

####
SELECT username,oid FROM tao86_order WHERE oid IN (473400,471658) ORDER BY INSTR(',473400,471658,',CONCAT(',',oid,','))

SET @sum = 0;SELECT max(id),SUM(num) FROM (SELECT id,num,@sum:=@sum+num mysum FROM tao86_jpsales ORDER BY id ASC) t WHERE mysum<=10

mysqlbinlog --start-date="2017-08-10 09:00:00" --stop-date="2017-08-10 09:30:00" mysql-bin.000016 > binlog16.txt

mysql_config_editor set --login-path=test --user=test_user  --host=127.0.0.1 --port=3306 --password


SELECT 
    o.id,o.tdate,o.goodcode,o.outnum,o.salePrice
    ,costprice=CAST(SUM((CASE WHEN i.SumInNum>o.Sumoutnum THEN o.Sumoutnum ELSE i.SumInNum END -CASE WHEN o.Sumoutnum-o.OutNum>i.SumInNum-i.InNum THEN o.Sumoutnum-o.OutNum ELSE i.SumInNum-i.InNum END)*i.Price)/o.outnum AS MONEY)
    ,costmoney=CAST(SUM((CASE WHEN i.SumInNum>o.Sumoutnum THEN o.Sumoutnum ELSE i.SumInNum END -CASE WHEN o.Sumoutnum-o.OutNum>i.SumInNum-i.InNum THEN o.Sumoutnum-o.OutNum ELSE i.SumInNum-i.InNum END)*i.Price) AS MONEY)
FROM 
(SELECT *,SumInNum=(SELECT SUM(InNum) FROM #in WHERE goodcode=i.goodcode AND id<=i.id) FROM #in AS i) AS i,
(SELECT *,Sumoutnum=(SELECT SUM(outnum) FROM #out WHERE goodcode=i.goodcode AND id<=i.id) FROM #out AS i) AS o
WHERE i.goodcode=o.goodcode AND i.SumInNum-i.InNum<o.Sumoutnum AND o.Sumoutnum-o.OutNum<i.SumInNum
GROUP BY o.id,o.tdate,o.goodcode,o.outnum,o.salePrice

show master status;

mysqlbinlog --no-defaults --start-datetime="2020-11-17 00:00:00" --stop-datetime="2016-11-19 23:59:59" ./mysql-bin.000011 --result-file=mysql-bin.000011.sql

/usr/local/mysql/bin/mysqlbinlog --base64-output=decode-rows -v --start-datetime="2020-2-21 00:00:00" --stop-datetime="2020-2-22 10:30:00" -d transportjp ./mysql-bin.000193 --result-file=mysql-bin.000193.sql

//定位日志记录
mysqlbinlog --no-defaults -v -v --base64-output=DECODE-ROWS mysql-bin.000167 | grep -A '10' 195993466

//定位坐标
grep -i "CHANGE MASTER TO" mysql.sql

//修改 slave
CHANGE MASTER TO MASTER_HOST='10.10.1.2',MASTER_USER='replicate',MASTER_PASSWORD='replpassword',MASTER_LOG_FILE='log-bin.log.000001',MASTER_LOG_POS=98

//同步跳过某个错误
STOP SLAVE;
SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1;
START SLAVE;
SHOW SLAVE STATUS

//先进先出存储过程
BEGIN
    #Routine body goes here...
    DECLARE sid INT;
    DECLARE pid INT;
    DECLARE pnum INT DEFAULT 0;
    DECLARE snum INT;
    DECLARE num INT;
    DECLARE depot INT;
    DECLARE sku VARCHAR(20);
    DECLARE p_unit_price DECIMAL;
    DECLARE s_unit_price DECIMAL;
    DECLARE pdate DATE;
    DECLARE sdate DATE;

    DECLARE done INT DEFAULT FALSE;
    DECLARE ma CURSOR FOR SELECT s.depot FROM tao86_jpsales s WHERE s.depot IN(5,6,7,8) GROUP BY s.depot;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN ma;
        get_ma: LOOP
            FETCH ma INTO depot;
            IF done THEN
                LEAVE get_ma;
            ELSE                
                -- SELECT depot;
                BEGIN
                    DECLARE done1 INT DEFAULT FALSE;
                    DECLARE mb CURSOR FOR SELECT s.sku FROM tao86_jpsales s LEFT JOIN tao86_v_jpverdate v ON s.depot=v.depot WHERE s.shipment>=v.mdate AND s.type IN (1,4) AND s.depot=depot AND s.sku>'' GROUP BY s.sku;
                    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done1 = TRUE;
                    OPEN mb;
                    get_mb: LOOP
                    FETCH mb INTO sku;
                    IF done1 THEN
                        LEAVE get_mb;
                    ELSE
                        BEGIN
                            DECLARE ynum INT DEFAULT 0;
                            DECLARE ppage INT DEFAULT 0;
                            DECLARE done2 INT DEFAULT FALSE;                
                            DECLARE mc CURSOR FOR SELECT s.id,s.num,s.unit_price,s.shipment FROM tao86_jpsales s LEFT JOIN tao86_v_jpverdate v ON s.depot=v.depot WHERE s.shipment>=v.mdate AND s.type IN (1,4) AND s.depot=depot AND s.sku=sku ORDER BY s.shipment ASC,id ASC;
                            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done2 = TRUE;
                            OPEN mc;
                            get_mc: LOOP
                            FETCH mc INTO sid,snum,s_unit_price,sdate;
                            IF done2 THEN
                                LEAVE get_mc;
                            ELSE
                                SET @osnum = snum;
                                IF ynum > 0 THEN
                                    IF snum > ynum THEN
                                        SET snum = snum - ynum;
                                        SET num = ynum;
                                        SET ynum = 0;
                                    ELSE                                        
                                        SET ynum = ynum - snum;
                                        SET num = snum;
                                        SET snum = 0;
                                    END IF;
                                    -- SELECT sid,@pid,snum,@pnum,depot,num,sku,@p_unit_price,s_unit_price,sdate,@pdate;
                                    CREATE TEMPORARY TABLE IF NOT EXISTS tao86_t_opij ENGINE = MEMORY SELECT @pid,sid,sku,depot,@pnum,@osnum,num,p_unit_price,s_unit_price,pdate,sdate;
                                END IF;
                                for_pur: BEGIN
                                    WHILE snum > 0 do
                                        SET @pur_sql = CONCAT('SELECT p.id,p.num,p.unit_price,CASE WHEN p.mvtime THEN p.mvtime WHEN p.ardtime THEN p.ardtime ELSE cdate END pdate FROM tao86_jppurchases p LEFT JOIN tao86_v_jpversion v ON p.depot=v.depot WHERE p.sku=\'',sku,'\' AND p.depot=',depot,' AND p.ver=v.ver AND p.deltime=\'0000-00-00 00:00:00\' ORDER BY pdate ASC,id ASC LIMIT ',ppage,',1 INTO @pid,@pnum,@p_unit_price,@pdate');
                                        PREPARE pq FROM @pur_sql;
                                        EXECUTE pq;
                                        DROP PREPARE pq;
                                        IF !@pid THEN
                                            LEAVE for_pur;
                                        ELSE
                                            SET pdate = @pdate;
                                            SET p_unit_price = @p_unit_price;
                                            IF snum >= @pnum THEN
                                                SET num = @pnum;
                                                SET ynum = 0;
                                            ELSEIF snum < @pnum THEN
                                                SET num = snum;
                                                SET ynum = @pnum - snum;
                                            END IF;
                                            -- SELECT sid,@pid,snum,@pnum,depot,num,sku,@p_unit_price,s_unit_price,sdate,pdate;
                                            CREATE TEMPORARY TABLE IF NOT EXISTS tao86_t_opij ENGINE = MEMORY SELECT @pid,sid,sku,depot,@pnum,snum,num,p_unit_price,s_unit_price,pdate,sdate;
                                            SET ppage = ppage + 1;
                                            SET snum = snum - @pnum;
                                        END IF;                                     
                                    END WHILE;
                                END;
                            END IF;
                            END LOOP get_mc;
                        END;
                    END IF;             
                    END LOOP get_mb;
                    CLOSE mb;
                END;
            END IF;
        END LOOP get_ma;
    CLOSE ma;
    TRUNCATE tao86_jpopij;
    INSERT INTO tao86_jpopij SELECT * FROM tao86_t_opij;
    DROP TABLE tao86_t_opij;
END

-- 批量替换表前缀
SELECT CONCAT( 'ALTER TABLE ', table_name, ' RENAME TO blog_', substring(table_name, 5),';') FROM information_schema.tables where table_schema='数据库名' and table_name LIKE 'whm_%';
