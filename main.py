import os
import subprocess
from flask import Flask, jsonify, render_template, request
from lxml import etree
from io import BytesIO

# Flask app initialization
app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

def run_nmap(target):
    # Updated scripts with a comma-separated list of scripts
    scripts = 'vulners,smb-enum-shares,smb-vuln*,smb-os-discovery,snmp-netstat,banner,ssl-enum-ciphers,ssh2-enum-algos'
    # Corrected the command syntax for XML output
    command = ["nmap", "-oX", "-", "-A", "--script", scripts, target]
    
    try:
        # Run nmap and return the XML output
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        # Log and return None if nmap fails
        print(f"An error occurred while running nmap: {e}")
        return None

def xml_to_html(xml_string):
    try:
        # Parse the XSLT stylesheet
        xslt = etree.parse('stylesheet.xslt')
        # Parse the XML string
        xml = etree.parse(BytesIO(xml_string.encode()))
        # Transform the XML to HTML using the XSLT
        transform = etree.XSLT(xslt)
        html = transform(xml)
        # Return the HTML as a string
        return str(html)
    except etree.XMLSyntaxError as e:
        # Log and raise an exception if XML parsing fails
        print(f"XML Syntax Error: {e}")
        raise
    except Exception as e:
        # Log and raise any other exception that occurs
        print(f"An error occurred during XML transformation: {e}")
        raise

@app.route('/scan', methods=['POST'])
def scan():
    # Get the target from the POST request
    target = request.json.get('target', '')
    if not target:
        # Return an error if no target is specified
        return jsonify({"error": "No target specified"}), 400
    
    # Run nmap to get the XML result
    xml_result = run_nmap(target)
    if xml_result:
        # Convert XML to HTML if nmap was successful
        html_result = xml_to_html(xml_result)
        return jsonify({"result": html_result})
    else:
        # Return an error if nmap failed
        return jsonify({"error": "Nmap scan failed"}), 500

if __name__ == '__main__':
    # Run the Flask app
    app.run(debug=True)
