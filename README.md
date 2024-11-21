# Infrastructure avec Bastion

![Image_Couverture](./img/bastion_copilot.jpg)

## Sommaire

- [Infrastructure avec Bastion](#infrastructure-avec-bastion)
  - [Sommaire](#sommaire)
  - [Contexte](#contexte)
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
    - [Configuration générale du bastion](#configuration-générale-du-bastion)
    - [Authentification](#authentification)
  - [Informations utiles](#informations-utiles)
  - [Sources et références](#sources-et-références)

## Contexte
 

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

Installer les paquets nécessaires :

```bash
sudo apt install docker docker-compose-v2 openssl -y
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
cd Dev3
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

* Le nom DNS des machines dans un réseau docker est le nom du conteneur associé.
* Il est possible de dé-commenter les sections `ports` dans le fichier docker-compose à des fins de débogage.

## Sources et références

- [docker-bastion](https://github.com/lprat/docker-bastion)
- [windows docker](https://github.com/dockur/windows)
- [guacamole-docker-compose](https://github.com/boschkundendienst/guacamole-docker-compose)
- [lldap/example_configs/apacheguacamole.md](https://github.com/lldap/lldap/blob/main/example_configs/apacheguacamole.md)
- [Apache Guacamole: Session recordings and playback in-browser — version 2](https://theko2fi.medium.com/apache-guacamole-session-recordings-and-playback-in-browser-version-2-535c42ab46cf)