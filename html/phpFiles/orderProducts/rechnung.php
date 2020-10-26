<?php
/*
    Copyright: phpEinfach.de Nils Reimers
    https://www.php-einfach.de/experte/php-codebeispiele/pdf-per-php-erstellen-pdf-rechnung/
*/
session_start();

require $_SERVER['DOCUMENT_ROOT'] . '/vendor/autoload.php';

if(!isset($_GET["rnr"])){
    ?>
        <h1>404: File not Found</h1>
    <?php
    exit;
}

$rnr = $_GET["rnr"];

include $_SERVER['DOCUMENT_ROOT']."/phpFiles/database/dbConnection.php";
mysqli_set_charset($conn, 'utf8');

/*
    Es wird überprüft, ob user Zugriffsrechte hat
*/
if(!isset($_SESSION["userID"])){
    ?>
        <h1>401: Unauthorized</h1>
    <?php
    exit;
}
$uid = $_SESSION["userID"];

$date;

$result = $conn->query("SELECT UID, DATE_FORMAT(Datum,'%d.%m.%Y') AS 'Datum' FROM bestellung WHERE BID = $rnr") or die ($conn->error);
if($row = $result->fetch_assoc()){
    if($uid!=$row["UID"]){
        ?>
            <h1>401: Unauthorized</h1>
        <?php
        exit;
    }else{
        $date = $row["Datum"];
    }
}

$rechnungs_nummer = $rnr;
$rechnungs_datum = $date;
$lieferdatum = date("d.m.Y");
$pdfAuthor = "PHP-Einfach.de";

$rechnungs_header = '
webshop
Stefan Schlaghuber
www.kajsdlkajklj';

/*
    Name und Addresse wird aus DB geholt 
*/
$result = $conn->query("SELECT Vorname, Nachname, Ort, PLZ, Strasse, HausNr FROM user WHERE UID = $uid");
$vorname="";
$nachname="";
$ort="";
$plz="";
$strasse="";
$hausNr="";

if($row = $result->fetch_assoc()){
    $vorname = $row["Vorname"];
    $nachname = $row["Nachname"];
    $ort = $row["Ort"];
    $plz = $row["PLZ"];
    $strasse = $row["Strasse"];
    $hausNr = $row["HausNr"];
}

$rechnungs_empfaenger = "$vorname $nachname
    $strasse $hausNr
    $plz $ort";

$rechnungs_footer = "Diese Rechnung stellt keine wirkliche Rechnung dar. Daher ist nichts zu begleichen.";
//$rechnungs_footer = "Wir bitten um eine Begleichung der Rechnung innerhalb von 14 Tagen nach Erhalt. Bitte Überweisen Sie den vollständigen Betrag an:";
/*
<b>Empfänger:</b> Meine Firma
<b>IBAN</b>: DE85 745165 45214 12364
<b>BIC</b>: C46X453AD";*/

/*
    Auflistung eurer verschiedenen Posten im Format [Produktbezeichnung, Menge, Einzelpreis]
    Posten werden aus DB geholt
*/

$rechnungs_posten = array();

$result = $conn->query("SELECT PName,Menge,PPreis FROM bestellposition WHERE BID = $rnr");

while($row = $result->fetch_assoc()){
    $rechnungs_posten[]=array($row["PName"],intval($row["Menge"]),doubleval($row["PPreis"]));
}
/*
array("Produkt 1", 1, 42.50),
array("Produkt 2", 5, 5.20),
array("Produkt 3", 3, 10.00));*/

//Höhe eurer Umsatzsteuer. 0.19 für 19% Umsatzsteuer
$umsatzsteuer = 0.0; 

$pdfName = "Rechnung_".$rechnungs_nummer.".pdf";


//////////////////////////// Inhalt des PDFs als HTML-Code \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


// Erstellung des HTML-Codes. Dieser HTML-Code definiert das Aussehen eures PDFs.
// tcpdf unterstützt recht viele HTML-Befehle. Die Nutzung von CSS ist allerdings
// stark eingeschränkt.

$html = '
<table cellpadding="5" cellspacing="0" style="width: 100%; ">
<tr>
<td>'.nl2br(trim($rechnungs_header)).'</td>
    <td style="text-align: right">
Rechnungsnummer: '.$rechnungs_nummer.'<br>
Rechnungsdatum: '.$rechnungs_datum.'<br>
Lieferdatum: '.$lieferdatum.'<br>
</td>
</tr>

