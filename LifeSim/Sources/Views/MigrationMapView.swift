import SwiftUI
import MapKit

struct MigrationMapView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 15, longitude: 10),
            span: MKCoordinateSpan(latitudeDelta: 150, longitudeDelta: 150)
        )
    )
    @State private var selectedCountry: String?
    @State private var quizSession: MigrationQuizSession?

    var character: Character { viewModel.character! }

    private var destinations: [(name: String, profile: CountryProfile)] {
        CountryData.profiles
            .filter { $0.key != character.country }
            .map { (name: $0.key, profile: $0.value) }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(position: $cameraPosition) {
                    ForEach(destinations, id: \.name) { destination in
                        Annotation(destination.name, coordinate: CLLocationCoordinate2D(latitude: destination.profile.latitude, longitude: destination.profile.longitude)) {
                            Button {
                                withAnimation { selectedCountry = destination.name }
                            } label: {
                                VStack(spacing: 2) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(selectedCountry == destination.name ? .red : .accentColor)
                                    Text(destination.name)
                                        .font(.caption2.bold())
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
                .mapStyle(.standard)

                if let selectedCountry, let profile = CountryData.profiles[selectedCountry] {
                    destinationCard(country: selectedCountry, profile: profile)
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("Migrate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("💰 $\(character.cash)")
                        .font(.headline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(item: $quizSession) { session in
                MigrationQuizView(viewModel: viewModel, session: session)
            }
        }
    }

    @ViewBuilder
    private func destinationCard(country: String, profile: CountryProfile) -> some View {
        let cost = MigrationData.migrationCost(for: profile)
        VStack(spacing: 10) {
            Text(country)
                .font(.title3.bold())
            Text("Known for \(profile.landmark)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Visa + relocation: $\(cost)")
                .font(.subheadline.bold())

            if let message = viewModel.migrationEligibilityMessage(to: country) {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            } else {
                Button("Apply for Visa") {
                    quizSession = viewModel.startMigration(to: country)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(radius: 8, y: 4)
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    return MigrationMapView(viewModel: vm)
}
