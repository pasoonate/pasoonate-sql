# Pasoonate MariaDB SQL Functions

This project provides a set of custom SQL functions for MariaDB to handle operations related to the Persian calendar (Jalali calendar) and Julian day conversions. These functions are intended for projects that require advanced date and time computations involving Persian dates.

## Functions Overview

The following SQL functions are included in this repository:

1. **Date Conversion Functions**:
   - `jdate2timestamp`: Converts a Jalali date to a Unix timestamp.
   - `timestamp2jdatetime`: Converts a Unix timestamp to a Jalali datetime string.
   - `timestamp2jdate`: Converts a Unix timestamp to a Jalali date string.
   - `jleap`: Checks if a given Jalali year is a leap year.

2. **Julian Day Functions**:
   - `DateToJulianDay`: Converts a Gregorian date to a Julian Day.
   - `AddTimeToJulianDay`: Adds time (hours, minutes, seconds) to a Julian Day.
   - `GetHoursOfJulianDay`, `GetMinutesOfJulianDay`, `GetSecondsOfJulianDay`: Extracts hours, minutes, and seconds from a Julian Day.
   - `GetTimeOfJulianDay`: Returns the time portion of a Julian Day as a string.
   - `JulianDayToDate`: Converts a Julian Day to a Gregorian date string.
   - `JulianDayToTimestamp`: Converts a Julian Day to a Unix timestamp.
   - `JulianDayWithoutTime`: Removes the time portion from a Julian Day.
   - `TimestampToJulianDay`: Converts a Unix timestamp to a Julian Day.

3. **Jalali Date Functions**:
   - `JDate`: Returns a formatted Jalali date string.
   - `JDay`, `JMonth`, `JYear`: Extracts the day, month, and year from a Jalali date.
   - `JMonthName`: Returns the name of the Jalali month.

## Usage

1. **Database Setup:** Ensure that you are using MariaDB as your database engine.

2. **Import Functions:**
   - Open your terminal and connect to your MariaDB instance:
     ```bash
     mysql -u [username] -p
     ```
   - Import the SQL file:
     ```sql
     source /path/to/pasoonate-mariadb.sql;
     ```
     Replace `/path/to/` with the correct file path.

3. **Function Usage:**  
   You can now call the functions in your SQL queries. Examples:
   ```sql
   SELECT timestamp2jdatetime(1700000000);
   SELECT jdate2timestamp(1402, 10, 29, 15, 30, 0);
   
   -- Convert a Unix timestamp to a Jalali date
   SELECT timestamp2jdate(1672531199);
    
   -- Check if a Jalali year is a leap year
   SELECT jleap(1402);
    
   -- Convert a Gregorian date to a Julian Day
   SELECT DateToJulianDay(2023, 1, 1, 0, 0, 0);
   ```
4. **Examples:**
   ```sql
    SELECT timestamp2jdate(UNIX_TIMESTAMP('2023-01-01 00:00:00'));
    -- Output: 1401/10/11
    
    SELECT JMonthName('2023-01-01 00:00:00');
    -- Output: دی
    
    SELECT JulianDayToDate(2459945.5);
    -- Output: 2023/1/1 0:0:0
    
    SELECT jleap(1402);
    -- Output: 0 (not a leap year)
