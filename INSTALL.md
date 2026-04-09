
## SOMMAIRE

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

### 2.2 Création d'une paire de clés Debian

Pour générer la paire de clés , voici la commande : 

``` bash
ssh-keygen -t ed25519 -f ~/.ssh/debian_ubuntu
```
Après cette commande, laissez la clé stocker par défaut en appuyant sur la touche **"ENTREE"** de votre clavier.
Passez également la **passphrase** avec la touche **"ENTREE"** de votre clavier.

![keygen_debian_ubuntu](https://github.com/WildCodeSchool/TSSR-0226-P2-G1/blob/main/Ressources/keygen_debian_ubuntu.png)

### 2.3 Copie de la clé publique sur CLILIN01

En considérant que sur la machine **CLILIN01** le paragraphe **"x.x Installation d'OpenSSH Serveur sur CLILIN01"** ai été appliqué , nous allons pouvoir copier la clé publique sur la machine Linux :

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
### 2.3 Copie de la clé publique sur CLIWIN01

En considérant que sur la machine **CLIWIN01** le paragraphe **"x.x Installation d'OpenSSH Serveur sur CLIWIN01"** ai été appliqué , nous allons pouvoir copier la clé publique sur la machine Windows :

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

En considérant que sur la machine **CLIWIN01** le paragraphe **"x.x Installation d'OpenSSH Serveur sur CLIWIN01"** ai été appliqué , nous allons pouvoir copier la clé publique sur la machine Windows :

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


