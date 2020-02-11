//
//  ViewController.swift
//  FindGlutenFree
//
//  Created by Admin on 2016-09-14.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

//Globala Variabler
var pickedResturantId = ""
var pickedResturantName = ""
var pickedResturantLon = ""
var pickedResturantLat = ""

var loadingData:Bool = false



var mapCenter:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 59.327516, longitude: 17.701775)  //Skapar och sätter kordinater initialt
var span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)  //skapar och Sätter initial ZoomLevel på kartan och håller reda på aktuell span
var region: MKCoordinateRegion = MKCoordinateRegionMake(mapCenter, span) //Skapar och sätter MAP Region initialt och håller reda på aktuellt region

var currentSpan: MKCoordinateSpan = span

//var addLocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 59.327488, longitude: 17.702440)

var addCoordinate:CLLocation = CLLocation(latitude: 59.327516, longitude: 17.701775)

typealias FinishedDownload = () -> ()


class ResturantPointAnnotation: MKPointAnnotation {  //Skapar en custom variant av Annoteringar med fler variabler
    
    var restId: String
    var restType: String
    
    init(restuId: String, restuType: String){
        self.restId = restuId
        self.restType = restuType
        
        super.init()
    }
}


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var map: MKMapView!
    
    @IBAction func gpsButton(sender: AnyObject) {
        
        let reLatitude: CLLocationDegrees = (locationManager.location?.coordinate.latitude)! //59.327488
        let reLongitude: CLLocationDegrees = (locationManager.location?.coordinate.longitude)! //17.702440 
        
        mapCenter = CLLocationCoordinate2D(latitude: reLatitude, longitude: reLongitude)
        
        region = MKCoordinateRegionMake(mapCenter, span)
        
       self.map.setRegion(region, animated: false)
    }
    
    
    @IBAction func AddResturantButton(sender: AnyObject) {
        
        let addLat: CLLocationDegrees = (locationManager.location?.coordinate.latitude)!
        let addLon: CLLocationDegrees = (locationManager.location?.coordinate.longitude)!
        
        addCoordinate = CLLocation(latitude:  addLat, longitude: addLon) //CLLocation(latitude: 59.327488, longitude: 17.702440)
        //addLocation = (locationManager.location?.coordinate)!
        
        performSegueWithIdentifier("AddResturantSeque", sender: nil)
        
    }
    
    
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Skapar åtkomst till GPS
        
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        //Läser ut användarens position
        
        var latitude:CLLocationDegrees
        
        var longitude:CLLocationDegrees
        
        //Sätter start kordinater under test enligt Global Deklarationen, men ska använda användarens position vid prod
        latitude = mapCenter.latitude //(locationManager.location?.coordinate.latitude)!
        longitude = mapCenter.longitude //(locationManager.location?.coordinate.longitude)!
        
        mapCenter = CLLocationCoordinate2D(latitude: latitude, longitude: longitude) //Sätter MapCenter för kartan
        
        region = MKCoordinateRegionMake(mapCenter, span) //Sätter start Region
        
        //sätter kartan till att peka på användarens kordinater
        
        //self.map.setRegion(region, animated: true)
        
        
        
        //Longpress on map for add resturant
        
        var uilpgr = UILongPressGestureRecognizer(target: self, action: "longPressAction:")

        uilpgr.minimumPressDuration = 2.0
        
        map.addGestureRecognizer(uilpgr)
        
    }
    
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        //print("View did Appear")
        //self.getJsonData()
        //self.addAnnotationToMap()
        self.getJsonData { () -> () in
            
            self.addAnnotationToMap()
            
      }
        //self.addAnnotationToMap()
        //print("Viewdidappear end")
     
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //print("view will appear")
       // self.getJsonData()
        
    }
    
    func longPressAction(gestureRecongnizer:UIGestureRecognizer){  //Funktionen som körs när man gör n longpress på kartan
        
        if gestureRecongnizer.state == UIGestureRecognizerState.Began {  //kollar så att man bara får en longpress genom att titta på första eventet
            
            var touchPoint = gestureRecongnizer.locationInView(self.map)
            
            var touchCoordinate = self.map.convertPoint(touchPoint, toCoordinateFromView: self.map)
            
            addCoordinate = CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
            
            performSegueWithIdentifier("AddResturantSeque", sender: nil)
                        
        }
        
        
        
    }
    
    func getJsonData(completed: FinishedDownload) {
    //func getJsonData() {
        //Hämta närmaste resturanger och lägger dem i coreData
        
        
        loadingData = true
        
        
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let coreDataContext: NSManagedObjectContext = appDel.managedObjectContext
        
        //Hämtar Data från JWS
        
        var zoomLatitude: String = String(currentSpan.latitudeDelta) //Skapar zoomnivå för Latitude som skickas till JWV
        
        var zoomLongitude: String = String(currentSpan.longitudeDelta) //skapar zoomNivå för longitude som skickas till JWS
        
        let url = NSURL(string: "http://www.spelahemma.se/fetchresturants?UN=FGFU&LO=ataGluttfritt&lat=\(mapCenter.latitude)&lon=\(mapCenter.longitude)&latzoom=\(zoomLatitude)&lonzoom=\(zoomLongitude)")!
        
        print(url)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url) { (jsondata, response, error) -> Void in  //Hämtar sidan som skapades för Task
            
            if error != nil {
                
                print(error)
                
            } else {
                
                
                if let data = jsondata {
                    
                    let jsonEncoded = NSString(data: data, encoding: NSUTF8StringEncoding)
                        print("avkodad data: \(jsonEncoded)")
    
                    //Kontrollerar inlogning i Json Webservice
                    if jsonEncoded == "Login Failed" {
                        let alert = UIAlertController(title: "Login", message: "Login Failed! \n No new resturants where collected! \n Only cached Resturants will be shown!", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    } else {
                    //print("Parsing Data")
                    //Parsar Json data som kommer från Web API
                    
                    do  { let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                        
                        print("kolla om det kom json data, Antal poster: \(jsonResult.count)")
                        
                        if jsonResult.count > 0 {   //Kontrollerar att det kommit data
                            
                            if let resturants = jsonResult["resturants"] as? NSArray {   //Skapar en Array av Items (är ett "träd" i Jason datat
                                
                                //Läser upp sparad data från Core-mamagedObjects
                                
                                let request = NSFetchRequest(entityName: "Resturants")  //Hämta data från "core data tabellen" Resturants
                                
                                request.returnsObjectsAsFaults = false
                                
                                do { let results = try coreDataContext.executeFetchRequest(request) //start fetch request
                                    
                                    print("Antal coredata poster före tömning: \(results.count)")
                                    if results.count >  0 {  //Kollar att det fanns data
                                        
                                        for result in results {  // läser igenom alla poster
                                            
                                            coreDataContext.deleteObject(result as! NSManagedObject)  //Rensar data  som är sparat för att inte få dubletter
                                            print("Antal CoreData poster efter tömning: \(results.count)")
                                            
                                            do { try coreDataContext.save() } catch {
                                                print("Kunde inte tömma Core Data")
                                            }  //Sparar ner den Tömda datan i Core igen
                                        }
                                        
                                    }
                                    
                                } catch {}  //slut Fetch Request
                                
                                for item in resturants {  //Läser igenom alla items som vi hämtat
                                    
                                    if let resturantName = item["resturantName"] as? String { //Kollar att det går att göra en string av json data
                                        
                                        if let resturantID = item["resturantID"] as? String{
                                            
                                            if let resturantUrl = item["resturantUrl"] as? String {
                                                
                                                if let resturantDescription = item["resturantDescription"] as? String {
                                                    
                                                    if let priceRange = item["priceRange"] as? String {
                                                        
                                                        if let glutenFreeFeatures = item["glutenFreeFeatures"] as? String {
                                                            
                                                            if let resturantAdress = item["resturantAdress"] as? String {
                                                                
                                                                if let resturantZip = item["resturantZip"] as? String {
                                                                    
                                                                    if let resturantCity = item["resturantCity"] as? String {
                                                                        
                                                                        if let resturantPhone = item["resturantPhone"] as? String {
                                                                            
                                                                            if let resturantEmail = item["resturantEmail"] as? String {
                                                                                
                                                                                if let resturantFacebook = item["resturantFacebook"] as? String {
                                                                                    
                                                                                    if let resturantTwitter = item["resturantTwitter"] as? String {
                                                                                        
                                                                                        if let resturantGooglePlus = item["resturantGooglePlus"] as? String {
                                                                                            
                                                                                            if let resturantLonComma = item["resturantLon"] as? String {
                                                                                                let resturantLon = resturantLonComma.stringByReplacingOccurrencesOfString(",", withString: ".")
                                                                                                
                                                                                                if let resturantLatComma = item["resturantLat"] as? String {
                                                                                                    let resturantLat = resturantLatComma.stringByReplacingOccurrencesOfString(",", withString: ".")
                                                                                                    
                                                                                                    if let resturantType = item["resturantType"] as? String {
                                                                                                        
                                                                                                        let newResturant: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Resturants", inManagedObjectContext: coreDataContext)  //Skriver ner data till Core
                                                                                                        
                                                                                                        newResturant.setValue(resturantName, forKey: "resturantName")
                                                                                                        newResturant.setValue(resturantID, forKey: "resturantId")
                                                                                                        newResturant.setValue(resturantUrl, forKey: "resturantUrl")
                                                                                                        newResturant.setValue(resturantDescription, forKey: "resturantDescription")
                                                                                                        newResturant.setValue(priceRange, forKey: "priceRange")
                                                                                                        newResturant.setValue(glutenFreeFeatures, forKey: "glutenFreeFeatures")
                                                                                                        newResturant.setValue(resturantAdress, forKey: "resturantAdress")
                                                                                                        newResturant.setValue(resturantZip, forKey: "resturantZip")
                                                                                                        newResturant.setValue(resturantCity, forKey: "resturantCity")
                                                                                                        newResturant.setValue(resturantPhone, forKey: "resturantPhone")
                                                                                                        newResturant.setValue(resturantEmail, forKey: "resturantEmail")
                                                                                                        newResturant.setValue(resturantFacebook, forKey: "resturantFacebook")
                                                                                                        newResturant.setValue(resturantTwitter, forKey: "resturantTwitter")
                                                                                                        newResturant.setValue(resturantGooglePlus, forKey: "resturantGooglePlus")
                                                                                                        newResturant.setValue(resturantLon, forKey: "resturantLon")
                                                                                                        newResturant.setValue(resturantLat, forKey: "resturantLat")
                                                                                                        newResturant.setValue(resturantType, forKey: "resturantType")
                                                                                                        
                                                                                                        do {
                                                                                                            try coreDataContext.save()  //Spara coreData
                                                                                                            
                                                                                                        }catch{
                                                                                                        
                                                                                                            print("Error on CoreData Save")
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                    } catch {}
                    //Slut json parse
                    }
                }
                
            } // --------
            
            completed() //Väntar på att Closure ska köras färdigt innan den fortsätter, dvs att den sparat ner data till Core Datat innan den forsätter med att skapa annotations
            loadingData = false
        } //Task ends
        
        task.resume()  //Utför task igen
    }
    
    func addAnnotationToMap() {
        
        let allAnnotations = self.map.annotations
        
        self.map.removeAnnotations(allAnnotations)  // tar bort alla befintliga annotatios innan man lägger dit alla igen
        
        let request = NSFetchRequest(entityName: "Resturants")  //Skapa en request mot "databasen" Resturants lokalt på telefonen
     
        request.returnsObjectsAsFaults = false  //Anger att det är datan i posterna vi vill ha tillbaka
     
        let appDel1: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
     
        let coreDataContext1: NSManagedObjectContext = appDel1.managedObjectContext
        
        print("Fetch Data")
        
        do {    //Test Fetch command
            let results = try coreDataContext1.executeFetchRequest(request)
     
            print("Resturants in Core Data: \(results.count)")
            if results.count > 0 {
     
                for result in results as! [NSManagedObject] { //Loopar igenom alla poster i CoreData som lästs upp
                    
                    if let resturantLatitude = result.valueForKey("resturantLat") as? String {
                        
                        if let resturantLongitude = result.valueForKey("resturantLon") as? String {
                            
                            if let resturantName = result.valueForKey("resturantName") as? String {
                                
                                if let resturantDescription = result.valueForKey("resturantDescription") as? String {
                                    
                                    if let resturantId = result.valueForKey("resturantId") as? String {
                                    
                                        if let resturantType = result.valueForKey("resturantType") as? String {
                                        
                                        //skapar annotation på kartan
                                    
                                            if ((resturantLatitude != "") && (resturantLongitude != "")) {
                                                
                                                //let annotation = ResturantPointAnnotation()
                                                
                                                let annotation = ResturantPointAnnotation(restuId: resturantId, restuType: resturantType)
                                                
                                                //let annotation = MKPointAnnotation()
                                                
                                                let annotationLat:CLLocationDegrees = Double(resturantLatitude)!
                                                
                                                let annotationLon:CLLocationDegrees = Double(resturantLongitude)!
                                                
                                                let annotationLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(annotationLat, annotationLon)
                                                
                                                //Skapar själva annotation
                                                
                                                annotation.coordinate = annotationLocation
                                                
                                                annotation.title = resturantName
                                                
                                                annotation.subtitle = resturantDescription
                                                
                                                annotation.restId = resturantId
                                                
                                                print(resturantName)
                                                
                                                self.map.addAnnotation(annotation) //sätter ut själva annotation på kartan
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }catch { }
        //Slut fetch Command
        
       self.map.setRegion(region, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "AddResturantSeque" {
        
            var addRestVC: AddResturantViewController = segue.destinationViewController as! AddResturantViewController
           
            addRestVC.recivedLatitude = (addCoordinate.coordinate.latitude)
            addRestVC.recivedLongitude = (addCoordinate.coordinate.longitude)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {  //skapar customized Annotation
        // Don't want to show a custom image if the annotation is the user's location.
        guard !annotation.isKindOfClass(MKUserLocation) else {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
            annotationView = av
        }
        
        if let annotationView = annotationView {
            // Configure your annotation view here
            
            annotationView.canShowCallout = true
            
            if let pinannotation = annotation as? ResturantPointAnnotation {
                
                //print("PinRestID: \(pinannotation.restId)")
                //print("Rest Type: \(pinannotation.restType)")
                
                switch pinannotation.restType {
                    case "1":
                        annotationView.image = UIImage(named: "caffe.png")
                    
                    case "2":
                        annotationView.image = UIImage(named: "pub.png")
                        
                    case "3":
                        annotationView.image = UIImage(named: "orange_marker_32p.png")
                        
                    default:
                        annotationView.image = UIImage(named: "resturant.png")
                }
            }
            
            //annotationView.image = UIImage(named: "pin-map-location-19-32.png")
        }
        
        return annotationView
    }
    
    //Hanterer att man har trycvkt på i symbolen för en resturang och gör en Seque till Resturang vyn
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print(#function)
        
        pickedResturantName = String(view.annotation?.title)
        
        if control == view.rightCalloutAccessoryView {
            
            if let pinannotation = view.annotation as? ResturantPointAnnotation {
            
                print("PinRestID: \(pinannotation.restId)")
                pickedResturantId = pinannotation.restId
                span = mapView.region.span
            }
            
            performSegueWithIdentifier("pickedResturantSegue", sender: nil)
        }
    }
    
    
    //sparar vilken center cordinat som var på kartan när flyttar sig på kartan
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //print("Sätter Map Center")
        
        mapCenter = mapView.centerCoordinate as CLLocationCoordinate2D
        
        region = MKCoordinateRegionMake(mapCenter, currentSpan)
        
        //Kollar Zoomlevel
        
        currentSpan = MKCoordinateSpanMake(mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta)
        
        /*if loadingData == false {
        
            self.getJsonData { () -> () in
                
                self.addAnnotationToMap()
            }
        }*/                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
        
    }
    
}








