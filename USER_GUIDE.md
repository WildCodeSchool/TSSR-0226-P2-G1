## Sommaire
1. [**Introduction**](#1--introduction)
2. [**Pré-requis d'utilisation**](#2---pré-requis-dutilisation)


## 1 . Introduction

Ce document explique comment utiliser le script d'administration que nous avons développé lors du Projet 2 TSSR. Il est destiné aux admins souhaitant exécuter les actions d'administration ou récupérer des informations sur des machines du réseau.

Les instructions couvrent :

- l'exécution du script Bash (serveur Debian)
- l'exécution du script Powershell (serveur Windows)
- la navigation dans les menus
- l'utilisation des fonctions disponible

## 2 .  Pré-requis d'utilisation

### 2.1 Script Bash

Le script bash doit être exécuté depuis le serveur Debian (SRVLX01)

**Pré-requis nécessaires :**

 - Une connexion SSH fonctionnelle vers les machines clientes (CLILIN01 et CLIWIN01)
 - La présence du script dans le dossier ``~/Documents/TSSR-0226-P2-G1/script/`` 
 - Les permissions d'exécution sur le script principal ``chmod +x script_bash.sh`` 
 - L'utilisateur ``wilder`` doit exister sur toutes les machines du réseau

**Arborescence requise :**

``` 
~Documents/TSSR-0226-P2-P1/
 ├── script\
 │   ├── script_bash.sh
 │   └── info\    
```

### 2.2 Script Powershell

Le script PowerShell doit être exécuté depuis le serveur Windows (SRVWIN01)

**Pré-requis nécessaires :**

 - Une connexion SSH fonctionnelle vers les machines clientes (CLILIN01 et CLIWIN01)
 - La présence du script dans le dossier ``C:\Users\<user>\Documents\TSSR-0226-P2-G1\script\`` 
 - La politique d'exécution PowerShell configuré pour permettre l'exécution de scripts 
 - L'utilisateur ``wilder`` doit exister sur toutes les machines du réseau

**Arborescence requise :**

```
 C:\Users\Wilder\Documents\TSSR-0226-P2-G1\
 ├── script\
 │   ├── script_powershell.ps1
 │   └── info\    

```

**Configuration de la politique d'exécution :** Pour permettre l'exécution du script, ouvrez PowerShell en administrateur et :

`` Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`` 

## 3. Lancer le script

### 3.1 Sous Linux

1. Ouvrir le terminal sur le serveur Debian (SRVLX01)

2. Se rendre dans le dossier où se trouve le script
   ```bash 
   cd ~/Documents/TSSR-0226-P2-G1/script
   ```

3. Lancer le script :
   ``` bash
   sudo ./script_bash.sh
   ```

4. Le menu principal s'affiche 

### 3.2 Sous Windows

1. Ouvrir PowerShell sur le serveur Windows (SRVWIN01)

2. Se rendre dans le dossier où se trouve le script
   ```powershell
   cd C:\Users\<user>\Documents\TSSR-0225-P2-G1\script
   ```

3. Lancer le script :
   ```powershell
   .\script_powershell.ps1
   ```

4. Le menu principal s'affiche

## 4 Navigation dans les Menus

### 4.1 Menu principal

Le menu principal permet de choisir si on veut administrer un **ordinateur** ou un **utilisateur** .
Il permet également de choisir des **infos** pour checker les logs .

**Options disponibles :**

- **1 - Ordinateurs :** Accès aux actions et informations concernant les machines clientes (CLILIN01 et CLIWIN01)
- **2 - Utilisateurs :** Accès aux actions et informations concernant les comptes utilisateurs
- **3 - Infos :** Recherche dans le fichier log_evt.log des événements par utilisateurs et par ordinateurs
- **4 - Quitter :** Permet de quitter le script 

### 4.2 Choix de la cible

Lorsque vous rentrez dans le menu **1 - Ordinateurs** ou **2 - Utilisateurs** , vous avez le choix entre la machine Windows ou la machine Ubuntu pour les ordinateurs, et l'utilisateur Wilder pour Windows et wilder pour Ubuntu. 

### 4.3 Séléction des actions

Chaque menu propose une liste d'actions disponibles numérotées. 
Il suffit de taper le numéro correspondant à l'action souhaitée et d'appuyer sur Entrée.
Le script exécute automatiquement l'action demandé et revient au sous-menu.

**Exemple de navigation :** 

```
Menu Principal > Ordinateurs > Client Windows > Action [1-9] > Exécution > Retour au menu Action
```

### 4.4 Retour / Quitter

- **Retour :** Permet de revenir au menu précédent sans quitter le script
- **Quitter :** Ferme proprement le script et enregistre l'événement dans les logs

Evitez la fermeture du script avec un ``CTRL+C`` , préférez toujours une fermeture via l'option **Quitter**.

## 5. Fonctionnalités - Utilisateurs

Le script permet d'effectuer les actions suivantes sur les comptes utilisateurs :

| Action                                         | Description                                                              |
| ---------------------------------------------- | ------------------------------------------------------------------------ |
| **1) Création de compte utilisateur local**    | Crée un nouveau compte utilisateur sur la machine cible                  |
| **2) Changement de mot de passe**              | Modifie le mot de passe d'un utilisateur existant                        |
| **3) Suppression de compte utilisateur local** | Supprime un compte utilisateur de la machine cible                       |
| **4) Ajout à un groupe d'administration**      | Ajoute un utilisateur au groupe sudo (Linux) ou Administrators (Windows) |
| **5) Ajout à un groupe**                       | Ajoute un utilisateur à un groupe personnalisé                           |
| **6) Infos**                                   | Infos droits et permission de l'utilisateur sur un dossier               |
## 6. Fonctionnalités - Machine clientes

