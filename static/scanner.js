
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('scan-btn').addEventListener('click', initiateScan);
    document.querySelector('.btn-group .dropdown-toggle').addEventListener('click', retrieveScans);
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
    
    updateStatus('Scanning ' + target + '...', true);

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

// Function to retrieve and display a list of scan files
function retrieveScans() {
    fetch('/list_scans')
    .then(response => response.json())
    .then(data => {
        if(data.error) {
            alert('Error: ' + data.error);
        } else {
            const scanList = document.getElementById('scan-list');
            scanList.innerHTML = ''; // Clear existing list
            data.scans.forEach(scan => {
                const listItem = document.createElement('li');
                const link = document.createElement('a');
                link.href = '#';
                link.textContent = scan;
                link.addEventListener('click', () => displayScan(scan));
                listItem.appendChild(link);
                scanList.appendChild(listItem);
            });
        }
    });
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
