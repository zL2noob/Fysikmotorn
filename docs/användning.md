# Användning

## Att starta
För att starta alla tjänster, navigera till mappen som innehåller [`compose.yaml`](../compose.yaml) och kör
```
docker compose up -d
```
Det fungerar eftersom all kod som ska köras kontinuerligt körs i Dockercontainrar konfigurerade i Docker Compose-filen! För att stänga ner, kör istället
```
docker compose down
```

## Tillgång till projekt
Vissa projektgrupper får tillgång till att köra vissa kommandon som annars kräver adminprivilegier, vanligtvis att öppna en shell i motsvarande docker-container.
Så här ges tillgång:
- Se till att det finns en grupp, `samplegroup`, och att rätt användare är tillagda i gruppen.
- I filen `/etc/sudoers`, skriv vilka kommandon som gruppen får köra. Till exempel:
```
%samplegroup ALL=(ALL) NOPASSWD: samplecommand
%samplegroup ALL=(ALL) NOPASSWD: /usr/bin/docker exec -it samplecontainer sh
```
- Lägg till skripts i mappen `/fysikmotorn/user-scripts/samplegroup/` motsvarande kommandona ovan.

## Backups
För att misstag ska kunna rättas till, och att saker inte ska försvinna, har servern även utrustats med backupskripts! Dessa förlitar sig på programmet `rclone` för att ladda upp projektens data (men inte hela projektet i och med att de finns på GitHub). Det kan sedan laddas ner igen lätt.

För att köra backupskript måste [`/scripts/`](../scripts/) sättas som working directory och körningen måste oftas ske som root user.
- För att **skapa en backup** för ett projekt, kör
```
./backup_<projektnamn> u
```
- För att **ladda ner en backup** för ett projekt, dvs. radera nuvarande filer och återställa dem enligt den senaste backupen, kör
```
./backup_<projektnamn> d
```
Argumenten `u` och `d` står för "upload" respektive "download".

Dessa scripts är anpassade efter varje projekt, och måste anpassas för varje nytt.

Det är viktigt att dessa fungerar för att inte data ska försvinna och för att man ska våga göra saker på Fysikmotorn. Om de fungerar slipper man hantera servern som en porslinstaty och kan istället experimentera och ha kul!

OBS! Det krävs lite extra lagring för att genomföra en backup, 2GB är definitivt tillräckligt!

OBS! För att underlätta felsökande efter stora ändringar, laddas även `.env`, `nginx.conf`, och Docker Compose-filen upp. Kolla i dessa ifall något gått sönder och du tror att de har omkonfigurerats (de laddas dock inte ner i vanliga fall eftersom de påverkar mycket annat också).

OBS! Notera att backupen inte följer symlinks om inte det är själva argumentet.

## Nedladdningsskript
För att ladda ner projekten finns det nedladdningsskript i [scripts](../scripts/)-mappen. Dessa är anpassade efter varje projekt, och för ett nytt projekt bör man kopiera och anpassa detta.

De kräver att det finns en Github release för projektet som antingen innehåller alla byggda filer (om så är relevant), eller källkoden (om bara den krävs). Kolla på de redan existerande projekten efter exempel.

OBS! Skripten måste köras med scripts som working directory, och det krävs oftast sudo.
