# imports
import os
import tabtosql
from Script_code.Git_Handler import push_to_git_repo
from Script_code.Os_Functions import remove_unnecessary_files, delete_older_files
from Script_code.Tab_To_Sql import tabtosql_workbook
from Script_code.Workbooks import get_all_workbook_ids, download_workbooks_to_storage
from Script_code.MySQL_Handler import *


# the main process for Tableau catalog
from Script_code.MySQL_Handler import write_to_mysql_db_process


def main():
    print(os.getcwd())
    os.chdir("..")
    print("delete all the older content")
    delete_older_files()
    print("getting all workbook ids")
    workbook_ids = get_all_workbook_ids()
    print("download the workbooks without the extracts")
    # example:
    # workbook_ids =['24a6443a-7106-4d97-b26d-5ea405fe684b', '84929525-2c29-44b3-a421-05efed972f3c']
    download_workbooks_to_storage(workbook_ids)
    print("running for each workbook the tab to sql command")
    tabtosql_workbook()
    print("checking if something went wrong")
    print("delete unnecessary files - twb or twbx")
    remove_unnecessary_files()
    print("push to git repo")
    push_to_git_repo()
    print("write transaction to MySQL db ")
    write_to_mysql_db_process()
    print("finish the process")


if __name__ == '__main__':
    main()