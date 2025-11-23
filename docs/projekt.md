# Projekt
De projekt som just nu finns på servern är:

## nginx
Detta är den webserver som bestämmer exakt vad som ska ske med serverns datatrafik. I filen [nginx.conf](../services/nginx/nginx.conf) konfigureras detta, men en överblick är: 
- Om en domän står nämnd där skickas trafiken vidare som likt specificerat.
- Annars kollar den om filen som sökvägen motsvarar finns, då skickas den filen dit! (Till exempel att https://f.kth.se/ett/exempel.html gör att nginx svarar med filen under /f.kth.se/ett/exempel.html i Dockercontainern).
- I sista fall skickas det vidare till Wordpress motsvarande domänen.

Notera att om du vill att vissa filer ska finnas tillgängliga, till exempel en `index.html`-fil, är det bara att lägga till den under en mapp i [`/services/`](../services/), och skapa en mount bind i Compose-filen (under volumes vid nginx). Det finns redan många exempel där att utgå ifrån.

Det kan vara bra att läsa på lite grann kring hur nginx fungerar.

## Certbot
Vi använder Certbot för att få SSL certifikat (krävs för https). Den fungerar genom att skapa vissa filer under `.wellknown/acme-challenge` directory som nginx servar.

För att förnya certifikat som är nära att gå ut (inom 30 dagar), använd:
```
docker compose run --rm certbot renew
```
Eftersom denna inte försöker förnya innan det behövs kan de köras hur ofta som helst.

För att skapa ny certifikat för nya domäner använder man istället:
```
docker compose run --rm certbot certonly --webroot --webroot-path /var/www/certbot/ -d fysiksektionen.se -d www.fysiksektionen.se
```
(där `fysiksektionen.se` kan bytas ut med de olika domänerna). Notera att dessa domäner måste vara konfigurerade i nginx (med `.well-known`) likt de övriga. Eftersom denna service bara tillåter ett visst antal nya certifikat per domän bör man alltid pröva med `--dry-run`-flaggan först för att försäkra sig om att det funkar.

OBS! Certifikaten håller i 90 dagar från att de skapas. Om de går ut kommer en varning till alla som försöker gå in på hemsidan.

## Wordpresshemsidor
Sektionen underhåller vid skrivande tillfälle 3 stycken Wordpress-sidor: f.kth.se, fysikalen.se, f.kth.se/fadderiet (även ffusion.se, men denna är numera avvecklad och omdirigerar istället). Dessa används för att enkelt kommunicera med omvärlden, och innehållshanteringen av dessa är utspridd på sektionen, där f.kth.se hittills faller på Webmaster.

Sidornas Wordpressversion behöver uppdateras ibland, så gör gärna det! Det sker genom att först uppdatera via adminkonsolen, och sedan ändra versionen i den centrala Docker Compose-filen. Kom ihåg att ta en backup innan!

Notera att det inte finns ett GitHub repo för dessa, utom all information är i backups:en av historiska skäl.

## Kons Count
[Länk till GitHub](https://github.com/Fysiksektionen/kons_count)

Kons Count är en hemsida (https://f.kth.se/counter samt https://f.kth.se/counter/admin) som är till för att räkna antalet person i Konsulatet under pubar.

Den har två delar: en frontend och backend. Frontend:en är ett React-projekt och byggs på GitHub så att filerna sedan kan levereras med hjälp av nginx. För att underlänkar (som counter/admin) ska fungera behövs också att nginx är konfigurerad att skicka all trafik som börjar med counter till dess `index.html`-sida.

Backend:en är en liten server i en Docker container som också byggs på GitHub. Notera att servern har en konfigurationsfil (`.env`) som inte är på GitHub och en autentiseringsfil (`service_account_auth_file.json`) som kommer från Google.

Vilka som har tillgång till admingränssnittet specificeras inte i Fysikmotorn, utan sköts av Google-gruppen `konscount`.

## Nämndkompassen
[Länk till GitHub](https://github.com/Fysiksektionen/namndkompassen)

Nämndkompassen är en kul liten hemsida där man efter att ha svarat på några frågor får veta vilken nämnd man borde gå med i. Detta projekt är enkla html-sidor och en release görs därför manuellt och laddas ner med nedladdningsskriptet. 

Notera att ingen kod exekveras lokalt, utom allt jobb sköts av nginx. För att detta ska ske måste dock nginx ha tillgång till filerna via mount binds definierade i Docker Compose-filen.

## Signature
[Länk till GitHub](https://github.com/Fysiksektionen/signature-website)

En liten hemsida där man kan skapa funktionärssignaturer för mailen. Den består bara av enkla HTML- och javascriptsidor, och releasen görs manuellt. Notera att den skulle må bra av lite CSS.

Notera att ingen kod exekveras lokalt, utom allt jobb sköts av nginx. För att detta ska ske måste dock nginx ha tillgång till filerna via mount binds definierade i Docker Compose-filen.

## Arcade
[GitHub (hemsidan)](https://github.com/Fysiksektionen/arcade-home) & [GitHub (källkod till några spel)](https://github.com/Fysiksektionen/Arcade-website)

Arcade är en samling spel som har gjorts på sektionen med åren. Notera att vår installation här har två delar.

Det finns en homepage som är skriven i React och byggs på GitHub och sedan finns det några spel som är skrivna i html och Javascript och release:as manuellt. Ingen av dessa kräver att kod körs lokalt utan behöver bara att filerna levereras, vilket sköts av nginx.

Båda installeras samtidigt med nedladdningsskriptet för Arcade.

## Misc
Det är inte ett projekt, utom en samling filer som ska finnas tillgängliga ändå. 

Just nu innehåller det en fil som behövde finnas tillgänglig för KTH:s autentiseringtjänst. Det är oklart om den fortfarande behöver vara tillgänglig, men får vara det tills vidare (men ta gärna bort typ 2026). Det är även ett bra exempel om hur enskilda filer kan finnas tillgängliga på servern. Notera att den är tillagd under volumes i Docker Compose-filen.

## Cyberföhs
**Grupp**: `cyberfohs`

[Länk till GitHub](https://github.com/Fysiksektionen/cyberfohs-appen)

Cyberföhs-appen är en app som används under cyberföhsning under mottagningen. Appens front byggs för tillfället inte på GitHub, men backenden gör det!

Notera att den behöver en databas (som man kan skapa med `./init.sh` kommandot om man har en terminal i containern (`docker exec -it cyberfohs bash`)), samt att den behöver static files (som genereras med `./manage.py collectstatic` också inne i containern).

## BitTan
**Grupp**: `bittan`

[Länk till GitHub](https://github.com/Fysiksektionen/bittan)

BitTan är ett system som används för att sälja biljetter.
För tillfället finns följande delprojekt:
- `bittan-fysikalen`: Försäljning av biljetter till Fysikalen
- `bittan-marke`: Försäljning av BitTan-märket

Varje delprojekt har en backend i Django samt en frontend bestående av statiska filer.

## fnkth.se
**Grupp**: `fnkthse`

[Länk till GitHub](https://github.com/Fysiksektionens-Naringslivsnamnd/hemsida)

En hemsida för FN som de själva sköter koden för men som host:as på Fysikmotorn. Projektet är i skrivande stund inte klart, men består för tillfället av en Flask-server samt några statiska filer.

## Valkompassen

[Länk till GitHub](https://github.com/Fysiksektionen/Valkompass-2025)

En liten tjänst för att låta sektionens medlemmar se vilka valkandidater de gillar mest. Projektet består av en Flask-server.
