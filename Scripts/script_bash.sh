#!/bin/bash

# Test pour voir si le script est lancé avec sudo

if [ -z "$SUDO_UID" ] 
then
    echo "Le script n'est pas éxécuté via sudo"
exit 1
fi

#################################################
#                                               #
#                  FONCTIONS                    #
#                                               #
#################################################

############## Fonction : Création des répertoires ##############

creation_repertoire_ubuntu() {

    while true
    do
            read -p "Nom du répertoire à créer (q pour quitter) : " nom_repertoire

            [ "$nom_repertoire" = "q" ] && clear && break
            ssh ubuntu "
            # Vérification que le répertoire n'existe pas déjà
            if [ -d "$nom_repertoire" ]
            then
                echo "Erreur : le répertoire '$nom_repertoire' existe déjà."
            else
                mkdir "$nom_repertoire"
                echo "Répertoire '$nom_repertoire' créé avec succès."
            fi
            "    
    done
}

creation_repertoire_windows() {

    while true
    do
        read -p "Nom du répertoire à créer (q pour quitter) : " nom_repertoire

        [ "$nom_repertoire" = "q" ] && clear && break

        # On demande à windows via SSH si le dossier existe
        ssh windows "powershell -Command \"(Test-Path -Path '$nom_repertoire')\"" | grep -q "True"

        if [ $? -eq 0 ]
        then
            echo "Erreur : le répertoire '$nom_repertoire' existe déjà."
        else
            # On crée le dossier sur Windows via SSH
        ssh windows "powershell -Command \"New-Item -ItemType Directory -Path '$nom_repertoire' | Out-Null\""
            echo "Répertoire '$nom_repertoire' créé avec succès."
        fi
    done
}

############## Fonction : Suppression des répertoires ##############
  
