//
//  RepoCoreDarta.swift
//  Krown
//
//  Created by Rachit Prajapati on 05/06/21.
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import Foundation
import CoreData

// In coreData the approach will be to use crud protocol in generic class aka CoreDataRepository. Also our logic will be in this class thus providing us less redundancy in XMPPControllers
// The below code is used in files OneChats and OneMessage. Can't use in OneRoaster because NSFetchedResultsController directlu communicates with UILayer for performance reasons
// The declaration will be creating the instance of below class and using the methods of this class in the instance. For eg: Our ManagedObejct will be abstracted to type CoreDataRepository<T>.Type
// I commented the previous code to observe the difference.
// A Switch statement will be used at declaration since we are returning result type which will act as alternative to do catch blocks.
protocol Repository {
    associatedtype Entity
    func get(predicate: NSPredicate, entityDescription: NSEntityDescription, fetchLimit: Int?, sortDescriptors: [NSSortDescriptor]?) -> Result<[Entity], Error>
    func create() -> Result<Entity, Error>
    func delete(entity: Entity)
    func reset()
    func refereshAllObjects()
    func save()
}

enum CoreDataError: Error {
    case invalidManagedObjectType
}

class CoreDataRepository<T: NSManagedObject>: Repository {
    
    typealias Entity = T
    
    private let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func get(predicate: NSPredicate, entityDescription: NSEntityDescription, fetchLimit: Int? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> Result<[Entity], Error> {
        let request = Entity.fetchRequest()
        request.predicate = predicate
        request.entity = entityDescription
        if let fetchLimit = fetchLimit {
            request.fetchLimit = fetchLimit
        }
        
        if let sortDescriptors = sortDescriptors {
            request.sortDescriptors = sortDescriptors
        }
        
        do {
            if let fetchResults = try managedObjectContext.fetch(request) as? [Entity] {
                return .success(fetchResults)
            } else {
                return .failure(CoreDataError.invalidManagedObjectType)
            }
        } catch {
            return .failure(error)
        }
        
    }
    
    func delete(entity: T) {
        managedObjectContext.delete(entity)
    }
    
    // TODO:- When needed
    func create() -> Result<Entity, Error> {
        let className = String(describing: Entity.self)
        if let managedObject = NSEntityDescription.insertNewObject(forEntityName: className, into: managedObjectContext) as? Entity {
            return .success(managedObject)
        } else {
            return .failure(CoreDataError.invalidManagedObjectType)
        }
    }
    
    func reset() {
        managedObjectContext.reset()
    }
    
    func refereshAllObjects() {
        managedObjectContext.refreshAllObjects()
    }
    
    func save() {
        do {
            try managedObjectContext.save()
        } catch let error {
            Log.log(message: "DBG: Error Saving by the abstract class Error: %@", type: .debug, category: Category.coreData, content: String(describing: error.localizedDescription))
        }
    }
}
