
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
![verif_ssh_debian]()

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

![verif_ssh_debian_up]()

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

![keygen_debian_ubuntu]()

Après cette commande, laisser la clé stocker par defaut en appuyant sur **"ENTREE"** de votre clavier.
