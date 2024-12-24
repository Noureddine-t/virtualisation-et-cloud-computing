/**
 * Manage the form submission to calculate an operation and get the operation ID
 */
document.getElementById('calcForm').addEventListener('submit', function(event) {
    event.preventDefault();

    const number1 = document.querySelector('input[name="number1"]').value;
    const number2 = document.querySelector('input[name="number2"]').value;
    const operator = document.querySelector('select[name="operator"]').value;

    fetch('http://calculatrice-taleb.polytech-dijon.kiowy.net/api/calculate', {
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
                document.getElementById('copyIdButton').style.display = 'inline-block';
                document.getElementById('resultForm').style.display = 'block';
            }
        })
        .catch(error => console.error('Erreur:', error));
});

/**
 * Manage the copy of the operation ID to the clipboard
 */document.getElementById('copyIdButton').addEventListener('click', function() {
    // Récupérer l'ID à partir du texte affiché dans resultId
    const idText = document.getElementById('resultId').textContent.replace("ID de l'opération : ", "");

    // Copier l'ID dans le presse-papiers
    if (navigator.clipboard) {
        navigator.clipboard.writeText(idText)
            .then(() => {
                console.log("ID copié dans le presse-papiers !");
            })
            .catch(err => {
                console.error("Erreur lors de la copie :", err);
            });
    } else {
        console.error("L'API du presse-papiers n'est pas supportée ou accessible. (HTTPS requis)");
    }
});

/**
 * Manage the form submission to get the result of an operation using the operation ID
 */
document.getElementById('resultForm').addEventListener('submit', function(event) {
    event.preventDefault();

    const operationId = document.querySelector('input[name="operationId"]').value;

    fetch(`http://calculatrice-taleb.polytech-dijon.kiowy.net/api/result/${operationId}`, {
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
