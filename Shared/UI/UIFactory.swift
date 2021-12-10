// Copyright 2021 MbientLab Inc. All rights reserved. See LICENSE.MD.

import Foundation
import MetaWear
import Metadata

public class UIFactory: ObservableObject {

    public init(devices: MetaWearStore,
                scanner: MetaWearScanner,
                routing: Routing) {
        self.store = devices
        self.scanner = scanner
        self.routing = routing
    }

    private unowned let store: MetaWearStore
    private unowned let scanner: MetaWearScanner
    private unowned let routing: Routing
    private lazy var actionQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".action")
}

public extension UIFactory {

    func makeDiscoveredDeviceListVM() -> DiscoveryListVM {
        .init(scanner: scanner, store: store)
    }

    func makeBluetoothStateWarningsVM() -> BLEStateWarningsVM {
        .init(scanner: scanner)
    }

    func makeMetaWearDiscoveryVM() -> MetaWearDiscoveryVM {
        .init(store: store) 
    }

    func makeMetaWearItemVM(_ item: Routing.Item) -> KnownItemVM {
        switch item {
            case .known(let mac):
                guard let known = store.getDeviceAndMetadata(mac)
                else { fatalError() }
                return .init(device: known, store: store, routing: routing)

            case .group(let id):
                guard let group = store.getGroup(id: id)
                else { fatalError() }
                return .init(group: group, store: store, routing: routing)
        }
    }

    func makeUnknownItemVM(_ id: CBPeripheralIdentifier) -> UnknownDeviceVM {
        .init(cbuuid: id, store: store, routing: routing)
    }

    func makeAboutDeviceVM(device: MWKnownDevice) -> AboutDeviceVM {
        .init(device: device, store: store)
    }

    func makeHistoryScreenVM(item: Routing.Item) -> HistoryScreenVM {
        let (title, devices) = getKnownDevices(for: item)
        let vms = makeAboutVMs(for: devices)
        return .init(title: title, item: item, vms: vms, store: store, routing: routing, scanner: scanner)
    }

    func makeSensorConfigurationVM(item: Routing.Item) -> SensorConfigurationVM {
        let (title, devices) = getKnownDevices(for: item)
        return .init(title: title, item: item, devices: devices, routing: routing)
    }

    func makeActionLogVM(item: Routing.Item) -> ActionLogVM {
        let (_, devices) = getKnownDevices(for: item)
        let vms = makeAboutVMs(for: devices)
        return .init(item: item, devices: devices, vms: vms, store: store, routing: routing, queue: actionQueue)
    }

}

private extension UIFactory {

    private func makeAboutVMs(for devices: [MWKnownDevice]) -> [AboutDeviceVM] {
        let vms = devices.map(makeAboutDeviceVM(device:))
        vms.indices.forEach { vms[$0].configure(for: $0) }
        return vms
    }

    private func getKnownDevices(for item: Routing.Item) -> (title: String, devices: [MWKnownDevice]) {
        switch item {
            case .group(let id):
                guard let group = store.getGroup(id: id) else { break }
                return (group.name, store.getDevicesInGroup(group))

            case .known(let mac):
                guard let device = store.getDeviceAndMetadata(mac) else { break }
                return (device.meta.name, [device])
        }
        return (title: "Error", devices: [])
    }
}
