
import UIKit

class DetailGraphView: UIViewController{
    //PLACE HOLDER
    @IBOutlet var name: UILabel!
    @IBOutlet var timeStamp: UILabel!


    var item: Item!
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated)
        //place holder for graphs
        
        name.text = item.name
        timeStamp.text = item.dateCreated
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backAction))
//

    }

}
