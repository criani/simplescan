<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="utf-8" indent="yes" doctype-system="about:legacy-compat"/>
  <xsl:template match="/">
    <html lang="en">
      
 <div class="container-fluid">
          <div class="jumbotron">
            <h1>Scan Results</h1>
            <!--<pre style="white-space:pre-wrap; word-wrap:break-word;"><xsl:value-of select="/nmaprun/@args"/></pre>-->
            <p class="lead">
              <xsl:value-of select="/nmaprun/@startstr"/> – <xsl:value-of select="/nmaprun/runstats/finished/@timestr"/><br/>
              <xsl:value-of select="/nmaprun/runstats/hosts/@total"/> hosts scanned.
              <xsl:value-of select="/nmaprun/runstats/hosts/@up"/> hosts up.
              <xsl:value-of select="/nmaprun/runstats/hosts/@down"/> hosts down.
            </p>
            <div class="progress">
              <div class="progress-bar progress-bar-success print-hide" style="width: 0%">
                <xsl:attribute name="style">width:<xsl:value-of select="/nmaprun/runstats/hosts/@up div /nmaprun/runstats/hosts/@total * 100"/>%;</xsl:attribute>
                <xsl:value-of select="/nmaprun/runstats/hosts/@up"/>
                <span class="sr-only"></span>
              </div>
              <div class="progress-bar progress-bar-danger print-hide" style="width: 0%">
                <xsl:attribute name="style">width:<xsl:value-of select="/nmaprun/runstats/hosts/@down div /nmaprun/runstats/hosts/@total * 100"/>%;</xsl:attribute>
                <xsl:value-of select="/nmaprun/runstats/hosts/@down"/>
                <span class="sr-only"></span>
              </div>
            </div>
          </div>
          <h2 id="scannedhosts" class="target">Scanned Hosts<xsl:if test="/nmaprun/runstats/hosts/@down > 1024"><small> (offline hosts are hidden)</small></xsl:if></h2>
          <div class="table-responsive">
            <table id="table-overview" class="table table-striped dataTable" role="grid">
              <thead>
                <tr>
                  <th style="text-align: center;">State</th>
                  <th style="text-align: center;">Address</th>
                  <th style="text-align: center;">Hostname</th>
                  <th style="text-align: center;">TCP (open)</th>
                  <th style="text-align: center;">UDP (open)</th>
                </tr>
              </thead>
              <tbody>
                <xsl:choose>
                  <xsl:when test="/nmaprun/runstats/hosts/@down > 1024">
                    <xsl:for-each select="/nmaprun/host[status/@state='up']">
                      <tr>
                        <td><span class="label label-danger"><xsl:if test="status/@state='up'"><xsl:attribute name="class">label label-success</xsl:attribute></xsl:if><xsl:value-of select="status/@state"/></span></td>
                        <td><a><xsl:attribute name="href">#onlinehosts-<xsl:value-of select="translate(address/@addr, '.', '-')"/></xsl:attribute><xsl:value-of select="address/@addr"/></a></td>
                        <td><xsl:value-of select="hostnames/hostname/@name"/></td>
                        <td><xsl:value-of select="count(ports/port[state/@state='open' and @protocol='tcp'])"/></td>
                        <td><xsl:value-of select="count(ports/port[state/@state='open' and @protocol='udp'])"/></td>
                      </tr>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:for-each select="/nmaprun/host">
                      <tr>
                        <td><span class="label label-danger"><xsl:if test="status/@state='up'"><xsl:attribute name="class">label label-success</xsl:attribute></xsl:if><xsl:value-of select="status/@state"/></span></td>
                        <td><a><xsl:attribute name="href">#onlinehosts-<xsl:value-of select="translate(address/@addr, '.', '-')"/></xsl:attribute><xsl:value-of select="address/@addr"/></a></td>
                        <td><xsl:value-of select="hostnames/hostname/@name"/></td>
                        <td><xsl:value-of select="count(ports/port[state/@state='open' and @protocol='tcp'])"/></td>
                        <td><xsl:value-of select="count(ports/port[state/@state='open' and @protocol='udp'])"/></td>
                      </tr>
                    </xsl:for-each>
                  </xsl:otherwise>
                </xsl:choose>
              </tbody>
            </table>
          </div>
          <script>
            $(document).ready(function() {
              $('#table-overview').DataTable();
            });
            $('#table-overview').DataTable( {
              "lengthMenu": [ [10, 25, 50, 100, -1], [10, 25, 50, 100, "All"] ]
            });
          </script>
