
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('scan-btn').addEventListener('click', initiateScan);
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


function updateStatus(message) {
    document.getElementById('status').textContent = message;
}
