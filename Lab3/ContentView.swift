//
//  ContentView.swift
//  Lab3
//
//  Created by David Ulvan on 2023-12-20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var apiViewModel = APIViewModel()
    @State private var inputSerialNumber: String = ""
    @State private var inputName: String = ""

    var body: some View {
        VStack {
            // List for displaying machine data with swipe-to-delete
            List {
                ForEach(apiViewModel.machineDataArray, id: \.serialNumber) { machineData in
                    MachineCard(name: machineData.name, error: machineData.isWorking, action: {
                        apiViewModel.updateMachineStatus(serialNumber: machineData.serialNumber, isWorking: !machineData.isWorking)
                    })
                }.onDelete(perform: deleteMachine)
            }


            // TextFields for input
            HStack {
                TextField("serialNumber", text: $inputSerialNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 100)
                
                TextField("name", text: $inputName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 100)
            }

            // Add Button
            Button(action: {
                let newSpecifications = Specifications(weight: 4500.0, dimensions: "3m x 2m x 2.5m")
                let newMachineData = MachineData(serialNumber: inputSerialNumber, name: inputName, isWorking: true, specifications: newSpecifications, maintenanceHistory: [])
                apiViewModel.postData(machineData: newMachineData)
            }){
                Text("Add")
            }
        }
        .onAppear {
            apiViewModel.fetchData()
        }
        .padding()
        
    }
    private func deleteMachine(at offsets: IndexSet) {
            offsets.forEach { index in
                let machineData = apiViewModel.machineDataArray[index]
                apiViewModel.deleteMachineData(withSerialNumber: machineData.serialNumber)
            }
            apiViewModel.fetchData()
        }
}

#Preview {
    ContentView()
}
