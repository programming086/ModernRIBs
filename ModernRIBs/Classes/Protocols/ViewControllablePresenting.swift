import UIKit

/// A protocol for the presenting and dismissing of ViewControllable and UIViewController.
/// A custom ViewControllable protocol might conform to this rather than recreate custom presenting and dismissing methods.
/// @mockable
public protocol ViewControllablePresenting: ViewControllable {
    /// Presents the view controller with modalPresentationStyle = .OverCurrentContext
    /// If you are presenting a modal over a map, this must be used to prevent map layout issues
    ///
    /// - parameter viewController: the viewController to present
    /// - parameter animated:       animated flag
    /// - parameter completion:     completion block
    func presentViewControllerOverCurrentContext(_ viewController: ViewControllable, animated: Bool, completion: (() -> Void)?)

    /// Presents a view controller modally.
    ///
    /// - parameter viewController: the viewController to present
    /// - parameter animated:       animated flag
    /// - parameter completion:     completion block
    func present(_ viewController: ViewControllable, animated: Bool, completion: (() -> Void)?)

    /// Dismisses the view controller that was presented modally by the view controller.
    ///
    /// - parameter animated:       animated flag
    /// - parameter completion:     completion block
    func dismiss(animated: Bool, completion: (() -> Void)?)
}

/// Default implementation of ViewControllablePresenting for ViewControllable, backed by the common UIViewController's presentation methods.
extension ViewControllablePresenting {
    /// Presents the view controller with modalPresentationStyle = .OverCurrentContext animated.
    /// If you are presenting a modal over a map, this must be used to prevent map layout issues
    ///
    /// - parameter viewController: the viewController to present
    public func presentViewControllerOverCurrentContext(_ viewController: ViewControllable) {
        presentViewControllerOverCurrentContext(viewController, animated: true, completion: nil)
    }

    /// Presents the view controller with modalPresentationStyle = .OverCurrentContext animated.
    /// If you are presenting a modal over a map, this must be used to prevent map layout issues
    ///
    /// - parameter viewController: the viewController to present
    /// - parameter completion:     completion block
    public func presentViewControllerOverCurrentContext(_ viewController: ViewControllable, completion: (() -> Void)?) {
        presentViewControllerOverCurrentContext(viewController, animated: true, completion: completion)
    }

    /// Presents the view controller with modalPresentationStyle = .OverCurrentContext
    /// If you are presenting a modal over a map, this must be used to prevent map layout issues
    ///
    /// - parameter viewController: the viewController to present
    /// - parameter animated:       animated flag
    public func presentViewControllerOverCurrentContext(_ viewController: ViewControllable, animated: Bool) {
        presentViewControllerOverCurrentContext(viewController, animated: animated, completion: nil)
    }

    public func presentViewControllerOverCurrentContext(_ viewController: ViewControllable, animated: Bool, completion: (() -> Void)?) {
        viewController.uiviewController.modalPresentationStyle = .overCurrentContext
        uiviewController.present(viewController.uiviewController, animated: animated, completion: completion)
    }

    /// Presents a view controller modally.
    ///
    /// - parameter viewController: the viewController to present
    /// - parameter animated:       animated flag
    public func present(_ viewController: ViewControllable, animated: Bool) {
        present(viewController, animated: animated, completion: nil)
    }

    /// Presents a view controller modally.
    ///
    /// - parameter viewController: the viewController to present
    /// - parameter completion:     completion block
    public func present(_ viewController: ViewControllable, completion: (() -> Void)?) {
        present(viewController, animated: true, completion: completion)
    }

    /// Presents a view controller modally.
    ///
    /// - parameter viewController: the viewController to present
    public func present(_ viewController: ViewControllable) {
        present(viewController, animated: true, completion: nil)
    }

    public func present(_ viewController: ViewControllable, animated: Bool, completion: (() -> Void)?) {
        uiviewController.present(viewController.uiviewController, animated: animated, completion: completion)
    }

    /// Dismisses a view controller  animated.
    ///
    /// - parameter completion: completion block
    public func dismiss(completion: (() -> Void)?) {
        dismiss(animated: true, completion: completion)
    }

    /// Dismisses a view controller.
    ///
    /// - parameter animated: animated flag
    public func dismiss(animated: Bool) {
        dismiss(animated: animated, completion: nil)
    }

    /// Dismisses a view controller  animated.
    public func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    public func dismiss(animated: Bool, completion: (() -> Void)?) {
        uiviewController.dismiss(animated: animated, completion: completion)
    }
}

extension UIViewController: ViewControllablePresenting {}

