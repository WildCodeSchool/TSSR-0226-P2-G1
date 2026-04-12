# Projet 2 - The Scripting Project

## Sommaire 

- [**Présentation du projet**](#1---présentation-du-projet)
- [**L'équipe**](#2---equipe)
- [**Contexte du projet**](#3---contexte-du-projet)
- [**Infrastructure**](#4---infrastructure)
- [**Prerequis et Installation**](#5---prerequis-et-installation)
- [**Fonctionnalites**](#6---fonctionnalites)
- [**Améliorations possibles**](#7---améliorations-possibles)
- [**Difficultés rencontrées**](#8---difficultés-rencontrées)

## 1 - Présentation du projet

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

## 2 - Equipe

## Sprint 1

| Membre   | Rôle       | Missions |
|----------|------------|----------|
| Zinedine | PO         |  Fonction création de répertoires / Pseudo code du script Bash /
| Brice    | Scrum Master | Mise en place VM  / Menu principal du script / Squelette du script Bash, pseudo code / 
| Mohamed  | Technicien | Fonctions verrouillage et redémarrage / Pseudo code / 
| Patrick  | Technicien | Fonction création de compte utilisateur local / pseudo code /

## Sprint 2

| Membre   | Rôle         | Missions |
|----------|--------------|----------|
| Brice    | PO           | Fonction changement de mot de passe (Ubuntu + Windows) / Activation du pare-feu (Ubuntu + Windows) |
| Mohamed  | Scrum Master | Ajout à un groupe d'administration / Ajout à un groupe |
| Zinedine | Technicien   | Suppression de compte utilisateur local (Ubuntu + Windows / PowerShell) |

---

## 3 - Contexte du projet

- **Formation :** TSSR - Technicien Systeme et Reseaux
- **Hyperviseur :** Proxmox VE (serveur distant)
- **Plage VM Groupe 1 :** ID 101 a 198

---

## 4 - Infrastructure

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

## 5 - Prerequis et Installation

### Cote serveur Linux (SRVLX01)

```bash

# Rendre le script executable
chmod +x scripts/bash/script_bash.sh

# Lancer le script
sudo ./script_bash.sh
```

### Cote serveur Windows (SRVWIN01)

```powershell
# Autoriser l'execution de scripts
Set-ExecutionPolicy RemoteSigned

# Lancer le script
./script_powershell.ps1 ( en administrateur )
```

---

## 6 - Fonctionnalites

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
## 7 - Améliorations possibles

### Sélection dynamique de l'utilisateur pour les actions

Aujourd'hui, certaines actions utilisent l'utilisateur défini par défaut (wilder).

Une amélioration serait d'intégrer :
- Une liste interactive des utilisateurs locaux
- Une sélection dynamique dans les menus

### Interface plus moderne
Le script pourrait évoluer vers : 

- Une interface semi-graphique (whiptail / dialog)
- Une version GUI PowerShell pour Windows

### Gestion des erreurs améliorée

- Vérification avancée des retours SSH
- Validation syntaxique automatique avant exécution

### Sécurité

- Changement du port 22 pour SSH par le port 2222

### Connexion automatique en ssh

- Faire une fonction pour qu'on puisse automatiquement se connecter en ssh sur nimporte qu'elle machine

### Reduire le nombre de lignes du script

- Faire une fonction pour le menu , ce qui rendrait le script plus agréable à lire

## 8 - Difficultés rencontrées

### Exécution SSH et droits sudo

L'exécution de scripts distants avec ssh et sudo a nécessité :

- Une bonne gestion des prompts
- Une adaptation de la syntaxe
- Le choix d'un comportement cohérent selon les actions

### Adaptation en bash / powershell

Pour que les commandes passent de bash a powershell et inversement
