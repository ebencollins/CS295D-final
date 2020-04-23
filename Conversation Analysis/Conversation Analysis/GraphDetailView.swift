import UIKit
import CoreData
import NotificationBannerSwift

class DetailGraphView: UIViewController {
    @IBOutlet var contentView: UIView!
    @IBOutlet var name: UILabel!
    @IBOutlet weak var uploadedStateIcon: UIImageView!
    
    var conversation: Conversation!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set name of conversation
        name.text = conversation.uuid?.uuidString
        
        // iterate through all segments and append to scroll view
        var y = 0
        for segment in conversation.getSegments() {
            // get the segments image data
            let imageData = (try? Data(contentsOf: segment.image))!
            DispatchQueue.main.async {
                // create image view with imageData
                let imageView = UIImageView(image: UIImage(data: imageData))
                imageView.frame = CGRect(x: 0, y: y, width: 300, height: 150)
                
                // create label with segment's time interval
                let interval = UILabel(frame: CGRect(x: 0, y: y, width: 300, height: 20))
                interval.textAlignment = NSTextAlignment.center
                interval.text = "\(segment.start_time) - \(segment.start_time + 15) sec."
                
                // add image and label to ui view
                self.contentView.addSubview(imageView)
                self.contentView.addSubview(interval)
                
                // increment y value
                y += 150
            }
        }
        if !conversation.uploaded {
            uploadedStateIcon.image = UIImage(systemName: "icloud.slash")
            uploadedStateIcon.tintColor = UIColor.red
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !conversation.uploaded {
            ConversationsAPIClient.upload(conversation: conversation, completion: {result,message  in
                var banner: NotificationBanner
                if result{
                    banner = NotificationBanner(title: "Upload complete", subtitle: message, style: .success)
                    self.uploadedStateIcon.image = UIImage(systemName: "icloud")
                    self.uploadedStateIcon.tintColor = UIColor.green
                }else{
                    banner = NotificationBanner(title: "Upload failed", subtitle: message, style: .danger)
                    self.uploadedStateIcon.image = UIImage(systemName: "icloud.slash")
                    self.uploadedStateIcon.tintColor = UIColor.red
                }
                banner.show()
            })
        }
    }
}
