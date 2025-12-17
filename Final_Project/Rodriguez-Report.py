# Blue Group -  CSD-310
# Carolina Rodriguez
#Report for Wine Distribution and Sales

import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv
import os

# Load .env file
load_dotenv("setup.env")

# Read database credentials from environment variables
db_user = os.getenv("DB_USER")
db_password = os.getenv("DB_PASSWORD")
db_host = os.getenv("DB_HOST")
db_database = os.getenv("DB_NAME")

if not all([db_user, db_password, db_host, db_database]):
    raise ValueError("One or more database environment variables are missing in setup.env")

config = {
     "host": db_host,
    "user": db_user,
    "password": db_password,
    "database": db_database,
    "raise_on_warnings": True #not in .env file
}

# Function to print data in aligned columns

def printAlignedData(cursor, data):
    headers = [desc[0] for desc in cursor.description]

    strData = [[("" if col is None else str(col)) for col in row] for row in data]

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

    if not data:
        print("(No Data to Display)")

    for row in strData:
        print(formatString.format(*row))


def run_query(cursor, query, description):
    print("\n" + "="*70)
    print(description)
    print("-"*70)
    cursor.execute(query)
    rows = cursor.fetchall()
    printAlignedData(cursor, rows)

def main():
    try:
        conn = mysql.connector.connect(**config)
        if not conn.is_connected():
            print("Could not connect to database.")
            return
        cursor = conn.cursor()

        # SQL Wine distribution, ordered by distributor
        wineByDist = """
        SELECT 
            w.WineID,
            w.WineName,
            w.YearProduced,
            d.DistID,
            d.DistName
        FROM distributor d
        JOIN distorder o
            ON d.DistID = o.DistID
        JOIN distitemorderid doi
            ON o.OrderID = doi.OrderID
        JOIN wine w 
            ON doi.WineID = w.WineID
        ORDER BY d.DistID, d.DistName
        LIMIT 0, 30;
        """
        #
        run_query(cursor, wineByDist, "Wine Distribution (by Distributor)")

        # Total sold per wine
        wineSold = """
        SELECT 
            w.WineID,
            w.WineName,
            w.YearProduced,
            SUM(dio.Quantity) AS TotalSold
        FROM Wine w
        JOIN DistItemOrderID dio 
            ON w.WineID = dio.WineID
        GROUP BY 
            w.WineID, 
            w.WineName, 
            w.YearProduced
        ORDER BY TotalSold DESC;
        """
        run_query(cursor, wineSold, "Total Sold per Wine")

        # Wines that haven't sold
        wineNOTsold = """
        SELECT 
            w.WineID,
            w.WineName,
            w.YearProduced,
            COALESCE(SUM(dio.Quantity), 0) AS NotSold
        FROM wine w
        LEFT JOIN distitemorderId dio
            ON w.WineID = dio.WineID
        GROUP BY w.WineID, w.WineName, w.YearProduced
        HAVING NotSold = 0
        ORDER BY w.WineID;
        """
        run_query(cursor, wineNOTsold, "Wines That Haven't Sold")

        cursor.close()
        conn.close()

    except Error as e:
        print("Error: ", e)

if __name__ == "__main__":
    main()