<h2 id="onlinehosts" class="target">Online Hosts</h2>
          <xsl:for-each select="/nmaprun/host[status/@state='up']">
            <div class="panel panel-default">
              <div class="panel-heading clickable" data-toggle="collapse">
                  <xsl:attribute name="id">onlinehosts-<xsl:value-of select="translate(address/@addr, '.', '-')"/></xsl:attribute>
                  <xsl:attribute name="data-target">#<xsl:value-of select="translate(address/@addr, '.', '-')"/></xsl:attribute>
                <h3 class="panel-title"><xsl:value-of select="address/@addr"/><xsl:if test="count(hostnames/hostname) > 0"> - <xsl:value-of select="hostnames/hostname/@name"/></xsl:if></h3>
              </div>
              <div class="panel-body collapse">
                <xsl:attribute name="id"><xsl:value-of select="translate(address/@addr, '.', '-')"/></xsl:attribute>
                <xsl:if test="count(hostnames/hostname) > 0">
                  
				  <h4>Hostnames</h4>
                  
				 
                    <xsl:for-each select="hostnames/hostname">
					   <h5><xsl:value-of select="@name"/></h5>
                    </xsl:for-each>

	
                </xsl:if>
                <h4>Ports</h4>
                <div class="table-responsive">
                  <table class="table table-bordered">
                    <thead>
                      <tr>
                        <th style="text-align: center;">Port</th>
                        <th style="text-align: center;">Protocol</th>
                        <th style="text-align: center;">State<br/>Reason</th>
                        <th style="text-align: center;">Service</th>
                        <th style="text-align: center;">Product</th>
                        <th style="text-align: center;">Version</th>
                        <th style="text-align: center;">Extra Info</th>
                      </tr>
                    </thead>
                    <tbody>
                      <xsl:for-each select="ports/port">
                        <xsl:choose>
                          <xsl:when test="state/@state = 'open'">
                            <tr class="success">
                              <td title="Port"><xsl:value-of select="@portid"/></td>
                              <td title="Protocol"><xsl:value-of select="@protocol"/></td>
                              <td title="State / Reason"><xsl:value-of select="state/@state"/><br/><xsl:value-of select="state/@reason"/></td>
                              <td title="Service"><xsl:value-of select="service/@name"/></td>
                              <td title="Product"><xsl:value-of select="service/@product"/></td>
                              <td title="Version"><xsl:value-of select="service/@version"/></td>
                              <td title="Extra Info"><xsl:value-of select="service/@extrainfo"/></td>
                            </tr>
                            <tr>
                              <td colspan="7">
									<xsl:if test="service/cpe">
										<!-- Store CPE in a variable -->
										<xsl:variable name="cpe" select="service/cpe"/>
										<!-- Check if CPE contains at least four colon-separated sections -->
										<xsl:variable name="hasVersion" select="contains(substring-after(substring-after(substring-after($cpe, ':'), ':'), ':'), ':')"/>

										<xsl:choose>
											<!-- Check if the CPE string likely contains a version -->
											<xsl:when test="$hasVersion">
												<!-- Display link with version -->
												<a href="https://nvd.nist.gov/vuln/search/results?form_type=Advanced&amp;cves=on&amp;cpe_version={normalize-space($cpe)}">
													Vulnerability Data
												</a>
												<br/>
											</xsl:when>
											<!-- Case when there is no clear version number in the CPE -->
											<xsl:otherwise>
												<span>Fingerprint Not Able to Determine Version</span>
												<br/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:if>
                                 <xsl:for-each select="script[@id='vulners']">
                                  <h5 style="color: red; font-size: larger;">Possible Vulnerabilities</h5>
                                  <pre style="white-space: pre-wrap; word-wrap: break-word; padding: 15px; background-color: #333; color: #fff; border: 1px solid #ccc; border-radius: 10px; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;">
										<xsl:value-of select="@output"/>
									</pre>
                                </xsl:for-each>
                              </td>
                            </tr>
                          </xsl:when>
                          <xsl:when test="state/@state = 'filtered'">
                            <tr class="warning">
                              <td><xsl:value-of select="@portid"/></td>
                              <td><xsl:value-of select="@protocol"/></td>
                              <td><xsl:value-of select="state/@state"/><br/><xsl:value-of select="state/@reason"/></td>
                              <td><xsl:value-of select="service/@name"/></td>
                              <td><xsl:value-of select="service/@product"/></td>
                              <td><xsl:value-of select="service/@version"/></td>
                              <td><xsl:value-of select="service/@extrainfo"/></td>
                            </tr>
                          </xsl:when>
                          <xsl:when test="state/@state = 'closed'">
                            <tr class="active">
                              <td><xsl:value-of select="@portid"/></td>
                              <td><xsl:value-of select="@protocol"/></td>
                              <td><xsl:value-of select="state/@state"/><br/><xsl:value-of select="state/@reason"/></td>
                              <td><xsl:value-of select="service/@name"/></td>
                              <td><xsl:value-of select="service/@product"/></td>
                              <td><xsl:value-of select="service/@version"/></td>
                              <td><xsl:value-of select="service/@extrainfo"/></td>
                            </tr>
                          </xsl:when>
                          <xsl:otherwise>
                            <tr class="info">
                              <td><xsl:value-of select="@portid"/></td>
                              <td><xsl:value-of select="@protocol"/></td>
                              <td><xsl:value-of select="state/@state"/><br/><xsl:value-of select="state/@reason"/></td>
                              <td><xsl:value-of select="service/@name"/></td>
                              <td><xsl:value-of select="service/@product"/></td>
                              <td><xsl:value-of select="service/@version"/></td>
                              <td><xsl:value-of select="service/@extrainfo"/></td>
                            </tr>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:for-each>
                    </tbody>
                  </table>
                </div>
                <xsl:if test="hostscript/script[@id='vulners']">
                  <h4>Raw Findings Warranting Investigation</h4>
                </xsl:if>
                <xsl:for-each select="hostscript/script[@id='vulners']">
                  <h5><xsl:value-of select="@id"/></h5>
                  <pre style="white-space:pre-wrap; word-wrap:break-word;"><xsl:value-of select="@output"/></pre>
                </xsl:for-each>
                <!--<xsl:if test="count(os/osmatch) > 0">
                  <<h4>OS Detection Confidence</h4>
                  <xsl:for-each select="os/osmatch">
                    <h5>OS details: <xsl:value-of select="@name"/> (<xsl:value-of select="@accuracy"/>%)</h5>
                    <xsl:for-each select="osclass">
                      Device type: <xsl:value-of select="@type"/><br/>
                      Running: <xsl:value-of select="@vendor"/><xsl:text> </xsl:text><xsl:value-of select="@osfamily"/><xsl:text> </xsl:text><xsl:value-of select="@osgen"/> (<xsl:value-of select="@accuracy"/>%)<br/>
                      OS CPE: <a><xsl:attribute name="href">https://nvd.nist.gov/vuln/search/results?form_type=Advanced&amp;cves=on&amp;cpe_version=<xsl:value-of select="cpe"/></xsl:attribute><xsl:value-of select="cpe"/></a>
                      <br/>
                    </xsl:for-each>
                    <br/>
                  </xsl:for-each>
                </xsl:if>-->
              </div>
            </div>
          </xsl:for-each>


