#################################################
#                                               #
#                     HELP                      #
#                                               #
#################################################


##############################################################################################
############################## DEBUT DU SCRIPT 12.04.2026 ####################################
####### SCRIPT AUTOMATISATION SUR WINDOWS SERVEUR POUR UN CLIENT WINDOWS ET LINUX ############
############## ZINEDINE --------------- BRICE ------------------------- MOHAMED ##############
################ A LANCER EN ADMINISTRATEUR SINON LE SCRIPT S'ARRETE #########################
############################## FIN DU SCRIPT 21.04.2026 ######################################
##############################################################################################



# Verification que le script est bien lancé en administrateur

# Identité de la personne qui lance le script
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

# Verification du groupe Admin
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "------------------------------------------------------------" -ForegroundColor Red
    Write-Host "ERREUR : Le script doit être exécuté en tant qu'administrateur." -ForegroundColor Red
    Write-Host "------------------------------------------------------------" -ForegroundColor Red
    exit 1
}


#################################################
#                                               #
#                  FONCTIONS                    #
#                                               #
#################################################

############ Fonction LOG ##############

$LOG_FILE = "C:\Windows\System32\LogFiles\log_evt.log"
$USER_NAME = $env:USERNAME

function Write-Log {
    param (
        [string]$evenement
    )

    $date_actuelle = Get-Date -Format "yyyyMMdd"
    $heure_actuelle = Get-Date -Format "HHmmss"

    $ligne = "${date_actuelle}_${heure_actuelle}_${USER_NAME}_${evenement}"
    
    Add-Content -Path $LOG_FILE -Value $ligne
}


############## Fonction : Création des répertoires ##############

function creation_repertoire_windows {
    while ($true) {

        $nom_repertoire = Read-Host "Nom du répertoire à créer sur C:\ (q pour quitter)"

        # Condition de sortie

        if ($nom_repertoire -eq "q") {
            Clear-Host
            break
        }

        
        # Test si le repertoire existe
        $existe = ssh windows "powershell -Command Test-Path -Path 'C:\$nom_repertoire'"

        # Creation repertoire si il n'existe pas
       if ($existe -match "True") {
            Write-Host "Erreur : le répertoire '$nom_repertoire' existe déjà sur la machine distante." -ForegroundColor Red
        } else {
            # Création du répertoire 
            ssh windows "powershell -Command New-Item -ItemType Directory -Path 'C:\$nom_repertoire'"
        
        # Vérification
        $verif = ssh windows "powershell -Command Test-Path -Path 'C:\$nom_repertoire'"
            if ($verif -match "True") {
                Write-Host "Répertoire '$nom_repertoire' créé avec succès sur C:\" -ForegroundColor Green
                Write-Log "Creation_Repertoire_Windows_$nom_repertoire"
            } else {
                Write-Host "Une erreur est survenue lors de la création." -ForegroundColor Red
                Write-Log "Echec_Creation_Repertoire_Windows_$nom_repertoire"
            }
        }
    }
}

function creation_repertoire_ubuntu {
    while ($true) {
        $nom_repertoire = Read-Host "Nom du répertoire à créer sur Ubuntu (q pour quitter)"
        
        # Condition de sortie
        if ($nom_repertoire -eq "q") { 
            Clear-Host
            break 
        }

        # Verification de l'existence du repertoire , ou création
        ssh ubuntu "if [ -d '$nom_repertoire' ]; then echo 'Existe'; exit 1; else mkdir '$nom_repertoire'; exit 0; fi"

        if ($LASTEXITCODE -eq 0) {
            Write-Host "Répertoire '$nom_repertoire' créé avec succès sur Ubuntu." -ForegroundColor Green
            Write-Log "Creation_Repertoire_Ubuntu_$nom_repertoire" 
        } else {
            Write-Host "Erreur : le répertoire '$nom_repertoire' existe déjà ou n'a pas pu être créé." -ForegroundColor Red
            Write-Log "Echec_Creation_Repertoire_Ubuntu_$nom_repertoire" 
        }
    }
}

############## Fonction : Suppression des répertoires ##############

function suppression_repertoire_windows {
    while ($true) {

        $nom_repertoire = Read-Host "Nom du répertoire à supprimer sur C:\ (q pour quitter)"

        # Condition de sortie

        if ($nom_repertoire -eq "q") {
            Clear-Host
            break
        }

        
        # Test si le repertoire existe
        $existe = ssh windows "powershell -Command Test-Path -Path 'C:\$nom_repertoire'"

        # Check si le répertoire existe
       if ($existe -match "False") {
            Write-Host "Erreur : le répertoire '$nom_repertoire' n'existe pas sur la machine distante." -ForegroundColor Red
        } else {
            # Suppression du répertoire 
            ssh windows "powershell -Command Remove-Item -Path 'C:\$nom_repertoire' -Recurse -Force"
        
        # Vérification
        $verif = ssh windows "powershell -Command Test-Path -Path 'C:\$nom_repertoire'"
            if ($verif -match "False") {
                Write-Host "Répertoire '$nom_repertoire' supprimé avec succès sur C:\" -ForegroundColor Green
                Write-Log "Suppression_Repertoire_Windows_$nom_repertoire" 
            } else {
                Write-Host "Une erreur est survenue lors de la suppression." -ForegroundColor Red
                Write-Log "Echec_Suppression_Repertoire_Windows_$nom_repertoire"
            }
        }
    }
}

function suppression_repertoire_ubuntu {
    while ($true) {

        $nom_repertoire = Read-Host "Nom du répertoire à supprimer (q pour quitter)"

        # Condition de sortie

        if ($nom_repertoire -eq "q") {
            Clear-Host
            break
        }

        # Test si le repertoire existe et supression si il existe
        ssh ubuntu "if [ -d ""$nom_repertoire"" ]; then rm -rf ""$nom_repertoire""; exit 0; else exit 1; fi"
      
        # Vérification
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Répertoire '$nom_repertoire' supprimé avec succès." -ForegroundColor Green
            Write-Log "Suppression_Repertoire_Ubuntu_$nom_repertoire"
        } else {
            Write-Host "Erreur : le répertoire '$nom_repertoire' n'existe pas." -ForegroundColor Red
            Write-Log "Echec_Suppression_Repertoire_Ubuntu_$nom_repertoire"
        }
    }
}

############## Fonction : Verrouillage ##############

function verrouillage_windows {
    while ($true) {

        $reponse = Read-Host "Voulez-vous vraiment verrouiller le client Windows ? (oui/q pour quitter) " 
         
        # Condition de sortie
        if ($reponse -eq "q") {
            Clear-Host
            break
        }
        elseif ($reponse -eq "oui") {
            Write-Host "Verrouillage de la session en cours..." -ForegroundColor Yellow
            
            # Recherche l'ID de la session active et verrouillage
            ssh windows "powershell -Command ""if ((query session | Select-String 'console') -match '(\d+)') { tsdiscon `$matches[1] }"""

            if ($LASTEXITCODE -eq 0) {
                Write-Host "Le client Windows a été verrouillé avec succès." -ForegroundColor Green
                Write-Log "Verrouillage_Windows"
            } else {
                Write-Host "Erreur : Impossible de verrouiller la session (vérifiez si une session est active)." -ForegroundColor Red
                Write-Log "Echec_Verrouillage_Windows"
            }
        }
    }
}

function verrouillage_ubuntu {
    while ($true) {

        $reponse = Read-Host "Voulez-vous vraiment verrouiller le client Ubuntu ? (oui/q pour quitter) " 
         
        # Condition de sortie
        if ($reponse -eq "q") {
            Clear-Host
            break
        }
        elseif ($reponse -eq "oui") {
            Write-Host "Verrouillage de la session en cours..." -ForegroundColor Yellow
            
            # Recherche l'ID de session la active et verrouillage
            ssh ubuntu @'
            loginctl list-sessions --no-legend | grep "wilder" | awk '{print $1}' | xargs -I{} env DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1001/bus loginctl lock-session {}
'@

            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Le client Ubuntu a été verrouillé avec succès." -ForegroundColor Green
                Write-Log "Verrouillage_Ubuntu"
            } else {
                Write-Host "Erreur : Impossible de verrouiller la session (vérifiez si une session est active)." -ForegroundColor Red
                Write-Log "Echec_Verrouillage_Ubuntu"
            }
        }
    }
}

############## Fonction : Redemarrage ##############

function redemarrage_windows {
    while ($true) {

        $reponse = Read-Host "Voulez-vous vraiment redemarrer le client Windows ? (oui/q pour quitter) " 
         
        # Condition de sortie
        if ($reponse -eq "q") {
            Clear-Host
            break
        }
        elseif ($reponse -eq "oui") {
            Write-Host "Redemarrage de la session en cours..." -ForegroundColor Yellow
            
            # Redemarrage
            ssh windows "shutdown /r /f /t 0"

            if ($LASTEXITCODE -eq 0) {
                Write-Host "Le client Windows a été redemarrer avec succès." -ForegroundColor Green
                Write-Log "Redemarrage_Windows"
            } else {
                Write-Host "Erreur : Impossible de redemarrer." -ForegroundColor Red
                Write-Log "Echec_Redemarrage_Windows"
            }
        }
    }
}

