import UIKit
import Combine

open class AutoDetachingViewController: UIViewController, ViewControllerScope, UIGestureRecognizerDelegate {
    
    private var subject = PassthroughSubject<ViewControllerLifecycleEvent, Never>()
    
    public var lifecycle: AnyPublisher<ViewControllerLifecycleEvent, Never> {
        subject.eraseToAnyPublisher()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        subject.send(.viewDidLoad)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subject.send(.viewDidAppear)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subject.send(.viewWillAppear)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        subject.send(.viewWillDisappear)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        subject.send(.viewDidDisappear)
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureRecognizer == navigationController?.interactivePopGestureRecognizer
    }
}

