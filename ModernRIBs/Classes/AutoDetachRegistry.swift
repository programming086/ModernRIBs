import Combine
import UIKit

public enum ViewControllerLifecycleEvent {
    case viewDidLoad
    case viewWillAppear
    case viewDidAppear
    case viewWillDisappear
    case viewDidDisappear
}

public protocol ViewControllerScope: AnyObject {
    var lifecycle: AnyPublisher<ViewControllerLifecycleEvent, Never> { get }
}

public protocol AutoDetachRegistering: AnyObject {
    func attachViewableChild(_ child: ViewableRouting, with parent: Routing)
    func attachViewableChild(_ child: ViewableRouting, with parent: Routing, detachedHandler: (() -> Void)?)
}

public final class AutoDetachRegistry: AutoDetachRegistering, AutoDetachHandlerListener {
    public init() {}

    public func attachViewableChild(_ child: ViewableRouting, with parent: Routing) {
        attachViewableChild(child, with: parent, detachedHandler: nil)
    }

    public func attachViewableChild(_ child: ViewableRouting, with parent: Routing, detachedHandler: (() -> Void)?) {
        parent.attachChild(child)
        let handler = AutoDetachHandler(child: child, parent: parent, detachedHandler: detachedHandler)
        handler.listener = self
        handlers.append(handler)
    }

    func didDetach(_ handler: AutoDetachHandler) {
        if let index = handlers.firstIndex(where: { $0 === handler }) {
            handlers.remove(at: index)
        }
    }

    private var handlers: [AutoDetachHandler] = []
}

protocol AutoDetachHandlerListener: AnyObject {
    func didDetach(_ handler: AutoDetachHandler)
}

final class AutoDetachHandler {
    weak var listener: AutoDetachHandlerListener?

    init(child: ViewableRouting, parent: Routing, detachedHandler: (() -> Void)?) {
        self.child = child
        self.parent = parent
        self.detachedHandler = detachedHandler
        subscribeChildLifecycle()
    }

    func detachIfNeeded() {
        guard let child = child else {
            detachedHandler?()
            listener?.didDetach(self)
            return
        }

        guard shouldDetach(child.viewControllable) else { return }

        parent?.detachChild(child)
        detachedHandler?()
        listener?.didDetach(self)
    }

    private weak var parent: Routing?
    private weak var child: ViewableRouting?
    private let detachedHandler: (() -> Void)?
    private var cancellables = Set<AnyCancellable>()
    private let dismissSubject = PassthroughSubject<Void, Never>()

    private func subscribeChildLifecycle() {
        guard let vc = child?.viewControllable as? ViewControllerScope else {
            assertionFailure("Auto detach only supports ViewControllerScope")
            return
        }
        let parentEvent = vc.lifecycle.eraseToAnyPublisher()
        
        let didDisappear = parentEvent
            .filter { event in event == .viewDidDisappear }
            .map { _ in ViewControllerLifecycleEvent.viewDidDisappear }
        
        let parentDidMove = parentEvent
            .scan((nil, nil)) { previous, current in (previous.1, current) }
            .compactMap { pair -> ViewControllerLifecycleEvent? in
                guard let pre = pair.0, pair.1 == nil else { return nil }
                return pre
            }
        
        let dismiss = dismissSubject
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .map { _ in ViewControllerLifecycleEvent.viewDidDisappear }

        Publishers.Merge3(didDisappear, parentDidMove, dismiss)
            .sink { [weak self] _ in
                self?.detachIfNeeded()
            }
            .store(in: &cancellables)
    }

    private func shouldDetach(_ viewController: ViewControllable) -> Bool {
        let vc = viewController.uiviewController
        let navigationController = vc.navigationController

        if (navigationController?.isBeingDismissed ?? false) || vc.isBeingDismissed {
            dismissSubject.send(())
            return false
        }

        let isVcGone = vc.parent == nil && vc.presentingViewController == nil && vc.view.window == nil

        guard let navController = navigationController else {
            return isVcGone
        }

        return isVcGone || (navController.parent == nil && navController.presentingViewController == nil && vc.view.window == nil)
    }
}

