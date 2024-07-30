import SnapKit

class AddOrChangeOfExecutorVC: UIViewController {
    
    // MARK: - Properties
    
    private var idExecutor: String?
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Constants.Font.systemFontBold
        return titleLabel
    }()
    
    private lazy var nameTextField: UITextField = {
        let nameTextField = UITextField()
        nameTextField.placeholder = Constants.Text.placeholderNameTextField.rawValue
        nameTextField.borderStyle = .roundedRect
        nameTextField.clearButtonMode = .whileEditing
        nameTextField.adjustsFontSizeToFitWidth = true
        nameTextField.tag = 1
        nameTextField.delegate = self
        return nameTextField
    }()
    
    private lazy var surnameTextField: UITextField = {
        let surnameTextField = UITextField()
        surnameTextField.placeholder = Constants.Text.placeholderSurnameTextField.rawValue
        surnameTextField.borderStyle = .roundedRect
        surnameTextField.clearButtonMode = .whileEditing
        surnameTextField.adjustsFontSizeToFitWidth = true
        surnameTextField.tag = 2
        surnameTextField.delegate = self
        return surnameTextField
    }()
    
    private lazy var dateOfBirthTextField: UITextField = {
        let dateOfBirthTextField = UITextField()
        dateOfBirthTextField.placeholder = Constants.Text.placeholderDateOfBirthTextField.rawValue
        dateOfBirthTextField.borderStyle = .roundedRect
        dateOfBirthTextField.clearButtonMode = .whileEditing
        dateOfBirthTextField.tag = 3
        dateOfBirthTextField.keyboardType = .numberPad
        dateOfBirthTextField.delegate = self
        return dateOfBirthTextField
    }()
    
    private lazy var countryTextField: UITextField = {
        let countryTextField = UITextField()
        countryTextField.placeholder = Constants.Text.placeholderCountryTextField.rawValue
        countryTextField.borderStyle = .roundedRect
        countryTextField.clearButtonMode = .whileEditing
        countryTextField.tag = 4
        countryTextField.delegate = self
        countryTextField.inputView = countryPickerView
        return countryTextField
    }()
    
    private lazy var addExecutorButton: UIButton = {
        let addExecutorButton = UIButton(type: .system)
        addExecutorButton.layer.borderColor = UIColor.systemBlue.cgColor
        addExecutorButton.layer.borderWidth = 0.7
        addExecutorButton.layer.cornerRadius = 10
        addExecutorButton.titleLabel?.font = Constants.Font.systemFontBold
        addExecutorButton.backgroundColor = .systemBlue
        addExecutorButton.setTitle("Add", for: .normal)
        addExecutorButton.tintColor = .white
        addExecutorButton.addTarget(self, action: #selector(addOrChangeExecutor), for: .touchUpInside)
        return addExecutorButton
    }()
    
    private lazy var countryPickerView: UIPickerView = {
        let countryPickerView = UIPickerView()
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        return countryPickerView
    }()
    
    // MARK: - Init
    
    init(title: String, textInLabel: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.titleLabel.text = textInLabel
    }
    
    convenience init(title: String, textInLabel: String, id: String, name: String, surname: String, dateOfBirth: Date, country: String) {
        let dateForm = DateFormatter()
        dateForm.dateFormat = "dd.MM.yyyy"
        self.init(title: title, textInLabel: textInLabel)
        self.addExecutorButton.setTitle(textInLabel, for: .normal)
        self.idExecutor = id
        self.nameTextField.text = name
        self.surnameTextField.text = surname
        self.dateOfBirthTextField.text = dateForm.string(from: dateOfBirth)
        self.countryTextField.text = country
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // удаление наблюдателя
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: dateOfBirthTextField)
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupViews()
        setupConstraints()
        setupNotifications()
    }

    private func setupViews() {
        self.view.addSubview(titleLabel)
        self.view.addSubview(nameTextField)
        self.view.addSubview(surnameTextField)
        self.view.addSubview(dateOfBirthTextField)
        self.view.addSubview(countryTextField)
        self.view.addSubview(addExecutorButton)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
        surnameTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(30)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
        dateOfBirthTextField.snp.makeConstraints { make in
            make.top.equalTo(surnameTextField.snp.bottom).offset(30)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
        countryTextField.snp.makeConstraints { make in
            make.top.equalTo(dateOfBirthTextField.snp.bottom).offset(30)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
        addExecutorButton.snp.makeConstraints { make in
            make.top.equalTo(countryTextField.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textFieldDidChange),
            name: UITextField.textDidChangeNotification,
            object: dateOfBirthTextField
        )
    }
}

// MARK: - Extension AddOrChangeOfExecutorVC

extension AddOrChangeOfExecutorVC: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - UITextFieldDelegate Methods
    
    // метод отслеживания введенных значений пользователем
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField.tag {
        // для nameTextField и surnameTextFiled
        case 1, 2:
            // посимвольный ввод; стирание; запрет на ввод чисел
            return !Constants.RegularExpression.regexLetters.matches(
                in: string,
                range: NSRange(
                    location: 0,
                    length: string.utf16.count)
            ).isEmpty ? true : false

        // для dateOfBirthTextField
        case 3:

            // получение текста для изъятия фактической длины
            guard let text = textField.text else { return false }

            // проверка вводимого символа на соответствие правилам regex
            if !Constants.RegularExpression.regexDateOfBirth.matches(
                in: string,
                range: NSRange(
                    location: 0,
                    length: string.utf16.count)
            ).isEmpty && text.count < 10 {

                // проверка длины набранного текста для выставления разделителей для ДР
                switch text.count {
                case 2, 5:
                    // выставление/блокировка автоматического разделителя
                    if string != "" { textField.text?.insert(".", at: text.endIndex) }
                default:
                    break
                }

                return true
            // для обеспечения работы стирания если количество символов <= 10
            } else if !Constants.RegularExpression.regexDateOfBirth.matches(
                in: string,
                range: NSRange(
                    location: 0,
                    length: string.utf16.count)
            ).isEmpty && text.count <= 10 && string == "" {
                return true
            } else {
                return false
            }
        default:
            return false
        }
    }

    // метод "перепрыгивания" между UI
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            surnameTextField.becomeFirstResponder()
        case surnameTextField:
            dateOfBirthTextField.becomeFirstResponder()
        case countryTextField:
            countryTextField.resignFirstResponder()
        default:
            break
        }
        return true
    }

    @objc private func textFieldDidChange(notification: Notification) {
        guard let textField = notification.object as? UITextField else { return }
        guard let text = textField.text else { return }
        switch text.count {
        case 10:
            if dateCheck(text) {
                countryTextField.becomeFirstResponder()
            }
        default:
            break
        }
    }
    
    // MARK: - add or change executor functionality
    
    @objc private func addOrChangeExecutor() {
        let dateForm = DateFormatter()
        dateForm.dateFormat = "dd.MM.yyyy"
        CoreDataStack.shared.addExecutor(
            id: {
                guard let id = idExecutor else { return nil }
                return id
            }(),
            name: nameTextField.text ?? "",
            surname: surnameTextField.text ?? "",
            dateOfBirth: dateForm.date(from: dateOfBirthTextField.text ?? "") ?? Date(),
            // получение кода страны по её названию из уже загруженных данных
            countryCode: {
                // получение языка системы для обращения к нужному свойству
                let systemLanguage = NSLocale.preferredLanguages.first?.components(separatedBy: "-").first ?? ""
                // выбор пути на основе языка
                let keyPath = systemLanguage == "ru" ? \CountryEntity.nameRu : \CountryEntity.nameEn
                // фильтрация массива для поиска нужной страны
                guard let matchCountry = CoreDataStack.shared.fetchResultCountries.filter({
                    $0[keyPath: keyPath] == countryTextField.text
                }).first else { return "" }
                    return matchCountry.code
            }(),
            typeOfOperation: titleLabel.text ?? ""
        )
        navigationController?.popViewController(animated: true)
    }

    private func dateCheck(_ string: String) -> Bool {
        let dateForm = DateFormatter()
        dateForm.dateFormat = "dd.MM.yyyy"
        return dateForm.date(from: string) != nil ? true : false
    }

    // MARK: - UIPickerViewDelegate, UIPickerViewDataSource methods

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        CoreDataStack.shared.fetchResultCountries.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // проверка существование индекса в массиве
        if CoreDataStack.shared.fetchResultCountries.indices.contains(row) {
            // получение текущей страны
            let country = CoreDataStack.shared.fetchResultCountries[row]
            // возврат названия в пикервью
            return NSLocale.preferredLanguages.first?.components(separatedBy: "-").first == "ru" ? country.nameRu : country.nameEn
        } else {
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // проверка существование индекса в массиве
        if CoreDataStack.shared.fetchResultCountries.indices.contains(row) {
            // получение текущей страны
            let country = CoreDataStack.shared.fetchResultCountries[row]
            // ввод названия страны в текстфилд
            countryTextField.text = NSLocale.preferredLanguages.first?.components(separatedBy: "-").first == "ru" ? country.nameRu : country.nameEn
        }
        countryTextField.resignFirstResponder()
    }
}