### 6.1 Actions possibles

Le script permet d'effectuer les actions suivantes sur les machines clientes :

| Action                                             | Description                                                                        |
| -------------------------------------------------- | ---------------------------------------------------------------------------------- |
| **1) Verrouillage**                                | Verrouille la session de l'utilisateur distant                                     |
| **2) Redémarrage**                                 | Redémarre la machine distante                                                      |
| **3) Création de répertoire**                      | Crée un nouveau dossier sur la machine distante                                    |
| **4) Suppression de répertoire**                   | Supprime un dossier existant sur la machine distante                               |
| **5) Prise en main en CLI**                        | Permet de prendre le contrôle de la machine a distance en CLI                      |
| **6) Activation du pare-feu**                      | Active le pare-feu système (ufw sur Linux, Windows Firewall sur Windows)           |
| **7) Exécution du script sur la machine distante** | Permet de lancer un script sur la machine distante, puis le supprimer par la suite |
| **8) Infos**                                       | Liste toutes les informations récupérables sur la machine                          |
### 6.2 Informations récupérables sur la machine

Le script peut récupérer les informations système suivantes :

| Information                                        | Description                                              |
| -------------------------------------------------- | -------------------------------------------------------- |
| **1) Liste des utilisateurs locaux**               | Liste des utilisateurs locaux sur la machine             |
| **2) 5 derniers logins**                           | Historique des 5 dernières connexions                    |
| **3) Adresses IP, masque, passerelle**             | Configuration réseau de la machine                       |
| **4) Nombre de disques**                           | Nombre de disques physiques                              |
| **5) Partition (nombre,nom,FS,taille) par disque** | Détails des partitions                                   |
| **6) Espace disque restant par partition/volume**  | Espace disponible sur chaque partition                   |
| **7) Version de l'OS**                             | Système d'exploitation et version                        |
| **8) Carte Graphique**                             | Modèle de GPU installé                                   |
| **9) CPU%**                                        | % Processeur utilisé actuellement                        |
| **10) Uptime**                                     | Temps de connexion du compte depuis le dernier démarrage |
| **11) 10 derniers événements critiques**           | 10 derniers événements système critiques                 |
| **12) Température CPU**                            | Température du processeur                                |

