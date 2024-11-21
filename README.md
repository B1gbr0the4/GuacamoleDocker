# Infrastructure avec Bastion

![Image_Couverture](./img/bastion_copilot.jpg)

## Sommaire

- [Infrastructure avec Bastion](#infrastructure-avec-bastion)
  - [Sommaire](#sommaire)
  - [Sécurisation des SI](#sécurisation-des-si)
    - [Le concept de bastion](#le-concept-de-bastion)
    - [Les bonnes pratiques](#les-bonnes-pratiques)
  - [Contexte d'implémentation](#contexte-dimplémentation)
  - [Pré-requis](#pré-requis)
    - [Installation (Ubuntu)](#installation-ubuntu)
    - [Installation (WSL)](#installation-wsl)
      - [Installer WSL](#installer-wsl)
      - [Installer docker](#installer-docker)
  - [Déploiement de l'architecture via Docker](#déploiement-de-larchitecture-via-docker)
    - [Arborescence](#arborescence)
    - [Première exécution](#première-exécution)
    - [Lancement et arrêt](#lancement-et-arrêt)
  - [Paramétrage](#paramétrage)
    - [Première authentification](#première-authentification)
    - [Configuration de la console d'administration](#configuration-de-la-console-dadministration)
    - [Enregistrement des sessions](#enregistrement-des-sessions)
    - [Configuration générale du bastion](#configuration-générale-du-bastion)
    - [Authentification](#authentification)
  - [Informations utiles](#informations-utiles)
  - [Approfondissement](#approfondissement)
  - [Sources et références](#sources-et-références)

## Sécurisation des SI

### Le concept de bastion

La multiplication des machines et services dans un SI1 présente des enjeux de sécurité majeurs : 

- Comment gérer les identifiants de ces dernières machines, en particulier les comptes administrateurs ? 
  - Gestion des accès selon la politique du moindre accès ? 
  - Stockage et rotation des identifiants ? 
- Comment garantir une traçabilité : 
  - Des actions effectuées ? 
  - De l’identité de la personne accédant au système ? 

 
Un bastion peut répondre à l’ensemble de ces enjeux. Aussi appelé *jump box*, un bastion peut être utilisé dans les configurations suivantes, non-mutuellement exclusives : 

- En externe, dans une DMZ, dans le but de sécuriser un accès distant à un réseau (surveiller les accès distants et éviter d'exposer les ports RDP/SSH sur internet),
- En interne : 
  - Afin de sécuriser l'accès administrateur à une ressource sensible (par exemple un lab contenant les serveurs d'une entreprise bancaire) en enregistrant les actions d’administration, voire en permettant à un administrateur d'en surveiller un autre en direct,
  - Ainsi que contrôler et journaliser l'accès à un système par des prestataires externes, pour permettre d'identifier les actions prises et de constituer des preuves en cas de conflit juridique. 

### Les bonnes pratiques

Il convient de suivre des bonnes pratiques lors de l’implémentation d’un système d’information. Notamment : 

- Disposer d'une documentation des SI à jour :
  - Les administrateurs doivent disposer de documents reflétant fidèlement l’état courant des SI qu’ils administrent, notamment des cartographies du SI,
  - Il s’agit d’une étape essentielle lors du démarrage d’un projet de déploiement d’un bastion : cartographier le système d’information, et identifier les assets qui seront intégrés à son périmètre,
  - Il faut également veiller à mettre la documentation à jour à la fin du déploiement, pour y intégrer le bastion. 
- Analyse de risque :
  - Il convient de réaliser une analyse des risques avant le démarrage du projet, qui pourra motiver l’intégration au bastion de certains assets plutôt que d’autres,
  - Il faudra également effectuer une analyse de risque sur la nouvelle infrastructure après déploiement du bastion. 
- Utiliser des protocoles sécurisés pour les flux d'administration :
  - Cette étape est primordiale : des protocoles utilisant des mécanismes de chiffrement et d’authentification robustes sont à imposer, les protocoles non sécurisés doivent être explicitement désactivés ou bloqués. 
  - Un bastion ne sert que d’intermédiaire, et ne protège pas d’attaques *MitM2* ! 
- Segmentation réseau : Le recours à un bastion ne dispense pas d’une segmentation réseau qui permet d’établir un cloisonnement du SI d’administration. 

## Contexte d'implémentation

La plupart des bastions sur le marché sont des solutions commerciales propriétaires. Nous avons choisi de développer un démonstrateur de bastion open-source, en utilisant l'une des rares solutions correspondant à ce critère : [Apache Guacamole](https://guacamole.apache.org/).

L'implémentation est réalisée sous Docker, dans un objectif de portabilité et de facilité de déploiement. L'architecture est d'abord composée de conteneurs implémentant la colonne vertébrale de l'application :  

- `guacd` : Le conteneur fournissant le démon `guacd`, construit à partir de `guacamole-server`, et qui implémente les différents protocoles de contrôle à distance (RDP, SSH, VNC...), 
- `guacamole` : L’application web Guacamole, implémentée sous Apache Tomcat® supportant le protocole *WebSocket*, qui permet la connexion à `guacd`, et aux moyens d’authentifications.,
- `postgres` : La base de données chiffrée permettant l’authentification, contenant l’ensemble des utilisateurs, leurs *credentials* (identifiant/mot de passe) et leurs droits. PostGreSQL, contrairement à ses concurrents comme SQL Server, est open-source, très performant pour des bases de grande taille, et flexible, supportant à la fois les formats relationnels (SQL) et non-relationnels (JSON),
- `nginx` :  Un serveur web open source, adapté pour les *reverse proxy* (ce qui est son rôle ici). 

Et de deux conteneurs soutenant le démonstrateur, et visant à être remplacés par des serveurs réels dans un environnement de production :

- `windows` : Le serveur Windows, qui émule un WIndows XP. Cette version a été préférée à des versions plus récente pour son poids (0,6 Go contre 6 Go pour WIndows 11), et par le caractère hors-ligne de ce projet, évitant les risques liés à l’utilisation de Windows XP dans des environnements quotidiens. Il est possible de changer l'image pour une version plus récente dans le *Dockerfile*,
- `debian` : Le serveur Linux, basé sur Debian, a également été choisi pour sa légèreté. Une image custom est créée afin d’ajouter un serveur SSH. 

## Pré-requis

### Installation (Ubuntu)

Installer Docker : [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

Installer les paquets nécessaires :

```bash
sudo apt install docker-compose-v2 openssl -y
```

### Installation (WSL)

Extrait du tutoriel suivant : [How to run docker on Windows without Docker Desktop](https://dev.to/_nicolas_louis_/how-to-run-docker-on-windows-without-docker-desktop-hik)


#### Installer WSL

D'après [How to install Linux on Windows with WSL](https://docs.microsoft.com/en-us/windows/wsl/install#step-2-update-to-wsl-2) :

* Pré-requis : **Windows 10 version 2004** et supérieur (**Build 19041** et supérieur) ou **Windows 11**.
* Exécuter **Windows Terminal** en tant qu'administrateur et entrer :
```sh
wsl --install
```
* Redémarrer la machine Windows ;
* Lancer le programme WSL.

#### Installer docker

Vous pouvez utiliser docker comme sur une machine Ubuntu à l'intérieur de WSL. Si vous souhaitez intéragir avec docker depuis Windows, suivre le [tutoriel initial](https://dev.to/_nicolas_louis_/how-to-run-docker-on-windows-without-docker-desktop-hik).

* Mettre à jour la distribution :
```sh
sudo apt update && sudo apt upgrade -y
```
* Configurer le repo de docker :
```sh
source /etc/os-release
curl -fsSL https://download.docker.com/linux/${ID}/gpg | sudo apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update
```
* Installer les paquets :
```sh
sudo apt install docker-ce docker-ce-cli containerd.io -y
```
* Ajouter notre utilisateur au groupe docker :
```sh
sudo usermod -aG docker $USER
```
* Tester la nouvelle installation :
```sh
docker run --rm hello-world
```
Si tout se passe bien, vous obtiendrez la sortie suivante :
> Hello from Docker!
>
> ...

## Déploiement de l'architecture via Docker

### Arborescence 

L’arborescence du livrable bastion/ contient 4 dossiers ressources :  

- `init/` : Mappé au dossier `/docker-entrypoint-initdb.d` du conteneur `postgres`, contient le script SQL (`initdb.sql`) qui crée la base de données PostgreSQL,
- `data/` : Mappé au dossier `/var/lib/postgresql/data/` du conteneur `postgres`, contient les données de la base de donnée PostgreSQL,
- `drive/` : Mappé aux deux conteneurs de Guacamole, contient les données utilisateur,
- `record/` : Mappé aux deux conteneurs de Guacamole, contient les enregistrements des sessions. 

Le déploiement se fait via un fichier `docker-compose`. Docker Compose facilite la gestion de configurations Docker complexes en remplaçant les longues commandes Docker par un fichier de configuration structuré en YAML. 

### Première exécution

* Récupérer le contenu du dossier `Dev3` et le transférer sur la machine.
* Mettre en place le fichier .env (on génère ici avec sed un mot de passe aléatoire pour la base de données) :
```bash
cp .env.example .env
sed -i "s/POSTGRES_PASSWORD=changeme/POSTGRES_PASSWORD=$(openssl rand -hex 32)/" .env
```
* Compléter le fichier .env avec les identifiants & mots de passe désirés :
```bash
nano .env
```
* Avant la première exécution, il faut rendre les scripts exécutables :
```sh
chmod +x *.sh
```
* Pour déployer l'architecture (une seule exécution suffit, même après avoir tout réinitialisé) :
```sh
sudo ./init.sh
```

### Lancement et arrêt

* Pour lancer tous les conteneurs :
```sh
sudo ./run.sh
```
* Pour arrêter les conteneurs, supprimer les données voire tout désinstaller :
```sh
sudo ./reset.sh
```

## Paramétrage 

### Première authentification

**Changez le mot de passe à la première connexion !**

Les identifiants de l'interface web sont les suivants :

- Nom d'utilisateur :   `guacadmin`
- Mot de passe :        `guacadmin`

### Configuration de la console d'administration

Une fois sur l'interface web (IP donnée à la fin de l'execution), il est possible de configurer les connexions aux serveurs. Pour cela, il faut se rendre dans *Settings > Connections > New Connection* et remplir les champs en suivants les informations de la documentation de Guacamole.

Typiquement, pour une connection SSH, on remplira :

- **EDIT CONNECTION**
  - Name : `Debian`
  - Location : `ROOT`
  - Protocol : `SSH`
- CONCURRENCY LIMIT
  - Maximum number of connections : `1`
  - Maximum number of connections per user : `1`
- **PARAMETERS**
  - Network
    - Hostname : `debian`
    - Port : `22`
    - Authentication
      - Username : `johndoe`
      - Password : `yourpassword`
  
Et pour une connection RDP : 

- **EDIT CONNECTION**
  - Name : `Windows`
  - Location : `ROOT`
  - Protocol : `RDP`
- CONCURRENCY LIMIT
  - Maximum number of connections : `1`
  - Maximum number of connections per user : `1`
- **PARAMETERS**
  - Network
    - Hostname : `windows`
    - Port : `3389`
    - Authentication
      - Username : `johndoe`
      - Password : `yourpassword`
      - Ignore server certificate : `true`
    - Device redirection
      - Support audio in console : `true`
      - Disable file download : `true`
      - Disable file upload : `true`

Pour configurer un utilisateur, aller dans *Settings > Users > New User* et remplir par exemple les champs :

- **EDIT USER**
  - Username : `john doe`
  - Password : `yourpassword`
  - Re-enter password : `yourpassword`
- **PROFILE**
  - Full Name : `John Doe`
  - Email Address : `john.doe@example.com`
  - Organization : `Example Inc.`
  - Role : `Example User`
- **ACCOUNT RESTRICTIONS**
  - User timezone : `Europe/Paris`
- **PERMISSIONS**
  - Change own password : `true`
- **CONNECTIONS**
  - All connections
    - *debian* : `true`
    - *windows* : `false`

### Enregistrement des sessions

Pour enregistrer les sessions, il faut, dans les paramètres d'une connection, éditer :

- Enregistrement Ecran
  - Chemin de l'enregistrement : `{HISTORY_PATH}/${HISTORY_UUID}`, qui permet de générer automatiquement les dossiers d’enregistrement à partir d’un ID unique
  - Nom de l'enregistrement : `${GUAC_DATE}_${GUAC_TIME}`, qui permet de nommer automatiquement le fichier avec la date et l’heure de l’enregistrement
  - Créer automatiquement le chemin de l'enregistrement : `true`

Pour enregistrer uniquement le textuel SSH, la section s'appelle **Typescript (Text Session Recording)**.

Guacamole utilise un format d'enregistrement particulier, qui permet de sauvegarder de longues sessions avec un volume réduit. Actuellement, ce format est lu dans le navigateur via une extension, mais il est aussi possible de convertir automatiquement les fichiers :

- Soit avec la commande `guacenc` : Voir la [documentation](https://guacamole.apache.org/doc/gug/configuring-guacamole.html#graphical-session-recording), mais celle-ci est complexe à installer dans Docker, avec de nombreux problèmes de dépendances. Vous pouvez aussi essayer de l'installer sur votre machine hôte,
- Soit avec un nouveau conteneur, comme [bytepen/guacenc](https://hub.docker.com/r/bytepen/guacenc).

De même avec les enregistrements textuels, dans un format particulier convertissables avec `scriptreplay`.

### Configuration générale du bastion

Pour configurer le bastion (ajout de serveurs, d'utilisateurs, de connexions, etc.), se référer à la [documentation de guacamole](https://guacamole.apache.org/doc/gug/) et aux divers tutoriels disponibles en ligne.

Pour le conteneur Windows, notamment pour changer la version de Windows, voir la documentation du projet : [Dockur/Windows](https://github.com/dockur/windows/blob/master/readme.md)

### Authentification

Guacamole supporte différents modes d'authentification :

- Authentification : 
  - Simple (Base de données, LDAP, HTTP Header, JSON chiffré, RADIUS) 
  - Via SSO (CAS, OpenID Connect, SAML)
  - 2FA (Duo, TOTP) 

L'authentification par base de donnée est aujourd'hui la mieux supportée, mais il est possible de configurer d'autres modes d'authentification en suivant la [documentation](https://guacamole.apache.org/doc/gug/). Dans un environnement de production, on aura tendance à privilégier l'authentification par LDAP, qui permet de centraliser les identifiants et les droits des utilisateurs.

## Informations utiles

- Le nom DNS des machines dans un réseau docker est le nom du conteneur associé,
- Il est possible de dé-commenter les sections `ports` dans le fichier docker-compose à des fins de débogage,
- Si vous avez besoin de forcer un *hard-delete* pour des raisons de débogage, vous pouvez utiliser la commande suivante :
  ```sh
  docker stop $(docker ps -a -q)
  docker rm $(docker ps -a -q)
  ```
- Le support de Guacamole sur Docker, bien que largement fonctionnel, comporte encore des bugs mineurs, et des trous dans la documentation, qui peuvent rendre l'implémentation de certaines fonctionnalités plus complexes que prévu.

## Approfondissement

Parmi les ajouts à ce projet, nous conseillons en premier lieu :

- Implémentation d’une authentification MFA : Guacamole fournit le moyen de configurer une authentification multi-facteurs, qui permet, dans le contexte d’accès à des données sensibles (administration de serveurs), de sécuriser l’accès contre des usurpations d’identités ou de credentials,
- Authentification déléguée : Actuellement, par simplicité, et parce qu’il s’agit du mode le mieux géré par Guacamole, l’authentification de ce PoC passe par des comptes inscrits dans une base de données. En pratique, les entreprises possèdent généralement une solution de gestion centralisée des comptes utilisateurs (Kerberos, LDAP, Active Directory...), qui permet une meilleure vision générale des identités à travers le périmètre. Guacamole supporte la délégation de l’authentification à ces services, ce qu’il conviendrait de mettre en place,
- Utilisation d’une machine dédiée à l’administration : Actuellement, dans un souci de portabilité du démonstrateur, celui-ci concentre l’ensemble des machines (bastion, identification, serveurs) en local. En pratique, on placerait le bastion sur un réseau d’administration cloisonné, dont l’accès serait réservé aux utilisateurs disposant des droits suffisants (solution du type *Single Packet Authorization*). 

## Sources et références

Techniques :

- [docker-bastion](https://github.com/lprat/docker-bastion)
- [windows docker](https://github.com/dockur/windows)
- [guacamole-docker-compose](https://github.com/boschkundendienst/guacamole-docker-compose)
- [lldap/example_configs/apacheguacamole.md](https://github.com/lldap/lldap/blob/main/example_configs/apacheguacamole.md)
- [Apache Guacamole: Session recordings and playback in-browser — version 2](https://theko2fi.medium.com/apache-guacamole-session-recordings-and-playback-in-browser-version-2-535c42ab46cf)

Concepts :

- “RECOMMANDATIONS RELATIVES À L’ADMINISTRATION SÉCURISÉE DES SYSTÈMES D’INFORMATION.” Accessed: Oct. 28, 2024. [Online]. Available: https://cyber.gouv.fr/sites/default/files/2018/04/anssi-guide-admin_securisee_si_v3-0.pdf 
- “Apache Guacamole Manual — Apache Guacamole Manual v1.5.5,” Apache.org, 2024. https://guacamole.apache.org/doc/gug/ (accessed Oct. 28, 2024). 
- K. Scarfone, W. Jansen, and M. Tracy, “Special Publication 800-123 Guide to General Server Security Recommendations of the National Institute of Standards and Technology,” Jul. 2008. Available: https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-123.pdf 
- “Système d’information,” Wikipédia. https://fr.wikipedia.org/wiki/Syst%C3%A8me_d%27information (accessed Oct. 28, 2024). 