import Foundation
import SnapKit

class TableWithExecutorsVC: UITableViewController {
    
    // MARK: - Properties
    
    // переменная для отключения уведомлений об изменении fetchRequestExecutor
    private var shouldSendNotifications = true
    
    // MARK: - UI Elements
    
    // Кнопка для изменения направления сортировки
    private lazy var leftBarButton: UIBarButtonItem = {
        // инициализация
        let leftBarButton = UIBarButtonItem(
            image: {
                if UserDefaults.standard.string(forKey: Constants.Text.sortingDirection.rawValue) != "" {
                    switch UserDefaults.standard.string(forKey: Constants.Text.sortingDirection.rawValue) {
                    case Constants.Text.arrowUp.rawValue:
                        CoreDataStack.shared.sortedData(direction: true)
                        return Constants.Image.arrowUp
                    case Constants.Text.arrowDown.rawValue:
                        CoreDataStack.shared.sortedData(direction: false)
                        return Constants.Image.arrowDown
                    default:
                        return Constants.Image.error
                    }
                } else {
                    return Constants.Image.arrowUpDown
                }
            }(),
            style: .plain,
            target: self,
            action: #selector(sortedExecutors)
        )
        // изменение цвета кнопки
        leftBarButton.tintColor = .black
        return leftBarButton
    }()
    
    // Кнопка "+" для добавления нового исполнителя
    private lazy var rightBarButton: UIBarButtonItem = {
        // инициализация
        let rightBarButton = UIBarButtonItem(
            image: Constants.Image.plus,
            style: .done,
            target: self,
            action: #selector(addExecutors)
        )
        // изменение цвета кнопки
        rightBarButton.tintColor = .black
        return rightBarButton
    }()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNotifications()
        registerTableViewCells()
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.leftBarButtonItem = leftBarButton
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangeData),
            name: Notification.Name("dataExecutorDidChange"),
            object: nil
        )
    }
    
    private func registerTableViewCells() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    // MARK: - Actions
    
    @objc private func sortedExecutors(_ selector: UIBarButtonItem) {
        switch selector.image {
        case Constants.Image.arrowUpDown:
            leftBarButton.image = Constants.Image.arrowUp
            CoreDataStack.shared.sortedData(direction: true)
            UserDefaults.standard.set(Constants.Text.arrowUp.rawValue, forKey: Constants.Text.sortingDirection.rawValue)
        case Constants.Image.arrowUp:
            leftBarButton.image = Constants.Image.arrowDown
            CoreDataStack.shared.sortedData(direction: false)
            UserDefaults.standard.set(Constants.Text.arrowDown.rawValue, forKey: Constants.Text.sortingDirection.rawValue)
        case Constants.Image.arrowDown:
            leftBarButton.image = Constants.Image.arrowUp
            CoreDataStack.shared.sortedData(direction: true)
            UserDefaults.standard.set(Constants.Text.arrowUp.rawValue, forKey: Constants.Text.sortingDirection.rawValue)
        default:
            break
        }
    }
    
    @objc private func addExecutors() {
        navigationController?.pushViewController(
            AddOrChangeOfExecutorVC(
                title: Constants.Text.labelAddOrChangeViewController.rawValue,
                textInLabel: Constants.Text.addExecutor.rawValue
            ),
            animated: true)
    }
    
    @objc private func didChangeData() {
        guard shouldSendNotifications else { return }
        tableView.reloadData()
    }
    
    // MARK: - Init
    
    init(title: String) {
        super.init(style: .grouped)
        self.title = title
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - TableView
    
    // количество секций в таблице
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    // количество ячеек в секции
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        CoreDataStack.shared.fetchResultExecutors.count
    }
    
    // заполнение таблицы данными
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // получение переиспользуемой ячейки
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // проверка существует ли индекс в массиве
        if CoreDataStack.shared.fetchResultExecutors.indices.contains(indexPath.row) {
            // получение конкретного объекта
            let fetchObjc = CoreDataStack.shared.fetchResultExecutors[indexPath.row]
            // установка лэйбла ячейки
            cell.textLabel?.text = "\(fetchObjc.name) \(fetchObjc.surname)"
        }
        return cell
    }
    
    // обработка нажатия на ячейку
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // проверка существует ли индекс в массиве исполнителей
        if CoreDataStack.shared.fetchResultExecutors.indices.contains(indexPath.row) {
            // получаем исполнителя
            let executor = CoreDataStack.shared.fetchResultExecutors[indexPath.row]
            // фильтрация массива для поиска нужной страны
            if let matchCountry = CoreDataStack.shared.fetchResultCountries.filter({$0.code == executor.countryCode}).first {
                // получение языка системы для обращения к нужному свойству
                let systemLanguage = NSLocale.preferredLanguages.first?.components(separatedBy: "-").first ?? ""
                // выбор пути на основе языка
                let keyPath = systemLanguage == "ru" ? \CountryEntity.nameRu : \CountryEntity.nameEn
                // инициализация контроллера
                navigationController?.pushViewController(AddOrChangeOfExecutorVC(
                    title: Constants.Text.labelAddOrChangeViewController.rawValue,
                    textInLabel: Constants.Text.changeExecutor.rawValue,
                    id: executor.id,
                    name: executor.name,
                    surname: executor.surname,
                    dateOfBirth: executor.dateOfBirth,
                    country: matchCountry[keyPath: keyPath] ?? ""
                ), animated: true)
            }
        }
        return tableView.indexPathForSelectedRow
    }
    
    // обработка удаления строки
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // отключаем уведомления
        shouldSendNotifications = false
        // Вызов метода удаления данных в core data
        CoreDataStack.shared.deleteExecutor(CoreDataStack.shared.fetchResultExecutors[indexPath.row]) { success in
            DispatchQueue.main.async { success ? tableView.deleteRows(at: [indexPath], with: .fade) : nil }
        }
        // включаем уведомления
        shouldSendNotifications = true
    }
}
