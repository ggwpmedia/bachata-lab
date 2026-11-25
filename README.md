# Bachata Lab

Mobile-first Web-App für deine Bachata-Tutorials. Mit Login, damit Lernstand, Notizen und eigene Videos auf Handy, Tablet und Laptop gleich sind.

## Funktionen

- **Lernen** (Startseite): Fortschrittsring, „Weiter üben“ mit Ein-Tipp-Häkchen, „Als Nächstes lernen“, „Mal wieder auffrischen“ und Fortschritt pro Kategorie.
- **Bibliothek**: Suche, schnelle Status-Chips und ein Filter-Sheet mit Stil, Kategorie, Rolle, Quelle sowie Reglern für Level, Videolänge und Sicherheit.
- **Board**: Spalten Offen → Will ich lernen → Lerne ich gerade → Kann ich. Auf dem Handy wischst du zwischen den Spalten, am Desktop ziehst du die Karten.
- **Videos**: YouTube (auch Shorts und mit Startzeit) und Vimeo laufen direkt in der App, mit Spiegeln-Funktion. Instagram, TikTok und ezdance öffnen als Link. Eigene Videos landen privat in der Cloud, dort gibt es auch 0,5× und 0,75× Tempo.
- **Große Videos**: Die App schneidet auf Wunsch einen Ausschnitt (Von/Bis) und komprimiert im Browser auf 720p oder 480p, bis die Datei unter 48 MB passt. Das läuft in Echtzeit, die App muss dabei offen bleiben. Bei 720p passen ca. 2,5 Minuten in voller Qualität, mit reduzierter Bitrate bis ca. 17 Minuten. Für längere Videos: nicht gelistet auf YouTube hochladen und den Link einfügen.
- **Teilen**: Als App installiert, kannst du auf Android einen Link aus der YouTube-App direkt an Bachata Lab teilen.
- **Offline**: Der letzte Stand ist gespeichert, Änderungen werden nachgeladen, sobald wieder Netz da ist.

## Technik

- Eine einzige `index.html` ohne Build-Schritt. Gehostet über GitHub Pages (`.github/workflows/pages.yml`).
- Cloud: Supabase (Projekt HeimWerk). Tabelle `bachata_tutorials` und privater Bucket `bachata-videos`, beide per Row Level Security pro Konto getrennt. Schema: `supabase/migrations/`.
- Der Publishable Key in `index.html` ist zum Veröffentlichen gedacht. Ohne Login kommt niemand an Daten.

## Einrichtung

1. **Datenbank**: Inhalt von `supabase/migrations/20261125_bachata_lab_init.sql` im Supabase-Dashboard von HeimWerk unter *SQL Editor* ausführen.
2. **Login-Weiterleitung**: Supabase → *Authentication → URL Configuration → Redirect URLs* die App-Adresse hinzufügen, z. B. `https://ggwpmedia.github.io/bachata-lab/`.
3. **Hosting**: GitHub → *Settings → Pages → Source: GitHub Actions*. Bei privatem Repo braucht GitHub Pages einen bezahlten Plan, sonst das Repo öffentlich stellen (es enthält keine persönlichen Daten).

## Mehr Speicher

Der Supabase-Free-Plan erlaubt 50 MB pro Datei und 1 GB Speicher insgesamt (geteilt mit HeimWerk). Mit Supabase Pro (ca. 25 $/Monat) sind es 100 GB. Dann im Bucket `bachata-videos` das Dateilimit erhöhen und in `index.html` `MAX_UPLOAD` anpassen.
