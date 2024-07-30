import Foundation

final class RequestManager: NSObject {

    // singleton
    static let shared = RequestManager()
    private override init() {}

    // properties
    private let urlSession = URLSession.shared

    // request configure
    private struct Request {
        static let baseURL = URL(string: "https://data-api.oxilor.com/rest/countries")!
        // получение языка системы
        // только ru и en
        static let language: String = {
            switch (Locale.preferredLanguages.first ?? "").components(separatedBy: "-").first ?? "" {
            case "ru":
                return "ru"
            default:
                return "en"
            }
        }()
        
        static let header = [
            "Authorization": "Bearer 9w0r_Mvjzjt3VxLB1hwK9viP9ad70O",
            "Accept-Language": "\(language)"
        ]
        
        // метод возвращает кортеж: (запрос, язык системы)
        static func requestConfigure() -> (URLRequest, String) {
            var request = URLRequest(url: baseURL)
            request.allHTTPHeaderFields = header
            return (request, language)
        }
    }

    // request
    // в completion также передается язык системы
    func request(completion: @escaping (Any, String) -> Void) {
        urlSession.dataTask(with: Request.requestConfigure().0, completionHandler: {data, _, error in
            if let error = error {
                completion(error, Request.requestConfigure().1)
            } else if let data = data, let jsonData = try? JSONDecoder().decode([Country].self, from: data) {
                completion(jsonData, Request.requestConfigure().1)
            }
        }).resume()
    }
}
