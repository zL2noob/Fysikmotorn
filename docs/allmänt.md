# Allmänt
## Struktur
Servern är strukturerad runt en Docker Compose-fil [`compose.yaml`](../compose.yaml). Denna innehåller information för Docker om hur man kör alla de olika projekten och hur de ska sättas ihop. I och med att det är just Docker betyder det också att all kod körs på samma sätt oavsett dator.

För att bygga dessa Dockercontainrar används GitHub Actions i varje projekts GitHubsida. De bygger en container som enkelt kan laddas ner av Docker Compose-filen. Exakt vilken version håller dessutom [`.env`-filen](../.env) koll på!

I Docker körs alla projekten, men också en nginx-server. Denna ansvarar för att ta emot all datatrafik som servern får och skicka vidare den till rätt projekt. DESSUTOM levererar den filer. Alla filer den kan se (titta i [Docker Compose-filen](../compose.yaml), under `nginx: [...] volumes:`), kan nås genom att gå in på `https://domän.se/väg/till/filen`, och nginx ser till att leverera den! De små hemsideprojekten behöver till exempel ingen kod som körs på servern utom bara att HTML- och Javascriptfilerna levereras vilket nginx tar hand om. Om du inte är bekant med detta, sök gärna upp om "static files". Notera också att nginx här är konfigurerad att allt som den inte vet var det ska skickas vidare till Wordpress.

Likt hur Dockercontainrarna byggs med GitHub Actions byggs även static files till många projekt med GitHub Actions. Dessa blir en release som sedan kan laddas ner med hjälp av nerladdningsskripten i [`/scripts/`](../scripts/). Underhåll dessa! Det gör att man inte måste undra vilken version av vardera paket som används för att bygga ett projekt.

Tillsammans gör detta att alla projekt hanteras på väldigt liknande sätt, och att uppstart, ändringar och flyttar knappt skiljer sig mellan projekt. Förhoppningen är att det underlättar Webmasterns arbetsbörda och gör det lättare att bevara gamla projekt.

Filstrukturen på servern är för nuvarande:
- `/fysikmotorn`: Innehåller detta repository.
- `/fysikmotorn/services`: Innehåller alla projekten.

## Säkerhet
Det finns vissa filer på servern som inte bör kunna ses av andra processer eller användare eftersom de är känsliga. I [protect-skriptet](../scripts/protect.sh), samt i backup-skripten sköts att dessa inte kan ses av övriga användare, men de måste uppdateras om fler tillkommer.

En lista av dessa hemligheter är:
- SSL-Certifikat - Används för att verifiera för webbläsare att vi verkligen är f.kth.se. De skulle annars kunna användas för att låtsas vara f.kth.se och lura folk på lösenord.
- `.env`-filer i Wordpress - Innehåller databaslösenord och skulle kunna användas för att läsa eller ändra data på sektionens hemsidor (om man har tillgång till servern, men ej rootprivilegier).
- Mariadb-mappar i Wordpress - Innehåller själva databaserna och skulle kunna användas för att läsa hemlig data på sektionens hemsidor.
- `service_account_auth_file.json` i kons-count - Innehåller API-nycklar med begränsad tillgång till vårt Google Workspace.

Var försiktig med dessa filer och generellt kring filer som innehåller autentisering med mer. Eftersom få har tillgång till servern är det ingen katastrof om dessa skulle synas, men det är bra att undvika.

Om nya hemliga filer tillkommer, till exempel Swishkoder, se till att backup- och protect-skriptet uppdateras för att reflektera detta.

## Användare
Användare på servern är personliga och namngivna efter KTH-id:n. Ett konto skapas med hjälp av `adduser`-kommandot. Ägaren får tillgång till deras konto genom att deras publika SSH-nyckel läggs till under `~/.ssh/authorized_keys`-mappen.

Det finns inget helt standardiserat sätt att ge folk tillgång till ett visst projekt. Om ett projekt ska ha en delad mapp kan man använda [share_dir-skriptet](../scripts/share_dir.sh) för att dela en folder med en grupp.

Det finns oftast ingen anledning att ta bort en person från ett projekt de en gång haft tillgång till, utom de kan oftast fortsätta ha tillgång (med undantag för viktiga personuppgifter).

Om användaren är Webmaster ska de även läggas till i `sudo`-gruppen vilket ger dem tillgång till `sudo` (super user do).

## Filbehörigheter
För att filer i en viss delad mapp ska gå att ändra för alla användare i en viss grupp är det viktigt att `umask` är 002, att stickybit är satt, och att mappen har motsvarande grupp som sin.

