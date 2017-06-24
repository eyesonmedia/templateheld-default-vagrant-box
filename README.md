# Vagrant Box für templateheld developer 

Vagrant LAMP setup mit PHP7.

## Was ist in der Box

- Ubuntu 14.04.3 LTS (Trusty Tahr)
- Apache
- Vim, Git, Curl, etc.
- PHP7 mit div. Extensions
- MySQL 5.6
- Node.js mit NPM
- Gulp (global installier)
- phpMyAdmin

## Anleitung

- clone diese Repo in Dein Projekt-Ordner
- gehe im Terminal in Dein Projekt-Ordner rein 
- führe ``vagrant up`` aus
- füge diese Zeilen in Deine hosts-Datei hinzu:
````
192.168.35.35 dev.templateheld.de
192.168.35.35 pma.templateheld.de
````
- Versuche ``http://dev.templateheld.de`` im Browser aufzurufen
- Versuche ``http://pma.templateheld.de`` im Browser aufzurufen für phpMyAdmin


## Wichtige Daten
DB User ist **root** und PW ist ebenfalls **root**