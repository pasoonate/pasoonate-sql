DELIMITER $$
CREATE FUNCTION `jdate2timestamp`(`year` INT(4), `month` INT(2), `day` INT(2), `hour` INT(2), `minute` INT(2), `second` INT(2)) RETURNS INT
	NO SQL
BEGIN
	DECLARE ts INT DEFAULT 0;

	SET ts = ((floor(((year * 682) - 110) / 2816) + ((year - 1) * 365) 
		+ IF(month <= 7, (month - 1) * 31, ((month - 1) * 30) + 6) 
		+ (day - 1)) * 86400) + (hour * 3600) + (minute * 60) + second - 42531868800;

	RETURN ts;
END $$

CREATE FUNCTION `timestamp2jdatetime`(`ts` INT) RETURNS CHAR(19)
	NO SQL
BEGIN
	DECLARE base BIGINT DEFAULT ts + 42531868800;
	DECLARE second INT DEFAULT mod(base, 60);
	DECLARE minute INT DEFAULT floor(mod(base, 3600) / 60);
	DECLARE hour INT DEFAULT floor(mod(base, 86400) / 3600);
	DECLARE days INT DEFAULT floor(base / 86400);
	DECLARE year INT DEFAULT floor(days / 365);
	DECLARE dayofyear INT DEFAULT days - (floor(((year * 682) - 110) / 2816) + ((year - 1) * 365));
	DECLARE month INT DEFAULT floor(IF(dayofyear <= 186, dayOfYear / 31, (dayofyear - 6) / 30)) + 1;
	DECLARE day INT DEFAULT dayofyear - IF(month <= 7, (month - 1) * 31, ((month - 1) * 30) + 6) + 1;

	IF month > 12 THEN
		SET day = day + IF(jleap(year) = 1, 0, 1);
		SET month = month - 12;
		SET year = year + 1;
	END IF;

	IF month = 12 AND day > 29 AND jleap(year) = 0 THEN
		SET day = 1;
		SET month = 1;
		SET year = year + 1;
	END IF;

	RETURN CONCAT(year, '/', LPAD(month, 2, 0), '/', LPAD(day, 2, 0), ' ', LPAD(hour, 2, 0), ':', LPAD(minute, 2, 0), ':', LPAD(second, 2, 0));
END $$

CREATE FUNCTION `timestamp2jdate`(`ts` INT) RETURNS CHAR(10)
	NO SQL
BEGIN
	DECLARE base BIGINT DEFAULT ts + 42531868800;
	DECLARE days INT DEFAULT floor(base / 86400);
	DECLARE year INT DEFAULT floor(days / 365);
	DECLARE dayofyear INT DEFAULT days - (floor(((year * 682) - 110) / 2816) + ((year - 1) * 365));
	DECLARE month INT DEFAULT floor(IF(dayofyear <= 186, dayOfYear / 31, (dayofyear - 6) / 30)) + 1;
	DECLARE day INT DEFAULT dayofyear - IF(month <= 7, (month - 1) * 31, ((month - 1) * 30) + 6) + 1;

	IF month > 12 THEN
		SET day = day + IF(jleap(year) = 1, 0, 1);
		SET month = month - 12;
		SET year = year + 1;
	END IF;

	IF month = 12 AND day > 29 AND jleap(year) = 0 THEN
		SET day = 1;
		SET month = 1;
		SET year = year + 1;
	END IF;

	RETURN CONCAT(year, '/', LPAD(month, 2, 0), '/', LPAD(day, 2, 0));
END $$

CREATE FUNCTION `jleap`(`year` INT(4)) RETURNS TINYINT(1)
	NO SQL
BEGIN
	RETURN IF(year < 1343, (year % 33) IN (1,5,9,13,17,21,26,30), (year % 33) IN (1,5,9,13,17,22,26,30));
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION `DateToJulianDay`(`year` INT(4), `month` INT(2), `day` INT(2), `hour` INT(2), `minute` INT(2), `second` INT(2)) RETURNS decimal(11,4)
    NO SQL
