import Foundation
import CoreData

extension ExecutorEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExecutorEntity> {
        return NSFetchRequest<ExecutorEntity>(entityName: "ExecutorEntity")
    }
    
    @NSManaged public var countryCode: String
    @NSManaged public var dateOfBirth: Date
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var surname: String
}

extension ExecutorEntity: Identifiable {}
