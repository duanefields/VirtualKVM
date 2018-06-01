//
//  Uiltites.swift
//  VirtualKVM
//
//  Created by Soneé John on 5/31/18.
//  Copyright © 2018 Fast Wombat. All rights reserved.
//

import Cocoa
import SwiftyBeaver

@objc class Uiltites: NSObject {
  
  static let shared = Uiltites()
  var log: SwiftyBeaver.Type?
  
  @objc func setupLogging() {
    guard log == nil else { return }
    
    log = SwiftyBeaver.self
   
    let console = ConsoleDestination()
    console.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $C$L$c: $M"
    
    let file = FileDestination()
    file.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $C$L$c: $M"
    
    log?.addDestination(console)
    log?.addDestination(file)
  }
}
