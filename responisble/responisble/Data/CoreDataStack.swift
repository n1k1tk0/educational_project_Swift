import Foundation
import CoreData

final class CoreDataStack: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Singleton
    
    static let shared = CoreDataStack()
    private override init() {}
    
    // MARK: - Data Properties
    
    private(set) lazy var fetchResultExecutors: [ExecutorEntity] = {
        ((request(entity: ExecutorEntity.self, delegate: self)).fetchedObjects) as? [ExecutorEntity] ?? []
    }() {
        // публикуем уведомление об изменении данных в центре уведомлений
        didSet {
            NotificationCenter.default.post(name: Notification.Name("dataExecutorDidChange"), object: self)
        }
    }
    
    private(set) lazy var fetchResultCountries: [CountryEntity] = {
        ((request(entity: CountryEntity.self, delegate: self)).fetchedObjects) as? [CountryEntity] ?? []
    }()
    
    // MARK: - PersistantContainer
    
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constants.Text.nameDataModel.rawValue)
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    private lazy var context: NSManagedObjectContext = {
        persistentContainer.viewContext
    }()
    
    private func request(entity: NSManagedObject.Type, delegate: any NSFetchedResultsControllerDelegate)
    -> NSFetchedResultsController<NSFetchRequestResult> {
        
        // запрос
        let request = entity.fetchRequest()
        // передача дескриптора сортировки в зависимости от типа сущности
        switch entity {
        case is ExecutorEntity.Type:
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        case is CountryEntity.Type:
            request.sortDescriptors = [NSSortDescriptor(key: "code", ascending: false)]
        default:
            break
        }
        
        // controller
        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultController.delegate = delegate
        
        // непосредственное выполнение запроса
        do {
            try fetchedResultController.performFetch()
        } catch {
            fatalError()
        }
        
        return fetchedResultController
    }
    
    // MARK: - Update Data
    
    private func refreshExecutors() {
        fetchResultExecutors = (request(entity: ExecutorEntity.self, delegate: self).fetchedObjects as? [ExecutorEntity]) ?? []
    }
    
    private func refreshCountries() {
        fetchResultCountries = (request(entity: CountryEntity.self, delegate: self).fetchedObjects as? [CountryEntity]) ?? []
    }
    
    // MARK: - Sorted Data
    
    func sortedData(direction: Bool) {
        fetchResultExecutors.sort(by: { direction ? $0.surname < $1.surname : $0.surname > $1.surname })
    }
    
    // save changes
    func saveContext() -> Bool {
        if context.hasChanges {
            do {
                try context.save()
                return true
            } catch {
                let nsError = error as NSError
                fatalError(nsError.description)
            }
        } else {
            return false
        }
    }
}

// MARK: - Extension CoreDataStak

extension CoreDataStack {
    
    // MARK: - Internal Func AddCountry
    
    func addCountry(countries: [Country], language: String) {
        // если первый запуск приложения
        if !UserDefaults.standard.bool(forKey: Constants.Text.firstLaunchAppAndDownloadSuccessful.rawValue) {
            createCountries(countries: countries, language: language)
            // если первый запуск приложения выполнен и первый запрос успешен, данные получены
            // вызываем установку значения при положительном запросе и сохранении
            if saveContext() {
                setDownloadSuccessesFlags(language: language)
                refreshCountries()
            }
        } else {
            // если запуск повторный и было успешное сохранение контекста
            // если регион iPhone был изменен
            updateCountries(countries: countries, language: language)
            // вызываем установку значения при положительном запросе и сохранении
            if saveContext() {
                setDownloadSuccessesFlags(language: language)
                refreshCountries()
            }
        }
    }
    
    // MARK: - Private Func CreateCountries
    
    private func createCountries(countries: [Country], language: String) {
        for country in countries {
            // создаем модель управляемого объекта
            let manageObject = NSEntityDescription.insertNewObject(forEntityName: "CountryEntity", into: context)
            // insert code item
            manageObject.setValue(country.countryCode, forKey: "code")
            // insert names item
            switch language {
            case "ru":
                manageObject.setValue(country.name, forKey: "nameRu")
            default:
                manageObject.setValue(country.name, forKey: "nameEn")
            }
        }
    }
    
    // MARK: - Private Func UpdateCountries
    
