//
//  MenuViewController.swift
//  ChicagoNA
//
//  Created by Daniel Turvey on 12/31/17.
//  Copyright © 2017 Daniel Turvey. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MenuViewController: UIViewController {
    var meetings = [Meeting]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //getData()
        
    }
    @IBAction func clearButton(_ sender: UIButton) {
        clearData()
    }
    
    @IBAction func step2(_ sender: UIButton) {
        saveJSONdata()
    }
    
    @IBAction func resetMeetings(_ sender: UIButton) {
        print("^^^^^^^^^^^%%%%%%%%%%%%%&&&&&&&&&&&$$$$$$$$$")
        clearURLData()
        clearData()
        saveURL(url: "reset")
        fetchJSONloc()
    }
    
    //**************************************************************************************************************************************
    //
    //
    //Core Data
    //
    //
    //
    //**************************************************************************************************************************************
    
    //
    //getContext for core data
    //
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    //
    //Clear Core Data
    //
    func clearData(){
        // Create Fetch Request
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
        } catch {
            // Error Handling
        }
    }
    //
    //Clear Core Data
    //
    func clearURLData(){
        // Create Fetch Request
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "JSON_URL")
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
        } catch {
            // Error Handling
        }
    }
    
    //
    //Save JSON Data - URL
    //
    func saveURL(url: String){
        insertNewURL(Any.self, url: url)
    }
    func insertNewURL(_ sender: Any, url: String) {
        let context = getContext() //self.fetchedResultsController.managedObjectContext
        let newURL = JSON_URL(context: context)
        
        // Create Fetch Request
        //  let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "JSON_URL")
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
        } catch {
            // Error Handling
        }
        // If appropriate, configure the new managed object.
        newURL.urlString = url

        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    //**************************************************************************************************************************************
    //
    //
    //JSON Data
    //
    //
    //
    //**************************************************************************************************************************************
    
    
    //
    //Fetch JSON Location
    //
    func fetchJSONloc() {
        let url = URLRequest(url:URL(string:"https://api.myjson.com/bins/70ccp")!)
        let session = URLSession.shared
        let task = session.dataTask(with:url, completionHandler: {(data, response, error) in
            if error != nil {
                print( "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ooops",error!)
            } else {
                for _ in 0...0 {
                    do {
                        let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                        let myData = parsedData[0] as! NSDictionary
                        let location = myData["uri"]
                        
                        let newURL = location as! String
                            self.saveURL(url: newURL)
                       //     self.clearData()
                            self.jsonCounter(urlString: location as! String)
                    
                    } catch let error as NSError {
                        print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&",error)
                    }
                }
            }
            
        })
        task.resume()
    }
    //
    //Count JSON Data Length
    //
    func jsonCounter(urlString: String) {
        let url = URLRequest(url:URL(string: urlString)!)
        let session = URLSession.shared
        let task = session.dataTask(with:url, completionHandler: {(data, response, error) in
            if error != nil {
                print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^",error!)
            } else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                    self.jsonParser(urlString: urlString, count: parsedData.count-1)
                } catch let error as NSError {
                    print("{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{",error)
                }
            }
        })
        task.resume()
    }
    
    //
    //Parse JSON Data
    //
    func jsonParser(urlString: String, count: Int) {
        let url = URLRequest(url:URL(string: urlString)!)
        let session = URLSession.shared
        let x = count
        let task = session.dataTask(with:url, completionHandler: {(data, response, error) in
            if error != nil {
                print("]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]",error!)
            } else {
                for index in 0...x {
                    do {
                        let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                        let myData = parsedData[index] as! NSDictionary
                        
                        let address = myData["address"]
                        let area = myData["area"]
                        let name = myData["name"]
                        let day = myData["day"]
                        let time = myData["time"]
                        let description = myData["description"]
                        let duration = myData["duration"]
                        let id = myData["id"]
                        let mtg = Meeting(area: area! as! String,name: name! as! String, day: day! as! String,time: time! as! String,address: address! as! String,description: description! as! String,duration: duration! as! String,id: id! as! String)
                        self.meetings.append(mtg)
                        //print(mtg.id)
                       // self.saveJSONdata()
                        
                        
                    } catch let error as NSError {
                        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",error)
                    }
                }
                //self.saveJSONdata()
            }
            
        })
        print("done")
        task.resume()
    }
    
    //
    //Save JSON Data
    //
    func saveJSONdata(){
        for i in meetings
        {
        insertNewObject(Any.self, mtg: i)
            print(i.id)
        }
        
       // exit(0)
        
    }
    func insertNewObject(_ sender: Any, mtg: Meeting) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        
        //retrieve the entity that we just created
        let entity =  NSEntityDescription.entity(forEntityName: "Event", in: context)
        let newEvent = NSManagedObject(entity: entity!, insertInto: context)
        
        //set the entity values
        newEvent.setValue(NSDate() as Date, forKey: "timestamp")
        newEvent.setValue(mtg.name, forKey: "name")
        newEvent.setValue(mtg.time, forKey: "time")
        newEvent.setValue(mtg.duration, forKey: "duration")
        newEvent.setValue(mtg.day, forKey: "day")
        newEvent.setValue(mtg.description, forKey: "desc")
        newEvent.setValue(mtg.area, forKey: "area")
        newEvent.setValue(mtg.address, forKey: "address")
        newEvent.setValue(mtg.id, forKey: "id")
        
        //save the object
        do {
            try context.save()
            // print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        
        /*//  let context = getContext() //self.fetchedResultsController.managedObjectContext
        let newEvent = Event(context: context)
        
        // If appropriate, configure the new managed object.
        newEvent.timestamp = NSDate() as Date
        newEvent.name = mtg.name
        newEvent.time = mtg.time
        newEvent.duration = mtg.duration
        newEvent.day = mtg.day
        newEvent.desc = mtg.description
        newEvent.area = mtg.area
        newEvent.address = mtg.address
        newEvent.id = mtg.id
        
        
        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }*/
    }
    
    
}
