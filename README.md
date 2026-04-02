# Projet 2 - The Scripting Project

## Présentation du projet

Ce projet consiste à créer un outil d'administration centralisée multi-plateforme capable d'administrer
à distance des machines clientes Windows et Linux depuis deux serveurs distincts.

L'outil permet de :

- Gérer des utilisateurs à distance
- Administrer des postes clients
- Interroger le statut d'une machine
- Créer et rechercher des informations dans des journaux d'événements
- Automatiser des opérations ciblées

Il se compose de deux scripts :

- Un script **Bash** exécutable depuis le serveur Debian, capable de faire des actions sur la machine Ubuntu et Windows
- Un script **PowerShell** exécutable depuis serveur Windows, capable de faire des actions sur la machine Ubuntu et Windows

Voici le schéma du lab sur lequel nous travaillerons

![Schema](https://github.com/WildCodeSchool/TSSR-0226-P2-G1/blob/main/Ressources/schema.png)

---

## Equipe

| Sprint 1 |
|--------|
| Zinedine Balamane P.O |
| Brice Hemart S.M |
| Patrick Tambwe TECH |
| Mohamed Badane TECH |

---

## Contexte du projet

- **Formation :** TSSR - Technicien Systeme et Reseaux
- **Hyperviseur :** Proxmox VE (serveur distant)
- **Plage VM Groupe 1 :** ID 101 a 198

---

## Infrastructure

### Machines virtuelles (Proxmox)

| Machine | OS | IP  | Role |
|---|---|---|---|
| SRVLX01 | Debian 13 CLI | 172.16.10.10 | Serveur Debian |
| SRVWIN01 | Windows Server 2022 GUI | 172.16.10.5 | Serveur Windows |
| CLILIN01 | Ubuntu 24 LTS | 172.16.10.30 | Client Linux |
| CLIWIN01 | Windows 11 | 172.16.10.20 | Client Windows |

- **Masque :** 255.255.255.0
- **Passerelle :** 172.16.0.254
- **DNS :** 8.8.8.8

---

## Prerequis et Installation

### Cote serveur Linux (SRVLX01)

```bash

# Rendre le script executable
chmod +x scripts/bash/NOMDUSCRIPT.SH

# Lancer le script
./scripts/bash/NOMDUSCRIPT.SH
```

### Cote serveur Windows (SRVWIN01)

```powershell
# Autoriser l'execution de scripts
Set-ExecutionPolicy RemoteSigned

# Lancer le script
.\scripts\powershell\NOMDUSCRIPT.PS1
```

---

## Fonctionnalites

### Actions disponibles

| Fonctionnalite | Bash | PowerShell |
|---|---|---|
| Verrouillage de la machine | Oui | Oui |
| Creation de compte utilisateur local | Oui | Oui |
| Changement de mot de passe | Oui | Oui |
| Suppression de compte utilisateur | Oui | Oui |
| Ajout a un groupe d'administration | Oui | Oui |
| Redemarrage de la machine | Oui | Oui |
| Creation et suppression de repertoire | Oui | Oui |
| Prise en main a distance (CLI) | Oui | Oui |
| Activation du pare-feu | Oui | Oui |
| Execution de script distant | Oui | Oui |

### Informations collectees

| Information | Bash | PowerShell |
|---|---|---|
| Liste des utilisateurs locaux | Oui | Oui |
| 5 derniers logins | Oui | Oui |
| Adresse IP / masque / passerelle | Oui | Oui |
| Disques (nombre, partitions, FS, taille) | Oui | Oui |
| Espace disque restant | Oui | Oui |
| Version de l'OS | Oui | Oui |
| Carte graphique | Oui | Oui |
| CPU % | Oui | Oui |
| Uptime | Oui | Oui |
| 10 derniers evenements critiques | Oui | Oui |
| Temperature CPU | Oui | Oui |
| Droits et permissions sur un dossier | Oui | Oui |
| Recherche dans les logs (utilisateur/machine) | Oui | Oui |

---
