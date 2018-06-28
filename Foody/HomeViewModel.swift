//
//  HomeViewModel.swift
//  Foody
//
//  Created by Vaibhav Singh on 20/05/18.
//  Copyright © 2018 Vaibhav. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class HomeViewModel: NSObject {

    private var context: NSManagedObjectContext?
    private var venues: [Venue?] = []
    private var dislikedVenues: [ManagedVenue] = []

    init(context: NSManagedObjectContext?) {
        super.init()

        self.context = context
    }

    func setup() {
        dislikedVenues = fetchDisliked()
    }

    func numberOfRowsInSection(section: Int) -> Int {
        switch section {
        case 0:
            return venues.count < 10 ? venues.count : 10
        default:
            return 0
        }
    }

    func getItemForCell(at indexpath: IndexPath) -> Venue? {
        switch indexpath.section {
        case 0:
            return venues[indexpath.row]
        default:
            return nil
        }
    }

    func fetchRecommended(router: Router, retries: Int = 0, completion: @escaping (([Venue?]) -> ())) {

        if let request = router.asUrlRequest() {
            let dataTask = NetworkManager.createTask(request: request, type: RecommendedResponse.self, completion: { (response) in

                self.venues = response?.groups?.first?.items?.map { return $0.venue } ?? []

                //Filter the response removing the disliked places
                for disliked in self.dislikedVenues {
                    self.venues = self.venues.filter { $0?.id != (disliked.value(forKey: "id") as! String) }
                }
                if self.venues.count > 10 {
                    DispatchQueue.main.async {
                        completion(self.venues)
                    }

                //Make another API call with more limit if objects are less than 10
                } else if retries < 3 {
                    self.fetchRecommended(router: router.increaseLimit(by: 10), retries: retries + 1, completion: completion)
                }

            })
            dataTask.resume()
        }
    }

    func searchVenues(router: Router, completion: @escaping (([Venue?]) -> ())) {
        if let request = router.asUrlRequest() {
            let dataTask = NetworkManager.createTask(request: request, type: SearchResponse.self, completion: { (response) in
                self.venues = response?.venues ?? []

                DispatchQueue.main.async {
                    completion(self.venues)
                }
            })
            dataTask.resume()
        }
    }

    func updateDislikesInData(_ disliked: Bool, at id: String) {

        //Save current state in Data Models
        if let index = venues.index(where: { $0?.id == id }) {
            venues[index]?.isDisliked = disliked
        }

        //Update the Database
        if disliked {
            saveDisliked(id)
            self.dislikedVenues = fetchDisliked()

        //Remove from the database to display again if user undoes the dislike
        } else if let managedContext = context {
            dislikedVenues = fetchDisliked()
            if let indexToDelete = dislikedVenues.index(where: { ($0.id) == id }) {
                managedContext.delete(dislikedVenues[indexToDelete])
                dislikedVenues.remove(at: indexToDelete)
                saveDBState(context: managedContext)
            }
        }
    }
}

//Mark :- CoreData methods
private extension HomeViewModel {

    func saveDisliked(_ id: String) {
         guard let managedContext = context else { return }
        let entity = NSEntityDescription.entity(forEntityName: "ManagedVenue", in: managedContext)!
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        person.setValue(id, forKey: "id")

        saveDBState(context: managedContext)
    }

    func fetchDisliked() -> [ManagedVenue] {
         guard let managedContext = context else { return [] }
        let fetchRequest = NSFetchRequest<ManagedVenue>(entityName: "ManagedVenue")
        do {
            let dislikedVenues = try managedContext.fetch(fetchRequest)

            return dislikedVenues
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        return []
    }

    func saveDBState(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
