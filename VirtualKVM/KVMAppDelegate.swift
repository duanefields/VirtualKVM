//
//  KVMAppDelegate.swift
//  VirtualKVM
//
//  Created by Soneé John on 4/9/19.
//  Copyright © 2019 Fast Wombat. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class KVMAppDelegate: NSObject, NSApplicationDelegate, AppProtocol {
  @objc static let shouldKillDisplayDaemonNotification = "VirtualKVMShouldKillDisplayDaemonNotification"
  @objc static let shouldKillDisplayAudioDaemonNotification = "VirtualKVMShouldKillDisplayAudioDaemonNotification"
  @objc static let shouldLaunchDisplayAudioDaemonNotification = "VirtualKVMShouldLaunchDisplayAudioDaemonNotification"
  
  private var currentHelperConnection: NSXPCConnection?
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    // Update the current authorization database right
    // This will prompt the user for authentication if something needs updating.
    
    do {
      try HelperAuthorization.authorizationRightsUpdateDatabase()
    } catch let error as NSError {
      print("Error `authorizationRightsUpdateDatabase` \(error)")
    }
    self.helperStatus { installed in
      guard installed == false else {
        return
      }
      
      print("Helper not installed, attempting installation.")
      
      do {
        _ = try self.helperInstall()
      } catch {
        print("Failed to install helper")
      }
    }
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: KVMAppDelegate.shouldKillDisplayDaemonNotification), object: nil, queue: nil) { (_) in
      guard let helper = self.helper(nil) else { return }
      helper.killProcess(arguments: "Safari", completion: { (existCode) in
        print("Kill Display Daemon with code \(existCode)")
      })
    }
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: KVMAppDelegate.shouldKillDisplayAudioDaemonNotification), object: nil, queue: nil) { (_) in
      guard let helper = self.helper(nil) else { return }
      helper.killProcess(arguments: "dpaudiothru", completion: { (existCode) in
        print("Kill Display Audio Daemon with code \(existCode)")
      })
    }
    
    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: KVMAppDelegate.shouldLaunchDisplayAudioDaemonNotification), object: nil, queue: nil) { (_) in
      guard let helper = self.helper(nil) else { return }
    
      helper.launchProcess(path: "/usr/libexec/dpaudiothru", completion: { (existCode) in
        print("Launch dpaudiothru with code \(existCode)")
      })
    }
  }
  
  // MARK: -
  // MARK: Helper Connection Methods
  
  func helperConnection() -> NSXPCConnection? {
    guard self.currentHelperConnection == nil else {
      return self.currentHelperConnection
    }
    
    let connection = NSXPCConnection(machServiceName: HelperConstants.machServiceName, options: .privileged)
    connection.exportedInterface = NSXPCInterface(with: AppProtocol.self)
    connection.exportedObject = self
    connection.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
    connection.invalidationHandler = {
      self.currentHelperConnection?.invalidationHandler = nil
      OperationQueue.main.addOperation {
        self.currentHelperConnection = nil
      }
    }
    
    self.currentHelperConnection = connection
    self.currentHelperConnection?.resume()
    
    return self.currentHelperConnection
  }
  
  func helper(_ completion: ((Bool) -> Void)?) -> HelperProtocol? {
    
    // Get the current helper connection and return the remote object (Helper.swift) as a proxy object to call functions on.
    
    guard let helper = self.helperConnection()?.remoteObjectProxyWithErrorHandler({ error in
      if let onCompletion = completion { onCompletion(false) }
    }) as? HelperProtocol else { return nil }
    return helper
  }
  
  func helperStatus(completion: @escaping (_ installed: Bool) -> Void) {
    
    // Comppare the CFBundleShortVersionString from the Info.plist in the helper inside our application bundle with the one on disk.
    
    let helperURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Library/LaunchServices/" + HelperConstants.machServiceName)
    guard
      let helperBundleInfo = CFBundleCopyInfoDictionaryForURL(helperURL as CFURL) as? [String: Any],
      let helperVersion = helperBundleInfo["CFBundleShortVersionString"] as? String,
      let helper = self.helper(completion) else {
        completion(false)
        return
    }
    
    helper.getVersion { installedHelperVersion in
      completion(installedHelperVersion == helperVersion)
    }
  }
  
  func helperInstall() throws -> Bool {
    
    // Install and activate the helper inside our application bundle to disk.
    
    var cfError: Unmanaged<CFError>?
    var authItem = AuthorizationItem(name: kSMRightBlessPrivilegedHelper, valueLength: 0, value:UnsafeMutableRawPointer(bitPattern: 0), flags: 0)
    var authRights = AuthorizationRights(count: 1, items: &authItem)
    
    guard
      let authRef = try HelperAuthorization.authorizationRef(&authRights, nil, [.interactionAllowed, .extendRights, .preAuthorize]),
      SMJobBless(kSMDomainSystemLaunchd, HelperConstants.machServiceName as CFString, authRef, &cfError) else {
        if let error = cfError?.takeRetainedValue() { throw error }
        return false
    }
    
    self.currentHelperConnection?.invalidate()
    self.currentHelperConnection = nil
    
    return true
  }
  // MARK: -
  // MARK: AppProtocol
  
  func log(stdOut: String) {
    print(stdOut)
  }
  
  func log(stdErr: String) {
    print(stdErr)
  }

}
