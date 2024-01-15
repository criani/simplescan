import os
import subprocess
import glob
import time
from flask import Flask, jsonify, render_template, request, send_file, current_app
from lxml import etree
from io import BytesIO
from urllib.parse import urlparse
from docx import Document
from docx.shared import Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import nsdecls
from docx.shared import RGBColor
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
        create_word_report(filepath)
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


def add_hyperlink(paragraph, text, url):
    part = paragraph.part
    r_id = part.relate_to(url, 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink', is_external=True)

    hyperlink = OxmlElement('w:hyperlink')
    hyperlink.set('{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id', r_id)

    new_run = OxmlElement('w:r')
    rPr = OxmlElement('w:rPr')

    # Create a new Run property (rPr)
    rStyle = OxmlElement('w:rStyle')
    rStyle.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val', 'Hyperlink')

    # Append style to properties
    rPr.append(rStyle)
    new_run.append(rPr)
    new_run.text = text
    hyperlink.append(new_run)

    paragraph._p.append(hyperlink)

    return paragraph

    
def extract_host_data(root):
    print("Extracting host data")
    host_data = []
    for host in root.findall('./host'):
        try:
            host_address_element = host.find('./address')
            host_address = host_address_element.get('addr', 'N/A') if host_address_element is not None else 'N/A'
            print(f"Processing host: {host_address}")

            state_element = host.find('./status')
            state = state_element.get('state', 'N/A') if state_element is not None else 'N/A'
            print(f"State: {state}")

            hostname_element = host.find('.//hostname')
            hostname = hostname_element.get('name', 'N/A') if hostname_element is not None else 'N/A'
            print(f"Hostname: {hostname}")

            # Port data extraction
            ports_data = []
            for port in host.findall(".//port"):
                protocol = port.get('protocol', 'N/A')
                state_element = port.find('state')
                port_state = state_element.get('state', 'N/A') if state_element is not None else 'N/A'
                service_element = port.find('service')

                service_name = product = version = extrainfo = cpe_link = 'N/A'
                if service_element is not None:
                    service_name = service_element.get('name', 'N/A')
                    product = service_element.get('product', 'N/A')
                    version = service_element.get('version', 'N/A')
                    extrainfo = service_element.get('extrainfo', 'N/A')
                    cpe = service_element.find('cpe')
                    if cpe is not None:
                        cpe_text = cpe.text
                        cpe_link = f'https://nvd.nist.gov/vuln/search/results?form_type=Advanced&cves=on&cpe_version={cpe_text}'

                port_info = {
                    'port_id': port.get('portid', 'N/A'),
                    'protocol': protocol,
                    'state': port_state,
                    'service_name': service_name,
                    'product': product,
                    'version': version,
                    'extrainfo': extrainfo,
                    'cpe_link': cpe_link
                }
                ports_data.append(port_info)

            # Vulners data extraction
            vulners_script = host.find(".//script[@id='vulners']")
            vulners_data = vulners_script.get('output', 'No vulners data found') if vulners_script is not None else 'No vulners data found'
            print(f"Vulners data found for host: {vulners_data}")

            host_info = {
                'state': state,
                'address': host_address,
                'hostname': hostname,
                'ports': ports_data,
                'vulners_data': vulners_data
            }

            host_data.append(host_info)

        except Exception as e:
            print(f"Error processing host {host_address}: {e}")

    print(f"Host data extracted: {host_data}")
    return host_data


def create_summary_section(doc, scan_data, host_data):
    doc.add_heading('Vulnerability Scan Summary', level=1)
    # Add overall scan summary
    doc.add_paragraph(f"Scan conducted from {scan_data['start_time']} to {scan_data['end_time']}.")
    doc.add_paragraph(f"Total hosts scanned: {scan_data['total_hosts']}. {scan_data['hosts_up']} hosts were found to be up.")

    doc.add_paragraph("Key Findings:")

    doc.add_paragraph("\nRecommendations:")

    
def create_detailed_host_section(doc, host_data):
    doc.add_heading('Online Hosts', level=1)

    for host in host_data:
        # Host Header
        doc.add_heading(f"Host: {host['address']} - {host['hostname']}", level=2)

        # Ports Table
        table = doc.add_table(rows=1, cols=8) # Added one more column for CPE Hyperlinks
        table.style = 'Table Grid'
        hdr_cells = table.rows[0].cells
        headers = ["Port", "Protocol", "State", "Service", "Product", "Version", "Extra Info", "CPE/NVD Link"]
        for i, header in enumerate(headers):
            hdr_cells[i].text = header

        for port in host['ports']:
            row_cells = table.add_row().cells
            row_cells[0].text = port['port_id']
            row_cells[1].text = port['protocol']
            row_cells[2].text = port['state']
            row_cells[3].text = port['service_name']
            row_cells[4].text = port['product']
            row_cells[5].text = port['version']
            row_cells[6].text = port['extrainfo']
            # Check if CPE link exists and add hyperlink
            if port['cpe_link'] != 'N/A':
                p = row_cells[7].paragraphs[0]
                add_hyperlink(p, 'NVD Link', port['cpe_link'])
            else:
                row_cells[7].text = 'N/A'

        # Vulnerabilities Section
        if 'vulners_data' in host and host['vulners_data']:
            vulners_paragraph = doc.add_paragraph(style='Body Text')
            vulners_paragraph.add_run('Vulnerabilities:').bold = True
            vulners_paragraph.add_run('\n' + host['vulners_data'])

            # Formatting for vulnerabilities
            font = vulners_paragraph.style.font
            font.name = 'Courier New'
            font.size = Pt(10)

    # Ensure each section starts on a new page
    doc.add_page_break()


def create_word_report(filepath):
    reports_dir = os.path.join(os.path.dirname(__file__), 'reports')
    
    if not os.path.exists(reports_dir):
        os.makedirs(reports_dir)
    try:
        tree = ET.parse(filepath)
        root = tree.getroot()
        scan_data = process_xml(filepath)
        host_data = extract_host_data(root)

        doc = Document()
        create_summary_section(doc, scan_data, host_data)
        create_detailed_host_section(doc, host_data)

        report_filename = os.path.splitext(os.path.basename(filepath))[0] + ".docx"
        report_filepath = os.path.join(reports_dir, report_filename)
        doc.save(report_filepath)
        print(f"Report saved to: {report_filepath}")
    except Exception as e:
        print(f"Error generating report: {e}")


@app.route('/retrieve-word-report/<filename>')
def retrieve_word_report(filename):
    print(f"Retrieving Word report for: {filename}")
    reports_dir = os.path.join(os.path.dirname(__file__), 'reports')
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