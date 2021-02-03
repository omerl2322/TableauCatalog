import glob
import os
import subprocess
import sys

from QF_Credentials import *


# ----------------------------------------------------------------------------------------------------------------------
# check what platform do I have
def check_my_platform():
    my_platform = sys.platform
    operation_sys = ''
    if my_platform == "linux" or my_platform == "linux2":
        operation_sys = "linux"
    elif my_platform == "darwin":
        operation_sys = "mac os x"
    elif my_platform == "win32":
        operation_sys = "windows"
    else:
        operation_sys = "None"
    return operation_sys


# ----------------------------------------------------------------------------------------------------------------------
# delete all the content under Workbooks_storage
def delete_folder_content():
    print(os.getcwd())
    file_path = get_files_path()+'*'
    root = glob.glob(file_path)
    if len(root) != 0:
        for item in root:
            os.remove(item)
        print("delete all content - the folder is empty")
    else:
        print("there was nothing to delete from folder")


# ----------------------------------------------------------------------------------------------------------------------
# run the tabtosql command on command line
# example tabtosql _User\ Access.twb > _User\ Access.sql
def run_command_on_commandline(command):
    # store the command output in variable
    try:
        output1 = subprocess.run(command, shell=True, capture_output=True, text=True)
        output_string = output1.stdout
        stderr_string = output1.stderr
        print(output_string)
        print(stderr_string)
    except Exception as e:
        print("There was an issue tab to sql command: " + str(e))
        exit()


# ----------------------------------------------------------------------------------------------------------------------
# take all the files in workbook_ storage and moves them to Tableau portal repo
def move_files_to_repo():
    # we are in the workbook_storage path
    repo_path = get_repo_path()
    # move only the sql files
    command = "mv *.sql "+repo_path
    print(os.getcwd())
    os.chdir("Workbooks_storage")
    print(os.getcwd())
    run_command_on_commandline(command)
    # go back to root dir
    os.chdir("..")
    print(os.getcwd())
    delete_folder_content()


# ----------------------------------------------------------------------------------------------------------------------
# delete unnecessary files - twb or twbx from the workbooks_storage folder
def remove_unnecessary_files():
    print(os.getcwd())
    command1 = "rm *.twb"
    command2 = "rm *.twbx"
    print("delete all twb files")
    run_command_on_commandline(command1)
    print("delete all twbx files")
    run_command_on_commandline(command2)


# ----------------------------------------------------------------------------------------------------------------------
# delete the older content from Tableau_Catalog folder
def delete_older_files():
    print(os.getcwd())
    delete_command_sql = "rm *.sql"
    delete_command_twb = "rm *.twb"
    delete_command_twbx = "rm *.twbx"
    print("starting delete files process")
    run_command_on_commandline(delete_command_sql)
    print("delete all old sql files")
    run_command_on_commandline(delete_command_twb)
    print("delete all old twb files")
    run_command_on_commandline(delete_command_twbx)
    print("delete all old twbx files")
