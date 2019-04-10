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
  fileprivate var task: Process?
  
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
  
  @objc func startAudioDaemon() {
    guard task?.isRunning == false || task?.isRunning == nil else { return }
    OperationQueue().addOperation {
      self.task = Process()
      self.task?.launchPath = "/usr/libexec/dpaudiothru"
      self.task?.arguments = [""]
      self.task?.launch()
      self.task?.waitUntilExit()
    }
  }
  
  @objc func stopAudioDaemon() {
    guard task?.isRunning ?? false else { return }
    self.task?.terminate()
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