BEGIN
	declare epochBase int default year - IF(year >= 0, 474, 473);
	declare epochYear int default (474 + mod(epochBase, 2820));
	declare julianDay decimal(11,4) default day;
    
	SET julianDay = julianDay + IF(month <= 7, (month - 1) * 31, ((month - 1) * 30) + 6);
	SET julianDay = julianDay + floor(((epochYear * 682) - 110) / 2816);
	SET julianDay = julianDay + ((epochYear - 1) * 365);
	SET julianDay = julianDay + (floor(epochBase / 2820) * 1029983);
	SET julianDay = julianDay + 1948320.5 - 1;

	RETURN AddTimeToJulianDay(julianDay, hour, minute, second);
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION `AddTimeToJulianDay`(`julianDay` DECIMAL(11,4), `hour` INT(2), `minute` INT(2), `second` INT(2)) RETURNS decimal(11,4)
    NO SQL
BEGIN
	declare timestamp bigint default JulianDayToTimestamp(julianDay);
    declare julianDayFloatRounded decimal(11,4);
    declare result decimal(11, 4);
    
    SET timestamp = timestamp + (3600 * hour) + (60 * minute) + second;
    SET julianDay = TimestampToJulianDay(timestamp);
    SET julianDayFloatRounded = round(((julianDay - floor(julianDay)) * 10000000) / 10000000, 5);
    SET result = round(floor(julianDay) + julianDayFloatRounded, 5);
    
    RETURN result;
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION `GetHoursOfJulianDay`(`julianDay` DECIMAL(11,4)) RETURNS int(2)
    NO SQL
BEGIN
	declare time int;
    
    set julianDay = julianDay + 0.5;
    set time = floor((julianDay - floor(julianDay)) * 86400);
    
    RETURN floor(time / 3600);
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION `GetMinutesOfJulianDay`(`julianDay` DECIMAL(11,4)) RETURNS int(2)
    NO SQL
BEGIN
	declare time int;

	SET julianDay = julianDay + 0.5;
    SET time = floor((julianDay - floor(julianDay)) * 86400);   
    
    RETURN floor(MOD(time / 60, 60));  
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION `GetSecondsOfJulianDay`(`julianDay` DECIMAL(11,4)) RETURNS int(2)
    NO SQL
BEGIN
	declare time int;
    
	SET julianDay = julianDay + 0.5;
    SET time = floor((julianDay - floor(julianDay)) * 86400);
    
    RETURN floor(MOD(time, 60));
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION `GetTimeOfJulianDay`(`julianDay` DECIMAL(11,4)) RETURNS varchar(8) CHARSET utf8mb4
    NO SQL
BEGIN
	declare time int;
    declare hour int;
    declare minute int;
    declare second int;

	SET julianDay = julianDay + 0.5;	
    SET time = floor((julianDay - floor(julianDay)) * 86400);   
    SET hour = IF(floor(time / 3600) < 10, CONCAT('0', floor(time / 3600)), floor(time / 3600));
    SET minute = IF(floor(MOD(time / 60,60)) < 10, CONCAT('0', floor(MOD(time / 60,60))), floor(MOD(time / 60,60)));
    SET second = IF(floor(MOD(time,60)) < 10, CONCAT('0', floor(MOD(time,60))), floor(MOD(time,60)));
        
    RETURN CONCAT(hour, ':', minute, ':', second);
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION `JDate`(date datetime) RETURNS varchar(25) CHARSET utf8mb4
    NO SQL
BEGIN
	declare year  int default JYEAR(date);
    declare monthName varchar(20) default JMONTHNAME(date);
    declare day   int default JDAY(date);
    
	RETURN concat(year, ' ', monthName, ' ', day);
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION `JDay`(date datetime) RETURNS int(11)
    NO SQL
