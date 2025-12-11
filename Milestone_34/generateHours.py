import random
from datetime import date, timedelta
import mysql.connector
from mysql.connector import Error
from dotenv import dotenv_values

def getConn():
    secrets = dotenv_values("setup.env")

    config = {
        "user": secrets["DB_USER"],
        "password": secrets["DB_PASSWORD"],
        "host": secrets["DB_HOST"],
        "database": secrets["DB_NAME"],
        "raise_on_warnings": True #not in .env file
    }

    try:
        conn = mysql.connector.connect(**config)
        if not conn.is_connected():
            print("Could not connect to database.")
            return None
        
        return conn
        
    except Error as e:
        print("Error: ", e)
        return None    

def generateDateRange(startDate, endDate):
    dates = []
    current = startDate
    while current <= endDate: # This While loop iterates through the dates from start to finish and one by one adds them to a list.
        dates.append(current)
        current += timedelta(days=1)
    return dates


def generateWeekdayHours():
    roll = random.random()
    if roll < 0.05: # Absent: None (means no punch)
        return None
    elif roll < 0.15: # Short day: 3–6 hours
        return round(random.uniform(3, 6), 2) 
    else: # Typical: 7.5–8.5 hours
        return round(random.uniform(7.5, 8.5), 2)


def generateSaturdayHours(): # Saturday logic:
    if random.random() < 0.20: # 20% chance of overtime (5–8 hours)
        return round(random.uniform(5, 8), 2)
    return None # Otherwise: absent, meaning no punch


def buildHoursEntries(employeeIDs, startDate, endDate):
    allRows = []
    allDates = generateDateRange(startDate, endDate)

    # Nested for loop iterates through employees, then dates to generate psudo random punches for every employee for 6 months.
    for empID in employeeIDs:
        for d in allDates:
            weekday = d.weekday() # Tells what day of the week it is using datetime (0-4 is Mon-Fri)

            if weekday < 5: # Mon-Fri
                hours = generateWeekdayHours()
            elif weekday == 5: # Sat for Possible Overtime
                hours = generateSaturdayHours()
            else: # Sunday — no punches
                hours = None

            # Skip absences
            if hours is None:
                continue

            allRows.append((empID, d.isoformat(), hours))   # Adds the time punch to list of ALL punches for all employees
                                                            # isoformat() formats the date as "yyyy-mm-dd"

    return allRows


def main():
    # List of EmployeeIDs
    employeeIDs = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26]

    # Creates date object in datetime for start and end date.
    startDate = date(2025, 6, 1)
    endDate = date(2025, 11, 30)

    rows = buildHoursEntries(employeeIDs, startDate, endDate)

    insertSQL = "INSERT INTO Hours (EmployeeID, DateWorked, HoursWorked) VALUES (%s, %s, %s)"

    conn = getConn()
    cur = conn.cursor()

    try:
        cur.execute("TRUNCATE TABLE Hours;") # Removes any data in the table

        for empID, d, hrs in rows: # Populates the table with new data
            cur.execute(insertSQL, (empID, d, hrs))
        conn.commit()    # commits the changes if and only if all inserts worked.
        print("Hours Generated Successfully")
    
    except Error as e:
        print("Error: ", e)
        conn.rollback() # Rollback the database if a SINGLE statement failed.
    
    finally:
        cur.close()
        conn.close()
    


if __name__ == "__main__":
    main()