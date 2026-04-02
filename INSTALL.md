
## SOMMAIRE

## 1.1 Prérequis Proxmox

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
