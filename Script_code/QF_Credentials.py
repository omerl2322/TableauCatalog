import tableauserverclient as TSC


# Connect to Vertica database

# ------------------------------------------------------------------------------------------------
# Connect to Tableau Server's PostgreSQL database
def get_tableau_postgresql_credentials():
    host = 'XXX'
    dbname = 'workgroup'
    user = 'XXX'
    port = '8060'
    password = 'P@ssw0rd'
    return ("dbname=" + str(dbname) + " user=" + str(user) + " host=" + str(host) + " port=" + str(
        port) + " password=" + str(password))


# ------------------------------------------------------------------------------------------------
# get Prod Tableau Server login data
def get_prod_tableau_server_data():
    server_prod = TSC.Server('XXX', use_server_version=True)
    return server_prod


# ------------------------------------------------------------------------------------------------
def get_tableau_auth_data():
    tableau_auth = TSC.TableauAuth('XXX', 'XXX', site_id='')
    return tableau_auth


# ------------------------------------------------------------------------------------------------
def get_files_path():
    return 'Workbooks_storage/'


# ------------------------------------------------------------------------------------------------
def get_repo_path():
    return '/Tableau_Catalog/Workbooks_storage'


# ------------------------------------------------------------------------------------------------
def get_repo_url():
    return 'XXX'


# ------------------------------------------------------------------------------------------------
def get_MySql_credentials():
    user = 'XXX'
    db_password = 'NJasy33@32'
    host = 'XXX'
    dbname = 'XXX'
    return host, user, db_password, dbname
