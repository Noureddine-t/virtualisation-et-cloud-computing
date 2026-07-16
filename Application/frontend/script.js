// Utilitaire pour afficher les notifications Toast
function showToast(message, isError = true) {
    const toast = document.getElementById('errorToast');
    toast.textContent = message;
    toast.style.background = isError ? 'var(--error-color)' : 'var(--success-color)';
    toast.classList.add('show');
    setTimeout(() => {
        toast.classList.remove('show');
    }, 4000);
}

// Utilitaires pour les animations d'infrastructure
function setNodeStatus(nodeId, statusText, state) {
    const node = document.getElementById(`node-${nodeId}`);
    const statusSpan = node.querySelector('.status');
    
    // Reset classes
    node.classList.remove('active', 'success');
    
    // Set new state
    if (state) {
        node.classList.add(state);
    }
    statusSpan.textContent = statusText;
}

function setConnectorState(connId, state) {
    const conn = document.getElementById(`conn-${connId}`);
    conn.classList.remove('active', 'success');
    if (state) {
        conn.classList.add(state);
    }
}

function resetInfrastructure() {
    ['api', 'rmq', 'worker', 'redis'].forEach(node => setNodeStatus(node, 'En attente...', ''));
    [1, 2, 3].forEach(conn => setConnectorState(conn, ''));
    
    document.getElementById('statusBox').style.display = 'none';
    document.getElementById('resultForm').style.display = 'none';
    document.getElementById('finalResultBox').style.display = 'none';
}

/**
 * Soumission du formulaire de calcul (Etape 1)
 */
document.getElementById('calcForm').addEventListener('submit', async function(event) {
    event.preventDefault();
    resetInfrastructure();

    const number1 = document.querySelector('input[name="number1"]').value;
    const number2 = document.querySelector('input[name="number2"]').value;
    const operator = document.querySelector('select[name="operator"]').value;
    const submitBtn = document.getElementById('calcSubmitBtn');

    submitBtn.disabled = true;
    submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Envoi en cours...';

    // Animation: API Reçoit la requête
    setNodeStatus('api', 'Réception de la requête...', 'active');
    setConnectorState(1, 'active');

    try {
        const response = await fetch('/api/calculate', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ num1: parseFloat(number1), num2: parseFloat(number2), operator: operator }),
        });
        
        const data = await response.json();

        if (data.error) {
            showToast(data.error);
            setNodeStatus('api', 'Erreur rencontrée', '');
            setConnectorState(1, '');
        } else {
            // Animation: API -> RabbitMQ
            setTimeout(() => {
                setNodeStatus('api', 'Requête validée', 'success');
                setConnectorState(1, 'success');
                
                setNodeStatus('rmq', 'Message placé en file d\'attente', 'active');
                setConnectorState(2, 'active');
                
                // Afficher l'ID
                document.getElementById('resultIdText').textContent = data.id;
                document.getElementById('hiddenOperationId').value = data.id;
                document.getElementById('statusBox').style.display = 'block';
                document.getElementById('resultForm').style.display = 'block';
                
                // On simule que le worker prend le message en tâche de fond
                setTimeout(() => {
                    setNodeStatus('rmq', 'Message dépilé', 'success');
                    setNodeStatus('worker', 'Calcul asynchrone en cours...', 'active');
                    setConnectorState(2, 'success');
                    setConnectorState(3, 'active');
                }, 1500);
            }, 800);
        }
    } catch (error) {
        console.error('Erreur:', error);
        showToast("Erreur de connexion au serveur.");
        resetInfrastructure();
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fa-solid fa-microchip"></i> Lancer le calcul';
    }
});

/**
 * Copie de l'ID
 */
document.getElementById('copyIdButton').addEventListener('click', function() {
    const idText = document.getElementById('resultIdText').textContent;
    if (navigator.clipboard) {
        navigator.clipboard.writeText(idText).then(() => {
            showToast("ID copié dans le presse-papiers !", false);
        }).catch(err => console.error("Erreur copie:", err));
    }
});

/**
 * Soumission de la demande de résultat (Etape 2)
 */
document.getElementById('resultForm').addEventListener('submit', async function(event) {
    event.preventDefault();

    const operationId = document.getElementById('hiddenOperationId').value;
    const fetchBtn = document.getElementById('fetchResultBtn');
    
    fetchBtn.disabled = true;
    fetchBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Interrogation en cours...';

    // Animation: Worker -> Redis
    setNodeStatus('worker', 'Calcul terminé, stockage DB', 'success');
    setConnectorState(3, 'success');
    setNodeStatus('redis', 'Interrogation de la clé...', 'active');

    try {
        const response = await fetch(`/api/result/${operationId}`, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' },
        });
        
        const data = await response.json();

        setTimeout(() => {
            if (data.error) {
                showToast(data.error);
                setNodeStatus('redis', 'Clé introuvable', '');
            } else {
                setNodeStatus('redis', 'Résultat récupéré (Cache Hit)', 'success');
                document.getElementById('finalResult').textContent = data.result;
                document.getElementById('finalResultBox').style.display = 'block';
            }
            fetchBtn.disabled = false;
            fetchBtn.innerHTML = '<i class="fa-solid fa-database"></i> Interroger Redis pour le résultat';
        }, 1000); // Petit délai pour laisser le temps de voir l'animation Redis

    } catch (error) {
        console.error('Erreur:', error);
        showToast("Erreur lors de la récupération du résultat.");
        fetchBtn.disabled = false;
        fetchBtn.innerHTML = '<i class="fa-solid fa-database"></i> Interroger Redis pour le résultat';
    }
});