    private func updateCountries(countries: [Country], language: String) {
        // выполнение запроса
        guard let fetchedItems = request(entity: CountryEntity.self, delegate: self).fetchedObjects else { return }
        if !fetchedItems.isEmpty {
            fetchedItems.forEach { entity in
                guard let entity = entity as? CountryEntity else { return }
                for country in countries where entity.code == country.countryCode {
                    let keyPath = language == "ru" ? \CountryEntity.nameRu : \CountryEntity.nameEn
                    entity[keyPath: keyPath] = country.name
                    break
                }
            }
        } else {
            // если хранилище пустое, то вызываем создание сущностей
            createCountries(countries: countries, language: language)
        }
    }
    
    // MARK: - Private Func SetDownloadSuccessesFlags
    
    private func setDownloadSuccessesFlags(language: String) {
        // первый запуск приложения выполнен и данные получены и сохранены
        UserDefaults.standard.set(true, forKey: Constants.Text.firstLaunchAppAndDownloadSuccessful.rawValue)
        // устанавливаем значение на каком языке была выполнена загрузка
        if language == "ru" {
            UserDefaults.standard.set(true, forKey: Constants.Text.successfulDownloadRU.rawValue)
        } else {
            UserDefaults.standard.set(true, forKey: Constants.Text.successfulDownloadOther.rawValue)
        }
        // если все данные загружены, устанавливаем флаг на основе результата загрузки разных языков
        UserDefaults.standard.set(
            UserDefaults.standard.bool(forKey: Constants.Text.successfulDownloadRU.rawValue) &&
            UserDefaults.standard.bool(forKey: Constants.Text.successfulDownloadOther.rawValue),
            forKey: Constants.Text.noMoreDownloadRequired.rawValue)
    }
    
    // MARK: - Internal Func AddExecutor
    
    func addExecutor(id: String?, name: String, surname: String, dateOfBirth: Date, countryCode: String, typeOfOperation: String) {
        // проверка какой операцией было инициировано событие (add/change)
        switch typeOfOperation {
        // добавление нового исполнителя
        case Constants.Text.addExecutor.rawValue:
            createExecutor(name: name, surname: surname, dateOfBirth: dateOfBirth, countryCode: countryCode)
            saveContext() ? refreshExecutors() : nil
        case Constants.Text.changeExecutor.rawValue:
            guard let id = id else { return }
            updateExecutor(id: id, name: name, surname: surname, dateOfBirth: dateOfBirth, countryCode: countryCode)
            saveContext() ? refreshExecutors() : nil
        default:
            break
        }
    }
    
    // MARK: - Private Func CreateExecutor
    
    private func createExecutor(name: String, surname: String, dateOfBirth: Date, countryCode: String) {
        // создаем модель управляемого объекта по описанию сущности исполнителя
        let manageObject = NSEntityDescription.insertNewObject(forEntityName: "ExecutorEntity", into: context)
        manageObject.setValue(UUID().uuidString, forKey: "id")
        manageObject.setValue(name, forKey: "name")
        manageObject.setValue(surname, forKey: "surname")
        manageObject.setValue(dateOfBirth, forKey: "dateOfBirth")
        manageObject.setValue(countryCode, forKey: "countryCode")
    }
    
    // MARK: - Private Func UpdateExecutor
    
    private func updateExecutor(id: String, name: String, surname: String, dateOfBirth: Date, countryCode: String) {
        // получаем исполнителя по id
        guard let executor = fetchResultExecutors.filter({ $0.id == id }).first else { return }
        // заносим изменения в бд
        executor.name != name ? executor.name = name : nil
        executor.surname != surname ? executor.surname = surname : nil
        executor.dateOfBirth != dateOfBirth ? executor.dateOfBirth = dateOfBirth : nil
        executor.countryCode != countryCode ? executor.countryCode = countryCode : nil
    }
    
    // MARK: - Internal Func DeleteExecutor
    
    func deleteExecutor(_ executor: ExecutorEntity, completion: @escaping (Bool) -> Void) {
        // удаление объекта
        context.delete(executor)
        // сохранение контекста и возврат значения
        if saveContext() {
            refreshExecutors()
            completion(true)
        } else {
            completion(false)
        }
    }
}
