import UIKit

// MARK: - Class Fish

final class Fish {
    
    // singleton
    static let shared = Fish()
    private init() {}
    
    // MARK: - Properties
    
    // структура с границами экрана
    var safeAreaBounds: ScreenSafeAreaBounds?
    // количество рыбок
    var fishCount: Int?
    // сложность
    var complexity: String? {
        didSet {
            switch complexity {
            case "Легко":
                animationDuration = 3.0
            case "Нормально":
                animationDuration = 2.0
            case "Сложно":
                animationDuration = 1.0
            default:
                break
            }
        }
    }
    // скорость анимации (сложность)
    private var animationDuration: TimeInterval?
    // ссылки на аниматоры
    private var animators: [UIImageView : UIViewPropertyAnimator] = [:]
    
    // MARK: - UI Elements
    
    func getFishView(count: Int) -> [UIImageView] {
        var viewArray: [UIImageView] = []
        guard let safeAreaBounds = safeAreaBounds else { return viewArray }
        for _ in 1...count {
            let view = UIImageView(image: UIImage(named: "fish"))
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(taps))
            view.frame = CGRect(origin: CGPoint(
                x: CGFloat.random(in: safeAreaBounds.widthPoints),
                y: CGFloat.random(in: safeAreaBounds.heightPoints)
            ), size: CGSize(width: 40, height: 40))
            view.contentMode = .scaleAspectFit
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(tapGestureRecognizer)
            viewArray.append(view)
        }
        return viewArray
    }
    
    // MARK: - Public Functionality
    
    func startInfiniteAnimation(_ imageView: UIImageView) {
        guard let safeAreaBounds = self.safeAreaBounds else { return }
        
        // блок вычисления преодолеваемого расстояния для плавности анимации
        /* Расстояние между точками на координатной плоскости
           по теореме Пифагора: |x(a) - x(b)|^2 + |y(a) - y(b)|^2 = AB^2
           формула: AB(dest) = sqrt( (x(a) - x(b))^2 + (y(a) - y(b))^2 )
           функция hypot(:)
        */
        
        // точка, в которой находится view
        let departure = imageView.center
        // точка назначения
        let destination = CGPoint(
            x: CGFloat.random(in: safeAreaBounds.widthPoints),
            y: CGFloat.random(in: safeAreaBounds.heightPoints)
        )
        // дистанция
        let distance = hypot(destination.x - departure.x, destination.y - departure.y)
        // продолжительность анимации
        let duration = animationDuration ?? 0 * distance / 500
        
        // анимация
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut, animations: {
            imageView.center = destination
        })
        
        // добавляем ссылку на аниматор
        animators[imageView] = animator
        
        // повторение после завершения
        animator.addCompletion { [weak self] position in
            guard let self = self else { return }
            if position == .end {
                startInfiniteAnimation(imageView)
            }
        }
        
        // запуск анимации
        animator.startAnimation()
    }
    
    func endAnimationTwists(_ endImageView: UIImageView, superViewCenter: CGPoint) {
        // удаляем экшн, полученный при инициализации
        if let gestureRecognizers = endImageView.gestureRecognizers?[0] {
            endImageView.removeGestureRecognizer(gestureRecognizers)
        }
        
        let animation: CABasicAnimation = {
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.fromValue = 0
            animation.toValue = Double.pi * 2
            animation.duration = 1.0
            animation.repeatCount = .infinity
            return animation
        }()
        
        CATransaction.begin()
        endImageView.layer.add(animation, forKey: "infiniteRotation")
        endAnimation(endImageView, superViewCenter: superViewCenter)
        CATransaction.commit()
    }
    
    // MARK: - Private Functionality
    
    @objc private func taps(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view as? UIImageView else { return }
        // удаляем экшн для предотвращения двойного нажатия
        view.removeGestureRecognizer(sender)
        animators[view]?.stopAnimation(true)
        animators[view]?.finishAnimation(at: .current)
        animators.removeValue(forKey: view)
        
        let animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeInOut, animations: {
            view.center = CGPoint(x: view.center.x, y: -1000)
        })
        
        animator.addCompletion({ position in
            if position == .end {
                animator.stopAnimation(false)
                view.removeFromSuperview()
            }
        })

        animator.startAnimation()
        NotificationCenter.default.post(name: .tapRecognized, object: nil)
    }
    
    // конечные анимации перемещения и увеличения
    private func endAnimation(_ endImageView: UIImageView, superViewCenter: CGPoint) {
        UIView.animate(withDuration: 2.0, delay: 1.0, options: .curveEaseInOut, animations: {
            endImageView.frame.size = CGSize(width: 100, height: 100)
        }, completion: { _ in
            endImageView.layer.removeAllAnimations()
        })
        
        let animator = UIViewPropertyAnimator(duration: 2.0, curve: .easeInOut, animations: {
            endImageView.center = CGPoint(x: superViewCenter.x, y: superViewCenter.y - 25)
        })
        
        animator.startAnimation()
    }
}

// MARK: - Structure ScreenSafeAreaBounds

struct ScreenSafeAreaBounds {
    let safeAreaLayoutFrame: CGRect
    let widthPoints: ClosedRange<CGFloat>
    let heightPoints: ClosedRange<CGFloat>
    
    init(safeAreaLayoutFrame: CGRect) {
        self.safeAreaLayoutFrame = safeAreaLayoutFrame
        self.widthPoints = (safeAreaLayoutFrame.minX + 20)...(safeAreaLayoutFrame.maxX - 20)
        // - 25 (высота label)
        self.heightPoints = (safeAreaLayoutFrame.minY + 20)...(safeAreaLayoutFrame.maxY - 20 - 25)
    }
}

// MARK: - Extension Notification.Name

extension Notification.Name {
    static let tapRecognized = Notification.Name("tapRecognized")
}
