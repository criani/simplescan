import os
import subprocess
import glob
import time
from flask import Flask, jsonify, render_template, request, send_file, current_app
from lxml import etree
from io import BytesIO
from urllib.parse import urlparse
from docx import Document
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
    command = ["nmap", "-oX", "-", "-A", "-O", "-sSU", "-F", "--script", scripts, "--script-args", "min-cvss=1.0", domain]
    
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
        return result.stdout
        create_word_report(filepath)
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
   
#word doc stuff      
        
def process_xml(xml_file_path):
    print(f"Processing XML file: {xml_file_path}")
    tree = ET.parse(xml_file_path)
    root = tree.getroot()

    scan_data = {
        "start_time": root.get('startstr', 'N/A'),
        "end_time": root.find("./runstats/finished").get('timestr', 'N/A'),
        "total_hosts": root.find("./runstats/hosts").get('total', 'N/A'),
        "hosts_up": root.find("./runstats/hosts").get('up', 'N/A'),
        "hosts_down": root.find("./runstats/hosts").get('down', 'N/A')
    }

    print(f"Scan data extracted: {scan_data}")
    return scan_data


    
def extract_host_data(root):
    print("Extracting host data")
    host_data = []
    for host in root.findall('./host'):
        try:
            host_address = host.find('./address').get('addr', 'N/A')
            print(f"Processing host: {host_address}")
            state = host.find('./status').get('state', 'N/A')
            print(f"State: {state}")
            hostname_element = host.find('.//hostname')
            hostname = hostname_element.get('name', 'N/A') if hostname_element is not None else 'N/A'
            print(f"Hostname: {hostname}")

            # Manually counting open TCP and UDP ports
            tcp_open = 0
            udp_open = 0
            for port in host.findall(".//port"):
                protocol = port.get('protocol')
                port_state = port.find('state').get('state')
                if port_state == 'open':
                    if protocol == 'tcp':
                        tcp_open += 1
                    elif protocol == 'udp':
                        udp_open += 1
            print(f"TCP Open: {tcp_open}, UDP Open: {udp_open}")

            vulners_script = host.find(".//script[@id='vulners']")
            if vulners_script is not None:
                vulners_data = vulners_script.get('output', 'No vulners data found')
                print(f"Vulners data found for host: {vulners_data}")
            else:
                vulners_data = 'No vulners data found'
                print("No vulners data found for host")

            host_info = {
                'state': state,
                'address': host_address,
                'hostname': hostname,
                'tcp_open': tcp_open,
                'udp_open': udp_open,
                'vulners_data': vulners_data
            }
            host_data.append(host_info)

        except Exception as e:
            print(f"Error processing host {host_address}: {e}")

    print(f"Host data extracted: {host_data}")
    return host_data

def create_summary_section(doc, scan_data):
    doc.add_heading('Scan Results', level=1)
    start_time = scan_data['start_time']  # Replace with actual data extraction logic
    end_time = scan_data['end_time']      # Replace with actual data extraction logic
    total_hosts = scan_data['total_hosts']  # Replace with actual data extraction logic
    hosts_up = scan_data['hosts_up']        # Replace with actual data extraction logic
    hosts_down = scan_data['hosts_down']    # Replace with actual data extraction logic

    doc.add_paragraph(f"{start_time} – {end_time}\n")
    doc.add_paragraph(f"{total_hosts} hosts scanned.\n")
    doc.add_paragraph(f"{hosts_up} hosts up.\n")
    doc.add_paragraph(f"{hosts_down} hosts down.\n")
    
def create_detailed_host_section(doc, host_data):
    doc.add_heading('Scanned Hosts', level=2)

    for host in host_data:
        doc.add_heading(f"Host: {host['address']} - {host['hostname']}", level=3)
        doc.add_paragraph(f"State: {host['state']}")
        doc.add_paragraph(f"TCP Open Ports: {host['tcp_open']}")
        doc.add_paragraph(f"UDP Open Ports: {host['udp_open']}")

        # Display vulners script data
        doc.add_heading('Vulners Script Data:', level=4)
        doc.add_paragraph(host['vulners_data'])

def create_word_report(xml_filepath):
    reports_dir = '/opt/simplescan/reports'
    
    if not os.path.exists(reports_dir):
        os.makedirs(reports_dir)

    try:
        tree = ET.parse(xml_filepath)
        root = tree.getroot()
        scan_data = process_xml(xml_filepath)
        host_data = extract_host_data(root)

        doc = Document()
        create_summary_section(doc, scan_data)
        create_detailed_host_section(doc, host_data)

        report_filename = os.path.splitext(os.path.basename(xml_filepath))[0] + ".docx"
        report_filepath = os.path.join(reports_dir, report_filename)
        doc.save(report_filepath)
        print(f"Report saved to: {report_filepath}")
    except Exception as e:
        print(f"Error generating report: {e}")


@app.route('/retrieve-word-report/<filename>')
def retrieve_word_report(filename):
    print(f"Retrieving Word report for: {filename}")
    reports_dir = '/opt/simplescan/reports'
    report_filename = os.path.splitext(filename)[0] + ".docx"
    print(f"trying to find: {report_filename}")
    report_filepath = os.path.join(reports_dir, report_filename)
    print (f"Looking for it at: {report_filepath}")

    if not os.path.exists(report_filepath):
        print(f"Report file not found: {report_filepath}")
        return jsonify({"error": "Report file not found"}), 404

    # Correct usage of send_file with the full path and specifying the download name
    return send_file(report_filepath, as_attachment=True, download_name=report_filename)




if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)