suppression_repertoire_ubuntu() {

    while true
    do
  
            read -p "Nom du répertoire à supprimer (q pour quitter) : " nom_repertoire
              
            [ "$nom_repertoire" = "q" ] && clear && break
            ssh ubuntu "
            if [ -d \"$nom_repertoire\" ]
            then
                rm -r \"$nom_repertoire\"
                echo \"Répertoire '$nom_repertoire' supprimé avec succès.\"
            else
                echo \"Erreur : le répertoire '$nom_repertoire' n'existe pas.\"
            fi
            "
    done
}

suppression_repertoire_windows() {

    while true
    do
        read -p "Nom du répertoire à supprimer (q pour quitter) : " nom_repertoire

        [ "$nom_repertoire" = "q" ] && clear && break

        # On demande à Windows via SSH si le dossier existe
        ssh windows "powershell -Command \"(Test-Path -Path '$nom_repertoire')\"" | grep -q "True"

        if [ $? -eq 0 ]
        then
            # Le dossier existe → on le supprime
            ssh windows "powershell -Command \"Remove-Item -Path '$nom_repertoire' -Recurse -Force\""
            echo "Répertoire '$nom_repertoire' supprimé avec succès."
        else
            echo "Erreur : le répertoire '$nom_repertoire' n'existe pas."
        fi
    done
}

############## Fonction : Vérouillage ##############
verrouillage_ubuntu() {
    while true
    do

         read -p "Voulez vous vraiment verrouiller le client Linux ? (oui/non/quitter) : " reponse
         if [ "$reponse" = "oui" ]
          then
            ssh ubuntu "loginctl lock-session \$(loginctl list-sessions | grep 'wilder' | awk '{print \$1}')"
            if [ $? -eq 0 ]
              then
                echo "Le client linux est maintenant verrouillé" 
                clear
                break
              else
                echo "Une erreur est survenu"
                break
            fi
        elif [ "$reponse" = "quitter" ] || [ "$reponse" = "non" ]
        then
                echo "Opération annulée"
                clear
                break
        fi
    done     
} 


verrouillage_windows() {
    while true
    do

         read -p "Voulez-vous vraiment verrouiller le client Windows ? (oui/non/quitter) : " reponse
         if [ "$reponse" = "oui" ]
          then
            ssh windows "powershell -Command \"\$sessionID = (quser | Select-String 'Active' | ForEach-Object { \$_ -split '\s+' | Select-Object -Index 2 }); tsdiscon \$sessionID\""
            
            if [ $? -eq 0 ]
              then
                echo "Le client Windows est maintenant verrouillé" 
                break
              else
                echo "Une erreur est survenu"
                break
            fi
        elif [ "$reponse" = "quitter" ] || [ "$reponse" = "non" ]
        then
                echo "Opération annulée"
                clear
                break
        fi
    done     
} 


############## Fonction : Redémarrage ##############

redemarage_ubuntu()
{
   # Lancement de la boucle
   while true
   do 

# Demande de validation ou non du choix
     read -p "Voulez vous vraiment redémarrer votre client Ubuntu ? (oui/non/quitter): " reponse

     # ---reponse positive---
     if [ "$reponse" = "oui" ]
      then
       ssh ubuntu "sudo reboot"

       #verification que le redemarage a bien été effectuer
       if [ $? = 0 ]
         then
          echo " Redémarrage en cours ..."
          break
         else 
          echo "Une erreur est survenue"
          break
       fi

     # ---reponse négatif---
     elif [ "$reponse" = "non" ] 
      then
       echo "Opération annulée"
       clear
       break
     elif [ "$reponse" = "quitter" ]
      then
       echo "Operation annulée"
       clear
       break
     fi
  done
}

redemarage_windows()
{

   while true
   do 

# Demande de validation ou non du choix
     read -p "Voulez vous vraiment redémarrer votre client Windows ? (oui/non/quitter): " reponse

     # ---reponse positive---
     if [ "$reponse" = "oui" ]
      then
       ssh windows "shutdown /r /f /t 0"

       #verification que le redemarage a bien été effectuer
       if [ $? = 0 ]
         then
          echo " Redémarrage en cours ..."
          break
         else 
          echo "Une erreur est survenue"
          break
       fi

     # ---reponse négatif---
     elif [ "$reponse" = "non" ] 
      then
       echo "Opération annulée"
       clear
       break
     elif [ "$reponse" = "quitter" ]
      then
       echo "Operation annulée"
       clear
       break
     fi
  done
}

############## Fonction : Création d'utilisateurs ##############

creation_utilisateur_ubuntu()

{

while true
do

# Demander le nom d'utilisateur à créer
       
read -p "Quel utilisateur souhaitez-vous créer ? (q pour quitter) : " Nom_Utilisateur

# Condition de sortie

if [[ "$Nom_Utilisateur" == "q" ]] ; then
    echo "Sortie de la création d'utilisateurs"
    clear
    break
fi

# Vérifier si l'utilisateur existe déjà
  
if ssh ubuntu "id $Nom_Utilisateur" &>/dev/null 
then
        echo "L'utilisateur $Nom_Utilisateur existe déjà " >&2
else
# Créer l'utilisateur,
ssh ubuntu "sudo useradd -m $Nom_Utilisateur"

# Vérifier si la création de l'utilisateur a réussi,
        if [ $? -eq 0 ]
        then
                echo "Utilisateur '$Nom_Utilisateur' a été créé avec succès."

        else
                echo "Erreur lors de la création de l'utilisateur '$Nom_Utilisateur'"
        fi  
fi
done

}

creation_utilisateur_windows()

{

while true
do

# Demander le nom d'utilisateur à créer
       
read -p "Quel utilisateur souhaitez-vous créer ? (q pour quitter) : " Nom_Utilisateur

# Condition de sortie

if [[ "$Nom_Utilisateur" == "q" ]] ; then
    echo "Sortie de la création d'utilisateurs"
    clear
    break
fi

# Vérifier si l'utilisateur existe déjà
  
if ssh windows "net user \"$Nom_Utilisateur\"" &>/dev/null 
then
        echo "L'utilisateur $Nom_Utilisateur existe déjà " >&2
else
# Créer l'utilisateur,
ssh windows "net user \"$Nom_Utilisateur\" \"\" /add"

# Vérifier si la création de l'utilisateur a réussi,
        if [ $? -eq 0 ]
        then
                echo "Utilisateur '$Nom_Utilisateur' a été créé avec succès."

        else
                echo "Erreur lors de la création de l'utilisateur '$Nom_Utilisateur'"
        fi  
fi
done

}

############## Fonction Changement de mot de passe ##############

changement_mdp_ubuntu () {
   
    while true
    do

read -p "De quel compte voulez-vous changer le mot de passe ? (q pour quitter) : " nom_user

        # Condition de sortie
        if [[ "$nom_user" == "q" ]] ; then
            echo "Sortie du changement de mot de passe"
            clear
            break
        fi

        # Vérifier si l'utilisateur existe
        if ssh ubuntu "id $nom_user" &>/dev/null
        then
            echo "L'utilisateur '$nom_user' existe. Préparation du changement..."
            
            # Changement de mot de passe 
            ssh -t ubuntu "sudo passwd $nom_user"

            # Vérifier si la commande passwd a réussi
            if [ $? -eq 0 ]
            then
                echo "Succès : Le mot de passe de '$nom_user' a été changé."
            else
                echo "Erreur lors du changement de mot de passe."
            fi
        else
            echo "Erreur : L'utilisateur '$nom_user' n'existe pas sur la machine distante." 
        fi
    done
}

changement_mdp_windows () {
    
    while true; 
    do
        
read -p "De quel compte voulez-vous changer le mot de passe ? (q pour quitter) : " nom_user
        
        # Condition de sortie

        if [[ "$nom_user" == "q" ]]; then
            echo "Sortie du changement de mot de passe"
            clear
            break
        fi
        
            # Verification que le compte existe 

            if ssh windows "net user $nom_user" > /dev/null 2>&1; 
            then
                echo "Changement de mot de passe pour $nom_user sur Windows..."

                # Changement du mot de passe

                ssh -t windows "net user $nom_user *"
        
                # Vérification que la commande a fonctionné

                if [ $? -eq 0 ]; 
                then
                    echo "Succès : Le mot de passe de '$nom_user' a été changé."
                else
                    echo "Erreur : Le changement de mot de passe à échoué"
                fi
            else
            echo "Erreur : L'utilisateur n'existe pas"
            fi
    done
}

############## Fonction Activation du Pare-Feu ##############

activation_parefeu_ubuntu ()
{

while true
do


        read -p "Voulez-vous activer le pare-feu ? (O/N): " reponse
        
        # Réponse positive

        if [ $reponse = "O" ]
        then
            ssh ubuntu " sudo ufw allow ssh && sudo ufw --force enable "

            # Vérification que le pare-feu a été activé 

            if [ $? = 0 ]
            then
                echo "Le pare-feu à bien été activé"
                break
            else
                echo "Une erreur est survenue"
                break
            fi        

        # Réponse négative

        elif [ $reponse = "N" ]
        then
            echo "Opération annulée"
            clear
            break
        else 
            echo "Entrée invalide. Veuillez répondre par O ou N"
        fi
done
}

activation_parefeu_windows ()
{

while true
do


        read -p "Voulez-vous activer le pare-feu ? (O/N): " reponse
        
        # Réponse positive

        if [ $reponse = "O" ]
        then
            ssh windows 'powershell -Command "New-NetFirewallRule -DisplayName \"Autoriser SSH\" -Direction Inbound -LocalPort 20 -Protocol TCP -Action Allow | Out-Null; Set-NetFirewallProfile -All -Enabled True | Out-Null"' > /dev/null 2>&1

            # Vérification que le pare-feu a été activé 

            if [ $? -eq 0 ]
            then
                echo "Le pare-feu à bien été activé"
                break
            else
                echo "Une erreur est survenue"
                break
            fi        

        # Réponse négative

        elif [ $reponse = N ]
        then
            echo "Opération annulée"
            clear
            break
        fi
done
}

############## Fonction suppression d'un utilisateur local ##############

supprimer_utilisateur_ubuntu() {

while true
do

    # ―――――― NOM USER ―――――――
    read -p "Quel utilisateur voulez-vous supprimer ? (q pour quitter) : " nom_utilisateur

    # Condition de sortie

        if [[ "$nom_utilisateur" == "q" ]]; then
            echo "Sortie de suppression d'utilisateur"
            clear
            break
        fi

    # ――――――― CHECK SI EXISTE DEJA ―――――
    if ssh ubuntu "id "$nom_utilisateur"" > /dev/null 2>&1
    then
        echo "Suppression de $nom_utilisateur en cours.."
        # ――――――― SUPPRESSION USER ―――――――
        ssh ubuntu "sudo userdel -r "$nom_utilisateur" > /dev/null 2>&1 || true"

        # ――――――― VERIF SI CA MARCHE BIEN ――――――
        if ! ssh ubuntu "id $nom_utilisateur" > /dev/null 2>&1
        then
            echo "L'utilisateur $nom_utilisateur a été supprimé avec succès."
        else
            echo "Erreur : la suppression de $nom_utilisateur a échoué."
        fi

    else
        # ――――――― USER NEXISTE PAS ―――――――
        echo "Erreur : l'utilisateur $nom_utilisateur n'existe pas."
        break
    fi
done
}

supprimer_utilisateur_windows() {

while true
do

    # ―――――― NOM USER ―――――――
    read -p "Quel utilisateur voulez-vous supprimer ? (q pour quitter) : " nom_utilisateur

    # Condition de sortie

        if [[ "$nom_utilisateur" == "q" ]]; then
            echo "Sortie de suppression d'utilisateur"
            clear
            break
        fi

    # ――――――― CHECK SI EXISTE DEJA ―――――
    if ssh windows "net user \"$nom_utilisateur\"" > /dev/null 2>&1
    then
        echo "Suppression de $nom_utilisateur en cours.."
        # ――――――― SUPPRESSION USER ―――――――
        ssh windows "powershell -Command \"Remove-LocalUser -Name '$nom_utilisateur'\""

        # ――――――― VERIF SI CA MARCHE BIEN ――――――
        if ! ssh windows "net user \"$nom_utilisateur\"" > /dev/null 2>&1
        then
            echo "L'utilisateur "$nom_utilisateur" a été supprimé avec succès."
        else
            echo "Erreur : la suppression de "$nom_utilisateur" a échoué."
        fi

    else
        # ――――――― USER NEXISTE PAS ―――――――
        echo "Erreur : l'utilisateur "$nom_utilisateur" n'existe pas."
    fi
done
}

############## Fonction ajout à un groupe ##############

ajout_group_ubuntu()
{
        while true
        do
              # demande sur quel utilisateur souhaitons-nous agir 
              read -p "Quel utilisateur souhaitez-vous ajouter à un groupe ? (q pour quitter) " reponse

                # Condition de sortie

        if [[ "$reponse" == "q" ]]; then
            echo "Sortie de l'ajout d'un utilisateur a un groupe"
            clear
            break
        fi

                # verification que l'utilisateur existe              
                if ssh ubuntu "! grep -q "$reponse:" /etc/passwd"
                 then
                  echo "L'utilisateur n'existe pas !" && break
                fi

                # demande dans quel groupe souhaitons-nous ajouter l'utilisateur
                read -p "Dans quel groupe souhaitez-vous ajouter $reponse ? : " nom
                
                # verification que le groupe existe
                if ssh ubuntu "grep -q "$nom" /etc/group" 
                  then

                    # ajout de l'utilisateur au groupe                 
                    ssh ubuntu  "sudo usermod -aG $nom $reponse"   && echo "$reponse a bien été ajouter a $nom."
                    break
                  else

                   # demande de créer le groupe s'il n'existe pas                 
                   read -p "Le groupe n'existe pas ! Voulez-vous le créer ? (oui/non) : " group
                     if test $group = "oui"
                       then
                          # créer le groupe et y ajouter l'utilisateur 
                          ssh ubuntu "sudo groupadd $nom && sudo usermod -aG $nom $reponse" && echo "$reponse a bien été ajouter a $nom."
                          break
                       else
                          break
                     fi
                fi


        done
}


ajout_group_windows()
{
        while true
        do
              # demande sur quel utilisateur souhaitons-nous agir 
              read -p "Quel utilisateur souhaitez-vous ajouter a un groupe ? (q pour quitter) : " reponse
                
                # Condition de sortie
                if [[ "$reponse" == "q" ]]; then
                echo "Sortie de l'ajout d'un utilisateur a un groupe"
                clear
                break
                fi

                # verification que l'utilisateur existe
                if ! ssh windows "net user \"$reponse\"" > /dev/null 2>&1
                 then
                  echo "L'utilisateur '$reponse' n'existe pas !" && break
                fi

                # demande dans quel groupe souhaitons-nous ajouter l'utilisateur
                read -p "Dans quel groupe souhaitez-vous ajouter $reponse ? " nom

                # verification que le groupe existe
                if ssh windows "net localgroup \"$nom\"" > /dev/null 2>&1
                  then

                    # ajout de l'utilisateur au groupe
                    ssh windows  "net localgroup \"$nom\" \"$reponse\" /add"   && echo "$reponse a bien été ajouter a $nom"
                    break
                else

                   # demande de créer le groupe s'il n'existe pas                 
                   read -p "Le groupe n'existe pas ! Voulez-vous le créer ? (oui/non)  " group
                    if [[ "$group" == "oui" ]] 
                       then

                          # créer le groupe et y ajouter l'utilisateur 
                          ssh windows "net localgroup \"$nom\" /add && net localgroup \"$nom\" \"$reponse\" /add" && echo "$reponse a bien été ajouter a $nom"
                          break
                    
                    fi
                fi
        done
}

############## Fonction ajout à un groupe admin ##############

ajout_group_admin_ubuntu()
{
        while true
        do
                # demande quel utilisateur ajouter au grp administrateur
                read -p "Quel utilisateur souhaitez-vous ajouter au groupe administrateur ? (q pour quitter) : " reponse
              
  # Condition de sortie

        if [[ "$reponse" == "q" ]]; then
            echo "Sortie de l'ajout d'un utilisateur a un groupe administrateur"
            clear
            break
        fi

                  # verif de l'existence de l'utilisateur          
                  if ssh ubuntu "! grep -q "$reponse:" /etc/passwd"
                   then
                     echo "L'utilisateur n'existe pas ! veuillez le créer avant de l'ajouter a un groupe ..." && break
                  fi
                 
                  # ajout de l'utilisateur au grp administrateur                
                  ssh ubuntu "sudo usermod -aG sudo $reponse"   && echo "$reponse a bien été ajouter au groupe administrateur."
                  break
        done
}


ajout_group_admin_windows()
{
        while true
        do
                # quel utilisateur souhaite t'ont ajouter au grp admin
                read -p "Quel utilisateur souhaitez-vous ajouter au groupe administrateur ? (q pour quitter) :  " reponse
                
                  # Condition de sortie

        if [[ "$reponse" == "q" ]]; then
            echo "Sortie de l'ajout d'un utilisateur a un groupe administrateur"
            clear
            break
        fi
                # verif que l'utilisateur existe
                if ssh windows "net user $reponse" > /dev/null 2>&1
                 then
                    
                    # connexion au compte admin et ajout de l'utilisateur au grp
                    echo "Connexion au compte administrateur ..."
                    ssh windows "net localgroup administrators $reponse /add" && echo "$reponse a bien été ajouter au groupe administrateur"
                    break
                 else
                  echo "L'utilisateur n'existe pas ! veuillez le créer avant de l'ajouter a un groupe ..." && break
                fi
        done
}


############## Fonction démmarage de script à distance ##############

execution_script_ubuntu()

{

    while true
    do

    read -p "Voulez vous lancer ce script à distance ? (O/N) : " reponse


        if [ "$reponse" = "O" ]
        then
            ssh -t ubuntu "sudo ./menu.Sh"
                echo "Script lancé pour l'utilisateur Wilder"
                break
        fi

        if [ "$reponse" = "N" ]
        then
            echo "Sortie du lancement du script a distance"
            clear
            break
        else
            echo "Réponse invalide. Merci de saisir O ou N"
        fi
    done
}

############## Info liste utilisateur ##############

info_liste_utilisateurs_ubuntu()
{

# Variable jour/heure

local heure=$(date +%H%M%S)
local jour=$(date +%Y%m%d)

# Chemin de destination

local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLILIN01_${jour}${heure}.txt"

# Affichage liste utilisateurs

liste_users=$(ssh ubuntu "awk -F: '\$3 >= 1000 {print \$1}' /etc/passwd")

echo "Liste des utilisateurs locaux : "$liste_users""

# Sauvegarde dans le dossier Info

echo "Liste des utilisateurs locaux : "$liste_users"" > "$destination"

# Test sauvegarde 

        if [ $? = 0 ]
        then 
            echo "Sauvegarde effectué dans : Info"
        else
            echo "Erreur lors de la sauvegarde"
        fi

sleep 5
clear

}

info_liste_utilisateurs_windows()
{

# Variable jour/heure

local heure=$(date +%H%M%S)
local jour=$(date +%Y%m%d)

# Chemin de destination

local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLIWIN01_${jour}${heure}.txt"

# Affichage liste utilisateurs

liste_users=$(ssh windows "powershell -Command \"Get-LocalUser | Select-Object Name, Enabled | Out-String\"")

echo "Liste des utilisateurs locaux : "
echo "$liste_users"

# Sauvegarde dans le dossier Info

echo "Liste des utilisateurs locaux :" > "$destination"
echo "$liste_users" >> "$destination"

# Test sauvegarde 

        if [ $? = 0 ]
        then 
            echo "Sauvegarde effectué dans : Info"
        else
            echo "Erreur lors de la sauvegarde"
        fi

sleep 5
clear

}

############## Info Version OS ##############

info_version_os_ubuntu()
{

# Variable jour/heure

local heure=$(date +%H%M%S)
local jour=$(date +%Y%m%d)

# Chemin de destination

local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLILIN01_$jour$heure.txt"

# Affichage liste utilisateurs

version_os=$(ssh ubuntu "cat /etc/lsb-release")

echo "Version de l'OS : "$version_os""

# Sauvegarde dans le dossier Info

echo "Version de l'OS : "$version_os"" > "$destination"


# Test sauvegarde 

        if [ $? = 0 ]
        then 
            echo "Sauvegarde effectué dans : Info"
        else
            echo "Erreur lors de la sauvegarde"
        fi

sleep 5
clear

}

info_version_os_windows()
{

# Variable jour/heure

local heure=$(date +%H%M%S)
local jour=$(date +%Y%m%d)

# Chemin de destination

local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLIWIN01_$jour$heure.txt"

# Affichage liste utilisateurs

version_os=$(ssh windows "powershell -Command \"Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber\"")

echo "Version de l'Os:"
echo "$version_os"

# Sauvegarde dans le dossier Info

echo "Version de l'OS :" > "$destination"
echo "$version_os" >> "$destination"

# Test sauvegarde 

        if [ $? = 0 ]
        then 
            echo "Sauvegarde effectué dans : Info"
        else
            echo "Erreur lors de la sauvegarde"
        fi

sleep 5
clear

}

############## Info 5 derniers logins ##############

info_cinqlogin_ubuntu()
{
        # variable jour/heure
        local heure=$(date +%H%M%S)
        local jour=$(date +%Y%m%d)

        
        # chemin destination
        local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLILIN01_${jour}${heure}.txt"

        # affichage 5 dernier login
        liste_login=$(ssh ubuntu "last -n 5 | grep -v wtmp | awk '{print \$1}'")

        echo "5 derniers login : "$liste_login""

        
        # sauvegarde dans le dossier info
        echo "5 derniers login : "$liste_login"" > "$destination"

        # test sauvegarde
        if test $? = 0
        then
         echo "Sauvegarde effectué dans : Info"
        else 
         echo "Erreur lors de la sauvegarde"
        fi

        sleep 5
        clear

}

info_cinqlogin_windows()
{

# Variable jour/heure

local heure=$(date +%H%M%S)
local jour=$(date +%Y%m%d)

# Chemin de destination

local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLIWIN01_$jour$heure.txt"

# Affichage des 5 derniers Login

liste_login=$(ssh windows "powershell -Command \"Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4624} -MaxEvents 5 | Select-Object TimeCreated, @{N='User'; E={\$_.Properties[5].Value}}, @{N='Type'; E={ switch(\$_.Properties[8].Value) { 2 {'Local'} 3 {'Reseau'} 5 {'Service'} 10 {'RDP'} Default {\$_.Properties[8].Value} } }} | Format-Table -AutoSize\"")

echo "5 derniers Login :"
echo "$liste_login"

# Sauvegarde dans le dossier Info

echo "5 derniers Login :" > "$destination"
echo "$liste_login" >> "$destination"

# Test sauvegarde 

        if [ $? = 0 ]
        then 
            echo "Sauvegarde effectué dans : Info"
        else
            echo "Erreur lors de la sauvegarde"
        fi

sleep 5
clear

}

############## Infos Reseaux ##############

info_reseaux_ubuntu()
{
        
        # variable jour/heure
        local heure=$(date +%H%M%S)
        local jour=$(date +%Y%m%d)

        # chemin de destination 
        local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLILIN01_${jour}${heure}.txt"

        # affichage info reseaux
        info_reseaux=$(ssh ubuntu 'ip a | grep "inet " | awk "{print \$2}" && ip route | grep "default" | awk "{print \$3}"')

        echo "information reseaux : "$info_reseaux""

        # sauvegarde dans le dossier info
        echo "Information réseaux : "$info_reseaux"" > "$destination"

        # test sauvegarde
        if test $? = 0
        then
         echo "Sauvegarde effectué dans : Info"
        else 
         echo "Erreur lors de la sauvegarde"
        fi

        sleep 5
        clear

}



info_reseaux_windowns()
{
        # variable jour/heure
        local heure=$(date +%H%M%S)
        local jour=$(date +%Y%m%d)

        # variable destination
        local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLIWIN01_${jour}${heure}.txt"

        # affichage des info sur les partition
        local info_reseaux=$(ssh windows "ipconfig | findstr /C:"IPv4" /C:"Masque" /C:"Passerelle"")

        echo "Infos Réseaux : "$info_reseaux""

        # sauvegarde dans le fichier info 
        echo "Infos Réseaux : "$info_reseaux"" > "$destination"

        # test sauvegarde
        if test $? = 0
        then
         echo "Sauvegarde effectué dans : Info"
        else 
         echo "Erreur lors de la sauvegarde"
        fi

        sleep 5
        clear

}

############## Infos carte Graphique ##############

info_cartegraphique_ubuntu()
{

# Variable jour/heure

local heure=$(date +%H%M%S)
local jour=$(date +%Y%m%d)

# Chemin de destination

local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLILIN01_$jour$heure.txt"

# Affichage liste utilisateurs

carte_graphique=$(ssh ubuntu "lspci | grep "VGA"")

echo "Carte graphique : "$carte_graphique""

# Sauvegarde dans le dossier Info

echo "Carte graphique : "$carte_graphique"" > "$destination"


# Test sauvegarde 

        if [ $? = 0 ]
        then 
            echo "Sauvegarde effectué dans : Info"
        else
            echo "Erreur lors de la sauvegarde"
        fi

sleep 5
clear
}


info_carte_graphique_windows()
{

# Variable jour/heure

local heure=$(date +%H%M%S)
local jour=$(date +%Y%m%d)

# Chemin de destination

local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLIWIN01_$jour$heure.txt"

# Affichage liste utilisateurs

carte_graphique=$(ssh windows "powershell -Command \"Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name\"")

echo "Carte graphique :"
echo "$carte_graphique"

# Sauvegarde dans le dossier Info

echo "Carte graphique : " > "$destination"
echo "$carte_graphique" >> "$destination"

# Test sauvegarde 

        if [ $? = 0 ]
        then 
            echo "Sauvegarde effectué dans : Info"
        else
            echo "Erreur lors de la sauvegarde"
        fi

sleep 5
clear

}

############## Infos Uptime ##############

info_uptime_ubuntu()

{

# Variable jour/heure

local heure=$(date +%H%M%S)
local jour=$(date +%Y%m%d)

# Chemin de destination

local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLILIN01_$jour$heure.txt"

# Affichage liste utilisateurs

uptime=$(ssh ubuntu "uptime")

echo "Uptime : "$uptime""

# Sauvegarde dans le dossier Info

echo "Uptime : "$uptime"" > "$destination"




# Test sauvegarde 

        if [ $? = 0 ]
        then 
            echo "Sauvegarde effectué dans : Info"
        else
            echo "Erreur lors de la sauvegarde"
        fi

sleep 5
clear

}

info_uptime_windows()
{

# Variable jour/heure

local heure=$(date +%H%M%S)
local jour=$(date +%Y%m%d)

# Chemin de destination

local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLIWIN01_$jour$heure.txt"

# Affichage liste utilisateurs

uptime=$(ssh windows "powershell -Command \"(Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime | Select-Object Days, Hours, Minutes, Seconds\"")

echo "Uptime :"
echo "$uptime"

# Sauvegarde dans le dossier Info

echo "Uptime : " > "$destination"
echo "$uptime" >> "$destination"

# Test sauvegarde 

        if [ $? = 0 ]
        then 
            echo "Sauvegarde effectué dans : Info"
        else
            echo "Erreur lors de la sauvegarde"
        fi

sleep 5
clear

}

############## Infos CPU% ##############

info_cpu_ubuntu()
{

# Variable jour/heure

local heure=$(date +%H%M%S)
local jour=$(date +%Y%m%d)

# Chemin de destination

local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLILIN01_$jour$heure.txt"

# Affichage liste utilisateurs

cpu=$(ssh ubuntu "grep 'cpu ' /proc/stat | awk '{usage=(\$2+\$4)*100/(\$2+\$4+\$5)} END {printf \"%.2f%%\", usage}'")

echo "CPU% : "$cpu""

# Sauvegarde dans le dossier Info

echo "CPU% : "$cpu"" > "$destination"


# Test sauvegarde 

        if [ $? = 0 ]
        then 
            echo "Sauvegarde effectué dans : Info"
        else
            echo "Erreur lors de la sauvegarde"
        fi

sleep 5
clear

}

info_cpu_windows()
{

# Variable jour/heure

local heure=$(date +%H%M%S)
local jour=$(date +%Y%m%d)

# Chemin de destination

local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLIWIN01_$jour$heure.txt"

# Affichage liste utilisateurs

cpu=$(ssh windows "powershell -Command \"(Get-CimInstance Win32_Processor).LoadPercentage | Out-String\"")

echo "CPU% :"
echo "$cpu %"

# Sauvegarde dans le dossier Info

echo "CPU% : " > "$destination"
echo "$cpu %" >> "$destination"

# Test sauvegarde 

        if [ $? = 0 ]
        then 
            echo "Sauvegarde effectué dans : Info"
        else
            echo "Erreur lors de la sauvegarde"
        fi

sleep 5
clear

}

############## Info nombre de disques ##############

info_nombre_disques_ubuntu()
{
        #  variable jour/heure
        local heure=$(date +%H%M%S)
        local jour=$(date +%Y%m%d)

        # chemin de destination
        local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLILIN01_${jour}${heure}.txt"

        # affichage nombres de disques
        nombre_Disque=$(ssh ubuntu "lsblk | awk '\$7=="disk" {print \$1}' | wc -l")

        echo "Nombres de Disques : "$nombre_Disque""

        # sauvegarde dans le fichier info
        echo "Nombres de Disques : "$nombre_Disque"" > "$destination"

        # test sauvegarde
        if test $? = 0
        then
         echo "Sauvegarde effectué dans : Info"
        else 
         echo "Erreur lors de la sauvegarde"
        fi

        sleep 5
        clear

}

info_nombre_disques_windows()
{
        #  variable jour/heure
        local heure=$(date +%H%M%S)
        local jour=$(date +%Y%m%d)

        # chemin de destination
        local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLIWIN01_${jour}${heure}.txt"

        # affichage nombres de disques
        nombre_Disque=$(ssh windows "powershell -Command \"(Get-Volume | Where-Object DriveLetter).Count\"")

        echo "Nombres de Disques : "
        echo "$nombre_Disque"

        # sauvegarde dans le fichier info
        echo "Nombres de Disques : " > "$destination"
        echo "$nombre_Disque" >> "$destination"
        
        # test sauvegarde
        if test $? = 0
        then
         echo "Sauvegarde effectué dans : Info"
        else 
         echo "Erreur lors de la sauvegarde"
        fi

        sleep 5
        clear

}

############## Info 10 derniers evenement critiques ##############

info_evenements_critique_ubuntu()
{

# Variable jour/heure

local heure=$(date +%H%M%S)
local jour=$(date +%Y%m%d)

# Chemin de destination

local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLILIN01_$jour$heure.txt"

# Affichage des 10 derniers evenements critiques

ssh ubuntu "journalctl -p 0..2 -n 10 --no-pager -q -o cat" | while read -r line
do

echo "Critique : $line"

# Sauvegarde dans le dossier Info

echo "Critique : $line" >> "$destination"
done


# Test sauvegarde 

        if [ $? = 0 ]
        then 
            echo "Sauvegarde effectué dans : Info"
        else
            echo "Erreur lors de la sauvegarde"
        fi

sleep 5
clear

}

info_evenement_critique_windows()
{

# Variable jour/heure

local heure=$(date +%H%M%S)
local jour=$(date +%Y%m%d)

# Chemin de destination

local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLIWIN01_$jour$heure.txt"

# Affichage des 10 derniers événements critiques

evenement_critique=$(ssh windows "powershell -Command \"Get-WinEvent -FilterHashtable @{LogName='*'; Level=1} -MaxEvents 10 | Select-Object TimeCreated, LogName, Message | Format-List\"")

echo "10 derniers événements critiques :"
echo "$evenement_critique"

# Sauvegarde dans le dossier Info

echo "10 derniers événements critiques :" > "$destination"
echo "$evenement_critique" >> "$destination"

# Test sauvegarde 

        if [ $? = 0 ]
        then 
            echo "Sauvegarde effectué dans : Info"
        else
            echo "Erreur lors de la sauvegarde"
        fi

sleep 5
clear

}

############## Info Temperature CPU ##############

info_temperature_cpu_ubuntu()
{

# Variable jour/heure

local heure=$(date +%H%M%S)
local jour=$(date +%Y%m%d)

# Chemin de destination

local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLILIN01_$jour$heure.txt"

# Vérification que la machine est une VM

VIRT_CHECK=$(ssh ubuntu "systemd-detect-virt" 2>/dev/null)

if [ "$VIRT_CHECK" != "none" ] && [ -n "$VIRT_CHECK" ]
then
    echo "Type de détéction : $VIRT_CHECK"
    echo "La machine est une VM, il n'y a donc pas de sonde physique"
    echo "Type de détéction : $VIRT_CHECK" > "$destination"
    echo "La machine est une VM, il n'y a donc pas de sonde physique" >> "$destination"
else
        # C'est bien une machine physique
        TEMP_BRUT=$(ssh ubuntu "cat /sys/class/thermal/thermal_zone0/temp" 2>/dev/null)
        if [ -n "$TEMP_BRUT" ]
        then
        TEMP=$((TEMP_BRUT / 1000))
            echo "Température du CPU : $TEMP degrés" > "$destination"
        fi
fi

# Test sauvegarde 

        if [ $? = 0 ]
        then 
            echo "Sauvegarde effectué dans : Info"
        else
            echo "Erreur lors de la sauvegarde"
        fi

sleep 5
clear

}

info_temperature_cpu_windows()
{
    # Variable jour/heure
    local heure=$(date +%H%M%S)
    local jour=$(date +%Y%m%d)

    # Chemin de destination
    local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLIWIN01_$jour$heure.txt"

    #Vérification du modèle (VM ou Physique)
    VIRT_CHECK=$(ssh windows "powershell -Command \"(Get-CimInstance Win32_ComputerSystem).Model\"")

    #Logique de détection et récupération de données
    if [[ "$VIRT_CHECK" =~ "Virtual" || "$VIRT_CHECK" =~ "VMware" || "$VIRT_CHECK" =~ "Standard PC" ]]
    then
        echo "Détection : Machine Virtuelle ($VIRT_CHECK)"
        MSG_INFO="La machine est une VM, il n'y a donc pas de sonde physique."
    else
        echo "Détection : Machine Physique"
        # On récupère la température et on l'arrondit via PowerShell pour éviter les erreurs de calcul Bash
        TEMP_BRUT=$(ssh windows "powershell -Command \"\$t = Get-CimInstance -Namespace root/wmi -ClassName MsAcpi_ThermalZoneTemperature -ErrorAction SilentlyContinue; if(\$t){ [math]::Round((\$t.CurrentTemperature / 10) - 273.15) }\"")
        
        if [ -z "$TEMP_BRUT" ]; then
            MSG_INFO="Machine Physique mais sonde non supportée par le BIOS."
        else
            MSG_INFO="Température du CPU : $TEMP_BRUT degrés."
        fi
    fi

    # Affichage et Sauvegarde
    echo "$MSG_INFO"
    
    {
        echo "--- Rapport Système ---"
        echo "Modèle : $VIRT_CHECK"
        echo "$MSG_INFO"
    } > "$destination"

    #Test sauvegarde 
    if [ $? -eq 0 ]
    then 
        echo "Sauvegarde effectuée dans : Info"
    else
        echo "Erreur lors de la sauvegarde"
    fi

    sleep 5
    clear
}

############## Info Partitions ##############
info_partition_ubuntu()
{
        # variable jour/heure
        local heure=$(date +%H%M%S)
        local jour=$(date +%Y%m%d)

        # variable destination
        local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLILIN01_${jour}${heure}.txt"

        # affichage des info sur les partition
        local info_Partition=$(ssh ubuntu "lsblk -o NAME,TYPE,FSTYPE,SIZE | grep -E 'disk|part'")

        echo "Info partition : "$info_Partition""

        # sauvegarde dans le fichier info 
        echo "Info Partition : "$info_Partition"" > "$destination"

        # test sauvegarde
        if test $? = 0
        then
         echo "Sauvegarde effectué dans : Info"
        else 
         echo "Erreur lors de la sauvegarde"
        fi

        sleep 5
        clear

}
############## Info espace disque restant ##############

info_espace_restant_ubuntu()
{
        # variable jour/heure
        local heure=$(date +%H%M%S)
        local jour=$(date +%Y%m%d)

        # variable destination
        local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_CLILIN01_${jour}${heure}.txt"

        # affichage de l'espace des disque restant
        local espace_restant=$(ssh ubuntu "df -h | grep "^/dev/sd" | awk '{print \$1, \$4}'")

        echo "Espace disque restant : "$espace_restant""

        # sauvergarde dans le fichier info
        echo "Espace disque restant : "$espace_restant"" > "$destination"

        if test $? = 0
        then
         echo "sauvegarde effectué dans : Info"
        else 
         echo "Erreur lors de la sauvegarde"
        fi

        sleep 5
        clear

}

############## Info Utilisateurs ##############

info_utilisateurs_ubuntu ()

{


# variable jour/heure
        local heure=$(date +%H%M%S)
        local jour=$(date +%Y%m%d)

# variable destination
        local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_wilder_${jour}${heure}.txt"

# Question sur quel dossier ? 

read -p "Sur quel dossier voulez-vous vérifier les droits de Wilder ? (q pour quitter): " dossier

# Condition de sortie 

     if [[ "$dossier" == "q" ]]; then
            echo "Sortie"
            sleep 2
            clear
            return 0
        fi

# Vérification que le dossier existe 

 verification_droits=$(ssh ubuntu "[ -d '$dossier' ] && ls -ld '$dossier' || echo 'ERREUR : Dossier introuvable'")

# Affichage  
echo " Droits sur le "$dossier" : "
echo "$verification_droits"
# Sauvegarde 
echo " Droits sur le $dossier : $verification_droits" > "$destination" 2>&1


# Test sauvegarde 

      if test $? = 0
        then
         echo "Sauvegarde effectué dans : Info"
        else 
         echo "Erreur lors de la sauvegarde"
        fi
        sleep 5
        clear
}


#!/bin/bash

info_utilisateurs_windows ()

{


# variable jour/heure
        local heure=$(date +%H%M%S)
        local jour=$(date +%Y%m%d)

# variable destination
        local destination="/root/Documents/TSSR-0226-P2-G1/script/info/info_Wilder_${jour}${heure}.txt"

# Question sur quel dossier ? 

read -p "Sur quel dossier voulez-vous vérifier les droits de Wilder ? (q pour quitter): " dossier

# Condition de sortie 

     if [[ "$dossier" == "q" ]]; then
            echo "Sortie"
            sleep 2
            clear
            return 0
        fi

# Vérification que le dossier existe 

verification_droits=$(ssh windows "powershell -Command \"if (Test-Path 'C:\\$dossier') { Get-Acl 'C:\\$dossier' | Format-List } else { Write-Output 'ERREUR : Dossier introuvable' }\"")

# Affichage  
echo " Droits sur le "$dossier" : "
echo "$verification_droits"
# Sauvegarde 
echo " Droits sur le $dossier : $verification_droits" > "$destination" 2>&1


# Test sauvegarde 

      if test $? = 0
        then
         echo "Sauvegarde effectué dans : Info"
        else 
         echo "Erreur lors de la sauvegarde"
        fi
        sleep 5
        clear
}


clear
echo "#################################################"
echo "#                                               #"
echo "#                MENU PRINCIPAL                 #"
echo "#                                               #"
echo "#################################################"


# Ordinateurs , Utilisateurs ou Infos

while true
do
        echo " Choississez une cible "
        echo "1- Ordinateurs"
        echo "2- Utilisateurs"
        echo "3- Infos script"
        echo "4- Quitter"
        read -p "Choississez une option : " choix
            clear

case $choix in

1)
    # Sous-menu Ordinateurs
    while true; do
        echo "Vous avez choisi : Ordinateurs"
        echo "1- Client Windows"
        echo "2- Client Ubuntu"
        echo "3- Retour"
        read -p "Choix : " souschoix
            clear
                
                case $souschoix in
                1)
                    echo " Ordinateur Windows : CLIWIN01 "
                    echo " Quel action faire sur l'ordinateur CLIWIN01 ?"
                    echo " 1- Vérrouillez l'ordinateur "
                    echo " 2- Redémarrer l'ordinateur"
                    echo " 3- Création de répertoire"
                    echo " 4- Suppression de répertoire"
                    echo " 5- Prise en main à distance en CLI"
                    echo " 6- Activation du parefeu"
                    echo " 7- Exécution du script sur la machine distante"
                    echo " 8- Infos "
                    echo " 9- Retour"
                    read -p "Choix : " action1
                        clear
                            
                            case $action1 in
                            1)
                                echo "Vérrouillez l'ordinateur"
                                verrouillage_windows
                                ;;
                            2)
                                echo "Redémarrer l'ordinateur"
                                redemarage_windows
                                ;;
                            3)
                                echo "Création de répertoire"
                                creation_repertoire_windows
                                ;;
                            4)
                                echo "Suppression de répertoire"
                                suppression_repertoire_windows
                                ;;
                            5)
                                echo "Prise en main à distance en CLI"
                                ssh windows
                                ;;
                            6)
                                echo "Activation du parefeu"
                                activation_parefeu_windows
                                ;;
                            7)
                                echo "Exécution du script sur la machine distante"
                                ;;
                            #Choix des infos a voir            
                            8) 
                                while true;do
                                    echo "==== MENU INFOS ===="
                                    echo "1- Liste des utilisateurs locaux"
                                    echo "2- 5 derniers logins"
                                    echo "3- Adresse IP, masque, passerelle"
                                    echo "4- Nombre de disque"
                                    echo "5- Partition (nombre,nom,FS,taille) par disque"
                                    echo "6- Espace disque restant par partition/volume"
                                    echo "7- Version de l'OS"
                                    echo "8- Carte graphique"
                                    echo "9- CPU %"
                                    echo "10- Uptime"
                                    echo "11- 10 derniers événements critiques"
                                    echo "12- Température CPU"
                                    echo "13- Retour"
                                    read -p "Choix : " infochoix
                                        clear

                                    case $infochoix in
                                        1)
                                            echo "Liste des utilisateurs locaux"
                                            info_liste_utilisateurs_windows
                                            ;;
                                        2)
                                            echo "5 derniers logins"
                                            info_cinqlogin_windows
                                            ;;
                                        3)
                                            echo "Adresse IP, masque, passerelle"
                                            info_reseaux_windowns
                                            ;;
                                        4)
                                            echo "Nombre de disque"
                                            info_nombre_disques_windows
                                            ;;
                                        5)
                                            echo "Partition (nombre,nom,FS,taille) par disque"
                                            ;;
                                        6)
                                            echo "Espace disque restant par partition volume"
                                            ;;
                                        7)
                                            echo "Version de l'OS"
                                            info_version_os_windows
                                            ;;
                                        8) 
                                            echo "Carte graphique"
                                            info_carte_graphique_windows
                                            ;;
                                        9)
                                            echo "CPU %"
                                            info_cpu_windows
                                            ;;
                                        10)
                                            echo "Uptime"
                                            info_uptime_windows
                                            ;;
                                        11)
                                            echo "10 derniers événements critiques"
                                            info_evenement_critique_windows
                                            ;;
                                        12)
                                            echo "Température CPU"
                                            info_temperature_cpu_windows
                                            ;;
                                        13)
                                            break
                                            ;;
                                        *)
                                            echo "Choix invalide"
                                            ;;
                                        esac
                                    done
                                    ;;
                                9)
                                    break
                                    ;;

                            *)      
                                echo "Option invalide"
                                ;;
                            esac
                    ;;
                2)
                    echo " Ordinateur Ubuntu : CLILIN01 "
                    echo " Quel action faire sur l'ordinateur CLILIN01 ?"
                    echo " 1- Vérrouillez l'ordinateur "
                    echo " 2- Redémarrer l'ordinateur"
                    echo " 3- Création de répertoire"
                    echo " 4- Suppression de répertoire"
                    echo " 5- Prise en main à distance en CLI"
                    echo " 6- Activation du parefeu"
                    echo " 7- Exécution du script sur la machine distante"
                    echo " 8- Infos"
                    echo " 9- Retour"
                    read -p "Choix : " action1
                            clear

                            case $action1 in
                            1)
                                echo "Vérrouillez l'ordinateur"
                                verrouillage_ubuntu
                                ;;
                            2)
                                echo "Redémarrer l'ordinateur"
                                redemarage_ubuntu
                                ;;
                            3)
                                echo "Création de répertoire"
                                creation_repertoire_ubuntu
                                ;;
                            4)
                                echo "Suppréssion de répertoire"
                                suppression_repertoire_ubuntu
                                ;;
                            5)
                                echo "Prise en main à distance en CLI"
                                ssh ubuntu
                                ;;
                            6)
                                echo "Activation du parefeu"
                                activation_parefeu_ubuntu
                                ;;
                            7)
                                echo "Exécution du script sur la machine distante"
                                execution_script_ubuntu
                                ;;                            
                           
                            #Choix des infos a voir  
                            8)          
                
                                while true;do
                                    echo "==== MENU INFOS ===="
                                    echo "1- Liste des utilisateurs locaux"
                                    echo "2- 5 derniers logins"
                                    echo "3- Adresse IP, masque, passerelle"
                                    echo "4- Nombre de disque"
                                    echo "5- Partition (nombre,nom,FS,taille) par disque"
                                    echo "6- Espace disque restant par partition/volume"
                                    echo "7- Version de l'OS"
                                    echo "8- Carte graphique"
                                    echo "9- CPU %"
                                    echo "10- Uptime"
                                    echo "11- 10 derniers événements critiques"
                                    echo "12- Température CPU"
                                    echo "13- Retour"
                                    read -p "Choix : " infochoix
                                        clear

                                    case $infochoix in
                                        1)
                                            echo "Liste des utilisateurs locaux"
                                            info_liste_utilisateurs_ubuntu
                                            ;;
                                        2)
                                            echo "5 derniers logins"
                                            info_cinqlogin_ubuntu
                                            ;;
                                        3)
                                            echo "Adresse IP, masque, passerelle"
                                            info_reseaux_ubuntu
                                            ;;
                                        4)
                                            echo "Nombre de disque"
                                            info_nombre_disques_ubuntu
                                            ;;
                                        5)
                                            echo "Partition (nombre,nom,FS,taille) par disque"
                                            info_partition_ubuntu
                                            ;;
                                        6)
                                            echo "Espace disque restant par partition volume"
                                            info_espace_restant_ubuntu
                                            ;;
                                        7)
                                            echo "Version de l'OS"
                                            info_version_os_ubuntu
                                            ;;
                                        8) 
                                            echo "Carte graphique"
                                            info_cartegraphique_ubuntu
                                            ;;
                                        9)
                                            echo "CPU %"
                                            info_cpu_ubuntu
                                            ;;
                                        10)
                                            echo "Uptime"
                                            info_uptime_ubuntu
                                            ;;
                                        11)
                                            echo "10 derniers événements critiques"
                                            info_evenements_critique_ubuntu
                                            ;;
                                        12)
                                            echo "Température CPU"
                                            info_temperature_cpu_ubuntu
                                            ;;
                                        13)
                                            break
                                            ;;
                                        *)
                                            echo "Choix invalide"
                                            ;;
                                        esac
                                    done
                                    ;;
                            9)
                                    break
                                    ;;
                            *)
                                echo "Option invalide"
                                ;;
                            esac
                    ;;
                3)
                    break
                    ;;
              
                *)
                    echo "Option invalide"
                    ;;
                esac
            done     
    ;;
