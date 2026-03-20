# Intégration Signal → Prometheus Alertmanager

## Architecture

```
Prometheus ──(règles d'alerte)──▶ Alertmanager ──(webhook)──▶ alertmanager-webhook-signal ──▶ signal-cli-rest-api ──▶ Groupe Signal
```

Deux services assurent l'intégration Signal :
- **signal-cli-rest-api** (bbernhard) : expose une API REST autour de signal-cli, gère le compte Signal
- **alertmanager-webhook-signal** (schlauerlauer) : reçoit les webhooks d'Alertmanager et les transmet à Signal

---

## Fichiers modifiés / créés

| Fichier | Rôle |
|---|---|
| `docker-compose.yml` | Correction des bugs + ajout réseau pour signal-cli-rest-api |
| `configs/alertmanager-webhook-signal/config.yaml` | Configuration du webhook (numéro expéditeur, groupe destinataire) |
| `configs/alertmanager/alertmanager-signal-config.yml` | Config Alertmanager routant toutes les alertes vers Signal |
| `.gitignore` | Exclusion des clés Signal (`configs/signal-cli-config/*`) |

---

## Bugs corrigés dans docker-compose.yml

- `alertmanager-webhook-signal` avait une commande erronée copiée depuis Loki (`command: -config.file=/etc/loki/loki.yaml`) qui empêchait le service de démarrer
- `signal-cli-rest-api` n'était pas rattaché au réseau `monitoring`, donc le webhook ne pouvait pas l'atteindre
- Mode `normal` changé en `json-rpc` (mode recommandé, plus stable pour le linking)

---

## Procédure de mise en service

### 1. Démarrer signal-cli-rest-api seul

```bash
docker compose up -d signal-cli-rest-api
```

### 2. Lier un compte Signal existant (via QR code)

Ouvrir dans un navigateur :

```
http://localhost:8080/v1/qrcodelink?device_name=prometheus-alerts
```

Dans l'application Signal sur mobile : **Paramètres → Appareils connectés → Lier un nouvel appareil** → scanner le QR code.

> Si le QR ne fonctionne pas, vider le dossier `configs/signal-cli-config/` (état résiduel d'une tentative d'enregistrement précédente) et redémarrer le conteneur.

### 3. Vérifier le compte lié et récupérer les groupes

```bash
# Vérifier que le compte est bien enregistré
curl http://localhost:8080/v1/accounts

# Lister les groupes Signal du compte (remplacer par votre numéro)
curl http://localhost:8080/v1/groups/+33XXXXXXXXX
```

Relever l'`id` du groupe cible (format `group.XXXXXXXXXXX==`).

### 4. Configurer le webhook

Éditer `configs/alertmanager-webhook-signal/config.yaml` :

```yaml
server:
  port: 10000
  debug: false

signal:
  number: "+33XXXXXXXXX"          # votre numéro Signal lié
  recipients:
    - "group.XXXXXXXXXXX=="       # ID interne du groupe Signal
  send: "http://signal-cli-rest-api:8080/v2/send"

alertmanager:
  generatorURL: false
  ignoreLabels:
    - "__replica__"
```

### 5. Démarrer la stack complète

```bash
docker compose up -d
```

---

## Test de l'intégration

### Test rapide (bypass Prometheus)

Envoyer une fausse alerte directement à Alertmanager :

```bash
curl -X POST http://localhost:9093/api/v2/alerts \
  -H "Content-Type: application/json" \
  -d '[{
    "labels": {
      "alertname": "TestAlert",
      "severity": "critical"
    },
    "annotations": {
      "summary": "Ceci est une alerte de test"
    }
  }]'
```

Un message doit arriver dans le groupe Signal sous ~30 secondes (`group_wait: 30s`).

### Vérifier chaque étape en cas de problème

```bash
# Alertmanager a-t-il reçu l'alerte ?
# → ouvrir http://localhost:9093

# Le webhook a-t-il été appelé ?
docker logs alertmanager_webhook_signal -f

# signal-cli-rest-api a-t-il envoyé le message ?
docker logs signal-cli-rest-api -f
```

### Erreur fréquente : "Specified account does not exist"

Le `number` dans `config.yaml` ne correspond pas au compte lié. Vérifier avec :

```bash
curl http://localhost:8080/v1/accounts
```

Corriger le numéro dans `config.yaml` puis :

```bash
docker compose restart alertmanager-webhook-signal
```

---

## Interfaces disponibles

| Service | URL |
|---|---|
| Grafana | http://localhost:3000 |
| Prometheus | http://localhost:9090 |
| Alertmanager | http://localhost:9093 |
| signal-cli-rest-api | http://localhost:8080 |
| alertmanager-webhook-signal | http://localhost:10000 |
