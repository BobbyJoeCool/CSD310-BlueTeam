# Blue Group -  CSD-310
# Carolina Rodriguez
# Robert Breutzmann
# Sara White


import mysql.connector
from mysql.connector import Error
import dotenv
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


def printTableSchema(cursor, table):
    print(f"\n{"="*70}")
    print(f"Table Schema: {table}")
    print("-"*70)

    cursor.execute(f"SHOW FULL COLUMNS FROM {table};")
    columns = cursor.fetchall()
    printAlignedData(cursor, columns)

def printTableRows(cursor, table):
    print(f"\n{"="*70}")
    print(f"Data in table: {table}")
    print("-"*70)

    cursor.execute(f"SELECT * FROM {table};")
    rows = cursor.fetchall()
    printAlignedData(cursor, rows)

def main():
    try:
        conn = mysql.connector.connect(**config)
        if not conn.is_connected():
            print("Could not connect to database.")
            return
        cursor = conn.cursor()

        cursor.execute("SHOW TABLES;")
        tables = [t[0] for t in cursor.fetchall()]
        print(f"Found Tables: {tables}\n")

        # for table in tables:
        #     printTableSchema(cursor, table)

        for table in tables:
            printTableRows(cursor, table)

        cursor.close()
        conn.close()

    except Error as e:
        print("Error: ", e)

if __name__ == "__main__":
    main()