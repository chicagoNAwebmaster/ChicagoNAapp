//
//  DetailViewController.swift
//  ChicagoNA
//
//  Created by Daniel Turvey on 12/18/17.
//  Copyright © 2017 Daniel Turvey. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {

   // @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var area: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var address: UITextView!
    @IBOutlet weak var desc: UITextView!
    
    @IBAction func addFav(_ sender: UIButton) {
        if let detail = detailItem {
            storeData(id: detail.id.description)
            }
        let alert = UIAlertController(title: "Added To Favorites", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
      
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            //if let label = detailDescriptionLabel {
             //   label.text = "Meeting ID: " + detail.id.description
          //  }
            
            if let n = name {
                self.title = detail.name.description
                n.text = "Name: " + detail.name.description
            }
            
            if let d = day {
                d.text = "Day: " + detail.day.description
            }
            if let t = time {
                t.text = "Time: " + detail.time.description
            }
            if let ar = area {
                ar.text = "Area: " + detail.area.description
            }
            if let du = duration {
                du.text = "Duration: " + detail.duration.description
            }
 
            if let ad = address {
                ad.text = "Address: " + detail.address.description
            }
            if let di = desc {
                di.text = "Description: " + detail.description.description
            }
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Meeting? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    func storeData (id: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        
        //retrieve the entity that we just created
        let entity =  NSEntityDescription.entity(forEntityName: "Favorites", in: context)
        let fav = NSManagedObject(entity: entity!, insertInto: context)
        
        //set the entity values
        fav.setValue(id, forKey: "id")
        
        //save the object
        do {
            try context.save()
            // print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
    }


}