**Notes importantes :**
- Toutes les informations sont sauvegardées dans des fichiers `info_<machine>_<date>.txt
- Les fichiers sont automatiquement rapatriés sur le serveur dans le dossier `script/info/`

## 7. Enregistrement des informations

### 7.1 Format des fichiers

Les informations récupérées sont enregistrées dans un fichier texte nommée :

```
info_<cible>_<date>.txt
```

**Exemple de nom de fichier :**

- ``info_CLIWIN01_20260421115045.txt``  :  Information sur la machine CLIWIN01
- ``info_Wilder_2026042115058.txt`` : Information sur l'utilisateur Wilder

**Format de la date :**

 - ``YYYYMMDDHHMMSS`` : Année Mois Jour Heure Minute Seconde
 - Exemple : ``2026042115058`` : 21 Avril 2026 à 11h50:58

### 7.2 Emplacement

Les fichiers d'informations sont automatiquement enregistrés sur le serveur de cette façon :

**Serveur Debian**

`` ~/Documents/TSSR-0226-P2-G1/script/info

**Serveur Windows**

`` C:\Users\<user>\Documents\TSSR-0226-P2-G1\script\ìnfo

## 8. Journalisation (Logs)

### 8.1 Format des fichiers

Chaque action effectuée par le script est enregistrée dans le fichier de log. <br>
Le format comprend la date, l'heure, l'utilisateur et l'action réalisée.

Les informations sont enregistrées dans un fichier log nommé :<br>
```
log_evt.log
```

**Format des entrées de log :**

Pour les actions de navigation :

```
YYYYMMDD_HHMMSS_utilisateur_événement
```

Pour les actions sur une cible :

```
YYYYMMDD_HHMMSS_utilisateur_événement_targetuser_targetcomputer
```

**Exemple d'entrées :**

```
20260421_112313_root_Start Script
20260421_112327_root_Navigation_Menu_Consultations_Logs
20260421_115045_root_Info_Consultation_Users_Windows
```

**Types d'événements journalisés :**

- Navigation dans les menus
- Actions effectuées
- Informations récupérées
- Erreurs

### 8.2 Emplacement

Le fichier de log se trouve dans des emplacements différents selon le serveur utilisé :

**Depuis SRVLX01 (Debian) :**
```
/var/log/log_evt.log
```

**Depuis SRVWIN01 (Windows Server) :**
```
C:\Windows\System32\LogFiles\log_evt.log
```

**Accès au fichier de log :**

**Sur Linux :**
```bash
# Consulter les 20 dernières lignes
tail -n 20 /var/log/log_evt.log

# Rechercher un événement spécifique
grep "CLILIN01" /var/log/log_evt.log

# Suivre en temps réel
tail -f /var/log/log_evt.log
```

**Sur Windows :**
```powershell
# Consulter les 20 dernières lignes
Get-Content C:\Windows\System32\LogFiles\log_evt.log -Tail 20

# Rechercher un événement spécifique
Select-String -Path C:\Windows\System32\LogFiles\log_evt.log -Pattern "CLIWIN01"
```

## 9. Quitter le script

Pour quitter le script correctement, retournez au menu principal et choisissez l'option **4 - Quitter** . 

**Ce qui se passe lors de la fermeture :**

- Le script enregistre l'événement "EndScript" dans le fichier de log
- Un message de confirmation s'affiche : `` Vous avez choisi de quitter``
- Le script se termine et libère toutes les ressources
- Vous revenez au terminal/Powershell

Comme vu auparavant, ne fermez pas le script avec ``CTRL+C`` , sinon l'événement de fermeture ne sera pas comptabilisé dans le fichier log

## 10. FAQ
