// Gestion de l'envoi du calcul
document.getElementById('calcForm').addEventListener('submit', function(event) {
    event.preventDefault();

    const number1 = document.querySelector('input[name="number1"]').value;
    const number2 = document.querySelector('input[name="number2"]').value;
    const operator = document.querySelector('select[name="operator"]').value;

    fetch('http://127.0.0.1:5000/api/calculate', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ num1: parseFloat(number1), num2: parseFloat(number2), operator: operator }),
    })
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                document.getElementById('operationResult').textContent = "Erreur: " + data.error;
            } else {
                // Afficher l'ID de l'opération
                document.getElementById('resultId').textContent = "ID de l'opération : " + data.id;
                document.getElementById('resultForm').style.display = 'block'; // Montrer le formulaire pour récupérer le résultat
            }
        })
        .catch(error => console.error('Erreur:', error));
});

// Gestion de la récupération du résultat
document.getElementById('resultForm').addEventListener('submit', function(event) {
    event.preventDefault();

    const operationId = document.querySelector('input[name="operationId"]').value;

    fetch(`http://127.0.0.1:5000/api/result/${operationId}`, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
        },
    })
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                document.getElementById('finalResult').textContent = "Erreur: " + data.error;
            } else {
                // Afficher le résultat
                document.getElementById('finalResult').textContent = "Résultat : " + data.result;
            }
        })
        .catch(error => console.error('Erreur:', error));
});
