//
//  NetworkInterfaceNotifier.swift
//  VirtualKVM
//
//  Created by Soneé John on 5/20/18.
//  Copyright © 2018 Fast Wombat. All rights reserved.
//

import SystemConfiguration
import Foundation


@objc protocol NetworkInterfaceNotifierDelegate {
  func networkInterfaceNotifierDidDetectChanage()
}

class NetworkInterfaceNotifier: NSObject {
  
  struct NetworkInterface {
    let BSDName: String
    let displayName: String
  }
  
  override init() {
    Uiltites.shared.setupLogging()
    super.init()
  }
  
  var delegate: NetworkInterfaceNotifierDelegate?
  
  func startObserving() {
    
    func callback(store: SCDynamicStore, changedKeys: CFArray, context: UnsafeMutableRawPointer?) -> Void {
      guard context != nil else { return }
      
      let mySelf = Unmanaged<NetworkInterfaceNotifier>.fromOpaque(context!).takeUnretainedValue()
      mySelf.delegate?.networkInterfaceNotifierDidDetectChanage()
    }
    
    OperationQueue().addOperation {
      
      guard Bundle.main.bundleIdentifier != nil else {
        Uiltites.shared.log?.warning("Could not get bundle identifier")
        return
      }
      
      var context = SCDynamicStoreContext(version: 0, info: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), retain: nil, release: nil, copyDescription: nil)
      
      guard let store = SCDynamicStoreCreate(nil, Bundle.main.bundleIdentifier! as CFString, callback, &context) else {
        Uiltites.shared.log?.warning("Could not connect SCDynamicStoreCreate")
        return
      }
      
      var interfaces:[NetworkInterface] = []
      
      for interface in SCNetworkInterfaceCopyAll() as NSArray {
        if let name = SCNetworkInterfaceGetBSDName(interface as! SCNetworkInterface),
          let displayName = SCNetworkInterfaceGetLocalizedDisplayName(interface as! SCNetworkInterface) {
          interfaces.append(NetworkInterface(BSDName: name as String, displayName: displayName as String))
          Uiltites.shared.log?.info("Hardware Port: \(displayName) \nInterface \(name)")
        }
      }
      
      var keys = [CFString]()
      
      for interface in interfaces {
        if interface.displayName.contains("Thunderbolt") && interface.displayName.contains("Bridge") == false {
          keys.append("State:/Network/Interface/\(interface.BSDName)/LinkQuality" as CFString)
        }
      }
      
      SCDynamicStoreSetNotificationKeys(store, keys as CFArray, nil)

      let runloop = SCDynamicStoreCreateRunLoopSource(nil, store, 0)
      CFRunLoopAddSource(RunLoop.current.getCFRunLoop(), runloop, CFRunLoopMode.commonModes)
      RunLoop.current.run()
    }
  }
}
