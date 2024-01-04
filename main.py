
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

# Function to run Nmap scan and return XML result
def run_nmap(target):
    scripts = 'vulners,metasploit-info,smb-enum-shares,smb-enum-users,snmp-netstat,snmp-processes,dns-brute,http-title,banner,ssl-enum-ciphers,tls-nextprotoneg'
    command = ["nmap", "-oX", "-", "sV", "--script", scripts, target]
    result = subprocess.run(command, capture_output=True, text=True)
    return result.stdout

# Function to convert XML to HTML
def xml_to_html(xml_string):
    xslt = etree.parse('stylesheet.xslt') # Assuming the XSLT file is in the same directory
    xml = etree.parse(BytesIO(xml_string.encode()))
    transform = etree.XSLT(xslt)
    html = transform(xml)
    return str(html)

@app.route('/scan', methods=['POST'])
def scan():
    target = request.json.get('target', '')
    if not target:
        return jsonify({"error": "No target specified"}), 400
    xml_result = run_nmap(target)
    html_result = xml_to_html(xml_result)
    return jsonify({"result": html_result})

if __name__ == '__main__':
    app.run(debug=True)
