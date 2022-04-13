import Foundation
import Network

class NetworkChecker {
    static let shared = NetworkChecker()
    private let monitor: NWPathMonitor
    var isConnected: Bool = false
    private var connectionType: ConnectionType = .unknown
    
    enum ConnectionType {
        case wifi
        case cellular
        case unknown
    }
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    func startMonitoring() {
        monitor.start(queue: DispatchQueue.global())
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            self?.getConnectionType(path)
            
            if self?.isConnected == true {
                print("연결됨") 
            } else {
                print("연결 안됨")
            }
        }
    }
    
    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else {
            connectionType = .unknown
        }
    }
}
