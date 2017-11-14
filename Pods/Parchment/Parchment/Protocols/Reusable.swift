import UIKit

protocol Reusable: class {
  static var reuseIdentifier: String { get }
}

extension Reusable where Self: UIView {
  static var reuseIdentifier: String {
    return String(describing: self)
  }
}

extension UICollectionReusableView: Reusable {}

extension UICollectionViewLayout {
  
  func registerDecorationView<T: UICollectionReusableView>(_: T.Type) {
    register(T.self, forDecorationViewOfKind: T.reuseIdentifier)
  }
  
}

extension UICollectionView {
  
  func registerReusableCell<T: UICollectionViewCell>(_ cellType: T.Type) {
    self.register(cellType.self, forCellWithReuseIdentifier: cellType.reuseIdentifier)
  }
  
  func dequeueReusableCell<T: UICollectionViewCell>(indexPath: IndexPath, cellType: T.Type = T.self) -> T {
    guard let cell = self.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
      fatalError("could not dequeue reusable cell with identifier \(cellType.reuseIdentifier)")
    }
    return cell
  }
  
}