BEGIN
	declare timestamp int default unix_timestamp(date);
	declare julianDay decimal(11,4) default TimestampToJulianDay(timestamp);
	declare hour int default GetHoursOfJulianDay(julianDay);
    declare minute int default GetMinutesOfJulianDay(julianDay);
    declare second int default GetSecondsOfJulianDay(julianDay);
    declare depoch decimal(11,4);
    declare cycle int;
    declare cyear int;
    declare ycycle int;
	declare aux1 int;
	declare aux2 int;
	declare year int;
    declare month int;
    declare day int;
    declare yday decimal(11,4);
    declare result varchar(20);
    
    set julianDay = JulianDayWithoutTime(julianDay);
    set julianDay = floor(julianDay) + 0.5;
    set depoch = julianDay - JulianDayWithoutTime(DateToJulianDay(475, 1, 1, hour, minute, second));
    set cycle = floor(depoch / 1029983);
	set cyear = MOD(depoch, 1029983);
    
	IF cyear = 1029982 THEN
    	SET ycycle = 2820;
	ELSE
    	SET aux1 = floor(cyear / 366);
    	SET aux2 = MOD(cyear, 366);
    	SET ycycle = floor(((2134 * aux1) + (2816 * aux2) + 2815) / 1028522) + aux1 + 1;
	END IF;

	SET year = ycycle + (2820 * cycle) + 474;

	IF year <= 0 THEN
    	SET year = year - 1;
	END IF;

	SET yday = (julianDay - JulianDayWithoutTime(DateToJulianDay(year, 1, 1, hour, minute, second))) + 1;

	IF yday <= 186 THEN
		SET month = ceil(yday / 31);
	ELSE
		SET month = ceil((yday - 6) / 30);
	END IF;

	SET day = (julianDay - JulianDayWithoutTime(DateToJulianDay(year, month, 1, hour, minute, second))) + 1;
    
	RETURN day;
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION `JMonth`(date datetime) RETURNS int(11)
    NO SQL
BEGIN
	declare timestamp int default unix_timestamp(date);
	declare julianDay decimal(11,4) default TimestampToJulianDay(timestamp);
	declare hour int default GetHoursOfJulianDay(julianDay);
    declare minute int default GetMinutesOfJulianDay(julianDay);
    declare second int default GetSecondsOfJulianDay(julianDay);
    declare depoch decimal(11,4);
    declare cycle int;
    declare cyear int;
    declare ycycle int;
	declare aux1 int;
	declare aux2 int;
	declare year int;
    declare month int;
    declare day int;
    declare yday decimal(11,4);
    declare result varchar(20);
    
    set julianDay = JulianDayWithoutTime(julianDay);
    set julianDay = floor(julianDay) + 0.5;
    set depoch = julianDay - JulianDayWithoutTime(DateToJulianDay(475, 1, 1, hour, minute, second));
    set cycle = floor(depoch / 1029983);
	set cyear = MOD(depoch, 1029983);
    
	IF cyear = 1029982 THEN
    	SET ycycle = 2820;
	ELSE
    	SET aux1 = floor(cyear / 366);
    	SET aux2 = MOD(cyear, 366);
    	SET ycycle = floor(((2134 * aux1) + (2816 * aux2) + 2815) / 1028522) + aux1 + 1;
	END IF;

	SET year = ycycle + (2820 * cycle) + 474;

	IF year <= 0 THEN
    	SET year = year - 1;
	END IF;

	SET yday = (julianDay - JulianDayWithoutTime(DateToJulianDay(year, 1, 1, hour, minute, second))) + 1;

	IF yday <= 186 THEN
		SET month = ceil(yday / 31);
	ELSE
		SET month = ceil((yday - 6) / 30);
	END IF;
    
	RETURN month;
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION `JYear`(date datetime) RETURNS int(11)
    NO SQL
BEGIN
	declare timestamp int default unix_timestamp(date);
	declare julianDay decimal(11,4) default TimestampToJulianDay(timestamp);
	declare hour int default GetHoursOfJulianDay(julianDay);
    declare minute int default GetMinutesOfJulianDay(julianDay);
    declare second int default GetSecondsOfJulianDay(julianDay);
    declare depoch decimal(11,4);
    declare cycle int;
    declare cyear int;
    declare ycycle int;
	declare aux1 int;
	declare aux2 int;
	declare year int;
    declare month int;
    declare day int;
    declare yday decimal(11,4);
    declare result varchar(20);
    
    set julianDay = JulianDayWithoutTime(julianDay);
    set julianDay = floor(julianDay) + 0.5;
    set depoch = julianDay - JulianDayWithoutTime(DateToJulianDay(475, 1, 1, hour, minute, second));
    set cycle = floor(depoch / 1029983);
	set cyear = MOD(depoch, 1029983);
    
	IF cyear = 1029982 THEN
    	SET ycycle = 2820;
	ELSE
    	SET aux1 = floor(cyear / 366);
    	SET aux2 = MOD(cyear, 366);
    	SET ycycle = floor(((2134 * aux1) + (2816 * aux2) + 2815) / 1028522) + aux1 + 1;
	END IF;

	SET year = ycycle + (2820 * cycle) + 474;

	IF year <= 0 THEN
    	SET year = year - 1;
	END IF;
    
	RETURN year;
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION `JMonthName`(`date` DATETIME) RETURNS varchar(20) CHARSET utf8mb4
    NO SQL
