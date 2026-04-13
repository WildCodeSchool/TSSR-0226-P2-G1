
## SOMMAIRE
1. [**Prérequis techniques**](#1-prérequis-technique)

   - [**1.1 Prérequis Proxmox**](#11-prérequis-proxmox)
   - [**1.2 Prérequis pour le script principal Bash**](#12-prérequis-pour-le-script-principal-bash)
   - [**1.3 Prérequis pour le script principal PowerShell**](#13-prérequis-pour-le-script-principal-powershell)

2. [**Installation sur le serveur Debian**](#2-installation-sur-le-serveur-debian)

   - [**2.1 Installation de Open SSH-Server**](#21-installation-de-open-ssh-server)
   - [**2.2 Création de paire de clés sur Debian**](#22-création-de-paire-de-clés-sur-debian)
   - [**2.3 Copie de la clé publique sur CLILIN01**](#23-copie-de-la-clé-publique-sur-clilin01)
   - [**2.4 Copie de la clé publique sur CLIWIN01**](#24-copie-de-la-clé-publique-sur-cliwin01)
   - [**2.5 Préparation du serveur Debian pour le script principal**](#25-préparation-du-serveur-debian-pour-le-script-principal)

3. [**Installation sur le serveur Windows (Windows serveur 2025)**](#3-installation-sur-le-serveur-windows-windows-serveur-2025)

   - [**3.1 Installation OpenSSH-Client**](#31-installation-openssh-client)
   - [**3.2 Création de paire de clés sur Windows Serveur**](#32-création-de-paire-de-clés-sur-windows-serveur)
   - [**3.3 Copie de la clé Publique sur CLILIN01**](#33-copie-de-la-clé-publique-sur-clilin01)
   - [**3.4 Copie de la clé Publique sur CLIWIN01**](#34-copie-de-clé-publique-sur-cliwin01)
   - [**3.5 Préparation du serveur Windows pour le script principal**](#35-préparation-du-serveur-windows-pour-le-script-principal)

4. [**Installation de OpenSSH Serveur sur CLIWIN01 (Windows 11)**](#4--installation-de-openssh-serveur-sur-cliwin01-windows-11)
   - [**4.1 Installation Open SSH en CLI**](#41-installation-open-ssh-en-cli)
   - [**4.2 Modification du fichier de configuration SSH**](#42-modification-du-fichier-de-configuration-ssh)

5. [**Installation de OpenSSH Serveur sur CLILIN01 (Ubuntu)**](#5--installation-de-openssh-serveur-sur-clilin01-ubuntu)
   - [**5.1 Installation de OpenSSH-server**](#51-installation-de-openssh-server)
   - [**5.2 Modification du fichier de configuration SSH**](#52-modification-du-fichier-de-configuration-ssh)
  
6. [**FAQ**](#6-faq)

## 1. Prérequis technique
### 1.1 Prérequis Proxmox

Nous devons avoir 4 machines virtuelle sous Proxmox :

-  **Serveur Debian 13**
-  Nom : **SRVLX01** 
- IP : **172.16.10.10**
--------------------
-  **Serveur Windows 2025** 
- Nom : **SRVWIN01**
-  IP : **172.16.10.5**
--------------------
-  **Client Ubuntu**
- Nom : **CLILIN01**
-  IP : **172.16.10.30**
--------------------
-  **Client Windows 11** 
-  Nom : **CLIWIN01** 
- IP : **172.16.10.20**
--------------------
Passerelle par défaut : **172.16.10.254** 
DNS : **8.8.8.8**

Nous aurons besoin d'un compte **ROOT** et **Administrator** sur les 2 serveurs. Notre compte utilisateur sera toujours **Wilder** sur nos 4 vm.

### 1.2 Prérequis pour le script principal bash

Le script principal bash `script_bash.sh` nécessite :

1. **Accès SSH** configuré vers les machines clientes (Windows et Linux)
2. **Structure de dossiers** sur le serveur Debian :
``` 
~Documents/TSSR-0226-P2-P1/
 ├── scripts\
 │   ├── script_bash.sh
 │   └── info\    
```
### 1.3 Prérequis pour le script principal powershell

Le script principal powershell ``script_powershell.ps1`` nécessite :
1. **Accès SSH** configuré vers les machines clientes (Windows et Linux)
2. **Structure de dossiers** sur le serveur Windows:
```
 C:\Users\Wilder\Documents\TSSR-0226-P2-G1\
 ├── scripts\
 │   ├── script_powershell.ps1
 │   └── info\    

```
3. **Powershell Core 7.6** installé 
## 2. Installation sur le serveur Debian

### 2.1 Installation de Open SSH-Server.

Normalement, **Open SSH-Server** est installé de base sur Debian. Voici la commande pour le vérifier : 

``` bash
apt-cache policy openssh-server
```

Lorsque vous rentrez cette commande, il se passe ça : 
![verif_ssh_debian](https://github.com/WildCodeSchool/TSSR-0226-P2-G1/blob/main/Ressources/verif_ssh_debian.png)

Nous constatons que **OpenSSH** est bien installé et que nous avons la version 10.0.

Dans le cas ou **OpenSSH** n'est pas installé , voici la commande : 

``` bash
sudo apt update && sudo apt upgrade -y
sudo apt install openssh-server 
```

Maintenant , vérifions l'état du serveur **SSH** avec cette commande : 

``` bash
systemctl status sshd
```

![verif_ssh_debian_up](https://github.com/WildCodeSchool/TSSR-0226-P2-G1/blob/main/Ressources/verif_ssh_debian_UP.png)

Nous voyons que le statut est bien en mode *active*.
Si cela n'était pas le cas, voici la commande pour démarrer le service : 

``` bash
systemctl start sshd
```

### 2.2 Création de paire de clés sur Debian

Pour générer la paire de clés , voici la commande : 

``` bash
ssh-keygen -t ed25519 -f ~/.ssh/debian_ubuntu
```
Après cette commande, laissez la clé stocker par défaut en appuyant sur la touche **"ENTREE"** de votre clavier.
Passez également la **passphrase** avec la touche **"ENTREE"** de votre clavier.

![keygen_debian_ubuntu](https://github.com/WildCodeSchool/TSSR-0226-P2-G1/blob/main/Ressources/keygen_debian_ubuntu.png)

### 2.3 Copie de la clé publique sur CLILIN01

En considérant que sur la machine **CLILIN01** le paragraphe **"5 . Installation de OpenSSH Serveur sur CLILIN01 (Ubuntu)"** ai été appliqué , nous allons pouvoir copier la clé publique sur la machine Linux :

```bash
ssh-copy-id -i ~/.ssh/debian_ubuntu.pub wilder@172.16.10.30
```

Nous devrions avoir cette affichage : 

![keygen_debian_ubuntu_keycopy](https://github.com/WildCodeSchool/TSSR-0226-P2-G1/blob/main/Ressources/keygen_debian_ubuntu_fonctionne.png)

Nous allons maintenant créer un *alias* pour avoir seulement à écrire une commande pour se connecter en **ssh** à notre machine Linux.

Pour se faire, nous allons créer et modifier un document :

``` bash
nano ~/.ssh/config
```

Puis : 

![creation_alias_ubuntu](https://github.com/WildCodeSchool/TSSR-0226-P2-G1/blob/main/Ressources/creation_alias_ubuntu.png)

Vous pouvez dès a présent vous connecter à votre machine en utilisant 
``` bash
ssh ubuntu
```

### 2.4 Copie de la clé publique sur CLIWIN01

En considérant que sur la machine **CLIWIN01** le paragraphe **"4 . Installation d'OpenSSH Serveur sur CLIWIN01"** ai été appliqué , nous allons pouvoir copier la clé publique sur la machine Windows :

Après avoir créer une paire de clé sur Debian ( voir 2.2 ) , nous allons pouvoir l'envoyer vers le client Windows

```bash
cat ~/.ssh/debian_windows.pub | ssh wilder@172.16.10.20 "powershell -Command \"\$input | Out-File -FilePath C:\Users\ton_nom\.ssh\authorized_keys -Append -Encoding ascii\""
```

Nous allons par la suite créer un *alias* , comme pour Ubuntu, en éditant le fichier **config** 

![creation_alias_windows](https://github.com/WildCodeSchool/TSSR-0226-P2-G1/blob/main/Ressources/creation_alias_windows.png)

Pour autoriser la connexion par clé, nous allons modifier le fichier **sshd_config** sur Windows.
Premièrement nous allons décommenté la ligne suivante en enlevant le **#** : 

![sshd_config_pubkey](https://github.com/WildCodeSchool/TSSR-0226-P2-G1/blob/main/Ressources/modif_sshdconfig_pubkey.png)

Puis, commenter les deux dernières lignes du fichier en ajoutant un **#** :

![sshd_config_commente](https://github.com/WildCodeSchool/TSSR-0226-P2-G1/blob/main/Ressources/sshd_config_commente.png)

Sauvegardez en faisant un **CTRL+S** , puis faites un ``restart-service sshd``

Vous pouvez dès a présent vous connecter à votre machine en utilisant 

``` bash
ssh windows
```

### 2.5 Préparation du serveur Debian pour le script principal

#### Création de l'arborescence de dossiers

Le script se trouve dans une structure de dossiers spécifique . Il vous suffira de la créer : 

``` bash
# Créer la structure de base 
mkdir -p ~/Documents/TSSR-2026-P2-G1/script/info
```

Lancez le script depuis le dossier **script** .
Les fichiers d'informations seront rapatriés dans le dossier **info**.

#### Création du fichier de log

Ce fichier est capable de se créer seul au lancement du script si il n'existe pas, nous allons le créer pour éviter de possibles soucis.

``` bash
# Créer le fichier de log 
sudo touch /var/log/log_evt.log

# Donner les droits d'écriture
sudo chmod 666 /var/log/log_evt.log
```

#### Placement du script

``` bash
# Placer le sript
cp script_bash.sh ~/Documents/TSSR-0226-P2-G1/script/

# Se rendre dans le dossier script et rendre le script executable
chmod +x script_bash.sh
```
## 3. Installation sur le serveur Windows (Windows serveur 2025)

### 3.1 Installation OpenSSH-Client 

Vérifiez que **OpenSSH-Client** est bien installé sur votre Windows serveur :

```
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'
```

Vous devriez avoir ce résultat : 

![Install_serverssh_serveurwindows](https://github.com/WildCodeSchool/TSSR-0226-P2-G1/blob/main/Ressources/install_serverssh_serveurwin.png)

Si le client n'est pas installer, entrez la commande suivante : 

```
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
```

### 3.2 Création de paire de clés sur Windows Serveur 

Pour générer la paire de clés voici la commande :

```
ssh-keygen -t ed25519 -f ~/.ssh/serveur_ubuntu
```

Après cette commande, laissez la clé stocker par défaut en appuyant sur la touche **"ENTREE"** de votre clavier.
Passez également la **passphrase** avec la touche **"ENTREE"** de votre clavier.

### 3.3 Copie de la clé Publique sur CLILIN01

En considérant que sur la machine **CLILIN01** le paragraphe **"x.x Installation d'OpenSSH Serveur sur CLILIN01"** ai été appliqué , nous allons pouvoir copier la clé publique sur la machine Linux :

Sur la machine Windows Serveur 2025 : 

```
ssh wilder@172.16.10.30
```

La connexion **SSH** s'effectue en rentrant le mot de passe de Wilder.

Ensuite, vous pouvez envoyer votre clé publique sur la machine Linux : 

```shell
scp C:\Users\Wilder\.ssh\serveur_ubuntu.pub wilder@172.16.10.30:~./ssh
```

Sur votre machine **Ubuntu** , copier la clé qui provient de *serveur_ubuntu.pub* dans *authorized_keys* .

Comme précédemment, nous allons créer un alias pour faciliter la connexion.
Nous allons créer le fichier **/.ssh/config** sur notre Windows Serveur :

```shell
notepad "$env:USERPROFILE\.ssh\config"
```

Puis remplir le fichier comme ceci : 

![alias_serveur_ubuntu](https://github.com/WildCodeSchool/TSSR-0226-P2-G1/blob/main/Ressources/configy_alias_serveur_ubuntu.png)

Sauvegardez en faisant un **CTRL+S**.

Vous pouvez dès a présent vous connecter à votre machine en utilisant 

```shell
ssh ubuntu
```

### 3.4 Copie de clé Publique sur CLIWIN01

En considérant que sur la machine **CLIWIN01** le paragraphe **"4 . Installation d'OpenSSH Serveur sur CLIWIN01"** ai été appliqué , nous allons pouvoir copier la clé publique sur la machine Windows :

Après avoir créer une paire de clé sur Windows Serveur ( voir 3.2 ) , nous allons pouvoir l'envoyer vers le client Windows.

Sur la machine Windows Serveur 2025 :

```shell
ssh wilder@172.16.10.20
```

La connexion **SSH** s'effectue en rentrant le mot de passe de Wilder.

Ensuite, vous pouvez envoyer votre clé publique sur la machine Windows : 

```shell
scp C:\Users\Wilder\.ssh\serveur_windows.pub wilder@172.16.10.20:~./ssh
```
Sur votre machine **Windows** , copier la clé qui provient de *serveur_windows.pub* dans *authorized_keys* .

Comme précédemment, nous allons créer un alias pour faciliter la connexion.
Nous allons modifier le fichier **/.ssh/config** sur notre Windows Serveur :

```shell
notepad "$env:USERPROFILE\.ssh\config"
```

Puis remplir le fichier comme ceci : 

![alias_serveur_windows](https://github.com/WildCodeSchool/TSSR-0226-P2-G1/blob/main/Ressources/configy_alias_serveur_windows.png)

Sauvegardez en faisant un **CTRL+S**.

Vous pouvez dès a présent vous connecter à votre machine en utilisant 

```shell
ssh windows
```

### 3.5 Préparation du serveur Windows pour le script principal

#### Installation de PowerShell Core 7.6

Le script PowerShell nécessite PowerShell Core version 7.6.

Pour télécharger et installer PowerShell 7.6 : 

``` powershell
# Télécharger et installer PowerShell 7.6
winget install --id Microsoft.Powershell --source winget

# Vérifiez l'installation
$PSVersionTable.PSVersion
```

#### Création du fichier de log 

Ce fichier est capable de se créer seul au lancement du script si il n'existe pas, nous allons le créer pour éviter de possibles soucis.

``` powershell
# Créer le fichier de log (en Administrateur sur PowerShell)
New-Item -ItemType File -Path "C:\Windows\System32\LogFiles\log_evt.log"
```

#### Placement du script

``` PowerShell 
# Placer le script principal
Copy-Item "script_powershell.ps1" "$env:USERPROFILE\Documents\TSSR-0226-P2-G1\script\"
```

## 4.  Installation de OpenSSH Serveur sur CLIWIN01 (Windows 11)

### 4.1 Installation Open SSH en CLI 

Ouvrir PowerShell en mode **administrateur** :

```PowerShell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```

Maintenant, démarrez le service :

```powershell 
Start-Service sshd
```

Configurez le service pour qu'il démarre automatiquement au démarrage de la machine :

```powershell
Set-Service -Name sshd -StartupType "Automatic"
```

![get_service_sshd](https://github.com/WildCodeSchool/TSSR-0226-P2-G1/blob/main/Ressources/get_service_CLIWIN01.png)

#### 4.2 Modification du fichier de configuration SSH

Dans votre PowerShell en administrateur :

```powershell
notepad C:\ProgramData\ssh\sshd_config
```

Il faut dé-commenter cette ligne = Enlevez le **#** devant pour l'activer

```
PubkeyAuthentication yes
```

Il faut commenter cette ligne = Ajoutez un **#** devant pour la désactiver

```
PasswordAuthentication yes
```

Dernière étape , relancez  le service **sshd**

``` powershell
Restart-Service sshd
```

## 5.  Installation de OpenSSH Serveur sur CLILIN01 (Ubuntu)

#### 5.1 Installation de OpenSSH-server

Dans le terminal , tapez à la suite ces commandes : 

``` bash
sudo apt update && sudo apt upgrade -y
sudo apt install openssh-server -y
sudo systemctl start ssh 
sudo systemctl enable ssh
```

Vérifiez que le service est bien **enabled** :

``` bash
sudo systemctl status ssh
```

#### 5.2 Modification du fichier de configuration SSH

Pour se rendre dans le fichier de configuration : 

``` bash
sudo nano /etc/ssh/sshd_config
```

Dans ce fichier, vous allez décommenter ces lignes : 

```
PubkeyAuthentication yes
PasswordAuthentication no
```

Faîtes un **CTRL+O** puis **ENTRER** pour sauvegarder. **CTRL+X** pour sortir du fichier . 
Le plus important maintenant est de redémarrer le service **ssh** :

```bash
sudo systemctl restart ssh
```

## 6. FAQ
