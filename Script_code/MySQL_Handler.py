# imports
import datetime
import glob
import os
import mysql.connector
from QF_Credentials import get_MySql_credentials
from Workbooks import *


# ----------------------------------------------------------------------------------------------------------------------
# get cursor and connection credentials
def get_connection():
    # establishing the connection
    db_host, db_user, db_password, db_name = get_MySql_credentials()
    conn = mysql.connector.connect(
        host=db_host,
        user=db_user,
        passwd=db_password,
        database=db_name,
        port=3313
    )
    return conn


# ----------------------------------------------------------------------------------------------------------------------
# write to mysql table - TableauCatalogData
def write_to_mysql_db_process():
    # for cutting the file
    print(os.getcwd())
    conn = get_connection()
    mycursor = conn.cursor()
    root = glob.glob("*.sql")
    root.sort()
    # loop all over the sqls files
    for item in root:
        # get item content
        file = open(item, 'r')
        file_content = file.read()
        file.close()
        report = item.replace('.sql', '')
        report_id = get_workbook_id(report)
        if report_id is None:
            print("can't find report id for "+str(report))
            print("moving on..")
            continue
        # Preparing SQL query to INSERT a record into the database.
        insert_stmt = (
            "INSERT INTO tableau_catalog_data(report_name,stats_date,report_id,query)"
            "VALUES (%s, %s, %s, %s)"
        )
        data = (report, datetime.date.today(), report_id, file_content)
        try:
            # Executing the SQL command
            mycursor.execute(insert_stmt, data)
            # Commit your changes in the database
            conn.commit()
            print("transaction for "+str(report)+" was created")
        except mysql.connector.Error as err:
            print("Something went wrong: {}".format(err))
            print("can't complete the process - workbook"+str(report)+" has problems")
            # Rolling back in case of error
            conn.rollback()
            exit()
    print("Data inserted")
    # Closing the connection
    conn.close()


