import SwiftUI

// Global State
class NavigationState: ObservableObject {
    @Published var selectedTab: MenuTabView = .dashboard
    @Published var dashboardNavigation: [DashboardNavDestination] = []
    @Published var inboxNavigation: [InboxNavDestination] = []
    @Published var calendarNavigation: [CalendarNavDestination] = []
    @Published var propertyNavigation: [PropertyNavDestination] = []

    func switchToTab(_ tab: MenuTabView) {
        selectedTab = tab
    }
}

struct RootHomeView: View {
    @StateObject var navState = NavigationState()

    var body: some View {
        ScrollViewReader { proxy in
            TabView(selection: createTabViewBinding(scrollViewProxy: proxy)) {
                DashboardView()
                    .tag(MenuTabView.dashboard)
                    .tabItem {
                        Label("Dashboard", systemImage: "newspaper")
                    }

                InboxView()
                    .tag(MenuTabView.inbox)
                    .tabItem {
                        Label("Inbox", systemImage: "envelope")
                    }

                CalendarView()
                    .tag(MenuTabView.inventory)
                    .tabItem {
                        Label("Inventory", systemImage: "calendar")
                    }

                PropertyView()
                    .tag(MenuTabView.properties)
                    .tabItem {
                        Label("Property", systemImage: "house")
                    }

            }
            .accentColor(.orange)
            .environmentObject(navState)
        }
    }

    private func createTabViewBinding(scrollViewProxy: ScrollViewProxy) -> Binding<MenuTabView> {
        Binding<MenuTabView>(
            get: { navState.selectedTab },
            set: { selectedTab in
                if selectedTab == navState.selectedTab {
                    print("tapped same tab")

                    switch selectedTab {
                    case .dashboard:
                        withAnimation {
                            navState.dashboardNavigation = []
                        }
                    case .inbox:
                        withAnimation {
                            navState.calendarNavigation = []
                        }
                    case .inventory:
                        withAnimation {
                            navState.inboxNavigation = []
                        }
                    case .properties:
                        withAnimation {
                            navState.propertyNavigation = []
                        }
                    }
                }
                navState.selectedTab = selectedTab
            }
        )
    }
}

// NavigationStack
struct DashboardView: View {
    @EnvironmentObject var navState: NavigationState

    var body: some View {
        NavigationStack(path: $navState.dashboardNavigation) {
            VStack {
                // add some view here
                Text("Vrbo Dashboard")

                NavigationLink(value: DashboardNavDestination.calendar) {
                    Text("Open SubView")
                }
                .padding()
                Button(action: {
                    navState.switchToTab(.inbox)
                }) {
                    Text("Go to Inbox")
                }
                .padding()
            }
            .padding()
            .navigationTitle("Dashboard")
            .navigationDestination(for: DashboardNavDestination.self) { destination in
                switch destination {
                case .calendar:
                    SpecificDateSubView()
                case .inbox:
                    InboxSubViewView()
                }
            }
        }
    }
}

struct InboxView: View {
    @EnvironmentObject var navState: NavigationState

    var body: some View {
        NavigationStack(path: $navState.inboxNavigation) {
            VStack {
                Text("Inbox View")

                NavigationLink(value: InboxNavDestination.properties) {
                    Text("Open subView 1")
                }
                .padding()
            }
            .padding()
            .navigationTitle("Inbox")
            .navigationDestination(for: InboxNavDestination.self) { destination in
                switch destination {
                case .properties:
                    OldAndBustedView()
                case .chat:
                    Text("Chat Here")
                }
            }
        }
    }
}

struct CalendarView: View {
    @EnvironmentObject var navState: NavigationState

    var body: some View {
        NavigationStack(path: $navState.calendarNavigation) {
            VStack {
                Text("CalendarView")

                NavigationLink(value: CalendarNavDestination.specificDate) {
                    Text("Open Date")
                }
                .padding()
            }
            .padding()
            .navigationTitle("Calendar")
            .navigationDestination(for: CalendarNavDestination.self) { destination in
                switch destination {
                case .specificDate:
                    SpecificDateSubView()
                case .properties:
                    PropertyView()
                }
            }
        }
    }
}

struct PropertyView: View {
    @EnvironmentObject var navState: NavigationState

    var body: some View {
        NavigationStack(path: $navState.propertyNavigation) {
            List {
                Section {
                    NavigationLink(value: PropertyNavDestination.propertyDetails) {
                        Text("Open Property details")
                    }
                }

                Section {
                    ForEach(0..<20) { index in
                        Text("\(index)")
                    }
                }
            }
            .navigationTitle("Property List")
            .navigationDestination(for: PropertyNavDestination.self) { destination in
                switch destination {
                case .propertyDetails:
                    SpecificDateSubView()
                }
            }
        }
    }
}

// --- Sub Views ----
struct InboxSubViewView: View {
    var body: some View {
        ZStack {
            Color.yellow
            VStack {
                Text("View 1")

                NavigationLink(value: DashboardNavDestination.calendar) {
                    Text("Open subview view 1")
                }
            }
            .padding()
            .navigationTitle("Inbox SubView")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PropertySubView: View {
    var body: some View {
        ZStack {
            Color.teal
            VStack {
                Text("Property")
            }
            .padding()
            .navigationTitle("Property Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SpecificDateSubView: View {
    @State private var text = String()
    var body: some View {
        ZStack {
            Color.green
            VStack {
                Text("Date")
                TextField("Wtrite something...", text: $text)
            }
            .padding()
            .navigationTitle("Property Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

class OldAndBustedViewModel: ObservableObject {
    @Published var name: String
    @Published var age: Int
    
    init() {
        name = "Nutter Fi"
        age = 1356
    }
    
    func updateAge(_ age: Int) {
        self.age = age
    }
    
    func updateName(_ name: String) {
        self.name = name
    }
    
    func randomAge() {
        self.age = Int.random(in: 200...500)
    }
}

extension Color {
    static var random: Color {
        let r = Double.random(in: 0...1)
        let g = Double.random(in: 0...1)
        let b = Double.random(in: 0...1)
        
        return Color(red:r, green: g, blue: b)
    }
}

struct OldAndBustedView: View {
    @StateObject private var viewModel = OldAndBustedViewModel()
    @State private var color = Color.red.opacity(0.4)
    var body: some View {
        ZStack {
            color.ignoresSafeArea()
            VStack {
                Text(viewModel.name)
                    .font(.title)
                Text("\(viewModel.age)")
                    .font(.subheadline)
                Button(action: {
                    viewModel.randomAge()
                }, label: {
                    Text("Random Age")
                        .padding()
                })
                .buttonBorderShape(.capsule)
                .buttonStyle(BorderedButtonStyle())
            }
            .onChange(of: viewModel.age) { oldValue in
                color = Color.random.opacity(Double.random(in: 0...1))
            }
//            .onChange(of: viewModel.age) { oldValue, newValue in
//                color = Color.random.opacity(0.4)
//            }
        }
    }
}

struct RootHomeView_Previews: PreviewProvider {
    static var previews: some View {
        RootHomeView()
    }
}
