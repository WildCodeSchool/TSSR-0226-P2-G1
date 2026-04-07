
# Guide Utilisateur  Outil d'Administration Réseau
### Projet 2 · TSSR · Groupe 1  Zinedine · Mohamed · Brice · Patrick

---

## Table des matières

1. [À propos de cet outil](#1-à-propos-de-cet-outil)
2. [Avant de commencer](#2-avant-de-commencer)
   - [Côté Linux](#21-côté-linux)

---

## 1. À propos de cet outil

Cet outil a été conçu pour permettre l'**administration à distance** de machines clientes depuis un serveur central, sans avoir besoin d'intervenir physiquement sur les postes.

Il se présente sous la forme d'un **script à menus interactifs** : l'administrateur navigue étape par étape pour choisir la cible, l'action à effectuer, et valider l'opération.

Deux versions du script coexistent selon l'environnement serveur :

| Version | Serveur d'exécution | Langage |
|---------|-------------------|---------|
| `script_linux.sh` | SRVLX01 (Debian) | Bash |
| `script_windows.ps1` | SRVWIN01 (Windows Server) | PowerShell |

Ce guide couvre l'installation, le lancement, la navigation et l'ensemble des fonctionnalités disponibles.

---

## 2. Avant de commencer

### 2.1. Côté Linux

> Le script Bash se lance uniquement depuis **SRVLX01**.

#### Dépendances requises

| Élément | Détail |
|---------|--------|
| SSH | Connexion active vers `CLILIN01` et `CLIWIN01` |
| Authentification | Clés SSH configurées via `keychain` (pas de saisie de mot de passe) |
| Utilisateur | `wilder` doit exister sur toutes les machines |
| Droits | Script principal exécutable (`chmod +x`) |

#### Emplacement des fichiers

Tous les fichiers doivent être placés dans le répertoire suivant sur SRVLX01 :

```
~/Documents/TSSR-1025-P2-G1/
└── scripts/
    ├── script_bash.sh       ← point d'entrée principal
    ├── [modules .sh]        ← scripts appelés par le principal
    └── info/                ← fichiers générés lors des opérations
```

#### Vérification rapide avant lancement

```bash
# Vérifier que SSH fonctionne vers les clients
ssh wilder@CLILIN01 "echo OK"
ssh wilder@CLIWIN01 "echo OK"

# Vérifier les droits d'exécution
ls -l script_bash.sh

# Corriger si nécessaire
chmod +x script_bash.sh
```
