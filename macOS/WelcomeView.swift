//
//  WelcomeView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.09.20.
//

import SwiftUI

struct WelcomeView: View {
    enum DisplayMode {
        case welcomeView
        case loginView
        case registerView
        case joinOrganizationInfoView
    }
    
    @State private var displayMode: DisplayMode = .welcomeView
    
    var welcomeView: some View {
            VStack(spacing: 15) {
                Text("Telemetry is a service that helps app and web developers improve their product by supplying immediate, accurate telemetry data while users use your app. And the best part: It's all anonymized so your users' data stays private!")
                    .padding(.bottom)
                
                
                    HStack {
                        Spacer()
                        
                        Image("analyzing_process")
                            .resizable()
                            .scaledToFit()
                        Spacer()
                    }
                
                Button("Login to Your Account") {
                    displayMode = .loginView
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)
                
                Button("Create a New Organization") {
                    displayMode = .registerView
                }
                .buttonStyle(SecondaryButtonStyle())
                .padding(.horizontal)
                
                Button("Join an Organization") {
                    displayMode = .joinOrganizationInfoView
                }
                .buttonStyle(SecondaryButtonStyle())
                .padding(.horizontal)
                
                
                
                AdaptiveStack(spacing: 15) {
                    Button("Docs: Getting Started →") {
                        NSWorkspace.shared.open(URL(string: "https://apptelemetry.io/pages/docs.html")!)
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())
                    
                    
                    Button("Privacy Policy →") {
                        NSWorkspace.shared.open(URL(string: "https://apptelemetry.io/pages/privacy-policy.html")!)
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())
                    
                    Button("Issues on GitHub →") {
                        NSWorkspace.shared.open(URL(string: "https://github.com/AppTelemetry/Viewer/issues")!)
                    }
                    .buttonStyle(SmallSecondaryButtonStyle())
                }
                .padding(.horizontal)
                
                Text("Telemetry is currently in public beta! If things don't work the way you expect them to, please be patient, and share your thoughts with Daniel on GitHub or the Slack <3")
                    .font(.footnote)
                    .foregroundColor(.grayColor)
            }    }
    
    var body: some View {       
        switch self.displayMode {
        case .welcomeView:
            MacNavigationView(title: "Welcome to Telemetry") { welcomeView }
        case .loginView:
            MacNavigationView(title: "Login to Your Account", backButtonAction: { self.displayMode = .welcomeView }, height: 200) { LoginView() }
        case .registerView:
            MacNavigationView(title: "Register a New Organization", backButtonAction: { self.displayMode = .welcomeView }, height: 550) { RegisterView() }
        case .joinOrganizationInfoView:
            MacNavigationView(title: "Joining an Organization", backButtonAction: { self.displayMode = .welcomeView }, height: 200) { Text("Join Org Info View") }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
