from Os_Functions import *
from QF_Credentials import *
# to get more the 100 results from Tableau
from QF_Credentials import get_tableau_auth_data, get_prod_tableau_server_data

req_options = TSC.RequestOptions(pagesize=1000)


# ----------------------------------------------------------------------------------------------------------------------
# get all workbook name's from the server
def get_all_workbook_ids():
    tableau_auth = get_tableau_auth_data()
    prod_server = get_prod_tableau_server_data()
    try:
        with prod_server.auth.sign_in(tableau_auth):
            all_workbooks_items, pagination_item = prod_server.workbooks.get(req_options)
    except Exception as e:
        print("There was an issue with get_all_workbook_ids function : " + str(e))
        exit()
    workbook_ids = []
    for item in all_workbooks_items:
        workbook_ids.append(item.id)
    return workbook_ids


# ----------------------------------------------------------------------------------------------------------------------
# remove unwanted characters form workbook name
def removing_unwanted_characters(name):
    bad_chars = [';', ':', '!', '*', "\'", '&', '/']
    for char in bad_chars:
        name = name.replace(char, '')
    return name


# ----------------------------------------------------------------------------------------------------------------------
# get workbook name and return the id from the prod server
def get_workbook_id(name):
    tableau_auth = get_tableau_auth_data()
    prod_server = get_prod_tableau_server_data()
    try:
        with prod_server.auth.sign_in(tableau_auth):
            all_workbooks_items, pagination_item = prod_server.workbooks.get(req_options)
    except Exception as e:
        print("There was an issue with get_all_workbook_ids function : " + str(e))
        exit()
    for item in all_workbooks_items:
        if item.name == name:
            return item.id
    return None


# ----------------------------------------------------------------------------------------------------------------------
# get workbook id and return the name of the workbook from the prod server
def get_workbook_name(workbook_id):
    tableau_auth = get_tableau_auth_data()
    prod_server = get_prod_tableau_server_data()
    try:
        with prod_server.auth.sign_in(tableau_auth):
            all_workbooks_items, pagination_item = prod_server.workbooks.get(req_options)
    except Exception as e:
        print("There was an issue with get_all_workbook_ids function : " + str(e))
        exit()
    for item in all_workbooks_items:
        if item.id == workbook_id:
            return item.name
    return None


# ----------------------------------------------------------------------------------------------------------------------
# download all workbooks and store them in the Workbooks_storage folder
def fixing_workbook_name(workbook_name, response):
    # if workbook_name is matched to response - do nothing
    if workbook_name in response:
        return
    # get the generated name from the response
    x = response.split('/')
    file_name = x[len(x)-1]
    workbook_name = workbook_name.replace('/', '')
    if 'twbx' in file_name:
        workbook_name = workbook_name+'.twbx'
    else:
        workbook_name = workbook_name+'.twb'
    # change the workbook name to the correct one from tableau server
    os.rename(file_name, workbook_name)


def download_workbooks_to_storage(workbook_ids):
    tableau_auth = get_tableau_auth_data()
    prod_server = get_prod_tableau_server_data()
    print("print the path for storing the files")
    print(os.getcwd())
    with prod_server.auth.sign_in(tableau_auth):
        try:
            for workbook_id in workbook_ids:
                # example of response - '/Users/omlevi/Documents/tableau_catalog/_User Access.twb'
                response = prod_server.workbooks.download(workbook_id, no_extract=True)
                # get workbook name from tableau server
                workbook_name = get_workbook_name(workbook_id)
                # fixing the issue when the workbook name and the response aren't match
                fixing_workbook_name(workbook_name, response)
                print("\nDownloaded the file {0}.".format(workbook_name))
        except Exception as e:
            print("There was an issue with download_workbooks_to_storage function : " + str(e))
            print("stopping the program")
            delete_older_files()
            exit()
    print("Finishing download all workbooks")


