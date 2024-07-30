import Foundation
import CoreData

extension CountryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CountryEntity> {
        return NSFetchRequest<CountryEntity>(entityName: "CountryEntity")
    }
    
    @NSManaged public var code: String
    @NSManaged public var nameEn: String?
    @NSManaged public var nameRu: String?
}

extension CountryEntity: Identifiable {}