function redemarrage_ubuntu {
    while ($true) {

        $reponse = Read-Host "Voulez-vous vraiment redemarrer le client Ubuntu ? (oui/q pour quitter) " 
         
        # Condition de sortie
        if ($reponse -eq "q") {
            Clear-Host
            break
        }
        elseif ($reponse -eq "oui") {
            Write-Host "Redemarrage en cours..." -ForegroundColor Yellow
            
            # Redemarrage
            ssh ubuntu "sudo reboot"

            if ($LASTEXITCODE -eq 0) {
                Write-Host "Le client Ubuntu a été redemarrer avec succès." -ForegroundColor Green
                Write-Log "Redemarrage_Ubuntu"
            } else {
                Write-Host "Erreur : Impossible de redemarrer." -ForegroundColor Red
                Write-Log "Echec_Redemarrage_Ubuntu"
            }
        }
    }
}

############## Fonction : Supprimer utilisateur Windows ##############

function supprimer_utilisateur_windows {
    while ($true) {

        $nom_utilisateur = Read-Host "Quel utilisateur voulez-vous supprimer ? (q pour quitter)"

        if ($nom_utilisateur -eq "q") {
            Clear-Host
            break
        }

        $existe = ssh windows "powershell -Command Get-LocalUser -Name '$nom_utilisateur' 2>null"

        if ($existe -match "$nom_utilisateur") {

            ssh windows "powershell -Command Remove-LocalUser -Name '$nom_utilisateur'"

            if ($LASTEXITCODE -eq 0) {
                Write-Host "L'utilisateur '$nom_utilisateur' a été supprimé avec succès." -ForegroundColor Green
                Write-Log "Suppression_Utilisateur_Windows_${nom_utilisateur}"
            } else {
                Write-Host "Une erreur est survenue lors de la suppression." -ForegroundColor Red
                Write-Log "Echec_Suppression_Utilisateur_Windows_${nom_utilisateur}"
            }

        } else {
            Write-Host "Erreur : l'utilisateur '$nom_utilisateur' n'existe pas sur la machine distante." -ForegroundColor Red
            Write-Log "Echec_Suppression_Utilisateur_Windows_${nom_utilisateur}_Inexistant"
        }
    }
}

function supprimer_utilisateur_ubuntu {
    while ($true) {

        $nom_utilisateur = Read-Host "Quel utilisateur voulez-vous supprimer ? (q pour quitter)"

        # Condition de sortie
        if ($nom_utilisateur -eq "q") {
            Clear-Host
            break
        }

        # Vérification que l'utilisateur existe
        $existe = ssh ubuntu "id '$nom_utilisateur' 2>/dev/null && echo 'True' || echo 'False'"

        if ($existe -match "True") {

            # Suppression de l'utilisateur
            ssh ubuntu "sudo deluser '$nom_utilisateur'"

            # Vérification que la suppression a bien fonctionné
            $verif = ssh ubuntu "id '$nom_utilisateur' 2>/dev/null && echo 'True' || echo 'False'"
            if ($verif -match "False") {
                Write-Host "Utilisateur '$nom_utilisateur' supprimé avec succès." -ForegroundColor Green
                Write-Log "Suppression_Utilisateur_Ubuntu_${nom_utilisateur}"
            } else {
                Write-Host "Une erreur est survenue lors de la suppression." -ForegroundColor Red
                Write-Log "Echec_Suppression_Utilisateur_Ubuntu_${nom_utilisateur}"
            }

        } else {
            Write-Host "Erreur : l'utilisateur '$nom_utilisateur' n'existe pas sur la machine distante." -ForegroundColor Red
            Write-Log "Suppression_Utilisateur_Ubuntu_${nom_utilisateur}_Inexistant"
        }
    }
}
############## Fonction : Creatrion utilisateur Windows ##############

function creation_utilisateur_windows {
    while ($true) {

        $nom_utilisateur = Read-Host "Quel utilisateur souhaitez-vous créer ? (q pour quitter)"

        # Condition de sortie
        if ($nom_utilisateur -eq "q") {
            Clear-Host
            break
        }

        # Vérification que l'utilisateur n'existe pas déjà
        $existe = ssh windows "powershell -Command Get-LocalUser -Name '$nom_utilisateur' 2>null"

        if ($existe -match "$nom_utilisateur") {
            Write-Host "Erreur : l'utilisateur '$nom_utilisateur' existe déjà sur la machine distante." -ForegroundColor Red
            Write-Log "Echec_Creation_Utilisateur_Windows_${nom_utilisateur}_Existant"

        } else {

            # Création de l'utilisateur
            ssh windows "powershell -Command New-LocalUser -Name '$nom_utilisateur' -NoPassword"

            # Vérification que la création a bien fonctionné
            $verif = ssh windows "powershell -Command Get-LocalUser -Name '$nom_utilisateur'"
            if ($verif -match "$nom_utilisateur") {
                Write-Host "Utilisateur '$nom_utilisateur' créé avec succès." -ForegroundColor Green
                Write-Log "Creation_Utilisateur_Windows_${nom_utilisateur}"
            } else {
                Write-Host "Une erreur est survenue lors de la création." -ForegroundColor Red
                Write-Log "Echec_Creation_Utilisateur_Windows_${nom_utilisateur}"
            }
        }
    }
}

function creation_utilisateur_ubuntu {
    while ($true) {

        $nom_utilisateur = Read-Host "Quel utilisateur souhaitez-vous créer ? (q pour quitter)"

        # Condition de sortie
        if ($nom_utilisateur -eq "q") {
            Clear-Host
            break
        }

        # Vérification que l'utilisateur n'existe pas déjà
        $existe = ssh ubuntu "id '$nom_utilisateur' 2>/dev/null && echo 'True' || echo 'False' 2>/dev/null"

        if ($existe -match "True") {
            Write-Host "Erreur : l'utilisateur '$nom_utilisateur' existe déjà sur la machine distante." -ForegroundColor Red

        } else {

            # Création de l'utilisateur
            ssh ubuntu "sudo useradd -m '$nom_utilisateur'"

            # Vérification que la création a bien fonctionné
            $verif = ssh ubuntu "id '$nom_utilisateur' 2>/dev/null && echo 'True' || echo 'False'"
            if ($verif -match "True") {
                Write-Host "Utilisateur '$nom_utilisateur' créé avec succès." -ForegroundColor Green
                Write-Log "Creation_Utilisateur_Ubuntu_${nom_utilisateur}"
            } else {
                Write-Host "Une erreur est survenue lors de la création." -ForegroundColor Red
                Write-Log "Echec_Creation_Utilisateur_Ubuntu_${nom_utilisateur}"
            }
        }
    }
}

############## Fonction : Changement Mot de Passe ##############

function changement_mdp_windows {
    while ($true) {

        $nom_utilisateur = Read-Host "De quel compte voulez-vous changer le mot de passe ? (q pour quitter)"

        if ($nom_utilisateur -eq "q") {
            Clear-Host
            break
        }

        # Vérification compatible Windows
        $existe = ssh windows "net user `"$nom_utilisateur`" > nul 2>&1 && echo True || echo False"

        if ($existe -match "True") {
            Write-Host "Changement de mot de passe pour $nom_utilisateur sur Windows..." -ForegroundColor Yellow
            ssh -t windows "net user `"$nom_utilisateur`" *"

            # Vérification au bon endroit
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Le mot de passe de '$nom_utilisateur' a été changé." -ForegroundColor Green
                Write-Log "Changement_MDP_Utilisateur_Windows_${nom_utilisateur}"
            } else {
                Write-Host "Une erreur est survenue lors du changement de mot de passe de '$nom_utilisateur'." -ForegroundColor Red
                Write-Log "Echec_Changement_MDP_Utilisateur_Windows_${nom_utilisateur}"
            }

        } else {
            Write-Host "Le compte '$nom_utilisateur' n'existe pas." -ForegroundColor Red
            Write-Log "Echec_Changement_MDP_Utilisateur_Windows_${nom_utilisateur}_Inexistant"
        }
    }
}

function changement_mdp_ubuntu {
    while ($true) {

        $nom_utilisateur = Read-Host "De quel compte voulez-vous changer le mot de passe ? (q pour quitter)"

        if ($nom_utilisateur -eq "q") {
            Clear-Host
            break
        }

        # Vérification compatible Windows
        $existe = ssh ubuntu "id $nom_utilisateur &>/dev/null && echo True || echo False"

        if ($existe -match "True") {
            Write-Host "Changement de mot de passe pour $nom_utilisateur sur Ubuntu..." -ForegroundColor Yellow
            ssh -t ubuntu "sudo passwd $nom_utilisateur"

            # Vérification au bon endroit
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Le mot de passe de '$nom_utilisateur' a été changé." -ForegroundColor Green
                Write-Log "Changement_MDP_Utilisateur_Ubuntu_${nom_utilisateur}"
            } else {
                Write-Host "Une erreur est survenue lors du changement de mot de passe de '$nom_utilisateur'." -ForegroundColor Red
                Write-Log "Echec_Changement_MDP_Utilisateur_Ubuntu_${nom_utilisateur}"
            }

        } else {
            Write-Host "Le compte '$nom_utilisateur' n'existe pas." -ForegroundColor Red
            Write-Log "Echec_Changement_MDP_Utilisateur_Ubuntu_${nom_utilisateur}_Inexistant"
        }
    }
}

############## Fonction : Ajout a un groupe ##############

