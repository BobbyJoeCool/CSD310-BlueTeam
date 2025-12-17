import random
from datetime import date, datetime, timedelta, time
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
        "raise_on_warnings": True
    }

    try:
        conn = mysql.connector.connect(**config)
        if not conn.is_connected():
            print("Could not connect to database.")
            return None
        return conn

    except Error as e:
        print("Error:", e)
        return None


def generateDateRange(startDate, endDate):
    dates = []
    current = startDate
    while current <= endDate:
        dates.append(current)
        current += timedelta(days=1)
    return dates


def generateWeekdayHours():
    roll = random.random()
    if roll < 0.05:          # Absent
        return None
    elif roll < 0.15:        # Short day
        return round(random.uniform(3, 6), 2)
    else:                    # Normal day
        return round(random.uniform(7.5, 8.5), 2)


def generateSaturdayHours():
    if random.random() < 0.20:   # Overtime
        return round(random.uniform(5, 8), 2)
    return None


def generateShiftTimes(workDate, hours):
    # Returns (StartShift, EndShift) as datetime objects
    baseMinutes = 8 * 60 # Sets the base time for 8:00

    offset = int(random.triangular(-60, 60, 0)) # Generates a random "offset" within 1 hour, weighted to 0.

    totalMinutes = baseMinutes + offset # Adds the offset to the Start Time

    startHour = totalMinutes // 60 # Calculates hour of start
    startMinute = totalMinutes % 60 # Calculates minute of start.

    startDT = datetime.combine(
        workDate,
        time(hour=startHour, minute=startMinute)
    ) # Creates the "start time object" by combining the random hour, minute, 

    endDT = startDT + timedelta(hours=hours) # Creates the end time by adding the total hours worked to the start time.

    return startDT, endDT


def buildHoursEntries(employeeIDs, startDate, endDate):
    allRows = []
    allDates = generateDateRange(startDate, endDate)

    for empID in employeeIDs:
        for d in allDates:
            weekday = d.weekday()

            if weekday < 5:
                hours = generateWeekdayHours()
            elif weekday == 5:
                hours = generateSaturdayHours()
            else:
                hours = None

            if hours is None:
                continue

            startShift, endShift = generateShiftTimes(d, hours)

            allRows.append(
                (empID, startShift, endShift, hours)
            )

    return allRows


def main():
    employeeIDs = [
        6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
        16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26
    ]

    startDate = date(2024, 12, 1)
    endDate = date(2025, 11, 30)

    rows = buildHoursEntries(employeeIDs, startDate, endDate)

    insertSQL = """
        INSERT INTO Hours
        (EmployeeID, StartShift, EndShift, HoursWorked)
        VALUES (%s, %s, %s, %s)
    """

    conn = getConn()
    cur = conn.cursor()

    try:
        cur.execute("TRUNCATE TABLE Hours;")

        cur.executemany(insertSQL, rows)
        conn.commit()

        print("Hours generated successfully.")

    except Error as e:
        print("Error:", e)
        conn.rollback()

    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    main()
