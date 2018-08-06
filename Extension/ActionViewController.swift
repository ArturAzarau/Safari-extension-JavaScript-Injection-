//
//  ActionViewController.swift
//  Extension
//
//  Created by Артур Азаров on 06.08.2018.
//  Copyright © 2018 Артур Азаров. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet weak var script: UITextView!

    private var pageTitle = ""
    private var pageURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        if let inputItem = extensionContext!.inputItems.first as? NSExtensionItem, let itemProvider = inputItem.attachments?.first as? NSItemProvider {
            itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [unowned self] (dict, error) in
                let itemDictionary = dict as! NSDictionary
                let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! NSDictionary
                self.pageTitle = javaScriptValues["title"] as! String
                self.pageURL = javaScriptValues["URL"] as! String
                
                DispatchQueue.main.async {
                    self.title = self.pageTitle
                }
            }
        }
        
        // Register for notifications to handle keyboard
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustKeyboard(notification:)), name: .UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustKeyboard(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }

    @objc private func adjustKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == .UIKeyboardWillHide {
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
            script.scrollIndicatorInsets = script.contentInset
            
            let selectedRange = script.selectedRange
            script.scrollRangeToVisible(selectedRange)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done() {
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        
        extensionContext?.completeRequest(returningItems: [item])
    }

}