function ajout_grp_ubuntu {
    
    while ($true)
    {
        # demande quel utilisateur 
        $user = Read-Host "Quel utilisateur souhaitez-vous ajouter à un groupe ? (q pour quitter)"
        
        # verif si l'utilisateur existe
        if ($user -eq "q")
        {
            Clear-Host
            break
        }

        $existe = ssh ubuntu "grep -q '${user}:' /etc/passwd && echo true || echo false"
        if ($existe -match "false")
        {
            Write-Host "L'utilisateur n'existe pas !" -ForegroundColor Red
            Write-Log "Echec_Ajout_Groupe_Ubuntu_${nom_utilisateur}_Inexistant"
            break
        }

        # demande dans quel groupe ajouter l'utilisateur
        $groupe = Read-Host "Dans quel groupe souhaitez-vous ajouter $user ?"

        # verif si le groupe existe et ajout de l'utilisateur au groupe
        $verif = ssh ubuntu "grep -q '${groupe}:' /etc/group && echo true || echo false"
        if ($verif -match "true")
        {
            ssh ubuntu "sudo usermod -aG $groupe $user"
            Write-Host "$user a bien été ajouté à $groupe" -ForegroundColor Green
            Write-Log "Ajout_Groupe_Ubuntu_${nom_utilisateur}"
        }
        else
        {
            $creer = Read-Host "Le groupe n'existe pas ! Voulez-vous le créer ? (oui/non)"
            if ($creer -eq "oui")
            {
                ssh ubuntu "sudo groupadd $groupe"
                ssh ubuntu "sudo usermod -aG $groupe $user"
                Write-Host "$user a bien été ajouté à $groupe" -ForegroundColor Green
                Write-Log "Ajout_Groupe_Ubuntu_${nom_utilisateur}"
            }
            else
            {
                Write-Host "Une erreur est survenu ..." -ForegroundColor Red
                Write-Log "Echec_Ajout_Groupe_Ubuntu_${nom_utilisateur}"
            }
        }
    }
}

function ajout_grp_windows{
    while ($true)
    {
        # demande quel utilisateur on souhaite ajouter au grp
        $user = Read-Host "Quel utilisateur souhaitez-vous ajouter au groupe ? (q pour quitter)"
        if ($user -eq "q")
        {
            Clear-Host
            break
        }
        # demande quel groupe
        $groupe = Read-Host "Dans quel groupe souhaitez-vous ajouter $user ?"
        # verif que l'utilisateur existe
        $existe = ssh windows "net user $user >nul 2>&1 && echo true || echo false"
        if ($existe -match "false")
        {
            Write-Host "L'utilisateur n'existe pas !" -ForegroundColor Red
            Write-Log "Echec_Ajout_Groupe_Windows_${nom_utilisateur}_Inexistant"
            break
        }
        else
        {
            Write-Host "L'utilisateur $user existe"
        }
        # verif que le groupe existe
        $grpExiste = ssh windows "net localgroup $groupe >nul 2>&1 && echo true || echo false"
        if ($grpExiste -match "false")
        {
            Write-Host "Le groupe n'existe pas ! Création en cours..." -ForegroundColor Yellow
            $createGrp = ssh windows "net localgroup $groupe /add >nul 2>&1 && echo true || echo false"
            if ($createGrp -match "false")
            {
                Write-Host "Erreur : impossible de créer le groupe $groupe !" -ForegroundColor Red
                break
            }
            else
            {
                Write-Host "Le groupe $groupe a bien été créé" -ForegroundColor Green
            }
        }
        else
        {
            Write-Host "Le groupe $groupe existe déjà" -ForegroundColor Green
        }
        # ajout au groupe (existant ou nouvellement créé)
        $addUser = ssh windows "net localgroup $groupe $user /add >nul 2>&1 && echo true || echo false"
        if ($addUser -match "false")
        {
            Write-Host "Erreur : impossible d'ajouter $user au groupe $groupe !" -ForegroundColor Red
            Write-Log "Echec_Ajout_Groupe_Windows_${nom_utilisateur}"
            break
        }
        else
        {
            Write-Host "$user a bien été ajouté au groupe $groupe" -ForegroundColor Green
            Write-Log "Ajout_Groupe_Windows_${nom_utilisateur}"
        }
    }
}


############## Fonction : Ajout a un groupe Admin ##############

function ajout_grp_admin_ubuntu{
    while ($true)
    {
        # demande quel utilisateur on souhaite ajouter au grp admin
        $user = Read-Host "Quel utilisateur souhaitez-vous ajouter au groupe admin ? (q pour quitter)"
        if ($user -eq "q")
        {
            Clear-Host
            break
        }
        
        # verif que l'utilisateur existe
        $existe = ssh ubuntu "grep -q '${user}:' /etc/passwd && echo true || echo false"
        if ($existe -match "false")
        {
            Write-Host "L'utilisateur n'existe pas !" -ForegroundColor Red
            Write-Log "Echec_Ajout_Groupe_Admin_Ubuntu_${nom_utilisateur}_Inexistant"
            break
        }

         # ajout de l'utilisateur dans le groupe admin
         ssh ubuntu "sudo usermod -aG sudo $user"
         Write-Host "$user a bien été ajouté au groupe admin (sudo)" -ForegroundColor Green
         Write-Log "Ajout_Groupe_Admin_Ubuntu_${nom_utilisateur}"
      }
}

function ajout_grp_admin_win{
    while ($true)
    {
        # demande quel utilisateur on souhaite ajouter au grp admin
        $user = Read-Host "Quel utilisateur souhaitez-vous ajouter au groupe admin ? (q pour quitter)"
        if ($user -eq "q")
        {
            Clear-Host
            break
        }
        
        # verif que l'utilisateur existe
        $existe = ssh windows "net user $user >nul 2>&1 && echo true || echo false"
        if ($existe -match "false")
        {
            Write-Host "L'utilisateur n'existe pas !" -ForegroundColor Red
            Write-Log "Echec_Ajout_Groupe_Admin_Windows_${nom_utilisateur}_Inexistant"
            break
        }
        ssh windows "net localgroup Administrateurs $user /add"
        Write-Host "$user a bien été ajouté au groupe admin (Administrateurs)" -ForegroundColor Green
        Write-Log "Ajout_Groupe_Admin_Ubuntu_${nom_utilisateur}"
    }
}


############## Fonction : Activation Parefeu##############
function activation_parefeu_ubuntu {
    while ($true) {

        $reponse = Read-Host "Voulez-vous activer le pare-feu du client Ubuntu ? (O/N)"

        # Condition de sortie
        if ($reponse -eq "N") {
            Write-Host "Opération annulée."
            Clear-Host
            break
        }

        if ($reponse -eq "O") {

            # Activation du pare-feu sur Ubuntu via SSH
            ssh ubuntu "sudo ufw allow ssh && sudo ufw --force enable"

            # Vérification que le pare-feu a bien été activé
            $verif = ssh ubuntu "sudo ufw status | grep -i 'active' && echo 'True' || echo 'False'"

            if ($verif -match "True") {
                Write-Host "Le pare-feu du client Ubuntu a bien été activé." -ForegroundColor Green
                Write-Log "Activation_PareFeu_Ubuntu"
                break
            } else {
                Write-Host "Une erreur est survenue lors de l'activation." -ForegroundColor Red
                Write-Log "Echec_Activation_PareFeu_Ubuntu"
                break
            }

        } else {
            Write-Host "Entrée invalide. Veuillez répondre par O ou N." -ForegroundColor Red
        }
    }
}

function activation_parefeu_windows {
    while ($true) {

        $reponse = Read-Host "Voulez-vous activer le pare-feu du client Windows ? (O/N)"

        # Condition de sortie
        if ($reponse -eq "N") {
            Write-Host "Opération annulée."
            Clear-Host
            break
        }

        if ($reponse -eq "O") {

            # Activation du pare-feu sur Windows via SSH
            ssh windows 'powershell -Command "New-NetFirewallRule -DisplayName ''Autoriser SSH'' -Direction Inbound -LocalPort 22 -Protocol TCP -Action Allow | Out-Null; Set-NetFirewallProfile -All -Enabled True | Out-Null"'

            # Vérification que le pare-feu a bien été activé
            $verif = ssh windows 'powershell -Command "Get-NetFirewallProfile | Where-Object { $_.Enabled -eq $true } | Measure-Object | Select-Object -ExpandProperty Count"'

            if ($verif -match "[1-9]") {
                Write-Host "Le pare-feu du client Windows a bien été activé." -ForegroundColor Green
                Write-Log "Activation_PareFeu_Windows"
                break
            } else {
                Write-Host "Une erreur est survenue lors de l'activation." -ForegroundColor Red
                Write-Log "Echec_Activation_PareFeu_Windows"
                break
            }

        } else {
            Write-Host "Entrée invalide. Veuillez répondre par O ou N." -ForegroundColor Red
        }
    }
}

############## Fonction démmarage de script à distance ##############

function execution_script_windows {
    while ($true) {

        $reponse = Read-Host "Voulez-vous lancer ce script à distance ? (O/N)"

        # Condition de sortie
        if ($reponse -eq "N") {
            Write-Host "Opération annulée."
            Clear-Host
            break
        }

        if ($reponse -eq "O") {
            
            # Envoi du script vers le client
            C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\script_distant.ps1 windows:/C:/Users/wilder/ 2>$null

            # Lancement du script
            ssh windows "powershell.exe -ExecutionPolicy Bypass -File C:/Users/wilder/script_distant.ps1"

            # Verification 

            if ($LASTEXITCODE -eq 0) {
                Write-Host "Script lancé sur le client Windows " -ForegroundColor Green
                Write-Log "Script_Execute_Windows"
                break

            } else {
                Write-Host "Une erreur est survenue lors de l'execution." -ForegroundColor Red
                Write-Log "Echec_Script_Execute_Windows"
                break
            }
    }
    }
}

