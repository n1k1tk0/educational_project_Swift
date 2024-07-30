import UIKit


class StartViewController: UIViewController {
    
    // MARK: - Properties
    
    private let fishCountArray = Array(1...100)
    private let complexityArray = ["Легко", "Нормально", "Сложно"]
    private let defaults = UserDefaults.standard
    
    // MARK: - UI Elements
    
    @IBOutlet weak var statisticsLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var fishCountLabel: UILabel!
    @IBOutlet weak var fishCountPickerView: UIPickerView!
    
    @IBOutlet weak var complexityLabel: UILabel!
    @IBOutlet weak var complexityPickerView: UIPickerView!
    
    
    // MARK: - Functionality
    
    @IBAction func clearButton(_ sender: UIButton) {
        defaults.set(0, forKey: "fishCatchCount")
        UIView.transition(with: statisticsLabel, duration: 0.5, options: .transitionCrossDissolve, animations: { [weak self] in
            guard let self = self else { return }
            self.statisticsLabel.text = "Суммарный улов: \(self.defaults.integer(forKey: "fishCatchCount"))🐠"
        })
    }
    
    @IBAction func playButton(_ sender: UIButton) {
        // задаем параметры игры
        Fish.shared.fishCount = fishCountArray[fishCountPickerView.selectedRow(inComponent: 0)]
        Fish.shared.complexity = complexityArray[complexityPickerView.selectedRow(inComponent: 0)]
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        settingValueFromUserDefaults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statisticsLabel.text = "Суммарный улов: \(defaults.integer(forKey: "fishCatchCount"))🐠"
    }
    
    private func setupViews() {
        fishCountPickerView.delegate = self
        fishCountPickerView.dataSource = self
        complexityPickerView.delegate = self
        complexityPickerView.dataSource = self
        
        statisticsLabel.text = "Суммарный улов: \(defaults.integer(forKey: "fishCatchCount"))🐠"
    }
    
    private func settingValueFromUserDefaults() {
        if defaults.integer(forKey: "fishCatchCount") == 0 {
            defaults.set(0, forKey: "fishCatchCount")
        }
    }
}

// MARK: - Extension UIPickerViewDelegate, UIPickerViewDataSource

extension StartViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return 100
        case 2:
            return 3
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return fishCountArray[row].description
        case 2:
            return complexityArray[row]
        default:
            return nil
        }
    }

}
