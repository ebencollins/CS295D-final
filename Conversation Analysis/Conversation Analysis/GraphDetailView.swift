import UIKit
import CoreData
import NotificationBannerSwift

class DetailGraphView: UIViewController {
    @IBOutlet var contentView: UIView!
    @IBOutlet var name: UILabel!
    
    var conversation: Conversation!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set name of conversation
        name.text = "\(conversation.hashValue)"
        
        // iterate through all segments and append to scroll view
        var y = 0
        for segment in conversation.getSegments() {
            // get the segments image data
            let imageData = (try? Data(contentsOf: segment.image))!
            DispatchQueue.main.async {
                // create image view w/ imageData
                let imageView = UIImageView(image: UIImage(data: imageData))
                imageView.frame = CGRect(x: 0, y: y, width: 300, height: 150)
                
                // add image to ui view
                self.contentView.addSubview(imageView)
                
                // increment y value
                y += 150
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !conversation.uploaded {
            ConversationsAPIClient.upload(conversation: conversation, completion: {result,message  in
                var banner: NotificationBanner
                if result{
                    banner = NotificationBanner(title: "Upload complete", subtitle: message, style: .success)
                }else{
                    banner = NotificationBanner(title: "Upload failed", subtitle: message, style: .danger)
                }
                banner.show()
            })
        }
    }
}
