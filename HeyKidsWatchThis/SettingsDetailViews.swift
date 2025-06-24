// SettingsDetailViews.swift
// HeyKidsWatchThis - Complete Settings Detail Views
// FIXED VERSION - All missing views implemented

import SwiftUI
import Foundation

// ============================================================================
// MARK: - Missing Views Fixed
// ============================================================================

struct PreferencesView: View {
    @Bindable var viewModel: SettingsViewModel
    
    var body: some View {
        Form {
            // Theme Section
            Section("Appearance") {
                Picker("Theme", selection: viewModel.themeBinding) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
            }
            
            // Age Group Section
            Section("Default Age Group") {
                Picker("Age Group", selection: viewModel.defaultAgeGroupBinding) {
                    ForEach(AgeGroup.allCases, id: \.self) { ageGroup in
                        Text(ageGroup.description).tag(ageGroup)
                    }
                }
            }
            
            // Notifications Section
            Section("Notifications") {
                Toggle("Enable Notifications", isOn: viewModel.notificationsBinding)
                Toggle("Movie Night Reminders", isOn: viewModel.movieNightRemindersBinding)
            }
            
            // Viewing Section
            Section("Viewing Experience") {
                Toggle("Show Watched Movies", isOn: viewModel.showWatchedMoviesBinding)
                Toggle("Enable Animations", isOn: viewModel.enableAnimationsBinding)
            }
            
            // Parental Controls Section
            Section("Parental Controls") {
                Toggle("Restrict Content by Age", isOn: viewModel.restrictContentBinding)
                
                if viewModel.userPreferences.restrictContentByAge {
                    VStack(alignment: .leading) {
                        Text("Maximum Content Rating")
                        Slider(
                            value: viewModel.maxContentRatingBinding,
                            in: 1.0...5.0,
                            step: 0.1
                        )
                        Text("\(viewModel.userPreferences.maxContentRating, specifier: "%.1f") stars")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Preferences")
    }
}

struct DataManagementView: View {
    @Bindable var viewModel: SettingsViewModel
    
    var body: some View {
        Form {
            Section("Cache Management") {
                Button("Clear Cache") {
                    Task {
                        await viewModel.clearCache()
                    }
                }
                .disabled(viewModel.isLoading)
            }
            
            Section("Backup & Restore") {
                Button("Export Settings") {
                    viewModel.showExportSheet()
                }
                .disabled(viewModel.isLoading)
                
                Button("Import Settings") {
                    viewModel.showImportSheet()
                }
                .disabled(viewModel.isLoading)
            }
            
            Section("Reset") {
                Button("Reset All Settings", role: .destructive) {
                    viewModel.showResetConfirmation()
                }
                .disabled(viewModel.isLoading)
            }
            
            Section("Storage Information") {
                let storageUsage = viewModel.calculateStorageUsage()
                
                HStack {
                    Text("Settings Storage")
                    Spacer()
                    Text(formatBytes(storageUsage.totalSizeBytes))
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Preference Items")
                    Spacer()
                    Text("\(storageUsage.itemCount)")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Data Management")
        .confirmationDialog(
            "Reset All Settings",
            isPresented: $viewModel.showingResetConfirmation
        ) {
            Button("Reset", role: .destructive) {
                Task {
                    await viewModel.resetApp()
                }
            }
            Button("Cancel", role: .cancel) {
                viewModel.cancelReset()
            }
        }
        .sheet(isPresented: $viewModel.showingExportSheet) {
            ExportDataSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingImportSheet) {
            ImportDataSheet(viewModel: viewModel)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct AboutView: View {
    private var appInfo: AppInformation {
        AppInformation(
            appName: "HeyKidsWatchThis",
            version: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0",
            buildNumber: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1",
            privacyPolicyURL: "https://example.com/privacy",
            termsOfServiceURL: "https://example.com/terms",
            supportEmail: "support@heykidswatchthis.com"
        )
    }
    
    var body: some View {
        Form {
            Section("App Information") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(appInfo.version)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text(appInfo.buildNumber)
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Support") {
                Link("Contact Support", destination: URL(string: "mailto:\(appInfo.supportEmail)")!)
                Link("Privacy Policy", destination: URL(string: appInfo.privacyPolicyURL)!)
                Link("Terms of Service", destination: URL(string: appInfo.termsOfServiceURL)!)
            }
            
            Section("About") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("HeyKidsWatchThis")
                        .font(.headline)
                    
                    Text("A family movie night planning app designed to help parents discover age-appropriate movies and create lasting memories with their children.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("About")
    }
}

// ============================================================================
// MARK: - Export/Import Sheets
// ============================================================================

struct ExportDataSheet: View {
    @Bindable var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var exportedData: String = ""
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
                
                Text("Export Your Data")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Export your preferences and settings to share with other devices or create a backup.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                if !exportedData.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Export Preview:")
                            .font(.headline)
                        
                        ScrollView {
                            Text(exportedData)
                                .font(.system(.caption, design: .monospaced))
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .frame(maxHeight: 200)
                        
                        Button("Share Export Data") {
                            showingShareSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                } else {
                    Button("Generate Export") {
                        Task {
                            await generateExport()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isLoading)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [exportedData])
            }
        }
    }
    
    private func generateExport() async {
        let result = await viewModel.exportUserData()
        switch result {
        case .success(let data):
            exportedData = data
        case .failure:
            break
        }
    }
}

struct ImportDataSheet: View {
    @Bindable var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var importText: String = ""
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)
                
                Text("Import Your Data")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Import previously exported data to restore your preferences and settings.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Paste Export Data:")
                        .font(.headline)
                    
                    TextEditor(text: $importText)
                        .font(.system(.caption, design: .monospaced))
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .frame(minHeight: 150)
                    
                    Button("Import Data") {
                        Task {
                            await importData()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(importText.isEmpty || viewModel.isLoading)
                    .frame(maxWidth: .infinity)
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Import Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Import Successful", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your data has been successfully imported.")
            }
        }
    }
    
    private func importData() async {
        let result = await viewModel.importUserData(importText)
        switch result {
        case .success:
            showingSuccess = true
            importText = ""
        case .failure:
            break
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
