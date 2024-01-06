<?xml version="1.0" encoding="utf-8"?>
<!--
Nmap Bootstrap XSL
Creative Commons BY-SA
This software must not be used by military or secret service organisations.
Andreas Hontzia (@honze_net)
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="utf-8" indent="yes" doctype-system="about:legacy-compat"/>
  <xsl:template match="/">
    <html lang="en">
      <head>
        <meta name="referrer" content="no-referrer"/> 
		<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootswatch/3.3.7/cyborg/bootstrap.min.css" crossorigin="anonymous"/>
		<link rel="stylesheet" href="https://cdn.datatables.net/1.10.19/css/dataTables.bootstrap.min.css" type="text/css" crossorigin="anonymous"/>
		<script src="https://code.jquery.com/jquery-3.3.1.js" crossorigin="anonymous"></script>
		<script src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js" crossorigin="anonymous"></script>
		<script src="https://cdn.datatables.net/1.10.19/js/dataTables.bootstrap.min.js" crossorigin="anonymous"></script>
		<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" crossorigin="anonymous"></script>		
      </head>
      <body>
        <nav class="navbar navbar-default navbar-fixed-top">
          <div class="container-fluid">
            <div class="navbar-header">
              <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1" aria-expanded="false">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
              </button>
              <a class="navbar-brand" href="#"><span class="glyphicon glyphicon-home"></span></a>
            </div>
            <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
              <ul class="nav navbar-nav">
                <li><a href="#scannedhosts">Scanned Hosts</a></li>
                <li><a href="#onlinehosts">Online Hosts</a></li>
                <li><a href="#openservices">Open Services</a></li>
              </ul>
            </div>
          </div>
        </nav>
 <div class="container">
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
              <div class="progress-bar progress-bar-success" style="width: 0%">
                <xsl:attribute name="style">width:<xsl:value-of select="/nmaprun/runstats/hosts/@up div /nmaprun/runstats/hosts/@total * 100"/>%;</xsl:attribute>
                <xsl:value-of select="/nmaprun/runstats/hosts/@up"/>
                <span class="sr-only"></span>
              </div>
              <div class="progress-bar progress-bar-danger" style="width: 0%">
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
                  <th>State</th>
                  <th>Address</th>
                  <th>Hostname</th>
                  <th>TCP (open)</th>
                  <th>UDP (open)</th>
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
      <div class="table-responsive">
        <table class="table table-bordered">
          <thead>
            <tr>
              <th>Port</th>
              <th>Protocol</th>
              <th>Status</th>
              <th>Service</th>
              <th>Product</th>
              <th>Version</th>
              <th>Extra Info</th>
            </tr>
          </thead>
          <tbody>
            <!-- Iterate over each port for the current host -->
            <xsl:for-each select="ports/port">
              <xsl:variable name="portId" select="@portid" />
              <tr>
                <td><xsl:value-of select="@portid"/></td>
                <td><xsl:value-of select="@protocol"/></td>
                <td>
                  <xsl:value-of select="state/@state"/>
                  <br/>
                  <xsl:value-of select="state/@reason"/>
                </td>
                <td><xsl:value-of select="service/@name"/></td>
                <td><xsl:value-of select="service/@product"/></td>
                <td><xsl:value-of select="service/@version"/></td>
                <td><xsl:value-of select="service/@extrainfo"/></td>
              </tr>
              <xsl:if test="service/cpe or script">
                <tr>
                  <td colspan="7">
                    <xsl:if test="service/cpe">
                      <h4>Vulnerability Finding</h4>
                      <a href="https://nvd.nist.gov/vuln/search/results?form_type=Advanced&amp;cves=on&amp;cpe_version={service/cpe}" class="btn btn-danger" style="font-size: larger;">
                        <xsl:value-of select="service/cpe"/>
                      </a>
                      <br/>
                    </xsl:if>
                  </td>                  
                </tr>
              </xsl:if>
            </xsl:for-each>
          </tbody>
        </table>
      </div>
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
                  <th>Address</th>
                  <th>Port</th>
                  <th>Protocol</th>
                  <th>Service</th>
                  <th>Product</th>
                  <th>Version</th>
                  <th>CPE Info</th>
                  <!--<th>Extra info</th>-->
                </tr>
              </thead>
              <tbody>
  <xsl:for-each select="/nmaprun/host/ports/port">
    <xsl:choose>
      <xsl:when test="state/@state = 'open'">
        <tr class="danger">
          <td><xsl:value-of select="@portid"/></td>
          <td><xsl:value-of select="@protocol"/></td>
          <td><xsl:value-of select="state/@state"/><br/><xsl:value-of select="state/@reason"/></td>
          <td><xsl:value-of select="service/@name"/></td>
          <td><xsl:value-of select="service/@product"/></td>
          <td><xsl:value-of select="service/@version"/></td>
          <td><xsl:value-of select="service/@extrainfo"/></td>
        </tr>
      </xsl:when>
      <xsl:when test="state/@state = 'filtered'">
        <tr class="success">
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
        <tr class="success">
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
          <script>
            $(document).ready(function() {
              $('#table-services').DataTable();
              $("a[href^='#onlinehosts-']").click(function(event){     
                  event.preventDefault();
                  $('html,body').animate({scrollTop:($(this.hash).offset().top-150}, 500);
              });
            });
            $('#table-services').DataTable( {
              "lengthMenu": [ [10, 25, 50, 100, -1], [10, 25, 50, 100, "All"] ]
            });
            
          </script>
        </div>
	   </div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
