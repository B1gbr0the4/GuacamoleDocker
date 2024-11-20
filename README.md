<img src="https://upload.wikimedia.org/wikipedia/en/a/a1/Universit%C3%A9_du_Qu%C3%A9bec_%C3%A0_Chicoutimi_%28logo%29.png" width="15%" />

# 8INF857 - Sécurité informatique - Automne 2024 - G11
# Devoir 3 - Projet de session - Infrastructure avec Bastion

<img src="./img/bastion_copilot.jpg" width="20%" />

## Sommaire

  - [Pré-requis](#pré-requis)
    - [Installation (Ubuntu)](#installation-ubuntu)
    - [Installation (WSL)](#installation-wsl)
      - [Installer WSL](#installer-wsl)
      - [Installer docker](#installer-docker)
  - [Déploiement de l'architecture via Docker](#déploiement-de-larchitecture-via-docker)
    - [Première exécution](#première-exécution)
    - [Lancement et arrêt](#lancement-et-arrêt)
  - [Première authentification](#première-authentification)
  - [Configuration du bastion](#configuration-du-bastion)
  - [Infos utiles](#infos-utiles)
  - [Sources](#sources)

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

### Première authentification

**Changez le mot de passe à la première connexion !**

Les identifiants de l'interface web sont les suivants :

Nom d'utilisateur :   `guacadmin`
<br>Mot de passe :        `guacadmin`

### Configuration du bastion

Se référer à la [documentation de guacamole](https://guacamole.apache.org/doc/gug/) et aux divers tutoriels disponibles en ligne.

## Infos utiles

* Le nom DNS des machines dans un réseau docker est le nom du conteneur associé.
* Il est possible de décommenter les sections `ports` dans le fichier docker-compose à des fins de déboggage.

## Sources

- [docker-bastion](https://github.com/lprat/docker-bastion)
- [windows docker](https://github.com/dockur/windows)
- [guacamole-docker-compose](https://github.com/boschkundendienst/guacamole-docker-compose)
- [lldap/example_configs/apacheguacamole.md](https://github.com/lldap/lldap/blob/main/example_configs/apacheguacamole.md)
- [Apache Guacamole: Session recordings and playback in-browser — version 2](https://theko2fi.medium.com/apache-guacamole-session-recordings-and-playback-in-browser-version-2-535c42ab46cf)