function execution_script_ubuntu {
    while ($true) {

        $reponse = Read-Host "Voulez-vous lancer ce script à distance ? (O/N)"

        # Condition de sortie
        if ($reponse -eq "N") {
            Write-Host "Opération annulée."
            Clear-Host
            break
        }

        if ($reponse -eq "O") {
            
            # Envoi du script vers le client
            scp C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\script_distant.sh ubuntu:/home/wilder/ 2>$null

            # Lancement du script
            ssh -t ubuntu "sed -i 's/\r//' ~/script_distant.sh && chmod u+x ~/script_distant.sh && bash ~/script_distant.sh && rm ~/script_distant.sh"

            # Verification 

            if ($LASTEXITCODE -eq 0) {
                Write-Host "Script lancé sur le client Ubuntu " -ForegroundColor Green
                Write-Log "Script_Execute_Ubuntu"
                break

            } else {
                Write-Host "Une erreur est survenue lors de l'execution." -ForegroundColor Red
                Write-Log "Echec_Script_Execute_Ubuntu"
                break
            }
    }
    }
}

############## Info liste utilisateur ##############

function info_liste_utilisateur_ubuntu {
    
    
    # Variables jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLILIN01_${jour}${heure}.txt"

    # Récupération des utilisateurs via SSH
    $listeUsers = ssh ubuntu "awk -F: '`$3 >= 1000 {print `$1}' /etc/passwd"

    # Test du code de sortie du processus SSH
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Liste des utilisateurs locaux : $listeUsers"
        
        # Sauvegarde
        "Liste des utilisateurs locaux : $listeUsers" | Out-File -FilePath $destination -Encoding utf8
        
        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-log "Info_Liste_Utilisateur_Ubuntu"
    }
    else {
        Write-Host "Erreur lors de la récupération ou de la sauvegarde" -ForegroundColor Red
        Write-Log "Echec_Info_Liste_Utilisateur_Ubuntu"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}

function info_liste_utilisateur_windows {
   
    # Variables jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLIWIN01_${jour}${heure}.txt"

    # Récupération des utilisateurs via SSH
    $liste_users= ssh windows "powershell -Command `"(Get-LocalUser | Where-Object { `$_.Enabled -eq `$true }).Name`""

    # Test du code de sortie du processus SSH
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Liste des utilisateurs locaux : $liste_users"
        
        # Sauvegarde
        "Liste des utilisateurs locaux : $liste_users" | Out-File -FilePath $destination -Encoding utf8

        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-log "Info_Liste_Utilisateur_Windows"
        }
    else {
        Write-Host "Erreur lors de la récupération ou de la sauvegarde" -ForegroundColor Red
        Write-Log "Echec_Info_Liste_Utilisateur_Windows"
    }

     Start-Sleep -Seconds 5
    Clear-Host
}

############## Info Version de l'OS ##############

function info_version_OS_ubuntu {
    
    
    # Variables jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLILIN01_${jour}${heure}.txt"

    # Récupération de la version OS via SSH
    $version_os = ssh ubuntu "cat /etc/lsb-release"

    # Test du code de sortie du processus SSH
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Version OS : $version_os"
        
        # Sauvegarde
        "Version OS : $version_os" | Out-File -FilePath $destination -Encoding utf8
        
        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-log "Info_Version_OS_Ubuntu"
    }
    else {
        Write-Host "Erreur lors de la récupération ou de la sauvegarde" -ForegroundColor Red
        Write-Log "Echec_Info_Version_OS_Ubuntu"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}

function info_version_OS_windows {
    
    
    # Variables jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLIWIN01_${jour}${heure}.txt"

    # Récupération de la version OS via SSH
    $version_os = ssh windows 'powershell -Command "Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber | Format-List"'
    
    # Test du code de sortie du processus SSH
    if ($LASTEXITCODE -eq 0) {
        
        Write-Host "Version OS :"
        Write-Host "$version_os"
        
        # Sauvegarde
        "Version OS : `n$version_os" | Out-File -FilePath $destination -Encoding utf8
        
        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-log "Info_Version_OS_Windows"
    }
    else {
        Write-Host "Erreur lors de la récupération ou de la sauvegarde" -ForegroundColor Red
        Write-Log "Echec_Info_Version_OS_Windows"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}

############## Info Partition disques ##############
function info_partition_disque_ubuntu {
    
    # Variable jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour  = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLILIN01_${jour}${heure}.txt"

    # Recuperation des info partitions via SSH
    $infoPartitions = ssh ubuntu "LANG=C lsblk -o NAME,TYPE,FSTYPE,SIZE | grep -E 'disk|part'"

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Infos Partitions :`n$infoPartitions"

        "Infos Partitions :`n$infoPartitions" | Out-File -FilePath $destination -Encoding utf8

        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-Log "Info_Partition_Disque_Ubuntu"
    }
    else {
        Write-Host "Erreur lors de la récupération ou de la sauvegarde" -ForegroundColor Red
        Write-Log "Echec_Info_Partition_Disque_Ubuntu"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}

