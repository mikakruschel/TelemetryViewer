//
//  StatusMessage.swift
//  StatusMessage
//
//  Created by Daniel Jilg on 17.09.21.
//

import SwiftUI

struct StatusMessage: View {
    let statusMessage: DTOv2.StatusMessage
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: statusMessage.systemImageName ?? "info.circle")
                .font(.system(size: 18))
                .padding(.horizontal, 4)
                .padding(.vertical, 10)
            
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    Text(statusMessage.validFrom, style: .date)
                
                    statusMessage.validUntil.map {
                        Text(" – ") + Text($0, style: .date)
                    }
                }
                .font(.footnote)
                .foregroundColor(.grayColor)
                
                Text(statusMessage.title).font(.headline)
            
                statusMessage.description.map {
                    Text($0).foregroundColor(.grayColor)
                }
                
                #if os(macOS)
                if statusMessage.id == "restricted-mode-notification" {
                    Button("Open Settings") {
                        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                    }
                }
                #endif
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.telemetryOrange.opacity(0.1))
    }
}
