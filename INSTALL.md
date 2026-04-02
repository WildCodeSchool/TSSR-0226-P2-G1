
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
