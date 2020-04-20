import UIKit
import CoreData

class DetailGraphView: UIViewController{
    @IBOutlet var contentView: UIView!
    @IBOutlet var name: UILabel!
    
    var conversation: Conversation!

    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated)
        // set name of conversation
        name.text = "\(conversation.hashValue)"
        
        // iterate through all segments and append to scroll view
        var n = 0
        for segment in conversation.getSegments() {
            // add image to view
            DispatchQueue.main.async {
                if let imageData = try? Data(contentsOf: segment.image) {
                    let imageView = UIImageView(image: UIImage(data: imageData))
                    imageView.frame = CGRect(x: 0, y: n, width: 300, height: 150)
                    self.contentView.addSubview(imageView)
                }
            }
            n += 50
        }
        
        // place holder for graphs
//        let segments = conversation.getSegments()
//        if let segment = segments.first {
//            // Configure Cell
//            DispatchQueue.global().async{
//                if let data = try? Data(contentsOf: segment.image){
//                    if let image = UIImage(data: data){
//                        DispatchQueue.main.async{
//                            self.imageView.image = image
//                        }
//                    }
//                }
//            }
//        }
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(backAction))
//
    }
}
