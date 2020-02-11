//
//  AddResturantViewController.swift
//  FindGlutenFree
//
//  Created by Admin on 2016-11-24.
//  Copyright © 2016 FindGlutenFree. All rights reserved.
//

import UIKit
import MapKit

class AddResturantViewController: UIViewController {

    
    var recivedLatitude: CLLocationDegrees = 0
    var recivedLongitude: CLLocationDegrees = 0

    
    @IBOutlet var resturantNameText: UITextField!
    
    @IBOutlet var streetText: UITextField!
    
    
    @IBOutlet var zipText: UITextField!
    
    
    @IBOutlet var cityText: UITextField!
    
    @IBOutlet var gluteFreeFeaturesText: UITextField!
    
    
    @IBOutlet var descriptionText: UITextView!
    
    @IBOutlet var priceRangeText: UITextField!
    
    @IBOutlet var resturantType: UITextField!
    
    @IBAction func infoPrizeRangeButton(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Prize range", message: "1 - 50-100 SEK \n 2 - 100-150 SEK \n 3 - 150-200 SEK \n 4 - 200-300 SEK \n 5 - 300+ SEK", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func infoTypeButton(sender: AnyObject) {
    
        let alert = UIAlertController(title: "Prize range", message: "1 - Caffé \n 2 - Pub/bar \n 3 - Fastfood \n 4 - Dinner Resturant", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBOutlet var urlText: UITextField!
    
    @IBOutlet var phoneText: UITextField!
    
    @IBOutlet var emailText: UITextField!
    
    @IBAction func saveResturantButton(sender: AnyObject) {
        
        var resturantDict = ["Name": ""]
        
        resturantDict["Name"] = resturantNameText.text
        resturantDict["Url"] = urlText.text
        resturantDict["Description"] = descriptionText.text
        resturantDict["PriceRange"] = priceRangeText.text
        resturantDict["GlutenFreeFeatures"] = gluteFreeFeaturesText.text
        resturantDict["Adress"] = streetText.text
        resturantDict["Zip"] = zipText.text
        resturantDict["City"] = cityText.text
        resturantDict["Phone"] = phoneText.text
        resturantDict["Email"] = emailText.text
        resturantDict["FaceBook"] = "fejan"
        resturantDict["Twitter"] = "Twittrare"
        resturantDict["GooglePlus"] = "Gplus"
        resturantDict["ResturantType"] = resturantType.text
        resturantDict["Lat"] = String(recivedLatitude)
        resturantDict["Lon"] = String(recivedLongitude)
        resturantDict["UN"] = "FGFU"
        resturantDict["LO"] = "ataGluttfritt"
        
        print(resturantDict)
        
        do {
            
            if let resturantJson : NSData = try NSJSONSerialization.dataWithJSONObject(resturantDict, options: NSJSONWritingOptions.PrettyPrinted){
                
                //let resturantJson = NSString(data: postData, encoding: NSUTF8StringEncoding)! as String
                
                let readbleJson = NSString(data: resturantJson, encoding: NSUTF8StringEncoding)
                
                //print(resturantJson)
                //print(readbleJson)
                
                let urlEncoadedJson = readbleJson!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
                
                //print(urlEncoadedJson)
                
                let url = NSURL(string: "http://www.spelahemma.se/saveResturant?resturant=\(urlEncoadedJson!)")!
                
                print(url)
                
                // create post request
                //let url = NSURL(string: "http://www.spelahemma.se/saveResturant")!
                let request = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "POST"
                
                // insert json data to the request
                request.HTTPBody = resturantJson
                
                
                let saveTask = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                    data, response, error in
                    
                    if error != nil{
                        print(error!.localizedDescription)
                        return
                    }
                    /*let responseJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
                    {
                        println(responseJSON)
                    }*/
                    //print(response)
                    //print(data)
                }
                
                saveTask.resume()
                
            }
            
        }
        catch {
            print(error)
        }
        
        //skapa en Popup ruta med att resturangen sparades
        
        let alert = UIAlertController(title: "Saved", message: "Resturant '\(resturantNameText.text!)' was saved to the database", preferredStyle: .Alert)
        //alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:
            {
                [unowned self] (action) -> Void in
                
                self.performSegueWithIdentifier("backToMapFromSave", sender: nil)
            }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //Skapar en border på Description fältet
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        descriptionText.layer.borderWidth = 0.5
        descriptionText.layer.borderColor = borderColor.CGColor
        descriptionText.layer.cornerRadius = 5.0
        
        
        //Tar fram förslag på adress för ny resturang och populerar fälten med resultatet
        CLGeocoder().reverseGeocodeLocation(addCoordinate) { (geoData, error) in
            
            if (error == nil) {
                
                if let resturantGeoData = geoData?[0] {
                    
                    if resturantGeoData.thoroughfare != nil {
                        
                        self.streetText.text = resturantGeoData.thoroughfare!
                        
                        if resturantGeoData.subThoroughfare != nil {
                            
                            self.streetText.text = self.streetText.text! + " " + resturantGeoData.subThoroughfare!
                        }
                    }
                    
                    if resturantGeoData.postalCode != nil {
                
                        self.zipText.text = resturantGeoData.postalCode!
                        
                    }
                    
                    if resturantGeoData.locality != nil {
                        
                        self.cityText.text = resturantGeoData.locality!
                        
                    }
                }
            }
        }
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        
        
        
        //latitudLabel.text = recivedSrtring
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
