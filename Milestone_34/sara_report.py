# Sara White
# CSD-310
# Group Project - Bacchus Winery Report
# Expected vs. Actual Deliveryf

import mysql.connector
from mysql.connector import Error
import dotenv
from dotenv import dotenv_values

import mysql.connector
from mysql.connector import Error
from dotenv import dotenv_values

secrets = dotenv_values("setup.env")

config = {
    "user": secrets["DB_USER"],
    "password": secrets["DB_PASSWORD"],
    "host": secrets["DB_HOST"],
    "database": secrets["DB_NAME"],
    "raise_on_warnings": True
}

def printAlignedData(cursor, data):
    """Print rows in aligned columns, using cursor.description for headers."""

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
        return

    for row in strData:
        print(formatString.format(*row))


def main():
    try:
        conn = mysql.connector.connect(**config)
        if not conn.is_connected():
            print("Could not connect to database.")
            return

        cursor = conn.cursor()

        # Report: expected vs actual delivery
        query = """
            SELECT 
                sd.InvoiceID,
                s.SupplierName,
                sd.ExpectedDelivery,
                sd.ActualDelivery,
                DATEDIFF(sd.ActualDelivery, sd.ExpectedDelivery) AS DaysDifference,
                CASE 
                    WHEN sd.ActualDelivery IS NULL THEN 'Pending'
                    WHEN sd.ActualDelivery < sd.ExpectedDelivery THEN 'Early'
                    WHEN sd.ActualDelivery = sd.ExpectedDelivery THEN 'On Time'
                    WHEN sd.ActualDelivery > sd.ExpectedDelivery THEN 'Late'
                END AS DeliveryStatus
            FROM SupplierDelivery AS sd
            INNER JOIN Supplier AS s
                ON sd.SupplierID = s.SupplierID
            ORDER BY sd.ExpectedDelivery, sd.InvoiceID;
        """

        cursor.execute(query)
        rows = cursor.fetchall()

        print("=" * 70)
        print("Supplier Delivery Report - Expected vs Actual")
        print("=" * 70)
        printAlignedData(cursor, rows)

        cursor.close()
        conn.close()

    except Error as e:
        print("Error:", e)


if __name__ == "__main__":
    main()