function info_partition_disque_windows {
    
    # Variable jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour  = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLIWIN01_${jour}${heure}.txt"

    # Recuperation des info partitions via SSH
    $infoPartitions = (ssh windows "powershell -Command `"Get-Partition | Select-Object DiskNumber, PartitionNumber, DriveLetter, Size, Type | Format-Table -AutoSize`"") -replace "`0", "" -join "`n"

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Infos Partitions :`n$infoPartitions"

        "Infos Partitions :`n$infoPartitions" | Out-File -FilePath $destination -Encoding utf8

        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-Log "Info_Partition_Disque_Windows"
    }
    else {
        Write-Host "Erreur lors de la récupération ou de la sauvegarde" -ForegroundColor Red
        Write-Log "Echec_Info_Partition_Disque_Windows"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}

############## Info Carte Graphique ##############

function info_carte_graphique_ubuntu {
    
    # Variable jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour  = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLILIN01_${jour}${heure}.txt"

    # Recuperation de l'info carte graphique via SSH
    $info_carte_graphique = ssh ubuntu "lspci | grep "VGA""
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Infos Carte Graphique :`n$info_carte_graphique"

        "Infos Carte Graphique :`n$info_carte_graphique" | Out-File -FilePath $destination -Encoding utf8

        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-Log "Info_Carte_Graphique_Ubuntu"
    }
    else {
        Write-Host "Erreur lors de la récupération ou de la sauvegarde" -ForegroundColor Red
        Write-Log "Echec_Info_Carte_Graphique_Ubuntu"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}

function info_carte_graphique_Windows {
    
    # Variable jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour  = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLIWIN01_${jour}${heure}.txt"

    # Recuperation de l'info carte graphique via SSH
    $info_carte_graphique = ssh windows 'powershell -Command "Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name"'
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Infos Carte Graphique :`n$info_carte_graphique"

        "Infos Carte Graphique :`n$info_carte_graphique" | Out-File -FilePath $destination -Encoding utf8

        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-Log "Info_Carte_Graphique_Windows"
    }
    else {
        Write-Host "Erreur lors de la récupération ou de la sauvegarde" -ForegroundColor Red
        Write-Log "Echec_Info_Carte_Graphique_Windows"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}

############## Info 5 derniers Login ##############
function info_derniers_logins_ubuntu {

    # Variables jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLILIN01_${jour}${heure}.txt"

    # Récupération des 5 derniers logins via SSH
    $derniers_logins = ssh ubuntu "LANG=C last -n 5" | Out-String

    if ($LASTEXITCODE -eq 0) {
        Write-Host "5 derniers logins : `n$derniers_logins"

        # Sauvegarde
        "5 derniers logins : `n$derniers_logins" | Out-File -FilePath $destination -Encoding utf8

        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-Log "Info_Derniers_Logins_Ubuntu"
    }
    else {
        Write-Host "Erreur lors de la récupération ou de la sauvegarde" -ForegroundColor Red
        Write-Log "Echec_Info_Derniers_Logins_Ubuntu"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}

function info_derniers_logins_windows {

    # Variable jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour  = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLIWIN01_${jour}${heure}.txt"

    # Recuperation des 5 derniers login via SSH
    $derniers_logins = ssh windows 'powershell -Command "Get-WinEvent -FilterHashtable @{LogName=''Security''; Id=4624} -MaxEvents 5 | Select-Object TimeCreated, @{N=''User'';E={$_.Properties[5].Value}} | Format-List"'

    if ($LASTEXITCODE -eq 0) {
        $derniers_logins = $derniers_logins | Out-String

        Write-Host "5 derniers logins :`n$derniers_logins"

        "5 derniers logins :`n$derniers_logins" | Out-File -FilePath $destination -Encoding utf8

        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-Log "Info_Derniers_Logins_Windows"
    }
    else {
        Write-Host "Erreur lors de la récupération ou de la sauvegarde" -ForegroundColor Red
        Write-Log "Echec_Info_Derniers_Logins_Windows"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}


############## Info IP ##############
function info_ip_ubuntu {

    # Variables jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLILIN01_${jour}${heure}.txt"

    # Récupération IP/masque/passerelle via SSH
    $ip_info = ssh ubuntu "ip a | grep 'inet ' && ip r | grep default"

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Adresse IP, masque, passerelle : `n$ip_info"

        # Sauvegarde
        "Adresse IP, masque, passerelle : `n$ip_info" | Out-File -FilePath $destination -Encoding utf8

        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-Log "Info_IP_Ubuntu"
    }
    else {
        Write-Host "Erreur lors de la récupération ou de la sauvegarde" -ForegroundColor Red
        Write-Log "Echec_Info_IP_Ubuntu"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}

function info_ip_windows {

    # Variable jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour  = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLIWIN01_${jour}${heure}.txt"

    # Recuperation des infos IP via SSH
    $ip_info = (ssh windows "powershell -Command `"Get-NetIPConfiguration | Select-Object InterfaceAlias, IPv4Address, IPv4DefaultGateway | Format-List`"") -replace "`0", "" -join "`n"

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Adresse IP, masque, passerelle :`n$ip_info"

        "Adresse IP, masque, passerelle :`n$ip_info" | Out-File -FilePath $destination -Encoding utf8

        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-Log "Info_IP_Windows"
    }
    else {
        Write-Host "Erreur lors de la récupération ou de la sauvegarde" -ForegroundColor Red
        Write-Log "Echec_Info_IP_Windows"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}

############## Infos CPU% ##############

function info_cpu_windows {

    # Variables jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour  = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLIWIN01_${jour}${heure}.txt"

    # Recuperation du CPU% via SSH
    $cpu = (ssh windows 'powershell -Command "(Get-CimInstance Win32_Processor).LoadPercentage | Out-String"')

    if ($LASTEXITCODE -eq 0) {
        Write-Host "CPU% :`n$cpu %"

        "CPU% :`n$cpu %" | Out-File -FilePath $destination -Encoding utf8

        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-Log "Info_CPU_Windows"
    }
    else {
        Write-Host "Erreur lors de la récupération ou de la sauvegarde" -ForegroundColor Red
        Write-Log "Echec_Info_CPU_Windows"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}

function info_cpu_ubuntu {

    # Variables jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour  = Get-Date -Format "yyyyMMdd"
    
    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLILIN01_${jour}${heure}.txt"

    # Récupération du CPU% via SSH
    $cpu = (ssh ubuntu 'grep "cpu " /proc/stat | awk "{usage=(\$2+\$4)*100/(\$2+\$4+\$5)} END {printf \"%.2f\", usage}"').Trim()

    if ($LASTEXITCODE -eq 0) {
        Write-Host "CPU% :`n$cpu %"

        "CPU% :`n$cpu %" | Out-File -FilePath $destination -Encoding utf8

        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-Log "Info_CPU_Ubuntu"
    }
    else {
        Write-Host "Erreur lors de la récupération ou de la sauvegarde" -ForegroundColor Red
        Write-Log "Echec_Info_CPU_Ubuntu"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}

############## Infos Nombre Disques ##############
function info_nombre_disques_ubuntu {

    # Variables jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLILIN01_${jour}${heure}.txt"

    # Récupération du nombre de disques via SSH
    $nb_disques = ssh ubuntu "lsblk -d | grep -v 'loop' | grep -c 'disk'"

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Nombre de disques : $nb_disques"

        # Sauvegarde
        "Nombre de disques : $nb_disques" | Out-File -FilePath $destination -Encoding utf8

        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-Log "Info_Nombre_Disques_Ubuntu"
    }
    else {
        Write-Host "Erreur lors de la récupération ou de la sauvegarde" -ForegroundColor Red
        Write-Log "Echec_Info_Nombre_Disques_Ubuntu"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}

function info_nombre_disques_windows {

    # Variables jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLIWIN01_${jour}${heure}.txt"

    # Récupération du nombre de disques via SSH
    $nb_disques = ssh windows 'powershell -Command "(Get-Volume | Where-Object DriveLetter).Count"'

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Nombre de disques : $nb_disques"

        # Sauvegarde
        "Nombre de disques : $nb_disques" | Out-File -FilePath $destination -Encoding utf8

        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-Log "Info_Nombre_Disques_Windows"
    }
    else {
        Write-Host "Erreur lors de la récupération ou de la sauvegarde" -ForegroundColor Red
        Write-Log "Echec_Info_Nombre_Disques_Windows"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}

############## Infos Uptime ##############

function info_uptime_ubuntu {

    # Variables jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLILIN01_${jour}${heure}.txt"

    # Récupération de l'Uptime via SSH
    $uptime = ssh ubuntu "uptime"

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Uptime : $uptime"

        # Sauvegarde
        "Uptime : $uptime" | Out-File -FilePath $destination -Encoding utf8

        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-Log "Info_Uptime_Ubuntu"
    }
    else {
        Write-Host "Erreur lors de la récupération ou de la sauvegarde" -ForegroundColor Red
        Write-Log "Echec_Uptime_Ubuntu"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}

function info_uptime_windows {

    # Variables jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLIWIN01_${jour}${heure}.txt"

    # Récupération de l'Uptime via SSH
    $uptime = ssh windows 'powershell -Command "$u = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime; \"$($u.Days)j $($u.Hours)h $($u.Minutes)m\""'

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Uptime : $uptime"

        # Sauvegarde
        "Uptime : $uptime" | Out-File -FilePath $destination -Encoding utf8

        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-Log "Info_Uptime_Windows"
    }
    else {
        Write-Host "Erreur lors de la récupération ou de la sauvegarde" -ForegroundColor Red
        Write-Log "Echec_Uptime_Windows"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}
############## Info Espace Disque Restant ##############
function info_espace_restant_windows {

    # Variables jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour  = Get-Date -Format "yyyyMMdd"

    # Variable destination
    $destination = "$env:USERPROFILE\Documents\TSSR-0226-P2-G1\script\info\info_CLIWIN01_${jour}${heure}.txt"

    # Récupération de l'espace restant
    $espaceRestant = ssh windows 'powershell -Command "Get-PSDrive -PSProvider FileSystem | Format-Table -AutoSize"'

    # Affichage
    Write-Host "Espace restant :"
    Write-Host ($espaceRestant -join "`n")

    # Sauvegarde dans le fichier info
    "Espace restant :`n$($espaceRestant -join "`n")" | Out-File -FilePath $destination -Encoding utf8

    # Test sauvegarde
    if ($?) {
        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
    }
    else {
        Write-Host "Erreur lors de la sauvegarde" -ForegroundColor Red
    }

    Start-Sleep -Seconds 5
    Clear-Host
}

function info_espace_restant_ubuntu {

    # Variables jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour  = Get-Date -Format "yyyyMMdd"

    # Variable destination
    $destination = "$env:USERPROFILE\Documents\TSSR-0226-P2-G1\script\info\info_CLILIN01_${jour}${heure}.txt"

    # Récupération de l'espace restant
    $espaceRestant = ssh ubuntu "df -h" | Out-String

    # Affichage
    Write-Host "Espace restant :"
    Write-Host $espaceRestant

    # Sauvegarde dans le fichier info
    "Espace restant :`n$espaceRestant" | Out-File -FilePath $destination -Encoding utf8

    # Test sauvegarde
    if ($?) {
        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
    }
    else {
        Write-Host "Erreur lors de la sauvegarde" -ForegroundColor Red
    }

    Start-Sleep -Seconds 5
    Clear-Host
}
############## Info 10 derniers evenement critiques ##############

function info_10_Derniers_Evenement_Critique_ubuntu {

    # Variables jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLILIN01_${jour}${heure}.txt"

    # Récupération des 10 derniers événements critiques (priorité 0 à 2)
    $critique = ssh ubuntu "journalctl -p 0..2 -n 10 --no-pager -q"

    if ($LASTEXITCODE -eq 0) {
        
        # Si la variable est vide (pas d'erreurs), on met un message
        if (-not $critique -or $critique.Trim() -eq "") {
            $critique = "Aucun événement critique détecté."
        }

        # Affichage Console
        Write-Host "10 derniers événements critiques :"
        Write-Host $critique

        # Sauvegarde
        "10 derniers événements critiques :`n$critique" | Out-File -FilePath $destination -Encoding utf8

        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-Log "Info_10_Derniers_Evenement_Critique_Ubuntu"
    }
    else {
        Write-Host "Erreur lors de la récupération des logs via SSH" -ForegroundColor Red
        Write-Log "Echec_Info_10_Derniers_Evenement_Critique_Ubuntu"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}


function info_10_Derniers_Evenement_Critique_windows {

    # Variable jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour = Get-Date -Format "yyyyMMdd"
    
    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLIWIN01_${jour}${heure}.txt"

    # Récupération avec protection des guillemets et gestion du vide
    $critique = ssh windows "powershell -Command `"Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2} -MaxEvents 10 -ErrorAction SilentlyContinue | Select-Object TimeCreated, Message | Format-List`""

    if ($LASTEXITCODE -eq 0) {
        
        # On transforme le résultat en une chaîne de texte propre
        $critiqueNettoye = ($critique | Out-String).Trim()

        if ([string]::IsNullOrWhiteSpace($critiqueNettoye)) {
            $critiqueNettoye = "Aucun événement critique ou erreur détecté."
        }

        # Affichage 
        Write-Host "10 derniers événements critiques :" 
        Write-Host $critiqueNettoye

        # Sauvegarde
        "10 derniers événements critiques :`n$critiqueNettoye" | Out-File -FilePath $destination -Encoding utf8

        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-Log "Info_10_Derniers_Evenement_Critique_Windows"
    }
    else {
        Write-Host "Erreur lors de la récupération des logs via SSH" -ForegroundColor Red
        Write-Log "Echec_Info_10_Derniers_Evenement_Critique_Windows"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}

############## Info Temperature CPU ##############

function info_temperature_CPU_Ubuntu {

    # Variables jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLILIN01_${jour}${heure}.txt"

    # Vérification du type de virtualisation
    $VIRT_CHECK = ssh ubuntu "systemd-detect-virt" 2>$null

    if ($VIRT_CHECK -and $VIRT_CHECK -ne "none") {
        $msg = "Type de détection : $VIRT_CHECK. La machine est une VM, il n'y a donc pas de sonde physique."
        Write-Host $msg
        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-Log "Info_Temperature_CPU_Ubuntu"
        
        Start-Sleep -Seconds 5
        Clear-Host
        
        # Sauvegarde
        $msg | Out-File -FilePath $destination -Encoding utf8
    }
    else {
        # On récupère la température brute (souvent en millidegrés)
        $TEMP_BRUT = ssh ubuntu "cat /sys/class/thermal/thermal_zone0/temp" 2>$null

        # Vérification si on a bien reçu une valeur numérique
        if ($null -ne $TEMP_BRUT -and $TEMP_BRUT -match "^\d+$") {
            # Calcul : on divise par 1000 pour avoir des Celsius
            $TEMP = [math]::Round(($TEMP_BRUT / 1000), 1)
            
            $msg = "Température du CPU : $TEMP °C"
            Write-Host $msg
            Start-Sleep -Seconds 5
            Clear-Host

            # Sauvegarde
            $msg | Out-File -FilePath $destination -Encoding utf8
            Write-Log "Info_Temperature_CPU_Ubuntu"
        }
        else {
            $msg = "Impossible de lire la sonde thermique."
            Write-Host $msg
            Start-Sleep -Seconds 5
            Clear-Host

            # Sauvegarde
            $msg | Out-File -FilePath $destination -Encoding utf8
            Write-Log "Echec_Info_Temperature_CPU_Ubuntu" -ForegroundColor Red

        }
    }
}

function info_temperature_CPU_Windows {

    # Variable jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLIWIN01_${jour}${heure}.txt"

    # 1. Vérification si c'est une VM
    $model = ssh windows "powershell -Command `"(Get-CimInstance Win32_ComputerSystem).Model`""
    $isVM = $model -match "Virtual|VMware|Hyper-V|KVM"

    if ($isVM) {
        $msg = "Type de machine : $model. C'est une VM, sonde physique non disponible."
        Write-Host $msg 
        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        $msg | Out-File -FilePath $destination -Encoding utf8
        Write-Log "Info_Temperature_CPU_Windows"
    }
    else {
        # Récupération de la température
        $TEMP = ssh windows "powershell -Command `"`$t = Get-CimInstance -Namespace root/wmi -ClassName MsAcpi_ThermalZoneTemperature -ErrorAction SilentlyContinue; if(`$t){ [math]::Round(((`$t[0].CurrentTemperature) / 10) - 273.15, 1) }`""

        # 3. Vérification si on a un nombre en retour
        if ($TEMP -match "^[0-9]+(,[0-9]+)?$") {
            $msg = "Température du CPU : $TEMP °C"
            Write-Host $msg 
            $msg | Out-File -FilePath $destination -Encoding utf8
            Write-Log "Info_Temperature_CPU_Windows"
        }
        else {
            $msg = "Impossible de lire la sonde thermique."
            Write-Host $msg 
            $msg | Out-File -FilePath $destination -Encoding utf8
            Write-Log "Echec_Info_Temperature_CPU_Windows" -ForegroundColor Red
        }
    }

    Start-Sleep -Seconds 5
    Clear-Host
}

############## Info Utilisateurs ##############

function info_utilisateur_ubuntu {

    # Variables jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLILIN01_${jour}${heure}.txt"

    # Question sur quel dossier ?
    $dossier = Read-Host "Sur quel dossier voulez-vous vérifier les droits de wilder ? (Ex: /home/wilder) (q pour quitter)"

    # Condition de sortie
    if ($dossier -eq "q") {
        Clear-Host
        return
    }

    # Récupération des droits avec gestion d'erreur
    $verification_droits = ssh ubuntu "ls -ld `"$dossier`" 2>/dev/null || echo 'ERREUR : Dossier introuvable ou acces refuse'"
    
    if ($LASTEXITCODE -eq 0) {
        
        # Affichage
        Write-Host "Droits sur le dossier $dossier" 
        Write-Host $verification_droits

        # Sauvegarde
        "Droits sur le dossier $dossier :`n$verification_droits" | Out-File -FilePath $destination -Encoding utf8
        
        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-Log "Info_droit_dossier_wilder"
    }
    else {
        Write-Host "Erreur lors de la sauvegarde" -ForegroundColor Red
        Write-Log "Echec_Info_droit_dossier_wilder"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}

function info_utilisateur_windows {

    # Variables jour/heure
    $heure = Get-Date -Format "HHmmss"
    $jour = Get-Date -Format "yyyyMMdd"

    # Chemin de destination
    $destination = "C:\Users\Wilder\Documents\TSSR-0226-P2-G1\script\info\info_CLIWIN01_${jour}${heure}.txt"

    # Question sur quel dossier ?
    $dossier = Read-Host "Sur quel dossier voulez-vous vérifier les droits de Wilder ? (Ex: C:\Users\Wilder\) (q pour quitter)"

    # Condition de sortie
    if ($dossier -eq "q") {
        Clear-Host
        return
    }

    # Récupération des droits avec gestion d'erreur
    $verification_droits = ssh windows "powershell -Command `"if (Test-Path '$dossier') { Get-Acl '$dossier' | Select-Object -ExpandProperty AccessToString } else { Write-Output 'ERREUR : Dossier introuvable' }`""
    
    if ($LASTEXITCODE -eq 0) {
        
        # Affichage
        Write-Host "Droits sur le dossier $dossier" 
        Write-Host $verification_droits

        # Sauvegarde
        "Droits sur le dossier $dossier :`n$verification_droits" | Out-File -FilePath $destination -Encoding utf8
        
        Write-Host "Sauvegarde effectuée dans : Info" -ForegroundColor Green
        Write-Log "Info_droit_dossier_Wilder"
    }
    else {
        Write-Host "Erreur lors de la sauvegarde" -ForegroundColor Red
        Write-Log "Echec_Info_droit_dossier_Wilder"
    }

    Start-Sleep -Seconds 5
    Clear-Host
}

############## Recherche des événements pour un utilisateur ##############

function recherche_log_utilisateur{

    $utilisateur = Read-Host "Entrez le nom de l'utilisateur à rechercher"

    Write-Host "--- Événements pour l'utilisateur : $utilisateur ---"

    # Recherche dans le fichier LOG
    $resultats = Select-String -Path $LOG_FILE -Pattern $utilisateur -CaseSensitive:$false

    if ($resultats) {
        $resultats.Line
        
        Write-Host "Fin des résultats" -ForegroundColor Green
        Write-Log "Recherche_Log_${utilisateur}"
    }
    else {
        Write-Host "Aucun événement trouvé pour l'utilisateur '$utilisateur'." -ForegroundColor Red
        Write-Log "Echec_Recherche_Log_${utilisateur}"
    }
    
    Start-Sleep -Seconds 5
}

############## Recherche des événements pour un ordinateur ##############

function recherche_log_ordinateur{

    $machine = Read-Host "Entrez le nom de l'ordinateur à rechercher (ex: Windows, Ubuntu, CLIWIN01...)"

    Write-Host "--- Événements pour l'ordinateur : $machine ---"

    # Recherche dans le fichier LOG
    $resultats = Select-String -Path $LOG_FILE -Pattern $machine -CaseSensitive:$false

    if ($resultats) {
        $resultats.Line
        
        Write-Host "Fin des résultats" -ForegroundColor Green
        Write-Log "Recherche_Log_${machine}"
    }
    else {
        Write-Host "Aucun événement trouvé pour l'ordinateur '$machine'." -ForegroundColor Red
        Write-Log "Echec_Recherche_Log_${machine}"
    }
    
    Start-Sleep -Seconds 5
}

# Ecriture dans le fichier LOG 

Clear-Host
Write-Log "Start Script"                             

while ($true) {

    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

@'

███╗   ███╗███████╗███╗   ██╗██╗   ██╗
████╗ ████║██╔════╝████╗  ██║██║   ██║
██╔████╔██║█████╗  ██╔██╗ ██║██║   ██║
██║╚██╔╝██║██╔══╝  ██║╚██╗██║██║   ██║
██║ ╚═╝ ██║███████╗██║ ╚████║╚██████╔╝
╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ 
                                      
                                               
'@      
        
    Write-Host " Choississez une cible "
    Write-Host "1- Ordinateurs"
    Write-Host "2- Utilisateurs"
    Write-Host "3- Infos script"
    Write-Host "4- Quitter"
    $choix = Read-Host "Choississez une option "
    Clear-Host

    switch ($choix) {
        "1" {
            # Sous-menu Ordinateurs
            Write-Log "Navigation_Menu_Windows_CLIWIN01"
            $continuerSousMenu = $true
            while ($continuerSousMenu) {
                Write-Host "Vous avez choisi : Ordinateurs"
                Write-Host "1- Client Windows"
                Write-Host "2- Client Ubuntu"
                Write-Host "3- Retour"

                $souschoix = Read-Host "Choix "
                Clear-Host
                
                switch ($souschoix) {
                    "1" { 
                        $continuerWin01 = $true
                        while ($continuerWin01) {
                            Write-Host " Ordinateur Windows : CLIWIN01 "
                            Write-Host " Quel action faire sur l'ordinateur CLIWIN01 ?"
                            Write-Host " 1- Verrouiller l'ordinateur"
                            Write-Host " 2- Redémarrer l'ordinateur"
                            Write-Host " 3- Création de répertoire"
                            Write-Host " 4- Suppression de répertoire"
                            Write-Host " 5- Prise en main à distance en CLI"
                            Write-Host " 6- Activation du pare-feu"
                            Write-Host " 7- Exécution du script sur la machine distante"
                            Write-Host " 8- Infos"
                            Write-Host " 9- Retour"

                            $action1 = Read-Host "Choix "
                            Clear-Host

                            switch ($action1) {
                                "1" { 
                                    Write-Log "Navigation_Action_Verrouillage_Windows"
                                    Write-Host "Vérrouillez l'ordinateur" 
                                    verrouillage_windows
                                    }
                                "2" { 
                                    Write-Log "Navigation_Action_Redemarrage_Windows"
                                    Write-Host "Redémarrer l'ordinateur" 
                                    redemarrage_windows
                                    }
                                "3" { 
                                    Write-Log "Navigation_Action_Creation_Repertoire_Windows"
                                    Write-Host "Création de répertoire" 
                                    creation_repertoire_windows
                                    }
                                "4" { 
                                    Write-Log "Navigation_Action_Suppression_Repertoire_Windows"
                                    Write-Host "Suppression de répertoire" 
                                    suppression_repertoire_windows
                                    }
                                "5" {
                                    Write-Log "Acces_SSH_Direct_Windows"
                                    Write-Host "Prise en main à distance en CLI" 
                                    ssh windows
                                    }
                                "6" {
                                    Write-Log "Navigation_Action_Activation_PareFeu_Windows"
                                    Write-Host "Activation du pare-feu" 
                                    activation_parefeu_windows
                                    }
                                "7" { 
                                    Write-Log "Navigation_Action_Execution_Script_Distant_Windows"
                                    Write-Host "Exécution du script sur la machine distante" 
                                    execution_script_windows
                                    }
                                "8" {
                                    Write-Log "Navigation_Menu_Infos_Windows"
                                    $continuerInfos = $true
                                    while ($continuerInfos) {
                                        Write-Host "==== MENU INFOS : CLIWIN01 ====" 
                                        Write-Host "1- Liste des utilisateurs locaux"
                                        Write-Host "2- 5 derniers logins"
                                        Write-Host "3- Adresse IP, masque, passerelle"
                                        Write-Host "4- Nombre de disques"
                                        Write-Host "5- Partitions (Nom, FS, Taille)"
                                        Write-Host "6- Espace disque restant"
                                        Write-Host "7- Version de l'OS"
                                        Write-Host "8- Carte graphique"
                                        Write-Host "9- CPU %"
                                        Write-Host "10- Uptime"
                                        Write-Host "11- 10 derniers événements critiques"
                                        Write-Host "12- Température CPU"
                                        Write-Host "13- Retour"
                                        $infochoix = Read-Host "Choix "
                                        Clear-Host
                                        switch ($infochoix) {
                                            "1" { 
                                                Write-Log "Info_Consultation_Users_Windows"
                                                Write-Host "Liste des utilisateurs locaux" 
                                                info_liste_utilisateur_windows
                                                }
                                            "2" { 
                                                Write-Log "Info_Consultation_5_Derniers_Logins_Windows"
                                                Write-Host "5 derniers logins" 
                                                info_derniers_logins_windows
                                                }
                                            "3" { 
                                                Write-Log "Info_Consultation_IP_Windows"
                                                Write-Host "Adresse IP, masque, passerelle" 
                                                info_ip_windows
                                                }
                                            "4" {
                                                Write-Log "Info_Consultation_Nombre_Disques_Windows"
                                                Write-Host "Nombre de disques" 
                                                info_nombre_disques_windows
                                                }
                                            "5" { 
                                                Write-Log "Info_Consultation_Partitions_Windows"
                                                Write-Host "Partitions (Nom, FS, Taille)" 
                                                info_partition_disque_windows
                                                }
                                            "6" { 
                                                Write-Log "Info_Consultation_Espace_Disque_Restant_Windows"
                                                Write-Host "Espace disque restant" 
                                                info_espace_restant_windows
                                                }
                                            "7" { 
                                                Write-Log "Info_Consultation_Version_OS_Windows"
                                                Write-Host "Version de l'OS" 
                                                info_version_OS_windows
                                                }
                                            "8" { 
                                                Write-Log "Info_Consultation_Carte_Graphique_Windows"
                                                Write-Host "Carte Graphique" 
                                                info_carte_graphique_Windows
                                                }
                                            "9" { 
                                                Write-Log "Info_Consultation_CPU%_Windows"
                                                Write-Host "CPU%" 
                                                info_cpu_windows
                                                }
                                            "10" { 
                                                 Write-Log "Info_Consultation_Uptime_Windows"
                                                 Write-Host "Uptime" 
                                                 info_uptime_windows
                                                 }
                                            "11" { 
                                                 Write-Log "Info_Consultation_10_Dernier_Evenement_Critique_Windows"
                                                 Write-Host "10 derniers événements critiques"
                                                 info_10_Derniers_Evenement_Critique_windows
                                                 }
                                            "12" { 
                                                 Write-Log "Info_Consultation_Temperature_CPU_Windows"
                                                 Write-Host "Température CPU" 
                                                 info_temperature_CPU_Windows
                                                 }
                                            "13" { $continuerInfos = $false }
                                            Default { Write-Host "Option invalide." }
                                        }
                                    }
                                }
                                "9" { $continuerWin01 = $false }
                                Default { Write-Host "Option invalide" }
                            }
                        }
                    }
                    "2" { 
                        Write-Log "Navigation_Menu_Ubuntu_CLILIN01"
                        $continuerLin01 = $true
                        while ($continuerLin01) {
                            Write-Host " Ordinateur Ubuntu : CLILIN01 " 
                            Write-Host " Quel action faire sur l'ordinateur CLILIN01 ?"
                            Write-Host " 1- Verrouiller l'ordinateur"
                            Write-Host " 2- Redémarrer l'ordinateur"
                            Write-Host " 3- Création de répertoire"
                            Write-Host " 4- Suppression de répertoire"
                            Write-Host " 5- Prise en main à distance en CLI"
                            Write-Host " 6- Activation du pare-feu"
                            Write-Host " 7- Exécution du script sur la machine distante"
                            Write-Host " 8- Infos"
                            Write-Host " 9- Retour"
                            $action1 = Read-Host "Choix "
                            Clear-Host
                            switch ($action1) {
                                "1" { 
                                    Write-Log "Navigation_Action_Verrouillage_Ubuntu"
                                    Write-Host "Vérrouillez l'ordinateur" 
                                    verrouillage_ubuntu
                                    }
                                "2" { 
                                    Write-Log "Navigation_Action_Redemarrage_Ubuntu"
                                    Write-Host "Redémarrer l'ordinateur" 
                                    redemarrage_ubuntu
                                    }
                                "3" { 
                                    Write-Log "Navigation_Action_Creation_Repertoire_Ubuntu"
                                    Write-Host "Création de répertoire" 
                                    creation_repertoire_ubuntu
                                    }
                                "4" { 
                                    Write-Log "Navigation_Action_Suppression_Repertoire_Ubuntu"
                                    Write-Host "Suppression de répertoire" 
                                    suppression_repertoire_ubuntu
                                    }
                                "5" { 
                                    Write-Log "Acces_SSH_Direct_Ubuntu"
                                    Write-Host "Prise en main à distance en CLI" 
                                    ssh ubuntu
                                    }
                                "6" {
                                    Write-Log "Navigation_Action_Activation_PareFeu_Ubuntu"
                                    Write-Host "Activation du pare-feu" 
                                    activation_parefeu_ubuntu
                                    }
                                "7" { 
                                    Write-Log "Navigation_Action_Execution_Script_Distant_Ubuntu"
                                    Write-Host "Exécution du script sur la machine distante" 
                                    execution_script_ubuntu
                                    }
                                "8" {
                                    Write-Log "Navigation_Menu_Infos_Ubuntu"
                                    $continuerInfos = $true
                                    while ($continuerInfos) {
                                        Write-Host "==== MENU INFOS : CLILIN01 ====" 
                                        Write-Host "1- Liste des utilisateurs locaux"
                                        Write-Host "2- 5 derniers logins"
                                        Write-Host "3- Adresse IP, masque, passerelle"
                                        Write-Host "4- Nombre de disques"
                                        Write-Host "5- Partitions (Nom, FS, Taille)"
                                        Write-Host "6- Espace disque restant"
                                        Write-Host "7- Version de l'OS"
                                        Write-Host "8- Carte graphique"
                                        Write-Host "9- CPU %"
                                        Write-Host "10- Uptime"
                                        Write-Host "11- 10 derniers événements critiques"
                                        Write-Host "12- Température CPU"
                                        Write-Host "13- Retour"
                                        $infochoix = Read-Host "Choix"
                                        Clear-Host
                                        switch ($infochoix) {
                                            "1" { 
                                                Write-Log "Info_Consultation_Users_Ubuntu"
                                                Write-Host "Liste des utilisateurs locaux" 
                                                info_liste_utilisateur_ubuntu
                                                }
                                            "2" { 
                                                Write-Log "Info_Consultation_5_Derniers_Logins_Ubuntu"
                                                Write-Host "5 derniers logins" 
                                                info_derniers_logins_ubuntu
                                                }
                                            "3" { 
                                                Write-Log "Info_Consultation_IP_Ubuntu"
                                                Write-Host "Adresse IP, masque, passerelle" 
                                                info_ip_ubuntu
                                                }
                                            "4" { 
                                                Write-Log "Info_Consultation_Nombre_Disques_Ubuntu"
                                                Write-Host "Nombre de disques" 
                                                info_nombre_disques_ubuntu
                                                }
                                            "5" { 
                                                Write-Log "Info_Consultation_Partition_Disque_Ubuntu"
                                                Write-Host "Partitions (Nom, FS, Taille)" 
                                                info_partition_disque_ubuntu
                                                }
                                            "6" { 
                                                Write-Log "Info_Consultation_Espace_Disque_Restant_Ubuntu"
                                                Write-Host "Espace disque restant" 
                                                info_espace_restant_ubuntu
                                                }
                                            "7" { 
                                                Write-Log "Info_Consultation_Version_OS_Ubuntu"
                                                Write-Host "Version de l'OS" 
                                                info_version_OS_ubuntu
                                                }
                                            "8" {
                                                Write-Log "Info_Consultation_Carte_Graphique_Ubuntu"
                                                Write-Host "Carte Graphique" 
                                                info_carte_graphique_ubuntu
                                                }
                                            "9" { 
                                                Write-Log "Info_Consultation_CPU%_Ubuntu"
                                                Write-Host "CPU%" 
                                                info_cpu_ubuntu
                                                }
                                            "10" { 
                                                 Write-Log "Info_Consultation_Uptime_Ubuntu"
                                                 Write-Host "Uptime" 
                                                 info_uptime_ubuntu
                                                 }
                                            "11" { 
                                                 Write-Log "Info_Consultation_10_Dernier_Evenement_Critique_Ubuntu"
                                                 Write-Host "10 derniers événements critiques"
                                                 info_10_Derniers_Evenement_Critique_ubuntu
                                                 }
                                            "12" { 
                                                 Write-Log "Info_Consultation_Temperature_CPU_Ubuntu"
                                                 Write-Host "Température CPU" 
                                                 info_temperature_CPU_Ubuntu
                                                 }
                                            "13" { $continuerInfos = $false }
                                            Default { Write-Host "Option invalide." }
                                        }
                                    }
                                }
                                "9" { $continuerLin01 = $false }
                                Default { Write-Host "Option invalide" }
                            }
                        }
                    }
                    "3" { $continuerSousMenu = $false }
                    Default { Write-Host "Option invalide" }
                }
            }
        }
        
        "2" {
            # Sous-menu Utilisateurs
            $continuerSousMenuUser = $true
            while ($continuerSousMenuUser) {
                Write-Host "Vous avez choisi : Utilisateurs"
                Write-Host "1- Utilisateur Windows"
                Write-Host "2- Utilisateur Ubuntu"
                Write-Host "3- Retour"
                $souschoix = Read-Host "Choix "
                Clear-Host
                switch ($souschoix) {
                    "1" {
                        $continuerWilder = $true
                        while ($continuerWilder) {
                            Write-Log "Navigation_Menu_Gestion_Users_Windows"
                            Write-Host "Utilisateur Windows : Wilder"
                            Write-Host "Quel action faire sur l'utilisateur Wilder ?"
                            Write-Host "1- Création de compte utilisateur local"
                            Write-Host "2- Changement de mot de passe"
                            Write-Host "3- Suppression de compte utilisateur local"
                            Write-Host "4- Ajout à un groupe d'administration"
                            Write-Host "5- Ajout à un groupe"
                            Write-Host "6- Infos"
                            Write-Host "7- Retour"
                            $action1 = Read-Host "Choix "
                            Clear-Host
                            switch ($action1) {
                                "1" { 
                                    Write-Log "Navigation_Action_Creation_User_Windows"
                                    Write-Host "Création de compte utilisateur local" 
                                    creation_utilisateur_windows
                                    }
                                "2" { 
                                    Write-Log "Navigation_Changement_MDP_User_Windows"
                                    Write-Host "Changement de mot de passe" 
                                    changement_mdp_windows
                                    }
                                "3" { 
                                    Write-Log "Navigation_Action_Suppression_User_Windows"
                                    Write-Host "Suppression de compte utilisateur local" 
                                    supprimer_utilisateur_windows
                                    }
                                "4" {
                                    Write-Log "Navigation_Action_Ajout_Groupe_Admin_Windows"
                                    Write-Host "Ajout à un groupe d'administration" 
                                    ajout_grp_admin_win
                                    }
                                "5" { 
                                    Write-Log "Navigation_Action_Ajout_Groupe_Windows"
                                    Write-Host "Ajout à un groupe" 
                                    ajout_grp_windows
                                    }
                                "6" { 
                                    Write-Log "Navigation_Consultation_Droits_User_Windows"
                                    Write-Host "Infos : Droits et permission de l'utilisateur sur un dossier" 
                                    info_utilisateur_windows
                                    }
                                "7" { $continuerWilder = $false }
                                Default { Write-Host "Option invalide" }
                            }
                        }
                    }
                    "2" {
                        $continuerwilderU = $true
                        while ($continuerwilderU) {
                            Write-Log "Navigation_Menu_Gestion_Users_Ubuntu"
                            Write-Host "Utilisateur Ubuntu : wilder"
                            Write-Host "Quel action faire sur l'utilisateur wilder ?"
                            Write-Host "1- Création de compte utilisateur local"
                            Write-Host "2- Changement de mot de passe"
                            Write-Host "3- Suppression de compte utilisateur local"
                            Write-Host "4- Ajout à un groupe d'administration"
                            Write-Host "5- Ajout à un groupe"
                            Write-Host "6- Infos"
                            Write-Host "7- Retour"
                            $action1 = Read-Host "Choix "
                            Clear-Host
                            switch ($action1) {
                                "1" { 
                                    Write-Log "Navigation_Action_Creation_User_Ubuntu"
                                    Write-Host "Création de compte utilisateur local" 
                                    creation_utilisateur_ubuntu
                                    }
                                "2" { 
                                    Write-Log "Navigation_Action_Changement_MDP_User_Ubuntu"
                                    Write-Host "Changement de mot de passe" 
                                    changement_mdp_ubuntu
                                    }
                                "3" { 
                                    Write-Log "Navigation_Action_Suppression_User_Ubuntu"
                                    Write-Host "Suppression de compte utilisateur local" 
                                    supprimer_utilisateur_ubuntu
                                    }
                                "4" { 
                                    Write-Log "Navigation_Action_Ajout_Groupe_Admin_Ubuntu"
                                    Write-Host "Ajout à un groupe d'administration" 
                                    ajout_grp_admin_ubuntu
                                    }
                                "5" { 
                                    Write-Log "Navigation_Action_Ajout_Groupe_Ubuntu"
                                    Write-Host "Ajout à un groupe" 
                                    ajout_grp_ubuntu
                                    }
                                "6" { 
                                    Write-Log "Navigation_Consultation_Droits_User_Ubuntu"
                                    Write-Host "Infos : Droits et permission de l'utilisateur sur un dossier" 
                                    info_utilisateur_ubuntu
                                    }
                                "7" { $continuerwilderU = $false }
                                Default { Write-Host "Option invalide" }
                            }
                        }
                    }
                    "3" { $continuerSousMenuUser = $false }
                    Default { Write-Host "Option invalide" }
                }
            }
        }
        
        "3" {
            # Sous-menu Infos
            $continuerInfosScript = $true
            while ($continuerInfosScript) {
                Write-Log "Navigation_Menu_Consultation_Logs"
                Write-Host "Infos script"
                Write-Host "Quelles infos voulez-vous voir ?"
                Write-Host "1- Recherche des événements pour un utilisateur"
                Write-Host "2- Recherche des événements pour un ordinateur"
                Write-Host "3- Retour"
                $actionI = Read-Host "Choix "
                Clear-Host
                switch ($actionI) {
                    "1" { 
                        Write-Log "Navigation_Menu_Consultation_Logs_Utilisateur"
                        Write-Host "Recherche des événements pour un utilisateur" 
                        recherche_log_utilisateur
                        }
                    "2" { 
                        Write-Log "Navigation_Menu_Consultation_Logs_Ordinateur"
                        Write-Host "Recherche des événements pour un ordinateur" 
                        recherche_log_ordinateur
                        }
                    "3" { $continuerInfosScript = $false }
                    Default { Write-Host "Option invalide" }
                }
            }
        }
        
        "4" { 
            Write-Log "EndScript"
            exit 
            }

        Default { Write-Host "Option invalide" }
    }
}
