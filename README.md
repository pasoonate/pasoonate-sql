# 🚀 Pasoonate MariaDB SQL Functions

This project provides a set of **custom SQL functions** for **MariaDB** to handle operations related to the **Persian calendar (Jalali calendar)** and **Julian day conversions**. These functions are ideal for projects requiring **advanced date and time computations** with Persian dates.

---

## 📌 Features

### 🗓️ Date Conversion Functions
- `jdate2timestamp` ➝ Converts a **Jalali date** to a **Unix timestamp**.
- `timestamp2jdatetime` ➝ Converts a **Unix timestamp** to a **Jalali datetime string**.
- `timestamp2jdate` ➝ Converts a **Unix timestamp** to a **Jalali date string**.
- `jleap` ➝ Checks if a **Jalali year** is a **leap year**.

### 🔢 Julian Day Functions
- `DateToJulianDay` ➝ Converts a **Gregorian date** to a **Julian Day**.
- `AddTimeToJulianDay` ➝ Adds time (**hours, minutes, seconds**) to a **Julian Day**.
- `GetHoursOfJulianDay`, `GetMinutesOfJulianDay`, `GetSecondsOfJulianDay` ➝ Extracts **hours, minutes, and seconds** from a Julian Day.
- `GetTimeOfJulianDay` ➝ Returns the **time portion** of a Julian Day as a **string**.
- `JulianDayToDate` ➝ Converts a **Julian Day** to a **Gregorian date**.
- `JulianDayToTimestamp` ➝ Converts a **Julian Day** to a **Unix timestamp**.
- `JulianDayWithoutTime` ➝ Removes the **time portion** from a Julian Day.
- `TimestampToJulianDay` ➝ Converts a **Unix timestamp** to a **Julian Day**.

### 📅 Jalali Date Functions
- `JDate` ➝ Returns a **formatted Jalali date string**.
- `JDay`, `JMonth`, `JYear` ➝ Extracts the **day, month, and year** from a **Jalali date**.
- `JMonthName` ➝ Returns the **name of the Jalali month**.

---

## 🛠️ Installation & Usage

### ✅ Database Setup
Ensure that you are using **MariaDB** as your database engine.

### 📥 Import Functions
1. Open your terminal and connect to your **MariaDB** instance:
   ```bash
   mysql -u [username] -p
   ```
2. Import the SQL file:
   ```sql
   source /path/to/pasoonate-mariadb.sql;
   ```
   🔹 Replace `/path/to/` with the correct file path.

### 🔍 Function Usage
You can now call the functions in your **SQL queries**:

```sql
-- Convert a Unix timestamp to a Jalali datetime
SELECT timestamp2jdatetime(1700000000);

-- Convert a Jalali date to a Unix timestamp
SELECT jdate2timestamp(1402, 10, 29, 15, 30, 0);

-- Convert a Unix timestamp to a Jalali date
SELECT timestamp2jdate(1672531199);

-- Check if a Jalali year is a leap year
SELECT jleap(1402);

-- Convert a Gregorian date to a Julian Day
SELECT DateToJulianDay(2023, 1, 1, 0, 0, 0);
```

### 📌 Examples
```sql
SELECT timestamp2jdate(UNIX_TIMESTAMP('2023-01-01 00:00:00'));
-- Output: 1401/10/11

SELECT JMonthName('2023-01-01 00:00:00');
-- Output: دی

SELECT JulianDayToDate(2459945.5);
-- Output: 2023/1/1 0:0:0

SELECT jleap(1402);
-- Output: 0 (not a leap year)
```

---

## 🏆 Contributing
Contributions are welcome! Feel free to **fork** this repository and submit a **pull request**. 😊

---

## 📜 License
This project is **open-source** and available under the **MIT License**.
