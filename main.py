import os
import subprocess
import glob
import time
from flask import Flask, jsonify, render_template, request, send_file, current_app
from lxml import etree
from io import BytesIO
from urllib.parse import urlparse
from docx import Document
from html2docx import html2docx
import re
import xml.etree.ElementTree as ET

# Flask app initialization
app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

def run_nmap(target):
    # Parse the target URL to extract the domain
    parsed_url = urlparse(target)
    domain = parsed_url.netloc or parsed_url.path

    # Your existing Nmap command setup
    scripts = 'vulners'
    command = ["nmap", "-oX", "-", "-sV", "-O", "-sSU", "-F", "--script", scripts, "--script-args", "min-cvss=1.0", domain]
    
    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        timestamp = time.strftime("%m%d%Y-%H%M%S")
        sanitized_domain = re.sub(r'[^a-zA-Z0-9\-_.]', '_', domain)  # Sanitize the domain for filename
        filename = f"{sanitized_domain}_{timestamp}.xml"
        scans_dir = os.path.join(os.path.dirname(__file__), 'scans')
        

        if not os.path.exists(scans_dir):
            os.makedirs(scans_dir)

        filepath = os.path.join(scans_dir, filename)        
        with open(filepath, 'w') as file:
            file.write(result.stdout)
        
        print(f"Saved scan result to {filename}")
        html_result = xml_to_html(result.stdout)
        
        return result.stdout

    except subprocess.CalledProcessError as e:
        print(f"An error occurred while running nmap: {e}\nError Output: {e.output}")
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
    print("Target received:", target)
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
   

def create_word_report(html_content, report_filename):
    reports_dir = os.path.join(os.path.dirname(__file__), 'reports')
    
    if not os.path.exists(reports_dir):
        os.makedirs(reports_dir)

    report_filepath = os.path.join(reports_dir, report_filename)
    title = "Scan Report"

    try:
        docx_io = html2docx(html_content, title)
        
        if not isinstance(docx_io, BytesIO):
            raise ValueError("Expected a BytesIO object from html2docx")

        docx_bytes = docx_io.getvalue()  # Get bytes from BytesIO object

        with open(report_filepath, 'wb') as docx_file:
            docx_file.write(docx_bytes)
        
        print(f"Report saved to: {report_filepath}")
    except Exception as e:
        print(f"Error generating report: {e}")


@app.route('/retrieve-word-report/<filename>')
def retrieve_word_report(filename):
    scans_dir = os.path.join(os.path.dirname(__file__), 'scans')
    xml_filename = os.path.splitext(filename)[0] + ".xml"
    xml_file_path = os.path.join(scans_dir, xml_filename)

    # Check if the XML file exists
    if not os.path.exists(xml_file_path):
        print(f"XML file not found: {xml_file_path}")
        return jsonify({"error": "XML file not found"}), 404

    try:
        # Read the XML file content
        with open(xml_file_path, 'r') as file:
            xml_content = file.read()

        # Convert XML to HTML
        html_content = xml_to_html(xml_content)

        # Generate the Word report
        report_filename = os.path.splitext(filename)[0] + ".docx"
        create_word_report(html_content, report_filename)

        # Retrieve the generated Word report for download
        reports_dir = os.path.join(os.path.dirname(__file__), 'reports')
        report_file_path = os.path.join(reports_dir, report_filename)

        # Correct usage of send_file with the full path and specifying the download name
        return send_file(report_file_path, as_attachment=True, download_name=report_filename)

    except Exception as e:
        print(f"Error in retrieving Word report: {e}")
        return jsonify({"error": str(e)})




if __name__ == '__main__':
    app.run(host='127.0.0.1', debug=True)