<tr>
<td style="font-size:1.3em; font-weight: bold;">
<br><br>
Rechnung
<br>
</td>
</tr>


<tr>
<td colspan="2">'.nl2br(trim($rechnungs_empfaenger)).'</td>
</tr>
</table>
<br><br><br>

<table cellpadding="5" cellspacing="0" style="width: 100%;" border="0">
<tr style="background-color: #cccccc; padding:5px;">
<td style="padding:5px;"><b>Bezeichnung</b></td>
<td style="text-align: center;"><b>Menge</b></td>
<td style="text-align: center;"><b>Einzelpreis</b></td>
<td style="text-align: center;"><b>Preis</b></td>
</tr>';


$gesamtpreis = 0;

foreach($rechnungs_posten as $posten) {
    $menge = $posten[1];
    $einzelpreis = $posten[2];
    $preis = $menge*$einzelpreis;
    $gesamtpreis += $preis;
    $html .= '<tr>
                    <td>'.$posten[0].'</td>
    <td style="text-align: center;">'.$posten[1].'</td> 
    <td style="text-align: center;">'.number_format($posten[2], 2, ',', '').' Euro</td>	
                    <td style="text-align: center;">'.number_format($preis, 2, ',', '').' Euro</td>
                </tr>';
}
$html .="</table>";



$html .= '
<hr>
<table cellpadding="5" cellspacing="0" style="width: 100%;" border="0">';
if($umsatzsteuer > 0) {
$netto = $gesamtpreis / (1+$umsatzsteuer);
$umsatzsteuer_betrag = $gesamtpreis - $netto;

$html .= '
<tr>
<td colspan="3">Zwischensumme (Netto)</td>
<td style="text-align: center;">'.number_format($netto , 2, ',', '').' Euro</td>
</tr>
<tr>
<td colspan="3">Umsatzsteuer ('.intval($umsatzsteuer*100).'%)</td>
<td style="text-align: center;">'.number_format($umsatzsteuer_betrag, 2, ',', '').' Euro</td>
</tr>';
}

$html .='
            <tr>
                <td colspan="3"><b>Gesamtsumme: </b></td>
                <td style="text-align: center;"><b>'.number_format($gesamtpreis, 2, ',', '').' Euro</b></td>
            </tr> 
        </table>
<br><br><br>';

if($umsatzsteuer == 0) {
$html .= 'Nach § 19 Abs. 1 UStG wird keine Umsatzsteuer berechnet.<br><br>';
}

$html .= nl2br($rechnungs_footer);



//////////////////////////// Erzeugung eures PDF Dokuments \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

// Erstellung des PDF Dokuments
$pdf = new TCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, PDF_PAGE_FORMAT, true, 'UTF-8', false);

// Dokumenteninformationen
$pdf->SetCreator(PDF_CREATOR);
$pdf->SetAuthor($pdfAuthor);
$pdf->SetTitle('Rechnung '.$rechnungs_nummer);
$pdf->SetSubject('Rechnung '.$rechnungs_nummer);


// Header und Footer Informationen
$pdf->setHeaderFont(Array(PDF_FONT_NAME_MAIN, '', PDF_FONT_SIZE_MAIN));
$pdf->setFooterFont(Array(PDF_FONT_NAME_DATA, '', PDF_FONT_SIZE_DATA));

// Auswahl des Font
$pdf->SetDefaultMonospacedFont(PDF_FONT_MONOSPACED);

// Auswahl der MArgins
$pdf->SetMargins(PDF_MARGIN_LEFT, PDF_MARGIN_TOP, PDF_MARGIN_RIGHT);
$pdf->SetHeaderMargin(PDF_MARGIN_HEADER);
$pdf->SetFooterMargin(PDF_MARGIN_FOOTER);

// Automatisches Autobreak der Seiten
$pdf->SetAutoPageBreak(TRUE, PDF_MARGIN_BOTTOM);

// Image Scale 
$pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);

// Schriftart
//$pdf->SetFont('arial', '', 10);

// Neue Seite
$pdf->AddPage();

// Fügt den HTML Code in das PDF Dokument ein
$pdf->writeHTML($html, true, false, true, false, '');

//Ausgabe der PDF

//Variante 1: PDF direkt an den Benutzer senden:
$pdf->Output($pdfName, 'I');
 
//Variante 2: PDF im Verzeichnis abspeichern:
//$pdf->Output(dirname(__FILE__).'/'.$pdfName, 'F');
//echo 'PDF herunterladen: <a href="'.$pdfName.'">'.$pdfName.'</a>';
?>