BEGIN
	declare name varchar(20);
    
	case JMONTH(date) 
		when 1  then set name = 'فروردین';
        when 2  then set name = 'اردیبهشت';
        when 3  then set name = 'خرداد';
        when 4  then set name = 'تیر';
        when 5  then set name = 'مرداد';
        when 6  then set name = 'شهریور';
        when 7  then set name = 'مهر';
        when 8  then set name = 'آبان';
        when 9  then set name = 'آذر';
        when 10 then set name = 'دی';
        when 11 then set name = 'بهمن';
        when 12 then set name = 'اسفند';
	end case;
    
	RETURN name;
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION `JulianDayToDate`(`julianDay` DECIMAL(11,4)) RETURNS varchar(20) CHARSET utf8mb4
    NO SQL
BEGIN
	declare hour int default GetHoursOfJulianDay(julianDay);
    declare minute int default GetMinutesOfJulianDay(julianDay);
    declare second int default GetSecondsOfJulianDay(julianDay);
    declare depoch decimal(11,4);
    declare cycle int;
    declare cyear int;
    declare ycycle int;
	declare aux1 int;
	declare aux2 int;
	declare year int;
    declare month int;
    declare day int;
    declare yday decimal(11,4);
    declare result varchar(20);
    
    set julianDay = JulianDayWithoutTime(julianDay);
    set julianDay = floor(julianDay) + 0.5;
    set depoch = julianDay - JulianDayWithoutTime(DateToJulianDay(475, 1, 1, hour, minute, second));
    set cycle = floor(depoch / 1029983);
	set cyear = MOD(depoch, 1029983);
    
	IF cyear = 1029982 THEN
    	SET ycycle = 2820;
	ELSE
    	SET aux1 = floor(cyear / 366);
    	SET aux2 = MOD(cyear, 366);
    	SET ycycle = floor(((2134 * aux1) + (2816 * aux2) + 2815) / 1028522) + aux1 + 1;
	END IF;

	SET year = ycycle + (2820 * cycle) + 474;

	IF year <= 0 THEN
    	SET year = year - 1;
	END IF;

	SET yday = (julianDay - JulianDayWithoutTime(DateToJulianDay(year, 1, 1, hour, minute, second))) + 1;

	IF yday <= 186 THEN
		SET month = ceil(yday / 31);
	ELSE
		SET month = ceil((yday - 6) / 30);
	END IF;

	SET day = (julianDay - JulianDayWithoutTime(DateToJulianDay(year, month, 1, hour, minute, second))) + 1;
    
    SET result = CONCAT(year, '/', month, '/', day, ' ', hour, ':', minute, ':', second);

	RETURN result;
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION `JulianDayToTimestamp`(`julianDay` DECIMAL(11,4)) RETURNS bigint(20)
    NO SQL
BEGIN
	return round((julianDay - 2440587.5) * 86400);
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION `JulianDayWithoutTime`(`julianDay` DECIMAL(11,4)) RETURNS decimal(11,4)
    NO SQL
BEGIN
	return floor(julianDay) + IF(julianDay - floor(julianDay) < 0.5, -0.5, 0.5);
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION `TimestampToJulianDay`(`timestamp` bigint) RETURNS decimal(11,4)
    NO SQL
BEGIN   
    declare julianDay decimal(11,4) default (timestamp / 86400 + 2440587.5);  
    declare julianDayFloatRounded decimal(12,5) default (round((julianDay - floor(julianDay)) * 10000000) / 10000000);

    RETURN floor(julianDay) + julianDayFloatRounded;
END$$
DELIMITER ;
