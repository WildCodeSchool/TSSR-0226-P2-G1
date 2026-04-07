Guide Utilisateur — Outil d'Administration Réseau
Projet 2 · TSSR · Groupe 1 — Zinedine · Mohamed · Brice · Patrick

Table des matières

À propos de cet outil
Avant de commencer

Côté Linux




1. À propos de cet outil
Cet outil a été conçu pour permettre l'administration à distance de machines clientes depuis un serveur central, sans avoir besoin d'intervenir physiquement sur les postes.
Il se présente sous la forme d'un script à menus interactifs : l'administrateur navigue étape par étape pour choisir la cible, l'action à effectuer, et valider l'opération.
Deux versions du script coexistent selon l'environnement serveur :
VersionServeur d'exécutionLangagescript_dady.shSRVLX01 (Debian)Bashscript_momy.ps1SRVWIN01 (Windows Server)PowerShell
Ce guide couvre l'installation, le lancement, la navigation et l'ensemble des fonctionnalités disponibles.

2. Avant de commencer
2.1. Côté Linux

Le script Bash se lance uniquement depuis SRVLX01.

Dépendances requises
ÉlémentDétailSSHConnexion active vers CLILIN01 et CLIWIN01AuthentificationClés SSH configurées via keychain (pas de saisie de mot de passe)Utilisateurwilder doit exister sur toutes les machinesDroitsScript principal exécutable (chmod +x)
Emplacement des fichiers
Tous les fichiers doivent être placés dans le répertoire suivant sur SRVLX01 :
~/Documents/TSSR-1025-P2-G1/
└── scripts/
    ├── script_dady.sh       ← point d'entrée principal
    ├── [modules .sh]        ← scripts appelés par le principal
    └── info/                ← fichiers générés lors des opérations
Vérification rapide avant lancement
bash# Vérifier que SSH fonctionne vers les clients
ssh wilder@CLILIN01 "echo OK"
ssh wilder@CLIWIN01 "echo OK"

# Vérifier les droits d'exécution
ls -l script_dady.sh

# Corriger si nécessaire
chmod +x script_dady.sh