<div>		  
<h2 id="openservices" class="target">Attack Surface</h2>
<p class="lead">(As seen from scanner)</p>
          <div class="table-responsive">
            <table id="table-services" class="table table-striped dataTable" role="grid">
              <thead>
                <tr>
                  <th style="text-align: center;">Address</th>
                  <th style="text-align: center;">Port</th>
                  <th style="text-align: center;">Protocol</th>
                  <th style="text-align: center;">Service</th>
                  <th style="text-align: center;">Product</th>
                  <th style="text-align: center;">Version</th>
                  <th style="text-align: center;">Vulnerability Data</th>
                  <!--<th>Extra info</th>-->
                </tr>
              </thead>
              <tbody>
  <xsl:for-each select="/nmaprun/host/ports/port">
    <!-- Store the IP address or hostname in a variable for later use -->
    <xsl:variable name="hostAddress">
      <xsl:choose>
        <!-- If a hostname exists, use it -->
        <xsl:when test="../../hostnames/hostname">
          <xsl:value-of select="../../hostnames/hostname/@name"/>
        </xsl:when>
        <!-- Otherwise, fall back to the IP address -->
        <xsl:otherwise>
          <xsl:value-of select="../../address/@addr"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="state/@state = 'open'">
        <tr class="danger">
          <td style="text-align: center;"><xsl:value-of select="$hostAddress"/></td>
          <td style="text-align: center;"><xsl:value-of select="@portid"/></td>
          <td style="text-align: center;"><xsl:value-of select="@protocol"/></td>
          <td style="text-align: center;"><xsl:value-of select="service/@name"/></td>
          <td style="text-align: center;"><xsl:value-of select="service/@product"/></td>
          <td style="text-align: center;"><xsl:value-of select="service/@version"/></td>
          <td style="text-align: center;">
                    <xsl:if test="service/cpe">
                        <!-- Store CPE in a variable -->
                        <xsl:variable name="cpe" select="service/cpe"/>
                        <!-- Check if CPE contains at least four colon-separated sections -->
                        <xsl:variable name="hasVersion" select="contains(substring-after(substring-after(substring-after($cpe, ':'), ':'), ':'), ':')"/>

                        <xsl:choose>
                            <!-- Check if the CPE string likely contains a version -->
                            <xsl:when test="$hasVersion">
                                <!-- Display link with version -->
                                <a href="https://nvd.nist.gov/vuln/search/results?form_type=Advanced&amp;cves=on&amp;cpe_version={normalize-space($cpe)}">
                                    Vulnerabilities Found!
                                </a>
                            </xsl:when>
                            <!-- Case when there is no clear version number in the CPE -->
                            <xsl:otherwise>
                                <span>Fingerprint Not Able to Determine Version</span>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </td>
        </tr>
      </xsl:when>
      <xsl:when test="state/@state = 'filtered'">
        <tr class="success">
          <td style="text-align: center;"><xsl:value-of select="$hostAddress"/></td>
          <td style="text-align: center;"><xsl:value-of select="@portid"/></td>
          <td style="text-align: center;"><xsl:value-of select="@protocol"/></td>
          <td style="text-align: center;"><xsl:value-of select="service/@name"/></td>
          <td style="text-align: center;"><xsl:value-of select="service/@product"/></td>
          <td style="text-align: center;"><xsl:value-of select="service/@version"/></td>
          <td style="text-align: center;">
                    <xsl:if test="service/cpe">
                        <!-- Store CPE in a variable -->
                        <xsl:variable name="cpe" select="service/cpe"/>
                        <!-- Check if CPE contains at least four colon-separated sections -->
                        <xsl:variable name="hasVersion" select="contains(substring-after(substring-after(substring-after($cpe, ':'), ':'), ':'), ':')"/>

                        <xsl:choose>
                            <!-- Check if the CPE string likely contains a version -->
                            <xsl:when test="$hasVersion">
                                <!-- Display link with version -->
                                <a href="https://nvd.nist.gov/vuln/search/results?form_type=Advanced&amp;cves=on&amp;cpe_version={normalize-space($cpe)}">
                                    Vulnerabilities Found!
                                </a>
                            </xsl:when>
                            <!-- Case when there is no clear version number in the CPE -->
                            <xsl:otherwise>
                                <span>Fingerprint Not Able to Determine Version</span>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </td>
        </tr>
      </xsl:when>
    </xsl:choose>
  </xsl:for-each>
</tbody>
            </table>
          </div>
          <script>
            $(document).ready(function() {
              $('#table-services').DataTable();
              $("a[href^='#onlinehosts-']").click(function(event){     
                  event.preventDefault();
                  $('html,body').animate({scrollTop:($(this.hash).offset().top-100}, 500);
              });
            });
            $('#table-services').DataTable( {
              "lengthMenu": [ [10, 25, 50, 100, -1], [10, 25, 50, 100, "All"] ]
            });
            
          </script>
        </div>
	   </div>
    </html>
  </xsl:template>
</xsl:stylesheet>
