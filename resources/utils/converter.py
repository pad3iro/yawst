#!/usr/bin/env python
# -*- coding: utf-8 -*-

import csv
import json
import os
import sys
import xmltodict
from json2html import *

def make_json_from_csv(csvFile, csvkey="domain"):
    jsonFile = os.path.splitext(csvFile)[0] + ".json"

    data = {}
    with open(csvFile, encoding='utf-8') as csvf:
        csvReader = csv.DictReader(csvf)

        for rows in csvReader:
            key = rows[csvkey]
            if key not in data:
                data[key] = []
            data[key].append(rows)
 
    with open(jsonFile, 'w', encoding='utf-8') as jsonf:
        jsonf.write(json.dumps(data, indent=4))

    return jsonFile

def make_json_from_xml(xmlFile):
    jsonFile = os.path.splitext(xmlFile)[0] + ".json"

    json_data = {}
    with open(xmlFile) as xml_file:
     
        data_dict = xmltodict.parse(xml_file.read())
        json_data = json.dumps(data_dict)
     
    with open(jsonFile, "w", encoding='utf-8') as json_file:
        json_file.write(json_data)
    
    return json_file

def make_html_from_json(jsonFile):
    htmlFile = os.path.splitext(jsonFile)[0] + ".html"
    try:
        jsonInput = json.load(open(jsonFile))
    except:
        jsonInput = {"Status": "Failed to parse json result"}

    htmlOutput = json2html.convert(json=jsonInput)
    with open(htmlFile, 'w', encoding='utf-8') as output_file:
        output_file.write(htmlOutput)
    
    return htmlFile
    
for file in sys.argv[1:]:
    if file.endswith(".csv"):
        make_json_from_csv(file)
    elif file.endswith(".xml"):
        make_json_from_xml(file)
    elif file.endswith(".json"):
        make_html_from_json(file)