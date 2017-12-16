class Offering {
    let id: Int
    let basePrice: Int
    let brand: String
    let name: String
    let consumption: Int
    let description: String
    let fuel: String
    let gear: String
    let hp: Int
    let latitude: Float
    let location: String
    let longitude: Float
    let pictureURL: String
    let seats: Int
    let type: String
    let featuresIDs: [Int]?
    let vehicleTypeID: Int
    let vehicleType: String
    
    init(id: Int, basePrice: Int, brand: String, name:String, consumption: Int, description: String, fuel: String, gear: String, hp: Int, latitude: Float, location: String, longitude: Float, pictureURL: String, seats: Int, type: String, featuresIDs: [Int]?, vehicleTypeID: Int, vehicleType: String) {
        self.basePrice = basePrice
        self.id = id
        self.brand = brand
        self.name = name
        self.consumption = consumption
        self.description = description
        self.fuel = fuel
        self.gear = gear
        self.hp = hp
        self.latitude = latitude
        self.longitude = longitude
        self.pictureURL = pictureURL
        self.seats = seats
        self.type = type
        self.location = location
        self.featuresIDs = featuresIDs
        self.vehicleTypeID = vehicleTypeID
        self.vehicleType = vehicleType
    }
    
    //Icons in program have the same name as the String of the detail
    func getBasicDetails() -> [String] {
        let seats = "\(self.seats)"
        let basicDetails = [seats, fuel, gear, type]
        return basicDetails
    }
    
}
