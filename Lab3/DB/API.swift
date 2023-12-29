import Foundation

struct Specifications: Decodable {
    let weight: Double
    let dimensions: String
}

struct MaintenanceHistory: Decodable {
    let date: Date
    let description: String
}

struct MachineData: Decodable {
    let serialNumber: String
    let name: String
    let isWorking: Bool
    let specifications: Specifications
    let maintenanceHistory: [MaintenanceHistory]

    private enum CodingKeys: String, CodingKey {
        case serialNumber
        case name
        case isWorking
        case specifications
        case maintenanceHistory
    }
}

class APIViewModel: ObservableObject {
    @Published var machineDataArray: [MachineData] = []

    func fetchData() {
        guard let url = URL(string: "http://localhost:3000/machinedata") else {
            return
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Adjust to match your server's date format
                decoder.dateDecodingStrategy = .formatted(dateFormatter)

                struct Response: Decodable {
                    let machineData: [MachineData]
                }

                let decodedResponse = try decoder.decode(Response.self, from: data)
                DispatchQueue.main.async {
                    self.machineDataArray = decodedResponse.machineData
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }

        }.resume()
    }
    
    func postData(machineData: MachineData) {
        guard let url = URL(string: "http://localhost:3000/machinedata") else {
            return
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Adjust to match your server's date format
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        // Convert MachineData to a dictionary, including formatted dates
        let machineDataDict: [String: Any] = [
            "serialNumber": machineData.serialNumber,
            "name": machineData.name,
            "isWorking": machineData.isWorking,
            "specifications": [
                "weight": machineData.specifications.weight,
                "dimensions": machineData.specifications.dimensions
            ],
            "maintenanceHistory": machineData.maintenanceHistory.map { history in
                ["date": dateFormatter.string(from: history.date), "description": history.description]
            }
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: machineDataDict) else {
            print("Error creating JSON data")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            DispatchQueue.main.async {
                self.fetchData() // Refresh data after update
            }
            
        }.resume()
    }
    
    func deleteMachineData(withSerialNumber serialNumber: String) {
            guard let url = URL(string: "http://localhost:3000/machinedata/\(serialNumber)") else {
                print("Invalid URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }

                // Handle the response and update your UI accordingly
                DispatchQueue.main.async {
                    self.machineDataArray.removeAll { $0.serialNumber == serialNumber }
                }
            }.resume()
        }
    
    func updateMachineStatus(serialNumber: String, isWorking: Bool) {
        guard let url = URL(string: "http://localhost:3000/machinedata/\(serialNumber)") else {
            print("Invalid URL")
            return
        }

        let updateData = ["isWorking": isWorking]
        guard let jsonData = try? JSONEncoder().encode(updateData) else {
            print("Error encoding update data")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            DispatchQueue.main.async {
                self?.fetchData() // Refresh data after update
            }
        }.resume()
    }
}

