import UIKit

//swiftlint:disable discouraged_optional_collection
/// A protocol for the pushing and poppoing of ViewControllable and UIViewController.
/// A custom ViewControllable protocol might conform to this rather than recreate custom pushing and popping methods.
/// @mockable
public protocol ViewControllablePushing: AnyObject {
    func pushViewControllable(_ viewControllable: ViewControllable, animated: Bool)
    func pushViewController(_ viewController: UIViewController, animated: Bool)
    @discardableResult func popViewController(animated: Bool) -> UIViewController?
    @discardableResult func popToViewController(viewController: UIViewController, animated: Bool) -> [UIViewController]?
    @discardableResult func popToRootViewController(animated: Bool) -> [UIViewController]?
}

/// Default implementation of ViewControllablePushing for ViewControllable, backed by the common UIViewController's modal methods.
/// Note that these methods utilize the UIViewController property of `navigationController`,
///  which is not compatible with the legacy `ThemeableNavigationViewController`. It does, however, work with the new `ThemeableNavigationController`.
public extension ViewControllablePushing where Self: ViewControllable {

    func pushViewControllable(_ viewControllable: ViewControllable, animated: Bool) {
        uiviewController.navigationController?.pushViewController(viewControllable.uiviewController, animated: animated)
    }

    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        uiviewController.navigationController?.pushViewController(viewController, animated: animated)
    }

    @discardableResult
    func popViewController(animated: Bool) -> UIViewController? {
        return uiviewController.navigationController?.popViewController(animated: animated)
    }

    @discardableResult
    func popToViewController(viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        return uiviewController.navigationController?.popToViewController(viewController, animated: animated)
    }

    @discardableResult
    func popToRootViewController(animated: Bool) -> [UIViewController]? {
        return uiviewController.navigationController?.popToRootViewController(animated: animated)
    }
}

