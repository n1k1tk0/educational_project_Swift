import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    // переменная-флаг отражает факт размещения view
    private var flag = false
    // переменная-флаг для игнорирования нажатия до конца игры
    private var endFlag = false
    private let defaults = UserDefaults.standard
    private var fishCatchCurrentCount = 0 {
        didSet {
            defaults.set(defaults.integer(forKey: "fishCatchCount") + 1, forKey: "fishCatchCount")
        }
    }
    
    // MARK: - UI Elements

    @IBOutlet weak var fishCatchCurrentCountLabel: UILabel!
    
    private lazy var winImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "win"))
        view.contentMode = .scaleAspectFit
        view.frame.size = CGSize(width: 100, height: 100)
        return view
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotifications()
        createTapGestureRecognized()
    }
    
    override func viewDidLayoutSubviews() {
        gettingFrameDimensions()
        flag ? nil : setupViews()
        flag = true
    }
    
    // MARK: - Functionality
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(fishCatch), name: .tapRecognized, object: nil)
    }
    
    private func createTapGestureRecognized() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupViews() {
        view.addSubviews(Fish.shared.getFishView(count: Fish.shared.fishCount ?? 0))
        fishCatchCurrentCountLabel.text = "Поймано 🐠: \(fishCatchCurrentCount) из \(Fish.shared.fishCount ?? 0)"
    }
    
    private func gettingFrameDimensions() {
        // передача layoutFrame в Fish
        Fish.shared.safeAreaBounds = ScreenSafeAreaBounds(safeAreaLayoutFrame: self.view.safeAreaLayoutGuide.layoutFrame)
    }
    
    @objc private func fishCatch() {
        // увеличиваем счетчик при каждом тапе на рыбку
        fishCatchCurrentCount += 1
        // анимируем подсчет
        UIView.transition(with: fishCatchCurrentCountLabel, duration: 0.1, options: .transitionCrossDissolve, animations: {
            self.fishCatchCurrentCountLabel.text = "Поймано 🐠: \(self.fishCatchCurrentCount) из \(Fish.shared.fishCount ?? 0)"
        })
        
        if Fish.shared.fishCount ?? 0 == fishCatchCurrentCount {
            deleteCountLabelAnimation()
            startEndAnimation(setupViewsEnd())
        }
    }
    
    private func deleteCountLabelAnimation() {
        UIView.animate(withDuration: 2.0, delay: 1.0, animations: { [weak self] in
            guard let self = self else { return }
            self.fishCatchCurrentCountLabel.transform = self.fishCatchCurrentCountLabel.transform.translatedBy(
                x: 0,
                y: self.view.bounds.height * 2
            )
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            self.fishCatchCurrentCountLabel.removeFromSuperview()
        })
    }
    
    private func setupViewsEnd() -> UIImageView {
        let endImageView = Fish.shared.getFishView(count: 1)[0]
        view.addSubview(endImageView)
        view.addSubview(winImageView)
        endImageView.center = CGPoint(x: view.center.x, y: -1000)
        winImageView.center = CGPoint(x: -300, y: self.view.center.y + 75)
        return endImageView
    }
    
    private func startEndAnimation(_ endImageView: UIImageView) {
        Fish.shared.endAnimationTwists(endImageView, superViewCenter: view.center)
        UIView.animate(withDuration: 2, delay: 1, options: .curveEaseInOut, animations: { [weak self] in
            guard let self = self else { return }
            self.winImageView.center.x = self.view.center.x
        }, completion: { [weak self] result in
            guard let self = self else { return }
            self.endFlag = result
        })
    }
    
    @objc private func handleTap() {
        endFlag ? _ = navigationController?.popViewController(animated: endFlag) : nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .tapRecognized, object: nil)
    }
}

// MARK: - Extension UIView

extension UIView {
    
    // метод для добавления массива views
    func addSubviews(_ subviews: [UIView]) {
        for subview in subviews {
            addSubview(subview)
            // запуск анимации
            guard let imageView = subview as? UIImageView else { return }
            Fish.shared.startInfiniteAnimation(imageView)
        }
    }
}