`umask` verkar vara 002 på Ubuntu som standard och skriptet [share_dir.sh](../scripts/share_dir.sh) kan användas för resterande!

## Program på servern
OBS! På Ubuntu verkar snap inte fungera på grund av att den inte tillåter root enkelt, och apt-get har för gamla versioner. På vardera programs sida finns dock lämpliga installations instruktioner.

### Docker
Docker är ett program för att isolera program och ge en konsekvent miljö för dem att exekveras i. Docker är också betydligt mer resurs effektiv än en virtual machine.

Som nämnts används Docker för att köra de flesta program på servern. Det behöver alltså vara nedladdat på servern.

Om du inte redan är bekant med Docker rekommenderar jag att söka på om det, samt Docker Compose!

### rclone
rclone är ett verktyg för att kopiera till och från olika fjärrfilsystem.

På Fysikmotorn används det för att sköta backups, då dessa blir uppladdade på sektionens Google Drive.

Det kräver ett projekt, vilket ägs av "Fysikmotorn" kontot (lösenord finns i Webmasters nyckelring). Själva filerna läggs in i den delade enheten "Backup Fysikmotorn", som Webmaster också har tillgång till.

För att rclone ska fungera på en enhet måste de konfigureras, följ då guiderna:
https://rclone.org/drive/
https://rclone.org/drive/#making-your-own-client-id
och lägg till den delade driven ("Team Drive") som heter "Backup Fysikmotorn" under namnet "Drive".

Kontot och projektet finns som sagt redan, men koder kan behövas för en lokal installation.

### Tar
Tar är ett program som är förinstallerat på de flesta Linux datorer. Med det kan man skapa arkiv av filer, vilket används av både nedladdningsskript och backupskript vid ned och uppladdning.

### Git
För att projektet ska fungera behövs Git, både för att ladda ner det :D, men också för att 
det används av Githubs command line interface.

Notera att det används en Deploy Key för att ge servern tillgång till repot.

Om du gör ändringar på servern, så uppdatera Fysikmotor repot också!

Notera att .gitignore används för att inte fylla repot med de olika projekten eftersom dessa finns och uppdateras på separata Github sidor.

### Github
Github är tjänsten vi använder för att hosta våra Gitrepon. Där i används bland annat Github Actions för att bygga projekten som behöver byggas. Fortsätt med detta!

Dessutom används Github CLI för att kunna ladda ner releases enkelt. De används i nedladdningsskripten. För att konfigurera detta, kör `gh auth login`. Vi använder Github-kontot kopplat till fysikmotorn@f.kth.se för att kunna logga in i Github CLI. Om du kör lokalt går det bra att använda ditt privata Github-konto istället, så länge det är med i Github-organisationen Fysiksektionen.

## Motivering
När Fysikmotorn först införskaffades lades olika projekt och kodsnuttar dit på de sätt som var mest naturliga i stunden. Det här fungerar till viss grad, men när projekt blir gamla, personerna som skrev dem lämnat, och någonting går sönder kan det vara ett massivt arbete att få upp det igen. Vissa försök gjordes att förbättra situationen och bland annat blev Dockeriserade projekt standard. Mycket gammalt var dock kvar och saker hängde inte riktigt ihop.

Därav det här projektet. Det här repot innehåller allt som behövs för den nya Fysikmotorn. Alla projekt körs i Dockercontainers, alla filer och containrar byggs på GitHub, och både nedladdning av projekt och backups är mer eller mindre automatiserat! Det har varit ett rejält arbete att få ihop detta, men Webmaster 2024 ansåg det vara dags för en renovering.

För att det här projektet ska fungera och att saker inte ska gå tillbaka till kaos krävs det att ni tar hand om det. Om ni lägger till ett projekt, uppdaterar något, eller på annat sätt ändrar, var god och uppdatera allt. Om små saker slutar fungera blir det en pina för de som kommer efter senare och då slutar det uppehållas. Det betyder dock inte att ändringar är dåliga; saker får gärna ändras på så länge man har förståelse för hur projektet hänger ihop. Även delar som backupprocessen och nerladdning har definitivt förbättringspotential!

## Kontakt
Om du skulle behöva assistans med något kan man alltid börja med att fråga Webmaster innan dig. Om det däremot skulle uppstå ett problem eller en fråga som handlar om själva serverarkitekturen går det alltid bra att kontakta Webmaster 2024 vars privata mejl finns i Webmasters testamente.
