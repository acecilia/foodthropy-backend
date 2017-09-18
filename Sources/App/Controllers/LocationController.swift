import Foundation

class LocationController: DefaultController<Location> { }

extension LocationController: DummyFillable {
    static func dummyFill() throws {
        if try Location.count() == 0 {
            let nf = NumberFormatter()
            nf.numberStyle = .spellOut
            nf.locale = Locale(identifier: "en_US")
            
            // Reset id count
            try Location.database?.raw("ALTER SEQUENCE locations_id_seq RESTART WITH 1")
            
            for number in 1...200 {
                if let name = nf.string(from: NSNumber(value: number)) {
                    try Location(name: name).save()
                }
            }
        }
    }
}