2)
    # Sous-menu Utilisateurs
    while true; do
        echo "Vous avez choisi : Utilisateurs"
        echo "1- Utilisateur Windows"
        echo "2- Utilisateur Ubuntu"
        echo "3- Retour"
        read -p "Choix : " souschoix
            clear
                case $souschoix in
                1)
                    echo "Utilisateur Windows : Wilder"
                    echo "Quel action faire sur l'utilisateur Wilder"
                    echo "1- Création de compte utilisateur local"
                    echo "2- Changement de mot de passe"
                    echo "3- Suppression de compte utilisateur local"
                    echo "4- Ajout à un groupe d'administration"
                    echo "5- Ajout à un groupe"
                    echo "6- Infos"
                    echo "7- Retour"
                    read -p "Choix : " action1
                    clear

                    case $action1 in 
                    1)
                        echo "Création de compte utilisateur local"
                        creation_utilisateur_windows
                        ;;
                    2)
                        echo "Changement de mot de passe"
                        changement_mdp_windows
                        ;;
                    3)
                        echo "Suppression de compte utilisateur local"
                        supprimer_utilisateur_windows
                        ;;
                    4)
                        echo "Ajout à un groupe d'administration"
                        ajout_group_admin_windows
                        ;;
                    5)
                        echo "Ajout à un groupe"
                        ajout_group_windows
                        ;;
                    6)
                        echo "Infos : Droits et permission de l'utilisateur sur un dossier"
                        info_utilisateurs_windows
                        ;;
                    7)
                        break
                        ;;
                    esac 
                    ;;
                2)
                    echo "Utilisateur Ubuntu : Wilder"
                    echo "Quel action faire sur l'utilisateur Wilder"
                    echo "1- Création de compte utilisateur local"
                    echo "2- Changement de mot de passe"
                    echo "3- Suppression de compte utilisateur local"
                    echo "4- Ajout à un groupe d'administration"
                    echo "5- Ajout à un groupe"
                    echo "6- Infos"
                    echo "7- Retour"
                    read -p "Choix : " action1
                    clear

                    case $action1 in 
                    1)
                        echo "Création de compte utilisateur local"
                        creation_utilisateur_ubuntu
                        ;;
                    2)
                        echo "Changement de mot de passe"
                        changement_mdp_ubuntu
                        ;;
                    3)
                        echo "Suppression de compte utilisateur local"
                        supprimer_utilisateur_ubuntu
                        ;;
                    4)
                        echo "Ajout à un groupe d'administration"
                        ajout_group_admin_ubuntu
                        ;;
                    5)
                        echo "Ajout à un groupe"
                        ajout_group_ubuntu
                        ;;
                    6)
                        echo "Infos : Droits et permission de l'utilisateur sur un dossier"
                        info_utilisateurs_ubuntu
                        ;;
                    7)
                        break
                        ;;
                    esac 
                    ;;
                3)
                    break
                    ;;
                *)
                    echo "Option invalide"
                    ;;
                
                esac
            done
    ;;
3)
                #Sous-menu Infos
                while true; do

                echo "Infos script"
                echo "Quelles infos voulez-vous voir ?"
                echo "1- Recherche des événements pour un utilisateur"
                echo "2- Recherche des événements pour un ordinateurs"
                echo "3- Retour"

                read -p "Choix : " action1
                    clear

                            case $action1 in
                            1)
                                echo "Recherche des événements pour un utilisateur"
                                ;;
                            2)
                                echo "Recherche des événements pour un ordinateurs"
                                ;;
                            3)
                                break
                                ;;
                            *)
                                echo "Option invalide"
                                ;;
                    esac
                done
    ;;
4)
    echo "Vous avez choisi de quitter"
    exit 0
    ;;

*) 
    echo " Choississez un chiffre"
    ;;
esac
done 
