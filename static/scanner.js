
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('scan-btn').addEventListener('click', initiateScan);
    document.querySelector('.btn-group .dropdown-toggle').addEventListener('click', populateScanLists);
});



function updateStatus(message, isLoading) {
    const statusElement = document.getElementById('status');
    statusElement.innerHTML = isLoading ? '<span class="glyphicon glyphicon-refresh glyphicon-spin"></span> ' + message : message;
}

function initiateScan() {
    const target = document.getElementById('url-input').value;
    if (!target) {
        alert('Please enter a URL or IP address to scan.');
        return;
    }
    
    updateStatus('Scanning ' + target + ' this may take a while...', true);

    fetch('/scan', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ target: target })
    })
    .then(response => response.json())
    .then(data => {
        if(data.error) {
            updateStatus('Error: ' + data.error, false);
        } else {
            document.getElementById('results').innerHTML = data.result;
            updateStatus('Scan completed.', false);
        }
    })
    .catch(error => {
        updateStatus('Fetch error: ' + error.message, false);
    });
}

function populateScanLists() {
	console.log("populateScanLists called");
    fetch('/list_scans')
    .then(response => response.json())
    .then(data => {
        if(data.error) {
            alert('Error: ' + data.error);
        } else {
            const scanListRetrieve = document.getElementById('scan-list-retrieve');
            scanListRetrieve.innerHTML = ''; // Clear existing list

            data.scans.forEach(scan => {
                // Populate the Retrieve Scans dropdown
                const listItemRetrieve = document.createElement('li');
                const linkRetrieve = document.createElement('a');
                linkRetrieve.href = '#';
                linkRetrieve.textContent = scan;
                linkRetrieve.addEventListener('click', () => displayScan(scan));
                listItemRetrieve.appendChild(linkRetrieve);
                scanListRetrieve.appendChild(listItemRetrieve);
            });
        }
    });
}

function printPage() {
    window.print();
}

function displayScan(scanFilename) {
    fetch('/retrieve_scan/' + scanFilename)
    .then(response => response.text())
    .then(data => {
        const resultsElement = document.getElementById('results');
        // Clear existing content
        resultsElement.innerHTML = '';
        // Set new content
        resultsElement.innerHTML = data;
    });
}

