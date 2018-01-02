//
//  MasterViewController.swift
//  ChicagoNA
//
//  Created by Daniel Turvey on 12/18/17.
//  Copyright © 2017 Daniel Turvey. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    let searchController = UISearchController(searchResultsController: nil)
    var meetings = [Meeting]()
    var filteredMeetings = [Meeting]()

    @IBAction func refresh(_ sender: UIBarButtonItem) {
        tableView.reloadData()
        //super.viewWillAppear(true)
        refreshTable()
    }
    func refreshTable(){
        pullData()
        tableView.reloadData()
        let indexPathForSection = NSIndexSet(index: 0)
        tableView.reloadSections(indexPathForSection as IndexSet, with: UITableViewRowAnimation.top)
      //  tableView.reloadData()
    //    tableView.reloadRows(at: indexPathForSection as IndexPath, with: UITableViewRowAnimation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Meeting List"
//clearData()

       // pullData() //Pull Meeting list from Core Data
        //fetchJSONloc() //Start the update meeting list chain of events

        clearJFTData() //Clear out old JFT
        jftJSONParser() //Fetch new JFT
        

        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Meetings"
      //  searchController.searchBar.
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["All","Su", "M", "T", "W","Th","F","Sa"]
        searchController.searchBar.delegate = self
        //tableView.tableHeaderView = searchController.searchBar
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
         //  searchController.isActive = true
        tableView.reloadData()
        pullData()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        pullData()
        let delayInSeconds = 3.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            
            self.tableView.reloadData()
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc
    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        let newEvent = Event(context: context)
             
        // If appropriate, configure the new managed object.
        newEvent.timestamp = Date()

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
    // MARK: - Segues
    //
    //**************************************************************************************************************************************

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let meeting: Meeting
                if isFiltering() {
                    meeting = filteredMeetings[indexPath.row]
                } else {
                    meeting = meetings[indexPath.row]
                }
                
           // let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = meeting
                //controller.detailDescriptionLabel.text = meeting.name
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    //**************************************************************************************************************************************
    //
    // MARK: - Table View
    //
    //**************************************************************************************************************************************

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let sectionInfo = fetchedResultsController.sections![section]
       // return sectionInfo.numberOfObjects
       // if searchController.isActive && searchController.searchBar.scopeButtonTitles![searchController.searchBar.selectedScopeButtonIndex] != ""{
            if isFiltering(){
            return filteredMeetings.count
        }
        return meetings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
      // let event = fetchedResultsController.object(at: indexPath)
        let meeting: Meeting
      //  if searchController.isActive && searchController.searchBar.scopeButtonTitles![searchController.searchBar.selectedScopeButtonIndex] != ""{
            if isFiltering(){
            meeting = filteredMeetings[indexPath.row]
        } else {
            meeting = meetings[indexPath.row]
        }
        //meeting = meetings[indexPath.row]
        configureCell(cell, withEvent: meeting)
       // cell.textLabel!.text = meeting.name
        //cell.detailTextLabel!.text = meeting.day + ": " + meeting.time + " - " + meeting.area
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withEvent event: Meeting) {
        //cell.textLabel!.text = event.name?.description
        
        if event.name != "" {
            cell.textLabel!.text = event.name
            cell.detailTextLabel!.text = event.day + ": " + event.time + " - " + event.area
        }
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        var scp = scope
        if scope == "Su"{
            scp = "Sunday"
        }
        else if scope == "M"{
            scp = "Monday"
        }
        else if scope == "T"{
            scp = "Tuesday"
        }
        else if scope == "W"{
            scp = "Wednesday"
        }
        else if scope == "Th"{
            scp = "Thursday"
        }
        else if scope == "F"{
            scp = "Friday"
        }
        else if scope == "Sa"{
            scp = "Saturday"
        }
        
        filteredMeetings = meetings.filter({( meeting : Meeting) -> Bool in
            let categoryMatch = (scp == "All") || (meeting.day == scp)
            if searchText == ""{
                return categoryMatch
            }
            else{
                return (categoryMatch && (meeting.name.lowercased().contains(searchText.lowercased()) || meeting.time.lowercased().contains(searchText.lowercased()) || meeting.area.lowercased().contains(searchText.lowercased())))
            }
        })
        
        tableView.reloadData()
    }

    
    // MARK: - Private instance methods
    
   /* func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredMeetings = meeting.filter({( event : Event) -> Bool in
            let doesCategoryMatch = (scope == "All") || (event.day == scope)
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && candy.name.lowercased().contains(searchText.lowercased())
            }
        })
        tableView.reloadData()
    }*/
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    
    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Event> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "area", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Event>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Meeting)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Meeting)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
    func controllerDidChangeContent(controller: NSFetchedResultsController<NSFetchRequestResult>) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
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
    //Pull Core Data
    //
    func pullData() {
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        
        do {
            let searchResults = try getContext().fetch(fetchRequest)
            for trans in searchResults{
                let mtg:Meeting = Meeting(area: trans.area!, name: trans.name!, day: trans.day!, time: trans.time!, address: trans.address!, description: trans.desc!, duration: trans.duration!, id: trans.id!)
                meetings.append(mtg)
                //print("---------------------------------CORE:",mtg.id)
            }
            
        } catch {
            print("@@@@@@@@@@@@@@@@@@@@@@@@@@@Error with request: \(error)")
        }
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
    //Clear Core Data JFT
    //
    func clearJFTData(){
        // Create Fetch Request
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "JFT")
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
        } catch {
            // Error Handling
        }
    }
    
    //
    //Clear Core Data JFT
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
    //Pull Core Data URL
    //
    func pullURL() -> String {
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<JSON_URL> = JSON_URL.fetchRequest()
        
        do {
            let searchResults = try getContext().fetch(fetchRequest)
            for trans in searchResults{
                let url:String = trans.urlString!
                return url
            }
            
        } catch {
            print("Error with ###########################request: \(error)")
        }
        return "ERROR"
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
        //clearData()
       // print("PULL CORE URL____________________________________")
    //    print(pullURL())
        let coreURL = pullURL()
        let url = URLRequest(url:URL(string:"https://api.myjson.com/bins/70ccp")!)
        let session = URLSession.shared
        //let x = count
        let task = session.dataTask(with:url, completionHandler: {(data, response, error) in
            if error != nil {
                print( "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ooops",error!)
            } else {
                for _ in 0...0 {
                    do {
                        let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                        let myData = parsedData[0] as! NSDictionary
                        let location = myData["uri"]
                        //rint("NEW URL:")
                        //rint(location as! String)
                        let newURL = location as! String
                        //rint("CORE URL:")
                      //  rint(coreURL)
                       // self.saveURL(url: location as! String)
                        if(coreURL != newURL){
                            print("*******************************************************************************RESETTING MEETING INFO*****************************************")
                            self.saveURL(url: newURL)
                           // print(self.pullURL())
                            self.clearData()
                           self.jsonCounter(urlString: location as! String)
                        }
                        else  {
                            print("*******************************************************************************NOT RESETTING MEETING INFO*****************************************")

                            break
                        }
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
                        self.saveJSONdata(mtg: mtg)
                        
                        
                    } catch let error as NSError {
                        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",error)
                    }
                }
            }
            
        })
        task.resume()
    }
    
    //
    //Save JSON Data
    //
    func saveJSONdata(mtg: Meeting){
        insertNewObject(Any.self, mtg: mtg)
    }
    func insertNewObject(_ sender: Any, mtg: Meeting) {
        let context = getContext() //self.fetchedResultsController.managedObjectContext
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
      //  print("-------------------------------------------------------------------------------------------------------------------------------------")
     //   print(newURL)
    //    print("-------------------------------------------------------------------------------------------------------------------------------------")
        
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
    
    //
    //JFT JSON Parser
    //
    func jftJSONParser() {
        let url = URLRequest(url:URL(string:"https://api.myjson.com/bins/12waqp")!)
        let session = URLSession.shared
        //   let x = 1
        let task = session.dataTask(with:url, completionHandler: {(data, response, error) in
            if error != nil {
                print("????????????????????????????????????????????????",error!)
            } else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                    let myData = parsedData[0] as! NSDictionary
                    let passName = myData["name"] as! String
                    let passDate = myData["date"] as! String
                    let passQuote = myData["quote"] as! String
                    let passBTPage = myData["btPage"] as! String
                    let passBody = myData["body"] as! String
                    let passJFT = myData["jft"] as! String
                    
                    self.saveJFTJSONdata(name: passName, date: passDate, quote: passQuote, btPage: passBTPage, body: passBody, jft: passJFT)
                    
                } catch let error as NSError {
                    print("|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||",error)
                }
            }
            
        })
        task.resume()
    }
    
    //
    //Save JFT JSON Data
    //
    func saveJFTJSONdata(name: String, date: String, quote: String, btPage: String, body: String, jft: String){
      //  print("=====================================",btPage)
        insertNewJFTObject(Any.self, name: name, date: date, quote: quote, btPage: btPage, body: body, jft: jft)
    }
    func insertNewJFTObject(_ sender: Any, name: String, date: String, quote: String, btPage: String, body: String, jft: String) {
        let context = getContext() //self.fetchedResultsController.managedObjectContext
        let newJFT = JFT(context: context)
        
        // If appropriate, configure the new managed object.
        newJFT.name = name
        newJFT.date = date
        newJFT.quote = quote
        newJFT.btPage = btPage
        newJFT.body = body
        newJFT.jft = jft
        //print("===================@@@@@@@########==================",btPage)
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
}

//***************************
//
//Search Bar Controller
//
//***************************
/*extension MasterViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension MasterViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}*/

extension MasterViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension MasterViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}
