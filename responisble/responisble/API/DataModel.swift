import Foundation

struct Country: Codable {
    let name: String
    let countryCode: String

    enum CodingKeys: String, CodingKey {
        case name
        case countryCode
    }
}
