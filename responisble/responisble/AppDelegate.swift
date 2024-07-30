import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // проверка на необходимость загрузки стран
        if !UserDefaults.standard.bool(forKey: Constants.Text.noMoreDownloadRequired.rawValue) {
            // регистрация доменов с настройками по умолчанию в userDefaults
            registerDefaultsFromSettingsBundle()
            // проверка изменения языка при каждом входе в приложение
            localeDidChange()
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // сохранение изменений при разрядке устройства
    func applicationWillTerminate(_ application: UIApplication) {
        _ = CoreDataStack.shared.saveContext()
    }
}

// MARK: - Extension AppDelegate

extension AppDelegate {
    
    // MARK: - Private Func UserDefaults Register
    
    private func registerDefaultsFromSettingsBundle() {
        // регистрация домена с настройками по умолчанию для загрузки стран
        guard let pathCountrySet = Bundle.main.path(forResource: "LoadCountrySet", ofType: "plist"),
              let defaults = NSDictionary(contentsOfFile: pathCountrySet) as? [String: Any] else { return /* выброс ошибки */}
        UserDefaults.standard.register(defaults: defaults)
        // регистрация домена с настройками приложени
        guard let pathAppSet = Bundle.main.path(forResource: "AppSet", ofType: "plist"),
              let defaults = NSDictionary(contentsOfFile: pathAppSet) as? [String: Any] else { return /* выброс ошибки */}
        UserDefaults.standard.register(defaults: defaults)
        // сохранение текущего языка в UserDefaults при первом запуске приложения
        if UserDefaults.standard.string(forKey: Constants.Text.systemLanguage.rawValue) == "" {
            UserDefaults.standard.set(NSLocale.preferredLanguages.first?.components(separatedBy: "-").first, forKey: Constants.Text.systemLanguage.rawValue)
        }
        // загрузка стран при первом запуске приложения
        if !UserDefaults.standard.bool(forKey: Constants.Text.firstLaunchAppAndDownloadSuccessful.rawValue) {
            loadCountry()
        }
    }
    
    // MARK: - Private Func LoadCountry
    
    private func loadCountry() {
        // http запрос
        RequestManager.shared.request(completion: { (data, language) in
            guard let data = data as? [Country] else { return }
            // вызов метода загрузки в Core Data
            CoreDataStack.shared.addCountry(countries: data, language: language)
        })
    }
    
    // MARK: - Private Func LocaleDidChange
    
    private func localeDidChange() {
        // т.к. уведомление, вызывающее метод, обрабатывает несколько изменений системы (язык и регион)
        // проверяем был ли изменен язык
        if UserDefaults.standard.string(forKey: Constants.Text.systemLanguage.rawValue) != NSLocale.preferredLanguages.first?.components(separatedBy: "-").first {
            loadCountry()
        }
    }
}
