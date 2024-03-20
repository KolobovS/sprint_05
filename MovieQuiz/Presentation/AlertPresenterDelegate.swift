import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func show(alert: UIAlertController)
}
