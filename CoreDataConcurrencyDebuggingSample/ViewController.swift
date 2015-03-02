//
//  ViewController.swift
//  CoreDataConcurrencyDebuggingSample
//
//  Created by Hiroki Yoshifuji on 2015/03/02.
//  Copyright (c) 2015年 Hiroki Yoshifuji. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func context() -> NSManagedObjectContext? {
        if let app = UIApplication.sharedApplication().delegate as? AppDelegate {
            return app.managedObjectContext
        }
        return nil
    }
    @IBAction func tappedMainThreadCreate(sender: AnyObject) {
        println("tappedMainThreadCreate")
        
        if let context = context() {
            let user = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context) as NSManagedObject
            user.setValue("main " + NSDate().description, forKey: "name")
            context.save(nil)
            
            println("create user")
        }
    }

    @IBAction func tappedBackgroundThreadCreate(sender: AnyObject) {
        println("tappedBackgroundThreadCreate")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if let context = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                let user = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context) as NSManagedObject
                user.setValue("main " + NSDate().description, forKey: "name")
                context.save(nil)
                
                println("create user")
            }
        })
    }
    
    @IBAction func tappedMainThreadSelect(sender: AnyObject) {
        println("tappedMainThreadSelect")
        
        if let context = context() {
            
            let request = NSFetchRequest(entityName: "User")
            let array:NSArray! = context.executeFetchRequest(request, error: nil)
            
            for data in array {
                println(data.valueForKey("name"))
            }
        }
    }
    
    @IBAction func tappedBackgroundThreadSelect(sender: AnyObject) {
        println("tappedBackgroundThreadSelect")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if let context = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                let request = NSFetchRequest(entityName: "User")
                let array:NSArray! = context.executeFetchRequest(request, error: nil)
                
                for data in array {
                    println(data.valueForKey("name"))
                }
            }
        })
    }
}

