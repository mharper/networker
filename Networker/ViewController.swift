//
//  ViewController.swift
//  Networker
//
//  Created by Michael Harper on 10/29/15.
//  Copyright © 2015 Standalone Code LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  let chuckQueue = NSOperationQueue()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBOutlet weak var enableCellularSwitch: UISwitch!
  @IBOutlet weak var chuckLabel: UILabel!
  
  @IBAction func chuckAction(sender: AnyObject) {
    let chuckOperation = ChuckOperation(enableCellularData: enableCellularSwitch.on) { (chuckism) -> () in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.chuckLabel.text = chuckism
      })
    }
    chuckQueue.addOperation(chuckOperation)
  }
}

public class ChuckOperation: NSOperation {
  let chuckURL = "http://api.icndb.com/jokes/random"
  
  let handler:(String) -> ()
  let enableCellularData: Bool
  
  public init(enableCellularData: Bool, handler: (String) -> ()) {
    self.enableCellularData = enableCellularData
    self.handler = handler
  }
  
  override public func main() {
      let request = chuckRequest()
      let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
      sessionConfiguration.allowsCellularAccess = enableCellularData
      let session = NSURLSession(configuration: sessionConfiguration)
      session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
        if let apiError = error {
          self.handler("Error chucking: \(apiError.localizedDescription)")
        }
        else if let data = data {
          do {
            let chuckData = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? NSDictionary
            if let chuckValue = chuckData?["value"], chuckJoke = chuckValue["joke"] as? String {
              self.handler(chuckJoke)
            }
            else {
              self.handler("Chuck fail!")
            }
          }
          catch {
            self.handler("Oh no, Chuck!")
          }
        }
      }).resume()
  }
  
  func chuckRequest() -> NSURLRequest {
    let apiRequest = NSMutableURLRequest(URL: NSURL(string: chuckURL)!)
    apiRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    apiRequest.addValue("application/json", forHTTPHeaderField: "Accept")
    return apiRequest
  }
}
