# Breutzmann, Robert
# Python Script to Query the Database for hours worked by the employees

# Objective - Generate report of average hours worked by each employee in the last quarter (using month since we made one month's worth of time punches)

import mysql.connector
from mysql.connector import Error
from dotenv import dotenv_values
from datetime import datetime, timedelta

#using our .env file
secrets = dotenv_values("setup.env")

config = {
    "user": secrets["DB_USER"],
    "password": secrets["DB_PASSWORD"],
    "host": secrets["DB_HOST"],
    "database": secrets["DB_NAME"],
    "raise_on_warnings": True #not in .env file
}

def fetchHoursWorked(conn):
    cur = conn.cursor()

    query = """
        SELECT
            e.EmployeeID,
            d.Name,
            e.FirstName,
            e.LastName,

            ROUND(SUM(CASE
                WHEN h.StartShift BETWEEN '2024-12-01' AND '2025-02-28'
                THEN h.HoursWorked END) / 13, 2) AS Q1_Avg,

            ROUND(SUM(CASE
                WHEN h.StartShift BETWEEN '2025-03-01' AND '2025-05-31'
                THEN h.HoursWorked END) / 13, 2) AS Q2_Avg,

            ROUND(SUM(CASE
                WHEN h.StartShift BETWEEN '2025-06-01' AND '2025-08-31'
                THEN h.HoursWorked END) / 13, 2) AS Q3_Avg,

            ROUND(SUM(CASE
                WHEN h.StartShift BETWEEN '2025-09-01' AND '2025-11-30'
                THEN h.HoursWorked END) / 13, 2) AS Q4_Avg,

            ROUND(SUM(h.HoursWorked) / 52, 2) AS Yearly_Avg

        FROM Employee e
        INNER JOIN Hours as h
            ON e.EmployeeID = h.EmployeeID
        INNER JOIN Department as d
            On e.DeptID = d.DeptID
        GROUP BY e.EmployeeID, e.FirstName, e.LastName
        ORDER BY d.Name, e.LastName, e.FirstName;
    """

    cur.execute(query)
    results = cur.fetchall()
    cur.close()

    return results

def displayTable(table):
    headers = [
        "Department",
        "Last Name",
        "First Name",
        "Q1 Avg",
        "Q2 Avg",
        "Q3 Avg",
        "Q4 Avg",
        "Year Avg"
    ]

    strData = [[("" if col is None else str(col)) for col in row] for row in table]

    colWidth = []
    for colIDX in range(len(headers)):
        longest = len(headers[colIDX])
        for row in strData:
            longest = max(longest, len(row[colIDX]))
        colWidth.append(longest)

    formatString = " | ".join("{:<" + str(width) + "}" for width in colWidth)

    print(formatString.format(*headers))
    print("-" * (sum(colWidth) + 3 * (len(headers) - 1)))

    if not table:
        print("(No Data to Display)")
        return

    for row in strData:
        print(formatString.format(*row))

def formatData(table):
    formatted = []
    for row in table:
        empID, dept, first, last, q1, q2, q3, q4, year = row
        formatted.append((
            dept,
            last,
            first,
            q1 or 0,
            q2 or 0,
            q3 or 0,
            q4 or 0,
            year or 0
        ))
    return formatted

def main():
    try:
        conn = mysql.connector.connect(**config)
        if not conn.is_connected():
            print("Could not connect to database.")
            return

        results = fetchHoursWorked(conn)
        results = formatData(results)

        print("\nAverage Hours Worked Per Quarter (Last Year)")
        displayTable(results)

        conn.close()

    except Error as e:
        print("Error:", e)

if __name__ == "__main__":
    main()