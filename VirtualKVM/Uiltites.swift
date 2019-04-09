//
//  Uiltites.swift
//  VirtualKVM
//
//  Created by Soneé John on 5/31/18.
//  Copyright © 2018 Fast Wombat. All rights reserved.
//

import Cocoa
import SwiftyBeaver

@objcMembers class Uiltites: NSObject {
  
  static let shared = Uiltites()
  var log: SwiftyBeaver.Type?
  
  @objc func setupLogging() {
    guard log == nil else { return }
    
    log = SwiftyBeaver.self
   
    let console = ConsoleDestination()
    console.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"
    
    let file = FileDestination()
    file.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"
    
    log?.addDestination(console)
    log?.addDestination(file)
  }
  
  @objc var logFilePath: String? {
    guard log?.destinations.isEmpty == false else { return nil }
    for desination in (log?.destinations)! {
      guard desination is FileDestination else { continue }
      
      let fileDesination = desination as! FileDestination
      return fileDesination.logFileURL?.path
    }
    
    return nil
  }
  
}
