import os
import subprocess
import glob
import time
from flask import Flask, jsonify, render_template, request, send_from_directory
from lxml import etree
from io import BytesIO

# Flask app initialization
app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

def run_nmap(target):
    scripts = 'vulners'
    command = [
        "nmap", "-oX", "-", "-sV", "--version-intensity", "9", 
        "--script", scripts, "--script-args mincvss=1", target
    ]
    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        timestamp = time.strftime("%Y%m%d-%H%M%S")
        filename = f"nmap_scan_{timestamp}.xml"
        scans_dir = os.path.join(os.path.dirname(__file__), 'scans')  # Use relative path

        # Check if the scans directory exists and create it if it doesn't
        if not os.path.exists(scans_dir):
            os.makedirs(scans_dir)

        filepath = os.path.join(scans_dir, filename)

        with open(filepath, 'w') as file:
            file.write(result.stdout)
        
        print(f"Saved scan result to {filename}")
        return result.stdout
    except subprocess.CalledProcessError as e:
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
        
@app.route('/list_scans', methods=['GET'])
def list_scans():
    scans_dir = os.path.join(os.path.dirname(__file__), 'scans')
    try:
        scans = os.listdir(scans_dir)
        return jsonify({"scans": scans})
    except Exception as e:
        return jsonify({"error": str(e)})

@app.route('/retrieve_scan/<filename>', methods=['GET'])
def retrieve_scan(filename):
    scans_dir = os.path.join(os.path.dirname(__file__), 'scans')
    try:
        # Construct the full file path
        file_path = os.path.join(scans_dir, filename)

        # Read the XML file content
        with open(file_path, 'r') as file:
            xml_content = file.read()

        # Convert XML to HTML
        html_content = xml_to_html(xml_content)
        return html_content
    except Exception as e:
        return jsonify({"error": str(e)})


if __name__ == '__main__':
    app.run(host=debug=True)