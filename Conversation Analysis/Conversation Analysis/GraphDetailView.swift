
import UIKit
import CoreData


class DetailGraphView: UIViewController{
    //PLACE HOLDER
    @IBOutlet var name: UILabel!
    @IBOutlet var timeStamp: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    var conversation: Conversation!


    
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated)
        //place holder for graphs
        let segments = conversation.getSegments()
        name.text = "\(conversation.hashValue)"
        timeStamp.text = "\(conversation.duration)"
        if let segment = segments.first {
            // Configure Cell
            DispatchQueue.global().async{
                if let data = try? Data(contentsOf: segment.image!){
                    if let image = UIImage(data: data){
                        DispatchQueue.main.async{
                            self.imageView.image = image
                        }
                    }
                }
            }
        }
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backAction))
//

    }
    
}

