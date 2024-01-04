
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('scan-btn').addEventListener('click', initiateScan);
});

function initiateScan() {
    const target = document.getElementById('url-input').value;
    if (!target) {
        alert('Please enter a URL or IP address to scan.');
        return;
    }
    updateStatus('Scanning ' + target + '...');
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
            updateStatus('Error: ' + data.error);
        } else {
            document.getElementById('results').innerHTML = data.result;
            updateStatus('Scan completed.');
        }
    });
}

function updateStatus(message) {
    document.getElementById('status').textContent = message;
}
