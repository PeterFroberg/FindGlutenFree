//
//  ReturantViewController.swift
//  FindGlutenFree
//
//  Created by Admin on 2016-10-12.
//  Copyright © 2016 FindGlutenFree. All rights reserved.
//

import UIKit
import CoreData


class ReturantViewController: UIViewController {

    
    
    @IBOutlet var navigationBar: UINavigationBar!
    
    @IBAction func mapButtonPressed(sender: AnyObject) {
        
        
    }
    
    @IBOutlet var descriptionLabel: UILabel!
    
    @IBOutlet var priceRangeLabel: UILabel!
    
    @IBOutlet var glutenFreeFeaturesLable: UILabel!
    
    @IBOutlet var resturantTypeLabel: UILabel!

    @IBOutlet var adressLabel: UILabel!
    
    @IBOutlet var zipCityLabel: UILabel!
    
    @IBOutlet var phoneLable: UILabel!
    
    @IBOutlet var emaliLabel: UILabel!
    
    @IBOutlet var urlLabel: UILabel!
    
    @IBOutlet var latLabel: UILabel!
    
    @IBOutlet var lonLabel: UILabel!
    
    
    
    func borderStyleUILable(lableToStyle : UILabel){
        
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        lableToStyle.layer.borderColor = borderColor.CGColor
        lableToStyle.layer.borderWidth = CGFloat(Float(0.5));
        lableToStyle.layer.cornerRadius = CGFloat(Float(5.0));
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Stylar UILable
        borderStyleUILable(descriptionLabel)
        borderStyleUILable(priceRangeLabel)
        borderStyleUILable(glutenFreeFeaturesLable)
        borderStyleUILable(resturantTypeLabel)
        borderStyleUILable(adressLabel)
        borderStyleUILable(zipCityLabel)
        borderStyleUILable(latLabel)
        borderStyleUILable(lonLabel)
        
        
                // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        //Hämta Data fron CoreData
        
        let request = NSFetchRequest(entityName: "Resturants")  //Skapa en request mot "databasen" Resturants lokalt på telefonen
        
        request.predicate = NSPredicate(format: "resturantId = %@", pickedResturantId)
        
        request.returnsObjectsAsFaults = false  //Anger att det är datan i posterna vi vill ha tillbaka

        let appDel1: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let coreDataContext1: NSManagedObjectContext = appDel1.managedObjectContext
        
        do {
            
            let results = try coreDataContext1.executeFetchRequest(request)
            
            if results.count > 0 {

                for result in results as! [NSManagedObject] { //Loopar igenom alla poster i CoreData som lästs upp
                    
                    if let resturantName = result.valueForKey("resturantName") as? String {
                        
                        navigationBar.topItem?.title = resturantName
                    }
                    
                    if let resturantDescription = result.valueForKey("resturantDescription") as? String {
                        descriptionLabel.text = resturantDescription
                    }
                    
                    if let resturantUrl = result.valueForKey("resturantUrl") as? String {
                        urlLabel.text = resturantUrl
                    }
                    
                    if let priceRange = result.valueForKey("priceRange") as? String {
                        priceRangeLabel.text = "Price Range: " + priceRange
                    }
                    if let glutenFreeFeatures = result.valueForKey("glutenFreeFeatures") as? String {
                        glutenFreeFeaturesLable.text = "Features: " + glutenFreeFeatures
                    }
                    if let resturantAdress = result.valueForKey("resturantAdress") as? String {
                        adressLabel.text = resturantAdress
                    }
                    if let resturantZip = result.valueForKey("resturantZip") as? String {
                        
                        if let resturantCity = result.valueForKey("resturantCity") as? String {
                            zipCityLabel.text = resturantZip + " " + resturantCity
                        }
                    }
                    
                    if let resturantPhone = result.valueForKey("resturantPhone") as? String {
                        phoneLable.text = resturantPhone
                    }
                    if let resturantEmail = result.valueForKey("resturantEmail") as? String {
                        emaliLabel.text = resturantEmail
                    }
                    if let resturantFacebook = result.valueForKey("resturantFacebook") as? String {
                    
                    }
                    if let resturantTwitter = result.valueForKey("resturantTwitter") as? String {
                    
                    }
                    if let resturantGooglePlus = result.valueForKey("resturantGooglePlus") as? String {
                    }
                    
                    if let resturantLon = result.valueForKey("resturantLon") as? String {
                        lonLabel.text = "LON: " + resturantLon
                    }
                    if let resturantLat = result.valueForKey("resturantLat") as? String {
                        latLabel.text = "LAT: " + resturantLat
                    }
                    
                    if let resturantType = result.valueForKey("resturantType") as? String {
                        
                        switch resturantType {
                            case "1":
                                resturantTypeLabel.text = "Type: Café"
                            case "2":
                                resturantTypeLabel.text = "Type: Pub/Bar"
                            case "3":
                                resturantTypeLabel.text = "Type: Fast Food"
                            case "4":
                                resturantTypeLabel.text = "Type: Dinner Resturant"
                        default:
                                resturantTypeLabel.text = "Type: Not Set"
                        }
                        
                    }
                
                }
                
            }
            
        }catch{}
        
        
        
        

        
        
    }
    
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        //print("View did Appear")
        //navigationBar.topItem?.title = "Peter"
        //navigationItem.title = "Peter"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
