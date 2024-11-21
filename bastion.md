# Sécurisation des SI

## Le concept de bastion

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

## Les bonnes pratiques

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

## Références

- “RECOMMANDATIONS RELATIVES À L’ADMINISTRATION SÉCURISÉE DES SYSTÈMES D’INFORMATION.” Accessed: Oct. 28, 2024. [Online]. Available: https://cyber.gouv.fr/sites/default/files/2018/04/anssi-guide-admin_securisee_si_v3-0.pdf 
- “Apache Guacamole Manual — Apache Guacamole Manual v1.5.5,” Apache.org, 2024. https://guacamole.apache.org/doc/gug/ (accessed Oct. 28, 2024). 
- K. Scarfone, W. Jansen, and M. Tracy, “Special Publication 800-123 Guide to General Server Security Recommendations of the National Institute of Standards and Technology,” Jul. 2008. Available: https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-123.pdf 
- “Système d’information,” Wikipédia. https://fr.wikipedia.org/wiki/Syst%C3%A8me_d%27information (accessed Oct. 28, 2024). 