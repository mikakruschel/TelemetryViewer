//
//  NewInsightForm.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.20.
//

import SwiftUI

struct CreateOrUpdateInsightForm: View {
    // Environment
    @EnvironmentObject var api: APIRepresentative
    
    // Initialization Constants
    let app: TelemetryApp
    let editMode: Bool
    
    let insight: Insight?
    let insightGroup: InsightGroup?
    
    // Bindings
    @Binding var isPresented: Bool
    
    // State
    @State var insightCreateRequestBody: InsightDefinitionRequestBody
    
    @State private var selectedInsightGroupIndex = 0
    
    @State private var selectedDateComponentIndex = 0
    @State private var rollingWindowSize: Double = 24
    
    @State private var selectedDisplayModeIndex = 0
    private let displayModes: [InsightDisplayMode] = [.number, .lineChart, .barChart, .pieChart]
    
    init(app: TelemetryApp, editMode: Bool, requestBody: InsightDefinitionRequestBody? = nil, isPresented: Binding<Bool>, insight: Insight?, group: InsightGroup?) {
        self.app = app
        self.editMode = editMode
        self._isPresented = isPresented
        
        self.insight = insight
        self.insightGroup = group
            
        self._insightCreateRequestBody = State(initialValue: requestBody ?? InsightDefinitionRequestBody(
            order: nil,
            title: "",
            subtitle: nil,
            signalType: nil,
            uniqueUser: false,
            filters: [:],
            rollingWindowSize: -3600*24,
            breakdownKey: nil,
            displayMode: .number))
    }
    
    var body: some View {
        let saveButton = Button("Save") {
            
            if selectedDateComponentIndex == 0 {
                insightCreateRequestBody.rollingWindowSize = rollingWindowSize * -1
            } else if selectedDateComponentIndex == 1 {
                insightCreateRequestBody.rollingWindowSize = rollingWindowSize * -3600
            } else {
                insightCreateRequestBody.rollingWindowSize = rollingWindowSize * -3600*24
            }
            
            insightCreateRequestBody.displayMode = displayModes[selectedDisplayModeIndex]
            
            let group: InsightGroup = api.insightGroups[app]![selectedInsightGroupIndex]
            isPresented = false
            
            if editMode {
                insightCreateRequestBody.groupID = group.id
                api.update(insight: insight!, in: insightGroup!, in: app, with: insightCreateRequestBody)
            } else {
                api.create(insightWith: insightCreateRequestBody, in: group, for: app)
            }
            
        }
        .keyboardShortcut(.defaultAction)
        
        let cancelButton = Button("Cancel") { isPresented = false }.keyboardShortcut(.cancelAction)
        let title = (editMode ? "Edit \(insightCreateRequestBody.title)" : "New Insight")
        
            Form {
                Section(header: Text("Title, Subtitle and Group"), footer: Text("Give your insight a title, and optionally, add a longer descriptive subtitle for your insight. All insights belong to an insight group.")) {
                    TextField("Title e.g. 'Daily Active Users'", text: $insightCreateRequestBody.title)
                    TextField("Optional Subtitle", text: $insightCreateRequestBody.subtitle.bound)
                    
                    Picker(selection: $selectedInsightGroupIndex, label: Text("Insight Group")) {
                        ForEach(0 ..< (api.insightGroups[app]?.count ?? 0)) {
                            Text(api.insightGroups[app]?[$0].title ?? "No Title")
                        }
                    }
                }
                
                Section(header: Text("Signal Type"), footer: Text(("What signal type are you interested in (e.g. appLaunchedRegularly)? Leave blank for any"))) {
                    TextField("All Signals", text: $insightCreateRequestBody.signalType.bound)
                    Toggle(isOn: $insightCreateRequestBody.uniqueUser) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Unique by User")
                                Text("Check to count each user only once")
                                    .font(.footnote)
                                    .foregroundColor(.grayColor)
                            }
                            Spacer()
                        }
                    }
                }
                
                Section(header: Text("Filters"), footer: Text("To add a filter, type a key into the text field and tap 'Add'")) {
                    FilterEditView(keysAndValues: $insightCreateRequestBody.filters)
                }
                
                Section(header: Text("Breakdown"), footer: Text("If you enter a key for the metadata payload here (e.g. systemVersion), you'll get a breakdown of its values.")) {
                    TextField("No breakdown", text: $insightCreateRequestBody.breakdownKey.bound)
                }
                
                Section(header: Text("Display")) {
                    
                    Picker(selection: $selectedDisplayModeIndex, label: Text("Display As")) {
                        if insightCreateRequestBody.breakdownKey == nil {
                            Text(InsightDisplayMode.number.rawValue.capitalized).tag(0)
                            Text(InsightDisplayMode.lineChart.rawValue.capitalized).tag(1)
                        } else {
                            Text(InsightDisplayMode.barChart.rawValue.capitalized).tag(2)
                            Text(InsightDisplayMode.pieChart.rawValue.capitalized).tag(3)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(EdgeInsets(top: 1, leading: -7, bottom: 1, trailing: 0))
                    
                    HStack {
                        Text("Rolling Window")
                        TextField("Rolling Window Size", text: $rollingWindowSize.stringValue).multilineTextAlignment(.trailing)
                        Picker(selection: $selectedDateComponentIndex, label: Text("")) {
                            Text("Seconds").tag(0)
                            Text("Hours").tag(1)
                            Text("Days").tag(2)
                        }.pickerStyle(SegmentedPickerStyle())
                    }
                    
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    saveButton.disabled(
                        insightCreateRequestBody.title.isEmpty
                        ||
                            insightCreateRequestBody.breakdownKey == nil && ![.lineChart, .number].contains(displayModes[selectedDisplayModeIndex])
                        ||
                            insightCreateRequestBody.breakdownKey != nil && ![.barChart, .pieChart].contains(displayModes[selectedDisplayModeIndex])
                        
                        )
                }
            }
            .onAppear() {
                // Group
                if let groupID = insightCreateRequestBody.groupID {
                    selectedInsightGroupIndex = api.insightGroups[app]?.firstIndex(where: { $0.id == groupID }) ?? 0
                }
                
                // Display Mode
                switch insight?.displayMode {
                case .number:
                    selectedDisplayModeIndex = 0
                case .lineChart:
                    selectedDisplayModeIndex = 1
                case .barChart:
                    selectedDisplayModeIndex = 2
                case .pieChart:
                    selectedDisplayModeIndex = 3
                case .none:
                    selectedDisplayModeIndex = -1
                }
                
                // Rolling Window
                if insightCreateRequestBody.rollingWindowSize.truncatingRemainder(dividingBy: 3600 * 24) == 0 {
                    self.selectedDateComponentIndex = 2
                    self.rollingWindowSize = insightCreateRequestBody.rollingWindowSize / -3600 / 24
                } else if insightCreateRequestBody.rollingWindowSize.truncatingRemainder(dividingBy: 3600) == 0 {
                    selectedDateComponentIndex = 1
                    self.rollingWindowSize = insightCreateRequestBody.rollingWindowSize / -3600
                } else {
                    selectedDateComponentIndex = 0
                    self.rollingWindowSize = insightCreateRequestBody.rollingWindowSize * -1
                }
            }
    }
}

//struct NewInsightForm_Previews: PreviewProvider {
//    static var platform: PreviewPlatform? = nil
//
//    static var previews: some View {
//        CreateOrUpdateInsightForm(app: MockData.app1, isPresented: .constant(true))
//            .environmentObject(APIRepresentative())
//            .previewLayout(.fixed(width: 600, height: 1000))
//    }
//}
