# Breutzmann, Robert
# Python Script to Query the Database for hours worked by the employees

# Objective - Generate report of average hours worked by each employee in the last quarter (using month since we made one month's worth of time punches)

import mysql.connector
from mysql.connector import Error
from dotenv import dotenv_values

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
    cur.execute("""
                SELECT 
                    e.EmployeeID,
                    e.FirstName,
                    e.LastName,
                    SUM(h.HoursWorked) / 4.0 AS AvgHoursPerWeek
                FROM Employee e
                LEFT JOIN Hours h
                    ON e.EmployeeID = h.EmployeeID
                WHERE h.DateWorked BETWEEN '2025-11-03' AND '2025-11-28'
                GROUP BY e.EmployeeID, e.FirstName, e.LastName
                ORDER BY AvgHoursPerWeek DESC
                """)
    byHour = cur.fetchall()
    
    cur.execute("""
                SELECT 
                    e.EmployeeID,
                    e.FirstName,
                    e.LastName,
                    SUM(h.HoursWorked) / 4.0 AS AvgHoursPerWeek
                FROM Employee e
                LEFT JOIN Hours h
                    ON e.EmployeeID = h.EmployeeID
                WHERE h.DateWorked BETWEEN '2025-11-03' AND '2025-11-28'
                GROUP BY e.EmployeeID, e.FirstName, e.LastName
                ORDER BY e.LastName, e.FirstName
                """)
    byName =cur.fetchall()
    cur.close()
    print(byHour) # for testing the output
    print(byName) # for testing the output
    return byHour, byName

def displayTable(table):
    headers = ["Last Name", "First Name", "Hours/Week"]
    strData = [[("" if col is None else str(col)) for col in row] for row in table]

    colWidth = []
    for colIDX in range(len(headers)):
        longest = len(headers[colIDX])
        for row in strData:
            longest = max(longest, len(row[colIDX]))
        colWidth.append(longest)

    formatString = " | ".join("{:<" + str(width) + "}" for width in colWidth)

    print(formatString.format(*headers))

    separatorLength = sum(colWidth) + (3 * (len(headers) - 1))
    print("-" * separatorLength)

    if not table:
        print("(No Data to Display)")

    for row in strData:
        print(formatString.format(*row))

def formatData(table):
    reformatedTable = []
    for row in table:
        empID, first, last, hours = row
        roundedHours = float(round(hours, 2))

        reformatedTable.append((last, first, roundedHours))
    
    return reformatedTable

def main():
    try:
        conn = mysql.connector.connect(**config)
        if not conn.is_connected():
            print("Could not connect to database.")
            return

        byHour, byName = fetchHoursWorked(conn)
        byHour = formatData(byHour)
        byName = formatData(byName)
        print(f"\nEmployee's organized by Hours Worked")
        displayTable(byHour)
        print(f"\nEmployee's organized by Last Name")
        displayTable(byName)

        conn.close()

    except Error as e:
        print("Error: ", e)

if __name__ == "__main__":
    main()