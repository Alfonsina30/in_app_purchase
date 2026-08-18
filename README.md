# app_pubblicita_monetizazione

Tutti gli annunci dell app devono essere caricati quando si apre l'app:
void main() async {
  // 1. Assicurati che i plugin siano pronti
  WidgetsFlutterBinding.ensureInitialized();

  await MobileAds.instance.initialize();

  AppPubblicitaManager.loadBannerAd();
  AppPubblicitaManager.loadInterstitial();
  AppPubblicitaManager.loadAnnuncioPremiato();

  runApp(const MyApp());
}

//Nel AndroidManifest.xml

<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application
        android:label="app_pubblicita_monetizazione"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-5127968785265249~4529324099"/>

        <activity
        

*****PUBBLICITA***
## ANNUNCIO PREMIATO - reward
- controlla se l'annuncio e pronto
- controlla quanti annunci ha visto l'utente se ha raggiunto il limite di visualizzazione al mese esce un showDialog
- Se la annuncio e pronto lo fa vedere
- ogni volta che l'utente guarda un'annuncio viene salvato nello storage
- il dispose di questo annuncio viene chiamato nel momento in qui l'ultente preme x per uscire del annuncio 

## ANNUNCIO BANNER 
- l'annuncio viene mostrato soltando quando e pronto
- il banner e inserito in un dispose perche se deve liberare memoria
 
## ANNUNCIO INTERTITIAL
- controllo per sapere si sono passati 3 minuti dopo la visualizzazione dell'ultimo annuncio
- e utilizato quando se salva un appuntamento
- il dispose di questo annuncio viene chiamato nel momento in qui l'ultente preme x per uscire del annuncio 


*****MONETIZZAZIONE***
- Controllo pagamento, in collegamento con Google sapiamo se l'utente ha pagato, chiesto un rimbolso o cancellato l'abbonamento.

- Ogni volta che l'app si apre andiamo a controllare Flutter Secure Storage per sapere lo status dell'utente. Inolte lo Stream di Google ci darà gli aggiornamenti in caso de che l'utente ha cambiato lo status del pago mente la nostra app era chiusa, così abbiamo sempre Flutter Secure Storage aggiornato. 

- Gli stessi id product che abbiamo in ControlloPagamento sono quelli dobbiamo inserire nella playConsole.

- La funzione "restoreUserPurchases()" è utilizzata per sapere lo status del pagamento, però deve essere chiamata per l'utente perchè quando verrà chiamata attivera lo stream, e farà vedere un loading di google, per una migliore UX deve essere chiamata dal'utente. 

