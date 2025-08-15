https://developer.apple.com/documentation/corehid/creatingvirtualdevices
https://aistudio.google.com/prompts/1NMEFrPkpbIQy-TkhCMvcrT3-QzjoCiDv




Article
Creating virtual devices
Use and interact with a virtual human interface device for testing and development.
Overview
A virtual human interface device (HID) is a software implementation of a hardware device. The system treats the device as any other external peripheral. HIDVirtualDevice models a virtual device and you communicate with it using HIDDeviceClient. Use a virtual device to transport data back and forth between other apps without the need for a connected device.

Define the details of a HIDVirtualDevice by passing a set of HIDVirtualDevice.Properties during creation. You must pass descriptor and vendorID, and specify additional properties using init(descriptor:vendorID:productID:transport:product:manufacturer:modelNumber:versionNumber:serialNumber:uniqueID:locationID:localizationCode:extraProperties:).

The following creates a HIDVirtualDevice that acts as a keyboard:

// This describes a keyboard device according to the Human Interface Devices standard.
let keyboardDescriptor: Data = Data([0x05, 0x01, 0x09, 0x06, 0xA1, 0x01, 0x05, 0x07, 0x19, 0xE0, 0x29, 0xE7, 0x15, 0x00, 0x25, 0x01, 0x75, 0x01, 0x95, 0x08, 0x81, 0x02, 0x95, 0x01, 0x75, 0x08, 0x81, 0x01, 0x05, 0x08, 0x19, 0x01, 0x29, 0x05, 0x95, 0x05, 0x75, 0x01, 0x91, 0x02, 0x95, 0x01, 0x75, 0x03, 0x91, 0x01, 0x05, 0x07, 0x19, 0x00, 0x2A, 0xFF, 0x00, 0x95, 0x05, 0x75, 0x08, 0x15, 0x00, 0x26, 0xFF, 0x00, 0x81, 0x00, 0x05, 0xFF, 0x09, 0x03, 0x75, 0x08, 0x95, 0x01, 0x81, 0x02, 0xC0])
let properties = HIDVirtualDevice.Properties(descriptor: keyboardDescriptor, vendorID: 1)


guard let device = HIDVirtualDevice(properties: properties) else {
    return
}
The virtual device adopts the HIDVirtualDeviceDelegate protocol to process report requests. Clients on the system send set reports and receive get reports to and from this virtual device using dispatchSetReportRequest(type:id:data:timeout:) and dispatchGetReportRequest(type:id:timeout:):

final class Delegate : HIDVirtualDeviceDelegate {
    // A handler for system requests to send data to the device.
    func hidVirtualDevice(_ device: HIDVirtualDevice, receivedSetReportRequestOfType type: HIDReportType, id: HIDReportID?, data: Data) throws {
        print("Device received a set report request for report type:\(type) id:\(String(describing: id)) with data:[\(data.map { String(format: "%02x", $0) }.joined(separator: " "))]")
    }


    // A handler for system requests to query data from the device.
    func hidVirtualDevice(_ device: HIDVirtualDevice, receivedGetReportRequestOfType type: HIDReportType, id: HIDReportID?, maxSize: size_t) throws -> Data {
        print("Device received a get report request for report type:\(type) id:\(String(describing: id))")
        assert(maxSize >= 4)
        return (Data([1, 2, 3, 4]))
    }
}


await device.activate(delegate: Delegate())
The virtual device can also dispatch input reports to clients. This is similar to a keyboard dispatching data when a key is pressed.

// Send input data to the system to indicate device activity.
try await device.dispatchInputReport(data: Data([5, 6, 7, 8]), timestamp: SuspendingClock.now)
See Also
Simulation
actor HIDVirtualDevice
A virtual service to emulate a HID device connected to the system.
protocol HIDVirtualDeviceDelegate
The delegate to receive notifications for a virtual HID device.
struct Properties
The properties for a virtual HID device.

HIDVirtualDevice
A virtual service to emulate a HID device connected to the system.
macOS 15.0+
actor HIDVirtualDevice
Mentioned in
Creating virtual devices
Overview
A HID device is a computer peripheral intended to provide direction to the system from human input. The specification is a broad, industry-wide standard maintained by the USB Implementers Forum.

