import SnapKit

enum Constants {
    enum Text: String {
        case addExecutor = "Addition"
        case changeExecutor = "Change"
        case placeholderNameTextField = "Enter name"
        case placeholderSurnameTextField = "Enter surname"
        case placeholderDateOfBirthTextField = "Enter date of birth"
        case placeholderCountryTextField = "Enter of country executor"
        case systemLanguage = "systemLanguage"
        case firstLaunchAppAndDownloadSuccessful = "firstLaunchAppAndDownloadSuccessful"
        case successfulDownloadRU = "successfulDownloadRU"
        case successfulDownloadOther = "successfulDownloadOther"
        case noMoreDownloadRequired = "noMoreDownloadRequired"
        case nameDataModel = "DataModel"
        case labelTableViewController = "Executors"
        case labelAddOrChangeViewController = "Executor"
        case sortingDirection = "sortingDirection"
        case arrowUp = "arrow.up"
        case arrowDown = "arrow.down"
    }

    enum Font {
        static let systemFontBold = UIFont.boldSystemFont(ofSize: 20)
    }
    
    enum Image {
        static let arrowUp = UIImage(systemName: "arrow.up")
        static let arrowDown = UIImage(systemName: "arrow.down")
        static let arrowUpDown = UIImage(systemName: "arrow.up.arrow.down")
        static let plus = UIImage(systemName: "plus")
        static let error = UIImage(systemName: "xmark")
    }

    enum RegularExpression {
        static let regexLetters: NSRegularExpression = {
            do {
                return try NSRegularExpression(pattern: "^[а-яa-z]*$", options: .caseInsensitive)
            } catch {
                return NSRegularExpression()
            }
        }()
        static let regexDateOfBirth: NSRegularExpression = {
            do {
                return try NSRegularExpression(pattern: "^[0-9]*$")
            } catch {
                return NSRegularExpression()
            }
        }()
    }
}
