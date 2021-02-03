import glob
from collections import OrderedDict
import os
import re
import xml.etree.ElementTree as ET
import zipfile

LINE_BIG = 77
LINE_SMALL = 50


# ----------------------------------------------------------------------------------------------------------------------
def return_xml(filename):
    """Load twb XML into memory & return root object."""
    _validate_file(filename)

    if filename.endswith('.twbx'):
        return _parse_twbx(filename)

    return ET.parse(filename).getroot()


# ----------------------------------------------------------------------------------------------------------------------
def _validate_file(filename):
    """Validate given file is acceptable for processing."""
    if not os.path.isfile(filename):
        raise OSError('%s is not a valid file path.' % filename)

    if filename.split('.')[-1] not in ('twb', 'twbx'):
        raise OSError('%s is not a valid tableau file.' % filename)


# ----------------------------------------------------------------------------------------------------------------------
def _parse_twbx(filename):
    """Parse twbx zip & return twb XML."""
    with open(filename, 'rb') as infile:
        twbx = zipfile.ZipFile(infile)

        for item in twbx.namelist():
            if item.endswith('.twb'):
                twb = twbx.open(item)
                return ET.parse(twb).getroot()


# ----------------------------------------------------------------------------------------------------------------------
def parse_queries(datasources, connections):
    """Parse query&table xml objects & return cleaned values."""
    results = OrderedDict()
    datasources = [i for i in datasources if 'caption' in i.attrib]

    for datasource, connection in zip(datasources, connections):
        name = datasource.attrib['caption']
        conn = datasource.find('connection/relation')
        if conn is None:
            # version 2020.3
            if connection is None:
                continue
            else:
                conn = connection
        query = conn.text if conn.text else '-- LINKED TO: %s' % conn.attrib['table']

        query = query.replace('<<', '<').replace('>>', '>')

        # TODO: Should be handling for universal newlines better (ie \r\n)
        results[name] = re.sub(r'\r\n', r'\n', query)

    return results


# ----------------------------------------------------------------------------------------------------------------------
def format_queries(queries):
    """Format datasources object for outfile."""
    output = '-- Queries %s\n' % ('-' * (LINE_BIG - 11))

    for query in queries:
        output += '-- %s %s\n' % (query, '-' * (LINE_SMALL - 4 - len(query)))
        output += queries[query]
        output += '\n;%s' % ('\n' * 3)

    return output


# ----------------------------------------------------------------------------------------------------------------------
# the main function for tabtosql -gets file path and return the converted sql file
def convert(filename):
    """Process tableau to sql conversion."""
    twb = return_xml(filename)
    datasources = twb.find('datasources')
    ls_of_connection = []
    for conn in twb.iter('relation'):
        if 'connection' in conn.attrib.keys():
            ls_of_connection.append(conn)
    sql = parse_queries(datasources, ls_of_connection)
    output = format_queries(sql)
    if ".twbx" in filename:
        sql_file = filename.replace('.twbx', '.sql')
    else:
        sql_file = filename.replace('.twb', '.sql')
    with open(sql_file, 'w') as f:
        f.write(output)


# ----------------------------------------------------------------------------------------------------------------------
# do the tab to sql process
def tabtosql_workbook():
    # get all workbooks list
    types = ('*.twb', '*.twbx')
    files_grabbed = []
    for files in types:
        files_grabbed.extend(glob.glob(files))
    # sort the list
    files_grabbed.sort()
    # send each file to convert function
    for workbook in files_grabbed:
        try:
            print("converting "+str(workbook))
            convert(workbook)
        except Exception as e:
            print("There is a problem with the converting process: " + str(e))
            break
    print("done converting workbooks to sql")

