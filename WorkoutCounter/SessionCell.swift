import UIKit

final class SessionCell: UITableViewCell, ConfigurableCell {
    
    typealias T = Session
    static let identifier: String = "SessionCell"
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelPreviousSession: UILabel!
    @IBOutlet weak var labelCurrentSession: UILabel!
    
    func configure(with object: Session) {
        labelTitle?.text = (object.user?.name ?? "") +
                          (object.active ? "" : " - закончил")
        labelCurrentSession?.text = object.setsDescription
    }
}
