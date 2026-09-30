import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showingShop = false
    @State private var showingDoctor = false
    @State private var showingCareer = false
    @State private var selectedPerson: PersonSelection?

    var character: Character { viewModel.character! }

    var body: some View {
        Group {
            ScrollView {
                VStack(spacing: 16) {
                    header
                    statsCard
                    FamilyView(family: character.family) { selectedPerson = $0 }
                    FriendsView(friends: character.friends, stage: character.stage) { selectedPerson = $0 }
                    eventLog
                }
                .padding()
                .padding(.bottom, 90)
            }
            .overlay(alignment: .bottom) {
                ageUpButton
            }
        }
        .blur(radius: character.hasUncorrectedVision ? 3.5 : 0)
        .animation(.easeInOut, value: character.hasUncorrectedVision)
        .overlay(alignment: .top) {
            if character.hasUncorrectedVision {
                Text("👓 Vision is blurry — try glasses from the Shop")
                    .font(.caption.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.yellow.opacity(0.9))
                    .clipShape(Capsule())
                    .padding(.top, 8)
                    .transition(.opacity)
            }
        }
        .sheet(isPresented: $showingShop) {
            ShopView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingDoctor) {
            DoctorView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingCareer) {
            CareerView(viewModel: viewModel)
        }
        .sheet(item: $selectedPerson) { person in
            PersonDetailView(viewModel: viewModel, person: person)
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            AvatarView(seed: character.fullName, gender: character.gender, stage: character.stage, equipped: character.equippedAccessories, scars: character.scars)
                .frame(width: 110, height: 110)
                .background(Color(.secondarySystemBackground))
                .clipShape(Circle())
            Text(character.fullName)
                .font(.title2.bold())
            Text("Age \(character.age) · \(character.country)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let job = character.job {
                Text(job.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 10) {
                Button {
                    showingShop = true
                } label: {
                    Label("$\(character.cash) · Shop", systemImage: "bag.fill")
                        .font(.subheadline.bold())
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)

                Button {
                    showingDoctor = true
                } label: {
                    Label("Doctor", systemImage: "stethoscope")
                        .font(.subheadline.bold())
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)

                Button {
                    showingCareer = true
                } label: {
                    Label("Career", systemImage: "briefcase.fill")
                        .font(.subheadline.bold())
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var statsCard: some View {
        VStack(spacing: 12) {
            StatBarView(label: "Health", value: character.stats.health, color: .red)
            StatBarView(label: "Happiness", value: character.stats.happiness, color: .yellow)
            StatBarView(label: "Smarts", value: character.stats.smarts, color: .blue)
            StatBarView(label: "Looks", value: character.stats.looks, color: .purple)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var eventLog: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("This Year")
                .font(.headline)
            if viewModel.yearLog.isEmpty {
                Text("Nothing happened yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.yearLog) { entry in
                    Text("• \(entry.text)")
                        .font(.subheadline)
                        .foregroundStyle(entry.isAlert ? .red : .primary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var ageUpButton: some View {
        Button {
            withAnimation { viewModel.ageUp() }
        } label: {
            Text("Age Up (+1 year)")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
        .background(
            LinearGradient(colors: [.clear, Color(.systemBackground)], startPoint: .top, endPoint: .bottom)
                .frame(height: 110)
                .allowsHitTesting(false),
            alignment: .top
        )
    }
}

#Preview {
    let vm = GameViewModel()
    vm.startNewLife()
    return GameView(viewModel: vm)
}
