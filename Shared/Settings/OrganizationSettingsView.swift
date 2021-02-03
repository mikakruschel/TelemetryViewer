//
//  OrganizationSettingsView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.09.20.
//

import SwiftUI
import TelemetryClient

struct UserInfoView: View {
    var user: UserDataTransferObject
    
    var body: some View {
        VStack {
            Text(user.firstName)
            Text(user.lastName)
            Text(user.email)
            Text(user.isFoundingUser ? "Founding User" : "")
        }
    }
}

struct OrganizationSettingsView: View {
    @EnvironmentObject var api: APIRepresentative
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var sizeClass
    #else
    enum SizeClassNoop {
        case compact
        case notCompact
    }
    
    var sizeClass: SizeClassNoop = .notCompact
    #endif

    @State private var showingSheet = false
    
    var body: some View {
        HStack {
            List {
                Text(api.user?.organization?.name ?? "Organization")
                    .font(.title)

                HStack {
                    ValueView(
                        value: Double(api.organizationUsers.count),
                        title: api.organizationUsers.count == 1 ? "user" : "users",
                        unit: "")
                    Divider()
                    ValueView(
                        value: Double(api.organizationJoinRequests.count),
                        title: api.organizationJoinRequests.count == 1 ? "invitation"  : "invitations",
                        unit: "")
                    Divider()
                    ValueView(
                        value: Double(api.numberOfSignals),
                        title: "signals this month",
                        unit: "")
                }

                Section(header: Text("Organization Users")) {
                    ForEach(api.organizationUsers) { organizationUser in
                        NavigationLink(destination: UserInfoView(user: organizationUser)) {
                            HStack {
                                Text(organizationUser.firstName)
                                Text(organizationUser.lastName)
                                Text(organizationUser.email)
                                Spacer()
                                Text(organizationUser.isFoundingUser ? "Founding User" : "")
                            }
                        }
                    }
                }

                Section(header: Text("Join Requests")) {
                    ForEach(api.organizationJoinRequests) { joinRequest in

                        ListItemView {
                            Text(joinRequest.email)
                            Spacer()
                            Text(joinRequest.registrationToken)

                            Button(action: {
                                api.delete(organizationJoinRequest: joinRequest)
                            }, label: {
                                Image(systemName: "minus.circle.fill")
                            })
                            .buttonStyle(IconButtonStyle())
                        }
                    }

                    Button("Create an Invitation to Join \(api.user?.organization?.name ?? "noorg")") {
                        showingSheet.toggle()
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())
                }
            }
        }
        .onAppear {
            TelemetryManager.shared.send(TelemetrySignal.organizationSettingsShown.rawValue, for: api.user?.email)
            api.getOrganizationUsers()
            api.getOrganizationJoinRequests()
            api.getNumberOfSignals()
        }
        .sheet(isPresented: $showingSheet) {
            CreateOrganizationJoinRequestView()
        }
        
    }
}

struct OrganizationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        OrganizationSettingsView().environmentObject(APIRepresentative())
    }
}
