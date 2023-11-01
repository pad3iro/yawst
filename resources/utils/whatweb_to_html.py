import json, sys

def create_html_report(jsonFile):

    jsonInput = json.load(open(jsonFile))

    html = """<html>
    <head>
        <title> Whatweb Report</title>
    </head>
    <body>
        <div id="all" style="width: 800px; margin: auto; text-align: center;">
            <div id="top">
                <br>
                <h1>Whatweb scan results </h1>
            </div>
            <div id="content" style="margin: auto;">\n"""

    request_config_processed = False
    for element in jsonInput:
        target = element["target"]
        http_status = str(element["http_status"])

        request_config = element["request_config"]
        if not request_config_processed and len(request_config) > 0:
            html += '\t\t\t\t<table style="width:100%; background-color: lightsteelblue; padding-left: 20px; border: 1px solid black; border-radius: 10px; border-collapse: separate; border-spacing: 1em;">\n'
            html += '\t\t\t\t\t<tr><td><h3>Request Config</h4></td></tr>\n'
            for config in request_config:
                first=True
                for config_key in request_config[config]:
                    value = "%s:%s"%(config_key,request_config[config][config_key]) 
                    if first:
                        html += '\t\t\t\t\t<tr><td style="min-width:250px;"><b>%s</b></td><td style="min-width:400px;">%s</td></tr>\n'%(config,value)
                        first=False
                    else:
                        html += '\t\t\t\t\t<tr><td></td><td>%s</td></tr>\n'%(value)

            html += '\t\t\t\t</table>\n'
            request_config_processed = True
        
        plugins = element["plugins"]

        
        html += '\t\t\t\t<br><br>\n\t\t\t\t<table style="width:100%; background-color: lightskyblue; padding-left: 20px; border-collapse: separate; border-spacing: 1em; border: 1px solid black; border-radius: 10px;">\n\t\t\t\t\t<tr><td><h3>Results</h4></td></tr>\n'
        html += '\t\t\t\t\t<tr><td style="min-width:250px;"><b>Target</b></td><td style="min-width:400px;">%s</td></tr>\n'%(target)
        html += '\t\t\t\t\t<tr><td><b>HTTP Status</b></td><td>[ %s ]</td></tr>\n'%(http_status)

        for plugin in plugins:
            if plugin == "Country": #special case where there is the 2 letter code
                value = [ plugins[plugin]["string"][0] + "["+ plugins[plugin]["module"][0] +"]" ]
            elif plugin == "UncommonHeaders": #special case where the headers come separated by comma instead of in a list
                value = plugins[plugin]["string"][0].split(",")
            else:
                if "string" in plugins[plugin]:
                    value = plugins[plugin]["string"]
                elif "version" in plugins[plugin]:
                    value = plugins[plugin]["version"]
                else:
                    value = []
            
            
            if len(value) > 0:
                textValue = value[0]
            else:
                textValue = ""
            html += '\t\t\t\t\t<tr><td><b>%s</b></td><td>%s</td></tr>\n'%(plugin,textValue)

            for i in range(1,len(value)):
                html += '\t\t\t\t\t<tr><td></td><td>%s</td></tr>\n'%(value[i])


        html += '\t\t\t\t</table>\n'

    html += '\t\t\t</div>\n\t\t</div>\n\t</body>\n</html>'

    htmlFilename = jsonFile.split(".json")[0]+".html"
    with open(htmlFilename, 'w', encoding='utf-8') as output_file:
        output_file.write(html)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("please provide a json file as input")
        sys.exit()

    jsonFile = sys.argv[1]

    create_html_report(jsonFile)