A HIDVirtualDevice is an object that emulates a HID device connected to the system, without the need for a physical device. Such a tool can be used by an app to emulate a keyboard and dispatch HID reports to the system using dispatchInputReport(data:timestamp:) that signify key strokes, and could be received by a HIDDeviceClientlistening for such activity in other apps. The virtual device can also receive requests from the system using its HIDVirtualDeviceDelegate.

Topics
Create a HID virtual device
init?(properties: HIDVirtualDevice.Properties)
Creates a virtual HID device.
let deviceReference: HIDDeviceClient.DeviceReference
The reference to the virtual HID device.
func activate(delegate: any HIDVirtualDeviceDelegate)
Activate a newly created virtual device to begin receiving notifications and enable functionality.
Dispatch input reports
func dispatchInputReport(data: Data, timestamp: SuspendingClock.Instant) async throws
Dispatch an input report to the system.
Structures
struct Properties
The properties for a virtual HID device.
Instance Properties
var hidDevice: IOHIDUserDevice?
Beta
Relationships
Conforms To
Actor
Copyable
CustomStringConvertible
Equatable
Hashable
Sendable
SendableMetatype
See Also
Simulation
Creating virtual devices
Use and interact with a virtual human interface device for testing and development.
protocol HIDVirtualDeviceDelegate
The delegate to receive notifications for a virtual HID device.
struct Properties
The properties for a virtual HID device.

HIDVirtualDeviceDelegate
The delegate to receive notifications for a virtual HID device.
macOS 15.0+
protocol HIDVirtualDeviceDelegate : Sendable
Mentioned in
Creating virtual devices
Overview
A delegate must be created and provided to activate(delegate:) during activation of a virtual HID device. This delegate receives notifications intended for the device, such as a get report request from a client. One delegate can be used for many devices.

Topics
Receive notifications for a device
func hidVirtualDevice(HIDVirtualDevice, receivedSetReportRequestOfType: HIDReportType, id: HIDReportID?, data: Data) async throws
A notification that a set report request has been received from the system.
Required

func hidVirtualDevice(HIDVirtualDevice, receivedGetReportRequestOfType: HIDReportType, id: HIDReportID?, maxSize: Int) async throws -> Data
A notification that a get report request has been received from the system.
Required

Relationships
Inherits From
Sendable
SendableMetatype
See Also
Simulation
Creating virtual devices
Use and interact with a virtual human interface device for testing and development.
actor HIDVirtualDevice
A virtual service to emulate a HID device connected to the system.
struct Properties
The properties for a virtual HID device.

Structure
HIDVirtualDevice.Properties
The properties for a virtual HID device.
macOS 15.0+
struct Properties
Mentioned in
Creating virtual devices
Overview
A virtual device has many properties, required and optional, that determine or alter its functionality. Use this class to provide these properties during the creation of a virtual device.

Uncommon properties that aren’t available can be specified in the extraProperties parameter of init(descriptor:vendorID:productID:transport:product:manufacturer:modelNumber:versionNumber:serialNumber:uniqueID:locationID:localizationCode:extraProperties:).

Topics
Initializers
init(descriptor: Data, vendorID: UInt32, productID: UInt32?, transport: HIDDeviceTransport?, product: String?, manufacturer: String?, modelNumber: String?, versionNumber: UInt64?, serialNumber: String?, uniqueID: String?, locationID: UInt64?, localizationCode: HIDDeviceLocalizationCode?, extraProperties: Dictionary<String, AnyObject>?)
Creates a set of properties for a virtual device.
Instance Properties
let descriptor: Data
The HID specification compliant report descriptor for the virtual device.
let localizationCode: HIDDeviceLocalizationCode?
A device localization code that specifies the HID compliant localization code.
let locationID: UInt64?
The location ID for the device.
let manufacturer: String?
The manufacturer of the device.
let modelNumber: String?
The model number for the device.
let product: String?
The product name for the device.
let productID: UInt32?
The product ID for the device.
let serialNumber: String?
The serial number for the device.
let transport: HIDDeviceTransport?
The data transport for the device.
let uniqueID: String?
A unique ID for the device.
let vendorID: UInt32
The vendor ID for the device.
let versionNumber: UInt64?
The version of the device.
Relationships
Conforms To
Sendable
SendableMetatype
See Also
Simulation
Creating virtual devices
Use and interact with a virtual human interface device for testing and development.
actor HIDVirtualDevice
A virtual service to emulate a HID device connected to the system.
protocol HIDVirtualDeviceDelegate
The delegate to receive notifications for a virtual HID device.
